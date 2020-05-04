import java.awt.Color;

@LXCategory("Texture")
public class Sizzle extends LXEffect {
  
  public final CompoundParameter amount = new CompoundParameter("Amount", .5)
    .setDescription("Intensity of the effect");
    
  public final CompoundParameter speed = new CompoundParameter("Speed", .5)
    .setDescription("Speed of the effect");
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  private float base = 0;
  
  public Sizzle(LX lx) {
    super(lx);
    addParameter("amount", this.amount);
    addParameter("speed", this.speed);
  }
  
  public void run(double deltaMs, double amount) {
      double amt = amount * this.amount.getValue();
    if (amt > 0) {
      base += deltaMs * .01 * speed.getValuef();
      for (int i = 0; i < this.buffer.length; ++i) {
        int val = (int) min(0xff, 500 * noise(i, base));
        this.buffer[i] = 0xff000000 | val | (val << 8) | (val << 16);
      }
      MultiplyBlend.multiply(this.colors, this.buffer, amt, this.colors);
    }
  }
}

@LXCategory("Form")
public static class Strobe extends LXEffect {
  
  public enum Waveshape {
    TRI,
    SIN,
    SQUARE,
    UP,
    DOWN
  };
  
  public final EnumParameter<Waveshape> mode = new EnumParameter<Waveshape>("Shape", Waveshape.TRI);
  
  public final CompoundParameter frequency = (CompoundParameter)
    new CompoundParameter("Freq", 1, .05, 10).setUnits(LXParameter.Units.HERTZ);  
  
  public final CompoundParameter depth = (CompoundParameter)
    new CompoundParameter("Depth", 0.5)
    .setDescription("Depth of the strobe effect");
    
  private final SawLFO basis = new SawLFO(1, 0, new FunctionalParameter() {
    public double getValue() {
      return 1000 / frequency.getValue();
  }});
        
  public Strobe(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
    addParameter("frequency", this.frequency);
    addParameter("depth", this.depth);
    startModulator(basis);
  }
  
  @Override
  protected void onEnable() {
    basis.setBasis(0).start();
  }
  
  private LXWaveshape getWaveshape() {
    switch (this.mode.getEnum()) {
    case SIN: return LXWaveshape.SIN;
    case TRI: return LXWaveshape.TRI;
    case UP: return LXWaveshape.UP;
    case DOWN: return LXWaveshape.DOWN;
    case SQUARE: return LXWaveshape.SQUARE;
    }
    return LXWaveshape.SIN;
  }
  
  private final float[] hsb = new float[3];
  
  @Override
  public void run(double deltaMs, double amount) {
    float amt = this.enabledDamped.getValuef() * this.depth.getValuef();
    if (amt > 0) {
      float strobef = basis.getValuef();
      strobef = (float) getWaveshape().compute(strobef);
      strobef = lerp(1, strobef, amt);
      if (strobef < 1) {
        if (strobef == 0) {
          for (int i = 0; i < colors.length; ++i) {
            colors[i] = LXColor.BLACK;
          }
        } else {
          for (int i = 0; i < colors.length; ++i) {
            LXColor.RGBtoHSB(colors[i], hsb);
            hsb[2] *= strobef;
            colors[i] = Color.HSBtoRGB(hsb[0], hsb[1], hsb[2]);
          }
        }
      }
    }
  }
}

@LXCategory("Color")
public class LSD extends LXEffect {
  
  public final BoundedParameter scale = new BoundedParameter("Scale", 10, 5, 40);
  public final BoundedParameter speed = new BoundedParameter("Speed", 4, 1, 6);
  public final BoundedParameter range = new BoundedParameter("Range", 1, .7, 2);
  
  public LSD(LX lx) {
    super(lx);
    addParameter(scale);
    addParameter(speed);
    addParameter(range);
    this.enabledDampingAttack.setValue(500);
    this.enabledDampingRelease.setValue(500);
  }
  
  final float[] hsb = new float[3];

