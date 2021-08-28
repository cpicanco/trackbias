# trackbias

Track Bias is a track bar with multiple positions (ranging from 0 to 100). Each position+delta is called a "spot".

![TTrackBias](https://raw.githubusercontent.com/cpicanco/trackbias/main/docs/trackbias-face.png)

One can set and get deltas from multiple positions easily.   

## Exemple

```pascal
  uses Controls.Bias;
  
  var
    MyBytes : TBytes;
    TrackBias1 : TTrackBias;
  begin
  // Create
  TrackBias1 := TTrackBias.Create(Form1);
  TrackBias1.Name := 'TrackBias1';
  TrackBias1.Parent := Form1;     
  
  // Add a new position and override old ones
  TrackBias1.AddSpot;  
  
  // Remove a position and override remaning ones, if any
  TrackBias1.RemoveSpot;

  // Optionally, you can use custom captions
  TrackBias1.NextSpotCaption := 'Response Bias'  
  
  // The next call to `AddSpot` will use your custom caption 
  TrackBias1.AddSpot;
  
  // Return all deltas in a byte array
  MyBytes := TrackBias1.Deltas;
  
  // Return all positions in a byte array
  MyBytes := TrackBias1.Positions;
  end;
  
  // Save spots to disk
  TrackBias1.Save;

  // Load spots from disk
  TrackBias1.Load;
  
```

## Dependecies

It inherits directly from TCustomControl and it depends on LCL and FCL packages.
