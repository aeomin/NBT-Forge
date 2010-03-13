unit HistoryLog;

interface

uses
	Generics.Collections,
	RzLstBox;

type
	TTransactionItem = class
	public
		X,Y,Z:Integer;
		FromID,ToID:Byte;
	end;
	TTransaction = class
	public
		Name : String;
		List : TObjectList<TTransactionITem>;
		procedure Add(const X,Y,Z:Integer;const FromID,ToID:Byte);
		constructor Create(const AName : String);
		destructor Destroy;override;
	end;
	THistoryLog = class
	private
		fListBox : TRzListBox;
		fLastIndex:Integer;
		procedure OnClick(Sender: TObject);
		procedure RevertTo(const Position:Integer);
	public
		List : TObjectList<TTransaction>;
		procedure Add(const ATransaction : TTransaction);
		procedure Clear;
		procedure Undo;
		constructor Create(const AListBox : TRzListBox);
		destructor Destroy;override;
	end;
implementation

uses
	SysUtils,
	Globals,
	Main;

procedure TTransaction.Add(const X,Y,Z:Integer;const FromID,ToID:Byte);
var
	AnItem : TTransactionItem;
begin
	if FromID <> ToID then
	begin
		AnItem := TTransactionItem.Create;
		AnItem.X := X;
		AnItem.Y := Y;
		AnItem.Z := Z;
		AnItem.FromID := FromID;
		AnItem.ToID := ToID;
		List.Add(AnItem);
	end;
end;
constructor TTransaction.Create(const AName : String);
begin
	inherited Create;
	List := TObjectList<TTransactionITem>.Create(True);
	Name := AName;
end;
destructor TTransaction.Destroy;
begin
	List.Free;
	inherited;
end;

procedure THistoryLog.Add(const ATransaction : TTransaction);
var
	Index : Integer;
begin
	if fListBox.ItemIndex < List.Count - 1 then
	begin
		for Index := List.Count - 1 downto fListBox.ItemIndex + 1 do
		begin
			List.Delete(Index);
			fListBox.Delete(Index);
		end;
	end;
	List.Add(ATransaction);
	fListBox.Add(ATransaction.Name);
	fListBox.ItemIndex := List.Count -1;
	fLastIndex := List.Count -1;
	//Meh...
	MainFrm.mUndo.Enabled := List.Count > 1;
end;
procedure THistoryLog.Clear;
begin
	fListBox.Clear;
	List.Clear;
end;
procedure THistoryLog.RevertTo(const Position:Integer);
var
	Index : Integer;
	AnItem : TTransactionItem;
begin
	if Position < fLastIndex then
	begin
		for Index := fLastIndex downto Position + 1 do
		begin
			for AnItem in List[Index].List do
			begin
				CurrentEditor.SetBlock(AnItem.X,AnItem.Y,AnItem.Z,AnItem.FromID);
			end;
		end;
	end else
	begin
		for Index := fLastIndex to Position do
		begin
			for AnItem in List[Index].List do
			begin
				CurrentEditor.SetBlock(AnItem.X,AnItem.Y,AnItem.Z,AnItem.ToID);
			end;
		end;
	end;
	fLastIndex := Position;
	fListBox.ItemIndex := Position;
	CurrentEditor.Render;
end;
procedure THistoryLog.Undo;
begin
	if fListBox.ItemIndex = List.Count - 1 then
	begin
		RevertTo(fListBox.ItemIndex-1);
	end else
	begin
		RevertTo(List.Count - 1);
	end;
end;
procedure THistoryLog.OnClick(Sender: TObject);
begin
	RevertTo(fListBox.ItemIndex);
end;

constructor THistoryLog.Create(const AListBox : TRzListBox);
begin
	inherited Create;
	List := TObjectList<TTransaction>.Create(True);
	fListBox := AListBox;
	fListBox.Clear;
	fListBox.OnClick := OnClick;
end;

destructor THistoryLog.Destroy;
begin
	List.Free;
	inherited;
end;
end.