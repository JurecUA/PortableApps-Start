# История изменений

## 0.6.11 — 2026-11-21

- Replace the tray context menu with a frameless custom flat popup featuring rounded corners and inline sorting choices.
- Remove the main window border and apply a rounded region to match the flat interface.

## 0.6.10 — 2026-11-21

- Center the category selector and its popup menu over the launcher.
- Draw submenu chevrons in owner-drawn menus so the sort submenu arrow is visible.

## 0.6.9 — 2026-11-21

- Read configuration files with `CreateFileW`/`ReadFile` so Unicode paths are handled explicitly.
- Read category names dynamically instead of silently truncating input at 255 characters; reject line breaks in saved category names.
- Include the Windows error message when an application fails to launch.

## 0.6.8 — 2026-11-21

- Fix the launcher working-directory lifetime when starting an app from its context menu.
- Refuse invalid launch targets outside the PortableApps folder.
- Report failed settings writes and preserve the previous in-memory setting when saving fails.
- Guard icon creation against GDI allocation failures; cap INI reads and keep per-folder scan errors local.

## 0.6.7 — 2026-11-21

- Keep the app's working-directory string alive through `ShellExecuteExW`; validate that launch targets are existing EXE files inside the PortableApps folder.
- Bound INI reads, reject malformed UTF-16 byte lengths, check settings-write failures, and isolate per-folder enumeration errors.
- Check GDI resource creation in the launcher icon path and normalize executable paths before duplicate-process checks.

## 0.6.6 — 2026-11-21

- Guard owner-drawn menu callbacks against stale item data and complete popup dismissal with the tray owner window.
- Use unique launcher keys for PAF multi-icon preferences, while reading older folder-based settings for compatibility.
- Check candidate running processes in one snapshot during app autostart instead of scanning the full process list per app.
- Release shared menu and dialog brushes when the launcher exits.

## 0.6.5 — 2026-11-21

- Apply the dark theme to category creation, all launcher menus, and tray menus; remove the light system dialog frame.
- Double-buffer launcher painting and repaint only the tiles whose hover state changes to prevent flicker.
- Remove the category selector outline and tighten its spacing above the app grid.

## 0.6.4 — 2026-11-21

- Use Segoe UI Variable throughout the launcher.
- Move the category selector below the pinned apps and draw its popup using the same dark palette as the launcher.
- Remove the Pinned option from the category popup and remove the horizontal divider under the pinned section.
- Render every app icon in a uniform 32 px box, scaling small source icons such as Chrome's to match while preserving aspect ratio.

## 0.6.3 — 2026-11-18

- Fix the app-name caption baseline so it remains below icons without changing their display size.
- Remove favorite star overlays while keeping the pinned-app area and its pin/unpin context action.
- Track and persist app launch counts; sort apps and pins by usage by default, with alphabetical choices in the launcher context menu.
- Tighten the five-column grid and reduce the launcher window to fit it.
- Add a Windows startup toggle to the launcher context menu and tray menu, stored under the current user's Run registry key and off by default.

## 0.6.2 — 2026-11-18

- Read source icon dimensions and preserve them up to the 32 px Start-menu icon size, without enlarging small images or stretching non-square icons.

## 0.6.1 — 2026-11-18

- Use 32 px app icons without enlarging extracted images.
- Make All Apps a dedicated filter state so every discovered, non-hidden app is shown.
- Replace the bright system scrollbar with a narrow dark scrollbar that widens slightly on hover.
- Stop invalidating the full launcher when the pointer moves across app icons, removing icon flicker.

## 0.6.0 — 2026-11-18

- Remember the launcher position across hide, minimize, and restart.
- Reduce the window to a compact five-column layout and remove the app-name header and tile cards.
- Draw app icons at 64 logical pixels while preserving their square icon aspect.
- Reset scrolling when switching categories and provide an explicit Hidden Apps category.
- Add Hide/Show to each app context menu; hidden apps are excluded from normal views and autostart remains configurable.

## 0.5.0 — 2026-11-18

