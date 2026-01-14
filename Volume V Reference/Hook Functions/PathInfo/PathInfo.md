# PathInfo

PathInfo
V-737
Parameters
cmdTemplate is the template that describes the syntax for your operation. See the Igor XOP Toolkit Reference 
Manual for details.
Details
ParseOperationTemplate parses your command template, generating structures that embody the syntax of 
your operation. It then uses these structures to generate code that can serve as a starting point for 
implementing your operation. The starter code is stored in the clipboard.
For most uses, the recommended flags are:
/T/S=1/C=2
// For non-threadsafe operations
/T/S=1/C=2/TS
// For threadsafe operations
ParseOperationTemplate sets the following output variable, but only when called from a function or macro:
If V_flag is nonzero, this indicates that your cmdTemplate syntax is incorrect. See the Igor XOP Toolkit 
Reference Manual for details.
Examples
Function Test()
String cmdTemplate
cmdTemplate = "MyTest"
cmdTemplate += " /A={number:aNum1,string:aStrH}"
cmdTemplate += " /B=wave:bWaveH"
cmdTemplate += " key1={name:k1N1[,wave:k1WaveH,name:k1N2,string[2]:k1StrHArray]}"
// If your XOP is C instead of C++, use /C=2 instead of /C=6
TestOperationParser/T/S=1/C=6 cmdTemplate
Print V_flag, S_value
End
See Also
Igor Extensions on page III-511.
PathInfo 
PathInfo [/S /SHOW ] pathName
The PathInfo operation stores information about the named symbolic path in the following variables:
/S=s
/T
Stores a comment listing your command template in the clipboard.
/TS
Identifies a ThreadSafe operation by adding an extra field to the runtime parameter structure. 
This is only of use to WaveMetrics programmers.
V_flag
0:
cmdTemplate was successfully parsed.
-1:
cmdTemplate was not successfully parsed.
V_flag:
0 if the symbolic path does not exist, 1 if it does exist.
S_path:
The full path (e.g., "hd:This:That:").
Stores a definition of your runtime parameter structure in the clipboard if s is nonzero.
We recommend that you use /S=1 and provide unique mnemonic parameter names in your 
template. ParseOperationTemplate then uses your parameter names as structure field 
names.
If you use /S=2, ParseOperationTemplate creates unique field names by concatenating flag 
or keyword text and your mnemonic names. This is left over from the early days of 
Operation Handler and is not recommended.
s=0:
Do not generate the runtime parameter structure
s=1:
Use your mnemonic names - recommended
s=2:
Automatically generate mnemonic names - not recommended
