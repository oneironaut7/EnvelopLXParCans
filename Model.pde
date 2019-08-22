import java.util.Arrays;
import java.util.Collections;
import java.util.List;

final static float INCHES = 1;
final static float FEET = 12*INCHES;

EnvelopModel getModel() {
  switch (environment) {
  case SATELLITE: return new Satellite();
  }
  return null;
}

//*******************************************************************
//*******************************************************************
//*******************************************************************

static abstract class EnvelopModel extends LXModel {
    
  static abstract class Config {
    
    static class Rail {
      public final PVector position;
      public final int numPoints;
      public final float pointSpacing;
      
      Rail(PVector position, int numPoints, float pointSpacing) {
        this.position = position;
        this.numPoints = numPoints;
        this.pointSpacing = pointSpacing;
      }
    }
    static class Par {
      public final PVector position;
      public final int numPoints;
      public final float pointSpacing;
      
      Par(PVector position, int numPoints, float pointSpacing) {
        this.position = position;
        this.numPoints = numPoints;
        this.pointSpacing = pointSpacing;
      }
    }
    
    public abstract PVector[] getColumns();
    public abstract PVector[] getParCans();
    public abstract float[] getArcs();
    public abstract Rail[] getRails();
    public abstract Par[] getPars();
  }
  
  public final List<Column> columns;
  public final List<ParCan> parcans;
  //public final List<Arc> arcs;
  public final List<Rail> rails;
  public final List<Par> pars;
  public final List<LXPoint> railPoints;
  public final List<LXPoint> parPoints;
  
  protected EnvelopModel(Config config) {
    super(new Fixture(config));
    Fixture f = (Fixture) fixtures.get(0);
    columns = Collections.unmodifiableList(Arrays.asList(f.columns));
    parcans = Collections.unmodifiableList(Arrays.asList(f.parcans));
   // final Arc[] arcs = new Arc[columns.size() * config.getArcs().length];
    final Rail[] rails = new Rail[columns.size() * config.getRails().length];
    final Par[] pars = new Par[columns.size() * config.getPars().length];
    final List<LXPoint> railPoints = new ArrayList<LXPoint>();
    final List<LXPoint> parPoints = new ArrayList<LXPoint>();
    int a = 0;
    int r = 0;
    for (Column column : columns) {
      //for (Arc arc : column.arcs) {
     //   arcs[a++] = arc;
     // }
      for (Rail rail : column.rails) {
        rails[r++] = rail;
        for (LXPoint p : rail.points) {
          railPoints.add(p);
        }
      }
    }
    
    r = 0;
    for (ParCan parcan : parcans) {
      for (Par par : parcan.pars) {
        pars[r++] = par;
        for (LXPoint p : par.points) {
          parPoints.add(p);
        }
      }
    }
    //this.arcs = Collections.unmodifiableList(Arrays.asList(arcs));
    this.rails = Collections.unmodifiableList(Arrays.asList(rails));
    this.pars = Collections.unmodifiableList(Arrays.asList(pars));
    this.railPoints = Collections.unmodifiableList(railPoints);
    this.parPoints = Collections.unmodifiableList(parPoints);
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    final Column[] columns;
    final ParCan[] parcans;
    
    Fixture(Config config) {
      columns = new Column[config.getColumns().length];
      parcans = new ParCan[config.getParCans().length];
      LXTransform transform = new LXTransform();
      int ci = 0;
      for (PVector pv : config.getColumns()) {
        transform.push();
        transform.translate(pv.x, 0, pv.y);
        float theta = atan2(pv.y, pv.x) - HALF_PI;
        transform.rotateY(-theta);
        addPoints(columns[ci] = new Column(config, ci, transform, theta));
        transform.pop();
        ++ci;
      }
      int cj = 0;
      for (PVector pv : config.getParCans()) {
        transform.push();
        transform.translate(pv.x, 0, pv.y);
        float theta = atan2(pv.y, pv.x) - HALF_PI;
        transform.rotateY(-theta);
        addPoints(parcans[cj] = new ParCan(config, cj, transform, theta));
        transform.pop();
        ++cj;
      }
    }
  }
  
  
}  



