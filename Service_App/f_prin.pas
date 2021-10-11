unit f_prin;

interface

uses
  Windows, Messages, Forms, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, Buttons, StdCtrls, SvcMgr, ExtCtrls, ComCtrls,
  Menus, DB, DBTables, Grids, DBGrids;

type
  TFrmPrin = class(TForm)
    SBEtoile: TSpeedButton;
    EEtoile: TEdit;
    LBTime: TListBox;
    STBar: TStatusBar;
    procedure SBEtoileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrin: TFrmPrin;

implementation

uses service_prin;

{$R *.dfm}

procedure TFrmPrin.SBEtoileClick(Sender: TObject);
begin
  EEtoile.Text := EEtoile.Text + ' *';
end;

end.
