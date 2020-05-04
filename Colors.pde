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

@LXCategory("Color")
public class TwoColorPaletteBlend extends EnvelopPattern {
  
  //global variables
  public double curStepTime = 0.0;
  public int numPix = model.points.length; 
  public float[] blend = new float[numPix];
  public float newInc = 0;
  
  //knobs and such
  public final CompoundParameter hue1 = new CompoundParameter("Hue 1", 1, 1. , 360.);
  public final CompoundParameter sat1 = new CompoundParameter("Sat 1", 100, 0. , 100.);
  public final CompoundParameter bri1 = new CompoundParameter("Bri 1", 100, 0. , 100.);
  public final DiscreteParameter increment = (DiscreteParameter)
    new DiscreteParameter("Size", 50, 1, 1000)
    .setExponent(2);
  public final CompoundParameter hue2 = new CompoundParameter("Hue 2", 1, 1. , 360.);
  public final CompoundParameter sat2 = new CompoundParameter("Sat 2", 100, 0. , 100.);
  public final CompoundParameter bri2 = new CompoundParameter("Bri 2", 100, 0. , 100.);
  public final BooleanParameter set = new BooleanParameter("Fixed",true);
  public final BooleanParameter direction = new BooleanParameter("Dir",true);
  public final CompoundParameter period = (CompoundParameter)
    new CompoundParameter("Period", 50, 20, 1000)
    .setExponent(3.0)
    .setDescription("Speed of the Movement");
  final LXModulator pos = startModulator(new SinLFO(0.9, 1.1, period));
  
  public TwoColorPaletteBlend(LX lx) {
    super(lx);
    addParameter(hue1);
    addParameter(sat1);
    addParameter(bri1);
    addParameter(increment);
    addParameter(hue2);
    addParameter(sat2);
    addParameter(bri2);
    addParameter(period);
    addParameter(set);
    addParameter(direction);
  }
  
  
  public void run(double deltaMs) {
    
    curStepTime = curStepTime +deltaMs; //adds time
    
    int numPixZ = numPix -1 ; // zero based number of pixels
    int cnt = 0; //count value
    int cntReset = 0; //Reset count value
    boolean blendModeUp = true; // if true increment, if false decrement
    boolean s = set.getValueb();
    boolean dir = direction.getValueb();
    float per = period.getValuef();
    float inc = increment.getValuef() /(numPix); //divide by number of pixel for to eliminate a seam
    int cycleReset = Math.round((numPix)/increment.getValuef()) ; //reset accum at set intervals to avoid quantitative error
    float accum = 0; //accumulator for blend values
    float accumReset = 0.5; //accumulator for blend values
    accum = 0.5; //set inital value of accumulator to ensure there are no seams
    
    
    if (s || inc != newInc) {
      for (LXPoint p :  model.points) {
        newInc = inc;
       
        //increments or decrements
        if (blendModeUp){
          if(cnt != 0){
            accum = accum + inc;
            blend[cnt] = min(1.0,accum); //prevent overflow
          } else {
            blend[cnt] = min(1.0,accum); //don't increment first number
          }  
        } else {   
          accum = accum - inc;
          blend[cnt] = max(0.0, accum); //prevent underflow
        }  
        
        ++cntReset;
        //evaluate whether cycle is complete
        if (cntReset >= cycleReset){
          accum = accumReset;
          cntReset = 0;
        }  
        
        //sets blend mode
        if (accum >= 1) {
          blendModeUp = false;
          blend[cnt] = 1;
        } else if (accum <= 0) {
          blendModeUp = true;
          blend[cnt] = 0;
        } 
        ++cnt;
        
        
        int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
        int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        
        colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]); 
      }
      //System.out.println("blend[0]: " + blend[0]);
      //System.out.println("blend[numPixZ]: " + blend[numPixZ]);
      //System.out.println("blend[768]: " + blend[768]);
    } else {
      
      //controls the period/speed
      if ( curStepTime >= per){ 
        curStepTime = 0;
        //controls the direction
        if (dir){
          for (LXPoint p :  model.points) {
            if (p.index != numPixZ) {
            blend[p.index] = blend[p.index+1];
            } else {
            blend[p.index] = blend[0];
            }
            int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
            int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        
            colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);  
            
          //System.out.println("blend[p.index]: " + blend[p.index]);
          //System.out.println("p.index: " + p.index);
          }
        } else {  
         for (LXPoint p :  model.points) {
            if (p.index != numPixZ) {
            blend[numPixZ-p.index] = blend[(numPixZ-p.index)-1];
            } else {
            blend[numPixZ-p.index] =blend[numPixZ];
            }
            int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
            int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        
            colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);  
          } 
        }
      }
    }  
  }
}

@LXCategory("Color")
public class ThreeColorPaletteBlend extends EnvelopPattern {
  
  //global variables
  public double curStepTime = 0.0;
  public int numPix = model.points.length; 
  public float[] blend = new float[numPix];
  public float newInc = 0;
  
  //knobs and such
  public final CompoundParameter hue1 = new CompoundParameter("Hue 1", 1, 1. , 360.);
  public final CompoundParameter sat1 = new CompoundParameter("Sat 1", 100, 0. , 100.);
  public final CompoundParameter bri1 = new CompoundParameter("Bri 1", 100, 0. , 100.);
  public final DiscreteParameter increment = (DiscreteParameter)
    new DiscreteParameter("Size", 50, 1, 1000)
    .setExponent(2);
  public final CompoundParameter hue2 = new CompoundParameter("Hue 2", 1, 1. , 360.);
  public final CompoundParameter sat2 = new CompoundParameter("Sat 2", 100, 0. , 100.);
  public final CompoundParameter bri2 = new CompoundParameter("Bri 2", 100, 0. , 100.);
  public final CompoundParameter hue3 = new CompoundParameter("Hue 3", 1, 1. , 360.);
  public final CompoundParameter sat3 = new CompoundParameter("Sat 3", 100, 0. , 100.);
  public final CompoundParameter bri3 = new CompoundParameter("Bri 3", 100, 0. , 100.);
  public final BooleanParameter set = new BooleanParameter("Fixed",true);
  public final BooleanParameter direction = new BooleanParameter("Dir",true);
  public final CompoundParameter period = (CompoundParameter)
    new CompoundParameter("Period", 50, 20, 1000)
    .setExponent(3.0)
    .setDescription("Speed of the Movement");
  final LXModulator pos = startModulator(new SinLFO(0.9, 1.1, period));
  
