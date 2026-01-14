# JCAMPLoadWave

JCAMPLoadWave
V-464
JCAMPLoadWave
JCAMPLoadWave [flags] [fileNameStr]
The JCAMPLoadWave operation loads data from the named JCAMP-DX file into waves.
Parameters
If fileNameStr is omitted or is "", or if the /I flag is used, JCAMPLoadWave presents an Open File dialog from 
which you can choose the file to load.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
The /N flag instructs Igor to automatically name new waves "wave", or baseName if /N=baseName is used, 
plus a number. The number starts from zero and increments by one for each wave loaded from the file. If 
the resulting name conflicts with an existing wave, the existing wave is overwritten.
The /A flag is like /N except that Igor skips names already in use.
Output Variables
JCAMPLoadWave sets the following output variables:
/A
Automatically assigns arbitrary wave names using "wave" as the base name. Skips 
names already in use.
/A=baseName
Same as /A but it automatically assigns wave names of the form baseName0, 
baseName1.
/D
Creates double-precision waves. If omitted, JCAMPLoadWave creates single-
precision waves.
/H
Reads header information from JCAMP file. If you include /W, this information is 
stored in the wave note. If you include /V, it is stored in header variables.
/I
Forces JCAMPLoadWave to display an Open File dialog even if the file is fully 
specified via /P and fileNameStr.
/N
Same as /A except that, instead of choosing names that are not in use, it overwrites 
existing waves.
/N=baseName
Same as /N except that it automatically assigns wave names of the form baseName0, 
baseName1.
/O
Overwrite existing waves in case of a name conflict.
/P=pathName
Specifies the folder to look in for fileNameStr. pathName is the name of an existing 
symbolic path.
/Q
Suppresses the normal messages in the history area.
/R
Reads data from file and creates Igor waves.
/V
Set variables from header information if /H is also present
/W
Stores header information in the wave note if /R and /H are also present.
V_flag
Number of waves loaded or -1 if an error occurs during the file load.
S_fileName
Name of the file being loaded.
S_path
File system path to the folder containing the file.
S_waveNames
Semicolon-separated list of the names of loaded waves.
