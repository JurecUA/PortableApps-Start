# Building PortableApps Start

## Requirements

- Windows 10 or 11 x64.
- Visual Studio Build Tools with the **Desktop development with C++** workload, MSVC x64 compiler/linker, Windows SDK, and `vswhere.exe`.
- PowerShell (included with Windows).

No Delphi, .NET SDK, NSIS, or third-party C++ library is required for the native launcher. The EXE links the Microsoft runtime statically (`/MT`).

## Build

Run `native\build.bat`. The script generates the multi-size ICO from the project artwork, initializes the latest installed MSVC toolchain, compiles the icon/version resource, and writes:

`native\build\PortableAppsStart.exe`

The compiler target is x64. `native\build` is excluded from Git. Source and build script are in `native`.

## PortableApps layout

For a normal installation, place `PortableAppsStart.exe` beside the PortableApps companion executables, typically under `PortableApps\PortableApps.com`. The launcher finds the sibling `PortableApps` folder and scans app folders there. It reads the platform's `PortableApps.com\Data\PortableAppsMenu.ini` (or a sibling `Data\PortableAppsMenu.ini` when installed beside the platform) to follow hidden-app, favorite, rename, category, and multi-icon preferences. It writes its own settings to `Data\PortableAppsStart.ini` in that same data folder.

PAF packages are discovered through `App\AppInfo\appinfo.ini` and launched through their declared `[Control] Start` executable. Other app folders are scanned for EXE files directly inside the folder; nested helper EXEs are not listed. The platform's `AppsHidden` entries are applied to both kinds of applications.

It launches each app using `AppInfo\appinfo.ini` → `[Control] Start`, so PortableApps' own launcher continues to manage per-app data. Updating and backup buttons call `PortableAppsUpdater.exe`, `PortableAppsBackup.exe`, or `PortableAppsBackupRestore.exe` beside the launcher when those files exist.

The Add button runs a selected `.paf.exe` with PortableApps silent install arguments and the detected `PortableApps` directory as its destination. Confirm the destination shown by the installer when using this prototype with an existing installation. The app list refreshes after the installer process exits.

## Build result on this PC

Built with Visual Studio Build Tools 18.11 and Windows SDK 10.0.26100. The result is a native x64 Windows GUI executable with the application icon embedded. No Delphi installer or license activation was needed. The code has been compiled; this does not certify runtime behavior against every PortableApps installation.
