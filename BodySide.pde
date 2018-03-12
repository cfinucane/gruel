import SimpleOpenNI.*;

public enum BodySide { 
  LEFT(SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP),
  RIGHT(SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
  
  public int hand, elbow, shoulder, hip;
  private BodySide(int hand, int elbow, int shoulder, int hip) {
    this.hand = hand;
    this.elbow = elbow;
    this.shoulder = shoulder;
    this.hip = hip;
  }
}