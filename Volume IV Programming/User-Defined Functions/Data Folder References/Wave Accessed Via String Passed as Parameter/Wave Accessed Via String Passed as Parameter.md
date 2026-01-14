# Wave Accessed Via String Passed as Parameter

Chapter IV-3 — User-Defined Functions
IV-83
Test($"wave0")
String wName = "wave0"; Test($wName)
In the first call to Test, the wave reference is a literal wave name. In the second call, we create the wave refer-
ence using $<literal string>. In the third call, we create the wave reference using $<string variable>. $<literal 
string> and $<string variable> are specific cases of the general case $<string expression>.
If the function expected to receive a reference to a text wave, we would declare the parameter using:
WAVE/T w
If the function expected to be receive a reference to a complex wave, we would declare the parameter using:
WAVE/C w
If you need to return a large number of values to the calling routine, it is sometimes convenient to use a 
parameter wave as an output mechanism. The following example illustrates this technique:
Function MyWaveStats(inputWave, outputWave)
WAVE inputWave
WAVE outputWave
WaveStats/Q inputWave
outputWave[0] = V_npnts
outputWave[1] = V_avg
outputWave[2] = V_sdev
End
Function Test()
Make/O testwave= gnoise(1)
Make/O/N=20 tempResultWave
MyWaveStats(testwave, tempResultWave)
Variable npnts = tempResultWave[0]
Variable avg = tempResultWave[1]
Variable sdev = tempResultWave[2]
KillWaves tempResultWave
Printf "Points: %g; Avg: %g; SDev: %g\r", npnts, avg, sdev
End
If the calling function needs the returned values only temporarily, it is better to return a free wave as the 
function result. See Wave Reference Function Results on page IV-76.
Wave Accessed Via String Passed as Parameter
This technique is of most use when the wave might not exist when the function is called. It is appropriate 
for functions that create waves.
Function Test(wName)
String wName
// String containing a name for wave
Make/O/N=5 $wName
WAVE w = $wName
// Create a wave reference
Print NameOfWave(w)
End
Test("wave0")
This example creates wave0 if it does not yet exist or overwrites it if it does exist. If we knew that the wave 
had to already exist, we could and should use the wave parameter technique shown in the preceding sec-
tion. In this case, since the wave may not yet exist, we can not use a wave parameter.
