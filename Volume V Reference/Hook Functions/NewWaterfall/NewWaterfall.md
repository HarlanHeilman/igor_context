# NewWaterfall

NewWaterfall
V-691
to change all of your commands. Instead, you need only to change the symbolic path so that it points to the 
changed folder location.
NewPath sets the variable V_flag to zero if the operation succeeded or to nonzero if it failed. The main use 
for this is to determine if the user clicked Cancel when you use NewPath to display a choose-folder dialog.
On the Macintosh, pressing Command-Option as the Choose Folder dialog comes up will allow you to 
choose package folders and folders inside packages.
Examples
NewPath Path1, "hd:IgorStuff:Test 1"
// Macintosh
NewPath Path1, "C:IgorStuff:Test 1"
// Windows
creates the symbolic path named Path1 which refers to the specified folder (the path’s “value”). You can 
then refer to this folder in many Igor operations and dialogs by using the symbolic path name Path1.
See Also
The PathInfo operation; especially if you need to preset a starting path for the dialog.
KillPath
NewWaterfall 
NewWaterfall [flags] matrixWave [vs {xWave,yWave}]
The NewWaterfall operation creates a new waterfall plot window or subwindow using each column in the 
2D matrix wave as a waterfall trace.
You can manually set x and z scaling by specifying xWave and yWave to override the default scalings. Either 
xWave or yWave may be omitted by using a “*”.
Flags
Windows Note:
You can use either the colon or the backslash character to separate folders. However, 
the backslash character is Igor’s escape character in strings. This means that you have 
to double each backslash to get one backslash like so:
NewPath stuff, "C:\\IgorStuff\\Test 1"
Because of this complication, it is recommended that you use Macintosh path syntax 
even on Windows. See Path Separators on page III-451 for details.
/FG=(gLeft, gTop, gRight, gBottom)
Specifies the frame guide to which the outer frame of the subwindow is attached 
inside the host window.
The standard frame guide names are FL, FR, FT, and FB, for the left, right, top, and 
bottom frame guides, respectively, or user-defined guide names as defined by the 
host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.
/HIDE=h
Hides (h = 1) or shows (h = 0, default) the window.
/HOST=hcSpec
Embeds the new waterfall plot in the host window or subwindow specified by hcSpec.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/I
Sets window coordinates to inches.
