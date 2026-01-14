# Notebook (Writing Graphics)

Notebook (Text Properties)
V-705
Notebook
(Text Properties) 
Notebook text property parameters
This section of Notebook relates to setting the text properties of the current selection in the notebook.
Notebook
(Writing Graphics) 
Writing notebook graphics parameters
This section of Notebook relates to inserting graphics at the current selection in the notebook.
These graphics keywords are allowed for formatted text files only, not for plain text files.
font="fontName"
"fontName" is the name of the font. Use "default" to specify the paragraph’s ruler 
font.
If you specify an unavailable font, it does nothing. This is so that, when you share 
procedures with a colleague, using a font that the colleague does not have will not 
cause your procedures to fail. The downside of this behavior is that if you misspell a 
font name you will get no error message.
fSize=fontSize
Text size from 3 to 32000 points.
Use -1 to specify the paragraph’s ruler size.
fStyle=fontStyle
syntaxColorSelection=n
Use n=1 to syntax-color the selected text in the notebook. This is the equivalent of 
selecting NotebookSyntax Color Selection. Other values of n are reserved for future 
use.
To remove syntax coloring, use the textRGB keyword to set the selected text to a 
specified color.
The syntaxColorSelection keyword was added in Igor Pro 9.00.
textRGB=(r,g,b[,a])
Specifies text color. r, g, b, and a specify the color and optional opacity as RGBA 
Values. The default is opaque black.
vOffset=v
Sets the vertical offset in points (positive offset is down, negative is up). Use this to 
create subscripts and superscripts. vOffset is allowed for formatted text files only, not 
for plain text files.
convertToPNG=x
Converts all pictures in the current selection to cross-platform PNG format. If the 
picture is already PNG, it does nothing.
x is the resolution expansion factor, an integer from 1 to 16 times screen resolution. x 
is clipped to legal limits.
A binary coded integer with each bit controlling one aspect of the text style as 
follows:
Use -1 to specify the paragraph’s ruler style. To set bit 0 and bit 1 (bold italic), use 
20+21 = 3 for fontStyle. See Setting Bit Parameters on page IV-12 for details about 
bit settings.
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough

Notebook (Writing Graphics)
V-706
frame=f
insertPicture={pictureName, pathName, filePath, options}
Inserts a picture from a file specified by pathName and filePath. The supported 
graphics file formats are listed under Inserting Pictures on page III-13.
pictureName is the special character name (see Special Character Names on page 
III-14) to use for the inserted notebook picture or $"" to automatically assign a name.
pathName is the name of an Igor symbolic path created via NewPath or $"" to use no 
path.
filePath is a full path to the file to be loaded or a partial path or simple file name 
relative to the specified symbolic path.
If pathName and filePath do not fully specify a file, an Open File dialog is displayed 
from which the user can choose the file to be inserted.
The variable V_flag is set to 1 if the picture was inserted or to 0 otherwise, for example, 
if the user canceled from the Open File dialog.
The string variable S_name is set to the special character name of the picture that was 
inserted or to "" if no picture was inserted.
The string variable S_fileName is set to the full path of the file that was inserted or to 
"" if no picture was inserted.
picture={objectSpec, mode, flags [, expansion]}
Inserts a picture based on the specified object.
objectSpec is usually just an object name, which is the name of a graph, table, page 
layout, Gizmo plot, or picture from Igor's picture gallery (MiscPictures). See further 
discussion below.
mode controls what happens when you insert a picture of a graph, table or page layout 
window. It does not affect insertions of pictures from the picture gallery.
Sets the frame used for the picture and insertPicture keywords.
f=0:
No frame (default).
f=1:
Single frame.
f=2:
Double frame.
f=3:
Triple frame.
f=4:
Shadow frame.
options is a bitwise parameter interpreted as follows:
All other bits are reserved and must be set to zero.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
If set, an Open File dialog is displayed even if the file is fully specified 
by pathName and filePath.
Bit 1:
Determines what to do in the event of a name conflict. If set, the existing 
special character with the conflicting name is overwritten. If cleared, a 
unique name is created and used as the special character name for the 
inserted picture.

