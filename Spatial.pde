@LXCategory("Spatial")
public static class MultiDelay extends LXPattern {
  
  final CompoundParameter intensity1 = new CompoundParameter("Int1", 100, 0, 100);
  final CompoundParameter intensity2 = new CompoundParameter("Int2", 100, 0, 100);
  final CompoundParameter intensity3 = new CompoundParameter("Int3", 100, 0, 100);
  final CompoundParameter intensity4 = new CompoundParameter("Int4", 100, 0, 100);
  final CompoundParameter intensity5 = new CompoundParameter("Int5", 100, 0, 100);
  final CompoundParameter intensity6 = new CompoundParameter("Int6", 100, 0, 100);
  final CompoundParameter intensity7 = new CompoundParameter("Int7", 100, 0, 100);
  final CompoundParameter intensity8 = new CompoundParameter("Int8", 100, 0, 100);
  
  final CompoundParameter spread = new CompoundParameter("Spread", 0.5 , 0, 2);
  final CompoundParameter distance = new CompoundParameter("Distance", 3* model.zMax, 0 , 10 * model.zMax);
  
  public MultiDelay(LX lx) {
    super(lx);
    addParameter(intensity1);
    addParameter(intensity2);
    addParameter(intensity3);
    addParameter(intensity4);
    addParameter(intensity5);
    addParameter(intensity6);
    addParameter(intensity7);
    addParameter(intensity8);
    addParameter(spread);
    addParameter(distance);
  }
  
  public void run(double deltaMs) {
    float d = distance.getValuef();
    float offset = 0.5;
    // x and z coordinates for each channel
    float x1 = (0.4043 - offset) * d;
    float z1 = (0.26903 - offset) * d;
    float x2 = (0.595671 - offset) * d;
    float z2 = (0.26903 - offset) * d;
    float x3 = (0.73097 - offset) * d;
    float z3 = (0.404329 - offset) * d;
    float x4 = (0.73097 - offset) * d;
    float z4 = (0.595671 - offset) * d;
    float x5 = (0.595671 - offset) * d;
    float z5 = (0.73097 - offset) * d;
    float x6 = (0.404329 - offset) * d;
    float z6 = (0.73097 - offset) * d;
    float x7 = (0.26903 - offset) * d;
    float z7 = (0.595671 - offset) * d;
    float x8 = (0.26903 - offset) * d;
    float z8 = (0.404329 - offset) * d;
    
    for (LXPoint p : model.points) {
      colors[p.index] = LXColor.gray(min(100,( max(0, intensity1.getValuef() - (spread.getValuef() *(abs(p.x - x1)+ abs(p.z - z1))))
                                    + max(0, intensity2.getValuef() - (spread.getValuef() *(abs(p.x - x2)+ abs(p.z - z2))))
                                    + max(0, intensity3.getValuef() - (spread.getValuef() *(abs(p.x - x3)+ abs(p.z - z3))))
                                    + max(0, intensity4.getValuef() - (spread.getValuef() *(abs(p.x - x4)+ abs(p.z - z4))))
                                    + max(0, intensity5.getValuef() - (spread.getValuef() *(abs(p.x - x5)+ abs(p.z - z5))))
                                    + max(0, intensity6.getValuef() - (spread.getValuef() *(abs(p.x - x6)+ abs(p.z - z6))))
                                    + max(0, intensity7.getValuef() - (spread.getValuef() *(abs(p.x - x7)+ abs(p.z - z7))))
                                    + max(0, intensity8.getValuef() - (spread.getValuef() *(abs(p.x - x8)+ abs(p.z - z8)))))));
    }
  }
}

@LXCategory("Spatial")
public class EnvelopDecode extends EnvelopPattern {
  
  public final CompoundParameter mode = new CompoundParameter("Mode", 0);
  public final CompoundParameter fade = new CompoundParameter("Fade", 1*FEET, 0.001, 6*FEET);
  public final CompoundParameter damping = (CompoundParameter)
    new CompoundParameter("Damping", 10, 10, .1)
    .setExponent(.25);
    
  private final DampedParameter[] dampedDecode = new DampedParameter[envelop.decode.channels.length]; 
  
  public EnvelopDecode(LX lx) {
    super(lx);
    addParameter("mode", mode);
    addParameter("fade", fade);
    addParameter("damping", damping);
    int d = 0;
    for (LXParameter parameter : envelop.decode.channels) {
      startModulator(dampedDecode[d++] = new DampedParameter(parameter, damping));
    }
  }
  
  public void run(double deltaMs) {
    float fv = fade.getValuef();
    float falloff = 100 / fv;
    float mode = this.mode.getValuef();
    float faden = fade.getNormalizedf();
    for (Column column : venue.columns) {
      float levelf = this.dampedDecode[column.index].getValuef();
      float level = levelf * (model.yRange / 2.);
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
          float yn = abs(p.y - model.cy);
          float b0 = constrain(falloff * (level - yn), 0, 100);
          float b1max = lerp(100, 100*levelf, faden);
          float b1 = (yn > level) ? max(0, b1max - 80*(yn-level)) : lerp(0, b1max, yn / level); 
          colors[p.index] = LXColor.gray(lerp(b0, b1, mode));
        }
      }
    }
  }
}

