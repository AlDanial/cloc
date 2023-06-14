// https://raw.githubusercontent.com/UBaer21/UB.scad/main/examples/UBexamples/Rounds.scad
include<ub.scad>//https://github.com/UBaer21/UB.scad
/*[Hidden]*/
  useVersion=22.016;
  designVersion=1.1;
  info=true;

/*[ Round Objects ]*/
r=[16,8,4,2]; // corner 1-4 radius - can also be just a number


LinEx(20) Quad(20);

LinEx() Quad([25,30],r=r);
Tz(20)LinEx2()Rund(1,2)Stern(5,r1=12,r2=5);

Rundrum(x=30,y=40,r=r)Quad(x=15,y=20,r=r/2,center=false);
Tz(30)Rundrum(x=15,eck=3,r=3)Quad(x=5,y=3,r=1,center=false);

T(50)Pille(l=20,d=10);
T(65)Pille(l=20,d=10,rad=[1,15]);
T(80)Pille(l=20,d=10,rad=1);



T(-50) {
  RotEx()T(10)Pille();
  RotEx()T(-8)Pille();
}
T(-80) Kassette(gon=3,r=5,help=1);
T(-80,30) Kassette(gon=4,r=[5,2,4,1],mitte=false,help=1);

T(-80,60)Rundrum(20,20,r=5,grad=60,grad2=120)rotate(90)Vollwelle(extrude=1);

T(-50,30) RotEx()T(10)Quad(5);

T(y=-60){
  
  Prisma(10,20,30,c1=5,s=3);
  T(15)Prisma(10,20,30,x2=5,y2=10,c1=5,s=3);
  T(30)Prisma(10,20,30,x2=5,y2=10,x2d=10,c1=5,s=3);
  T(60) Box(20,z=20,eck=5,s=5,c=10,outer=false);// outer = x= side radius or edge
  
  T(-30) Tz(15)Superellipse(r=[10,20,30]/2,help=1);
  T(-50) Tz(15)Superellipse(r=[10,20,30]/2,n=10);
  T(-70) Tz(15)Superellipse(r=[10,20,30]/2,n=4,n3=20);
  
}


T(y=90){
  Torus(trx=5,help=1);
  Torus(dia=30,d=5,end=true);
  Torus(dia=43,d=5,end=1,grad=270);
  Torus(dia=59,d=5,end=+10,grad=270)Quad($d,10);
  Torus(dia=79,trxEnd=-9,d=5,end=1,grad=270)Quad($d,10);
  T(80) Polar(3)RingSeg(120,r=15,help=1,size=3,h=5,fn2=16);
}

T(y=160){
  RStern();
  T(x=50) RStern(messpunkt=0)circle();
}
