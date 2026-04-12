; ---------------------------------------------------
; UNIChat Windows 安装器脚本
; ---------------------------------------------------

[Setup]
; 唯一标识符，你可以用 Inno Setup 自带的工具 (Tools -> Generate GUID) 重新生成一个替换掉这里的
AppId={{29E00414-E007-490E-B089-714A8741DA86}}
AppName=UNIChat
AppVersion=1.0.1
AppPublisher=Wejoinnwk
AppPublisherURL=https://unichat.wejoinnwk.com
; 默认安装到 Program Files 下的 UNIChat 文件夹
DefaultDirName={pf}\UNIChat
DisableProgramGroupPage=yes
; 安装包的输出目录（会生成在项目根目录的 Installer 文件夹下）
OutputDir=.\Installer
; 最终生成的 exe 安装包文件名
OutputBaseFilename=UNIChatV1.0_Setup
; 安装器的图标（复用 Flutter 的桌面图标）
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; 明确只允许在 64 位系统上安装
ArchitecturesAllowed=x64
; 明确指定以 64 位模式安装，这样 {autopf} 就会乖乖变成纯 Program Files 文件夹了
ArchitecturesInstallIn64BitMode=x64
[Languages]
; 配置中英双语支持
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
; 提供“创建桌面快捷方式”的复选框
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 1. 拷贝主程序
Source: "build\windows\x64\runner\Release\uni_chat.exe"; DestDir: "{app}"; Flags: ignoreversion
; 2. 拷贝 Release 目录下的所有依赖文件 (dll 和 data 文件夹)
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 3. 拷贝 C++ 运行库到临时目录 (安装完会自动删除)
Source: "VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
; 创建开始菜单和桌面快捷方式
Name: "{autoprograms}\UNIChat"; Filename: "{app}\uni_chat.exe"
Name: "{autodesktop}\UNIChat"; Filename: "{app}\uni_chat.exe"; Tasks: desktopicon

[Run]
; 1. 静默安装 C++ 运行库 (通过 Check 函数判断是否需要安装)
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; Check: VCRedistNeedsInstall; Flags: waituntilterminated
; 2. 安装完成后运行程序
Filename: "{app}\uni_chat.exe"; Description: "{cm:LaunchProgram,UNIChat}"; Flags: nowait postinstall skipifsilent

[Code]
// 检查系统是否已经安装了 Visual C++ 2015-2022 运行库
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  // 检查注册表中的 x64 运行库键值
  if RegQueryStringValue(HKEY_LOCAL_MACHINE,
     'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) then
  begin
    // 如果找到了，说明已经安装，无需再次安装
    Result := False;
  end
  else
  begin
    // 如果没找到，返回 True，触发 [Run] 里面的安装指令
    Result := True;
  end;
end;