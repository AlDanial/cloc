;; This is SKILL
;; https://www.mics.ece.vt.edu/ICDesign/Tutorials/Cadence/layout_pg5.html

/*
  This procedure will change the bulk node values of nfet3 and pfet3
  to be vss! and vdd!, respectively.
*/

procedure(cb(lib cell)
;let will allow you to access the cv and newlabel variables outside
;of this procedure
let((cv newLabel)
;open the cellview as a database object and assign it to cv
cv = dbOpenCellViewByType(lib cell "schematic" "" "a")
;for loop to go through all instances in this cellview
foreach(instancecv~>instances
;open the property window -- this will display the window!
geSelectObjectNoFilter(instance)
schHiObjectProperty()
;check the cellname and change the bulk node (bn) property
if(schObjPropForm->cellName->value == "nfet3"
then
schObjPropForm->bn->value = "vss!"
if(schObjPropForm->cellName->value == "pfet3"
then
schObjPropForm->bn->value = "vdd!"
;close the form
hiFormDone(schObjPropForm)
geDeselectAll()
);end foreach
);end of let
);end procedure
