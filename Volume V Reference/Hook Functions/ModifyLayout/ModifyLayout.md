# ModifyLayout

ModifyLayout
V-639
Flags
See Also
AppendImage and RemoveImage.
ModifyLayout 
ModifyLayout [flags] key [(objectName)] =value [, key [(objectName)] =value]…
The ModifyLayout operation modifies objects in the top layout or in the layout specified by the /W flag.
Parameters
Each key parameter may take an optional objectName enclosed in parentheses. If “(objectName)” is omitted, 
all objects in the layout are affected.
Though not shown in the syntax, the optional “(objectName)” may be replaced with “[objectIndex]”, where 
objectIndex is zero or a positive integer denoting the object to be modified. “[0]” denotes the first object 
appended to the layout, “[1]” denotes the second object, etc. This syntax is used for style macros, in 
conjunction with the /Z flag.
The parameter descriptions below omit the optional “(objectName)”.
The “units”, “mag” and “bgRGB” keywords apply to the layout as a whole, not to a specific object and do 
not accept an objectName.
/W=winName
Directs action to a specific window or subwindow rather than the top graph window. 
When omitted, action will affect the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
bgRGB=(r,g,b[,a])
Specifies the background color for the layout. r, g, b, and a specify the color and 
optional opacity as RGBA Values.
columns=c
Specifies the number of columns for a table object.
fidelity=f
frame=f
gradient
See Gradient Fills on page III-498 for details.
gradientExtra
See Gradient Fills on page III-498 for details.
height=h
Sets the height of the object.
left=l
l is the horizontal coordinate of the left edge of the object relative to the left edge of 
the paper.
mag=m
Sets the on screen layout magnification where m is a value between 0.5 and 10.
m=1 corresponds to 100%.
Factors of two, such as m=.25, m=.5, m=1, m=2, tend to produce the best on screen 
graphics.
rows=r
Specifies the number of rows for table object.
top=t
t is the vertical coordinate of the top edge of the object relative to the top edge of the paper.
Controls the drawing of layout objects.
f=0:
Low fidelity.
f=1:
High fidelity.
Specifies the type of frame enclosing the object.
f=0:
No frame.
f=1:
Single frame (default).
f=2:
Double frame.
f=3:
Triple frame.
f=4:
Shadow frame.
