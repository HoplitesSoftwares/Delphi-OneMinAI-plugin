unit OneMinAiPlugin.Models;

interface

uses
  OneMinAiPlugin.Consts, OneMinAiPlugin.JsonHelper, REST.Json.Types, System.JSON;

{$M+}

type
  { --- 1min.ai Specific Internal Objects --- }

  TConversationObject = class
  private
    [JSONName('uuid')]
    FId: string;
    [JSONName('title')]
    FTitle: string;
    [JSONName('status')]
    FStatus: string;
    [JSONName('createdAt')]
    FCreatedAt: string;
  published
    property Id: string read FId write FId;
    property Title: string read FTitle write FTitle;
    property Status: string read FStatus write FStatus;
    property CreatedAt: string read FCreatedAt write FCreatedAt;
  end;

  TConversationResponse = class
  private
    [JSONName('conversation')]
    FConversation: TConversationObject;
  published
    property Conversation: TConversationObject read FConversation write FConversation;
  end;

{ --- Web Search Settings --- }
  TWebSearchSettings = class
  private
    [JSONName('webSearch')]
    FWebSearch: Boolean;
    [JSONName('numOfSite')]
    FNumOfSite: Integer;
    [JSONName('maxWord')]
    FMaxWord: Integer;
  public
    constructor Create;
  published
    property WebSearch: Boolean read FWebSearch write FWebSearch;
    property NumOfSite: Integer read FNumOfSite write FNumOfSite;
    property MaxWord: Integer read FMaxWord write FMaxWord;
  end;

  { --- History Settings --- }
  THistorySettings = class
  private
    [JSONName('isMixed')]
    FIsMixed: Boolean;
    [JSONName('historyMessageLimit')]
    FHistoryMessageLimit: Integer;
  public
    constructor Create;
  published
    property IsMixed: Boolean read FIsMixed write FIsMixed;
    property HistoryMessageLimit: Integer read FHistoryMessageLimit write FHistoryMessageLimit;
  end;

  { --- Global Settings Sub-Object --- }
  TSettingsObj = class
  private
    [JSONName('webSearchSettings')]
    FWebSearchSettings: TWebSearchSettings;
    [JSONName('historySettings')]
    FHistorySettings: THistorySettings;
    [JSONName('withMemories')]
    FWithMemories: Boolean;
    function GetWebSearchSettings: TWebSearchSettings;
    function GetHistorySettings: THistorySettings;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property WebSearchSettings: TWebSearchSettings read GetWebSearchSettings;
    property HistorySettings: THistorySettings read GetHistorySettings;
    property WithMemories: Boolean read FWithMemories write FWithMemories;
  end;

  { --- Attachments Object --- }
  { Maps string[][] arrays using Delphi multi-dimensional dynamic arrays }
  T2DStringArray = TArray<TArray<string>>;

  TAttachmentsObj = class
  private
    [JSONName('images')]
    FImages: T2DStringArray;
    [JSONName('files')]
    FFiles: T2DStringArray;
  public
    destructor Destroy; override;
  published
    property Images: T2DStringArray read FImages write FImages;
    property Files: T2DStringArray read FFiles write FFiles;
  end;

  TPromptObject = class
  private
    [JSONName('prompt')]
    FPrompt: string;
    [JSONName('conversationId')]
    FConversationId: string;
    [JSONName('settings')]
    FSettings: TSettingsObj;
    [JSONName('attachments')]
    FAttachments: TAttachmentsObj;
    function GetSettings: TSettingsObj;
    function GetAttachments: TAttachmentsObj;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Prompt: string read FPrompt write FPrompt;
    property ConversationId: string read FConversationId write FConversationId;
    property Settings: TSettingsObj read GetSettings;
    property Attachments: TAttachmentsObj read GetAttachments;
  end;

  { --- Refactored Request Object --- }

  TRequestObj = class(TJsonReflectionBase)
  private
    [JSONName('type')]
    FType: string;
    [JSONName('model')]
    FModel: string;
    [JSONName('promptObject')]
    FPromptObject: TPromptObject;
    [JSONName('title')]
    FTitle: string;
    function GetPromptObject: TPromptObject;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property &Type: string read FType write FType;
    property Model: string read FModel write FModel;
    property PromptObject: TPromptObject read GetPromptObject;
    property Title: string read FTitle write FTitle;
  end;

  { --- Feature Result Modeling --- }

  TAIResultObject = TArray<string>;

  TAIRecordDetail = class(TJsonReflectionBase)
  private
    [JSONName('promptObject')]
    FPromptObject: TPromptObject;
    [JSONName('resultObject')]
    FResultObject: TAIResultObject;
  public
    destructor Destroy; override;
  published
    property PromptObject: TPromptObject read FPromptObject write FPromptObject;
    property ResultObject: TAIResultObject read FResultObject write FResultObject;
  end;

  { --- Record Envelope --- }

  TAIRecord = class(TJsonReflectionBase)
  private
    [JSONName('uuid')]
    FId: string;
    [JSONName('status')]
    FStatus: string;
    [JSONName('aiRecordDetail')]
    FAiRecordDetail: TAIRecordDetail;
  public
    destructor Destroy; override;
  published
    property Id: string read FId write FId;
    property Status: string read FStatus write FStatus;
    property AiRecordDetail: TAIRecordDetail read FAiRecordDetail write FAiRecordDetail;
  end;

  TAIResponseObj = class(TJsonReflectionBase)
  private
    [JSONName('aiRecord')]
    FAiRecord: TAIRecord;
  public
    destructor Destroy; override;
  published
    property AiRecord: TAIRecord read FAiRecord write FAiRecord;
  end;

  { --- Error Handling --- }

  TErrorObj = class(TJsonReflectionBase)
  private
    [JSONName('message')]
    FMessage: string;
  published
    property Message: string read FMessage write FMessage;
  end;

