#define UNICODE
#define _UNICODE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>
#include <shellapi.h>
#include <shlwapi.h>
#include <dwmapi.h>
#include <winver.h>
#include <tlhelp32.h>
#include <filesystem>
#include <string>
#include <vector>
#include <algorithm>
#include <fstream>
#include <sstream>
#include <cwctype>
#include <cstring>
#include <cwchar>
#include <memory>
#include <unordered_set>

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "dwmapi.lib")
#pragma comment(lib, "version.lib")
#pragma comment(lib, "advapi32.lib")

namespace fs = std::filesystem;
namespace {
constexpr UINT WM_TRAY = WM_APP + 1;
constexpr int ID_HOTKEY = 1010;
constexpr int ID_OPEN = 1101, ID_RUN_ADMIN = 1102, ID_FOLDER = 1103, ID_FAVORITE = 1104, ID_AUTOSTART = 1105, ID_HIDE = 1106;
constexpr UINT ID_TRAY_OPEN = 2001, ID_TRAY_REFRESH = 2002, ID_TRAY_ROOT = 2003, ID_TRAY_EXIT = 2004;
constexpr UINT ID_CATEGORY_ALL = 3000, ID_CATEGORY_HIDDEN = 3002, ID_CATEGORY_BASE = 3100;
constexpr UINT ID_CONTEXT_CATEGORY_BASE = 4100, ID_CONTEXT_NEW_CATEGORY = 4200;
constexpr UINT ID_SORT_USAGE=4301,ID_SORT_NAME_ASC=4302,ID_SORT_NAME_DESC=4303,ID_WINDOWS_AUTOSTART=4304;
constexpr UINT_PTR TIMER_TRAY_RETRY = 2, TIMER_AUTOSTART = 3;
constexpr int IDD_CATEGORY_PROMPT = 500, IDC_CATEGORY_PROMPT = 501;
constexpr wchar_t kClassName[] = L"PortableAppsStartNativeWindow";
constexpr wchar_t kPromptClassName[] = L"PortableAppsStartCategoryPrompt";
constexpr wchar_t kRunKey[] = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr wchar_t kRunValue[] = L"PortableAppsStart";
constexpr wchar_t kCategoryAll[] = L"@all", kCategoryHidden[] = L"@hidden";
struct App { std::wstring folder, relativeKey, configKey, legacyConfigKey, name, category, launcher, iconPath; HICON icon{}; int iconWidth=32,iconHeight=32; unsigned long long launchCount=0; bool favorite = false, autoStart = false, hidden = false; };
struct TileHit { RECT rect{}; int appIndex=-1; };
struct MenuDrawInfo { std::wstring text; };

HINSTANCE g_instance{}; HWND g_window{};
HICON g_icon{}; NOTIFYICONDATAW g_nid{};
std::vector<App> g_apps; std::vector<std::wstring> g_categories, g_userCategories;
std::vector<TileHit> g_tileHits;
fs::path g_moduleDir, g_appsDir, g_dataDir, g_iniPath;
fs::path g_legacyIniPath;
std::wstring g_legacyIniText, g_userIniText, g_currentCategory=kCategoryAll;
bool g_refreshing = false, g_draggingWindow=false;
HFONT g_font{}, g_smallFont{}, g_titleFont{};
UINT g_taskbarCreated{};
int g_scrollY=0, g_contentHeight=0, g_hoverApp=-1, g_contextApp=-1;
RECT g_categoryRect{};
RECT g_scrollHit{},g_scrollThumb{};int g_scrollViewport=0,g_scrollMaximum=0,g_scrollDragStart=0,g_scrollDragOrigin=0;bool g_scrollHover=false,g_scrollDragging=false;
std::wstring g_promptResult;
bool g_restoringPosition=false;
std::wstring g_sortMode=L"Usage";bool g_windowsAutostart=false;
std::vector<std::unique_ptr<MenuDrawInfo>> g_menuDrawStorage;
HBRUSH g_menuBackgroundBrush{},g_promptBackgroundBrush{},g_promptEditBrush{};
std::wstring trim(std::wstring s);
int scaleFor(HWND w,int value);
LRESULT CALLBACK PromptWndProc(HWND w,UINT msg,WPARAM wp,LPARAM lp) {
    switch(msg) {
    case WM_ERASEBKGND:return 1;
    case WM_PAINT:{PAINTSTRUCT ps{};HDC dc=BeginPaint(w,&ps);RECT client{};GetClientRect(w,&client);if(!g_promptBackgroundBrush)g_promptBackgroundBrush=CreateSolidBrush(RGB(30,32,37));FillRect(dc,&client,g_promptBackgroundBrush);SetBkMode(dc,TRANSPARENT);SetTextColor(dc,RGB(242,243,245));auto old=(HFONT)SelectObject(dc,g_font);RECT title{scaleFor(w,18),scaleFor(w,8),client.right-scaleFor(w,50),scaleFor(w,34)};DrawTextW(dc,L"Новая категория",-1,&title,DT_LEFT|DT_VCENTER|DT_SINGLELINE);RECT close{client.right-scaleFor(w,38),scaleFor(w,7),client.right-scaleFor(w,12),scaleFor(w,34)};DrawTextW(dc,L"×",1,&close,DT_CENTER|DT_VCENTER|DT_SINGLELINE);SelectObject(dc,old);EndPaint(w,&ps);return 0;}
    case WM_CTLCOLORSTATIC:{HDC dc=(HDC)wp;SetTextColor(dc,RGB(226,228,232));SetBkMode(dc,TRANSPARENT);if(!g_promptBackgroundBrush)g_promptBackgroundBrush=CreateSolidBrush(RGB(30,32,37));return (LRESULT)g_promptBackgroundBrush;}
    case WM_CTLCOLOREDIT:{HDC dc=(HDC)wp;SetTextColor(dc,RGB(246,247,249));SetBkColor(dc,RGB(49,52,58));if(!g_promptEditBrush)g_promptEditBrush=CreateSolidBrush(RGB(49,52,58));return (LRESULT)g_promptEditBrush;}
    case WM_DRAWITEM:{auto* draw=(DRAWITEMSTRUCT*)lp;if(draw&&draw->CtlType==ODT_BUTTON){const bool pressed=(draw->itemState&ODS_SELECTED)!=0;HBRUSH brush=CreateSolidBrush(pressed?RGB(78,82,90):RGB(61,65,72));FillRect(draw->hDC,&draw->rcItem,brush);DeleteObject(brush);SetBkMode(draw->hDC,TRANSPARENT);SetTextColor(draw->hDC,RGB(245,246,248));auto old=(HFONT)SelectObject(draw->hDC,g_smallFont);wchar_t text[64]{};GetWindowTextW(draw->hwndItem,text,64);RECT r=draw->rcItem;DrawTextW(draw->hDC,text,-1,&r,DT_CENTER|DT_VCENTER|DT_SINGLELINE);SelectObject(draw->hDC,old);return TRUE;}break;}
    case WM_NCHITTEST:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};ScreenToClient(w,&p);RECT r{};GetClientRect(w,&r);if(p.y<scaleFor(w,40)&&p.x<r.right-scaleFor(w,42))return HTCAPTION;return HTCLIENT;}
    case WM_LBUTTONUP:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};RECT r{};GetClientRect(w,&r);if(p.y<scaleFor(w,40)&&p.x>=r.right-scaleFor(w,42)){DestroyWindow(w);return 0;}break;}
    case WM_KEYDOWN:if(wp==VK_ESCAPE){SendMessageW(w,WM_COMMAND,IDCANCEL,0);return 0;}break;
    case WM_COMMAND:if(LOWORD(wp)==IDOK||LOWORD(wp)==IDCANCEL){if(LOWORD(wp)==IDOK){HWND edit=GetDlgItem(w,IDC_CATEGORY_PROMPT);const int length=GetWindowTextLengthW(edit);if(length>0&&length<32768){std::wstring value((size_t)length+1,L'\0');const int copied=GetWindowTextW(edit,value.data(),length+1);value.resize((size_t)(std::max)(0,copied));g_promptResult=trim(std::move(value));}}DestroyWindow(w);return 0;}break;
    case WM_CLOSE:DestroyWindow(w);return 0;
    }
    return DefWindowProcW(w,msg,wp,lp);
}

