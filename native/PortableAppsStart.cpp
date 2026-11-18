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
constexpr int ID_CATEGORY = 1002, ID_LIST = 1003;
constexpr int ID_HOTKEY = 1010;
constexpr int ID_OPEN = 1101, ID_RUN_ADMIN = 1102, ID_FOLDER = 1103, ID_FAVORITE = 1104;
constexpr UINT ID_TRAY_OPEN = 2001, ID_TRAY_REFRESH = 2002, ID_TRAY_ROOT = 2003, ID_TRAY_EXIT = 2004;
constexpr UINT_PTR TIMER_TRAY_RETRY = 2;
constexpr wchar_t kClassName[] = L"PortableAppsStartNativeWindow";
struct App { std::wstring folder, relativeKey, configKey, name, category, launcher, icon; bool favorite = false; };

HINSTANCE g_instance{}; HWND g_window{}, g_category{}, g_list{};
HIMAGELIST g_images{}; HICON g_icon{}; NOTIFYICONDATAW g_nid{};
std::vector<App> g_apps; std::vector<std::wstring> g_categories;
fs::path g_moduleDir, g_appsDir, g_dataDir, g_iniPath;
fs::path g_legacyIniPath;
std::wstring g_legacyIniText;
bool g_refreshing = false;
HFONT g_font{}, g_smallFont{};
UINT g_taskbarCreated{};

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
    g_apps.clear(); g_categories.clear();
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
                a.icon=!iconPath.empty()?(it->path()/iconPath).wstring():(it->path()/L"App"/L"AppInfo"/(iconCount>1&&!singleIcon?L"appicon"+std::to_wstring(iconNo)+L".ico":L"appicon.ico")).wstring();
                const auto own=ini(readText(g_iniPath),L"Favorites",a.configKey,L"__missing__");a.favorite=own==L"__missing__"?platformFavorite(relKey):isTrue(own);
                g_apps.push_back(std::move(a));
            }
            continue;
        }
        // Match Platform 30.4's legacy-app rule: scan only EXEs directly inside
        // each app folder; ignore the uninstaller and names hidden in the menu INI.
        for(fs::directory_iterator ex(it->path(),ec),exEnd;!ec&&ex!=exEnd;ex.increment(ec)) {
            if(!ex->is_regular_file(ec)||lower(ex->path().extension().wstring())!=L".exe"||lower(ex->path().filename().wstring())==L"uninstall.exe")continue;
            const auto relKey=folder+L"\\"+ex->path().filename().wstring();if(isHiddenByPlatform(relKey))continue;
            App a;a.folder=folder;a.relativeKey=relKey;a.configKey=relKey;a.launcher=ex->path().wstring();a.icon=L"";
            a.name=platformName(relKey,appDisplayName(ex->path()));a.category=platformCategory(relKey,L"Other");
            const auto own=ini(readText(g_iniPath),L"Favorites",a.configKey,L"__missing__");a.favorite=own==L"__missing__"?platformFavorite(relKey):isTrue(own);
            g_apps.push_back(std::move(a));
        }
    }
    std::sort(g_apps.begin(),g_apps.end(),[](const App& a,const App& b){return lower(a.name)<lower(b.name);});
    for (const auto& a:g_apps) if (std::find(g_categories.begin(),g_categories.end(),a.category)==g_categories.end()) g_categories.push_back(a.category);
    std::sort(g_categories.begin(),g_categories.end(),[](const auto&a,const auto&b){return lower(a)<lower(b);});
}
void layout(int w,int h) {
    const int pad=18, top=16, categoryH=30, listTop=top+categoryH+24;
    MoveWindow(g_category,pad,top+34,w-2*pad,categoryH,TRUE);
    MoveWindow(g_list,pad,listTop,w-2*pad,h-listTop-pad,TRUE);
}
int selectedIndex() {
    int row=ListView_GetNextItem(g_list,-1,LVNI_SELECTED); if (row<0) return -1;
    LVITEMW item{}; item.mask=LVIF_PARAM; item.iItem=row; if (!ListView_GetItem(g_list,&item)) return -1;
    return (int)item.lParam;
}
void refreshList() {
    if (!g_list || g_refreshing) return; g_refreshing=true;
    loadApps(); int sel=(int)SendMessageW(g_category,CB_GETCURSEL,0,0); std::wstring category;
    if(sel>0){ wchar_t b[256]{}; SendMessageW(g_category,CB_GETLBTEXT,sel,(LPARAM)b); category=b; }
    SendMessageW(g_category,CB_RESETCONTENT,0,0); SendMessageW(g_category,CB_ADDSTRING,0,(LPARAM)L"Все приложения");
    SendMessageW(g_category,CB_ADDSTRING,0,(LPARAM)L"Избранное");
    for(const auto& c:g_categories) SendMessageW(g_category,CB_ADDSTRING,0,(LPARAM)c.c_str());
    int wanted=0; if(lower(category)==L"избранное") wanted=1; else if(!category.empty()) for(size_t i=0;i<g_categories.size();++i) if(g_categories[i]==category) wanted=(int)i+2;
    SendMessageW(g_category,CB_SETCURSEL,wanted,0);
    ListView_DeleteAllItems(g_list); if(g_images) ImageList_RemoveAll(g_images);
    const auto cat=lower(category); int row=0;
    for(size_t i=0;i<g_apps.size();++i) {
        const auto& a=g_apps[i];
        if(cat==L"избранное" && !a.favorite) continue; if(!cat.empty()&&cat!=L"избранное"&&cat!=L"все приложения"&&lower(a.category)!=cat) continue;
        LVITEMW item{}; item.mask=LVIF_TEXT|LVIF_IMAGE|LVIF_PARAM; item.iItem=row; item.iImage=I_IMAGECALLBACK; item.lParam=(LPARAM)i; item.pszText=(LPWSTR)a.name.c_str();
        int image=-1; if(g_images) {
            HICON ico=(HICON)LoadImageW(nullptr,a.icon.c_str(),IMAGE_ICON,32,32,LR_LOADFROMFILE|LR_DEFAULTSIZE);
            if(!ico) ico=ExtractIconW(g_instance,a.launcher.c_str(),0);
            if(ico && ico!=(HICON)1){image=ImageList_AddIcon(g_images,ico);DestroyIcon(ico);}
        }
        item.iImage=image; ListView_InsertItem(g_list,&item);
        ListView_SetItemText(g_list,row,1,(LPWSTR)a.category.c_str()); ++row;
    }
    g_refreshing=false;
}
void runApp(int index,bool admin=false) {
    if(index<0||index>=(int)g_apps.size())return; const auto& a=g_apps[index];
    SHELLEXECUTEINFOW si{};si.cbSize=sizeof(si);si.fMask=SEE_MASK_FLAG_NO_UI;si.hwnd=g_window;si.lpVerb=admin?L"runas":L"open";
    si.lpFile=a.launcher.c_str();si.lpDirectory=fs::path(a.launcher).parent_path().c_str();si.nShow=SW_SHOWNORMAL;
    if(!ShellExecuteExW(&si)) { DWORD e=GetLastError(); if(e!=ERROR_CANCELLED) MessageBoxW(g_window,L"Не удалось запустить PortableApps launcher.",a.name.c_str(),MB_ICONERROR); }
}
void openRoot() { ShellExecuteW(g_window,L"explore",g_appsDir.c_str(),nullptr,nullptr,SW_SHOWNORMAL); }
void toggleFavorite(int index) { if(index<0||index>=(int)g_apps.size())return;g_apps[index].favorite=!g_apps[index].favorite;saveFavorite(g_apps[index]);refreshList(); }
void contextMenu(POINT pt) {
    LVHITTESTINFO hit{};hit.pt=pt;ScreenToClient(g_list,&hit.pt);int row=ListView_SubItemHitTest(g_list,&hit);if(row>=0){ListView_SetItemState(g_list,row,LVIS_SELECTED|LVIS_FOCUSED,LVIS_SELECTED|LVIS_FOCUSED);}
    int idx=selectedIndex(); if(idx<0)return; HMENU m=CreatePopupMenu();
    AppendMenuW(m,MF_STRING,ID_OPEN,L"Открыть");AppendMenuW(m,MF_STRING,ID_RUN_ADMIN,L"Запустить от имени администратора");
    AppendMenuW(m,MF_STRING,ID_FOLDER,L"Открыть папку приложения");AppendMenuW(m,MF_SEPARATOR,0,nullptr);
    AppendMenuW(m,MF_STRING,ID_FAVORITE,g_apps[idx].favorite?L"Убрать из избранного":L"Добавить в избранное");
    UINT cmd=TrackPopupMenu(m,TPM_RETURNCMD|TPM_RIGHTBUTTON,pt.x,pt.y,0,g_window,nullptr);DestroyMenu(m);
    if(cmd==ID_OPEN)runApp(idx);else if(cmd==ID_RUN_ADMIN)runApp(idx,true);else if(cmd==ID_FOLDER)ShellExecuteW(g_window,L"explore",fs::path(g_apps[idx].launcher).parent_path().c_str(),nullptr,nullptr,SW_SHOWNORMAL);else if(cmd==ID_FAVORITE)toggleFavorite(idx);
}
void showMainWindow();
void showTrayMenu() {
    HMENU m=CreatePopupMenu();AppendMenuW(m,MF_STRING,ID_TRAY_OPEN,L"Открыть PortableApps Start");AppendMenuW(m,MF_STRING,ID_TRAY_REFRESH,L"Обновить список приложений");
    AppendMenuW(m,MF_STRING,ID_TRAY_ROOT,L"Открыть папку PortableApps");AppendMenuW(m,MF_SEPARATOR,0,nullptr);AppendMenuW(m,MF_STRING,ID_TRAY_EXIT,L"Выход");
    POINT p{};GetCursorPos(&p);SetForegroundWindow(g_window);UINT c=TrackPopupMenu(m,TPM_RETURNCMD|TPM_RIGHTBUTTON,p.x,p.y,0,g_window,nullptr);DestroyMenu(m);
    if(c==ID_TRAY_OPEN)showMainWindow();else if(c==ID_TRAY_REFRESH)refreshList();else if(c==ID_TRAY_ROOT)openRoot();else if(c==ID_TRAY_EXIT)DestroyWindow(g_window);
}
void showMainWindow() { ShowWindow(g_window,SW_RESTORE);ShowWindow(g_window,SW_SHOW);SetForegroundWindow(g_window);BringWindowToTop(g_window);SetActiveWindow(g_window); }
bool addTray(HWND owner) {
    if(owner)g_window=owner;
    g_nid={};g_nid.cbSize=sizeof(g_nid);g_nid.hWnd=g_window;g_nid.uID=1;g_nid.uFlags=NIF_MESSAGE|NIF_ICON|NIF_TIP;g_nid.uCallbackMessage=WM_TRAY;g_nid.hIcon=g_icon;
    wcscpy_s(g_nid.szTip,L"PortableApps Start");
    if(!Shell_NotifyIconW(NIM_ADD,&g_nid)){SetTimer(g_window,TIMER_TRAY_RETRY,1500,nullptr);return false;}
    g_nid.uVersion=NOTIFYICON_VERSION_4;Shell_NotifyIconW(NIM_SETVERSION,&g_nid);return true;
}
void createControls(HWND w) {
    g_font=CreateFontW(-17,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI");
    g_smallFont=CreateFontW(-13,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,DEFAULT_PITCH|FF_DONTCARE,L"Segoe UI");
    HWND title=CreateWindowExW(0,L"STATIC",L"PortableApps Start",WS_CHILD|WS_VISIBLE,18,12,400,30,w,nullptr,g_instance,nullptr);SendMessageW(title,WM_SETFONT,(WPARAM)g_font,TRUE);
    g_category=CreateWindowExW(0,WC_COMBOBOXW,L"",WS_CHILD|WS_VISIBLE|WS_TABSTOP|CBS_DROPDOWNLIST|WS_VSCROLL,0,0,0,300,w,(HMENU)(INT_PTR)ID_CATEGORY,g_instance,nullptr);SendMessageW(g_category,WM_SETFONT,(WPARAM)g_smallFont,TRUE);
    SendMessageW(g_category,CB_SETMINVISIBLE,12,0);
    g_list=CreateWindowExW(WS_EX_CLIENTEDGE,WC_LISTVIEWW,L"",WS_CHILD|WS_VISIBLE|WS_TABSTOP|LVS_REPORT|LVS_SINGLESEL|LVS_SHOWSELALWAYS,0,0,0,0,w,(HMENU)(INT_PTR)ID_LIST,g_instance,nullptr);
    ListView_SetExtendedListViewStyle(g_list,LVS_EX_FULLROWSELECT|LVS_EX_DOUBLEBUFFER|LVS_EX_LABELTIP);
    LVCOLUMNW col{};col.mask=LVCF_TEXT|LVCF_WIDTH;col.pszText=(LPWSTR)L"Приложение";col.cx=350;ListView_InsertColumn(g_list,0,&col);col.pszText=(LPWSTR)L"Категория";col.cx=170;ListView_InsertColumn(g_list,1,&col);
    g_images=ImageList_Create(32,32,ILC_COLOR32|ILC_MASK,8,8);ListView_SetImageList(g_list,g_images,LVSIL_SMALL);
}
LRESULT CALLBACK WndProc(HWND w,UINT msg,WPARAM wp,LPARAM lp) {
    if(g_taskbarCreated&&msg==g_taskbarCreated){addTray(w);return 0;}
    switch(msg) {
    case WM_NCCREATE:g_window=w;return DefWindowProcW(w,msg,wp,lp);
    case WM_CREATE: g_window=w;createControls(w);addTray(w);if(!RegisterHotKey(w,ID_HOTKEY,MOD_WIN|MOD_SHIFT|MOD_NOREPEAT,'P'))MessageBoxW(w,L"Не удалось назначить горячую клавишу Win+Shift+P: сочетание занято другой программой.",L"PortableApps Start",MB_ICONWARNING);refreshList();return 0;
    case WM_SIZE: if(wp==SIZE_MINIMIZED){ShowWindow(w,SW_HIDE);return 0;}layout(LOWORD(lp),HIWORD(lp));return 0;
    case WM_COMMAND:
        switch(LOWORD(wp)) {
        case ID_CATEGORY:if(HIWORD(wp)==CBN_SELCHANGE)refreshList();return 0;
        case ID_OPEN:runApp(selectedIndex());return 0;
        }
        break;
    case WM_NOTIFY:{auto* n=(LPNMHDR)lp;if(n->idFrom==ID_LIST&&n->code==NM_DBLCLK){runApp(selectedIndex());return 0;}if(n->idFrom==ID_LIST&&n->code==NM_RCLICK){POINT p{};GetCursorPos(&p);contextMenu(p);return 0;}break;}
    case WM_CONTEXTMENU:if((HWND)wp==g_list){POINT p{GET_X_LPARAM(lp),GET_Y_LPARAM(lp)};contextMenu(p);return 0;}break;
    case WM_HOTKEY:if(wp==ID_HOTKEY){showMainWindow();return 0;}break;
    case WM_TRAY:
        if(LOWORD(lp)==WM_LBUTTONUP||LOWORD(lp)==NIN_SELECT||LOWORD(lp)==NIN_KEYSELECT||LOWORD(lp)==WM_LBUTTONDBLCLK){showMainWindow();}
        else if(LOWORD(lp)==WM_RBUTTONUP||LOWORD(lp)==WM_CONTEXTMENU)showTrayMenu();return 0;
    case WM_TIMER:
        if(wp==TIMER_TRAY_RETRY){KillTimer(w,TIMER_TRAY_RETRY);addTray(w);return 0;}
        return 0;
    case WM_CLOSE:ShowWindow(w,SW_HIDE);return 0;
    case WM_DESTROY:UnregisterHotKey(w,ID_HOTKEY);Shell_NotifyIconW(NIM_DELETE,&g_nid);PostQuitMessage(0);return 0;
    }
    return DefWindowProcW(w,msg,wp,lp);
}
}
int WINAPI wWinMain(HINSTANCE instance,HINSTANCE,PWSTR,int) {
    g_instance=instance;SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);g_taskbarCreated=RegisterWindowMessageW(L"TaskbarCreated");setPaths();
    HANDLE mutex=CreateMutexW(nullptr,TRUE,L"Local\\PortableAppsStartNative_v1");if(mutex&&GetLastError()==ERROR_ALREADY_EXISTS){HWND old=FindWindowW(kClassName,nullptr);if(old){ShowWindow(old,SW_RESTORE);ShowWindow(old,SW_SHOW);SetForegroundWindow(old);BringWindowToTop(old);}CloseHandle(mutex);return 0;}
    INITCOMMONCONTROLSEX cc{sizeof(cc),ICC_LISTVIEW_CLASSES|ICC_STANDARD_CLASSES};InitCommonControlsEx(&cc);g_icon=makeIcon(32);
    WNDCLASSEXW wc{};wc.cbSize=sizeof(wc);wc.hInstance=instance;wc.lpfnWndProc=WndProc;wc.lpszClassName=kClassName;wc.hCursor=LoadCursorW(nullptr,IDC_ARROW);wc.hIcon=g_icon;wc.hIconSm=g_icon;wc.hbrBackground=(HBRUSH)(COLOR_WINDOW+1);RegisterClassExW(&wc);
    const int width=620,height=650;int x=GetSystemMetrics(SM_CXSCREEN)-width-24,y=GetSystemMetrics(SM_CYSCREEN)-height-64;
    g_window=CreateWindowExW(WS_EX_TOOLWINDOW,kClassName,L"PortableApps Start",WS_OVERLAPPEDWINDOW|WS_CLIPCHILDREN,x,y,width,height,nullptr,nullptr,instance,nullptr);
    if(!g_window)return 1;ShowWindow(g_window,SW_SHOW);UpdateWindow(g_window);
    MSG msg;while(GetMessageW(&msg,nullptr,0,0)>0){TranslateMessage(&msg);DispatchMessageW(&msg);}
    if(g_images)ImageList_Destroy(g_images);if(g_icon)DestroyIcon(g_icon);if(g_font)DeleteObject(g_font);if(g_smallFont)DeleteObject(g_smallFont);if(mutex)CloseHandle(mutex);return (int)msg.wParam;
}
