# Procedure File Text Encodings

Chapter III-13 — Procedure Windows
III-409
That line contains a code marker comment.
The format of a code marker comment is:
// *** <code marker text> ***
The code marker text, which appears in the code marker popup menu, is everthing after "// *** " and 
before " ***".
The code marker comment must be flush left with no spaces, tabs, or any other text before "// *** ".
You can insert a code marker comment manually or by clicking the code markers popup menu and choos-
ing "Insert Code Marker Comment". You can not insert a code marker comment if the procedure window 
is write protected or is open for read only.
Aligning Comments
You can align comments introduced by "//" in a procedure window by selecting text and choosing 
EditAlign Comments. This aligns subsequent comments with the first comment in the selected text. This 
feature is available for procedure windows only, not for notebooks.
Aligning comments requires that the procedure window use the spaces mode of defining default tabs. To 
ensure this, when you choose EditAlign Comments, Igor adds a DefaultTab pragma to the procedure 
window if it is not already there. See The Default Tab Pragma For Procedure Files on page III-406 for 
details about this pragma. The DefaultTab pragma is ignored by versions of Igor prior to 9.00 so comments 
that you align using this technique will not appear aligned in earlier versions.
Aligning comments also requires that the procedure window use a monospace font. It is up to you to make 
sure that this is the case. The factory default fonts for procedure windows, Monaco on Macintosh and 
Lucida Console on Windows, are monospace fonts.
When you choose EditAlign Comments, Igor finds the first selected line containing a comment (intro-
duced by "//"). It then works on each subsequent selected line and attempts to align comments by inserting 
or removing tabs. During this process, Igor removes spaces that appear between the end of the line's active 
code and the comment.
Comments that are flush left are left unchanged as they typically appear above function definitions and are 
already positioned as desired.
By default, other pure comment lines (lines with nothing before the comment symbol except for spaces and 
tabs) are also left unchanged unless:
•
The section consists entirely of pure comment lines
•
You press the Option key (Macintosh) or Alt key (Windows) while choosing EditAlign Comments 
to override the default behavior
In some cases, exact alignment is not possible. For example, if the active code of the second selected line 
extends paste the comment in the first selected line, removing all tabs from the second selected line does 
not achieve alignment. In such cases, Igor does the best it can.
Procedure File Text Encodings
Igor uses UTF-8, a form of Unicode, internally. Prior to Igor7, Igor used non-Unicode text encodings such 
as MacRoman, Windows-1252 and Shift JIS.
All new procedure files should use UTF-8 text encoding. When you create a new procedure file using Win-
dowsNewProcedure, Igor automatically uses UTF-8.

Chapter III-13 — Procedure Windows
III-410
Igor must convert from the old text encodings to Unicode when opening old files. It is not always possible 
to get this conversion right. You may get incorrect characters or receive errors when opening files contain-
ing non-ASCII text.
For a discussion of these issues, see Text Encodings on page III-459 and Plain Text File Text Encodings on 
page III-466.