@LXCategory("Spatial")
public class EnvelopObjects extends EnvelopPattern implements CustomDeviceUI {
  
  public final CompoundParameter size = new CompoundParameter("Base", 4*FEET, 0, 24*FEET);
  public final BoundedParameter response = new BoundedParameter("Level", 0, 1*FEET, 24*FEET);
  public final CompoundParameter spread = new CompoundParameter("Spread", 1, 1, .2); 
  
  public EnvelopObjects(LX lx) {
    super(lx);
    addParameter("size", this.size);
    addParameter("response", this.response);
    addParameter("spread", this.spread);
    for (Envelop.Source.Channel object : envelop.source.channels) {
      Layer layer = new Layer(lx, object);
      addLayer(layer);
      addParameter("active-" + object.index, layer.active);
    }
  }
  
  public void buildDeviceUI(UI ui, UI2dContainer device) {
    int i = 0;
    for (LXLayer layer : getLayers()) {
      new UIButton((i % 4)*33, (i/4)*28, 28, 24)
      .setLabel(Integer.toString(i+1))
      .setParameter(((Layer)layer).active)
      .setTextAlignment(PConstants.CENTER, PConstants.CENTER)
      .addToContainer(device);
      ++i;
    }
    int knobSpacing = UIKnob.WIDTH + 4;
    new UIKnob(0, 116).setParameter(this.size).addToContainer(device);
    new UIKnob(knobSpacing, 116).setParameter(this.response).addToContainer(device);
    new UIKnob(2*knobSpacing, 116).setParameter(this.spread).addToContainer(device);
    //new UIItemList.BasicList(ui,0,0,100,100).addToContainer(device);

    device.setContentWidth(3*knobSpacing - 4);
  }
  
  class Layer extends LXModelLayer<EnvelopModel> {
    
    private final Envelop.Source.Channel object;
    private final BooleanParameter active = new BooleanParameter("Active", true); 
    
    private final MutableParameter tx = new MutableParameter();
    private final MutableParameter ty = new MutableParameter();
    private final MutableParameter tz = new MutableParameter();
    private final DampedParameter x = new DampedParameter(this.tx, 50*FEET);
    private final DampedParameter y = new DampedParameter(this.ty, 50*FEET);
    private final DampedParameter z = new DampedParameter(this.tz, 50*FEET);
    
    Layer(LX lx, Envelop.Source.Channel object) {
      super(lx);
      this.object = object;
      startModulator(this.x);
      startModulator(this.y);
      startModulator(this.z);
    }
    
    public void run(double deltaMs) {
      if (!this.active.isOn()) {
        return;
      }
      this.tx.setValue(object.tx);
      this.ty.setValue(object.ty);
      this.tz.setValue(object.tz);
      if (object.active) {
        float x = this.x.getValuef();
        float y = this.y.getValuef();
        float z = this.z.getValuef();
        float spreadf = spread.getValuef();
        float falloff = 100 / (size.getValuef() + response.getValuef() * object.getValuef());
        for (LXPoint p : model.railPoints) {
          float dist = dist(p.x * spreadf, p.y, p.z * spreadf, x * spreadf, y, z * spreadf);
          float b = 100 - dist*falloff;
          if (b > 0) {
            addColor(p.index, LXColor.gray(b));
          }
        }
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(LXColor.BLACK);
  }
}

@LXCategory("Spatial")
public class EnvelopShimmer extends EnvelopPattern {
  
  private final int BUFFER_SIZE = 512; 
  private final float[][] buffer = new float[model.columns.size()][BUFFER_SIZE];
  private int bufferPos = 0;
  
  public final CompoundParameter interp = new CompoundParameter("Mode", 0); 
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 1, 5, .1)
    .setDescription("Speed of the sound waves emanating from the speakers");
    
    public final CompoundParameter taper = (CompoundParameter)
    new CompoundParameter("Taper", 1, 0, 10)
    .setExponent(2)
    .setDescription("Amount of tapering applied to the signal");
  
  private final DampedParameter speedDamped = new DampedParameter(speed, 1);
  
  public EnvelopShimmer(LX lx) {
    super(lx);
    addParameter("intern", interp);
    addParameter("speed", speed);
    addParameter("taper", taper);
    startModulator(speedDamped);
    for (float[] buffer : this.buffer) {
      for (int i = 0; i < buffer.length; ++i) {
        buffer[i] = 0;
      }
    }
  }
  
