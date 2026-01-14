# Text Info Variables

Chapter III-2 — Annotations
III-51
ColorScale Ticks Tab
The color scale’s axis ticks settings are similar to those for a graph axis:
The main axis tick marks can be automatically computed by checking Automatic Ticks, or you can control 
tick marks manually by checking User Ticks from Waves. In the latter case, you provide two waves: one 
numeric wave which specifies the tick mark positions, and one text wave which specifies the corresponding 
tick mark labels.
You can also specify user-defined tick values and labels to create a second axis. This might be useful, for 
example, to display a temperature range in Fahrenheit and in Celsius.You do this by choosing Axis 2 from 
the pop-up menu that normally shows Main Axis. The second axis is drawn on the opposite side of the color 
bar from the main axis.
The Tick Dimensions settings apply to both axes. A length of -1 means Auto. Otherwise the dimensions are in 
points. To hide tick marks, set Thickness to 0. 
Elaborate Annotations
It is possible to create elaborate annotations with subscripts, superscripts, and math symbols in Igor. Doing so 
requires entering escape codes. The Add Annotation dialog provides menus for inserting many of the escape 
codes that you might need.
This is feasible for relatively simple math expressions such as you might use for axis labels or to label graphs. For 
complex equations, you should use an Igor TeX formula or use a real equation editor and paste a picture repre-
senting the equation into an Igor graph or page layout.
Text Info Variables
The text info variable is a mechanism that uses escape codes that have a higher degree of “intelligence” than 
simple changes of font, font size, or style. Using text info variables, you can create quite elaborate annota-
tions if you have the patience to do it. Since you need to know about them only to do fancy things, if you 
are satisfied with simple annotations, skip the rest of these Text Info Variable sections.
A text info variable saves information about a particular “spot” (text insertion point) in an annotation. Spe-
cifically, it saves the font, font size, style (bold, italic, etc.), and horizontal and vertical positions of the spot.