  private float accum = 0;
  private int equalCount = 0;
  private float sign = 1;
  
  @Override
  public void run(double deltaMs, double amount) {
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
    for (LXPoint p :  model.points) {
      LXColor.RGBtoHSB(colors[p.index], hsb);
      float h = rf * noise(sf*p.x, sf*p.y, sf*p.z + accum);
      int c2 = LX.hsb(h * 360, 100, hsb[2]*100);
      if (amount < 1) {
        colors[p.index] = LXColor.lerp(colors[p.index], c2, amount);
      } else {
        colors[p.index] = c2;
      }
      
    }
  }
}

@LXCategory("Color")
public class HSB extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0, 360);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100, 0, 100);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100, 0., 100);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public HSB(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      colors[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
    }
  }
}

@LXCategory("Blend")
public class LERP extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  public final CompoundParameter blend = new CompoundParameter("Blend", 1., 0., 1.);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public LERP(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
    addParameter(blend);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], blend.getValuef()));
    }
  }
}

@LXCategory("Blend")
public class Lightest extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Lightest(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.lightest(buffer[p.index], colors[p.index]));
    }
  }
}

@LXCategory("Blend")
public class Darkest extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Darkest(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.darkest(buffer[p.index], colors[p.index]));
    }
  }
}

@LXCategory("Blend")
public class Screen extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  public final CompoundParameter blend = new CompoundParameter("Blend", 1., 0., 1.);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Screen(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
    addParameter(blend);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.screen(buffer[p.index], colors[p.index]));
    }
  }
}

@LXCategory("Blend")
public class Subtract extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Subtract(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.subtract(buffer[p.index], colors[p.index]));
    }
  }
}

@LXCategory("Blend")
public class Multiply extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Multiply(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    for (LXPoint p :  model.points) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      colors[p.index] = min(360,LXColor.multiply(buffer[p.index], colors[p.index]));
    }
  }
}

@LXCategory("Sub Group")
public class ParCansOff extends LXEffect {
  public ParCansOff(LX lx) {
    super(lx);
  }
  
  @Override
  public void run(double deltaMs, double amount) {
    if (amount > 0) {
      for (ParCan parcan : venue.parcans) {
        setColor(parcan, #000000);
      }
    }
  }
}

@LXCategory("Sub Group")
public class PlatformHSB extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0, 360);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100, 0, 100);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100, 0., 100);
  
  public PlatformHSB(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    float count = 0;
    for (LXPoint p :  model.points) { 
      count = count +1;
      if (count > 1536 && count <= 1608){
      colors[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      }
    }
  }
}


@LXCategory("Sub Group")
public class SubGroupRingsOff extends LXEffect {
  
  final BooleanParameter ring1 = new BooleanParameter("Ring1");
  final BooleanParameter ring2 = new BooleanParameter("Ring2");
  final BooleanParameter ring3 = new BooleanParameter("Ring3");
  
  //This is a Contructor Method!!
  public SubGroupRingsOff(LX lx) {
    super(lx);
    addParameter(ring1); //instance field/variable
    addParameter(ring2);
    addParameter(ring3);
  }
  
