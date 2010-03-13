{------------------------------------------------------------------------
NBT reader (and writer).
Copyright (C) 2010 Lin Ling

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------------}
unit NBTReader;

interface

uses
	SysUtils,
	Classes,
	Generics.Collections;

type
	TTag = class;
	TTagClass = class of TTag;
	TCompound = class;
	TNBTReader = class
	private
		fRootCompound	: TCompound;
		fFileName	: String;
		fLoaded		: Boolean;
	public
		property Root : TCompound read fRootCompound;
		property Loaded : Boolean read fLoaded;
		function Load(const FileName:String):Boolean;
		function Save(FileName:String=''):Boolean;
		procedure Unload;
		function ExportToText:String;
		function GetTag(const Key:AnsiString;const SourceTag:TTag = nil):TTag;
		function CreateTag(const Name:AnsiString;const TypeID:Byte;const SourceTag:TTag = nil):TTag;
		constructor Create;
		destructor Destroy;override;
	end;
	TTag = class
	public
		Name : AnsiString;
		Parent : TTag;
		procedure Add(const AName : AnsiString;const ATag: TTag);virtual;
		function Get(const AName : AnsiString):TTag;virtual;
		constructor Create(const AName:AnsiString;const AParent:TTag);
	end;
	TTagList = class(TTag)
	public
		TagID : Byte;
		List : TObjectList<TTag>;
		procedure Add(const AName : AnsiString;const ATag: TTag);override;
		constructor Create(const AName:AnsiString;const AParent:TTag);
		destructor Destroy;override;
	end;
	TTagByte = class(TTag)
	public
		Value : Byte;
	end;
	TTagShort = class(TTag)
	public
		Value : SmallInt;
	end;
	TTagInt = class(TTag)
	public
		Value : Integer;
	end;
	TTagLong = class(TTag)
	public
		Value : Int64;
	end;
	TTagFloat = class(TTag)
	public
		Value : Single;
	end;
	TTagDouble = class(TTag)
	public
		Value : Double;
	end;
	TTagByteArray = class(TTag)
	public
		Data : TMemoryStream;
		constructor Create(const AName:AnsiString;const AParent:TTag);
		destructor Destroy;override;
	end;
	TTagString = class(TTag)
	public
		Value : AnsiString;
	end;
	//Sequential list container
	TCompound = class(TTag)
	public
		List : TDictionary<AnsiString, TTag>;
		procedure Clear;
		procedure Add(const AName : AnsiString;const ATag: TTag);override;
		function Get(const AName : AnsiString):TTag;override;
		constructor Create(const AName:AnsiString;const AParent:TTag);
		destructor Destroy;override;
	end;
const
	TTags : array[1..10] of TTagClass =
		(TTagByte,TTagShort,TTagInt,TTagLong,TTagFloat,TTagDouble,TTagByteArray,
		TTagString,TTagList,TCompound);
implementation

uses
	ZLibExGZ;