  public void run(double deltaMs) {
    float speed = this.speedDamped.getValuef();
    float interp = this.interp.getValuef();
    float taper = this.taper.getValuef() * lerp(3, 1, interp); 
    for (Column column : model.columns) {
      float[] buffer = this.buffer[column.index];
      buffer[this.bufferPos] = envelop.decode.channels[column.index].getValuef();
      for (Rail rail : column.rails) {
        for (int i = 0; i < rail.points.length; ++i) {
          LXPoint p = rail.points[i];
          int i3 = i % (rail.points.length/3);
          float td = abs(i3 - rail.points.length / 6);
          float threeWay = getValue(buffer, speed * td);
          float nd = abs(i - rail.points.length / 2);
          float normal = getValue(buffer, speed * nd);
          float bufferValue = lerp(threeWay, normal, interp);
          float d = lerp(td, nd, interp);
          colors[p.index] = LXColor.gray(max(0, 100 * bufferValue - d*taper));
        }
      }      
    }
    --bufferPos;
    if (bufferPos < 0) {
      bufferPos = BUFFER_SIZE - 1;
    }
  }
  
  private float getValue(float[] buffer, float bufferOffset) {
    int offsetFloor = (int) bufferOffset;
    int bufferTarget1 = (bufferPos + offsetFloor) % BUFFER_SIZE;
    int bufferTarget2 = (bufferPos + offsetFloor + 1) % BUFFER_SIZE;
    return lerp(buffer[bufferTarget1], buffer[bufferTarget2], bufferOffset - offsetFloor);
  }
}

@LXCategory("Spatial")
public static class TwoObjects extends LXPattern {
  
  final CompoundParameter X1 = new CompoundParameter("XThing1", 0, model.xMin*3, model.xMax*3);
  final CompoundParameter Z1 = new CompoundParameter("ZThing1", 0, model.zMin*3, model.zMax*3);
  final CompoundParameter intensity1 = new CompoundParameter("Int1", 100, 0, 100);
  final CompoundParameter spread1 = new CompoundParameter("Sprd1", 0.2 , 0, 2);
  final CompoundParameter X2 = new CompoundParameter("XThing2", 0, model.xMin*3, model.xMax*3);
  final CompoundParameter Z2 = new CompoundParameter("ZThing2", 0, model.zMin*3, model.zMax*3);
  final CompoundParameter intensity2 = new CompoundParameter("Int2", 100, 0, 100);
  final CompoundParameter spread2 = new CompoundParameter("Sprd2", 0.2, 0, 2);
  final CompoundParameter hue1 = new CompoundParameter("Hue1", 0, 0, 360);
  final CompoundParameter saturation = new CompoundParameter("Sat", 100, 0, 100);
  final CompoundParameter hue2 = new CompoundParameter("Hue2", 0, 0, 360);
  final CompoundParameter thresh = new CompoundParameter("Thresh", 82, 0, 100);
  float hue =0 ;
  float brightness =0 ;

  
  public TwoObjects(LX lx) {
    super(lx);
    addParameter(X1);
    addParameter(Z1);
    addParameter(intensity1);
    addParameter(spread1);
    addParameter(X2);
    addParameter(Z2);
    addParameter(intensity2);
    addParameter(spread2);
    addParameter(hue1);
    addParameter(hue2);
    addParameter(saturation);
    addParameter(thresh);
  }
  
  public void run(double deltaMs) {
    float b1 = 0;
    float b2 = 0;
    float bdiff = 0;
    float hdiff = 0;
    float hadj = 0;
    float b1n = 0;
    float b2n = 0;
    float badj =0;
    float th = 0;
    for (LXPoint p : model.points) {
      //int hue_1= (int) hue1.getValuef();
      b1 = min(100,((max(0.0001, intensity1.getValuef() - (spread1.getValuef() *(abs(p.x - X1.getValuef())+ abs(p.z - Z1.getValuef())))))));
      b2 = min(100,((max(0.0001, intensity2.getValuef() - (spread2.getValuef() *(abs(p.x - X2.getValuef())+ abs(p.z - Z2.getValuef())))))));
      bdiff = abs(b1-b2);
      hdiff = abs(hue1.getValuef()-hue2.getValuef());
      b1n = b1 / max (b1,b2);
      b2n = b2 / max (b1,b2);
      badj = min(b1n, b2n);
      th = thresh.getValuef();
      
      //hue adjust
      if (b2 >= b1) {
        hadj = hue2.getValuef();
      } else {
        hadj = hue1.getValuef();
      }
      
      //shitcode that works hopefully 
      if (bdiff > th && b1 >= b2) {
        //println("if 1");
        hue = hue1.getValuef();
      } else if (bdiff > th && b2 > b1){
        //println("if 2");
        hue = hue2.getValuef();
      } else { 
        //println("if 3");
        if( b2>=b1) {
         // println("if 4");
          hue = hadj-((hdiff*badj)/2);
        } else {
          //println("if 5");
          hue = hadj+((hdiff*badj)/2);
        }  
        
        //hue = ((abs(hue1.getValuef()-hue2.getValuef()))/2)+min(hue1.getValuef(),hue2.getValuef());
      }
      brightness = max(b1,b2);
      if (p.index == 31 || p.index ==30)   
         {//println("hue: " + hue + " hadj: " + hadj+ " hdiff: " + hdiff+ "p.y: " + p.y);
       }
      colors[p.index] = LXColor.hsb(hue,saturation.getValuef(),brightness);//+hue2.getValuei()));
    }
  }
}
