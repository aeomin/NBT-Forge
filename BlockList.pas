unit BlockList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, BlockOptions,ContNrs, Generics.Collections;

type
	TBlockListFrm = class(TForm)
		ListHolder: TScrollBox;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure FormShow(Sender: TObject);
	private
		Images : TObjectList<TPNGImage>;
		Objects : TObjectList;
		PerRow : LongWord;
		procedure GenerateList;
		procedure FindBlockColors;
	protected
		procedure CreateParams(var Params: TCreateParams); override;
		procedure DoSelectBlock(Sender: TObject);
	public

	end;

var
	BlockListFrm: TBlockListFrm;

implementation

{$R *.dfm}

uses
	GR32,
	Main,
	Globals;

procedure TBlockListFrm.CreateParams(var Params: TCreateParams);
begin
	//BorderStyle := bsNone;
	inherited;
	Params.ExStyle := Params.ExStyle or WS_EX_STATICEDGE;
	Params.Style := Params.Style or WS_SIZEBOX;
end;
procedure TBlockListFrm.FormCreate(Sender: TObject);
var
	Index : LongWord;
	APNG : TPNGImage;
begin
	BlockSettings := TBlockOptions.Create(AppPath+'Blocks.ini');
	BlockSettings.Load;

	Objects := TObjectList.Create(True);
	Images := TObjectList<TPNGImage>.Create(True);
	Images.Capacity := BlockSettings.Blocks;
	for Index := 0 to BlockSettings.Blocks do
	begin
		if FileExists(AppPath+'Blocks\'+IntToStr(Index)+'.png') then
		begin
			APNG := TPNGImage.Create;
			APNG.LoadFromFile(AppPath+'Blocks\'+IntToStr(Index)+'.png');
			Images.Add(APNG);
		end else
		begin
			Showmessage('Blocks\'+IntToStr(Index)+'.png does not exist!');
		end;
	end;
	BlockColors.Capacity := BlockSettings.Blocks;
	FindBlockColors;
end;

procedure TBlockListFrm.FormDestroy(Sender: TObject);
begin
	Images.Free;
	Objects.Free;
	BlockSettings.Free;
end;
procedure TBlockListFrm.GenerateList;
var
	AImage : TImage;
	Index : LongWord;
	Count : LongWord;
	ATop : LongWord;
	ALeft : LongWord;
begin
	Count := (ListHolder.Width - GetSystemMetrics(SM_CXVSCROLL)) div 48;
	if Count <> PerRow then
	begin
		PerRow := Count;
		Objects.Clear;
		Count := 1;
		ATop := 16;
		ALeft := 16;
		for Index := 0 to BlockSettings.Blocks do
		begin
			if Count > PerRow then
			begin
				Count := 1;
				Inc(ATop,48);
				ALeft := 16;
			end;
			AImage := TImage.Create(ListHolder);
			AImage.Height := 32;
			AImage.Width := 32;
			AImage.Top := ATop;
			AImage.Left := ALeft;
			AImage.Parent := ListHolder;
			AImage.Picture.Assign(Images[Index]);
			AImage.Cursor := NIDC_HAND;
			AImage.Name := 'bli_'+IntToStr(Index);
			AImage.OnClick := DoSelectBlock;
			AImage.ShowHint := True;
			AImage.Hint := BlockSettings.Names[Index];
			Objects.Add(AImage);
			Inc(Count);
			Inc(ALeft, 48);
		end;
	end;
end;
procedure TBlockListFrm.FindBlockColors;
var
	Index : LongWord;
	APNG : TPNGImage;
	IndexX,IndexY:Byte;
	AColor : TColor;
	R,G,B : LongWord;
	Count : LongWord;
	Alpha:pngimage.pByteArray;
begin
	BlockColors.Capacity := BlockSettings.Blocks;
	for Index := 0 to BlockSettings.Blocks do
	begin
		APNG := Images[Index];
		R:=0;
		G:=0;
		B:=0;
		Count := 0;
		for IndexX := 0 to 31 do
		begin
			for IndexY := 0 to 31 do
			begin
				Alpha := APNG.AlphaScanline[IndexY];
				AColor := ColorToRGB(APNG.Pixels[IndexX,IndexY]);
				if (Assigned(Alpha) AND (Alpha[IndexX] > 0)) OR ( (NOT Assigned(Alpha)) AND (AColor <> APNG.TransparentColor)) then
				begin
					R := R + GetRValue(AColor);
					G := G + GetGValue(AColor);
					B := B + GetBValue(AColor);
					Inc(Count);
				end{ else
				begin
					R := R + 255;
					G := G + 255;
					B := B + 255;
				end};
			end;
		end;
		BlockColors.Add(Color32(R div Count,G div Count, B div Count));
	end;
end;
procedure TBlockListFrm.DoSelectBlock(Sender: TObject);
var
	AImage : TImage;
	BlockID : Word;
	TmpName :String;
begin
	AImage := TImage(Sender);
	Self.Hide;
	MainFrm.BlockListDropDown.Down := False;
	TmpName := AImage.Name;
	Delete(TmpName,1,4);
	BlockID := StrToIntDef(TmpName,0);
	MainFrm.CurrentBlockImage.Picture.Assign(Images[BlockID]);
	MainFrm.CurrentBlockName.Caption := BlockSettings.Names[BlockID];

	DefaultEditor.Block := BlockID;
	CurrentBlock := BlockID;
end;
procedure TBlockListFrm.FormResize(Sender: TObject);
begin
	GenerateList;
end;

procedure TBlockListFrm.FormShow(Sender: TObject);
begin
	GenerateList;
	Application.HintPause:=10;
end;

end.
