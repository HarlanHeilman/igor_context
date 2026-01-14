# PostScript Font Names

Chapter III-6 — Exporting Graphics (Windows)
III-106
addition, if a nonplain font style name is the same as the plain font name, then embedding is done. This 
means that standard PostScript fonts that do not come in italic versions (such as Symbol), will be embedded 
for the italic case but not for the plain case.
For PDF, non-standard fonts are those other than the basic fonts guaranteed by the PDF specification to be built-
in to any PDF reader. Those fonts are Helvetica and TImes in plain, bold, italic, and bold-italic styles as well as 
plain versions of Symbol and Zapf Dingbats. If embedding is not used or if a font can not be embedded, fonts 
other than those just listed will be rendered as Helvetica and will not give the desired results.
PostScript Font Names
When generating PostScript, Igor needs to generate proper PostScript font names. This presents problems 
under Windows. Igor also needs to be able to substitute PostScript fonts for non-PostScript fonts. Here is a 
list of font names that are translated into the standards:
TrueType Name
PostScript Name
Arial
Helvetica
Arial Narrow
Helvetica-Narrow
Book Antiqua
Palatino
Bookman Old Style
Bookman
Century Gothic
AvantGarde
Century Schoolbook
NewCenturySchlbk
Courier New
Courier
Monotype Corsiva
ZapfChancery
Monotype Sorts
ZapfDingbats
Symbol
Symbol
Times New Roman
Times
