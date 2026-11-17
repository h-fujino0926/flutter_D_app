; =============================================================
; 付箋タスク インストーラー（Inno Setup 6）
;
; 作り方：
;   1. flutter build windows --release --dart-define-from-file=env.json
;   2. Inno Setup Compiler でこのファイルを開いて「Compile」
;      （またはコマンド：ISCC.exe installer\fusen_app.iss）
;   3. build\installer\FusenTask-Setup.exe ができる
;
; 仮決定（F6）：コード署名はしない（初回起動時に SmartScreen の警告が出る）。自動更新なし。
; 管理者権限なしで「ユーザーごと」にインストールする（学校PCでも入れられるように）。
; =============================================================

#define MyAppName "付箋タスク"
#define MyAppVersion "0.1.0"
#define MyAppExeName "flutter_d_app.exe"

[Setup]
AppId={{2D2C9F98-68BD-47CE-B516-0AC4ED5F72DF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={localappdata}\Programs\FusenTask
DefaultGroupName={#MyAppName}
PrivilegesRequired=lowest
OutputDir=..\build\installer
OutputBaseFilename=FusenTask-Setup
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "デスクトップにアイコンを作成する"; GroupDescription: "追加のアイコン:"
Name: "startup"; Description: "Windows の起動時にアプリを起動する（ミニウィンドウを常駐させる）"; GroupDescription: "その他:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startup

[Registry]
; 招待URL（fusenapp://join?token=...）をこのアプリで開けるようにする
; ※ アプリ自身も起動時に同じ登録を行う（zip 版でも開けるように）
Root: HKCU; Subkey: "Software\Classes\fusenapp"; ValueType: string; ValueName: ""; ValueData: "URL:fusenapp"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\fusenapp"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\fusenapp\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{#MyAppName} を起動する"; Flags: nowait postinstall skipifsilent
