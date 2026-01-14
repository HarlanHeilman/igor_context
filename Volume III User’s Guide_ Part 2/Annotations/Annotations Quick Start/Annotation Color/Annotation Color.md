# Annotation Color

Chapter III-2 — Annotations
III-39
\{"%g",mean(TagWaveRef())}
The TagVal and TagWaveRef functions work only while Igor is in the process of evaluating the annotation text, 
so you should use them only in annotation dynamic text or in a function called from annotation dynamic text.
Annotation Tabs
The Text Tab’s Annotation text area actually has two functions which are controlled by the pop-up menu at 
its top-left corner. If you choose Set Tabs from this pop-up menu, Igor shows the tab stops for the annotation.
By default, an annotation has 10 tab stops spaced 1/2 inch apart. You can change the tab stops by dragging 
them along the ruler. You can remove a tab stop by dragging it down off the ruler. You can add a tab by 
dragging it from the tab storage area at the left onto the ruler.
Igor supports a maximum of 10 tab stops per annotation and they are always left-aligned tabs. There is only 
one set of tab stops per annotation and they affect the entire annotation.
General Annotation Properties
Most annotation properties are common to all kinds of annotations.
Annotation Name
You can assign a name to the annotation with the Name item. In the Modify Annotation dialog, this is the 
Rename item. The name is used to identify the annotation in a Tag, TextBox, ColorScale, or Legend opera-
tion. Annotation names must be unique in a given window. See Programming with Annotations on page 
III-52 for more information.
Annotation Frame
In the Frame Tab, the Frame and Border pop-up menus allow you to frame the annotation with a box or 
shadow box, to underline the textbox, or to have no frame at all. The line size of the frames and the shadow 
are set by the Thickness and Shadow values.
By default, framed annotations also have a 1-point “halo” that surrounds them to separate them from their 
surroundings. The halo takes on the color of the annotation’s background color. You can change the width 
of this halo to a value between 0 and 10 points by setting the desired thickness in the Halo box in the Frame 
tab. A fractional value such as 0.5 is permitted.
Specifying a negative value for Halo allows the halo thickness to be overridden by the global variable V_TB-
BufZone in the root data folder. If the variable doesn’t exist, the absolute value of the entered value is used. 
The default halo value is -1. You can override the default halo by setting the V_TBBufZone global in a 
IgorStartOrNewHook hook function. See the example in User-Defined Hook Functions on page IV-280.
Annotation Color
The Frame tab contains most of the annotation’s color settings.
Use the Foreground Color pop-up menu to set the initial text color. You can change the color of the text from 
the initial foreground color by inserting a color escape code using the Special pop-up menu in the Text tab.
Use the Background pop-up menu to set the background mode and color:
Background Color Mode
Effect
Opaque
The annotation background covers objects behind. You choose the 
background color from a pop-up menu.
Transparent
Objects behind the annotation show through.
