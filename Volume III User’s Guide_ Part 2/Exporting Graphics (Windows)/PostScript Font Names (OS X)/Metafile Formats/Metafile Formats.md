# Metafile Formats

Chapter III-6 — Exporting Graphics (Windows)
III-102
Overview
This chapter discusses exporting graphics from Igor graphs, page layouts, tables, and Gizmo plots to 
another program on Windows. You can export graphics through the clipboard by choosing EditExport 
Graphics, or through a file, by choosing FileSave Graphics.
Igor Pro supports a number of different graphics export formats. You can usually obtain very good results 
by choosing the appropriate format, which depends on the nature of your graphics, your printer and the 
characteristics of the program to which you are exporting.
Unfortunately, experimentation is sometimes required to find the best export format for your particular cir-
cumstances. This section provides the information you need to make an informed choice.
This table shows the available graphic export formats on Windows:
Metafile Formats
The metafile formats are Windows vector graphics formats that support drawing commands for the indi-
vidual objects such as lines, rectangles and text that make up a picture. Drawing programs can decompose 
a metafile into its component parts to allow editing the individual objects. Most word processing programs 
treat a metafile as a black box and call the operating system to display or print it.
Enhanced Metafile (EMF) is the primary Windows-native graphics format. It comes in two flavors: the older 
EMF and a newer EMF+. Igor “dual EMF” by default. A dual EMF contains both a plain EMF and an EMF+; 
applications that don’t support EMF+ will use the plain EMF component. EMF+ is needed if transparency (colors 
with an alpha channel) is used. You can export using the older EMF format if the destination program does not 
work well with EMF+ - see Graphics Technology on page III-506 for details.
Export Format
Export Method
Notes
EMF (Enhanced 
Metafile)
Clipboard, file
Windows-specific vector format.
BMP (Bitmap)
Clipboard, file
Windows-specific bitmap format.
Does not use compression.
Igor PDF
Clipboard, file
Platform-independent and high quality.
Igor PDF with CMYK color does not support transparency.
EPS 
(Encapsulated 
Postscript)
File only
Platform-independent except for the screen preview.
Supports high resolution.
EPS does not support transparency.
Useful only when exporting to PostScript-savvy program (e.g., Adobe 
Illustrator, Tex).
PNG (Portable 
Network 
Graphics)
Clipboard, file
Platform-independent bitmap format.
Uses lossless compression. Supports high resolution.
JPEG
Clipboard, file
Platform-independent bitmap format.
Uses lossy compression. Supports high resolution.
PNG is a better choice for scientific graphics.
TIFF
Clipboard, file
Platform-independent bitmap format.
Supports high resolution but not compression.
SVG
Clipboard, file
Platform-independent vector graphics format. A good choice if the 
destination program supports SVG. As of this writing, few 
Windows programs support SVG.
