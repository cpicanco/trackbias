{
  Trackbias
  Copyright (C) 2021 Carlos Rafael Fernandes Picanço.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
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
