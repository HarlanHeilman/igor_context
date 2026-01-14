# Special Escape Codes

Chapter III-2 — Annotations
III-36
Font Escape Codes
Choosing an item from the Font pop-up menu inserts a code that changes the font for subsequent characters 
in the annotation. The checked font is the font currently in effect at the current insertion point in the anno-
tation text entry area.
If you don’t choose a font, Igor uses the default font or the graph font for annotations in graphs. You can 
set the default font using the Default Font item in the Misc menu, and the graph font using the Modify 
Graph item in the Graph menu. The Font pop-up menu also has a “Recall font” item. This item is used in 
elaborate annotations and is described under Text Info Variable Escape Codes on page III-55.
Font Size Escape Codes
Choosing an item from the Font Size pop-up menu inserts a code that changes the font size for subsequent 
characters in the annotation. The checked font size is the size currently in effect at the current insertion point 
in the annotation text entry area.
To insert a size not shown, choose any shown size, and edit the escape code to contain the desired font size. 
Annotation font sizes may be 03 to 99 points; two digits are required after the “\Z” escape code.
If you specify no font size escape code for annotations in graphs, Igor chooses a font size appropriate to the 
size of the graph unless you’ve specified a graph font size in the Modify Graph dialog. The default font size 
for annotations in page layouts is 10 points. The Font Size pop-up menu contains a “Recall size” item. This 
item is used in elaborate annotations and is described under Text Info Variable Escape Codes on page 
III-55.
Relative Font Size Escape Codes
Choosing an item from the Rel. Font Size pop-up menu inserts a code that changes the relative font size for 
subsequent characters in the annotation. Use values larger than 100 to increase the font size, and values 
smaller than 100 to decrease the font size.
To insert a size not shown, choose any shown relative size, and edit the escape code to contain the desired 
relative font size. Annotation relative font sizes may be 001 to 999 (1% to 999%). Three digits are required 
after the “\Zr” escape code.
Don’t use, say, 50% followed by 200% and expect to get exactly the original font size back; rounding inac-
curacies will prevent success (because font sizes are handled as only integers). For example, if you start with 
15 point text and use \Zr050 (50%) the result is 7 point text. 200% of 7 points is only 14 point text. Instead, 
use the Normal “\M” escape code, or an absolute font size or a recalled font size, to return to a known font 
size.
Special Escape Codes
Choosing an item from the Special pop-up menu inserts an escape code that makes subsequent characters 
superscript, subscript or normal, affects the style, position or color of subsequent text, or inserts the symbol 
with which a wave is plotted in a graph.

Chapter III-2 — Annotations
III-37
The first four items, Store Info, Recall Info, Recall X Position, and Recall Y Position are used to make elabo-
rate annotations and are described under Text Info Variable Escape Codes on page III-55.
The Style item invokes a subdialog that you use to change the style (bold, italic, etc.) for the annotation at 
the current insertion point in the annotation text entry area. This subdialog has a Recall Style checkbox that 
is used in elaborate annotations with text info variables.
The Superscript and Subscript items insert an escape code that makes subsequent characters superscript or 
subscript. Use the Normal item to return the text to the original text size and Y position.
The Backslash item inserts a code to insert a backslash that prints, rather than one which introduces an escape 
code. Igor does this by inserting two backslashes, which is an escape code that represents a backslash.
The Normal item inserts a code to return to the original font size and baseline. More precisely, Normal sets the 
font size and baseline to the values stored in text info variable 0 (see Text Info Variable Escape Codes on page 
III-55). The font and style are not affected.
The Justify items insert codes to align the current and following lines.
The Color item inserts a code to color the following text. The initial text color and the annotation back-
ground color are set in the Frame Tab.
The Wave Symbol item inserts a code that prints the symbol (line, marker, etc.) used to display the wave trace 
in the graph. This code is inserted automatically in a legend. You can use this menu item to manually insert a 
symbol into a tag, textbox, or color scale. For graph annotations, the submenu lists all the trace name instances 
in the top graph. For layout annotations, all the trace name instances in all graphs in the layout are listed.
The Character item presents a table from which you can select text and special characters to add to the annotation.
The Marker item inserts a code to draw a marker symbol. These symbols are independent of any traces in 
the graph.
Symbol that a trace is 
plotted with in a graph.
Bold, Italic, etc.
Return to starting font size 
and no offset from baseline.
Text Info Variables.
Insert symbols from a 
character map.
Insert a TeX formula 
template.
Choose a marker symbol 
independent of any traces.
