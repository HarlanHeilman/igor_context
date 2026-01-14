# Platform-Independent Bitmap Formats

Chapter III-5 — Exporting Graphics (Macintosh)
III-97
can tell Igor to draw image pixels as individual rectangles using the ModifyImage interpolate keyword 
with a value of -1. You should do this only when necessary as the resulting PDF will be much larger.
Encapsulated PostScript (EPS) Format 
Encapsulated PostScript was a widely-used, platform-independent vector graphics format consisting of 
PostScript commands in plain text form. It usually gives the best quality, but it works only when printed to 
a PostScript printer or exported to a PostScript-savvy program such as Adobe Illustrator. You should use 
only PostScript fonts (e.g., Helvetica).
Encapsulated PostScript was a widely-used platform-independent vector graphics format consisting of 
PostScript commands in plain text form. EPS is largely obsolete but still in use. It usually gives good quality, 
but it works only when printed to a PostScript printer or exported to a PostScript-savvy program such as 
Adobe Illustrator. You should use only PostScript fonts such as Helvetica. EPS does not support transpar-
ency.
Prior to Igor Pro 7, Igor embedded a screen preview in EPS files. This is no longer done because the preview 
was not cross-platform and caused problems with many programs.
EPS files normally use the RGB encoding to represent color but you can also use CMYK. See Exporting 
Colors on page III-99 for details.
Igor Pro exports EPS files using PostScript language level 2. This allows much better fill patterns when 
printing and also allows Adobe Illustrator to properly import Igor’s fill patterns. For backwards compati-
bility with old printers, you can force Igor to use level 1 by specifying /PLL=1 with the SavePICT operation.
If the graph or page layout that you are exporting as EPS contains a non-EPS picture imported from another 
program, Igor exports the picture as an image incorporated in the output EPS file.
Igor can embed TrueType fonts as outlines. See Font Embedding on page III-99 and Symbols with EPS and 
Igor PDF on page III-493 for details.
SVG Format
SVG (Scalable Vector Graphics) is an XML-based platform-independent 2D vector and raster graphics format 
developed by the World Wide Web Consortium. It is often used for displaying graphics in web pages and is 
a good choice for other uses if the destination program supports it. However, as of this writing, few Macintosh 
programs support SVG. Safari supports it but you can not import an SVG file or paste an SVG graphic into 
Preview.
Platform-Independent Bitmap Formats
PNG (Portable Network Graphics) is a platform-independent bitmap format that uses lossless compression 
and supports high resolution. It is a superior alternative to JPEG or GIF. Although Igor can export and 
import PNG images via files and via the clipboard, some programs that allow you to insert PNG files do 
not allow you to paste PNG images from the clipboard.
JPEG is a lossy image format whose main virtue is that it is accepted by all web browsers. However all 
modern web browsers support PNG so there is little reason to use JPEG for scientific graphics. Although 
Igor can export and import JPEG via the clipboard, not all programs can paste JPEGs.
TIFF is an Adobe format often used for digital photographs. Igor’s implementation of TIFF export does not 
use compression. TIFF files normally use the RGB scheme to specify color but you can also use CMYK. See 
Exporting Colors on page III-99 for details. There is no particular reason to use TIFF over PNG unless you 
are exporting to a program that does not support PNG. Igor can export and import TIFF via files and via 
the clipboard and most graphics programs can import TIFF.
