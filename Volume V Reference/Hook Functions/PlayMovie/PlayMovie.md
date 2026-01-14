# PlayMovie

PlayMovie
V-744
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
If the specified axis is not found and if the name is “left” or “bottom” then the first vertical or horizontal 
axis will be used.
If graphNameStr references a subwindow, the returned pixel value is relative to top left corner of base 
window, not the subwindow.
Axis ranges and other graph properties are computed when the graph is redrawn. Since automatic screen 
updates are suppressed while a user-defined function is running, if the graph was recently created or 
modified, you must call DoUpdate to redraw the graph so you get accurate axis information.
See Also
The AxisValFromPixel and TraceFromPixel functions.
PlayMovie 
PlayMovie [flags] [as fileNameStr]
The PlayMovie operation opens a movie file in a window and plays it.
Parameters
The file to be opened is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
The file is passed to the operating system to be opened with the default program for the given filename 
extension and the /W flag is ignored.
On Macintosh, prior to Mac OS 10.15 (Catalina,) QuickTime could be used to play a movie in an Igor 
window and could be controlled using PlayMovieAction. Since QuickTime is no longer available, movies 
no longer open in Igor windows on any operating system and PlayMovieAction after PlayMovie is no 
longer of use.
Flags
Details
If the movie file to be played is not fully specified by /P and fileNameStr, PlayMovie displays an Open File 
dialog to let you choose a movie file. See Symbolic Paths on page II-22 and Path Separators on page III-451 
for details.
See Also
Movies on page IV-245.
The PlayMovieAction operation.
/I
This flag is obsolete and is ignored.
/M
This flag is obsolete and is ignored.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing 
symbolic path.
/W=(left,top,right,bottom)
This flag is obsolete and is ignored.
/Z
No error reporting; an error is indicated by nonzero value of the variable 
V_flag. If the user clicks the cancel button in the Open File dialog, V_flag is set 
to -1.