  //This is the Method
  @Override
  public void run(double deltaMs, double amount) {
    int white = #FFFFFF;
    int black = #000000;
    int railCount = 0;
    
     //declare values in groupMasks
     Boolean[] ringMask1 = {false,false,false,false,false,true,true,true,
                          false,false,false,false,false,false,false,false,
                          false,false,false,false,false,true,true,true,
                          false,false,false,false,false,true,true,true,
                          false,false,false,false,false,false,false,false,
                          false,false,false,false,false,true,true,true};
     Boolean[] ringMask2 = {false,false,false,true,true,false,false,false,
                          false,false,false,false,true,true,true,true,
                          false,false,false,true,true,false,false,false,
                          false,false,false,true,true,false,false,false,
                          false,false,false,false,true,true,true,true,
                          false,false,false,true,true,false,false,false};
     Boolean[] ringMask3 = {true,true,true,false,false,false,false,false,
                          true,true,true,true,false,false,false,false,
                          true,true,true,false,false,false,false,false,
                          true,true,true,false,false,false,false,false,
                          true,true,true,true,false,false,false,false,
                          true,true,true,false,false,false,false,false,};                       
    
   if (amount > 0) {
      int railSize = 32;//number of pixels in a Rail/Tube whatever
      for (Rail rail : venue.rails) {
        if (ring1.getValueb() && ringMask1[railCount]) {  
            for (int i = 0; i < railSize; ++i) {
              colors[ (railCount*railSize) + i] = LXColor.BLACK;
            }
        } else if (ring2.getValueb() && ringMask2[railCount]) {  
            for (int i = 0; i < railSize; ++i) {
              colors[ (railCount*railSize) + i] = LXColor.BLACK;
            }
        } else if (ring3.getValueb() && ringMask3[railCount]) {  
            for (int i = 0; i < railSize; ++i) {
              colors[ (railCount*railSize) + i] = LXColor.BLACK;
            }
        }else {
            //setColor(rail, black); 
        } 
        ++railCount;
      } 
    }  
  }
}
/*
@LXCategory("Texture")
public class Kaleidescope extends LXEffect {
  
  public final CompoundParameter hue = new CompoundParameter("Hue", 0, 0., 360.);
  public final CompoundParameter sat = new CompoundParameter("Sat", 100., 0., 100.);
  public final CompoundParameter bri = new CompoundParameter("Bri", 100., 0., 100);
  public final DiscreteParameter div = new DiscreteParameter("Div", 1, 1, 4);
  
  //buffer???
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public Kaleidescope(LX lx) {
    super(lx);
    addParameter(hue);
    addParameter(sat);
    addParameter(bri);
    addParameter(div);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int mode = div.getValuei();
    for (LXPoint p :  model.rails) {
      buffer[p.index]= LX.hsb(hue.getValuef(),sat.getValuef(),bri.getValuef());
      if(p.x < 0 && mode == 1) {
        colors[p.index] = buffer[p.index];
      }
    }
  }
}*/

@LXCategory("Dim")
public class ParDim extends LXEffect {
  
  public final CompoundParameter Dim = new CompoundParameter("ParDim", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public ParDim(LX lx) {
    super(lx);
    addParameter(Dim);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if ( cnt > 1608){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim.getValuef()));
      }
    }
  }
}

@LXCategory("Dim")
public class PlatformDim extends LXEffect {
  
  public final CompoundParameter Dim = new CompoundParameter("PlatformDim", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public PlatformDim (LX lx) {
    super(lx);
    addParameter(Dim);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if (cnt > 1536 && cnt <= 1608){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim.getValuef()));
      }
    }
  }
}

@LXCategory("Dim")
public class TubeDim extends LXEffect {
  
  public final CompoundParameter Dim = new CompoundParameter("TubeDim", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public TubeDim(LX lx) {
    super(lx);
    addParameter(Dim);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if (cnt <= 1536 ){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim.getValuef()));
      }
    }
  }
}

@LXCategory("Dim")
public class OutRingDim extends LXEffect {
  
  public final CompoundParameter Dim = new CompoundParameter("OutRingDim", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public OutRingDim (LX lx) {
    super(lx);
    addParameter(Dim);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if (cnt > 1612 && cnt <= 1616){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim.getValuef()));
      }
    }
  }
}

@LXCategory("Dim")
public class InRingDim extends LXEffect {
  
  public final CompoundParameter Dim = new CompoundParameter("InRingDim", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public InRingDim (LX lx) {
    super(lx);
    addParameter(Dim);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if (cnt > 1608 && cnt <= 1612){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim.getValuef()));
      }
    }
  }
}

@LXCategory("Dim")
public class SingleParDim extends LXEffect {
  