function TNBTReader.Load(const FileName:String):Boolean;
var
	AFile : TFileStream;
	AData	: TMemoryStream;
	AType : Byte;
	DataSize : LongWord;
	ATag : TTag;
	TagLen : Word;
	TagName : AnsiString;

	function Parse(const TagOverride:Byte=0):Byte;
		procedure ParseTagList;
		var
			TagID:Byte;
			Tags : LongWord;
			Index : LongWord;
		begin
			ATag := TTagList.Create(TagName,ATag);
			AData.Read(TagID,1);
			AData.Read(Tags,4);
			Tags := Swap(Tags shr 16) or (Swap(Tags and $ffff) shl 16);
			TTagList(ATag).List.Capacity := Tags;
			TTagList(ATag).TagID := TagID;
			for Index := 1 to Tags do
			begin
				Parse(TagID);
			end;
			ATag := ATag.Parent;
		end;
		procedure ParseShort;
		var
			AShortTag : TTagShort;
		begin
			AShortTag := TTagShort.Create(TagName,ATag);
			AData.Read(AShortTag.Value,2);
			AShortTag.Value := Swap(AShortTag.Value);
		end;
		procedure ParseInt;
		var
			AIntTag : TTagInt;
		begin
			AIntTag := TTagInt.Create(TagName,ATag);
			AData.Read(AIntTag.Value,4);
			AIntTag.Value := Swap(AIntTag.Value shr 16) or (Swap(AIntTag.Value and $ffff) shl 16);
		end;
		procedure ParseLong;
		var
			ALongTag : TTagLong;
			Bytes:array[0..7] of Byte;
			TmpBytes:array[0..7] of Byte;
		begin
			ALongTag := TTagLong.Create(TagName,ATag);
			AData.Read(ALongTag.Value,8);
			Move(ALongTag.Value,TmpBytes[0],8);
			Bytes[0]:=TmpBytes[7];
			Bytes[1]:=TmpBytes[6];
			Bytes[2]:=TmpBytes[5];
			Bytes[3]:=TmpBytes[4];
			Bytes[4]:=TmpBytes[3];
			Bytes[5]:=TmpBytes[2];
			Bytes[6]:=TmpBytes[1];
			Bytes[7]:=TmpBytes[0];
			Move(Bytes[0],ALongTag.Value,8);
		end;
		procedure ParseFloat;
		var
			AFloatTag : TTagFloat;
			AValue : LongWord;
		begin
			AFloatTag := TTagFloat.Create(TagName,ATag);
			AData.Read(AValue,4);
			AValue := Swap(AValue shr 16) or (Swap(AValue and $ffff) shl 16);
			Move(AValue,AFloatTag.Value,4);
		end;
		procedure ParseDouble;
		var
			AValue : Int64;
			Bytes:array[0..7] of Byte;
			TmpBytes:array[0..7] of Byte;
			ADoubleTag : TTagDouble;
		begin
			AData.Read(AValue,8);
			ADoubleTag := TTagDouble.Create(TagName,ATag);
			Move(AValue,TmpBytes[0],8);
			Bytes[0]:=TmpBytes[7];
			Bytes[1]:=TmpBytes[6];
			Bytes[2]:=TmpBytes[5];
			Bytes[3]:=TmpBytes[4];
			Bytes[4]:=TmpBytes[3];
			Bytes[5]:=TmpBytes[2];
			Bytes[6]:=TmpBytes[1];
			Bytes[7]:=TmpBytes[0];
			Move(Bytes[0],ADoubleTag.Value,8);
		end;
		procedure ParseByteArray;
		var
			Len : LongWord;
			AByteArrayTag : TTagByteArray;
		begin
			AData.Read(Len,4);
			Len := Swap(Len shr 16) or (Swap(Len and $ffff) shl 16);
			AByteArrayTag := TTagByteArray.Create(TagName,ATag);
			if Len >0 then
				AByteArrayTag.Data.CopyFrom(AData,Len);
		end;
		procedure ParseString;
		var
			Len : Word;
			AStringTag : TTagString;
		begin
			AData.Read(Len,2);
			Len := Swap(Len);
			AStringTag := TTagString.Create(TagName,ATag);
			if Len >0 then
			begin
				SetLength(AStringTag.Value,Len);
				AData.Read(AStringTag.Value[1],Len);
			end;
		end;
	begin
		if TagOverride = 0 then
		begin
			AData.Read(AType,1);
			if AType > 0 then
			begin
				AData.Read(TagLen,2);
				TagLen := Swap(TagLen);
				SetLength(TagName,TagLen);
				AData.Read(TagName[1],TagLen);
			end;
		end else
			AType := TagOverride;

		Result := AType;
		case AType of
			0:begin //End
				ATag := ATag.Parent;
			end;
			1:begin //Byte
				AData.Read( TTagByte.Create(TagName,ATag).Value, 1);
			end;
			2:begin
				ParseShort;
			end;
			3:begin
				ParseInt;
			end;
			4:begin
				ParseLong;
			end;
			5:begin
				ParseFloat;
			end;
			6:begin
				ParseDouble;
			end;
			7:begin
				ParseByteArray;
			end;
			8:begin
				ParseString;
			end;
			9:begin
				ParseTagList;
			end;
			10:begin
				ATag := TCompound.Create(TagName,ATag);
				while Parse > 0 do;
			end;
		end;
	end;
