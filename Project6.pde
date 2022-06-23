// VertexAnimation Project - Student Version
import java.io.*;
import java.util.*;

/*========== Monsters ==========*/
Animation monsterAnim;
ShapeInterpolator monsterForward = new ShapeInterpolator();
ShapeInterpolator monsterReverse = new ShapeInterpolator();
ShapeInterpolator monsterSnap = new ShapeInterpolator();

/*========== Sphere ==========*/
Animation sphereAnim; // Load from file
Animation spherePos; // Create manually
ShapeInterpolator sphereForward = new ShapeInterpolator();
PositionInterpolator spherePosition = new PositionInterpolator();

/*========== CAMERA ==========*/
Camera camera;

// Create animations for interpolators
Animation cubeAnim;
ArrayList<PositionInterpolator> cubes = new ArrayList<PositionInterpolator>();

void setup()
{
  //pixelDensity(2);
  size(1200, 800, P3D);
  
  camera = new Camera();
 
  /*====== Load Animations ======*/
  monsterAnim = ReadAnimationFromFile("monster.txt");
  sphereAnim = ReadAnimationFromFile("sphere.txt");

  monsterForward.SetAnimation(monsterAnim);
  monsterReverse.SetAnimation(monsterAnim);
  monsterSnap.SetAnimation(monsterAnim);
  monsterSnap.SetFrameSnapping(true);

  sphereForward.SetAnimation(sphereAnim);

  /*====== Create Animations For Cubes ======*/
  // Load cube animation
  cubeAnim = new Animation();
  for(int i = 0; i < 4; i++)
  {
    // Make keyframes for each cube-- i decides position on z/blue
    KeyFrame kf = new KeyFrame();
      kf.time = (i + 1) * 0.5f;
      float z;
      if(i % 2 == 0)
        z = 0.0f;
      else
        z = (i == 1) ? 100.0f : -100.0f;
      kf.points.add(new PVector(0, 0, z));
    cubeAnim.keyFrames.add(kf);
  }
  // Set cube animations in interpolators
  for(int i = 0; i < 11; i++)
  {
    PositionInterpolator cubeSide = new PositionInterpolator();
    cubeSide.SetAnimation(cubeAnim);
    if(i % 2 != 0)
      cubeSide.SetFrameSnapping(true);
    cubeSide.Update(i*0.1f);
    cubes.add(cubeSide);
  }
  
  /*====== Create Animations For Spheroid (spherePosition) ======*/
  Animation spherePos = new Animation();
  // Create and set keyframes
  for(int i = 0; i < 4; i++)
  {
    KeyFrame kf = new KeyFrame();
    kf.time = i + 1;
    float x = (i == 0 || i == 1) ? -100 : 100;
    float z = (i == 1 || i == 2) ? -100 : 100;
    kf.points.add(new PVector(x, 0, z));
    spherePos.keyFrames.add(kf);
  }
  spherePosition.SetAnimation(spherePos);
}



void draw()
{
  lights();
  background(0);
  DrawGrid();
  camera.Update();

  float playbackSpeed = 0.005f;

  /*====== Draw Forward Monster ======*/
  pushMatrix();
  translate(-40, 0, 0);
  monsterForward.fillColor = color(128, 200, 54);
  monsterForward.Update(playbackSpeed);
  shape(monsterForward.currentShape);
  popMatrix();
  
  /*====== Draw Reverse Monster ======*/
  pushMatrix();
  translate(40, 0, 0);
  monsterReverse.fillColor = color(220, 80, 45);
  monsterReverse.Update(-playbackSpeed);
  shape(monsterReverse.currentShape);
  popMatrix();
  
  /*====== Draw Snapped Monster ======*/
  pushMatrix();
  translate(0, 0, -60);
  monsterSnap.fillColor = color(160, 120, 85);
  monsterSnap.Update(playbackSpeed);
  shape(monsterSnap.currentShape);
  popMatrix();
  
  /*====== Draw Spheroid ======*/
  spherePosition.Update(playbackSpeed);
  sphereForward.fillColor = color(39, 110, 190);
  sphereForward.Update(playbackSpeed);
  PVector pos = spherePosition.currentPosition;
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  shape(sphereForward.currentShape);
  popMatrix();
  
  /*====== Draw Cubes ======*/
  for(int i = 0; i < 11; i++)
  {
    cubes.get(i).Update(playbackSpeed);
    fill(255,0,0);
    if(cubes.get(i).snapping)
      fill(255,255,0);
    noStroke();
    float x = -100 + (i*20);
    float z = cubes.get(i).currentPosition.z;
    pushMatrix();
    translate(x, 0, z);
    box(10);
    popMatrix();
    
  }
}



void mouseWheel(MouseEvent event)
{
  float ticks = event.getCount();
  camera.Zoom(ticks);
}


void mouseDragged()
{
  camera.Move();
}


// Create and return an animation object
Animation ReadAnimationFromFile(String fileName)
{
  Animation animation = new Animation();

  // The BufferedReader class will let you read in the file data
  BufferedReader reader = createReader(fileName);
  String line;
  try
  {
    // Get number of frames in animation (first line)
    line = reader.readLine();
    int framecount = int(line);
    
    // Get number of vertices per frame (second line)
    line = reader.readLine();
    int vertcount = int(line);
    
    // Parse through each frame
    for(int i = 0; i < framecount; i++)
    {
      KeyFrame kf = new KeyFrame();
      
      // Get and set time data
      line = reader.readLine();
      float kftime = float(line);
      kf.time = kftime;
      
      // Parse through each vertex
      for(int j = 0; j < vertcount; j++)
      {
        // Get and set vertex data
        line = reader.readLine();
        String[] pos = split(line, " ");
        PVector vertex = new PVector(float(pos[0]), float(pos[1]), float(pos[2]));
        kf.points.add(vertex);
      }
      
      // Add new frame to animation
      animation.keyFrames.add(kf);
    }
    
  }
  catch (FileNotFoundException ex)
  {
    println("File not found: " + fileName);
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
  }
 
  return animation;
}


void DrawGrid()
{
  // Draw the grid
  strokeWeight(8); 
  // X axis (red)
  stroke(255,0,0);
  line(-100,0,0,100,0,0);
  // Z axis (blue)
  stroke(0,0,255);
  line(0,0,-100,0,0,100);
  
  strokeWeight(1.1f);
  stroke(255,255,255);
  for(int i = -100; i <= 100; i+=10)
  {
    if(i != 0)
    {
      line(-100, 0, i, 100, 0, i);
      line(i, 0, -100, i, 0, 100);
    }
  }
}
