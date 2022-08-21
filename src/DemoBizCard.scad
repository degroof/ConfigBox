include <ConfigBox.scad>

wall=2;
iw=93;
id=53;
ih=8;
w=iw+wall*2;
d=id+wall*2;
h=ih+wall*2;
lz=h-wall*2;
ol=h-lz-wall-.2;


specs=[
//w,d,h,wall,lidz,wdradius,hradius,interfaceType,latchType,overlap
  Box(w=w,d=d,h=h,lidz=lz,wdradius=2,hradius=1,overlap=ol,latchType=FRICTION),
  //side,type,external,x,y,z,angle,l,w,h,filename
  Svg(x=95/2,y=58/2,l=25,w=25,z=.5,filename="fleur.svg"),
];

makeBox(specs,printable=true);
