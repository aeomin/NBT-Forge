unit Line;

interface

uses
	Types,
	StdCtrls,
	RzTrkBar,
	RzEdit,
	Tool,
	Globals,
	Controller;

type
	TALine = class(TTool)
	protected
		fTracker : TRzTrackBar;
		fEdit : TRzNumericEdit;
		fStatus : TLabel;
		fReplace : TCheckBox;
		fRound : TCheckBox;
		fFirstPlotted : Boolean;
		fFirstPoint : TPoint3;
		fCancelBTN : TButton;

		fLastView : TViewMode;
		procedure OnSizeTrackChange(Sender: TObject);
		procedure OnSizeEditChange(Sender: TObject);
		procedure DoCancel(Sender:TObject);
	public
		procedure Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);override;
		procedure Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);override;
		function InitGui(const ADesigner : TGUIDesigner):String;override;
		function GetToolName : String;override;
	end;
implementation

uses
	SysUtils;

procedure Swap(var A,B:Integer);
var
	C : Integer;
begin
	C := A;
	A := B;
	B := C;
end;

procedure TALine.OnSizeTrackChange(Sender: TObject);
begin
	fEdit.IntValue := fTracker.Position;
end;
procedure TALine.OnSizeEditChange(Sender: TObject);
begin
	fTracker.Position := fEdit.IntValue;
end;
procedure TALine.DoCancel(Sender:TObject);
begin
	fFirstPlotted := False;
	fStatus.Caption := '';
	fCancelBTN.Visible := False;

	fHelper.BeginUpdate;
	fHelper.Clear($0);
	fHelper.EndUpdate;
	fHelper.Changed;
end;
procedure TALine.Click(const X,Y,Z:SmallInt;const Boundary:TPoint3);
var
	IndexX, x0, x1, delta_x, step_x  :integer;
	IndexY, y0, y1, delta_y, step_y  :integer;
	IndexZ, z0, z1, delta_z, step_z  :integer;
	swap_xy, swap_xz            :boolean;
	drift_xy, drift_xz          :integer;
	cx, cy, cz                  :integer;
	Radius : Word;
	ARound : Boolean;
	Replace : Boolean;
	procedure Paint(const X,Y,Z:Integer);
		function RoundPass(const NewX,NewY,NewZ:SmallInt):Boolean;
		begin
			Result := (Round(Distance(X-NewX,Y-NewY,Z-NewZ))<=Radius);
		end;
		function HollowPass(const NewX,NewY,NewZ:SmallInt):Boolean;
		begin
			if ARound then
			begin
				Result := (Round(Distance(X-NewX,Y-NewY,Z-NewZ))=Radius);
			end else
			begin
				Result := (NewX = X - Radius)OR
					(NewX = X + Radius)OR
					(NewY = Y - Radius)OR
					(NewY = Y + Radius)OR
					(NewZ = Z - Radius)OR
					(NewZ = Z + Radius);
			end;
		end;
	var
		IndexX : SmallInt;
		IndexY : SmallInt;
		IndexZ : SmallInt;
		FromX,ToX:SmallInt;
		FromY,ToY:SmallInt;
		FromZ,ToZ:SmallInt;
	begin
		FromX := X-Radius;
		if FromX <0 then
			FromX :=0;
		FromY := Y-Radius;
		if FromY <0 then
			FromY :=0;
		FromZ := Z-Radius;
		if FromZ <0 then
			FromZ :=0;
		ToX := X+Radius;
		ToY := Y+Radius;
		ToZ := Z+Radius;
		for IndexX := FromX to ToX do
		begin
			for IndexY := FromY to ToY do
			begin
				for IndexZ := FromZ to ToZ do
				begin
					if (Replace OR (fGet(IndexX,IndexY,IndexZ) = 0))AND
					(NOT ARound OR RoundPass(IndexX,IndexY,IndexZ)) then
						fSet(IndexX,IndexY,IndexZ,CurrentBlock);
				end;
			end;
		end;
	end;
