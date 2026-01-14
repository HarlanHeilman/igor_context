# sign

ShowTools
V-870
ShowTools 
ShowTools [/A/W=winName][toolName]
The ShowTools operation puts a tool palette for drawing along the left hand side of the target or named 
graph or control panel, and optionally activates the named tool.
Flags
Parameters
If you specify a toolName (which can be one of: normal, arrow, text, line, rect, rrect, oval, or poly) the named 
tool is activated. Specifying the “normal” tool has the same effect as issuing the GraphNormal command 
for a graph that has the drawing tools selected.
Details
The activated tool is not highlighted until the top graph or control panel becomes the topmost (activated) 
window. Use DoWindow/F to bring a window to the top (or “front”).
See Also
The DoWindow, GraphNormal, GraphWaveDraw, GraphWaveEdit, and HideTools operations.
SinIntegral
SinIntegral(z)
The SinIntegral(z) function returns the sine integral of z.
If z is real, a real value is returned. If z is complex then a complex value is returned.
The SinIntegral function was added in Igor Pro 7.00.
Details
The sine integral is defined by
IGOR computes the SinIntegral using the expression:
References
Abramowitz, M., and I.A. Stegun, "Handbook of Mathematical Functions", Dover, New York, 1972. Chapter 
5.
See Also
CosIntegral, ExpIntegralE1, hyperGPFQ
sign 
sign(num)
The sign function returns -1 if num is negative or 1 if it is not negative.
/A
Sizes window automatically to make extra room for the tool palette. This preserves 
the proportion and size of the actual graph area.
/W=winName
Shows tool palette in the named window. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
winName must be either the name of a top-level window or a path leading to an 
exterior panel window (see Exterior Control Panels on page III-443).
Si(z) =
sin(t)
t
dt.
0
z
∫
Si(z) = z 1F2
1
2 ; 3
2 , 3
2 ;−z2
4
⎛
⎝⎜
⎞
⎠⎟.
