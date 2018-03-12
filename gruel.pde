
// based on simpleopenni examples

import SimpleOpenNI.*;
import java.util.Map;
import ddf.minim.*;
import ddf.minim.ugens.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };

Map<Integer, Person> people = new HashMap();
Minim minim;
AudioOutput out;

void setup()
{
  size(640,480);
  setupKinect();
  setupAudio();
}

void setupKinect()
{
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();  
}

void setupAudio()
{
  minim = new Minim(this);
  out = minim.getLineOut();
}

void draw() {
  drawKinect();
}

void drawKinect()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
       fill(255, 255, 255);
          rect(0, 0, 200, 400);
  int[] userList = context.getUsers();
  for(int i=0; i<userList.length; i++)
  {
    int userId=userList[i];
    
    // draw the skeleton if it's available
    if(context.isTrackingSkeleton(userId))
    {
      if (!people.containsKey(userId)) {
        // create new voice
          println("\tstarting voice for: " + userId);

        people.put(userId, new Person(0.5, 0.5, 0.5, out));
      }

      stroke(userClr[ (userId - 1) % userClr.length ] );
      drawSkeleton(userId);
      
     float[] leftAngles = getArmAngles(userId, BodySide.LEFT);
     float[] rightAngles = getArmAngles(userId, BodySide.RIGHT);

     // show the angles on the screen for debugging

     scale(1);

     fill(userClr[ (userId - 1) % userClr.length ] );

     text("left shoulder: " + int(leftAngles[0]) + "\n" + " elbow: " + int(leftAngles[1]), 20, 20+100*(userId-1));
     text("\n\nright shoulder: " + int(rightAngles[0]) + "\n" + " elbow: " + int(rightAngles[1]), 20, 20+100*(userId-1));
     Person p = people.get(userId);
     if (p == null) {
         println("ghost! userId: " + userId);
     } else {
       p.updateParameters(leftAngles[0]/180, leftAngles[1]/360, rightAngles[0]/180);
     }

    }      
      
   PVector com = new PVector();                                   
   PVector com2d = new PVector();                                   

    // draw the center of mass
    if(context.getCoM(userId,com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userId),com2d.x,com2d.y);
    }
  }    
}

float[] getArmAngles(int userId, BodySide side) {
    // get the positions of the three joints of our arm
     PVector hand = new PVector();
     context.getJointPositionSkeleton(userId, side.hand, hand);
     PVector elbow = new PVector();
     context.getJointPositionSkeleton(userId, side.elbow, elbow);
     PVector shoulder = new PVector();
     context.getJointPositionSkeleton(userId, side.shoulder, shoulder);
     // we need hip to orient the shoulder angle
     PVector hip = new PVector();
     context.getJointPositionSkeleton(userId, side.hip, hip);
     
     // reduce our joint vectors to two dimensions
     PVector hand2D = new PVector(hand.x, hand.y); 
     PVector elbow2D = new PVector(elbow.x, elbow.y);
     PVector shoulder2D = new PVector(shoulder.x, shoulder.y);
     PVector hip2D = new PVector(hip.x, hip.y);
     // calculate the axes against which we want to measure our angles
     PVector torsoOrientation = PVector.sub(shoulder2D, hip2D); 
     PVector upperArmOrientation = PVector.sub(elbow2D, shoulder2D);
     
     // calculate the angles between our joints
     float shoulderAngle = angleOf(elbow2D, shoulder2D, torsoOrientation);
     float elbowAngle = angleOf(hand2D, elbow2D, upperArmOrientation);
     
     return new float[] {shoulderAngle, elbowAngle};
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  Person p = people.get(userId);
  if (p == null) {
    println("death of ghost! userId: " + userId);
  } else {
     p.stop();
     people.remove(userId);
  }
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}

//Generate the angle
float angleOf(PVector one, PVector two, PVector axis){
 PVector limb = PVector.sub(two, one);
 return degrees(PVector.angleBetween(limb, axis));
}

void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  