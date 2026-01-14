# ModDate

mod
V-592
Specifying Loading Options for Each Matlab Matrix
The /Z flag instructs MLLoadWave to load each Matlab object (matrix, vector, variable, string) step by step. 
MLLoadWave presents a dialog for each Matlab object in the file. You can choose to load or skip the object. 
If you omit the /Z flag, MLLoadWave will load all objects in the file without presenting any dialogs.
Output Variables
MLLoadWave sets the following output variables:
Prior to MLLoadWave 5.50, the variables V_Flag1, V_Flag2, V_Flag3 and V_Flag4 were named V1_Flag, 
V2_Flag, V3_Flag and V4_Flag.
See Also
Symbolic Paths on page II-22
See Loading Matlab MAT Files on page II-163 for background information, including configuration 
instructions.
mod 
mod(num, div)
The mod function returns the remainder when num is divided by div.
The mod function may give unexpected results when num or div is fractional because most fractional 
numbers can not be precisely represented by a finite-precision floating point value.
See Also
trunc, gcd
ModDate 
ModDate(waveName)
The ModDate function returns the modification date/time of the wave.
Details
The returned value is a double precision Igor date/time value, which is the number of seconds from 
1/1/1904. It returns zero for waves created by versions of Igor prior to 1.2, for which no modification 
date/time is available.
See Also
WaveModCount, Secs2Date, Secs2Time
S_path
File system path to the folder containing the file.
This is a system file path (e.g., "hd:FolderA:FolderB:"), not an Igor symbolic path. The 
path uses Macintosh path syntax, even on Windows, and has a trailing colon.
S_fileName
Name of the loaded file.
V_flag
Number of waves created.
V_flag1
Number of Matlab data sets (2D, 3D, or 4D) loaded.
V_flag2
Number of waves created.
V_flag3
Number of numeric variables created.
V_flag4
Number of string variables created.
S_waveNames
Semicolon-separated list of the names of loaded waves.
