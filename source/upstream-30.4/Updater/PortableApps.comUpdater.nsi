;Copyright 2009-2026 John T. Haller of PortableApps.com
;With concepts from Marko Moeller and Ryan McCue
;Website: https://portableapps.com/

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

;=== Runtime Switches
Unicode true 
ManifestDPIAware true
AutoCloseWindow true
CRCCheck on
RequestExecutionLevel user
XPStyle on
SetCompress auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize on
ShowInstDetails nevershow

;=== Defines
!define APP_NAME "PortableApps.com Updater"
;!define FRIENDLY_VERSION "30.3"
!define PRODUCT_VERSION "30.4.0.0"
!define WEBSITE "PortableApps.com"

;!define DebugBuild

;=== Program Details
Name "${APP_NAME}"
OutFile "PortableAppsUpdater.exe"
Caption "PortableApps.com Platform"
VIProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey ProductName "${APP_NAME}"
VIAddVersionKey Comments "Application and platform updater.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "John T. Haller"
VIAddVersionKey FileDescription "${APP_NAME}"
VIAddVersionKey FileVersion "${PRODUCT_VERSION}"
VIAddVersionKey ProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey InternalName "${APP_NAME}"
VIAddVersionKey LegalTrademarks "PortableApps.com is a trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "PortableApps.comUpdater.exe"

;=== Constants
!define UPDATE_FILE_7Z "$PLUGINSDIR\update.7z" ;TEMP location for compressed updater database while in use
!define UPDATE_FILE_INI "$PLUGINSDIR\Update.ini" ;TEMP location for the updater database while in use
;!define UPDATE_FILE_INI_STORED "$EXEDIR\Data\Update.ini" ;Location for storing the updater database between runs
!define APP_LIST_FILE_INI "$PLUGINSDIR\AppList.ini" ;The temporary location of the app list for the listbox component
!define UPDATER_DATABASE_URL "portableapps.com/updater/update.php" ;updater database

;=== Include
;(Standard)
!include FileFunc.nsh
!insertmacro GetOptions
!insertmacro GetParent
!include LogicLib.nsh
!include MUI2.nsh
!include WinVer.nsh
!include WordFunc.nsh
!insertmacro VersionCompare
!insertmacro WordReplace
;(Custom)
;!include GetWindowsVersion.nsh
!include ReadINIStrWithDefault.nsh
!include StrLoc.nsh
!include ProcFunc.nsh
!include TBProgress.nsh

;=== Icon & Style ===
; MUI Settings
!define MUI_ICON "PortableApps.comUpdater.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "PortableApps.comUpdater.bmp"
!define MUI_HEADERIMAGE_BITMAP_RTL "PortableApps.comUpdaterRTL.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "PortableApps.comUpdaterFinish.bmp"
BrandingText $strBrandingTextCustom

;=== Pages
; == Components page ==
Page custom AppListShow AppListLeave

# Reserve plugin files (good practice)
ReserveFile `${NSISDIR}\Plugins\EmbeddedLists.dll`

!define MUI_PAGE_CUSTOMFUNCTION_SHOW InstallFilesShow
!insertmacro MUI_PAGE_INSTFILES

!define MUI_PAGE_CUSTOMFUNCTION_SHOW CustomFinishText
# !define MUI_FINISHPAGE_CANCEL_ENABLED
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

;=== Languages
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "EnglishGB"
!insertmacro MUI_LANGUAGE "Afrikaans"
!insertmacro MUI_LANGUAGE "Albanian"
!insertmacro MUI_LANGUAGE "Amharic"
!insertmacro MUI_LANGUAGE "Arabic"
!insertmacro MUI_LANGUAGE "Armenian"
!insertmacro MUI_LANGUAGE "Basque"
!insertmacro MUI_LANGUAGE "Belarusian"
!insertmacro MUI_LANGUAGE "Bengali"
!insertmacro MUI_LANGUAGE "Bosnian"
!insertmacro MUI_LANGUAGE "Bulgarian"
!insertmacro MUI_LANGUAGE "Burmese"
!insertmacro MUI_LANGUAGE "Catalan"
!insertmacro MUI_LANGUAGE "Corsican"
!insertmacro MUI_LANGUAGE "Croatian"
!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Esperanto"
!insertmacro MUI_LANGUAGE "Estonian"
!insertmacro MUI_LANGUAGE "Farsi"
!insertmacro MUI_LANGUAGE "Filipino"
!insertmacro MUI_LANGUAGE "Finnish"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "Galician"
!insertmacro MUI_LANGUAGE "Georgian"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Greek"
!insertmacro MUI_LANGUAGE "Hebrew"
!insertmacro MUI_LANGUAGE "Hindi"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Icelandic"
!insertmacro MUI_LANGUAGE "Igbo"
!insertmacro MUI_LANGUAGE "Indonesian"
!insertmacro MUI_LANGUAGE "Irish"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Japanese"
!insertmacro MUI_LANGUAGE "Khmer"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Kurdish"
!insertmacro MUI_LANGUAGE "Latvian"
!insertmacro MUI_LANGUAGE "Lithuanian"
!insertmacro MUI_LANGUAGE "Luxembourgish"
!insertmacro MUI_LANGUAGE "Macedonian"
!insertmacro MUI_LANGUAGE "Malagasy"
!insertmacro MUI_LANGUAGE "Malay"
!insertmacro MUI_LANGUAGE "Marathi"
!insertmacro MUI_LANGUAGE "Mongolian"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "Pashto"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Punjabi"
!insertmacro MUI_LANGUAGE "Romanian"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "ScotsGaelic"
!insertmacro MUI_LANGUAGE "Serbian"
!insertmacro MUI_LANGUAGE "SerbianLatin"
!insertmacro MUI_LANGUAGE "Sesotho"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "Slovak"
!insertmacro MUI_LANGUAGE "Slovenian"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "SpanishInternational"
!insertmacro MUI_LANGUAGE "Sundanese"
!insertmacro MUI_LANGUAGE "Swahili"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "Tamil"
!insertmacro MUI_LANGUAGE "Tatar"
!insertmacro MUI_LANGUAGE "Thai"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "Twi"
!insertmacro MUI_LANGUAGE "Ukrainian"
!insertmacro MUI_LANGUAGE "Urdu"
!insertmacro MUI_LANGUAGE "Uyghur"
!insertmacro MUI_LANGUAGE "Uzbek"
!insertmacro MUI_LANGUAGE "Vietnamese"
!insertmacro MUI_LANGUAGE "Welsh"
!insertmacro MUI_LANGUAGE "Yoruba"
!insertmacro MUI_LANGUAGE "Zulu"
;InstallButtonText "$(^NextBtn)"

;=== Variables
!define NON-BREAKING_SPACE " "
Var strRealCaption
Var strPortableAppsPath
Var bolPlatformStartupMode
Var bolUpdateMode
Var bolBetaPlatformReleases
Var bolShowInstalledApps
Var strBetaPlatformReleasesSuffix
Var bolPlatformUpdateMode
Var bolAddAll
Var bolDownloadFailed
Var strShowFreewareApps
Var bolLicenseMatch
Var bolShowAdvanced
Var strLanguageName
Var strLanguageNameFallback
Var strLanguageNameFile
Var intLocaleID
Var strLocaleFile
Var strSettingsFile
Var strCurrentAppID
Var strCurrentAppIDClean
Var intUpdaterApps
Var intCurrentAppCounter
Var strCurrentAppName
Var strCurrentAppNameShort
Var strCurrentAppCategory
Var strCurrentAppCategoryLocalized
Var strCurrentAppSubCategory
Var strCurrentAppType
Var strCurrentAppInfoPath
Var strCurrentAppBasePath
Var strCurrentAppPackageVersion
Var strCurrentAppDisplayVersion
Var strCurrentAppDownloadFile
Var strCurrentAppDownloadPath
Var strDownloadToLocalPath
Var strCurrentExtraPieceDownloadFile
Var strCurrentExtraPieceDownloadPath
Var strCurrentAppDownloadSize
Var strCurrentAppInstallSize
;Var strCurrentAppInstallSizeTo
Var bolCurrentAppBasePathExists
Var bolCommonFilesExists
Var strCurrentAppLicense
;Var strCurrentAppCompatibility
Var bolCurrentAppAdvanced
Var strCurrentAppMinOS
Var strCurrentAppMaxOS
Var strCurrentAppBits
Var strCurrentAppClass
;Var bolCurrentAppUpdateOnly
Var strCurrentAppIcon
Var bolCurrentAppListed
Var bolCurrentAppListedDisabled
Var strCurrentAppInstalledVersion
Var strCurrentAppHash
Var strCurrentAppReleasedOn
Var strCurrentAppUpdatedOn
;Var bolCurrentApp64Bit
;Var strCurrentAppInstallerEXE
Var intSelectedApps
Var intCounter
Var intCurrentApp
Var intAppsToProcess
Var strBrandingTextCustom

Var bolSecondDownloadAttempt
Var bolErrors
Var bolUpdaterHasRun
Var bolBannerIsUp
;Var intDownloadSize
Var strTempMessage
Var strTempMessage2
;Var intInstallSize
Var bolSecondTryDuringMaintenance
Var bolShowErrorsInStartupMode
Var strPAcInstallerExecString

Var strMutex

Var bolKeyboardFriendly
Var bolHidePortableInAppNames
Var bolHide64BitApps
Var strInstall32BitInDualMode
Var strSelectedApps
Var strOrder

Var strConnectionType
Var strProxyIP
Var strProxyPort


Var strFullErrorMessageAtEnd

Var intDPI
Var intDPIMultiply
Var intDPIDivide

Var strUserAgent

Var intWarnOnZoneCrossing
Var intSecureProtocols

Var strWindowsVersion
Var strWindowsVersionSimple
Var bolTLSUpdate
Var strWindowsEra
Var strBitDepth

;Var bolProcessRunningBug
;Var bolProcessRunningBugAffectedInstallers

Var fileAppList
Var fileIconList

Var intSettingsCount

Var strRemoteUpdateURL
Var strHTTPProtocol

Var strFontName
Var intFontSize
Var fntPlatform
Var fntPlatformBold
Var fntPlatformTitle
Var fntPlatformFinish

Var strIgnoreAppsDuringUpdate



;(Localized Strings)
Var strLocaleDirection
Var strTransCategoryAccessibility
Var strTransCategoryDevelopment
Var strTransCategoryEducation
Var strTransCategoryGames
Var strTransCategoryGraphicsPictures
Var strTransCategoryInternet
Var strTransCategoryMusicVideo
Var strTransCategoryOffice
Var strTransCategorySecurity
Var strTransCategoryUtilities
Var strTransColumnMB
Var strTransColumnApp
Var strTransColumnDownloadSize
Var strTransColumnInstallSize
Var strTransColumnDescription
Var strTransColumnAppType
Var strTransColumnCategory
Var strTransColumnSubCategory
Var strTransColumnReleasedOn
Var strTransColumnUpdatedOn
Var strTransDownloadConnecting
Var strTransDownloadingXofY
Var strTransDownloadingXofYVerifying
Var strTransDownloadInvalid
Var strTransInstallingXofY
Var strTransIntroWait
Var strTransIntroUpToDate
Var strTransIntroNoOtherApps
Var strTransSectionHeadingNew
Var strTransSectionSubHeadingNew
Var strTransSectionHeadingUpdate
Var strTransSectionSubHeadingUpdate
Var strTransDownloadHeading
Var strTransDownloadSubHeading
Var strTransFinishHeadingNew
Var strTransFinishTextNew
Var strTransFinishHeadingUpdate
Var strTransFinishTextUpdate
Var strTransFinishHeadingFail
Var strTransFinishTextFail
Var strTransErrorNoConnection
Var strTransFinishHeadingNoSelection
Var strTransFinishTextNoSelectionStore
Var strTransFinishTextNoSelectionUpdater
Var strTransUpToDate
Var strTransLargeDriveWorkaround
Var strTransAlreadyRunning
Var strTransProcessRunningBug
Var strTransTimeSecond
Var strTransTimeMinute
Var strTransTimeHour
Var strTransTimePlural
Var strTransTimeRemaining
Var strTransTimeKB
Var strTransTimeKBs
Var strTransTimeOf
Var strTransDownloadError
Var strTransDownloadErrorSiteMaintenance
Var strTransDownloadErrorSendRequest
Var strTransRequiredPlatformUpdate
Var strTransPlatformNotRunning
Var strTransOldWindowsBugs

Function AdjustWidthForDPI
	;Start with a clean slate
	ClearErrors
	
	;Get our parameters
	Exch $0 ;STARTING_WIDTH
	Push $1

	IntOp $1 $0 * $intDPIMultiply
	IntOp $0 $1 / $intDPIDivide
	
	;Reset the last variable and leave our result on the stack
	Pop $1
	Exch $0
FunctionEnd

!define AdjustWidthForDPI '!insertmacro "AdjustWidthForDPI"'
!macro AdjustWidthForDPI OUTPUT_VALUE STARTING_WIDTH
  Push `${STARTING_WIDTH}`
  Call AdjustWidthForDPI
  Pop `${OUTPUT_VALUE}`
!macroend

!define PageHeaderHackForHighContrast "!insertmacro PageHeaderHackForHighContrast"
!macro PageHeaderHackForHighContrast
	!if ${MUI_SYSVERSION} >= 2
		SetCtlColors $mui.Header.Text 0x000000 0xFFFFFF
		SetCtlColors $mui.Header.SubText 0x000000 0xFFFFFF
		SendMessage $mui.Header.Text ${WM_SETFONT} $fntPlatformBold 1
		SendMessage $mui.Header.SubText ${WM_SETFONT} $fntPlatform 1
	!else
		Push $0
		FindWindow $0 "#32770" "" $HWNDPARENT
		GetDlgItem $0 $HWNDPARENT 1037
		SetCtlColors $0 0x000000 0xFFFFFF
		GetDlgItem $0 $HWNDPARENT 1038
		SetCtlColors $0 0x000000 0xFFFFFF
		Pop $0
	!endif
!macroend



!macro UpdaterFileDownload OUTPUT_VALUE REMOTE_URL LOCAL_FILE DISPLAY_MESSAGE ALLOW_CANCEL SHOW_BANNER BANNER_TEXT
	;Check to ensure cross zone won't cause Redirection (301) error
	ReadRegDWORD $intWarnOnZoneCrossing HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "WarnonZoneCrossing"
	
	ReadRegDWORD $intSecureProtocols HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "SecureProtocols"
	
	${If} $intWarnOnZoneCrossing != 0
		WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "WarnonZoneCrossing" 0x00000000
	${EndIf}
	
	${If} $intSecureProtocols < 640
		WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "SecureProtocols" 0x00000a80
	${EndIf}
	
	;A bit of a messy hack to ensure inetc functions properly with proxies. TODO - Convert to function
	${If} $strConnectionType == "Direct"
		${If} ${SHOW_BANNER} == true
			${If} ${ALLOW_CANCEL} == true
				inetc::get /NOPROXY /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}"  /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) of %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /NOPROXY /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}" /NOCANCEL /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) of %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${Else}
			${If} ${ALLOW_CANCEL} == true
				inetc::get /NOPROXY /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) of %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /NOPROXY /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /NOCANCEL /TRANSLATE $strTempMessage $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) of %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${EndIf}
	${EndIf}
	${If} $strConnectionType == "Proxy"
		${If} ${SHOW_BANNER} == true
			${If} ${ALLOW_CANCEL} == true
				inetc::get /PROXY $strProxyIP:$strProxyPort /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}" /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /PROXY $strProxyIP:$strProxyPort /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}" /NOCANCEL /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${Else}
			${If} ${ALLOW_CANCEL} == true
				inetc::get /PROXY $strProxyIP:$strProxyPort /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /PROXY $strProxyIP:$strProxyPort /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /NOCANCEL /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${EndIf}
	${EndIf}
	${If} $strConnectionType == "Automatic"
		${If} ${SHOW_BANNER} == true
			${If} ${ALLOW_CANCEL} == true
				inetc::get /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}" /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /BANNER "${BANNER_TEXT}" /CAPTION "${APP_NAME}" /NOCANCEL /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${Else}
			${If} ${ALLOW_CANCEL} == true
				inetc::get /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${Else}
				inetc::get /CONNECTTIMEOUT 30 /USERAGENT "$strUserAgent" /NOCOOKIES /NOCANCEL /TRANSLATE "${DISPLAY_MESSAGE}" $strTransDownloadConnecting $strTransTimeSecond $strTransTimeMinute $strTransTimeHour $strTransTimePlural "%d$strTransTimeKB (%d%%) $strTransTimeOf %d$strTransTimeKB @ %d.%01d$strTransTimeKBs" " (%d %s%s $strTransTimeRemaining)" "${REMOTE_URL}" "${LOCAL_FILE}" /END
			${EndIf}
		${EndIf}	
	${EndIf}
	
	${If} $intWarnOnZoneCrossing != 0
		WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "WarnonZoneCrossing" $intWarnOnZoneCrossing
	${EndIf}
	
	${If} $intSecureProtocols < 640
		WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" "SecureProtocols" $intSecureProtocols
	${EndIf}
	
	Pop `${OUTPUT_VALUE}`
