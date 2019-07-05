import heronarts.lx.modulator.*;
import java.util.Stack;
import java.util.Random;

public static abstract class EnvelopPattern extends LXModelPattern<EnvelopModel> {
  
  protected EnvelopPattern(LX lx) {
    super(lx);
  }
}

public static abstract class RotationPattern extends EnvelopPattern {
  
  protected final CompoundParameter rate = (CompoundParameter)
  new CompoundParameter("Rate", .25, .01, 2)
    .setExponent(2)
    .setUnits(LXParameter.Units.HERTZ)
    .setDescription("Rate of the rotation");
    
  protected final SawLFO phase = new SawLFO(0, TWO_PI, new FunctionalParameter() {
    public double getValue() {
      return 1000 / rate.getValue();
    }
  });
  
  protected RotationPattern(LX lx) {
    super(lx);
    startModulator(this.phase);
    addParameter("rate", this.rate);
  }
}

@LXCategory("Pattern")
public static class Helix extends RotationPattern {
    
  private final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 2*FEET, 6*INCHES, 8*FEET)
    .setDescription("Size of the corkskrew");
    
  private final CompoundParameter coil = (CompoundParameter)
    new CompoundParameter("Coil", 1, .25, 2.5)
    .setExponent(.5)
    .setDescription("Coil amount");
    
  private final DampedParameter dampedCoil = new DampedParameter(coil, .2);
  
  public Helix(LX lx) {
    super(lx);
    addParameter("size", this.size);
    addParameter("coil", this.coil);
    startModulator(dampedCoil);
    setColors(0);
  }
  
  public void run(double deltaMs) {
    float phaseV = this.phase.getValuef();
    float sizeV = this.size.getValuef();
    float falloff = 200 / sizeV;
    float coil = this.dampedCoil.getValuef();
    
    for (Rail rail : model.rails) {
      float yp = -sizeV + ((phaseV + (TWO_PI + PI + coil * rail.theta)) % TWO_PI) / TWO_PI * (model.yRange + 2*sizeV);
      float yp2 = -sizeV + ((phaseV + TWO_PI + coil * rail.theta) % TWO_PI) / TWO_PI * (model.yRange + 2*sizeV);
      for (LXPoint p : rail.points) {
        float d1 = 100 - falloff*abs(p.y - yp);
        float d2 = 100 - falloff*abs(p.y - yp2);
        float b = max(d1, d2);
        colors[p.index] = b > 0 ? LXColor.gray(b) : #000000;
      }
    }
  }
}

@LXCategory("Pattern")
public static class Warble extends RotationPattern {
  
  private final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 2*FEET, 6*INCHES, 12*FEET)
    .setDescription("Size of the warble");
    
  private final CompoundParameter depth = (CompoundParameter)
    new CompoundParameter("Depth", .4, 0, 1)
    .setExponent(2)
    .setDescription("Depth of the modulation");
  
  private final CompoundParameter interp = 
    new CompoundParameter("Interp", 1, 1, 3)
    .setDescription("Interpolation on the warble");
    
  private final DampedParameter interpDamped = new DampedParameter(interp, .5, .5);
  private final DampedParameter depthDamped = new DampedParameter(depth, .4, .4);
    
  public Warble(LX lx) {
    super(lx);
    startModulator(this.interpDamped);
    startModulator(this.depthDamped);
    addParameter("size", this.size);
    addParameter("interp", this.interp);
    addParameter("depth", this.depth);
    setColors(0);
  }
  
  public void run(double deltaMs) {
    float phaseV = this.phase.getValuef();
    float interpV = this.interpDamped.getValuef();
    int mult = floor(interpV);
    float lerp = interpV % mult;
    float falloff = 200 / size.getValuef();
    float depth = this.depthDamped.getValuef();
    for (Rail rail : model.rails) {
      float y1 = model.yRange * depth * sin(phaseV + mult * rail.theta);
      float y2 = model.yRange * depth * sin(phaseV + (mult+1) * rail.theta);
      float yo = lerp(y1, y2, lerp);
      for (LXPoint p : rail.points) {
        colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(p.y - model.cy - yo)));
      }
    }
  }
}

@LXCategory("Pattern")
public static class PitchRollYaw extends LXPattern {
  
  //fields or variables 
  private LXProjection proj = new LXProjection(model);
  final CompoundParameter pRot = new CompoundParameter("Pitch", 0, -PI, PI);
  final CompoundParameter rRot = new CompoundParameter("Roll", 0, -PI, PI);
  final CompoundParameter yRot = new CompoundParameter("Yaw", 0, 0, TWO_PI);
  final CompoundParameter yOffset  = new CompoundParameter("Y off", 0, -3* model.yMax, 3* model.yMax);
  final CompoundParameter intensity = new CompoundParameter("Int", 100, 0, 100);
  final CompoundParameter spread = (CompoundParameter) new CompoundParameter("Spread", 10 , 0, 100).setExponent(3);
  final CompoundParameter pAmp = (CompoundParameter) new CompoundParameter("pAmp", 0.1, 0 , 1.0)  .setExponent(3);
  final CompoundParameter rAmp = (CompoundParameter) new CompoundParameter("rAmp", 0.1, 0 , 1.0) .setExponent(3);
  final CompoundParameter yAmp = new CompoundParameter("yAmp", 1.0, 0 , 1.0);
  
  //Contructor Method
  public PitchRollYaw(LX lx) {
    super(lx);
    for (int i = 0; i < 1; ++i) {
      addLayer(new PitRoll(lx));
    }
    addParameter(pRot);
    addParameter(rRot);
    addParameter(yRot);
    addParameter(yOffset);
    addParameter(pAmp);
    addParameter(rAmp);
    addParameter(yAmp);
    addParameter(intensity);
    addParameter(spread);
  }
  
  //sets background color to be black
  public void run(double deltaMs) {
    setColors(#000000);
  }
  //New class called
  class PitRoll extends LXLayer {
    
    //Contructor method  
    public PitRoll(LX lx) {
        super(lx);
      }
      
      //main/run method
      public void run(double deltaMs) {
      proj.reset().center().rotateY(yAmp.getValuef() *yRot.getValuef()).rotateX(pAmp.getValuef() * pRot.getValuef()).rotateZ(rAmp.getValuef() * rRot.getValuef());//rotateZ(amplitude.getValuef() * zAmp.getValuef() * roll.getValuef());
      //float yOffset = yOffset.getValuef();
      //float falloff = 100 / (2*FEET);
      for (LXVector v : proj) {
        float b = intensity.getValuef() - spread.getValuef() * abs(v.y - yOffset.getValuef());  
        if (b > 0) {
          addColor(v.index, LXColor.gray(b));
        }
      } 
    }
  }
}

@LXCategory("Pattern")
public static class Raindrops extends EnvelopPattern {
  
  private static final float MAX_VEL = -180;
  
  private final Stack<Drop> availableDrops = new Stack<Drop>();
  
  public final CompoundParameter velocity = (CompoundParameter)
    new CompoundParameter("Velocity", 0, MAX_VEL)
    .setDescription("Initial velocity of drops");
    
  public final CompoundParameter randomVelocity = 
    new CompoundParameter("Rnd>Vel", 0, MAX_VEL)
    .setDescription("How much to randomize initial velocity of drops");
  
  public final CompoundParameter gravity = (CompoundParameter)
    new CompoundParameter("Gravity", -386, -1, -500)
    .setExponent(3)
    .setDescription("Gravity rate for drops to fall");
  
  public final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 4*INCHES, 1*INCHES, 48*INCHES)
    .setExponent(2)
    .setDescription("Size of the raindrops");
    
  public final CompoundParameter randomSize = (CompoundParameter)
    new CompoundParameter("Rnd>Sz", 1*INCHES, 0, 48*INCHES)
    .setExponent(2)
    .setDescription("Amount of size randomization");    
  
  public final CompoundParameter negative =
    new CompoundParameter("Negative", 0)
    .setDescription("Whether drops are light or dark");
  
  public final BooleanParameter reverse =
    new BooleanParameter("Reverse", false)
    .setDescription("Whether drops fall from the ground to the sky");
  
  public final BooleanParameter auto =
    new BooleanParameter("Auto", false)
    .setDescription("Whether drops automatically fall");  
  
  public final CompoundParameter rate =
    new CompoundParameter("Rate", .5, 30)
    .setDescription("Rate at which new drops automatically fall");

  private final Click click = new Click("click", new FunctionalParameter() {
    public double getValue() {
      return 1000 / rate.getValue();
    }
  });

  public Raindrops(LX lx) {
    super(lx);
    addParameter("velocity", this.velocity);
    addParameter("randomVelocity", this.randomVelocity);
    addParameter("gravity", this.gravity);
    addParameter("size", this.size);
    addParameter("randomSize", this.randomSize);
    addParameter("negative", this.negative);
    addParameter("auto", this.auto);
    addParameter("rate", this.rate);
    addParameter("reverse", this.reverse);
    startModulator(click);
  }
  
  private void triggerDrop() {
    if (availableDrops.empty()) {
      Drop drop = new Drop(lx);
      addLayer(drop);
      availableDrops.push(drop);
    }
    availableDrops.pop().initialize();
  }
    
  private class Drop extends LXLayer {
        
    private final Accelerator accel = new Accelerator(model.yMax, velocity, gravity);
    private float random;
    
    private Rail rail;
    private boolean active = false;
    
    Drop(LX lx) {
      super(lx);
      addModulator(this.accel);
    }
    
    void initialize() {
      int railIndex = (int) Math.round(Math.random() * (Raindrops.this.model.rails.size()-1));
      this.rail = Raindrops.this.model.rails.get(railIndex);
      this.random = (float) Math.random();
      this.accel.reset();
      this.accel.setVelocity(this.accel.getVelocity() + Math.random() * randomVelocity.getValue());
      this.accel.setValue(model.yMax + size.getValuef() + this.random * randomSize.getValuef()).start();
      this.active = true;
    }
    
    public void run(double deltaMs) {
      if (this.active) {
        float len = size.getValuef() + this.random * randomSize.getValuef();
        float falloff = 100 / len;
        float accel = this.accel.getValuef();
        float pos = reverse.isOn() ? (model.yMin + model.yMax - accel) : accel; 
        for (LXPoint p : this.rail.points) {
          float b = 100 - falloff * abs(p.y - pos);
          if (b > 0) {
            addColor(p.index, LXColor.gray(b));
          }
        }
        if (accel < -len) {
          this.active = false;
          availableDrops.push(this);
        }
      }
    }
  }
  
  @Override
  public void noteOnReceived(MidiNoteOn note) {
    triggerDrop();
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
    if (this.click.click() && this.auto.isOn()) {
      triggerDrop();
    }
  }
  
