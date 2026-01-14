# SoundInStatus

SoundInStartChart
V-888
Flags
Details
SoundInSet requires a computer with sound inputs. Several sample experiments using sound inputs are in 
your Igor Pro Folder in the Examples folder.
See Also
The SoundInRecord, SoundInStartChart, and SoundInStatus operations.
SoundInStartChart 
SoundInStartChart [/Z] buffersize , destFIFOname
The SoundInStartChart operation starts audio data acquisition into the given FIFO.
Parameters
buffersize is the number of bytes to allocate for the interrupt time buffer which then feeds into the given Igor 
named FIFO destFIFOname. The FIFO must be set up with the correct number of channels and number type 
- use SoundInStatus to find legal values. The sample rate is read from the FIFO also, so that also needs to 
be correct.
Flags
Details
SoundInStartChart requires a computer with sound inputs. Several sample experiments using sound inputs 
are in your Igor Pro Folder in the Examples folder.
On systems where 32-bit floating point data is supported, you can use NewFIFOChan with no flags and a 
range of -1 to 1.
See Also
The SoundInRecord, SoundInSet, SoundInStatus and SoundInStopChart operations, and FIFOs and 
Charts on page IV-313.
SoundInStatus 
SoundInStatus [format={intOrFloat,channels,bits,frequency}]
The SoundInStatus operation creates and sets a set of variables and strings with information about the 
current sound input device.
Keywords
Windows: SoundInSet attempts to adjust the master gain of the sound input device but not all 
sound cards have a master gain. If V_SoundInGain from the SoundInStatus command returns 
-1, you will have to use your sound card software to adjust the input gain for the particular 
input source your are using. On some cards there are separate line-in and microphone-in 
sources.
/Z
Errors are not fatal. V_flag is set to zero if no error, else nonzero if error.
/Z
Errors are not fatal. V_flag is set to zero if no error, else nonzero if error.
format={intOrFloat, channels, bits, frequency}
