# Picture Compatibility

Chapter III-15 — Platform-Related Issues
III-449
The Macintosh creator code for Igor is 'IGR0' (last character is zero).
Experiments and Paths
An Igor experiment sometimes refers to wave, notebook, or procedure files that are stored separate from 
the experiment file itself. This is discussed under References to Files and Folders on page II-24. In this case, 
Igor creates a symbolic path that points to the folder containing the referenced file. It writes a NewPath 
command in the experiment file to recreate the symbolic path when the experiment is opened. When you 
move the experiment to another computer or to another platform, this path may not be valid. However, Igor 
goes to great lengths to find the folder, if possible.
Igor stores the path to the folder containing the file as a relative path, relative to the experiment file, if pos-
sible. This means that Igor will be able to find the folder, even on another computer, if the folder’s relative 
location in the disk hierarchy is the same on both computers. You can minimize problems by using the same 
disk hierarchy on both computers.
If the folder is not on the same volume as the experiment file, then Igor can not use a relative path and must use 
an absolute path. Absolute paths cause problems because, although your disk hierarchy may be the same on 
both computers, often the name of the root volume will be different. For example, on the Macintosh your hard 
disk may be named “hd” while on Windows it may be named “C:”.
If Igor can not locate a folder or file needed to recreate an experiment, it displays a dialog asking you to 
locate it.
Picture Compatibility
Igor displays pictures in graphs, page layouts, control panels and notebooks. The pictures are stored in the 
Pictures collection (MiscPictures) and in notebooks. Graphs, page layouts and control panels reference 
pictures stored in the Pictures collection while notebooks store private copies of pictures.
This table shows the graphic formats that Igor can use to store pictures:
.txt
TEXT
Igor plain notebook 
.ihf
WMT0
Igor help file
.ibw
IGBW
Igor binary data file
Format
How To Create
Notes
PDF
Paste or use MiscPictures
Cross-platform high resolution vector format.
See Importing PDF Pictures on page III-510.
EMF (Enhanced 
Metafile)
Paste or use MiscPictures
Windows only
See Graphics Technology on Windows on page III-506 
for information about different types of EMF pictures.
BMP (bitmap)
Use MiscPictures
Windows Only.
BMP also called DIB (device-independent bitmap).
PNG (Portable 
Network Graphics)
Use MiscPictures
Cross-platform bitmap format
JPEG
Use MiscPictures
Cross-platform bitmap format
TIFF (Tagged Image 
File Format)
Use MiscPictures
Cross-platform bitmap format
Extension
File Type
What’s in the File
