{
  Trackbias
  Copyright (C) 2021 Carlos Rafael Fernandes Picanço.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Controls.Bias;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls;

type

  TSpot = record
    TopCaption   : string;
    BottomCaption   : string;
    Dragging   : Boolean;
    Position      : Byte;
    BoundsRect : TRect;
    TopRect    : TRect;
    BottomRect : TRect;
  end;

  TSpotArray = array of TSpot;

  { TTrackBias }

  TTrackBias = class(TCustomControl)
  private
    FNextSpotCaption : string;
    FSpots : TSpotArray;
    function ClientToPorcentage(AValue : integer) : Byte;
    function GetCount : integer;
    function GetDelta(AIndex: integer) : Byte;
    function GetDeltas : TBytes;
    function GetPosition : TBytes;
    function IsOverSpot(ASpot : TSpot; X, Y : integer) : Boolean;
    function PorcentageToClient(AValue : Byte) : integer;
    procedure SetCount(AValue : integer);
    procedure UpdateSpots(AIndex : integer); overload;
    procedure UpdateSpots(AOverride : Boolean = True); overload;
  protected
    procedure ChangeBounds(ALeft, ATop, AWidth, AHeight : integer; KeepBase : boolean);
      override;
    procedure MouseDown(Button : TMouseButton; Shift : TShiftState;
      X, Y : Integer); override;
    procedure MouseMove(Shift : TShiftState; X, Y : Integer); override;
    procedure MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
      override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Save;
    procedure Load;
    procedure AddSpot;
    procedure RemoveSpot;
    property Count : integer read GetCount write SetCount;
    property Deltas : TBytes read GetDeltas;
    property NextSpotCaption : string read FNextSpotCaption write FNextSpotCaption;
    property Positions : TBytes read GetPosition;
  end;


implementation

{ TTrackBias }

uses Forms, Graphics;

const
  TopRectHeight = 10;
  InnerBorderH = 10;
  InnerBorderV = 20;
  SpotSize = 16;
  HalfSpotSize = 8;

procedure TTrackBias.UpdateSpots(AOverride : Boolean);
var
  i : Integer;
  LValues : Integer;
begin
  if AOverride then begin
    LValues := Round(100/Count);
    for i := Low(FSpots) to High(FSpots) do begin
      if i = High(FSpots) then begin
        FSpots[i].Position := 100;
      end else begin
        FSpots[i].Position := LValues*(i+1);
      end;
    end;
  end;
  for i := Low(FSpots) to High(FSpots) do begin
    UpdateSpots(i);
  end;
  Invalidate;
end;

function TTrackBias.GetCount : integer;
begin
  Result := Length(FSpots);
end;

procedure TTrackBias.UpdateSpots(AIndex : integer);
begin
  with FSpots[AIndex] do begin
    BoundsRect :=
      Rect(
        InnerBorderH + PorcentageToClient(Position),
        InnerBorderV,
        InnerBorderH + PorcentageToClient(Position) + SpotSize,
        InnerBorderV + SpotSize);

    //BottomRect := Rect(
    //  BoundsRect.Left-3,
    //  BoundsRect.Bottom,
    //  BoundsRect.Right+3,
    //  BoundsRect.Bottom+SpotSize);

    if AIndex = Low(FSpots) then begin
      TopCaption := Position.ToString;
      TopRect := Rect(
        InnerBorderH + HalfSpotSize,
        InnerBorderV - TopRectHeight - 3,
        BoundsRect.CenterPoint.X,
        InnerBorderV - 3);

      BottomRect := Rect(
        InnerBorderH + HalfSpotSize,
        BoundsRect.Bottom,
        BoundsRect.CenterPoint.X,
        BoundsRect.Bottom+SpotSize);

    end else begin
      TopCaption := GetDelta(AIndex).ToString;
      TopRect := Rect(
        FSpots[Aindex-1].BoundsRect.CenterPoint.X,
        InnerBorderV - TopRectHeight - 3,
        BoundsRect.CenterPoint.X,
        InnerBorderV - 3);

      BottomRect := Rect(
        FSpots[Aindex-1].BoundsRect.CenterPoint.X,
        BoundsRect.Bottom + 3,
        BoundsRect.CenterPoint.X,
        BoundsRect.Bottom + TopRectHeight);
    end;
  end;
end;

procedure TTrackBias.ChangeBounds(ALeft, ATop, AWidth, AHeight : integer;
  KeepBase : boolean);
begin
  inherited ChangeBounds(ALeft, ATop, AWidth, AHeight, KeepBase);
  UpdateSpots(False);
end;

function TTrackBias.PorcentageToClient(AValue : Byte) : integer;
begin
  Result := Round(((Width - ((InnerBorderH*2) + SpotSize))*AValue)/100);
end;

procedure TTrackBias.SetCount(AValue : integer);
begin
  SetLength(FSpots, AValue);
end;

function TTrackBias.ClientToPorcentage(AValue : integer) : Byte;
var
  V : real;
begin
  V := AValue-InnerBorderH-(SpotSize/2);
  Result := Round((V*100)/(Width - ((InnerBorderH*2) + SpotSize)));
end;

function TTrackBias.IsOverSpot(ASpot : TSpot; X, Y : integer) : Boolean;
var
  A, B : integer;
begin
  with ASpot do begin
    A := (BoundsRect.Left + HalfSpotSize - X);
    B := (BoundsRect.Top  + HalfSpotSize - Y);
  end;
  Result := ((A * A) + (B * B)) < 300;
end;

procedure TTrackBias.MouseDown(Button : TMouseButton; Shift : TShiftState; X,
  Y : Integer);
var
  i : integer;
begin
  if Button = mbLeft then
  begin
    if (X > (ClientRect.Left  + InnerBorderH)) and
       (X < (ClientRect.Right - InnerBorderH)) then begin
      for i:= Low(FSpots) to High(FSpots) do begin
        if IsOverSpot(FSpots[i], X, Y) then begin
          FSpots[i].Dragging := True;
          FSpots[i].BoundsRect.Left := ClientToPorcentage(X);
          UpdateSpots(i);
          Break;
        end else begin
          { do nothing }
        end;
      end;
    end;

  end;
end;


procedure TTrackBias.MouseMove(Shift : TShiftState; X, Y : Integer);
var
  i : Integer;
  LLength : integer;
  LValue : Byte;
begin
  inherited MouseMove(Shift, X, Y);
  if (X > (InnerBorderH + HalfSpotSize)) and
     (X < (Width - InnerBorderH - HalfSpotSize)) then begin
    LLength := Count;
    for i := Low(FSpots) to High(FSpots) do begin
      if FSpots[i].Dragging then
      begin
        LValue := ClientToPorcentage(X);
        if LLength > 1 then begin
          if (i < High(FSpots)) then begin
            if LValue >= FSpots[i+1].Position then Exit;
          end;

          if (i > Low(FSpots)) then begin
            if LValue <= FSpots[i-1].Position then Exit
          end;
        end;
        FSpots[i].Position := LValue;
        UpdateSpots(i);
        if i < High(FSpots) then begin
          UpdateSpots(i+1);
        end;
        Invalidate;
      end;
    end;
  end else begin
    { do nothing }
  end;
end;

procedure TTrackBias.MouseUp(Button : TMouseButton; Shift : TShiftState; X,
  Y : Integer);
var
  i : Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  for i := Low(FSpots) to High(FSpots) do begin
    FSpots[i].Dragging := False;
  end;
end;

procedure TTrackBias.Paint;
  procedure DrawBackground;
  begin
    Canvas.Pen.Width := 1;
    if Focused then begin
      Canvas.Pen.Color := clActiveBorder;
      Canvas.Brush.Color := clHotLight;
    end else begin
      Canvas.Pen.Color := clInactiveBorder;
      Canvas.Brush.Color := cl3DLight;
    end;
    Canvas.Rectangle(0, 0, Width, Height);
  end;

  procedure DrawLine;
  var
    LSizeH, LSizeV : integer;
  begin
    LSizeH := InnerBorderH + HalfSpotSize;
    LSizeV := InnerBorderV + HalfSpotSize;
    Canvas.Pen.Color := clHighlightText;
    Canvas.Pen.Width := 1;
    Canvas.Line(LSizeH, LSizeV, Width - LSizeH, LSizeV);
  end;

  procedure DrawSpots;
  var
    i : integer;
    LTextStyle : TTextStyle;
    R : TRect;
    S : string;
  begin
    LTextStyle.Alignment := taCenter;
    LTextStyle.Layout := tlCenter;
    with Canvas do begin
      Pen.Width := 1;
      for i := Low(FSpots) to High(FSpots) do begin
        Brush.Color := clHighlight;
        Pen.Color := clBlack;
        Polygon(
          [FSpots[i].BoundsRect.CenterPoint,
           FSpots[i].BoundsRect.BottomRight,
           Point(FSpots[i].BoundsRect.Left,FSpots[i].BoundsRect.Bottom)]);

        Brush.Color := clDefault;
        Font.Color:= clWhite;
        Font.Size := 7;
        Pen.Color := clWhite;
        R := FSpots[i].BottomRect;
        S := FSpots[i].BottomCaption;
        TextRect(R, R.Left, R.Top, S, LTextStyle);

        R := FSpots[i].TopRect;
        S := FSpots[i].TopCaption;
        TextRect(R, R.Left, R.Top, S, LTextStyle);

        Pen.Color := clRed;
        Line(R.Left, R.Top, R.Left, R.Bottom);
        Line(R.Right, R.Top, R.Right, R.Bottom);
      end;
    end;
  end;

begin
  inherited Paint;
  DrawBackground;
  DrawLine;
  DrawSpots;
end;

constructor TTrackBias.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  NextSpotCaption := '';
  Constraints.MinHeight := 55;
  Constraints.MaxHeight := 55;
  Constraints.MinWidth := 400;
end;

procedure TTrackBias.Save;
var
  i : Integer;
  S : TStringList;
begin
  if Count = 0 then Exit;
  S := TStringList.Create;
  try
    S.Values[Self.Name+'.Count'] := IntToStr(Count);
    for i := Low(FSpots) to High(FSpots) do begin
      with FSpots[i] do begin
        S.Values[Self.Name+'.Position'+i.ToString] := IntToStr(Position);
        S.Values[Self.Name+'.Caption'+i.ToString] := BottomCaption;
      end;
    end;
    S.SaveToFile(Self.Name);
  finally
    S.Free;
  end;
end;

procedure TTrackBias.Load;
var
  i : Integer;
  S : TStringList;
begin
  S := TStringList.Create;
  try
    if FileExists(Self.Name) then begin
      S.LoadFromFile(Self.Name);
      i := StrToIntDef(S.Values[Self.Name+'.Count'], -1);
      if (i = 0) or (i = -1) then begin
        { do nothing }
      end else begin
        Count := i;
        for i := Low(FSpots) to High(FSpots) do begin
          with FSpots[i] do begin
            Position := StrToInt(S.Values[Self.Name+'.Position'+i.ToString]);
            BottomCaption := S.Values[Self.Name+'.Caption'+i.ToString];
          end;
        end;
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TTrackBias.AddSpot;
var
  LCaption : string;
  LHigh : integer;
begin
  SetLength(FSpots, Count + 1);
  if NextSpotCaption = '' then begin
    LHigh := High(FSpots);
    case LHigh of
      0 :
        LCaption := 'R+';

      else
        LCaption := 'R- '+LHigh.ToString;
    end;
  end else begin
    LCaption := NextSpotCaption;
    NextSpotCaption := '';
  end;
  FSpots[LHigh].BottomCaption := LCaption;
  UpdateSpots;
end;

procedure TTrackBias.RemoveSpot;
begin
  if Count = 0 then Exit;
  SetLength(FSpots, Count - 1);
  UpdateSpots;
end;

function TTrackBias.GetDelta(AIndex : integer) : Byte;
begin
  Result := FSpots[AIndex].Position;
  if AIndex = 0 then Exit;
  Result := Result - FSpots[AIndex-1].Position;
end;

function TTrackBias.GetDeltas : TBytes;
var
  i : Integer;
begin
  Result := nil;
  SetLength(Result, Count);
  if Count > 0 then begin
    for i := Low(FSpots) to High(FSpots) do begin
      Result[i] := GetDelta(i);
    end;
  end else begin
    { do nothing }
  end;
end;

function TTrackBias.GetPosition : TBytes;
begin
  Result := nil;
  SetLength(Result, Count);
  if Count > 0 then begin
    for i := Low(FSpots) to High(FSpots) do begin
      Result[i] := FSpots[i].Position;
    end;
  end else begin
    { do nothing }
  end;
end;

end.

