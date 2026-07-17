unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading, OneMinAIPlugin.Consts,
  OneMinAIPlugin.Models, System.Win.Registry, REST.Client, REST.Types, REST.Json, System.JSON;

type
  TOneMinAiChatClient = class
  private
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRestResponse: TRESTResponse;
    FConversationId: string;
    FBaseURL: string;
    FModel: string;
    FApiKey: string;
    FTimeOut: Integer;
    procedure ApplyDefaultSettings;
    procedure LoadSettings;
    function EnsureConversation(const APrompt: string; out AError: string): Boolean;
    function BuildRequestBody(const APrompt: string): string;
    function ParseResponse(out AError: string): string;
    function TryParseError(const AContent: string; out AError: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Chat(const APrompt: string; out AError: string): string;
  end;

  TForm1minAI = class(TForm)
    BtnSubmit: TButton;
    MemoRequest: TMemo;
    MemoResponse: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSubmitClick(Sender: TObject);
  private
    FChatClient: TOneMinAiChatClient;
  end;

var
  Form1minAI: TForm1minAI;

implementation

{$R *.dfm}

uses
  System.SyncObjs;

{ TOneMinAiChatClient }

constructor TOneMinAiChatClient.Create;
begin
  inherited Create;
  FRestClient := TRESTClient.Create(nil);
  FRestResponse := TRESTResponse.Create(nil);
  FRestRequest := TRESTRequest.Create(nil);
  FRestRequest.Client := FRestClient;
  FRestRequest.Response := FRestResponse;
  FRestRequest.Method := rmPOST;
  FRestClient.ContentType := TRESTContentType.ctAPPLICATION_JSON;
  ApplyDefaultSettings;
end;

procedure TOneMinAiChatClient.ApplyDefaultSettings;
begin
  FBaseURL := cOneMinAiAI_def_BaseUrl;
  FModel := cOneMinAiAI_def_Model;
  FApiKey := '';
  FTimeOut := cOneMinAiAI_Def_Timeout;
  FConversationId := '';
end;

destructor TOneMinAiChatClient.Destroy;
begin
  FRestRequest.Free;
  FRestResponse.Free;
  FRestClient.Free;
  inherited;
end;

procedure TOneMinAiChatClient.LoadSettings;
var
  LReg: TRegistry;
begin
  ApplyDefaultSettings;
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

function TOneMinAiChatClient.Chat(const APrompt: string; out AError: string): string;
var
  LRequestObj: TRequestObj;
  dbg: string;
begin
  Result := '';
  AError := '';
  LoadSettings;
  if FApiKey.Trim.IsEmpty then
  begin
    AError := cOneMinAiAI_Msg_CheckAPI;
    Exit;
  end;
  if not EnsureConversation(APrompt, AError) then
    Exit;
  FRestRequest.Params.Clear;
  FRestRequest.Body.ClearBody;
  FRestClient.BaseURL := '';
  FRestRequest.Resource := FBaseURL;
  FRestRequest.ResourceSuffix := 'chat-with-ai';
  FRestRequest.Timeout := FTimeOut;
  FRestRequest.AddParameter('isStreaming', 'false', pkQUERY);
  FRestRequest.Params.AddHeader('API-KEY', FApiKey).Options := [poDoNotEncode];
  FRestRequest.Params.AddHeader('Authorization', 'Bearer ' + FApiKey).Options := [poDoNotEncode];
//  FRestRequest.Params.AddHeader('Accept', 'application/json').Options := [poDoNotEncode];
  LRequestObj := TRequestObj.Create;
  try
    LRequestObj.&Type := cOneMinAiAI_def_Type;
    LRequestObj.Model := FModel;
    LRequestObj.PromptObject.prompt := APrompt;
    LRequestObj.PromptObject.conversationId := FConversationId;

    dbg := TJson.ObjectToJsonString(LRequestObj, [joIgnoreDefault]);

    FRestRequest.AddBody(TJson.ObjectToJsonString(LRequestObj), ctAPPLICATION_JSON);
  finally
    LRequestObj.Free;
  end;

  try
    FRestRequest.Execute;
  except on E: Exception do
    begin
      AError := E.Message +#13+#10+ dbg;
      Exit;
    end;
  end;
  if not FRestResponse.Status.SuccessOK_200 then
  begin
    if TryParseError(FRestResponse.Content, AError) then
      Exit;
    AError := FRestResponse.StatusText;
    Exit;
  end;
  Result := ParseResponse(AError);
end;

function TOneMinAiChatClient.EnsureConversation(const APrompt: string; out AError: string): Boolean;
var
  LTempRequest: TRESTRequest;
  LTempResponse: TRESTResponse;
  LConv: TConversationResponse;
  LRequestObj: TRequestObj;
  LTitle: string;
const
  TitleMaxLength = 64;
begin
  Result := False;
  if not FConversationId.IsEmpty then
  begin
    Result := True;
    Exit;
  end;
  LTempRequest := TRESTRequest.Create(nil);
  LTempResponse := TRESTResponse.Create(nil);
  try
    LTempRequest.Client := FRestClient;
    LTempRequest.Response := LTempResponse;
    LTempRequest.Method := rmPOST;
    LTempRequest.Resource := FBaseURL;
    LTempRequest.ResourceSuffix := 'conversations';
    LTempRequest.Params.Clear;
    LTempRequest.Body.ClearBody;
    LTempRequest.Params.AddHeader('API-KEY', FApiKey).Options := [poDoNotEncode];
    LTempRequest.Params.AddHeader('Authorization', 'Bearer ' + FApiKey).Options := [poDoNotEncode];
    LRequestObj := TRequestObj.Create;
    try
      LTitle := cOneMinAiAI_LTitle;
      if LTitle.Length > TitleMaxLength then
        LTitle := LTitle.Substring(0, TitleMaxLength);
      LRequestObj.&Type := cOneMinAiAI_def_Type;
      LRequestObj.Model := FModel;
      LRequestObj.Title := LTitle;
      LTempRequest.AddBody(TJson.ObjectToJsonString(LRequestObj, [joIgnoreDefault]), ctAPPLICATION_JSON);
    finally
      LRequestObj.Free;
    end;
    try
      LTempRequest.Execute;
    except on E: Exception do
      begin
        AError := E.Message;
        Exit;
      end;
    end;
    if not LTempResponse.Status.SuccessOK_200 then
    begin
      AError := 'Failed to initialize 1min.ai Conversation: ' + LTempResponse.StatusText;
      Exit;
    end;
    LConv := TJson.JsonToObject<TConversationResponse>(LTempResponse.Content);
    try
      if (LConv = nil) or LConv.Conversation.Id.IsEmpty then
      begin
        AError := cOneMinAiAI_Msg_NoAnswer;
        Exit;
      end;
      FConversationId := LConv.Conversation.Id;
      Result := True;
    finally
      LConv.Free;
    end;
  finally
    LTempRequest.Free;
    LTempResponse.Free;
  end;
end;

function TOneMinAiChatClient.BuildRequestBody(const APrompt: string): string;
var
  LRequestObj: TRequestObj;
begin
  LRequestObj := TRequestObj.Create;
  try
    LRequestObj.&Type := cOneMinAiAI_def_Type;
    LRequestObj.Model := FModel;
    LRequestObj.PromptObject.Prompt := APrompt;
    LRequestObj.PromptObject.ConversationId := FConversationId;
//    LRequestObj.PromptObject.IsMixed := False;
//    LRequestObj.PromptObject.WebSearch := False;
    Result := TJson.ObjectToJsonString(LRequestObj);
  finally
    LRequestObj.Free;
  end;
end;

function TOneMinAiChatClient.ParseResponse(out AError: string): string;
var
  LJsonObj: TJSONObject;
  LResponseObj: TAIResponseObj;
  LRecordDetail: TAIRecordDetail;
begin
  Result := '';
  AError := '';
  LJsonObj := TJSONObject.ParseJSONValue(FRestResponse.Content) as TJSONObject;
  if LJsonObj = nil then
  begin
    if TryParseError(FRestResponse.Content, AError) then
      Exit;
    AError := cOneMinAiAI_Msg_NoAnswer;
    Exit;
  end;
  try
    LResponseObj := TJson.JsonToObject<TAIResponseObj>(LJsonObj);
    try
      if Assigned(LResponseObj) and Assigned(LResponseObj.AiRecord) and Assigned(LResponseObj.AiRecord.AiRecordDetail) then
      begin
        LRecordDetail := LResponseObj.AiRecord.AiRecordDetail;
        for var i := 0 to high(LRecordDetail.ResultObject) do
          Result := Result + LRecordDetail.ResultObject[i];
      end
      else AError := cOneMinAiAI_Msg_NoAnswer;
    finally
      LResponseObj.Free;
    end;
  finally
    LJsonObj.Free;
  end;
end;

function TOneMinAiChatClient.TryParseError(const AContent: string; out AError: string): Boolean;
var
  LJsonObj: TJSONObject;
  LErrorObj: TErrorObj;
begin
  Result := False;
  AError := '';
  LJsonObj := TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  if LJsonObj = nil then
    Exit;
  try
    LErrorObj := TJson.JsonToObject<TErrorObj>(LJsonObj);
    try
      if Assigned(LErrorObj) and not LErrorObj.Message.IsEmpty then
      begin
        AError := LErrorObj.Message;
        Result := True;
      end;
    finally
      LErrorObj.Free;
    end;
  finally
    LJsonObj.Free;
  end;
end;

{ TForm1 }

procedure TForm1minAI.BtnSubmitClick(Sender: TObject);
var
  LPrompt: string;
begin
  LPrompt := trim(MemoRequest.Text);
  if LPrompt.IsEmpty then
  begin
    MemoResponse.Text := 'Please enter a prompt before submitting.';
    Exit;
  end;
  BtnSubmit.Enabled := False;
  MemoResponse.Text := 'Sending request...';
  TTask.Run(
    procedure
    var
      LResult: string;
      LError: string;
    begin
      LResult := FChatClient.Chat(LPrompt, LError);
      TThread.Synchronize(nil,
        procedure
        begin
          BtnSubmit.Enabled := True;
          if LError.IsEmpty then
          begin
            MemoResponse.Text := StringReplace(LResult, #10, #13+#10, [rfReplaceAll]);
            Exit;
          end;
          MemoResponse.Text := 'Error: ' + LError;
        end);
    end);
end;

procedure TForm1minAI.FormCreate(Sender: TObject);
begin
  FChatClient := TOneMinAiChatClient.Create;
end;

procedure TForm1minAI.FormDestroy(Sender: TObject);
begin
  FChatClient.Free;
end;

end.