implementation


{ TWebSearchSettings }
constructor TWebSearchSettings.Create;
begin
  inherited;
  FWebSearch := False;
  FNumOfSite := 3;
  FMaxWord := 1000;
end;

{ THistorySettings }
constructor THistorySettings.Create;
begin
  inherited;
  FIsMixed := False;
  FHistoryMessageLimit := 10;
end;

{ TSettingsObj }
constructor TSettingsObj.Create;
begin
  inherited;
  FWithMemories := False;
  FWebSearchSettings := TWebSearchSettings.Create;
  FHistorySettings := THistorySettings.Create;
end;

destructor TSettingsObj.Destroy;
begin
  FWebSearchSettings.Free;
  FHistorySettings.Free;
  inherited;
end;

function TSettingsObj.GetHistorySettings: THistorySettings;
begin
  if FHistorySettings = nil then
    FHistorySettings := THistorySettings.Create;
  Result := FHistorySettings;
end;

function TSettingsObj.GetWebSearchSettings: TWebSearchSettings;
begin
  if FWebSearchSettings = nil then
    FWebSearchSettings := TWebSearchSettings.Create;
  Result := FWebSearchSettings;
end;

{ TAttachmentsObj }
destructor TAttachmentsObj.Destroy;
begin
  SetLength(FImages, 0);
  SetLength(FFiles, 0);
  inherited;
end;

{ TPromptObject }

constructor TPromptObject.Create;
begin
  inherited;
  FPrompt := '';
  FConversationId := '';
  Fsettings := TSettingsObj.Create;
  Fattachments := TAttachmentsObj.Create;
  // Sub-objects will be lazily instantiated via Getters to prevent JSON pollution if left unused
end;

destructor TPromptObject.Destroy;
begin
  FSettings.Free;
  FAttachments.Free;
  inherited;
end;

function TPromptObject.GetSettings: TSettingsObj;
begin
  if FSettings = nil then
    FSettings := TSettingsObj.Create;
  Result := FSettings;
end;

function TPromptObject.GetAttachments: TAttachmentsObj;
begin
  if FAttachments = nil then
    FAttachments := TAttachmentsObj.Create;
  Result := FAttachments;
end;


{ TRequestObj }
constructor TRequestObj.Create;
begin
  inherited;
  FType := cOneMinAiAI_def_Type;
  FTitle := cOneMinAiAI_LTitle;
  FPromptObject := TPromptObject.Create;
end;

destructor TRequestObj.Destroy;
begin
  FPromptObject.Free;
  inherited;
end;

function TRequestObj.GetPromptObject: TPromptObject;
begin
  if FPromptObject = nil then
    FPromptObject := TPromptObject.Create;
  Result := FPromptObject;
end;

{ TAIRecordDetail }
destructor TAIRecordDetail.Destroy;
var
  I: Integer;
begin
  Setlength(FResultObject, 0);
  FPromptObject.Free;
  inherited;
end;

{ TAIRecord }
destructor TAIRecord.Destroy;
begin
  FAiRecordDetail.Free;
  inherited;
end;

{ TAIResponseObj }
destructor TAIResponseObj.Destroy;
begin
  FAiRecord.Free;
  inherited;
end;

end.
