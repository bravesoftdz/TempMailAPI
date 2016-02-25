program TempMailClient;

uses
  System.StartUpCopy,
  FMX.Forms,
  uGeneral in 'C:\Users\Maxim\Documents\Embarcadero\Studio\Projects\TempMailAPI\Sample\uGeneral.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
