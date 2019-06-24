@LXCategory("Color")
public static class RGB_Solid extends LXPattern {
  
  final DiscreteParameter R = new DiscreteParameter("R", 128, 0, 255);
  final DiscreteParameter G = new DiscreteParameter("G", 128, 0, 255);
  final DiscreteParameter B = new DiscreteParameter("B", 128, 0, 255);
  final DiscreteParameter A = new DiscreteParameter("A", 254, 0, 255);
  
  
  public RGB_Solid(LX lx) {
    super(lx);
    addParameter(R);
    addParameter(G);
    addParameter(B);
    addParameter(A);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index]= LXColor.rgba( (int) R.getValue(),(int)G.getValue(), (int)B.getValue(),(int) A.getValue());
    }
  }
}   

@LXCategory("Color")
public static class RGB_Two_Color_Blend extends LXPattern {
  
  final CompoundParameter R1 = new CompoundParameter("R1", 1, 1, 254.);
  final CompoundParameter G1 = new CompoundParameter("G1", 128, 1, 254);
  final CompoundParameter B1 = new CompoundParameter("B1", 1, 1, 254);
  final CompoundParameter A1 = new CompoundParameter("A1", 254, 1, 254);
  final CompoundParameter R2 = new CompoundParameter("R2", 1, 1, 254);
  final CompoundParameter G2 = new CompoundParameter("G2", 1, 1, 254);
  final CompoundParameter B2 = new CompoundParameter("B2", 128, 1, 254);
  final CompoundParameter A2 = new CompoundParameter("A2", 254, 1, 254);
  final DiscreteParameter Div = new DiscreteParameter("Div", 2, 2, 128);
  
  public RGB_Two_Color_Blend(LX lx) {
    super(lx);
    addParameter(R1);
    addParameter(G1);
    addParameter(B1);
    addParameter(A1);
    addParameter(R2);
    addParameter(G2);
    addParameter(B2);
    addParameter(A2);
    addParameter(Div);
  }
  
  public void run(double deltaMs) {
    float div =  Div.getValuef();
    float xRange =  model.xMax - model.xMin;
    float xDiv= 1/div;
    float rDiv= 0;
    float gDiv= 0;
    float bDiv= 0;
    float xFactor = xRange/div;
    float midpoint = xRange/2;
    float rBlend= 0;
    float gBlend= 0;
    float bBlend= 0;
    float aBlend= 0;
    float r1 = R1.getValuef();
    float g1 = G1.getValuef();
    float b1 = B1.getValuef();
    float r2 = R2.getValuef();
    float g2 = G2.getValuef();
    float b2 = B2.getValuef();
    
    for (LXPoint p : model.points) {
      if(r2>=r1){
        rDiv = 0;
        } else if (r2 < r1) {
        rDiv = div; 
        }
      if(g2>=g1){
        gDiv = 0;
        } else if (g2 < g1){
        gDiv = div; 
        }
      if(b2>=b1){
        bDiv = 0;
        } else if (b2 < b1){
        bDiv = div; 
        }
      if (p.x >= 0) {
        rBlend= ((ceil(abs(rDiv - (p.x+midpoint)/xFactor)) * xDiv * max(1,abs(r1 - r2))))+ min( r1, r2);
        gBlend= ((ceil(abs(gDiv - (p.x+midpoint)/xFactor)) * xDiv * max(1,abs(g1 - g2))))+ min( g1, g2);
        bBlend= ((ceil(abs(bDiv - (p.x+midpoint)/xFactor) )* xDiv * max(1,abs(b1 - b2))))+ min( b1, b2);
        aBlend= A1.getValuef();// ((ceil(xRange/(p.x+midpoint)) * xDiv * abs(A1.getValuef() - A2.getValuef()))/xRange)+ min( A1.getValuef(), A2.getValuef());
        //println("min: " +ceil(rDiv - (p.x+midpoint)/xFactor) + " p.x: " + p.x + " abs:" + abs(r1 - r2));
        //println("xRange: " + xRange + " xDiv: " + xDiv);
       // println("midpoint: " + midpoint);
       
       // println("rhalf: " + ((ceil(xRange/(p.x+midpoint)) * xDiv * abs(R1.getValuef() - R2.getValuef()))/xRange));
       // println("rBlend: " + rBlend);
       // println(model.xMax ,model.xMin);
        colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
      } else if  (p.x < 0) {
        rBlend= (abs((ceil(-rDiv + (p.x+midpoint)/xFactor)) * xDiv * max(1,abs(r1 - r2))))+ min( r1, r2);
        gBlend= (abs((ceil(-gDiv + (p.x+midpoint)/xFactor)) * xDiv * max(1,abs(g1 - g2))))+ min( g1, g2);
        bBlend= (abs((ceil(-bDiv + (p.x+midpoint)/xFactor)) * xDiv * max(1,abs(b1 - b2))))+ min( b1, b2);
        aBlend= A1.getValuef();//((ceil((p.x-midpoint)/div) * abs(A1.getValuef() - A2.getValuef()))/xRange)+ min( R1.getValuef(), R2.getValuef());
        colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
       // println("ceil2: " + ceil((p.x+midpoint)/xFactor) * rDiv+ " p.x: " + p.x );
       // println("rBlend2: " + rBlend);
      } 
        
        
    }
  }
}   

