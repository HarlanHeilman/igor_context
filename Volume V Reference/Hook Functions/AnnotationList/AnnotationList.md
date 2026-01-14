# AnnotationList

AnnotationList
V-26
AnnotationList 
AnnotationList(winNameStr)
The AnnotationList function returns a semicolon-separated list of annotation names from the named graph 
or page layout window or subwindow.
Parameters
winNameStr can be "" to refer to the top graph or layout window.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Keyword
Information Following Keyword
ABSX
X location, in points, of the anchor point of the annotation. For graphs, this is relative to the 
top-left corner of the graph window. For layouts, it is relative to the top-left corner of the page.
ABSY
Y location, in points, of the anchor point of the annotation. For graphs, this is relative to the 
top-left corner of the graph window. For layouts, it is relative to the top-left corner of the page.
ATTACHX
For tags, it is the X value of the wave at the point where the tag is attached, as specified 
with the Tag operation. For textboxes, color scales, and legends, this will be zero and has 
no meaning.
AXISX
X location of the anchor point of the annotation. For tags or color scales in graphs, it is in 
terms of the X axis against which the tagged wave is plotted. For textboxes and legends in 
graphs, it is in terms of the first X axis. For layouts, this has no meaning and is always zero.
AXISY
Y location of the anchor point of the annotation. For layouts, this has no meaning and is 
always zero. For tags or color scales in graphs, it is in terms of the Y axis against which the 
tagged wave is plotted. For textboxes and legends in graphs, it is in terms of the first Y axis.
AXISZ
Z value of the image or contour level trace to which the tag is attached or NaN if the trace 
is not a contour level trace or the annotation is not a tag.
COLORSCALE Parameters used in a ColorScale operation to create the annotation.
FLAGS
Flags used in a Tag, Textbox, ColorScale, or Legend operation to create the annotation.
RECT
The outermost corners of the annotation (values are in points):
RECT:left, top, right, bottom
TEXT
Text that defines the contents of the annotation or the main axis label of a color scale.
TYPE
Annotation type: “Tag”, “TextBox”, “ColorScale”, or “Legend”.
XWAVE
For tags, it is the name of the X wave in the XY pair to which the tag is attached. If the tag 
is attached to a single wave rather than an XY pair, this will be empty. For textboxes, color 
scales, and legends, this will be empty and has no meaning.
XWAVEDF
For tags, the full path to the data folder containing the X wave associated with the trace 
to which the tag is attached. For textboxes, color scales, and legends, this will be empty 
and has no meaning.
YWAVE
For tags, it is the name of the trace or image to which the tag is attached. See 
ModifyGraph (traces) and Instance Notation on page IV-20 for discussions of trace 
names and instance notation. For color scales, it is the name of the wave displayed in 
associated the contour plot, image plot, f(z) trace, or the name of the color scale’s cindex 
wave. For textboxes and legends, this will be empty and has no meaning.
YWAVEDF
Full path to the data folder containing the Y wave or blank if the annotation is not a tag 
or color scale.
