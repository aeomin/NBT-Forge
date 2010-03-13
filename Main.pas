unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, GR32_Image, GR32_Layers, ExtCtrls, Buttons, ComCtrls, ToolWin, RzTabs,
  StdCtrls, pngimage, Globals,Controller, RzStatus, RzCommon, RzPanel, RzLstBox,
  RzSplit;

type
	TMainFrm = class(TForm)
		MainMenu: TMainMenu;
		mFile: TMenuItem;
    mNew: TMenuItem;
    Open1: TMenuItem;
    mSave: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    mExit: TMenuItem;
    MapPanel: TPanel;
    RightPanel: TPanel;
    N3: TMenuItem;
    Import1: TMenuItem;
    Export1: TMenuItem;
    Heightmap1: TMenuItem;
    Edit1: TMenuItem;
    mView: TMenuItem;
    mTools: TMenuItem;
    CurrentBlockImage: TImage;
    BlockListDropDown: TSpeedButton;
    CheckBox1: TCheckBox;
    CurrentBlockName: TLabel;
    mSaveAs: TMenuItem;
    RzStatusBar1: TRzStatusBar;
    StatusMessage: TRzStatusPane;
    StatusProgress: TRzProgressStatus;
    Label1: TLabel;
    ZoomIn: TButton;
    ZoomOut: TButton;
    Label2: TLabel;
    LayerUp: TButton;
    LayerDown: TButton;
    ViewXY: TRadioButton;
    ViewXZ: TRadioButton;
    ViewYZ: TRadioButton;
    mUndo: TMenuItem;
    Map: TImgView32;
    mGrid: TMenuItem;
    MenuController: TRzMenuController;
    Help1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    About1: TMenuItem;
    mOfficialPost: TMenuItem;
    RzSplitter1: TRzSplitter;
    ToolsPanel: TRzPageControl;
    TabSheet1: TRzTabSheet;
    ScrollBox1: TScrollBox;
    TabSheet2: TRzTabSheet;
    HistoryLogList: TRzListBox;
    HistoryLogMenu: TPopupMenu;
    mClear: TMenuItem;
    mFixChests: TMenuItem;
    N4: TMenuItem;
    mCopyUp: TMenuItem;
    mCopyDown: TMenuItem;
    MapAttributions1: TMenuItem;
    N5: TMenuItem;
    mDonate: TMenuItem;
    BlockCount1: TMenuItem;
    procedure mExitClick(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BlockListDropDownClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
    procedure mNewClick(Sender: TObject);
    procedure MapMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ZoomInClick(Sender: TObject);
    procedure ZoomOutClick(Sender: TObject);
    procedure LayerUpClick(Sender: TObject);
    procedure LayerDownClick(Sender: TObject);
    procedure ViewXYClick(Sender: TObject);
    procedure ViewXZClick(Sender: TObject);
    procedure ViewYZClick(Sender: TObject);
    procedure MapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure MapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormShow(Sender: TObject);
    procedure mSaveClick(Sender: TObject);
		procedure DeFocus(Sender: TObject);
    procedure MapScroll(Sender: TObject);
    procedure mGridClick(Sender: TObject);
    procedure mSaveAsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mUndoClick(Sender: TObject);
    procedure mClearClick(Sender: TObject);
    procedure HistoryLogMenuPopup(Sender: TObject);
    procedure mUndoDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect;
      Selected: Boolean);
    procedure mFixChestsClick(Sender: TObject);
    procedure mCopyUpClick(Sender: TObject);
    procedure mCopyDownClick(Sender: TObject);
    procedure MapAttributions1Click(Sender: TObject);
    procedure mDonateClick(Sender: TObject);
    procedure mOfficialPostClick(Sender: TObject);
	private
		procedure WMMove(var Message: TMessage); message WM_MOVE;
		procedure AdjustBlockListPosition;


		procedure EditorOnError(const Error:String);
		procedure EditorOnUpdateStatus(const Text:String);
		procedure EditorOnAllowZoomIn(const Allow:Boolean);
		procedure EditorOnAllowZoomOut(const Allow:Boolean);
		procedure EditorOnChangeViewMode(const AMode : TViewMode);
	public
		function GetProperBlockListPosition:TPoint;
		procedure AcceptFiles( var msg : TMessage );message WM_DROPFILES;
		procedure OpenMap(const AFileName:String);
	end;

var
	MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
	ShellAPI,
	BlockList,
	DefaultController,
	NewMap,
	Attributes,
	HistoryLog,
	NBTReader;

procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	TransactionLog.Free;
	DefaultEditor.Free;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
	Caption := ProgramTitle;
	Application.Title := ProgramTitle;

	DragAcceptFiles( Handle, True );

	TransactionLog := THistoryLog.Create(HistoryLogList);

	DefaultEditor := TDefaultController.Create(Map,ToolsPanel,MapData);
	DefaultEditor.OnError := EditorOnError;
	DefaultEditor.OnUpdateStatus := EditorOnUpdateStatus;
	DefaultEditor.OnAllowZoomIn := EditorOnAllowZoomIn;
	DefaultEditor.OnAllowZoomOut := EditorOnAllowZoomOut;
	DefaultEditor.OnChangewViewMode := EditorOnChangeViewMode;

	CurrentEditor := DefaultEditor;
	CurrentBlock := 1;
end;

procedure TMainFrm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
	Control:TControl;
begin
	Control:=ControlAtPos(ScreenToClient(MousePos),False,True,True);
	if Assigned(Control) then
	begin
		if (Control=Map)OR(Control=MapPanel) then
		begin
			if MapData.Loaded then
			begin
				if ssCtrl in Shift then
				begin
					Handled := True;
					if WheelDelta > 0 then
						CurrentEditor.Zoom(1)
					else
						CurrentEditor.Zoom(-1);
				end else
					Handled := CurrentEditor.OnMouseWheel(WheelDelta);
			end;
		end;
	end;
end;

procedure TMainFrm.FormResize(Sender: TObject);
begin
	if  Assigned(BlockListFrm) AND BlockListFrm.Visible then
		AdjustBlockListPosition;
	DefaultEditor.FrameSize := Point(MapPanel.Width,MapPanel.Height);
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
	DefaultEditor.Block := 1; //Set to stone

	if ParamCount > 0 then
	begin
		OpenMap(ParamStr(1));
	end;
end;

procedure TMainFrm.mClearClick(Sender: TObject);
begin
	if TransactionLog.List.Count > 1 then
	begin
		TransactionLog.Clear;
		TransactionLog.Add(TTransaction.Create('Clear'));
	end;
end;

procedure TMainFrm.mCopyDownClick(Sender: TObject);
var
	IndexX,IndexY,IndexZ : Word;
	ABlock,BBlock : Byte;
	ATransaction : TTransaction;
