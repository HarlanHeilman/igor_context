# GrepList

GrepList
V-333
// Format matching text wave row to the history area
Grep/E=("Red")/DCOL={"prefix text --- ", 0, " --- suffix text"} textWave
// Printed output:
prefix text --- BlueRedGreen --- suffix text
prefix text --- RedWhiteBlue --- suffix text
prefix text --- BlueRedGreen256 --- suffix text
prefix text --- RedWhiteBlue256 --- suffix text
prefix text --- Red --- suffix text
prefix text --- RedWhiteGreen --- suffix text
prefix text --- BlueBlackRed --- suffix text
// Re-copy rows of textWave that contain "Red" (case sensitive)
// to the Clipboard as carriage-return separated lines.
Grep/E="Red" textWave as "Clipboard"
// Create a 2-column text wave whose column 1 (the second column)
// contains the matching text from the Clipboard
Make/O/N=(0,2)/T outputTextWave
// Grep with /A to preserve 2 columns of outputTextWave
Grep/A/E="Red"/GCOL=1/DCOL={1} "Clipboard" as outputTextWave
Edit outputTextWave
// Examples with two-dimensional source text waves
Make/O/T/N=(10, 3) sourceTW= StringFromList(p+10*q,list)
Edit sourceTW
// Copy rows of textWave that contain "Red" in column 2 to outputTextWave.
Make/O/N=0/T outputTextWave
Grep/E="Red"/GCOL=2 sourceTW as outputTextWave
Edit outputTextWave
// Format matching text wave columns to the history area.
// Match lines that contain "Red" in any column of sourceTW:
Grep/E=("Red")/GCOL=-1/DCOL={0,", ",1,", ",2} sourceTW
// Printed output:
YellowHot, BlueRedGreen256, Magenta
BlueHot, RedWhiteBlue256, Yellow
BlueRedGreen, PlanetEarth256, Copper
RedWhiteBlue, Terrain256, Gold
Terrain, Rainbow16, RedWhiteGreen
Grays256, Red, BlueBlackRed
References
The regular expression syntax supported by Grep, GrepString, and GrepList is based on the PCRE — Perl-
Compatible Regular Expression Library by Philip Hazel, University of Cambridge, Cambridge, England. The 
PCRE library is a set of functions that implement regular expression pattern matching using the same 
syntax and semantics as Perl 5.
Visit <http://pcre.org/> for more information about the PCRE library.
A good book on regular expressions is: Friedl, Jeffrey E. F., Mastering Regular Expressions, 2nd ed., 492 pp., 
O’Reilly Media, 2002.
A helpful web site is: http://www.regular-expressions.info
See Also
Regular Expressions on page IV-176 and Symbolic Paths on page II-22.
Demo, CopyFile, PutScrapText, LoadWave operations. The GrepString, GrepList, StringMatch, and 
CmpStr functions.
GrepList 
GrepList(listStr, regExprStr [,reverse [, listSepStr]])
The GrepList function returns each list item in listStr that matches the regular expression regExprStr.
ListStr should contain items separated by listSepStr which typically is ";".
regExprStr is a regular expression such as is used by the UNIX grep(1) command. It is much more powerful 
than the wildcard syntax used for ListMatch. See Regular Expressions on page IV-176 for regExprStr details.
