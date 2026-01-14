# LayoutInfo

Layout
V-478
See Also
The NewLayout and LayoutInfo operations. See Chapter II-18, Page Layouts.
Layout 
Layout
Layout is a procedure subtype keyword that identifies a macro as being a page layout recreation macro. It 
is automatically used when Igor creates a window recreation macro for a layout. See Procedure Subtypes 
on page IV-204 and Killing and Recreating a Layout on page II-477 for details.
See Also
See Chapter II-18, Page Layouts.
LayoutInfo 
LayoutInfo(winNameStr, itemNameStr)
The LayoutInfo function returns a string containing a semicolon-separated list of keywords and values that 
describe an object in the active page of a page layout or overall properties of the layout. The main purpose 
of LayoutInfo is to allow an advanced Igor programmer to write a procedure which formats or arranges 
objects.
winNameStr is the name of an existing page layout window or "" to refer to the top layout.
itemNameStr is a string expression containing one of the following:
•
The name (e.g., "Graph0") of a layout object in the active page to get information about that object.
•
An object instance (e.g., "Graph0#0" or "Graph0#1") to get information about a particular instance 
of an object in the active page. This is of use only in the unusual situation when the same object 
appears in the active page multiple times. "Graph0#0" is equivalent to "Graph0". "Graph0#1" is the 
second occurrence of Graph0 in the active page.
•
An integer object index starting from zero to get information about an object referenced by its 
position in the active page in the layout. Zero refers to the first object going from back to front in 
the page.
•
The word "Layout" to get overall information about the layout.
Details
In cases 1, 2 and 3 above, where itemNameStr references an object, the returned string contains the following 
keywords, with a semicolon after each keyword-value pair.
/F=frame
/T=trans
Keyword
Information Following Keyword
FIDELITY
Object fidelity expressed as a code usable in a ModifyLayout fidelity command.
FRAME
Object frame expressed as a code usable in a ModifyLayout frame command.
HEIGHT
Object height in points.
Controls the object frame:
frame=0:
No frame.
frame=1:
Single frame (default).
frame=2:
Double frame.
frame=3:
Triple frame.
frame=4:
Shadow frame.
Controls the transparency of the layout object:
trans=0:
Opaque (default).
trans=1:
Transparent. For this to be effective, the object itself must also be 
transparent. Annotations have their own transparent/opaque 
settings. Graphs are transparent only if their backgrounds are white. 
Pictures may have been created transparent or opaque, and Igor 
cannot make an inherently opaque picture transparent.

LayoutInfo
V-479
In case 4 above, where itemNameStr is "Layout", the returned string contains the following keywords, with 
a semicolon after each keyword-value pair.
LayoutInfo returns "" in the following situations:
•
winNameStr is "" and there are no layout windows.
•
winNameStr is a name but there are no layout windows with that name.
•
itemNameStr is not "Layout" and is not the name or index of an existing object.
Examples
This example sets the background color of all selected graphs in the active page of a particular page layout 
to the color specified by red, green, and blue, which are numbers from 0 to 65535.
Function SetLayoutGraphsBackgroundColor(layoutName,red,green,blue)
String layoutName
// Name of layout or "" for top layout.
Variable red, green, blue
Variable index
String info
Variable selected
String indexStr
String objectTypeStr
String graphNameStr
INDEX
Object position in back-to-front order in the active page of the layout, starting 
from zero.
LEFT
Object left position in points.
NAME
The name of the object.
SELECTED
Zero if the object is not selected or nonzero if it is selected.
TOP
Object top position in points.
TRANS
Object transparency expressed as a code usable in a ModifyLayout trans 
command.
TYPE
Object type which is one of: Graph, Table, Picture, or Textbox.
WIDTH
Object width in points.
Keyword
Information Following Keyword
BGRGB
Layout background color expressed as <red>, <green>, <blue> where each color is 
a value from 0 to 65535.
MAG
Layout magnification: 0.25, 0.5, 1.0, or 2.0.
NUMOBJECTS
Total number of objects in the active page of the layout.
NUMSELECTED
Number of selected objects in the active page of the layout.
PAGE
A rectangle defining the part of the paper that is inside the margins, expressed in 
points. The format is <left>, <top>, <right>, <bottom>.
CURRENTPAGENUM
One-based page number of the currently active page. Added in Igor Pro 7.00.
NUMPAGES
Total number of pages in the layout. Added in Igor Pro 7.00.
PAPER
A rectangle defining the bounds of the paper, expressed in points. The format is 
<left>, <top>, <right>, <bottom>.
SELECTED
A comma-separated list of the names of selected objects in the active page of the 
layout.
UNITS
Units used to display object locations and sizes. This will be one of the following: 
0 for points, 1 for inches, 2 for centimeters.
Keyword
Information Following Keyword
