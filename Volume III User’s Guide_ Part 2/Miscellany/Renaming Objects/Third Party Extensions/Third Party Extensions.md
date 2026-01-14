# Third Party Extensions

Chapter III-17 — Miscellany
III-511
The Kill This Picture button will be dimmed if the selected picture is used in a currently open graph or layout.
Note:
Igor determines if a picture is in use by checking to see if it is used in an open graph or layout window.
If you kill a graph or layout that contains a picture and create a recreation macro, the recreation 
macro will refer to the picture by name. However, Igor does not check for this. It will consider the 
picture to be unused and will allow you to kill it. If you later run the recreation macro, an error 
will occur when the macro attempts to append the picture to the graph or layout. Therefore, don’t 
kill a picture unless you are sure that it is not needed.
NotebookPictures
When you paste a picture into a formatted notebook, you create a notebook picture. These work just like 
pictures in a word processor document. You can copy and paste them. These pictures will not appear in the 
Pictures or Rename Objects dialogs.
Igor Extensions
Igor includes a feature that allows a C or C++ programmer to extend its capabilities. An Igor extension is 
called an “XOP” (short for “external operation”). The term XOP comes from that fact that, originally, adding 
a command line operation was all that an extension could do. Now extensions can add operations, func-
tions, menus, dialogs and windows.
XOPs come in 32-bit and 64-bit varieties. Because almost all Igor users now run the 64-bit version of Igor, 
this section focuses on 64-bit XOPs.
WaveMetrics XOPs
The "Igor Pro Folder/Igor Extensions (64-bit)" and "Igor Pro Folder/More Extensions (64-bit)" folders contain 
XOPs that we developed at WaveMetrics. These add capabilities such as file-loading and instrument control 
to Igor and also serve as examples of what XOPs can do. These XOPs range from very simple to rather elab-
orate. Most XOPs come with help files that describe their operation.
The WaveMetrics XOPs are described in the XOP Index help file, accessible through the HelpHelp 
Windows submenu.
Third Party Extensions
A number of Igor users have written XOPs to customize Igor for their particular fields. Some of these are 
freeware, some are shareware and some are commercial programs. WaveMetrics publicizes third party 
XOPs through our Web page. User-developed XOPs are available from http://www.igorexchange.com.
A preview of the selected 
picture.
Loads a new picture from 
a file, usually created in a 
drawing program.
Loads a new picture that you have copied to the 
Clipboard, usually from a drawing program.
Click to place the picture in a 
graph or page layout.
Lists the named pictures 
in the picture gallery. 
Click to select a picture.
Creates an ASCII 
representation for use in 
procedures.
Removes the selected picture, 
from the collection.
Converts the selected picture 
into a platform-independent 
PNG format bitmap. Select the 
box for high resolution