@LXCategory("Color")
public static class RGB_Three_Color_Blend extends LXPattern {
  
  final CompoundParameter R1 = new CompoundParameter("R1", 1, 1, 254.);
  final CompoundParameter G1 = new CompoundParameter("G1", 128, 1, 254);
  final CompoundParameter B1 = new CompoundParameter("B1", 1, 1, 254);
  final CompoundParameter R2 = new CompoundParameter("R2", 1, 1, 254);
  final CompoundParameter G2 = new CompoundParameter("G2", 1, 1, 254);
  final CompoundParameter B2 = new CompoundParameter("B2", 128, 1, 254);
  final CompoundParameter R3 = new CompoundParameter("R3", 1, 1, 254);
  final CompoundParameter G3 = new CompoundParameter("G3", 1, 1, 254);
  final CompoundParameter B3 = new CompoundParameter("B3", 128, 1, 254);
  final CompoundParameter A = new CompoundParameter("A", 254, 1, 254);
  final DiscreteParameter Div = new DiscreteParameter("Div", 2, 2, 128);
  
  public RGB_Three_Color_Blend(LX lx) {
    super(lx);
    addParameter(R1);
    addParameter(G1);
    addParameter(B1);
    addParameter(R2);
    addParameter(G2);
    addParameter(B2);
    addParameter(R3);
    addParameter(G3);
    addParameter(B3);
    addParameter(A);
    addParameter(Div);
  }
  
