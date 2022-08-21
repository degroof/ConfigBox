//w,d,h,wall,lidZ,wdradius,hradius,interface,latch
//width across front
BOXWIDTH=1;
//front-to-back
BOXDEPTH=2;
//height
BOXHEIGHT=3;
//wall thickness
WALL=4;
//height at which the lid starts
LIDZ=5;
//lateral corner radius
WDRADIUS=6;
//vetical corner radius
HRADIUS=7;
//hinge, etc
INTERFACETYPE=8;
//latch type
LATCHTYPE=9;
//latch type
OVERLAP=10;

//sides
FRONT=1;
TOP=2;
LEFT=3;
RIGHT=4;
BACK=5;
BOTTOM=6;

//value to represent nothing
NONE=0;

//interface types
HINGE=1;
SNAP=2;
SLIDE=3;
FLEX=4;
PINHINGE=5;

//latches
FRICTION=1;
FLAP=2;

//shapes
ELLIPSE=1;
RECTANGLE=2;
OVAL=3;
POLYGON=4;

//extrusion types
THROUGH=1;
ENGRAVED=2;
RAISED=3;

//boundaries between spec types
MAX2D=100;
MAXSTRUCT=199;
MAXVOID=299;

//specs
//extrudable 2D features
GRID=1;  //side,type,external,x,y,z,angle,l,w,h,r, shape,spl,spw,thickness,invert
SHAPE=2; //side,type,external,x,y,z,angle,l,w,h,r,shape
SVG=3;   //side,type,external,x,y,z,angle,l,w,h,filename
TEXT=4;  //side,type,external,x,y,z,angle,l,w,h,text,size,typeface
CIRCTEXT=5;  //side,type,external,x,y,z,angle,l,w,h,text,size,typeface,r,arc
KNOCKOUT=6; //side,type,external,x,y,z,angle,l,w,r,shape

//common structures
STANDOFF=101; //side,x,y,z,dia,h,boreDia,boredepth
TORUS=102; //side,x,y,z,outerDia,innerDia

//common voids
COUNTERBORE=201; //side,x,y,z,dia,h
COUNTERSINK=202; //side,x,y,z,outerDia,innerDia
HEXBORE=203; //side,x,y,z,width,h
SQUAREBORE=204; //side,x,y,z,width,h

//the box (only one allowed)
BOX=500; //w,d,h,wall,lidz,wdradius,hradius,interfaceType,latchType

clr=0.05;

$fn=40;

module rbCorner(whRadius,depthRadius)
{
  whr=whRadius>0?whRadius:.01;
  dr=depthRadius>0?depthRadius:.01;
  if(dr<=whr/2)
  {
    rotate([90,0,0])
    rotate_extrude()
    translate([whr-dr,0,0])
    circle(dr);
  }
  else
  {
    scale([whr,dr,whr])
    sphere(r=1);
  }
}

// rectangular prism with rounded corners
module roundedBox(width,depth, height, whRadius,depthRadius)
{
  tr=whRadius-depthRadius;
  hull()
  {
    translate([whRadius,depthRadius,whRadius])
    rbCorner(whRadius,depthRadius);

    translate([width-whRadius,depthRadius,whRadius])
    rbCorner(whRadius,depthRadius);

    translate([width-whRadius,depth-depthRadius,whRadius])
    rbCorner(whRadius,depthRadius);

    translate([whRadius,depth-depthRadius,whRadius])
    rbCorner(whRadius,depthRadius);

    translate([whRadius,depthRadius,height-whRadius])
    rbCorner(whRadius,depthRadius);

    translate([width-whRadius,depthRadius,height-whRadius])
    rbCorner(whRadius,depthRadius);

    translate([width-whRadius,depth-depthRadius,height-whRadius])
    rbCorner(whRadius,depthRadius);

    translate([whRadius,depth-depthRadius,height-whRadius])
    rbCorner(whRadius,depthRadius);
      
  }
}

module snapHinge(tabs=2,thickness=4,length=120,leafWidth=25,clearance=.25,swingLimitTop=45,swingLimitBottom=0,bumpHeight=1)
{     
  f=tabs*2;
  difference()
  {
    union()
    {
      difference()
      {
        //body overlap
        translate([0,-thickness/4-leafWidth/2,0])
        cube([length,leafWidth+thickness/2,thickness],center=true);
        //cyl cuts
        for(c=[0:tabs-1])
        {
          translate([-length/2+length*0.75/tabs+length/tabs*c,0,0])
          rotate([0,90,0])
          cylinder(h=length/2/tabs+clearance*2,d=thickness,center=true,$fn=40);
        }
        //top swing limit
        rotate([90+swingLimitTop/2,0,0])
        translate([-length,0,-length*2])
        cube(length*2);

        //bottom swing limit
        rotate([-swingLimitBottom/2,0,0])
        translate([-length,0,-length*2])
        cube(length*2);

      }
      //tabs
      for(c=[0:tabs-1])
      {
        translate([-length/2+length/4/tabs+length/tabs*c,0,0])
        rotate([0,90,0])
        cylinder(h=length/2/tabs-clearance,d=thickness,center=true,$fn=40);
      }
      //bumps
      for(i=[1:f-1])
      {
        if(i<tabs && i%2==0)
        {
          translate([-length/2+i*length/f+clearance/2,0,0])
          scale([bumpHeight,thickness*.8-clearance,thickness*.8-clearance])
          sphere(d=1,$fn=20);
        }
        if(i>tabs && i%2==1)
        {
          translate([-length/2+i*length/f-clearance/2,0,0])
          scale([bumpHeight,thickness*.8-clearance,thickness*.8-clearance])
          sphere(d=1,$fn=20);
        }
      }
    }
    //dents
    for(i=[1:f-1])
    {
      if(i<tabs && i%2==1)
      {
        translate([-length/2+i*length/f-clearance/2,0,0])
        scale([bumpHeight,thickness*.8-clearance,thickness*.8-clearance])
        sphere(d=1,$fn=20);
      }
      if(i>tabs && i%2==0)
      {
        translate([-length/2+i*length/f+clearance/2,0,0])
        scale([bumpHeight,thickness*.8-clearance,thickness*.8-clearance])
        sphere(d=1,$fn=20);
      }
    }
  }
}


module pinHinge(tabs=2,thickness=4,length=120,leafWidth=25,clearance=.25)
{     
  f=tabs*2;
  difference()
  {
    union()
    {
      difference()
      {
        //body overlap
        translate([0,-thickness/4-leafWidth/2,0])
        cube([length,leafWidth+thickness/2,thickness],center=true);
        //cyl cuts
        for(c=[0:tabs-1])
        {
          translate([-length/2+length*0.75/tabs+length/tabs*c,0,0])
          rotate([0,90,0])
          cylinder(h=length/2/tabs+clearance*2,d=thickness,center=true,$fn=40);
        }
        //top swing limit
        rotate([135,0,0])
        translate([-length,0,-length*2])
        cube(length*2);

        //bottom swing limit
        rotate([-45,0,0])
        translate([-length,0,-length*2])
        cube(length*2);
      }
      //tabs
      for(c=[0:tabs-1])
      {
        translate([-length/2+length/4/tabs+length/tabs*c,0,0])
        rotate([0,90,0])
        cylinder(h=length/2/tabs-clearance,d=thickness,center=true,$fn=40);
      }
    }
    //pin hole
    rotate([0,90,0])
    cylinder(d=2,h=length*2,center=true);
    
  }
}


