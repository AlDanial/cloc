(* 
    http://spot.colorado.edu/~sitelic/samplecode/mathematica/imagesfile.html
 *)

image = Import["denise.png","PNG"]   (* or *)

image = Import["denise.gif","GIF"]

A = image[[1,1]]/255.;
ListDensityPlot[A,Mesh->False, AspectRatio->Automatic]

(*
        -- or -- 
 *)

Show[Graphics[Raster[A]], AspectRatio->Automatic]


blurA = ListConvolve[Table[1/25,{5},{5}],A];

Show[Graphics[Raster[blurA]], AspectRatio->Automatic]
B = Fourier[A];

(*
          delete
    higher frequencies *)

B[[Range[30,278],All]]=0;

B[[All,Range[30,202]]]=0;

Show[Graphics[Raster[ Re[InverseFourier[B]] ]], AspectRatio->Automatic]