  public void run(double deltaMs) {
    float div =  Div.getValuef();
    float xRange =  model.xMax - model.xMin;
    float xDiv= 1/div;
    float rDiv= 0;
    float gDiv= 0;
    float bDiv= 0;
    float xFactor = xRange/div;
    float midpoint1 = xRange/4;
    float midpoint2 = 3 * xRange/4;
    float rBlend= 0;
    float gBlend= 0;
    float bBlend= 0;
    float aBlend= 0;
    float r1 = R1.getValuef();
    float g1 = G1.getValuef();
    float b1 = B1.getValuef();
    float r2 = R2.getValuef();
    float g2 = G2.getValuef();
    float b2 = B2.getValuef();
    float r3 = R3.getValuef();
    float g3 = G3.getValuef();
    float b3 = B3.getValuef();
    float pxOffset = 0;
    
    for (LXPoint p : model.points) {
        pxOffset = (xRange/2)- p.x;
        //println("pxOffset: " + pxOffset);
        if (p.x >= 0) {  
          if(r1>=r2){
            rDiv = 0;
            } else if (r1 < r2) {
            rDiv = div; 
            }
          if(g1>=g2){
            gDiv = 0;
            } else if (g1 < g2){
            gDiv = div; 
            }
          if(b1>=b2){
            bDiv = 0;
            } else if (b1 < b2){
            bDiv = div; 
            }
          if ( pxOffset <= midpoint1 && pxOffset >= 0) {
            rBlend= ((ceil(abs(rDiv - (p.x+midpoint1)/xFactor)) * xDiv * max(1,abs(r1 - r2))))+ min( r1, r2);
            gBlend= ((ceil(abs(gDiv - (p.x+midpoint1)/xFactor)) * xDiv * max(1,abs(g1 - g2))))+ min( g1, g2);
            bBlend= ((ceil(abs(bDiv - (p.x+midpoint1)/xFactor) )* xDiv * max(1,abs(b1 - b2))))+ min( b1, b2);
            aBlend= A.getValuef();
            colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
           // println("1: " + p.x);
          } else if (pxOffset >= midpoint1 && pxOffset <= (xRange/2))  {
            rBlend= (abs((ceil(-rDiv + (p.x+midpoint1)/xFactor)) * xDiv * max(1,abs(r1 - r2))))+ min( r1, r2);
            gBlend= (abs((ceil(-gDiv + (p.x+midpoint1)/xFactor)) * xDiv * max(1,abs(g1 - g2))))+ min( g1, g2);
            bBlend= (abs((ceil(-bDiv + (p.x+midpoint1)/xFactor)) * xDiv * max(1,abs(b1 - b2))))+ min( b1, b2);
            aBlend= A.getValuef();//((ceil((p.x-midpoint)/div) * abs(A1.getValuef() - A2.getValuef()))/xRange)+ min( R1.getValuef(), R2.getValuef());
            colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
           // println("2: " + p.x);
          }
        } else if (p.x < 0)  { 
          if(r2>=r3){
            rDiv = 0;
            } else if (r2 < r3) {
            rDiv = div; 
            }
          if(g2>=g3){
            gDiv = 0;
            } else if (g2 < g3){
            gDiv = div; 
            }
          if(b2>=b3){
            bDiv = 0;
            } else if (b2 < b3){
            bDiv = div; 
            }
          if (pxOffset <= midpoint2 && pxOffset > (xRange/2)) {
            rBlend= ((ceil(abs(rDiv - (p.x+midpoint2)/xFactor)) * xDiv * max(1,abs(r3 - r2))))+ min( r3, r2);
            gBlend= ((ceil(abs(gDiv - (p.x+midpoint2)/xFactor)) * xDiv * max(1,abs(g3 - g2))))+ min( g3, g2);
            bBlend= ((ceil(abs(bDiv - (p.x+midpoint2)/xFactor) )* xDiv * max(1,abs(b3 - b2))))+ min( b3, b2);
            aBlend= A.getValuef();
            colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
            // println("3: " + p.x);
          } else if  (pxOffset >= midpoint2 && pxOffset <= (model.xMax*2)) {
            rBlend= (abs((ceil(-rDiv + (p.x+midpoint2)/xFactor)) * xDiv * max(1,abs(r3 - r2))))+ min( r3, r2);
            gBlend= (abs((ceil(-gDiv + (p.x+midpoint2)/xFactor)) * xDiv * max(1,abs(g3 - g2))))+ min( g3, g2);
            bBlend= (abs((ceil(-bDiv + (p.x+midpoint2)/xFactor)) * xDiv * max(1,abs(b3 - b2))))+ min( b3, b2);
            aBlend= A.getValuef();//((ceil((p.x-midpoint)/div) * abs(A1.getValuef() - A2.getValuef()))/xRange)+ min( R1.getValuef(), R2.getValuef());
            colors[p.index]= LXColor.rgba( (int) rBlend,(int)gBlend, (int)bBlend,(int) aBlend);
            // println("4: " + p.x);
          }
        }
    }
  }
}

@LXCategory("Color")
public static class GrayTest extends LXPattern {
  
  final CompoundParameter thing = new CompoundParameter("Thing", 0, model.yRange);
  final SinLFO lfo = new SinLFO("Stuff", 0, 1, 2000);
  
  public GrayTest(LX lx) {
    super(lx);
    addParameter(thing);
    startModulator(lfo);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      //colors[p.index] = palette.getColor(max(0, 100 - 10*abs(p.y - thing.getValuef())));
      colors[p.index]= LXColor.gray(max(0, 100 - 10*abs(p.y - thing.getValuef())));
     //if (p.index == 0) {
      
      //println("LXColor value: " + (max(0, 100 - 10*abs(p.y - thing.getValuef()))));
     //}
    }
  }
}

@LXCategory("Color")
public static class ParCansColor extends EnvelopPattern {
    
  final CompoundParameter hue = new CompoundParameter("Hue", 0, 0, 360);
  final CompoundParameter saturation = new CompoundParameter("Saturation", 100, 0, 100);
  final CompoundParameter brightness = new CompoundParameter("Brightness", 100, 0, 100);
  
  public ParCansColor(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(saturation);
    addParameter(brightness);
  }
  
  public void run(double deltaMs) {
    
    for (Par par : model.pars) {
      for (LXPoint p : par.points) {
        colors[p.index] = LXColor.hsb( hue.getValuef() , saturation.getValuef(),brightness.getValuef());
      }
    }
  }
}

