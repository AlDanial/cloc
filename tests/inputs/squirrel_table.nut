/*
 http://www.squirrel-lang.org/
*/
local table = {
	a = "10"
	subtable = {
		array = [1,2,3]
	},
	[10 + 123] = "expression index"
}
 
local array=[ 1, 2, 3, { a = 10, b = "string" } ];
 
foreach (i,val in array)
{
	::print("the type of val is"+typeof val);
}
 
/////////////////////////////////////////////
 
class Entity
{	
	constructor(etype,entityname)
	{
		name = entityname;
		type = etype;
	}
									
	x = 0;
	y = 0;
	z = 0;
	name = null;
	type = null;
}
 
function Entity::MoveTo(newx,newy,newz)
{
	x = newx;
	y = newy;
	z = newz;
}