  public void afterLayers(double deltaMs) {
    float neg = this.negative.getValuef();
    if (neg > 0) {
      for (LXPoint p : model.railPoints) {
        colors[p.index] = LXColor.lerp(colors[p.index], LXColor.subtract(#ffffff, colors[p.index]), neg);
      }
    }
  }
  
  public void buildDeviceUI(UI ui, UI2dContainer device) {
    device.setLayout(UI2dContainer.Layout.VERTICAL);
    device.setChildMargin(6);
    new UIKnob(this.velocity).addToContainer(device);
    new UIKnob(this.gravity).addToContainer(device);
    new UIKnob(this.size).addToContainer(device);
    new UIDoubleBox(0, 0, device.getContentWidth(), 16)
      .setParameter(this.randomVelocity)
      .addToContainer(device);
    new UIButton(0, 0, device.getContentWidth(), 16)
      .setParameter(this.auto)
      .setLabel("Auto")
      .addToContainer(device);
    new UIDoubleBox(0, 0, device.getContentWidth(), 16)
      .setParameter(this.rate)
      .addToContainer(device);      
  }
}

@LXCategory("Pattern")
public class Bouncing extends LXPattern {
  
  public CompoundParameter gravity = (CompoundParameter)
    new CompoundParameter("Gravity", -200, -10, -400)
    .setExponent(2)
    .setDescription("Gravity factor");
  
  public CompoundParameter size =
    new CompoundParameter("Length", 2*FEET, 1*FEET, 8*FEET)
    .setDescription("Length of the bouncers");
  
  public CompoundParameter amp =
    new CompoundParameter("Height", model.yRange, 1*FEET, model.yRange)
    .setDescription("Height of the bounce");
  
  public Bouncing(LX lx) {
    super(lx);
    addParameter("gravity", this.gravity);
    addParameter("size", this.size);
    addParameter("amp", this.amp);
    for (Column column : venue.columns) {
      addLayer(new Bouncer(lx, column));
    }
  }
  
  class Bouncer extends LXLayer {
    
    private final Column column;
    private final Accelerator position;
    
    Bouncer(LX lx, Column column) {
      super(lx);
      this.column = column;
      this.position = new Accelerator(column.yMax, 0, gravity);
      startModulator(position);
    }
    
    public void run(double deltaMs) {
      if (position.getValue() < 0) {
        position.setValue(-position.getValue());
        position.setVelocity(sqrt(abs(2 * (amp.getValuef() - random(0, 2*FEET)) * gravity.getValuef()))); 
      }
      float h = palette.getHuef();
      float falloff = 100. / size.getValuef();
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
          float b = 100 - falloff * abs(p.y - position.getValuef());
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

@LXCategory("Pattern")
public class Tron extends LXPattern {
  
  private final static int MIN_DENSITY = 5;
  private final static int MAX_DENSITY = 80;
  
  private CompoundParameter period = (CompoundParameter)
    new CompoundParameter("Speed", 150000, 400000, 50000)
    .setExponent(.5)
    .setDescription("Speed of movement");
    
  private CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 2*FEET, 6*INCHES, 5*FEET)
    .setExponent(2)
    .setDescription("Size of strips");
    
  private CompoundParameter density = (CompoundParameter)
    new CompoundParameter("Density", 25, MIN_DENSITY, MAX_DENSITY)
    .setDescription("Density of tron strips");
    
  public Tron(LX lx) {  
    super(lx);
    addParameter("period", this.period);
    addParameter("size", this.size);
    addParameter("density", this.density);    
    for (int i = 0; i < MAX_DENSITY; ++i) {
      addLayer(new Mover(lx, i));
    }
  }
  
  class Mover extends LXLayer {
    
    final int index;
    
    final TriangleLFO pos = new TriangleLFO(0, lx.total, period);
    
    private final MutableParameter targetBrightness = new MutableParameter(100); 
    
    private final DampedParameter brightness = new DampedParameter(this.targetBrightness, 50); 
    
    Mover(LX lx, int index) {
      super(lx);
      this.index = index;
      startModulator(this.brightness);
      startModulator(this.pos.randomBasis());
    }
    
    public void run(double deltaMs) {
      this.targetBrightness.setValue((density.getValuef() > this.index) ? 100 : 0);
      float maxb = this.brightness.getValuef();
      if (maxb > 0) {
        float pos = this.pos.getValuef();
        float falloff = maxb / size.getValuef();
        for (LXPoint p : model.points) {
          float b = maxb - falloff * LXUtils.wrapdistf(p.index, pos, model.points.length);
          if (b > 0) {
            addColor(p.index, LXColor.gray(b));
          }
        }
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("Pattern")
public static class Rings extends EnvelopPattern {
  
  public final CompoundParameter amplitude =
    new CompoundParameter("Amplitude", 1);
    
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 10000, 20000, 1000)
    .setExponent(.25);
  
  public Rings(LX lx) {
    super(lx);
    for (int i = 0; i < 2; ++i) {
      addLayer(new Ring(lx));
    }
    addParameter("amplitude", this.amplitude);
    addParameter("speed", this.speed);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
  class Ring extends LXLayer {
    
    private LXProjection proj = new LXProjection(model);
    private final SawLFO yRot = new SawLFO(0, TWO_PI, 9000 + 2000 * Math.random());
    private final SinLFO zRot = new SinLFO(-1, 1, speed);
    private final SinLFO zAmp = new SinLFO(PI / 10, PI/4, 13000 + 3000 * Math.random());
    private final SinLFO yOffset = new SinLFO(-2*FEET, 2*FEET, 12000 + 5000*Math.random());
    
    public Ring(LX lx) {
      super(lx);
      startModulator(yRot.randomBasis());
      startModulator(zRot.randomBasis());
      startModulator(zAmp.randomBasis());
      startModulator(yOffset.randomBasis());
    }
    
    public void run(double deltaMs) {
      proj.reset().center().rotateY(yRot.getValuef()).rotateZ(amplitude.getValuef() * zAmp.getValuef() * zRot.getValuef());
      float yOffset = this.yOffset.getValuef();
      float falloff = 100 / (2*FEET);
      for (LXVector v : proj) {
        float b = 100 - falloff * abs(v.y - yOffset);  
        if (b > 0) {
          addColor(v.index, LXColor.gray(b));
        }
      }
    }
  }
}

@LXCategory("Pattern")
public static class RingsX extends EnvelopPattern {
  
  public final CompoundParameter amplitude =
    new CompoundParameter("Amplitude", 1);
    
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 10000, 20000, 1000)
    .setExponent(.25);
  
  public RingsX(LX lx) {
    super(lx);
    for (int i = 0; i < 2; ++i) {
      addLayer(new Ring(lx));
    }
    addParameter("amplitude", this.amplitude);
    addParameter("speed", this.speed);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
  
  class Ring extends LXLayer {
    
    private LXProjection proj = new LXProjection(model);
    private final SawLFO xRot = new SawLFO(0, TWO_PI, 9000 + 2000 * Math.random());
    private final SinLFO zRot = new SinLFO(-1, 1, speed);
    private final SinLFO zAmp = new SinLFO(PI / 10, PI/4, 13000 + 3000 * Math.random());
    private final SinLFO xOffset = new SinLFO(-2*FEET, 2*FEET, 12000 + 5000*Math.random());
    
    public Ring(LX lx) {
      super(lx);
      startModulator(xRot.randomBasis());
      startModulator(zRot.randomBasis());
      startModulator(zAmp.randomBasis());
      startModulator(xOffset.randomBasis());
    }
    
    public void run(double deltaMs) {
      proj.reset().center().rotateX(xRot.getValuef()).rotateZ(amplitude.getValuef() * zAmp.getValuef() * zRot.getValuef());
      float xOffset = this.xOffset.getValuef();
      float falloff = 100 / (2*FEET);
      for (LXVector v : proj) {
        float b = 100 - falloff * abs(v.x - xOffset);  
        if (b > 0) {
          addColor(v.index, LXColor.gray(b));
        }
      }
    }
  }
}


@LXCategory("Pattern")
public static final class SwarmAll extends EnvelopPattern {
  
  private static final double MIN_PERIOD = 200;
  
  public final CompoundParameter chunkSize =
    new CompoundParameter("Chunk", 10, 5, 20)
    .setDescription("Size of the swarm chunks");
  
  private final LXParameter chunkDamped = startModulator(new DampedParameter(this.chunkSize, 5, 5));
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1)
    .setDescription("Speed of the swarm motion");
    
  public final CompoundParameter oscillation =
    new CompoundParameter("Osc", 0)
    .setDescription("Amoount of oscillation of the swarm speed");
  
  private final FunctionalParameter minPeriod = new FunctionalParameter() {
    public double getValue() {
      return MIN_PERIOD / speed.getValue();
    }
  };
  
  private final FunctionalParameter maxPeriod = new FunctionalParameter() {
    public double getValue() {
      return MIN_PERIOD / (speed.getValue() + oscillation.getValue());
    }
  };
  
  private final SawLFO pos = new SawLFO(0, 1, startModulator(
    new SinLFO(minPeriod, maxPeriod, startModulator(
      new SinLFO(9000, 23000, 49000).randomBasis()
  )).randomBasis()));
  
  private final SinLFO swarmA = new SinLFO(0, 4*PI, startModulator(
    new SinLFO(37000, 79000, 51000)
  ));
  
  private final SinLFO swarmY = new SinLFO(
    startModulator(new SinLFO(model.yMin, model.cy, 19000).randomBasis()),
    startModulator(new SinLFO(model.cy, model.yMax, 23000).randomBasis()),
    startModulator(new SinLFO(14000, 37000, 19000))
  );
  
  private final SinLFO swarmSize = new SinLFO(.6, 1, startModulator(
    new SinLFO(7000, 19000, 11000)
  ));
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 1, 2, .5)
    .setDescription("Size of the overall swarm");
  
  public SwarmAll(LX lx) {
    super(lx);
    addParameter("chunk", this.chunkSize);
    addParameter("size", this.size);
    addParameter("speed", this.speed);
    addParameter("oscillation", this.oscillation);
    startModulator(this.pos.randomBasis());
    startModulator(this.swarmA);
    startModulator(this.swarmY);
    startModulator(this.swarmSize);
    setColors(#000000);
  }
 
  public void run(double deltaMs) {
    float chunkSize = this.chunkDamped.getValuef();
    float pos = this.pos.getValuef();
    float swarmA = this.swarmA.getValuef();
    float swarmY = this.swarmY.getValuef();
    float swarmSize = this.swarmSize.getValuef() * this.size.getValuef();
    
    for (Column column : model.columns) {
      int ri = 0;
      for (Rail rail : column.rails) {
        for (int i = 0; i < rail.points.length; ++i) {
          LXPoint p = rail.points[i];
          float f = (i % chunkSize) / chunkSize;
          if ((column.index + ri) % 3 == 2) {
            f = 1-f;
          }
          float fd = 40*LXUtils.wrapdistf(column.azimuth, swarmA, TWO_PI) + abs(p.y - swarmY);
          fd *= swarmSize;
          colors[p.index] = LXColor.gray(max(0, 100 - fd - (100 + fd) * LXUtils.wrapdistf(f, pos, 1)));
        }
        ++ri;
      }
    }
  }
}

@LXCategory("Pattern")
public static final class Swarm extends EnvelopPattern {
  
  private static final double MIN_PERIOD = 200;
  
  public final CompoundParameter chunkSize =
    new CompoundParameter("Chunk", 10, 5, 20)
    .setDescription("Size of the swarm chunks");
  
  private final LXParameter chunkDamped = startModulator(new DampedParameter(this.chunkSize, 5, 5));
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1)
    .setDescription("Speed of the swarm motion");
    
  public final CompoundParameter oscillation =
    new CompoundParameter("Osc", 0)
    .setDescription("Amoount of oscillation of the swarm speed");
  
  private final FunctionalParameter minPeriod = new FunctionalParameter() {
    public double getValue() {
      return MIN_PERIOD / speed.getValue();
    }
  };
  
  private final FunctionalParameter maxPeriod = new FunctionalParameter() {
    public double getValue() {
      return MIN_PERIOD / (speed.getValue() + oscillation.getValue());
    }
  };
  
  private final SawLFO pos = new SawLFO(0, 1, startModulator(
    new SinLFO(minPeriod, maxPeriod, startModulator(
      new SinLFO(9000, 23000, 49000).randomBasis()
  )).randomBasis()));
  
  private final SinLFO swarmA = new SinLFO(0, 4*PI, startModulator(
    new SinLFO(37000, 79000, 51000)
  ));
  
  private final SinLFO swarmY = new SinLFO(
    startModulator(new SinLFO(model.yMin, model.cy, 19000).randomBasis()),
    startModulator(new SinLFO(model.cy, model.yMax, 23000).randomBasis()),
    startModulator(new SinLFO(14000, 37000, 19000))
  );
  
  private final SinLFO swarmSize = new SinLFO(.6, 1, startModulator(
    new SinLFO(7000, 19000, 11000)
  ));
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 1, 2, .5)
    .setDescription("Size of the overall swarm");
  
  public Swarm(LX lx) {
    super(lx);
    addParameter("chunk", this.chunkSize);
    addParameter("size", this.size);
    addParameter("speed", this.speed);
    addParameter("oscillation", this.oscillation);
    startModulator(this.pos.randomBasis());
    startModulator(this.swarmA);
    startModulator(this.swarmY);
    startModulator(this.swarmSize);
    setColors(#000000);
  }
 
  public void run(double deltaMs) {
    float chunkSize = this.chunkDamped.getValuef();
    float pos = this.pos.getValuef();
    float swarmA = this.swarmA.getValuef();
    float swarmY = this.swarmY.getValuef();
    float swarmSize = this.swarmSize.getValuef() * this.size.getValuef();
    
    //for (Column column : model.columns) {
      for (Rail rail : model.rails) {
        int ri = 0;
        for (int i = 0; i < rail.points.length; ++i) {
          LXPoint p = rail.points[i];
          float f = (i % chunkSize) / chunkSize;
          if ((p.index + ri) % 3 == 2) {
            f = 1-f;
          }
          float fd = 40*LXUtils.wrapdistf(p.azimuth, swarmA, TWO_PI) + abs(p.y - swarmY);
          fd *= swarmSize;
          colors[p.index] = LXColor.gray(max(0, 100 - fd - (100 + fd) * LXUtils.wrapdistf(f, pos, 1)));
        }
        ++ri;
      }
    //}
  }
}

@LXCategory("Pattern")
public class Bugs extends EnvelopPattern {
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 10, 20, 1)
    .setDescription("Speed of the bugs");
  
  public final CompoundParameter size =
    new CompoundParameter("Size", .1, .02, .4)
    .setDescription("Size of the bugs");
  
  public Bugs(LX lx) {
    super(lx);
    for (Rail rail : model.rails) {
      for (int i = 0; i < 10; ++i) {
        addLayer(new Layer(lx, rail));
      }
    }
    addParameter("speed", this.speed);
    addParameter("size", this.size);
  }
  
  class RandomSpeed extends FunctionalParameter {
    
    private final float rand;
    
    RandomSpeed(float low, float hi) {
      this.rand = random(low, hi);
    }
    
    public double getValue() {
      return this.rand * speed.getValue();
    }
  }
  
  class Layer extends LXModelLayer<EnvelopModel> {
    
    private final Rail rail;
    private final LXModulator pos = startModulator(new SinLFO(
      startModulator(new SinLFO(0, .5, new RandomSpeed(500, 1000)).randomBasis()),
      startModulator(new SinLFO(.5, 1, new RandomSpeed(500, 1000)).randomBasis()),
      new RandomSpeed(3000, 8000)
    ).randomBasis());
    
    private final LXModulator size = startModulator(new SinLFO(
      startModulator(new SinLFO(.1, .3, new RandomSpeed(500, 1000)).randomBasis()),
      startModulator(new SinLFO(.5, 1, new RandomSpeed(500, 1000)).randomBasis()),
      startModulator(new SinLFO(4000, 14000, random(3000, 18000)).randomBasis())
    ).randomBasis());
    
    Layer(LX lx, Rail rail) {
      super(lx);
      this.rail = rail;
    }
    
    public void run(double deltaMs) {
      float size = Bugs.this.size.getValuef() * this.size.getValuef();
      float falloff = 100 / max(size, (1.5*INCHES / model.yRange));
      float pos = this.pos.getValuef();
      for (LXPoint p : this.rail.points) {
        float b = 100 - falloff * abs(p.yn - pos);
        if (b > 0) {
          addColor(p.index, LXColor.gray(b));
        }
      }
    }
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  }
}
//..................
// Additional Patterns
//..................

@LXCategory("Pattern")
  // Defines the pattern
  public static class SawRings extends EnvelopPattern {
  //sets the knob; the variables are defined as (default, min, max)
  //leaving out the min and max defaults to 0 to 1 range
  public final CompoundParameter amplitude =
    new CompoundParameter("Rotation", 0);

  //knob for rotational speed  
  public final CompoundParameter ROTspeed = (CompoundParameter)
    new CompoundParameter("RSpeed", 10000, 20000, 1000)
    .setExponent(.25);

  //Knob for Y speed  
  public final CompoundParameter Yspeed = (CompoundParameter)
    new CompoundParameter("YSpeed", 10000, 40000, 1000)
    .setExponent(.25);  

  public final CompoundParameter thickness = (CompoundParameter)
    new CompoundParameter("Thickness", 40, 0, 100) 
    .setExponent(4.0);  

  public final CompoundParameter SawMin =
    new CompoundParameter("SawMin", -20 *FEET, -40*FEET, 40*FEET);    

  public final CompoundParameter SawMax =
    new CompoundParameter("SawMax", 20*FEET, -40*FEET, 40*FEET);  

  //defines number of rings; the original stated 2 but 1 looks better for this
  public SawRings(LX lx) {
    super(lx);
    for (int i = 0; i < 1; ++i) {
      addLayer(new Ring(lx));
    }
    addParameter("Rotation", this.amplitude);
    addParameter("ROT speed", this.ROTspeed);
    addParameter("Y speed", this.Yspeed);
    addParameter("Thickness", this.thickness);
    addParameter("SawMin", this.SawMin);
    addParameter("SawMax", this.SawMax);
  }

  //sets color in background Hex #000000 is Black
  public void run(double deltaMs) {
    setColors(#000000);
  }

  //defines the class Ring which is what is added to Rings in the above code
  class Ring extends LXLayer {

    private LXProjection proj = new LXProjection(model);
    // y rotation SawLFO(start value, endvalue, period)
    private final SinLFO yRot = new SinLFO(0, TWO_PI, 9000 + 2000 * Math.random());
    // z rotation SinLFO(start value, endvalue, period)
    private final SinLFO zRot = new SinLFO(-1, 1, ROTspeed);
    // z amplitude
    //private final SinLFO zAmp = new SinLFO(0.5, .5, 13000 + 3000 * Math.random());
    private final SinLFO zAmp = new SinLFO(PI / 10, PI/4, 13000 + 3000 * Math.random());
    //y offset
    //private final SinLFO yOffset = new SinLFO(-2*FEET, 2*FEET, 12000 + 5000*Math.random());
    //private final SawLFO yOffset = new SawLFO(SawMin, SawMax, Yspeed);
    private final SinLFO yOffset = new SinLFO(SawMin, SawMax, Yspeed);

    public Ring(LX lx) {
      super(lx);
      startModulator(yRot.randomBasis());
      startModulator(zRot.randomBasis());
      startModulator(zAmp.randomBasis());
      startModulator(yOffset.randomBasis());
    }

    public void run(double deltaMs) {
      proj.reset().center().rotateY(yRot.getValuef()).rotateZ(amplitude.getValuef() * zAmp.getValuef() * zRot.getValuef());
      float yOffset = this.yOffset.getValuef();
      float falloff = thickness.getValuef();//40; //100 / (2*FEET);
      for (LXVector v : proj) {
        float b = 100 - falloff * abs(v.y - yOffset);  
        if (b > 0) {
          addColor(v.index, LXColor.gray(b));
        }
      }
    }
  }
}

@LXCategory("Pattern")
  // Defines the pattern
  public static class SawRingsX extends EnvelopPattern {
  //sets the knob; the variables are defined as (default, min, max)
  //leaving out the min and max defaults to 0 to 1 range
  public final CompoundParameter amplitude =
    new CompoundParameter("Rotation", 0);

  //knob for rotational speed  
  public final CompoundParameter ROTspeed = (CompoundParameter)
    new CompoundParameter("RSpeed", 10000, 20000, 1000)
    .setExponent(.25);

  //Knob for Y speed  
  public final CompoundParameter Xspeed = (CompoundParameter)
    new CompoundParameter("XSpeed", 10000, 40000, 1000)
    .setExponent(.25);  

  public final CompoundParameter thickness = (CompoundParameter)
    new CompoundParameter("Thickness", 40, 0, 100) 
    .setExponent(4.0);  

  public final CompoundParameter SawMin =
    new CompoundParameter("SawMin", -20 *FEET, -40*FEET, 40*FEET);    

  public final CompoundParameter SawMax =
    new CompoundParameter("SawMax", 20*FEET, -40*FEET, 40*FEET);  
    
  //Knob for Number of Rings
  //public final DiscreteParameter numRings = 
 //  new DiscreteParameter("numRings",1,1,10);
    
  //defines number of rings; the original stated 2 but 1 looks better for this
  public SawRingsX(LX lx) {
    super(lx);
    for (int i = 0; i < 1; ++i) {
      addLayer(new Ring(lx));
    }
    addParameter("Rotation", this.amplitude);
    addParameter("ROT speed", this.ROTspeed);
    addParameter("X speed", this.Xspeed);
    addParameter("Thickness", this.thickness);
    addParameter("SawMin", this.SawMin);
    addParameter("SawMax", this.SawMax);
    //addParameter("numRings", this.numRings);
  }

  //sets color in background Hex #000000 is Black
  public void run(double deltaMs) {
    setColors(#000000);
  }

  //defines the class Ring which is what is added to Rings in the above code
  class Ring extends LXLayer {

    private LXProjection proj = new LXProjection(model);
    // y rotation SawLFO(start value, endvalue, period)
    private final SinLFO xRot = new SinLFO(0, TWO_PI, 9000 + 2000 * Math.random());
    // z rotation SinLFO(start value, endvalue, period)
    private final SinLFO zRot = new SinLFO(-1, 1, ROTspeed);
    // z amplitude
    //private final SinLFO zAmp = new SinLFO(0.5, .5, 13000 + 3000 * Math.random());
    private final SinLFO zAmp = new SinLFO(PI / 10, PI/4, 13000 + 3000 * Math.random());
    //y offset
   // private final SinLFO xOffset = new SinLFO(SawMin, SawMin, Xspeed);
   //private final SinLFO xOffset = new SinLFO(SawMin, SawMin, 12000 + 5000*Math.random());
   ///code for saw tooth
   private final SinLFO xOffset = new SinLFO(SawMin, SawMax, Xspeed);

    public Ring(LX lx) {
      super(lx);
      startModulator(xRot.randomBasis());
      startModulator(zRot.randomBasis());
      startModulator(zAmp.randomBasis());
      startModulator(xOffset.randomBasis());
    }

    public void run(double deltaMs) {
      proj.reset().center().rotateX(xRot.getValuef()).rotateZ(amplitude.getValuef() * zAmp.getValuef() * zRot.getValuef());
      float xOffset = this.xOffset.getValuef();
      float falloff = thickness.getValuef();//40; //100 / (2*FEET);
      for (LXVector v : proj) {
        float b = 100 - falloff * abs(v.x - xOffset);  
        if (b > 0) {
          addColor(v.index, LXColor.gray(b));
        }
      }
    }
  }
}

@LXCategory("Pattern")
public class Clouds extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter thickness =
    new CompoundParameter("Thickness", 50, 100, 0)
    .setDescription("Thickness of the cloud formation");
  
  public final CompoundParameter xSpeed = (CompoundParameter)
    new CompoundParameter("XSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the X axis");

  public final CompoundParameter ySpeed = (CompoundParameter)
    new CompoundParameter("YSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the Y axis");
    
  public final CompoundParameter zSpeed = (CompoundParameter)
    new CompoundParameter("ZSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the Z axis");
    
  public final CompoundParameter scale = (CompoundParameter)
    new CompoundParameter("Scale", 3, .25, 10)
    .setDescription("Scale of the clouds")
    .setExponent(2);

  public final CompoundParameter xScale =
    new CompoundParameter("XScale", 0, 0, 10)
    .setDescription("Scale along the X axis");

  public final CompoundParameter yScale =
    new CompoundParameter("YScale", 0, 0, 10)
    .setDescription("Scale along the Y axis");
    
  public final CompoundParameter zScale =
    new CompoundParameter("ZScale", 0, 0, 10)
    .setDescription("Scale along the Z axis");
    
  private float xBasis = 0, yBasis = 0, zBasis = 0;
    
  public Clouds(LX lx) {
    super(lx);
    addParameter("thickness", this.thickness);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("scale", this.scale);
    addParameter("xScale", this.xScale);
    addParameter("yScale", this.yScale);
    addParameter("zScale", this.zScale);
  }

  private static final double MOTION = .0005;

  public void run(double deltaMs) {
    this.xBasis -= deltaMs * MOTION * this.xSpeed.getValuef();
    this.yBasis -= deltaMs * MOTION * this.ySpeed.getValuef();
    this.zBasis -= deltaMs * MOTION * this.zSpeed.getValuef();
    float thickness = this.thickness.getValuef();
    float scale = this.scale.getValuef();
    float xScale = this.xScale.getValuef();
    float yScale = this.yScale.getValuef();
    float zScale = this.zScale.getValuef();
    
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;
    
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
        float nv = noise(
          (scale + p.xn * xScale) * p.xn + this.xBasis,
          (scale + p.yn * yScale) * p.yn + this.yBasis, 
          (scale + p.zn * zScale) * p.zn + this.zBasis
        );
        final_num = (strandnum *64) + pixnum;
        //println(final_num);
        colors[final_num]= LXColor.gray(constrain(-thickness + (150 + thickness) * nv, 0, 100)); //(setColor(strand, LXColor.lerp(c1, c2, lerp));
        ++pixnum;
        }
      }
    }
  }  
}

@LXCategory("Pattern")
public class Waves extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  final int NUM_LAYERS = 3;
  
  final float AMP_DAMPING_V = 1.5;
  final float AMP_DAMPING_A = 2.5;
  
  final float LEN_DAMPING_V = 1.5;
  final float LEN_DAMPING_A = 1.5;

  public final CompoundParameter rate = (CompoundParameter)
    new CompoundParameter("Rate", 6000, 48000, 2000)
    .setDescription("Rate of the of the wave motion")
    .setExponent(.3);

  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 6*INCHES, 28*FEET)
    .setDescription("Width of the wave");
    
  public final CompoundParameter amp1 =
    new CompoundParameter("Amp1", .5, 2, .2)
    .setDescription("First modulation size");
        
  public final CompoundParameter amp2 =
    new CompoundParameter("Amp2", 1.4, 2, .2)
    .setDescription("Second modulation size");
    
  public final CompoundParameter amp3 =
    new CompoundParameter("Amp3", .5, 2, .2)
    .setDescription("Third modulation size");
    
  public final CompoundParameter len1 =
    new CompoundParameter("Len1", 1, 2, .2)
    .setDescription("First wavelength size");
    
  public final CompoundParameter len2 =
    new CompoundParameter("Len2", .8, 2, .2)
    .setDescription("Second wavelength size");
    
  public final CompoundParameter len3 =
    new CompoundParameter("Len3", 1.5, 2, .2)
    .setDescription("Third wavelength size");
    
  private final LXModulator phase =
    startModulator(new SawLFO(0, TWO_PI, rate));
    
  private final LXModulator amp1Damp = startModulator(new DampedParameter(this.amp1, AMP_DAMPING_V, AMP_DAMPING_A));
  private final LXModulator amp2Damp = startModulator(new DampedParameter(this.amp2, AMP_DAMPING_V, AMP_DAMPING_A));
  private final LXModulator amp3Damp = startModulator(new DampedParameter(this.amp3, AMP_DAMPING_V, AMP_DAMPING_A));
  
  private final LXModulator len1Damp = startModulator(new DampedParameter(this.len1, LEN_DAMPING_V, LEN_DAMPING_A));
  private final LXModulator len2Damp = startModulator(new DampedParameter(this.len2, LEN_DAMPING_V, LEN_DAMPING_A));
  private final LXModulator len3Damp = startModulator(new DampedParameter(this.len3, LEN_DAMPING_V, LEN_DAMPING_A));  

  private final LXModulator sizeDamp = startModulator(new DampedParameter(this.size, 40*FEET, 80*FEET));

  private final double[] bins = new double[512];

  public Waves(LX lx) {
    super(lx);
    addParameter("rate", this.rate);
    addParameter("size", this.size);
    addParameter("amp1", this.amp1);
    addParameter("amp2", this.amp2);
    addParameter("amp3", this.amp3);
    addParameter("len1", this.len1);
    addParameter("len2", this.len2);
    addParameter("len3", this.len3);
  }

  public void run(double deltaMs) {
    double phaseValue = phase.getValue();
    float amp1 = this.amp1Damp.getValuef();
    float amp2 = this.amp2Damp.getValuef();
    float amp3 = this.amp3Damp.getValuef();
    float len1 = this.len1Damp.getValuef();
    float len2 = this.len2Damp.getValuef();
    float len3 = this.len3Damp.getValuef();    
    float falloff = 100 / this.sizeDamp.getValuef();
    
    for (int i = 0; i < bins.length; ++i) {
      bins[i] = model.cy + model.yRange/2 * Math.sin(i * TWO_PI / bins.length + phaseValue);
    }
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;
    
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      int idx = Math.round((bins.length-1) * (len1 * p.xn)) % bins.length;
      int idx2 = Math.round((bins.length-1) * (len2 * (.2 + p.xn))) % bins.length;
      int idx3 = Math.round((bins.length-1) * (len3 * (1.7 - p.xn))) % bins.length; 
      
      float y1 = (float) bins[idx];
      float y2 = (float) bins[idx2];
      float y3 = (float) bins[idx3];
      
      float d1 = abs(rail.cy*amp1 - y1);
      float d2 = abs(rail.cy*amp2 - y2);
      float d3 = abs(rail.cy*amp3 - y3);
      
      float b = max(0, 100 - falloff * min(min(d1, d2), d3));      
      //setColor(strand, b > 0 ? LXColor.gray(b) : #000000);
      final_num = (strandnum *64) + pixnum;
      if(b>0){
      colors[final_num]= LXColor.gray(b); 
      } else {
      colors[final_num]= #000000;  
      }  
      ++pixnum;
        }
      } 
    }
  }
}

