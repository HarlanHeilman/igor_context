# Axis Label Special Effects

Chapter II-13 — Graphs
II-318
Another technique is to use Igor’s drawing tools to create fake axes. For an example, choose FileExample 
ExperimentsGraphing TechniquesNew Polar Graph Demo or FileExample ExperimentsGraphing 
TechniquesTernary Diagram Demo.
Axis Labels
The text for an axis label in a graph can come from one of two places. If you specify units for the wave which 
controls an axis, using the Change Wave Scaling dialog, Igor uses these units to label the axis. You can over-
ride this labeling by explicitly entering axis label text using the Axis Label tab of the Modify Axis dialog.
To display the dialog, choose GraphLabel Axis or double-click an axis label. Select the axis that you want 
to label from the Axis pop-up menu and then enter the text for the axis label in the Axis Label area. Further 
label formatting options are available in the Label Options Tab.
There are two parts to an axis label: the text for the label and the special effects such as font, font size, super-
script or subscript. You specify the text by typing in the Axis Label area. At any point in entering the text, 
you can choose a special effect from a pop-up menu in the Insert area.
The Label Preview area shows what the axis label will look like, taking the text and special effects into account. 
You can not enter text in the preview. You can also see your label on the graph if you check the Live Update 
checkbox.
Axis Label Escape Codes
When you choose a special effect, Igor inserts an 
escape code in the text. An escape code consists of a 
backslash character followed by one or more charac-
ters. It represents the special effect you chose. The 
escape codes are cryptic but you can see their effects in 
the Label Preview box.
You can insert special affects at any point in the text by clicking at that point and choosing the special effect 
from the Insert pop-ups.
Choosing an item from the Font pop-up menu inserts a code that changes the font for subsequent characters 
in the label. The font pop-up also has a “Recall font” item. This item is used to make elaborate axis labels. 
See Elaborate Annotations on page III-51.
Choosing an item from the Font Size pop-up menu inserts a code that changes the font size for subsequent 
characters in the label. The font size pop-up also has a “Recall size” item used to make elaborate axis labels.
Axis Label Special Effects
The Special pop-up menu includes items for controlling many features including superscript, subscript, 
justification, and text color, as well as items for inserting special characters, markers and pictures.
The Store Info, Recall Info, Recall X Position, and Recall Y Position items are used to create elaborate anno-
tations. See Elaborate Annotations on page III-51.
The most commonly used items are Superscript, Subscript and Normal. To create a superscript or subscript, 
use the Special pop-up menu to insert the desired code, type the text of the superscript or subscript and then 
finish with the Normal code. For example, suppose you want to create an axis label that reads “Phase space 
density (s3m-6)”. To do this, type “Phase space density (s”, choose the Superscript item from the Special pop-
up menu, type “3”, choose Normal, type “m”, choose Superscript, type “-6”, choose Normal and then type 
“)”. See Chapter III-2, Annotations, for a complete discussion of these items.
The “Wave controlling axis” item inserts a code that prints the name of the first wave plotted on the given 
axis.
The Trace Symbol submenu inserts a code that draws the symbol used to plot the selected trace.
Joules\E
axis label preview
escape code
text
Joulesx106
