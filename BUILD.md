# Сборка PortableApps Start

## Состояние инструкции

Исходники 30.4 получены и распакованы. Проверка компьютера 18 ноября 2026 года не нашла `dcc32`/`dcc64`, каталоги Embarcadero или RAD Studio в реестре; команда `msbuild` тоже не найдена в PATH. Сборка `.exe` ещё не выполнялась и без Delphi compiler не может начаться.

## Что известно

Platform и Start — проекты Delphi VCL с `.dproj`, настроенные на Win32/x86; Start запускает `PortableAppsPlatform.exe` в структуре PortableApps. Updater 30.4 собирается из NSIS `.nsi` с локальными `.nsh`. Для исходного 30.4 журнал обновлений указывает Delphi 13.1. В RAD Studio 13.1 официальный feature matrix относит Delphi Win32 compiler/toolchain к Professional и старшим редакциям; Community в матрице указана только для Delphi 12.1. Точная совместимость пакетов проекта требует контрольной сборки.

## Что установить сейчас

- Embarcadero RAD Studio / Delphi 13.1 Professional или старше, с Delphi Win32 compiler (DCC32), VCL и MSBuild. До покупки/установки проверить у Embarcadero доступность подходящей лицензии и компонентов для проекта.
- Git для истории версий (уже установлен в текущей среде).
- 7-Zip только если понадобится заново распаковывать `.7z` (текущие архивы уже распакованы).
- NSIS нужен только для пересборки Updater из предоставленного сценария.

Visual Studio не заменяет Delphi compiler; отдельная установка Visual Studio по исходным проектам не требуется. На текущем компьютере не обнаружены Delphi, MSBuild и NSIS в PATH/стандартных каталогах. Поэтому EXE сейчас собрать нельзя. Когда RAD Studio будет установлена, сначала открыть Platform `.dproj`, собрать Release/Win32 и устранить отсутствующие Delphi packages; затем отдельно собрать Start. NSIS понадобится только для сборки Updater.

Официальные справочные материалы: [матрица возможностей RAD Studio 13.1](https://www.embarcadero.com/docs/rad-studio-feature-matrix.pdf) и [документация Delphi Compiler](https://docwiki.embarcadero.com/RADStudio/Florence/en/Delphi_Compiler).

