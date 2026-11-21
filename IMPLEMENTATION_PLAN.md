# PortableApps Start — implementation plan

## Direction

The project now uses a small native C++17/Win32 launcher instead of compiling or modifying the full Delphi VCL platform. The 30.4 source remains available under `source/upstream-30.4` as a compatibility reference. The target is a quick, portable x64 GUI executable that calls the existing PortableApps launchers and companion tools.

## Native launcher (0.6.12)

Implemented in `native/PortableAppsStart.cpp`:

- Resolve the `PortableApps` directory from the launcher's location.
- Discover PAF packages through `App/AppInfo/appinfo.ini`, plus legacy direct EXEs using Platform 30.4 rules and menu settings.
- Launch the path named by `[Control] Start` in the app package folder.
- Show pinned apps and the selected category's apps as five-column tiles; scroll the grid and filter with a custom category menu.
- Create user categories and move apps into an existing or newly created category.
- Save favorite state in a launcher-specific INI file next to the application.
- Provide app context actions to open normally, request elevation, open its folder, pin/unpin, assign a category, and enable startup launch.
- Stay in the notification area without a taskbar button; closing/minimizing hides the window. Tray registration recovers after Explorer restarts.
- Open the main window on tray click and with `Ctrl+Alt+Space`; hide it when another application receives focus.
- Launch selected startup apps after the launcher starts, skipping processes already running from the same executable path.
- Keep the launcher focused on installed apps; omit in-app search, installer, updater, backup, and restore controls.
- Keep the tray menu to reopen the launcher, refresh discovery, open the apps folder, or exit.
- Enforce one running instance and refresh app discovery on request.

## Next increments

1. Try the launcher against a copied real PortableApps installation and correct any layout, Unicode, or elevation differences.
2. Add drag reordering for pinned apps and categories, plus category rename/delete.
3. Add platform-compatible hide/unhide and app rename actions.
4. Add theme and hotkey settings after preserving the current default interaction.
5. Keep install, update, backup, and restore features in the official companion applications.
6. Keep the original project notices and clearly identify functions intentionally omitted from the native edition.

## Compatibility and release checks

- Run against a disposable copy of a PortableApps drive first.
- Confirm app discovery for PAF packages with Unicode names and non-ASCII paths.
- Confirm `[Control] Start` launch behavior and preserve user data across repeated launches.
- Confirm pin persistence, category filtering and assignment, startup launch without duplicate processes, outside-click hiding, tray click, global hotkey, and single-instance behavior.
- Confirm display scaling and usable layout on a small screen.
- Compare the executable size and dependencies after release builds.

## Known gaps in 0.6.8

The prototype is not a line-for-line port of Platform 30.4. It does not reorder tiles by drag, rename/delete categories, implement user-facing hide/rename actions, handle language packs, or implement all platform settings. Runtime behavior still needs confirmation on the user's PortableApps installation.