  public final CompoundParameter Dim1 = new CompoundParameter("Dim1", 1., 0., 1.);
  public final CompoundParameter Dim2 = new CompoundParameter("Dim2", 1., 0., 1.);
  public final CompoundParameter Dim3 = new CompoundParameter("Dim3", 1., 0., 1.);
  public final CompoundParameter Dim4 = new CompoundParameter("Dim4", 1., 0., 1.);
  public final CompoundParameter Dim5 = new CompoundParameter("Dim5", 1., 0., 1.);
  public final CompoundParameter Dim6 = new CompoundParameter("Dim6", 1., 0., 1.);
  public final CompoundParameter Dim7 = new CompoundParameter("Dim7", 1., 0., 1.);
  public final CompoundParameter Dim8 = new CompoundParameter("Dim8", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public SingleParDim (LX lx) {
    super(lx);
    addParameter(Dim1);
    addParameter(Dim2);
    addParameter(Dim3);
    addParameter(Dim4);
    addParameter(Dim5);
    addParameter(Dim6);
    addParameter(Dim7);
    addParameter(Dim8);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    for (LXPoint p :  model.points) {
      ++cnt;
      if (cnt == 1609){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim1.getValuef()));
      } else if (cnt == 1610){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim2.getValuef()));
      } else if (cnt == 1611){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim3.getValuef()));
      } else if (cnt == 1612){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim4.getValuef()));
      } else if (cnt == 1613){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim5.getValuef()));
      } else if (cnt == 1614){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim6.getValuef()));
      } else if (cnt == 1615){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim7.getValuef()));
      } else if (cnt == 1616){
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim8.getValuef()));
      }
    }
  }
}  
@LXCategory("Dim")
public class RingDim extends LXEffect {
  
  public final CompoundParameter Dim1 = new CompoundParameter("RingDim1", 1., 0., 1.);
  public final CompoundParameter Dim2 = new CompoundParameter("RingDim2", 1., 0., 1.);
  public final CompoundParameter Dim3 = new CompoundParameter("RingDim3", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public RingDim (LX lx) {
    super(lx);
    addParameter(Dim1);
    addParameter(Dim2);
    addParameter(Dim3);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    int rCnt = 0;
    for (LXPoint p :  model.points) {
      
      if (cnt%32 == 0 && cnt != 0){
        ++rCnt;
      }  
      ++cnt;
      if (rCnt == 5 || rCnt == 6 || rCnt == 7 || rCnt == 21 || rCnt == 22 || rCnt == 23 ||
        rCnt == 29 || rCnt == 30 || rCnt == 31 || rCnt == 45 || rCnt == 46 || rCnt == 47) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim1.getValuef()));
      } else if (rCnt == 3 || rCnt == 4 || rCnt == 12 || rCnt == 13 || rCnt == 14 || rCnt == 15 || rCnt == 19 || rCnt == 20 ||
        rCnt == 27 || rCnt == 28 || rCnt == 36 || rCnt == 37 || rCnt == 38 || rCnt == 39 || rCnt == 43 || rCnt == 44 ) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim2.getValuef()));
      } else if (cnt == 1611){ } else if (rCnt == 0 || rCnt == 1 || rCnt == 2 || rCnt == 8 || rCnt == 9 || rCnt == 10 || rCnt == 11 || rCnt == 16 || rCnt == 17 || rCnt == 18 ||
        rCnt == 24 || rCnt == 25 || rCnt == 26 || rCnt == 32 || rCnt == 33 || rCnt == 34 || rCnt == 35 || rCnt == 40 || rCnt == 41 || rCnt == 42) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim3.getValuef()));
      }       
    }
  }
}

@LXCategory("Dim")
public class SectionDim extends LXEffect {
  
