include <ConfigBox.scad>

piw=56;
pil=85;
pih=16.8;
pith=1.5;
wl=2;
bcl=3;
tcl=6;
gap=1;
frontSpace=20;


w=pil+wl*2+gap*2;
d=piw+wl*2+gap*2+frontSpace;
h=pih+bcl+tcl+wl*2;

pix0=wl+gap;
piy0=wl+gap+frontSpace;
piz0=wl+bcl;

lidz=piz0+3;


function boardMount(x,y)=[Post(x=pix0+x,y=piy0+y,h=bcl,dia=7),
  Counterbore(side=BOTTOM,x=pix0+x,y=piy0+y),
  Counterbore(side=BOTTOM,x=pix0+x,y=piy0+y,h=bcl*2,dia=3),  Standoff(side=TOP,x=pix0+x,y=piy0+y,h=h-wl*2-bcl-pith)
];

specs=[
  Box(w=w,h=h,d=d,interfaceType=NONE,latchType=NONE,overlap=1,wdradius=6,lidz=lidz),
  //USB1
  Shape(type=THROUGH,side=LEFT,x=piy0+9-frontSpace,y=piz0+9.5,w=16,l=16,r=1),
  //USB2
  Shape(type=THROUGH,side=LEFT,x=piy0+27-frontSpace,y=piz0+9.5,w=16,l=16,r=1),
  //Ethernet
  Shape(type=THROUGH,side=LEFT,x=piy0+45.5-frontSpace,y=piz0+8,w=15,l=17,r=1),
  //USB-C
  Oval(side=BACK,type=THROUGH,w=6.5,l=11.8,x=pix0+11.5,y=piz0+3),
  //HDMI1
  Oval(side=BACK,type=THROUGH,w=7.3,l=11.8,x=pix0+26,y=piz0+3),
  //HDMI2
  Oval(side=BACK,type=THROUGH,w=7.3,l=11.8,x=pix0+39.5,y=piz0+3),
  //Audio
  Circle(side=BACK,type=THROUGH,dia=7,x=pix0+54,y=piz0+4.5),
  //SD card
  Shape(type=THROUGH,side=RIGHT,x=piy0+27.5,y=piz0,l=17.5,w=9,r=1),
  //fan clip 1
  Shape(type=RAISED,external=false,side=TOP,x=pix0+42,y=piy0+23.5,l=2,w=7,h=8,r=0),
  Shape(type=RAISED,external=false,side=TOP,x=pix0+42.5,y=piy0+23.5,l=2,w=7,z=7,h=1,r=0),
  //fan clip 2
  Shape(type=RAISED,external=false,side=TOP,x=pix0+69,y=piy0+23.5,l=2,w=7,h=8,r=0),
  Shape(type=RAISED,external=false,side=TOP,x=pix0+68.5,y=piy0+23.5,l=2,w=7,z=7,h=1,r=0),
  //fan surround
  Shape(type=RAISED,external=false,side=TOP,x=pix0+55.5,y=piy0+23.5,l=29,w=29,h=2,r=3),
  Shape(side=TOP,type=ENGRAVED,external=false,x=pix0+55.5,y=piy0+23.5,z=0,l=25,w=25,h=3,r=2),
  //vents
  Grid(side=TOP,type=THROUGH,external=true,x=pix0+55.5,y=piy0+23.5,l=25,w=25,shape=ELLIPSE,spl=3,spw=60,thickness=1,invert=true),
  Grid(side=BOTTOM,type=THROUGH,external=true,x=w/2,y=d/2,l=31,w=22,shape=RECTANGLE,spl=10,spw=3,thickness=1,r=6,invert=true),
  //text
  Text(side=BACK,x=pix0+32,y=piz0+11,size=3,text="HDMI"),
  Text(side=BACK,x=pix0+11.5,y=piz0+11,size=3,text="PWR"),
  Text(side=BACK,x=pix0+54,y=piz0+11,size=3,text="AUDIO"),
];

makeBox(concat(specs,boardMount(23.5,3.5),boardMount(23.5,52.5),boardMount(23.5,3.5),boardMount(23.5,3.5),boardMount(81,52.5),boardMount(81,3.5)),printable=true,open=true,section=NONE);

