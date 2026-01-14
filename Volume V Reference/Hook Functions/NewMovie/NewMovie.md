# NewMovie

NewMovie
V-683
Details
When you create a new page layout window, if preferences are enabled, the page size is determined by the 
preferred page size as set via the Capture Layout Prefs dialog. If preferences are disabled, as is usually the 
case when executing a procedure, the page is set to the factory default size.
See Also
AppendLayoutObject, DoWindow, RemoveLayoutObjects, and ModifyLayout.
NewMovie 
NewMovie [flags] [as fileNameStr]
The NewMovie operation opens a movie file in preparation for adding frames.
By default, NewMovie creates MP4 movies on both Macintosh and Windows. Prior to Igor Pro 8, it created 
QuickTime movies on Macintosh and AVI movies on Windows. That older technology is still available 
using the /A flag on Windows, but it is deprecated and may not be available in future operating systems. 
QuickTime is no longer available as of Mac OS 10.15 (Catalina) and the /A flag results in an error in Igor Pro 
9 on all Mac operating system versions.
Parameters
The file to be opened is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If 
NewMovie can not determine the location of the file from fileNameStr and pathName, it displays a dialog 
allowing you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
/N=name
Requests that the layout have this name, if it is not in use. If it is in use, then name0, 
name1, etc. are tried until an unused window name is found. In a function or macro, 
S_name is set to the chosen layout name.
If /N is not used, a name of the form “Layoutn”, where n is some integer, is assigned. 
In a function or macro, the assigned name is stored in the S_name string. This is the 
name you can use to refer to the page layout window from a procedure. Use the 
RenameWindow operation to rename the window.
/P=orientation
Sets the orientation of the page in the layout to either Portrait or Landscape (e.g., 
Layout/P=Landscape). See Details.
/W=(left,top,right,bottom)
Gives the layout window a specific location and size on the screen. Coordinates for 
/W are in points.
/A
Windows: NewMovie/A creates movie files using the deprecated AVI technology.
Macintosh: NewMovie/A returns an error.
/CF=factor
Specifies a compression factor relative to the theoretical uncompressed value. The 
default compression factor of 200 is used if you omit /CF. /CF was added in Igor Pro 
8.00. It is ignored if you use the /A flag.
/CTYPE=typeStr
Specifies the compression codec to use.
Windows: typeStr can be "WMV3" to create .wmv files or "mp4v" to create MP4 files 
(default).
Macintosh: /CTYP is ignored and an MP4 file is created.
/F=frameRate
Frames per second between 1 and 60. frameRate defaults to 30.
/I
Obsolete.
