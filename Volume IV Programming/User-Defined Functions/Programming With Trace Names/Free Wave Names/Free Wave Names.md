# Free Wave Names

Chapter IV-3 — User-Defined Functions
IV-95
To a discussion of leak detection and investigation techniques, see Detecting Wave Leaks on page IV-206.
Free Wave Names
By default, the name of a free wave is _free_. If you use free waves in programming, you may find that the 
lack of specific names makes debugging difficult. If you break into the debugger, you see a lot of waves 
named _free_ and you can't tell which is used for what purpose.
In Igor Pro 9.00 and later, you can override the default and provide specific names for free waves using 
Make/FREE=1 and NewFreeWave. This improves debuggability and also helps in investigating leaks using 
the WaveTracking operation.
This example shows how to use Make/FREE=1 to specify the name of a free wave:
Function FreeWaveName1()
// Creates a wave reference named tempw, wave name is _free_
Make/FREE tempw
Print NameOfWave(tempw)
// Prints _free_
// Creates a wave reference named tempw, wave name is also tempw
Make/FREE=1 tempw2
Print NameOfWave(tempw2)
// Prints tempw2
End
You can also give a name to a free wave using the optional name string input to NewFreeWave:
Function FreeWaveName2()
// Creates a wave reference named tempw, wave name is _free_
Wave tempw = NewFreeWave(4,2)
Print NameOfWave(tempw)
// Prints _free_
// Creates a wave reference named tempw, wave name is myFreeWave
Wave tempw = NewFreeWave(4,2,"myFreeWave")
Print NameOfWave(tempw)
// Prints myFreeWave
End
Igor does not use the name of a free wave but in user procedure code there could be an assumption that free 
waves are named '_free_'. In that rare case, specifying the name of a free wave could expose a bug. The fix 
is to use WaveType to determine if a wave is free instead of the wave name.
Even if you didn't give a name to a free wave explicitly, there are tricky ways for a free wave to have a name 
other than '_free_'. One such way is to create a wave inside a free data folder, and then kill the free data 
folder:
Function/WAVE WaveInFreeDF()
DFREF saveDF = GetDataFolderDFR()
DFREF freeDF = NewFreeDataFolder()
SetDataFolder freeDF
// Free data folder is current data folder
Make jack
// Wave in free data folder
SetDataFolder saveDF
// Free data folder is no longer current data folder
return jack
// At this point the free data folder is killed because freeDF
// goes out of scope and consequently jack becomes a free wave
End
Function Tricky()
Wave w = WaveInFreeDF()
Print NameOfWave(w)
// Prints jack
Print WaveType(w, 3)
// Prints 1 meaning free wave
End
