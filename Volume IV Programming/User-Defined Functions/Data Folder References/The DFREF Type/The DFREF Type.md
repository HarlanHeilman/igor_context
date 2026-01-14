# The DFREF Type

Chapter IV-3 — User-Defined Functions
IV-80
The /SDFR Flag
You can also use the /SDFR (source data folder reference) flag in a WAVE, NVAR or SVAR statement. The 
utility of /SDFR is illustrated by this example which shows three different ways to reference multiple waves 
in the same data folder:
Function Test()
// Assume a data folder exists at root:Run1
// Use explicit paths
Wave wave0=root:Run1:wave0, wave1=root:Run1:wave1, wave2=root:Run1:wave2
// Use a data folder reference
DFREF dfr = root:Run1
Wave wave0=dfr:wave0, wave1=dfr:wave1, wave2=dfr:wave2
// Use the /SDFR flag
DFREF dfr = root:Run1
Wave/SDFR=dfr wave0, wave1, wave2
End
Igor Pro 8 and Igor Pro 9 handle invalid data folder references in /SDFR=dfr flags differently when /Z is 
included. Igor Pro 8 incorrectly flags an error on the /SDFR statement despite the /Z. Igor Pro 9 correctly 
suppresses the error on the /SDFR statement because of /Z.
If you use WAVE/Z, NVAR/Z, or SVAR/Z, this means you want to handle errors yourself so you should 
follow it with a WaveExists, NVAR_Exists, or SVAR_Exists test.
The DFREF Type
In functions, you can define data folder reference variables using the DFREF declaration:
DFREF localname [= <DataFolderRef or path>] [<more defs]
You can then use the data folder reference in those places where you can use a data folder path. For exam-
ple:
DFREF dfr = root:df1
Display dfr:wave1
// Equivalent to Display root:df1:wave1
The syntax is limited to a single name after the data folder reference, so this is not legal:
Display dfr:subfolder:wave1
// Illegal
You can use DFREF to define input parameters for user-defined functions. For example:
Function Test(df)
DFREF df
Display df:wave1
End
You can also use DFREF to define fields in structures. However, you can not directly use a DFREF structure 
field in those places where Igor is expecting a path and object name. So, instead of:
Display s.dfr:wave1
// Illegal
you would need to write:
DFREF dftmp = s.dfr
Display dftmp:wave1
// OK
You can use a DFREF structure field where just a path is expected. For example:
SetDataFolder s.dfr
// OK
