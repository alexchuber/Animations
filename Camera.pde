//==================================//
//==============GLOBALS=============//
//==================================//

float TICK_SCALE = 5;
float CAM_DAMPEN = 0.15f;
float MIN_RADIUS = 10;
float MAX_RADIUS = 200;
float DEF_RADIUS = 30;
float MIN_PHI = 0;
float MAX_PHI = 360;
float DEF_PHI = 90;
float MIN_THETA = 1;
float MAX_THETA = 179;
float DEF_THETA = 120;



class Camera
{
  
  //==================================//
  //========DATA & CONSTRUCTOR========//
  //==================================//
  
  //Data
  float radius, phi, theta;
  
  //Constructor
  Camera()
  {
    radius = DEF_RADIUS;
    phi = DEF_PHI;
    theta = DEF_THETA;
  }
  
  
  //==================================//
  //=============MUTATORS=============//
  //==================================//
  
  //Updates phi (left-right) and theta (up-down) based on mouseDragged movement
  void Move()
  {
    phi = phi + ((mouseX - pmouseX) * CAM_DAMPEN);
    if(phi > MAX_PHI)
      phi = MAX_PHI;
    else if(phi < MIN_PHI)
      phi = MIN_PHI;
      
    theta = theta + ((mouseY - pmouseY) * CAM_DAMPEN);
    if(theta > MAX_THETA)
      theta = MAX_THETA;
    else if(theta < MIN_THETA)
      theta = MIN_THETA;
  }
  
  //Updates radius (closeness) based on mouseScroll movement
  void Zoom(float ticks)
  {
    radius += (ticks * TICK_SCALE);
    if(radius > MAX_RADIUS)
      radius = MAX_RADIUS;
    else if(radius < MIN_RADIUS)
      radius = MIN_RADIUS;
  }  
  

  //==================================//
  //============BEHAVIORS=============//
  //==================================// 
  
  //"Draws" camera with appropriate position; called each frame
  void Update()
  {
    float positionx = (radius*cos(radians(phi))*sin(radians(theta)));
    float positiony = (radius*cos(radians(theta)));
    float positionz = (radius*sin(radians(theta))*sin(radians(phi)));
    
    camera(positionx, positiony, positionz,
           0, 0, 0,
           0, 1, 0);
    perspective(radians(90), (float)width/height, 0.1, 1000);
  }
  
}
