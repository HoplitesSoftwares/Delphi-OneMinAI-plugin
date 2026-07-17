unit OneMinAiPlugin.Controller;

interface

uses
  System.Classes, System.SysUtils, Vcl.Forms, Vcl.Dialogs,
  {$IFNDEF EXE}
  ToolsAPI, ToolsAPI.AI, ToolUtils,
  {$ENDIF}
  OneMinAiPlugin.Consts,
  OneMinAiPlugin.Setting,
  OneMinAiPlugin.JsonHelper,
  OneMinAiPlugin.Models,
  REST.Client,
  REST.Types,
  REST.Json,
  System.JSON,
  System.Generics.Collections;

type
  TOneMinAiRestClient = class {$IFNDEF EXE}(TOTAclass){$ENDIF}
  private
    FRestClient: TCustomRESTClient;
    FRestResponse: TRESTResponse;
    FRestRequest: TRESTRequest;
    FResponseObject: TAIResponseObj;
    FConversationId: string; // Persistent ID for the session
    FLastPrompt: string;
    FLastRequestBody: string;
    function IsParsable(var AJsonObj: TJSONObject): Boolean;
    function CheckError(out AValue: string): Boolean;
    procedure DoCompletion(const ARequestID: TGUID);
    procedure DoFinishLoad(const AResponseObj: TAIResponseObj; const ARequestID: TGUID);
    procedure PrepareBody(const AValue: string);
    procedure PrepareHeader;
    procedure NotifyError(const AEndpoint, AMessage: string; const ARequestID: TGUID);
    procedure NotifyAnswer(const AMessage: string; const ARequestID: TGUID);
    function CheckAPIKey(const ARequestID: TGUID): Boolean;
    function EnsureConversation(const ARequestID: TGUID): Boolean;
    function FormatRequestContext: string;
    function ExtractAnswer(const AResponseObj: TAIResponseObj): string;
  protected
    FBaseURL: string;
    FModel: string;
    FApiKey: string;
    FTimeOut: Integer;
    procedure DoCancel;
  {$IFNDEF EXE}
    function AddNotifier(const ANotifier: IOTAAIServicesNotifier): Integer;
    procedure RemoveNotifier(const AIndex: Integer);
  {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    function DoChat(const APrompt: string; const ARequestID: TGUID): string;
  end;

implementation

{ TOneMinAiRestClient }

constructor TOneMinAiRestClient.Create;
begin
  inherited Create;
  FRestClient := TCustomRESTClient.Create(nil);
  FRestResponse := TRESTResponse.Create(nil);
  FRestRequest := TRESTRequest.Create(nil);

  FRestRequest.Method := TRESTRequestMethod.rmPost;
  FRestRequest.Client := FRestClient;
  FRestRequest.Response := FRestResponse;

  // Default 1min.ai Settings
  FBaseURL := cOneMinAiAI_def_BaseUrl;
  FModel := cOneMinAiAI_def_Model;
  FApiKey := '';
  FTimeOut := cOneMinAiAI_Def_Timeout;

  FRestRequest.TimeOut := FTimeOut;
  FRestClient.ContentType := TRESTContentType.ctAPPLICATION_JSON;
end;

destructor TOneMinAiRestClient.Destroy;
begin
  if Assigned(FResponseObject) then FreeAndNil(FResponseObject);
  if Assigned(FRestResponse) then FreeAndNil(FRestResponse);
  if Assigned(FRestRequest) then FreeAndNil(FRestRequest);
  if Assigned(FRestClient) then FreeAndNil(FRestClient);
  inherited;
end;

{$IFNDEF EXE}
function TOneMinAiRestClient.AddNotifier(const ANotifier: IOTAAIServicesNotifier): Integer;
begin
  Result := AddToList(FNotifyList, ANotifier);
end;

procedure TOneMinAiRestClient.RemoveNotifier(const AIndex: Integer);
begin
  FNotifyList[AIndex] := nil;
end;
{$ENDIF}

function TOneMinAiRestClient.CheckAPIKey(const ARequestID: TGUID): Boolean;
begin
  Result := not FApiKey.Trim.IsEmpty;
  if not Result then
    NotifyError(Self.FRestRequest.ResourceSuffix, cOneMinAiAI_Msg_CheckAPI, ARequestID);
end;

function TOneMinAiRestClient.EnsureConversation(const ARequestID: TGUID): Boolean;
var
  LTempRequest: TRESTRequest;
  LTempResponse: TRESTResponse;
  LConv: TConversationResponse;
  LRequestObj: TRequestObj;
  LTitle: string;
const
  TitleMaxLength = 64;
begin
//  showmessage('EnsureConversation');
  Result := False;
  if not FConversationId.IsEmpty then
    Exit(True);

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
    LTempRequest.Timeout := FTimeout;

    LRequestObj := TRequestObj.Create;
    try
      LTitle := FLastPrompt;
      if LTitle.IsEmpty then
        LTitle := cOneMinAiAI_LTitle;
      if LTitle.Length > TitleMaxLength then
        LTitle := LTitle.Substring(0, TitleMaxLength);

      LRequestObj.Model := FModel;
      LRequestObj.Title := LTitle;
      LTempRequest.AddBody(TJson.ObjectToJsonString(LRequestObj), ctAPPLICATION_JSON);
    finally
      LRequestObj.Free;
    end;

    try
      LTempRequest.Execute;
    except on E: Exception do
      begin
        NotifyError(LTempRequest.ResourceSuffix, E.Message, ARequestID);
        Exit;
      end;
    end;

    if not LTempResponse.Status.SuccessOK_200 then
    begin
      NotifyError(LTempRequest.ResourceSuffix, 'Failed to initialize 1min.ai Conversation: ' + LTempResponse.StatusText, ARequestID);
      Exit;
    end;

    LConv := TJson.JsonToObject<TConversationResponse>(LTempResponse.Content);
    try
      if (LConv <> nil) and not LConv.Conversation.Id.IsEmpty then
      begin
        FConversationId := LConv.Conversation.Id;
        Result := True;
      end
      else
        NotifyError(LTempRequest.ResourceSuffix, cOneMinAiAI_Msg_NoAnswer, ARequestID);
    finally
      LConv.Free;
    end;
  finally
    LTempRequest.Free;
    LTempResponse.Free;
  end;
end;

function TOneMinAiRestClient.DoChat(const APrompt: string; const ARequestID: TGUID): string;
begin
  Result := '';
  FLastPrompt := APrompt.Trim;
  FLastRequestBody := '';

  if not CheckAPIKey(ARequestID) then Exit;

  // 1min.ai requirement: must have a conversation ID first
  if not EnsureConversation(ARequestID) then Exit;

  FRestRequest.Body.ClearBody;
  FRestRequest.Params.Clear;

  PrepareHeader;
  PrepareBody(APrompt);

  try
    FRestRequest.ExecuteAsync(
      procedure
      begin
        DoCompletion(ARequestID);
      end,
      True,
      True,
      procedure(AObject: TObject)
      begin
        NotifyError(FRestRequest.ResourceSuffix+'A', Exception(AObject).Message, ARequestID);
      end);
  except on E: Exception do
    NotifyError(FRestRequest.ResourceSuffix+'B', E.Message, ARequestID);
  end;
end;

procedure TOneMinAiRestClient.PrepareHeader;
begin
  FRestClient.BaseURL := '';
  FRestRequest.Client := FRestClient;
  FRestRequest.Method := rmPOST;
  FRestRequest.Resource := FBaseURL;
  FRestRequest.ResourceSuffix := 'chat-with-ai'; // The endpoint for chat/gen

  // 1min.ai standard uses query param for streaming preference
  FRestRequest.AddParameter('isStreaming', 'false', pkQUERY);

  FRestRequest.Timeout := FTimeOut;
  // Use API-KEY header as per 1min.ai docs
  FRestRequest.Params.AddHeader('API-KEY', FApiKey).Options := [poDoNotEncode];
  FRestRequest.Params.AddHeader('Authorization', 'Bearer ' + FApiKey).Options := [poDoNotEncode];
//  FRestRequest.Params.AddHeader('Accept', 'application/json').Options := [poDoNotEncode];
end;

procedure TOneMinAiRestClient.PrepareBody(const AValue: string);
var
  LJsonBody: string;
  LRequestObj: TRequestObj;
begin
  LRequestObj := TRequestObj.Create;
  try
    LRequestObj.&Type := cOneMinAiAI_def_Type;
    LRequestObj.Model := FModel;
    LRequestObj.PromptObject.Prompt := AValue;
    LRequestObj.PromptObject.conversationId := FConversationId;
//    LRequestObj.PromptObject.IsMixed := False;
//    LRequestObj.PromptObject.WebSearch := False;

    LJsonBody := TJson.ObjectToJsonString(LRequestObj);
    FRestRequest.AddBody(LJsonBody, ctAPPLICATION_JSON);
    FLastRequestBody := LJsonBody;
  finally
    LRequestObj.Free;
  end;
end;

procedure TOneMinAiRestClient.DoCompletion(const ARequestID: TGUID);
var
  LJsonObj: TJSONObject;
  LErrorMsg: string;
begin
//  showmessage('DoCompletion');
  if (FRestRequest = nil) or (FRestResponse = nil) then Exit;

  if not FRestResponse.Status.SuccessOK_200 then
  begin
    LErrorMsg := FRestResponse.StatusText;
    var Err: string;
    if CheckError(Err) then LErrorMsg := Err;
    NotifyError(Self.FRestRequest.ResourceSuffix, LErrorMsg, ARequestID);
    Exit;
  end;

  if not IsParsable(LJsonObj) then Exit;

  try
    try
      if Assigned(FResponseObject) then FreeAndNil(FResponseObject);
      FResponseObject := TJson.JsonToObject<TAIResponseObj>(LJsonObj);
      DoFinishLoad(FResponseObject, ARequestID);
    finally
      LJsonObj.Free;
    end;
  except on E: Exception do
    NotifyError(Self.FRestRequest.ResourceSuffix, E.Message, ARequestID);
  end;
end;

procedure TOneMinAiRestClient.DoFinishLoad(const AResponseObj: TAIResponseObj; const ARequestID: TGUID);
var
  LMessage: string;
begin
//  showmessage('DoFinishLoad');

  LMessage := ExtractAnswer(AResponseObj);

  NotifyAnswer(LMessage, ARequestID);
end;

function TOneMinAiRestClient.CheckError(out AValue: string): Boolean;
var
  LJsonObj: TJSONObject;
  LErrors: TErrorObj;
begin
//  showmessage('CheckError');
  Result := False;
  if IsParsable(LJsonObj) then
  begin
    try
      LErrors := TJson.JsonToObject<TErrorObj>(LJsonObj);
      try
        if (LErrors <> nil) and not LErrors.Message.IsEmpty then
        begin
          AValue := LErrors.Message;
          Result := True;
        end;
      finally
        LErrors.Free;
      end;
    finally
      LJsonObj.Free;
    end;
  end;

  if not Result then
    AValue := FRestResponse.Content;
end;

function TOneMinAiRestClient.ExtractAnswer(const AResponseObj: TAIResponseObj): string;
var
  LRecordDetail: TAIRecordDetail;
begin
//  showmessage('ExtractAnswer');
  Result := cOneMinAiAI_Msg_NoAnswer;
  if (AResponseObj <> nil) and Assigned(AResponseObj.AiRecord) and Assigned(AResponseObj.AiRecord.AiRecordDetail) then
  begin
    Result := '';
    LRecordDetail := AResponseObj.AiRecord.AiRecordDetail;
    for var i := 0 to high(LRecordDetail.ResultObject) do
    begin
      Result := Result + LRecordDetail.ResultObject[i];
    end;
  end;
  Result := StringReplace(Result, #10, #13+#10, [rfReplaceAll]);
end;

function TOneMinAiRestClient.IsParsable(var AJsonObj: TJSONObject): Boolean;
begin
  AJsonObj := nil;
  try
    AJsonObj := TJSONObject.ParseJSONValue(FRestResponse.Content) as TJSONObject;
  except
    AJsonObj := nil;
  end;
  Result := AJsonObj <> nil;
end;

procedure TOneMinAiRestClient.NotifyError(const AEndpoint, AMessage: string; const ARequestID: TGUID);
var
  I: Integer;
  LMessage: string;
  LContext: string;
begin
  {$IFNDEF EXE}
//  showmessage('NotifyError');
  LContext := FormatRequestContext;
  if LContext.IsEmpty then
    LMessage := AMessage
  else
    LMessage := Format('%s%s%s%s%s', ['Endpoint : '+AEndpoint, sLineBreak, AMessage, sLineBreak, LContext]);

//  FNotifyList.Lock;
//  try
    for I := 0 to Pred(FNotifyList.Count) do
      if Assigned(FNotifyList[I]) then
        (FNotifyList[I] as IOTAAIServicesNotifier).Error(LMessage, ARequestID);
//  finally
//    FNotifyList.Unlock;
//  end;
  {$ENDIF}
end;

procedure TOneMinAiRestClient.NotifyAnswer(const AMessage: string; const ARequestID: TGUID);
var
  I: Integer;
begin
  {$IFNDEF EXE}
//  showmessage('NotifyAnswer');
//  FNotifyList.Lock;
//  try
    for I := 0 to Pred(FNotifyList.Count) do
      if Assigned(FNotifyList[I]) then
        (FNotifyList[I] as IOTAAIServicesNotifier).Answer(AMessage, ARequestID);
//  finally
//    FNotifyList.Unlock;
//  end;
  {$ENDIF}
end;

function TOneMinAiRestClient.FormatRequestContext: string;
const
  CONTEXT_TEMPLATE = 'Calling message: %s' + sLineBreak + 'Parameters: %s';
var
  LCallingMessage: string;
  LParameters: string;
begin
  LCallingMessage := FLastPrompt.Trim;
  LParameters := FLastRequestBody.Trim;
  if LCallingMessage.IsEmpty and LParameters.IsEmpty then
    Exit(EmptyStr);

  if LCallingMessage.IsEmpty then
    LCallingMessage := 'N/A';
  if LParameters.IsEmpty then
    LParameters := 'N/A';

  Result := Format(CONTEXT_TEMPLATE, [LCallingMessage, LParameters]);
end;

procedure TOneMinAiRestClient.DoCancel;
begin
  if FRestRequest <> nil then
    FRestRequest.Cancel;
end;

end.
