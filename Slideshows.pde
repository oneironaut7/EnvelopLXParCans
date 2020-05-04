@LXCategory("Slideshow")
public abstract class ColorSlideshow extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3000, 10000, 250);

  private final SawLFO lerp = (SawLFO) startModulator(new SawLFO(0, 1, rate));

  private int imageIndex;
  private final PImage[] images;
  
  public ColorSlideshow(LX lx) {
    super(lx);
    String[] paths = getPaths();
    this.images = new PImage[paths.length];
    for (int i = 0; i < this.images.length; ++i) {
      this.images[i] = loadImage(paths[i]);
      this.images[i].loadPixels();
    }
    addParameter("rate", this.rate);
    this.imageIndex = 0;
  }
  
  abstract String[] getPaths();
  
  public void run(double deltaMs) {
    float lerp = this.lerp.getValuef();
    if (this.lerp.loop()) {
      this.imageIndex = (this.imageIndex + 1) % this.images.length;
    }
    PImage image1 = this.images[this.imageIndex];
    PImage image2 = this.images[(this.imageIndex + 1) % this.images.length];
    
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;
    
   for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      int c1 = image1.get(
        (int) (p.xn * (image1.width-1)),
        (int) ((1-p.zn) * (image1.height-1))
      );
      int c2 = image2.get(
        (int) (p.xn * (image2.width-1)),
        (int) ((1-p.zn) * (image2.height-1))
      );
      final_num = (strandnum *64) + pixnum;
      //println(final_num);
      colors[final_num]= LXColor.lerp(c1, c2, lerp); //(setColor(strand, LXColor.lerp(c1, c2, lerp));
      ++pixnum;
     }
     //++strandnum;
    }
   }
  }
}
@LXCategory("Slideshow")
public class ColorSlideshowClouds extends ColorSlideshow {
  public ColorSlideshowClouds(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "clouds1.jpeg",
      "clouds2.jpeg",
      "clouds3.jpeg"
      
    };
  }
}
@LXCategory("Slideshow")
public class ColorSlideshowSunsets extends ColorSlideshow {
  public ColorSlideshowSunsets(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "sunset1.jpeg",
      "sunset2.jpeg",
      "sunset3.jpeg",
      "sunset4.jpeg",
      "sunset5.jpeg",
      "sunset6.jpeg"
    };
  }
}
@LXCategory("Slideshow")
public class ColorSlideshowOceans extends ColorSlideshow {
  public ColorSlideshowOceans(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "ocean1.jpeg",
      "ocean2.jpeg",
      "ocean3.jpeg",
      "ocean4.jpeg"
    };
  }
}
@LXCategory("Slideshow")
public class ColorSlideshowCorals extends ColorSlideshow {
  public ColorSlideshowCorals(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "coral1.jpeg",
      "coral2.jpeg",
      "coral3.jpeg",
      "coral4.jpeg",
      "coral5.jpeg"
    };
  }
}

@LXCategory("Slideshow")
public class TestSlides extends ColorSlideshow {
  public TestSlides(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "black_blue_lines.jpg",
      "red_honeycomb.png",
      "RainbowGradient13.jpg",
      "polkadots1.png",
      "pinkDot.png",
      "panels3.png",
      "test.png"
    };
  }
}

@LXCategory("Slideshow")
public abstract class ColorSlideshowY extends EnvelopPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
    
  public final CompoundParameter rate =
    new CompoundParameter("Rate", 3000, 10000, 250);

  private final SawLFO lerp = (SawLFO) startModulator(new SawLFO(0, 1, rate));

  private int imageIndex;
  private final PImage[] images;
  
  public ColorSlideshowY(LX lx) {
    super(lx);
    String[] paths = getPaths();
    this.images = new PImage[paths.length];
    for (int i = 0; i < this.images.length; ++i) {
      this.images[i] = loadImage(paths[i]);
      this.images[i].loadPixels();
    }
    addParameter("rate", this.rate);
    this.imageIndex = 0;
  }
  
  abstract String[] getPaths();
  
  public void run(double deltaMs) {
    float lerp = this.lerp.getValuef();
    if (this.lerp.loop()) {
      this.imageIndex = (this.imageIndex + 1) % this.images.length;
    }
    PImage image1 = this.images[this.imageIndex];
    PImage image2 = this.images[(this.imageIndex + 1) % this.images.length];
    
    int pixnum = 0;
    int strandnum = 0;
    int final_num = 0;
    
   for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
        for (LXPoint p : rail.points) {
      int c1 = image1.get(
        (int) (p.yn * (image1.width-1)),
        (int) ((1-p.zn) * (image1.height-1))
      );
      int c2 = image2.get(
        (int) (p.yn * (image2.width-1)),
        (int) ((1-p.zn) * (image2.height-1))
      );
      final_num = (strandnum *64) + pixnum;
      //println(final_num);
      colors[final_num]= LXColor.lerp(c1, c2, lerp); //(setColor(strand, LXColor.lerp(c1, c2, lerp));
      ++pixnum;
     }
     //++strandnum;
    }
   }
  }
}
@LXCategory("Slideshow")
public class YColorSlideshowClouds extends ColorSlideshowY {
  public YColorSlideshowClouds(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "clouds1.jpeg",
      "clouds2.jpeg",
      "clouds3.jpeg"
      
    };
  }
}
@LXCategory("Slideshow")
public class YColorSlideshowSunsets extends ColorSlideshowY {
  public YColorSlideshowSunsets(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "sunset1.jpeg",
      "sunset2.jpeg",
      "sunset3.jpeg",
      "sunset4.jpeg",
      "sunset5.jpeg",
      "sunset6.jpeg"
    };
  }
}
@LXCategory("Slideshow")
public class YColorSlideshowOceans extends ColorSlideshowY {
  public YColorSlideshowOceans(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "ocean1.jpeg",
      "ocean2.jpeg",
      "ocean3.jpeg",
      "ocean4.jpeg"
    };
  }
}
@LXCategory("Slideshow")
public class YColorSlideshowCorals extends ColorSlideshowY {
  public YColorSlideshowCorals(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "coral1.jpeg",
      "coral2.jpeg",
      "coral3.jpeg",
      "coral4.jpeg",
      "coral5.jpeg"
    };
  }
}

