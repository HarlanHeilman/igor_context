# MeasureStyledText

MeasureStyledText
V-587
The X scaling of the wave is used only to locate the points nearest to x=x1 and x=x1. To use point indexing, 
replace x1 with "pnt2x(waveName,pointNumber1 )", and a similar expression for x2.
If the points nearest to x1 or x2 are outside the point range of 0 to numpnts(waveName )-1, median limits 
them to the nearest of point 0 or point numpnts(waveName)-1.
If the wave contains NaNs they are skipped.
The function returns NaN if the input wave has zero non-NaN points.
See Also
mean, Variance, StatsMedian, StatsQuantiles, WaveStats
MeasureStyledText
MeasureStyledText [/W=winName /A=axisName /B=baselineMode /F=fontName 
/SIZE=fontSize /STYL=fontStyle] [styledTextStr]
The MeasureStyledText operation takes as input a string optionally containing style codes such as are used 
in graph annotations and the DrawText operation. It sets various variables with information about the 
dimensions of the string.
In Igor Pro 9.00, the styledTextStr parameter was made optional, the /B flag was added, and several output 
variables (all but V_width and V_height) were added.
Flags
Parameters
styledTextStr is the styled text to be measured.
In Igor Pro 9.00 and later, styledTextStr is an optional parameter. Previously it was required.
If you include styledTextStr, the default font and styled text output variables are set.
If you omit styledTextStr, only the default font output variables are set.
/W=winName
Takes default text information from the window winName.
If you omit /W, MeasureStyledText works on the top graph window.
/A=axisName
Takes default text information from the axis named axisName in the top graph or 
in the window specified by /W.
/B=baseLineMode
Selects which baseline offset is returned in V_baseline if the text contains multiple 
lines (separated by carriage returns).
If you omit /B or specify /B=0, V_baseline is set to the offset to the last line of the 
text.
If you specify /B=1, V_baseline is set to the offset to the first line of the text.
The /B flag was added in Igor Pro 9.00.
/F=fontNameStr
The name of the default font.
In Igor Pro 9.00 and later, /F="default" and /F="" are the same as omitting /F in 
which case the default font is defined by /W, /A, or by the overall default font 
specified by the DefaultFont operation.
/SIZE=size
Sets default font size.
/STYL=fontStyle
Sets default font style:
/STYLE=0 specifies plain text.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough

MeasureStyledText
V-588
See Default Font Output Variables and Styled Text Output Variables below.
styledTextStr can contain escape codes to set the font, size, style, color and other properties. See Annotation 
Escape Codes on page III-53 for details. The text may contain multiple lines separated with carriage returns 
("\r").
Details
In the absence of formatting codes within the text that set the font, font size and font style, some mechanism 
must be provided that sets them.
The /W flag tells MeasureStyledText to get the default font name and font size from the specified window. 
If /W is omitted, defaults come from the top graph window.
The /A flag specifies that the default font name and font size come from the specified axis in the graph 
window specified by /W or in the top graph if /W is omitted.
The /F, /SIZE and /STYL flags set defaults that override any defaults from a window or axis. If you don't 
use any flags, the defaults are Igor's overall defaults.
If you omit all flags, the font specified by the DefaultFont operation is used, the default font size is 12 
points, and the style is plain.
Default Font Output Variables
In the descriptions of these variables, "default font" refers to the font, size, and style defined by /W, /A, 
/SIZE, and /STYLE, and not any escape codes in styledTextStr.
MeasureStyledText returns information about the default font via the following output variables:
Styled Text Output Variables
The MeasureStyledText operation returns information in the following variables:
MeasureStyledText Diagrams
These diagrams illustrate the meanings of the various output variables:
S_font
The name of the default font (before escape codes in styledTextStr take effect). 
If a substitute font would be used, the name of the substitute font is returned.
V_ascent
Height above the baseline of the default font. This will include some blank 
space above even the tallest characters.
V_descent
Height below the baseline of the default font.
V_fontSize
The default font size in points.
V_fontStyle
The default font style.
V_subscriptExtraHeight
Extra height needed to accomodate any subscript when using the default 
font.
V_superscriptExtraHeight
Extra height needed to accomodate any superscript when using the default 
font.
V_width
The width in points of the text.
V_height
The height in points of the text.
V_baseline
The offset to the baseline of the styled text in points, as measured from the bottom of 
the text.
If you omit /B or specify /B=0, this is is the offset to the last line's baseline.
If you specify /B=1, this is is the offset to the first line's baseline.
Higgs Boson }
V_baseline
{
V_ascent
{
V_descent
V_width
V_height
