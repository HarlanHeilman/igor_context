# Symbols with EPS and Igor PDF

Chapter III-16 — Text Encodings
III-493
If you don't care about compatibility with Igor6 or EPS export, you don't need to use Symbol font. You can 
instead write:
TextBox/C/N=text0/F=0/A=MC "\\Z18A\\B"
On Macintosh, you might still want to specify Symbol font because it provides almost all of the Symbol 
characters and you may prefer its style compared to other fonts.
Zapf Dingbat Font
Igor deals with Zapf Dingbats font in the same way. Zapf Dingbats was widely available on Macintosh in 
previous millennium.
Symbol Tips
On Windows, because Igor now uses Unicode, Symbol font does not appear to be useful. Consequently, 
Igor substitutes another font when Symbol is encountered.
To insert frequently-used symbol characters, such as Greek characters and math symbols, choose 
EditCharacters.
In the Add Annotation dialog and in the Axis Label tab of the Modify Axis dialog, you can click Special and 
choose a character from the Character submenu.
Symbol Font Characters
The “Text Encoding.ihf” help file includes a list of Symbol font characters. To display it, execute:
DisplayHelpTopic "Symbol Font Characters"
You can copy the characters as Unicode from that section of the help file and paste them into another 
window.
Symbols with EPS and Igor PDF
Both EPS and PDF include Symbol font as one of their standard supported fonts. When inserting a character 
from the above list, you can either specify Symbol font or you can use a Unicode font that supports those 
characters.
In the case of Symbol font, Igor translates the Unicode code point to the corresponding Symbol single byte 
code (unless you have specified that even standard fonts be embedded) and such characters in the resulting 
file will be editable in a program such as Adobe Illustrator. The alternative is to specify a font such as Lucida 
Sans Unicode in which case the characters are embedded using an outline font and will not be editable.
Be sure to specify either Symbol or a font that will be embedded because it is likely that the current default 
font is one of the EPS or PDF standard supported fonts. These are not Unicode and the result will not be 
what you expect.

Chapter III-16 — Text Encodings
III-494
