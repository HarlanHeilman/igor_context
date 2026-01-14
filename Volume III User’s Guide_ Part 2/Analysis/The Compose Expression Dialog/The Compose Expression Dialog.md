# The Compose Expression Dialog

Chapter III-7 — Analysis
III-137
Using the Resample operation:
Duplicate/O wave0, wave2
Resample/DOWN=10/WINF=None/N=11 wave2
// no /UP means no interpolation
gives nearly identical results to the wave1Centered = mean(…) computation, the exceptions being only the 
initial and final values, which are simple end-effect variations.
The /WINF and /N flags of Resample define simple low-pass filtering options for a variety of decimation-
by-smoothing choices. The default /WINF=Hanning window gives a smoother result than /WINF=None. 
See the WindowFunction operation (page V-1097) for more about these window options.
See Multidimensional Decimation on page II-98 for a discussion of decimating 2D and higher dimension 
waves.
Miscellaneous Operations
WaveTransform
When working with large amounts of data (many waves or multiple large waves), it is frequently useful to 
replace various wave assignments with wave operations which execute significantly faster. The Wave-
Transform operation (see page V-1090) is designed to help in these situations. For example, to flip the data 
in a 1D wave you can execute the following code:
Function flipWave(inWave)
wave inWave
Variable num=numPnts(inWave)
Variable n2=num/2
Variable i,tmp
num-=1
Variable j
for(i=0;i<n2;i+=1)
tmp=inWave[i]
j=num-i
inWave[i]=inWave[j]
inWave[j]=tmp
endfor
End
You can obtain the same result much faster using the command:
WaveTransform/O flip, waveName
In addition to “flip”, WaveTransform can also fill a wave with point index or the inverse point index, shift 
data points, normalize, convert to complex-conjugate, compute the squared magnitude or the phase, etc.
For multi-dimensional waves, use MatrixOp instead of WaveTransform. See Using MatrixOp on page 
III-140 for details.
The Compose Expression Dialog
The Compose Expression item in the Analysis menu brings up the Compose Expression dialog.
This dialog generates a command that sets the value of a wave, variable or string based on a numeric or 
string expression created by pointing and clicking. Any command that you can generate using the dialog 
could also be typed directly into the command line.
The command that you generate with the Compose Expression dialog consists of three parts: the destina-
tion, the assignment operator and the expression. The command resembles an equation and is of the form:
<destination> <assignment-operator> <expression>
