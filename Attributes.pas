unit Attributes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzCommon;

type
	TAttributesFrm = class(TForm)
		GroupBox1: TGroupBox;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		GroupBox2: TGroupBox;
		WaterHeight: TRzNumericEdit;
		GroundHeight: TRzNumericEdit;
		Label5: TLabel;
		CloudHeight: TRzNumericEdit;
		Label6: TLabel;
		FogColor: TRzColorEdit;
		Label7: TLabel;
		SkyColor: TRzColorEdit;
		OkayBTN: TButton;
		Button2: TButton;
		Label8: TLabel;
		CloudColor: TRzColorEdit;
		WaterType: TComboBox;
		GroundType: TComboBox;
		procedure FormShow(Sender: TObject);
		procedure Button2Click(Sender: TObject);
		procedure OkayBTNClick(Sender: TObject);
	private
		{ Private declarations }
	public
		procedure Refresh;
	end;

var
	AttributesFrm: TAttributesFrm;

implementation

{$R *.dfm}

uses
	Globals,
	NBTReader;

function GetColor(const Color:TColor):Integer;
var
	RGBColor : Integer;
begin
	RGBColor := ColorToRGB(Color);
	Result := (RGBColor shr 16) OR
	(((RGBColor AND $FFFF) shr 8)shl 8)OR
	((RGBColor AND $FF)shl 16);
end;
procedure TAttributesFrm.Button2Click(Sender: TObject);
begin
	Close;
end;

procedure TAttributesFrm.FormShow(Sender: TObject);
begin
	Refresh;
end;
procedure TAttributesFrm.OkayBTNClick(Sender: TObject);
var
	ATag : TTag;
begin
	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingWaterHeight');
	TTagShort(ATag).Value := WaterHeight.IntValue;

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingGroundHeight');
	TTagShort(ATag).Value := GroundHeight.IntValue;

	ATag := MapData.GetTag('MinecraftLevel:Environment:CloudHeight');
	TTagShort(ATag).Value := CloudHeight.IntValue;

	ATag := MapData.GetTag('MinecraftLevel:Environment:FogColor');
	TTagInt(ATag).Value := GetColor(FogColor.SelectedColor);

	ATag := MapData.GetTag('MinecraftLevel:Environment:SkyColor');
	TTagInt(ATag).Value := GetColor(SkyColor.SelectedColor);

	ATag := MapData.GetTag('MinecraftLevel:Environment:CloudColor');
	TTagInt(ATag).Value := GetColor(CloudColor.SelectedColor);

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingWaterType');
	TTagByte(ATag).Value := WaterType.ItemIndex;

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingGroundType');
	TTagByte(ATag).Value := GroundType.ItemIndex;

	Close;
end;


procedure TAttributesFrm.Refresh;
var
	ATag : TTag;
begin
	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingWaterHeight');
	WaterHeight.IntValue := TTagShort(ATag).Value;

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingGroundHeight');
	GroundHeight.IntValue := TTagShort(ATag).Value;

	ATag := MapData.GetTag('MinecraftLevel:Environment:CloudHeight');
	CloudHeight.IntValue := TTagShort(ATag).Value;

	ATag := MapData.GetTag('MinecraftLevel:Environment:FogColor');
	FogColor.SelectedColor := GetColor(TTagInt(ATag).Value);

	ATag := MapData.GetTag('MinecraftLevel:Environment:SkyColor');
	SkyColor.SelectedColor := GetColor(TTagInt(ATag).Value);

	ATag := MapData.GetTag('MinecraftLevel:Environment:CloudColor');
	CloudColor.SelectedColor := GetColor(TTagInt(ATag).Value);

	WaterType.Items.Assign(BlockSettings.Names);
	GroundType.Items.Assign(BlockSettings.Names);

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingWaterType');
	WaterType.ItemIndex := TTagByte(ATag).Value;

	ATag := MapData.GetTag('MinecraftLevel:Environment:SurroundingGroundType');
	GroundType.ItemIndex := TTagByte(ATag).Value;
end;
end.
