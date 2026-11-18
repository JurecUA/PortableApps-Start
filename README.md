# PortableApps Start

Compact Windows launcher for PortableApps.com installations. The native launcher is written in C++17 and Win32; it does not require Delphi or a separate .NET runtime.

## Current version: 0.4.0

This is the first native C++ prototype, built as a standalone x64 EXE. The 30.4 Delphi source archives remain in `source/upstream-30.4` as reference material. This prototype replaces the launcher UI and its core app discovery/launch path; it does not port the complete Platform or Updater codebase.

## Features

- Finds PAF apps through `App/AppInfo/appinfo.ini` and legacy apps by scanning EXEs directly inside each app folder, following PortableApps Platform 30.4 discovery rules.
- Starts each app through the PAF launcher named by `[Control] Start`, preserving PortableApps data handling.
- Category filtering, favorite toggles, app icons, and an app context menu.
- System tray without a taskbar button, click-to-open behavior, `Win+Shift+P` hotkey, hide-on-close/minimize, single-instance behavior, and tray recovery after Explorer restarts.
- Reads PortableApps 30.4 hidden-app, favorite, rename, category, and multi-icon preferences from `PortableAppsMenu.ini`; stores launcher-specific favorite overrides in `Data/PortableAppsStart.ini`.

## Build

Run `native/build.bat` in a Visual Studio Developer Command Prompt or on a machine with Visual C++ Build Tools and a Windows SDK. It builds a self-contained native Win32 API executable with the MSVC static runtime. Details: [BUILD.md](BUILD.md).

## Project files

- [Implementation plan](IMPLEMENTATION_PLAN.md)
- [Architecture audit of upstream 30.4](ARCHITECTURE_AUDIT.md)
- [Build instructions](BUILD.md)
- [Change log](CHANGELOG.md)
- [Custom vector icon](assets/portableapps-start.svg)
- Native implementation: `native/PortableAppsStart.cpp`

## Current limits

This prototype focuses on launching installed apps. It does not auto-start apps, reproduce custom category management/drag sorting, or implement Platform settings and language packs. Installers, updating, backup, and restore remain in the official companion apps. The build is x64; test it with your PortableApps installation before replacing an existing platform.

The inherited upstream source is retained with its copyright and license notices. The new native code is original project code; see the repository license and upstream notices before redistribution.
