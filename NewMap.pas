unit NewMap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, RzEdit;

type
  TNewMapFrm = class(TForm)
    GenerateBTN: TButton;
    CancelBTN: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    GroupBox2: TGroupBox;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RzNumericEdit3: TRzNumericEdit;
    RzNumericEdit2: TRzNumericEdit;
    RzNumericEdit1: TRzNumericEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewMapFrm: TNewMapFrm;

implementation

{$R *.dfm}

end.
