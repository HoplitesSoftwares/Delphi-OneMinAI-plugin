program OneMinAIrun;

uses
  Vcl.Forms,
  Web.WebReq,
  System.SysUtils,
  Winapi.Windows,
  REST.Client,
  REST.Json,
  REST.Types,
  OneMinAIPlugin.Consts in 'OneMinAIPlugin.Consts.pas',
  OneMinAIPlugin.Controller in 'OneMinAIPlugin.Controller.pas',
  OneMinAIPlugin.JsonHelper in 'OneMinAIPlugin.JsonHelper.pas',
  OneMinAIPlugin.Main in 'OneMinAIPlugin.Main.pas',
  OneMinAIPlugin.Models in 'OneMinAIPlugin.Models.pas',
  OneMinAIPlugin.Setting in 'OneMinAIPlugin.Setting.pas' {Setting},
  Unit1 in 'Unit1.pas' {Form1minAI};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1minAI, Form1minAI);
  Application.Run;
end.
