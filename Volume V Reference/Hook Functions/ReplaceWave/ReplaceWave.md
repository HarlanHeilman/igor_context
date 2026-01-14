# ReplaceWave

ReplaceText
V-801
ReplaceText 
ReplaceText [/W=winName/N=name] textStr
The ReplaceText operation replaces the text in the most recently created or changed annotation or in the 
annotation specified by /W=winName and/N=name.
Parameters
textStr can contain escape codes to set the font, size, style, color and other properties. See Annotation 
Escape Codes on page III-53 for details.
If the annotation is a color scale, this command replaces the text of the color scale’s main axis label.
Flags
See Also
Tag, TextBox, ColorScale, Legend, AppendText, Annotation Escape Codes on page III-53.
ReplaceWave 
ReplaceWave [/W=winName] allinCDF
ReplaceWave [/X/W=winName] trace=traceName, waveName
ReplaceWave [/X/Y/W=winName] image=imageName, waveName
ReplaceWave [/X/Y/W=winName] contour=contourName, waveName
The ReplaceWave operation replaces waves displayed in a graph with other waves. The waves to be 
replaced, and the replacement waves are chosen by the flags, the keyword and the wave names on the 
command line.
Flags
Keywords
/N=name
Replaces the text of the named tag or textbox.
/W=winName
Replaces text in the named graph window or subwindow. When omitted, action will 
affect the active window or subwindow. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/W=winName
Replaces the wave in the named graph window or subwindow. When omitted, action 
will affect the active window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/X
Replaces the wave supplying X coordinates.
If the trace represents a category plot, the wave must be either a text wave or the 
special keyword '_labels_' to use dimension labels from the Y wave controlling the 
axis.
/Y
Replaces the wave supplying Y data.
allinCDF
Searches the current data folder for waves with the same names as waves used in 
the graph. If found and if the waves are of the correct type, they replace the 
existing waves. Thus, if you have several data folders with identically-named 
waves containing data from different experimental runs, you can browse through 
the runs by moving from one data folder to another, using ReplaceWave 
allinCDF to update the graph.
contour=contourName
Replaces the wave supplying the Z data for contourName. If /X or /Y is used, 
replaces the wave used to set the X or Y data spacing (if the Z data are in a matrix) 
or the wave used to supply the X or Y positions if XYZ triplets were specified with 
three separate waves.
