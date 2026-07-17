unit OneMinAiPlugin.Main;

interface

uses
  {$IFNDEF EXE}
  ToolsAPI, ToolsAPI.AI,
  {$ENDIF}
  System.Win.Registry, Winapi.Windows, System.SysUtils, System.Classes,
  OneMinAiPlugin.Consts,
  OneMinAiPlugin.Controller,
  OneMinAiPlugin.Setting;

type
  {$IFDEF EXE}
  TAIFeature = (afChat, afImageGeneration, afModeration, afInstruction, afListModels, afTextToSpeech, afSpeechToText);
  TAIFeatures = set of TAIFeature;
  {$ENDIF}


  TOneMinAiPlugin = class(TOneMinAiRestClient {$IFNDEF EXE}, IOTAAIPlugin {$ENDIF})
  private
    procedure LoadSetting;
    {IOTAAIPlugin}
    function GetName: string;
    function GetFeatures: TAIFeatures;
    function GetEnabled: Boolean;
  public
    {IOTAAIPlugin}
    function Chat(const AQuestion: string): TGUID;
    function LoadModels: TGUID;
    function Instruction(const AInput: string; const AInstruction: string): TGUID;
    function Moderation(const AInput: string): TGUID;
    function GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;
    function GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;
    function GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;
  {$IFNDEF EXE}
    function GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;
  {$ENDIF}
    procedure Cancel;

    property AvailableFeatures: TAIFeatures read GetFeatures;
    property Enabled: Boolean read GetEnabled;
    property Name: string read GetName;
  end;

var
  PluginIndex: Integer = -1;
  OneMinAiPlugin: TOneMinAiPlugin;

{$IFNDEF EXE}
procedure Register;
{$ENDIF}

implementation

{$IFNDEF EXE}
procedure Register;
begin
  if AIEngineService <> nil then
  begin
    OneMinAiPlugin := TOneMinAiPlugin.Create;
    PluginIndex := AIEngineService.RegisterPlugin(OneMinAiPlugin);
  end;
end;
{$ENDIF}

{ TOneMinAiPlugin }

procedure TOneMinAiPlugin.Cancel;
begin
  DoCancel;
end;

function TOneMinAiPlugin.Chat(const AQuestion: string): TGUID;
begin
  LoadSetting;
  Result := TGUID.NewGuid;
  DoChat(AQuestion, Result);
end;

function TOneMinAiPlugin.GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;
begin
//Not used.
end;

function TOneMinAiPlugin.GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;
begin
//Not used.
end;

function TOneMinAiPlugin.GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;
begin
//Not used.
end;

function TOneMinAiPlugin.GetEnabled: Boolean;
var
  LReg: TRegistry;
begin
  Result := False;
  LReg := TRegistry.Create;
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if LReg.OpenKey(TFrame_Setting.GetRegKey, False) then
    begin
      if LReg.ValueExists(cOneMinAiAI_RegKey_Enabled) then
        Result := LReg.ReadBool(cOneMinAiAI_RegKey_Enabled);
      LReg.CloseKey;
    end;
  finally
    LReg.Free;
  end;
end;

function TOneMinAiPlugin.GetFeatures: TAIFeatures;
begin
  Result := [afChat, afInstruction];
end;

function TOneMinAiPlugin.GetName: string;
begin
  Result := cOneMinAiAI_name;
end;

{$IFNDEF EXE}
function TOneMinAiPlugin.GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;
begin
  Result := TFrame_Setting.Create(AOwner) as IOTAAIPluginSetting;
end;
{$ENDIF}

function TOneMinAiPlugin.Instruction(const AInput: string; const AInstruction: string): TGUID;
begin
  LoadSetting;
  Result := TGUID.NewGuid;
  DoChat(AInstruction + ' ' + AInput, Result);
end;

function TOneMinAiPlugin.LoadModels: TGUID;
begin
//Not used.
end;

procedure TOneMinAiPlugin.LoadSetting;
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if LReg.OpenKey(cOneMinAiAI_RegKey, False) then
    begin
      if LReg.ValueExists(cOneMinAiAI_RegKey_BaseURL) then
        FBaseURL := LReg.ReadString(cOneMinAiAI_RegKey_BaseURL);
      if LReg.ValueExists(cOneMinAiAI_RegKey_Model) then
        FModel := LReg.ReadString(cOneMinAiAI_RegKey_Model);
      if LReg.ValueExists(cOneMinAiAI_RegKey_ApiKey) then
        FApiKey := LReg.ReadString(cOneMinAiAI_RegKey_ApiKey);
      if LReg.ValueExists(cOneMinAiAI_RegKey_Timeout) then
        FTimeOut := LReg.ReadInteger(cOneMinAiAI_RegKey_Timeout);
      LReg.CloseKey;
    end;
  finally
    LReg.Free;
  end;
end;

function TOneMinAiPlugin.Moderation(const AInput: string): TGUID;
begin
//Not used.
end;

initialization

finalization
  {$IFNDEF EXE}
  if (AIEngineService <> nil) and (PluginIndex <> -1) then
    AIEngineService.UnregisterPlugin(PluginIndex);
  {$ENDIF}

  OneMinAIPlugin := nil;