@LXCategory("Color")
public static class SplitColor extends EnvelopPattern {
    
  final CompoundParameter hue1 = new CompoundParameter("Hue 1", 0, 0, 360);
  final CompoundParameter saturation1 = new CompoundParameter("Sat 1", 100, 0, 100);
  final CompoundParameter brightness1 = new CompoundParameter("Bri 1", 100, 0, 100);
  final DiscreteParameter splitMode = new DiscreteParameter("Mode", 1, 1, 6);
  final CompoundParameter hue2 = new CompoundParameter("Hue 2", 0, 0, 360);
  final CompoundParameter saturation2 = new CompoundParameter("Sat 2", 100, 0, 100);
  final CompoundParameter brightness2 = new CompoundParameter("Bri 2", 100, 0, 100);
  
  public SplitColor(LX lx) {
    super(lx);
    addParameter(hue1);
    addParameter(saturation1);
    addParameter(brightness1);
    addParameter(splitMode);
    addParameter(hue2);
    addParameter(saturation2);
    addParameter(brightness2);
  }
  
  public void run(double deltaMs) {
    
    int mode= (int) splitMode.getValue();
    int pixCnt = 0;
    int parCnt = 0;
    
    if (mode == 1) {
      for (Rail rail : model.rails) {
        pixCnt = 0;
        for (LXPoint p : rail.points) {
          if (pixCnt < 16) {
          colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
          colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
          ++pixCnt;
        }
      }
      //par count
      parCnt = 0;
      for (Par par : model.pars) {
        for (LXPoint p : par.points) {
          System.out.println("parCnt % 2 >= 1: " + (parCnt % 2 >= 1));
          System.out.println("parCnt: " + parCnt);
          if (parCnt % 2 >= 1) {
            colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
            colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
        }
        ++parCnt;
      }
    } else if (mode == 2){
      for (Rail rail : model.rails) {
        pixCnt = 0;
        for (LXPoint p : rail.points) {
          if (pixCnt % 16 >= 8) {  
          colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
          colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
          ++pixCnt;
        }
      }
      //par count
      parCnt = 0;
      for (Par par : model.pars) {
        for (LXPoint p : par.points) {
          System.out.println("parCnt % 2 >= 1: " + (parCnt % 2 >= 1));
          System.out.println("parCnt: " + parCnt);
          if (parCnt % 2 >= 1) {
            colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
            colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
        }
        ++parCnt;
      }
    }  else if (mode == 3){
      for (Rail rail : model.rails) {
        pixCnt = 0;
        for (LXPoint p : rail.points) {
          if (pixCnt % 8 >= 4) { 
            colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
          colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
          ++pixCnt;
        }
      }
      //par count
      parCnt = 0;
      for (Par par : model.pars) {
        for (LXPoint p : par.points) {
          System.out.println("parCnt % 2 >= 1: " + (parCnt % 2 >= 1));
          System.out.println("parCnt: " + parCnt);
          if (parCnt % 2 >= 1) {
            colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
            colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
        }
        ++parCnt;
      }
    } else if (mode == 4){
      for (Rail rail : model.rails) {
        pixCnt = 0;
        for (LXPoint p : rail.points) {
          if (pixCnt % 4 >= 2) {
          colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
          colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
          ++pixCnt;
          }
        }
        //par count
        parCnt = 0;
        for (Par par : model.pars) {
          for (LXPoint p : par.points) {
            System.out.println("parCnt % 2 >= 1: " + (parCnt % 2 >= 1));
            System.out.println("parCnt: " + parCnt);
            if (parCnt % 2 >= 1) {
              colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
            } else {
              colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
            } 
          }
          ++parCnt;
        }
      } else if (mode == 5){
      for (Rail rail : model.rails) {
        pixCnt = 0;
        for (LXPoint p : rail.points) {
          if (pixCnt % 2 >= 1) {
          colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
          colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
          ++pixCnt;
        }
      }
      //par count
      parCnt = 0;
      for (Par par : model.pars) {
        for (LXPoint p : par.points) {
          if (parCnt % 2 >= 1) {
            colors[p.index] = LXColor.hsb( hue1.getValuef() , saturation1.getValuef(),brightness1.getValuef());
          } else {
            colors[p.index] = LXColor.hsb( hue2.getValuef() , saturation2.getValuef(),brightness2.getValuef());
          } 
        }
        ++parCnt;
      }
    }
  }
}
