include <ConfigBox.scad>
wall=2;
sph=35;
spdia=38.5;
sprdia=20;
kdia=50;
sprh=40;
cl=.5;


bd=27;
bhd=24;


d=wall*2+bd*2.5;
h=wall+sprh;
w=wall*2+kdia+bd*2;


specs=[

  Box(w=w,h=h,d=d,wdradius=2,hradius=2,interfaceType=SNAP,latchType=NONE,lidz=h/2),
  //encoder
  Hole(side=TOP,dia=sprdia+cl,y=d/2,x=w-wall-cl-kdia/2),

  Oval(side=TOP,type=ENGRAVED,w=3.25,l=4,y=d/2,x=w-wall-cl-kdia/2-14,z=-10,h=20),
  Oval(side=TOP,type=ENGRAVED,z=-wall/2,w=5.6,l=6.35,y=d/2,x=w-wall-cl-kdia/2-14),
  Post(side=TOP,h=3,z=-1,dia=7.5,y=d/2,x=w-wall-cl-kdia/2-14),
  
  Oval(side=TOP,type=ENGRAVED,angle=120,w=3.25,l=4,y=d/2-14*sin(60),x=w-wall-cl-kdia/2+7,z=-10,h=20),
  Oval(side=TOP,type=THROUGH,angle=120,w=5.6,l=6.35,y=d/2-14*sin(60),x=w-wall-cl-kdia/2+7),
  Post(side=TOP,h=3,z=-1,dia=7.5,y=d/2-14*sin(60),x=w-wall-cl-kdia/2+7),

  Oval(side=TOP,type=ENGRAVED,angle=240,w=3.25,l=4,y=d/2+14*sin(60),x=w-wall-cl-kdia/2+7,z=-10,h=20),
  Oval(side=TOP,type=THROUGH,angle=240,w=5.6,l=6.35,y=d/2+14*sin(60),x=w-wall-cl-kdia/2+7),
  Post(side=TOP,h=3,z=-1,dia=7.5,y=d/2+14*sin(60),x=w-wall-cl-kdia/2+7),

  
  //buttons
  Hole(side=TOP,dia=bhd+cl,x=wall+bd*.6,y=d/2),
  Hole(side=TOP,dia=bhd+cl,y=d/2-d/4,x=wall+bd*1.5),
  Hole(side=TOP,dia=bhd+cl,y=d/2+d/4,x=wall+bd*1.5),
  
  //arduino
  Shape(side=LEFT,y=wall+3,x=10+wall,external=false,r=0,w=6,l=20),
  Shape(side=LEFT,y=wall+4,x=10+wall,type=THROUGH,w=10,l=11,r=1),
  Shape(side=BOTTOM,y=d-wall-10,x=wall+36,h=6,type=RAISED,external=false,w=20,l=5,r=1),
  Shape(side=BOTTOM,y=d-wall-10,x=wall+34,z=4,h=2,type=RAISED,external=false,w=8,l=5,r=1),
  Shape(side=BOTTOM,y=d-wall-21.5,x=wall+16,h=4,type=RAISED,external=false,w=4,l=20,r=1),
];


difference()
{
makeBox(specs,true,false,NONE);
*  translate([-w/2,d/2,0])
  cube([80,20,20],center=true);
}

*color("#c0c0c0",1)
translate([-w/2,-d/2,0])
union()
{
  translate([wall+16,wall+10,wall])
  rotate([0,0,90])
  import("c:/data/stl/arduinoMicro.stl");
  
  translate([w-wall-cl-kdia/2,d/2,h+17])
  rotate([180,0,0])
  import("c:/data/stl/spinnerKnob.stl");

  translate([w-wall-cl-kdia/2,d/2,wall])
  rotate([0,0,60])
  import("c:/data/stl/rotaryEncoder.stl");

  translate([wall+bd*.6,d/2,h])
  import("c:/data/stl/pb24mm.stl");
  translate([wall+bd*1.5,d/4,h])
  import("c:/data/stl/pb24mm.stl");
  translate([wall+bd*1.5,d*3/4,h])
  import("c:/data/stl/pb24mm.stl");
}