  public ThreeColorPaletteBlend(LX lx) {
    super(lx);
    addParameter(hue1);
    addParameter(sat1);
    addParameter(bri1);
    addParameter(increment);
    addParameter(hue2);
    addParameter(sat2);
    addParameter(bri2);
    addParameter(period);
    addParameter(hue3);
    addParameter(sat3);
    addParameter(bri3);
    addParameter(set);
    addParameter(direction);
  }
  
  
  public void run(double deltaMs) {
    
    curStepTime = curStepTime +deltaMs; //adds time
    
    int numPixZ = numPix -1 ; // zero based number of pixels
    int cnt = 0; //count value
    int cntReset = 0; //Reset count value
    boolean blendModeUp = true; // if true increment, if false decrement
    boolean s = set.getValueb();
    boolean dir = direction.getValueb();
    float per = period.getValuef();
    float inc = increment.getValuef() /(numPix); //divide by number of pixel for to eliminate a seam
    int cycleReset = Math.round((numPix)/increment.getValuef()) ; //reset accum at set intervals to avoid quantitative error
    int cycleCnt = 0; //represents number of cycles
    float accum = 0; //accumulator for blend values
    float accumReset = 0.5; //accumulator for blend values
    accum = 0.5; //set inital value of accumulator to ensure there are no seams
    
    
    if (s || inc != newInc) {
      for (LXPoint p :  model.points) {
        newInc = inc;
       
        //increments or decrements
        if (blendModeUp){
          if(cnt != 0){
            accum = accum + inc;
            blend[cnt] = min(1.0,accum); //prevent overflow
          } else {
            blend[cnt] = min(1.0,accum); //don't increment first number
          }  
        } else {   
          accum = accum - inc;
          blend[cnt] = max(0.0, accum); //prevent underflow
        }  
        
        
        //evaluate whether cycle is complete
        if (cntReset >= cycleReset){
          accum = accumReset;
          cntReset = 0;
        }  
        
        //sets blend mode
        if (accum >= 1) {
          blendModeUp = false;
          blend[cnt] = 1;
          ++cycleCnt;
          // System.out.println("Going Down: " +cycleCnt);
        } else if (accum <= 0) {
          blendModeUp = true;
          blend[cnt] = 0;
          ++cycleCnt;
          //System.out.println("Going Up: " +cycleCnt);
        } 
        ++cnt;
        
        
        int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
        int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        int c3 = LX.hsb(hue3.getValuef(), sat3.getValuef(),bri3.getValuef());
        
        if (cycleCnt == 0){
          colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);
        } else if (cycleCnt == 1){
          colors[p.index] = LXColor.lerp(c3, c2, blend[p.index]);  
        } else if (cycleCnt == 2){
          colors[p.index] = LXColor.lerp(c3, c1, blend[p.index]); 
        } else if (cycleCnt == 3){
          colors[p.index] = LXColor.lerp(c2, c1, blend[p.index]); 
        } else if (cycleCnt == 4){
          colors[p.index] = LXColor.lerp(c2, c1, blend[p.index]); 
        } else if (cycleCnt == 5){
          colors[p.index] = LXColor.lerp(c2, c3, blend[p.index]); 
        }  else {
          colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);
          cycleCnt = 0;
        }  
        ++cntReset;
      }
      cycleCnt = 0;
     // System.out.println("blend[0]: " + blend[0]);
     // System.out.println("blend[numPixZ]: " + blend[numPixZ]);
      //System.out.println("blend[768]: " + blend[768]);
    } else {
      
      //controls the period/speed
      if ( curStepTime >= per){ 
        curStepTime = 0;
        //controls the direction
        if (dir){
          for (LXPoint p :  model.points) {
            if (p.index != numPixZ) {
            blend[p.index] = blend[p.index+1];
            } else {
            blend[p.index] = blend[0];
            }
            int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
            int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        
            colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);  
            
          //System.out.println("blend[p.index]: " + blend[p.index]);
          //System.out.println("p.index: " + p.index);
          }
        } else {  
         for (LXPoint p :  model.points) {
            if (p.index != numPixZ) {
            blend[numPixZ-p.index] = blend[(numPixZ-p.index)-1];
            } else {
            blend[numPixZ-p.index] =blend[numPixZ];
            }
            int c1 = LX.hsb(hue1.getValuef(), sat1.getValuef(),bri1.getValuef());
            int c2 = LX.hsb(hue2.getValuef(), sat2.getValuef(),bri2.getValuef());
        
            colors[p.index] = LXColor.lerp(c1, c2, blend[p.index]);  
          } 
        }
      }
    }  
  }
} 

@LXCategory("Color")
public class LSDee extends EnvelopPattern {
  
  public final BoundedParameter scale = new BoundedParameter("Scale", 10, 5, 40);
  public final BoundedParameter speed = new BoundedParameter("Speed", 4, 1, 6);
  public final BoundedParameter range = new BoundedParameter("Range", 1, .7, 2);
  
  public LSDee(LX lx) {
    super(lx);
    addParameter(scale);
    addParameter(speed);
    addParameter(range);
  }
  
  final float[] hsb = new float[3];

  private float accum = 0;
  private int equalCount = 0;
  private float sign = 1;
  
