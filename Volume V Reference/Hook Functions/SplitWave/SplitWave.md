# SplitWave

SplitWave
V-901
 2005
Print S_value
 Mon, May 2, 2005
// Get the part of str that matches regExprStr
SplitString/E=",.*," "stuff in front,second value,stuff at end"
Print S_value
 ,second value,
See Also
Regular Expressions on page IV-176 and Subpatterns on page IV-186.
sscanf, Grep, strsearch, str2num, RemoveEnding, TrimString
SplitWave
SplitWave [flags] srcWave
The SplitWave operation creates new waves containing subsets of the data in srcWave which must be 2D or 
greater.
The newly generated waves have lower dimensionality than srcWave. The operation is ideal for splitting 2D 
waves into constituent columns, 3D waves into their layers, etc.
Added in Igor Pro 7.00.
Flags
/DDF=destDataFolder
Specifies the data folder where the generated waves are created. If the data folder 
does not exist the operation creates it. If the /DDF flag is not used, output goes 
into the current data folder.
/FREE
Generates free output waves. The /OREF flag must also be used when the /FREE 
flag is used. When you use this flag there is no need to use either /N or /NAME.
/N=baseName
Provides the base name for all output waves. The waves will be named 
sequentially, i.e., baseName0, baseName1...
/NAME=strList
strList is a semicolon-separated list of wave names to be used as the names of the 
output waves.
If strList contains fewer names than the number needed, the operation terminates 
and returns an error.
If the output data folder is the data folder containing srcWave then strList must not 
contain the name of srcWave.
Only simple names, not full paths, are allowed in strList.
/NOTE
Copies the wave note, if any, from srcWave to the output waves. The /NOTE flag 
was added in Igor Pro 8.00.
/O
Permits overwriting of existing destination waves. Overwriting srcWave is not 
permitted.
/OREF=waveRefWave
waveRefWave is a wave reference wave. SplitWave stores a wave reference for 
each of the output waves in waveRefWave.
If the specified waveRefWave already exists it is overwritten and its size is changed 
as appropriate. If it does not already exist, it is created by the operation.
/SDIM=n
Specifies the dimensionality of the output waves. By default this is 1 less than the 
dimensionality of srcWave. The minimum value is n=1 which results in 1D output 
waves.
/Z[=z]
/Z or /Z=1 prevents procedure execution from aborting if there is an error. Use /Z 
if you want to handle this case in your procedures rather than having execution 
abort.
/Z=0: Same as no /Z at all. This is the default.
/Z=1: Same as /Z alone.