@LXCategory("Pattern")
public class Borealis extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1)
    .setDescription("Speed of motion");
  
  public final CompoundParameter scale =
    new CompoundParameter("Scale", .5, .1, 1)
    .setDescription("Scale of lights");
  
  public final CompoundParameter spread =
    new CompoundParameter("Spread", 6, .1, 10)
    .setDescription("Spreading of the motion");
  
  public final CompoundParameter base =
    new CompoundParameter("Base", .5, .2, 1)
    .setDescription("Base brightness level");
    
  public final CompoundParameter contrast =
    new CompoundParameter("Contrast", 1, .5, 2)
    .setDescription("Contrast of the lights");    
  
  public Borealis(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("scale", this.scale);
    addParameter("spread", this.spread);
    addParameter("base", this.base);
    addParameter("contrast", this.contrast);
  }
  
  private float yBasis = 0;
  
  public void run(double deltaMs) {
    this.yBasis -= deltaMs * .0005 * this.speed.getValuef();
    float scale = this.scale.getValuef();
    float spread = this.spread.getValuef();
    float base = .01 * this.base.getValuef();
    float contrast = this.contrast.getValuef();
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      float nv = noise(
        scale * (base * p.rxz - spread * p.yn),
        p.yn + this.yBasis
      );
      final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(constrain(contrast * (-50 + 180 * nv), 0, 100)); 
      ++pixnum;
      }
     }
    }
  }
}

