# Polygon as Input Device

Chapter IV-6 — Interacting with the User
IV-164
When the user chooses Print Marquee Coordinates, the following function runs. It prints the coordinates of 
the marquee in the history area. It assumes that the graph has left and bottom axes.
Function PrintMarqueeCoords()
String format
GetMarquee/K left, bottom
format = "flag: %g; left: %g; top: %g; right: %g; bottom: %g\r"
printf format, V_flag, V_left, V_top, V_right, V_bottom
End
The use of the marquee menu as in input device is demonstrated in the Marquee Demo and Delete Points 
from Wave example experiments.
Polygon as Input Device
This technique is similar to the marquee technique except that you can identify a nonrectangular area. It is 
implemented using FindPointsInPoly operation (see page V-248).
