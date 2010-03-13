unit Globals;

interface

uses
	Windows,
	Generics.Collections,
	NBTReader,
	HistoryLog,
	BlockOptions,
	Controller,
	DefaultController;

var
	AppPath : String;
	MapData : TNBTReader;
	DefaultEditor : TDefaultController;
	CurrentEditor : TController;

	BlockColors : TList<LongWord>;
	BlockSettings : TBlockOptions;

	CurrentBlock:Byte;
	CurrentView : TViewMode;//darn hack

	TransactionLog : THistoryLog;
const
	NIDC_HAND = 32649;
	IDC_HAND = MakeIntResource(NIDC_HAND);
	ProgramTitle = 'NBT Forge 0.1.11';

function Distance(DeltaX,DeltaY,DeltaZ:Integer):Single;
procedure FixChest(const X,Y,Z:Word);

implementation
uses
	Forms;

function Distance(DeltaX,DeltaY,DeltaZ:Integer):Single;
begin
	//Square costs!
	Result := DeltaX*DeltaX+DeltaY*DeltaY+DeltaZ*DeltaZ;
	asm
		rsqrtss xmm0, [Result]
		rcpss xmm0, xmm0
		movss [Result], xmm0
	end;
end;

procedure FixChest(const X,Y,Z:Word);
var
	ATag : TTag;
	ATagList : TTagList;
	ACompound : TCompound;
	AChestProp : TTag;
	ChestPos : Integer;
	Index : Integer;
	Found : Boolean;
begin
	ChestPos := X + Z*1024+Y*1024*1024;
	Found := False;
	ATag := MapData.GetTag('MinecraftLevel:TileEntities');
	if NOT Assigned(ATag) then
	begin
		ATag := MapData.CreateTag('TileEntities',9,MapData.GetTag('MinecraftLevel'));
		TTagList(ATag).TagID := 10;
	end;
	ATagList := TTagList(ATag);
	for Index := ATagList.List.Count -1 downto 0 do
	begin
		ATag := ATagList.List[Index];
		ACompound := TCompound(ATag);
		AChestProp := MapData.GetTag('id',ACompound);
		if Assigned(AChestProp) AND
		(AChestProp is TTagString)AND
		(TTagString(AChestProp).Value = 'Chest') then
		begin
			AChestProp := MapData.GetTag('Pos',ACompound);
			if Assigned(AChestProp) AND
			(AChestProp is TTagInt)AND
			(TTagInt(AChestProp).Value = ChestPos) then
			begin
				Found := True;
				Break;
			end;
		end;
	end;
	if NOT Found then
	begin
		ACompound := TCompound.Create('',ATagList);
		TTagString.Create('id',ACompound).Value := 'Chest';
		TTagInt.Create('Pos',ACompound).Value := ChestPos;
		TTagList.Create('Items',ACompound).TagID := 10;
	end;
end;
initialization
	Screen.Cursors[NIDC_HAND] := LoadCursor(0, IDC_HAND);
	MapData := TNBTReader.Create;
	BlockColors := TList<LongWord>.Create;
finalization
	MapData.Free;
	BlockColors.Free;
end.