//cut an indent or through hole
module cut(box,spec)
{
  f=spec[0];
  if(f>=GRID && f<=MAX2D && (spec[2]==THROUGH || spec[2]==ENGRAVED))
  {
    //side,type,external,x,y,z,angle
    side=spec[1];
    type=spec[2];
    external=spec[3];
    x=spec[4];
    y=spec[5];
    z=spec[6];
    h=type==THROUGH?0:spec[10];
    
    xt=side==BOTTOM||side==TOP?box[BOXWIDTH]-x:side==RIGHT?box[WALL]/2:side==LEFT?box[BOXWIDTH]-box[WALL]/2:side==FRONT?box[BOXWIDTH]-x:x;
    yt=side==BOTTOM?box[BOXDEPTH]-y:side==RIGHT?box[BOXDEPTH]-x:side==TOP?box[BOXDEPTH]-y:side==LEFT?x:side==FRONT?box[BOXDEPTH]-box[WALL]/2:box[WALL]/2;
    zt=side==BOTTOM?box[WALL]/2:side==RIGHT||side==LEFT||side==FRONT||side==BACK?y:side==TOP?box[BOXHEIGHT]-box[WALL]/2:0;
    xa=side==FRONT?-90:side==BACK?90:TOP?180:0;
    ya=side==BOTTOM?0:side==TOP?180:side==RIGHT?90:side==LEFT?-90:0;
    za=0;

    translate([xt,yt,zt])
    rotate([xa,ya,za])
    
    translate([0,0,h>0?(external?(z+box[WALL]/2):(-box[WALL]/2-z-h)):type==THROUGH?-box[WALL]*.75+z:external?z:-box[WALL]-z])
    rotate([0,0,side==BOTTOM?180:side==RIGHT?90:side==RIGHT?90:side==LEFT?-90:side==FRONT?-180:0])
    linear_extrude(h>0?h:type==THROUGH?box[WALL]*1.5:box[WALL])
    if(f==GRID)
    {
      grid(spec);
    } else if(f==SHAPE)
    {
      shape(spec);
    } else if(f==TEXT)
    {
      txt(spec);
    } else if(f==CIRCTEXT)
    {
      circtxt(spec);
    } else if(f==KNOCKOUT)
    {
      knockout(box,spec);
    } else if(f==SVG)
    {
      svg(spec);
    }
  }
}

//raise a shape
module raise(box,spec)
{
  f=spec[0];
  if(f>=GRID && f<=MAX2D && (spec[2]==RAISED))
  {
    //side,type,external,x,y,z,angle,l,w,h,r
    side=spec[1];
    external=spec[3];
    x=spec[4];
    y=spec[5];
    z=spec[6];
    h=spec[10];
    extr=h==0?box[WALL]:h+box[WALL]/2;
    offs=external?-box[WALL]/2+z:-extr-box[WALL]/2-z;
    
    xt=side==BOTTOM||side==TOP?box[BOXWIDTH]-x:side==RIGHT?0:side==LEFT?box[BOXWIDTH]:side==FRONT?box[BOXWIDTH]-x:x;
    yt=side==BOTTOM?box[BOXDEPTH]-y:side==RIGHT?box[BOXDEPTH]-x:side==TOP?box[BOXDEPTH]-y:side==LEFT?x:side==FRONT?box[BOXDEPTH]:0;
    zt=side==BOTTOM?0:side==RIGHT||side==LEFT||side==FRONT||side==BACK?y:side==TOP?box[BOXHEIGHT]:0;
    xa=side==FRONT?-90:side==BACK?90:TOP?180:0;
    ya=side==BOTTOM?0:side==TOP?180:side==RIGHT?90:side==LEFT?-90:0;
    za=0;
    intersection()
    {
      if(!external)
      {
        externalExtents(box);
      }
      translate([xt,yt,zt])
      rotate([xa,ya,za])
      translate([0,0,offs])
      rotate([0,0,side==BOTTOM?180:side==RIGHT?90:side==RIGHT?90:side==LEFT?-90:side==FRONT?-180:0])
      linear_extrude(extr)
      if(f==GRID)
      {
        grid(spec);
      } else if(f==SHAPE)
      {
        shape(spec);
      } else if(f==TEXT)
      {
        txt(spec);
      } else if(f==CIRCTEXT)
      {
        circtxt(spec);
      } else if(f==SVG)
      {
        svg(spec);
      }
    }
  }
}

//add a structure
module struct(box,spec)
{
  f=spec[0];
  side=spec[1];
  x=spec[2];
  y=spec[3];
  z=spec[4];
  tx=side==BOTTOM?box[BOXWIDTH]-x:side==TOP?box[BOXWIDTH]-x:side==RIGHT?z:side==LEFT?box[BOXWIDTH]-z:side==FRONT?box[BOXWIDTH]-x:side==BACK?x:x;
  ty=side==BOTTOM?box[BOXDEPTH]-y:side==TOP?box[BOXDEPTH]-y:side==RIGHT?box[BOXDEPTH]-x:side==LEFT?x:side==FRONT?box[BOXDEPTH]-z:side==BACK?z:y;
  tz=side==BOTTOM?z:side==TOP?box[BOXHEIGHT]-z:side==RIGHT?y:side==LEFT?y:side==FRONT?y:side==BACK?y:z;
  ax=side==TOP?180:side==FRONT?90:side==BACK?-90:0;
  ay=side==RIGHT?90:side==LEFT?-90:0;
  az=0;
  translate([tx,ty,tz])
  rotate([ax,ay,az])
  if(f==TORUS)
  {
    torus(spec);
  } else if(f==STANDOFF)
  {
    standoff(box,spec);
  }
}


//subtract a void
module void(box,spec)
{
  f=spec[0];
  side=spec[1];
  x=spec[2];
  y=spec[3];
  z=spec[4];
  tx=side==BOTTOM?box[BOXWIDTH]-x:side==TOP?box[BOXWIDTH]-x:side==RIGHT?z:side==LEFT?box[BOXWIDTH]-z:side==FRONT?box[BOXWIDTH]-x:side==BACK?x:x;
  ty=side==BOTTOM?box[BOXDEPTH]-y:side==TOP?box[BOXDEPTH]-y:side==RIGHT?box[BOXDEPTH]-x:side==LEFT?x:side==FRONT?box[BOXDEPTH]-z:side==BACK?z:y;
  tz=side==BOTTOM?z:side==TOP?box[BOXHEIGHT]-z:side==RIGHT?y:side==LEFT?y:side==FRONT?y:side==BACK?y:z;
  ax=side==TOP?180:side==FRONT?90:side==BACK?-90:0;
  ay=side==RIGHT?90:side==LEFT?-90:0;
  az=0;
  translate([tx,ty,tz])
  rotate([ax,ay,az])
  translate([0,0,-.005])
  if(f==COUNTERBORE)
  {
    union()
    {
      cylinder(d=spec[5],h=spec[6]);
      cylinder(d=spec[5],h=.005,center=true);
    }
  } else if(f==HEXBORE)
  {
    union()
    {
      cylinder(d=spec[5]/sin(60),h=spec[6],$fn=6);
      cylinder(d=spec[5]/sin(60),h=.005,center=true,$fn=6);
    }
  } else if(f==SQUAREBORE)
  {
    rotate([0,0,45])
    union()
    {
      cylinder(d=spec[5]/sin(45),h=spec[6],$fn=4);
      cylinder(d=spec[5]/sin(45),h=.005,center=true,$fn=4);
    }
  } else if(f==COUNTERSINK)
  {
    od=spec[5];
    id=spec[6];
    ht=(od-id)/2/tan(45);
    union()
    {
      cylinder(d1=od,d2=id,h=ht);
      cylinder(d=od,h=.005,center=true);
    }
  }
}


