; setup.iss — улучшенный Inno Setup для Flutter (Windows, русский язык)
; НЕ ЗАБУДЬ ОБНОВИТЬ ВЕРСИЮ ПРИ СБОРКЕ!
#define MyAppName "TwoSpace"
#define MyAppExeName "two_space_app.exe"
#ifndef MyAppVersion
#define MyAppVersion "1.0.6"
#endif
#ifndef MyBuildDir
#define MyBuildDir "build\windows\x64\runner\Release"
#endif
#ifndef MyOutputSuffix
#define MyOutputSuffix ""
#endif
#define MyAppPublisher "Synapse Corp"
#define MyAppURL "https://twospace.ru"

[Setup]
AppId={#MyAppName}
AppName={#MyAppName}
AppVerName={#MyAppName} {#MyAppVersion}
AppVersion={#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
OutputDir=.
OutputBaseFilename={#MyAppName}_setup{#MyOutputSuffix}_v{#MyAppVersion}
WindowVisible=yes
WizardStyle=modern
CloseApplications=yes
CloseApplicationsFilter={#MyAppExeName}
RestartApplications=no
UninstallDisplayIcon={app}\{#MyAppExeName}
; --- Язык интерфейса ---
ShowLanguageDialog=no
; ------------------------

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "{#MyBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifdef MyVcRedistPath
Source: "{#MyVcRedistPath}"; DestDir: "{tmp}"; Flags: deleteafterinstall
#endif

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; GroupDescription: "Дополнительные ярлыки:"; Flags: unchecked
Name: "quicklaunchicon"; Description: "Добавить ярлык в папку быстрого запуска"; GroupDescription: "Дополнительные ярлыки:"; Flags: unchecked; OnlyBelowVersion: 6.1
Name: "pinstartmenu"; Description: "Закрепить в меню «Пуск»"; GroupDescription: "Интеграция с Windows:"; Flags: unchecked; MinVersion: 6.2

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
#ifdef MyVcRedistPath
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /passive /norestart"; StatusMsg: "Установка Microsoft Visual C++ Runtime..."; Flags: waituntilterminated skipifsilent
#endif
Filename: "{app}\{#MyAppExeName}"; Description: "Запустить {#MyAppName}"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function IsAppRunning(const FileName: string): Boolean;
var
  FSWbemLocator: Variant;
  FWMIService: Variant;
  FWbemObjectSet: Variant;
begin
  Result := False;
  try
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2', '', '');
    FWbemObjectSet := FWMIService.ExecQuery(Format('SELECT * FROM CIM_Process WHERE Name="%s"', [FileName]));
    if not VarIsNull(FWbemObjectSet) and (FWbemObjectSet.Count > 0) then
      Result := True;
  except
    // Игнорируем ошибки (например, на старых Windows без WMI)
  end;
end;

function InitializeSetup(): Boolean;
begin
  // Завершить процесс, если он уже запущен
  if IsAppRunning(ExpandConstant('{#MyAppExeName}')) then
  begin
    MsgBox(ExpandConstant('{#MyAppName} сейчас запущен. Пожалуйста, закройте приложение и нажмите "Повторить".'), mbError, MB_OK);
    Result := False;
  end
  else
    Result := True;
end;
