unit OneMinAiPlugin.Consts;

interface

const
  cOneMinAiAI_name = '1MinAI';
  cOneMinAiAI_def_BaseUrl = 'https://api.1min.ai/api/';
  cOneMinAiAI_def_Type = 'UNIFY_CHAT_WITH_AI';
  cOneMinAiAI_def_Model = 'gpt-4o-mini';
  cOneMinAiAI_LTitle = 'Delphi1MinAIPlugin';
  cOneMinAiAI_def_Timeout = 30000;

  cOneMinAiAI_Msg_CheckAPI = 'The API key has not been set.';
  cOneMinAiAI_Msg_NoAnswer = 'No Answer';

  cOneMinAiAI_RegKey = '\software\MyAIPlugins\OneMinAI';
  cOneMinAiAI_RegKey_Enabled = 'Enabled';
  cOneMinAiAI_RegKey_BaseURL = 'BaseURL';
  cOneMinAiAI_RegKey_Model = 'Model';
  cOneMinAiAI_RegKey_ApiKey = 'ApiKey';
  cOneMinAiAI_RegKey_Timeout = 'Timeout';

  cOneMinAiAI_Msg_BaseURL = 'Please Enter the BaseURL for OneMinAI';
  cOneMinAiAI_Msg_Model = 'Please Enter the Model for OneMinAI';
  cOneMinAiAI_Msg_APIKey = 'Please Enter the API Key for OneMinAI';
  cOneMinAiAI_Msg_Timeout = 'Please Enter the Timeout value for OneMinAI';
  cOneMinAiAI_URLRegex = '^((https?://[a-zA-Z0-9.-]+(:\d+)?(/.*)?)|(localhost(:\d+)?(/.*)?))$';
  cOneMinAiAI_Msg_InvalidURL = 'Invalid Base URL. Please provide a valid Localhost, HTTP or HTTPS URL.';

  cOneMinAiAI_ContentType = 'application/json';



implementation

end.