  @Override
  public void run(double deltaMs) {
    float newAccum = (float) (accum + sign * deltaMs * speed.getValuef() / 4000.);
    if (newAccum == accum) {
      if (++equalCount >= 5) {
        equalCount = 0;
        sign = -sign;
        newAccum = accum + sign*.01;
      }
    }
    accum = newAccum;
    float sf = scale.getValuef() / 1000.;
    float rf = range.getValuef();
    float amount = 1;
    for (LXPoint p :  model.points) {
      LXColor.RGBtoHSB(colors[p.index], hsb);
      float h = rf * noise(sf*p.x, sf*p.y, sf*p.z + accum);
      int c2 = LX.hsb(h * 360, 100,100);
      //combine two colors
      if (amount < 1) {
        colors[p.index] = LXColor.lerp(colors[p.index], c2, amount);
      } else {
        colors[p.index] = c2;
      }
       amount = 0.18;
    }
   
  }
}

@LXCategory("Color")
public class Plasma extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;
  float red, green, blue;
  float shade;
  float movement = 0.1;
  
  PlasmaGenerator plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 0.8, 0.1, 1)
    .setDescription("Size");
  
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      2, 
      20, 
      45000     
    );
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.xMax*-1, 
      model.yMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  public Plasma(LX lx) {
    super(lx);
    
    addParameter(size);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    
    plasmaGenerator =  new PlasmaGenerator(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      
      //GET A UNIQUE SHADE FOR THIS PIXEL

      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
   
        //separate out a red, green and blue shade from the plasma wave 
        red = map(sinTable.sin(shade*PI), -1, 1, 0, brightness);
        green =  map(sinTable.sin(shade*PI+(2*cosTable.cos(movement*490))), -1, 1, 0, brightness); //*cos(movement*490) makes the colors morph over the top of each other 
        blue = map(sinTable.sin(shade*PI+(4*sinTable.sin(movement*300))), -1, 1, 0, brightness);
  
        //ready to populate this color!
        setColor(rail, LXColor.rgb((int)red,(int)green, (int)blue));
      }
    }
    
  movement =+ ((float)RateLfo.getValue() / 1000); //advance the animation through time. 
   
  UpdateCirclePosition();
    
  }
  
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }


}

@LXCategory("Color")
public class PlasmaY extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade;
  float movement = 0.1;
  
  //variable calling the helper class
  PlasmaGenerator plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 0.8, 0.1, 1)
    .setDescription("Size");
  
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      2, 
      20, 
      45000     
    );
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      40000     
    );
    
      public final SinLFO CircleMoveZ = new SinLFO(
      model.xMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  //constructor
  public PlasmaY(LX lx) {
    super(lx);
    
    addParameter(size);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveZ);
    startModulator(RateLfo);
    
    plasmaGenerator =  new PlasmaGenerator(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    //System.out.println("frame rate: " + Math.round(1000/deltaMs));
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL

      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
   
        //separate out a red, green and blue shade from the plasma wave 
        red = map(sinTable.sin(shade*PI), -1, 1, 0, brightness);
        green =  map(sinTable.sin(shade*PI+(2*cosTable.cos(movement*490))), -1, 1, 0, brightness); //*cos(movement*490) makes the colors morph over the top of each other 
        blue = map(sinTable.sin(shade*PI+(4*sinTable.sin(movement*300))), -1, 1, 0, brightness);
  
        //ready to populate this color!
        colors[p.index]= LXColor.rgba( (int) red,(int)green, (int)blue,254);
        //setColor(p, LXColor.rgb((int)red,(int)green, (int)blue));
      }
    }
    
   movement =+ ((float)RateLfo.getValue() / 1000); //advance the animation through time. 
   
  UpdateCirclePosition();
    
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveZ.getValue(),
      0
      );
  }


}



// This is a helper class to generate plasma. 

public static class PlasmaGenerator {
      
    //NOTE: Geometry is FULL scale for this model. Dont use normalized values. 
      
      float xmax, ymax, zmax;
      LXVector circle; 
      
      //sets up table of 255 points that represent a sin wave in radians
      static final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
      
      //methods
      float SinVertical(LXVector p, float size, float movement)
      {
        return sinTable.sin(   ( p.x / xmax / size) + (movement / 100 ));
      }
      
      float SinRotating(LXVector p, float size, float movement)
      {
        
        return sinTable.sin( ( ( p.y / ymax / size) * sin( movement /66 )) + (p.z / zmax / size) * (cos(movement / 100))  ) ;
      }
       
      float SinCircle(LXVector p, float size, float movement)
      {
        float distance =  p.dist(circle);
        return sinTable.sin( (( distance + movement + (p.z/zmax) ) / xmax / size) * 2 ); 
      }
    
      float GetThreeTierPlasma(LXPoint p, float size, float movement)
      {
        LXVector pointAsVector = new LXVector(p);
        return  SinVertical(  pointAsVector, size, movement) +
        SinRotating(  pointAsVector, size, movement) +
        SinCircle( pointAsVector, size, movement);
      }
      
      //contructor
      public PlasmaGenerator(float _xmax, float _ymax, float _zmax)
      {
        xmax = _xmax;
        ymax = _ymax;
        zmax = _zmax;
        circle = new LXVector(0,0,0);
      }
      
      //main method
      void UpdateCirclePosition(float x, float y, float z)
      {
        circle.x = x;
        circle.y = y;
        circle.z = z;
      }
    
}//end plasma generator

