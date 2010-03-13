unit DefaultToolManager;

interface

uses
	Generics.Collections,
	RzTabs,
	GR32,
	Tool,
	ToolManager;

type
	TDefaultToolManager = class(TToolManager)
	protected
	public
		constructor Create(const APanel : TRzPageControl;const AGet:TToolGet;const ASet : TToolSet;const AHelper : TBitmap32);reintroduce;
	end;
implementation

uses
	Brush,
	Line,
	Fill;
const
	Tools : array[0..2] of TToolClass = (TABrush,TALine,TAFill);

constructor TDefaultToolManager.Create(const APanel : TRzPageControl;const AGet:TToolGet;const ASet : TToolSet;const AHelper : TBitmap32);
var
	Index : Byte;
	Count : Byte;
begin
	inherited Create(APanel);
	Count := Length(Tools);
	for Index := 0 to Count - 1 do
	begin
		fTools.Add(Tools[Index].Create(AGet,ASet,AHelper));
	end;
end;
end.
