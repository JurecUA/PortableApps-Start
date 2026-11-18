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

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "dwmapi.lib")
#pragma comment(lib, "version.lib")

namespace fs = std::filesystem;
namespace {
constexpr UINT WM_TRAY = WM_APP + 1;
constexpr int ID_HOTKEY = 1010;
constexpr int ID_OPEN = 1101, ID_RUN_ADMIN = 1102, ID_FOLDER = 1103, ID_FAVORITE = 1104, ID_AUTOSTART = 1105;
constexpr UINT ID_TRAY_OPEN = 2001, ID_TRAY_REFRESH = 2002, ID_TRAY_ROOT = 2003, ID_TRAY_EXIT = 2004;
constexpr UINT ID_CATEGORY_ALL = 3000, ID_CATEGORY_FAVORITES = 3001, ID_CATEGORY_BASE = 3100;
constexpr UINT ID_CONTEXT_CATEGORY_BASE = 4100, ID_CONTEXT_NEW_CATEGORY = 4200;
constexpr UINT_PTR TIMER_TRAY_RETRY = 2, TIMER_AUTOSTART = 3;
constexpr int IDD_CATEGORY_PROMPT = 500, IDC_CATEGORY_PROMPT = 501;
constexpr wchar_t kClassName[] = L"PortableAppsStartNativeWindow";
constexpr wchar_t kPromptClassName[] = L"PortableAppsStartCategoryPrompt";
struct App { std::wstring folder, relativeKey, configKey, name, category, launcher, iconPath; HICON icon{}; bool favorite = false, autoStart = false; };
struct TileHit { RECT rect{}; int appIndex=-1; };

HINSTANCE g_instance{}; HWND g_window{};
HICON g_icon{}; NOTIFYICONDATAW g_nid{};
std::vector<App> g_apps; std::vector<std::wstring> g_categories, g_userCategories;
std::vector<TileHit> g_tileHits;
fs::path g_moduleDir, g_appsDir, g_dataDir, g_iniPath;
fs::path g_legacyIniPath;
std::wstring g_legacyIniText, g_userIniText, g_currentCategory=L"Все приложения";
bool g_refreshing = false, g_draggingWindow=false;
HFONT g_font{}, g_smallFont{}, g_titleFont{};
UINT g_taskbarCreated{};
int g_scrollY=0, g_contentHeight=0, g_hoverApp=-1, g_contextApp=-1;
RECT g_categoryRect{};
std::wstring g_promptResult;
std::wstring trim(std::wstring s);
LRESULT CALLBACK PromptWndProc(HWND w,UINT msg,WPARAM wp,LPARAM lp) {
    if(msg==WM_COMMAND&&(LOWORD(wp)==IDOK||LOWORD(wp)==IDCANCEL)) {
        if(LOWORD(wp)==IDOK){wchar_t value[256]{};GetDlgItemTextW(w,IDC_CATEGORY_PROMPT,value,256);g_promptResult=trim(value);}
        DestroyWindow(w);return 0;
    }
    if(msg==WM_CLOSE){DestroyWindow(w);return 0;}
    return DefWindowProcW(w,msg,wp,lp);
}

std::wstring trim(std::wstring s) {
    auto ws = [](wchar_t c) { return std::iswspace(c) != 0; };
    auto a = std::find_if_not(s.begin(), s.end(), ws), b = std::find_if_not(s.rbegin(), s.rend(), ws).base();
    if (a >= b) return L""; return std::wstring(a, b);
}
std::wstring lower(std::wstring s) { std::transform(s.begin(), s.end(), s.begin(), towlower); return s; }
std::wstring readText(const fs::path& p) {
    std::ifstream f(p, std::ios::binary); if (!f) return {};
    std::string bytes((std::istreambuf_iterator<char>(f)), {}); if (bytes.empty()) return {};
    if (bytes.size() >= 2 && (BYTE)bytes[0] == 0xFF && (BYTE)bytes[1] == 0xFE) {
        std::wstring w((bytes.size() - 2) / 2, L'\0'); memcpy(w.data(), bytes.data() + 2, w.size() * 2); return w;
    }
    if (bytes.size() >= 2 && (BYTE)bytes[0] == 0xFE && (BYTE)bytes[1] == 0xFF) {
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
}
HICON makeIcon(int size) {
    HDC screen=GetDC(nullptr), dc=CreateCompatibleDC(screen); HBITMAP color=CreateCompatibleBitmap(screen,size,size);
    HBITMAP old=(HBITMAP)SelectObject(dc,color); HBRUSH clear=CreateSolidBrush(RGB(20,39,66)); RECT r{0,0,size,size};
    FillRect(dc,&r,clear); DeleteObject(clear);
    auto tile=[&](int x,int y,int w,int h,COLORREF c){ HBRUSH b=CreateSolidBrush(c); RECT q{x,y,x+w,y+h}; FillRect(dc,&q,b); DeleteObject(b); };
    const int m=size/8, gap=size/12, tw=(size-2*m-gap)/2, top=size/6;
    tile(m,top,tw,tw,RGB(50,150,245)); tile(m+tw+gap,top,tw,tw,RGB(113,190,247));
    tile(m,top+tw+gap,tw,tw,RGB(113,190,247)); tile(m+tw+gap,top+tw+gap,tw,tw,RGB(166,213,250));
    SelectObject(dc,old); DeleteDC(dc); ReleaseDC(nullptr,screen);
    HBITMAP mask=CreateBitmap(size,size,1,1,nullptr); ICONINFO ii{}; ii.fIcon=TRUE; ii.hbmColor=color; ii.hbmMask=mask;
    HICON icon=CreateIconIndirect(&ii); DeleteObject(color); DeleteObject(mask); return icon;
}
void saveFavorite(const App& app) {
    WritePrivateProfileStringW(L"Favorites",app.configKey.c_str(),app.favorite?L"true":L"false",g_iniPath.c_str());
}
void saveAutoStart(const App& app) {
    WritePrivateProfileStringW(L"AutoStart",app.configKey.c_str(),app.autoStart?L"true":L"false",g_iniPath.c_str());
    g_userIniText=readText(g_iniPath);
}
std::vector<std::wstring> splitList(const std::wstring& value) {
    std::vector<std::wstring> out; std::wistringstream in(value); std::wstring item;
    while(std::getline(in,item,L'|')) { item=trim(item); if(!item.empty())out.push_back(item); }
    return out;
}
void saveUserCategories() {
    std::wstring value; for(const auto& c:g_userCategories){if(!value.empty())value+=L"|";value+=c;}
    WritePrivateProfileStringW(L"UserCategories",L"Items",value.c_str(),g_iniPath.c_str());g_userIniText=readText(g_iniPath);
}
void saveCategory(const App& app,const std::wstring& category) {
    WritePrivateProfileStringW(L"CategoryOverride",app.configKey.c_str(),category.c_str(),g_iniPath.c_str());g_userIniText=readText(g_iniPath);
}
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
void loadApps() {
    for(auto& a:g_apps)if(a.icon)DestroyIcon(a.icon);
    g_apps.clear(); g_categories.clear();
    g_userCategories=splitList(ini(g_userIniText,L"UserCategories",L"Items"));
    if (!existsDir(g_appsDir)) return;
    std::error_code ec;
    for (fs::directory_iterator it(g_appsDir,ec), end; !ec && it!=end; it.increment(ec)) {
        if (!it->is_directory(ec)) continue;
        const auto folder=it->path().filename().wstring(); if (lower(folder)==L"portableapps.com") continue;
        fs::path appInfo=it->path()/L"App"/L"AppInfo"/L"appinfo.ini";
        if(fs::is_regular_file(appInfo,ec)) {
            const auto txt=readText(appInfo); const auto appName=ini(txt,L"Details",L"Name");
            int iconCount=1;try{iconCount=(std::max)(1,std::stoi(ini(txt,L"Control",L"Icons",L"1")));}catch(...){}
            const bool singleIcon=isTrue(ini(g_legacyIniText,L"DisplayOptions",L"ShowSingleIconForMultiIconApps",L"true"));
            const int count=(iconCount>1&&!singleIcon)?iconCount:1;
            for(int iconNo=1;iconNo<=count;++iconNo) {
                const auto startKey=(iconCount>1&&!singleIcon)?L"Start"+std::to_wstring(iconNo):L"Start";
                const auto start=ini(txt,L"Control",startKey);if(start.empty())continue;
                fs::path launcher=it->path()/start;if(!fs::is_regular_file(launcher,ec))continue;
                const auto relKey=folder+L"\\"+fs::path(start).filename().wstring();if(isHiddenByPlatform(relKey))continue;
                App a;a.folder=folder;a.relativeKey=relKey;a.configKey=folder;
                a.name=(iconCount>1&&!singleIcon)?ini(txt,L"Control",L"Name"+std::to_wstring(iconNo),appName):appName;
                if(a.name.empty())a.name=launcher.stem().wstring();
                a.name=platformName(relKey,a.name);a.category=platformCategory(relKey,ini(txt,L"Details",L"Category",L"Other"));
                a.launcher=launcher.wstring();const auto iconPath=ini(txt,L"Control",L"ExtractIcon");
                a.iconPath=!iconPath.empty()?(it->path()/iconPath).wstring():(it->path()/L"App"/L"AppInfo"/(iconCount>1&&!singleIcon?L"appicon"+std::to_wstring(iconNo)+L".ico":L"appicon.ico")).wstring();
                const auto ownFavorite=ini(g_userIniText,L"Favorites",a.configKey,L"__missing__");a.favorite=ownFavorite==L"__missing__"?platformFavorite(relKey):isTrue(ownFavorite);
                a.autoStart=isTrue(ini(g_userIniText,L"AutoStart",a.configKey,L"false"));
                a.category=ini(g_userIniText,L"CategoryOverride",a.configKey,a.category);
                g_apps.push_back(std::move(a));
            }
            continue;
        }
        // Match Platform 30.4's legacy-app rule: scan only EXEs directly inside
        // each app folder; ignore the uninstaller and names hidden in the menu INI.
        for(fs::directory_iterator ex(it->path(),ec),exEnd;!ec&&ex!=exEnd;ex.increment(ec)) {
            if(!ex->is_regular_file(ec)||lower(ex->path().extension().wstring())!=L".exe"||lower(ex->path().filename().wstring())==L"uninstall.exe")continue;
            const auto relKey=folder+L"\\"+ex->path().filename().wstring();if(isHiddenByPlatform(relKey))continue;
            App a;a.folder=folder;a.relativeKey=relKey;a.configKey=relKey;a.launcher=ex->path().wstring();
            a.name=platformName(relKey,appDisplayName(ex->path()));a.category=platformCategory(relKey,L"Other");
            const auto ownFavorite=ini(g_userIniText,L"Favorites",a.configKey,L"__missing__");a.favorite=ownFavorite==L"__missing__"?platformFavorite(relKey):isTrue(ownFavorite);
            a.autoStart=isTrue(ini(g_userIniText,L"AutoStart",a.configKey,L"false"));
            a.category=ini(g_userIniText,L"CategoryOverride",a.configKey,a.category);
            g_apps.push_back(std::move(a));
        }
    }
    std::sort(g_apps.begin(),g_apps.end(),[](const App& a,const App& b){return lower(a.name)<lower(b.name);});
    for (const auto& a:g_apps) if (std::find(g_categories.begin(),g_categories.end(),a.category)==g_categories.end()) g_categories.push_back(a.category);
    for(const auto& c:g_userCategories)if(std::find(g_categories.begin(),g_categories.end(),c)==g_categories.end())g_categories.push_back(c);
    std::sort(g_categories.begin(),g_categories.end(),[](const auto&a,const auto&b){return lower(a)<lower(b);});
    for(auto& a:g_apps) {
        if(!a.iconPath.empty())a.icon=(HICON)LoadImageW(nullptr,a.iconPath.c_str(),IMAGE_ICON,48,48,LR_LOADFROMFILE|LR_DEFAULTSIZE);
        if(!a.icon){SHFILEINFOW sfi{};if(SHGetFileInfoW(a.launcher.c_str(),0,&sfi,sizeof(sfi),SHGFI_ICON|SHGFI_LARGEICON))a.icon=sfi.hIcon;}
    }
}
std::vector<int> pinnedApps() {
    std::vector<int> out;for(size_t i=0;i<g_apps.size();++i)if(g_apps[i].favorite)out.push_back((int)i);return out;
}
std::vector<int> visibleApps() {
    std::vector<int> out;const auto cat=lower(g_currentCategory);
    for(size_t i=0;i<g_apps.size();++i) {
        const auto& a=g_apps[i];
        if(cat==L"избранное"&&!a.favorite)continue;
        if(cat!=L"все приложения"&&cat!=L"избранное"&&lower(a.category)!=cat)continue;
        out.push_back((int)i);
    }
    return out;
}
int scaleFor(HWND w,int value) { return MulDiv(value,(int)GetDpiForWindow(w),96); }
void addTileHit(RECT r,int appIndex) { g_tileHits.push_back({r,appIndex}); }
void drawTile(HDC dc,const App& app,int index,RECT r,bool pinned,int hover,int dpi) {
    const bool hot=hover==index;HBRUSH bg=CreateSolidBrush(hot?RGB(67,72,82):RGB(44,47,54));
    HPEN pen=CreatePen(PS_SOLID,1,hot?RGB(99,151,221):RGB(58,62,70));auto oldPen=(HPEN)SelectObject(dc,pen);auto oldBrush=(HBRUSH)SelectObject(dc,bg);
    RoundRect(dc,r.left,r.top,r.right,r.bottom,scaleFor(g_window,14),scaleFor(g_window,14));SelectObject(dc,oldBrush);SelectObject(dc,oldPen);DeleteObject(bg);DeleteObject(pen);
    const int iconSize=scaleFor(g_window,44), ix=(r.left+r.right-iconSize)/2, iy=r.top+scaleFor(g_window,10);
    if(app.icon)DrawIconEx(dc,ix,iy,app.icon,iconSize,iconSize,0,nullptr,DI_NORMAL);
    RECT text{r.left+scaleFor(g_window,4),iy+iconSize+scaleFor(g_window,3),r.right-scaleFor(g_window,4),r.bottom-scaleFor(g_window,5)};
    SetBkMode(dc,TRANSPARENT);SetTextColor(dc,RGB(244,245,247));SelectObject(dc,g_smallFont);
    DrawTextW(dc,app.name.c_str(),-1,&text,DT_CENTER|DT_VCENTER|DT_WORDBREAK|DT_END_ELLIPSIS|DT_NOPREFIX);
    if(pinned){SetTextColor(dc,RGB(119,180,255));RECT mark{r.right-scaleFor(g_window,17),r.top+scaleFor(g_window,4),r.right-scaleFor(g_window,5),r.top+scaleFor(g_window,16)};DrawTextW(dc,L"★",1,&mark,DT_CENTER|DT_VCENTER|DT_SINGLELINE);}
    (void)dpi;
}
void paintLauncher(HWND w,HDC dc) {
    RECT client{};GetClientRect(w,&client);const int dpi=(int)GetDpiForWindow(w),pad=scaleFor(w,24),header=scaleFor(w,82);
    HBRUSH bg=CreateSolidBrush(RGB(30,32,37));FillRect(dc,&client,bg);DeleteObject(bg);
    SetBkMode(dc,TRANSPARENT);SetTextColor(dc,RGB(248,249,251));SelectObject(dc,g_titleFont);
    RECT title{pad,scaleFor(w,23),client.right/2,scaleFor(w,58)};DrawTextW(dc,L"PortableApps Start",-1,&title,DT_LEFT|DT_VCENTER|DT_SINGLELINE);
    g_categoryRect={client.right-pad-scaleFor(w,240),scaleFor(w,20),client.right-pad,scaleFor(w,60)};
    HBRUSH cb=CreateSolidBrush(RGB(47,51,58));HPEN cp=CreatePen(PS_SOLID,1,RGB(67,72,81));auto op=(HPEN)SelectObject(dc,cp);auto ob=(HBRUSH)SelectObject(dc,cb);
    RoundRect(dc,g_categoryRect.left,g_categoryRect.top,g_categoryRect.right,g_categoryRect.bottom,scaleFor(w,12),scaleFor(w,12));SelectObject(dc,ob);SelectObject(dc,op);DeleteObject(cb);DeleteObject(cp);
    SetTextColor(dc,RGB(236,238,242));SelectObject(dc,g_smallFont);RECT ct=g_categoryRect;ct.left+=scaleFor(w,12);ct.right-=scaleFor(w,12);
    std::wstring catLabel=g_currentCategory+L"   ▾";DrawTextW(dc,catLabel.c_str(),-1,&ct,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);
    const int contentTop=header, gap=scaleFor(w,12), cellH=scaleFor(w,96), inner=client.right-2*pad;
    const int cellW=(inner-4*gap)/5;auto pins=pinnedApps();auto apps=visibleApps();const int pinRows=(int)((pins.size()+4)/5);
    const int pinnedSection=scaleFor(w,33)+(std::max)(1,pinRows)*cellH+scaleFor(w,24);
    const int appTitleY=contentTop+pinnedSection-g_scrollY;
    const int appGridY=appTitleY+scaleFor(w,38);
    g_contentHeight=pinnedSection+scaleFor(w,40)+(int)((apps.size()+4)/5)*cellH+scaleFor(w,28);
    const int viewport=client.bottom-contentTop-scaleFor(w,16);const int maxScroll=(std::max)(0,g_contentHeight-viewport);g_scrollY=std::clamp(g_scrollY,0,maxScroll);
    SCROLLINFO si{sizeof(si),SIF_RANGE|SIF_PAGE|SIF_POS};si.nMin=0;si.nMax=(std::max)(0,g_contentHeight-1);si.nPage=viewport;si.nPos=g_scrollY;SetScrollInfo(w,SB_VERT,&si,TRUE);
    g_tileHits.clear();int saved=SaveDC(dc);IntersectClipRect(dc,pad,contentTop,client.right-pad,client.bottom-scaleFor(w,10));
    SetTextColor(dc,RGB(216,220,228));RECT ph{pad,contentTop-scaleFor(w,6)-g_scrollY,client.right-pad,contentTop+scaleFor(w,25)-g_scrollY};SelectObject(dc,g_smallFont);DrawTextW(dc,L"ЗАКРЕПЛЁННЫЕ",-1,&ph,DT_LEFT|DT_VCENTER|DT_SINGLELINE);
    if(pins.empty()){SetTextColor(dc,RGB(150,155,165));RECT empty{pad,contentTop+scaleFor(w,38)-g_scrollY,client.right-pad,contentTop+cellH-scaleFor(w,5)-g_scrollY};DrawTextW(dc,L"Добавьте приложения в закреплённые через контекстное меню",-1,&empty,DT_LEFT|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);}
    for(size_t n=0;n<pins.size();++n){int row=(int)n/5,col=(int)n%5;RECT r{pad+col*(cellW+gap),contentTop+scaleFor(w,31)+row*cellH-g_scrollY,pad+col*(cellW+gap)+cellW,contentTop+scaleFor(w,31)+row*cellH+cellH-scaleFor(w,5)-g_scrollY};int i=pins[n];drawTile(dc,g_apps[i],i,r,true,g_hoverApp,dpi);addTileHit(r,i);}
    const int dividerY=appTitleY-scaleFor(w,7);HPEN div=CreatePen(PS_SOLID,1,RGB(58,62,70));auto od=(HPEN)SelectObject(dc,div);MoveToEx(dc,pad,dividerY,nullptr);LineTo(dc,client.right-pad,dividerY);SelectObject(dc,od);DeleteObject(div);
    SetTextColor(dc,RGB(244,245,247));SelectObject(dc,g_font);RECT ah{pad,appTitleY,client.right-pad,appTitleY+scaleFor(w,30)};DrawTextW(dc,L"Все приложения",-1,&ah,DT_LEFT|DT_VCENTER|DT_SINGLELINE);
    for(size_t n=0;n<apps.size();++n){int row=(int)n/5,col=(int)n%5;RECT r{pad+col*(cellW+gap),appGridY+row*cellH,pad+col*(cellW+gap)+cellW,appGridY+row*cellH+cellH-scaleFor(w,5)};int i=apps[n];drawTile(dc,g_apps[i],i,r,g_apps[i].favorite,g_hoverApp,dpi);addTileHit(r,i);}
    RestoreDC(dc,saved);
}
void refreshList() { if(g_window)InvalidateRect(g_window,nullptr,FALSE); }
void runApp(int index,bool admin=false) {
    if(index<0||index>=(int)g_apps.size())return; const auto& a=g_apps[index];
    SHELLEXECUTEINFOW si{};si.cbSize=sizeof(si);si.fMask=SEE_MASK_FLAG_NO_UI;si.hwnd=g_window;si.lpVerb=admin?L"runas":L"open";
    si.lpFile=a.launcher.c_str();si.lpDirectory=fs::path(a.launcher).parent_path().c_str();si.nShow=SW_SHOWNORMAL;
    if(!ShellExecuteExW(&si)) { DWORD e=GetLastError(); if(e!=ERROR_CANCELLED) MessageBoxW(g_window,L"Не удалось запустить приложение.",a.name.c_str(),MB_ICONERROR); }
    else ShowWindow(g_window,SW_HIDE);
}
bool isProcessRunning(const std::wstring& executable) {
    HANDLE snap=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);if(snap==INVALID_HANDLE_VALUE)return false;
    PROCESSENTRY32W pe{};pe.dwSize=sizeof(pe);const auto wanted=lower(fs::path(executable).wstring());bool found=false;
    if(Process32FirstW(snap,&pe))do {
        HANDLE proc=OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,FALSE,pe.th32ProcessID);if(!proc)continue;
        wchar_t path[32768]{};DWORD len=32768;if(QueryFullProcessImageNameW(proc,0,path,&len)&&lower(fs::path(path).wstring())==wanted)found=true;
        CloseHandle(proc);if(found)break;
    } while(Process32NextW(snap,&pe));
    CloseHandle(snap);return found;
}
void launchAutoStartApps() {
    for(size_t i=0;i<g_apps.size();++i)if(g_apps[i].autoStart&&!isProcessRunning(g_apps[i].launcher))runApp((int)i);
}
void openRoot() { ShellExecuteW(g_window,L"explore",g_appsDir.c_str(),nullptr,nullptr,SW_SHOWNORMAL); }
void toggleFavorite(int index) { if(index<0||index>=(int)g_apps.size())return;g_apps[index].favorite=!g_apps[index].favorite;saveFavorite(g_apps[index]);refreshList(); }
void toggleAutoStart(int index) { if(index<0||index>=(int)g_apps.size())return;g_apps[index].autoStart=!g_apps[index].autoStart;saveAutoStart(g_apps[index]);refreshList(); }
std::wstring promptCategory(HWND owner) {
    g_promptResult.clear();RECT r{};GetWindowRect(owner,&r);const int width=scaleFor(owner,340),height=scaleFor(owner,148);
    HWND dlg=CreateWindowExW(WS_EX_DLGMODALFRAME|WS_EX_TOPMOST,kPromptClassName,L"Новая категория",WS_CAPTION|WS_SYSMENU|WS_POPUP|WS_VISIBLE,
        r.left+(r.right-r.left-width)/2,r.top+(r.bottom-r.top-height)/2,width,height,owner,nullptr,g_instance,nullptr);
    if(!dlg)return {};
    HWND label=CreateWindowExW(0,L"STATIC",L"Название категории",WS_CHILD|WS_VISIBLE,scaleFor(owner,16),scaleFor(owner,12),width-scaleFor(owner,32),scaleFor(owner,22),dlg,nullptr,g_instance,nullptr);
    HWND edit=CreateWindowExW(WS_EX_CLIENTEDGE,L"EDIT",L"",WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_AUTOHSCROLL,scaleFor(owner,16),scaleFor(owner,40),width-scaleFor(owner,32),scaleFor(owner,28),dlg,(HMENU)(INT_PTR)IDC_CATEGORY_PROMPT,g_instance,nullptr);
    HWND ok=CreateWindowExW(0,L"BUTTON",L"Создать",WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_DEFPUSHBUTTON,width-scaleFor(owner,174),scaleFor(owner,80),scaleFor(owner,76),scaleFor(owner,28),dlg,(HMENU)IDOK,g_instance,nullptr);
    HWND cancel=CreateWindowExW(0,L"BUTTON",L"Отмена",WS_CHILD|WS_VISIBLE|WS_TABSTOP,width-scaleFor(owner,90),scaleFor(owner,80),scaleFor(owner,74),scaleFor(owner,28),dlg,(HMENU)IDCANCEL,g_instance,nullptr);
    SendMessageW(label,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(edit,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(ok,WM_SETFONT,(WPARAM)g_smallFont,TRUE);SendMessageW(cancel,WM_SETFONT,(WPARAM)g_smallFont,TRUE);
    EnableWindow(owner,FALSE);SetFocus(edit);MSG msg;
    while(IsWindow(dlg)&&GetMessageW(&msg,nullptr,0,0)>0){if(!IsDialogMessageW(dlg,&msg)){TranslateMessage(&msg);DispatchMessageW(&msg);}}
    EnableWindow(owner,TRUE);SetForegroundWindow(owner);return g_promptResult;
}
void addUserCategory(const std::wstring& name) {
    if(name.empty()||name.find(L'|')!=std::wstring::npos)return;
    if(std::none_of(g_userCategories.begin(),g_userCategories.end(),[&](const auto& c){return lower(c)==lower(name);}))g_userCategories.push_back(name);
    saveUserCategories();loadApps();refreshList();
}
void assignCategory(int index,const std::wstring& category) {
    if(index<0||index>=(int)g_apps.size())return;saveCategory(g_apps[index],category);g_apps[index].category=category;
    if(std::find(g_categories.begin(),g_categories.end(),category)==g_categories.end())g_categories.push_back(category);refreshList();
}
void showCategoryMenu() {
    HMENU menu=CreatePopupMenu();AppendMenuW(menu,MF_STRING|(g_currentCategory==L"Все приложения"?MF_CHECKED:0),ID_CATEGORY_ALL,L"Все приложения");
    AppendMenuW(menu,MF_STRING|(g_currentCategory==L"Избранное"?MF_CHECKED:0),ID_CATEGORY_FAVORITES,L"Закреплённые");AppendMenuW(menu,MF_SEPARATOR,0,nullptr);
    for(size_t i=0;i<g_categories.size()&&i<800;++i)AppendMenuW(menu,MF_STRING|(g_currentCategory==g_categories[i]?MF_CHECKED:0),ID_CATEGORY_BASE+(UINT)i,g_categories[i].c_str());
    AppendMenuW(menu,MF_SEPARATOR,0,nullptr);AppendMenuW(menu,MF_STRING,ID_CONTEXT_NEW_CATEGORY,L"Создать категорию…");
    POINT p{g_categoryRect.left,g_categoryRect.bottom};ClientToScreen(g_window,&p);UINT cmd=TrackPopupMenu(menu,TPM_RETURNCMD|TPM_RIGHTBUTTON,p.x,p.y,0,g_window,nullptr);DestroyMenu(menu);
    if(cmd==ID_CATEGORY_ALL)g_currentCategory=L"Все приложения";else if(cmd==ID_CATEGORY_FAVORITES)g_currentCategory=L"Избранное";
    else if(cmd>=ID_CATEGORY_BASE&&cmd<ID_CATEGORY_BASE+g_categories.size())g_currentCategory=g_categories[cmd-ID_CATEGORY_BASE];
    else if(cmd==ID_CONTEXT_NEW_CATEGORY){auto name=promptCategory(g_window);if(!name.empty()){addUserCategory(name);g_currentCategory=name;}}
    refreshList();
}
void showAppContextMenu(int index,POINT p) {
    if(index<0||index>=(int)g_apps.size())return;g_contextApp=index;const auto& a=g_apps[index];HMENU menu=CreatePopupMenu();
    AppendMenuW(menu,MF_STRING,ID_OPEN,L"Запустить");AppendMenuW(menu,MF_STRING,ID_RUN_ADMIN,L"Запустить от имени администратора");
    AppendMenuW(menu,MF_STRING,ID_FOLDER,L"Открыть папку приложения");AppendMenuW(menu,MF_SEPARATOR,0,nullptr);
    AppendMenuW(menu,MF_STRING|(a.favorite?MF_CHECKED:0),ID_FAVORITE,a.favorite?L"Открепить приложение":L"Закрепить приложение");
    AppendMenuW(menu,MF_STRING|(a.autoStart?MF_CHECKED:0),ID_AUTOSTART,L"Запускать вместе с PortableApps Start");
    HMENU categories=CreatePopupMenu();for(size_t i=0;i<g_categories.size()&&i<800;++i)AppendMenuW(categories,MF_STRING|(a.category==g_categories[i]?MF_CHECKED:0),ID_CONTEXT_CATEGORY_BASE+(UINT)i,g_categories[i].c_str());
    AppendMenuW(categories,MF_SEPARATOR,0,nullptr);AppendMenuW(categories,MF_STRING,ID_CONTEXT_NEW_CATEGORY,L"Создать категорию и переместить сюда");
    AppendMenuW(menu,MF_POPUP,(UINT_PTR)categories,L"Переместить в категорию");
    UINT cmd=TrackPopupMenu(menu,TPM_RETURNCMD|TPM_RIGHTBUTTON,p.x,p.y,0,g_window,nullptr);DestroyMenu(menu);
    if(cmd==ID_OPEN)runApp(index);else if(cmd==ID_RUN_ADMIN)runApp(index,true);else if(cmd==ID_FOLDER)ShellExecuteW(g_window,L"explore",fs::path(a.launcher).parent_path().c_str(),nullptr,nullptr,SW_SHOWNORMAL);
    else if(cmd==ID_FAVORITE)toggleFavorite(index);else if(cmd==ID_AUTOSTART)toggleAutoStart(index);
    else if(cmd>=ID_CONTEXT_CATEGORY_BASE&&cmd<ID_CONTEXT_CATEGORY_BASE+g_categories.size())assignCategory(index,g_categories[cmd-ID_CONTEXT_CATEGORY_BASE]);
    else if(cmd==ID_CONTEXT_NEW_CATEGORY){auto name=promptCategory(g_window);if(!name.empty()){addUserCategory(name);assignCategory(index,name);}}
}
void showMainWindow();
void showTrayMenu() {
    HMENU m=CreatePopupMenu();AppendMenuW(m,MF_STRING,ID_TRAY_OPEN,L"Открыть PortableApps Start");AppendMenuW(m,MF_STRING,ID_TRAY_REFRESH,L"Обновить список приложений");
    AppendMenuW(m,MF_STRING,ID_TRAY_ROOT,L"Открыть папку PortableApps");AppendMenuW(m,MF_SEPARATOR,0,nullptr);AppendMenuW(m,MF_STRING,ID_TRAY_EXIT,L"Выход");
    POINT p{};GetCursorPos(&p);SetForegroundWindow(g_window);UINT c=TrackPopupMenu(m,TPM_RETURNCMD|TPM_RIGHTBUTTON,p.x,p.y,0,g_window,nullptr);DestroyMenu(m);
    if(c==ID_TRAY_OPEN)showMainWindow();else if(c==ID_TRAY_REFRESH)refreshList();else if(c==ID_TRAY_ROOT)openRoot();else if(c==ID_TRAY_EXIT)DestroyWindow(g_window);
}
void showMainWindow() {
    POINT cursor{};GetCursorPos(&cursor);HMONITOR monitor=MonitorFromPoint(cursor,MONITOR_DEFAULTTONEAREST);MONITORINFO mi{sizeof(mi)};GetMonitorInfoW(monitor,&mi);
    const int dpi=(int)GetDpiForSystem(),width=(std::min)(MulDiv(820,dpi,96),(int)(mi.rcWork.right-mi.rcWork.left)-24),height=(std::min)(MulDiv(860,dpi,96),(int)(mi.rcWork.bottom-mi.rcWork.top)-24);
    const int x=mi.rcWork.right-width-MulDiv(16,dpi,96),y=mi.rcWork.top+(mi.rcWork.bottom-mi.rcWork.top-height)/2;
    SetWindowPos(g_window,HWND_TOP,x,y,width,height,SWP_NOACTIVATE|SWP_SHOWWINDOW);ShowWindow(g_window,SW_RESTORE);SetForegroundWindow(g_window);BringWindowToTop(g_window);SetActiveWindow(g_window);InvalidateRect(g_window,nullptr,FALSE);
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
    g_font=CreateFontW(-MulDiv(16,dpi,96),0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI");
    g_smallFont=CreateFontW(-MulDiv(12,dpi,96),0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI");
    g_titleFont=CreateFontW(-MulDiv(21,dpi,96),0,0,0,FW_SEMIBOLD,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI");
    loadApps();
}
LRESULT CALLBACK WndProc(HWND w,UINT msg,WPARAM wp,LPARAM lp) {
    if(g_taskbarCreated&&msg==g_taskbarCreated){addTray(w);return 0;}
    switch(msg) {
    case WM_NCCREATE:g_window=w;return DefWindowProcW(w,msg,wp,lp);
    case WM_CREATE: {
        g_window=w;createControls(w);addTray(w);
        if(!RegisterHotKey(w,ID_HOTKEY,MOD_CONTROL|MOD_ALT|MOD_NOREPEAT,VK_SPACE))MessageBoxW(w,L"Не удалось назначить Ctrl+Alt+Пробел: сочетание занято другой программой.",L"PortableApps Start",MB_ICONWARNING);
        SetTimer(w,TIMER_AUTOSTART,1400,nullptr);return 0;
    }
    case WM_ERASEBKGND:return 1;
    case WM_PAINT:{PAINTSTRUCT ps{};HDC dc=BeginPaint(w,&ps);paintLauncher(w,dc);EndPaint(w,&ps);return 0;}
    case WM_SIZE:if(wp==SIZE_MINIMIZED){ShowWindow(w,SW_HIDE);return 0;}g_scrollY=0;InvalidateRect(w,nullptr,FALSE);return 0;
    case WM_MOUSEMOVE:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};int hover=-1;for(const auto& h:g_tileHits)if(PtInRect(&h.rect,p)){hover=h.appIndex;break;}if(hover!=g_hoverApp){g_hoverApp=hover;InvalidateRect(w,nullptr,FALSE);}TRACKMOUSEEVENT tme{sizeof(tme),TME_LEAVE,w,0};TrackMouseEvent(&tme);return 0;}
    case WM_MOUSELEAVE:g_hoverApp=-1;InvalidateRect(w,nullptr,FALSE);return 0;
    case WM_LBUTTONDOWN:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};if(p.y<scaleFor(w,75)&&!PtInRect(&g_categoryRect,p)){ReleaseCapture();SendMessageW(w,WM_NCLBUTTONDOWN,HTCAPTION,0);return 0;}break;}
    case WM_LBUTTONUP:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};if(PtInRect(&g_categoryRect,p)){showCategoryMenu();return 0;}for(const auto& h:g_tileHits)if(PtInRect(&h.rect,p)){runApp(h.appIndex);return 0;}return 0;}
    case WM_RBUTTONUP:{POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};if(PtInRect(&g_categoryRect,p)){showCategoryMenu();return 0;}for(const auto& h:g_tileHits)if(PtInRect(&h.rect,p)){ClientToScreen(w,&p);showAppContextMenu(h.appIndex,p);return 0;}return 0;}
    case WM_MOUSEWHEEL:{int delta=GET_WHEEL_DELTA_WPARAM(wp);g_scrollY-=(delta/WHEEL_DELTA)*scaleFor(w,72);SCROLLINFO si{sizeof(si),SIF_RANGE|SIF_PAGE};GetScrollInfo(w,SB_VERT,&si);g_scrollY=std::clamp(g_scrollY,0,(std::max)(0,si.nMax-(int)si.nPage+1));InvalidateRect(w,nullptr,FALSE);return 0;}
    case WM_VSCROLL:{SCROLLINFO si{sizeof(si),SIF_ALL};GetScrollInfo(w,SB_VERT,&si);int pos=si.nPos;switch(LOWORD(wp)){case SB_LINEUP:pos-=scaleFor(w,36);break;case SB_LINEDOWN:pos+=scaleFor(w,36);break;case SB_PAGEUP:pos-=(int)si.nPage;break;case SB_PAGEDOWN:pos+=(int)si.nPage;break;case SB_THUMBTRACK:pos=si.nTrackPos;break;}g_scrollY=std::clamp(pos,0,(std::max)(0,si.nMax-(int)si.nPage+1));InvalidateRect(w,nullptr,FALSE);return 0;}
    case WM_ACTIVATEAPP:if(!wp){ShowWindow(w,SW_HIDE);return 0;}break;
    case WM_KEYDOWN:if(wp==VK_ESCAPE){ShowWindow(w,SW_HIDE);return 0;}break;
    case WM_HOTKEY:if(wp==ID_HOTKEY){showMainWindow();return 0;}break;
    case WM_TRAY:
        if(LOWORD(lp)==WM_LBUTTONUP||LOWORD(lp)==NIN_SELECT||LOWORD(lp)==NIN_KEYSELECT||LOWORD(lp)==WM_LBUTTONDBLCLK){showMainWindow();}
        else if(LOWORD(lp)==WM_RBUTTONUP||LOWORD(lp)==WM_CONTEXTMENU)showTrayMenu();return 0;
    case WM_TIMER:
        if(wp==TIMER_TRAY_RETRY){KillTimer(w,TIMER_TRAY_RETRY);addTray(w);return 0;}
        if(wp==TIMER_AUTOSTART){KillTimer(w,TIMER_AUTOSTART);launchAutoStartApps();return 0;}
        return 0;
    case WM_CLOSE:ShowWindow(w,SW_HIDE);return 0;
    case WM_DESTROY:UnregisterHotKey(w,ID_HOTKEY);Shell_NotifyIconW(NIM_DELETE,&g_nid);for(auto& a:g_apps)if(a.icon)DestroyIcon(a.icon);PostQuitMessage(0);return 0;
    }
    return DefWindowProcW(w,msg,wp,lp);
}
}
int WINAPI wWinMain(HINSTANCE instance,HINSTANCE,PWSTR,int) {
    g_instance=instance;SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);g_taskbarCreated=RegisterWindowMessageW(L"TaskbarCreated");setPaths();
    HANDLE mutex=CreateMutexW(nullptr,TRUE,L"Local\\PortableAppsStartNative_v1");if(mutex&&GetLastError()==ERROR_ALREADY_EXISTS){HWND old=FindWindowW(kClassName,nullptr);if(old){ShowWindow(old,SW_RESTORE);ShowWindow(old,SW_SHOW);SetForegroundWindow(old);BringWindowToTop(old);}CloseHandle(mutex);return 0;}
    g_icon=makeIcon(32);
    WNDCLASSEXW wc{};wc.cbSize=sizeof(wc);wc.hInstance=instance;wc.lpfnWndProc=WndProc;wc.lpszClassName=kClassName;wc.hCursor=LoadCursorW(nullptr,IDC_ARROW);wc.hIcon=g_icon;wc.hIconSm=g_icon;wc.hbrBackground=(HBRUSH)(COLOR_WINDOW+1);RegisterClassExW(&wc);
    WNDCLASSEXW pc{};pc.cbSize=sizeof(pc);pc.hInstance=instance;pc.lpfnWndProc=PromptWndProc;pc.lpszClassName=kPromptClassName;pc.hCursor=LoadCursorW(nullptr,IDC_ARROW);pc.hbrBackground=(HBRUSH)(COLOR_WINDOW+1);RegisterClassExW(&pc);
    POINT cursor{};GetCursorPos(&cursor);HMONITOR monitor=MonitorFromPoint(cursor,MONITOR_DEFAULTTONEAREST);MONITORINFO mi{sizeof(mi)};GetMonitorInfoW(monitor,&mi);int dpi=(int)GetDpiForSystem();
    const int width=(std::min)(MulDiv(820,dpi,96),(int)(mi.rcWork.right-mi.rcWork.left)-24),height=(std::min)(MulDiv(860,dpi,96),(int)(mi.rcWork.bottom-mi.rcWork.top)-24);
    int x=mi.rcWork.right-width-MulDiv(16,dpi,96),y=mi.rcWork.top+(mi.rcWork.bottom-mi.rcWork.top-height)/2;
    g_window=CreateWindowExW(WS_EX_TOOLWINDOW|WS_EX_TOPMOST,kClassName,L"PortableApps Start",WS_POPUP|WS_VSCROLL|WS_CLIPCHILDREN,x,y,width,height,nullptr,nullptr,instance,nullptr);
    if(g_window){const BOOL dark=TRUE;const int corner=2,backdrop=2;DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)20,&dark,sizeof(dark));DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)33,&corner,sizeof(corner));DwmSetWindowAttribute(g_window,(DWMWINDOWATTRIBUTE)38,&backdrop,sizeof(backdrop));}
    if(!g_window)return 1;ShowWindow(g_window,SW_SHOW);UpdateWindow(g_window);
    MSG msg;while(GetMessageW(&msg,nullptr,0,0)>0){TranslateMessage(&msg);DispatchMessageW(&msg);}
    if(g_icon)DestroyIcon(g_icon);if(g_font)DeleteObject(g_font);if(g_smallFont)DeleteObject(g_smallFont);if(g_titleFont)DeleteObject(g_titleFont);if(mutex)CloseHandle(mutex);return (int)msg.wParam;
}
