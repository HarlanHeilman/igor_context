# Fonts Used with Igor TeX

Chapter III-2 — Annotations
III-59
The example above shows white space after the opening and before the closing escape sequence. Such white 
space is optional.
You can use local string variables to construct the annotation text. For example:
static StrConstant kTeXOpen = "\\$WMTEX$"
static StrConstant kTeXClose = "\\$/WMTEX$"
static StrConstant kTeXFontSize = "\Z18"
Function TeXTest()
DoWindow/F TexTestGraph
if (V_Flag == 0)
Display /N=TexTestGraph /W=(35,45,339,154)
endif
String TeXFormula = "\frac{3x}{2}"
String annotationText = kTeXFontSize + kTeXOpen + TeXFormula + kTeXClose
TextBox/C/N=TeXTest/A=MC/F=0 annotationText
End
For more examples open the Igor TeX Demo experiment by choosing FileGraphing TechniquesIgor 
TeX Demo.
By default, formulas use an inline style. You can switch to a larger style that is commonly used for formulas 
on their own line by adding "\displaystyle" at the start of the TeX formula.
Igor Supports a Subset of TeX
Igor does not contain a full LaTeX interpreter. Rather it uses code patterned after Knuth's TeX.web with a 
subset that supports the most common math syntax that an Igor user is likely to use. Formulas are drawn 
directly using Igor's normal text and line drawing code — Igor does not first create a picture or .dvi file.
Igor's subset supports LaTeX's \frac but does not support standard TeX's \over and does not support 
macros. If you discover syntax that Igor does not support but really should, please let us know.
You can use \rm to force letters to be upright (rather than italic.) This is useful in chemical formulas such 
as ethanol: \rm CH_3CH_2OH
Fonts Used with Igor TeX
For purposes of determining what font is used, each component of a TeX formula is classified as one of 
these:
•
A Greek letter specified by a TeX code like \alpha, \beta, and \gamma
•
A math symbol specified by a TeX code like \neg, \prod, \sum, and \int
•
Other text (letters, numbers, function names, and anything else other than Greek letters and math 
symbols as defined above)
By default, Igor uses these fonts for components classified as Greek letters and math symbols:
All other text is rendered using the font in effect in the annotation before the TeX formula.
The default Greek and math symbol fonts were chosen based on appearance and support for special char-
acters such as square bracket extensions (used when building a tall square bracket).
You can override these defaults within a given annotation by storing a font name in text info variable 8 for 
Greek characters and text info variable 9 for math symbols. See Text Info Variables on page III-51. You can 
experiment with different fonts using the Igor TeX Demo experiment.
Macintosh
Hiragino Sans with backups Cambria Math and Symbol
Windows
Symbol with backup Cambria Math
