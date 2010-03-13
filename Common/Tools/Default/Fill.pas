unit Fill;

interface

uses
	StdCtrls,
	Types,
	Tool;

type
	TAFill = class(TTool)
	protected
		f2DFill : TRadioButton;
		f3DFill : TRadioButton;
		f2DReplace : TRadioButton;
		f3DReplace : TRadioButton;
	public
		procedure Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);override;
		function InitGui(const ADesigner : TGUIDesigner):String;override;
		function GetToolName : String;override;
	end;
	TFloodItem = class
	public
		X,Y,Z : Integer;
	end;
implementation

uses
	Generics.Collections,
	ContNrs,
	Globals,
	Controller;

procedure TAFill.Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);
var
	TargetBlock : Byte;
	procedure Fill2D;
	var
		Index : Integer;
		MainIndex : Integer;
		AFloodItem : TFloodItem;
		BFloodItem : TFloodItem;
		AFloodList : TObjectList<TFloodItem>;
		OnLine : Boolean;
		FillL, FillR : Integer;
	begin
		AFloodList := TObjectList<TFloodItem>.Create(True);
		AFloodItem := TFloodItem.Create;
		AFloodItem.X := X;
		AFloodItem.Y := Y;
		AFloodItem.Z := Z;
		AFloodList.Add(AFloodItem);

		case CurrentView of
			vmXY: begin
				while AFloodList.Count > 0 do
				begin
					MainIndex := AFloodList.Count -1;
					AFloodItem := AFloodList[MainIndex];

					FillL := AFloodItem.X;
					FillR := AFloodItem.X;
					OnLine := True;
					while OnLine do
					begin
						fSet(FillL,AFloodItem.Y,Z,CurrentBlock);
						Dec(FillL);
						if FillL < 0 then
							OnLine := False
						else
							OnLine := fGet(FillL,AFloodItem.Y,Z) = TargetBlock;
					end;
					Inc(FillL);
					OnLine := True;

					while OnLine do
					begin
						fSet(FillR,AFloodItem.Y,Z,CurrentBlock);
						Inc(FillR);
						if FillR > Boundary.X-1 then
							OnLine := False
						else
							OnLine := fGet(FillR,AFloodItem.Y,Z) = TargetBlock;
					end;
					Dec(FillR);

					for Index := FillL to FillR do
					begin
						if (AFloodItem.Y > 0) AND (fGet(Index,AFloodItem.Y-1,Z) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := Index;
							BFloodItem.Y := AFloodItem.Y-1;
							BFloodItem.Z := AFloodItem.Z;
							AFloodList.Add(BFloodItem);
						end;
						if (AFloodItem.Y < Boundary.Y-1) AND (fGet(Index,AFloodItem.Y+1,Z) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := Index;
							BFloodItem.Y := AFloodItem.Y+1;
							BFloodItem.Z := AFloodItem.Z;
							AFloodList.Add(BFloodItem);
						end;
					end;
					AFloodList.Delete(MainIndex);
				end;
			end;
			vmXZ: begin
				while AFloodList.Count > 0 do
				begin
					MainIndex := AFloodList.Count -1;
					AFloodItem := AFloodList[MainIndex];

					FillL := AFloodItem.X;
					FillR := AFloodItem.X;
					OnLine := True;
					while OnLine do
					begin
						fSet(FillL,Y,AFloodItem.Z,CurrentBlock);
						Dec(FillL);
						if FillL < 0 then
							OnLine := False
						else
							OnLine := fGet(FillL,Y,AFloodItem.Z) = TargetBlock;
					end;
					Inc(FillL);
					OnLine := True;

					while OnLine do
					begin
						fSet(FillR,Y,AFloodItem.Z,CurrentBlock);
						Inc(FillR);
						if FillR > Boundary.X-1 then
							OnLine := False
						else
							OnLine := fGet(FillR,Y,AFloodItem.Z) = TargetBlock;
					end;
					Dec(FillR);

					for Index := FillL to FillR do
					begin
						if (AFloodItem.Z > 0) AND (fGet(Index,Y,AFloodItem.Z-1) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := Index;
							BFloodItem.Y := AFloodItem.Y;
							BFloodItem.Z := AFloodItem.Z-1;
							AFloodList.Add(BFloodItem);
						end;
						if (AFloodItem.Z < Boundary.Z-1) AND (fGet(Index,Y,AFloodItem.Z+1) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := Index;
							BFloodItem.Y := AFloodItem.Y;
							BFloodItem.Z := AFloodItem.Z+1;
							AFloodList.Add(BFloodItem);
						end;
					end;
					AFloodList.Delete(MainIndex);
				end;
			end;
			vmYZ: begin
				while AFloodList.Count > 0 do
				begin
					MainIndex := AFloodList.Count -1;
					AFloodItem := AFloodList[MainIndex];

					FillL := AFloodItem.Y;
					FillR := AFloodItem.Y;
					OnLine := True;
					while OnLine do
					begin
						fSet(X,FillL,AFloodItem.Z,CurrentBlock);
						Dec(FillL);
						if FillL < 0 then
							OnLine := False
						else
							OnLine := fGet(X,FillL,AFloodItem.Z) = TargetBlock;
					end;
					Inc(FillL);
					OnLine := True;

					while OnLine do
					begin
						fSet(X,FillR,AFloodItem.Z,CurrentBlock);
						Inc(FillR);
						if FillR > Boundary.Y-1 then
							OnLine := False
						else
							OnLine := fGet(X,FillR,AFloodItem.Z) = TargetBlock;
					end;
					Dec(FillR);

					for Index := FillL to FillR do
					begin
						if (AFloodItem.Z > 0) AND (fGet(X,Index,AFloodItem.Z-1) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := AFloodItem.X;
							BFloodItem.Y := Index;
							BFloodItem.Z := AFloodItem.Z-1;
							AFloodList.Add(BFloodItem);
						end;
						if (AFloodItem.Z < Boundary.Z-1) AND (fGet(X,Index,AFloodItem.Z+1) = TargetBlock) then
						begin
							BFloodItem := TFloodItem.Create;
							BFloodItem.X := AFloodItem.X;
							BFloodItem.Y := Index;
							BFloodItem.Z := AFloodItem.Z+1;
							AFloodList.Add(BFloodItem);
						end;
					end;
					AFloodList.Delete(MainIndex);
				end;
			end;
		end;
		AFloodList.Free;
	end;
	procedure Fill3D;
	var
		Index : Integer;
		MainIndex : Integer;
		AFloodItem : TFloodItem;
		BFloodItem : TFloodItem;
		AFloodList : TObjectList<TFloodItem>;
		OnLine : Boolean;
		FillL, FillR : Integer;
	begin
		AFloodList := TObjectList<TFloodItem>.Create(True);
		AFloodItem := TFloodItem.Create;
		AFloodItem.X := X;
		AFloodItem.Y := Y;
		AFloodItem.Z := Z;
		AFloodList.Add(AFloodItem);

		while AFloodList.Count > 0 do
		begin
			MainIndex := AFloodList.Count -1;
			AFloodItem := AFloodList[MainIndex];

			FillL := AFloodItem.X;
			FillR := AFloodItem.X;
			OnLine := True;
			while OnLine do
			begin
				fSet(FillL,AFloodItem.Y,AFloodItem.Z,CurrentBlock);
				Dec(FillL);
				if FillL < 0 then
					OnLine := False
				else
					OnLine := fGet(FillL,AFloodItem.Y,AFloodItem.Z) = TargetBlock;
			end;
			Inc(FillL);
			OnLine := True;

			while OnLine do
			begin
				fSet(FillR,AFloodItem.Y,AFloodItem.Z,CurrentBlock);
				Inc(FillR);
				if FillR > Boundary.X-1 then
					OnLine := False
				else
					OnLine := fGet(FillR,AFloodItem.Y,AFloodItem.Z) = TargetBlock;
			end;
			Dec(FillR);

			for Index := FillL to FillR do
			begin
				if (AFloodItem.Y > 0) AND (fGet(Index,AFloodItem.Y-1,AFloodItem.Z) = TargetBlock) then
				begin
					BFloodItem := TFloodItem.Create;
					BFloodItem.X := Index;
					BFloodItem.Y := AFloodItem.Y-1;
					BFloodItem.Z := AFloodItem.Z;
					AFloodList.Add(BFloodItem);
				end;
				if (AFloodItem.Y < Boundary.Y-1) AND (fGet(Index,AFloodItem.Y+1,AFloodItem.Z) = TargetBlock) then
				begin
					BFloodItem := TFloodItem.Create;
					BFloodItem.X := Index;
					BFloodItem.Y := AFloodItem.Y+1;
					BFloodItem.Z := AFloodItem.Z;
					AFloodList.Add(BFloodItem);
				end;
				if (AFloodItem.Z > 0) AND (fGet(Index,AFloodItem.Y,AFloodItem.Z-1) = TargetBlock) then
				begin
					BFloodItem := TFloodItem.Create;
					BFloodItem.X := Index;
					BFloodItem.Y := AFloodItem.Y;
					BFloodItem.Z := AFloodItem.Z-1;
					AFloodList.Add(BFloodItem);
				end;
				if (AFloodItem.Z < Boundary.Z-1) AND (fGet(Index,AFloodItem.Y,AFloodItem.Z+1) = TargetBlock) then
				begin
					BFloodItem := TFloodItem.Create;
					BFloodItem.X := Index;
					BFloodItem.Y := AFloodItem.Y;
					BFloodItem.Z := AFloodItem.Z+1;
					AFloodList.Add(BFloodItem);
				end;
			end;
			AFloodList.Delete(MainIndex);
		end;
		AFloodList.Free;
	end;
	procedure Replace2D;
	var
		IndexX,IndexY:Integer;
	begin
		case CurrentView of
			vmXY:begin
				for IndexX := Boundary.X - 1 downto 0 do
				begin
					for IndexY := Boundary.Y-1 downto 0 do
					begin
						if fGet(IndexX,IndexY,Z) = TargetBlock then
							fSet(IndexX,IndexY,Z,CurrentBlock);
					end;
				end;
			end;
			vmXZ:begin
				for IndexX := Boundary.X - 1 downto 0 do
				begin
					for IndexY := Boundary.Z-1 downto 0 do
					begin
						if fGet(IndexX,Y,IndexY) = TargetBlock then
							fSet(IndexX,Y,IndexY,CurrentBlock);
					end;
				end;
			end;
			vmYZ:begin
				for IndexX := Boundary.Y - 1 downto 0 do
				begin
					for IndexY := Boundary.Z-1 downto 0 do
					begin
						if fGet(X,IndexX,IndexY) = TargetBlock then
							fSet(X,IndexX,IndexY,CurrentBlock);
					end;
				end;
			end;
		end;
	end;
	procedure Replace3D;
	var
		IndexX,IndexY,IndexZ:Integer;
	begin
		for IndexX := Boundary.X - 1 downto 0 do
		begin
			for IndexY := Boundary.Y-1 downto 0 do
			begin
				for IndexZ := Boundary.Z -1 downto 0 do
				begin
					if fGet(IndexX,IndexY,IndexZ) = TargetBlock then
							fSet(IndexX,IndexY,IndexZ,CurrentBlock);
				end;
			end;
		end;
	end;
begin
	TargetBlock := fGet(X,Y,Z);
	if TargetBlock <> CurrentBlock then
	begin
		if f2DFill.Checked then
			Fill2D
		else if f3DFill.Checked then
			Fill3D
		else if f2DReplace.Checked then
			Replace2D
		else if f3DReplace.Checked then
			Replace3D;
	end;
end;
function TAFill.InitGui(const ADesigner : TGUIDesigner):String;
begin
	Result := 'Fill';

	f2DFill := ADesigner.NewRadio;
	f2DFill.Caption := '2D Flood Fill';
	f2DFill.Checked := True;

	ADesigner.NewLine;

	f3DFill := ADesigner.NewRadio;
	f3DFill.Caption := '3D Flood Fill';

	ADesigner.NewLine;

	f2DReplace := ADesigner.NewRadio;
	f2DReplace.Caption := '2D Replace';

	ADesigner.NewLine;

	f3DReplace := ADesigner.NewRadio;
	f3DReplace.Caption := '3D Replace';

	ADesigner.NewLine;
end;
function TAFill.GetToolName : String;
begin
	if f2DFill.Checked then
		Result := '2D Fill'
	else if f3DFill.Checked then
		Result := '3D Fill'
	else if f2DReplace.Checked then
		Result := '2D Replace'
	else if f3DReplace.Checked then
		Result := '3D Replace';
end;
end.