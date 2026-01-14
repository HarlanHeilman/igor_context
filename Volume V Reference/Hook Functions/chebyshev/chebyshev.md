# chebyshev

chebyshev
V-63
Flags
Details
The target window must be a graph or panel.
The action of some of the Chart keywords depends on whether or not data acquisition is taking place. If the 
chart is in review mode then all keywords cause the chart to be redrawn. If data acquisition is taking place 
and the chart is in live mode then some keywords affect new data but do not attempt to update the part of 
the “paper” that has already been drawn. The following keywords affect only new data during live mode:
ppStrip, maxDots, gain, offset, color, lineMode
See Also
Charts on page III-415 and FIFOs and Charts on page IV-313.
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Control Panel Units on page III-444 for a discussion of the units used for controls.
The ControlInfo operation for information about the control.
The GetUserData function for retrieving named user data.
chebyshev 
chebyshev(n, x)
The chebyshev function returns the Chebyshev polynomial of the first kind and of degree n.
The Chebyshev polynomials satisfy the recurrence relation:
with: 
The orthogonality of the polynomial is expressed by the integral:
sMode=sm
sRate=sr
Sets the scroll rate (vertical strips/second). If the chart control is in review mode 
negative numbers scroll in reverse.
title=titleStr
Specifies the chart title. Use "" for no title.
uMode=um
win=winName
Specifies which window or subwindow contains the named control. If not given, 
then the top-most graph or panel window or subwindow is assumed.
When identifying a subwindow with winName, see Subwindow Syntax on page 
III-92 for details on forming the window hierarchy.
/Z
No error reporting.
Status line mode.
sm=0:
Turns off fancy status line and positioning bar.
sm=1:
Normal mode.
sm=2:
Uses alternate style for bar.
Status line mode.
um=1:
Fast update with no bells and whistles.
um=2:
Status line and positioning bar.
um=3:
Status line, positioning bar, and animated pens.
Tn+1(x) = 2xTn(x)−Tn−1(x)
T0(x) = 1
T1(x) = x
T2(x) = 2x2 −1.