- Заменён табличный экран на компактное окно в стиле меню «Пуск»: закреплённые и общие приложения показаны плитками по пять в строке; окно появляется справа по центру экрана.
- Селектор категорий теперь открывает отдельное меню; доступны фильтр категорий и создание пользовательской категории, а приложение можно переместить в категорию через контекстное меню.
- Добавлен пункт автозапуска приложения при старте лаунчера. Настройка сохраняется, уже запущенный процесс повторно не запускается.
- Окно скрывается при переключении на другое приложение; назначена горячая клавиша `Ctrl+Alt+Пробел`.
- Сохранены закрепление через контекстное меню, прокрутка плиток и работа в системном трее.

## 0.4.0 — 2026-11-18

- Исправлен клик по значку в трее: окно открывается и не исчезает сразу.
- Назначена горячая клавиша `Win+Shift+P`.
- Убран поиск; окно сосредоточено на категориях и списке программ, раскрытие выбора категорий исправлено.
- Удалены встроенные установка приложений, проверка обновлений, архивация и восстановление; эти задачи остаются в companion-приложениях PortableApps.
- В меню трея оставлены открытие окна, обновление списка, открытие папки приложений и выход.

## 0.3.0 — 2026-11-18

- Исправлена регистрация значка в трее; добавлено повторное подключение после перезапуска Проводника Windows.
- Убрано окно с панели задач; закрытие и сворачивание прячут его в трей.
- Добавлено обнаружение обычных EXE внутри папок приложений по правилам PortableApps Platform 30.4.
- Учтены настройки `PortableAppsMenu.ini`: скрытые приложения и служебные EXE исключаются, применяются избранное, переименования, категории и настройка нескольких значков.
- Настройки платформы читаются из `PortableApps.com\Data`, даже если launcher лежит в корне диска.

## 0.2.1 — 2026-11-18

- Установщик принимает только `.paf.exe`; добавлена проверка и для выбора файла, и для drag-and-drop.
- Список приложений обновляется после завершения установщика.

## 0.2.0 — 2026-11-18

- Переписан основной launcher на C++17 и Win32 API: собран автономный x64 `.exe`.
- Добавлены обнаружение PAF-приложений по `appinfo.ini`, запуск штатного launcher, поиск, фильтр категории, избранное и значки.
- Добавлены системный трей, скрытие окна при закрытии, одиночный экземпляр, запуск от администратора и открытие папки приложения.
- Подключены кнопки установки PAF-пакета, обновления приложений, архивации и восстановления через штатные PortableApps утилиты.
- Добавлена собственная многослойная `.ico` и воспроизводимый скрипт сборки Visual C++.
- Delphi исходники 30.4 сохранены как справочный snapshot; полный набор функций оригинальной Platform ещё не портирован.

## 0.1.5 — 2026-11-18

- Завершён статический обзор обнаружения приложений, избранного, категорий, скрытия, автозапуска, горячей клавиши, трея, обновления приложений и архивации.
- Уточнена сборочная инструкция по RAD Studio 13.1 и зафиксировано отсутствие Delphi compiler на текущем компьютере.
- На этапе 0.1.x контрольная сборка и функциональные проверки ещё не выполнялись.

## 0.1.4 — 2026-11-18

- Добавлены исходники Platform, Start и Updater 30.4 с проверенными контрольными суммами Platform.
- Подтверждены Delphi VCL/Win32 проекты, NSIS-сценарий Updater и существующая поддержка системного трея.
- Обновлены аудит, инструкция сборки и исключения для локальных результатов компиляции.
- Контрольная сборка пока не выполнялась.

## 0.1.3 — 2026-11-12

- Выравнена структура опубликованного репозитория: исходник иконки находится в `assets/portableapps-start.svg`.

## 0.1.2 — 2026-11-12

- Обновлена текущая версия в README.

## 0.1.1 — 2026-11-12

- Уточнена инструкция по компилятору: официальный журнал изменений сообщает о Delphi 13.1 начиная с версии платформы 30.3.
- Оставлены открытыми редакция IDE и дополнительные компоненты до анализа исходников.

## 0.1.0 — 2026-11-12

- Зафиксированы решения по базе 30.4, режиму работы из трея и направлению иконки.
- Добавлены предварительный аудит, план реализации, README и эта история изменений.
- Добавлен исходник векторной иконки.
- Сборка исходного приложения пока не выполнялась; архив официальных исходников не удалось получить в рабочей среде.