//the box before being split up into top and bottom
module envelope(box)
{
  union()
  {
    difference()
    {
      translate([0,0,box[BOXHEIGHT]])
      rotate([-90,0,0])
      roundedBox(width=box[BOXWIDTH],depth=box[BOXHEIGHT], height=box[BOXDEPTH], whRadius=box[WDRADIUS],depthRadius=box[HRADIUS]);
      internalExtents(box);
    }
  }
}


//the internal volume of the box; used to limit the size of internal features
module internalExtents(box)
{
  
  translate([box[WALL],box[WALL],box[BOXHEIGHT]-box[WALL]])
  rotate([-90,0,0])
  roundedBox(width=box[BOXWIDTH]-box[WALL]*2,depth=box[BOXHEIGHT]-box[WALL]*2, height=box[BOXDEPTH]-box[WALL]*2, whRadius=max(box[WDRADIUS]-box[WALL],0),depthRadius=max(box[HRADIUS]-box[WALL],0));
}

//the external volume of the box; used to limit the size of features
module externalExtents(box)
{
  translate([0,0,box[BOXHEIGHT]])
  rotate([-90,0,0])
  roundedBox(width=box[BOXWIDTH],depth=box[BOXHEIGHT], height=box[BOXDEPTH], whRadius=box[WDRADIUS],depthRadius=box[HRADIUS]);
}



//friction latch on opening
module frictionLatch(box)
{
  //size of frictionLatch
  frictionLatchSize=min((box[BOXHEIGHT]-box[LIDZ])/sqrt(2)*2,box[LIDZ]/sqrt(2)*2,10);
  //width of lid notch
  lidNotch=min(box[BOXWIDTH]/1,10);
  mirror([1,0,0])
  translate([frictionLatchSize/2,0,0])
  union()
  {
   difference()
    {
      union()
      {
        translate([0,-frictionLatchSize/sqrt(2),-frictionLatchSize*0])
        cube([frictionLatchSize,frictionLatchSize*sqrt(2),frictionLatchSize*sqrt(2)],center=true);
        rotate([45,0,0])
        cube(frictionLatchSize,center=true);
      }
      //thumb cutout
      translate([box[WALL]+frictionLatchSize/2,frictionLatchSize/2,frictionLatchSize])
      cube(frictionLatchSize*2,center=true);
      //dimple
      translate([-frictionLatchSize/2,frictionLatchSize*sqrt(.5)/4,frictionLatchSize*sqrt(.5)/4])
      sphere(d=min(frictionLatchSize/5,box[WALL]*2));
      //outer cutoff
      translate([0,frictionLatchSize+frictionLatchSize*sqrt(.5)-box[WALL]/2,0])
      cube(frictionLatchSize*2,center=true);
      //lower cutoff
      translate([0,0,frictionLatchSize*(1+sqrt(.5))-box[WALL]*sqrt(.5)])
      cube(frictionLatchSize*2,center=true);
      translate([0,-frictionLatchSize,frictionLatchSize])
      cube(frictionLatchSize*2,center=true);    
    }
    translate([-frictionLatchSize/2,frictionLatchSize*sqrt(.5)/4,-frictionLatchSize*sqrt(.5)/4])
    sphere(d=min(frictionLatchSize/5,box[WALL]*2));
  }
}


//flap latch on opening
module flap(box,top=true)
{
  flapWidth=max(box[BOXWIDTH]/4,20);
  flapHeight=min(box[LIDZ]-box[HRADIUS],box[BOXHEIGHT]-box[LIDZ]-box[HRADIUS])*2;
  translate([box[BOXWIDTH]/2,box[BOXDEPTH]+box[WALL]/4,box[LIDZ]])
  if(top)
  {
    difference()
    {
      hull()
      {
        translate([-flapWidth/2+box[HRADIUS],0,-flapHeight/2+box[HRADIUS]])
        rotate([90,0,0])
        cylinder(r=box[HRADIUS],h=box[WALL]/2,center=true);
        translate([flapWidth/2-box[HRADIUS],0,-flapHeight/2+box[HRADIUS]])
        rotate([90,0,0])
        cylinder(r=box[HRADIUS],h=box[WALL]/2,center=true);
        translate([0,0,flapHeight/2-box[WALL]/4])
        cube([flapWidth,box[WALL]/2,box[WALL]/2],center=true);
      }
      translate([0,box[WALL]/4,flapHeight/2])
      rotate([-45,0,0])
      cube([flapWidth*2,box[WALL]*sqrt(.5),box[WALL]*sqrt(.5)],center=true);
      translate([0,-box[WALL]/2,-flapHeight/2])
      cube([flapWidth/2,box[WALL],box[WALL]/2],center=true);
      translate([0,-box[WALL]/4,-flapHeight/3])
      rotate([0,90,0])
      cylinder(d=box[WALL]/2,flapWidth/2, center=true);
    }
  }
  else
  {
    translate([0,-box[WALL]/4,-flapHeight/3])
    rotate([0,90,0])
    cylinder(d=box[WALL]/2,flapWidth/2, center=true);
  }
}


module snapLid(box,top)
{
  snapHeight=min((box[BOXHEIGHT]-box[LIDZ]-box[WALL]),4);
  bump=box[WALL]/16;
  difference()
  {
    translate([0,0,box[LIDZ]])
    union()
    {
      hull()
      {
        translate([box[WDRADIUS]+(top?-clr:0),box[WDRADIUS]+(top?-clr:0),0])
        cylinder(r=max(box[WDRADIUS]-box[WALL]/2,0.001),h=snapHeight); 
        translate([box[BOXWIDTH]-box[WDRADIUS]-(top?-clr:0),box[WDRADIUS]+(top?-clr:0),0])
        cylinder(r=max(box[WDRADIUS]-box[WALL]/2,0.001),h=snapHeight); 
        translate([box[WDRADIUS]+(top?-clr:0),box[BOXDEPTH]-box[WDRADIUS]-(top?-clr:0),0])
        cylinder(r=max(box[WDRADIUS]-box[WALL]/2,0.001),h=snapHeight); 
        translate([box[BOXWIDTH]-box[WDRADIUS]-(top?-clr:0),box[BOXDEPTH]-box[WDRADIUS]-(top?-clr:0),0])
        cylinder(r=max(box[WDRADIUS]-box[WALL]/2,0.001),h=snapHeight);
      }
      translate([box[WALL]/2-bump,box[WALL]/2-bump,snapHeight*.625])
      rotate([-90,0,0])
      roundedBox(width=box[BOXWIDTH]-box[WALL]+bump*2,depth=snapHeight/4, height=box[BOXDEPTH]-box[WALL]+bump*2, whRadius=box[WDRADIUS]-box[WALL]/2+bump,depthRadius=bump);
    }
    if(!top)
    {
      internalExtents(box);
    }
  } 
}





