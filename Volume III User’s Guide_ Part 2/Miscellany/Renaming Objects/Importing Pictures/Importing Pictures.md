# Importing Pictures

Chapter III-17 — Miscellany
III-509
10. Reboot your machine twice. To get the best results, you must reboot your machine 2 times after any 
changes to the display settings.
11. After your machine restarts twice, start Igor. Except for occasional minor glitches, it should work prop-
erly.
If the preceding instructions do not give useable results, you may find it necessary to fall back to standard 
resolution for the high-resolution display. To do this, set Resolution to standard resolution and set Scale 
and Layout to 100%. Standard resolution is usually half the recommended resolution - for example 1920 x 
1080 instead of 3140 x 2160. If you do this, you can make either display the main display.
Pictures
Igor can import pictures from other programs for display in graphs, page layouts and notebooks. It can also 
export pictures from graphs, page layouts and tables for use in other programs. Exporting is discussed in 
Chapter III-5, Exporting Graphics (Macintosh), and Chapter III-6, Exporting Graphics (Windows). This section 
discusses how you can import pictures into Igor, what you can do with them and how Igor stores them.
For information on importing images as data rather than as graphics, see Loading Image Files on page II-157.
Importing Pictures
There are three ways to import a picture.
•
Pasting from the Clipboard into a graph, layout, or notebook
•
Using the Pictures dialog (Misc menu) to import a picture from a file or from the Clipboard
•
Using the LoadPICT operation (see page V-506) to import a picture from a file or from the Clipboard
Each of these methods, except for pasting into a notebook, creates a named, global picture object that you can 
use in one or more graphs or layouts. Pasting into a notebook creates a picture that is local to the notebook.
This table shows the types of graphics formats from which Igor can import pictures:
Format
Notes
PDF (Portable Document Format)
Macintosh: Supported in native graphics only.
Windows: Supported in Igor Pro 9.00 and later.
See Importing PDF Pictures.
EMF (Enhanced Metafile)
Supported in Windows native graphics only.
See Graphics Technology on Windows on page III-506 for information 
about different types of EMF pictures.
BMP (Windows bitmap)
Supported in on Windows only.
BMP is sometimes called DIB (Device Independent Bitmap).
PNG (Portable Network Graphics)
Lossless cross-platform bitmap format
JPEG
Lossy cross-platform bitmap format
TIFF (Tagged Image File Format)
Lossless cross-platform bitmap format
