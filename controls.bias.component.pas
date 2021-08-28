unit Controls.Bias.Component;

{$mode ObjFPC}{$H+}

interface

procedure Register;

implementation

uses
  Classes, LResources, Controls.Bias;

procedure Register;
begin
  {$I controls.bias.component_icon.lrs}
  RegisterComponents('Stimulus Control',[TTrackBias]);
end;

end.
