# ModifyGraph (general)

ModifyGizmo
V-611
ModifyGizmo 
ModifyGizmo [flags] keyword [=value]
The ModifyGizmo operation changes Gizmo properties.
Documentation for the ModifyGizmo operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "ModifyGizmo"
ModifyGraph
(general) 
ModifyGraph [/W=winName/Z] key=value [, key=value]…
The ModifyGraph operation modifies the target or named graph. This section of ModifyGraph relates to 
general graph window settings.
Parameters
expand=e
Specifies the onscreen expansion (or magnification) factor of a graph. e may be 
zero or 0.125 to 8 times expansion.
Graph magnification affects only base graphs (not subwindowed graphs), and it 
affects only the onscreen display; it has no effect on graph exporting or printing.
When magnification changes, the graph window will automatically resize except 
for negative values, which are used in recreation macros where the size is already 
correct.
frameInset= i
Specifies the number of pixels by which to inset the frame of the graph 
subwindow.
frameStyle= f
gfMult=f
Multiplies font and marker size by f percent. Clipped to between 25% and 400%; 
it is applied after all other font and marker size calculations.
gFont=fontStr
Specifies the name of the default font for the graph, overriding the normal default 
font. The normal default font for a subgraph is obtained from its parent while a 
base graph uses the value set by the DefaultFont operation.
gfSize=gfs
Sets the default size for text in the graph. Normally, the default size for text is 
proportional to the graph size; gfSize will override that calculation as will the 
gfRelSize method. Use a value of -1 to make a subgraph get its default font size from 
its parent.
gfRelSize=pct
Specifies the percentage of the graph size to use in calculating a default size for 
text in the graph. This overrides the normal method for setting default font size 
as a function of graph size. When used, the default marker size is set to one third 
the font size. Use a value of 0 to revert to the default method.
gmSize=gms
Sets the default size for markers in the graph. Use a value of -1 to make a 
subgraph get its default marker size from its parent.
height=heightSpec
Sets the height for the graph area. See the Examples.
ModifyGraph
Specifies the frame style for a graph subwindow.
The last three styles are fake 3D and will look good only if the background 
color of the enclosing space and the graph itself is a light shade of gray.
f=0:
None.
f=1:
Single.
f=2:
Double.
f=3:
Triple.
f=4:
Shadow.
f=5:
Indented.
f=6:
Raised.
f=7:
Text well.

ModifyGraph (general)
V-612
swapXY=s
useComma=uc
UIControl=f
Disables certain aspects of the user interface for graphs. The UIControl keyword, 
added in Igor Pro 7.00, is for use by advanced Igor programmers who want to 
disable user actions.
This is a bitwise setting. Setting Bit Parameters on page IV-12 for details about 
bit settings.
To disable items in the Graph menu use SetIgorMenuMode.
useDotForX=u
In the display of axis labels, if u=1 then, in instances of exponential notation such 
as “5x103”, the normal “x” is replaced with a dot giving “5x103”. useDotForX was 
added in Igor Pro 9.00.
useLongMinus=m
Uses a normal (m=0; default) or long dash (m=1) for the minus sign.
width=widthSpec
Sets the width of the graph area. See the examples.
Sets the orientation of the X and Y axes.
s=0:
Normal orientation of X and Y axes.
s=1:
Swap X and Y values to plot Y coordinates versus the 
horizontal axes and X coordinates versus the vertical axes. 
The effect is similar to mirroring the graph about the lower-
left to upper-right diagonal.
Controls the decimal separator used in tick mark labels.
uc=0:
Use period as decimal separator and comma as thousands 
separator (default) when displaying numbers in graph labels 
and annotations.
uc=1:
Use comma as decimal separator and period as the thousands 
separator. This does not alter the presentation of numbers in 
\{expression} constructs in annotations.
f is defined as follows:
Bit 0:
Disable axis click. Prevents moving or otherwise modifying an 
axis.
Bit 1:
Disable cursor click. Prevents moving a graph cursor.
Bit 2:
Disable trace drag. Prohibits the click-and-hold action to offset a 
trace on the graph.
Bit 3:
Disable marquee. When set, you can't make a marquee on the 
graph, which in turn prevents changing the range of the graph 
using the marquee.
Bit 4:
Disable draw mode.
Bit 5:
Disable double click. Prohibits any double-click action. In general, 
double-clicks in a graph bring up dialogs to modify the graph's 
appearance.
Bit 6:
Disable clicks on annotations. Prevents modification of 
annotations.
Bit 7:
Disable tool tips.
Bit 8:
Disable contextual menus.
Bit 9:
Disable marquee menu. With this set, you can still have a 
marquee and use it for, i.e., selecting some portion of the graph, 
but you can't use the maruqee menu to change the graph's range. 
Note that if bit 3 is set, this bit is moot.
Bit 10:
Disable mouse wheel events. This will prevent axis scaling using 
the mouse wheel.
Bit 11:
Disable option-drag. Prevents offsetting the graph by holding 
down the option (Macintosh) or Alt (Windows) key and then 
dragging in the plot area.
