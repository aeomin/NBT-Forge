unit DefaultController;

interface

uses
	Windows,
	Classes,
	GR32_Image,
	GR32_Layers,
	RzTabs,
	NBTReader,
	Controller,
	HistoryLog;

type
	TDefaultController = class(TController)
	protected
		fBlocks : TMemoryStream;
		
		fLayerPos :array[TViewMode] of Integer;//Memorize layer

		fMouseX,fMouseY : Integer;
		fDrawing:Boolean;
		fBlockColor : LongWord;

		fTransaction : TTransaction;
		procedure SetCurrentLayer(const AValue : Integer);override;
		procedure UpdateStatus;
		procedure SetViewMode(const AValue : TViewMode);override;
		procedure SetBrush(const AValue : Byte);override;
		procedure GetMousePosition(var X,Y,Z:Integer);
		procedure ToolSet(const X,Y,Z:Integer;const ABlock:Byte);override;
		procedure SetShowGrid(const AValue : Boolean);override;
		procedure AdjustGrid;
	public
		function GetBlock(const X,Y,Z:Integer):Byte;override;
		procedure SetBlock(const X,Y,Z:Integer;const ABlock:Byte);override;
		procedure Reload;override;
		procedure Render;override;
		function OnMouseWheel(const Delta : Integer):Boolean;override;
		procedure UpdateMouseCoordination(const X,Y:Integer);override;
		procedure Zoom(const Delta:SmallInt);override;
		procedure StartDraw;override;
		procedure StopDraw;override;
		procedure Draw;
		procedure OnScroll(const ShiftX,ShiftY:Single);override;
		constructor Create(const AnImage : TImgView32;const APanel : TRzPageControl;const AMapData:TNBTReader);override;
	end;
implementation

uses
	SysUtils,
	Math,
	GR32,
	Globals,
	Tool,
	DefaultToolManager;

const
	MaxZoom=16;

function TDefaultController.GetBlock(const X,Y,Z:Integer):Byte;
var
	P : Pointer;
begin
	Result := 0;
	if (X >=0)AND(X < SizeX) AND
	(Y >=0)AND(Y < SizeY) AND
	(Z >=0)AND(Z < SizeZ) then
	begin
		//Faster way to fetch data!
		P := Pointer(LongWord(fBlocks.Memory) + LongWord((Z * SizeY + Y) * SizeX + X));
		Move(P^, Result, 1);
	end;
end;

procedure TDefaultController.SetBlock(const X,Y,Z:Integer;const ABlock:Byte);
	procedure RemoveChest;
	var
		ATag : TTag;
		ATagList : TTagList;
		ACompound : TCompound;
		AChestProp : TTag;
		ChestPos : Integer;
		Index : Integer;
	begin
		ChestPos := X + Z*1024+Y*1024*1024;
		ATag := fMapData.GetTag('MinecraftLevel:TileEntities');
		if NOT Assigned(ATag) then
		begin
			ATag := fMapData.CreateTag('TileEntities',9,fMapData.GetTag('MinecraftLevel'));
			TTagList(ATag).TagID := 10;
		end;
		ATagList := TTagList(ATag);
		for Index := ATagList.List.Count -1 downto 0 do
		begin
			ATag := ATagList.List[Index];
			ACompound := TCompound(ATag);
			AChestProp := fMapData.GetTag('id',ACompound);
			if Assigned(AChestProp) AND
			(AChestProp is TTagString)AND
			(TTagString(AChestProp).Value = 'Chest') then
			begin
				AChestProp := fMapData.GetTag('Pos',ACompound);
				if Assigned(AChestProp) AND
				(AChestProp is TTagInt)AND
				(TTagInt(AChestProp).Value = ChestPos) then
				begin
					ATagList.List.Delete(Index);
					Break;
				end;
			end;

		end;
	end;
	procedure AddChest;
	var
		ATag : TTag;
		ATagList : TTagList;
		ACompound : TCompound;
		ChestPos : Integer;
	begin
		ChestPos := X + Z*1024+Y*1024*1024;
		ATag := fMapData.GetTag('MinecraftLevel:TileEntities');
		if NOT Assigned(ATag) then
		begin
			ATag := fMapData.CreateTag('TileEntities',9,fMapData.GetTag('MinecraftLevel'));
			TTagList(ATag).TagID := 10;
		end;
		ATagList := TTagList(ATag);
		ACompound := TCompound.Create('',ATagList);
		TTagString.Create('id',ACompound).Value := 'Chest';
		TTagInt.Create('Pos',ACompound).Value := ChestPos;
		TTagList.Create('Items',ACompound).TagID := 10;;
	end;
