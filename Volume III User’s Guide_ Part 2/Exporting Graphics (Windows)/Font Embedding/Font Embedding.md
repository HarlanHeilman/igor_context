# Font Embedding

Chapter III-6 — Exporting Graphics (Windows)
III-105
When a page layout has an object selected or when the marquee is active, choosing EditCopy copies an 
Igor object in a format used internally by Igor along with an enhanced metafile and does not use the format 
from the Export Graphics dialog.
Although Igor can export a number of different formats, not all programs can recognize them on the clip-
board. You may need to export via a file.
Exporting Graphics Via a File
To export a graphic from the active window via a file, choose FileSave Graphics. This displays the Save 
Graphics File.
The controls in the Format area of the dialog change to reflect options appropriate to each export format.
When you click the Do It button, Igor writes a graphics file. You can then switch to another program and 
import the file.
If you select _Use Dialog_ from the Path pop-up menu, Igor presents a Save File dialog in which you can 
specify the name and location of the saved file.
Exporting a Section of a Layout
To export a section of a page layout, use the marquee tool to identify the section and then choose 
EditExport Graphics or FileSave Graphics.
If you don’t use the marquee and the Crop to Page Contents checkbox is checked, Igor exports the area of 
the layout that is in use plus a small margin. If it is unchecked, Igor exports the entire page.
Exporting Colors
The EPS and TIFF graphics formats normally use the RGB scheme to specify color. Some publications 
require the use of CMYK instead of RGB, although the best results are obtained if the publisher does the 
RGB to CMYK conversion using the actual characteristics of the output device. For those publications that 
insist on CMYK, you can use the SavePICT /C=2 flag.
Font Embedding
This section is largely obsolete. It applies only to EPS files and PDF files generated for CMYK colors. Even 
then you need this info only in unusual circumstances.
You can embed TrueType fonts in EPS files and in PDF Files. This means that you can print EPS or PDF files 
on systems lacking the equivalent PostScript fonts. This also helps with publications that require embedded 
fonts.
Font embedding is always on and the only option is to not embed standard fonts. For most purposes, 
embedding only non-standard fonts is the best choice.
Igor embeds TrueType fonts as synthetic PostScript Type 3 fonts derived from the TrueType font outlines. 
Only the actual characters used are included in the fonts.
Not all fonts and font styles on your system can be embedded. Some fonts may not allow embedding and 
others may not be TrueType or may give errors. Be sure to test your EPS files on a local printer or by import-
ing into Adobe Illustrator before sending them to your publisher. You can also use the “TrueType Out-
lines.pxp” example experiment to validate fonts for embedding. You will find this experiment file in your 
Igor Pro Folder in the “Examples:Testing:” folder.
For EPS, Igor determines if a font is non-standard by attempting to look up the font name in a table 
described in PostScript Font Names on page III-106 after doing any font substitution using that table. In