!macroend

!define UpdaterFileDownload '!insertmacro "UpdaterFileDownload"'


Function .onInit
	ReadEnvStr $strFontName "PortableApps.comFontName"
	${If} $strFontName == ""
		StrCpy $strFontName "Tahoma"
	${EndIf}
	ReadEnvStr $intFontSize "PortableApps.comFontSize"
	${If} $intFontSize == ""
		StrCpy $intFontSize 8
	${EndIf}
	CreateFont $fntPlatform $strFontName $intFontSize
	CreateFont $fntPlatformBold $strFontName $intFontSize 700
	
	IntOp $0 $intFontSize + 3
	CreateFont $fntPlatformFinish $strFontName $0
	IntOp $0 $intFontSize + 4
	CreateFont $fntPlatformTitle $strFontName $0 700
	

	;Get Windows version
	${If} ${IsWin2000}
		StrCpy $strWindowsVersion "2000"
		StrCpy $strWindowsVersionSimple "04"
		StrCpy $strWindowsEra "Vintage"
	${EndIf}
	${If} ${IsWinXP}
		StrCpy $strWindowsVersion "XP"
		StrCpy $strWindowsVersionSimple "05"
		StrCpy $strWindowsEra "Vintage"
	${EndIf}
	${If} ${IsWinVista}
		StrCpy $strWindowsVersion "Vista"
		StrCpy $strWindowsVersionSimple "06"
		StrCpy $strWindowsEra "Vintage"
	${EndIf}
	${If} ${IsWin7}
		StrCpy $strWindowsVersion "7"
		StrCpy $strWindowsVersionSimple "07"
		StrCpy $strWindowsEra "Legacy"
	${EndIf}
	${If} ${IsWin8}
		StrCpy $strWindowsVersion "8"
		StrCpy $strWindowsVersionSimple "08"
		StrCpy $strWindowsEra "Legacy"
	${EndIf}
	${If} ${IsWin8.1}
		StrCpy $strWindowsVersion "8.1"
		StrCpy $strWindowsVersionSimple "09"
		StrCpy $strWindowsEra "Legacy"
	${EndIf}
	${If} ${IsWin10}
		StrCpy $strWindowsEra "Modern"
		ReadRegStr $1 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuild"
		${If} $1 < 20000
			StrCpy $strWindowsVersion "10"
			StrCpy $strWindowsVersionSimple "10"
		${Else}
			StrCpy $strWindowsVersion "11"
			StrCpy $strWindowsVersionSimple "11"
		${EndIf}
	${EndIf}
	${If} $strWindowsVersionSimple == ""
		;Fallback for ReactOS
		ReadRegStr $1 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuildNumber"
		${If} $1 > 20000
			StrCpy $strWindowsVersion "11"
			StrCpy $strWindowsVersionSimple "11"
			StrCpy $strWindowsEra "Modern"
		${ElseIf} $1 > 10000
			StrCpy $strWindowsVersion "10"
			StrCpy $strWindowsVersionSimple "10"
			StrCpy $strWindowsEra "Modern"
		${ElseIf} $1 > 9599
			StrCpy $strWindowsVersion "8.1"
			StrCpy $strWindowsVersionSimple "09"
			StrCpy $strWindowsEra "Legacy"
		${ElseIf} $1 > 9199
			StrCpy $strWindowsVersion "8.0"
			StrCpy $strWindowsVersionSimple "08"
			StrCpy $strWindowsEra "Legacy"
		${ElseIf} $1 > 7599
			StrCpy $strWindowsVersion "7"
			StrCpy $strWindowsVersionSimple "07"
			StrCpy $strWindowsEra "Legacy"
		${ElseIf} $1 > 5999
			StrCpy $strWindowsVersion "Vista"
			StrCpy $strWindowsVersionSimple "06"
			StrCpy $strWindowsEra "Vintage"
		${ElseIf} $1 > 2599
			StrCpy $strWindowsVersion "XP"
			StrCpy $strWindowsVersionSimple "05"
			StrCpy $strWindowsEra "Vintage"
		${ElseIf} $1 > 2194
			StrCpy $strWindowsVersion "2000"
			StrCpy $strWindowsVersionSimple "04"
			StrCpy $strWindowsEra "Vintage"
		${EndIf}
	${EndIf}
		
	System::Call kernel32::GetCurrentProcess()i.s
	System::Call kernel32::IsWow64Process(is,*i.r0)
	${If} $0 == 0
		StrCpy $strBitDepth "32"
	${Else}
		StrCpy $strBitDepth "64"
	${EndIf}
	
	StrCpy $bolTLSUpdate == false

	${If} ${AtLeastWin7}
		StrCpy $strHTTPProtocol "https"
	${Else}
		StrCpy $strHTTPProtocol "http"
	${EndIf}
	${If} ${IsWinVista}
		;Check for Vista TLS Update
		ReadEnvStr $0 "WINDIR"
		${If} ${FileExists} `$0\system32\crypt32.dll`
			MoreInfo::GetProductVersion `$0\system32\crypt32.dll`
			Pop $1
			${VersionCompare} $1 "6.0.6002.18953" $R0
			${If} $R0 == 1
				StrCpy $bolTLSUpdate true
			${EndIf}
		${EndIf}
	${EndIf}
	${If} ${IsWinXP}
		;Check for XP TLS Update
		ReadEnvStr $0 "WINDIR"
		${If} ${FileExists} `$0\system32\secur32.dll`
			MoreInfo::GetProductVersion `$0\system32\secur32.dll`
			Pop $1
			${VersionCompare} $1 "5.1.2600.5834" $R0
			${If} $R0 == 1
				StrCpy $bolTLSUpdate true
			${EndIf}
		${EndIf}
	${EndIf}

	;Set Useragent
	StrCpy $strUserAgent "Wget/1.21.4"

	;Temporary quick and dirty check of Windows DPI level
	ReadRegDWORD $intDPI HKCU "Control Panel\Desktop\WindowMetrics\" "AppliedDPI"
	ClearErrors
	${Select} $intDPI
		${Case} 96 ;100%
			StrCpy $intDPIMultiply 1
			StrCpy $intDPIDivide 1
		${Case} 120 ;125%
			StrCpy $intDPIMultiply 118
			StrCpy $intDPIDivide 100
		${Case} 144 ;150%
			StrCpy $intDPIMultiply 3
			StrCpy $intDPIDivide 2
		${Case} 168 ;175%
			StrCpy $intDPIMultiply 168
			StrCpy $intDPIDivide 100
		${Case} 192 ;200%
			StrCpy $intDPIMultiply 2
			StrCpy $intDPIDivide 1
		${Case} 216 ;225%
			StrCpy $intDPIMultiply 220
			StrCpy $intDPIDivide 100
		${Case} 240 ;250%
			StrCpy $intDPIMultiply 25
			StrCpy $intDPIDivide 10
		${Case} 288 ;300%
			StrCpy $intDPIMultiply 3
			StrCpy $intDPIDivide 1
		${CaseElse} ;100%
			StrCpy $intDPI 96
			StrCpy $intDPIMultiply 1
			StrCpy $intDPIDivide 1
	${EndSelect}

	InitPluginsDir
	StrCpy $strRealCaption "PortableApps.com Platform"
	StrCpy $strBrandingTextCustom "PortableApps.com®"
	
	;Get command line options and set the appropriate mode
	${GetOptions} "$CMDLINE" "/ORDER=" $R0	
	${If} $R0 == ""
		StrCpy $strOrder "category"
	${Else}
		StrCpy $strOrder $R0
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/CONNECTION=" $strConnectionType
	${GetOptions} "$CMDLINE" "/PROXYIP=" $strProxyIP
	${GetOptions} "$CMDLINE" "/PROXYPORT=" $strProxyPort

	${GetOptions} "$CMDLINE" "/KEYBOARDFRIENDLY=" $R0	
	${If} $R0 == "true"
		StrCpy $bolKeyboardFriendly "true"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/HIDEPORTABLE=" $R0	
	${If} $R0 == "true"
		StrCpy $bolHidePortableInAppNames "true"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/STARTUP=" $R0	
	${If} $R0 == "true"
		StrCpy $bolPlatformStartupMode "true"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/STARTUPSHOWERRORS=" $R0	
	${If} $R0 == "true"
		StrCpy $bolShowErrorsInStartupMode "true"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/SHOWINSTALLEDAPPS=" $R0	
	${If} $R0 == "true"
		StrCpy $bolShowInstalledApps "true"
	${EndIf}

	${GetOptions} "$CMDLINE" "/BETA=" $R0	
	${If} $R0 == "true"
		StrCpy $bolBetaPlatformReleases "true"
		StrCpy $strBetaPlatformReleasesSuffix "BetaChannel"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/ADVANCED=" $R0	
	${If} $R0 == "true"
		StrCpy $bolShowAdvanced "true"
	${Else}
		StrCpy $bolShowAdvanced "false"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/SHOWFREEWARE=" $strShowFreewareApps	
	
	${GetOptions} "$CMDLINE" "/HIDE64BIT=" $R0	
	${If} $R0 == "true"
		StrCpy $bolHide64BitApps "true"
	${Else}
		StrCpy $bolHide64BitApps "false"
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/INSTALL32BITDUALMODE=" $R0	
	${If} $R0 == ""
		StrCpy $strInstall32BitInDualMode "always"
	${Else}
		StrCpy $strInstall32BitInDualMode $R0
	${EndIf}
	
	${GetOptions} "$CMDLINE" "/MODE=" $R0	
	${If} $R0 == "ADD"
		StrCpy $bolUpdateMode false
		StrCpy $strRealCaption "Portable App Directory"
	${ElseIf} $R0 == "ADDALL"
		StrCpy $bolUpdateMode false
		StrCpy $bolAddAll "true"
		StrCpy $strRealCaption "Portable App Directory"
	${ElseIf} $R0 == "UPDATE"
		StrCpy $bolUpdateMode true
		StrCpy $strRealCaption "PortableApps.com Updater"
	${ElseIf} $R0 == "INSTALL"
		StrCpy $bolUpdateMode true
		StrCpy $strRealCaption "Portable App Directory"
	${Else}
		MessageBox MB_OK|MB_ICONEXCLAMATION `The PortableApps.com Updater must be run from the PortableApps.com Platform. It will not function properly when run directly.`
		Abort
	${EndIf}
	
	;Prepare the data directory
	CreateDirectory "$EXEDIR\Data"
	Delete ${UPDATE_FILE_INI}
	
	;Get the platform language and pass through proper platform variables
	ReadEnvStr $intLocaleID "PortableApps.comLocaleID_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLocaleID", "$intLocaleID").r0'
	ReadEnvStr $strLanguageName "PortableApps.comLocaleWinName_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLocaleWinName", "$strLanguageName").r0'
	ReadEnvStr $0 "PortableApps.comLocaleCode2_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLocaleCode2", "$0").r0'
	ReadEnvStr $0 "PortableApps.comLocaleCode3_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLocaleCode3", "$0").r0'
	ReadEnvStr $0 "PortableApps.comLanguageCode_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLanguageCode", "$0").r0'
	ReadEnvStr $0 "PortableApps.comLocaleglibc_INTERNAL"
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PortableApps.comLocaleglibc", "$0").r0'
	
	
	${If} $intLocaleID = ""
		;If not set, use English
		StrCpy $intLocaleID 1033
		StrCpy $strLanguageName "ENGLISH"
	${Else}
		;Strip LANG_ from the beginning of the string
		StrCpy $strLanguageName $strLanguageName "" 5
	${EndIf}
	StrCpy $strLanguageNameFile $strLanguageName
	${If} $strLanguageNameFile == "PORTUGUESEBR"
		StrCpy $strLanguageNameFile "PORTUGUESEBRAZILIAN"
	${ElseIf} $strLanguageNameFile == "SIMPCHINESE"
		StrCpy $strLanguageNameFile "CHINESESIMPLIFIED"
	${ElseIf} $strLanguageNameFile == "TRADCHINESE"
		StrCpy $strLanguageNameFile "CHINESETRADITIONAL"		
	${EndIf}
	
	${If} $strLanguageName == "PORTUGUESEBR"
		StrCpy $strLanguageNameFallback "PORTUGUESE"
	${ElseIf} $strLanguageName == "PORTUGUESE"
		StrCpy $strLanguageNameFallback "PORTUGUESEBR"
	${ElseIf} $strLanguageName == "SPANISHINTERNATIONAL"
		StrCpy $strLanguageNameFallback "SPANISH"		
	${ElseIf} $strLanguageName == "SPANISH"
		StrCpy $strLanguageNameFallback "SPANISHINTERNATIONAL"		
	${Else}
		StrCpy $strLanguageNameFallback "NONE"
	${EndIf}
	StrCpy $LANGUAGE $intLocaleID
	StrCpy $strLocaleFile "$EXEDIR\App\Locale\$strLanguageNameFile.locale"
	StrCpy $strSettingsFile "$EXEDIR\Data\PortableAppsMenu.ini"
	
	;Load the language strings
	
	
	${ReadINIStrWithDefault} $strLocaleDirection $strLocaleFile "PortableApps.comLocaleDetails" "Direction" "LTR"
	${ReadINIStrWithDefault} $strTransCategoryAccessibility $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_ACCESSIBILITY" "Accessibility"
	${ReadINIStrWithDefault} $strTransCategoryDevelopment $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_DEVELOPMENT" "Development"
	${ReadINIStrWithDefault} $strTransCategoryEducation $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_EDUCATION" "Education"
	${ReadINIStrWithDefault} $strTransCategoryGames $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_Games" "Games"
	${ReadINIStrWithDefault} $strTransCategoryGraphicsPictures $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_GRAPHICS_AND_PICTURES" "Graphics and Pictures"
	${ReadINIStrWithDefault} $strTransCategoryInternet $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_INTERNET" "Internet"
	${ReadINIStrWithDefault} $strTransCategoryMusicVideo $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_MUSIC_AND_VIDEO" "Music and Video"
	${ReadINIStrWithDefault} $strTransCategoryOffice $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_OFFICE" "Office"
	${ReadINIStrWithDefault} $strTransCategorySecurity $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_SECURITY" "Security"
	${ReadINIStrWithDefault} $strTransCategoryUtilities $strLocaleFile "FORM_MAIN" "APP_MENU_CATEGORY_UTILITIES" "Utilities"
	${WordReplace} $strTransCategoryAccessibility "&" "" "+" $strTransCategoryAccessibility
	${WordReplace} $strTransCategoryDevelopment "&" "" "+" $strTransCategoryDevelopment
	${WordReplace} $strTransCategoryEducation "&" "" "+" $strTransCategoryEducation
	${WordReplace} $strTransCategoryGames "&" "" "+" $strTransCategoryGames
	${WordReplace} $strTransCategoryGraphicsPictures "&" "" "+" $strTransCategoryGraphicsPictures
	${WordReplace} $strTransCategoryInternet "&" "" "+" $strTransCategoryInternet
	${WordReplace} $strTransCategoryMusicVideo "&" "" "+" $strTransCategoryMusicVideo
	${WordReplace} $strTransCategoryOffice "&" "" "+" $strTransCategoryOffice
	${WordReplace} $strTransCategorySecurity "&" "" "+" $strTransCategorySecurity
	${WordReplace} $strTransCategoryUtilities "&" "" "+" $strTransCategoryUtilities
	
	${ReadINIStrWithDefault} $strTransColumnMB $strLocaleFile "UPDATER" "COLUMN_ABBREVIATION_MEGABYTE" "MB"
	${ReadINIStrWithDefault} $strTransColumnApp $strLocaleFile "UPDATER" "COLUMN_APP" "Portable App"
	;Add non-breaking space to avoid file corruption with some locales
	StrCpy $strTransColumnApp "$strTransColumnApp${NON-BREAKING_SPACE}"
	
	${ReadINIStrWithDefault} $strTransColumnDownloadSize $strLocaleFile "UPDATER" "COLUMN_DOWNLOAD_SIZE" "Download"
	${ReadINIStrWithDefault} $strTransColumnInstallSize $strLocaleFile "UPDATER" "COLUMN_INSTALL_SIZE" "Install"
	${ReadINIStrWithDefault} $strTransColumnDescription $strLocaleFile "UPDATER" "COLUMN_DESCRIPTION" "Description"
	${ReadINIStrWithDefault} $strTransColumnAppType $strLocaleFile "UPDATER" "COLUMN_APP_TYPE" "App Type"
	${ReadINIStrWithDefault} $strTransColumnCategory $strLocaleFile "UPDATER" "COLUMN_CATEGORY" "Category"
	${ReadINIStrWithDefault} $strTransColumnSubCategory $strLocaleFile "UPDATER" "COLUMN_SUBCATEGORY" "Sub-Category"	
	${ReadINIStrWithDefault} $strTransColumnReleasedOn $strLocaleFile "UPDATER" "COLUMN_RELEASE_DATE" "Released"	
	${ReadINIStrWithDefault} $strTransColumnUpdatedOn $strLocaleFile "UPDATER" "COLUMN_UPDATED_DATE" "Updated"	
	
	${ReadINIStrWithDefault} $strTransDownloadConnecting $strLocaleFile "UPDATER" "DOWNLOADCONNECTING" "Connecting..."	
	${ReadINIStrWithDefault} $strTransDownloadingXofY $strLocaleFile "UPDATER" "DOWNLOADING_X_OF_Y" "Downloading %CURRENTAPP% of %APPSTOPROCESS%: %CURRENTAPPNAME%..."
	${ReadINIStrWithDefault} $strTransDownloadingXofYVerifying $strLocaleFile "UPDATER" "DOWNLOADING_X_OF_Y_VERIFYING" $strTransDownloadingXofY
	
	${ReadINIStrWithDefault} $strTransTimeSecond $strLocaleFile "UPDATER" "DOWNLOADSECOND" "second"	
	${ReadINIStrWithDefault} $strTransTimeMinute $strLocaleFile "UPDATER" "DOWNLOADMINUTE" "minute"	
	${ReadINIStrWithDefault} $strTransTimeHour $strLocaleFile "UPDATER" "DOWNLOADHOUR" "hour"
	${ReadINIStrWithDefault} $strTransTimePlural $strLocaleFile "UPDATER" "DOWNLOADPLURAL" "s"
	${ReadINIStrWithDefault} $strTransTimeRemaining $strLocaleFile "UPDATER" "DOWNLOADREMAINING" "remaining"
	${ReadINIStrWithDefault} $strTransTimeKB $strLocaleFile "UPDATER" "DOWNLOADKB" "kB"
	${ReadINIStrWithDefault} $strTransTimeKBs $strLocaleFile "UPDATER" "DOWNLOADKBS" "kB/s"
	${ReadINIStrWithDefault} $strTransTimeOf $strLocaleFile "UPDATER" "DOWNLOADOF" "/"

	${ReadINIStrWithDefault} $strTransDownloadError $strLocaleFile "UPDATER" "DOWNLOADERROR" "Download Error: %ERROR% on file %FILE%"
	${ReadINIStrWithDefault} $strTransDownloadErrorSendRequest $strLocaleFile "UPDATER" "DOWNLOADERRORSENDREQUEST" "Unable to download the file. This could be due to a proxy or network issue or the hosting server not permitting downloads from your location. File: %FILE%"
	${ReadINIStrWithDefault} $strTransDownloadErrorSiteMaintenance $strLocaleFile "UPDATER" "DOWNLOADERRORSITEMAINTENANCE" "The PortableApps.com website is temporarily inaccessible due to maintenance and the app can not be downloaded.  Please try again later. (File: %FILE%)"
	${ReadINIStrWithDefault} $strTransDownloadInvalid $strLocaleFile "UPDATER" "DOWNLOADINVALID" "The downloaded copy of %CURRENTAPPNAME% is not valid and can not be installed. This could be due to an incomplete download or other network issue. Please try running the updater again when complete."	
	${ReadINIStrWithDefault} $strTransInstallingXofY $strLocaleFile "UPDATER" "INSTALLING_X_OF_Y" "Installing %CURRENTAPP% of %APPSTOPROCESS%: %CURRENTAPPNAME%..."	
	${ReadINIStrWithDefault} $strTransIntroWait $strLocaleFile "UPDATER" "INTRO_WAIT" "Checking PortableApps.com for apps..."
	${ReadINIStrWithDefault} $strTransIntroUpToDate $strLocaleFile "UPDATER" "INTRO_UPTODATE" "All portable apps are up to date."
	${ReadINIStrWithDefault} $strTransIntroNoOtherApps $strLocaleFile "UPDATER" "INTRO_NOOTHERAPPS" "All available portable apps are already installed. You rock!"
	${ReadINIStrWithDefault} $strTransSectionHeadingNew $strLocaleFile "UPDATER" "SELECTION_HEADING_NEW" "Download New Portable Apps"
	${ReadINIStrWithDefault} $strTransSectionSubHeadingNew $strLocaleFile "UPDATER" "SELECTION_SUBHEADING_NEW" "Select the portable apps you would like to install."
	${WordReplace} $strTransSectionSubHeadingNew "%NEXT%" ">" "+" $strTransSectionSubHeadingNew
	${ReadINIStrWithDefault} $strTransSectionHeadingUpdate $strLocaleFile "UPDATER" "SELECTION_HEADING_UPDATE" "Update Portable Apps"
	${ReadINIStrWithDefault} $strTransSectionSubHeadingUpdate $strLocaleFile "UPDATER" "SELECTION_SUBHEADING_UPDATE" "Updates are available for the following portable apps"
	${ReadINIStrWithDefault} $strTransDownloadHeading $strLocaleFile "UPDATER" "DOWNLOAD_HEADING" "Downloading and Installing"
	${ReadINIStrWithDefault} $strTransDownloadSubHeading $strLocaleFile "UPDATER" "DOWNLOAD_SUBHEADING" "Please wait while the portable apps are downloaded and installed"
	${ReadINIStrWithDefault} $strTransFinishHeadingNew $strLocaleFile "UPDATER" "FINISH_HEADING_NEW" "Portable Apps Added"
	${ReadINIStrWithDefault} $strTransFinishTextNew $strLocaleFile "UPDATER" "FINISH_TEXT_NEW" "Your new portable apps have been installed and are now available in the PortableApps.com Menu."
	${ReadINIStrWithDefault} $strTransFinishHeadingUpdate $strLocaleFile "UPDATER" "FINISH_HEADING_UPDATE" "Update Complete"
	${ReadINIStrWithDefault} $strTransFinishTextUpdate $strLocaleFile "UPDATER" "FINISH_TEXT_UPDATE" "Your portable apps have been updated and are available in the PortableApps.com Menu."
	${ReadINIStrWithDefault} $strTransFinishHeadingFail $strLocaleFile "UPDATER" "FINISH_HEADING_FAIL" "Error"
	${ReadINIStrWithDefault} $strTransFinishTextFail $strLocaleFile "UPDATER" "FINISH_TEXT_FAIL" "The PortableApps.com Updater did not complete successfully.  Please try again later."
	${ReadINIStrWithDefault} $strTransFinishHeadingNoSelection $strLocaleFile "UPDATER" "FINISH_HEADING_NOSELECTION" "No Apps Selected"
	${ReadINIStrWithDefault} $strTransFinishTextNoSelectionStore $strLocaleFile "UPDATER" "FINISH_TEXT_NOSELECTIONSTORE" "No apps were selected to install. If you wish to install new apps, please open the %APPSTORE% again and select some."
	${WordReplace} $strTransFinishTextNoSelectionStore "%APPSTORE%" "Portable App Directory" "+" $strTransFinishTextNoSelectionStore
	${ReadINIStrWithDefault} $strTransFinishTextNoSelectionUpdater $strLocaleFile "UPDATER" "FINISH_TEXT_NOSELECTIONUPDATER" "No apps were selected to update. If you wish to update your apps, please open the %UPDATER% again and select some."
	${WordReplace} $strTransFinishTextNoSelectionUpdater "%UPDATER%" "PortableApps.com Updater" "+" $strTransFinishTextNoSelectionUpdater
	${ReadINIStrWithDefault} $strTransErrorNoConnection $strLocaleFile "UPDATER" "ERROR_NOCONNECTION" "Unable to connect to PortableApps.com to retrieve portable apps.  Please try again later."
	${ReadINIStrWithDefault} $strTransUpToDate $strLocaleFile "UPDATER" "INTRO_UPTODATE" "All portable apps are up to date"
	${ReadINIStrWithDefault} $strTransLargeDriveWorkaround $strLocaleFile "UPDATER" "LARGE_DRIVE_WORKAROUND" "Some of the portable apps will show an error that there is not enough space on your device during installation.  This is due to a slight incompatibility with drives over 2TB and the older installer they are packaged with. Just click OK to the error and then click Next on the directory selection screen to continue installing them when they pop up. This issue will be fully resolved shortly."
	${ReadINIStrWithDefault} $strTransAlreadyRunning $strLocaleFile "UPDATER" "ALREADY_RUNNING" "The PortableApps.com Updater or App Directory is already running.  This could be the PortableApps.com Platform automatically checking for updates on startup. Please wait for other instances to finish before starting another."
	${ReadINIStrWithDefault} $strTransRequiredPlatformUpdate $strLocaleFile "UPDATER" "REQUIRED_PLATFORM_UPDATE" "Required Platform Update"
	
	${ReadINIStrWithDefault} $strTransProcessRunningBug $strLocaleFile "UPDATER" "PROCESS_RUNNING_BUG" "Some of the portable apps you are installing will be unable to detect the PortableApps.com Platform due to a bug in older versions of the installer when too many processes are running for it to sort through. These installers not run in silent mode and will require clicking next multiple times as these older apps install."
	
	${ReadINIStrWithDefault} $strTransPlatformNotRunning $strLocaleFile "UPDATER" "PLATFORM_NOT_RUNNING" "The PortableApps.com Platform must remain running while the Updater is in use. Without the platform running, unexpected results may occur."
	
	${ReadINIStrWithDefault} $strTransOldWindowsBugs $strLocaleFile "UPDATER" "OLD_WINDOWS_BUGS" "Some features of the PortableApps.com Platform will not function correctly on this older version of Windows."
	
	;Ensure not already running
	${WordReplace} "${APP_NAME}-$EXEDIR" "\" "-" "+" $strMutex

	System::Call 'kernel32::CreateMutexW(i 0, i 0, t "$strMutex") i .r1 ?e'
	Pop $0
	${If} $0 != 0
		MessageBox MB_OK|MB_ICONINFORMATION $strTransAlreadyRunning
		Abort
	${EndIf}
	
	;Determine whether to use https
	StrCpy $strRemoteUpdateURL "$strHTTPProtocol://${UPDATER_DATABASE_URL}"
	

	;Get the application list (silently if in Startup mode)
	${WordReplace} "$strTransIntroWait" "PortableApps.com " "" "+" $strTransIntroWait
	Delete ${UPDATE_FILE_7Z}

	${If} $bolPlatformStartupMode != "true"
		Banner::show /set 76 "$strRealCaption" "$strTransIntroWait"
		StrCpy $bolBannerIsUp true
	${EndIf}

	${UpdaterFileDownload} $R0 "$strRemoteUpdateURL" "${UPDATE_FILE_7Z}" "" false false ""
	
	;Check for proxy authentication
	${If} $R0 == "Proxy Error (407)"
		Delete ${UPDATE_FILE_7Z}
		${If} $bolBannerIsUp == true
			Banner::destroy
			StrCpy $bolBannerIsUp false
		${EndIf}
		;Take two
		${UpdaterFileDownload} $R0 "$strRemoteUpdateURL" "${UPDATE_FILE_7Z}" "" false true "$strTransIntroWait"
		
	${EndIf}
	
	;Check for File Write Error (workaround for Microsoft Security Essentials)
	${If} $R0 == "File Write Error"
		Delete ${UPDATE_FILE_7Z}
		
		;Take two
		${UpdaterFileDownload} $R0 "$strRemoteUpdateURL" "${UPDATE_FILE_7Z}" "" false false ""
		
		;Check for proxy authentication
		${If} $R0 == "Proxy Error (407)"
			Delete ${UPDATE_FILE_7Z}
			${If} $bolBannerIsUp == true
				Banner::destroy
				StrCpy $bolBannerIsUp false
			${EndIf}
			
			;Take two
			${UpdaterFileDownload} $R0 "$strRemoteUpdateURL" "${UPDATE_FILE_7Z}" "" false true "$strTransIntroWait"
		${EndIf}
	${EndIf}
	
	;Fallback attempt with http
	${If} $R0 != "OK"
	${AndIf} $strHTTPProtocol == "https"
		StrCpy $strRemoteUpdateURL "http://${UPDATER_DATABASE_URL}"
		${UpdaterFileDownload} $R0 "$strRemoteUpdateURL" "${UPDATE_FILE_7Z}" "" false false ""
		
		${If} $R0 == "OK"
			StrCpy $strHTTPProtocol "http"
		${EndIf}
	${EndIf}
	
	;Check if the list was downloaded
	${If} $R0 != "OK"
		StrCpy $bolDownloadFailed "true"
		${If} $bolPlatformStartupMode != "true"
		${OrIf} $bolShowErrorsInStartupMode == true
			${If} $bolBannerIsUp == true
				Banner::destroy
				StrCpy $bolBannerIsUp false
			${EndIf}
			;Show an error if not downloaded and user selected to update
			MessageBox MB_OK|MB_ICONEXCLAMATION `$strTransErrorNoConnection  [ $R0 ]`
		${EndIf}
		Abort ;We'll just exit here for now
	${Else} ;Download was ok, check the file
		${IfNot} ${FileExists} ${UPDATE_FILE_7Z}
			StrCpy $bolDownloadFailed "true"
			${If} $bolPlatformStartupMode != "true"
				${If} $bolBannerIsUp == true
					Banner::destroy
					StrCpy $bolBannerIsUp false
				${EndIf}
				;Show an error if not downloaded and user selected to update
				MessageBox MB_OK|MB_ICONEXCLAMATION `$strTransErrorNoConnection  [ NotDownloadedPossibleNoConnection ]`
				Abort
			${EndIf}
		${Else}
			Delete ${UPDATE_FILE_INI}
			nsExec::Exec `"$EXEDIR\App\7-Zip\7za.exe" x "${UPDATE_FILE_7Z}" -o"$PLUGINSDIR" -aoa`
			${IfNot} ${FileExists} ${UPDATE_FILE_INI}
				StrCpy $bolDownloadFailed "true"
				${If} $bolPlatformStartupMode != "true"
					${If} $bolBannerIsUp == true
						Banner::destroy
						StrCpy $bolBannerIsUp false
					${EndIf}
					;Show an error if not downloaded and user selected to update
					MessageBox MB_OK|MB_ICONEXCLAMATION `$strTransErrorNoConnection  [ InvalidZipFilePossibleNoConnectionOrFirewall ]`
					Abort
				${EndIf}
				Abort
			${EndIf}

			${ReadINIStrWithDefault} $strCurrentAppPackageVersion ${UPDATE_FILE_INI} "PortableApps.com" "PackageVersion" "MISSING"
			${If} $strCurrentAppPackageVersion == "MISSING"
				StrCpy $bolDownloadFailed "true"
				${If} $bolPlatformStartupMode != "true"
					${If} $bolBannerIsUp == true
						Banner::destroy
						StrCpy $bolBannerIsUp false
					${EndIf}
					;Show an error if not downloaded and user selected to update
					MessageBox MB_OK|MB_ICONEXCLAMATION `$strTransErrorNoConnection  [ InvalidFilePossibleNoConnectionOrFirewall ]`
					Abort
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}
	
	;Get the PortableApps directory
	${GetParent} $EXEDIR $strPortableAppsPath
	
	;Prepare the app list, if needed
	${If} $bolDownloadFailed != "true"
		;Reset banner if we removed it due to proxy authentication
		${If} $bolPlatformStartupMode != "true"
		${AndIf} $bolBannerIsUp != true
			Banner::show /set 76 "$strRealCaption" "$strTransIntroWait"
			StrCpy $bolBannerIsUp true
		${EndIf}
	
		Delete ${APP_LIST_FILE_INI}
		Delete "$PLUGINSDIR\blankutf16lefile.txt"
		
		;Initialize File As blank UTF16LE
		CopyFiles /SILENT "$EXEDIR\App\bin\blankutf16lefile.txt" "$PLUGINSDIR"
		Rename "$PLUGINSDIR\blankutf16lefile.txt" ${APP_LIST_FILE_INI}
		
		ClearErrors
		Delete "${APP_LIST_FILE_INI}.Apps.ini"
		Delete "${APP_LIST_FILE_INI}.Icons.ini"
		CopyFiles /SILENT "$EXEDIR\App\Bin\blankutf16lefile.txt" $PLUGINSDIR
		Rename "$PLUGINSDIR\blankutf16lefile.txt" "${APP_LIST_FILE_INI}.Apps.ini"
		CopyFiles /SILENT "$EXEDIR\App\Bin\blankutf16lefile.txt" $PLUGINSDIR
		Rename "$PLUGINSDIR\blankutf16lefile.txt" "${APP_LIST_FILE_INI}.Icons.ini"
		FileOpen $fileAppList "${APP_LIST_FILE_INI}.Apps.ini" a
		FileSeek $fileAppList 0 END
		FileOpen $fileIconList "${APP_LIST_FILE_INI}.Icons.ini" a
		FileSeek $fileIconList 0 END
		
		FileWriteUTF16LE $fileAppList "[Settings]$\r$\n"
		FileWriteUTF16LE $fileAppList "Type=ListView$\r$\n"
		;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "Type" "ListView"

		${If} $bolKeyboardFriendly == true
			FileWriteUTF16LE $fileAppList "CheckBoxes=0$\r$\n"
			FileWriteUTF16LE $fileAppList "NoItemSelection=0$\r$\n"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "CheckBoxes" "0"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "NoItemSelection" "0"
		${Else}
			FileWriteUTF16LE $fileAppList "CheckBoxes=1$\r$\n"
			FileWriteUTF16LE $fileAppList "NoItemSelection=1$\r$\n"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "CheckBoxes" "1"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "NoItemSelection" "1"
		${EndIf}

		FileWriteUTF16LE $fileAppList "ColumnHeader=1$\r$\n"
		${If} $bolKeyboardFriendly == true
		${AndIf} $bolUpdateMode == true
			FileWriteUTF16LE $fileAppList "ToggleNextButton=0$\r$\n"
		${Else}
			FileWriteUTF16LE $fileAppList "ToggleNextButton=1$\r$\n"
		${EndIf}
		FileWriteUTF16LE $fileAppList "ViewListOnly=1$\r$\n"

		;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "ColumnHeader" "1"
		;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "ToggleNextButton" "1"
		;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "ViewListOnly" "1"
		${If} ${AtLeastWin8}
			${If} $strWindowsVersion == "11"
				FileWriteUTF16LE $fileAppList "UseCheckBitmap=$EXEDIR\App\Graphics\updatericons\modernmodded-win11.bmp$\r$\n"
			${Else}
				FileWriteUTF16LE $fileAppList "UseCheckBitmap=$EXEDIR\App\Graphics\updatericons\modernmodded-win8.bmp$\r$\n"
			${EndIf}
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "UseCheckBitmap" "$EXEDIR\App\Graphics\updatericons\modernmodded-win8.bmp"
		${Else}
			FileWriteUTF16LE $fileAppList "UseCheckBitmap=$EXEDIR\App\Graphics\updatericons\modernmodded.bmp$\r$\n"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "UseCheckBitmap" "$EXEDIR\App\Graphics\updatericons\modernmodded.bmp"
		${EndIf}
		FileWriteUTF16LE $fileAppList "SortByColumnClick=0$\r$\n"
		;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumnClick" "0"
	
		${If} $bolUpdateMode == true
			FileWriteUTF16LE $fileAppList "Sort=ascending$\r$\n"
			FileWriteUTF16LE $fileAppList "SortByColumn=1$\r$\n"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "Sort" "ascending"
			;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumn" "1"
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1" $strTransColumnApp
			${AdjustWidthForDPI} $0 230
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1Width" $0
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnDownloadSize
			${AdjustWidthForDPI} $0 70
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2Width" $0
			${If} $LANGUAGE == 1033
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnDescription
			${Else}
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnSubCategory
			${EndIf}
			${AdjustWidthForDPI} $0 200
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3Width" $0
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4" $strTransColumnUpdatedOn
			${AdjustWidthForDPI} $0 74
			WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4Width" $0
		${Else}
			${If} $strOrder == "category"
			${OrIf} $strOrder == "title"
				FileWriteUTF16LE $fileAppList "Sort=ascending$\r$\n"
				;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "Sort" "ascending"
				${If} $strOrder == "category"
					FileWriteUTF16LE $fileAppList "SortByColumn=4$\r$\n"
					;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumn" "4"
				${Else}
					FileWriteUTF16LE $fileAppList "SortByColumn=1$\r$\n"
					;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumn" "1"
				${EndIf}
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1" $strTransColumnApp
				${AdjustWidthForDPI} $0 230
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1Width" $0
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4" "-" ;Sort column
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4Width" "0"
				${If} $LANGUAGE == 1033
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnDescription
				${Else}
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnSubCategory
				${EndIf}
				${AdjustWidthForDPI} $0 200
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2Width" $0
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnDownloadSize
				${AdjustWidthForDPI} $0 70
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3Width" $0
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5" $strTransColumnInstallSize
				${AdjustWidthForDPI} $0 70
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5Width" $0
			${Else} ;release date or updated date
				FileWriteUTF16LE $fileAppList "Sort=descending$\r$\n"
				FileWriteUTF16LE $fileAppList "SortByColumn=6$\r$\n"
				;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "Sort" "descending"
				;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumn" "6"
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1" $strTransColumnApp
				${If} $strOrder == "updated"
				${OrIf} $strOrder == "new"
					${AdjustWidthForDPI} $0 194
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1Width" $0
				${Else}
					${AdjustWidthForDPI} $0 229
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1Width" $0
				${EndIf}
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4" "-" ;Sort column
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4Width" "0"
				${If} $LANGUAGE == 1033
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnDescription
				${Else}
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnSubCategory
				${EndIf}
				${If} $strOrder == "updated"
				${OrIf} $strOrder == "new"
					${AdjustWidthForDPI} $0 174
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2Width" $0
				${Else}
					${AdjustWidthForDPI} $0 220
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2Width" $0
				${EndIf}
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnDownloadSize
				${AdjustWidthForDPI} $0 62
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3Width" $0
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5" $strTransColumnInstallSize
				${AdjustWidthForDPI} $0 70
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5Width" $0
				${If} $strOrder == "updated"
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column6" $strTransColumnUpdatedOn
				${Else} ;new
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column6" $strTransColumnReleasedOn
				${EndIf}
				${AdjustWidthForDPI} $0 74
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column6Width" $0
			${EndIf}
		${EndIf}
		
		;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "1"
		;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "Icon1" ""
		
		EnumINI::SectionNames ${UPDATE_FILE_INI}
		
		Pop $intUpdaterApps ;Number of sections found or "error"

		StrCpy $intCurrentAppCounter 1
		${If} $intUpdaterApps != "error"
			;Determine useragent
			
			${ReadINIStrWithDefault} $strUserAgent ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "UserAgent" $strUserAgent
		
			;First check platform updates
			${ReadINIStrWithDefault} $strCurrentAppPackageVersion ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "PackageVersion" "0.0.0.0"
			${ReadINIStrWithDefault} $strCurrentAppPackageVersion ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "UpdateFrom-${PRODUCT_VERSION}-PackageVersion" $strCurrentAppPackageVersion
			${VersionCompare} ${PRODUCT_VERSION} $strCurrentAppPackageVersion $R0
			${If} $R0 == 2
				;Update the platform!
				StrCpy $bolUpdateMode true
				StrCpy $bolPlatformUpdateMode "true"
				StrCpy $strDownloadToLocalPath $TEMP
				
				;Switch to update layout of the list
				;FileWriteUTF16LE $fileAppList "SortByColumn=1$\r$\n"
				;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "SortByColumn" "1"
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1" $strTransColumnApp
				${AdjustWidthForDPI} $0 230
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column1Width" $0
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2" $strTransColumnDownloadSize
				${AdjustWidthForDPI} $0 70
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column2Width" $0
				${If} $LANGUAGE == 1033
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnDescription
				${Else}
					WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3" $strTransColumnSubCategory
				${EndIf}
				${AdjustWidthForDPI} $0 260
				WriteINIStr ${APP_LIST_FILE_INI} "Columns" "Column3Width" $0
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4"
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column4Width"
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5"
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column5Width"
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column6"
				DeleteINIStr ${APP_LIST_FILE_INI} "Columns" "Column6Width"
				
				;Add the platform as an entry
				WriteINIStr ${APP_LIST_FILE_INI} "Icons" "Icon1" "$EXEDIR\App\Graphics\appicons\PortableApps.com.ico"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "IconIndex" "1"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "AppID" "PortableApps.com$strBetaPlatformReleasesSuffix"
				${ReadINIStrWithDefault} $strCurrentAppDisplayVersion ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "DisplayVersion" "0.0.0.0"
				${ReadINIStrWithDefault} $strCurrentAppDownloadSize ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "DownloadSize" "0"
				${ReadINIStrWithDefault} $strCurrentAppDownloadSize ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "UpdateFrom-${PRODUCT_VERSION}-DownloadSize" $strCurrentAppDownloadSize
				${ReadINIStrWithDefault} $strCurrentAppInstallSize ${UPDATE_FILE_INI} "PortableApps.com$strBetaPlatformReleasesSuffix" "InstallSize" "0"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "Text" "PortableApps.com Platform $strCurrentAppDisplayVersion"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "SubItem1" "$strCurrentAppDownloadSize $strTransColumnMB"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "SubItem2" "$strTransRequiredPlatformUpdate"
				WriteINIStr ${APP_LIST_FILE_INI} "Item 1" "Checked" "1"
				
				StrCpy $intSettingsCount 1
				;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "count" "1"
				WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "1"
				StrCpy $intSelectedApps 1
			${Else}
				;Handle the apps
				${If} $bolUpdateMode == true
					${ReadINIStrWithDefault} $strIgnoreAppsDuringUpdate $strSettingsFile "Updater" "IgnoredApps" ""
				${Else}
					StrCpy $strIgnoreAppsDuringUpdate ""
				${EndIf}
				
				StrCpy $strDownloadToLocalPath $PLUGINSDIR
				
				${If} ${FileExists} "$strPortableAppsPath\CommonFiles\*.*"
					StrCpy $bolCommonFilesExists true
				${Else}
					StrCpy $bolCommonFilesExists false
				${EndIf}
		
				FileWriteUTF16LE $fileIconList "[Icons]$\r$\n"
				
				StrCpy $intCounter $intUpdaterApps
				${DoUntil} $intCounter = 0
					Pop $strCurrentAppID
					
					${If} $bolUpdateMode == true
						;Determine if base app path exists to save time
						
						${If} ${FileExists} "$strPortableAppsPath\$strCurrentAppID\*.*"
							${If} $bolPlatformStartupMode == true
							${AndIf} $strIgnoreAppsDuringUpdate != "||"
								${StrLoc} $0 $strIgnoreAppsDuringUpdate "|$strCurrentAppID|" ">"
								${If} $0 > 0
									StrCpy $bolCurrentAppBasePathExists false
								${Else}
									StrCpy $bolCurrentAppBasePathExists true
								${EndIf}
							${Else}
								StrCpy $bolCurrentAppBasePathExists true
							${EndIf}
						${Else}
							;Doesn't exist.  Check if it is a plugin.
							${ReadINIStrWithDefault} $strCurrentAppType ${UPDATE_FILE_INI} $strCurrentAppID "Type" "app"
					
							${If} $strCurrentAppType != "app"
							${AndIf} $bolCommonFilesExists == true
								;It's a plugin, check there
								${If} ${FileExists} "$strPortableAppsPath\CommonFiles\$strCurrentAppID\*.*"
									StrCpy $bolCurrentAppBasePathExists true
								${Else}
									StrCpy $bolCurrentAppBasePathExists false
								${EndIf}
							${Else}
								StrCpy $bolCurrentAppBasePathExists false
							${EndIf}	
						${EndIf}
					${EndIf}
					
					${If} $bolUpdateMode != true
					${OrIf} $bolCurrentAppBasePathExists == true
						;Get our app details
						${ReadINIStrWithDefault} $strCurrentAppName ${UPDATE_FILE_INI} $strCurrentAppID "Name" "(ERROR: $strCurrentAppID\Name)"
						${If} $bolHidePortableInAppNames == "true"
							${WordReplace} $strCurrentAppName ", Portable Edition" "" "+" $strCurrentAppNameShort
							${WordReplace} $strCurrentAppNameShort ", Portable" "" "+" $strCurrentAppNameShort
							${WordReplace} $strCurrentAppNameShort " PortableApps.com" " XXX^^^XXX^^^" "+" $strCurrentAppNameShort
							${WordReplace} $strCurrentAppNameShort " Portable" "" "+" $strCurrentAppNameShort
							${WordReplace} $strCurrentAppNameShort " XXX^^^XXX^^^" " PortableApps.com" "+" $strCurrentAppNameShort
						${Else}
							StrCpy $strCurrentAppNameShort $strCurrentAppName
						${EndIf}
						${ReadINIStrWithDefault} $strCurrentAppCategory ${UPDATE_FILE_INI} $strCurrentAppID "Category" "NONE"
						${If} $LANGUAGE == 1033
							${ReadINIStrWithDefault} $strCurrentAppSubCategory ${UPDATE_FILE_INI} $strCurrentAppID "Description" "..."
						${Else}
							${ReadINIStrWithDefault} $strCurrentAppSubCategory ${UPDATE_FILE_INI} $strCurrentAppID "SubCategory" "..."
							${ReadINIStrWithDefault} $strCurrentAppSubCategory $strLocaleFile "SUBCATEGORIES" $strCurrentAppSubCategory $strCurrentAppSubCategory
						${EndIf}
						
						${ReadINIStrWithDefault} $strCurrentAppDisplayVersion ${UPDATE_FILE_INI} $strCurrentAppID "DisplayVersion" "(ERROR: $strCurrentAppID\DisplayVersion)"
						${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile" "(ERROR: $strCurrentAppID\DownloadURL)"
						${If} $strLanguageName != "ENGLISH"
							${StrLoc} $0 $strCurrentAppDownloadFile "_English" ">"
							${StrLoc} $1 $strCurrentAppDownloadFile "_Multilingual" ">"
							${If} $0 > 0
							${OrIf} $1 > 0
								StrCpy $0 $strCurrentAppDownloadFile
								${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageName" "$strCurrentAppDownloadFile"
								${If} $0 == $strCurrentAppDownloadFile
								${AndIf} $strLanguageNameFallback != "NONE"
									${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageNameFallback" "$strCurrentAppDownloadFile"
								${EndIf}
							${EndIf}
						${EndIf}
						${ReadINIStrWithDefault} $strCurrentAppDownloadPath ${UPDATE_FILE_INI} $strCurrentAppID "DownloadPath" "$strHTTPProtocol://downloads.sourceforge.net/portableapps/"
						${ReadINIStrWithDefault} $strCurrentAppDownloadSize ${UPDATE_FILE_INI} $strCurrentAppID "DownloadSize" "0"

						${If} $bolUpdateMode == true
							${ReadINIStrWithDefault} $strCurrentAppPackageVersion ${UPDATE_FILE_INI} $strCurrentAppID "PackageVersion" "(ERROR: $strCurrentAppID\PackageVersion)"
							${If} $strLanguageName != "ENGLISH"
								${StrLoc} $0 $strCurrentAppDownloadFile "_English" ">"
								${StrLoc} $1 $strCurrentAppDownloadFile "_Multilingual" ">"
								${If} $0 > 0
								${OrIf} $1 > 0									
									StrCpy $0 $strCurrentAppDownloadFile
									${ReadINIStrWithDefault} $strCurrentAppPackageVersion ${UPDATE_FILE_INI} $strCurrentAppID "PackageVersion_$strLanguageName" "$strCurrentAppPackageVersion"
									${If} $0 == $strCurrentAppDownloadFile
									${AndIf} $strLanguageNameFallback != "NONE"
										${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageNameFallback" "$strCurrentAppDownloadFile"
									${EndIf}
								${EndIf}
							${EndIf}
							${ReadINIStrWithDefault} $strCurrentAppUpdatedOn ${UPDATE_FILE_INI} $strCurrentAppID "UpdateDate" "2000-00-00"
						${Else}		 
							${ReadINIStrWithDefault} $strCurrentAppInstallSize ${UPDATE_FILE_INI} $strCurrentAppID "InstallSize" "0"
							${If} $strOrder == "new"
								${ReadINIStrWithDefault} $strCurrentAppReleasedOn ${UPDATE_FILE_INI} $strCurrentAppID "ReleaseDate" "2000-00-00"
							${EndIf}
							
							${ReadINIStrWithDefault} $0 ${UPDATE_FILE_INI} $strCurrentAppID "Compatibility" "04,12,**"
							
							StrCpy $strCurrentAppMinOS $0 2
							StrCpy $strCurrentAppMaxOS $0 2 3
							StrCpy $strCurrentAppBits $0 2 6
							StrLen $1 $0
							${If} $1 > 8
								StrCpy $strCurrentAppLicense $0 3 9
								${If} $1 > 12
									StrCpy $strCurrentAppClass $0 "" 13
								${Else}
									StrCpy $strCurrentAppClass "Stable"
								${EndIf}
							${Else}
								StrCpy $strCurrentAppLicense "oss"
								StrCpy $strCurrentAppClass "Stable"
							${EndIf}
							
							${If} $strCurrentAppClass == "Beta"
							${OrIf} $strCurrentAppClass == "Dev"
							${OrIf} $strCurrentAppClass == "Discontinued"
							${OrIf} $strCurrentAppClass == "Advanced"
							${OrIf} $strCurrentAppClass == "LTS"
							${OrIf} $strCurrentAppClass == "Legacy"
							${OrIf} $strCurrentAppClass == "Test"
								StrCpy $bolCurrentAppAdvanced "true"
							${Else}
								StrCpy $bolCurrentAppAdvanced "false"
							${EndIf}
						${EndIf}

						${If} $strOrder == "updated"
							${ReadINIStrWithDefault} $strCurrentAppUpdatedOn ${UPDATE_FILE_INI} $strCurrentAppID "UpdateDate" "2000-00-00"
						${EndIf}

						${ReadINIStrWithDefault} $strCurrentAppType ${UPDATE_FILE_INI} $strCurrentAppID "Type" "app"
						
						${If} $strCurrentAppType == "app"
							StrCpy $strCurrentAppBasePath "$strPortableAppsPath\$strCurrentAppID"
							StrCpy $strCurrentAppInfoPath "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\appinfo.ini"
						${Else}
							StrCpy $strCurrentAppBasePath "$strPortableAppsPath\CommonFiles\$strCurrentAppID"
							${If} ${FileExists} "$strPortableAppsPath\CommonFiles\$strCurrentAppID\App\AppInfo\plugininstaller.ini"
								StrCpy $strCurrentAppInfoPath "$strPortableAppsPath\CommonFiles\$strCurrentAppID\App\AppInfo\plugininstaller.ini"
							${Else}
								StrCpy $strCurrentAppInfoPath "$strPortableAppsPath\CommonFiles\$strCurrentAppID\Other\Source\plugininstaller.ini"
							${EndIf}
						${EndIf}
						
						StrCpy $bolCurrentAppListedDisabled "false"
						${If} ${FileExists} $strCurrentAppInfoPath
							${If} $bolUpdateMode == "true"
								${ReadINIStrWithDefault} $strCurrentAppInstalledVersion $strCurrentAppInfoPath "Version" "PackageVersion" "0.0.0.0"
								${VersionCompare} $strCurrentAppInstalledVersion $strCurrentAppPackageVersion $R0
								${If} $R0 == 2
									StrCpy $bolCurrentAppListed "true"
									
									;/// Check for partial update installer
									
									${StrLoc} $0 $strCurrentAppDownloadFile "_Rev" ">"
									${If} $0 > 0									
										${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadFile" $strCurrentAppDownloadFile
										${ReadINIStrWithDefault} $strCurrentAppDownloadPath ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadPath" $strCurrentAppDownloadPath
										${ReadINIStrWithDefault} $strCurrentAppDownloadSize ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadSize" $strCurrentAppDownloadSize
									${EndIf}
									
									${If} $strCurrentAppDownloadPath == ""
										StrCpy $strCurrentAppDownloadPath "$strHTTPProtocol://downloads.sourceforge.net/portableapps/"
									${EndIf}
								${Else}
									StrCpy $bolCurrentAppListed "false"
								${EndIf}
							${Else}
								${If} $bolShowInstalledApps == "true"
									StrCpy $bolCurrentAppListed "true"
									StrCpy $bolCurrentAppListedDisabled "true"
								${Else}
									StrCpy $bolCurrentAppListed "false"
								${EndIf}
							${EndIf}
						${Else} ;CHECK JAVA HERE!
							${If} $bolUpdateMode == "true"
								StrCpy $bolCurrentAppListed "false"
							${Else}
								${If} $strCurrentAppClass == "UpdateOnly"
									StrCpy $bolCurrentAppListed "false"
								${Else}
									${If} $bolShowAdvanced != "true"
									${AndIf} $bolCurrentAppAdvanced == "true"
										StrCpy $bolCurrentAppListed "false"
									${Else}
										;Freeware licensing
										${If} $strShowFreewareApps == "all"
										${OrIf} $strCurrentAppLicense == "oss"
											StrCpy $bolLicenseMatch true
										${ElseIf} $strShowFreewareApps == "none"
											StrCpy $bolLicenseMatch false
										${ElseIf} $strShowFreewareApps == "business"
											${If} $strCurrentAppLicense == "fwa"
												StrCpy $bolLicenseMatch true
											${Else}
												StrCpy $bolLicenseMatch false
											${EndIf}										
										${Else} ;$strShowFreewareApps == "education"
											${If} $strCurrentAppLicense == "fwp"
												StrCpy $bolLicenseMatch false
											${Else}
												StrCpy $bolLicenseMatch true
											${EndIf}
										${EndIf}

										${If} $bolLicenseMatch == false
											StrCpy $bolCurrentAppListed "false"
										${Else}
											${If} $strCurrentAppBits == "**"
												StrCpy $strCurrentAppBits $strBitDepth
											${EndIf}
											
											${If} $bolHide64BitApps != "true"
											${AndIf} $strCurrentAppBits == "64"
												StrCpy $strCurrentAppBits $strBitDepth
											${EndIf}
											
											;Edge cases
											${If} $strCurrentAppClass == "PlusWin81and10x86"
											${AndIf} $strBitDepth == "32"
												${If} $strWindowsVersionSimple == "09"
												${OrIf} $strWindowsVersionSimple == "10"
													StrCpy $strCurrentAppBits "32"
													StrCpy $strCurrentAppMinOS $strWindowsVersionSimple
													StrCpy $strCurrentAppMaxOS $strWindowsVersionSimple
												${EndIf}
											${EndIf}
											${If} $strCurrentAppClass == "PlusWin10x86"
											${AndIf} $strWindowsVersionSimple == "10"
											${AndIf} $strBitDepth == "32"
												StrCpy $strCurrentAppBits "32"
												StrCpy $strCurrentAppMinOS "10"
												StrCpy $strCurrentAppMaxOS "10"
											${EndIf}
											${If} $strCurrentAppClass == "PlusVistax64"
											${AndIf} $strWindowsVersionSimple == "06"
											${AndIf} $strBitDepth == "64"
												StrCpy $strCurrentAppBits "64"
												StrCpy $strCurrentAppMinOS "06"
												StrCpy $strCurrentAppMaxOS "06"
											${EndIf}
											${If} $strCurrentAppClass == "PlusXPx64"
											${AndIf} $strWindowsVersionSimple == "05"
											${AndIf} $strBitDepth == "64"
												StrCpy $strCurrentAppBits "64"
												StrCpy $strCurrentAppMinOS "05"
												StrCpy $strCurrentAppMaxOS "05"
											${EndIf}
											${If} $strCurrentAppClass == "PlusLegacy"
												${If} $strWindowsVersionSimple == "05"
												${OrIf} $strWindowsVersionSimple == "06"
													StrCpy $strCurrentAppBits $strBitDepth
													StrCpy $strCurrentAppMinOS "05"
													StrCpy $strCurrentAppMaxOS "06"
												${EndIf}
											${EndIf}
											${If} $strCurrentAppClass == "MinusWin80"
											${AndIf} $strWindowsVersionSimple == "08"
												StrCpy $strCurrentAppMinOS "99"
												StrCpy $strCurrentAppMaxOS "99"
											${EndIf}
											${If} $strCurrentAppClass == "PlusWin80"
											${AndIf} $strWindowsVersionSimple == "08"
												StrCpy $strCurrentAppBits $strBitDepth
												StrCpy $strCurrentAppMinOS "08"
												StrCpy $strCurrentAppMaxOS "08"
											${EndIf}
											
											${If} $strCurrentAppMinOS > $strWindowsVersionSimple
											${OrIf} $strCurrentAppMaxOS < $strWindowsVersionSimple
											${OrIf} $strCurrentAppBits != $strBitDepth
												StrCpy $bolCurrentAppListed $bolShowAdvanced
											${Else}		
												StrCpy $bolCurrentAppListed "true"
											${EndIf}
										${EndIf}
									${EndIf}
								${EndIf}
							${EndIf}
						${EndIf}
						
						${If} $strCurrentAppID == "PortableApps.com"
						${OrIf} $strCurrentAppID == "PortableApps.comBeta"
						${OrIf} $strCurrentAppID == "PortableApps.comBetaChannel"
							;Fallback if not running in standard sub-directory
							StrCpy $bolCurrentAppListed "false"
						${EndIf}
						
						${If} $bolCurrentAppListed == "true"
							${WordReplace} $strCurrentAppID "orrent" "o-X-rr-X-ent" "+" $strCurrentAppIDClean
							;See if we already have the app's icon
							${If} ${FileExists} "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
								StrCpy $strCurrentAppIcon "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
							${ElseIf} ${FileExists} "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\appicon.ico"
								StrCpy $strCurrentAppIcon "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\appicon.ico"
							${Else} ;Try to download the icon
								${UpdaterFileDownload} $R0 "$strHTTPProtocol://portableapps.com/files/images/updatericons/$strCurrentAppIDClean.ico" "$EXEDIR\App\graphics\appicons\$strCurrentAppIDClean.ico" "" false false ""

								${If} $R0 != "OK"
									Delete "$EXEDIR\App\graphics\appicons\$strCurrentAppIDClean.ico"
									CopyFiles /SILENT "$EXEDIR\App\Graphics\updatericons\defaultapp.ico" "$EXEDIR\App\Graphics\appicons"
									Rename "$EXEDIR\App\Graphics\appicons\defaultapp.ico" "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
								${EndIf}
								${GetSize} "$EXEDIR\App\graphics\appicons" "/M=$strCurrentAppIDClean.ico /S=0K /G=0" $0 $1 $2
								${If} $0 > 5
									Delete "$EXEDIR\App\graphics\appicons\$strCurrentAppIDClean.ico"
									CopyFiles /SILENT "$EXEDIR\App\Graphics\updatericons\defaultapp.ico" "$EXEDIR\App\Graphics\appicons"
									Rename "$EXEDIR\App\Graphics\appicons\defaultapp.ico" "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
								${EndIf}

								${If} ${FileExists} "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
									StrCpy $strCurrentAppIcon "$EXEDIR\App\Graphics\appicons\$strCurrentAppIDClean.ico"
								${Else}
									StrCpy $strCurrentAppIcon "$EXEDIR\App\Graphics\appicons\defaultapp.ico"	
								${EndIf}
							${EndIf}
						
							;Incorporate the app icon
							;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "Icon$intCurrentAppCounter" "$strCurrentAppIcon"
							FileWriteUTF16LE $fileIconList "Icon$intCurrentAppCounter=$strCurrentAppIcon$\r$\n"
							;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "IconIndex" "$intCurrentAppCounter"
							
							FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
							FileWriteUTF16LE $fileAppList "IconIndex=$intCurrentAppCounter$\r$\n"
							
							
							;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "AppID" "$strCurrentAppID"
							FileWriteUTF16LE $fileAppList "AppID=$strCurrentAppID$\r$\n"
							
							
							${If} $bolUpdateMode == "true"
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "Text" "$strCurrentAppNameShort $strCurrentAppDisplayVersion"
								FileWriteUTF16LE $fileAppList "Text=$strCurrentAppNameShort $strCurrentAppDisplayVersion$\r$\n"
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem1" "$strCurrentAppDownloadSize $strTransColumnMB"
								FileWriteUTF16LE $fileAppList "SubItem1=$strCurrentAppDownloadSize $strTransColumnMB$\r$\n"
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem2" "$strCurrentAppCategory - $strCurrentAppSubCategory"
								
								${If} $LANGUAGE == 1033
									StrCpy $strCurrentAppCategoryLocalized $strCurrentAppCategory
								${Else}
									${Switch} $strCurrentAppCategory
										${Case} 'Accessibility'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryAccessibility
											${Break}
										${Case} 'Development'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryDevelopment
											${Break}
										${Case} 'Education'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryEducation
											${Break}
										${Case} 'Games'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryGames
											${Break}
										${Case} 'Graphics and Pictures'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryGraphicsPictures
											${Break}
										${Case} 'Internet'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryInternet
											${Break}
										${Case} 'Music and Video'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryMusicVideo
											${Break}
										${Case} 'Office'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryOffice
											${Break}
										${Case} 'Security'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategorySecurity
											${Break}
										${Case} 'Utilities'
											StrCpy $strCurrentAppCategoryLocalized $strTransCategoryUtilities
											${Break}
										${Default}
											StrCpy $strCurrentAppCategoryLocalized ""
									${EndSwitch}							
								${EndIf}
								
								FileWriteUTF16LE $fileAppList "SubItem2=$strCurrentAppCategoryLocalized - $strCurrentAppSubCategory$\r$\n"
									FileWriteUTF16LE $fileAppList "SubItem3=$strCurrentAppUpdatedOn$\r$\n"																					 
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "Checked" "1"
								${StrLoc} $0 $strIgnoreAppsDuringUpdate "|$strCurrentAppID|" ">"
								${If} $0 > 0
									FileWriteUTF16LE $fileAppList "Checked=0$\r$\n"
								${Else}
									FileWriteUTF16LE $fileAppList "Checked=1$\r$\n"
								${EndIf}
							${Else}
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "Text" "$strCurrentAppNameShort"
								FileWriteUTF16LE $fileAppList "Text=$strCurrentAppNameShort$\r$\n"
								;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem1" "$strCurrentAppSubCategory"
								FileWriteUTF16LE $fileAppList "SubItem1=$strCurrentAppSubCategory$\r$\n"
								${If} $bolCurrentAppListedDisabled == "true"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem2" "-"
									FileWriteUTF16LE $fileAppList "SubItem2=-$\r$\n"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem4" "-"
									FileWriteUTF16LE $fileAppList "SubItem4=-$\r$\n"
								${Else}
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem2" "$strCurrentAppDownloadSize $strTransColumnMB"
									FileWriteUTF16LE $fileAppList "SubItem2=$strCurrentAppDownloadSize $strTransColumnMB$\r$\n"
									;${If} $strCurrentAppInstallSizeTo == "0"
										;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem4" "$strCurrentAppInstallSize $strTransColumnMB"
										FileWriteUTF16LE $fileAppList "SubItem4=$strCurrentAppInstallSize $strTransColumnMB$\r$\n"
									;${Else}
										;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem4" "$strCurrentAppInstallSize-$strCurrentAppInstallSizeTo $strTransColumnMB"
										;FileWriteUTF16LE $fileAppList "SubItem4=$strCurrentAppInstallSize-$strCurrentAppInstallSizeTo $strTransColumnMB$\r$\n"
									;${EndIf}
								${EndIf}
								${If} $strOrder == "new"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem5" "$strCurrentAppReleasedOn"
									FileWriteUTF16LE $fileAppList "SubItem5=$strCurrentAppReleasedOn$\r$\n"
								${EndIf}
								${If} $strOrder == "updated"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem5" "$strCurrentAppUpdatedOn"
									FileWriteUTF16LE $fileAppList "SubItem5=$strCurrentAppUpdatedOn$\r$\n"
								${EndIf}
								;IntOp $intDownloadSize $intDownloadSize + $strCurrentAppDownloadSize
								;IntOp $intInstallSize $intInstallSize + $strCurrentAppInstallSize
								${If} $strCurrentAppCategory == "Accessibility"
									StrCpy $strCurrentAppCategory $strTransCategoryAccessibility
								${ElseIf} $strCurrentAppCategory == "Development"
									StrCpy $strCurrentAppCategory $strTransCategoryDevelopment
								${ElseIf} $strCurrentAppCategory == "Education"
									StrCpy $strCurrentAppCategory $strTransCategoryEducation
								${ElseIf} $strCurrentAppCategory == "Games"
									StrCpy $strCurrentAppCategory $strTransCategoryGames
								${ElseIf} $strCurrentAppCategory == "Graphics and Pictures"
									StrCpy $strCurrentAppCategory $strTransCategoryGraphicsPictures
								${ElseIf} $strCurrentAppCategory == "Internet"
									StrCpy $strCurrentAppCategory $strTransCategoryInternet
								${ElseIf} $strCurrentAppCategory == "Music and Video"
									StrCpy $strCurrentAppCategory $strTransCategoryMusicVideo
								${ElseIf} $strCurrentAppCategory == "Office"
									StrCpy $strCurrentAppCategory $strTransCategoryOffice
								${ElseIf} $strCurrentAppCategory == "Security"
									StrCpy $strCurrentAppCategory $strTransCategorySecurity
								${ElseIf} $strCurrentAppCategory == "Utilities"
									StrCpy $strCurrentAppCategory $strTransCategoryUtilities
								${EndIf}

								${If} $strOrder == "category"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem3" "$strCurrentAppCategory - $strCurrentAppNameShort"
									FileWriteUTF16LE $fileAppList "SubItem3=$strCurrentAppCategory - $strCurrentAppNameShort$\r$\n"
								${Else}
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "SubItem3" " "
									FileWriteUTF16LE $fileAppList "SubItem3=' '$\r$\n"
								${EndIf}
								
								${If} $bolCurrentAppListedDisabled == "true"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "Checked" "1"
									FileWriteUTF16LE $fileAppList "Checked=1$\r$\n"
									;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "DisableCheck" "1"
									FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
								${Else}
									${If} $bolAddAll == "true"
										;WriteINIStr ${APP_LIST_FILE_INI} "Item $intCurrentAppCounter" "Checked" "1"
										FileWriteUTF16LE $fileAppList "Checked=1$\r$\n"									
									${EndIf}
								${EndIf}
							${EndIf}
							
							IntOp $intCurrentAppCounter $intCurrentAppCounter + 1 ;increment our list counter
						${EndIf}
					${EndIf}
					IntOp $intCounter $intCounter - 1 ;cycle through our app list
				${Loop}
				
				IntOp $intSelectedApps $intCurrentAppCounter - 1 ;Number of apps selected
				
				${If} $bolUpdateMode == "true"
					StrCpy $intSettingsCount $intSelectedApps
					;WriteINIStr ${APP_LIST_FILE_INI} "Settings" "count" "$intSelectedApps"
					;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "$intSelectedApps"
					FileWriteUTF16LE $fileIconList "IconCount=$intSelectedApps$\r$\n"	
				${ElseIf} $strOrder == "category"
					;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "Icon$intCurrentAppCounter" "$EXEDIR\App\graphics\updatericons\blank.ico"
					FileWriteUTF16LE $fileIconList "Icon$intCurrentAppCounter=$EXEDIR\App\graphics\updatericons\blank.ico$\r$\n"	
					;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "$intCurrentAppCounter"
					
					StrCpy $0 $intCurrentAppCounter
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryAccessibility - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryAccessibility$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryAccessibility - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryAccessibility - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryDevelopment - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryDevelopment$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryDevelopment - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryDevelopment - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryEducation - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryEducation$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryEducation - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryEducation - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGames - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryGames$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGames - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGames - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1					
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGraphicsPictures - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryGraphicsPictures$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGraphicsPictures - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryGraphicsPictures - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1						

					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryInternet - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryInternet$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryInternet - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryInternet - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1			
						
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryMusicVideo - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryMusicVideo$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryMusicVideo - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryMusicVideo - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1	
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryOffice - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryOffice$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryOffice - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryOffice - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1	
				
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategorySecurity - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategorySecurity$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategorySecurity - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategorySecurity - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
									
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1	
					\
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=______________________________$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryUtilities - 1111$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
								
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=$strTransCategoryUtilities$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryUtilities - 1112$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=1$\r$\n"
					
					IntOp $intCurrentAppCounter $intCurrentAppCounter + 1
					
					FileWriteUTF16LE $fileAppList "[Item $intCurrentAppCounter]$\r$\n"
					FileWriteUTF16LE $fileAppList "Text=¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem1=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem2=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem3=$strTransCategoryUtilities - 1113$\r$\n"
					FileWriteUTF16LE $fileAppList "SubItem4=' '$\r$\n"
					FileWriteUTF16LE $fileAppList "IconIndex=$0$\r$\n"
					FileWriteUTF16LE $fileAppList "DisableCheck=2$\r$\n"
					
					;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "$intCurrentAppCounter"
					FileWriteUTF16LE $fileIconList "IconCount=$intCurrentAppCounter$\r$\n"	
				${Else}
					;WriteINIStr ${APP_LIST_FILE_INI} "Icons" "IconCount" "$intCurrentAppCounter"				
					FileWriteUTF16LE $fileIconList "IconCount=$intCurrentAppCounter$\r$\n"	
				${EndIf}
				
			${EndIf}
				FileClose $fileAppList
				FileClose $fileIconList
				
				FileOpen $0 "${APP_LIST_FILE_INI}" a
				FileSeek $0 0 END
				
				ClearErrors
				FileOpen $fileAppList "${APP_LIST_FILE_INI}.Apps.ini" r
				IfErrors DoneReadingAppsIni
				LoopReadingAppsIni:
					FileReadUTF16LE $fileAppList $1
					IfErrors DoneReadingAppsIni
					FileWriteUTF16LE $0 $1
					Goto LoopReadingAppsIni
				
				DoneReadingAppsIni:
				FileClose $fileAppList
				
				ClearErrors
				FileOpen $fileIconList "${APP_LIST_FILE_INI}.Icons.ini" r
				IfErrors DoneReadingIconsIni
				LoopReadingIconsIni:
					FileReadUTF16LE $fileIconList $1
					IfErrors DoneReadingIconsIni
					FileWriteUTF16LE $0 $1
					Goto LoopReadingIconsIni
				
				DoneReadingIconsIni:
				FileClose $fileIconList
				
				FileClose $0
				
				${If} $intSettingsCount > 0
					WriteINIStr ${APP_LIST_FILE_INI} "Settings" "count" "$intSettingsCount"
				${EndIf}
		${Else}
			;Invalid update file from PA.c
		${EndIf}
	${EndIf}
	${If} $intSelectedApps == 0
		${If} $bolPlatformStartupMode != "true"
			${If} $bolBannerIsUp == true
				Banner::destroy
				StrCpy $bolBannerIsUp false
			${EndIf}
			${If} $bolUpdateMode == "true"
				MessageBox MB_OK|MB_ICONINFORMATION $strTransUpToDate
			${Else}
				MessageBox MB_OK|MB_ICONINFORMATION $strTransIntroNoOtherApps
			${EndIf}
			Abort
		${Else}
			Abort
		${EndIf}
	${EndIf}
	
	;=== Check for running platform
	${IfNot} ${ProcessExists} "PortableAppsPlatform.exe"
		${If} ${AtLeastWinXP}
			MessageBox MB_OK|MB_ICONINFORMATION $strTransPlatformNotRunning
		${Else}
			MessageBox MB_OK|MB_ICONINFORMATION $strTransOldWindowsBugs
		${EndIf}
	${EndIf}
FunctionEnd

Function InstallFilesShow
	${PageHeaderHackForHighContrast}
	GetDlgItem $0 $HWNDPARENT 3
	ShowWindow $0 0
	GetDlgItem $0 $HWNDPARENT 2
	ShowWindow $0 0
	SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR:$strRealCaption"
	!insertmacro MUI_HEADER_TEXT $strTransDownloadHeading $strTransDownloadSubHeading
FunctionEnd

Function AppListShow
	;SendMessage $mui.Button.Cancel ${WM_SETFONT} $fntPlatform 1
	;SendMessage $mui.Button.Next ${WM_SETFONT} $fntPlatform 1
	;SendMessage $mui.Branding.Text ${WM_SETFONT} $fntPlatform 1
	${PageHeaderHackForHighContrast}
	GetDlgItem $0 $HWNDPARENT 3
	ShowWindow $0 0
	SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR:$strRealCaption"
	${If} $bolUpdateMode == "true"
		!insertmacro MUI_HEADER_TEXT $strTransSectionHeadingUpdate $strTransSectionSubHeadingUpdate
	${Else}
		!insertmacro MUI_HEADER_TEXT $strTransSectionHeadingNew $strTransSectionSubHeadingNew
	${EndIf}
	${If} $bolBannerIsUp == true
		Banner::destroy
		StrCpy $bolBannerIsUp false
	${EndIf}
	EmbeddedLists::InitDialog ${APP_LIST_FILE_INI}
	Pop $R0
	EmbeddedLists::Show
	Pop $R1
	${If} $bolKeyboardFriendly == true
		SendMessage $HWNDPARENT ${WM_SETFOCUS} $R0 1 
	${EndIf}
FunctionEnd

Function AppListLeave
	;Is there enough free space on the local PC to download?
	${If} $bolKeyboardFriendly == true
		StrCpy $R1 ``        ; Clear selected items list.
		
		Pop $R0              ; Selected item number.
		
		StrCmp $R0 /END +4   ; No item selected?
			ReadINIStr $R0 `${APP_LIST_FILE_INI}` `Item $R0` `AppID`
			StrCpy $R1 $R1|$R0
			Goto -4              ; Loop.

		StrCpy $R1 $R1 `` 1  ; Trim first | from front.
		${If} $R1 == ''
			StrCpy $strSelectedApps ''
		${Else}
			StrCpy $strSelectedApps '|$R1|'
		${EndIf}
	${EndIf}
	
	;Is there enough free space on the device to install?
FunctionEnd

Section "Main"
	StrCpy $bolUpdaterHasRun true
	SetDetailsPrint both
	DetailPrint `$strTransDownloadConnecting`
	SetDetailsPrint none
	RealProgress::SetProgress /NOUNLOAD 1
	StrCpy $strTempMessage $strTransDownloadConnecting
	
	;determine how many apps we will be processing
	StrCpy $intAppsToProcess 0
	StrCpy $intCounter $intSelectedApps

	${If} $bolUpdateMode == true
		StrCpy $strIgnoreAppsDuringUpdate "||"
	${EndIf}

	${DoUntil} $intCounter = 0
		${If} $bolKeyboardFriendly == true
			${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "AppID" "zzFakeAppIDzz"
			${If} $strSelectedApps == ''
			${AndIf} $bolUpdateMode == true
				IntOp $intAppsToProcess $intAppsToProcess + 1 ;cycle through our app list
			${Else}
				${WordFind} $strSelectedApps "|$R0|" "*" $R1
				${If} $R1 == 1
				${OrIf} $R0 == "PortableApps.com"
				${OrIf} $R0 == "PortableApps.comBeta"
				${OrIf} $R0 == "PortableApps.comBetaChannel"
					IntOp $intAppsToProcess $intAppsToProcess + 1 ;cycle through our app list
				${EndIf}
			${EndIf}
		${Else}
			${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "Checked" "0"
			${ReadINIStrWithDefault} $R1 ${APP_LIST_FILE_INI} "Item $intCounter" "DisableCheck" "0"
			${If} $R0 == "1"
			${AndIf} $R1 == "0"
				IntOp $intAppsToProcess $intAppsToProcess + 1 ;cycle through our app list
			${EndIf}
			${If} $R0 == "0"
			${AndIf} $bolUpdateMode == true
				${ReadINIStrWithDefault} $R2 ${APP_LIST_FILE_INI} "Item $intCounter" "AppID" ""
				StrCpy $strIgnoreAppsDuringUpdate "$strIgnoreAppsDuringUpdate$R2|"
			${EndIf}
		${EndIf}
		IntOp $intCounter $intCounter - 1 ;cycle through our app list
	${Loop}
	;IntOp $intProgressIncrements 49 / $intAppsToProcess
	
	${If} $bolUpdateMode == true
		WriteINIStr $strSettingsFile "Updater" "IgnoredApps" $strIgnoreAppsDuringUpdate
	${EndIf}	
	
	${If} $intAppsToProcess > 0
		;Loop through apps and download all
		StrCpy $intCounter $intSelectedApps
		StrCpy $intCurrentApp 1
		${DoUntil} $intCounter = 0
			${If} $bolKeyboardFriendly == true
				${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "AppID" "zzFakeAppIDzz"
				${If} $strSelectedApps == ''
				${AndIf} $bolUpdateMode == true
					StrCpy $R0 "1"
					StrCpy $R1 "0"
				${Else}
					${WordFind} $strSelectedApps "|$R0|" "*" $R1
					${If} $R1 == 1
					${OrIf} $R0 == "PortableApps.com"
					${OrIf} $R0 == "PortableApps.comBeta"
					${OrIf} $R0 == "PortableApps.comBetaChannel"
						StrCpy $R0 "1"
						StrCpy $R1 "0"
					${EndIf}
				${EndIf}
			${Else}
				${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "Checked" "0"
				${ReadINIStrWithDefault} $R1 ${APP_LIST_FILE_INI} "Item $intCounter" "DisableCheck" "0"
			${EndIf}
			${If} $R0 == "1"
			${AndIf} $R1 == "0"
				${ReadINIStrWithDefault} $strCurrentAppID ${APP_LIST_FILE_INI} "Item $intCounter" "AppId" "ERROR"
				${ReadINIStrWithDefault} $strCurrentAppName ${UPDATE_FILE_INI} $strCurrentAppID "Name" "(ERROR: $strCurrentAppID\Name)"
				
				${If} $bolHidePortableInAppNames == "true"
					${WordReplace} $strCurrentAppName ", Portable Edition" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort ", Portable" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " PortableApps.com" " XXX^^^XXX^^^" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " Portable" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " XXX^^^XXX^^^" " PortableApps.com" "+" $strCurrentAppNameShort
				${Else}
					StrCpy $strCurrentAppNameShort $strCurrentAppName
				${EndIf}
				
				${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile" "(ERROR: $strCurrentAppID\DownloadURL)"
				
				${If} $strCurrentAppID == "PortableApps.com"
				${OrIf} $strCurrentAppID == "PortableApps.comBeta"
				${OrIf} $strCurrentAppID == "PortableApps.comBetaChannel"
					${ReadINIStrWithDefault} $strCurrentAppHash ${UPDATE_FILE_INI} $strCurrentAppID "Hash256" "(ERROR: $strCurrentAppID\Hash256)"
				${Else}
					${ReadINIStrWithDefault} $strCurrentAppHash ${UPDATE_FILE_INI} $strCurrentAppID "Hash" "(ERROR: $strCurrentAppID\Hash)"
				${EndIf}
				
				${If} $strLanguageName != "ENGLISH"
					${StrLoc} $0 $strCurrentAppDownloadFile "_English" ">"
					${StrLoc} $1 $strCurrentAppDownloadFile "_Multilingual" ">"
					${If} $0 > 0
					${OrIf} $1 > 0						
						StrCpy $0 $strCurrentAppDownloadFile
						${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageName" "$strCurrentAppDownloadFile"
						${ReadINIStrWithDefault} $strCurrentAppHash ${UPDATE_FILE_INI} $strCurrentAppID "Hash_$strLanguageName" "$strCurrentAppHash"
						${If} $0 == $strCurrentAppDownloadFile
						${AndIf} $strLanguageNameFallback != "NONE"
							${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageNameFallback" "$strCurrentAppDownloadFile"
							${ReadINIStrWithDefault} $strCurrentAppHash ${UPDATE_FILE_INI} $strCurrentAppID "Hash_$strLanguageNameFallback" "$strCurrentAppHash"
						${EndIf}
					${EndIf}
				${EndIf}
				${ReadINIStrWithDefault} $strCurrentAppDownloadPath ${UPDATE_FILE_INI} $strCurrentAppID "DownloadPath" "$strHTTPProtocol://downloads.sourceforge.net/portableapps/"
				
				
				
				;${GetFileName} $strCurrentAppDownloadFile $strCurrentAppInstallerEXE
				
				;/// Check for partial update installer
				${If} $bolPlatformUpdateMode == true
					StrCpy $strCurrentAppInstalledVersion ${PRODUCT_VERSION}
				${Else}
					${ReadINIStrWithDefault} $strCurrentAppInstalledVersion "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\AppInfo.ini" "Version" "PackageVersion" "0.0.0.0"
				${EndIf}
				${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadFile" $strCurrentAppDownloadFile
				${ReadINIStrWithDefault} $strCurrentAppDownloadPath ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadPath" $strCurrentAppDownloadPath
				${If} $strCurrentAppDownloadPath == ""
					StrCpy $strCurrentAppDownloadPath "$strHTTPProtocol://downloads.sourceforge.net/portableapps/"
				${EndIf}
				${ReadINIStrWithDefault} $strCurrentAppHash ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-Hash" $strCurrentAppHash
				
				IntOp $0 $intCurrentApp - 1
				IntOp $0 $0 * 49
				IntOp $0 $0 / $intAppsToProcess
				IntOp $0 $0 + 1
				SetDetailsPrint none
				RealProgress::SetProgress /NOUNLOAD $0
				SetDetailsPrint none
				${TBProgress} $0
				SetDetailsPrint none
				
				;ReDownloadTheCurrentApp:
				
				StrCpy $bolSecondDownloadAttempt false
				StrCpy $bolSecondTryDuringMaintenance false
				
				DownloadTheCurrentApp:
				
				
				
				${WordReplace} $strTransDownloadingXofY "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage
				${WordReplace} $strTempMessage "%CURRENTAPP%" $intCurrentApp "+" $strTempMessage
				${WordReplace} $strTempMessage "%APPSTOPROCESS%" $intAppsToProcess "+" $strTempMessage
				${WordReplace} $strTransDownloadingXofYVerifying "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage2
				${WordReplace} $strTempMessage2 "%CURRENTAPP%" $intCurrentApp "+" $strTempMessage2
				${WordReplace} $strTempMessage2 "%APPSTOPROCESS%" $intAppsToProcess "+" $strTempMessage2
				;NSIS inetc component can only handle 63 chars in the downloading message
				StrLen $R5 $strTempMessage
				${If} $R5 > 63
					StrCpy $strTempMessage $strTempMessage 60 0
					StrCpy $strTempMessage "$strTempMessage..."
				${EndIf}
	
				${If} $bolTLSUpdate == true
					${WordReplace} $strCurrentAppDownloadPath "%WINDOWSVERSION%" "$strWindowsVersion&tlsupdate=true" "+" $strCurrentAppDownloadPath
				${Else}
					${WordReplace} $strCurrentAppDownloadPath "%WINDOWSVERSION%" $strWindowsVersion "+" $strCurrentAppDownloadPath
				${EndIf}
				
				${If} $strHTTPProtocol == "http"
					${WordReplace} $strCurrentAppDownloadPath "https://portableapps.com/" "http://portableapps.com/" "+" $strCurrentAppDownloadPath
					${WordReplace} $strCurrentAppDownloadPath "https://downloads.portableapps.com/" "http://downloads.portableapps.com/" "+" $strCurrentAppDownloadPath
					${WordReplace} $strCurrentAppDownloadPath "https://downloads2.portableapps.com/" "http://downloads2.portableapps.com/" "+" $strCurrentAppDownloadPath
					${WordReplace} $strCurrentAppDownloadPath "https://download3.portableapps.com/" "http://download3.portableapps.com/" "+" $strCurrentAppDownloadPath
					${WordReplace} $strCurrentAppDownloadPath "https://download2.portableapps.com/" "http://download2.portableapps.com/" "+" $strCurrentAppDownloadPath
					${WordReplace} $strCurrentAppDownloadPath "https://download2.portableapps.com/" "http://download2.portableapps.com/" "+" $strCurrentAppDownloadPath
				${EndIf}
				SetDetailsPrint textonly
				DetailPrint $strTempMessage
				SetDetailsPrint none
				
				${UpdaterFileDownload} $R1 "$strCurrentAppDownloadPath$strCurrentAppDownloadFile" "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "$strTempMessage" true false ""
				SetDetailsPrint none
				
				${If} $R1 != "ok"
					${If} $bolSecondDownloadAttempt == false
					${AndIf} $R1 != "Cancelled"
						StrCpy $bolSecondDownloadAttempt true
						Goto DownloadTheCurrentApp
					${Else}
						${If} $R1 != "Cancelled"
							${If} $R1 == "Server Error (503)" ;This occurs when the website is offline during SQL backups
							${AndIf} $bolSecondTryDuringMaintenance != true
								StrCpy $0 $strCurrentAppDownloadPath 34
								${If} $0 == "$strHTTPProtocol://portableapps.com/bouncer?t="
									${WordReplace} $strCurrentAppDownloadPath "$strHTTPProtocol://portableapps.com/bouncer?t=" "" "+" $strCurrentAppDownloadPath
									${WordReplace} $strCurrentAppDownloadPath "%3A" ":" "+" $strCurrentAppDownloadPath
									${WordReplace} $strCurrentAppDownloadPath "%2F" "/" "+" $strCurrentAppDownloadPath
									StrCpy $bolSecondTryDuringMaintenance true
									Goto DownloadTheCurrentApp
								${Else}
									;${WordReplace} $strTransDownloadErrorSiteMaintenance "%FILE%" $strCurrentAppDownloadFile "+" $strTempMessage
									${WordReplace} $strTransDownloadError "%ERROR%" $R1 "+" $strTempMessage
									${WordReplace} $strTempMessage "%FILE%" "$strCurrentAppDownloadPath$strCurrentAppDownloadFile" "+" $strTempMessage
									StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
									StrCpy $bolErrors true
								${EndIf}
							${Else}	
								StrCpy $0 $strCurrentAppDownloadPath 34
								${If} $0 == "$strHTTPProtocol://download3.portableapps.com/"
								${OrIf} $0 == "$strHTTPProtocol://downloads.portableapps.com/"
									${WordReplace} $strCurrentAppDownloadPath "$strHTTPProtocol://download3.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentAppDownloadPath
									${WordReplace} $strCurrentAppDownloadPath "$strHTTPProtocol://downloads.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentAppDownloadPath
									Goto DownloadTheCurrentApp
								${Else}
									;${If} $bolSecondTryDuringMaintenance == true
									;	${WordReplace} $strTransDownloadErrorSiteMaintenance "%FILE%" $strCurrentAppDownloadFile "+" $strTempMessage
									;${Else}
										${If} $R1 == "SendRequest Error"
											StrCpy $strTempMessage $strTransDownloadErrorSendRequest
										${Else}						
											${WordReplace} $strTransDownloadError "%ERROR%" "$R1" "+" $strTempMessage
										${EndIf}
										${WordReplace} $strTempMessage "%FILE%" "$\r$\n$strCurrentAppDownloadPath$strCurrentAppDownloadFile" "+" $strTempMessage
										;${WordReplace} $strTempMessage "redirect/?" "redirect/$\r$\n?" "+" $strTempMessage
										;${WordReplace} $strTempMessage "&wv" "&w$\r$\nv" "+" $strTempMessage
									;${EndIf}
									StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
									StrCpy $bolErrors true
								${EndIf}
							${EndIf}
						${Else}
							;Download was cancelled
							;MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to cancel this download?" IDNO ReDownloadTheCurrentApp
							${WordReplace} $strTransDownloadError "%ERROR%" "Cancelled" "+" $strTempMessage
							${WordReplace} $strTempMessage "%FILE%" "$strCurrentAppDownloadPath$strCurrentAppDownloadFile" "+" $strTempMessage
							StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
							StrCpy $bolErrors true
						${EndIf}
						Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
						StrCpy $bolErrors true
					${EndIf}
				${Else}
					SetDetailsPrint textonly
					DetailPrint $strTempMessage2
					SetDetailsPrint none
					filecheck::calcFileHash "$strDownloadToLocalPath\$strCurrentAppDownloadFile" sha256
					Pop $R0
					SetDetailsPrint none
					${If} $R0 != $strCurrentAppHash
						${If} $bolSecondDownloadAttempt == false
							StrCpy $bolSecondDownloadAttempt true
							Goto DownloadTheCurrentApp
						${Else}
							${WordReplace} $strTransDownloadInvalid "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage
							StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
							Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
							StrCpy $bolErrors true
						${EndIf}
					${Else} ;Downloaded app is valid					
						;Live installer download file 1
						MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownloadURL"
						Pop $strCurrentExtraPieceDownloadPath
						SetDetailsPrint none
						${If} $strCurrentExtraPieceDownloadPath != "" ;Online Installer
							MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownloadFilename"
							Pop $strCurrentExtraPieceDownloadFile
							SetDetailsPrint none
							
							DownloadTheCurrentExtraPiece:
							
							${WordReplace} $strTransDownloadingXofY "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage
							${WordReplace} $strTempMessage "%CURRENTAPP%" $intCurrentApp "+" $strTempMessage
							${WordReplace} $strTempMessage "%APPSTOPROCESS%" $intAppsToProcess "+" $strTempMessage
							SetDetailsPrint textonly
							DetailPrint $strTempMessage
							SetDetailsPrint none
							${UpdaterFileDownload} $R1 "$strCurrentExtraPieceDownloadPath" "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile" "$strTempMessage" true false ""
							SetDetailsPrint none
							${If} $R1 != "ok" ;download of extra piece failed
								StrCpy $0 $strCurrentExtraPieceDownloadPath 34
								${If} $0 == "$strHTTPProtocol://download3.portableapps.com/"
								${OrIf} $0 == "$strHTTPProtocol://downloads.portableapps.com/"
									${WordReplace} $strCurrentExtraPieceDownloadPath "$strHTTPProtocol://download3.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentExtraPieceDownloadPath
									${WordReplace} $strCurrentExtraPieceDownloadPath "$strHTTPProtocol://downloads.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentExtraPieceDownloadPath
									Goto DownloadTheCurrentExtraPiece
								${EndIf}
								
								${If} $R1 == "SendRequest Error"
									StrCpy $strTempMessage $strTransDownloadErrorSendRequest
								${Else}
									${WordReplace} $strTransDownloadError "%ERROR%" $R1 "+" $strTempMessage
								${EndIf}
								${WordReplace} $strTempMessage "%FILE%" "$strCurrentExtraPieceDownloadPath" "+" $strTempMessage
								StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
								Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
								Delete "$strDownloadToLocalPath\$2"
								StrCpy $bolErrors true
							${Else} ;Extra file downloaded ok
								MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownloadSHA256"
								Pop $3
								SetDetailsPrint none
								${If} $3 != ""
									SetDetailsPrint textonly
									DetailPrint $strTempMessage2
									SetDetailsPrint none
									filecheck::calcFileHash "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile" sha256
									Pop $R0
									SetDetailsPrint none
									${If} $3 != $R0 ;sha256 mismatch
										${WordReplace} $strTransDownloadInvalid "%CURRENTAPPNAME%" "$strCurrentAppNameShort ($strCurrentExtraPieceDownloadPath)" "+" $strTempMessage
										StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
										Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
										Delete "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile"
										StrCpy $bolErrors true
									${EndIf}
								${EndIf}
							${EndIf}
						${EndIf}
						
						;Live installer download file 2
						StrCpy $strCurrentExtraPieceDownloadPath ""
						MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownload2URL"
						Pop $strCurrentExtraPieceDownloadPath
						SetDetailsPrint none
						${If} $strCurrentExtraPieceDownloadPath != "" ;Online Installer
							MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownload2Filename"
							Pop $strCurrentExtraPieceDownloadFile
							SetDetailsPrint none
							
							DownloadTheCurrentExtraPiece2:
							
							${WordReplace} $strTransDownloadingXofY "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage
							${WordReplace} $strTempMessage "%CURRENTAPP%" $intCurrentApp "+" $strTempMessage
							${WordReplace} $strTempMessage "%APPSTOPROCESS%" $intAppsToProcess "+" $strTempMessage
							
							SetDetailsPrint textonly
							DetailPrint $strTempMessage
							SetDetailsPrint none
							${UpdaterFileDownload} $R1 "$strCurrentExtraPieceDownloadPath" "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile" "$strTempMessage" true false ""
							SetDetailsPrint none
							
							${If} $R1 != "ok" ;download of extra piece failed
								StrCpy $0 $strCurrentExtraPieceDownloadPath 34
								${If} $0 == "$strHTTPProtocol://download3.portableapps.com/"
								${OrIf} $0 == "$strHTTPProtocol://downloads.portableapps.com/"
									${WordReplace} $strCurrentExtraPieceDownloadPath "$strHTTPProtocol://download3.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentExtraPieceDownloadPath
									${WordReplace} $strCurrentExtraPieceDownloadPath "$strHTTPProtocol://downloads.portableapps.com/" "$strHTTPProtocol://downloads2.portableapps.com/" "+" $strCurrentExtraPieceDownloadPath
									Goto DownloadTheCurrentExtraPiece2
								${EndIf}
								
								${If} $R1 == "SendRequest Error"
									StrCpy $strTempMessage $strTransDownloadErrorSendRequest
								${Else}
									${WordReplace} $strTransDownloadError "%ERROR%" $R1 "+" $strTempMessage
								${EndIf}
								${WordReplace} $strTempMessage "%FILE%" "$strCurrentExtraPieceDownloadPath" "+" $strTempMessage
								StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
								Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
								Delete "$strDownloadToLocalPath\$2"
								StrCpy $bolErrors true
							${Else} ;Extra file downloaded ok
								MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comDownload2SHA256"
								Pop $3
								SetDetailsPrint none
								${If} $3 != ""
									SetDetailsPrint textonly
									DetailPrint $strTempMessage2
									SetDetailsPrint none
									filecheck::calcFileHash "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile" sha256
									Pop $R0
									SetDetailsPrint none
									${If} $3 != $R0 ;sha256 mismatch
										${WordReplace} $strTransDownloadInvalid "%CURRENTAPPNAME%" "$strCurrentAppNameShort ($strCurrentExtraPieceDownloadPath)" "+" $strTempMessage
										StrCpy $strFullErrorMessageAtEnd "$strFullErrorMessageAtEnd$strTempMessage$\r$\n"
										Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
										Delete "$strDownloadToLocalPath\$strCurrentExtraPieceDownloadFile"
										StrCpy $bolErrors true
									${EndIf}
								${EndIf}
							${EndIf}
						${EndIf}
					${EndIf}
				${EndIf}
				IntOp $intCurrentApp $intCurrentApp + 1 ;cycle through our app list
			${EndIf}
			IntOp $intCounter $intCounter - 1 ;cycle through our app list
		${Loop}

		
		;Loop through apps and install all
		StrCpy $intCounter $intSelectedApps
		StrCpy $intCurrentApp 1
		${DoUntil} $intCounter = 0
			${If} $bolKeyboardFriendly == true
				${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "AppID" "zzFakeAppIDzz"
				${If} $strSelectedApps == ''
				${AndIf} $bolUpdateMode == true
					StrCpy $R0 "1"
					StrCpy $R1 "0"
				${Else}
					${WordFind} $strSelectedApps "|$R0|" "*" $R1
					${If} $R1 == 1
					${OrIf} $R0 == "PortableApps.com"
					${OrIf} $R0 == "PortableApps.comBeta"
					${OrIf} $R0 == "PortableApps.comBetaChannel"
						StrCpy $R0 "1"
						StrCpy $R1 "0"
					${EndIf}
				${EndIf}
			${Else}
				${ReadINIStrWithDefault} $R0 ${APP_LIST_FILE_INI} "Item $intCounter" "Checked" "0"
				${ReadINIStrWithDefault} $R1 ${APP_LIST_FILE_INI} "Item $intCounter" "DisableCheck" "0"
			${EndIf}
			${If} $R0 == "1"
			${AndIf} $R1 == "0"
				${ReadINIStrWithDefault} $strCurrentAppID ${APP_LIST_FILE_INI} "Item $intCounter" "AppId" "ERROR"
				${ReadINIStrWithDefault} $strCurrentAppName ${UPDATE_FILE_INI} $strCurrentAppID "Name" "(ERROR: $strCurrentAppID\Name)"
				
				${If} $bolHidePortableInAppNames == "true"
					${WordReplace} $strCurrentAppName ", Portable Edition" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort ", Portable" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " PortableApps.com" " XXX^^^XXX^^^" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " Portable" "" "+" $strCurrentAppNameShort
					${WordReplace} $strCurrentAppNameShort " XXX^^^XXX^^^" " PortableApps.com" "+" $strCurrentAppNameShort
				${Else}
					StrCpy $strCurrentAppNameShort $strCurrentAppName
				${EndIf}
				
				${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile" "(ERROR: $strCurrentAppID\DownloadURL)"
				${If} $strLanguageName != "ENGLISH"
					${StrLoc} $0 $strCurrentAppDownloadFile "_English" ">"
					${StrLoc} $1 $strCurrentAppDownloadFile "_Multilingual" ">"
					${If} $0 > 0
					${OrIf} $1 > 0						
						StrCpy $0 $strCurrentAppDownloadFile
						${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageName" "$strCurrentAppDownloadFile"
						${If} $0 == $strCurrentAppDownloadFile
						${AndIf} $strLanguageNameFallback != "NONE"
							${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "DownloadFile_$strLanguageNameFallback" "$strCurrentAppDownloadFile"
						${EndIf}
					${EndIf}
				${EndIf}
				;/// Check for partial update installer
				${If} $bolPlatformUpdateMode == true
					StrCpy $strCurrentAppInstalledVersion ${PRODUCT_VERSION}
				${Else}
					${ReadINIStrWithDefault} $strCurrentAppInstalledVersion "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\AppInfo.ini" "Version" "PackageVersion" "0.0.0.0"
				${EndIf}
				${ReadINIStrWithDefault} $strCurrentAppDownloadFile ${UPDATE_FILE_INI} $strCurrentAppID "UpdateFrom-$strCurrentAppInstalledVersion-DownloadFile" $strCurrentAppDownloadFile			
				
				${If} ${FileExists} "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
					${WordReplace} $strTransInstallingXofY "%CURRENTAPPNAME%" $strCurrentAppNameShort "+" $strTempMessage
					${WordReplace} $strTempMessage "%CURRENTAPP%" $intCurrentApp "+" $strTempMessage
					${WordReplace} $strTempMessage "%APPSTOPROCESS%" $intAppsToProcess "+" $strTempMessage
					SetDetailsPrint both
					DetailPrint $strTempMessage
					SetDetailsPrint none
					
					IntOp $0 $intCurrentApp - 1
					IntOp $0 $0 * 49
					IntOp $0 $0 / $intAppsToProcess
					IntOp $0 $0 + 49
					
					SetDetailsPrint none
					RealProgress::SetProgress /NOUNLOAD $0
					SetDetailsPrint none
					${TBProgress} $0
					SetDetailsPrint none
		
					${If} $bolPlatformUpdateMode != "true"
						MoreInfo::GetUserDefined "$strDownloadToLocalPath\$strCurrentAppDownloadFile" "PortableApps.comInstallerVersion"
						Pop $1
						SetDetailsPrint none
						${VersionCompare} $1 "1.0.0.0" $2
						${If} $2 == 2
							;Invalid download
							Goto SkipInstall
						${EndIf}
						
						${VersionCompare} $1 "3.5.13.0" $2
						${If} $2 == 2
							;Fallback extract method for old installers
							StrCpy $strPAcInstallerExecString `"$strPortableAppsPath\PortableApps.com\App\7-Zip\7za.exe" x -r "$strDownloadToLocalPath\$strCurrentAppDownloadFile" -o"$strPortableAppsPath\$strCurrentAppID" * -aoa -y`
							
							CreateDirectory "$strPortableAppsPath\$strCurrentAppID"
							RMDir /r "$strPortableAppsPath\$strCurrentAppID\App"
							RMDir /r "$strPortableAppsPath\$strCurrentAppID\Other"
							
							nsExec::Exec $strPAcInstallerExecString
							SetDetailsPrint none
							Pop $0
							
							RMDir /r "$strPortableAppsPath\$strCurrentAppID\$$PLUGINSDIR"
							
							WriteINIStr "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\appinfo.ini" "PortableApps.comInstaller" "InstallIntegrityCheck" "true"
							WriteINIStr "$strPortableAppsPath\$strCurrentAppID\App\AppInfo\pac_installer_log.ini" "PortableApps.comInstaller" "Info2" "This file was generated by the PortableApps.com Installer wizard and modified by the official PortableApps.com Installer TM Rare Ideas, LLC as the app was installed."
							
							StrCpy $2 'PortableApps.comPlatformWindowMessageToRefresh$strPortableAppsPath\PortableApps.com\PortableAppsPlatform.exe'
							System::Call "user32::RegisterWindowMessage(t r2) i .r3"
							SetDetailsPrint none
							SendMessage 65535 $3 0 0 /TIMEOUT=1
						${Else}
							StrCpy $strPAcInstallerExecString `"$strDownloadToLocalPath\$strCurrentAppDownloadFile" /DESTINATION="$strPortableAppsPath\" /AUTOCLOSE=true /HIDEINSTALLER=true /SILENT=true /SILENT32BITMODE=$strInstall32BitInDualMode`
						
							;Install primary version
							SetDetailsPrint none
							ExecWait $strPAcInstallerExecString
							
							;Check for additional copies of the app (2 to 10)
							${If} ${FileExists} "$strPortableAppsPath\$strCurrentAppID_Copy_2"
								StrCpy $0 2
								${While} $0 < 11
									${If} ${FileExists} "$strPortableAppsPath\$strCurrentAppID_Copy_$0"
										ExecWait "$strPAcInstallerExecString /COPYNUMBER=$0"
									${EndIf}
									IntOp $0 $0 + 1
								${EndWhile}
							${EndIf}
							
							;Check for additional copies of the app (11 to 100)
							${If} ${FileExists} "$strPortableAppsPath\$strCurrentAppID_Copy_11"
								StrCpy $0 11
								${While} $0 < 101
									${If} ${FileExists} "$strPortableAppsPath\$strCurrentAppID_Copy_$0"
										ExecWait "$strPAcInstallerExecString /COPYNUMBER=$0"
									${EndIf}
									IntOp $0 $0 + 1
								${EndWhile}
							${EndIf}
						${EndIf}
						SkipInstall:
					${Else}
						SetDetailsPrint none
						Exec `"$strDownloadToLocalPath\$strCurrentAppDownloadFile" /DESTINATION="$strPortableAppsPath\" /AUTOCLOSE=true /HIDEINSTALLER=true /SILENT=true`
						SetDetailsPrint none
					${EndIf}			
					
					;SetDetailsPrint listonly
					;DetailPrint `Install Complete`
					SetDetailsPrint none
				${Else}
					StrCpy $bolErrors true
				${EndIf}
				${If} $bolPlatformUpdateMode != "true"
					Delete "$strDownloadToLocalPath\$strCurrentAppDownloadFile"
				${EndIf}
				IntOp $intCurrentApp $intCurrentApp + 1 ;cycle through our app list
			${EndIf}
			IntOp $intCounter $intCounter - 1 ;cycle through our app list
		${Loop}
	${EndIf}
	SetDetailsPrint none
	RealProgress::SetProgress /NOUNLOAD 100
	SetDetailsPrint none
	${TBProgress_State} NoProgress
	SetDetailsPrint none
SectionEnd

!ifndef SC_CLOSE
!define SC_CLOSE 0xF060
!endif

Function CustomFinishText
	SetCtlColors $mui.FinishPage.Title 0x000000 0xFFFFFF
	SetCtlColors $mui.FinishPage.Text 0x000000 0xFFFFFF
	EnableWindow $mui.Button.Cancel 1
	System::Call 'USER32::GetSystemMenu(i $hwndparent,i0)i.s'
	System::Call 'USER32::EnableMenuItem(is,i${SC_CLOSE},i0)'
	GetDlgItem $0 $HWNDPARENT 3
	ShowWindow $0 0
	GetDlgItem $0 $HWNDPARENT 1
	ShowWindow $0 1
	GetDlgItem $0 $HWNDPARENT 2
	ShowWindow $0 0
	SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR:$strRealCaption"
	${If} $bolErrors == true
		SendMessage $mui.FinishPage.Title ${WM_SETTEXT} 0 "STR:$strTransFinishHeadingFail"
		SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$strTransFinishTextFail"
		
		${If} $strLocaleDirection == 'RTL'
			${If} $strWindowsVersionSimple == '05'
			${OrIf} $strWindowsVersionSimple == '06'
			${OrIf} $strWindowsVersionSimple == '07'
				${WordReplace} $strFullErrorMessageAtEnd "(" "" "+" $strFullErrorMessageAtEnd
				${WordReplace} $strFullErrorMessageAtEnd ")" "" "+" $strFullErrorMessageAtEnd
			${Else}
				${WordReplace} $strFullErrorMessageAtEnd "(" "[" "+" $strFullErrorMessageAtEnd
				${WordReplace} $strFullErrorMessageAtEnd ")" "]" "+" $strFullErrorMessageAtEnd
			${EndIf}
		${EndIf}
		
		MessageBox MB_OK|MB_ICONEXCLAMATION $strFullErrorMessageAtEnd
	${Else}
		${If} $intAppsToProcess > 0
			${If} $bolPlatformUpdateMode == true
				Abort
			${Else}
				${If} $bolUpdaterHasRun == true
				${AndIf} $bolPlatformUpdateMode != "true"
					${If} $bolUpdateMode == true
						SendMessage $mui.FinishPage.Title ${WM_SETTEXT} 0 "STR:$strTransFinishHeadingUpdate"
						SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$strTransFinishTextUpdate"
					${Else}
						SendMessage $mui.FinishPage.Title ${WM_SETTEXT} 0 "STR:$strTransFinishHeadingNew"
						SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$strTransFinishTextNew"
					${EndIf}
				${EndIf} ;Otherwise it was cancelled
			${EndIf}
		${Else}
			SendMessage $mui.FinishPage.Title ${WM_SETTEXT} 0 "STR:$strTransFinishHeadingNoSelection"
			${If} $bolUpdateMode == true
				SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$strTransFinishTextNoSelectionUpdater"
			${Else}
				SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$strTransFinishTextNoSelectionStore"
			${EndIf}
		${EndIf}
	${EndIf}
    SendMessage $mui.FinishPage.Title ${WM_SETFONT} $fntPlatformTitle 1
	SendMessage $mui.FinishPage.Text ${WM_SETFONT} $fntPlatformFinish 1
FunctionEnd

Function .onGUIEnd
	RealProgress::Unload
FunctionEnd