@LXCategory("Pattern")
public class Tumbler extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private LXModulator azimuthRotation = startModulator(new SawLFO(0, 1, 15000).randomBasis());
  private LXModulator thetaRotation = startModulator(new SawLFO(0, 1, 13000).randomBasis());
  
  public Tumbler(LX lx) {
    super(lx);
  }
  
  
  public void run(double deltaMs) {
    float azimuthRotation = this.azimuthRotation.getValuef();
    float thetaRotation = this.thetaRotation.getValuef();
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      float tri1 = LXUtils.trif(azimuthRotation + p.azimuth / PI);
      float tri2 = LXUtils.trif(thetaRotation + (PI + p.theta) / PI);
      float tri = max(tri1, tri2);
      final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(100 * tri * tri); 
      ++pixnum;
      }
     }
    }
  }
}

@LXCategory("Pattern")
public class Lattice extends EnvelopPattern {

  public final double MAX_RIPPLES_TREAT_AS_INFINITE = 2000.0;
  
  public final CompoundParameter rippleRadius =
    new CompoundParameter("Ripple radius", 500.0, 200.0, MAX_RIPPLES_TREAT_AS_INFINITE)
    .setDescription("Controls the spacing between ripples");

  public final CompoundParameter subdivisionSize =
    new CompoundParameter("Subdivision size", MAX_RIPPLES_TREAT_AS_INFINITE, 200.0, MAX_RIPPLES_TREAT_AS_INFINITE)
    .setDescription("Subdivides the canvas into smaller canvases of this size");

  public final CompoundParameter numSpirals =
    new CompoundParameter("Spirals", 0, -3, 3)
    .setDescription("Adds a spiral effect");

  public final CompoundParameter yFactor =
    new CompoundParameter("Y factor")
    .setDescription("How much Y is taken into account");

  public final CompoundParameter manhattanCoefficient =
    new CompoundParameter("Square")
    .setDescription("Whether the rippes should be circular or square");

  public final CompoundParameter triangleCoefficient =
    new CompoundParameter("Triangle coeff")
    .setDescription("Whether the wave resembles a sawtooth or a triangle");

  public final CompoundParameter visibleAmount =
    new CompoundParameter("Visible", 1.0, 0.1, 1.0)
    .setDescription("Whether the full wave is visible or only the peaks");

  public Lattice(LX lx) {
    super(lx);
    addParameter(rippleRadius);
    addParameter(subdivisionSize);
    addParameter(numSpirals);
    addParameter(yFactor);
    addParameter(manhattanCoefficient);
    addParameter(triangleCoefficient);
    addParameter(visibleAmount);
  }
  
  private double _modAndShiftToHalfZigzag(double dividend, double divisor) {
    double mod = (dividend + divisor) % divisor;
    double value = (mod > divisor / 2) ? (mod - divisor) : mod;
    int quotient = (int) (dividend / divisor);
    return (quotient % 2 == 0) ? -value : value;
  }
  
  private double _calculateDistance(Rail rail) {
    double x = rail.cx;
    double y = rail.cy * this.yFactor.getValue();
    double z = rail.cz;
    
    double subdivisionSizeValue = subdivisionSize.getValue();
    if (subdivisionSizeValue < MAX_RIPPLES_TREAT_AS_INFINITE) {
      x = _modAndShiftToHalfZigzag(x, subdivisionSizeValue);
      y = _modAndShiftToHalfZigzag(y, subdivisionSizeValue);
      z = _modAndShiftToHalfZigzag(z, subdivisionSizeValue);
    }
        
    double manhattanDistance = (Math.abs(x) + Math.abs(y) + Math.abs(z)) / 1.5;
    double euclideanDistance = Math.sqrt(x * x + y * y + z * z);
    return LXUtils.lerp(euclideanDistance, manhattanDistance, manhattanCoefficient.getValue());
  }
  
   private double _calculateParDistance(Par par) {
    double x = par.cx;
    double y = par.cy * this.yFactor.getValue();
    double z = par.cz;
    
    double subdivisionSizeValue = subdivisionSize.getValue();
    if (subdivisionSizeValue < MAX_RIPPLES_TREAT_AS_INFINITE) {
      x = _modAndShiftToHalfZigzag(x, subdivisionSizeValue);
      y = _modAndShiftToHalfZigzag(y, subdivisionSizeValue);
      z = _modAndShiftToHalfZigzag(z, subdivisionSizeValue);
    }
        
    double manhattanDistance = (Math.abs(x) + Math.abs(y) + Math.abs(z)) / 1.5;
    double euclideanDistance = Math.sqrt(x * x + y * y + z * z);
    return LXUtils.lerp(euclideanDistance, manhattanDistance, manhattanCoefficient.getValue());
  }

