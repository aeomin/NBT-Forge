unit BlockOptions;

interface
uses
	Classes,
	IniFiles;

type
	TBlockOptions = class(TMemIniFile)
	private
		fBlocks : Byte;

	public
		Names : TStringList;
		property Blocks : Byte read fBlocks;

		procedure Load;
		constructor Create(const FileName: string);
		destructor Destroy;override;
	end;


implementation
uses
	SysUtils,
	Math;


procedure TBlockOptions.Load;
var
	Section    : TStringList;
	Index : Byte;
begin
	Section    := TStringList.Create;

	Section.QuoteChar := '"';
	Section.Delimiter := ',';

	ReadSectionValues('General', Section);
	fBlocks := EnsureRange(StrToIntDef(Section.Values['Count'] ,54), 0, High(Byte));

	ReadSectionValues('Names', Section);
	for Index := 0 to Blocks do
	begin
		Names.Add(Section.Values[IntToStr(Index)]);
	end;
	Section.Free;
end;

constructor TBlockOptions.Create(const FileName: string);
begin
	inherited;
	Names := TStringList.Create;
end;
destructor TBlockOptions.Destroy;
begin
	Names.Free;
	inherited;
end;
end.
