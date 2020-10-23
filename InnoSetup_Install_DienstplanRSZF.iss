; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!


#define MyAppName "Dienstplan RSZF"
#define MyAppVersion "2.8.1"
#define MyAppPublisher "mwb"
#define MyAppExeName "DienstplanRSZF.exe"

;See https://msdn.microsoft.com/en-us/library/ee942965(v=vs.110).aspx#return_codes
#define InstalledFramework= "4.7.2"
#define InstalledFrameworkNo= 461808

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{433C0D77-050E-43DC-BFAE-258691AC3D1C}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName=   DienstplanRSZF
OutputDir=..\publish;OutputBaseFilename=DienstplanRSZF_Install_{#MyAppVersion}
OutputBaseFilename=DienstplanRSZF_Install
Compression=lzma
SolidCompression=yes
PrivilegesRequired=none
RestartIfNeededByRun=FalseCloseApplications=yes
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany=mwb
VersionInfoCopyright=mwb
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

;Include Download Needed Dot Net Framework#include <D:\Program Files (x86)\Inno Download Plugin\idp.iss>

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\bin\Release\DienstplanRSZF.exe"; DestDir: "{app}"; Flags: ignoreversion                                                       
Source: "..\bin\Release\Google.Apis.Auth.dll"; DestDir: "{app}"
Source: "..\bin\Release\Google.Apis.Auth.PlatformServices.dll"; DestDir: "{app}"
Source: "..\bin\Release\Google.Apis.Calendar.v3.dll"; DestDir: "{app}"
Source: "..\bin\Release\Google.Apis.Core.dll"; DestDir: "{app}"
Source: "..\bin\Release\Google.Apis.dll"; DestDir: "{app}"
Source: "..\bin\Release\Google.Apis.PlatformServices.dll"; DestDir: "{app}"
Source: "..\bin\Release\Newtonsoft.Json.dll"; DestDir: "{app}"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Dirs]
Name: "{userdocs}\RSZF\Setup"; Flags: uninsalwaysuninstall; Permissions: everyone-full
Name: "{userdocs}\RSZF\ExcelAusgabe"; Flags: uninsalwaysuninstall; Permissions: everyone-full

[InstallDelete]
Type: filesandordirs; Name: "Setup"

[CustomMessages]
IDP_DownloadFailed=Download of .NET Framework {#InstalledFramework} failed. .NET Framework {#InstalledFramework} is required to run {#MyAppName} .
IDP_RetryCancel=Click 'Retry' to try downloading the files again, or click 'Cancel' to terminate setup.
InstallingDotNetFramework=Installing .NET Framework {#InstalledFramework}. This might take a few minutes...
DotNetFrameworkFailedToLaunch=Failed to launch .NET Framework Installer with error "%1". Please fix the error then run this installer again.
DotNetFrameworkFailed1602=.NET Framework installation was cancelled. This installation can continue, but be aware that this application may not run unless the .NET Framework installation is completed successfully.
DotNetFrameworkFailed1603=A fatal error occurred while installing the .NET Framework. Please fix the error, then run the installer again.
DotNetFrameworkFailed5100=Your computer does not meet the requirements of the .NET Framework. Please consult the documentation.
DotNetFrameworkFailedOther=The .NET Framework installer exited with an unexpected status code "%1". Please review any other messages shown by the installer to determine whether the installation completed successfully, and abort this installation and fix the problem if it did not.

[Code]

var
  requiresRestart: boolean;

function NetFrameworkIsMissing(): Boolean;
var
  bSuccess: Boolean;
  regVersion: Cardinal;
begin
  Result := True;

  //461308 = 4.7.1
  //461808 = 4.7.2  Windows 10
  bSuccess := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', regVersion);
  if (True = bSuccess) and (regVersion >= {#InstalledFrameworkNo}) then begin
    Result := False;
  end;
end;

procedure InitializeWizard;
begin
  if NetFrameworkIsMissing() then
  begin
    idpAddFile('http://go.microsoft.com/fwlink/?LinkId=863262', ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
    idpDownloadAfter(wpReady);
  end;
end;

function InstallFramework(): String;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := CustomMessage('InstallingDotNetFramework');
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    if not Exec(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'), '/passive /norestart /showrmui /showfinalerror', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      Result := FmtMessage(CustomMessage('DotNetFrameworkFailedToLaunch'), [SysErrorMessage(resultCode)]);
    end
    else
    begin
      // See https://msdn.microsoft.com/en-us/library/ee942965(v=vs.110).aspx#return_codes
      case resultCode of
        0: begin
          // Successful
        end;
        1602 : begin
          MsgBox(CustomMessage('DotNetFrameworkFailed1602'), mbInformation, MB_OK);
        end;
        1603: begin
          Result := CustomMessage('DotNetFrameworkFailed1603');
        end;
        1641: begin
          requiresRestart := True;
        end;
        3010: begin
          requiresRestart := True;
        end;
        5100: begin
          Result := CustomMessage('DotNetFrameworkFailed5100');
        end;
        else begin
          MsgBox(FmtMessage(CustomMessage('DotNetFrameworkFailedOther'), [IntToStr(resultCode)]), mbError, MB_OK);
        end;
      end;
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
    
    DeleteFile(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  // 'NeedsRestart' only has an effect if we return a non-empty string, thus aborting the installation.
  // If the installers indicate that they want a restart, this should be done at the end of installation.
  // Therefore we set the global 'restartRequired' if a restart is needed, and return this from NeedRestart()

  if NetFrameworkIsMissing() then
  begin
    Result := InstallFramework();
  end;
end;

function NeedRestart(): Boolean;
begin
  Result := requiresRestart;
end;