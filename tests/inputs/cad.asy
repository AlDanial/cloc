// https://asymptote.sourceforge.io/gallery/CAD1.asy
import CAD;

sCAD cad=sCAD.Create();

/* Freehand line
this is a comment
*/
draw(g=cad.MakeFreehand(pFrom=(3,-1)*cm,(6,-1)*cm),
     p=cad.pFreehand);

// Standard measurement lines
draw(g=box((0,0)*cm,(1,1)*cm),p=cad.pVisibleEdge);
cad.MeasureParallel(L="$\sqrt{2}$",
                    pFrom=(0,1)*cm,
                    pTo=(1,0)*cm,
                    dblDistance=-15mm);

// Label inside,shifted to the right; arrows outside
draw(g=box((2,0)*cm,(3,1)*cm),p=cad.pVisibleEdge);
cad.MeasureParallel(L="1",
                    pFrom=(2,1)*cm,
                    pTo=(3,1)*cm,
                    dblDistance=5mm,
                    dblLeft=5mm,
                    dblRelPosition=0.75);

// Label and arrows outside
draw(g=box((5,0)*cm,(5.5,1)*cm),p=cad.pVisibleEdge);
cad.MeasureParallel(L="0.5",
                    pFrom=(5,1)*cm,
                    pTo=(5.5,1)*cm,
                    dblDistance=5mm,
                    dblLeft=10mm,
                    dblRelPosition=-1);

// Small bounds,asymmetric measurement line
draw(g=box((7,0)*cm,(7.5,1)*cm),p=cad.pVisibleEdge);
cad.MeasureParallel(L="0.5",
                    pFrom=(7,1)*cm,
                    pTo=(7.5,1)*cm,
                    dblDistance=5mm,
                    dblLeft=2*cad.GetMeasurementBoundSize(bSmallBound=true),
                    dblRight=10mm,
                    dblRelPosition=2,
                    bSmallBound=true);