begin
	if fFirstPlotted then
	begin
		if (fFirstPoint.X <> X)OR
		(fFirstPoint.Y <> Y)OR
		(fFirstPoint.Z <> Z) then
		begin
			fHelper.BeginUpdate;
			fHelper.Clear($0);
			fHelper.EndUpdate;
			fHelper.Changed;

			Radius := fTracker.Position;
			ARound := fRound.Checked;
			Replace := fReplace.Checked;

			x0 := fFirstPoint.X;	x1 := X;
			y0 := fFirstPoint.Y;	y1 := Y;
			z0 := fFirstPoint.Z;	z1 := Z;

			//'steep' xy Line, make longest delta x plane
			swap_xy := Abs(y1 - y0) > Abs(x1 - x0);
			if swap_xy then
			begin
				Swap(x0, y0);
				Swap(x1, y1);
			end;

			//do same for xz
			swap_xz := Abs(z1 - z0) > Abs(x1 - x0);
			if swap_xz then
			begin
				Swap(x0, z0);
				Swap(x1, z1);
			end;

			if x0 > x1 then
			begin
				Swap(x0, x1);
				Swap(y0, y1);
				Swap(z0, z1);
			end;

			//delta is Length in each plane
			delta_x := (x1 - x0);
			delta_y := Abs(y1 - y0);
			delta_z := Abs(z1 - z0);

			//drift controls when to step in 'shallow' planes
			//starting value keeps Line centred
			drift_xy  := (delta_x div 2);
			drift_xz  := (delta_x div 2);

			//direction of line
			step_x := 1;	if (x0 > x1) then step_x := -1;
			step_y := 1;	if (y0 > y1) then step_y := -1;
			step_z := 1;	if (z0 > z1) then step_z := -1;

			//starting point
			IndexX := x0;
			IndexY := y0;
			IndexZ := z0;

			//step through longest delta (which we have swapped to x)
			while IndexX <= x1 do
			begin

				//copy position
				cx := IndexX;    cy := IndexY;    cz := IndexZ;

				//unswap (in reverse)
				if swap_xz then Swap(cx, cz);
				if swap_xy then Swap(cx, cy);

				//passes through this point
				//fSet(cx,cy,cz,CurrentBlock);
				Paint(cx,cy,cz);

				//update progress in other planes
				drift_xy := drift_xy - delta_y;
				drift_xz := drift_xz - delta_z;

				//step in y plane
				if drift_xy < 0 then
				begin
					IndexY := IndexY + step_y;
					drift_xy := drift_xy + delta_x;
				end;

				//same in z
				if drift_xz < 0 then
				begin
					IndexZ := IndexZ + step_z;
					drift_xz := drift_xz + delta_x;
				end;

				Inc(IndexX,step_x);
			end;
			fFirstPlotted := False;
			fStatus.Caption := '';
			fCancelBTN.Visible := False;
		end;
	end else
	begin
		fFirstPlotted := True;
		fStatus.Caption := 'Point: ('+IntToStr(X)+','+IntToStr(Y)+','+IntToStr(Z)+')';
		fFirstPoint := Point3(X,Y,Z);
		fCancelBTN.Visible := True;

		fLastView := CurrentView;

		{fHelper.BeginUpdate;
		fHelper.Clear($0);
		case fLastView of
			vmXY: fHelper.SetPixelTS(X,Y,BlockColors[CurrentBlock]);
			vmXZ: fHelper.SetPixelTS(X,Boundary.Z-1-Z,BlockColors[CurrentBlock]);
			vmYZ: fHelper.SetPixelTS(Y,Boundary.Z-1-Z,BlockColors[CurrentBlock]);
		end;
		fHelper.EndUpdate;
		fHelper.Changed;}
	end;
end;
procedure TALine.Refresh(const X,Y,Z:SmallInt;const Boundary:TPoint3);
var
	Replace : Boolean;
	IndexX, x0, x1, delta_x, step_x  :integer;
	IndexY, y0, y1, delta_y, step_y  :integer;
	IndexZ, z0, z1, delta_z, step_z  :integer;
	swap_xy, swap_xz            :boolean;
	drift_xy, drift_xz          :integer;
	cx, cy, cz                  :integer;
