program Editor;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  SysUtils,
  Globals in 'Common\Globals.pas',
  BlockOptions in 'Common\Config\BlockOptions.pas',
  Controller in 'Common\Controller.pas',
  DefaultController in 'Common\DefaultController.pas',
  NBTReader in 'Common\NBTReader.pas',
  HistoryLog in 'Common\HistoryLog.pas',
  Tool in 'Common\Tools\Tool.pas',
  ToolManager in 'Common\Tools\ToolManager.pas',
  DefaultToolManager in 'Common\Tools\DefaultToolManager.pas',
  Brush in 'Common\Tools\Default\Brush.pas',
  Line in 'Common\Tools\Default\Line.pas',
  Fill in 'Common\Tools\Default\Fill.pas',
  ZLibExGZ in 'Common\zlib\ZLibExGZ.pas',
  ZLibEx in 'Common\zlib\ZLibEx.pas',
  Main in 'Main.pas' {MainFrm},
  BlockList in 'BlockList.pas' {BlockListFrm},
  NewMap in 'NewMap.pas' {NewMapFrm},
  Attributes in 'Attributes.pas' {AttributesFrm};

{$R *.res}

begin
	AppPath := ExtractFilePath(ParamStr(0));
	SetCurrentDir(AppPath);
	Application.Initialize;

	Application.MainFormOnTaskbar := True;
	Application.CreateForm(TMainFrm, MainFrm);
	Application.CreateForm(TBlockListFrm, BlockListFrm);
	Application.CreateForm(TAttributesFrm, AttributesFrm);
	Application.Run;
end.
