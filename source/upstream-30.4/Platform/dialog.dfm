object frmDialog: TfrmDialog
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'frmDialog'
  ClientHeight = 211
  ClientWidth = 462
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClick = FormClick
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object lblMessage2: TLabel
    Left = 80
    Top = 150
    Width = 361
    Height = 25
    AutoSize = False
    Caption = 'lblMessage2'
    Transparent = True
    WordWrap = True
    OnClick = lblMessage2Click
  end
  object lblMessage: TLabel
    Left = 80
    Top = 19
    Width = 361
    Height = 153
    AutoSize = False
    Caption = 'lblMessage'
    Transparent = True
    WordWrap = True
    OnClick = lblMessageClick
  end
  object imgIcon: TImage
    Left = 16
    Top = 16
    Width = 48
    Height = 48
    Proportional = True
    Stretch = True
    Visible = False
  end
  object btnCancel: TButton
    Left = 365
    Top = 178
    Width = 89
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    Default = True
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnOK: TButton
    Left = 269
    Top = 178
    Width = 89
    Height = 25
    Caption = '&Ok'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object progProgress: TProgressBar
    Left = 16
    Top = 123
    Width = 427
    Height = 17
    Style = pbstMarquee
    TabOrder = 3
    Visible = False
  end
  object btnThird: TButton
    Left = 104
    Top = 178
    Width = 158
    Height = 25
    Caption = 'Third'
    TabOrder = 0
    Visible = False
    OnClick = btnThirdClick
  end
end