  public void run(double deltaMs) {
    // add an arbitrary number of beats so refreshValueModOne isn't negative;
    // divide by 4 so you get one ripple per measure
    double ticksSoFar = (lx.tempo.beatCount() + lx.tempo.ramp() + 256) / 4;

    double rippleRadiusValue = rippleRadius.getValue();
    double triangleCoefficientValueHalf = triangleCoefficient.getValue() / 2;
    double visibleAmountValueMultiplier = 1 / visibleAmount.getValue();
    double visibleAmountValueToSubtract = visibleAmountValueMultiplier - 1;
    double numSpiralsValue = Math.round(numSpirals.getValue());

    // Let's iterate over all the leaves...
    int pixnum = 0;
    //int strandnum = 0;
    //int final_num = 0;  
     for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      double totalDistance = _calculateDistance(rail);
      double rawRefreshValueFromDistance = totalDistance / rippleRadiusValue;
      double rawRefreshValueFromSpiral = Math.atan2(p.z, p.x) * numSpiralsValue / (2 * Math.PI);

      double refreshValueModOne = (ticksSoFar - rawRefreshValueFromDistance - rawRefreshValueFromSpiral) % 1.0;
      double brightnessValueBeforeVisibleCheck = (refreshValueModOne >= triangleCoefficientValueHalf) ?
        1 - (refreshValueModOne - triangleCoefficientValueHalf) / (1 - triangleCoefficientValueHalf) :
        (refreshValueModOne / triangleCoefficientValueHalf);

      double brightnessValue = brightnessValueBeforeVisibleCheck * visibleAmountValueMultiplier - visibleAmountValueToSubtract;
     //  final_num = (strandnum *64) + pixnum;
       
      
      if (brightnessValue > 0) {
        colors[pixnum]= LXColor.gray((float) brightnessValue * 100); 
      } else {
        colors[pixnum]=  #000000;
      }
      ++pixnum;
      } 
     }
    }
    for (ParCan parcan : venue.parcans) {
      for (Par par : parcan.pars) {
          for (LXPoint p : par.points) {
        double totalDistance = _calculateParDistance(par);
        double rawRefreshValueFromDistance = totalDistance / rippleRadiusValue;
        double rawRefreshValueFromSpiral = Math.atan2(p.z, p.x) * numSpiralsValue / (2 * Math.PI);
  
        double refreshValueModOne = (ticksSoFar - rawRefreshValueFromDistance - rawRefreshValueFromSpiral) % 1.0;
        double brightnessValueBeforeVisibleCheck = (refreshValueModOne >= triangleCoefficientValueHalf) ?
          1 - (refreshValueModOne - triangleCoefficientValueHalf) / (1 - triangleCoefficientValueHalf) :
          (refreshValueModOne / triangleCoefficientValueHalf);
  
        double brightnessValue = brightnessValueBeforeVisibleCheck * visibleAmountValueMultiplier - visibleAmountValueToSubtract;
         
         
        
        if (brightnessValue > 0) {
          colors[pixnum]= LXColor.gray((float) brightnessValue * 100); 
        } else {
          colors[pixnum]=  #000000;
        }
        ++pixnum;
        } 
       }
      }
  }
}


// More Tenere Patterns
@LXCategory("Pattern")
public class AxisPlanes extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter xSpeed = new CompoundParameter("XSpd", 19000, 31000, 5000).setDescription("Speed of motion on X-axis");
  public final CompoundParameter ySpeed = new CompoundParameter("YSpd", 13000, 31000, 5000).setDescription("Speed of motion on Y-axis");
  public final CompoundParameter zSpeed = new CompoundParameter("ZSpd", 17000, 31000, 5000).setDescription("Speed of motion on Z-axis");
  
  public final CompoundParameter xSize = new CompoundParameter("XSize", .1, .05, .3).setDescription("Size of X scanner");
  public final CompoundParameter ySize = new CompoundParameter("YSize", .1, .05, .3).setDescription("Size of Y scanner");
  public final CompoundParameter zSize = new CompoundParameter("ZSize", .1, .05, .3).setDescription("Size of Z scanner");
  
  private final LXModulator xPos = startModulator(new SinLFO(0, 1, this.xSpeed).randomBasis());
  private final LXModulator yPos = startModulator(new SinLFO(0, 1, this.ySpeed).randomBasis());
  private final LXModulator zPos = startModulator(new SinLFO(0, 1, this.zSpeed).randomBasis());
  
  public AxisPlanes(LX lx) {
    super(lx);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("xSize", this.xSize);
    addParameter("ySize", this.ySize);
    addParameter("zSize", this.zSize);
  }
  
  public void run(double deltaMs) {
    float xPos = this.xPos.getValuef();
    float yPos = this.yPos.getValuef();
    float zPos = this.zPos.getValuef();
    float xFalloff = 100 / this.xSize.getValuef();
    float yFalloff = 100 / this.ySize.getValuef();
    float zFalloff = 100 / this.zSize.getValuef();
    
  int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
    //for (Leaf leaf : model.leaves) {
      float b = max(max(
        100 - xFalloff * abs(p.xn - xPos),
        100 - yFalloff * abs(p.yn - yPos)),
        100 - zFalloff * abs(p.zn - zPos)
      );

      final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(max(0, b)); 
      ++pixnum;
      }
     } 
    }
  }
}

@LXCategory("Pattern")
public class Scanner extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Speed that the plane moves at");
    
  public final CompoundParameter sharp = (CompoundParameter)
    new CompoundParameter("Sharp", 0, -50, 150)
    .setDescription("Sharpness of the falling plane")
    .setExponent(2);
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlope", 0, -1, 1)
    .setDescription("Slope on the X-axis");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlope", 0, -1, 1)
    .setDescription("Slope on the Z-axis");
  
  private float basis = 0;
  
  public Scanner(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("sharp", this.sharp);
    addParameter("xSlope", this.xSlope);
    addParameter("zSlope", this.zSlope);
  }
  
  public void run(double deltaMs) {
    float speed = this.speed.getValuef();
    speed = speed * speed * ((speed < 0) ? -1 : 1);
    float sharp = this.sharp.getValuef();
    float xSlope = this.xSlope.getValuef();
    float zSlope = this.zSlope.getValuef();
    this.basis = (float) (this.basis - .001 * speed * deltaMs) % 1.;
     int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      
     final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(max(0, 50 - sharp + (50 + sharp) * LXUtils.trif(p.yn + this.basis + (p.xn-.5) * xSlope + (p.zn-.5) * zSlope))); 
      ++pixnum;
      }
     } 
    }
  }
}

@LXCategory("Pattern")
public abstract class SpinningPattern extends EnvelopPattern {
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 17000, 49000, 5000)
    .setExponent(2)
    .setDescription("Speed of lighthouse motion");
        
  public final BooleanParameter reverse =
    new BooleanParameter("Reverse", false)
    .setDescription("Reverse the direction of spinning");
        
  protected final SawLFO azimuth = (SawLFO) startModulator(new SawLFO(0, TWO_PI, speed));
    
  public SpinningPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("reverse", this.reverse);
  }
  
  public void onParameterChanged(LXParameter p) {
    if (p == this.reverse) {
      float start = this.reverse.isOn() ? TWO_PI : 0;
      float end = TWO_PI - start;
      double basis = this.azimuth.getBasis();
      this.azimuth.setRange(start, end).setBasis(1 - basis); 
    }
  }
}

@LXCategory("Pattern")
public class GentleSpin extends SpinningPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public GentleSpin(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    float azimuth = this.azimuth.getValuef();
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
     
      float az = (p.azimuth + azimuth + abs(p.yn - .5) * QUARTER_PI) % TWO_PI;
      
      final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(max(0, 100 - 40 * abs(az - PI))); 
      ++pixnum;
      }
     } 
    }
  }
}


@LXCategory("Pattern")
public abstract class BufferPattern extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speedRaw = (CompoundParameter)
    new CompoundParameter("Speed", 256, 2048, 64)
    .setExponent(.5)
    .setDescription("Speed of the wave propagation");
  
  public final LXModulator speed = startModulator(new DampedParameter(speedRaw, 256, 512));
  
  private static final int BUFFER_SIZE = 4096;
  protected int[] history = new int[BUFFER_SIZE];
  protected int cursor = 0;

  public BufferPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speedRaw);
    for (int i = 0; i < this.history.length; ++i) {
      this.history[i] = #000000;
    }
  }
  
  public final void run(double deltaMs) {
    // Add to history
    if (--this.cursor < 0) {
      this.cursor = this.history.length - 1;
    }
    this.history[this.cursor] = getColor();
    onRun(deltaMs);
  }
  
  protected int getColor() {
    return LXColor.gray(100 * getLevel());
  }
  
  protected float getLevel() {
    return 0;
  }
  
  abstract void onRun(double deltaMs); 
}

@LXCategory("Pattern")
public abstract class Melt extends BufferPattern {
  
  private final float[] multipliers = new float[32];
  
  public final CompoundParameter level =
    new CompoundParameter("Level", 0)
    .setDescription("Level of the melting effect");
  
  public final BooleanParameter auto =
    new BooleanParameter("Auto", true)
    .setDescription("Automatically make content");
  
    public final CompoundParameter melt =
    new CompoundParameter("Melt", .5)
    .setDescription("Amount of melt distortion");
  
  private final LXModulator meltDamped = startModulator(new DampedParameter(this.melt, 2, 2, 1.5));
  private LXModulator rot = startModulator(new SawLFO(0, 1, 39000)); 
  private LXModulator autoLevel = startModulator(new TriangleLFO(-.5, 1, startModulator(new SinLFO(3000, 7000, 19000))));
  
  public Melt(LX lx) {
    super(lx);
    addParameter("level", this.level);
    addParameter("auto", this.auto);
    addParameter("melt", this.melt);
    for (int i = 0; i < this.multipliers.length; ++i) {
      float r = random(.6, 1);
      this.multipliers[i] = r * r * r;
    }
  }
  
  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float rot = this.rot.getValuef();
    float melt = this.meltDamped.getValuef();
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      float az = p.azimuth;
      float maz = (az / TWO_PI + rot) * this.multipliers.length;
      float lerp = maz % 1;
      int floor = (int) (maz - lerp);
      float m = lerp(1, lerp(this.multipliers[floor % this.multipliers.length], this.multipliers[(floor + 1) % this.multipliers.length], lerp), melt);      
      float d = getDist(p);
      int offset = round(d * speed * m); 
      final_num = (strandnum *64) + pixnum;
      colors[final_num]= this.history[(this.cursor + offset) % this.history.length]; 
      ++pixnum;
      }
     } 
    }
  }


  
  protected abstract float getDist(LXPoint p);
  
  public float getLevel() {
    if (this.auto.isOn()) {
      float autoLevel = this.autoLevel.getValuef();
      if (autoLevel > 0) {
        return pow(autoLevel, .5);
      }
      return 0;
    }
    return this.level.getValuef();
  }
}
@LXCategory("Pattern")
public class MeltDown extends Melt {
  public MeltDown(LX lx) {
    super(lx);
  }
  
  protected float getDist(LXPoint p) {
    return 1 - p.yn;
  }
}

@LXCategory("Pattern")
public class MeltUp extends Melt {
  public MeltUp(LX lx) {
    super(lx);
  }
  
  protected float getDist(LXPoint p) {
    return p.yn;
  }
  
}

@LXCategory("Pattern")
public class MeltOut extends Melt {
  public MeltOut(LX lx) {
    super(lx);
  }
  
