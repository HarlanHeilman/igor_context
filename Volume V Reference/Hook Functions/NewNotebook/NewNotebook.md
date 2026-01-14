# NewNotebook

NewNotebook
V-684
Details
If either the path or the file name is omitted then NewMovie displays a Save File dialog to let you create a 
movie file. If both are present, NewMovie creates the file automatically.
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
There can be only one open movie at a time.
The target window at the time you invoke NewMovie must be a graph, page layout or Gizmo plot unless the 
/PICT flag is present. The window size should remain constant while adding frames to the movie. The 
window and optional sound wave are used to determine the size and sound properties only; they do not 
specify the first frame.
In Igor7 or later, the target window at the time you call NewMovie is remembered and is used by 
AddMovieFrame even if it is not the target window when you call AddMovieFrame.
The /PICT flag allows you to create a movie from a page layout in conjunction with the 
SavePICT/P=_PictGallery_ method. See SavePICT on page V-826. This allows creation of a movie from a 
source other than a graph, page layout or Gizmo window, but is rarely needed.
See Also
Movies on page IV-245.
The AddMovieFrame, AddMovieAudio, CloseMovie, PlayMovie, PlayMovieAction and SavePICT 
operations.
NewNotebook 
NewNotebook [flags] [as titleStr]
The NewNotebook operation creates a new notebook document.
Parameters
The optional titleStr is a string containing the title of the notebook window.
Flags
/L[=flatten]
Obsolete.
/O
Overwrite existing file, if any.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/PICT=pictName
Uses the specified picture (see Pictures on page III-509) rather than the top graph.
/S=soundWave
Adding a sound track is not currently supported. If you would like this feature, let us 
know.
/Z
No error reporting; an error is indicated by nonzero value of the output variable 
V_flag. If the user clicks the cancel button in the Save File dialog, V_flag is set to -1.
/FG=(gLeft, gTop, gRight, gBottom)
Specifies the frame guide to which the outer frame of the subwindow is attached 
inside the host window.
The standard frame guide names are FL, FR, FT, and FB, for the left, right, top, and 
bottom frame guides, respectively, or user-defined guide names as defined by the 
host. Use * to specify a default guide name.
Guides may override the numeric positioning set by /W.

NewNotebook
V-685
/HOST=hcSpec
Embeds the new notebook in the host window or subwindow specified by hcSpec. The 
host window or subwindow must be a control panel. Graphs and page layouts are not 
supported as hosts for notebook subwindows.
When identifying a subwindow with hcSpec, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
See Notebooks as Subwindows in Control Panels on page III-91 for more 
information.
/ENCG=textEncoding
textEncoding specifies the text encoding for the new notebook. This determines the 
text encoding used for later saving the notebook to a file.
See Text Encoding Names and Codes on page III-490 for a list of accepted values for 
textEncoding.
This flag was added in Igor Pro 7.00.
This flag is relevant for plain text notebooks only and has no effect for formatted 
notebooks because formatted text notebooks can contain multiple text encodings. See 
Plain Text File Text Encodings on page III-466 and Formatted Text Notebook File 
Text Encodings on page III-472 for details.
If you omit /ENCG or pass 0 (unknown) for textEncoding, the notebook's text encoding 
is determined by the default text encoding - see The Default Text Encoding on page 
III-465 for details.
For most purposes, UTF-8 (textEncoding=1) is recommended. Other values are 
available for compatibility with software that requires a specific text encoding. This 
includes Igor Pro 6 which uses MacRoman (textEncoding=2), Windows-1252 
(textEncoding=3) or Shift-JIS (textEncoding=4) depending on the operating system and 
localization.
This flag has an optional form that allows you to control whether the byte order mark 
is written when the notebook is later saved to disk. It applies to Unicode text 
encodings also. The form is:
/ENCG = {textEncoding, writeBOM }
If you use the simpler form or omit /ENCG entirely, the notebook's writeBOM 
property defaults to 1.
See Byte Order Marks on page III-471 for background information.
/F=format
/K=k
/N=winName
Sets the notebook’s window name to winName.
Specifies the format of the notebook:
format=0:
Plain text.
format=1:
Formatted text.
format=-1:
Displays a dialog in which the user can choose plain text or 
formatted text (default).
Specifies window behavior when the user attempts to close it.
If you use /K=2 or /K=3, you can still kill the window using the KillWindow 
operation.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
k=3:
Hides the window.

NewNotebook
V-686
Details
A notebook has a file name, a window name, and a window title. In the simplest case these will all be the same.
The file name is the name by which the operating system identifies the notebook once it is saved to disk. 
When you initially create a notebook, it is not associated with any file. However it still has a file name. This 
is the name that will be used when the file is saved to disk.
The window name is the name by which Igor identifies the window and therefore the name you specify in 
operations that act on the notebook.
The window title is what appears in the window’s title bar. If you omit the title, NewNotebook uses a 
default title that is the same as the window name.
If you specify the window name and the notebook format and omit the window title, this is the simplest 
case. NewNotebook creates the document with no user interaction. The file name, window name and 
window title will all be the same. For example:
NewNotebook/N=Notebook1/F=0
If you omit the window name, NewNotebook chooses a default name (e.g., “Notebook0”) and presents the 
standard New Notebook dialog.
If you omit the format or specify a format of -1 (either plain or formatted text), NewNotebook presents the 
standard New Notebook dialog. For example:
NewNotebook/N=Notebook1
// no format specified
See Also
The Notebook and OpenNotebook operations, and Chapter III-1, Notebooks.
Notebooks as Subwindows in Control Panels on page III-91.
/OPTS=options
/V=visible
Specifies whether the notebook window is visible (visible=1; default) or invisible 
(visible=0).
/W=(left,top,right,bottom)
Sets window location. Coordinates are in points for normal notebook windows. 
When used with the /HOST flag, the specified location coordinates can have one of 
two possible meanings:
When all values are less than 1, coordinates are assumed to be fractional relative to 
the host frame size.
When any value is greater than 1, coordinates are taken to be fixed locations measured 
in points, or Control Panel Units for control panel hosts, relative to the top left corner 
of the host frame.
Sets special options. options is a bitwise parameter interpreted as follows:
All other bits are reserved and must be set to zero.
If /OPTS is omitted, all bits default to zero.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Hide the vertical scroll bar.
Bit 1:
Hide the horizontal scroll bar.
Bit 2:
Set the write-protect icon initially to on.
Bit 3:
Sets the changeableByCommandOnly bit. When set, the user can 
not make any modifications.