static class Satellite extends EnvelopModel {
  
  final static float EDGE_LENGTH = 8*FEET;
  final static float HALF_EDGE_LENGTH = EDGE_LENGTH / 2;
  final static float INCIRCLE_RADIUS = HALF_EDGE_LENGTH + EDGE_LENGTH / sqrt(2);
  final static int TUBE_LENGTH = 32;
  final static float dtr = (2*PI)/360; //degrees to radians
  // outer perimeter design
  final static float radius = 3 ;
  final static float numtubes= 16; //number of tubes
  final static float ratio= (360/numtubes) * dtr;
  
  // 3 inner circles design
  //circle 1
  final static float radius1 = 11.5 ;
  final static float numtubes1= 12; //number of tubes
  final static float ratio1= (360/numtubes1) * dtr;
  //circle 2
  final static float radius2 = 15.2 ;
  final static float numtubes2= 16; //number of tubes
  final static float ratio2= (360/numtubes2) * dtr;
  final static float offset2 = 0; //-11.25 *dtr ; //offset in radians;
  //circle 3
  final static float radius3 = 19.1 ;
  final static float numtubes3= 20; //number of tubes
  final static float ratio3= (360/numtubes3) * dtr;
  
  //8 Kamishees
  //circle 3
  final static float radius4 = 19.1 ;
  final static float numtubes4= 8; //number of tubes
  final static float ratio4= (360/numtubes4) * dtr;
  
  final static PVector[] COLUMN_POSITIONS = {
    new PVector( 0, 0,  101)
  };
  final static PVector[] PARCAN_POSITIONS = {
    new PVector( 0, 0,  101)
  };
  /*
  final static PVector[] COLUMN_POSITIONS;
  static {
    float ratio = (INCIRCLE_RADIUS - Column.RADIUS - 6*INCHES) / INCIRCLE_RADIUS;
    COLUMN_POSITIONS = new PVector[PLATFORM_POSITIONS.length];
    for (int i = 0; i < PLATFORM_POSITIONS.length; ++i) {
      COLUMN_POSITIONS[i] = PLATFORM_POSITIONS[i].copy().mult(ratio);
    }
  };*/
  
  final static float POINT_SPACING = 1.31233596*INCHES;
  