//create a shape (side,type,external,x,y,z,angle,l,w,h,r,shape)
module shape(spec)
{
  assert(len(spec)>=13,str("Shape spec must contain at least 13 values: ",spec));
  shape=spec[12];
  assert(is_num(shape) && shape>=ELLIPSE && shape<=POLYGON,str("Shape value: (",shape,") is invalid: ",spec));
  side=spec[1];
  assert(is_num(side) && side>=FRONT && side<=BOTTOM,str("Side value: (",side,") is invalid: ",spec));
  l=spec[8];
  assert(is_num(l),str("Length value: (",l,") is invalid: ",spec));
  w=spec[9];
  assert(is_num(w),str("Width value: (",w,") is invalid: ",spec));
  r=spec[11];
  assert(is_num(r),str("Radius value: (",r,") is invalid: ",spec));
  angle=(side==BOTTOM?-1:1)*spec[7];
  assert(is_num(angle),str("Angle value: (",angle,") is invalid: ",spec));
  rotate([0,0,angle])
  if(shape==ELLIPSE)
  {
    scale([l,w])
    circle(d=1);
  } else if(shape==RECTANGLE)
  {
    if(r>0)
    {
      hull()
      {
        translate([-l/2+r,-w/2+r])
        circle(r=r);
        translate([-l/2+r,w/2-r])
        circle(r=r);
        translate([l/2-r,-w/2+r])
        circle(r=r);
        translate([l/2-r,w/2-r])
        circle(r=r);
      }
    }
    else
    {
      square([l,w],center=true);
    }
  } else if(shape==OVAL)
  {
    hull()
    {
      translate([l>w?-(l-w)/2:0,l>w?0:-(w-l)/2])
      circle(d=min(l,w));
      translate([l>w?(l-w)/2:0,l>w?0:(w-l)/2])
      circle(d=min(l,w));
    }
  } else if(shape==POLYGON)
  {
    assert(len(spec)==14,str("Polygon spec must contain 14 values: ",spec));
    assert(is_list(spec[13]) && len(spec[13])>1,str("Polygon spec[13] must be a list and must contain at least 2 points: ",spec[13]));
    pr=max(r,.0001);
    hull()
    {
      for(pt=spec[13])
      {
        px=pt[0];
        py=pt[1];
        d0=sqrt(px^2+py^2);
        dx=px*pr/d0;
        dy=py*pr/d0;
        translate([px-dx,py-dy])
        circle(r=pr);
      }
    }
  }
}

//create a grid (side,type,external,x,y,z,angle,l,w,h,r, shape,spl,spw,thickness,invert)
module grid(spec)
{
  assert(len(spec)==17,str("Grid spec must contain 17 values: ",spec));
  shape=spec[12];
  assert(is_num(shape) && side>=ELLIPSE && shape<=RECTANGLE,str("Shape of grid: (",shape,") is invalid: ",spec));
  side=spec[1];
  assert(is_num(side) && side>=FRONT && side<=BOTTOM,str("Side value: (",side,") is invalid: ",spec));
  l=spec[8];
  assert(is_num(l),str("Length value: (",l,") is invalid: ",spec));
  w=spec[9];
  assert(is_num(w),str("Width value: (",w,") is invalid: ",spec));
  r=spec[11];
  assert(is_num(r),str("Radius value: (",r,") is invalid: ",spec));
  angle=(side==BOTTOM?-1:1)*spec[7];
  assert(is_num(angle),str("Angle value: (",angle,") is invalid: ",spec));
  spl=spec[13];
  assert(is_num(spl),str("Length spacing value: (",spl,") is invalid: ",spec));
  spw=spec[14];
  assert(is_num(spw),str("Width spacing value: (",spw,") is invalid: ",spec));
  th=spec[15];
  assert(is_num(spw),str("Thickness value: (",spw,") is invalid: ",spec));
  invert=spec[16];
  assert(is_bool(invert),str("Invert grid value: (",invert,") is invalid: ",spec));
  rotate([0,0,angle])
  if(shape==ELLIPSE)
  {
    rings=min(l,w)/spl/2;
    spokes=round(180/spw);
    inca=180/spokes;
    difference()
    {
      if(invert)
      {
        scale([l,w])
        circle(d=1);
      }
      intersection()
      {
        union()
        {
          for(i=[0:rings])
          {
            difference()
            {
              scale([i*l/rings/2+th,i*w/rings/2+th])
              circle(r=1);
              scale([i*l/rings/2,i*w/rings/2])
              circle(r=1);
            }
          }
          for(an=[0:inca:179])
          {
            rotate([0,0,an])
            square([th,max(l,w)],center=true);
          }
          difference()
          {
            scale([l,w])
            circle(d=1);
            scale([l-th*2,w-th*2])
            circle(d=1);
          }
        }
        scale([l,w])
        circle(d=1);
      }
    }
  } 
  else if(shape==RECTANGLE)
  {
    difference()
    {
      if(invert)
      {
        if(r>0)
        {
          hull()
          {
            translate([-l/2+r,-w/2+r])
            circle(r=r);
            translate([-l/2+r,w/2-r])
            circle(r=r);
            translate([l/2-r,-w/2+r])
            circle(r=r);
            translate([l/2-r,w/2-r])
            circle(r=r);
          }
        }
        else
        {
          square([l,w],center=true);
        }
      }
      intersection()
      {
        if(r>0)
        {
          hull()
          {
            translate([-l/2+r,-w/2+r])
            circle(r=r);
            translate([-l/2+r,w/2-r])
            circle(r=r);
            translate([l/2-r,-w/2+r])
            circle(r=r);
            translate([l/2-r,w/2-r])
            circle(r=r);
          }
        }
        else
        {
          square([l,w],center=true);
        }
        union()
        {
          for(y0=[-w/2+th/2:spw:w/2-th/2])
          {
            translate([0,y0])
            square([l,th],center=true);
          }
          for(x0=[-l/2+th/2:spl:l/2-th/2])
          {
            translate([x0,0])
            square([th,w],center=true);
          }
        }
      }
    }
  }
}

//create a knockout (side,type,external,x,y,z,angle,l,w,r,shape)
module knockout(box,spec)
{
  assert(len(spec)==12,str("Knockout spec must contain 12 values: ",spec));
  shape=spec[11];
  assert(is_num(shape) && shape>=ELLIPSE && shape<=RECTANGLE,str("Shape of knockout: (",shape,") is invalid: ",spec));
  side=spec[1];
  assert(is_num(side) && side>=FRONT && side<=BOTTOM,str("Side value: (",side,") is invalid: ",spec));
  l=spec[8];
  assert(is_num(l),str("Length value: (",l,") is invalid: ",spec));
  w=spec[9];
  assert(is_num(w),str("Width value: (",w,") is invalid: ",spec));
  r=spec[10];
  assert(is_num(r),str("Radius value: (",r,") is invalid: ",spec));
  r0=max(r-box[WALL]/2,.01);
  l0=l-box[WALL];
  w0=w-box[WALL];
  angle=(side==BOTTOM?-1:1)*spec[7];
  rotate([0,0,angle])
  difference()
  {
    if(shape==ELLIPSE)
    {
      difference()
      {
        scale([l,w])
        circle(d=1);
        scale([l0,w0])
        circle(d=1);
      }
    } else if(shape==RECTANGLE)
    {
      difference()
      {
        if(r>0)
        {
          hull()
          {
            translate([-l/2+r,-w/2+r])
            circle(r=r);
            translate([-l/2+r,w/2-r])
            circle(r=r);
            translate([l/2-r,-w/2+r])
            circle(r=r);
            translate([l/2-r,w/2-r])
            circle(r=r);
          }
        }
        else
        {
          square([l,w],center=true);
        }
        if(r0>0)
        {
          hull()
          {
            translate([-l0/2+r0,-w0/2+r0])
            circle(r=r0);
            translate([-l0/2+r0,w0/2-r0])
            circle(r=r0);
            translate([l0/2-r0,-w0/2+r0])
            circle(r=r0);
            translate([l0/2-r0,w0/2-r0])
            circle(r=r0);
          }
        }
        else
        {
          square([l0,w0],center=true);
        }

      }
    } else if(shape==OVAL)
    {
      difference()
      {
        hull()
        {
          translate([l>w?-(l-w)/2:0,l>w?0:-(w-l)/2])
          circle(d=min(l,w));
          translate([l>w?(l-w)/2:0,l>w?0:(w-l)/2])
          circle(d=min(l,w));
        }
        hull()
        {
          translate([l0>w0?-(l0-w0)/2:0,l0>w0?0:-(w0-l0)/2])
          circle(d=min(l0,w0));
          translate([l0>w0?(l0-w0)/2:0,l0>w0?0:(w0-l0)/2])
          circle(d=min(l0,w0));
        }
      }
    }
    if(l>=w*2)
    {
      translate([-l/6,0])
      square([box[WALL]/2,w*2],center=true);
      translate([l/6,0])
      square([box[WALL]/2,w*2],center=true);
    }
    else
    {
      square([box[WALL]/2,w*2],center=true);
    }
    if(w>=l*2)
    {
      translate([0,-w/6])
      square([l*2,box[WALL]/2],center=true);
      translate([0,w/6])
      square([l*2,box[WALL]/2],center=true);
    }
    else
    {
      square([l*2,box[WALL]/2],center=true);
    }
  }
}