begin
	fFileName := '';
	if FileExists(FileName) then
	begin
		Result := True;
		Unload;
		AFile := TFileStream.Create(FileName,fmOpenRead OR fmShareDenyWrite);
		try
			AData	:= TMemoryStream.Create;
			try
				GZDecompressStream(AFile,AData);
				AData.Position := 0;
			except
				Result := False;
			end;
			if Result then
			begin
				DataSize := AData.Size;
				ATag := fRootCompound;
				while AData.Position < DataSize do
				begin
					Parse;
				end;
				fLoaded := True;
			end;
			AData.Free;
			fFileName := FileName;
		finally
			AFile.Free;
		end;
	end else
		Result := False;
end;





function TNBTReader.Save(FileName:String=''):Boolean;
var
	AFile : TFileStream;
	AData : TMemoryStream;
	procedure WriteTag(const ID:Byte);
	begin
		AData.Write(ID,1);
	end;
	function GetTagID(const Tag : TTag):Byte;
	var
		Index : Byte;
	begin
		Result := 0;
		for Index := 1 to 10 do
		begin
			if Tag is TTags[Index] then
			begin
				Result := Index;
				Break;
			end;
		end;
	end;
	procedure Dump(const Tag : TTag);
	var
		ATag:TTag;
		ACompound :TCompound;
		ATagList : TTagList;
		TagID : Byte;
		Len : Word;
		Count : LongWord;
		procedure ProcessShort;
		var
			AValue : SmallInt;
		begin
			AValue := Swap(TTagShort(ATag).Value);
			AData.Write(AValue,2);
		end;
		procedure ProcessInt;
		var
			AValue : Integer;
		begin
			AValue := TTagInt(ATag).Value;
			AValue := Swap(AValue shr 16) or (Swap(AValue and $ffff) shl 16);
			AData.Write(AValue,4);
		end;
		procedure ProcessLong;
		var
			AValue : Int64;
			Bytes:array[0..7] of Byte;
			TmpBytes:array[0..7] of Byte;
		begin
			AValue := TTagLong(ATag).Value;
			Move(AValue,TmpBytes[0],8);
			Bytes[0]:=TmpBytes[7];
			Bytes[1]:=TmpBytes[6];
			Bytes[2]:=TmpBytes[5];
			Bytes[3]:=TmpBytes[4];
			Bytes[4]:=TmpBytes[3];
			Bytes[5]:=TmpBytes[2];
			Bytes[6]:=TmpBytes[1];
			Bytes[7]:=TmpBytes[0];
			Move(Bytes[0],AValue,8);
			AData.Write(AValue,8);
		end;
		procedure ProcessFloat;
		var
			AValue : LongWord;
		begin
			Move(TTagFloat(ATag).Value,AValue,4);
			AValue := Swap(AValue shr 16) or (Swap(AValue and $ffff) shl 16);
			AData.Write(AValue,4);
		end;
		procedure ProcessDouble;
		var
			AValue : Int64;
			Bytes:array[0..7] of Byte;
			TmpBytes:array[0..7] of Byte;
		begin
			Move(TTagDouble(ATag).Value,TmpBytes[0],8);
			Bytes[0]:=TmpBytes[7];
			Bytes[1]:=TmpBytes[6];
			Bytes[2]:=TmpBytes[5];
			Bytes[3]:=TmpBytes[4];
			Bytes[4]:=TmpBytes[3];
			Bytes[5]:=TmpBytes[2];
			Bytes[6]:=TmpBytes[1];
			Bytes[7]:=TmpBytes[0];
			Move(Bytes[0],AValue,8);
			AData.Write(AValue,8);
		end;
		procedure ProcessByteArray;
		var
			Len : LongWord;
		begin
			Len := TTagByteArray(ATag).Data.Size;
			Len := Swap(Len shr 16) or (Swap(Len and $ffff) shl 16);
			AData.Write(Len,4);
			TTagByteArray(ATag).Data.Position := 0;
			if Len >0 then
				AData.CopyFrom(TTagByteArray(ATag).Data,TTagByteArray(ATag).Data.Size);
		end;
		procedure ProcessString;
		var
			Len : Word;
		begin
			Len := Swap(Length(TTagString(ATag).Value));
			AData.Write(Len,2);
			AData.Write(TTagString(ATag).Value[1],Length(TTagString(ATag).Value));
		end;
		procedure Process;
		begin
			case TagID of
				1:begin //Byte
					AData.Write(TTagByte(ATag).Value, 1);
				end;
				2:begin
					ProcessShort;
				end;
				3:begin
					ProcessInt;
				end;
				4:begin
					ProcessLong;
				end;
				5:begin
					ProcessFloat;
				end;
				6:begin
					ProcessDouble;
				end;
				7:begin
					ProcessByteArray;
				end;
				8:begin
					ProcessString;
				end;
				9,10:begin
					Dump(ATag);
				end;
			end;
		end;
	begin
		if Tag is TCompound then
		begin
			ACompound := TCompound(Tag);
			for ATag in ACompound.List.Values do
			begin
				TagID := GetTagID(ATag);
				Len := Length(ATag.Name);
				if TagID > 0 then
				begin
					WriteTag(TagID);
					Len := Swap(Len);
					AData.Write(Len,2);
					Len := Swap(Len);

					AData.Write(ATag.Name[1],Len);

					Process;
				end;
			end;
			TagID := 0;
			AData.Write(TagID,1);
		end else
		if Tag is TTagList then
		begin
			ATagList := TTagList(Tag);
			TagID := ATagList.TagID;
			WriteTag(ATagList.TagID);

			Count := ATagList.List.Count;
			Count := Swap(Count shr 16) or (Swap(Count and $ffff) shl 16);
			AData.Write(Count,4);
			for ATag in ATagList.List do
			begin
				Process;
			end;
		end;
	end;