var
	OldType : Byte;
begin
	OldType := GetBlock(X,Y,Z);
	//Let's fix Chest!
	if (OldType = 54)AND(ABlock<>54) then
	begin
		RemoveChest;
	end else
	if (OldType <> 54) AND (ABlock = 54) then
	begin
		AddChest;
	end;

	Move(ABlock, Pointer(LongWord(fBlocks.Memory) + LongWord((Z * SizeY + Y) * SizeX + X))^, 1);
end;
procedure TDefaultController.SetCurrentLayer(const AValue : Integer);
var
	X,Y,Z:Integer;
begin
	if AValue <> fCurrentLayer then
	begin
		inherited;
		GetMousePosition(X,Y,Z);
		fTools.Refresh(X,Y,Z,Point3(SizeX,SizeY,SizeZ));
		Render;
	end;
end;

procedure TDefaultController.UpdateStatus;
var
	X,Y,Z:Integer;
begin
	GetMousePosition(X,Y,Z);
	OnUpdateStatus(
		'X: '+IntToStr(X)+
		' Y: '+IntToStr(Y)+
		' Z: '+IntToStr(Z) +
		' ['+BlockSettings.Names[
			GetBlock(X,Y,Z)
		]+']'
		);
end;

procedure TDefaultController.SetViewMode(const AValue : TViewMode);
var
	X,Y,Z:Integer;
begin
	fLayerPos[ViewMode] := fCurrentLayer;
	inherited;
	fImage.Scale := 1;

	case AValue of
		vmXY: begin
			fCurrentLayer := fLayerPos[vmXY];
			fImage.Bitmap.SetSize(SizeX,SizeY);
			fGrid.Bitmap.SetSize(SizeX*Scale,SizeY*Scale);
			fToolHelper.Bitmap.SetSize(SizeX,SizeY);
			fToolHelper.Location := GR32.FloatRect(0,0,SizeX,SizeY);

		end;
		vmXZ: begin
			fCurrentLayer :=fLayerPos[vmXZ];
			fImage.Bitmap.SetSize(SizeX,SizeZ);
			fGrid.Bitmap.SetSize(SizeX*Scale,SizeZ*Scale);
			fToolHelper.Bitmap.SetSize(SizeX,SizeZ);
			fToolHelper.Location := GR32.FloatRect(0,0,SizeX,SizeZ);
		end;
		vmYZ: begin
			fCurrentLayer :=fLayerPos[vmYZ];
			fImage.Bitmap.SetSize(SizeY,SizeZ);
			fGrid.Bitmap.SetSize(SizeY*Scale,SizeZ*Scale);
			fToolHelper.Bitmap.SetSize(SizeY,SizeZ);
			fToolHelper.Location := GR32.FloatRect(0,0,SizeY,SizeZ);
		end;
	end;
	GetMousePosition(X,Y,Z);
	fTools.Refresh(X,Y,Z,Point3(SizeX,SizeY,SizeZ));
	UpdateStatus;
	Render;
end;

procedure TDefaultController.SetBrush(const AValue : Byte);
begin
	inherited;
	fBlockColor := BlockColors[AValue];
end;

procedure TDefaultController.GetMousePosition(var X,Y,Z:Integer);
begin
	case ViewMode of
		vmXY:begin
			X := fMouseX div Scale;
			Y := fMouseY div Scale;
			Z := fCurrentLayer;
		end;
		vmXZ:begin
			X := fMouseX div Scale;
			Y := fCurrentLayer;
			Z := SizeZ-1-fMouseY div Scale;
		end;
		vmYZ:begin
			X := fCurrentLayer;
			Y := fMouseX div Scale;
			Z := SizeZ-1-fMouseY div Scale;
		end;
	end;
end;

procedure TDefaultController.ToolSet(const X,Y,Z:Integer;const ABlock:Byte);
var
	OldBlock:Byte;
begin
	if (X >=0) AND (X < SizeX)AND
	(Y>=0)AND (Y< SizeY) AND
	(Z>=0)AND (Z< SizeZ) then
	begin
		OldBlock := GetBlock(X,Y,Z);
		if ABlock <> OldBlock then
		begin
			SetBlock(X,Y,Z,ABlock);
			fTransaction.Add(X,Y,Z,OldBlock,ABlock);
		end;
	end;
end;
procedure TDefaultController.AdjustGrid;
var
	ShiftX,ShiftY: Single;