  final static EnvelopModel.Config.Rail[] RAILS = {
   /* new EnvelopModel.Config.Rail(new PVector(0, 0, 0), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(-1.5, 0, 0), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(1.5, 0, 0), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(-2, 0, 2), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(-.75, 0, 2), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(.75, 0, 2), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(2, 0, 2), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(-3, 0, 4), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(-1.5, 0, 4), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(0, 0, 4), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(1.5, 0, 4), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(3, 0, 4), TUBE_LENGTH, POINT_SPACING)*/
    /*
    new EnvelopModel.Config.Rail(new PVector(radius* sin(0*ratio), 0, radius* cos(0*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(1*ratio), 0, radius* cos(1*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(2*ratio), 0, radius* cos(2*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(3*ratio), 0, radius* cos(3*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(4*ratio), 0, radius* cos(4*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(5*ratio), 0, radius* cos(5*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(6*ratio), 0, radius* cos(6*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(7*ratio), 0, radius* cos(7*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(8*ratio), 0, radius* cos(8*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(9*ratio), 0, radius* cos(9*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(10*ratio), 0, radius* cos(10*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(11*ratio), 0, radius* cos(11*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(12*ratio), 0, radius* cos(12*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(13*ratio), 0, radius* cos(13*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(14*ratio), 0, radius* cos(14*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(15*ratio), 0, radius* cos(15*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(16*ratio), 0, radius* cos(16*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(17*ratio), 0, radius* cos(17*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(18*ratio), 0, radius* cos(18*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(19*ratio), 0, radius* cos(19*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(20*ratio), 0, radius* cos(20*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(21*ratio), 0, radius* cos(21*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(22*ratio), 0, radius* cos(22*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(23*ratio), 0, radius* cos(23*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(24*ratio), 0, radius* cos(24*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(25*ratio), 0, radius* cos(25*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(26*ratio), 0, radius* cos(26*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(27*ratio), 0, radius* cos(27*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(28*ratio), 0, radius* cos(28*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(29*ratio), 0, radius* cos(29*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(30*ratio), 0, radius* cos(30*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(31*ratio), 0, radius* cos(31*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(32*ratio), 0, radius* cos(32*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(33*ratio), 0, radius* cos(33*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(34*ratio), 0, radius* cos(34*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(35*ratio), 0, radius* cos(35*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(36*ratio), 0, radius* cos(36*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(37*ratio), 0, radius* cos(37*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(38*ratio), 0, radius* cos(38*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(39*ratio), 0, radius* cos(39*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(40*ratio), 0, radius* cos(40*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(41*ratio), 0, radius* cos(41*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(42*ratio), 0, radius* cos(42*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(43*ratio), 0, radius* cos(43*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(44*ratio), 0, radius* cos(44*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(45*ratio), 0, radius* cos(45*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(46*ratio), 0, radius* cos(46*ratio)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius* sin(47*ratio), 0, radius* cos(47*ratio)), TUBE_LENGTH, POINT_SPACING)*/
    /*
    // section 1
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(0*ratio1), 0, radius1* cos(0*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(1*ratio1), 0, radius1* cos(1*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(2*ratio1), 0, radius1* cos(2*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(0*ratio2 + offset2), 0, radius2* cos(0*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(1*ratio2 + offset2), 0, radius2* cos(1*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(2*ratio2 + offset2), 0, radius2* cos(2*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(3*ratio2 + offset2), 0, radius2* cos(3*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(0*ratio3), 0, radius3* cos(0*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(1*ratio3), 0, radius3* cos(1*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(2*ratio3), 0, radius3* cos(2*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(3*ratio3), 0, radius3* cos(3*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(4*ratio3), 0, radius3* cos(4*ratio3)), TUBE_LENGTH, POINT_SPACING),
    
    //section 2
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(3*ratio1), 0, radius1* cos(3*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(4*ratio1), 0, radius1* cos(4*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(5*ratio1), 0, radius1* cos(5*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(4*ratio2 + offset2), 0, radius2* cos(4*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(5*ratio2 + offset2), 0, radius2* cos(5*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(6*ratio2 + offset2), 0, radius2* cos(6*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(7*ratio2 + offset2), 0, radius2* cos(7*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(5*ratio3), 0, radius3* cos(5*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(6*ratio3), 0, radius3* cos(6*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(7*ratio3), 0, radius3* cos(7*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(8*ratio3), 0, radius3* cos(8*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(9*ratio3), 0, radius3* cos(9*ratio3)), TUBE_LENGTH, POINT_SPACING),
    
    //section 3
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(6*ratio1), 0, radius1* cos(6*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(7*ratio1), 0, radius1* cos(7*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(8*ratio1), 0, radius1* cos(8*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(8*ratio2 + offset2), 0, radius2* cos(8*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(9*ratio2 + offset2), 0, radius2* cos(9*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(10*ratio2 + offset2), 0, radius2* cos(10*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(11*ratio2 + offset2), 0, radius2* cos(11*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(10*ratio3), 0, radius3* cos(10*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(11*ratio3), 0, radius3* cos(11*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(12*ratio3), 0, radius3* cos(12*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(13*ratio3), 0, radius3* cos(13*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(14*ratio3), 0, radius3* cos(14*ratio3)), TUBE_LENGTH, POINT_SPACING),
    
    //section 4
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(9*ratio1), 0, radius1* cos(9*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(10*ratio1), 0, radius1* cos(10*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(11*ratio1), 0, radius1* cos(11*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(12*ratio2 + offset2), 0, radius2* cos(12*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(13*ratio2 + offset2), 0, radius2* cos(13*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(14*ratio2 + offset2), 0, radius2* cos(14*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(15*ratio2 + offset2), 0, radius2* cos(15*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(15*ratio3), 0, radius3* cos(15*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(16*ratio3), 0, radius3* cos(16*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(17*ratio3), 0, radius3* cos(17*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(18*ratio3), 0, radius3* cos(18*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(19*ratio3), 0, radius3* cos(19*ratio3)), TUBE_LENGTH, POINT_SPACING)*/
    //Home 8 Kamish
    /*
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(0*ratio4), 0, radius4* cos(0*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(1*ratio4), 0, radius4* cos(1*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(2*ratio4), 0, radius4* cos(2*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(3*ratio4), 0, radius4* cos(3*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(4*ratio4), 0, radius4* cos(4*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(5*ratio4), 0, radius4* cos(5*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(6*ratio4), 0, radius4* cos(6*ratio4)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius4* sin(7*ratio4), 0, radius4* cos(7*ratio4)), TUBE_LENGTH, POINT_SPACING)
    
    */
    //Working Ripple
    // FC #1
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(2*ratio3), 0, radius3* cos(2*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(3*ratio3), 0, radius3* cos(3*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(4*ratio3), 0, radius3* cos(4*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(2*ratio2 + offset2), 0, radius2* cos(2*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(3*ratio2 + offset2), 0, radius2* cos(3*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(0*ratio1), 0, radius1* cos(0*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(1*ratio1), 0, radius1* cos(1*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(2*ratio1), 0, radius1* cos(2*ratio1)), TUBE_LENGTH, POINT_SPACING),
    
    //FC #2
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(18*ratio3), 0, radius3* cos(18*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(19*ratio3), 0, radius3* cos(19*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(0*ratio3), 0, radius3* cos(0*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(1*ratio3), 0, radius3* cos(1*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(14*ratio2 + offset2), 0, radius2* cos(14*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(15*ratio2 + offset2), 0, radius2* cos(15*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(0*ratio2 + offset2), 0, radius2* cos(0*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(1*ratio2 + offset2), 0, radius2* cos(1*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    
    //FC #3
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(15*ratio3), 0, radius3* cos(15*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(16*ratio3), 0, radius3* cos(16*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(17*ratio3), 0, radius3* cos(17*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(12*ratio2 + offset2), 0, radius2* cos(12*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(13*ratio2 + offset2), 0, radius2* cos(13*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(9*ratio1), 0, radius1* cos(9*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(10*ratio1), 0, radius1* cos(10*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(11*ratio1), 0, radius1* cos(11*ratio1)), TUBE_LENGTH, POINT_SPACING),
    
    //FC #4
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(12*ratio3), 0, radius3* cos(12*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(13*ratio3), 0, radius3* cos(13*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(14*ratio3), 0, radius3* cos(14*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(10*ratio2 + offset2), 0, radius2* cos(10*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(11*ratio2 + offset2), 0, radius2* cos(11*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(6*ratio1), 0, radius1* cos(6*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(7*ratio1), 0, radius1* cos(7*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(8*ratio1), 0, radius1* cos(8*ratio1)), TUBE_LENGTH, POINT_SPACING),
    
    //FC #5
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(8*ratio3), 0, radius3* cos(8*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(9*ratio3), 0, radius3* cos(9*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(10*ratio3), 0, radius3* cos(10*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(11*ratio3), 0, radius3* cos(11*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(6*ratio2 + offset2), 0, radius2* cos(6*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(7*ratio2 + offset2), 0, radius2* cos(7*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(8*ratio2 + offset2), 0, radius2* cos(8*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(9*ratio2 + offset2), 0, radius2* cos(9*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    
    //FC #6
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(5*ratio3), 0, radius3* cos(5*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(6*ratio3), 0, radius3* cos(6*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius3* sin(7*ratio3), 0, radius3* cos(7*ratio3)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(4*ratio2 + offset2), 0, radius2* cos(4*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius2* sin(5*ratio2 + offset2), 0, radius2* cos(5*ratio2 + offset2)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(3*ratio1), 0, radius1* cos(3*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(4*ratio1), 0, radius1* cos(4*ratio1)), TUBE_LENGTH, POINT_SPACING),
    new EnvelopModel.Config.Rail(new PVector(radius1* sin(5*ratio1), 0, radius1* cos(5*ratio1)), TUBE_LENGTH, POINT_SPACING)
    
     };
  
  final static EnvelopModel.Config.Par[] PARS = {
    new EnvelopModel.Config.Par(new PVector(8, 0, 0), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(0, 0, -8), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(-8, 0, 0), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(0, 0, 8), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(18, 0, 18), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(18, 0, -18), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(-18, 0, -18), 1, POINT_SPACING),
    new EnvelopModel.Config.Par(new PVector(-18, 0, 18), 1, POINT_SPACING)
  };
  final static float[] ARC_POSITIONS = { };
  
  final static EnvelopModel.Config CONFIG = new EnvelopModel.Config() {
    public PVector[] getColumns() {
      return COLUMN_POSITIONS;
    }
    
     public PVector[] getParCans() {
      return PARCAN_POSITIONS;
    }
    
    public float[] getArcs() {
      return ARC_POSITIONS;
    }
    
    public EnvelopModel.Config.Rail[] getRails() {
      return RAILS;
    }
    public EnvelopModel.Config.Par[] getPars() {
      return PARS;
    }
  };
  
  Satellite() {
    super(CONFIG);
  }
}


//***************************************
//classes Column, Arc, Rails and Par Cans

static class Column extends LXModel {
  
  final static float SPEAKER_ANGLE = 22./180.*PI;
  
  final static float HEIGHT = Rail.HEIGHT;
  final static float RADIUS = 20*INCHES;
  
  final int index;
  final float azimuth;
  
  //final List<Arc> arcs;
  final List<Rail> rails;
  final List<LXPoint> railPoints;
  
  Column(EnvelopModel.Config config, int index, LXTransform transform, float azimuth) {
    super(new Fixture(config, transform));
    this.index = index;
    this.azimuth = azimuth;
    Fixture f = (Fixture) fixtures.get(0);
    //this.arcs = Collections.unmodifiableList(Arrays.asList(f.arcs));
    this.rails = Collections.unmodifiableList(Arrays.asList(f.rails));
    List<LXPoint> railPoints = new ArrayList<LXPoint>();
    for (Rail rail : this.rails) {
      for (LXPoint p : rail.points) {
        railPoints.add(p);
      }
    }
    this.railPoints = Collections.unmodifiableList(railPoints); 
  }
  
  private static class Fixture extends LXAbstractFixture {
    //final Arc[] arcs;
    final Rail[] rails;
    
    Fixture(EnvelopModel.Config config, LXTransform transform) {
      
      // Transform begins on the floor at center of column
      transform.push();
      
      // Rails
      this.rails = new Rail[config.getRails().length];
      for (int i = 0; i < config.getRails().length; ++i) {
        EnvelopModel.Config.Rail rail = config.getRails()[i]; 
        transform.translate(RADIUS * rail.position.x, 0, RADIUS * rail.position.z);
        addPoints(rails[i] = new Rail(rail, transform));
        transform.translate(-RADIUS * rail.position.x, 0, -RADIUS * rail.position.z);
      }
      
      // Arcs
      /*
      this.arcs = new Arc[config.getArcs().length];
      for (int i = 0; i < config.getArcs().length; ++i) {
        float y = config.getArcs()[i] * HEIGHT;
        transform.translate(0, y, 0);      
        addPoints(arcs[i] = new Arc(transform));
        transform.translate(0, -y, 0);
      }*/
      
      transform.pop();
    }
  }
}

static class Rail extends LXModel {
  
  final static int LEFT = 0;
  final static int RIGHT = 1;
  
  final static float HEIGHT = 12*FEET;
  
  public final float theta;
  
  public static final int NUM_LEDS = 32;
  
  Rail(EnvelopModel.Config.Rail rail, LXTransform transform) {
    super(new Fixture(rail, transform));
    this.theta = atan2(transform.z(), transform.x());
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(EnvelopModel.Config.Rail rail, LXTransform transform) {
      transform.push();
      transform.translate(0, rail.pointSpacing / 2., 0);
      for (int i = 0; i < rail.numPoints; ++i) {
        addPoint(new LXPoint(transform));
        transform.translate(0, rail.pointSpacing, 0);
      }
      transform.pop();
    }
  }
}

static class Arc extends LXModel {
  
  final static float RADIUS = Column.RADIUS;
  
  final static int BOTTOM = 0;
  final static int TOP = 1;
  
  final static int NUM_POINTS = 34;
  final static float POINT_ANGLE = PI / NUM_POINTS;
  
  Arc(LXTransform transform) {
    super(new Fixture(transform));
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(LXTransform transform) {
      transform.push();
      transform.rotateY(-POINT_ANGLE / 2.);
      for (int i = 0; i < NUM_POINTS; ++i) {
        transform.translate(-RADIUS, 0, 0);
        addPoint(new LXPoint(transform));
        transform.translate(RADIUS, 0, 0);
        transform.rotateY(-POINT_ANGLE);
      }
      transform.pop();
    }
  }
}

//***********************
static class ParCan extends LXModel {
  
  final static float SPEAKER_ANGLE = 22./180.*PI;
  
  final static float HEIGHT = Par.HEIGHT;
  final static float RADIUS = 20*INCHES;
  
  final int index;
  final float azimuth;
  
  final List<Par> pars;
  final List<LXPoint> parPoints;
  
  //constructor
  ParCan(EnvelopModel.Config config, int index, LXTransform transform, float azimuth) {
    super(new Fixture(config, transform));
    this.index = index;
    this.azimuth = azimuth;
    Fixture f = (Fixture) fixtures.get(0);
    
    this.pars = Collections.unmodifiableList(Arrays.asList(f.pars));
    List<LXPoint> parPoints = new ArrayList<LXPoint>();
    for (Par par : this.pars) {
      for (LXPoint p : par.points) {
        parPoints.add(p);
      }
    }
    this.parPoints = Collections.unmodifiableList(parPoints); 
  }
  
  private static class Fixture extends LXAbstractFixture {
    
    final Par[] pars;
    
    Fixture(EnvelopModel.Config config, LXTransform transform) {
      
      // Transform begins on the floor at center of column
      transform.push();
      
      // Pars
      this.pars = new Par[config.getPars().length];
      for (int i = 0; i < config.getPars().length; ++i) {
        EnvelopModel.Config.Par par = config.getPars()[i]; 
        transform.translate(RADIUS * par.position.x, 0, RADIUS * par.position.z);
        addPoints(pars[i] = new Par(par, transform));
        transform.translate(-RADIUS * par.position.x, 0, -RADIUS * par.position.z);
      }
      
      transform.pop();
    }
  }
}

static class Par extends LXModel {
  
  final static int LEFT = 0;
  final static int RIGHT = 1;
  
  final static float HEIGHT = 12*FEET;
  
  public final float theta;
  
  Par(EnvelopModel.Config.Par par, LXTransform transform) {
    super(new Fixture(par, transform));
    this.theta = atan2(transform.z(), transform.x());
  }
  
  private static class Fixture extends LXAbstractFixture {
    Fixture(EnvelopModel.Config.Par par, LXTransform transform) {
      transform.push();
      transform.translate(0, par.pointSpacing / 2., 0);
      for (int i = 0; i < par.numPoints; ++i) {
        addPoint(new LXPoint(transform));
        transform.translate(0, par.pointSpacing, 0);
      }
      transform.pop();
    }
  }
}