@LXCategory("Color")
public class Plasma3Color extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =(2*PI)/3;
  float slice3 =(4*PI)/3;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 1.0, 0.1, 2.0)
    .setDescription("Size");
    
    public final CompoundParameter r1 = new CompoundParameter("R1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g1 = new CompoundParameter("G1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b1 = new CompoundParameter("B1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter r2 = new CompoundParameter("R2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g2 = new CompoundParameter("G2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b2 = new CompoundParameter("B2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter r3 = new CompoundParameter("R3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g3 = new CompoundParameter("G3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b3 = new CompoundParameter("B3 Bri", 255.0, 0.0, 255.0);
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
   // public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      2, //start
      20, //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public Plasma3Color(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
        shade1 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice1 );
        shade2 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice2 );
        shade3 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice3 );
        
        //separate out a red, green and blue shade from the plasma wave 
        if (shade1 > 0.5) {
          red = r1.getValuef();
          green = g1.getValuef();
          blue = b1.getValuef();
        } else if (shade2 > 0.5){
          red = r2.getValuef();
          green = g2.getValuef();
          blue = b2.getValuef();
        }  else if(shade3 > 0.5) {
          red = r3.getValuef();
          green = g3.getValuef();
          blue = b3.getValuef();
        }
        colors[p.index]= LXColor.rgba( (int) red,(int)green, (int)blue,254);
      }
    }
    
   movement =+ ((float)RateLfo.getValue() / 1000); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }
}

@LXCategory("Color")
public class Plasma3ColorHSB extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =(2*PI)/3;
  float slice3 =(4*PI)/3;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 1.0, 0.1, 2.0)
    .setDescription("Size");
    
    public final CompoundParameter r1 = new CompoundParameter("Hue1", 0.0, 0.0, 360.0);
    public final CompoundParameter g1 = new CompoundParameter("Sat1", 100.0, 0.0, 100.0);
    public final CompoundParameter b1 = new CompoundParameter("Bri1", 100.0, 0.0, 100.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter r2 = new CompoundParameter("Hue2", 0.0, 0.0, 360.0);
    public final CompoundParameter g2 = new CompoundParameter("Sat2", 100.0, 0.0, 100.0);
    public final CompoundParameter b2 = new CompoundParameter("Bri2", 100.0, 0.0, 100.0);
    public final CompoundParameter r3 = new CompoundParameter("Hue3", 0.0, 0.0, 360.0);
    public final CompoundParameter g3 = new CompoundParameter("Sat3", 100.0, 0.0, 100.0);
    public final CompoundParameter b3 = new CompoundParameter("Bri3", 100.0, 0.0, 100.0);
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
   // public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      2, //start
      20, //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public Plasma3ColorHSB(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
        shade1 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice1 );
        shade2 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice2 );
        shade3 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice3 );
        
        //separate out a red, green and blue shade from the plasma wave 
        if (shade1 > 0.5) {
          red = r1.getValuef();
          green = g1.getValuef();
          blue = b1.getValuef();
        } else if (shade2 > 0.5){
          red = r2.getValuef();
          green = g2.getValuef();
          blue = b2.getValuef();
        }  else if(shade3 > 0.5) {
          red = r3.getValuef();
          green = g3.getValuef();
          blue = b3.getValuef();
        }
        colors[p.index]= LXColor.hsb( (int) red,(int)green, (int)blue);
      }
    }
    
   movement =+ ((float)RateLfo.getValue() / 1000); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }
}

@LXCategory("Color")
public class Plasma3ColorHSBmove extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =(2*PI)/3;
  float slice3 =(4*PI)/3;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size =
    new CompoundParameter("Size", 1.0, 0.1, 2.0)
    .setDescription("Size");
          
    public final CompoundParameter r1 = new CompoundParameter("Hue1", 0.0, 0.0, 360.0);
    public final CompoundParameter g1 = new CompoundParameter("Sat1", 100.0, 0.0, 100.0);
    public final CompoundParameter b1 = new CompoundParameter("Bri1", 100.0, 0.0, 100.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter r2 = new CompoundParameter("Hue2", 0.0, 0.0, 360.0);
    public final CompoundParameter g2 = new CompoundParameter("Sat2", 100.0, 0.0, 100.0);
    public final CompoundParameter b2 = new CompoundParameter("Bri2", 100.0, 0.0, 100.0);
    public final CompoundParameter r3 = new CompoundParameter("Hue3", 0.0, 0.0, 360.0);
    public final CompoundParameter g3 = new CompoundParameter("Sat3", 100.0, 0.0, 100.0);
    public final CompoundParameter b3 = new CompoundParameter("Bri3", 100.0, 0.0, 100.0);
    //public final CompoundParameter slice1 = new CompoundParameter("Slice1", 0.0, 0, PI);
    //public final CompoundParameter slice2 = new CompoundParameter("Slice2", (2*PI)/3, 0, PI);
    //public final CompoundParameter slice3 = new CompoundParameter("Slice3", (4*PI)/3, 0, PI);
    
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
    //public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final CompoundParameter move = new CompoundParameter("Move", 2.0, 2.0, 20.0);
    public final SinLFO RateLfo = new SinLFO(
      2, //start
      20, //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public Plasma3ColorHSBmove(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    addParameter(move);
    //addParameter(slice1);
    //addParameter(slice2);
    //addParameter(slice3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade = plasmaGenerator.GetThreeTierPlasma(p, _size, movement );
        shade1 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice1 );
        shade2 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice2 );
        shade3 = plasmaGenerator.MineRotatingDiagonSlice(pointAsVector, _size, movement, slice3 );
        
        //separate out a red, green and blue shade from the plasma wave 
        if (shade1 > 0.5) {
          red = r1.getValuef();
          green = g1.getValuef();
          blue = b1.getValuef();
        } else if (shade2 > 0.5){
          red = r2.getValuef();
          green = g2.getValuef();
          blue = b2.getValuef();
        }  else if(shade3 > 0.5) {
          red = r3.getValuef();
          green = g3.getValuef();
          blue = b3.getValuef();
        }
        colors[p.index]= LXColor.hsb( (int) red,(int)green, (int)blue);
      }
    }
    
   movement =+ ((float)move.getValue() / 1000); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }
}


