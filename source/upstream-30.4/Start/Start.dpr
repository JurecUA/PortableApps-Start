program Start;

uses
  Dialogs,
  System.SysUtils,
  Forms,
  Windows,
  ShellAPI,
  inifiles;

{$R *.res}

var
  strTemp: string;
  ptrFileInfo: pointer;
	lngFileInfoSize: Longint;
	dwdFileInfoLength: DWORD;
	ptrFileInfoLanguage : Pointer;
	ptrFileInfoData: Pointer;
	strFileInfoQuery: String;
	uintFileInfoDataLength: Uint;
  strPlatformPath: String;
  strPlatformProductName, strPlatformCompanyName: String;
  bolDoNotStart: boolean;
  iniPlatformSettings: TIniFile;
  strStartPath: String;
  strDriveToMap: String;
  strPathEnvVar: String;
  bolMapTheDrive: Boolean;
  guidTempFolder: TGUID;
begin
  Application.Title:='PortableApps.com Platform';
  bolDoNotStart:=false;
  strTemp:=GetEnvironmentVariable('TEMP');
  strStartPath:=ExtractFilePath(Application.ExeName);

  if (Win32MajorVersion = 5) and (Win32MinorVersion = 0) then
  begin
    Application.MessageBox(PCHAR('This version of the PortableApps.com Platform does not work on Windows 2000. Please download the 21.2.2 stable version.'),'PortableApps.com Platform',MB_ICONEXCLAMATION);
    bolDoNotStart:=true;
  end;


  if (Win32MajorVersion = 5) then
  // Windows XP/2003/ReactOS, add in UIAutomationCore.dll shim
  begin
    strPathEnvVar:=GetEnvironmentVariable('PATH');
    strPathEnvVar:=ExtractFilePath(Application.ExeName) + 'PortableApps\PortableApps.com\App\bin\WinXP;' + strPathEnvVar;
    if not SetEnvironmentVariable(PChar('PATH'),PChar(strPathEnvVar)) then
      Application.MessageBox(PCHAR('Unable to update PATH for Windows XP/2003/ReactOS compatibility. The PortableApps.com Platform may not start correctly.'),'PortableApps.com Platform',MB_ICONINFORMATION)
  end;

  // Setup (optional) and ensure the TEMP path exists
  if DirectoryExists(strStartPath+'TempForPortableApps') then
  begin
    if SetEnvironmentVariable(PChar('TEMP'),PChar(strStartPath+'TempForPortableApps')) then
    begin
      strTemp:=strStartPath+'TempForPortableApps';
      SetEnvironmentVariable(PChar('TMP'),PChar(strStartPath+'TempForPortableApps'));
    end
    else
      if Application.MessageBox(PCHAR('Unable to set custom TEMP path. Would you like to start the PortableApps.com Platform anyway?'),'PortableApps.com Platform',MB_ICONQUESTION Or MB_YESNO)=IDNO then
        bolDoNotStart:=True;
  end
  else
  begin
    if not DirectoryExists(strTemp) then
    begin
      Application.MessageBox(PCHAR('The TEMP directory on this computer ('+strTemp+') does not seem to exist. Most software requires a valid TEMP directory. Please ensure a valid TEMP directory exists and can be written to. You can create a folder TempForPortableApps next to Start.exe to use a custom one temporarily.'),'PortableApps.com Platform',MB_ICONEXCLAMATION);
      bolDoNotStart:=True;
    end;
  end;

  // Test the TEMP path for rights
  if not bolDoNotStart then
  begin
    CreateGUID(guidTempFolder);

    if DirectoryExists(strTemp+'\'+GUIDToString(guidTempFolder)) then
      RemoveDir(strTemp+'\'+GUIDToString(guidTempFolder));
    MkDir(strTemp+'\'+GUIDToString(guidTempFolder));

    if not DirectoryExists(strTemp+'\'+GUIDToString(guidTempFolder)) then
    begin
      Application.MessageBox(PCHAR('The TEMP directory ('+strTemp+') can not be written to, likely due to permissions. A valid TEMP directory is required for most software to properly function. Use the Permissions tab of Folder Properties and add the appropriate Read, Write, Modify and Execute rights.'),'PortableApps.com Platform',MB_ICONEXCLAMATION);
      bolDoNotStart:=True;
    end
    else
      RemoveDir(strTemp+'\'+GUIDToString(guidTempFolder));
  end;

  // Check for existence of the PA.c Platform
  if not bolDoNotStart then
  begin
    strPlatformPath:=ExtractFilePath(Application.ExeName)+'PortableApps\PortableApps.com\PortableAppsPlatform.exe';
    if not FileExists(strPlatformPath) then
    begin
      Application.MessageBox(PCHAR('Could not find the PortableApps.com Platform main EXE: '+strPlatformPath+'.'),'PortableApps.com Platform',MB_ICONEXCLAMATION);
      bolDoNotStart:=True;
    end
    else
    begin // Ensure a proper PA.c Platform EXE
      lngFileInfoSize:=GetFileVersionInfoSize(PChar(strPlatformPath), dwdFileInfoLength);
	  	if (lngFileInfoSize > 0) then
      begin
        GetMem(ptrFileInfo, lngFileInfoSize);
 	    	try
        // Check if the current app has a ProductName
   	    if GetFileVersionInfo(PChar(strPlatformPath), dwdFileInfoLength, lngFileInfoSize, ptrFileInfo) then
        begin
          strFileInfoQuery:='ProductName';
          if VerQueryValue(ptrFileInfo,'\VarFileInfo\Translation',ptrFileInfoLanguage, uintFileInfoDataLength) then
            strFileInfoQuery:=Format('\StringFileInfo\%0.4x%0.4x\%s'#0,[LoWord(LongInt(ptrFileInfoLanguage^)),
            HiWord(LongInt(ptrFileInfoLanguage^)), strFileInfoQuery]);
          if VerQueryValue(ptrFileInfo,PChar(strFileInfoQuery),ptrFileInfoData,uintFileInfoDataLength) then
            strPlatformProductName:=strPas(PChar(ptrFileInfoData));
          strFileInfoQuery:='CompanyName';
          if VerQueryValue(ptrFileInfo,'\VarFileInfo\Translation',ptrFileInfoLanguage, uintFileInfoDataLength) then
            strFileInfoQuery:=Format('\StringFileInfo\%0.4x%0.4x\%s'#0,[LoWord(LongInt(ptrFileInfoLanguage^)),
            HiWord(LongInt(ptrFileInfoLanguage^)), strFileInfoQuery]);
          if VerQueryValue(ptrFileInfo,PChar(strFileInfoQuery),ptrFileInfoData,uintFileInfoDataLength) then
            strPlatformCompanyName:=strPas(PChar(ptrFileInfoData));
        end;
        finally
          FreeMem(ptrFileInfo, lngFileInfoSize);
        end;
      end;

      if (strPlatformCompanyName<>'PortableApps.com') or (strPlatformProductName<>'PortableApps.com Platform') then
      begin
        Application.MessageBox(PCHAR('The PortableAppsPlatform.exe file is not a valid PortableApps.com release and can not be launched.'),'PortableApps.com Platform',MB_ICONEXCLAMATION);
        bolDoNotStart:=True;
      end;
    end;
  end;

  // Check if we should map a drive letter
  if not bolDoNotStart then
  begin
    // Check in running from a UNC path
    if (Length(ExtractFileDrive(Application.ExeName))>2) then
    begin
      // UNC path
      iniPlatformSettings:= TIniFile.Create(strStartPath+'PortableApps\PortableApps.com\Data\PortableAppsMenu.ini');
      try
        if ansiLowerCase(iniPlatformSettings.ReadString('Integration','MapDriveLetter','False')) = 'true' then
        begin
          MkDir(strStartPath + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder));
          if (not FileExists('P:\*.*')) or FileExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),'P:',[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder)) then
            strDriveToMap:='P:'
          else if (not FileExists('Z:\*.*')) or FileExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),'Z:',[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder)) then
            strDriveToMap:='Z:'
          else if (not FileExists('Y:\*.*')) or FileExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),'Y:',[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder)) then
            strDriveToMap:='Y:'
          else if (not FileExists('X:\*.*')) or FileExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),'X:',[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder)) then
            strDriveToMap:='X:'
          else
            strDriveToMap:='NONE';
          bolMapTheDrive:=(not DirectoryExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),strDriveToMap,[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder)));
          RemoveDir(strStartPath + 'PortableApps\PortableApps.com\Data\'+GUIDToString(guidTempFolder));
          if strDriveToMap<>'NONE' then
          begin
            if bolMapTheDrive then
            begin
              ShellExecute(0, nil, PChar('net'), PChar('use ' + strDriveToMap + ' ' + ExtractFileDrive(strStartPath)), nil, SW_HIDE);
              Application.MessageBox(PCHAR(ExtractFileDrive(strStartPath) + ' has been temporarily mapped to drive ' + strDriveToMap),'PortableApps.com Platform',MB_ICONINFORMATION);
            end;
            if FileExists(StringReplace(strStartPath,ExtractFileDrive(strStartPath),strDriveToMap,[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\PortableAppsPlatform.exe') then
            begin
              strStartPath:=StringReplace(strStartPath,ExtractFileDrive(strStartPath),strDriveToMap,[rfReplaceAll, rfIgnoreCase]);
              strPlatformPath:=StringReplace(strStartPath,ExtractFileDrive(strStartPath),strDriveToMap,[rfReplaceAll, rfIgnoreCase]) + 'PortableApps\PortableApps.com\PortableAppsPlatform.exe';
            end;
          end;
        end;
      finally
        FreeandNil(iniPlatformSettings);
      end;
    end;
  end;

  // Start the platform
  if not bolDoNotStart then
    ShellExecute(0, 'open', PChar(strPlatformPath), nil, PChar(strStartPath), SW_SHOWNORMAL);
end.