  public final CompoundParameter Dim1 = new CompoundParameter("SectionDim1", 1., 0., 1.);
  public final CompoundParameter Dim2 = new CompoundParameter("SectionDim2", 1., 0., 1.);
  public final CompoundParameter Dim3 = new CompoundParameter("SectionDim3", 1., 0., 1.);
  public final CompoundParameter Dim4 = new CompoundParameter("SectionDim4", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public SectionDim (LX lx) {
    super(lx);
    addParameter(Dim1);
    addParameter(Dim2);
    addParameter(Dim3);
    addParameter(Dim4);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    int rCnt = 0;
    for (LXPoint p :  model.points) {
      
      if (cnt%32 == 0 && cnt != 0){
        ++rCnt;
      }  
      ++cnt;
      if (rCnt == 0 || rCnt == 1 || rCnt == 2 || rCnt == 3 || rCnt == 4 || rCnt == 5 ||
        rCnt == 6 || rCnt == 7 || rCnt == 10 || rCnt == 11 || rCnt == 14 || rCnt == 15) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim1.getValuef()));
      } else if (rCnt == 8 || rCnt == 9 || rCnt == 12 || rCnt == 13 || rCnt == 16 || rCnt == 17 ||
        rCnt == 18 || rCnt == 19 || rCnt == 20 || rCnt == 21 || rCnt == 22 || rCnt == 23) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim2.getValuef()));
       } else if (rCnt == 24 || rCnt == 25 || rCnt == 26 || rCnt == 27 || rCnt == 28 || rCnt == 29 ||
        rCnt == 30 || rCnt == 31 || rCnt == 34 || rCnt == 35 || rCnt == 38 || rCnt == 39) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim3.getValuef()));
       } else if (rCnt ==32 || rCnt == 33 || rCnt == 36 || rCnt == 37 || rCnt == 40 || rCnt == 41 ||
        rCnt == 42 || rCnt == 43 || rCnt == 44 || rCnt == 45 || rCnt == 46 || rCnt == 47) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim4.getValuef()));
      }       
    }
  }
}

@LXCategory("Dim")
public class InOutDim extends LXEffect {
  
  public final CompoundParameter Dim1 = new CompoundParameter("InOutDim1", 1., 0., 1.);
  public final CompoundParameter Dim2 = new CompoundParameter("InOutDim2", 1., 0., 1.);
  public final CompoundParameter Dim3 = new CompoundParameter("InOutDim3", 1., 0., 1.);
  
  private final int[] buffer = new ModelBuffer(lx).getArray();
  
  public InOutDim (LX lx) {
    super(lx);
    addParameter(Dim1);
    addParameter(Dim2);
    addParameter(Dim3);
  }
  
  
  @Override
  public void run(double deltaMs, double amount) {
    int cnt = 0;
    int rCnt = 0;
    for (LXPoint p :  model.points) {
      
      if (cnt%32 == 0 && cnt != 0){
        ++rCnt;
      }  
      ++cnt;
      if (rCnt == 2 || rCnt == 4 || rCnt == 5 || rCnt == 7 || rCnt == 9 || rCnt == 10 ||
        rCnt == 13 || rCnt == 14 || rCnt == 16 || rCnt == 19 || rCnt == 21 || rCnt == 23 ||
        rCnt == 26 || rCnt == 28 || rCnt == 29 || rCnt == 31 || rCnt == 33 || rCnt == 34 ||
        rCnt == 37 || rCnt == 38 || rCnt == 40 || rCnt == 43 || rCnt == 45 || rCnt == 47) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim1.getValuef()));
       } else if (rCnt == 1 || rCnt == 3 || rCnt == 6 || rCnt == 8 || rCnt == 11 || rCnt == 12 || rCnt == 15 || rCnt == 17 || rCnt == 20 || rCnt == 22 ||
        rCnt == 25 || rCnt == 27 || rCnt == 30 || rCnt == 32 || rCnt == 35 || rCnt == 36 || rCnt == 39 || rCnt == 41 || rCnt == 44 || rCnt == 46 ) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim2.getValuef()));
      } else if (rCnt == 0 || rCnt == 18 || rCnt == 24 || rCnt == 42) {
        buffer[p.index]= LX.hsb(1,1,0);
        colors[p.index] = min(360,LXColor.lerp(buffer[p.index], colors[p.index], Dim3.getValuef()));
      }       
    }
  }
}
