# WAVEClear

WAVEClear
V-1070
When localName is the same as the global wave name and you want to reference a wave in the current data 
folder, you can omit the pathToWave.
pathToWave can be a full literal path (e.g., root:FolderA:wave0), a partial literal path (e.g., :FolderA:wave0) 
or $ followed by string variable containing a computed path (see Converting a String into a Reference 
Using $ on page IV-62).
You can also use a data folder reference or the /SDFR flag to specify the location of the wave if it is not in 
the current data folder. See Data Folder References on page IV-78 and The /SDFR Flag on page IV-80 for 
details.
If the wave may not exist at runtime, use the /Z flag and call WaveExists before accessing the wave. The /Z 
flag prevents Igor from flagging a missing wave as an error and dropping into the debugger. For example:
WAVE/Z wv=<pathToPossiblyMissingWave>
if( WaveExists(wv) )
<do something with wv>
endif
In Igor Pro 9.00 and later, you can avoid the runtime lookup of localName in the current data folder by 
including the /ZZ flag. For example:
Function CallingRoutine()
WAVE/ZZ w
PassByRefRoutine(w)
Print w
End
Function PassByRefRoutine(WAVE& wr)
WAVE wr = NewFreeWave(2,2)
End
Without the /ZZ flag, at runtime Igor would attempt to find a wave named w in the current data folder. This 
is unnecessary in this case since PassByRefRoutine sets the w variable.
Flags
See Also
WaveExists function.
WAVE Reference Type Flags on page IV-74 for additional wave type flags and information.
Accessing Global Variables and Waves on page IV-65.
Accessing Waves in Functions on page IV-82.
Converting a String into a Reference Using $ on page IV-62.
WAVEClear 
WAVEClear localName [, localName1 …]
The WAVEClear operation clears out a wave reference variable. WAVEClear is equivalent to WAVE/Z 
localName= $"".
Details
Use WAVEClear to avoid unexpected results from certain operations such as Duplicate or Concatenate, 
which will reuse the contents of a WAVE reference variable and may not generate the wave in the desired 
data folder or with the desired name.
/C
Complex wave
/T
Text wave
/WAVE
Wave reference wave
/DF
Data folder reference wave
/SDFR=dfr
Specifies the source data folder. See The /SDFR Flag on page IV-80 for details.
/Z
Ignores wave reference checking failures
/ZZ
Ignores wave reference checking failures and prevents wave lookup