  protected float getDist(LXPoint p) {
    return 2*abs(p.yn - .5);
  }
}
@LXCategory("Pattern")
public class AzimuthSpin extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee Edited by Tom Montagliano";
  }
  private final CompoundParameter az = (CompoundParameter)
    new CompoundParameter("Azimuth", 0., 0. , TWO_PI)
    .setDescription("Azimuth in Degrees");
  private final CompoundParameter xtest = (CompoundParameter)
    new CompoundParameter("xtest", 100., 0., 1000.)
    .setDescription("X Test");
  private final CompoundParameter ztest = (CompoundParameter)
    new CompoundParameter("ztest", 40., 0., 1000.)
    .setDescription("Z Test"); 
    
  public AzimuthSpin(LX lx) {
    super(lx);
    addParameter("azimuth", this.az);
    addParameter("x", this.xtest);
    addParameter("z", this.ztest);
  }
  
  public void run(double deltaMs) {
    float azimuth = this.az.getValuef();
    float x = this.xtest.getValuef();
    float z = this.ztest.getValuef();
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;  
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
     
      float az = (p.azimuth + azimuth + abs(p.yn - .5) * QUARTER_PI) % TWO_PI;
      
      final_num = (strandnum *64) + pixnum;
      colors[final_num]= LXColor.gray(max(0, x - z * abs(az - PI))); 
      ++pixnum;
      }
     } 
    }
  }
}
/*
public class ParCansColor extends EnvelopPattern {
  public ParCansColor(LX lx) {
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
*/
/*
public static class ParCansColor extends LXPattern {
  
  final CompoundParameter hue = new CompoundParameter("Hue", 0, 0, 360);
  final CompoundParameter saturation = new CompoundParameter("Saturation", 100, 0, 100);
  final CompoundParameter brightness = new CompoundParameter("Brightness", 100, 0, 100);
  
  public ParCansColor(LX lx) {
    super(lx);
    addParameter(brightness);
    addParameter(hue);
    addParameter(saturation);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.railPoints) {
      colors[p.index] = LXColor.hsb( hue.getValuef() , saturation.getValuef(),brightness.getValuef());
    }
  }
}
*/




//New patterns I added since I learned better how to code better
@LXCategory("Pattern")
public class Vortex extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  //variable declarations
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 2000, 9000, 300)
    .setExponent(.5)
    .setDescription("Speed of vortex motion");
  
  public final CompoundParameter size =
    new CompoundParameter("Size",  4*FEET, 1*FEET, 10*FEET)
    .setDescription("Size of vortex");
  
  public final CompoundParameter xPos = (CompoundParameter)
    new CompoundParameter("XPos", model.cx, model.xMin, model.xMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-position of vortex center");
    
  public final CompoundParameter yPos = (CompoundParameter)
    new CompoundParameter("YPos", model.cy, model.yMin, model.yMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-position of vortex center");
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlp", .2, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-slope of vortex center");
    
  public final CompoundParameter ySlope = (CompoundParameter)
    new CompoundParameter("YSlp", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-slope of vortex center");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlp", .3, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Z-slope of vortex center");
  
  private final LXModulator pos = startModulator(new SawLFO(1, 0, this.speed));
  
  private final LXModulator sizeDamped = startModulator(new DampedParameter(this.size, 5*FEET, 8*FEET));
  private final LXModulator xPosDamped = startModulator(new DampedParameter(this.xPos, model.xRange, 3*model.xRange));
  private final LXModulator yPosDamped = startModulator(new DampedParameter(this.yPos, model.yRange, 3*model.yRange));
  private final LXModulator xSlopeDamped = startModulator(new DampedParameter(this.xSlope, 3, 6));
  private final LXModulator ySlopeDamped = startModulator(new DampedParameter(this.ySlope, 3, 6));
  private final LXModulator zSlopeDamped = startModulator(new DampedParameter(this.zSlope, 3, 6));

  //contructor method and instance variables
  public Vortex(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    addParameter("xPos", this.xPos);
    addParameter("yPos", this.yPos);
    addParameter("xSlope", this.xSlope);
    addParameter("ySlope", this.ySlope);
    addParameter("zSlope", this.zSlope);
  }
  
  //run method
  public void run(double deltaMs) {
    final float xPos = this.xPosDamped.getValuef();
    final float yPos = this.yPosDamped.getValuef();
    final float size = this.sizeDamped.getValuef();
    final float pos = this.pos.getValuef();
    
    final float xSlope = this.xSlopeDamped.getValuef();
    final float ySlope = this.ySlopeDamped.getValuef();
    final float zSlope = this.zSlopeDamped.getValuef();

    float dMult = 2 / size;
    for (Rail rail : venue.rails) {
      for(LXPoint p : rail.points){
        float radix = abs((xSlope*abs(p.x - model.cx) + ySlope*abs(p.y -model.cy) + zSlope*abs(p.z - model.cz)));
        float dist = dist(p.x, p.y, xPos, yPos); 
        //float falloff = 100 / max(20*INCHES, 2*size - .5*dist);
        //float b = 100 - falloff * LXUtils.wrapdistf(radix, pos * size, size);
        float b = abs(((dist + radix + pos * size) % size) * dMult - 1);
        setColor(p.index, (b > 0) ? LXColor.gray(b*b*100) : #000000);
      }
    }
  }
}

@LXCategory("Pattern")
public class SunriseSunset extends LXPattern {
  BoundedParameter dayTime = new BoundedParameter("DAY", 24000, 10000, 240000);
  LXProjection projection = new LXProjection(model);  
  SawLFO sunPosition = new SawLFO(0, TWO_PI, dayTime);  
  
  CompoundParameter sunRadius = new CompoundParameter("RAD", 1, 1, 24);
  CompoundParameter colorSpread = new CompoundParameter("CLR", 0.65, 0.65, 1);
  
  private static final double GAIN_DEFAULT = 6;
  private static final double MODULATION_RANGE = 1;
  
  private BandGate audioModulatorLow;
  private BandGate audioModulatorMid;
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private L8onBlurLayer blurLayer = new L8onBlurLayer(lx, this, blurParameter);
  
  private BoundedParameter yMinParam = new BoundedParameter("YMIN", 465, 400, model.yMax);
  
  public SunriseSunset(LX lx) {
    super(lx);
    addModulator(sunPosition).start();
    
    addParameter(blurParameter);
    addLayer(blurLayer);
    
    addParameter(dayTime);
    addParameter(yMinParam);
    addParameter(sunRadius);
    addParameter(colorSpread);
    
    this.createAudioModulators();
  }
   
  
  private void createAudioModulators() {    
    this.createLowAudioModulator();    
    this.createMidAudioModulator();
  }
  
  private void createLowAudioModulator() {
    this.audioModulatorLow = new BandGate("Low", this.lx);
    addModulator(this.audioModulatorLow);
    this.audioModulatorLow.threshold.setValue(1);
    this.audioModulatorLow.floor.setValue(0);
    this.audioModulatorLow.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorLow.maxFreq.setValue(216);
    this.audioModulatorLow.minFreq.setValue(0);
    
    this.audioModulatorLow.start();
    
    LXCompoundModulation compoundModulationLow = new LXCompoundModulation(audioModulatorLow.average, sunRadius);
    compoundModulationLow.range.setValue(MODULATION_RANGE);
  }
  
  private void createMidAudioModulator() {
    this.audioModulatorMid = new BandGate("Mid", this.lx);
    addModulator(this.audioModulatorMid);
    this.audioModulatorMid.threshold.setValue(1);
    this.audioModulatorMid.floor.setValue(0);
    this.audioModulatorMid.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorMid.maxFreq.setValue(2200);
    this.audioModulatorMid.minFreq.setValue(216);
    
    this.audioModulatorMid.start();
    
    LXCompoundModulation compoundModulationMid = new LXCompoundModulation(audioModulatorMid.average, colorSpread);
    compoundModulationMid.range.setValue(MODULATION_RANGE);
  }
  
  public void run(double deltaMs) {
    projection.reset();
    projection.rotateZ(sunPosition.getValuef());
    
    int i = 0;
    for(LXVector v: projection) {      
      if (model.yMax - v.y < sunRadius.getValuef()) {
          setColor(i, LX.hsb(0, 0, 100));
      } else if(v.y > yMinParam.getValuef()) {        
        float yn = (v.y - yMinParam.getValuef()) / model.yRange;        
        float hue = (350 + ((360 * colorSpread.getValuef() * yn))) % 360;
        setColor(i, LX.hsb(hue, 100, 100 * yn));  
      } else {
        setColor(i, 0);
      }
      i++;
    }
  }
}


  
@LXCategory("Pattern")  
 public class BigwillSnow extends LXPattern {
  private class Flake {
    public int c;
    public float r;    
    public float x;
    public float z;
    private LXPeriodicModulator yMod;
    private BigwillSnow pat;

    public Flake(BigwillSnow pat) {
      this.pat = pat;
      this.c = #FFFFFF;
      this.r = 3.0*INCHES;
      this.yMod = new SawLFO(1.0*INCHES + 15 * FEET *2.0, -1.0*INCHES, 0).randomBasis();
      newValues();
      pat.startModulator(this.yMod);
    }

    public void run() {
      if (this.yMod.loop()) {
        newValues();
      }
    }

    private void newValues() {
      newX();
      newyModPeriod();
      newZ();
    }

    private void newyModPeriod() {
      this.yMod.setPeriod(this.pat.rate.getValuef() * (0.9 + 0.2 * (float) Math.random()));
    }

    private void newX() {
      this.x = -2.0 * 15*FEET + 15*FEET * 4.0 * (float) Math.random();
    }

    private void newZ() {
      this.z = -2.0 * 15*FEET + 15*FEET * 4.0 * (float) Math.random();
    }
  }

  private final static int MAX_FLAKES = 1000;

  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3500, 1, 20000)
    .setDescription("Average rate at which the snow flakes fall");

  public final CompoundParameter numFlakes =
    new CompoundParameter("Flakes", 500, 100, MAX_FLAKES)
    .setDescription("Number of snow flakes");

  private final List<Flake> flakes = new ArrayList<Flake>();

  private float bucket(float x, float y, float z) {
    return 17 * (float) Math.floor(x * 3*INCHES) + 13 * (float) Math.floor(y * 3*INCHES) + 11 * (float) Math.floor(z * 3*INCHES);
  }

  public BigwillSnow(LX lx) {
    super(lx);
    addParameter(this.rate);
    addParameter(this.numFlakes);

    for (int i = 0; i < MAX_FLAKES; i++) {
      flakes.add(new Flake(this));
    }
  }

  public void run(double deltaMs) {
    HashMap<Float, Flake> flakeMap = new HashMap<Float, Flake>();

    for (int i = 0; i < (int) this.numFlakes.getValuef(); i++) {
      Flake f = flakes.get(i);
      f.run();
      flakeMap.put(bucket(f.x, f.yMod.getValuef(), f.z), f);
    }

    for (Rail rail : venue.rails) {
      for (LXPoint p : rail.points) {
        int c = #000000;
  
        Flake f = flakeMap.get(bucket(p.x, p.y, p.z));
        if (f != null) {
          // System.out.println("flake hit! " + leaf.toString() + "flake: " + flake.toString());
          c = f.c;
        }
        setColor(p.index, c);
        //setColor(rail, c);
      }  
    }
  } 
}


//////////////////////////////////////////////////////////////////////////

// Sub groups



@LXCategory("Pattern")
public class GameOfLife extends EnvelopPattern {
  /* Set the author */
  public String getAuthor() {
    return "Wilco V.";
  }
  
  // This is a parameter, it has a label, an intial value and a range 
  public final CompoundParameter t_step =
    new CompoundParameter("Step time", 10.0, 1.0, 10000.0)
    .setDescription("Controls the step time");
    
  public final DiscreteParameter life_drainage =
    new DiscreteParameter("Drainage", 3, 0, 4)
    .setDescription("Drainage per timestep");
    
    public final DiscreteParameter life_loneliness =
    new DiscreteParameter("Loneliness", 20, 0, 25)
    .setDescription("Penalty for loneliness per timestep");
    
    public final DiscreteParameter life_crowded =
    new DiscreteParameter("Overcrowded", 20, 0, 25)
    .setDescription("Penalty for overcrowding per timestep");
    
    public final DiscreteParameter life_boost =
    new DiscreteParameter("Boost", 10, 0, 25)
    .setDescription("Boost for ideal nr of neighbours per timestep");
    
    public final CompoundParameter spawn_percentage =
    new CompoundParameter("Spawn percentage", 1.0, 0.0, 1.0)
    .setDescription("Percentage of max health when spawning");
    
    public final DiscreteParameter max_life =
    new DiscreteParameter("Max health", 7000, 1, 10000)
    .setDescription("Maximum health");

  // Array of cells
  public final int[][][] world; 
  public final int[][] world_indices;
  public double cur_step_time = 0.0;
  public int grid_size = 60;
  //public int max_life = 1000;
  //public float spawn_percentage = 0.25; // [0 - 1]
  
  //public int life_drainage     = 1;  // penalty
  //public int life_loneliness   = 9;  // penalty
  //public int life_crowded      = 9;  // penalty
  //public int life_boost        = 10; // boost
  
  public float color_h_life    = 80.0;
  public float color_h_offset  = 0.2;
  
  public float color_s_life    = 80.0;
  
  public float color_b_life    = 50.0;
  public float color_b_offset  = 15.0;
  
  public int neighbours_min = 3;
  public int neighbours_max = 5;
  public int neighbours_boost = 4;

  public GameOfLife(LX lx) {
    super(lx);
    addParameter(t_step);
    addParameter(spawn_percentage);
    addParameter(max_life);
    addParameter(life_drainage);
    addParameter(life_loneliness);
    addParameter(life_crowded);
    addParameter(life_boost);
    
    world = new int[grid_size][grid_size][grid_size];
    world_indices = new int[48*32][3];
    
    float xmin = 10000.0, xmax = 0.0, ymin = 10000.0, ymax = 0.0, zmin = 10000.0, zmax = 0.0;
    for (Rail rail : model.rails) {
      for (LXPoint p : rail.points){
        if(rail.cx < xmin){
          xmin = p.x;
        }else if(p.x > xmax){
          xmax = p.x;
        }
        if(p.y < ymin){
          ymin = p.y;
        }else if(p.y > ymax){
          ymax = p.y;
        }
        if(p.z < zmin){
          zmin = p.z;
        }else if(p.z > zmax){
          zmax = p.z;
        }
      }  
    }
    
    
    int l = 0;
    for (Rail rail : model.rails) {
      for (LXPoint p : rail.points){
        world_indices[l][0] = Math.round((p.x - xmin) / (xmax - xmin) * (grid_size-1));
        world_indices[l][1] = Math.round((p.y - ymin) / (ymax - ymin) * (grid_size-1));
        world_indices[l][2] = Math.round((p.z - zmin) / (zmax - zmin) * (grid_size-1));
        l++;
      }  
    }
    for(int x = 0; x < grid_size; x = x + 1){
      for(int y = 0; y < grid_size; y = y + 1){
        for(int z = 0; z < grid_size; z = z + 1){
          float state = random(100);
          if(state > 15){
            world[x][y][z] = (int) (spawn_percentage.getValuef() * max_life.getValuei() * random(100) / 100.0f);
          }
        }
      }
    }
  }
  
  public void update_world(double deltaMs) {
    boolean update_world_now = false;
    cur_step_time = cur_step_time + deltaMs;
    if(cur_step_time > this.t_step.getValuef()){
      cur_step_time = 0.0;
      update_world_now = true;
    }
    if(update_world_now){
      for(int x = 0; x < grid_size; x++){
        for(int y = 0; y < grid_size; y++){
          for(int z = 0; z < grid_size; z++){
            int number_of_neighbours = 0;
            for(int xi = x-1; xi <= x+1; xi++){
              for(int yi = y-1; yi <= y+1; yi++){
                for(int zi = z-1; zi <= z+1; zi++){
                  if(x!= xi && y!=yi && z!=zi && xi >= 0 && xi < grid_size && yi >= 0 && yi < grid_size && zi >= 0 && zi < grid_size){
                    if(world[xi][yi][zi] > 0){
                      number_of_neighbours++;
                    }
                  }
                }
              }
            }
            // Should we live or should we die?
            if(world[x][y][z] > 0){
              // We were alive
              world[x][y][z] -= life_drainage.getValuei();
              if(number_of_neighbours < neighbours_min){
                world[x][y][z] -= life_loneliness.getValuei();
              }else if(number_of_neighbours > neighbours_max){
                world[x][y][z] -= life_crowded.getValuei();
              }else if(number_of_neighbours == neighbours_boost && world[x][y][z] < max_life.getValuei()){
                world[x][y][z] += life_boost.getValuei();
              }else{
                //world[x][y][z] += 1;
              }
            }else{
              // We were dead
              if(number_of_neighbours >= neighbours_min && number_of_neighbours <= neighbours_max){
                // Enough neighbours, let's spawn
                world[x][y][z] = Math.round(spawn_percentage.getValuef() * max_life.getValuei());
              }
            }
          }
        }
      }
    }
  }

  public void run(double deltaMs) {
    // Update the world
    update_world(deltaMs);
    // Let's iterate over all the leaves...
    int l = 0;
    for (Rail rail : model.rails) {
      for(LXPoint p : rail.points){
        //print("leaf_ind: " + l + ",  x_ind: " + world_indices[l][0] + ",  y_ind: " + world_indices[l][1] + ",  z_ind: " + world_indices[l][2]);
        int leaf_life = world[world_indices[l][0]][world_indices[l][1]][world_indices[l][2]];
        if (leaf_life > 0) {
          setColor(p.index, LX.hsb(Math.round(Math.max(0.0, Math.min(color_h_life, color_h_life * (leaf_life - color_h_offset * max_life.getValuei()) / ((1.0 - color_h_offset) * max_life.getValuei())))), Math.round(color_s_life) , Math.round(color_b_life * Math.sqrt(leaf_life) / Math.sqrt(max_life.getValuei())) + color_b_offset));
        } else {
          setColor(p.index, #000000);
        }
        l++;
      } 
    }
  }
}

@LXCategory("Pattern")
public abstract class WavePattern extends BufferPattern {
  
  public static final int NUM_MODES = 5; 
  private final float[] dm = new float[NUM_MODES];
  
  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0, NUM_MODES - 1)
    .setDescription("Mode of the wave motion");
  
  private final LXModulator modeDamped = startModulator(new DampedParameter(this.mode, 1, 8)); 
  
  protected WavePattern(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
  }
    
  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float mode = this.modeDamped.getValuef();
    float lerp = mode % 1;
    int floor = (int) (mode - lerp);
    for (Rail rail : model.rails) {
      for (LXPoint p : rail.points) {
        dm[0] = abs(p.yn - .5);
        dm[1] = .5 * abs(p.xn - .5) + .5 * abs(p.yn - .5);
        dm[2] = abs(p.xn - .5);
        dm[3] = p.yn;
        dm[4] = 1 - p.yn;
        
        int offset1 = round(dm[floor] * dm[floor] * speed);
        int offset2 = round(dm[(floor + 1) % dm.length] * dm[(floor + 1) % dm.length] * speed);
        int c1 = this.history[(this.cursor + offset1) % this.history.length];
        int c2 = this.history[(this.cursor + offset2) % this.history.length];
        setColor(rail, LXColor.lerp(c1, c2, lerp));
      }
    }
  }
}
/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class L8onAudioBeatGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  
  public L8onAudioBeatGate(LX lx) {
    this("Beat", lx);
  }

  public L8onAudioBeatGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public L8onAudioBeatGate(String label, GraphicMeter meter) {
    super(label, meter);
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);    
  }
  
  public L8onAudioBeatGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Beat", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public L8onAudioBeatGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

