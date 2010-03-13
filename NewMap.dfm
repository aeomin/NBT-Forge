object NewMapFrm: TNewMapFrm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Create a new map'
  ClientHeight = 128
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GenerateBTN: TButton
    Left = 214
    Top = 95
    Width = 75
    Height = 25
    Caption = 'Generate'
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBTN: TButton
    Left = 295
    Top = 95
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 97
    Height = 105
    Caption = 'Map Type'
    TabOrder = 2
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 49
      Height = 17
      Caption = 'Inland'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
  end
  object GroupBox2: TGroupBox
    Left = 111
    Top = 8
    Width = 257
    Height = 81
    Caption = 'Map Size'
    TabOrder = 3
    object Label1: TLabel
      Left = 15
      Top = 51
      Width = 6
      Height = 13
      Caption = 'X'
    end
    object Label2: TLabel
      Left = 94
      Top = 51
      Width = 6
      Height = 13
      Caption = 'Y'
    end
    object Label3: TLabel
      Left = 173
      Top = 51
      Width = 6
      Height = 13
      Caption = 'Z'
    end
    object RadioButton2: TRadioButton
      Left = 15
      Top = 16
      Width = 49
      Height = 17
      Caption = 'Small'
      TabOrder = 0
    end
    object RadioButton3: TRadioButton
      Left = 67
      Top = 16
      Width = 58
      Height = 17
      Caption = 'Medium'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object RadioButton4: TRadioButton
      Left = 133
      Top = 16
      Width = 50
      Height = 17
      Caption = 'Large'
      TabOrder = 2
    end
    object RadioButton5: TRadioButton
      Left = 190
      Top = 16
      Width = 58
      Height = 17
      Caption = 'Custom'
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 3
    end
    object RzNumericEdit3: TRzNumericEdit
      Left = 183
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 4
      Max = 1024.000000000000000000
      Value = 64.000000000000000000
      DisplayFormat = ',0;(,0)'
    end
    object RzNumericEdit2: TRzNumericEdit
      Left = 103
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 5
      Max = 1024.000000000000000000
      Value = 256.000000000000000000
      DisplayFormat = ',0;(,0)'
    end
    object RzNumericEdit1: TRzNumericEdit
      Left = 24
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 6
      Max = 1024.000000000000000000
      Value = 256.000000000000000000
      DisplayFormat = ',0;(,0)'
    end
  end
end