//create text (side,type,external,x,y,z,angle,l,w,h,text,size,typeface)
module txt(spec)
{
  assert(len(spec)==14,str("Text spec must contain 14 values: ",spec));
  ext=spec[3];
  assert(is_bool(ext),str("External value: (",ext,") is invalid: ",spec));
  angle=spec[7];
  assert(is_num(angle),str("Angle value: (",angle,") is invalid: ",spec));
  t=spec[11];
  assert(is_string(t),str("Text value: (",t,") is invalid: ",spec));
  size=spec[12];
  assert(is_num(size),str("Text size value: (",size,") is invalid: ",spec));
  typeface=spec[13];
  assert(is_string(typeface),str("Typeface value: (",typeface,") is invalid: ",spec));
  rotate([0,0,angle])
  mirror([ext?0:1,0,0])
  text(text=t,size=size,font=typeface,halign="center",valign="center");
}

//create text in a circular arc (side,type,external,x,y,z,angle,l,w,h,text,size,typeface,r,arc)
module circtxt(spec)
{
  assert(len(spec)==16,str("Circular text spec must contain 16 values: ",spec));
  ext=spec[3];
  assert(is_bool(ext),str("External value: (",ext,") is invalid: ",spec));
  angle=spec[7];
  assert(is_num(angle),str("Angle value: (",angle,") is invalid: ",spec));
  t=spec[11];
  assert(is_string(t),str("Text value: (",t,") is invalid: ",spec));
  size=spec[12];
  assert(is_num(size),str("Text size value: (",size,") is invalid: ",spec));
  typeface=spec[13];
  assert(is_string(typeface),str("Typeface value: (",typeface,") is invalid: ",spec));
  r=spec[14];
  assert(is_num(r),str("Radius value: (",r,") is invalid: ",spec));
  arc=spec[15];
  assert(is_num(arc),str("Arc value: (",arc,") is invalid: ",spec));
  chars=len(t);
  inca=arc/(chars-1) ;
  rotate([0,0,angle])
  mirror([ext?0:1,0,0])
  for (i = [0:chars-1])
  {
    rotate([0,0,-inca*i])
    translate([0,r])
    text(text=t[i],size=size,font=typeface,halign="center",valign="center");
  }
}

//create SVG pattern (side,type,external,x,y,z,angle,l,w,h,filename)
module svg(spec)
{
  assert(len(spec)==12,str("SVG spec must contain 12 values: ",spec));
  ext=spec[3];
  assert(is_bool(ext),str("External value: (",ext,") is invalid: ",spec));
  angle=spec[7];
  assert(is_num(angle),str("Angle value: (",angle,") is invalid: ",spec));
  l=spec[8];
  assert(is_num(l),str("Length value: (",l,") is invalid: ",spec));
  w=spec[9];
  assert(is_num(w),str("Width value: (",w,") is invalid: ",spec));
  filename=spec[11];
  assert(is_string(filename),str("File name value: (",filename,") is invalid: ",spec));
  rotate([0,0,angle])
  mirror([ext?0:1,0,0])
  scale([l/200,w/200])
  translate([-100,-100])
  import(file=filename);
}

//a torus (side,x,y,z,outerDia,innerDia)
module torus(spec)
{
  assert(len(spec)==7,str("Torus spec must contain 7 values: ",spec));
  od=spec[5];
  assert(is_num(od),str("Outer diameter value: (",od,") is invalid: ",spec));
  id=spec[6];
  assert(is_num(id),str("Inner diameter value: (",id,") is invalid: ",spec));
  assert(od>id,str("Outer diameter must be greater than inner diameter: ",spec));
  rotate_extrude()
  translate([id/4+od/4,0])
  circle(d=(od-id)/2);
}

//a cylindrical standoff (side,x,y,z,dia,h,boreDia,boredepth)
module standoff(box,spec)
{
  assert(len(spec)>=9,str("Standoff spec must contain 9 values: ",spec));
  d=spec[5];
  assert(is_num(d),str("Diameter value: (",d,") is invalid: ",spec));
  h=spec[6];
  assert(is_num(h),str("Height value: (",h,") is invalid: ",spec));
  bd=spec[7];
  assert(is_num(bd),str("Bore diameter value: (",bd,") is invalid: ",spec));
  bdt=spec[8];
  assert(is_num(bdt),str("Bore depth value: (",bdt,") is invalid: ",spec));
  translate([0,0,box[WALL]])
  difference()
  {
    cylinder(h=h,d=d);
    translate([0,0,h])
    cylinder(h=bdt*2,d=bd,center=true);
  }
}


