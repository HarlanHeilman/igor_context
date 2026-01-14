# AppendToGraph

AppendText
V-35
For general information on contour plots, see Chapter II-15, Contour Plots.
AppendText 
AppendText [/W=winName/N/NOCR [=n]] textStr
The AppendText operation appends a carriage return and textStr to the most recently created annotation, 
or to the named annotation in the target or graph or layout window. Annotations include tags, textboxes, 
color scales, and legends.
Parameters
textStr can contain escape codes to control font, font size and other stylistic variations. See Annotation 
Escape Codes on page III-53 for details.
Flags
Details
A textbox, tag, or legend can contain at most 100 lines. A color scale can have at most one line, and this line 
is the color scale’s main axis label.
See Also
The Tag, TextBox, ColorScale, ReplaceText, and Legend operations.
Annotation Escape Codes on page III-53.
AppendToGizmo 
AppendToGizmo [flags] keyword [=value]
The AppendToGizmo operation appends a Gizmo object or attribute operation to the top Gizmo window 
or to the Gizmo window specified by the /N flag.
Documentation for the AppendToGizmo operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "AppendToGizmo"
AppendToGraph 
AppendToGraph [flags] waveName [, waveName]…[vs xwaveName]
The AppendToGraph operation appends the named waves to the target or named graph. By default the 
waves are plotted versus the left and bottom axes.
Parameters
The waveNames parameters are the names of existing waves.
vs xwaveName plots the data values of waveNames against the data values of xwaveName.
If you are appending a new trace to an existing category plot, xwaveName must be the same as the one 
already controlling the plot’s X axis. If the existing X axis uses dimension labels from a Y wave, using the 
'_labels_' keyword, then xwaveName must be set to '_labels_'.
If you are appending a new category plot using a different X axis, xwaveName can refer any suitable text 
wave, or it may be '_labels_' to use dimension labels from the Y wave.
/N=name
Appends textStr to the named tag or textbox.
/NOCR[=n]
Omits the initial appending of a carriage return (allows a long line to be created with 
multiple AppendText commands). /NOCR=0 is the same as no /NOCR, and /NOCR=1 
is the same as just /NOCR.
/W=winName
Appends to an annotation in the named graph, layout window, or subwindow. 
Without /W, AppendText appends to an annotation in the topmost graph or layout 
window or subwindow. This must be the first flag specified when AppendText is 
used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
