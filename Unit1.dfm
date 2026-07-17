object Form1minAI: TForm1minAI
  Left = 0
  Top = 0
  Caption = '1MinAI Codeinsight'
  ClientHeight = 441
  ClientWidth = 624
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    624
    441)
  TextHeight = 13
  object MemoRequest: TMemo
    Left = 20
    Top = 20
    Width = 584
    Height = 160
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object MemoResponse: TMemo
    Left = 20
    Top = 200
    Width = 584
    Height = 168
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object BtnSubmit: TButton
    Left = 524
    Top = 388
    Width = 80
    Height = 30
    Anchors = [akRight, akBottom]
    Caption = '&Submit'
    TabOrder = 2
    OnClick = BtnSubmitClick
  end
end
