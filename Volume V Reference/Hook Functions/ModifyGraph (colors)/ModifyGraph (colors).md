# ModifyGraph (colors)

ModifyGraph (colors)
V-634
Flags
Details
With the prescaleExp parameter, you can force tick and axis label scaling to values different from the defaults. 
For example, if you have data whose X scaling ranges from 9pA to 120pA and you display this on a log axis, 
the tick marks will be labelled 10pA and 100pA. But if you really want the tick marks labeled 10 and 100 with 
pA in the axis label, you can set the prescaleExp to 12. To see this, execute the following commands:
Make/O jack=x
Display jack
SetScale x,9e-12,120e-12,"A",jack
ModifyGraph log(bottom)=1
then execute:
ModifyGraph prescaleExp(bottom)=12
The tickExp parameter applies to units that do not traditionally use SI prefix characters. For example, one usually 
speaks of 10-3 Torr and not mTorr. To see how this feature works, execute the following example commands:
Make/O jack=x
Display jack
SetScale x,1E-7,1E-5,"Torr",jack
ModifyGraph log(bottom)=1
then execute:
ModifyGraph tickExp(bottom)=1
at this point, the tick mark labels have Torr in them. If you want to eliminate the units from the tick marks, 
execute:
ModifyGraph tickUnit(bottom)=1
and if you now want Torr in the label string, use the \U escape in the label string:
Label bottom "\\U"
To see the effect of linTkLabel, execute these commands:
Make/O jack=x
Display jack
SetScale x,1E-7,1E-5,"Torr",jack
then execute:
ModifyGraph linTkLabel(bottom)=1
and then try:
ModifyGraph tickExp(bottom)=1
and finally:
ModifyGraph tickUnit(bottom)=1
ModifyGraph
(colors) 
ModifyGraph [/W=winName/Z] key [(axisName)]=(r,g,b,[a])
[, key [(axisName)]=(r,g,b[,a])]…
This section of ModifyGraph relates to modifying the use of colors in a graph.
Parameters
Most of the key parameters may take an optional axisName enclosed in parentheses. axisName is “left”, 
“right”, “top”, “bottom” or the name of an free axis such as “vertCrossing”.
Where the parameter descriptions indicate an “(axisName)”, it may be omitted to change all axes in the graph.
r, g, b, and a specify the color and optional opacity as RGBA Values. (0, 0, 0) specifies opaque black and 
(65535, 65535, 65535) specifies opaque white.
/W=winName
Modifies the named graph window or subwindow. When omitted, action will affect 
the active window or subwindow. This must be the first flag specified when used in 
a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
Does not generate an error if the named axis does not exist in a style macro.
