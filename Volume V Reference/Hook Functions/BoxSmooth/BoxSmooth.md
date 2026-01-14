# BoxSmooth

BoundingBall
V-53
BoundingBall 
BoundingBall [/F/Z] scatterWave
The BoundingBall operation calculates a bounding circle or the bounding sphere for a set of scatter points. 
The operation accepts 2D waves that have two, three or more columns; data in the additional columns are 
ignored.
When scatterWave consists of two columns the operation computes the bounding circle. Otherwise it 
computes the bounding 3D sphere.
Parameters
scatterWave is a two-dimensional wave with X coordinates in column 0, Y in column 1, and optional Z 
coordinates in column 2.
Flags
Details
The center and radius of the bounding sphere are stored in the variables: V_CenterX, V_CenterY, 
V_CenterZ, and V_Radius.
If you are not using the /F flag, the operation also accepts a 2 column wave consisting of X, Y pairs for 
calculating the center and radius of a bounding circle in the plane.
Example
Make/N=(33,2) ddd=enoise(4)
// Create random data
BoundingBall ddd
Display ddd[][1] vs ddd[][0]
ModifyGraph mode=3
Make/n=360 xxx,yyy
yyy=v_centerY+V_radius*cos(p*2*pi/360)
xxx=v_centerX+V_radius*sin(p*2*pi/360)
AppendToGraph yyy vs xxx
References
Glassner, Andrew S., (Ed.), Graphics Gems, 833 pp., Academic Press, San Diego, 1990.
BoxSmooth
BoxSmooth box, srcWave, smoothedWave
The BoxSmooth operation replaces smoothedWave with a smoothed copy of srcWave. The waves must both 
exist.
The BoxSmooth operation is used primarily by Igor Technical Note #20 and its variants. For most purposes, 
use the more flexible Smooth operation instead of BoxSmooth. 
Parameters
box is the number of srcWave points averaged to form each smoothedWave point. If you specify an even 
number, the next-higher odd number is used.
Details
BoxSmooth is equivalent to the Smooth operation with the /B flag, except that BoxSmooth does not 
compute the result in-place like Smooth does. This command:
BoxSmooth box, srcWave, smoothedWave
is equivalent to:
Duplicate/O srcWave, smoothedWave
Smooth/B/DIM=-1/E=3/F=0 box, smoothedWave
/F
This flag applies to 3D scatter only. It uses an algorithm from “An Efficient Bounding 
Sphere” by Jack Ritter originally from Graphics Gems. Unfortunately it does not give 
an accurate bounding ball but something that is sufficiently large. This algorithm is 
less accurate but it produces a ball which is sufficiently large to contain all the points.
/Z
No error reporting.
