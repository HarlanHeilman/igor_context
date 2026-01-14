# Exporting Graphics Via the Clipboard

Chapter III-6 — Exporting Graphics (Windows)
III-104
Igor can embed TrueType fonts as outlines. See Font Embedding on page III-105 and Symbols with EPS and 
Igor PDF on page III-493 for details.
SVG Format
SVG (Scalable Vector Graphics) is an XML-based platform-independent 2D vector and raster graphics format 
developed by the World Wide Web Consortium. It is often used for displaying graphics in web pages and is 
a good choice for other uses if the destination program supports it. As of this writing, Microsoft Office sup-
ports SVG but few other Windows programs support it.
Platform-Independent Bitmap Formats
PNG (Portable Network Graphics) is a platform-independent bitmap format. It uses lossless compression 
and supports high resolution. It is a superior alternative to JPEG or GIF. Although Igor can export and 
import PNG images via files and via the clipboard, some programs that allow you to insert PNG files do 
not allow you to paste PNG images from the clipboard.
JPEG is a lossy format whose main virtue is that it is accepted by all web browsers. However, all modern 
web browsers support PNG so there is little reason to use JPEG for scientific graphics. Although Igor can 
export and import JPEG via the clipboard, most Windows programs can not paste JPEGs, but Microsoft 
Office can.
TIFF is an Adobe format often used for digital photographs. Igor’s implementation of TIFF export does not 
use compression. TIFF files normally use the RGB scheme to specify color but you can also use CMYK. See 
Exporting Colors on page III-105 for details. There is no particular reason to use TIFF over PNG unless you 
are exporting to a program that does not support PNG. Igor can export and import TIFF via files and via 
the clipboard and most graphics programs can import TIFF.
Choosing a Graphics Format
Because of the wide variety of types of graphics, destination programs, printer capabilities, operating 
system behaviors and user-priorities, it is not possible to give definitive guidance on choosing an export 
format. But here is an approach that will work in most situations.
PNG is the recommended choice for exporting image plots and Gizmo plots which are inherently bitmaps.
For vector graphics, if the destination program accepts PDF or SVG, then they are probably your best choice 
because of their high-quality vector graphics and platform-independence.
Encapsulated PostScript (EPS) is also a very high quality format which works well if the destination 
program supports it, but it does not support transparency.
If PDF, SVG and EPS are not appropriate, your next choice for vector graphics would be a high-resolution 
bitmap. The PNG format is preferred because it is platform-independent and supports lossless compres-
sion.
Exporting Graphics Via the Clipboard
To export a graphic from the active window via the clipboard, choose EditExport Graphics. This displays 
the Export Graphics dialog.
When you click the OK button, Igor copies the graphics for the active window to the clipboard. You can 
then switch to another program and do a paste.
When a graph, page layout, or Gizmo plot is active and in operate mode, choosing EditCopy copies to 
the clipboard whatever format was last used in the Export Graphics dialog. For a table, EditCopy copies 
the selected numbers to the clipboard and does not copy graphics.
