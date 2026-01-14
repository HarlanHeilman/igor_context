# SoundSaveWave

SoundSaveWave
V-892
Examples
// Display an Open File dialog and load the chosen file. 
// Use file's name for wave, overwrite any pre-existing wave, print information to history
SoundLoadWave/O myDestWave
// SoundLoadWave stores following in S_Info and prints it to the history area
FILE:<file name>;FORMAT:MPEG Layer 3;CHANNELS:2;BITS:0;SAMPLES:524416;RATE:44100;
// Rename the wave to a cleaned up version of the file name
Rename myDestWave, $CleanupName(S_fileName,1)
See Also
SoundSaveWave, PlaySound
SoundSaveWave
SoundSaveWave [flags] typeStr, waveName [ , fileNameStr ]
The SoundSaveWave operation saves the named wave on disk as an Audio Interchange File Format (AIFF-
C) or Microsoft WAVE sound file. AIFF-C is primarily used on Macintosh.
Parameters
typeStr must be either "AIFC" or "WAVE".
fileNameStr contains the name of the file in which the named wave is saved. If you omit fileNameStr , 
SoundSaveWave uses the wave name with the appropriate extension.
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If 
SoundSaveWave can not determine the location of the file from fileNameStr and pathName, it displays a 
dialog allowing you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
The sound file is always an uncompressed AIFF-C or WAVE file, with as many channels as the wave 
contains columns.
The sound file format is determined by the wave's data type, typeStr, and the /BITS flag. Signed 8-, 16- and 
24-bit integers are supported as are 32-bit and 64-bit floating point. When writing floating point waves, the 
wave data should be scaled to +/- 1.0 as full scale.
/BITS=bits
Controls the number of bits used for each sound sample written to the file.
Use /BITS=24 with a 32-bit integer wave to save 24-bit sound data capable of 
representing values from -8,388,608 to +8,388,607.
If you omit /BITS or use /BITS=0, SoundSaveWave uses the wave's data type and size 
to determine how many bits are written for each sound sample.
The /BITS flag was added in Igor Pro 9.00.
/I
Presents a Save File dialog in which you can specify the file to be saved.
/O
Overwrites the file if it already exists.
If you omit /O and the file exists, SoundSaveWave displays a Save File dialog.
/P=pathName
Specifies the folder to store the file in. pathName is the name of an Igor symbolic path, 
created via NewPath. It is not a file system path like "hd:Folder1:" or 
"C:\\Folder1\". See Symbolic Paths on page II-22 for details.
/Q
Suppresses the normal messages in the history area of the command window. At 
present nothing is written to the history even if /Q is omitted.
