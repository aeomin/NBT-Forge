unit ToolManager;

interface

uses
	Types,
	Generics.Collections,
	RzTabs,
	Tool;

type
	TToolClass = class of TTool;
	TToolManager = class
	protected
		fPanel : TRzPageControl;
		fTools : TObjectList<TTool>;
		function GetCurrentTool:String;
	public
		property CurrentTool : String read GetCurrentTool;
		procedure Init;
		procedure Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);
		procedure Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);
		procedure Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);
		constructor Create(const APanel : TRzPageControl);virtual;
		destructor Destroy;override;
	end;
implementation

uses
	StdCtrls,
	Forms,
	Controls,
	Classes;

function TToolManager.GetCurrentTool:String;
begin
	Result := fTools[fPanel.ActivePageIndex].GetToolName;
end;


procedure TToolManager.Init;
var
	Index : LongWord;
	ATabSheet : TRzTabSheet;
	AScrollBox : TScrollBox;
	ADesigner : TGUIDesigner;
	ALabel : TLabel;
	ATool : TTool;
begin
	for Index := fPanel.PageCount -1 downto 0 do
	begin
		fPanel.Pages[Index].Free;
	end;

	for ATool in fTools do
	begin
		ATabSheet := TRzTabSheet.Create(fPanel);
		AScrollBox := TScrollBox.Create(ATabSheet);
		AScrollBox.Parent := ATabSheet;
		AScrollBox.HorzScrollBar.Smooth := True;
		AScrollBox.HorzScrollBar.Tracking := True;
		AScrollBox.VertScrollBar.Smooth := True;
		AScrollBox.VertScrollBar.Tracking := True;
		AScrollBox.BorderStyle := bsNone;
		AScrollBox.Align := alClient;
		ADesigner := TGUIDesigner.Create(AScrollBox);
		ATabSheet.PageControl := fPanel;
		ATabSheet.Caption := ATool.InitGui(ADesigner);
		ADesigner.Free;
	end;

	//No options AT ALL?
	if fPanel.PageCount = 0 then
	begin
		ATabSheet := TRzTabSheet.Create(fPanel);
		ATabSheet.Caption :='Oh no...';
		ATabSheet.TabVisible := False;
		ATabSheet.PageControl := fPanel;

		ALabel := TLabel.Create(ATabSheet);
		ALabel.Parent := ATabSheet;
		ALabel.AutoSize := False;
		ALabel.Width := ATabSheet.Width;
		ALabel.Alignment := taCenter;
		ALabel.Transparent := True;
		ALabel.Top := 0;
		ALabel.Left := 0;
		ALabel.Caption := 'No options available.';
	end;
	fPanel.ActivePageIndex := 0;
end;

procedure TToolManager.Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin
	fTools[fPanel.ActivePageIndex].Draw(X,Y,Z,Boundary);
end;
procedure TToolManager.Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin
	fTools[fPanel.ActivePageIndex].Click(X,Y,Z,Boundary);
end;
procedure TToolManager.Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);
begin
	fTools[fPanel.ActivePageIndex].Refresh(X,Y,Z,Boundary);
end;
constructor TToolManager.Create(const APanel : TRzPageControl);
begin
	inherited Create;
	fPanel := APanel;
	fTools := TObjectList<TTool>.Create(True);
end;
destructor TToolManager.Destroy;
begin
	fTools.Free;
	inherited;
end;



end.