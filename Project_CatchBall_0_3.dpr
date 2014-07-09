program Project_CatchBall_0_3;

uses
  Forms,
  Unit_main_0_3 in 'Unit_main_0_3.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'CatchBall v.0.3';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