begin
	fImage.Layers.GetViewportShift(ShiftX,ShiftY);
	case ViewMode of
		vmXY:begin
			fGrid.Location := GR32.FloatRect(ShiftX,ShiftY,SizeX*Scale+ShiftX,SizeY*Scale+ShiftY);
		end;
		vmXZ: begin
			fGrid.Location := GR32.FloatRect(ShiftX,ShiftY,SizeX*Scale+ShiftX,SizeZ*Scale+ShiftY);
		end;
		vmYZ: begin
			fGrid.Location := GR32.FloatRect(ShiftX,ShiftY,SizeY*Scale+ShiftX,SizeZ*Scale+ShiftY);
		end;
	end;
//	fToolHelper.Location := fGrid.Location;
end;
procedure TDefaultController.Reload;
var
	ATag : TTag;
begin
	ATag := fMapData.GetTag('MinecraftLevel:Map:Blocks');
	fBlocks := TTagByteArray(ATag).Data;
	fBlocks.Position := 0;

	ATag := fMapData.GetTag('MinecraftLevel:Map:Width');
	SizeX := TTagShort(ATag).Value;

	ATag := fMapData.GetTag('MinecraftLevel:Map:Length');
	SizeY := TTagShort(ATag).Value;

	ATag := fMapData.GetTag('MinecraftLevel:Map:Height');
	SizeZ := TTagShort(ATag).Value;

	if SizeX > SizeY then
	begin
		fScale := FrameSize.X div SizeX;
	end else
	begin
		fScale := FrameSize.Y div SizeY;
	end;
	fScale := EnsureRange(fScale,1,MaxZoom);

	fCurrentLayer := SizeZ-1;

	OnAllowZoomIn(fScale<MaxZoom);
	OnAllowZoomOut(fScale>1);

	fImage.Bitmap.SetSize(SizeX,SizeY);
	fToolHelper.Bitmap.SetSize(SizeX,SizeY);
	fToolHelper.Location := GR32.FloatRect(0,0,SizeX,SizeY);

	fImage.Scale := fScale;

	fViewMode := vmXY;
	OnChangewViewMode(ViewMode);

	fLayerPos[vmXY] := SizeZ-1;
	fLayerPos[vmXZ] := SizeY-1;
	fLayerPos[vmYZ] := SizeX-1;

	fGrid.Bitmap.SetSize(SizeX*Scale,SizeY*Scale);

end;
procedure TDefaultController.Render;
var
	IndexX,IndexY : Word;
	ABlock : Byte;
	procedure DrawGrid;
	var
		Index : Integer;
		Count : Integer;
	begin
		fGrid.Bitmap.BeginUpdate;
		fGrid.Bitmap.Clear($0);
		Count := fGrid.Bitmap.Width div Scale;
		for Index := 1 to Count do
		begin
			fGrid.Bitmap.VertLineTS(Index*Scale,0,fGrid.Bitmap.Height,$BF000000);
		end;
		Count := fGrid.Bitmap.Height div Scale;
		for Index := 1 to Count do
		begin
			fGrid.Bitmap.HorzLineTS(0,Index*Scale,fGrid.Bitmap.Width,$BF000000);
		end;

		fGrid.Bitmap.EndUpdate;
		fGrid.Bitmap.Changed;
	end;
begin
	fImage.Scale := Scale;
	fImage.Bitmap.BeginUpdate;

	case ViewMode of
		vmXY:begin
			for IndexX := 0 to SizeX - 1 do
			begin
				for IndexY := 0 to SizeY - 1 do
				begin
					ABlock := GetBlock(IndexX,IndexY,CurrentLayer);
					if ABlock >0 then
						fImage.Bitmap.SetPixelT(IndexX,IndexY,BlockColors[ABlock])
					else
						fImage.Bitmap.SetPixelT(IndexX,IndexY,$FFFFFFFF);
				end;
			end;
		end;
		vmXZ:begin
			for IndexX := SizeX - 1 downto 0 do
			begin
				for IndexY := SizeZ - 1 downto 0 do
				begin
					ABlock := GetBlock(IndexX,CurrentLayer,SizeZ-1-IndexY);
					if ABlock >0 then
						fImage.Bitmap.SetPixelT(IndexX,IndexY,BlockColors[ABlock])
					else
						fImage.Bitmap.SetPixelT(IndexX,IndexY,$FFFFFFFF);
				end;
			end;
		end;
		vmYZ:begin
			for IndexX := SizeY - 1 downto 0 do
			begin
				for IndexY := 0 to SizeZ - 1 do
				begin
					ABlock := GetBlock(CurrentLayer,IndexX,SizeZ-1-IndexY);
					if ABlock >0 then
						fImage.Bitmap.SetPixelT(IndexX,IndexY,BlockColors[ABlock])
					else
						fImage.Bitmap.SetPixelT(IndexX,IndexY,$FFFFFFFF);
				end;
			end;
		end;
	end;
	fImage.Bitmap.EndUpdate;
	fImage.Bitmap.Changed;

	if ShowGrid then
	begin
		DrawGrid;
		AdjustGrid;
	end;

	fImage.Refresh;
