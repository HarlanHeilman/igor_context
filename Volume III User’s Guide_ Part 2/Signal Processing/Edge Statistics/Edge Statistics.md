# Edge Statistics

Chapter III-9 — Signal Processing
III-289
V_Flag=0; V_LevelX=-0.37497; V_rising=1;
Finding a Level in XY Data
You can find a level crossing in XY data by searching the Y wave and then figuring out where in the X wave 
that X value can be found. This requires that the values in the X wave be sorted in ascending or descending 
order. To ensure this, the command:
Sort xWave,xWave,yWave
sorts the waves so that the values in xWave are ascending, and the XY correspondence is preserved.
The following procedure finds the X location where a Y level is crossed within an X range, and stores the 
result in the output variable V_LevelX:
Function FindLevelXY()
String swy,swx
// strings contain the NAMES of waves
Variable startX=-inf,endX=inf // startX,endX correspond to VALUEs in wx, not any X 
scaling
Variable level
// Put up a dialog to get info from user
Prompt swy,"Y Wave",popup WaveList("*",";","")
Prompt swx,"X Wave",popup WaveList("*",";","")
Prompt startX, "starting X value"
Prompt endX, "ending X value"
Prompt level, "level to find"
DoPrompt "Find Level XY", swy,swx,startX, endX, level
WAVE wx = $swx
WAVE wy = $swy
// Here's where the interesting stuff begins
Variable startP,endP
//compute point range covering startX,endX
startP=BinarySearch(wx,startX)
endP=BinarySearch(wx,endX)
FindLevel/Q/R=[startP,endP] wy,level
// search Y wave, assume success
Variable p1,m
p1=x2pnt(wy,V_LevelX-deltaX(wy)/2)
//x2pnt rounds; circumvent it
// Linearly interpolate between two points in wx
// that bracket V_levelX in wy
m=(V_LevelX-pnt2x(wy,p1))/(pnt2x(wy,p1+1)-pnt2x(wy,p1))
// slope
V_LevelX=wx[p1] + m * (wx[p1+1] -wx[p1] )
//point-slope equation
End
This function does not handle a level crossing that isn’t found; all that is missing is a test of V_Flag after 
searching the Y wave with FindLevel.
Edge Statistics
The EdgeStats operation (see page V-190) produces simple statistics (measurements, really) on a region of 
a wave that is expected to contain a single edge as shown below. If more than one edge exists, EdgeStats 
works on the first edge it finds. The edge statistics are stored in special variables which are described in the 
EdgeStats reference. The statistics are edge levels, X or point positions of various found “points”, and the 
distances between them. These found points are actually the locations of level crossings, and are usually 
located between actual waveform points (they are interpolation locations).