begin
	if fFirstPlotted then
	begin
		fHelper.BeginUpdate;
		fHelper.Clear($0);
		if fLastView = CurrentView then
		begin
			Replace := fReplace.Checked;

			x0 := fFirstPoint.X;	x1 := X;
			y0 := fFirstPoint.Y;	y1 := Y;
			z0 := fFirstPoint.Z;	z1 := Z;

			//'steep' xy Line, make longest delta x plane
			swap_xy := Abs(y1 - y0) > Abs(x1 - x0);
			if swap_xy then
			begin
				Swap(x0, y0);
				Swap(x1, y1);
			end;

			//do same for xz
			swap_xz := Abs(z1 - z0) > Abs(x1 - x0);
			if swap_xz then
			begin
				Swap(x0, z0);
				Swap(x1, z1);
			end;

			if x0 > x1 then
			begin
				Swap(x0, x1);
				Swap(y0, y1);
				Swap(z0, z1);
			end;

			//delta is Length in each plane
			delta_x := (x1 - x0);
			delta_y := Abs(y1 - y0);
			delta_z := Abs(z1 - z0);

			//drift controls when to step in 'shallow' planes
			//starting value keeps Line centred
			drift_xy  := (delta_x div 2);
			drift_xz  := (delta_x div 2);

			//direction of line
			step_x := 1;	if (x0 > x1) then step_x := -1;
			step_y := 1;	if (y0 > y1) then step_y := -1;
			step_z := 1;	if (z0 > z1) then step_z := -1;

			//starting point
			IndexX := x0;
			IndexY := y0;
			IndexZ := z0;

			//step through longest delta (which we have swapped to x)
			while IndexX <= x1 do
			begin

				//copy position
				cx := IndexX;    cy := IndexY;    cz := IndexZ;

				//unswap (in reverse)
				if swap_xz then Swap(cx, cz);
				if swap_xy then Swap(cx, cy);

				//passes through this point
				//fSet(cx,cy,cz,CurrentBlock);
				if (Replace OR (fGet(cx,cy,cz) = 0)) then
				case fLastView of
					vmXY:begin
						if fFirstPoint.Z = Z then
							fHelper.SetPixelTS(cx,cy,BlockColors[CurrentBlock]);
					end;
					vmXZ:begin
						if fFirstPoint.Y = Y then
							fHelper.SetPixelTS(cx,Boundary.Z-cz-1,BlockColors[CurrentBlock]);
					end;
					vmYZ:begin
						if fFirstPoint.X = X then
							fHelper.SetPixelTS(cy,Boundary.Z-cz-1,BlockColors[CurrentBlock]);
					end;
				end;

				//update progress in other planes
				drift_xy := drift_xy - delta_y;
				drift_xz := drift_xz - delta_z;

				//step in y plane
				if drift_xy < 0 then
				begin
					IndexY := IndexY + step_y;
					drift_xy := drift_xy + delta_x;
				end;

				//same in z
				if drift_xz < 0 then
				begin
					IndexZ := IndexZ + step_z;
					drift_xz := drift_xz + delta_x;
				end;

				Inc(IndexX,step_x);
			end;

		end;
		fHelper.EndUpdate;
		fHelper.Changed;
	end;
end;
function TALine.InitGui(const ADesigner : TGUIDesigner):String;
begin
	Result :='Line';

	fTracker := ADesigner.AddTrackBar('Line Radius');
	fTracker.Min := 0;
	fTracker.Max := 50;
	fTracker.OnChange := OnSizeTrackChange;
	fTracker.ShowTicks := False;

	fEdit := ADesigner.NewNumEditBox;
	fEdit.Height := 15;
	fEdit.Width := 30;
	fEdit.Top := fTracker.Top - fEdit.Height - 8;
	fEdit.Left := fTracker.Left + fTracker.Width - fEdit.Width-3;
	fEdit.Min := fTracker.Min;
	fEdit.Max := fTracker.Max;
	fEdit.Value := 0;
	fEdit.OnChange := OnSizeEditChange;

	ADesigner.NewLine;

	fReplace := ADesigner.NewCheckBox;
	fReplace.Caption := 'Replace';
	fReplace.Checked := True;

	ADesigner.NewLine;

	fRound := ADesigner.NewCheckBox;
	fRound.Caption := 'Round';

	ADesigner.NewLine;

	fStatus := ADesigner.NewLabel;
	fStatus.Caption := '';

	ADesigner.NewLine;

	fCancelBTN := ADesigner.NewButton;
	fCancelBTN.Caption := 'Cancel';
	fCancelBTN.Visible := False;
	fCancelBTN.OnClick := DoCancel;

	fFirstPlotted := False;
end;
function TALine.GetToolName : String;
begin
	Result := 'Line';
end;
end.