//the top of the box
module top(specs,box)
{
  //size of slide overlap
  slideHeight=box[OVERLAP]==0?(box[BOXHEIGHT]-box[LIDZ]-box[HRADIUS])/2:box[OVERLAP];
  //size of frictionLatch
  frictionLatchSize=min((box[BOXHEIGHT]-box[LIDZ])/sqrt(2)*2,box[LIDZ]/sqrt(2)*2,10);
  //width of lid notch
  lidNotch=min(box[BOXWIDTH]/1,10);
  difference() // - voids & cuts 
  {
    union() //+structures+raised shapes on top
    {
      difference() //-interface indents  
      {
        union() // +latches +hinges
        {
          difference()// -lid cutoff 
          {
            union() //envelope+structures+raised shapes on sides
            {
              //START envelope+structures+raised shapes on sides
              envelope(box);
              //additions that are neither top nor bottom should be clipped at lid line
              for(f=specs)
              {
                if(f[0]>MAX2D && f[0]<=MAXSTRUCT && f[1]!=BOTTOM && f[1]!=TOP)
                {
                  struct(box,f);
                }
              }
              for(f=specs)
              {
                if(f[0]>NONE && f[0]<=MAX2D && f[1]!=BOTTOM && f[1]!=TOP)
                {
                  raise(box,f);
                }
              }
              //END envelope+structures+raised shapes on sides
            }
            //START -lid cutoff
            translate([box[BOXWIDTH]/2,box[BOXDEPTH]/2,-box[BOXHEIGHT]+box[LIDZ]])
            cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]*2],center=true);
            //END -lid cutoff
          }
          //START + hinges and latches
          if(box[LATCHTYPE]==FRICTION)
          {
            //friction latch on front
            difference()
            {
              translate([box[BOXWIDTH]/2,box[BOXDEPTH],box[LIDZ]])
              rotate([0,180,0])
              frictionLatch(box);
              translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,box[BOXHEIGHT]])
              cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
              externalExtents(box);
            }
            //friction latch on back if slide top
            if(box[INTERFACETYPE]==SLIDE)
            {
              difference()
              {
                translate([box[BOXWIDTH]/2,0,box[LIDZ]])
                rotate([0,0,180])
                rotate([0,180,0])
                frictionLatch(box);
                translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,box[BOXHEIGHT]])
                cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
                externalExtents(box);
              }
            }
          }
          else if(box[LATCHTYPE]==FLAP)
          {
            //flap on front
            flap(box,true);
            if(box[INTERFACETYPE]==SLIDE)
            {
              //flap on back if slide top
              translate([box[BOXWIDTH],box[BOXDEPTH],0])
              rotate([0,0,180])
              flap(box,true);
            }
          }
          if(box[INTERFACETYPE]==HINGE)
          {
            difference()
            {
              //hinge
              translate([box[BOXWIDTH]/2,-box[WALL],box[LIDZ]])
              rotate([135,180,0])
              snapHinge(tabs=max(2,floor((box[BOXWIDTH]-box[WALL]*2)/25)),thickness=box[WALL]*2,length=box[BOXWIDTH]-box[WDRADIUS]*2,leafWidth=box[WALL]*2,clearance=clr,swingLimitTop=90,swingLimitBottom=90,bumpHeight=box[WALL]/2);
              translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,box[BOXHEIGHT]])
              cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
              internalExtents(box);
            }
          } else if(box[INTERFACETYPE]==PINHINGE)
          {
            difference()
            {
              //hinge
              translate([box[BOXWIDTH]/2,-box[WALL],box[LIDZ]])
              rotate([135,180,0])
              pinHinge(tabs=max(2,floor((box[BOXWIDTH]-box[WALL]*2)/25)),thickness=box[WALL]*2,length=box[BOXWIDTH]-box[WDRADIUS]*2,leafWidth=box[WALL]*2,clearance=clr);
              translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,box[BOXHEIGHT]])
              cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
              internalExtents(box);
            }
          } else if(box[INTERFACETYPE]==FLEX)
          {
            //flex hinge
            hull()
            {
              translate([box[BOXWIDTH]/2,0,box[LIDZ]+box[WALL]*1.5])
              cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]/2,box[WALL]*3],center=true);
              translate([box[BOXWIDTH]/2,-box[WALL]*1.5,box[LIDZ]+box[WALL]/4])
              cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]*2.5,box[WALL]/2],center=true);
            }
            translate([box[BOXWIDTH]/2,-box[WALL]*1.5,box[LIDZ]+box[WALL]/8])
            cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]*3,box[WALL]/4],center=true);
          }
          //END + hinges and latches
        }
        //START -interface indents
        if(box[INTERFACETYPE]==SNAP)
        {
          //indent for snap lid
          snapLid(box,true);
          translate([box[BOXWIDTH]/2,box[BOXDEPTH]-box[WALL]+lidNotch/2,-lidNotch/2+box[LIDZ]+box[WALL]/2])
          cube(lidNotch,center=true);
        }
        else if(box[INTERFACETYPE]==SLIDE || (box[INTERFACETYPE]!=SNAP && box[OVERLAP]>0))
        {
          //indent for slide lid
          translate([0,0,slideHeight/2-box[WALL]/2])
          hull()
          {
            translate([box[WDRADIUS]-clr,box[WDRADIUS]-clr,box[LIDZ]])
            cylinder(r=max(box[WDRADIUS]-box[WALL]/2,.01),h=slideHeight+box[WALL],center=true); 
            translate([box[BOXWIDTH]-box[WDRADIUS]+clr,box[WDRADIUS]-clr,box[LIDZ]])
            cylinder(r=max(box[WDRADIUS]-box[WALL]/2,.01),h=slideHeight+box[WALL],center=true); 
            translate([box[WDRADIUS]-clr,box[BOXDEPTH]-box[WDRADIUS]+clr,box[LIDZ]])
            cylinder(r=max(box[WDRADIUS]-box[WALL]/2,.01),h=slideHeight+box[WALL],center=true); 
            translate([box[BOXWIDTH]-box[WDRADIUS]+clr,box[BOXDEPTH]-box[WDRADIUS]+clr,box[LIDZ]])
            cylinder(r=max(box[WDRADIUS]-box[WALL]/2,.01),h=slideHeight+box[WALL],center=true);
          } 
        }
        //END -interface indents
      }
      //START +structures+raised shapes on top
      //additions that are on the top should not be clipped at lid line
      //structures on top (standoffs, etc)
      for(f=specs)
      {
        if(f[0]>MAX2D && f[0]<=MAXSTRUCT && f[1]==TOP)
        {
          struct(box,f);
        }
      }
      //raised 2D shapes
      for(f=specs)
      {
        if(f[0]>NONE && f[0]<=MAX2D && f[1]==TOP)
        {
          raise(box,f);
        }
      }
      //END +structures+raised shapes on top
    }
    //START - voids and cuts
    //cutouts made from 2D shapes
    for(f=specs)
    {
      cut(box,f);
    }
    //subtract voids
    for(f=specs)
    {
      if(f[0]>MAXSTRUCT && f[0]<=MAXVOID && f[1]!=BOTTOM)
      {
        void(box,f);
      }
    }
    //END - voids and cuts
  }
}

