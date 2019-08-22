public class ADSR {
  final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the notes");

  final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 500, 50, 3000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");

  final CompoundParameter sustain = (CompoundParameter)
    new CompoundParameter("Sustain", .5)
    .setExponent(2)
    .setDescription("Sets the sustain level of the notes");    

  final CompoundParameter release = (CompoundParameter)
    new CompoundParameter("Release", 500, 50, 5000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");
}


@LXCategory("MIDI")
  public class NotePattern extends EnvelopPattern {

  private final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the flash");

  private final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 1000, 50, 10000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the flash");

  private final CompoundParameter size = new CompoundParameter("Size", .2)
    .setDescription("Sets the base size of notes");

  private final CompoundParameter pitchBendDepth = new CompoundParameter("BendAmt", 0.5)
    .setDescription("Controls the depth of modulation from the Pitch Bend wheel");

  private final CompoundParameter modBrightness = new CompoundParameter("Mod>Brt", 0)
    .setDescription("Sets the amount of LFO modulation to note brightness");

  private final CompoundParameter modSize = new CompoundParameter("Mod>Sz", 0)
    .setDescription("Sets the amount of LFO modulation to note size");

  private final CompoundParameter lfoRate = (CompoundParameter)
    new CompoundParameter("LFOSpd", 500, 1000, 100)
    .setExponent(2)
    .setDescription("Sets the rate of LFO modulation from the mod wheel");

  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");

  private final CompoundParameter velocitySize = new CompoundParameter("Vel>Size", .5)
    .setDescription("Sets the amount of modulation from note velocity to size");

  private final CompoundParameter position = new CompoundParameter("Pos", .5)
    .setDescription("Sets the base position of middle C");

  private final CompoundParameter pitchDepth = new CompoundParameter("Note>Pos", 1, .1, 4)
    .setDescription("Sets the amount pitch modulates the position");

  private final DiscreteParameter soundObject = new DiscreteParameter("Object", 0, 17)
    .setDescription("Which sound object to follow");

  private final LXModulator lfo = startModulator(new SinLFO(0, 1, this.lfoRate));

  private float pitchBendValue = 0;
  private float modValue = 0;

  private final NoteLayer[] notes = new NoteLayer[128];

  public NotePattern(LX lx) {
    super(lx);
    for (int i = 0; i < notes.length; ++i) {
      addLayer(this.notes[i] = new NoteLayer(lx, i));
    }
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("size", this.size);
    addParameter("pitchBendDepth", this.pitchBendDepth);
    addParameter("velocityBrightness", this.velocityBrightness);
    addParameter("velocitySize", this.velocitySize);
    addParameter("modBrightness", this.modBrightness);
    addParameter("modSize", this.modSize);
    addParameter("lfoRate", this.lfoRate);
    addParameter("position", this.position);
    addParameter("pitchDepth", this.pitchDepth);
    addParameter("soundObject", this.soundObject);
  }

  protected class NoteLayer extends LXLayer {

    private final int pitch;

    private float velocity;

    private final MutableParameter level = new MutableParameter(0); 

    private final ADEnvelope envelope = new ADEnvelope("Env", 0, level, attack, decay);

    NoteLayer(LX lx, int pitch) {
      super(lx);
      this.pitch = pitch;
      addModulator(envelope);
    }

    public void run(double deltaMs) {
      float pos = position.getValuef() + pitchDepth.getValuef() * (this.pitch - 64) / 64.;
      float level = envelope.getValuef() * (1 - modValue * modBrightness.getValuef() * lfo.getValuef()); 
      if (level > 0) {        
        float yn = pos + pitchBendDepth.getValuef() * pitchBendValue;
        float sz =
          size.getValuef() +
          velocity * velocitySize.getValuef() +
          modValue * modSize.getValuef() * (lfo.getValuef() - .5); 

        Envelop.Source.Channel sourceChannel = null;
        int soundObjectIndex = soundObject.getValuei();
        if (soundObjectIndex > 0) {
          sourceChannel = envelop.source.channels[soundObjectIndex - 1];
        }

        float falloff = 50.f / sz;
        for (Rail rail : venue.rails) {
          float l2 = level;
          if (sourceChannel != null) {
            float l2fall = 100 / (20*FEET);
            l2 = level - l2fall * max(0, dist(sourceChannel.tx, sourceChannel.tz, rail.cx, rail.cz) - 2*FEET);
          } 
          for (LXPoint p : rail.points) {
            float b = l2 - falloff * abs(p.yn - yn);
            if (b > 0) {
              addColor(p.index, LXColor.gray(b));
            }
          }
        }
      }
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    NoteLayer noteLayer = this.notes[note.getPitch()];
    noteLayer.velocity = note.getVelocity() / 127.;
    noteLayer.level.setValue(lerp(100.f, noteLayer.velocity * 100, this.velocityBrightness.getNormalizedf()));
    noteLayer.envelope.engage.setValue(true);
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    this.notes[note.getPitch()].envelope.engage.setValue(false);
  }

  @Override
    public void pitchBendReceived(MidiPitchBend pb) {
    this.pitchBendValue = (float) pb.getNormalized();
  }

  @Override
    public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == MidiControlChange.MOD_WHEEL) {
      this.modValue = (float) cc.getNormalized();
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("MIDI")
  public static class Flash extends LXPattern implements CustomDeviceUI {

  private final BooleanParameter manual =
    new BooleanParameter("Trigger")
    .setMode(BooleanParameter.Mode.MOMENTARY)
    .setDescription("Manually triggers the flash");

  private final BooleanParameter midi =
    new BooleanParameter("MIDI", true)
    .setDescription("Toggles whether the flash is engaged by MIDI note events");

  private final BooleanParameter midiFilter =
    new BooleanParameter("Note Filter")
    .setDescription("Whether to filter specific MIDI note");

  private final DiscreteParameter midiNote = (DiscreteParameter)
    new DiscreteParameter("Note", 0, 128)
    .setUnits(LXParameter.Units.MIDI_NOTE)
    .setDescription("Note to filter for");

  private final CompoundParameter brightness =
    new CompoundParameter("Brt", 100, 0, 100)
    .setDescription("Sets the maxiumum brightness of the flash");

  private final CompoundParameter velocitySensitivity =
    new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount to which brightness responds to note velocity");

  private final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the flash");

  private final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 1000, 50, 10000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the flash");

  private final CompoundParameter shape = (CompoundParameter)
    new CompoundParameter("Shape", 1, 1, 4)
    .setDescription("Sets the shape of the attack and decay curves");

  private final MutableParameter level = new MutableParameter(0);

  private final ADEnvelope env = new ADEnvelope("Env", 0, level, attack, decay, shape);

  public Flash(LX lx) {
    super(lx);
    addModulator(this.env);
    addParameter("brightness", this.brightness);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("shape", this.shape);
    addParameter("velocitySensitivity", this.velocitySensitivity);
    addParameter("manual", this.manual);
    addParameter("midi", this.midi);
    addParameter("midiFilter", this.midiFilter);
    addParameter("midiNote", this.midiNote);
  }

  @Override
    public void onParameterChanged(LXParameter p) {
    if (p == this.manual) {
      if (this.manual.isOn()) {
        level.setValue(brightness.getValue());
      }
      this.env.engage.setValue(this.manual.isOn());
    }
  }

  private boolean isValidNote(MidiNote note) {
    return this.midi.isOn() && (!this.midiFilter.isOn() || (note.getPitch() == this.midiNote.getValuei()));
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    if (isValidNote(note)) {
      level.setValue(brightness.getValue() * lerp(1, note.getVelocity() / 127., velocitySensitivity.getValuef()));
      this.env.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    if (isValidNote(note)) {
      this.env.engage.setValue(false);
    }
  }

  public void run(double deltaMs) {
    setColors(LXColor.gray(env.getValue()));
  }

  @Override
    public void buildDeviceUI(UI ui, UI2dContainer device) {
    device.setContentWidth(216);
    new UIADWave(ui, 0, 0, device.getContentWidth(), 90).addToContainer(device);

    new UIButton(0, 92, 84, 16).setLabel("Trigger").setParameter(this.manual).setTriggerable(true).addToContainer(device);

    new UIButton(88, 92, 40, 16).setParameter(this.midi).setLabel("Midi").addToContainer(device);

    final UIButton midiFilterButton = (UIButton)
      new UIButton(132, 92, 40, 16)
      .setParameter(this.midiFilter)
      .setLabel("Note")
      .setEnabled(this.midi.isOn())
      .addToContainer(device);

    final UIIntegerBox midiNoteBox = (UIIntegerBox)
      new UIIntegerBox(176, 92, 40, 16)
      .setParameter(this.midiNote)
      .setEnabled(this.midi.isOn() && this.midiFilter.isOn())
      .addToContainer(device);

    new UIKnob(0, 116).setParameter(this.brightness).addToContainer(device);
    new UIKnob(44, 116).setParameter(this.attack).addToContainer(device);
    new UIKnob(88, 116).setParameter(this.decay).addToContainer(device);
    new UIKnob(132, 116).setParameter(this.shape).addToContainer(device);

    final UIKnob velocityKnob = (UIKnob)
      new UIKnob(176, 116)
      .setParameter(this.velocitySensitivity)
      .setEnabled(this.midi.isOn())
      .addToContainer(device);

    this.midi.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        velocityKnob.setEnabled(midi.isOn());
        midiFilterButton.setEnabled(midi.isOn());
        midiNoteBox.setEnabled(midi.isOn() && midiFilter.isOn());
      }
    }
    ); 

    this.midiFilter.addListener(new LXParameterListener() {
      public void onParameterChanged(LXParameter p) {
        midiNoteBox.setEnabled(midi.isOn() && midiFilter.isOn());
      }
    }
    );
  }

  class UIADWave extends UI2dComponent {
    UIADWave(UI ui, float x, float y, float w, float h) {
      super(x, y, w, h);
      setBackgroundColor(ui.theme.getDarkBackgroundColor());
      setBorderColor(ui.theme.getControlBorderColor());

      LXParameterListener redraw = new LXParameterListener() {
        public void onParameterChanged(LXParameter p) {
          redraw();
        }
      };

      brightness.addListener(redraw);
      attack.addListener(redraw);
      decay.addListener(redraw);
      shape.addListener(redraw);
    }

    public void onDraw(UI ui, PGraphics pg) {
      double av = attack.getValue();
      double dv = decay.getValue();
      double tv = av + dv;
      double ax = av/tv * (this.width-1);
      double bv = brightness.getValue() / 100.;

      pg.stroke(ui.theme.getPrimaryColor());
      int py = 0;
      for (int x = 1; x < this.width-2; ++x) {
        int y = (x < ax) ?
          (int) Math.round(bv * (height-4.) * Math.pow(((x-1) / ax), shape.getValue())) :
          (int) Math.round(bv * (height-4.) * Math.pow(1 - ((x-ax) / (this.width-1-ax)), shape.getValue()));
        if (x > 1) {
          pg.line(x-1, height-2-py, x, height-2-y);
        }
        py = y;
      }
    }
  }
}

@LXCategory("MIDI")
  public class Blips extends EnvelopPattern {

  public final CompoundParameter speed = new CompoundParameter("Speed", 500, 4000, 250); 

  final Stack<Blip> available = new Stack<Blip>();

  public Blips(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
  }

  class Blip extends LXModelLayer<EnvelopModel> {

    public final LinearEnvelope dist = new LinearEnvelope(0, model.yRange, new FunctionalParameter() {
      public double getValue() {
        return speed.getValue() * lerp(1, .6, velocity);
      }
    }
    );

    private float yStart;
    private int column;
    private boolean active = false;
    private float velocity = 0;

    public Blip(LX lx) {
      super(lx);
      addModulator(this.dist);
    }

    public void trigger(MidiNoteOn note) {
      this.velocity = note.getVelocity() / 127.;
      this.column = note.getPitch() % venue.columns.size();
      this.yStart = venue.cy + random(-2*FEET, 2*FEET); 
      this.dist.trigger();
      this.active = true;
    }

    public void run(double deltaMs) {
      if (!this.active) {
        return;
      }
      boolean touched = false;
      float dist = this.dist.getValuef();
      float falloff = 100 / (1*FEET);
      float level = lerp(50, 100, this.velocity);
      for (LXPoint p : venue.columns.get(this.column).railPoints) {
        float b = level - falloff * abs(abs(p.y - this.yStart) - dist);
        if (b > 0) {
          touched = true;
          addColor(p.index, LXColor.gray(b));
        }
      }
      if (!touched) {
        this.active = false;
        available.push(this);
      }
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    // TODO(mcslee): hack to not fight with flash
    if (note.getPitch() == 72) {
      return;
    }

    Blip blip;
    if (available.empty()) {
      addLayer(blip = new Blip(lx));
    } else {
      blip = available.pop();
    }
    blip.trigger(note);
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("MIDI")
  //public class ColumnNotes
  public class ColumnNotes extends EnvelopPattern {

  //declarion of an array of noteLayers of the size of number of columns
  private final ColumnLayer[] columns = new ColumnLayer[model.columns.size()]; 

  //contructor for Class. It contains the midi info, attack and decay info
  public ColumnNotes(LX lx) {
    super(lx);
    for (Column column : model.columns) {
      int c = column.index;
      addLayer(columns[c] = new ColumnLayer(lx, column));
      addParameter("attack-" + c, columns[c].attack);
      addParameter("decay-" + c, columns[c].decay);
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel();
    if (channel < this.columns.length) {
      this.columns[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel();
    if (channel < this.columns.length) {
      this.columns[channel].envelope.engage.setValue(false);
    }
  }

  //sub class containing midi information
  private class ColumnLayer extends LXLayer {

    // variables containing attack, decay, envelope, Column and modulator
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final ADEnvelope envelope;

    private final Column column;

    private final LXModulator vibrato = startModulator(new SinLFO(.8, 1, 400));

    //contructor for midi information for each column
    public ColumnLayer(LX lx, Column column) {
      super(lx);
      this.column = column;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-" + column.index, 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-" + column.index, 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);
    }

    //run method for columnLayer class
    public void run(double deltaMs) {
      float level = this.vibrato.getValuef() * this.envelope.getValuef();
      for (LXPoint p : column.points) {
        colors[p.index] = LXColor.gray(level);
      }
    }
  }

  //run method for columnNotes
  public void run(double deltaMs) {
    setColors(#000000);
  }
}


//additional Midi effects; hope this shit works biiiiiiitch
@LXCategory("MIDI")
  public class TubeNotePattern extends EnvelopPattern {

  private final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the flash");

  private final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 1000, 50, 10000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the flash");

  private final CompoundParameter size = new CompoundParameter("Size", .2)
    .setDescription("Sets the base size of notes");

  private final CompoundParameter pitchBendDepth = new CompoundParameter("BendAmt", 0.5)
    .setDescription("Controls the depth of modulation from the Pitch Bend wheel");

  private final CompoundParameter modBrightness = new CompoundParameter("Mod>Brt", 0)
    .setDescription("Sets the amount of LFO modulation to note brightness");

  private final CompoundParameter modSize = new CompoundParameter("Mod>Sz", 0)
    .setDescription("Sets the amount of LFO modulation to note size");

  private final CompoundParameter lfoRate = (CompoundParameter)
    new CompoundParameter("LFOSpd", 500, 1000, 100)
    .setExponent(2)
    .setDescription("Sets the rate of LFO modulation from the mod wheel");

  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");

  private final CompoundParameter velocitySize = new CompoundParameter("Vel>Size", .5)
    .setDescription("Sets the amount of modulation from note velocity to size");

  private final CompoundParameter position = new CompoundParameter("Pos", .5)
    .setDescription("Sets the base position of middle C");

  private final CompoundParameter pitchDepth = new CompoundParameter("Note>Pos", 1, .1, 4)
    .setDescription("Sets the amount pitch modulates the position");

  private final DiscreteParameter soundObject = new DiscreteParameter("Object", 0, 17)
    .setDescription("Which sound object to follow");

  private final LXModulator lfo = startModulator(new SinLFO(0, 1, this.lfoRate));

  private final DiscreteParameter tube = new DiscreteParameter("Tube", 1, 48)
    .setDescription("Which sound object to follow");

  private float pitchBendValue = 0;
  private float modValue = 0;

  private final NoteLayer[] notes = new NoteLayer[128];

  public TubeNotePattern(LX lx) {
    super(lx);
    for (int i = 0; i < notes.length; ++i) {
      addLayer(this.notes[i] = new NoteLayer(lx, i));
    }
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("size", this.size);
    addParameter("pitchBendDepth", this.pitchBendDepth);
    addParameter("velocityBrightness", this.velocityBrightness);
    addParameter("velocitySize", this.velocitySize);
    addParameter("modBrightness", this.modBrightness);
    addParameter("modSize", this.modSize);
    addParameter("lfoRate", this.lfoRate);
    addParameter("position", this.position);
    addParameter("pitchDepth", this.pitchDepth);
    addParameter("soundObject", this.soundObject);
    addParameter("tube", this.tube);
  }

  protected class NoteLayer extends LXLayer {

    private final int pitch;

    private float velocity;

    private final MutableParameter level = new MutableParameter(0); 

    private final ADEnvelope envelope = new ADEnvelope("Env", 0, level, attack, decay);

    NoteLayer(LX lx, int pitch) {
      super(lx);
      this.pitch = pitch;
      addModulator(envelope);
    }

    public void run(double deltaMs) {
      float pos = position.getValuef() + pitchDepth.getValuef() * (this.pitch - 64) / 64.;
      float level = envelope.getValuef() * (1 - modValue * modBrightness.getValuef() * lfo.getValuef()); 
      if (level > 0) {        
        float yn = pos + pitchBendDepth.getValuef() * pitchBendValue;
        float sz =
          size.getValuef() +
          velocity * velocitySize.getValuef() +
          modValue * modSize.getValuef() * (lfo.getValuef() - .5); 

        Envelop.Source.Channel sourceChannel = null;
        int soundObjectIndex = soundObject.getValuei();
        int tubeIndex = tube.getValuei();
        if (soundObjectIndex > 0) {
          sourceChannel = envelop.source.channels[soundObjectIndex - 1];
        }

        float falloff = 50.f / sz;
        int railnum = 1;
        //int randnum = 0;
        //randnum = (int) (48 *Math.random()); look at tree code for rain midi thing
        for (Rail rail : venue.rails) {
          float l2 = level;
          if (railnum == tubeIndex) {
            if (sourceChannel != null) {
              float l2fall = 100 / (20*FEET);
              l2 = level - l2fall * max(0, dist(sourceChannel.tx, sourceChannel.tz, rail.cx, rail.cz) - 2*FEET);
            } 
            for (LXPoint p : rail.points) {
              float b = l2 - falloff * abs(p.yn - yn);
              if (b > 0) {
                addColor(p.index, LXColor.gray(b));
              }
            }
          } else {
            for (LXPoint p : rail.points) {
              addColor(p.index, LXColor.BLACK);
            }
          }  
          railnum++;
        }
      }
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    NoteLayer noteLayer = this.notes[note.getPitch()];
    noteLayer.velocity = note.getVelocity() / 127.;
    noteLayer.level.setValue(lerp(100.f, noteLayer.velocity * 100, this.velocityBrightness.getNormalizedf()));
    noteLayer.envelope.engage.setValue(true);
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    this.notes[note.getPitch()].envelope.engage.setValue(false);
  }

  @Override
    public void pitchBendReceived(MidiPitchBend pb) {
    this.pitchBendValue = (float) pb.getNormalized();
  }

  @Override
    public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == MidiControlChange.MOD_WHEEL) {
      this.modValue = (float) cc.getNormalized();
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}


@LXCategory("MIDI")
  //class declaration
  public class ParNotes extends EnvelopPattern {

  //declaration of array to hold all pars
  int numPars = model.pars.size();
  
  //parameter
  public final DiscreteParameter offset = new DiscreteParameter("Offset", 5, 0, 20);
  
  int offsetVal = 4; 
    
  private final ParLayer[] pars = new ParLayer[numPars]; 
  
  //contructor
  public ParNotes(LX lx) {
    super(lx);
    addParameter(offset);
    int c = 0; // count value

    for (Par par : model.pars) {
      addLayer(pars[c] = new ParLayer(lx, par));
      addParameter("att-" + c, pars[c].attack);
      addParameter("dec-" + c, pars[c].decay);
      ++c; //inc count value
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel() - (int)offset.getValue() + 1;
    System.out.println(channel);
    if (channel < this.pars.length && channel >= 0) {
      this.pars[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel() - (int)offset.getValue() + 1;
    if (channel < this.pars.length && channel >= 0) {
      this.pars[channel].envelope.engage.setValue(false);
    }
  }

  private class ParLayer extends LXLayer {

    //variables
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final ADEnvelope envelope;

    private final Par par;

    private final LXModulator vibrato = startModulator(new SinLFO(.8, 1, 400));

    //constructor
    public ParLayer(LX lx, Par par) {
      super(lx);
      this.par = par;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-", 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-", 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);
    }

    public void run(double deltaMs) {
      //float level = this.vibrato.getValuef() * this.envelope.getValuef(); delete vibrato
      float level = 1.0 * this.envelope.getValuef();
      for (LXPoint p : par.points) {
        colors[p.index] = LXColor.gray(level);
      }
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("MIDI")
  //public class RingNotes
  public class RingNotes extends EnvelopPattern {

  //declarion of an array of noteLayers of the size of number of columns
  int arrSize = 3;
  int countChannels= 1; //keep track of number of channels
  private final RailLayer[] railLayer = new RailLayer[arrSize]; 

  //contructor for Class. It contains the midi info, attack and decay info
  public RingNotes(LX lx) {
    super(lx);
    int rCnt = 0;
    int arrayCnt1 = 0;
    int arrayCnt2 = 0;
    int arrayCnt3 = 0;

    Rail[] ring1 = new Rail[12]; //sets array of Ring1
    Rail[] ring2 = new Rail[16]; //sets array of Ring2
    Rail[] ring3 = new Rail[20]; //sets array of Ring3
    for (Rail rail : model.rails) {
      if (rCnt == 5 || rCnt == 6 || rCnt == 7 || rCnt == 21 || rCnt == 22 || rCnt == 23 ||
        rCnt == 29 || rCnt == 30 || rCnt == 31 || rCnt == 45 || rCnt == 46 || rCnt == 47) {
        ring1[arrayCnt1] = rail;
        ++arrayCnt1;
      } else if (rCnt == 3 || rCnt == 4 || rCnt == 12 || rCnt == 13 || rCnt == 14 || rCnt == 15 || rCnt == 19 || rCnt == 20 ||
        rCnt == 27 || rCnt == 28 || rCnt == 36 || rCnt == 37 || rCnt == 38 || rCnt == 39 || rCnt == 43 || rCnt == 44 ) {
        ring2[arrayCnt2] = rail;
        ++arrayCnt2;
      } else if (rCnt == 0 || rCnt == 1 || rCnt == 2 || rCnt == 8 || rCnt == 9 || rCnt == 10 || rCnt == 11 || rCnt == 16 || rCnt == 17 || rCnt == 18 ||
        rCnt == 24 || rCnt == 25 || rCnt == 26 || rCnt == 32 || rCnt == 33 || rCnt == 34 || rCnt == 35 || rCnt == 40 || rCnt == 41 || rCnt == 42) {
        ring3[arrayCnt3] = rail;
        ++arrayCnt3;
      }

      ++rCnt;
    } 

    //layer 1
    int c = 0;
    addLayer(railLayer[c] = new RailLayer(lx, ring1));
    addParameter("attack-" + c, railLayer[c].attack);
    addParameter("decay-" + c, railLayer[c].decay);
    addParameter("hue-" + c, railLayer[c].hue);
    addParameter("sat-" + c, railLayer[c].sat);

    //layer 2
    int d = 1;
    addLayer(railLayer[d] = new RailLayer(lx, ring2));
    addParameter("attack-" + d, railLayer[d].attack);
    addParameter("decay-" + d, railLayer[d].decay);
    addParameter("hue-" + d, railLayer[d].hue);
    addParameter("sat-" + d, railLayer[d].sat);

    //layer 3
    int e = 2;
    addLayer(railLayer[e] = new RailLayer(lx, ring3));
    addParameter("attack-" + e, railLayer[e].attack);
    addParameter("decay-" + e, railLayer[e].decay);
    addParameter("hue-" + e, railLayer[e].hue);
    addParameter("sat-" + e, railLayer[e].sat);
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(false);
    }
  }

  //sub class containing midi information
  private class RailLayer extends LXLayer {

    // variables containing attack, decay, envelope, Rail and modulator
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final CompoundParameter hue;
    private final CompoundParameter sat;
    private final ADEnvelope envelope;

    private final Rail[] rail;

    private final LXModulator vibrato = startModulator(new SinLFO(0.8, 1, 400));

    //contructor for midi information for each rail
    public RailLayer(LX lx, Rail[] rail) {
      super(lx);
      this.rail = rail;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-" + countChannels, 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-" + countChannels, 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.hue = (CompoundParameter)
        new CompoundParameter("Hue-" + countChannels, 0, 0, 360);

      this.sat = (CompoundParameter)
        new CompoundParameter("Sat-" + countChannels, 0, 0, 100.0); 

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);

      ++countChannels;
    }

    //run method for RingLayer class
    public void run(double deltaMs) {
      //float level = this.vibrato.getValuef() * this.envelope.getValuef(); get rid of vibrato
      //System.out.println("vibrato: " + this.vibrato.getValuef());
      float level = 1.0 * this.envelope.getValuef();
      for (Rail railArr : rail) {
        for (LXPoint p : railArr.points) {
          colors[p.index] = LXColor.hsb(hue.getValuef(), sat.getValuef(), level);
        }
      }
    }
  }

  //run method for columnNotes
  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("MIDI")
  //public class InOutNotes
  public class InOutNotes extends EnvelopPattern {

  //declarion of an array of noteLayers of the size of number of columns
  int arrSize = 3;
  int countChannels= 1; //keep track of number of channels
  private final RailLayer[] railLayer = new RailLayer[arrSize]; 

  //contructor for Class. It contains the midi info, attack and decay info
  public InOutNotes(LX lx) {
    super(lx);
    int rCnt = 0;
    int arrayCnt1 = 0;
    int arrayCnt2 = 0;
    int arrayCnt3 = 0;

    Rail[] inOut1 = new Rail[24]; //sets array of Ring1
    Rail[] inOut2 = new Rail[20]; //sets array of Ring2
    Rail[] inOut3 = new Rail[4]; //sets array of Ring3
    for (Rail rail : model.rails) {
      if (rCnt == 2 || rCnt == 4 || rCnt == 5 || rCnt == 7 || rCnt == 9 || rCnt == 10 ||
        rCnt == 13 || rCnt == 14 || rCnt == 16 || rCnt == 19 || rCnt == 21 || rCnt == 23 ||
        rCnt == 26 || rCnt == 28 || rCnt == 29 || rCnt == 31 || rCnt == 33 || rCnt == 34 ||
        rCnt == 37 || rCnt == 38 || rCnt == 40 || rCnt == 43 || rCnt == 45 || rCnt == 47) {
        inOut1[arrayCnt1] = rail;
        ++arrayCnt1;
      } else if (rCnt == 1 || rCnt == 3 || rCnt == 6 || rCnt == 8 || rCnt == 11 || rCnt == 12 || rCnt == 15 || rCnt == 17 || rCnt == 20 || rCnt == 22 ||
        rCnt == 25 || rCnt == 27 || rCnt == 30 || rCnt == 32 || rCnt == 35 || rCnt == 36 || rCnt == 39 || rCnt == 41 || rCnt == 44 || rCnt == 46 ) {
        inOut2[arrayCnt2] = rail;
        ++arrayCnt2;
      } else if (rCnt == 0 || rCnt == 18 || rCnt == 24 || rCnt == 42) {
        inOut3[arrayCnt3] = rail;
        ++arrayCnt3;
      }

      ++rCnt;
    } 

    //layer 1
    int c = 0;
    addLayer(railLayer[c] = new RailLayer(lx, inOut1));
    addParameter("attack-" + c, railLayer[c].attack);
    addParameter("decay-" + c, railLayer[c].decay);
    addParameter("hue-" + c, railLayer[c].hue);
    addParameter("sat-" + c, railLayer[c].sat);

    //layer 2
    int d = 1;
    addLayer(railLayer[d] = new RailLayer(lx, inOut2));
    addParameter("attack-" + d, railLayer[d].attack);
    addParameter("decay-" + d, railLayer[d].decay);
    addParameter("hue-" + d, railLayer[d].hue);
    addParameter("sat-" + d, railLayer[d].sat);

    //layer 3
    int e = 2;
    addLayer(railLayer[e] = new RailLayer(lx, inOut3));
    addParameter("attack-" + e, railLayer[e].attack);
    addParameter("decay-" + e, railLayer[e].decay);
    addParameter("hue-" + e, railLayer[e].hue);
    addParameter("sat-" + e, railLayer[e].sat);
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(false);
    }
  }

  //sub class containing midi information
  private class RailLayer extends LXLayer {

    // variables containing attack, decay, envelope, Rail and modulator
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final CompoundParameter hue;
    private final CompoundParameter sat;
    private final ADEnvelope envelope;

    private final Rail[] rail;

    private final LXModulator vibrato = startModulator(new SinLFO(0.8, 1, 400));

    //contructor for midi information for each rail
    public RailLayer(LX lx, Rail[] rail) {
      super(lx);
      this.rail = rail;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-" + countChannels, 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-" + countChannels, 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.hue = (CompoundParameter)
        new CompoundParameter("Hue-" + countChannels, 0, 0, 360);
      this.sat = (CompoundParameter)
        new CompoundParameter("Sat-" + countChannels, 0, 0, 100.0);   

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);

      ++countChannels;
    }

    //run method for RingLayer class
    public void run(double deltaMs) {
      //float level = this.vibrato.getValuef() * this.envelope.getValuef(); get rid of vibrato
      //System.out.println("vibrato: " + this.vibrato.getValuef());
      float level = 1.0 * this.envelope.getValuef();
      for (Rail railArr : rail) {
        for (LXPoint p : railArr.points) {
          //colors[p.index] = LXColor.gray(level);
          colors[p.index] = LXColor.hsb(hue.getValuef(), sat.getValuef(), level);
        }
      }
    }
  }

  //run method for columnNotes
  public void run(double deltaMs) {
    setColors(#000000);
  }
} 

@LXCategory("MIDI")
  //public class SectionNotes
  public class SectionNotes extends EnvelopPattern {

  //declarion of an array of noteLayers of the size of number of columns
  int arrSize = 4;
  int countChannels= 1; //keep track of number of channels
  private final RailLayer[] railLayer = new RailLayer[arrSize]; 

  //contructor for Class. It contains the midi info, attack and decay info
  public SectionNotes(LX lx) {
    super(lx);
    int rCnt = 0;
    int arrayCnt1 = 0;
    int arrayCnt2 = 0;
    int arrayCnt3 = 0;
    int arrayCnt4 = 0;

    Rail[] section1 = new Rail[12]; //sets array of section 1
    Rail[] section2 = new Rail[12]; //sets array of section 2
    Rail[] section3 = new Rail[12]; //sets array of section 3
    Rail[] section4 = new Rail[12]; //sets array of section 4
    for (Rail rail : model.rails) {
      if (rCnt == 0 || rCnt == 1 || rCnt == 2 || rCnt == 3 || rCnt == 4 || rCnt == 5 ||
        rCnt == 6 || rCnt == 7 || rCnt == 10 || rCnt == 11 || rCnt == 14 || rCnt == 15) {
        section1[arrayCnt1] = rail;
        ++arrayCnt1;
      } else if (rCnt == 8 || rCnt == 9 || rCnt == 12 || rCnt == 13 || rCnt == 16 || rCnt == 17 ||
        rCnt == 18 || rCnt == 19 || rCnt == 20 || rCnt == 21 || rCnt == 22 || rCnt == 23) {
        section2[arrayCnt2] = rail;
        ++arrayCnt2;
      } else if (rCnt == 24 || rCnt == 25 || rCnt == 26 || rCnt == 27 || rCnt == 28 || rCnt == 29 ||
        rCnt == 30 || rCnt == 31 || rCnt == 34 || rCnt == 35 || rCnt == 38 || rCnt == 39) {
        section3[arrayCnt3] = rail;
        ++arrayCnt3;
      } else if (rCnt ==32 || rCnt == 33 || rCnt == 36 || rCnt == 37 || rCnt == 40 || rCnt == 41 ||
        rCnt == 42 || rCnt == 43 || rCnt == 44 || rCnt == 45 || rCnt == 46 || rCnt == 47) {
        section4[arrayCnt4] = rail;
        ++arrayCnt4;
      }
      ++rCnt;
    } 

    //layer 1
    int c = 0;
    addLayer(railLayer[c] = new RailLayer(lx, section1 ));
    addParameter("attack-" + c, railLayer[c].attack);
    addParameter("decay-" + c, railLayer[c].decay);
    addParameter("hue-" + c, railLayer[c].hue);
    addParameter("sat-" + c, railLayer[c].sat);

    //layer 2
    int d = 1;
    addLayer(railLayer[d] = new RailLayer(lx, section2));
    addParameter("attack-" + d, railLayer[d].attack);
    addParameter("decay-" + d, railLayer[d].decay);
    addParameter("hue-" + d, railLayer[d].hue);
    addParameter("sat-" + d, railLayer[d].sat);

    //layer 3
    int e = 2;
    addLayer(railLayer[e] = new RailLayer(lx, section3));
    addParameter("attack-" + e, railLayer[e].attack);
    addParameter("decay-" + e, railLayer[e].decay);
    addParameter("hue-" + e, railLayer[e].hue);
    addParameter("sat-" + e, railLayer[e].sat);

    //layer 4
    int f = 3;
    addLayer(railLayer[f] = new RailLayer(lx, section4));
    addParameter("attack-" + f, railLayer[f].attack);
    addParameter("decay-" + f, railLayer[f].decay);
    addParameter("hue-" + f, railLayer[f].hue);
    addParameter("sat-" + f, railLayer[f].sat);
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(false);
    }
  }

  //sub class containing midi information
  private class RailLayer extends LXLayer {

    // variables containing attack, decay, envelope, Rail and modulator
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final CompoundParameter hue;
    private final CompoundParameter sat;
    private final ADEnvelope envelope;

    private final Rail[] rail;

    private final LXModulator vibrato = startModulator(new SinLFO(0.8, 1, 400));

    //contructor for midi information for each rail
    public RailLayer(LX lx, Rail[] rail) {
      super(lx);
      this.rail = rail;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-" + countChannels, 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-" + countChannels, 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.hue = (CompoundParameter)
        new CompoundParameter("Hue-" + countChannels, 0, 0, 360);

      this.sat = (CompoundParameter)
        new CompoundParameter("Sat-" + countChannels, 0, 0, 100.0);  

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);

      ++countChannels;
    }

    //run method for RingLayer class
    public void run(double deltaMs) {
      //float level = this.vibrato.getValuef() * this.envelope.getValuef(); get rid of vibrato
      //System.out.println("vibrato: " + this.vibrato.getValuef());
      float level = 1.0 * this.envelope.getValuef();
      for (Rail railArr : rail) {
        for (LXPoint p : railArr.points) {
          //colors[p.index] = LXColor.gray(level);
          colors[p.index] = LXColor.hsb(hue.getValuef(), sat.getValuef(), level);
        }
      }
    }
  }

  //run method for columnNotes
  public void run(double deltaMs) {
    setColors(#000000);
  }
}

@LXCategory("MIDI")
  public abstract class MeltMIDI extends NoteWavePattern {

  private final float[] multipliers = new float[32];

  public final CompoundParameter melt =
    new CompoundParameter("Melt", .5)
    .setDescription("Amount of melt distortion");

  private final LXModulator meltDamped = startModulator(new DampedParameter(this.melt, 2, 2, 1.5));

  private final LXModulator rot = startModulator(new SawLFO(0, 1, 39000));

  public MeltMIDI(LX lx) {
    super(lx);
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
}

@LXCategory("MIDI")
  public class MeltOutMIDI extends MeltMIDI {
  public MeltOutMIDI(LX lx) {
    super(lx);
  }

  protected float getDist(LXPoint p) {
    return 2*abs(p.yn - .5);
  }
}

@LXCategory("MIDI")
  public class MeltUpMIDI extends MeltMIDI {
  public MeltUpMIDI(LX lx) {
    super(lx);
  }

  protected float getDist(LXPoint p) {
    return p.yn;
  }
}

@LXCategory("MIDI")
  public class MeltDownMIDI extends MeltMIDI {
  public MeltDownMIDI(LX lx) {
    super(lx);
  }

  protected float getDist(LXPoint p) {
    return 1- p.yn;
  }
}

@LXCategory("MIDI")
  public class WavesMIDI extends NoteWavePattern {

  public WavesMIDI(LX lx) {
    super(lx);
  }
}

@LXCategory("MIDI")
  public abstract class NoteWavePattern extends WavePattern {
  private final ADSR adsr = new ADSR();
  public final CompoundParameter attack = adsr.attack;
  public final CompoundParameter decay = adsr.decay;
  public final CompoundParameter sustain = adsr.sustain;
  public final CompoundParameter release = adsr.release;

  public final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");

  protected final NormalizedParameter level = new NormalizedParameter("level"); 

  protected final ADSREnvelope envelope = new ADSREnvelope("Envelope", 0, this.level, this.attack, this.decay, this.sustain, this.release);

  private int notesDown = 0;
  private int damperNotes = 0;
  private boolean damperDown = false;

  protected NoteWavePattern(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
    addModulator(this.envelope);
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    ++this.notesDown;
    this.level.setValue(note.getVelocity() / 127.);
    this.envelope.attack();
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    if (this.damperDown) {
      ++this.damperNotes;
    } else {
      if (--this.notesDown == 0) {
        this.envelope.release();
      }
    }
  }

  @Override
    public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == MidiControlChange.DAMPER_PEDAL) {
      if (cc.getValue() > 0) {
        if (!this.damperDown) {
          this.damperDown = true;
        }
      } else {
        if (this.damperDown) {
          this.damperDown = false;
          this.notesDown -= this.damperNotes;
          this.damperNotes = 0;
          if (this.notesDown == 0) {
            this.envelope.release();
          }
        }
      }
    }
  }

  public float getLevel() {
    return this.envelope.getValuef();
  }
}

@LXCategory("MIDI")
  public class PulseMIDI extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  private final ADSR adsr = new ADSR();
  private final CompoundParameter attack = adsr.attack;
  private final CompoundParameter decay = adsr.decay;
  private final CompoundParameter sustain = adsr.sustain;
  private final CompoundParameter release = adsr.release;

  private final CompoundParameter velocityBrightness = new CompoundParameter("Vel>Brt", .5)
    .setDescription("Sets the amount of modulation from note velocity to brightness");

  private NormalizedParameter level = new NormalizedParameter("Level", 1); 
  private final ADSREnvelope envelope = new ADSREnvelope("Env", 0, this.level, this.attack, this.decay, this.sustain, this.release);

  public PulseMIDI(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("sustain", this.sustain);
    addParameter("release", this.release);
    addParameter("velocityBrightness", this.velocityBrightness);
    addModulator(this.envelope);
  }

  public void run(double deltaMs) {
    setColors(LXColor.gray(100 * this.envelope.getValuef()));
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    this.level.setValue(lerp(1, note.getVelocity() / 127., this.velocityBrightness.getNormalizedf()));
    this.envelope.engage.setValue(true);
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    this.envelope.engage.setValue(false);
  }
}

@LXCategory("MIDI")
  public class SnakesMIDI extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  final static int NUM_TUBE_GROUPS = 48; //set to number of tubes
  final static int NUM_PIX = 32; //set to number of pixels per tube

  private final LinearEnvelope[] branchGroups = new LinearEnvelope[NUM_TUBE_GROUPS];
  private final int[][] branchMasks = new int[NUM_TUBE_GROUPS][NUM_PIX]; 

  public final CompoundParameter speed =
    new CompoundParameter("Speed", 2000, 10000, 500)
    .setDescription("Speed of the snakes"); 

  public final CompoundParameter size =
    new CompoundParameter("Size", 10, 5, 80)
    .setDescription("Size of the snakes"); 

  private int branchRoundRobin = 0;

  public SnakesMIDI(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    for (int i = 0; i < this.branchGroups.length; ++i) {
      this.branchGroups[i] = (LinearEnvelope) addModulator(new LinearEnvelope(0, NUM_PIX + 40, speed));
    }
  }

  public void run(double deltaMs) {
    float falloff = 100 / this.size.getValuef();
    for (int i = 0; i < NUM_TUBE_GROUPS; ++i) {
      int[] mask = this.branchMasks[i];
      float pos = this.branchGroups[i].getValuef();
      float max = 100 * (1 - this.branchGroups[i].getBasisf());
      for (int j = 0; j < NUM_PIX; ++j) {
        float b = (j < pos) ? max(0, 100 - falloff * (pos - j)) : 0;
        mask[j] = LXColor.gray(b);
      }
    }

    // Copy into all masks
    int bi = 0;
    for (Rail rail : model.rails) {
      int li = 0;
      for (LXPoint p : rail.points) {
        setColor(p.index, this.branchMasks[bi % this.branchMasks.length][li]);
        ++li;
      }
      ++bi;
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    this.branchGroups[this.branchRoundRobin].trigger();
    this.branchRoundRobin = (this.branchRoundRobin + 1) % this.branchGroups.length;
  }
}

@LXCategory("MIDI")
  public class Seaboard extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter attack = (CompoundParameter)
    new CompoundParameter("Attack", 50, 25, 1000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the attack time of the notes");

  public final CompoundParameter decay = (CompoundParameter)
    new CompoundParameter("Decay", 500, 50, 3000)
    .setExponent(2)
    .setUnits(LXParameter.Units.MILLISECONDS)
    .setDescription("Sets the decay time of the notes");

  public final CompoundParameter size =
    new CompoundParameter("Size", 2*FEET, 1*FEET, 8*FEET)
    .setDescription("Size of the notes");

  private final Note[] notes = new Note[16];
  private final Note[] channelToNote = new Note[16];
  private int noteRoundRobin = 0;

  public Seaboard(LX lx) {
    super(lx);
    addParameter("attack", this.attack);
    addParameter("decay", this.decay);
    addParameter("size", this.size);
    for (int i = 0; i < this.notes.length; ++i) {
      this.channelToNote[i] = this.notes[i] = new Note();
    }
  }
  int numPixels = 48*32; 
  private final float[] b = new float[numPixels];

  private final int NUM_KEYS = 25;
  private final int CENTER_KEY = 60;

  private final float SPREAD = model.yRange / (NUM_KEYS + 6);

  public void run(double deltaMs) {
    for (int i = 0; i < b.length; ++i) {
      b[i] = 0;
    }
    float size = this.size.getValuef();

    // Iterate over each note
    for (Note note : this.notes) {
      float level = note.levelDamped.getValuef() * note.envelope.getValuef();
      if (level > 0) {
        float falloff = 100 / (size * (1 + 2 * note.slideDamped.getValuef()));
        int i = 0;
        float yp = model.cy + (note.pitch - CENTER_KEY + note.bendDamped.getValuef() * Note.BEND_RANGE) * SPREAD;
        for (Rail rail : model.rails) {
          for (LXPoint p : rail.points) {
            b[i] += max(0, level - falloff * abs(yp - p.y));
            ++i;
          }
        }
      }
    }

    // Set colors for a
    int i = 0;
    for (Rail rail : model.rails) {
      for (LXPoint p : rail.points) {
        setColor(p.index, LXColor.gray(min(100, b[i++])));
      }
    }
  }

  class Note {

    static final float BEND_RANGE = 48;

    private final NormalizedParameter level = new NormalizedParameter("Level");
    private final NormalizedParameter slide = new NormalizedParameter("Slide");
    private final BoundedParameter bend = new BoundedParameter("Bend", 0, -1, 1);

    final LXModulator bendDamped = startModulator(new DampedParameter(this.bend, .3, 1, .1));
    final LXModulator slideDamped = startModulator(new DampedParameter(this.slide, .3, 1));
    final LXModulator levelDamped = startModulator(new DampedParameter(this.level, .4));

    final ADEnvelope envelope = new ADEnvelope("Note", 0, 100, attack, decay);

    int pitch;

    Note() {
      addModulator(envelope);
    }
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    this.channelToNote[note.getChannel()] = this.notes[this.noteRoundRobin];
    this.noteRoundRobin = (this.noteRoundRobin + 1) % 16; 

    Note n = this.channelToNote[note.getChannel()];
    n.bend.setValue(0);
    n.bendDamped.setValue(0);
    n.slide.setValue(0);
    n.slideDamped.setValue(0);
    n.pitch = note.getPitch();
    n.level.setValue(note.getVelocity() / 127.f);
    n.levelDamped.setValue(note.getVelocity() / 127.f);
    n.envelope.engage.setValue(true);
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    Note n = this.channelToNote[note.getChannel()];
    n.level.setValue(n.levelDamped.getValue());
    n.envelope.engage.setValue(false);
  }

  @Override
    void aftertouchReceived(MidiAftertouch aftertouch) {
    // Wait until note attack stage is done...
    Note n = this.channelToNote[aftertouch.getChannel()];
    if (!n.envelope.isRunning()) {
      n.level.setValue(aftertouch.getAftertouch() / 127.f);
    }
  }

  @Override
    public void pitchBendReceived(MidiPitchBend pb) {
    this.channelToNote[pb.getChannel()].bend.setValue(pb.getNormalized());
  }

  @Override
    public void controlChangeReceived(MidiControlChange cc) {
    if (cc.getCC() == 74) {
      this.channelToNote[cc.getChannel()].slide.setValue(cc.getNormalized());
    }
  }
}

@LXCategory("MIDI")
  //public class SectionNotes
  public class Split4Notes extends EnvelopPattern {

  //declarion of an array of noteLayers of the size of number of columns
  int arrSize = 4;
  int countChannels= 1; //keep track of number of channels
  private final RailLayer[] railLayer = new RailLayer[arrSize]; 

  //contructor for Class. It contains the midi info, attack and decay info
  public Split4Notes(LX lx) {
    super(lx);
    int rCnt = 0;
    int arrayCnt1 = 0;
    int arrayCnt2 = 0;
    int arrayCnt3 = 0;
    int arrayCnt4 = 0;
    int pixSize = 32;
    int arrSize = 48;

    LXPoint[] section1 = new LXPoint[8 * arrSize]; //sets array of section 1
    LXPoint[] section2 = new LXPoint[8 * arrSize]; //sets array of section 2 
    LXPoint[] section3 = new LXPoint[8 * arrSize]; //sets array of section 3
    LXPoint[] section4 = new LXPoint[8 * arrSize]; //sets array of section 4
    //for (Rail rail : model.rails) {
    for (LXPoint p : model.points ) {
      if (rCnt < (pixSize * arrSize)) { //only interate over values that are tubes; no par cans
        if (rCnt % pixSize   >= 0 && rCnt % pixSize   < 8 ) {
          section1[arrayCnt1] = p;
          ++arrayCnt1;
        } else if (rCnt % pixSize   >= 8 && rCnt % pixSize   < 16 ) {
          section2[arrayCnt2] = p;
          ++arrayCnt2;
        } else if (rCnt % pixSize   >= 16 && rCnt % pixSize   < 24 ) {
          section3[arrayCnt3] = p;
          ++arrayCnt3;
        } else if (rCnt % pixSize   >= 24 && rCnt % pixSize   < 32 ) {
          section4[arrayCnt4] = p;
          ++arrayCnt4;
        }
        ++rCnt;
      }
    }  
    //} 

    //layer 1
    int c = 0;
    addLayer(railLayer[c] = new RailLayer(lx, section1 ));
    addParameter("attack-" + c, railLayer[c].attack);
    addParameter("decay-" + c, railLayer[c].decay);
    addParameter("hue-" + c, railLayer[c].hue);
    addParameter("sat-" + c, railLayer[c].sat);

    //layer 2
    int d = 1;
    addLayer(railLayer[d] = new RailLayer(lx, section2));
    addParameter("attack-" + d, railLayer[d].attack);
    addParameter("decay-" + d, railLayer[d].decay);
    addParameter("hue-" + d, railLayer[d].hue);
    addParameter("sat-" + d, railLayer[d].sat);

    //layer 3
    int e = 2;
    addLayer(railLayer[e] = new RailLayer(lx, section3));
    addParameter("attack-" + e, railLayer[e].attack);
    addParameter("decay-" + e, railLayer[e].decay);
    addParameter("hue-" + e, railLayer[e].hue);
    addParameter("sat-" + e, railLayer[e].sat);

    //layer 4
    int f = 3;
    addLayer(railLayer[f] = new RailLayer(lx, section4));
    addParameter("attack-" + f, railLayer[f].attack);
    addParameter("decay-" + f, railLayer[f].decay);
    addParameter("hue-" + f, railLayer[f].hue);
    addParameter("sat-" + f, railLayer[f].sat);
  }

  @Override
    public void noteOnReceived(MidiNoteOn note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(true);
    }
  }

  @Override
    public void noteOffReceived(MidiNote note) {
    int channel = note.getChannel();
    if (channel < this.railLayer.length) {
      this.railLayer[channel].envelope.engage.setValue(false);
    }
  }

  //sub class containing midi information
  private class RailLayer extends LXLayer {

    // variables containing attack, decay, envelope, Rail and modulator
    private final CompoundParameter attack;
    private final CompoundParameter decay;
    private final CompoundParameter hue;
    private final CompoundParameter sat;
    private final ADEnvelope envelope;

    private final LXPoint[] lxPoints;

    private final LXModulator vibrato = startModulator(new SinLFO(0.8, 1, 400));

    //contructor for midi information for each rail
    public RailLayer(LX lx, LXPoint[] lxPoints) {
      super(lx);
      this.lxPoints = lxPoints;

      this.attack = (CompoundParameter)
        new CompoundParameter("Atk-" + countChannels, 50, 25, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the attack time of the flash");

      this.decay = (CompoundParameter)
        new CompoundParameter("Dcy-" + countChannels, 1000, 50, 2000)
        .setExponent(4)
        .setUnits(LXParameter.Units.MILLISECONDS)
        .setDescription("Sets the decay time of the flash");

      this.hue = (CompoundParameter)
        new CompoundParameter("Hue-" + countChannels, 0, 0, 360);

      this.sat = (CompoundParameter)
        new CompoundParameter("Sat-" + countChannels, 0, 0, 100.0);  

      this.envelope = new ADEnvelope("Env", 0, new FixedParameter(100), attack, decay);

      addModulator(this.envelope);

      ++countChannels;
    }

    //run method for RingLayer class
    public void run(double deltaMs) {
      //float level = this.vibrato.getValuef() * this.envelope.getValuef(); get rid of vibrato
      //System.out.println("vibrato: " + this.vibrato.getValuef());
      float level = 1.0 * this.envelope.getValuef();
      //for (Rail railArr : rail) {
      for (LXPoint p : lxPoints) {
        //colors[p.index] = LXColor.gray(level);
        colors[p.index] = LXColor.hsb(hue.getValuef(), sat.getValuef(), level);
      }
      //}
    }
  }

  //run method for columnNotes
  public void run(double deltaMs) {
    setColors(#000000);
  }
}