/**
 * Use this to get a beat gate that has been configured to be very sensitive to
 * the bass beat of the audio input.
 */
public class L8onAudioClapGate extends BandGate {
  final float DEFAULT_GAIN = 7;
  final float DEFAULT_THRESHOLD = .5;
  final float DEFAULT_FLOOR = .88;
  final float CLAP_MIN_FREQ = 2200;
  final float CLAP_MAX_FREQ = 2800;
  
  public L8onAudioClapGate(LX lx) {
    this("Clap", lx);
  }

  public L8onAudioClapGate(String label, LX lx) {
    this(label, lx.engine.audio.meter);
  }
  
  public L8onAudioClapGate(String label, GraphicMeter meter) {
    super(label, meter);        
    this.gain.setValue(DEFAULT_GAIN);
    this.threshold.setValue(DEFAULT_THRESHOLD);
    this.floor.setValue(DEFAULT_FLOOR);
    
    this.maxFreq.setValue(CLAP_MAX_FREQ);
    this.minFreq.setValue(CLAP_MIN_FREQ);
  }
  
  public L8onAudioClapGate(GraphicMeter meter, float minHz, float maxHz) {
    this("Clap", meter);
    setFrequencyRange(minHz, maxHz);
  }
  
  public L8onAudioClapGate(String label, GraphicMeter meter, int minHz, int maxHz) {
    this(label, meter);
    setFrequencyRange(minHz, maxHz);
  }  
}

@LXCategory("Pattern")
public class L8onExplosion implements LXParameterListener {  
  float center_x;
  float center_y;
  float center_z;  
  float stroke_width;
  float hue_value;
  float chill_time;
  float time_chillin;

  private BooleanParameter trigger_parameter;
  public LXModulator radius_modulator;  
  private boolean radius_modulator_triggered = false;

  public L8onExplosion(LXModulator radius_modulator, BooleanParameter trigger_parameter, float stroke_width, float center_x, float center_y, float center_z) {
    this.setRadiusModulator(radius_modulator, stroke_width);
    
    this.trigger_parameter = trigger_parameter;
    this.trigger_parameter.addListener(this);
    
    this.center_x = center_x;
    this.center_y = center_y;
    this.center_z = center_z;
  }
 
  public void setChillTime(float chill_time) {
    this.chill_time = chill_time;  
    this.time_chillin = 0;
  }

  public boolean isChillin(float deltaMs) {
    this.time_chillin += deltaMs;

    return time_chillin < this.chill_time;  
  }

  public float distanceFromCenter(float x, float y, float z) {
    return dist(this.center_x, this.center_y, this.center_z, x, y, z);
  }

  public void setRadiusModulator(LXModulator radius_modulator, float stroke_width) {
    this.radius_modulator = radius_modulator;
    this.stroke_width = stroke_width;    
    this.radius_modulator_triggered = false;
  }

  public void setCenter(float x, float y, float z) {
    this.center_x = x;
    this.center_y = y;
    this.center_z = z;
  }

  public void explode() {
    this.radius_modulator_triggered = true;
    this.radius_modulator.trigger();
  }

  public boolean hasExploded() {
    return this.radius_modulator_triggered;
  }

  public boolean isExploding() {
    if (this.radius_modulator == null) {
      return false;
    }

    return this.radius_modulator.isRunning();
  }

  public boolean isFinished() {
    if (this.radius_modulator == null) {
      return true;
    }

    return !this.radius_modulator.isRunning();
  }

  public boolean onExplosion(float x, float y, float z) {
    float current_radius = this.radius_modulator.getValuef();
    float min_dist = max(0.0, current_radius - (stroke_width / 2.0));
    float max_dist = current_radius + (stroke_width / 2.0);;
    float point_dist = this.distanceFromCenter(x, y, z);

    return (point_dist >= min_dist && point_dist <= max_dist);  
  }
  
  public void onParameterChanged(LXParameter parameter) {    
    if (!(parameter == this.trigger_parameter)) { return; }
        
    if (this.trigger_parameter.getValueb() && this.isFinished()) {            
      this.setChillTime(0);
    }
  }
}