//bottom section
module bottom(specs,box)
{
  //size of slide overlap
  slideHeight=box[OVERLAP]==0?(box[BOXHEIGHT]-box[LIDZ]-box[HRADIUS])/2:box[OVERLAP];
  //size of frictionLatch
  frictionLatchSize=min((box[BOXHEIGHT]-box[LIDZ])/sqrt(2)*2,box[LIDZ]/sqrt(2)*2,10);
  //width of lid notch
  lidNotch=min(box[BOXWIDTH]/1,10);
  union()  // + latches & hinges
  {
    difference()  // - voids & cuts
    {
      union()  // +interface protrusions + raised shapes & structures on bottom
      {
        difference() // - lid cutoff 
        {
            union() //envelope + side structures & raised shapes
            {
              //START envelope + side structures & raised shapes
              envelope(box);
              //additions that are neither top nor bottom should be clipped at lid line
              for(f=specs)
              {
                if(f[0]>MAX2D && f[0]<=MAXSTRUCT && f[1]!=TOP && f[1]!=BOTTOM)
                {
                  struct(box,f);
                }
              }
              for(f=specs)
              {
                if(f[0]>NONE && f[0]<=MAX2D && f[1]!=TOP && f[1]!=BOTTOM)
                {
                  raise(box,f);
                }
              }
              //END envelope + side structures & raised shapes
            }
          //START lid cutoff
          translate([box[BOXWIDTH]/2,box[BOXDEPTH]/2,box[BOXHEIGHT]+box[LIDZ]])
          cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]*2],center=true);
          //END lid cutoff
        }
        //START +interface protrusions + raised shapes & structures on bottom
        if(box[INTERFACETYPE]==SNAP)
        {
          //add bump for snap lid
          snapLid(box,false);
        }
        else if(box[INTERFACETYPE]==SLIDE || (box[INTERFACETYPE]!=SNAP && box[OVERLAP]>0))
        {
          //add slide lid extension
          difference()
          {
            hull()
            {
              translate([box[WDRADIUS],box[WDRADIUS],box[LIDZ]-box[WALL]])
              cylinder(r=box[WDRADIUS]-box[WALL]/2,h=slideHeight+box[WALL]); 
              translate([box[BOXWIDTH]-box[WDRADIUS],box[WDRADIUS],box[LIDZ]-box[WALL]])
              cylinder(r=box[WDRADIUS]-box[WALL]/2,h=slideHeight+box[WALL]); 
              translate([box[WDRADIUS],box[BOXDEPTH]-box[WDRADIUS],box[LIDZ]-box[WALL]])
              cylinder(r=box[WDRADIUS]-box[WALL]/2,h=slideHeight+box[WALL]); 
              translate([box[BOXWIDTH]-box[WDRADIUS],box[BOXDEPTH]-box[WDRADIUS],box[LIDZ]-box[WALL]])
              cylinder(r=box[WDRADIUS]-box[WALL]/2,h=slideHeight+box[WALL]);
            }
            internalExtents(box);
          } 
        }
        //additions that are on the bottom should not be clipped at lid line
        //add structures on bottom (standoffs)
        for(f=specs)
        {
          if(f[0]>MAX2D && f[0]<=MAXSTRUCT && f[1]==BOTTOM)
          {
            struct(box,f);
          }
        }
        //add raised 2D shapes on bottom 
        for(f=specs)
        {
          if(f[0]>NONE && f[0]<=MAX2D && f[1]==BOTTOM)
          {
            raise(box,f);
          }
        }
        //END +interface protrusions + raised shapes & structures on bottom
      }
      
      //START - voids & cuts
      //subtract voids (countersinks, etc)
      for(f=specs)
      {
        if(f[0]>MAXSTRUCT && f[0]<=MAXVOID && f[1]!=TOP)
        {
          void(box,f);
        }
      }
      //subtract 2D cuts
      for(f=specs)
      {
        cut(box,f);
      }
      //END - voids & cuts
    }
    // START + latches & hinges
    if(box[LATCHTYPE]==FRICTION)
    {
      //friction latch on front
      difference()
      {
        translate([box[BOXWIDTH]/2,box[BOXDEPTH],box[LIDZ]])
        frictionLatch(box);
        internalExtents(box);
        translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,-box[BOXHEIGHT]])
        cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
      }
      //friction latch on back if slide top
      if(box[INTERFACETYPE]==SLIDE)
      {
        difference()
        {
          translate([box[BOXWIDTH]/2,0,box[LIDZ]])
          rotate([0,0,180])
          frictionLatch(box);
          internalExtents(box);
          translate([-box[BOXWIDTH]/2,-box[BOXDEPTH]/2,-box[BOXHEIGHT]])
          cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]]);
        }
      }
    }
    else if(box[LATCHTYPE]==FLAP)
    {
      //flap on front
      flap(box,false);
      if(box[INTERFACETYPE]==SLIDE)
      {
        //flap on back if slide top
        translate([box[BOXWIDTH],box[BOXDEPTH],0])
        rotate([0,0,180])
        flap(box,false);
      }
    }
   
    if(box[INTERFACETYPE]==HINGE)
    {
      //pop hinge
      difference()
      {
        translate([box[BOXWIDTH]/2,-box[WALL],box[LIDZ]])
        rotate([90+45,0,0])
        snapHinge(tabs=max(2,floor((box[BOXWIDTH]-box[WALL]*2)/25)),thickness=box[WALL]*2,length=box[BOXWIDTH]-box[WDRADIUS]*2,leafWidth=box[WALL]*2,clearance=clr,swingLimitTop=90,swingLimitBottom=90,bumpHeight=box[WALL]/2);
        translate([0,0,-box[BOXHEIGHT]])
        cube([box[BOXWIDTH],box[BOXDEPTH],box[BOXHEIGHT]]);
        internalExtents(box);
      }
    } else if(box[INTERFACETYPE]==PINHINGE)
    {
      //pin hinge
      difference()
      {
        translate([box[BOXWIDTH]/2,-box[WALL],box[LIDZ]])
        rotate([90+45,0,0])
        pinHinge(tabs=max(2,floor((box[BOXWIDTH]-box[WALL]*2)/25)),thickness=box[WALL]*2,length=box[BOXWIDTH]-box[WDRADIUS]*2,leafWidth=box[WALL]*2,clearance=clr);
        translate([0,0,-box[BOXHEIGHT]])
        cube([box[BOXWIDTH],box[BOXDEPTH],box[BOXHEIGHT]]);
        internalExtents(box);
      }
    } else if(box[INTERFACETYPE]==FLEX)
    {
      hull()
      {
        //flex hinge
        translate([box[BOXWIDTH]/2,0,box[LIDZ]-box[WALL]*1.5])
        cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]/2,box[WALL]*3],center=true);
        translate([box[BOXWIDTH]/2,-box[WALL]*1.5,box[LIDZ]-box[WALL]/4])
        cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]*2.5,box[WALL]/2],center=true);
      }
      translate([box[BOXWIDTH]/2,-box[WALL]*1.5,box[LIDZ]-box[WALL]/8])
      cube([box[BOXWIDTH]-box[WDRADIUS]*2,box[WALL]*3,box[WALL]/4],center=true);
    }
    //END + latches & hinges
  }
}




//render the box with top and bottom on the same level
module renderPrintable(specs,box)
{
  translate([box[BOXWIDTH],box[BOXDEPTH],0])
  rotate([0,0,180])
  {
    bottom(specs,box);
    translate([0,-box[WALL]*6,0])
    rotate([180,0,0])
    translate([0,0,-box[BOXHEIGHT]])
    top(specs,box);
  }
}



//render
module renderAssembled(specs,box,open,section)
{
  translate([box[BOXWIDTH]/2,box[BOXDEPTH]/2,0])
  rotate([0,0,180])
  difference()
  {
    union()
    {
      bottom(specs,box);
      ift=box[INTERFACETYPE];
      if(open)
      {
        if(ift==SNAP || ift==SLIDE || ift==NONE)
        {
          snapHeight=min((box[BOXHEIGHT]-box[LIDZ]-box[WALL]),4);
          slideHeight=box[OVERLAP]==0?(box[BOXHEIGHT]-box[LIDZ]-box[HRADIUS])/2:box[OVERLAP];
          translate([0,0,ift==SNAP?snapHeight+box[WALL]/2:ift==SLIDE?slideHeight+box[WALL]/2:box[WALL]/2])
          top(specs,box);
        }
        else if(ift==HINGE || ift==PINHINGE)
        {
          translate([0,-box[WALL],box[LIDZ]])
          rotate([90,0,0])
          translate([0,box[WALL],-box[LIDZ]])
          top(specs,box);
        }
        else if(ift==FLEX)
        {
          translate([0,-box[WALL]/2,box[LIDZ]+box[WALL]/4])
          rotate([45,0,0])
          translate([0,box[WALL]/2,-box[LIDZ]-box[WALL]/4])
          top(specs,box);
        }
      }
      else
      {
        translate([0,0,clr])
        top(specs,box);
      }
    }
    if(section!=NONE)
    {
      translate([section==RIGHT?box[BOXWIDTH]/2:section==LEFT?-box[BOXWIDTH]*1.5:-box[BOXWIDTH]/2,section==BACK?box[BOXDEPTH]/2:section==FRONT?-box[BOXDEPTH]*1.5:-box[BOXDEPTH]/2,section==TOP?-box[BOXHEIGHT]*1.5:section==BOTTOM?box[BOXHEIGHT]/2:-box[BOXHEIGHT]/2])
      cube([box[BOXWIDTH]*2,box[BOXDEPTH]*2,box[BOXHEIGHT]*2]);
    }
  }
}
//convenience functions