std::wstring trim(std::wstring s) {
    auto ws = [](wchar_t c) { return std::iswspace(c) != 0; };
    auto a = std::find_if_not(s.begin(), s.end(), ws), b = std::find_if_not(s.rbegin(), s.rend(), ws).base();
    if (a >= b) return L""; return std::wstring(a, b);
}
std::wstring lower(std::wstring s) { std::transform(s.begin(), s.end(), s.begin(), towlower); return s; }
std::wstring readText(const fs::path& p) {
    constexpr DWORD maxIniBytes=16*1024*1024;
    HANDLE file=CreateFileW(p.c_str(),GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE,nullptr,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr);
    if(file==INVALID_HANDLE_VALUE)return {};
    LARGE_INTEGER size{};
    if(!GetFileSizeEx(file,&size)||size.QuadPart<=0||size.QuadPart>maxIniBytes){CloseHandle(file);return {};}
    std::string bytes((size_t)size.QuadPart,'\0');DWORD total=0;
    while(total<(DWORD)bytes.size()){
        DWORD read=0;const DWORD remaining=(DWORD)bytes.size()-total;
        if(!ReadFile(file,bytes.data()+total,remaining,&read,nullptr)||read==0){CloseHandle(file);return {};}
        total+=read;
    }
    CloseHandle(file);
    if (bytes.size() >= 2 && (BYTE)bytes[0] == 0xFF && (BYTE)bytes[1] == 0xFE) {
        if((bytes.size()-2)%2!=0)return {};
        std::wstring w((bytes.size() - 2) / 2, L'\0'); memcpy(w.data(), bytes.data() + 2, w.size() * 2); return w;
    }
    if (bytes.size() >= 2 && (BYTE)bytes[0] == 0xFE && (BYTE)bytes[1] == 0xFF) {
        if((bytes.size()-2)%2!=0)return {};
        std::wstring w((bytes.size() - 2) / 2, L'\0');
        for (size_t i=0;i<w.size();++i) w[i]=(wchar_t)(((BYTE)bytes[2+i*2]<<8)|(BYTE)bytes[3+i*2]); return w;
    }
    const char* data = bytes.data(); int len = (int)bytes.size();
    if (len >= 3 && (BYTE)data[0] == 0xEF && (BYTE)data[1] == 0xBB && (BYTE)data[2] == 0xBF) { data += 3; len -= 3; }
    int n = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, data, len, nullptr, 0);
    if (n) { std::wstring w(n, L'\0'); MultiByteToWideChar(CP_UTF8, 0, data, len, w.data(), n); return w; }
    n = MultiByteToWideChar(CP_ACP, 0, data, len, nullptr, 0); std::wstring w(n, L'\0');
    if (n) MultiByteToWideChar(CP_ACP, 0, data, len, w.data(), n); return w;
}
std::wstring ini(const std::wstring& text, const std::wstring& section, const std::wstring& key, const std::wstring& fallback = L"") {
    std::wistringstream in(text); std::wstring line, current; const auto want = lower(section);
    while (std::getline(in, line)) {
        line = trim(line); if (line.empty() || line[0] == L';' || line[0] == L'#') continue;
        if (line.front() == L'[' && line.back() == L']') { current = lower(trim(line.substr(1, line.size()-2))); continue; }
        if (current != want) continue; auto eq = line.find(L'='); if (eq == std::wstring::npos) continue;
        if (lower(trim(line.substr(0, eq))) == lower(key)) return trim(line.substr(eq+1));
    }
    return fallback;
}
bool hasIniKey(const std::wstring& text, const std::wstring& section, const std::wstring& key) {
    std::wistringstream in(text); std::wstring line, current; const auto wantSection=lower(section), wantKey=lower(key);
    while(std::getline(in,line)) {
        line=trim(line); if(line.empty()||line[0]==L';'||line[0]==L'#')continue;
        if(line.front()==L'['&&line.back()==L']'){current=lower(trim(line.substr(1,line.size()-2)));continue;}
        if(current!=wantSection)continue;auto eq=line.find(L'=');if(eq==std::wstring::npos)continue;
        if(lower(trim(line.substr(0,eq)))==wantKey)return true;
    }
    return false;
}
bool isTrue(const std::wstring& v) { auto x=lower(trim(v)); return x==L"true" || x==L"1" || x==L"yes"; }
bool existsDir(const fs::path& p) { std::error_code e; return fs::is_directory(p, e); }
fs::path findAppsRoot() {
    if (lower(g_moduleDir.filename().wstring()) == L"portableapps.com") return g_moduleDir.parent_path();
    if (existsDir(g_moduleDir / L"PortableApps")) return g_moduleDir / L"PortableApps";
    fs::path cur = g_moduleDir;
    for (int i=0; i<6 && !cur.empty(); ++i, cur=cur.parent_path()) {
        if (lower(cur.filename().wstring()) == L"portableapps.com") return cur.parent_path();
        if (lower(cur.filename().wstring()) == L"portableapps") return cur;
        if (existsDir(cur / L"PortableApps")) return cur / L"PortableApps";
    }
    return g_moduleDir;
}
void setPaths() {
    wchar_t path[32768]{}; GetModuleFileNameW(nullptr, path, 32768); g_moduleDir=fs::path(path).parent_path();
    g_appsDir=findAppsRoot();
    if(fs::is_regular_file(g_moduleDir/L"Data"/L"PortableAppsMenu.ini"))g_dataDir=g_moduleDir/L"Data";
    else if(existsDir(g_appsDir/L"PortableApps.com"/L"Data"))g_dataDir=g_appsDir/L"PortableApps.com"/L"Data";
    else g_dataDir=g_moduleDir/L"Data";
    g_iniPath=g_dataDir/L"PortableAppsStart.ini";
    g_legacyIniPath=g_dataDir/L"PortableAppsMenu.ini"; g_legacyIniText=readText(g_legacyIniPath);
    std::error_code e; fs::create_directories(g_dataDir, e);
    g_userIniText=readText(g_iniPath);
    g_sortMode=ini(g_userIniText,L"Sort",L"Mode",L"Usage");
}
HICON makeIcon(int size) {
    if(size<=0)return nullptr;
    HDC screen=GetDC(nullptr);if(!screen)return nullptr;
    HDC dc=CreateCompatibleDC(screen);if(!dc){ReleaseDC(nullptr,screen);return nullptr;}
    HBITMAP color=CreateCompatibleBitmap(screen,size,size);if(!color){DeleteDC(dc);ReleaseDC(nullptr,screen);return nullptr;}
    HGDIOBJ old=SelectObject(dc,color);if(!old||old==HGDI_ERROR){DeleteObject(color);DeleteDC(dc);ReleaseDC(nullptr,screen);return nullptr;}
    HBRUSH clear=CreateSolidBrush(RGB(20,39,66));if(!clear){SelectObject(dc,old);DeleteObject(color);DeleteDC(dc);ReleaseDC(nullptr,screen);return nullptr;}
    RECT r{0,0,size,size};FillRect(dc,&r,clear);DeleteObject(clear);
    bool ok=true;
    auto tile=[&](int x,int y,int w,int h,COLORREF c){ HBRUSH b=CreateSolidBrush(c);if(!b){ok=false;return;}RECT q{x,y,x+w,y+h};FillRect(dc,&q,b);DeleteObject(b); };
    const int m=size/8, gap=size/12, tw=(size-2*m-gap)/2, top=size/6;
    tile(m,top,tw,tw,RGB(50,150,245)); tile(m+tw+gap,top,tw,tw,RGB(113,190,247));
    tile(m,top+tw+gap,tw,tw,RGB(113,190,247)); tile(m+tw+gap,top+tw+gap,tw,tw,RGB(166,213,250));
    SelectObject(dc,old); DeleteDC(dc); ReleaseDC(nullptr,screen);
    if(!ok){DeleteObject(color);return nullptr;}
    HBITMAP mask=CreateBitmap(size,size,1,1,nullptr);if(!mask){DeleteObject(color);return nullptr;}
    ICONINFO ii{};ii.fIcon=TRUE;ii.hbmColor=color;ii.hbmMask=mask;
    HICON icon=CreateIconIndirect(&ii);DeleteObject(color);DeleteObject(mask);return icon;
}
bool saveIniValue(const wchar_t* section,const std::wstring& key,const std::wstring& value,bool notify=true) {
    if(WritePrivateProfileStringW(section,key.c_str(),value.c_str(),g_iniPath.c_str())){g_userIniText=readText(g_iniPath);return true;}
    if(notify&&g_window)MessageBoxW(g_window,L"Не удалось сохранить настройки PortableApps Start. Проверьте доступность файла Data\\PortableAppsStart.ini и свободное место.",L"PortableApps Start",MB_ICONWARNING|MB_SETFOREGROUND);
    return false;
}
bool saveFavorite(const App& app) {return saveIniValue(L"Favorites",app.configKey,app.favorite?L"true":L"false");}
bool saveAutoStart(const App& app) {return saveIniValue(L"AutoStart",app.configKey,app.autoStart?L"true":L"false");}
bool saveHidden(const App& app) {return saveIniValue(L"HiddenApps",app.configKey,app.hidden?L"true":L"false");}
void saveLaunchCount(const App& app) {saveIniValue(L"LaunchCount",app.configKey,std::to_wstring(app.launchCount),false);}
bool saveSortMode() {return saveIniValue(L"Sort",L"Mode",g_sortMode);}
bool isWindowsAutostartEnabled() {
    HKEY key{};if(RegOpenKeyExW(HKEY_CURRENT_USER,kRunKey,0,KEY_QUERY_VALUE,&key)!=ERROR_SUCCESS)return false;
    DWORD type=0,size=0;const LONG status=RegQueryValueExW(key,kRunValue,nullptr,&type,nullptr,&size);RegCloseKey(key);return status==ERROR_SUCCESS&&type==REG_SZ;
}
bool setWindowsAutostart(bool enabled) {
    HKEY key{};DWORD disposition=0;if(RegCreateKeyExW(HKEY_CURRENT_USER,kRunKey,0,nullptr,0,KEY_SET_VALUE,nullptr,&key,&disposition)!=ERROR_SUCCESS)return false;
    LONG status=ERROR_SUCCESS;
    if(enabled){wchar_t path[32768]{};DWORD len=GetModuleFileNameW(nullptr,path,(DWORD)(sizeof(path)/sizeof(path[0])));if(!len||len>=sizeof(path)/sizeof(path[0]))status=ERROR_BUFFER_OVERFLOW;else{std::wstring command=L"\""+std::wstring(path,len)+L"\"";status=RegSetValueExW(key,kRunValue,0,REG_SZ,(const BYTE*)command.c_str(),(DWORD)((command.size()+1)*sizeof(wchar_t)));}}
    else {status=RegDeleteValueW(key,kRunValue);if(status==ERROR_FILE_NOT_FOUND)status=ERROR_SUCCESS;}
    RegCloseKey(key);return status==ERROR_SUCCESS;
}
void saveWindowPosition(HWND w) {
    if(!w||g_restoringPosition||!IsWindowVisible(w)||IsIconic(w))return;
    RECT r{};if(!GetWindowRect(w,&r))return;
    saveIniValue(L"Window",L"Left",std::to_wstring(r.left),false);
    saveIniValue(L"Window",L"Top",std::to_wstring(r.top),false);
}
std::vector<std::wstring> splitList(const std::wstring& value) {
    std::vector<std::wstring> out; std::wistringstream in(value); std::wstring item;
    while(std::getline(in,item,L'|')) { item=trim(item); if(!item.empty())out.push_back(item); }
    return out;
}
bool saveUserCategories() {
    std::wstring value; for(const auto& c:g_userCategories){if(!value.empty())value+=L"|";value+=c;}
    return saveIniValue(L"UserCategories",L"Items",value);
}
bool saveCategory(const App& app,const std::wstring& category) {return saveIniValue(L"CategoryOverride",app.configKey,category);}
std::wstring fileVersionString(const fs::path& path,const wchar_t* field) {
    DWORD ignored=0;DWORD size=GetFileVersionInfoSizeW(path.c_str(),&ignored);if(!size)return L"";
    std::vector<BYTE> data(size);if(!GetFileVersionInfoW(path.c_str(),0,size,data.data()))return L"";
    struct LangCodePage { WORD language, codePage; };
    LangCodePage* translations=nullptr;UINT count=0;
    if(VerQueryValueW(data.data(),L"\\VarFileInfo\\Translation",(void**)&translations,&count)&&count>=sizeof(LangCodePage)) {
        for(UINT i=0;i<count/sizeof(LangCodePage);++i) {
            wchar_t query[96]{};swprintf_s(query,L"\\StringFileInfo\\%04x%04x\\%s",translations[i].language,translations[i].codePage,field);
            wchar_t* value=nullptr;UINT chars=0;if(VerQueryValueW(data.data(),query,(void**)&value,&chars)&&value&&chars>1)return trim(value);
        }
    }
    wchar_t* value=nullptr;UINT chars=0;wchar_t query[96]{};
    swprintf_s(query,L"\\StringFileInfo\\040904B0\\%s",field);
    if(VerQueryValueW(data.data(),query,(void**)&value,&chars)&&value&&chars>1)return trim(value);
    return L"";
}
std::wstring appDisplayName(const fs::path& exe) {
    auto name=fileVersionString(exe,L"ProductName");if(name.empty())name=fileVersionString(exe,L"FileDescription");
    if(name.empty())name=exe.stem().wstring();return name;
}
bool isHiddenByPlatform(const std::wstring& key) { return hasIniKey(g_legacyIniText,L"AppsHidden",lower(key)); }
bool platformFavorite(const std::wstring& key) { return isTrue(ini(g_legacyIniText,L"AppsFavorite",lower(key),L"false")); }
std::wstring platformName(const std::wstring& key,const std::wstring& fallback) { return ini(g_legacyIniText,L"AppsRenamed",lower(key),fallback); }
std::wstring platformCategory(const std::wstring& key,const std::wstring& fallback) { return ini(g_legacyIniText,L"AppsRecategorized",lower(key),fallback); }
std::wstring appSetting(const App& app,const std::wstring& section,const std::wstring& fallback) {
    const auto value=ini(g_userIniText,section,app.configKey,L"__missing__");
    if(value!=L"__missing__")return value;
    // Older PAF builds stored per-app settings under the package folder. Keep
    // reading that key while new writes use the launcher-specific relative key.
    if(!app.legacyConfigKey.empty()&&app.configKey!=app.legacyConfigKey)return ini(g_userIniText,section,app.legacyConfigKey,fallback);
    return fallback;
}
void loadApps() {
    for(auto& a:g_apps)if(a.icon)DestroyIcon(a.icon);
    g_apps.clear(); g_categories.clear();
    g_userCategories=splitList(ini(g_userIniText,L"UserCategories",L"Items"));
    if (!existsDir(g_appsDir)) return;
    std::error_code ec;
    for (fs::directory_iterator it(g_appsDir,ec), end; !ec && it!=end; it.increment(ec)) {
        std::error_code entryError;if(!it->is_directory(entryError)||entryError)continue;
        const auto folder=it->path().filename().wstring(); if (lower(folder)==L"portableapps.com") continue;
        fs::path appInfo=it->path()/L"App"/L"AppInfo"/L"appinfo.ini";
        std::error_code infoError;
        if(fs::is_regular_file(appInfo,infoError)&&!infoError) {
            const auto txt=readText(appInfo); const auto appName=ini(txt,L"Details",L"Name");
            int iconCount=1;try{iconCount=(std::max)(1,std::stoi(ini(txt,L"Control",L"Icons",L"1")));}catch(...){}
            const bool singleIcon=isTrue(ini(g_legacyIniText,L"DisplayOptions",L"ShowSingleIconForMultiIconApps",L"true"));
            const int count=(iconCount>1&&!singleIcon)?iconCount:1;
            for(int iconNo=1;iconNo<=count;++iconNo) {
                const auto startKey=(iconCount>1&&!singleIcon)?L"Start"+std::to_wstring(iconNo):L"Start";
                const auto start=ini(txt,L"Control",startKey);if(start.empty())continue;
                fs::path launcher=it->path()/start;std::error_code launcherError;if(!fs::is_regular_file(launcher,launcherError)||launcherError)continue;
                const auto relKey=folder+L"\\"+fs::path(start).filename().wstring();if(isHiddenByPlatform(relKey))continue;
                App a;a.folder=folder;a.relativeKey=relKey;
                a.configKey=folder+L"\\"+fs::path(start).lexically_normal().wstring();
                if(count>1)a.configKey+=L"#icon"+std::to_wstring(iconNo);
                a.legacyConfigKey=folder;
                a.name=(iconCount>1&&!singleIcon)?ini(txt,L"Control",L"Name"+std::to_wstring(iconNo),appName):appName;
                if(a.name.empty())a.name=launcher.stem().wstring();
                a.name=platformName(relKey,a.name);a.category=platformCategory(relKey,ini(txt,L"Details",L"Category",L"Other"));
                a.launcher=launcher.wstring();const auto iconPath=ini(txt,L"Control",L"ExtractIcon");
                a.iconPath=!iconPath.empty()?(it->path()/iconPath).wstring():(it->path()/L"App"/L"AppInfo"/(iconCount>1&&!singleIcon?L"appicon"+std::to_wstring(iconNo)+L".ico":L"appicon.ico")).wstring();
                const auto ownFavorite=appSetting(a,L"Favorites",L"__missing__");a.favorite=ownFavorite==L"__missing__"?platformFavorite(relKey):isTrue(ownFavorite);
                a.autoStart=isTrue(appSetting(a,L"AutoStart",L"false"));
                a.hidden=isTrue(appSetting(a,L"HiddenApps",L"false"));
                try{a.launchCount=std::stoull(ini(g_userIniText,L"LaunchCount",a.configKey,ini(g_userIniText,L"LaunchCount",a.relativeKey,L"0")));}catch(...){}
                a.category=appSetting(a,L"CategoryOverride",a.category);
                g_apps.push_back(std::move(a));
            }
            continue;
        }
        // Match Platform 30.4's legacy-app rule: scan only EXEs directly inside
        // each app folder; ignore the uninstaller and names hidden in the menu INI.
        std::error_code nestedError;
        for(fs::directory_iterator ex(it->path(),nestedError),exEnd;!nestedError&&ex!=exEnd;ex.increment(nestedError)) {
            std::error_code fileError;
            if(!ex->is_regular_file(fileError)||fileError||lower(ex->path().extension().wstring())!=L".exe"||lower(ex->path().filename().wstring())==L"uninstall.exe")continue;
            const auto relKey=folder+L"\\"+ex->path().filename().wstring();if(isHiddenByPlatform(relKey))continue;
            App a;a.folder=folder;a.relativeKey=relKey;a.configKey=relKey;a.launcher=ex->path().wstring();
            a.name=platformName(relKey,appDisplayName(ex->path()));a.category=platformCategory(relKey,L"Other");
            const auto ownFavorite=appSetting(a,L"Favorites",L"__missing__");a.favorite=ownFavorite==L"__missing__"?platformFavorite(relKey):isTrue(ownFavorite);
            a.autoStart=isTrue(appSetting(a,L"AutoStart",L"false"));
            a.hidden=isTrue(appSetting(a,L"HiddenApps",L"false"));
            try{a.launchCount=std::stoull(ini(g_userIniText,L"LaunchCount",a.configKey,L"0"));}catch(...){}
            a.category=appSetting(a,L"CategoryOverride",a.category);
            g_apps.push_back(std::move(a));
        }
    }
    std::sort(g_apps.begin(),g_apps.end(),[](const App& a,const App& b){return lower(a.name)<lower(b.name);});
    for (const auto& a:g_apps) if (std::find(g_categories.begin(),g_categories.end(),a.category)==g_categories.end()) g_categories.push_back(a.category);
    for(const auto& c:g_userCategories)if(std::find(g_categories.begin(),g_categories.end(),c)==g_categories.end())g_categories.push_back(c);
    std::sort(g_categories.begin(),g_categories.end(),[](const auto&a,const auto&b){return lower(a)<lower(b);});
    for(auto& a:g_apps) {
        if(!a.iconPath.empty())a.icon=(HICON)LoadImageW(nullptr,a.iconPath.c_str(),IMAGE_ICON,0,0,LR_LOADFROMFILE);
        if(!a.icon){SHFILEINFOW sfi{};if(SHGetFileInfoW(a.launcher.c_str(),0,&sfi,sizeof(sfi),SHGFI_ICON|SHGFI_LARGEICON))a.icon=sfi.hIcon;}
        if(a.icon){ICONINFO ii{};if(GetIconInfo(a.icon,&ii)){BITMAP bm{};HBITMAP source=ii.hbmColor?ii.hbmColor:ii.hbmMask;if(source&&GetObjectW(source,sizeof(bm),&bm)){a.iconWidth=bm.bmWidth;a.iconHeight=ii.hbmColor?bm.bmHeight:bm.bmHeight/2;}if(ii.hbmColor)DeleteObject(ii.hbmColor);if(ii.hbmMask)DeleteObject(ii.hbmMask);}}
    }
}
void sortAppIndices(std::vector<int>& items);
std::vector<int> pinnedApps() {
    std::vector<int> out;for(size_t i=0;i<g_apps.size();++i)if(g_apps[i].favorite&&!g_apps[i].hidden)out.push_back((int)i);sortAppIndices(out);return out;
}
void sortAppIndices(std::vector<int>& items) {
    std::sort(items.begin(),items.end(),[](int left,int right){const auto& a=g_apps[left];const auto& b=g_apps[right];
        if(g_sortMode==L"NameAsc")return lower(a.name)<lower(b.name);
        if(g_sortMode==L"NameDesc")return lower(a.name)>lower(b.name);
        if(a.launchCount!=b.launchCount)return a.launchCount>b.launchCount;return lower(a.name)<lower(b.name);
    });
}
std::vector<int> visibleApps() {
    std::vector<int> out;const auto cat=lower(g_currentCategory);
    for(size_t i=0;i<g_apps.size();++i) {
        const auto& a=g_apps[i];
        if(cat==kCategoryHidden){if(!a.hidden)continue;}
        else {
            if(a.hidden)continue;
            if(cat!=kCategoryAll&&lower(a.category)!=cat)continue;
        }
        out.push_back((int)i);
    }
    sortAppIndices(out);return out;
}
int scaleFor(HWND w,int value) { return MulDiv(value,(int)GetDpiForWindow(w),96); }
void addTileHit(RECT r,int appIndex) { g_tileHits.push_back({r,appIndex}); }
void drawTile(HDC dc,const App& app,int index,RECT r,bool pinned,int hover,int dpi) {
    const bool hot=hover==index;
    const int sourceW=(std::max)(1,app.iconWidth),sourceH=(std::max)(1,app.iconHeight);const double fit=32.0/(std::max)(sourceW,sourceH);
    const int iconW=scaleFor(g_window,(std::max)(1,(int)(sourceW*fit))),iconH=scaleFor(g_window,(std::max)(1,(int)(sourceH*fit)));const int ix=(r.left+r.right-iconW)/2,iy=r.top+scaleFor(g_window,8);
    if(app.icon)DrawIconEx(dc,ix,iy,app.icon,iconW,iconH,0,nullptr,DI_NORMAL);
    RECT text{r.left+scaleFor(g_window,2),r.top+scaleFor(g_window,44),r.right-scaleFor(g_window,2),r.bottom-scaleFor(g_window,2)};
    SetBkMode(dc,TRANSPARENT);SetTextColor(dc,hot?RGB(255,255,255):RGB(238,239,242));SelectObject(dc,g_smallFont);
    DrawTextW(dc,app.name.c_str(),-1,&text,DT_CENTER|DT_TOP|DT_WORDBREAK|DT_END_ELLIPSIS|DT_NOPREFIX);
    (void)pinned;(void)dpi;
}
std::wstring currentCategoryLabel() {
    if(g_currentCategory==kCategoryAll)return L"Все приложения";
    if(g_currentCategory==kCategoryHidden)return L"Скрытые приложения";
    return g_currentCategory;
}
void paintLauncher(HWND w,HDC dc) {
    RECT client{};GetClientRect(w,&client);const int dpi=(int)GetDpiForWindow(w),pad=scaleFor(w,16),header=scaleFor(w,22);
    HBRUSH bg=CreateSolidBrush(RGB(30,32,37));FillRect(dc,&client,bg);DeleteObject(bg);
    SetBkMode(dc,TRANSPARENT);
    const int contentTop=header, gap=scaleFor(w,4), cellH=scaleFor(w,82), inner=client.right-2*pad;
    const int cellW=(inner-4*gap)/5;auto pins=pinnedApps();auto apps=visibleApps();const int pinRows=(int)((pins.size()+4)/5);
    const int pinnedSection=scaleFor(w,30)+(std::max)(1,pinRows)*cellH+scaleFor(w,14);
    const int appTitleY=contentTop+pinnedSection-g_scrollY;
    g_categoryRect={client.right-pad-scaleFor(w,190),appTitleY,client.right-pad,appTitleY+scaleFor(w,34)};
    HBRUSH cb=CreateSolidBrush(RGB(47,51,58));auto ob=(HBRUSH)SelectObject(dc,cb);auto op=(HPEN)SelectObject(dc,GetStockObject(NULL_PEN));
    RoundRect(dc,g_categoryRect.left,g_categoryRect.top,g_categoryRect.right,g_categoryRect.bottom,scaleFor(w,10),scaleFor(w,10));SelectObject(dc,ob);SelectObject(dc,op);DeleteObject(cb);
    SetTextColor(dc,RGB(236,238,242));SelectObject(dc,g_smallFont);RECT ct=g_categoryRect;ct.left+=scaleFor(w,12);ct.right-=scaleFor(w,12);
    std::wstring catLabel=currentCategoryLabel()+L"   ▾";DrawTextW(dc,catLabel.c_str(),-1,&ct,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);
    const int appGridY=appTitleY+scaleFor(w,36);
    g_contentHeight=pinnedSection+scaleFor(w,42)+(int)((apps.size()+4)/5)*cellH+scaleFor(w,20);
    const int viewport=client.bottom-contentTop-scaleFor(w,8);g_scrollViewport=viewport;g_scrollMaximum=(std::max)(0,g_contentHeight-viewport);g_scrollY=std::clamp(g_scrollY,0,g_scrollMaximum);
    g_tileHits.clear();int saved=SaveDC(dc);IntersectClipRect(dc,pad,contentTop,client.right,client.bottom-scaleFor(w,10));
    SetTextColor(dc,RGB(216,220,228));RECT ph{pad,contentTop-scaleFor(w,2)-g_scrollY,client.right-pad,contentTop+scaleFor(w,22)-g_scrollY};SelectObject(dc,g_smallFont);DrawTextW(dc,L"Закреплено",-1,&ph,DT_LEFT|DT_VCENTER|DT_SINGLELINE);
    if(pins.empty()){SetTextColor(dc,RGB(150,155,165));RECT empty{pad,contentTop+scaleFor(w,38)-g_scrollY,client.right-pad,contentTop+cellH-scaleFor(w,5)-g_scrollY};DrawTextW(dc,L"Добавьте приложения в закреплённые через контекстное меню",-1,&empty,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);}
    for(size_t n=0;n<pins.size();++n){int row=(int)n/5,col=(int)n%5;RECT r{pad+col*(cellW+gap),contentTop+scaleFor(w,25)+row*cellH-g_scrollY,pad+col*(cellW+gap)+cellW,contentTop+scaleFor(w,25)+row*cellH+cellH-scaleFor(w,3)-g_scrollY};int i=pins[n];drawTile(dc,g_apps[i],i,r,true,g_hoverApp,dpi);addTileHit(r,i);}
    for(size_t n=0;n<apps.size();++n){int row=(int)n/5,col=(int)n%5;RECT r{pad+col*(cellW+gap),appGridY+row*cellH,pad+col*(cellW+gap)+cellW,appGridY+row*cellH+cellH-scaleFor(w,5)};int i=apps[n];drawTile(dc,g_apps[i],i,r,g_apps[i].favorite,g_hoverApp,dpi);addTileHit(r,i);}
    const int trackTop=contentTop,trackBottom=client.bottom-scaleFor(w,8),trackHeight=trackBottom-trackTop;
    g_scrollHit={client.right-scaleFor(w,14),trackTop,client.right,trackBottom};g_scrollThumb={};
    if(g_scrollMaximum>0&&trackHeight>0){const int thumbH=(std::max)(scaleFor(w,24),MulDiv(trackHeight,viewport,g_contentHeight));const int travel=(std::max)(0,trackHeight-thumbH);const int thumbY=trackTop+(g_scrollMaximum?MulDiv(travel,g_scrollY,g_scrollMaximum):0);const int thumbW=scaleFor(w,g_scrollHover||g_scrollDragging?8:4);g_scrollThumb={client.right-scaleFor(w,7)-thumbW/2,thumbY,client.right-scaleFor(w,7)+(thumbW+1)/2,thumbY+thumbH};HBRUSH sb=CreateSolidBrush(g_scrollHover||g_scrollDragging?RGB(147,151,158):RGB(91,95,103));auto old=(HBRUSH)SelectObject(dc,sb);RoundRect(dc,g_scrollThumb.left,g_scrollThumb.top,g_scrollThumb.right,g_scrollThumb.bottom,thumbW,thumbW);SelectObject(dc,old);DeleteObject(sb);}
    RestoreDC(dc,saved);
}
void refreshList() { if(g_window)InvalidateRect(g_window,nullptr,FALSE); }
bool resolveLauncherPath(const App& app,fs::path& resolved) {
    std::error_code ec;const auto root=fs::weakly_canonical(g_appsDir,ec);if(ec)return false;
    resolved=fs::weakly_canonical(fs::path(app.launcher),ec);if(ec||!resolved.is_absolute()||lower(resolved.extension().wstring())!=L".exe")return false;
    const auto relative=resolved.lexically_relative(root);if(relative.empty()||relative.is_absolute())return false;
    const auto first=relative.begin();if(first==relative.end()||*first==L"..")return false;
    return fs::is_regular_file(resolved,ec)&&!ec;
}
void runApp(int index,bool admin=false) {
    if(index<0||index>=(int)g_apps.size())return; auto& a=g_apps[index];
    fs::path executable;if(!resolveLauncherPath(a,executable)){MessageBoxW(g_window,L"Путь к программе должен указывать на существующий EXE внутри папки PortableApps.",a.name.c_str(),MB_ICONERROR|MB_SETFOREGROUND);return;}
    const std::wstring executablePath=executable.wstring();
    const std::wstring workingDirectory=executable.parent_path().wstring();
    SHELLEXECUTEINFOW si{};si.cbSize=sizeof(si);si.fMask=SEE_MASK_FLAG_NO_UI;si.hwnd=g_window;si.lpVerb=admin?L"runas":L"open";
    si.lpFile=executablePath.c_str();si.lpDirectory=workingDirectory.c_str();si.nShow=SW_SHOWNORMAL;
    if(!ShellExecuteExW(&si)) { DWORD e=GetLastError(); if(e!=ERROR_CANCELLED){wchar_t systemMessage[512]{};FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,nullptr,e,0,systemMessage,(DWORD)std::size(systemMessage),nullptr);std::wstring message=L"Не удалось запустить приложение.\n";message+=systemMessage;MessageBoxW(g_window,message.c_str(),a.name.c_str(),MB_ICONERROR|MB_SETFOREGROUND);} }
    else {++a.launchCount;saveLaunchCount(a);ShowWindow(g_window,SW_HIDE);}
}
std::wstring normalizedExecutablePath(const std::wstring& path) {
    std::error_code ec;const auto canonical=fs::weakly_canonical(fs::path(path),ec);
    return lower((ec?fs::path(path).lexically_normal():canonical).wstring());
}
void launchAutoStartApps() {
    std::unordered_set<std::wstring> running,requiredNames;
    for(const auto& app:g_apps)if(app.autoStart)requiredNames.insert(lower(fs::path(app.launcher).filename().wstring()));
    if(requiredNames.empty())return;
    HANDLE snap=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
    if(snap!=INVALID_HANDLE_VALUE){PROCESSENTRY32W pe{};pe.dwSize=sizeof(pe);
        if(Process32FirstW(snap,&pe))do {
            if(requiredNames.find(lower(pe.szExeFile))==requiredNames.end())continue;
            HANDLE proc=OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,FALSE,pe.th32ProcessID);if(!proc)continue;
            wchar_t path[32768]{};DWORD len=32768;
            if(QueryFullProcessImageNameW(proc,0,path,&len))running.insert(normalizedExecutablePath(std::wstring(path,len)));
            CloseHandle(proc);
        } while(Process32NextW(snap,&pe));
        CloseHandle(snap);
    }
    for(size_t i=0;i<g_apps.size();++i)if(g_apps[i].autoStart){
        const auto path=normalizedExecutablePath(g_apps[i].launcher);
        if(running.find(path)==running.end()){runApp((int)i);running.insert(path);}
    }
}
void openRoot() { ShellExecuteW(g_window,L"explore",g_appsDir.c_str(),nullptr,nullptr,SW_SHOWNORMAL); }
void toggleFavorite(int index) { if(index<0||index>=(int)g_apps.size())return;g_apps[index].favorite=!g_apps[index].favorite;if(!saveFavorite(g_apps[index]))g_apps[index].favorite=!g_apps[index].favorite;refreshList(); }
void toggleAutoStart(int index) { if(index<0||index>=(int)g_apps.size())return;g_apps[index].autoStart=!g_apps[index].autoStart;if(!saveAutoStart(g_apps[index]))g_apps[index].autoStart=!g_apps[index].autoStart;refreshList(); }
std::wstring promptCategory(HWND owner) {
    g_promptResult.clear();RECT r{};GetWindowRect(owner,&r);const int width=scaleFor(owner,380),height=scaleFor(owner,184);
    HWND dlg=CreateWindowExW(WS_EX_TOPMOST|WS_EX_TOOLWINDOW,kPromptClassName,L"",WS_POPUP|WS_VISIBLE|WS_CLIPCHILDREN,
        r.left+(r.right-r.left-width)/2,r.top+(r.bottom-r.top-height)/2,width,height,owner,nullptr,g_instance,nullptr);
    if(!dlg)return {};
    const BOOL dark=TRUE;const int corner=2,backdrop=2;DwmSetWindowAttribute(dlg,(DWMWINDOWATTRIBUTE)20,&dark,sizeof(dark));DwmSetWindowAttribute(dlg,(DWMWINDOWATTRIBUTE)33,&corner,sizeof(corner));DwmSetWindowAttribute(dlg,(DWMWINDOWATTRIBUTE)38,&backdrop,sizeof(backdrop));
    HWND label=CreateWindowExW(0,L"STATIC",L"Название категории",WS_CHILD|WS_VISIBLE,scaleFor(owner,18),scaleFor(owner,48),width-scaleFor(owner,36),scaleFor(owner,24),dlg,nullptr,g_instance,nullptr);
    HWND edit=CreateWindowExW(0,L"EDIT",L"",WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_AUTOHSCROLL,scaleFor(owner,18),scaleFor(owner,76),width-scaleFor(owner,36),scaleFor(owner,34),dlg,(HMENU)(INT_PTR)IDC_CATEGORY_PROMPT,g_instance,nullptr);
    HWND ok=CreateWindowExW(0,L"BUTTON",L"Создать",WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_OWNERDRAW|BS_DEFPUSHBUTTON,width-scaleFor(owner,176),height-scaleFor(owner,42),scaleFor(owner,78),scaleFor(owner,30),dlg,(HMENU)IDOK,g_instance,nullptr);
    HWND cancel=CreateWindowExW(0,L"BUTTON",L"Отмена",WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_OWNERDRAW,width-scaleFor(owner,90),height-scaleFor(owner,42),scaleFor(owner,74),scaleFor(owner,30),dlg,(HMENU)IDCANCEL,g_instance,nullptr);
    SendMessageW(label,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(edit,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(ok,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(cancel,WM_SETFONT,(WPARAM)g_smallFont,TRUE);
    EnableWindow(owner,FALSE);SetFocus(edit);MSG msg;
    while(IsWindow(dlg)&&GetMessageW(&msg,nullptr,0,0)>0){if(!IsDialogMessageW(dlg,&msg)){TranslateMessage(&msg);DispatchMessageW(&msg);}}
    EnableWindow(owner,TRUE);SetForegroundWindow(owner);return g_promptResult;
}
bool addUserCategory(const std::wstring& name) {
    if(name.empty()||name.find_first_of(L"|\r\n")!=std::wstring::npos)return false;
    const bool exists=std::any_of(g_userCategories.begin(),g_userCategories.end(),[&](const auto& c){return lower(c)==lower(name);});
    if(exists)return true;
    g_userCategories.push_back(name);
    if(!saveUserCategories()){g_userCategories.pop_back();return false;}
    loadApps();refreshList();return true;
}
void assignCategory(int index,const std::wstring& category) {
    if(index<0||index>=(int)g_apps.size())return;if(!saveCategory(g_apps[index],category))return;g_apps[index].category=category;
    if(std::find(g_categories.begin(),g_categories.end(),category)==g_categories.end())g_categories.push_back(category);refreshList();
}
void setDarkMenu(HMENU menu) {
    if(!g_menuBackgroundBrush)g_menuBackgroundBrush=CreateSolidBrush(RGB(42,42,42));
    MENUINFO mi{};mi.cbSize=sizeof(mi);mi.fMask=MIM_BACKGROUND;mi.hbrBack=g_menuBackgroundBrush;SetMenuInfo(menu,&mi);
}
MenuDrawInfo* makeMenuDrawInfo(const std::wstring& text) {
    auto info=std::make_unique<MenuDrawInfo>();info->text=text;auto* raw=info.get();g_menuDrawStorage.push_back(std::move(info));return raw;
}
MenuDrawInfo* findMenuDrawInfo(ULONG_PTR data) {
    for(const auto& info:g_menuDrawStorage)if(info.get()==reinterpret_cast<MenuDrawInfo*>(data))return info.get();
    return nullptr;
}
void appendDarkMenuItem(HMENU menu,UINT id,const std::wstring& text,bool checked=false,bool disabled=false) {
    MENUITEMINFOW item{};item.cbSize=sizeof(item);item.fMask=MIIM_FTYPE|MIIM_ID|MIIM_DATA|MIIM_STATE;item.fType=MFT_OWNERDRAW;item.fState=(checked?MFS_CHECKED:0)|(disabled?MFS_DISABLED:0);item.wID=id;item.dwItemData=(ULONG_PTR)makeMenuDrawInfo(text);InsertMenuItemW(menu,(UINT)GetMenuItemCount(menu),TRUE,&item);
}
void appendDarkSubmenu(HMENU menu,HMENU submenu,const std::wstring& text) {
    setDarkMenu(submenu);MENUITEMINFOW item{};item.cbSize=sizeof(item);item.fMask=MIIM_FTYPE|MIIM_DATA|MIIM_SUBMENU;item.fType=MFT_OWNERDRAW;item.dwItemData=(ULONG_PTR)makeMenuDrawInfo(text);item.hSubMenu=submenu;InsertMenuItemW(menu,(UINT)GetMenuItemCount(menu),TRUE,&item);
}
UINT trackDarkMenu(HMENU menu,POINT position) {
    SetForegroundWindow(g_window);
    const UINT command=TrackPopupMenu(menu,TPM_RETURNCMD|TPM_RIGHTBUTTON|TPM_NONOTIFY,position.x,position.y,0,g_window,nullptr);
    // Required for tray-owned popups so Windows completes menu dismissal and
    // returns the owner window to its normal message state.
    PostMessageW(g_window,WM_NULL,0,0);
    return command;
}
void showCategoryMenu() {
    g_menuDrawStorage.clear();HMENU menu=CreatePopupMenu();setDarkMenu(menu);
    appendDarkMenuItem(menu,ID_CATEGORY_ALL,L"Все приложения",g_currentCategory==kCategoryAll);
    appendDarkMenuItem(menu,ID_CATEGORY_HIDDEN,L"Скрытые приложения",g_currentCategory==kCategoryHidden);
    for(size_t i=0;i<g_categories.size()&&i<800;++i)appendDarkMenuItem(menu,ID_CATEGORY_BASE+(UINT)i,g_categories[i],g_currentCategory==g_categories[i]);
    appendDarkMenuItem(menu,ID_CONTEXT_NEW_CATEGORY,L"Создать категорию…");
    POINT p{g_categoryRect.left,g_categoryRect.bottom};ClientToScreen(g_window,&p);UINT cmd=trackDarkMenu(menu,p);DestroyMenu(menu);g_menuDrawStorage.clear();
    if(cmd==ID_CATEGORY_ALL)g_currentCategory=kCategoryAll;else if(cmd==ID_CATEGORY_HIDDEN)g_currentCategory=kCategoryHidden;
    else if(cmd>=ID_CATEGORY_BASE&&cmd<ID_CATEGORY_BASE+g_categories.size())g_currentCategory=g_categories[cmd-ID_CATEGORY_BASE];
    else if(cmd==ID_CONTEXT_NEW_CATEGORY){auto name=promptCategory(g_window);if(!name.empty()&&addUserCategory(name))g_currentCategory=name;}
    g_scrollY=0;refreshList();
}
void showAppContextMenu(int index,POINT p) {
    if(index<0||index>=(int)g_apps.size())return;g_menuDrawStorage.clear();g_contextApp=index;const auto& a=g_apps[index];HMENU menu=CreatePopupMenu();setDarkMenu(menu);
    appendDarkMenuItem(menu,ID_OPEN,L"Запустить");appendDarkMenuItem(menu,ID_RUN_ADMIN,L"Запустить от имени администратора");
    appendDarkMenuItem(menu,ID_FOLDER,L"Открыть папку приложения");
    appendDarkMenuItem(menu,ID_FAVORITE,a.favorite?L"Открепить приложение":L"Закрепить приложение",a.favorite);
    appendDarkMenuItem(menu,ID_AUTOSTART,L"Запускать вместе с PortableApps Start",a.autoStart);
    appendDarkMenuItem(menu,ID_HIDE,a.hidden?L"Показать приложение":L"Скрыть приложение",a.hidden);
    HMENU categories=CreatePopupMenu();setDarkMenu(categories);for(size_t i=0;i<g_categories.size()&&i<800;++i)appendDarkMenuItem(categories,ID_CONTEXT_CATEGORY_BASE+(UINT)i,g_categories[i],a.category==g_categories[i]);
    appendDarkMenuItem(categories,ID_CONTEXT_NEW_CATEGORY,L"Создать категорию и переместить сюда");appendDarkSubmenu(menu,categories,L"Переместить в категорию");
    appendDarkMenuItem(menu,0,L"Запусков: "+std::to_wstring(a.launchCount),false,true);
    UINT cmd=trackDarkMenu(menu,p);DestroyMenu(menu);g_menuDrawStorage.clear();
    if(cmd==ID_OPEN)runApp(index);else if(cmd==ID_RUN_ADMIN)runApp(index,true);else if(cmd==ID_FOLDER)ShellExecuteW(g_window,L"explore",fs::path(a.launcher).parent_path().c_str(),nullptr,nullptr,SW_SHOWNORMAL);
    else if(cmd==ID_FAVORITE)toggleFavorite(index);else if(cmd==ID_AUTOSTART)toggleAutoStart(index);else if(cmd==ID_HIDE){g_apps[index].hidden=!g_apps[index].hidden;if(!saveHidden(g_apps[index]))g_apps[index].hidden=!g_apps[index].hidden;g_scrollY=0;refreshList();}
    else if(cmd>=ID_CONTEXT_CATEGORY_BASE&&cmd<ID_CONTEXT_CATEGORY_BASE+g_categories.size())assignCategory(index,g_categories[cmd-ID_CONTEXT_CATEGORY_BASE]);
    else if(cmd==ID_CONTEXT_NEW_CATEGORY){auto name=promptCategory(g_window);if(!name.empty()&&addUserCategory(name))assignCategory(index,name);}
}
void appendLauncherOptions(HMENU menu) {
    HMENU sort=CreatePopupMenu();setDarkMenu(sort);
    appendDarkMenuItem(sort,ID_SORT_USAGE,L"По числу запусков",g_sortMode==L"Usage");
    appendDarkMenuItem(sort,ID_SORT_NAME_ASC,L"По имени: А — Я",g_sortMode==L"NameAsc");
    appendDarkMenuItem(sort,ID_SORT_NAME_DESC,L"По имени: Я — А",g_sortMode==L"NameDesc");
    appendDarkSubmenu(menu,sort,L"Сортировка приложений");
    appendDarkMenuItem(menu,ID_WINDOWS_AUTOSTART,L"Запускать PortableApps Start вместе с Windows",g_windowsAutostart);
}
void handleLauncherOption(UINT cmd) {
    const std::wstring previousSort=g_sortMode;
    if(cmd==ID_SORT_USAGE)g_sortMode=L"Usage";else if(cmd==ID_SORT_NAME_ASC)g_sortMode=L"NameAsc";else if(cmd==ID_SORT_NAME_DESC)g_sortMode=L"NameDesc";
    else if(cmd==ID_WINDOWS_AUTOSTART){const bool next=!g_windowsAutostart;if(setWindowsAutostart(next))g_windowsAutostart=next;else MessageBoxW(g_window,L"Не удалось изменить автозапуск Windows.",L"PortableApps Start",MB_ICONERROR);}
    else return;
    if(cmd!=ID_WINDOWS_AUTOSTART&&!saveSortMode())g_sortMode=previousSort;g_scrollY=0;refreshList();
}
void showLauncherContextMenu(POINT p) {
    g_menuDrawStorage.clear();HMENU menu=CreatePopupMenu();setDarkMenu(menu);appendLauncherOptions(menu);
    UINT cmd=trackDarkMenu(menu,p);DestroyMenu(menu);g_menuDrawStorage.clear();handleLauncherOption(cmd);
}
void showMainWindow();
void showTrayMenu() {
    g_menuDrawStorage.clear();HMENU m=CreatePopupMenu();setDarkMenu(m);appendDarkMenuItem(m,ID_TRAY_OPEN,L"Открыть PortableApps Start");appendDarkMenuItem(m,ID_TRAY_REFRESH,L"Обновить список приложений");
    appendDarkMenuItem(m,ID_TRAY_ROOT,L"Открыть папку PortableApps");appendLauncherOptions(m);appendDarkMenuItem(m,ID_TRAY_EXIT,L"Выход");
    POINT p{};GetCursorPos(&p);UINT c=trackDarkMenu(m,p);DestroyMenu(m);g_menuDrawStorage.clear();
    if(c==ID_TRAY_OPEN)showMainWindow();else if(c==ID_TRAY_REFRESH)refreshList();else if(c==ID_TRAY_ROOT)openRoot();else if(c==ID_TRAY_EXIT)DestroyWindow(g_window);else handleLauncherOption(c);
}
void showMainWindow() {
    POINT cursor{};GetCursorPos(&cursor);HMONITOR monitor=MonitorFromPoint(cursor,MONITOR_DEFAULTTONEAREST);MONITORINFO mi{sizeof(mi)};GetMonitorInfoW(monitor,&mi);
    const int dpi=(int)GetDpiForSystem(),width=(std::min)(MulDiv(560,dpi,96),(int)(mi.rcWork.right-mi.rcWork.left)-24),height=(std::min)(MulDiv(620,dpi,96),(int)(mi.rcWork.bottom-mi.rcWork.top)-24);
    int x=GetPrivateProfileIntW(L"Window",L"Left",mi.rcWork.right-width-MulDiv(16,dpi,96),g_iniPath.c_str());
    int y=GetPrivateProfileIntW(L"Window",L"Top",mi.rcWork.top+(mi.rcWork.bottom-mi.rcWork.top-height)/2,g_iniPath.c_str());
    x=std::clamp(x,(int)mi.rcWork.left,(int)mi.rcWork.right-width);y=std::clamp(y,(int)mi.rcWork.top,(int)mi.rcWork.bottom-height);
    g_restoringPosition=true;SetWindowPos(g_window,HWND_TOP,x,y,width,height,SWP_NOACTIVATE|SWP_SHOWWINDOW);g_restoringPosition=false;
    ShowWindow(g_window,SW_RESTORE);SetForegroundWindow(g_window);BringWindowToTop(g_window);SetActiveWindow(g_window);InvalidateRect(g_window,nullptr,FALSE);
}
bool addTray(HWND owner) {
    if(owner)g_window=owner;
    g_nid={};g_nid.cbSize=sizeof(g_nid);g_nid.hWnd=g_window;g_nid.uID=1;g_nid.uFlags=NIF_MESSAGE|NIF_ICON|NIF_TIP;g_nid.uCallbackMessage=WM_TRAY;g_nid.hIcon=g_icon;
    wcscpy_s(g_nid.szTip,L"PortableApps Start");
    if(!Shell_NotifyIconW(NIM_ADD,&g_nid)){SetTimer(g_window,TIMER_TRAY_RETRY,1500,nullptr);return false;}
    g_nid.uVersion=NOTIFYICON_VERSION_4;Shell_NotifyIconW(NIM_SETVERSION,&g_nid);return true;
}
void createControls(HWND w) {
    const int dpi=(int)GetDpiForWindow(w);
    g_font=CreateFontW(-MulDiv(14,dpi,96),0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI Variable Text");
    g_smallFont=CreateFontW(-MulDiv(13,dpi,96),0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI Variable Text");
    g_titleFont=CreateFontW(-MulDiv(18,dpi,96),0,0,0,FW_SEMIBOLD,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI Variable Text");
    loadApps();
}
LRESULT CALLBACK WndProc(HWND w,UINT msg,WPARAM wp,LPARAM lp) {
    if(g_taskbarCreated&&msg==g_taskbarCreated){addTray(w);return 0;}
    switch(msg) {
    case WM_MEASUREITEM:{auto* measure=(MEASUREITEMSTRUCT*)lp;if(measure&&measure->CtlType==ODT_MENU){auto* info=findMenuDrawInfo(measure->itemData);if(!info)break;HDC dc=GetDC(w);if(!dc)break;auto old=(HFONT)SelectObject(dc,g_smallFont);SIZE size{};GetTextExtentPoint32W(dc,info->text.c_str(),(int)info->text.size(),&size);SelectObject(dc,old);ReleaseDC(w,dc);measure->itemWidth=size.cx+scaleFor(w,42);measure->itemHeight=(UINT)scaleFor(w,30);return TRUE;}break;}
    case WM_DRAWITEM:{auto* draw=(DRAWITEMSTRUCT*)lp;if(draw&&draw->CtlType==ODT_MENU){auto* info=findMenuDrawInfo(draw->itemData);if(!info)break;const bool selected=(draw->itemState&ODS_SELECTED)!=0;HBRUSH bg=CreateSolidBrush(selected?RGB(62,64,68):RGB(42,42,42));if(bg){FillRect(draw->hDC,&draw->rcItem,bg);DeleteObject(bg);}SetBkMode(draw->hDC,TRANSPARENT);SetTextColor(draw->hDC,(draw->itemState&ODS_DISABLED)?RGB(130,132,136):RGB(244,245,247));auto old=(HFONT)SelectObject(draw->hDC,g_smallFont);RECT text=draw->rcItem;text.left+=scaleFor(w,34);text.right-=scaleFor(w,10);DrawTextW(draw->hDC,info->text.c_str(),-1,&text,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS|DT_NOPREFIX);if(draw->itemState&ODS_CHECKED){RECT mark=draw->rcItem;mark.left+=scaleFor(w,10);mark.right=mark.left+scaleFor(w,16);DrawTextW(draw->hDC,L"✓",1,&mark,DT_LEFT|DT_VCENTER|DT_SINGLELINE);}SelectObject(draw->hDC,old);return TRUE;}break;}
    case WM_NCCREATE:g_window=w;return DefWindowProcW(w,msg,wp,lp);
    case WM_CREATE: {
        g_window=w;createControls(w);g_windowsAutostart=isWindowsAutostartEnabled();addTray(w);
        if(!RegisterHotKey(w,ID_HOTKEY,MOD_CONTROL|MOD_ALT|MOD_NOREPEAT,VK_SPACE))MessageBoxW(w,L"Не удалось назначить Ctrl+Alt+Пробел: сочетание занято другой программой.",L"PortableApps Start",MB_ICONWARNING);
        SetTimer(w,TIMER_AUTOSTART,1400,nullptr);return 0;
    }
    case WM_ERASEBKGND:return 1;
    case WM_PAINT:{
        PAINTSTRUCT ps{};HDC dc=BeginPaint(w,&ps);RECT client{};GetClientRect(w,&client);
        const int width=client.right-client.left,height=client.bottom-client.top;
        if(width>0&&height>0){HDC buffer=CreateCompatibleDC(dc);HBITMAP bitmap=CreateCompatibleBitmap(dc,width,height);
            if(buffer&&bitmap){HGDIOBJ old=SelectObject(buffer,bitmap);paintLauncher(w,buffer);BitBlt(dc,0,0,width,height,buffer,0,0,SRCCOPY);SelectObject(buffer,old);}
            if(bitmap)DeleteObject(bitmap);if(buffer)DeleteDC(buffer);
        }
        EndPaint(w,&ps);return 0;}
    case WM_SIZE:if(wp==SIZE_MINIMIZED){saveWindowPosition(w);ShowWindow(w,SW_HIDE);return 0;}InvalidateRect(w,nullptr,FALSE);return 0;
    case WM_EXITSIZEMOVE:saveWindowPosition(w);return 0;
    case WM_MOUSEMOVE:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};
        const bool overScroll=PtInRect(&g_scrollHit,p)!=FALSE;
        if(g_scrollDragging){const int trackH=g_scrollHit.bottom-g_scrollHit.top,thumbH=g_scrollThumb.bottom-g_scrollThumb.top,travel=(std::max)(1,trackH-thumbH);g_scrollY=std::clamp(g_scrollDragOrigin+MulDiv(p.y-g_scrollDragStart,g_scrollMaximum,travel),0,g_scrollMaximum);InvalidateRect(w,nullptr,FALSE);}
        if(overScroll!=g_scrollHover){g_scrollHover=overScroll;InvalidateRect(w,&g_scrollHit,FALSE);}
        int hover=-1;for(const auto& tile:g_tileHits)if(PtInRect(&tile.rect,p)){hover=tile.appIndex;break;}
        if(hover!=g_hoverApp){for(const auto& tile:g_tileHits)if(tile.appIndex==g_hoverApp||tile.appIndex==hover)InvalidateRect(w,&tile.rect,FALSE);g_hoverApp=hover;}
        TRACKMOUSEEVENT tme{sizeof(tme),TME_LEAVE,w,0};TrackMouseEvent(&tme);return 0;}
    case WM_MOUSELEAVE:if(g_hoverApp>=0)for(const auto& tile:g_tileHits)if(tile.appIndex==g_hoverApp){InvalidateRect(w,&tile.rect,FALSE);break;}g_hoverApp=-1;if(g_scrollHover){g_scrollHover=false;InvalidateRect(w,&g_scrollHit,FALSE);}return 0;
    case WM_LBUTTONDOWN:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};
        if(PtInRect(&g_scrollHit,p)&&g_scrollMaximum>0){if(PtInRect(&g_scrollThumb,p)){g_scrollDragging=true;g_scrollDragStart=p.y;g_scrollDragOrigin=g_scrollY;SetCapture(w);}else{g_scrollY=std::clamp(g_scrollY+(p.y<g_scrollThumb.top?-g_scrollViewport:g_scrollViewport),0,g_scrollMaximum);InvalidateRect(w,nullptr,FALSE);}return 0;}
        if(p.y<scaleFor(w,75)&&!PtInRect(&g_categoryRect,p)){ReleaseCapture();SendMessageW(w,WM_NCLBUTTONDOWN,HTCAPTION,0);return 0;}break;}
    case WM_LBUTTONUP:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};if(g_scrollDragging){g_scrollDragging=false;ReleaseCapture();InvalidateRect(w,&g_scrollHit,FALSE);return 0;}if(PtInRect(&g_scrollHit,p))return 0;if(PtInRect(&g_categoryRect,p)){showCategoryMenu();return 0;}for(const auto& h:g_tileHits)if(PtInRect(&h.rect,p)){runApp(h.appIndex);return 0;}return 0;}
    case WM_RBUTTONUP:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};if(PtInRect(&g_categoryRect,p)){showCategoryMenu();return 0;}for(const auto& h:g_tileHits)if(PtInRect(&h.rect,p)){ClientToScreen(w,&p);showAppContextMenu(h.appIndex,p);return 0;}ClientToScreen(w,&p);showLauncherContextMenu(p);return 0;}
    case WM_MOUSEWHEEL:{int delta=GET_WHEEL_DELTA_WPARAM(wp);g_scrollY=std::clamp(g_scrollY-(delta/WHEEL_DELTA)*scaleFor(w,72),0,g_scrollMaximum);InvalidateRect(w,nullptr,FALSE);return 0;}
    case WM_ACTIVATEAPP:if(!wp){saveWindowPosition(w);ShowWindow(w,SW_HIDE);return 0;}break;
    case WM_KEYDOWN:if(wp==VK_ESCAPE){ShowWindow(w,SW_HIDE);return 0;}break;
    case WM_HOTKEY:if(wp==ID_HOTKEY){showMainWindow();return 0;}break;
    case WM_TRAY:
        if(LOWORD(lp)==WM_LBUTTONUP||LOWORD(lp)==NIN_SELECT||LOWORD(lp)==NIN_KEYSELECT||LOWORD(lp)==WM_LBUTTONDBLCLK){showMainWindow();}
        else if(LOWORD(lp)==WM_RBUTTONUP||LOWORD(lp)==WM_CONTEXTMENU)showTrayMenu();return 0;
    case WM_TIMER:
        if(wp==TIMER_TRAY_RETRY){KillTimer(w,TIMER_TRAY_RETRY);addTray(w);return 0;}
        if(wp==TIMER_AUTOSTART){KillTimer(w,TIMER_AUTOSTART);launchAutoStartApps();return 0;}
        return 0;
    case WM_CLOSE:saveWindowPosition(w);ShowWindow(w,SW_HIDE);return 0;
    case WM_DESTROY:UnregisterHotKey(w,ID_HOTKEY);Shell_NotifyIconW(NIM_DELETE,&g_nid);for(auto& a:g_apps)if(a.icon)DestroyIcon(a.icon);PostQuitMessage(0);return 0;
    }
    return DefWindowProcW(w,msg,wp,lp);
}
}
int WINAPI wWinMain(HINSTANCE instance,HINSTANCE,PWSTR,int) {
    g_instance=instance;SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);g_taskbarCreated=RegisterWindowMessageW(L"TaskbarCreated");setPaths();
    HANDLE mutex=CreateMutexW(nullptr,TRUE,L"Local\\PortableAppsStartNative_v1");if(mutex&&GetLastError()==ERROR_ALREADY_EXISTS){HWND old=FindWindowW(kClassName,nullptr);if(old){ShowWindow(old,SW_RESTORE);ShowWindow(old,SW_SHOW);SetForegroundWindow(old);BringWindowToTop(old);}CloseHandle(mutex);return 0;}
    g_icon=makeIcon(32);
    WNDCLASSEXW wc{};wc.cbSize=sizeof(wc);wc.hInstance=instance;wc.lpfnWndProc=WndProc;wc.lpszClassName=kClassName;wc.hCursor=LoadCursorW(nullptr,IDC_ARROW);wc.hIcon=g_icon;wc.hIconSm=g_icon;wc.hbrBackground=(HBRUSH)GetStockObject(BLACK_BRUSH);RegisterClassExW(&wc);
    WNDCLASSEXW pc{};pc.cbSize=sizeof(pc);pc.hInstance=instance;pc.lpfnWndProc=PromptWndProc;pc.lpszClassName=kPromptClassName;pc.hCursor=LoadCursorW(nullptr,IDC_ARROW);pc.hbrBackground=(HBRUSH)GetStockObject(BLACK_BRUSH);RegisterClassExW(&pc);
    POINT cursor{};GetCursorPos(&cursor);HMONITOR monitor=MonitorFromPoint(cursor,MONITOR_DEFAULTTONEAREST);MONITORINFO mi{sizeof(mi)};GetMonitorInfoW(monitor,&mi);int dpi=(int)GetDpiForSystem();
    const int width=(std::min)(MulDiv(560,dpi,96),(int)(mi.rcWork.right-mi.rcWork.left)-24),height=(std::min)(MulDiv(620,dpi,96),(int)(mi.rcWork.bottom-mi.rcWork.top)-24);
    int x=GetPrivateProfileIntW(L"Window",L"Left",mi.rcWork.right-width-MulDiv(16,dpi,96),g_iniPath.c_str()),y=GetPrivateProfileIntW(L"Window",L"Top",mi.rcWork.top+(mi.rcWork.bottom-mi.rcWork.top-height)/2,g_iniPath.c_str());
    x=std::clamp(x,(int)mi.rcWork.left,(int)mi.rcWork.right-width);y=std::clamp(y,(int)mi.rcWork.top,(int)mi.rcWork.bottom-height);
    g_window=CreateWindowExW(WS_EX_TOOLWINDOW|WS_EX_TOPMOST,kClassName,L"PortableApps Start",WS_POPUP|WS_CLIPCHILDREN,x,y,width,height,nullptr,nullptr,instance,nullptr);
    if(g_window){const BOOL dark=TRUE;const int corner=2,backdrop=2;DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)20,&dark,sizeof(dark));DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)33,&corner,sizeof(corner));DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)38,&backdrop,sizeof(backdrop));}
    if(!g_window)return 1;ShowWindow(g_window,SW_SHOW);UpdateWindow(g_window);
    MSG msg;while(GetMessageW(&msg,nullptr,0,0)>0){TranslateMessage(&msg);DispatchMessageW(&msg);}
    if(g_icon)DestroyIcon(g_icon);if(g_font)DeleteObject(g_font);if(g_smallFont)DeleteObject(g_smallFont);if(g_titleFont)DeleteObject(g_titleFont);
    if(g_menuBackgroundBrush)DeleteObject(g_menuBackgroundBrush);if(g_promptBackgroundBrush)DeleteObject(g_promptBackgroundBrush);if(g_promptEditBrush)DeleteObject(g_promptEditBrush);
    if(mutex)CloseHandle(mutex);return (int)msg.wParam;
}

