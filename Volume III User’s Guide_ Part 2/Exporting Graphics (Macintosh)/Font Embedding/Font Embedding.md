# Font Embedding

Chapter III-5 — Exporting Graphics (Macintosh)
III-99
Exporting a Section of a Layout
To export a section of a page layout, use the marquee tool to identify the section and then choose 
EditExport Graphics or FileSave Graphics.
If you don’t use the marquee and the Crop to Page Contents checkbox is checked, Igor exports the area of 
the layout that is in use plus a small margin. If it is unchecked, Igor exports the entire page.
Exporting Colors
The PDF, EPS and TIFF graphics formats normally use the RGB scheme to specify color. Some publications 
require the use of CMYK instead of RGB, although the best results are obtained if the publisher does the 
RGB to CMYK conversion using the actual characteristics of the output device. For those publications that 
insist on CMYK, you can use the SavePICT /C=2 flag
Font Embedding
This section is largely obsolete. It applies only to EPS files and PDF files generated for CMYK colors. Even then 
you need this information only in unusual circumstances.
You can embed TrueType fonts in EPS files and in PDF files. This means you can print EPS or PDF files on 
systems lacking the equivalent PostScript fonts. This also helps for publications that require embedded fonts.
Font embedding is done automatically for the Quartz PDF format and you do not need to bother with this 
section unless you are using EPS or Igor PDF formats.
Font embedding is always on and the only option is to not embed standard fonts. For most purposes, 
embedding only non-standard fonts is the best choice.
Igor embeds TrueType fonts as synthetic PostScript Type 3 fonts derived from the TrueType font outlines. 
Only the actual characters used are included in the fonts.
Not all fonts and font styles on your system can be embedded. Some fonts may not allow embedding and 
others may not be TrueType or may give errors. Be sure to test your EPS files on a local printer or by import-
ing into Adobe Illustrator before sending them to your publisher. You can test your PDF files with Adobe 
Reader. You can also use the “TrueType Outlines.pxp” example experiment to validate fonts for embed-
ding. Choose FilesExample ExperimentsFeature Demos 2TrueType Outlines.
For EPS, Igor determines if a font is non-standard by attempting to look up the font name in a table 
described in PostScript Font Names (OS X) on page III-100 after doing any font substitution using that 
table. In addition, if a nonplain font style name is the same as the plain font name, then embedding is done. 
This means that standard PostScript fonts that do not come in italic versions (such as Symbol), will be 
embedded for the italic case but not for the plain case.
For PDF, non-standard fonts are those other than the basic fonts guaranteed by the PDF specification to be built-
in to any PDF reader. Those fonts are Helvetica and Times in plain, bold, italic and bold-italic forms as well as 
Symbol and Zapf Dingbats only in plain style. If embedding is not used or if a font can not be embedded, fonts 
other than those just listed will be rendered as Helvetica and will not give the desired results.