begin
	ATransaction := TTransaction.Create('Copy Layer Down');
	case CurrentEditor.ViewMode of
		vmXY:begin
			if CurrentEditor.CurrentLayer > 0 then
			begin
				IndexZ := CurrentEditor.CurrentLayer;
				for IndexX := CurrentEditor.SizeX-1 downto 0 do
				begin
					for IndexY := CurrentEditor.SizeY-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ-1);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX,IndexY,IndexZ-1,ABlock
							);
							ATransaction.Add(IndexX,IndexY,IndexZ-1,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
		vmXZ:begin
			if CurrentEditor.CurrentLayer > 0 then
			begin
				IndexY := CurrentEditor.CurrentLayer;
				for IndexX := CurrentEditor.SizeX-1 downto 0 do
				begin
					for IndexZ := CurrentEditor.SizeZ-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX,IndexY-1,IndexZ);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX,IndexY-1,IndexZ,ABlock
							);
							ATransaction.Add(IndexX,IndexY-1,IndexZ,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
		vmYZ:begin
			if CurrentEditor.CurrentLayer > 0 then
			begin
				IndexX := CurrentEditor.CurrentLayer;
				for IndexY := CurrentEditor.SizeY-1 downto 0 do
				begin
					for IndexZ := CurrentEditor.SizeZ-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX-1,IndexY,IndexZ);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX-1,IndexY,IndexZ,ABlock
							);
							ATransaction.Add(IndexX-1,IndexY,IndexZ,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
	end;
	if ATransaction.List.Count > 0 then
		TransactionLog.Add(ATransaction)
	else
		ATransaction.Free;
end;

procedure TMainFrm.mCopyUpClick(Sender: TObject);
var
	IndexX,IndexY,IndexZ : Word;
	ABlock,BBlock : Byte;
	ATransaction : TTransaction;
begin
	ATransaction := TTransaction.Create('Copy Layer Up');
	case CurrentEditor.ViewMode of
		vmXY:begin
			if CurrentEditor.CurrentLayer < CurrentEditor.SizeZ - 1 then
			begin
				IndexZ := CurrentEditor.CurrentLayer;
				for IndexX := CurrentEditor.SizeX-1 downto 0 do
				begin
					for IndexY := CurrentEditor.SizeY-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ+1);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX,IndexY,IndexZ+1,ABlock
							);
							ATransaction.Add(IndexX,IndexY,IndexZ+1,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
		vmXZ:begin
			if CurrentEditor.CurrentLayer < CurrentEditor.SizeY - 1 then
			begin
				IndexY := CurrentEditor.CurrentLayer;
				for IndexX := CurrentEditor.SizeX-1 downto 0 do
				begin
					for IndexZ := CurrentEditor.SizeZ-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY+1,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX,IndexY+1,IndexZ,ABlock
							);
							ATransaction.Add(IndexX,IndexY+1,IndexZ,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
		vmYZ:begin
			if CurrentEditor.CurrentLayer < CurrentEditor.SizeX - 1 then
			begin
				IndexX := CurrentEditor.CurrentLayer;
				for IndexY := CurrentEditor.SizeY-1 downto 0 do
				begin
					for IndexZ := CurrentEditor.SizeZ-1 downto 0 do
					begin
						ABlock := CurrentEditor.GetBlock(IndexX,IndexY,IndexZ);
						BBlock := CurrentEditor.GetBlock(IndexX+1,IndexY,IndexZ);
						if ABlock <> BBlock then
						begin
							CurrentEditor.SetBlock(
								IndexX+1,IndexY,IndexZ,ABlock
							);
							ATransaction.Add(IndexX+1,IndexY,IndexZ,BBlock,ABlock);
						end;
					end;
				end;
			end;
		end;
	end;
	if ATransaction.List.Count > 0 then
		TransactionLog.Add(ATransaction)
	else
		ATransaction.Free;
end;

procedure TMainFrm.mDonateClick(Sender: TObject);
begin
	ShellExecute(Handle,'open','https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8CZGMQ4LB3MUS',nil,nil,SW_SHOW);
end;

procedure TMainFrm.mExitClick(Sender: TObject);
begin
	Close;
end;

procedure TMainFrm.mFixChestsClick(Sender: TObject);
var
	IndexX,IndexY,IndexZ:Integer;
begin
	if MessageBox(Handle,'This might take awhile to scan all blocks, continue?','dun dun dun',MB_YESNO or MB_ICONQUESTION) = IDYES then
	begin
		for IndexX := CurrentEditor.SizeX -1 downto 0 do
		begin
			for IndexY := CurrentEditor.SizeY downto 0 do
			begin
				for IndexZ := CurrentEditor.SizeZ downto 0 do
				begin
					if CurrentEditor.GetBlock(IndexX,IndexY,IndexZ) = 54 then
					begin
						FixChest(IndexX,IndexY,IndexZ);
					end;
				end;
			end;
		end;
		Showmessage('Done!');
	end;
end;

procedure TMainFrm.mGridClick(Sender: TObject);
begin
	CurrentEditor.ShowGrid := mGrid.Checked;
end;

procedure TMainFrm.mNewClick(Sender: TObject);
begin
	NewMapFrm := TNewMapFrm.Create(Self);
	if NewMapFrm.ShowModal = mrOK then
	begin

	end;
	NewMapFrm.Free;
end;

procedure TMainFrm.mOfficialPostClick(Sender: TObject);
begin
	ShellExecute(Handle,'open','http://www.minecraftforum.net/viewtopic.php?f=25&t=6382',nil,nil,SW_SHOW);
end;

procedure TMainFrm.mSaveClick(Sender: TObject);
begin
	MapData.Save;
end;

procedure TMainFrm.mUndoClick(Sender: TObject);
begin
	TransactionLog.Undo;
end;

procedure TMainFrm.mUndoDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
begin
	mUndo.Enabled := TransactionLog.List.Count > 1;
end;

procedure TMainFrm.Open1Click(Sender: TObject);
begin
	if OpenDialog.Execute then
	begin
		OpenMap(OpenDialog.FileName);
	end;
end;

procedure TMainFrm.mSaveAsClick(Sender: TObject);
begin
	if SaveDialog.Execute then
	begin
		MapData.Save(SaveDialog.FileName);
	end;
end;

procedure TMainFrm.DeFocus(Sender: TObject);
begin
	Map.SetFocus;
end;

procedure TMainFrm.ViewXYClick(Sender: TObject);
begin
	if MapData.Loaded then
		CurrentEditor.ViewMode := vmXY;
end;

procedure TMainFrm.ViewXZClick(Sender: TObject);
begin
	if MapData.Loaded then
		CurrentEditor.ViewMode := vmXZ;
end;

procedure TMainFrm.ViewYZClick(Sender: TObject);
begin
	if MapData.Loaded then
		CurrentEditor.ViewMode := vmYZ;
end;

procedure TMainFrm.BlockListDropDownClick(Sender: TObject);
begin
	if NOT BlockListDropDown.Down then
	begin
		BlockListDropDown.Down := False;
		BlockListFrm.Hide;
	end else
	begin
		AdjustBlockListPosition;
		ShowWindow(BlockListFrm.Handle, SW_SHOWNOACTIVATE);
		BlockListFrm.Visible := True;
		BlockListDropDown.Down := True;
	end;
end;

procedure TMainFrm.WMMove(var Message: TMessage);
begin
	if Assigned(BlockListFrm) AND BlockListFrm.Visible then
		AdjustBlockListPosition;
end;
procedure TMainFrm.ZoomInClick(Sender: TObject);
begin
	CurrentEditor.Zoom(1);
end;

procedure TMainFrm.ZoomOutClick(Sender: TObject);
begin
	CurrentEditor.Zoom(-1);
end;

procedure TMainFrm.AdjustBlockListPosition;
var
	APoint: TPoint;
begin
	APoint := GetProperBlockListPosition;
	BlockListFrm.Top := APoint.Y;
	BlockListFrm.Left := APoint.X;
end;
function TMainFrm.GetProperBlockListPosition:TPoint;
begin
	Result.X := 0;
	Result.Y := BlockListDropDown.Height;
	Result := BlockListDropDown.ClientToScreen( Result );
	Result.X := Result.X-BlockListFrm.Width+BlockListDropDown.Width;
end;


procedure TMainFrm.HistoryLogMenuPopup(Sender: TObject);
begin
	mClear.Enabled := TransactionLog.List.Count > 1;
end;

procedure TMainFrm.LayerUpClick(Sender: TObject);
begin
	if MapData.Loaded then
		CurrentEditor.OnMouseWheel(-1);
end;

procedure TMainFrm.LayerDownClick(Sender: TObject);
begin
	if MapData.Loaded then
		CurrentEditor.OnMouseWheel(1);
end;

procedure TMainFrm.MapAttributions1Click(Sender: TObject);
begin
	AttributesFrm.Show;
end;

procedure TMainFrm.MapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
	if MapData.Loaded AND (Button = mbLeft) then
		CurrentEditor.StartDraw;
end;

procedure TMainFrm.MapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
var
	APoint : TPoint;
begin
	if MapData.Loaded then
	begin
		APoint := Map.ControlToBitmap(Point(X,Y));
		CurrentEditor.UpdateMouseCoordination(
			APoint.X*CurrentEditor.Scale,
			APoint.Y*CurrentEditor.Scale
		);
	end;
end;


procedure TMainFrm.MapMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
	if MapData.Loaded then
		CurrentEditor.StopDraw;
end;

procedure TMainFrm.MapMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
	//Handled := CurrentEditor.OnMouseWheel(WheelDelta);
end;

procedure TMainFrm.MapScroll(Sender: TObject);
var
	ShiftX,ShiftY:Single;
begin
	if MapData.Loaded then
	begin
		Map.Layers.GetViewportShift(ShiftX,ShiftY);
		CurrentEditor.OnScroll(
			ShiftX,ShiftY
		);
	end;
end;

procedure TMainFrm.EditorOnError(const Error:String);
begin
	ShowMessage(Error);
end;

procedure TMainFrm.EditorOnUpdateStatus(const Text:String);
begin
	StatusMessage.Caption := Text;
end;

procedure TMainFrm.EditorOnAllowZoomIn(const Allow:Boolean);
begin
	ZoomIn.Enabled := Allow;
end;
procedure TMainFrm.EditorOnAllowZoomOut(const Allow:Boolean);
begin
	ZoomOut.Enabled := Allow;
end;
procedure TMainFrm.EditorOnChangeViewMode(const AMode : TViewMode);
begin
	case AMode of
		vmXY:begin
			ViewXY.Checked := True;
		end;
		vmXZ:begin
			ViewXZ.Checked := True;
		end;
		vmYZ:begin
			ViewYZ.Checked := True;
		end;
	end;
end;
procedure TMainFrm.AcceptFiles( var msg : TMessage );
const
	cnMaxFileNameLen = 255;
var
	acFileName : array [0..cnMaxFileNameLen] of char;
begin

	// query Windows one at a time for the file name
	DragQueryFile( msg.WParam, 0,
			acFileName, cnMaxFileNameLen );

	OpenMap(acFileName);

	// let Windows know that you're done
	DragFinish( msg.WParam );
end;

procedure TMainFrm.OpenMap(const AFileName:String);
begin
	if NOT MapData.Load(AFilename) then
	begin
		MessageBox(Self.Handle,'Failed to load map file','WUT?',0);
	end else
	begin
		Caption := ProgramTitle + ' - ['+ExtractFileName(AFilename)+']';
		Application.Title := Caption;
		TransactionLog.Clear;
		TransactionLog.Add(TTransaction.Create('Open'));
		CurrentEditor.Reload;
		CurrentEditor.Render;
		LayerUP.Enabled := True;
		LayerDown.Enabled := True;
		mSave.Enabled := True;
		mSaveAs.Enabled := True;
		mView.Enabled := True;
		mTools.Enabled := True;
		AttributesFrm.Refresh;
	end;
end;
end.