Notebook (Writing Graphics)
V-707
When using the picture keyword, you may include a coordinate specification after the object name in 
objectSpec. For example:
Notebook Notebook1 picture={Layout0(100, 50, 500, 700), 1, 1}
The coordinates are in points. A coordinate specification of (0, 0, 0, 0) behaves the same as no coordinate 
specification at all.
Modes -6, -7, -8, and -9 require Igor Pro 7.00 or later.
In Igor 7 and 8, mode=-8 produced PDF on Macintosh and EMF on Windows. As of 
Igor Pro 9.00, it produces PDF on both Macintosh and Windows. If you were using -
8 for EMF on Windows, change your code to use -2.
Mode -2 (PDF on Macintosh, EMF on Windows) is recommended for platform-
specific graphics. Mode -5 (PNG) is recommended for platform-independent bitmap 
graphics. Mode -8 (PDF) is recommended for platform-independent vector graphics 
but see the note above about -8 on Windows.
If objectSpec names a Gizmo window, only modes -5, -6, or -7 are allowed.
Modes -2 through 8 are supported for backward compatibility. In previous versions 
of Igor, they selected other formats that are now obsolete.
See Chapter III-5, Exporting Graphics (Macintosh), Chapter III-6, Exporting 
Graphics (Windows), and Metafile Formats on page III-102 for further discussion of 
these formats.
expansion is optional and requires Igor Pro 7.00 or later. It affects only modes -5, -6, 
and -7.
expansion sets the expansion factor over screen resolution. expansion must be an 
integer between 1 and 8 and is usually 1, 2, 4 or 8. The default value is 1.
scaling={h, v}
Sets the horizontal(h) and vertical (v) scaling for the selected picture or the picture and 
insertPicture keywords. h and v are in percent.
mode specifies the format of the picture as follows:
mode
Macintosh
Windows
-9
SVG
SVG
-8
Igor PDF
Igor PDF
-7
TIFF
TIFF
-6
JPEG
JPEG
-5
PNG
PNG
-4
4X PNG
Device-independent bitmap
-2
8X PDF
8X Enhanced metafile
-1
8X PDF
8X Enhanced metafile
0
8X PDF
8X Enhanced metafile
1
1X PDF
8X Enhanced metafile
2
2X PDF
8X Enhanced metafile
4
4X PDF
8X Enhanced metafile
8
8X PDF
8X Enhanced metafile
flags is a bitwise parameter interpreted as follows:
All other bits are reserved and must be set to zero.
For color, set flags = 20 = 1.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
0 for black and white, 1 for color.

Notebook (Writing Graphics)
V-708
If the object is a graph, the coordinate specification determines the width and height of the graph. If you 
omit the coordinate specification, Igor takes the width and height from the graph window.
If the object is a layout, the coordinate specification identifies a section of the layout. If you omit the coordinate 
specification, Igor selects a section of the layout that includes all objects in the layout plus a small margin.
For any other kind of object, Igor ignores the coordinate specification if it is present.
The scaling and frame keywords affect the selected picture, if any. If no picture is selected, they affect the 
insertion of a picture using the picture or insertPicture keywords. For example, this command inserts a picture 
of Graph0 with 50% scaling and a double frame:
Notebook Test1 scaling={50, 50}, frame=2, picture={Graph0, 1, 1}
If no picture is selected and no picture is inserted, scaling and frame have no effect.
InsertPicture Example
Function InsertPictureFromFile(nb)
String nb
// Notebook name or "" for top notebook
if (strlen(nb) == 0)
nb = WinName(0, 16, 1)
endif
if (strlen(nb) == 0)
Abort "There are no notebooks"
endif
// Display Open File dialog to get the file to be inserted
Variable refNum
// Required for Open but not really used
String fileFilter = "Graphics Files:.eps,.jpg,.png;All Files:.*;"
Open /D /R /F=fileFilter refNum
String filePath = S_fileName
if (strlen(filePath) == 0)
Print "You cancelled"
return -1
endif
Notebook $nb, insertPicture={$"", $"", filePath, 0}
if (V_flag)
Print "Picture inserted"
else
Print "No picture inserted"
endif
return 0
End
Save notebook pictures to files
The savePicture keyword is allowed for formatted text files only, not for plain text files.
savePicture={pictureName, pathName, filePath, options}
 
Saves a picture from a formatted text notebook to a file specified by pathName and 
filePath.
pictureName is the special character name (see Special Character Names on page 
III-14) of the picture to be saved or $"" to save the selected picture in which case one 
picture and one picture only must be selected in the notebook.
pathName is the name of an Igor symbolic path created via NewPath or $"" to use no 
path.
filePath is a full path to the file to be written or a partial path or simple file name 
relative to the specified symbolic path.
If pathName and filePath do not fully specify a file, a Save File dialog is displayed in 
which the user can specify the file to be written.