@LXCategory("Color")
public class PlasmaPlay extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3, shade4, shade5, shade6;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =250;
  float slice3 =500;
  float slice4 = 750;
  float slice5 = 333;
  float slice6 = 667;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size = new CompoundParameter("Size", 1.0, 0.1, 2.0)
    .setDescription("Size");
    
    public final CompoundParameter r1 = new CompoundParameter("R1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g1 = new CompoundParameter("G1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b1 = new CompoundParameter("B1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter depth = new CompoundParameter("depth", 1000.0, 1000.0, 32000.0);
    public final CompoundParameter r2 = new CompoundParameter("R2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g2 = new CompoundParameter("G2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b2 = new CompoundParameter("B2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter r3 = new CompoundParameter("R3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g3 = new CompoundParameter("G3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b3 = new CompoundParameter("B3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter shapeWindow = new CompoundParameter("shapeWindow", 1000.0, 10.0, 1000.0);
    public final CompoundParameter offset1 = new CompoundParameter("Off1", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset2 = new CompoundParameter("Off2", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset3 = new CompoundParameter("Off3", 0.0, 0.0, 1000.0);
    public final CompoundParameter diagon = new CompoundParameter("diagon", 1.0, -1.0, 1.0);
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
   // public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      1, //start
      new FunctionalParameter() {
    public double getValue() {
      return depth.getValue();
      }
    }  , //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public PlasmaPlay(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    addParameter(shapeWindow);
    addParameter(depth);
    addParameter(diagon);
    addParameter(offset1);
    addParameter(offset2);
    addParameter(offset3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade1 = plasmaGenerator.SinTrim(pointAsVector, _size, movement, offset1.getValuef(), shapeWindow.getValuef() );
        shade2 = plasmaGenerator.SinTrim(pointAsVector, _size, movement, offset2.getValuef(), shapeWindow.getValuef() );
        shade3 = plasmaGenerator.SinTrim(pointAsVector, _size, movement, offset3.getValuef(), shapeWindow.getValuef() );
        //separate out a red, green and blue shade from the plasma wave 
        red = min(255,shade1*(r1.getValuef()/255) + shade2*(r2.getValuef()/255) + shade3*(r3.getValuef()/255));
        green = min(255,shade1 *(g1.getValuef()/255) + shade2*(g2.getValuef()/255) + shade3*(g3.getValuef()/255));
        blue = min(255,shade1 *(b1.getValuef()/255) + shade2*(b2.getValuef()/255) + shade3*(b3.getValuef()/255));
        colors[p.index]= LXColor.rgba( (int) red,(int)green, (int)blue,254);
      }
      //++cntRail;
    }
    
   movement =+ (float)RateLfo.getValue(); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }


}

@LXCategory("Color")
public class PlasmaRadius extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3, shade4, shade5, shade6;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =250;
  float slice3 =500;
  float slice4 = 750;
  float slice5 = 333;
  float slice6 = 667;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size = new CompoundParameter("Size", 1.0, 0.1, 2.0)
    .setDescription("Size");
    
    public final CompoundParameter r1 = new CompoundParameter("R1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g1 = new CompoundParameter("G1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b1 = new CompoundParameter("B1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter depth = new CompoundParameter("depth", 1000.0, 1000.0, 32000.0);
    public final CompoundParameter r2 = new CompoundParameter("R2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g2 = new CompoundParameter("G2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b2 = new CompoundParameter("B2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter r3 = new CompoundParameter("R3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g3 = new CompoundParameter("G3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b3 = new CompoundParameter("B3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter shapeWindow = new CompoundParameter("shapeWindow", 1000.0, 10.0, 1000.0);
    public final CompoundParameter offset1 = new CompoundParameter("Off1", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset2 = new CompoundParameter("Off2", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset3 = new CompoundParameter("Off3", 0.0, 0.0, 1000.0);
    public final CompoundParameter diagon = new CompoundParameter("diagon", 1.0, -1.0, 1.0);
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
   // public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      1, //start
      new FunctionalParameter() {
    public double getValue() {
      return depth.getValue();
      }
    }  , //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public PlasmaRadius(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    addParameter(shapeWindow);
    addParameter(depth);
    addParameter(diagon);
    addParameter(offset1);
    addParameter(offset2);
    addParameter(offset3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade1 = plasmaGenerator.SinRadius(pointAsVector, _size, movement, offset1.getValuef(), shapeWindow.getValuef() );
        shade2 = plasmaGenerator.SinRadius(pointAsVector, _size, movement, offset2.getValuef(), shapeWindow.getValuef() );
        shade3 = plasmaGenerator.SinRadius(pointAsVector, _size, movement, offset3.getValuef(), shapeWindow.getValuef() );
        //separate out a red, green and blue shade from the plasma wave 
        red = min(255,shade1*(r1.getValuef()/255) + shade2*(r2.getValuef()/255) + shade3*(r3.getValuef()/255));
        green = min(255,shade1 *(g1.getValuef()/255) + shade2*(g2.getValuef()/255) + shade3*(g3.getValuef()/255));
        blue = min(255,shade1 *(b1.getValuef()/255) + shade2*(b2.getValuef()/255) + shade3*(b3.getValuef()/255));
        colors[p.index]= LXColor.rgba( (int) red,(int)green, (int)blue,254);
      }
      //++cntRail;
    }
    
   movement =+ (float)RateLfo.getValue(); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }
}

@LXCategory("Color")
public class ColorCylinders extends EnvelopPattern {
  
  public String getAuthor() {
    return "Fin McCarthy";
  }
  
  //by Fin McCarthy
  // finchronicity@gmail.com
  
  //variables
  int brightness = 255;//set brightness to max
  float red, green, blue;
  float shade,shade1, shade2, shade3, shade4, shade5, shade6;
  float movement = 0.1;
  float slice1 =0;
  float slice2 =250;
  float slice3 =500;
  float slice4 = 750;
  float slice5 = 333;
  float slice6 = 667;
  
  //variable calling the helper class
  PlasmaGeneratorY plasmaGenerator;
  
  long framecount = 0;
    
    //adjust the size of the plasma
    public final CompoundParameter size = new CompoundParameter("Size", 150.0, 50.0, 750.0)
    .setDescription("Size");
    
    public final CompoundParameter r1 = new CompoundParameter("R1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g1 = new CompoundParameter("G1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b1 = new CompoundParameter("B1 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter rate = new CompoundParameter("Rate", 22000.0, 1000.0, 60000.0);
    public final CompoundParameter depth = new CompoundParameter("depth", 1000.0, 1000.0, 32000.0);
    public final CompoundParameter r2 = new CompoundParameter("R2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g2 = new CompoundParameter("G2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b2 = new CompoundParameter("B2 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter r3 = new CompoundParameter("R3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter g3 = new CompoundParameter("G3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter b3 = new CompoundParameter("B3 Bri", 255.0, 0.0, 255.0);
    public final CompoundParameter shapeWindow = new CompoundParameter("shapeWindow", 1000.0, 10.0, 1000.0);
    public final CompoundParameter offset1 = new CompoundParameter("Off1", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset2 = new CompoundParameter("Off2", 0.0, 0.0, 1000.0);
    public final CompoundParameter offset3 = new CompoundParameter("Off3", 0.0, 0.0, 1000.0);
    public final CompoundParameter diagon = new CompoundParameter("diagon", 1.0, -1.0, 1.0);
    //public final CompoundParameter min = new CompoundParameter("Min", 2.0, 2.0, 20.0);
   // public final CompoundParameter max = new CompoundParameter("Max", 20.0, 2.0, 20.0);*/
    //variable speed of the plasma. 
    public final SinLFO RateLfo = new SinLFO(
      1, //start
      new FunctionalParameter() {
    public double getValue() {
      return depth.getValue();
      }
    }  , //stop
       new FunctionalParameter() {
    public double getValue() {
      return rate.getValue();
    }
  });
  
    //moves the circle object around in space
    public final SinLFO CircleMoveX = new SinLFO(
      model.xMax*-1, 
      model.xMax*2, 
      22000//40000     
    );
    
      public final SinLFO CircleMoveY = new SinLFO(
      model.zMax*-1, 
      model.zMax*2, 
      22000 
    );

  private final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
  private final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
  
  
  //constructor
  public ColorCylinders(LX lx) {
    super(lx);
    
    addParameter(size);
    addParameter(r1);
    addParameter(g1);
    addParameter(b1);
    
    startModulator(CircleMoveX);
    startModulator(CircleMoveY);
    startModulator(RateLfo);
    addParameter("rate", this.rate);
    addParameter(r2);
    addParameter(g2);
    addParameter(b2);
    addParameter(r3);
    addParameter(g3);
    addParameter(b3);
    addParameter(shapeWindow);
    addParameter(depth);
    addParameter(diagon);
    addParameter(offset1);
    addParameter(offset2);
    addParameter(offset3);
    
    
    plasmaGenerator =  new PlasmaGeneratorY(model.xMax, model.yMax, model.zMax);
    UpdateCirclePosition();
    
    //PrintModelGeometory();
}
    
  //main method
  public void run(double deltaMs) {
    for (Rail rail : venue.rails) {
      //GET A UNIQUE SHADE FOR THIS PIXEL
      
      //convert this point to vector so we can use the dist method in the plasma generator
      float _size = size.getValuef(); 
      for (LXPoint p : rail.points) {
        //combine the individual plasma patterns 
        LXVector pointAsVector = new LXVector(p);
        shade1 = plasmaGenerator.CylinderXY(pointAsVector, _size, offset1.getValuef(), offset2.getValuef() );
        //shade2 = plasmaGenerator.CylinderXY(pointAsVector, _size, movement, offset2.getValuef(), shapeWindow.getValuef() );
        //shade3 = plasmaGenerator.CylinderXY(pointAsVector, _size, movement, offset3.getValuef(), shapeWindow.getValuef() );
        //separate out a red, green and blue shade from the plasma wave 
        red = min(255,shade1*(r1.getValuef()/255)); //+ shade2*(r2.getValuef()/255) + shade3*(r3.getValuef()/255));
        green = min(255,shade1 *(g1.getValuef()/255));// + shade2*(g2.getValuef()/255) + shade3*(g3.getValuef()/255));
        blue = min(255,shade1 *(b1.getValuef()/255));// + shade2*(b2.getValuef()/255) + shade3*(b3.getValuef()/255));
        colors[p.index]= LXColor.rgba( (int) red,(int)green, (int)blue,254);
      }
      //++cntRail;
    }
    
   movement =+ (float)RateLfo.getValue(); //advance the animation through time. =+ notation means it takes the positive value so this will range from 0.002 to 0.020 over 45s 
   UpdateCirclePosition();
  }
  
  //method to update circle position
  void UpdateCirclePosition()
  {
      plasmaGenerator.UpdateCirclePosition(
      (float)CircleMoveX.getValue(), 
      (float)CircleMoveY.getValue(),
      0
      );
  }
}
// This is a helper class to generate plasma. 

public static class PlasmaGeneratorY {
      
    //NOTE: Geometry is FULL scale for this model. Dont use normalized values. 
      
      float xmax, ymax, zmax;
      float rmax, emax, amax;
      LXVector circle; 
      //sets up table of 255 points that represent a sin wave in radians
      static final LXUtils.LookupTable.Sin sinTable = new LXUtils.LookupTable.Sin(255);
      static final LXUtils.LookupTable.Cos cosTable = new LXUtils.LookupTable.Cos(255);
      
      //methods
      float SinVertical(LXVector p, float size, float movement)
      {
        return sinTable.sin(   ( p.x / xmax / size) + (movement / 100 ));
      }
      
      float SinHorizontal(LXVector p, float size, float movement)
      {
        return sin(   ( map(p.y / (ymax),0,1,-1,1)/ size) + (movement / 100 ));
      }
      
      float MineRotating(LXVector p, float size, float movement)
      {
       
        return sinTable.sin( PI*((p.y / ymax / size) )+((map(movement,.002,.020,-12*PI, 12*PI))));//* (sin(map(movement,.002,.020,0,2*PI)  )))) ;
      }
       float MineRotatingPI(LXVector p, float size, float movement)
      {
       
        return sinTable.sin(PI+(PI*((p.y / ymax / size) )+((map(movement,.002,.020,-12*PI, 12*PI)))));//* (sin(map(movement,.002,.020,0,2*PI)  )))) ;
      }
      float MineRotatingDiagon(LXVector p, float size, float movement)
      {
       
        return sinTable.sin(map(p.x/xmax/size,-1,1,-PI,PI)+(PI*((p.y / ymax / size) )+((map(movement,.002,.020,-12*PI, 12*PI)))));//* (sin(map(movement,.002,.020,0,2*PI)  )))) ;
      }
       float MineRotatingDiagonSlice(LXVector p, float size, float movement,float offset)
      {
       
        return sinTable.sin(offset+(map(p.x/xmax/size,-1,1,-PI,PI)+(PI*((p.y / ymax / size) )+((map(movement,.002,.020,-12*PI, 12*PI))))));//* (sin(map(movement,.002,.020,0,2*PI)  )))) ;
      }
      
      float MineRotatingDiagonSliceSin(LXVector p, float size, float movement,float offset)
      {
        
        float pStretched = map(p.x / xmax,-1,1,0, xmax * 2); // normalized coordinates
        float oneCycle = xmax * 2  * size; //size of a single cycle
        
        
          if((pStretched > oneCycle) || (pStretched > offset)){
            oneCycle = 0;
            //System.out.println("pStretched: " + pStretched + " oneCycle: " +oneCycle+ "va " +map(oneCycle/size,0, xmax * 2,-1,1));
          } else {
            oneCycle = pStretched + offset;
          }
          
        //System.out.println("pStretched: " + pStretched + " oneCycle: " +oneCycle);
        
        float theCycle = map(oneCycle/size,0, xmax * 2,-PI,PI);
        return cosTable.cos(theCycle) ;//* (sin(map(movement,.002,.020,0,2*PI)  )))) ;
      }
      
      float SinTrim(LXVector p, float size, float movement,float offset,float shapeWindow)
      {
        float posVal = map(p.x/xmax/size,-1,1,1, 1000);
        //float shapeWindow = 750;
        float finalVal = 0;
        float shape = 0;
        float animStart = (posVal + movement +offset) % 1000; //start of the animation
        
        if ( animStart <= shapeWindow){
          shape = cosTable.cos(map(shapeWindow - animStart, 0, shapeWindow, -PI, PI));
          finalVal = map(shape,-1,1,0,255);
          
        } else {
          finalVal= 0;
        }
        
        return finalVal ;
      }
      
      float SinTrimY(LXVector p, float size, float movement,float offset,float shapeWindow, float diagon)
      {
        float xDist = p.x/xmax/size;
        float yDist = p.y/ymax/size;
        float posVal = map(yDist,0,1,1, 1000);
        float xVal = map(xDist,-1,1,1,1000);
        float finalVal = 0;
        float shape = 0;
        float diagonAdjust = xVal * diagon;
        float animStart = (posVal + movement +offset + diagonAdjust) % 1000; //start of the animation
        
        if ( animStart <= shapeWindow){
          shape = cosTable.cos(map ((shapeWindow - animStart), 0, shapeWindow, -PI, PI));
          finalVal = map(shape,-1,1,0,255);
          
        } else {
          finalVal= 0;
        }
        
        return finalVal ;
      }
      
      float SinRadius(LXVector p, float size, float movement,float offset,float shapeWindow)
      {
        LXPoint lxp = p.point;
        float posVal = map(lxp.rn/size,0,1,1, 1000);
        //float shapeWindow = 750;
        float finalVal = 0;
        float shape = 0;
        float animStart = (posVal + movement +offset) % 1000; //start of the animation
        
        if ( animStart <= shapeWindow){
          shape = cosTable.cos(map(shapeWindow - animStart, 0, shapeWindow, -PI, PI));
          finalVal = map(shape,-1,1,0,255);
          
        } else {
          finalVal= 0;
        }
        
        return finalVal ;
      }
      
      float SinRadiusXY(LXVector p, float size, float movement,float offset,float shapeWindow)
      {
        LXPoint lxp = p.point;
        float posVal = map(lxp.rxy/xmax/size,0,1,1, 1000);
        float finalVal = 0;
        float shape = 0;
        float animStart = (posVal + offset) % 1000;//(posVal + movement +offset) % 1000; //start of the animation
        
        if ( animStart <= shapeWindow){
          shape = cosTable.cos(map(shapeWindow - animStart, 0, shapeWindow, -PI, PI));
          finalVal = map(shape,-1,1,0,255);
          
        } else {
          finalVal= 0;
        }
        
        return finalVal ;
      }
      
      float CylinderXY(LXVector p, float size, float xOff,float zOff)
      {
        LXPoint lxp = p.point;
        float finalVal = 0;
        float xCoord,zCoord= 0;
        xCoord = xOff + (size * sin (lxp.theta)); 
        zCoord = zOff + (size * cos (lxp.theta)); 
        
        if ( Math.abs(lxp.x) < Math.abs(xCoord) && Math.abs(lxp.z) < Math.abs(zCoord)) { 
          //shape = cosTable.cos(map(shapeWindow - animStart, 0, shapeWindow, -PI, PI));
          //System.out.println("lxp.x: " + lxp.x + "xCoord: " + xCoord + "lxp.z: " + lxp.z + "zCoord: " + zCoord );
          finalVal = 255; //map(shape,-1,1,0,255);
          
        } else {
          finalVal= 0;
        }
        
        return finalVal ;
      }
      
      float SinEllipsoid(LXVector p, float size, float movement,float offset, boolean animateSwitch)//oval shaped sphere
      {
        //this is hacky AF
        LXPoint lxp = p.point;
        float finalVal = 0;
        float radius1 = 250;//offset;
        float radius2 = 350;//shapeWindow;
        float shape = 0;
        //float radius3 = 300;
        //float YOffset = 10;
        float animate = 0; // determine whether animation will be controlled by offset or movement
        
        if (animateSwitch) {
          animate = movement;
        } else {
          animate = offset;
        }  
        
        float ring1Min = map(animate,1,1000, 6-size,36-size);
        float ring1Max = map(animate,1,1000, 6+size,36+size);
        float ring2Min = map(animate,1,1000,15-size,26-size);
        float ring2Max = map(animate,1,1000,15+size,26+size);
        float ring3Min = map(animate,1,1000,36-size, 6-size);
        float ring3Max = map(animate,1,1000,36+size, 6+size);
        
        //if statement to decide where ring values will be
        if ( (lxp.r < radius1) && (p.y > ring1Min) && (p.y <= ring1Max)) {
          shape = sinTable.sin(map(p.y, ring1Min, ring1Max, -PI/2, (3*PI/2)));
          finalVal = map(shape,-1,1,0,255);
        } else if ( (lxp.r > radius1) && (lxp.r < radius2) && (p.y > ring2Min) && (p.y <= ring2Max)){
          shape = sinTable.sin(map(p.y, ring2Min, ring2Max, -PI/2, (3*PI/2)));
          finalVal = map(shape,-1,1,0,255);
        } else if ( (lxp.r > radius2) && (p.y >= ring3Min) && (p.y <= ring3Max)){
          shape = sinTable.sin(map(p.y, ring3Min, ring3Max, -PI/2, (3*PI/2)));
          finalVal = map(shape,-1,1,0,255);
        } else {
          finalVal = 0;
        }  
        
        //this code is pretty dope, right?  
        return finalVal ;
      }
       float SinRotating(LXVector p, float size, float movement)
      {
        
        return sinTable.sin( ( ( p.z / zmax / size) * sin( movement /66 )) + (p.y / ymax / size) * (cos(movement / 100))  ) ;
      } 
      float SinCircle(LXVector p, float size, float movement)
      {
        float distance =  p.dist(circle);
        return sinTable.sin( (( distance + movement + (p.y/ymax) ) / xmax / size) * 2 ); 
      }
    
      float GetThreeTierPlasma(LXPoint p, float size, float movement)
      {
        LXVector pointAsVector = new LXVector(p);
        return  SinVertical(  pointAsVector, size, movement) +
        SinRotating(  pointAsVector, size, movement) +
        SinCircle( pointAsVector, size, movement);
      }
      
      //contructor
      public PlasmaGeneratorY(float _xmax, float _ymax, float _zmax)
      {
        xmax = _xmax;
        ymax = _ymax;
        zmax = _zmax;
        circle = new LXVector(0,0,0);
      }
      
      //main method
      void UpdateCirclePosition(float x, float y, float z)
      {
        circle.x = x;
        circle.y = y;
        circle.z = z;
      }
    
}//end plasma generator

@LXCategory("Color")
public class ColorSwirl extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  private float basis = 0;
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, 0, 2);
      
  public final CompoundParameter slope = 
    new CompoundParameter("Slope", 1, .2, 3);    
    
  public final DiscreteParameter amount =
    new DiscreteParameter("Amount", 3, 1, 5)
    .setDescription("Amount of swirling around the center");    
  
  public ColorSwirl(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("slope", this.slope);
    addParameter("amount", this.amount);
  }
  
  public void run(double deltaMs) {
    this.basis = (float) (this.basis + .001 * speed.getValuef() * deltaMs) % TWO_PI;
    float slope = this.slope.getValuef();
    float sat = palette.getSaturationf();
    int amount = this.amount.getValuei();
    for (LXPoint p : model.points) {
      float hb1 = (this.basis + p.azimuth - slope * (1 - p.yn)) / TWO_PI;
      colors[p.index]= LXColor.hsb(
        hb1 * 360 * amount,
        sat,
        100
      );
    }
  }
}

@LXCategory("Color")
public static class HSB_Two_Color_Split extends LXPattern {
  
  public final CompoundParameter hue1 = new CompoundParameter("Hue1", 0, 0, 360);
  public final CompoundParameter sat1 = new CompoundParameter("Sat1", 100, 0, 100);
  public final CompoundParameter bri1 = new CompoundParameter("Bri1", 100, 0., 100);
  public final CompoundParameter hue2 = new CompoundParameter("Hue2", 0, 0, 360);
  public final CompoundParameter sat2 = new CompoundParameter("Sat2", 100, 0, 100);
  public final CompoundParameter bri2 = new CompoundParameter("Bri2", 100, 0., 100);
  
  public HSB_Two_Color_Split(LX lx) {
    super(lx);
    addParameter(hue1);
    addParameter(sat1);
    addParameter(bri1);
    addParameter(hue2);
    addParameter(sat2);
    addParameter(bri2);
  }
  
  public void run(double deltaMs) {  
    float h1 = hue1.getValuef();
    float s1 = sat1.getValuef();
    float b1 = bri1.getValuef();
    float h2 = hue2.getValuef();
    float s2 = sat2.getValuef();
    float b2 = bri2.getValuef();
    
    for (LXPoint p : model.points) {
      if (p.x >= 0) {
        colors[p.index]= LX.hsb( h1, s1, b1);
      } else if  (p.x < 0) {
        colors[p.index]= LX.hsb( h2, s2, b2);
      } 
    }
  }
}   
