# Function Errors

Chapter IV-3 — User-Defined Functions
IV-110
Predefined Global Symbols
These global symbols are predefined if appropriate and available in all procedure windows:
Conditional Compilation Examples
#define MYSYMBOL
#ifdef MYSYMBOL
Function foo()
Print "This is foo when MYSYMBOL is defined"
End
#else
Function foo()
Print "This is foo when MYSYMBOL is NOT defined"
End
#endif
// MYSYMBOL
// This works in Igor Pro 6.10 or later
#if IgorVersion() >= 7.00
<code for Igor7 or later>
#else
<code for Igor6 or before>
#endif
// This works in Igor Pro 6.20 or later
#if defined(MACINTOSH)
<conditionally compiled code here>
#endif
Function Errors
During function compilation, Igor checks and reports syntactic errors and errors in parameter declarations. 
The normal course of action is to edit the offending function and try to compile again.
Runtime errors in functions are not reported on the spot. Instead, Igor saves information about the error 
and function execution continues. Igor presents an error dialog only after the last function ceases execution 
and Igor returns to the idle state. If multiple runtime errors occur, only the first is reported.
When a runtime error occurs, after function execution ends, Igor presents an error dialog:
Symbol
Automatically Predefined If
MACINTOSH
The Igor application is a Macintosh application.
WINDOWS
The Igor application is a Windows application.
IGOR64
The Igor application is a 64-bit application.
