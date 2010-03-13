unit Controller;

interface

uses
	Types,
	RzTabs,
	GR32_Layers,
	GR32_Image,
	ToolManager,
	NBTReader;
type
	TViewMode = (vmXY,vmXZ,vmYZ);
	TOnErrorCallback = procedure(const Error:String) of object;
	TOnUpdateStatus = procedure(const Text:String) of object;
	TOnAllowZoom = procedure(const Allow:Boolean) of object;
	TOnChangeViewMode = procedure(const AMode : TViewMode) of object;

	TController = class
	protected
		fImage : TImgView32;
		fMapData : TNBTReader;

		fViewMode : TViewMode;
		fCurrentBlock : Byte;
		fScale : Byte;
		fPanel : TRzPageControl;
		fTools : TToolManager;
		fShowGrid : Boolean;

		fGrid : TBitmapLayer;
		fToolHelper : TBitmapLayer;

		//Layer can be X,Y or Z depends on view mode
		fCurrentLayer : Integer;
		procedure SetViewMode(const AValue : TViewMode);virtual;
		procedure SetCurrentLayer(const AValue : Integer);virtual;
		procedure SetBrush(const AValue : Byte);virtual;
		procedure SetShowGrid(const AValue : Boolean);virtual;
		procedure ToolSet(const X,Y,Z:Integer;const ABlock:Byte);virtual;abstract;
	public
		FrameSize : TPoint;
		OnError : TOnErrorCallback;
		OnUpdateStatus : TOnUpdateStatus;
		OnAllowZoomIn : TOnAllowZoom;
		OnAllowZoomOut : TOnAllowZoom;
		OnChangewViewMode : TOnChangeViewMode;
		SizeX,SizeY,SizeZ:Integer;
		property Scale : Byte read fScale;
		property ViewMode : TViewMode read fViewMode write SetViewMode;
		property CurrentLayer : Integer read fCurrentLayer write SetCurrentLayer;
		property Block : Byte read fCurrentBlock write SetBrush;
		property ShowGrid : Boolean read fShowGrid write SetShowGrid;
		function GetBlock(const X,Y,Z:Integer):Byte;virtual;abstract;
		procedure SetBlock(const X,Y,Z:Integer;const ABlock:Byte);virtual;abstract;
		procedure Render;virtual;abstract;
		function OnMouseWheel(const Delta : Integer):Boolean;virtual;abstract;
		procedure UpdateMouseCoordination(const X,Y:Integer);virtual;abstract;
		procedure Reload;virtual;abstract;
		procedure Zoom(const Delta:SmallInt);virtual;abstract;
		procedure StartDraw;virtual;abstract;
		procedure StopDraw;virtual;abstract;
		procedure OnScroll(const ShiftX,ShiftY:Single);virtual;abstract;
		constructor Create(const AnImage : TImgView32;const APanel : TRzPageControl;const AMapData:TNBTReader);virtual;
	end;
implementation

uses
	GR32,
	Globals;

procedure TController.SetViewMode(const AValue : TViewMode);
begin
	fViewMode := AValue;
	CurrentView := AValue;
end;
procedure TController.SetCurrentLayer(const AValue : Integer);
	function VerifyValue(const MaxValue : Integer):Integer;
	begin
		if AValue >= MaxValue then
			Result := 0
		else if AValue < 0 then
			Result := MaxValue-1
		else
			Result := AValue;
	end;
begin
	case ViewMode of
		vmXY:begin
			fCurrentLayer := VerifyValue(SizeZ);
		end;
		vmXZ: begin
			fCurrentLayer := VerifyValue(SizeY);
		end;
		vmYZ: begin
			fCurrentLayer := VerifyValue(SizeX);
		end;
	end;
end;
procedure TController.SetBrush(const AValue : Byte);
begin
	fCurrentBlock := AValue;
end;
procedure TController.SetShowGrid(const AValue : Boolean);
begin
	fShowGrid := AValue;
end;
constructor TController.Create(const AnImage : TImgView32;const APanel : TRzPageControl;const AMapData:TNBTReader);
begin
	inherited Create;
	fImage := AnImage;
	fMapData := AMapData;
	fPanel := APanel;
	fScale := 1;

	fImage.Layers.Clear;

	fGrid := TBitmapLayer.Create(fImage.Layers);
	fGrid.Scaled := False;
	fGrid.Index := 2;
	fGrid.Bitmap.DrawMode := dmBlend;
	//fGrid.Location := GR32.FloatRect(0,0,SizeX*Scale,SizeY*Scale);

	fToolHelper := TBitmapLayer.Create(fImage.Layers);
	fToolHelper.Scaled := True;
	fToolHelper.Index := 3;
	fToolHelper.Bitmap.DrawMode := dmBlend;
end;
end.