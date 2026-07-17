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
Parameters:
{"type":"UNIFY_CHAT_WITH_AI","model":"gpt-4o-mini","promptObject":{"prompt":"Trouver les bogues dans le code suivant\r\nunit OneMinAiPlugin.Main;\r\n\r\ninterface\r\n\r\nuses\r\n  {$IFNDEF EXE}\r\n
ToolsAPI, ToolsAPI.AI,\r\n  {$ENDIF}\r\n  System.Win.Registry, Winapi.Windows, System.SysUtils, System.Classes,\r\n  OneMinAiPlugin.Consts,\r\n  OneMinAiPlugin.Controller,\r\n
OneMinAiPlugin.Setting;\r\n\r\ntype\r\n  {$IFDEF EXE}\r\n  TAIFeature = (afChat, afImageGeneration, afModeration, afInstruction, afListModels, afTextToSpeech, afSpeechToText);\r\n  TAIFeatures = set
of TAIFeature;\r\n  {$ENDIF}\r\n\r\n\r\n  TOneMinAiPlugin = class(TOneMinAiRestClient {$IFNDEF EXE}, IOTAAIPlugin {$ENDIF})\r\n  private\r\n    procedure LoadSetting;\r\n    {IOTAAIPlugin}\r\n
function GetName: string;\r\n    function GetFeatures: TAIFeatures;\r\n    function GetEnabled: Boolean;\r\n  public\r\n    {IOTAAIPlugin}\r\n    function Chat(const AQuestion: string): TGUID;\r\n
function LoadModels: TGUID;\r\n    function Instruction(const AInput: string; const AInstruction: string): TGUID;\r\n    function Moderation(const AInput: string): TGUID;\r\n    function
GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;\r\n    function GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;\r\n    function
GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;\r\n  {$IFNDEF EXE}\r\n    function GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;\r\n  {$ENDIF}\r\n    procedure
Cancel;\r\n\r\n    property AvailableFeatures: TAIFeatures read GetFeatures;\r\n    property Enabled: Boolean read GetEnabled;\r\n    property Name: string read GetName;\r\n  end;\r\n\r\nvar\r\n
PluginIndex: Integer = -1;\r\n  OneMinAiPlugin: TOneMinAiPlugin;\r\n\r\n{$IFNDEF EXE}\r\nprocedure Register;\r\n{$ENDIF}\r\n\r\nimplementation\r\n\r\n{$IFNDEF EXE}\r\nprocedure Register;\r\nbegin\r\n
if AIEngineService <> nil then\r\n  begin\r\n    OneMinAiPlugin := TOneMinAiPlugin.Create;\r\n    PluginIndex := AIEngineService.RegisterPlugin(OneMinAiPlugin);\r\n  end;\r\nend;\r\n{$ENDIF}\r\n\r\n{
TOneMinAiPlugin }\r\n\r\nprocedure TOneMinAiPlugin.Cancel;\r\nbegin\r\n  DoCancel;\r\nend;\r\n\r\nfunction TOneMinAiPlugin.Chat(const AQuestion: string): TGUID;\r\nbegin\r\n  LoadSetting;\r\n  Result
:= TGUID.NewGuid;\r\n  DoChat(AQuestion, Result);\r\nend;\r\n\r\nfunction TOneMinAiPlugin.GenerateImage(const APrompt: string; const ASize: string; const AFormat: string): TGUID;\r\nbegin\r\n//Not
used.\r\nend;\r\n\r\nfunction TOneMinAiPlugin.GenerateSpeechFromText(const AText: string; const AVoice: string): TGUID;\r\nbegin\r\n//Not used.\r\nend;\r\n\r\nfunction
TOneMinAiPlugin.GenerateTextFromAudioFile(const AAudioFilePath: string): TGUID;\r\nbegin\r\n//Not used.\r\nend;\r\n\r\nfunction TOneMinAiPlugin.GetEnabled: Boolean;\r\nvar\r\n  LReg:
TRegistry;\r\nbegin\r\n  Result := False;\r\n  LReg := TRegistry.Create;\r\n  try\r\n    LReg.RootKey := HKEY_CURRENT_USER;\r\n    if LReg.OpenKey(TFrame_Setting.GetRegKey, False) then\r\n
begin\r\n      if LReg.ValueExists(cOneMinAiAI_RegKey_Enabled) then\r\n        Result := LReg.ReadBool(cOneMinAiAI_RegKey_Enabled);\r\n      LReg.CloseKey;\r\n    end;\r\n  finally\r\n
LReg.Free;\r\n  end;\r\nend;\r\n\r\nfunction TOneMinAiPlugin.GetFeatures: TAIFeatures;\r\nbegin\r\n  Result := [afChat, afInstruction];\r\nend;\r\n\r\nfunction TOneMinAiPlugin.GetName:
string;\r\nbegin\r\n  Result := cOneMinAiAI_name;\r\nend;\r\n\r\n{$IFNDEF EXE}\r\nfunction TOneMinAiPlugin.GetSettingFrame(AOwner: TComponent): IOTAAIPluginSetting;\r\nbegin\r\n  Result :=
TFrame_Setting.Create(AOwner) as IOTAAIPluginSetting;\r\nend;\r\n{$ENDIF}\r\n\r\nfunction TOneMinAiPlugin.Instruction(const AInput: string; const AInstruction: string): TGUID;\r\nbegin\r\n
LoadSetting;\r\n  Result := TGUID.NewGuid;\r\n  DoChat(AInstruction + ' ' + AInput, Result);\r\nend;\r\n\r\nfunction TOneMinAiPlugin.LoadModels: TGUID;\r\nbegin\r\n//Not used.\r\nend;\r\n\r\nprocedure
TOneMinAiPlugin.LoadSetting;\r\nvar\r\n  LReg: TRegistry;\r\nbegin\r\n  LReg := TRegistry.Create;\r\n  try\r\n    LReg.RootKey := HKEY_CURRENT_USER;\r\n    if LReg.OpenKey(cOneMinAiAI_RegKey, False)
then\r\n    begin\r\n      if LReg.ValueExists(cOneMinAiAI_RegKey_BaseURL) then\r\n        FBaseURL := LReg.ReadString(cOneMinAiAI_RegKey_BaseURL);\r\n      if
LReg.ValueExists(cOneMinAiAI_RegKey_Model) then\r\n        FModel := LReg.ReadString(cOneMinAiAI_RegKey_Model);\r\n      if LReg.ValueExists(cOneMinAiAI_RegKey_ApiKey) then\r\n        FApiKey :=
LReg.ReadString(cOneMinAiAI_RegKey_ApiKey);\r\n      if LReg.ValueExists(cOneMinAiAI_RegKey_Timeout) then\r\n        FTimeOut := LReg.ReadInteger(cOneMinAiAI_RegKey_Timeout);\r\n
LReg.CloseKey;\r\n    end;\r\n  finally\r\n    LReg.Free;\r\n  end;\r\nend;\r\n\r\nfunction TOneMinAiPlugin.Moderation(const AInput: string): TGUID;\r\nbegin\r\n//Not
used.\r\nend;\r\n\r\ninitialization\r\n\r\nfinalization\r\n  {$IFNDEF EXE}\r\n  if (AIEngineService <> nil) and (PluginIndex <> -1) then\r\n    AIEngineService.UnregisterPlugin(PluginIndex);\r\n
{$ENDIF}\r\n\r\n  OneMinAIPlugin :=
nil;\r\nend.","conversationId":"","settings":{"webSearchSettings":{"webSearch":false,"numOfSite":3,"maxWord":1000},"historySettings":{"isMixed":false,"historyMessageLimit":10},"withMemories":false},"attachments":{"images":[],"files":[]}},"title":"Delphi1MinAIPlugin"}
*)
