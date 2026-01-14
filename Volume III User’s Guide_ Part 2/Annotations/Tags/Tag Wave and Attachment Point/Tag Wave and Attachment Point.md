# Tag Wave and Attachment Point

Chapter III-2 — Annotations
III-44
Tags can not be added to page layouts or Gizmo plots. However, a graph containing a tag can be added to 
a page layout.
Igor automatically generates tags to label contour plots.
Tag Text
Text in a tag can contain anything a textbox or legend can handle, and more.
The Dynamic pop-up menu of the Text Tab inserts escape codes that apply only to tags. These codes insert 
information about the wave the tag is attached to, or about the point in the wave to which the tag is 
attached. This information is “dynamically” updated whenever the wave or the attachment point changes. 
See Dynamic Escape Codes for Tags on page III-38.
The TagVal and TagWaveRef functions are also useful when creating a tag with dynamic text. See TagVal 
and TagWaveRef Functions on page III-38.
Tag Wave and Attachment Point
You specify which wave the tag is attached to in the Position Tab, by choosing a wave from the “Tag on” 
pop-up menu.
You specify which point the tag is attached to by entering the point number in the “At p=” entry or an X 
value in the “At x=” entry. The X value is in terms of the X scaling of the wave to which you are attaching 
the tag. This is not necessarily the same as the X axis position of the point if the wave is displayed in XY 
mode. It is the X value of the Y wave point to which the tag is attached. If this distinction mystifies you, see 
Waveform Model of Data on page II-62.
The attachment point of a tag in a (2D) image or waterfall plot is treated a bit differently than for 1D waves. 
In images it is the sequential point number linearly indexed into the matrix array. The dialog converts this 
point number, entered as the “At p=” setting, into the X and Y values, and vice versa.
Since it is the point number that determines the actual attachment point, because of rounding, the tag is not 
necessarily attached exactly at the entered “At x=” and “At y=” values.
1.0
0.5
0.0
56
54
52
50
48
46
44
Tag attached at x=50
40
30
20
10
0
40
30
20
10
0
Pixel value is 253.761
at x=24.9933 and y=24.9933
Choose which 
trace or image the 
tag is attached to

Chapter III-2 — Annotations
III-45
As described in the next section, you can position the tag manually by dragging.
Changing a Tag’s Attachment Point
Once a tag is on a graph you can attach it to a different point by pressing Option (Macintosh) or Alt (Win-
dows), clicking in the tag, and dragging the special tag cursor 
 to the new attachment point on the trace. 
You must drag the tag cursor to the point on the trace to which you want to attach the tag, not to the position 
on the screen where you want the tag text to appear. The dot in the center of the tag cursor shows where 
the tag will be attached.
If you drag the tag cursor off the graph, the tag is deleted from the graph.
Tag Arrows
You can indicate a tag’s attachment point with an arrow or line drawn from the tag’s anchor point using 
the “Connect Tag to Wave with” pop-up menu in the Tag Arrows tab. 
You can adjust how close the arrow or line comes to the data point by setting the Line/Arrow Standoff dis-
tance in units of points.
The Advanced Line/Arrow options give you added control of the line and arrow characteristics.
A Line Thickness value of 0 corresponds to the default line thickness of 0.5 points. Otherwise, enter a value 
up to 10.0 points. To make the line disappear, select No Line from the “Connect Tag to Wave with” popup 
menu.
The line color is normally set by the annotation frame color (in the Frame tab). You can override this by 
checking the Override Line Color checkbox and choosing a color from the popup menu.
Change the attachment line’s style from the default solid line using the line style popup menu.
If “Connect Tag to Wave with” popup is set to Arrow, you can control the appearance of the arrowhead 
using the remaining controls. Options include full or half arrowhead, filled or outlined arrowhead, arrow 
length, fatness, and sharpness.
The Arrow Length setting is in units of points with 0 or Auto giving the default length.
The Sharp setting is a small value between -1.0 and 1.0. 0 or Auto gives the default sharpness.
2. Press Option 
or Alt
3. Drag to new 
attach point
4. Tag attaches to 
new point
1. Move cursor 
over tag text
