unit Tool;

interface

uses
	Forms,
	Types,
	StdCtrls,
	GR32,
	RzTabs,
	RzTrkBar,
	RzEdit;
type
	TToolGet = function(const X,Y,Z:Integer):Byte of object;
	TToolSet = procedure(const X,Y,Z:Integer;const ABlock:Byte) of object;
	TGUIDesigner = class
	private
		fTabSheet : TScrollBox;
		fY : Integer;
		fLowY : Integer;
	public
		function AddTrackBar(const AName : String):TRzTrackBar;
		function NewNumEditBox:TRzNumericEdit;
		function NewCheckBox:TCheckBox;
		function NewLabel : TLabel;
		function NewButton : TButton;
		function NewRadio : TRadioButton;
		procedure NewLine;
		constructor Create(ATabSheet : TScrollBox);
	end;
	TPoint3 = record
		X,Y,Z : Integer;
	end;
	TTool = class
	protected
		fGet : TToolGet;
		fSet : TToolSet;
		fHelper : TBitmap32;
	public
		function InitGui(const ADesigner : TGUIDesigner):String;virtual;abstract;
		procedure Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);virtual;
		procedure Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);virtual;
		procedure Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);virtual;
		function GetToolName : String;virtual;abstract;
		constructor Create(const AGet:TToolGet;const ASet : TToolSet;const AHelper : TBitmap32);
	end;
	function Point3(const X,Y,Z:Integer):TPoint3;
implementation


const
	YInc = 10;
	XOffset = 5;
	PanelWidth = 250;
constructor TGUIDesigner.Create(ATabSheet : TScrollBox);
begin
	inherited Create;
	fTabSheet := ATabSheet;
	fY := YInc;
	fLowY := YInc;
end;

function TGUIDesigner.AddTrackBar(const AName : String):TRzTrackBar;
var
	ALabel : TLabel;
begin
	ALabel := TLabel.Create(fTabSheet);
	ALabel.Parent := fTabSheet;
	ALabel.Caption := AName;
	ALabel.Top := fY;
	ALabel.Left := XOffset;

	Result := TRzTrackBar.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.ThumbStyle := tsFlat;
	Result.Top := fY + ALabel.Height + 3;
	Result.Width := PanelWidth;

	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + ALabel.Height + YInc + 3);
end;
function TGUIDesigner.NewNumEditBox:TRzNumericEdit;
begin
	Result := TRzNumericEdit.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.Top := fY;
	Result.FrameVisible := True;
	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + YInc + 3);
end;
function TGUIDesigner.NewCheckBox:TCheckBox;
begin
	Result := TCheckBox.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.Top := fY;
	Result.Left := XOffset;

	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + YInc + 3);
end;
function TGUIDesigner.NewLabel : TLabel;
begin
	Result := TLabel.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.Top := fy;
	Result.Left := XOffset;
	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + YInc + 3);
end;
function TGUIDesigner.NewButton : TButton;
begin
	Result := TButton.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.Top := fy;
	Result.Left := XOffset;
	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + YInc + 3);
end;
function TGUIDesigner.NewRadio : TRadioButton;
begin
	Result := TRadioButton.Create(fTabSheet);
	Result.Parent := fTabSheet;
	Result.Top := fy;
	Result.Left := XOffset;
	if Result.Top + Result.Height > fLowY then
		Inc(fLowY,Result.Height + YInc + 3);
end;
procedure TGUIDesigner.NewLine;
begin
	fY := fLowY;
end;

constructor TTool.Create(const AGet:TToolGet;const ASet : TToolSet;const AHelper : TBitmap32);
begin
	inherited Create;
	fGet := AGet;
	fSet := ASet;
	fHelper := AHelper;
end;
procedure TTool.Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin

end;
procedure TTool.Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin

end;
procedure TTool.Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin

end;
function Point3(const X,Y,Z:Integer):TPoint3;
begin
	Result.X := X;
	Result.Y := Y;
	Result.Z := Z;
end;
end.