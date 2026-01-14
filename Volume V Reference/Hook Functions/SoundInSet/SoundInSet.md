# SoundInSet

SoundInRecord
V-887
Print SortList("b;c;A;a;", ";", 4+32)
// prints "A;b;c;"
Print SortList("b;c;a;A;", ";", 4+32)
// prints "a;b;c;"
// Numeric sorts
Print SortList("9,93,91,33,15,3",",",2)
// prints "3,9,15,33,91,93,"
Print SortList("9,93,91,33,15,3",",",3)
// prints "93,91,33,15,9,3,"
See Also
Sort, StringFromList, WaveList, RemoveEnding
See Setting Bit Parameters on page IV-12 for details about bit settings.
SoundInRecord 
SoundInRecord [/BITS=bits /Z] wave
The SoundInRecord operation records audio input at the sample rate obtained from the wave’s X scaling 
and for the number of points determined by the length of the wave. The recording is done synchronously.
The number type of the wave must be a type supported by the sound input hardware as reported by the 
SoundInStatus operation. Use SoundInStatus with the format keyword to check if a particular format is 
supported.
On Windows 8-bit or 16-bit integer are typically supported. On Macintosh, 16-bit integer or 32-bit floating 
point (the Mac OS native type for sound) are typically supported.
To record in stereo, provide a 2 column wave. (The software is designed to handle any number of channels 
but has not been tested on more than 2.)
Flags
Details
SoundInRecord requires a computer with sound inputs. Several sample experiments using sound input can 
be found in your Igor Pro Folder in the Examples folder.
See Also
SoundInSet, SoundInStartChart, SoundInStatus
SoundInSet 
SoundInSet [/Z][gain=g, agc=a]
The SoundInSet operation is used to setup the input device for recording.
Parameters
SoundInSet can accept multiple keyword =value parameters on one line.
/BITS=bits
Controls the number of bits used for each recorded sound sample.
Use /BITS=24 with a 32-bit integer wave for 24-bit sound data capable of representing 
values from -8,388,608 to +8,388,607.
If you omit /BITS or use /BITS=0, SoundInRecord uses the wave's data type and size 
to determine how many bits are recorded for each sound sample.
The /BITS flag was added in Igor Pro 9.00.
/Z
Errors are not fatal. V_flag is set to zero if no error, else nonzero if error.
agc=a
Turns automatic gain control mode on (a=1) or off (a=0). Will generate an error if device does 
not support setting agc. Use SoundInStatus to check or use /Z flag to make errors nonfatal.
Windows: This is not supported and V_SoundInAGC from the SoundInStatus command 
always returns -1.
gain=g
Sets input gain, 0 is lowest gain and 1 is highest. Will generate an error if device does not 
support setting gain. Use SoundInStatus to check or use /Z flag to make errors nonfatal.
