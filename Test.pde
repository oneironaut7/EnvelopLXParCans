@LXCategory("Test")
//This is the Class declaration
public static class Test extends LXPattern {
  
  final CompoundParameter thing = new CompoundParameter("Thing", 0, model.yRange);
  final CompoundParameter hue = new CompoundParameter("Hue", 0, 0, 360);
  final CompoundParameter saturation = new CompoundParameter("Saturation", 100, 0, 100);
  
  //This is a Contructor Method!!
  public Test(LX lx) {
    super(lx);
    addParameter(thing); //instance field/variable
    addParameter(hue);
    addParameter(saturation);
  }
  
  //This is the Method
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = LXColor.hsb( hue.getValuef() , saturation.getValuef(),max(0, 100 - 10*abs(p.y - thing.getValuef())));
     // System.out.println("Tom is an expert coder biiiitch");
      //System.out.println(hue.getValuef());
    }
  }
}
//---Tom Patterns LOL
@LXCategory("Test") 
public class TubeSelect extends EnvelopPattern {
  public String getAuthor() {
    return "Tom Montagliano";
  }
 
  public final DiscreteParameter tube_num = 
    new DiscreteParameter("Tube",1,1,49);
    
  public TubeSelect(LX lx) {
    super(lx);
    addParameter("Tube", this.tube_num);
  }
  
  public void run(double deltaMs) {
    float tcnt = 1;
    float tnum = tube_num.getValuef(); 
    for (Column column : venue.columns) {
      for (Rail rail : column.rails) {
          if (tcnt == tnum) {
          setColor(rail, #FFFFFF);
          } else {
          setColor(rail, #000000);
          }  
          ++tcnt;  
      }  
    }
  }
}
@LXCategory("Test") 
public class ParSelect extends EnvelopPattern {
  public String getAuthor() {
    return "Tom Montagliano";
  }
 
  public final DiscreteParameter par_num = 
    new DiscreteParameter("Par",1,1,3);
    
  public ParSelect(LX lx) {
    super(lx);
    addParameter("Par", this.par_num);
  }
  
  public void run(double deltaMs) {
    float tcnt = 1;
    float tnum = par_num.getValuef(); 
    for (Par par : model.pars) {
      //for (Rail rail : column.rails) {
          if (tcnt == tnum) {
          setColor(par, #FFFFFF);
          } else {
          setColor(par, #000000);
          }  
          ++tcnt;  
     // }  
    }
  }
}
@LXCategory("Test") 
public class ColumnSelect extends EnvelopPattern {
  public String getAuthor() {
    return "Tom Montagliano";
  }
    
  public final DiscreteParameter col_num = 
    new DiscreteParameter("Column",1,1,5);
    
  public ColumnSelect(LX lx) {
    super(lx);
    addParameter("Column", this.col_num);
  }
  
  public void run(double deltaMs) {
    float ccnt = 1;
    float cnum = col_num.getValuef(); 
    for (Column column : venue.columns) {
      if (ccnt == cnum) {
          setColor(column, #FFFFFF);
          } else {
          setColor(column, #000000);
          }  
          ++ccnt;  
    }
  }
}

@LXCategory("Test")
public class PixelSelect
  extends LXPattern
{
  public final DiscreteParameter tube = new DiscreteParameter("Tube", 1, 1, 49);
  public final DiscreteParameter pixel = new DiscreteParameter("Pixel", 1, 1, 65);
  
  public PixelSelect(LX paramLX)
  {
    super(paramLX);
    addParameter("tube", tube);
    addParameter("pixel", pixel);
  }
  
  public void run(double paramDouble)
  {
    int pixnum = (int)pixel.getValuei()-1;
    int tubenum = (int)tube.getValuei()-1;
    int final_num = (tubenum * 64) + pixnum;
    
    for (int j = 0; j < colors.length; j++) {
      colors[j] = (j == final_num ? -1 : -16777216);
    }
  }
}

@LXCategory("Test")
//test to try to group rails into arrays
public class GroupSelect extends EnvelopPattern {
  public String getAuthor() {
    return "Tom Montaglianololololol";
  }
 
  public final DiscreteParameter tube_num = 
    new DiscreteParameter("Tube",1,1,49);
    
  public GroupSelect(LX lx) {
    super(lx);
    addParameter("Tube", this.tube_num);
     
  }
  
  public void run(double deltaMs) {
    int rCnt = 0;
    int arrayCnt = 0;
    int blueCnt = 0;
    Rail[] rTest = new Rail[3]; //sets array of Rails
    Rail[] rTestBlue = new Rail[4]; //sets another array of Rails
    for (Rail rail : model.rails) {
      if (rCnt == 3 || rCnt == 27 || rCnt == 45){
        rTest[arrayCnt] = rail;
        ++arrayCnt;
      }  else if (rCnt == 12 || rCnt == 33 || rCnt == 40 || rCnt == 42){
         rTestBlue[blueCnt] = rail;
        ++blueCnt;
      }  
      ++rCnt;
    }  
    int t =0;
    for (Rail rail: rTest) {
      rail = rTest[t];
      setColor(rail, #FFFFFF); 
      ++t;
    }  
    
    int c = 0; 
    for (Rail rail: rTestBlue) {
      rail = rTestBlue[c];
      setColor(rail, #0000FF);   
      ++c;
    }
  }
}
