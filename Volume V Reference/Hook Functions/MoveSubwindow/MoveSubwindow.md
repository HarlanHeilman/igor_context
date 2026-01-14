# MoveSubwindow

MoveString
V-663
Moving the folder to a different volume actually creates a new folder with new volume refnum and 
directory IDs, and symbolic paths pointing to or into the moved folder aren’t updated. They will be 
pointing at a deleted folder (they’re probably invalid).
Examples
Rename a folder (“move” it to the same folder):
MoveFolder "Macintosh HD:folder" as "Macintosh HD:Renamed Folder"
Rename a folder referred to by only a path:
NewPath/O myPath "Macintosh HD:folder"
MoveFolder/P=myPath as "::Renamed Folder"
Move a folder from one volume to another. This moves “Macintosh HD:My Folder” inside “Server:My 
Folder” if “Server:My Folder” already exists:
MoveFolder "Macintosh HD:My Folder" as "Server:My Folder"
Move a folder from one volume to another. This overwrites “Server:My Folder” (if it existed) with the 
moved “Macintosh HD:My Folder”:
MoveFolder/O "Macintosh HD:My Folder" as "Server:My Folder"
Move user-selected folder in any folder as “Renamed Folder” into a user-selected folder (possibly the same 
one):
MoveFolder as "Renamed Folder"
Move user-selected file in any folder as “Moved Folder” in any folder:
MoveFolder/I=3 as "Moved Folder"
See Also
MoveFile, CopyFolder, DeleteFolder, IndexedDir, PathInfo, and RemoveEnding. Symbolic Paths on 
page II-22.
MoveString 
MoveString sourceString, destDataFolderPath [newname]
The MoveString operation removes the source string variable and places it in the specified location 
optionally with a new name.
Parameters
sourceString can be just the name of a string variable in the current data folder, a partial path (relative to the 
current data folder) and variable name or an absolute path (starting from root) and variable name.
destDataFolderPath can be a partial path (relative to the current data folder) or an absolute path (starting 
from root).
Details
An error is issued if a variable or wave of the same name already exists at the destination.
Examples
MoveString :foo:s1,:bar:
// Move string s1 into data folder bar
MoveString :foo:s1,:bar:ss1
// Move string s1 into bar with new name ss1
See Also
The MoveVariable, MoveWave, and Rename operations; andChapter II-8, Data Folders.
MoveSubwindow 
MoveSubwindow [/W=winName] key = (values)[, key = (values)]…
The MoveSubwindow operation moves the active or named subwindow to a new location within the host 
window. This command is primarily for use by recreation macros; users should use layout mode for 
repositioning subwindows.
Parameters
fguide=(gLeft, gTop, gRight, gBottom)

MoveSubwindow
V-664
Flags
Details
When moving an exterior subwindow, only the fnum keyword may be used. The values are the same as the 
NewPanel /W flag for exterior subwindows.
The names for the built-in guides are as defined in the following table:
The frame guides apply to all window and subwindow types. The graph rectangle and plot rectangle guide 
types apply only to graph windows and subwindows.
See Also
The MoveWindow operation. Chapter III-4, Embedding and Subwindows for further details and 
discussion.
Specifies the frame guide name(s) to which the outer frame of the subwindow is 
attached inside the host window.
The frame guides are identified by the standard names or user-defined names as 
defined by the host. Use * to specify a default guide name.
When the host is a graph, additional standard guides are available for the outer graph 
rectangle and the inner plot rectangle (where traces are plotted).
See Details for standard guide names.
fnum=(left, top, right, bottom)
Specifies the new location of the subwindow. The location coordinates of the 
subwindow sides can have one of two possible meanings:
When all values are less than 1, coordinates are assumed to be fractional relative to 
the host frame size.
When any value is greater than 1, coordinates are taken to be fixed locations measured in 
points, or Control Panel Units for control panel hosts, relative to the top left corner of the 
host frame.
pguide=(gLeft, gTop, gRight, gBottom)
Specifies the guide name(s) to which the plot rectangle of the graph subwindow is 
attached inside the host window.
Guides are identified by the standard names or user-defined names as defined by the 
host. Use * to specify a default guide name.
See Details for standard guide names.
/W= winName
Moves the subwindow in the named window or subwindow. When omitted, action 
will affect the active subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
Left
Right
Top
Bottom
Subwindow Frame
FL
FR
FT
FB
Outer Graph Rectangle
GL
GR
GT
GB
Inner Plot Rectangle
PL
PR
PT
PB