@LXCategory("Slideshow")
public class YTestSlides extends ColorSlideshowY {
  public YTestSlides(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "black_blue_lines.jpg",
      "red_honeycomb.png",
      "RainbowGradient13.jpg",
      "Rainbow.jpg",
      "polkadots1.png",
      "pinkDot.png",
      "panels3.png",
      "test.png"
    };
  }
}
@LXCategory("Slideshow")
public class YColorStripes extends ColorSlideshowY {
  public YColorStripes(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "stripes-yellow-lines-streaks-blue-1280x800-c2-f0f000-0000ff-l2-76-107-a-210-f-1.jpg",
      "purple-lines-blue-streaks-stripes-1280x800-c2-ff00ff-0000ff-l2-76-107-a-210-f-1.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class YColorPolkaDots extends ColorSlideshowY {
  public YColorPolkaDots(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "yellow-dots-polka-pink-spots-1280x800-c2-934d7d-e5cd57-l2-47-121-a-105-f-3.jpg",
      "pink-polka-green-dots-spots-1280x800-c2-f34d7d-008080-l2-47-121-a-105-f-3.jpg",
      "polka-dots-spots-magenta-green-1280x800-c2-a34dad-008080-l2-47-121-a-105-f-3.jpg",
      "polka-spots-cyan-magenta-dots-1280x800-c2-a34dad-00a0a0-l2-47-121-a-105-f-3.jpg",
      "yellow-blue-spots-polka-dots-1280x800-c2-0000ff-f0f000-l2-47-121-a-105-f-3.jpg",
      "yellow-magenta-spots-polka-dots-1280x800-c2-f000ff-f0f000-l2-47-121-a-105-f-3.jpg",
      "spots-magenta-yellow-polka-dots-1280x800-c2-80008f-f0f000-l2-47-121-a-105-f-3.jpg",
      "dots-spots-orange-polka-purple-1280x800-c2-800080-ff9000-l2-47-121-a-105-f-3.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class YColorArgyle extends ColorSlideshowY {
  public YColorArgyle(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "argyle-green-blue-lines-yellow-diamonds-1280x800-c3-f0f000-008000-000fff-l3-164-229-8-a-75-f-17.jpg",
      "lines-blue-green-argyle-yellow-diamonds-1280x800-c3-008000-000fff-f0f000-l3-164-229-8-a-75-f-17.jpg",
      "magenta-lines-diamonds-blue-argyle-green-1280x800-c3-008000-000fff-a000a0-l3-164-229-8-a-75-f-17.jpg",
      "green-magenta-blue-argyle-lines-diamonds-1280x800-c3-008000-a000a0-000fff-l3-164-229-8-a-75-f-17.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class YColorBursts extends ColorSlideshowY {
  public YColorBursts(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "sunburst-rays-blue-burst-1280x800-c2-161055-200ed1-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "rays-burst-blue-yellow-sunburst-1280x800-c2-c0c000-200ed1-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "burst-sunburst-yellow-blue-rays-1280x800-c2-200ed1-c0c000-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "burst-green-yellow-sunburst-rays-1280x800-c2-228b22-c0c000-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "rays-burst-green-violet-sunburst-1280x800-c2-228b22-8000ff-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "violet-burst-blue-sunburst-rays-1280x800-c2-0000ff-8000ff-k2-50-50-l2-15-0-a-6-f-22.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class YColorCircles extends ColorSlideshowY {
  public YColorCircles(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "circles-concentric-rings-azure-violet-1280x800-c2-1f72b8-aa0efb-k2-50-50-l-88-f-25.jpg",
      "circles-rings-concentric-cyan-violet-1280x800-c2-00a0a0-aa0efb-k2-50-50-l-88-f-25.jpg",
      "rings-circles-yellow-violet-concentric-1280x800-c2-800eff-c0c000-k2-50-50-l-88-f-25.jpg",
      "cyan-rings-circles-concentric-violet-1280x800-c2-aa0efb-00a0a0-k2-50-50-l-88-f-25.jpg",
      "concentric-rings-green-violet-circles-1280x800-c2-800eff-228b22-k2-50-50-l-88-f-25.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class ColorStripes extends ColorSlideshow {
  public ColorStripes(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "lines-streaks-purple-yellow-stripes-1920x1080-c2-fcd60d-800080-l2-76-107-a-210-f-1.jpg",
      "stripes-yellow-lines-streaks-blue-1280x800-c2-f0f000-0000ff-l2-76-107-a-210-f-1.jpg",
      "purple-lines-blue-streaks-stripes-1280x800-c2-ff00ff-0000ff-l2-76-107-a-210-f-1.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class ColorPolkaDots extends ColorSlideshow {
  public ColorPolkaDots(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "yellow-dots-polka-pink-spots-1280x800-c2-934d7d-e5cd57-l2-47-121-a-105-f-3.jpg",
      "pink-polka-green-dots-spots-1280x800-c2-f34d7d-008080-l2-47-121-a-105-f-3.jpg",
      "polka-dots-spots-magenta-green-1280x800-c2-a34dad-008080-l2-47-121-a-105-f-3.jpg",
      "polka-spots-cyan-magenta-dots-1280x800-c2-a34dad-00a0a0-l2-47-121-a-105-f-3.jpg",
      "yellow-blue-spots-polka-dots-1280x800-c2-0000ff-f0f000-l2-47-121-a-105-f-3.jpg",
      "yellow-magenta-spots-polka-dots-1280x800-c2-f000ff-f0f000-l2-47-121-a-105-f-3.jpg",
      "spots-magenta-yellow-polka-dots-1280x800-c2-80008f-f0f000-l2-47-121-a-105-f-3.jpg",
      "dots-spots-orange-polka-purple-1280x800-c2-800080-ff9000-l2-47-121-a-105-f-3.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class ColorArgyle extends ColorSlideshow {
  public ColorArgyle(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "argyle-green-blue-lines-yellow-diamonds-1280x800-c3-f0f000-008000-000fff-l3-164-229-8-a-75-f-17.jpg",
      "lines-blue-green-argyle-yellow-diamonds-1280x800-c3-008000-000fff-f0f000-l3-164-229-8-a-75-f-17.jpg",
      "magenta-lines-diamonds-blue-argyle-green-1280x800-c3-008000-000fff-a000a0-l3-164-229-8-a-75-f-17.jpg",
      "green-magenta-blue-argyle-lines-diamonds-1280x800-c3-008000-a000a0-000fff-l3-164-229-8-a-75-f-17.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class ColorBursts extends ColorSlideshow {
  public ColorBursts(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "sunburst-rays-blue-burst-1280x800-c2-161055-200ed1-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "rays-burst-blue-yellow-sunburst-1280x800-c2-c0c000-200ed1-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "burst-sunburst-yellow-blue-rays-1280x800-c2-200ed1-c0c000-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "burst-green-yellow-sunburst-rays-1280x800-c2-228b22-c0c000-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "rays-burst-green-violet-sunburst-1280x800-c2-228b22-8000ff-k2-50-50-l2-15-0-a-6-f-22.jpg",
      "violet-burst-blue-sunburst-rays-1280x800-c2-0000ff-8000ff-k2-50-50-l2-15-0-a-6-f-22.jpg"
      
    };
  }
}

@LXCategory("Slideshow")
public class ColorCircles extends ColorSlideshow {
  public ColorCircles(LX lx) {
    super(lx);
  }
  
  public String[] getPaths() {
    return new String[] {
      "circles-concentric-rings-azure-violet-1280x800-c2-1f72b8-aa0efb-k2-50-50-l-88-f-25.jpg",
      "circles-rings-concentric-cyan-violet-1280x800-c2-00a0a0-aa0efb-k2-50-50-l-88-f-25.jpg",
      "rings-circles-yellow-violet-concentric-1280x800-c2-800eff-c0c000-k2-50-50-l-88-f-25.jpg",
      "cyan-rings-circles-concentric-violet-1280x800-c2-aa0efb-00a0a0-k2-50-50-l-88-f-25.jpg",
      "concentric-rings-green-violet-circles-1280x800-c2-800eff-228b22-k2-50-50-l-88-f-25.jpg"
      
    };
  }
}
