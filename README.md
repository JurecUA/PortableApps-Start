# PortableApps Start

Compact Windows launcher for PortableApps.com installations. The native launcher is written in C++17 and Win32; it does not require Delphi or a separate .NET runtime.

## Current version: 0.2.0

This is the first native C++ prototype, built as a standalone x64 EXE. The 30.4 Delphi source archives remain in `source/upstream-30.4` as reference material. This prototype replaces the launcher UI and its core app discovery/launch path; it does not port the complete Platform or Updater codebase.

## Features

- Finds PortableApps Format apps under `PortableApps` by reading `App/AppInfo/appinfo.ini`.
- Starts each app through the PAF launcher named by `[Control] Start`, preserving PortableApps data handling.
- Search, category filtering, favorite toggles, app icons, and an app context menu.
- System tray, hide-on-close, single-instance behavior, and a four-tile portable-drive icon.
- PAF installer selection and drag-and-drop; invokes the standard PortableApps silent install arguments.
- Opens installed PortableApps updater, backup, and restore utilities when present beside this launcher.
- Stores favorites in `Data/PortableAppsStart.ini` beside the launcher.

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

This prototype covers common launcher tasks, not every Platform 30.4 feature. It does not migrate `PortableAppsMenu.ini`, auto-start apps, reproduce custom category management/drag sorting, handle multiple icons per package, or implement Platform settings and language packs. It delegates updating and backup to the official companion executables. The first build is x64; test it with a copied PortableApps installation before replacing an existing platform.

The inherited upstream source is retained with its copyright and license notices. The new native code is original project code; see the repository license and upstream notices before redistribution.
