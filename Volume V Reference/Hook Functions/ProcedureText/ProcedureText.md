# ProcedureText

PrintTable
V-779
See Also
The PrintGraphs, PrintTable, PrintLayout and PrintNotebook operations.
PrintTable 
PrintTable [/P=(startPage,endPage) /S=selection] winName
The PrintTable operation prints the named table window.
Parameters
winName is the window name of the table to print.
Flags
See Also
Chapter II-12, Tables.
The PrintSettings, PrintGraphs, PrintLayout and PrintNotebook operations.
Proc 
Proc macroName([parameters]) [:macro type]
The Proc keyword introduces a macro that does not appear in any menu. Otherwise, it works the same as 
Macro. See Macro Syntax on page IV-118 for further information.
ProcedureText
ProcedureText(macroOrFunctionNameStr [, linesOfContext [, 
procedureWinTitleStr]])
The ProcedureText function returns a string containing the text of the named macro or function as it exists 
in some procedure file, optionally with additional lines that are before and after to provide context or to 
collect documenting comments.
Alternatively, all of the text in the specified procedure window can be returned.
Parameters
macroOrFunctionNameStr identifies the macro or function. It may be just the name of a global (nonstatic) 
procedure, or it may include a module name, such as "myModule#myFunction" to specify the static 
function myFunction in a procedure window that contains a #pragma ModuleName=myModule statement.
If macroOrFunctionNameStr is set to "", and procedureWinTitleStr specifies the title of a single procedure 
window, then all of the text in the procedure window is returned.
linesOfContext optionally specifies the number of lines around the function to include in the returned string. 
The default is 0 (no additional contextual lines of text are returned). This parameter is ignored if 
macroOrFunctionNameStr is "" and procedureWinTitleStr specifies the title of a single procedure window.
Setting linesOfContext to a positive number returns that many lines before the procedure and after the 
procedure. Blank lines are not omitted.
Setting linesOfContext to -1 returns lines before the procedure that are not part of the preceding macro or 
function. Usually these lines are comment lines describing the named procedure. Blank lines are omitted.
Setting linesOfContext to -n, where n>1, returns at most n lines before the procedure that are not part of the 
preceding macro or function. Blank lines are not omitted in this case. n can be -inf, which acts the same as 
-1 but includes blank lines.
The optional procedureWinTitleStr can be the title of a procedure window (such as "Procedure" or "File Name 
Utilities.ipf"). The text of the named macro or function in the specified procedure window is returned.
/P=(startPage,endPage)
Specifies a page range to print. 1 is the first page.
If /P is omitted all pages are printed unless /S is used.
/S=selection
Controls what is printed.
selection=0:
Print entire table (default).
selection=1:
Print selection only.
