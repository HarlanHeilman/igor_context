# GetEnvironmentVariable

GetDimLabel
V-298
If axisNameStr is "", the font style of the default font for the graph is returned.
If named axis exists, the default font style for the named axis in the graph is returned.
If named axis does not exist, NaN is returned.
The function result is a bitwise value with each bit identifying one aspect of the font style as follows:
See Setting Bit Parameters on page IV-12 for details about bit settings.
See Also
The GetDefaultFont, GetDefaultFontSize, FontSizeHeight, and FontSizeStringWidth functions.
GetDimLabel 
GetDimLabel(waveName, dimNumber, dimIndex)
The GetDimLabel function returns a string containing the label for the given dimension or dimension 
element.
Use dimNumber=0 for rows, 1 for columns, 2 for layers and 3 for chunks.
If dimIndex is -1, it returns the label for the entire dimension. If dimIndex is  0, it returns the dimension label 
for that element of the dimension.
See Also
SetDimLabel, FindDimLabel, CopyDimLabels
Dimension Labels on page II-93 for further usage details and examples.
GetEnvironmentVariable
GetEnvironmentVariable(varName)
The GetEnvironmentVariable function returns a string containing the current value of the specified 
environment variable for the currently running Igor process. If the variable does not exist, an empty string 
("") is returned.
The GetEnvironmentVariable function was added in Igor Pro 7.00.
Parameters
Details
The environment of Igor's process is composed of a set of key=value pairs that are known as environment 
variables.
Any child process created by calling ExecuteScriptText inherits the environment variables of Igor's process.
On Windows, environment variable names are case-insensitive. On other platforms, they are case-sensitive.
GetEnvironmentVariable returns an empty string if varName does not exist or if it does exist but its value is 
empty. If you need to know whether or not the environment variable itself actually exists, you can use the 
following function:
Function EnvironmentVariableExists(varName)
String varName
String varList = GetEnvironmentVariable("=")
Bit 0:
Bold
Bit 1:
Italic
Bit 2:
Underline
Bit 4:
Strikethrough
varName
The name of an environment variable which may or may not exist. It must not be an 
empty string and may not contain an equals sign (=).
As a special case, if a single equals sign ("=") is passed for varName, a carriage return 
(\r) separated list of all current key=value environment variable pairs is returned.