end;

function TDefaultController.OnMouseWheel(const Delta : Integer):Boolean;
begin
	Result := True;
	//OnUpdateStatus(IntToStr(Delta));
	if Delta > 0 then
		CurrentLayer := CurrentLayer - 1
	else if Delta < 0 then
		CurrentLayer := CurrentLayer + 1;

	UpdateStatus;
end;

procedure TDefaultController.UpdateMouseCoordination(const X,Y:Integer);
var
	mX,mY,mZ : Integer;
begin
	fMouseX := X;
	fMouseY := Y;
	UpdateStatus;
	GetMousePosition(mX,mY,mZ);
	fTools.Refresh(mX,mY,mZ,Point3(SizeX,SizeY,SizeZ));
	if fDrawing then
		Draw;
end;

procedure TDefaultController.Zoom(const Delta:SmallInt);
begin
	fScale := EnsureRange(Scale+Delta,1,MaxZoom);
	OnAllowZoomOut(Scale>1);
	OnAllowZoomIn(Scale<MaxZoom);

	fImage.Scale := 1;
	case ViewMode of
		vmXY:begin
			fImage.Bitmap.SetSize(SizeX,SizeY);
			fGrid.Bitmap.SetSize(SizeX*Scale,SizeY*Scale);
			fToolHelper.Bitmap.SetSize(SizeX,SizeY);
//			fToolHelper.Bitmap.SetSize(SizeX*Scale,SizeY*Scale);
		end;
		vmXZ: begin
			fImage.Bitmap.SetSize(SizeX,SizeZ);
			fGrid.Bitmap.SetSize(SizeX*Scale,SizeZ*Scale);
			fToolHelper.Bitmap.SetSize(SizeX,SizeZ);
//			fToolHelper.Bitmap.SetSize(SizeX*Scale,SizeZ*Scale);
		end;
		vmYZ: begin
			fImage.Bitmap.SetSize(SizeY,SizeZ);
			fGrid.Bitmap.SetSize(SizeY*Scale,SizeZ*Scale);
			fToolHelper.Bitmap.SetSize(SizeY,SizeZ);
//			fToolHelper.Bitmap.SetSize(SizeY*Scale,SizeZ*Scale);
		end;
	end;

	Render;
end;

procedure TDefaultController.StartDraw;
begin
	fDrawing := True;
	fTransaction := TTransaction.Create(fTools.CurrentTool);
	Draw;
end;

procedure TDefaultController.StopDraw;
var
	X,Y,Z : Integer;
begin
	if fDrawing then
	begin
		GetMousePosition(X,Y,Z);
		if (X >=0) AND (X < SizeX) AND
		(Y >=0) AND (Y < SizeY) AND
		(Z >=0) AND (Z < SizeZ) then
		begin
			fTools.Click(X,Y,Z,Point3(SizeX,SizeY,SizeZ));
		end;
		if Assigned(fTransaction) then
		begin
			if fTransaction.List.Count > 0 then
				TransactionLog.Add(fTransaction)
			else
				fTransaction.Free;
			fTransaction:=nil;
		end;
		Render;
		fDrawing := False;
	end;
end;

procedure TDefaultController.Draw;
var
	X,Y,Z : Integer;
begin
	GetMousePosition(X,Y,Z);
	if (X >=0) AND (X < SizeX) AND
	(Y >=0) AND (Y < SizeY) AND
	(Z >=0) AND (Z < SizeZ) then
	begin
		fTools.Draw(X,Y,Z,Point3(SizeX,SizeY,SizeZ));
		Render;
	end;
end;

procedure TDefaultController.OnScroll(const ShiftX,ShiftY:Single);
begin
	if ShowGrid then
	begin
		AdjustGrid;
	end;
end;

procedure TDefaultController.SetShowGrid(const AValue : Boolean);
begin
	inherited;
	if NOT AValue then
		fGrid.Bitmap.Clear($0);
	Render;
end;


constructor TDefaultController.Create(const AnImage : TImgView32;const APanel : TRzPageControl;const AMapData:TNBTReader);
begin
	inherited;
	fTools := TDefaultToolManager.Create(APanel,GetBlock,ToolSet,fToolHelper.Bitmap);
	fTools.Init;
end;
end.