end.
(************* Trouver des bogues ***************
Endpoint : chat-with-ai
Invalid prompt object
Calling message: Trouver les bogues dans le code suivant
unit
OneMinAiPlugin.Main;

interface

uses
  {$IFNDEF EXE}
  ToolsAPI, ToolsAPI.AI,
  {$ENDIF}
  System.Win.Registry, Winapi.Windows, System.SysUtils, System.Classes,
  OneMinAiPlugin.Consts,

OneMinAiPlugin.Controller,
  OneMinAiPlugin.Setting;

type
  {$IFDEF EXE}
  TAIFeature = (afChat, afImageGeneration, afModeration, afInstruction, afListModels, afTextToSpeech, afSpeechToText);

TAIFeatures = set of TAIFeature;
  {$ENDIF}


  TOneMinAiPlugin = class(TOneMinAiRestClient {$IFNDEF EXE}, IOTAAIPlugin {$ENDIF})
  private
    procedure LoadSetting;
    {IOTAAIPlugin}

function GetName: string;
    function GetFeatures: TAIFeatures;
    function GetEnabled: Boolean;
  public
    {IOTAAIPlugin}
    function Chat(const AQuestion: string): TGUID;
    function
LoadModels: TGUID;
    function Instruction(const AInput: string; const AInstruction: string): TGUID;
    function Moderation(const AInput: string): TGUID;
    function GenerateImage(const APrompt:
string; const ASize: string; const AFormat: string): TGUID;
    function GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;
    function GenerateTextFromAudioFile(const
AAudioFilePath: string): TGUID;
  {$IFNDEF EXE}
    function GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;
  {$ENDIF}
    procedure Cancel;

    property AvailableFeatures:
TAIFeatures read GetFeatures;
    property Enabled: Boolean read GetEnabled;
    property Name: string read GetName;
  end;

var
  PluginIndex: Integer = -1;
  OneMinAiPlugin:
TOneMinAiPlugin;

{$IFNDEF EXE}
procedure Register;
{$ENDIF}

implementation

{$IFNDEF EXE}
procedure Register;
begin
  if AIEngineService <> nil then
  begin
    OneMinAiPlugin :=
TOneMinAiPlugin.Create;
    PluginIndex := AIEngineService.RegisterPlugin(OneMinAiPlugin);
  end;
end;
{$ENDIF}

{ TOneMinAiPlugin }

procedure TOneMinAiPlugin.Cancel;
begin

DoCancel;
end;

function TOneMinAiPlugin.Chat(const AQuestion: string): TGUID;
begin
  LoadSetting;
  Result := TGUID.NewGuid;
  DoChat(AQuestion, Result);
end;

function
TOneMinAiPlugin.GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;
begin
//Not used.
end;

function TOneMinAiPlugin.GenerateSpeechFromText(const AText:
string; const AVoice: string): TGUID;
begin
//Not used.
end;

function TOneMinAiPlugin.GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;
begin
//Not used.
end;

function
TOneMinAiPlugin.GetEnabled: Boolean;
var
  LReg: TRegistry;
begin
  Result := False;
  LReg := TRegistry.Create;
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if
LReg.OpenKey(TFrame_Setting.GetRegKey, False) then
    begin
      if LReg.ValueExists(cOneMinAiAI_RegKey_Enabled) then
        Result := LReg.ReadBool(cOneMinAiAI_RegKey_Enabled);

LReg.CloseKey;
    end;
  finally
    LReg.Free;
  end;
end;

function TOneMinAiPlugin.GetFeatures: TAIFeatures;
begin
  Result := [afChat, afInstruction];
end;

function
TOneMinAiPlugin.GetName: string;
begin
  Result := cOneMinAiAI_name;
end;

{$IFNDEF EXE}
function TOneMinAiPlugin.GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;
begin
  Result :=
TFrame_Setting.Create(AOwner) as IOTAAIPluginSetting;
end;
{$ENDIF}

function TOneMinAiPlugin.Instruction(const AInput: string; const AInstruction: string): TGUID;
begin
  LoadSetting;
  Result
:= TGUID.NewGuid;
  DoChat(AInstruction + ' ' + AInput, Result);
end;

function TOneMinAiPlugin.LoadModels: TGUID;
begin
//Not used.
end;

procedure TOneMinAiPlugin.LoadSetting;
var
  LReg:
TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if LReg.OpenKey(cOneMinAiAI_RegKey, False) then
    begin
      if
LReg.ValueExists(cOneMinAiAI_RegKey_BaseURL) then
        FBaseURL := LReg.ReadString(cOneMinAiAI_RegKey_BaseURL);
      if LReg.ValueExists(cOneMinAiAI_RegKey_Model) then
        FModel :=
LReg.ReadString(cOneMinAiAI_RegKey_Model);
      if LReg.ValueExists(cOneMinAiAI_RegKey_ApiKey) then
        FApiKey := LReg.ReadString(cOneMinAiAI_RegKey_ApiKey);
      if
LReg.ValueExists(cOneMinAiAI_RegKey_Timeout) then
        FTimeOut := LReg.ReadInteger(cOneMinAiAI_RegKey_Timeout);
      LReg.CloseKey;
    end;
  finally
    LReg.Free;

end;
end;

function TOneMinAiPlugin.Moderation(const AInput: string): TGUID;
begin
//Not used.
end;

initialization

finalization
  {$IFNDEF EXE}
  if (AIEngineService <> nil) and
(PluginIndex <> -1) then
    AIEngineService.UnregisterPlugin(PluginIndex);
  {$ENDIF}

  OneMinAIPlugin := nil;
end.
