# FontSizeHeight

FontSizeHeight
V-257
endif
End
See Also
The FontSizeStringWidth, FontSizeHeight, and WinType functions, and the Execute, SetDrawEnv, and 
Notebook Operations.
FontSizeHeight 
FontSizeHeight(fontNameStr, fontSize, fontstyle [,appearanceStr])
The FontSizeHeight function returns the line height in pixels of any string when rendered with the named 
font and the given font style and size.
Parameters
fontNameStr is the name of the font, such as "Helvetica".
fontSize is the size (height) of the font in pixels.
fontStyle is text style (bold, italic, etc.). Use 0 for plain text.
Details
The returned height is the sum of the font’s ascent and descent heights. Variations in fontStyle and typeface 
design cause the actual font height to be different than fontSize would indicate. (Typically a font “height” 
refers to only the ascent height, so the total height will be slightly larger to accommodate letters that 
descend below the baseline, such as g, p, q, and y).
FontSize is in pixels. To obtain the height of a font specified in points, use the ScreenResolution function 
and the conversion factor of 72 points per inch (see Examples).
If the named font is not installed, FontSizeHeight returns NaN.
FontSizeHeight understands “default” to mean the current experiment’s default font.
fontStyle is a binary coded integer with each bit controlling one aspect of the text style as follows:
To set bit 0 and bit 2 (bold, underline), use 20+22 = 1+4 = 5 for fontStyle. See Setting Bit Parameters on page 
IV-12 for details about bit settings.
The optional appearanceStr parameter has no effect on Windows.
On Macintosh, the appearanceStr parameter is used for determining the height of a string drawn by a control. 
Set appearanceStr to "native" if you are measuring the height of a string drawn by a "native GUI" control or 
to "os9" if not.
Set appearanceStr to "default" to use the appearance set by the user in the Miscellaneous Settings dialog. "os9" 
is the default value.
Usually you will want to set appearanceStr to the S_Value output of DefaultGUIControls/W=winName 
when determining the height of a string drawn by a control. 
Examples
Variable pixels= 12 * ScreenResolution/72
// convert 12 points to pixels
Variable pixelHeight= FontSizeHeight("Helvetica",pixels,0)
Print "Height in points= ", pixelHeight * 72/ScreenResolution
Function FontIsInstalled(fontName)
String fontName
if( numtype(FontSizeHeight(fontName,10,0)) == 2 )
return 0
// NaN returned, font not installed
else
return 1
endif
End
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
