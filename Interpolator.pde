abstract class Interpolator
{
  Animation animation;
  
  // Where we at in the animation?
  float currentTime = 0;
  
  // To interpolate, or not to interpolate... that is the question
  boolean snapping = false;
  
  void SetAnimation(Animation anim)
  {
    animation = anim;
  }
  
  void SetFrameSnapping(boolean snap)
  {
    snapping = snap;
  }
  
  void UpdateTime(float time)
  {
    // TODO: Update the current time
    // Check to see if the time is out of bounds (0 / Animation_Duration)
    // If so, adjust by an appropriate amount to loop correctly
    currentTime += time;
    if(currentTime >= animation.GetDuration())
      currentTime = 0;
    else if(currentTime <= 0)
      currentTime = animation.GetDuration();
  }
  
  // Implement this in derived classes
  // Each of those should call UpdateTime() and pass the time parameter
  // Call that function FIRST to ensure proper synching of animations
  abstract void Update(float time);
}



class ShapeInterpolator extends Interpolator
{
  // The result of the data calculations - either snapping or interpolating
  PShape currentShape;
  
  // Changing mesh colors
  color fillColor;
  
  PShape GetShape()
  {
    return currentShape;
  }
  
  void Update(float time)
  {
    // TODO: Create a new PShape by interpolating between two existing key frames
    // using linear interpolation
    currentShape = createShape();
    
    //Step 0: Update currentTime
    UpdateTime(time);
    
    //Step 1: Figure out the two frames currentTime is between
    //        (Default values are for when currentTime = 0)
    KeyFrame prev = animation.keyFrames.get(animation.keyFrames.size()-1);
    KeyFrame next = animation.keyFrames.get(0);
    for(int i = 0; i < animation.keyFrames.size()-1; i++)
    {
      KeyFrame first = animation.keyFrames.get(i);
      KeyFrame second = animation.keyFrames.get(i+1);
      if(currentTime >= first.time && currentTime <= second.time)
      {
        prev = first;
        next = second;
      }
    }
    
    //Step 2: If we're snapping, just draw the previous frame
    if(snapping)
    {
      currentShape.beginShape(TRIANGLE);
      for(int i = 0; i < prev.points.size(); i++)
      {
        PVector pos = prev.points.get(i);
        currentShape.vertex(pos.x, pos.y, pos.z);
      }
      currentShape.endShape();
      currentShape.setFill(fillColor);
      currentShape.setStroke(false);
      return;
    }
    
    //Step 3: If we're interpolating... interpolate!
    //        (Default ratio set to when currentTime is before first keyframe)
    float ratio = currentTime / next.time;
    if(currentTime >= animation.keyFrames.get(0).time)
      ratio = abs(currentTime - prev.time) / abs(next.time - prev.time);
    currentShape.beginShape(TRIANGLE);
    for(int i = 0; i < prev.points.size(); i++)    //Assuming KeyFrame has the same number of vertices/PVectors
    {
      PVector prevpos = prev.points.get(i);
      PVector nextpos = next.points.get(i);
      float x = lerp(prevpos.x, nextpos.x, ratio);
      float y = lerp(prevpos.y, nextpos.y, ratio);
      float z = lerp(prevpos.z, nextpos.z, ratio);
      currentShape.vertex(x, y, z);
    }
    currentShape.endShape();
    currentShape.setFill(fillColor);
    currentShape.setStroke(false);
  }
}



class PositionInterpolator extends Interpolator
{
  PVector currentPosition;
  
  void Update(float time)
  {
    // The same type of process as the ShapeInterpolator class... except
    // this only operates on a single point
    
    //Step 0: Update currentTime
    UpdateTime(time);
    
    //Step 1: Figure out the two frames currentTime is between
    //        (Default frames set to when currentTime is before first keyframe)
    KeyFrame prev = animation.keyFrames.get(animation.keyFrames.size()-1);
    KeyFrame next = animation.keyFrames.get(0);
    for(int i = 0; i < animation.keyFrames.size()-1; i++)
    {
      KeyFrame first = animation.keyFrames.get(i);
      KeyFrame second = animation.keyFrames.get(i+1);
      if(currentTime >= first.time && currentTime <= second.time)
      {
        prev = first;
        next = second;
      }
    }
    
    //Step 2: If we're snapping, just draw the previous frame
    if(snapping)
    {
      currentPosition = prev.points.get(0);
      return;
    }
    
    //Step 3: If we're interpolating... interpolate!
    //        (Default ratio set to when currentTime is before first keyframe)
    float ratio = currentTime / next.time;
    if(currentTime >= animation.keyFrames.get(0).time)
      ratio = abs(currentTime - prev.time) / abs(next.time - prev.time);
    PVector prevpos = prev.points.get(0);
    PVector nextpos = next.points.get(0);
    float x = lerp(prevpos.x, nextpos.x, ratio);
    float y = lerp(prevpos.y, nextpos.y, ratio);
    float z = lerp(prevpos.z, nextpos.z, ratio);
    currentPosition = new PVector(x,y,z);
  }
}