@LXCategory("Pattern")
public class Explosions extends LXPattern {
  // Used to store info about each explosion.
  // See L8onUtil.pde for the definition.
  private List<L8onExplosion> explosions = new ArrayList<L8onExplosion>();
  private final SinLFO saturationModulator = new SinLFO(80.0, 100.0, 200000);
  private BoundedParameter numExplosionsParameter = new BoundedParameter("NUM", 4.0, 1.0, 20.0);
  private BoundedParameter brightnessParameter = new BoundedParameter("BRGT", 50, 10, 80);
  
  private static final double GAIN_DEFAULT = 6;
  private static final double MODULATION_RANGE = 1;
  
  private BandGate audioModulatorFull;
  private CompoundParameter rateParameter = new CompoundParameter("RATE", 8000.0, 8000.0, 750.0);  
  
  private BoundedParameter blurParameter = new BoundedParameter("BLUR", 0.69);
  private L8onBlurLayer blurLayer = new L8onBlurLayer(lx, this, blurParameter);
  
  private Random pointRandom = new Random();
  
  private L8onAudioBeatGate beatGate = new L8onAudioBeatGate("XBEAT", lx);
  private L8onAudioClapGate clapGate = new L8onAudioClapGate("XCLAP", lx);

  public Explosions(LX lx) {
    super(lx);

    addParameter(numExplosionsParameter);
    addParameter(brightnessParameter);

    createAudioModulator();
    modulateRateParam();
    
    addParameter(rateParameter);    
    addParameter(blurParameter);

    addLayer(blurLayer);

    addModulator(saturationModulator).start();
    addModulator(beatGate).start();
    addModulator(clapGate).start();

    initExplosions();
  }
  
  private void createAudioModulator() {
    this.audioModulatorFull = new BandGate("Full", this.lx);
    addModulator(this.audioModulatorFull);
    this.audioModulatorFull.threshold.setValue(1);
    this.audioModulatorFull.floor.setValue(0);
    this.audioModulatorFull.gain.setValue(GAIN_DEFAULT);
    
    this.audioModulatorFull.maxFreq.setValue(this.audioModulatorFull.maxFreq.range.max);
    this.audioModulatorFull.minFreq.setValue(0);
    
    this.audioModulatorFull.start();
  }
  
  private void modulateRateParam() {
    LXCompoundModulation compoundModulation = new LXCompoundModulation(audioModulatorFull.average, rateParameter);    
    compoundModulation.range.setValue(MODULATION_RANGE); 
  }

  public void run(double deltaMs) {
    initExplosions();

    float base_hue = lx.palette.getHuef();
    float wave_hue_diff = (float) (360.0 / this.explosions.size());

    for(L8onExplosion explosion : this.explosions) {
      if (explosion.isChillin((float)deltaMs)) {
        continue;
      }
 
      explosion.hue_value = (float)(base_hue % 360.0);
      base_hue += wave_hue_diff;

      if (!explosion.hasExploded()) {
        explosion.explode();
      } else if (explosion.isFinished()) {
        assignNewCenter(explosion);
      }
    }

    color c;
    float hue_value = 0.0;
    float sat_value = saturationModulator.getValuef();
    float brightness_value = brightnessParameter.getValuef();    

    for (LXPoint p : model.points) {
      int num_explosions_in = 0;

      for(L8onExplosion explosion : this.explosions) {
        if(explosion.isChillin(0)) {
          continue;
        }

        if(explosion.onExplosion(p.x, p.y, p.z)) {
          num_explosions_in++;
          hue_value = L8onUtil.natural_hue_blend(explosion.hue_value, hue_value, num_explosions_in);
        }
      }

      if(num_explosions_in > 0) {
        c = LX.hsb(hue_value, sat_value, brightness_value);
      } else {
        c = colors[p.index];
        c = LX.hsb(LXColor.h(c), LXColor.s(c), 0.0);
      }

      colors[p.index] = c;
    }
  }

  private void initExplosions() {
    int num_explosions = (int) numExplosionsParameter.getValue();

    if (this.explosions.size() == num_explosions) {
      return;
    }

    if (this.explosions.size() < num_explosions) {
      for(int i = 0; i < (num_explosions - this.explosions.size()); i++) {
        float stroke_width = this.new_stroke_width();
        QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
        new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);
        LXPoint new_center_point = model.points[pointRandom.nextInt(model.points.length)];        
        addModulator(new_radius_env);
        BandGate explosionGate = (this.explosions.size() % 2 == 1) ? this.beatGate : this.clapGate;        
        this.explosions.add(
          new L8onExplosion(new_radius_env, explosionGate.gate, stroke_width, new_center_point.x, new_center_point.y, new_center_point.z)
        );
      }
    } else {
      for(int i = (this.explosions.size() - 1); i >= num_explosions; i--) {
        removeModulator(this.explosions.get(i).radius_modulator);
        this.explosions.remove(i);
      }
    }
  }

  private void assignNewCenter(L8onExplosion explosion) {
    float stroke_width = this.new_stroke_width();
    LXPoint new_center_point = model.points[pointRandom.nextInt(model.points.length)];
    float chill_time = (15.0 + random(15)) * 1000;
    QuadraticEnvelope new_radius_env = new QuadraticEnvelope(0.0, model.xRange, rateParameter);
    new_radius_env.setEase(QuadraticEnvelope.Ease.OUT);

    explosion.setCenter(new_center_point.x, new_center_point.y, new_center_point.z);
    addModulator(new_radius_env);
    explosion.setRadiusModulator(new_radius_env, stroke_width);
    explosion.setChillTime(chill_time);
  }

  public float new_stroke_width() {
    return 3 * INCHES + random(6 * INCHES);
  }
}
public static class L8onUtil {
  L8onUtil() {
  }
  
  /*
   * Use this to decrease the brightness of a light over `delay` ms.
   * The current color is reduces by the appropriate proportion given   
   * the deltaMs of the current run.   
   */   
  public static float decayed_brightness(color c, float delay,  double deltaMs) {
    float bright_prop = min(((float)deltaMs / delay), 1.0);
    float bright_diff = max((LXColor.b(c) * bright_prop), 1);
    return max(LXColor.b(c) - bright_diff, 0.0);
  }
  
  
  public static float natural_hue_blend(float hueBase, float hueNew) {
    return natural_hue_blend(hueBase, hueNew, 2);    
  }
  
  /**
   * Use this to "naturally" blend colors.   
   * Can be used iteratively on a point as more colors are "mixed" into it, or 
   * used simply with 2 colors.
   * 
   */ 
  public static float natural_hue_blend(float hueBase, float hueNew, int count) {    
    // Return hueA if there is only one hue to mix
    if(count == 1) { return hueBase; }
        
    if(count > 2) {
      // Jump color by 180 before blending again to avoid regression towards the mean (180)
      hueBase = (hueBase + 180) % 360;
    }    
    
    // Blend a with b
    float minHue = min(hueBase, hueNew);
    float maxHue = max(hueBase, hueNew);    
    return (minHue * 2.0 + maxHue / 2.0) / 2.0;    
  }
}

public class L8onBlurLayer extends LXLayer {
  public final BoundedParameter amount;
  private final int[] blurBuffer;

  public L8onBlurLayer(LX lx, LXDeviceComponent pattern) {
    this(lx, pattern, new BoundedParameter("BLUR", 0));
  }

  public L8onBlurLayer(LX lx, LXDeviceComponent pattern, BoundedParameter amount) {    
    super(lx, pattern); 
    this.amount = amount;
    this.blurBuffer = new int[lx.total];
    
    for (int i = 0; i < blurBuffer.length; ++i) {
      this.blurBuffer[i] = 0xff000000;
    }
  }
  
  public void run(double deltaMs) {
    float blurf = this.amount.getValuef();
    if (blurf > 0) {
      blurf = 1 - (1 - blurf) * (1 - blurf) * (1 - blurf);
      for (int i = 0; i < this.colors.length; ++i) {
        int blend = LXColor.screen(this.colors[i], this.blurBuffer[i]);
        this.colors[i] = LXColor.lerp(this.colors[i], blend, blurf);
      }
    }
    for (int i = 0; i < this.colors.length; ++i) {
      this.blurBuffer[i] = this.colors[i];
    }
  }
}

@LXCategory("Pattern")
public class Snakes extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  int numPix = 32; //number of pixels in a tube
  private static final int NUM_SNAKES = 24;
  private final LXModulator snakes[] = new LXModulator[NUM_SNAKES];
  private final LXModulator sizes[] = new LXModulator[NUM_SNAKES];
  
  private final int[][] mask = new int[NUM_SNAKES][numPix];
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 7000, 19000, 2000)
    .setExponent(.5)
    .setDescription("Speed of snakes moving");
    
  public final CompoundParameter modSpeed = (CompoundParameter)
    new CompoundParameter("ModSpeed", 7000, 19000, 2000)
    .setExponent(.5)
    .setDescription("Speed of snake length modulation");    
    
  public final CompoundParameter size =
    new CompoundParameter("Size", 15, 10, 100)
    .setDescription("Size of longest snake");    
      
  public Snakes(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("modSpeed", this.modSpeed);
    addParameter("size", this.size);
    for (int i = 0; i < NUM_SNAKES; ++i) {
      final int ii = i;
      this.snakes[i] = startModulator(new SawLFO(0, numPix, speed).randomBasis());
      this.sizes[i] = startModulator(new SinLFO(4, this.size, new FunctionalParameter() {
        public double getValue() {
          return modSpeed.getValue() + ii*100;
        }
      }).randomBasis());
    }
  }
  
  public void run(double deltaMs) {
    for (int i = 0; i < NUM_SNAKES; ++i) {
      float snake = this.snakes[i].getValuef();
      float falloff = 100 / this.sizes[i].getValuef();
      for (int j = 0; j < numPix; ++j) {
        this.mask[i][j] = LXColor.gray(max(0, 100 - falloff * LXUtils.wrapdistf(j, snake, numPix)));
      }
    }
    int bi = 0;
    for (Rail rail : model.rails) {
      int[] mask = this.mask[bi++ % NUM_SNAKES];
      int li = 0;
      for (LXPoint p : rail.points) {
        setColor(p.index, mask[li++]);
      }
    }
  }
}

@LXCategory("Pattern") 
public class TubeSequence extends EnvelopPattern {
  public String getAuthor() {
    return "Tom Montagliano";
  }
  
  public final DiscreteParameter seq_num = 
    new DiscreteParameter("Seq",0,0,49);
  
    int seqCnt = 0;
    
    
  public TubeSequence(LX lx) {
    super(lx);
    addParameter("Seq", this.seq_num);
  }
  
  public void run(double deltaMs) {
    
    int seqCnt = 0;
    int tnum = (int) seq_num.getValue(); 
    //This dictates which number in the sequence each arra
    int[] seqArr = new int[]{ 0,24,1,25,   2,26,3,27,   4,28,5,29,   6,30,7,31,   8,32,9,33,   10,34,11,35,   
                              12,36,13,37, 14,38,15,39, 16,40,17,41, 18,42,19,43, 20,44,21,45, 22,46,23,47};
                             
                                                      
    Rail[] tubeSeq = new Rail[48];
    
    //populate dummy arr with sequence; doesnt work correctly unless populated first? (Shruggie guy)
    for (Rail rail : model.rails) {
      tubeSeq[seqCnt] = rail;
      ++seqCnt;
    }  
    
    seqCnt = 0;
    
    //populate rail arr with sequence
    for (Rail rail : model.rails) {
      tubeSeq[seqArr[seqCnt]] = rail;
      ++seqCnt;
    }  
    
    //light up only rails in sequence
    for (int i = 0; i < 49; ++i){
      if (i <= tnum && i != 0) {
        setColor(tubeSeq[i-1], #FFFFFF);
        } else if (i != 0){
        setColor(tubeSeq[i-1], #000000);
        } else {
        setColor(tubeSeq[i], #000000);  
        
        }
    }  
  }
}