begin
	Result := True;
	if FileName = '' then
		FileName := fFileName;
	AFile := nil;
	AData := TMemoryStream.Create;
	try
		AFile := TFileStream.Create(FileName,fmCreate);
		Dump(fRootCompound);
		AData.Position :=0;

		GZCompressStream(AData,AFile);
	except
		Result := False;
	end;
	if Assigned(AFile) then
		AFile.Free;
	AData.Free;
end;
procedure TNBTReader.Unload;
begin
	fRootCompound.Clear;
end;
function TNBTReader.ExportToText:String;
var
	Indent : Word;
	function GetIndent:String;
	var
		Index:Word;
	begin
		Result := '';
		if Indent > 0 then
			for Index := 1 to Indent do
				Result := Result + '    ';
	end;
	procedure Parse(const Tag : TTag);
	var
		ATag:TTag;
		ACompound :TCompound;
		ATagList : TTagList;
	begin
		if Tag is TCompound then
		begin
			ACompound := TCompound(Tag);
			for ATag in ACompound.List.Values do
			begin
				if ATag is TCompound then
				begin
					Result := Result+GetIndent+'TAG_Compound("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TCompound(ATag).List.Count)+' entries';
					Result := Result+#13#10+GetIndent+'{'#13#10;
					Inc(Indent);
					Parse(ATag);
					Dec(Indent);
					Result := Result+#13#10+GetIndent+'}'#13#10;
				end else
				if ATag is TTagList then
				begin
					Result := Result+GetIndent+'TAG_List("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TTagList(ATag).List.Count)+' entries';
					Result := Result+#13#10+GetIndent+'{'#13#10;
					Inc(Indent);
					Parse(ATag);
					Dec(Indent);
					Result := Result+#13#10+GetIndent+'}'#13#10;
				end;
				if ATag is TTagString then
				begin
					Result := Result+GetIndent+'TAG_String("'+UnicodeString(ATag.Name)+'"): '+UnicodeString(TTagString(ATag).Value)+#13#10;
				end else
				if ATag is TTagByte then
				begin
					Result := Result+GetIndent+'TAG_Byte("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TTagByte(ATag).Value)+#13#10;
				end else
				if ATag is TTagShort then
				begin
					Result := Result+GetIndent+'TAG_Short("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TTagShort(ATag).Value)+#13#10;
				end else
				if ATag is TTagInt then
				begin
					Result := Result+GetIndent+'TAG_Int("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TTagInt(ATag).Value)+#13#10;
				end else
				if ATag is TTagLong then
				begin
					Result := Result+GetIndent+'TAG_Long("'+UnicodeString(ATag.Name)+'"): '+IntToStr(TTagLong(ATag).Value)+#13#10;
				end else
				if ATag is TTagFloat then
				begin
					Result := Result+GetIndent+'TAG_Float("'+UnicodeString(ATag.Name)+'"): '+FloatToStr(TTagFloat(ATag).Value)+#13#10;
				end else
				if ATag is TTagDouble then
				begin
					Result := Result+GetIndent+'TAG_Double("'+UnicodeString(ATag.Name)+'"): '+FloatToStr(TTagDouble(ATag).Value)+#13#10;
				end else
				if ATag is TTagByteArray then
				begin
					Result := Result+GetIndent+'TAG_ByteArray("'+UnicodeString(ATag.Name)+'")'{: ByteArray cannot be displayed ATM'}+#13#10;
				end;
			end;
		end else
		if Tag is TTagList then
		begin
			ATagList := TTagList(Tag);
			for ATag in ATagList.List do
			begin
				if ATag is TCompound then
				begin
					Result := Result+GetIndent+'TAG_Compound: '+IntToStr(TCompound(ATag).List.Count)+' entries';
					Result := Result+#13#10+GetIndent+'{'#13#10;
					Inc(Indent);
					Parse(ATag);
					Dec(Indent);
					Result := Result+#13#10+GetIndent+'}'#13#10;
				end else
				if ATag is TTagList then
				begin
					Result := Result+GetIndent+'TAG_List: '+IntToStr(TTagList(ATag).List.Count)+' entries';
					Result := Result+#13#10+GetIndent+'{'#13#10;
					Inc(Indent);
					Parse(ATag);
					Dec(Indent);
					Result := Result+#13#10+GetIndent+'}'#13#10;
				end;
				if ATag is TTagString then
				begin
					Result := Result+GetIndent+'TAG_String: '+UnicodeString(TTagString(ATag).Value)+#13#10;
				end else
				if ATag is TTagByte then
				begin
					Result := Result+GetIndent+'TAG_Bytet: '+IntToStr(TTagByte(ATag).Value)+#13#10;
				end else
				if ATag is TTagShort then
				begin
					Result := Result+GetIndent+'TAG_Short: '+IntToStr(TTagShort(ATag).Value)+#13#10;
				end else
				if ATag is TTagInt then
				begin
					Result := Result+GetIndent+'TAG_Int: '+IntToStr(TTagInt(ATag).Value)+#13#10;
				end else
				if ATag is TTagLong then
				begin
					Result := Result+GetIndent+'TAG_Int: '+IntToStr(TTagLong(ATag).Value)+#13#10;
				end else
				if ATag is TTagFloat then
				begin
					Result := Result+GetIndent+'TAG_Float: '+FloatToStr(TTagFloat(ATag).Value)+#13#10;
				end else
				if ATag is TTagDouble then
				begin
					Result := Result+GetIndent+'TAG_Double: '+FloatToStr(TTagDouble(ATag).Value)+#13#10;
				end else
				if ATag is TTagByteArray then
				begin
					Result := Result+GetIndent+'TAG_ByteArray'{: ByteArray cannot be displayed ATM'}+#13#10;
				end;
			end;
		end;
	end;
begin
	Indent := 0;
	Parse(fRootCompound);
end;
function TNBTReader.GetTag(const Key:AnsiString;const SourceTag:TTag = nil):TTag;
var
	//TODO:Replace this
	AList : TStringList;
	Index : Byte;
	ATag : TTag;
begin
	AList := TStringList.Create;
	try
		AList.Delimiter := ':';
		AList.DelimitedText := UnicodeString(Key);
		if NOT Assigned(SourceTag) then
			ATag := fRootCompound
		else
			ATag := SourceTag;
		for Index := 0 to AList.Count - 1 do
		begin
			if NOT Assigned(ATag) then
				Break;
			ATag := ATag.Get(AnsiString(AList[Index]));
		end;
		Result := ATag;
	finally
		AList.Free;
	end;
end;
function TNBTReader.CreateTag(const Name:AnsiString;const TypeID:Byte;const SourceTag:TTag = nil):TTag;
var
	ATag : TTag;
begin
	ATag := SourceTag;
	Result := nil;
	if NOT Assigned(ATag) then
		ATag := Root;
	case TypeID of
		1:begin //Byte
			Result := TTagByte.Create(Name,ATag);
		end;
		2:begin
			Result := TTagShort.Create(Name,ATag);
		end;
		3:begin
			Result := TTagInt.Create(Name,ATag);
		end;
		4:begin
			Result := TTagLong.Create(Name,ATag);
		end;
		5:begin
			Result := TTagFloat.Create(Name,ATag);
		end;
		6:begin
			Result := TTagDouble.Create(Name,ATag);
		end;
		7:begin
			Result := TTagByteArray.Create(Name,ATag);
		end;
		8:begin
			Result := TTagString.Create(Name,ATag);
		end;
		9:begin
			Result := TTagList.Create(Name,ATag);
		end;
		10:begin
			Result := TCompound.Create(Name,ATag);
		end;
	end;
end;
constructor TNBTReader.Create;
begin
	inherited;
	fRootCompound := TCompound.Create('_ROOT_',nil);
end;
destructor TNBTReader.Destroy;
begin
	fRootCompound.Free;
	inherited;
end;


procedure TTag.Add(const AName: AnsiString; const ATag: TTag);
begin
end;
function TTag.Get(const AName : AnsiString):TTag;
begin
	Result := nil;
end;
constructor TTag.Create(const AName:AnsiString;const AParent:TTag);
begin
	inherited Create;
	Name := AName;
	Parent := AParent;
	if Assigned(Parent) then
		Parent.Add(Name,Self);
end;

procedure TTagList.Add(const AName: AnsiString; const ATag: TTag);
begin
	List.Add(ATag);
end;
constructor TTagList.Create(const AName:AnsiString;const AParent:TTag);
begin
	inherited Create(AName,AParent);
	List := TObjectList<TTag>.Create(True);
end;
destructor TTagList.Destroy;
begin
	List.Free;
	inherited;
end;


constructor TTagByteArray.Create(const AName: AnsiString; const AParent: TTag);
begin
	inherited Create(AName,AParent);
	Data := TMemoryStream.Create;
end;
destructor TTagByteArray.Destroy;
begin
	Data.Free;
	inherited;
end;


procedure TCompound.Clear;
var
	ATag : TTag;
begin
	for ATag in List.Values do
	begin
		ATag.Free;
	end;
	List.Clear;
end;
procedure TCompound.Add(const AName: AnsiString; const ATag: TTag);
begin
	List.Add(AName,ATag);
end;
function TCompound.Get(const AName : AnsiString):TTag;
begin
	if NOT List.TryGetValue(AName,Result) then
		Result := nil;
end;
constructor TCompound.Create(const AName:AnsiString;const AParent:TTag);
begin
	inherited Create(AName,AParent);
	List := TDictionary<AnsiString,TTag>.Create;
end;
destructor TCompound.Destroy;
begin
	Clear;
	List.Free;
	inherited;
end;
end.