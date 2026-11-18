# PortableApps Start — implementation plan

## Direction

The project now uses a small native C++17/Win32 launcher instead of compiling or modifying the full Delphi VCL platform. The 30.4 source remains available under `source/upstream-30.4` as a compatibility reference. The target is a quick, portable x64 GUI executable that calls the existing PortableApps launchers and companion tools.

## Native launcher (0.3.0)

Implemented in `native/PortableAppsStart.cpp`:

- Resolve the `PortableApps` directory from the launcher's location.
- Discover PAF packages through `App/AppInfo/appinfo.ini`, plus legacy direct EXEs using Platform 30.4 rules and menu settings.
- Launch the path named by `[Control] Start` in the app package folder.
- Search by app name and category; filter by category and favorites.
- Save favorite state in a launcher-specific INI file next to the application.
- Provide app context actions to open normally, request elevation, open its folder, and toggle favorite.
- Stay in the notification area without a taskbar button; closing/minimizing hides the window. Tray registration recovers after Explorer restarts.
- Provide shortcuts to install a `.paf.exe`, update applications, back up, restore, and open the apps folder.
- Accept only `.paf.exe` installers and refresh discovery when the installer process exits.
- Enforce one running instance and refresh app discovery on request or after installation.

## Next increments

1. Try the launcher against a copied real PortableApps installation and correct any layout, Unicode, elevation, installer, or updater differences.
2. Load each app's own icon, add empty-list/setup guidance, and improve the Start-like layout while keeping the binary compact.
3. Add configurable hotkeys and auto-start only after preserving expected PortableApps behavior.
4. Add app rename/hide, category management, ordered favorites, and import/export or migration from `Data/PortableAppsMenu.ini`.
5. Add a portable distribution folder and verify update/backup delegation against the official companion tools.
6. Keep the original project notices and clearly identify functions intentionally omitted from the native edition.

## Compatibility and release checks

- Run against a disposable copy of a PortableApps drive first.
- Confirm app discovery for PAF packages with Unicode names and non-ASCII paths.
- Confirm `[Control] Start` launch behavior and preserve user data across repeated launches.
- Confirm favorite persistence, category and search filters, tray reopen/exit, and single-instance behavior.
- Check that `.paf.exe` installation targets the PortableApps folder and refreshes the list when done.
- Check updater and backup launch only when their companion executable exists.
- Confirm display scaling and usable layout on a small screen.
- Compare the executable size and dependencies after release builds.

## Known gaps in 0.2.0

The prototype is not a line-for-line port of Platform 30.4 and does not yet implement its complete feature set. It does not import old favorites/settings, auto-start apps, support multiple launcher icons from one package, create/manage categories, reorder items, handle language packs, or implement platform settings. No real PortableApps drive was available for integration validation during the first build.