//the box (only one allowed)
//w,d,h,wall,lidz,wdradius,hradius,interfaceType,latchType
function Box(w=100,d=75,h=50,wall=2,lidz=25,wdradius=10,hradius=3,interfaceType=HINGE,latchType=FRICTION,overlap=0)=[BOX,w,d,h,wall,lidz,wdradius,hradius,interfaceType,latchType,overlap];

//side,type,external,x,y,z,angle,l,w,h,r,shape,spl,spw,thickness,invert
function Grid(side=TOP,type=ENGRAVED,external=true,x=50,y=50,z=0,angle=0,l=22,w=22,h=0,r=0,shape=RECTANGLE,spl=3,spw=3,thickness=1,invert=false) = [GRID,side,type,external,x,y,z,angle,l,w,h,r,shape,spl,spw,thickness,invert];

//side,type,external,x,y,z,angle,l,w,h,r,shape
function Shape(side=TOP,type=ENGRAVED,external=true,x=25,y=25,z=0,angle=0,l=10,w=10,h=0,r=3,shape=RECTANGLE) = [SHAPE,side,type,external,x,y,z,angle,l,w,h,r,shape];

//side,type,external,x,y,z,dia,h
function Circle(side=TOP,type=ENGRAVED,external=true,x=25,y=40,z=0,dia=10,h=0) = [SHAPE,side,type,external,x,y,z,0,dia,dia,h,0,ELLIPSE];

//side,type,external,x,y,z,l,w,h
function Oval(side=TOP,type=ENGRAVED,external=true,x=25,y=50,z=0,angle=0,l=10,w=5,h=0) = [SHAPE,side,type,external,x,y,z,angle,l,w,h,0,OVAL];

//side,type,external,x,y,z,w,h
function Square(side=TOP,type=ENGRAVED,external=true,x=25,y=10,z=0,w=10,h=0,r=0) = [SHAPE,side,type,external,x,y,z,0,w,w,h,r,RECTANGLE];

//side,type,external,x,y,z,w,h
function Hexagon(side=TOP,type=ENGRAVED,external=true,x=25,y=60,z=0,w=10,h=0,r=0) = [SHAPE,side,type,external,x,y,z,0,0,0,h,r,POLYGON,[[0,w/sin(60)/2],[0,-w/sin(60)/2],[-w*.5,-w*.25],[w*.5,-w*.25],[-w*.5,w*.25],[w*.5,w*.25],]];

//side,type,external,x,y,z,h,points
function Polygon(side=TOP,type=ENGRAVED,external=true,x=75,y=35,z=0,h=0,r=0.5,points=[[-7.7,3.3],[7.7,3.3],[-7.7,0],[7.7,0],[-5.3,-3.3],[5.3,-3.3]]) = [SHAPE,side,type,external,x,y,z,0,0,0,h,r,POLYGON,points];

//side,type,external,x,y,z,angle,l,w,h,filename
function Svg(side=TOP,type=ENGRAVED,external=true,x=75,y=50,z=0,angle=0,l=20,w=20,h=0,filename="fleur.svg") = [SVG,side,type,external,x,y,z,angle,l,w,h,filename];

//side,type,external,x,y,z,angle,h,text,size,typeface
function Text(side=TOP,type=ENGRAVED,external=true,x=50,y=15,z=0,angle=0,h=0,text="Text",size=6,typeface="Verdana:style=Regular") = [TEXT,side,type,external,x,y,z,angle,0,0,h,text,size,typeface];

//side,type,external,x,y,z,angle,h,text,size,typeface,r,arc
function CircularText(side=TOP,type=ENGRAVED,external=true,x=50,y=25,z=0,angle=90,h=0,text="Circular Text",size=3,typeface="Verdana:style=Regular",r=10,arc=180) = [CIRCTEXT,side,type,external,x,y,z,angle,0,0,h,text,size,typeface,r,arc];

//side,external,x,y,z,angle,l,w,r,shape
function Knockout(side=TOP,x=75,y=20,angle=0,l=20,w=10,r=6,shape=RECTANGLE) = [KNOCKOUT,side,THROUGH,true,x,y,0,angle,l,w,r,shape];

//side,x,y,z,dia,h,boreDia,boredepth
function Standoff(side=BOTTOM,x=50,y=50,dia=6,h=20,boreDia=2.9,boreDepth=12) = [STANDOFF,side,x,y,0,dia,h,boreDia,boreDepth];

//side,x,y,z,outerDia,innerDia
function Torus(side=LEFT,x=37.5,y=25,z=0,outerDia=6,innerDia=3) = [TORUS,side,x,y,z,outerDia,innerDia];

//side,x,y,z,dia,h
function Counterbore(side=TOP,x=10,y=20,z=0,dia=6,h=2) = [COUNTERBORE,side,x,y,z,dia,h];

//side,x,y,z,w,h
function Hexbore(side=TOP,x=10,y=30,z=0,w=6,h=2) = [HEXBORE,side,x,y,z,w,h];

//side,x,y,z,w,h
function Squarebore(side=TOP,x=10,y=40,z=0,w=6,h=2) = [SQUAREBORE,side,x,y,z,w,h];

//side,x,y,z,outerDia,innerDia
function Countersink(side=TOP,x=10,y=50,z=0,outerDia=6,innerDia=3) = [COUNTERSINK,side,x,y,z,outerDia,innerDia];

//side,x,y,z,h,dia
function Post(side=BOTTOM,x=50,y=25,z=0,h=20,dia=6) = [STANDOFF,side,x,y,z,dia,h,0,0];

//side,external,x,y,dia
function Hole(side=TOP,x=10,y=60,dia=6) = [SHAPE,side,THROUGH,true,x,y,0,0,dia,dia,0,0,ELLIPSE];


module makeBox(specifications,printable=true,open=false,section=NONE)
{
  specs=specifications;
  assert(is_list(specs),str("Specifications must be a list: ",specs));
  
  bxs = [ for(b=specs) if(b[0]==BOX) b ];
  assert(len(bxs)==1,str("Specifications must contain exactly 1 box: ",specs));
  box = bxs.len==0?NONE:bxs[0];
  //w,d,h,wall,lidz,wdradius,hradius,interfaceType,latchType
  assert(len(box)==11,str("Box spec must contain 11 values: ",box));
  assert(is_num(box[1]),str("Box width value: (",box[1],") is invalid: ",box));
  assert(is_num(box[2]),str("Box depth value: (",box[2],") is invalid: ",box));
  assert(is_num(box[3]),str("Box height value: (",box[3],") is invalid: ",box));
  assert(is_num(box[4]),str("Box wall thickness value: (",box[4],") is invalid: ",box));
  assert(is_num(box[5]),str("Box top elevation value: (",box[5],") is invalid: ",box));
  assert(is_num(box[6]),str("Box horizontal corner radius value: (",box[6],") is invalid: ",box));
  assert(is_num(box[7]),str("Box vertical corner radius value: (",box[7],") is invalid: ",box));
  assert(is_num(box[8]) && box[8]>=NONE && box[8]<=PINHINGE,str("Box interface type: (",box[8],") is invalid: ",box));
  assert(is_num(box[9]) && box[9]>=NONE && box[9]<=FLAP,str("Box latch type: (",box[9],") is invalid: ",box));
  assert(is_num(box[10]) && box[10]>=0,str("Box overlap: (",box[10],") is invalid: ",box));
  assert(box[8]!=FLEX || box[5]==box[3]/2,str("Box interface type FLEX requires lidz to be exactly half box height:",[box[5],box[3]]));
  if(printable)
  {
    renderPrintable(specs,box);
  }
  else
  {
    renderAssembled(specs,box,open,section);
  }
}

