unit service_prin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls, Menus, AppEvnts, ShellAPI;

type
  TService1 = class(TService)
    PopMenu: TPopupMenu;
    MIShowPrin: TMenuItem;
    N2: TMenuItem;
    MIPause: TMenuItem;
    N1: TMenuItem;
    MICloseService: TMenuItem;
    TimerUpdateTray: TTimer;
    TimerService: TTimer;
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure MIShowPrinClick(Sender: TObject);
    procedure MIPauseClick(Sender: TObject);
    procedure MICloseServiceClick(Sender: TObject);
    procedure TimerUpdateTrayTimer(Sender: TObject);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure TimerServiceTimer(Sender: TObject);
  private
    { Private declarations }
  public
    Service_Busy: Boolean;
    IconData : TNotifyIconData;
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Service1: TService1;

implementation

uses f_prin, Forms, f_Main;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service1.Controller(CtrlCode);
end;

function TService1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TService1.ServiceExecute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(true); // Attend l'appel de fermeture par windows ...
end;

procedure TService1.ServiceCreate(Sender: TObject);
begin
  Service_Busy := false;
end;

procedure TService1.ServiceStart(Sender: TService; var Started: Boolean);
begin
  // Tray Icon dans la TaskBar:
  IconData.cbSize := sizeof(IconData);
  IconData.Wnd := FrmMain.Handle;
  IconData.uID := 100;
  IconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  IconData.uCallbackMessage := WM_TASKBAREVENT;
  IconData.hIcon := Forms.Application.Icon.Handle;
  StrPCopy(IconData.szTip, Service1.DisplayName);
  Shell_NotifyIcon(NIM_ADD, @IconData);
end;

procedure TService1.MIShowPrinClick(Sender: TObject);
begin
  if FrmPrin.Visible
  then SetForegroundWindow(FrmPrin.Handle)
  else FrmPrin.Show;
end;

procedure TService1.MIPauseClick(Sender: TObject);
begin
  if Service1.Status in [csRunning, csContinuePending]
  then Service1.Status := csPaused
  else Service1.Status := csRunning;

  Service1.ReportStatus;   // Notify Windows Service Manager ...
end;

procedure TService1.MICloseServiceClick(Sender: TObject);
begin
  if Service1.Service_Busy
  then begin
    ShowMessage('Service occupé pour le moment!');
    EXIT;
  end;

  if not (Service1.Status in [csStopped, csStopPending])
  then begin
    Service1.Status := csStopped;
    Service1.ReportStatus;            // Notify Windows Service Manager ...
  end;
end;

procedure TService1.ServiceDestroy(Sender: TObject);
begin
  // Eliminer le Tray icon :
  Shell_NotifyIcon(NIM_DELETE, @IconData);
end;

procedure TService1.TimerServiceTimer(Sender: TObject);
var i: Integer;
begin
  if service1.Terminated then EXIT;

  // ReportStatus na StatusBar :
  case Service1.Status of
    csContinuePending: FrmPrin.STBar.SimpleText := 'ContinuePending';
    csPaused: FrmPrin.STBar.SimpleText := 'Paused';
    csPausePending: FrmPrin.STBar.SimpleText := 'PausePending';
    csRunning: FrmPrin.STBar.SimpleText := 'Running';
    csStartPending: FrmPrin.STBar.SimpleText := 'StartPending';
    csStopped: FrmPrin.STBar.SimpleText := 'Stopped';
    csStopPending: FrmPrin.STBar.SimpleText := 'StopPending';
    else
      FrmPrin.STBar.SimpleText := 'Unknown state';
  end;

  if Service1.Status = csRunning
  then begin
    TimerService.Enabled := false;
    Service1.Service_Busy := true;

    i := FrmPrin.LBTime.Items.Add(FormatDateTime('hh:mm:ss', Now));
    FrmPrin.LBTime.ItemIndex := i;
    Forms.Application.ProcessMessages;
    Sleep(1000);                        // Endormir le programme pour faire comme si on executait une grande tâche ...
    
    Service1.Service_Busy := false;
    TimerService.Enabled := true;
  end;
end;

procedure TService1.TimerUpdateTrayTimer(Sender: TObject);
begin
  // Je n' ai trouvé que cette manière pour montrer l' icone dans le
  // taskbar après avoir démarrer une nouvelle session :
  if not service1.Terminated
  then Shell_NotifyIcon(NIM_ADD, @IconData);
end;

end.
