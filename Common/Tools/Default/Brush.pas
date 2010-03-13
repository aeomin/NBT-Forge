unit Brush;

interface

uses
	Types,
	StdCtrls,
	RzTrkBar,
	RzEdit,
	Tool;

type
	TABrush = class(TTool)
	protected
		fTracker : TRzTrackBar;
		fEdit : TRzNumericEdit;
		fReplace : TCheckBox;
		fRound : TCheckBox;
		fHollow : TCheckBox;
		f3D : TCheckBox;
		procedure OnSizeTrackChange(Sender: TObject);
		procedure OnSizeEditChange(Sender: TObject);
	public
		procedure Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);override;
		function InitGui(const ADesigner : TGUIDesigner):String;override;
		function GetToolName : String; override;
	end;

implementation

uses
	Math,
	Globals,
	Controller;

procedure TABrush.OnSizeTrackChange(Sender: TObject);
begin
	fEdit.IntValue := fTracker.Position;
end;
procedure TABrush.OnSizeEditChange(Sender: TObject);
begin
	fTracker.Position := fEdit.IntValue;
end;

procedure TABrush.Draw(const X,Y,Z:SmallInt;const Boundary:TPoint3);
var
	Radius : Word;
	IndexX : SmallInt;
	IndexY : SmallInt;
	IndexZ : SmallInt;
	ARound : Boolean;
	Hollow : Boolean;
	Replace : Boolean;
	FromX,ToX:SmallInt;
	FromY,ToY:SmallInt;
	FromZ,ToZ:SmallInt;
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
begin
	Radius := fTracker.Position;
	ARound := fRound.Checked;
	Hollow := fHollow.Checked;
	Replace := fReplace.Checked;
	if NOT f3D.Checked then
	begin
		case CurrentView of
			vmXY:begin
				FromX := X-Radius;
				if FromX <0 then
					FromX :=0;
				FromY := Y-Radius;
				if FromY <0 then
					FromY :=0;
				ToX := X+Radius;
				ToY := Y+Radius;
				for IndexX := FromX to ToX do
				begin
					for IndexY := FromY to ToY do
					begin
						if (Replace OR (fGet(IndexX,IndexY,Z) = 0))AND
						(NOT ARound OR RoundPass(IndexX,IndexY,Z))AND
						(NOT Hollow OR HollowPass(IndexX,IndexY,Z)) then
							fSet(IndexX,IndexY,Z,CurrentBlock);
					end;
				end;
			end;
			vmXZ:begin
				FromX := X-Radius;
				if FromX <0 then
					FromX :=0;
				FromY := Z-Radius;
				if FromY <0 then
					FromY :=0;
				ToX := X+Radius;
				ToY := Z+Radius;
				for IndexX := FromX to ToX do
				begin
					for IndexY := FromY to ToY do
					begin
						if (Replace OR (fGet(IndexX,Y,IndexY) = 0)) AND
						(NOT ARound OR RoundPass(IndexX,Y,IndexY))AND
						(NOT Hollow OR HollowPass(IndexX,Y,IndexY)) then
							fSet(IndexX,Y,IndexY,CurrentBlock);
					end;
				end;
			end;
			vmYZ:begin
				FromX := Y-Radius;
				if FromX <0 then
					FromX :=0;
				FromY := Z-Radius;
				if FromY <0 then
					FromY :=0;
				ToX := Y+Radius;
				ToY := Z+Radius;
				for IndexX := FromX to ToX do
				begin
					for IndexY := FromY to ToY do
					begin
						if (Replace OR (fGet(X,IndexX,IndexY) = 0)) AND
						(NOT ARound OR RoundPass(X,IndexX,IndexY))AND
						(NOT Hollow OR HollowPass(X,IndexX,IndexY)) then
							fSet(X,IndexX,IndexY,CurrentBlock);
					end;
				end;
			end;
		end;
	end else
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
					(NOT ARound OR RoundPass(IndexX,IndexY,IndexZ))AND
					(NOT Hollow OR HollowPass(IndexX,IndexY,IndexZ)) then
						fSet(IndexX,IndexY,IndexZ,CurrentBlock);
				end;
			end;
		end;
	end;
end;

function TABrush.InitGui(const ADesigner : TGUIDesigner):String;
begin
	Result := 'Brush';

	fTracker := ADesigner.AddTrackBar('Brush Radius');
	fTracker.Min := 0;
	fTracker.Max := 200;
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

	fHollow := ADesigner.NewCheckBox;
	fHollow.Caption := 'Hollow';

	ADesigner.NewLine;

	f3D := ADesigner.NewCheckBox;
	f3D.Caption := '3D';

end;
function TABrush.GetToolName : String;
begin
	if f3D.Checked then
		Result := '3D Brush'
	else
		Result := '2D Brush';
end;
end.
