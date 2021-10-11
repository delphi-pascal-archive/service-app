unit f_Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs;

const
  WM_TASKBAREVENT = WM_USER + 1;

type
  TFrmMain = class(TForm)
  private
    { Private declarations }
    procedure WMTaskBarEvent(var Msg: TMessage); message WM_TASKBAREVENT;    
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses service_prin;

{$R *.dfm}

// Capturer Events du TrayIcon :
procedure TFrmMain.WMTaskBarEvent(var Msg: TMessage);
var pt: TPoint;
begin
  if msg.LParam = WM_RBUTTONDOWN
  then begin   
    if IsIconic(Forms.Application.Handle)
    then ShowWindow(Forms.Application.Handle, Sw_Restore);

    GetCursorPos(pt);
    Service1.PopMenu.Popup(pt.x, pt.y);
    PostMessage(Handle, WM_NULL, 0, 0);
  end;
end;

end.
