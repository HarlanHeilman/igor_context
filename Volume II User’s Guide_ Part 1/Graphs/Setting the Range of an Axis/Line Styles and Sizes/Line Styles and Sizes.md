# Line Styles and Sizes

Chapter II-13 — Graphs
II-294
To create a text marker, choose the Markers or Lines and Markers display mode. Then click the Markers 
pop-up menu and choose the Text button. This leads to the Text Markers subdialog in which you can 
specify the source of the text as well as the font, style, rotation and other properties of the markers.
You can offset and rotate all the text markers by the same amount but you can not set the offset and rotation 
for individual data points — use tags for that. You may find it necessary to experimentally adjust the X and Y 
offsets to get character markers exactly centered on the data points. For example, to center the text just above 
each data point, choose Middle bottom from the Anchor pop-up menu and set the Y offset to 5-10 points. If 
you need to offset some items differently from others, you will have to use tags (see Tags on page III-43).
Igor determines the font size to use for text markers from the marker size, which you set in the Modify Trace 
Appearance dialog. The font size used is 3 times the marker size.
You may want to show a text marker and a regular drawn marker. For this, you will need to display the 
wave twice in the graph. After creating the graph and setting the trace to use a drawn marker, choose 
GraphAppend Traces to Graph to append a second copy of the wave. Set this copy to use text markers.
Arrow Markers
Arrow markers can be used to create vector plots illustrating flow and gradient fields, for example. Arrow 
markers are fairly special purpose and require quite a bit of advance preparation.
Here is a very simple example:
// Make XY data
Make/O xData = {1, 2, 3}, yData = {1, 2, 3}
Display yData vs xData
// Make graph
ModifyGraph mode(yData) = 3
// Marker mode
// Make an arrow data wave to control the length and angle for each point.
Make/O/N=(3,2) arrowData
// Controls arrow length and angle
Edit /W=(439,47,820,240) arrowData
// Put some data in arrowData
arrowData[0][0]= {20,25,30} 
// Col 0: arrow lengths in points
arrowData[0][1]= {0.523599,0.785398,1.0472}
// Col 1: arrow angle in radians
// Set trace to arrow mode to turn arrows on
ModifyGraph arrowMarker(yData) = {arrowData, 1, 10, 1, 1}
// Make an RGB color wave
Make/O/N=(3,3) arrowColor
Edit /W=(440,272,820,439) arrowColor
// Store some colors in the color wave
arrowColor[0][0]= {65535,0,0}
// Red
arrowColor[0][1]= {0,65535,0}
// Green
arrowColor[0][2]= {0,0,65535}
// Blue
// Turn on color as f(z) mode
ModifyGraph zColor(yData)={arrowColor,*,*,directRGB,0}
To see a demo of arrow markers choose FileExample ExperimentsGraphing TechniquesArrow Plot.
See the reference for a description of the arrowMarker keyword under the ModifyGraph (traces) operation on 
page V-613 for further details.
Line Styles and Sizes
If you choose the “Lines between points”, “Lines and markers”, or Cityscape mode you can also choose the 
line style. You can change the dash patterns using the Dashed Lines item in the Line section.
