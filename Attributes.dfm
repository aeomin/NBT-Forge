object AttributesFrm: TAttributesFrm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Map Attributes'
  ClientHeight = 166
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 201
    Height = 122
    BiDiMode = bdLeftToRight
    Caption = 'Surrounding'
    ParentBiDiMode = False
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 57
      Height = 13
      Caption = 'Water Type'
    end
    object Label2: TLabel
      Left = 16
      Top = 44
      Width = 62
      Height = 13
      Caption = 'Ground Type'
    end
    object Label3: TLabel
      Left = 16
      Top = 70
      Width = 64
      Height = 13
      Caption = 'Water Height'
    end
    object Label4: TLabel
      Left = 16
      Top = 97
      Width = 69
      Height = 13
      Caption = 'Ground Height'
    end
    object WaterHeight: TRzNumericEdit
      Left = 91
      Top = 67
      Width = 38
      Height = 21
      TabOrder = 0
      DisplayFormat = ',0;(,0)'
    end
    object GroundHeight: TRzNumericEdit
      Left = 91
      Top = 94
      Width = 38
      Height = 21
      TabOrder = 1
      DisplayFormat = ',0;(,0)'
    end
    object WaterType: TComboBox
      Left = 91
      Top = 16
      Width = 102
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
    end
    object GroundType: TComboBox
      Left = 91
      Top = 40
      Width = 102
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 215
    Top = 8
    Width = 130
    Height = 122
    Caption = 'Space'
    TabOrder = 1
    object Label5: TLabel
      Left = 16
      Top = 16
      Width = 61
      Height = 13
      Caption = 'Cloud Height'
    end
    object Label6: TLabel
      Left = 16
      Top = 43
      Width = 46
      Height = 13
      Caption = 'Fog Color'
    end
    object Label7: TLabel
      Left = 16
      Top = 70
      Width = 45
      Height = 13
      Caption = 'Sky Color'
    end
    object Label8: TLabel
      Left = 16
      Top = 97
      Width = 55
      Height = 13
      Caption = 'Cloud Color'
    end
    object CloudHeight: TRzNumericEdit
      Left = 83
      Top = 13
      Width = 38
      Height = 21
      TabOrder = 0
      DisplayFormat = ',0;(,0)'
    end
    object FogColor: TRzColorEdit
      Left = 83
      Top = 40
      Width = 38
      Height = 21
      ShowCustomColor = True
      TabOrder = 1
    end
    object SkyColor: TRzColorEdit
      Left = 83
      Top = 67
      Width = 38
      Height = 21
      ShowCustomColor = True
      TabOrder = 2
    end
    object CloudColor: TRzColorEdit
      Left = 83
      Top = 94
      Width = 38
      Height = 21
      ShowCustomColor = True
      TabOrder = 3
    end
  end
  object OkayBTN: TButton
    Left = 86
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Okay...'
    TabOrder = 2
    OnClick = OkayBTNClick
  end
  object Button2: TButton
    Left = 179
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
