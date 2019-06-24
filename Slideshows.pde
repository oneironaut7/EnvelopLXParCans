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
