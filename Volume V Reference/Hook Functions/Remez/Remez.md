# Remez

Remez
V-789
Wave Data Types
As a replacement for the above number type flags you can use /Y=numType to set the number type as an 
integer code. See the WaveType function for code values. Do not use /Y in combination with other type 
flags. This technique cannot be used to change the number type without changing the real/complex setting.
Details
The waves must already exist. New points in waves that are extended are zeroed.
In general, Redimension does not move data from one dimension to another. For instance, if you have a 6x6 
matrix wave, and you would like it to be 3x12, the rows have been shortened and the data for the last three 
rows is lost.
As a special case, if converting to or from a 1D wave, Redimension will leave the data in place while 
changing the dimensionality of the wave. For example, you can use Redimension to convert a 36-element 
1D wave into a 6x6 matrix in which the elements in the first column (column 0) are the first 6 elements of 
the 1D wave, the elements of the second column are the next 6, etc. When redimensioning from a 1D wave, 
columns are filled first, then layers, followed by chunks.
Examples
Reshaping a 1D wave having 4 elements to make a 2x2 matrix:
Make/N=4 vector=x
Redimension/N=(2,2) vector
See Also
Make, DeletePoints, InsertPoints, Concatenate, SplitWave
Remez
Remez [/N=num /Q[=iter] ] frWave, wtWave, gridWave, coefsWave
The Remez operation calculates the coefficients for digital filters given a desired frequency response as 
input.
Remez is primarily used for the MPR filter feature of the Igor Filter Design Laboratory (IFDL) package.
Parameters
frWave contains the desired response.
wtWave contains the weight function array. For a differentiator, the weight function is inversely 
proportional to frequency.
gridWave contains the frequencies corresponding to each point in frWave and wtWave. Its values range from 
0 to 0.5 with gaps where the band edges occur.
coefsWave receives the resulting coefficients. Its length defines the number of coefficients (nfilt in the IEEE 
program referenced below).
Flags
Details
Remez returns symmetrical coefficients suitable for use with FilterFIR in coefsWave.
/N=mode
mode=0: Selects multiple passband/stopband filter (default).
mode=1: Selects differentiator or Hilbert transform filter.
/Q[=iter]
Determines if execution stops if the filter doesn't converge.
If you omit /Q, execution stops if the filter doesn't converge.
If you specify /Q or /Q=0, execution continues if the filter doesn't converge, regardless 
of the number of iterations.
For iter>=1, execution stops if the filter fails to converge in iter iterations or less. If the 
filter does converge after iter iterations, execution does stop.
Use /Q=3 to stop execution for serious errors (after only 1, 2, or 3 iterations) but not 
for minor errors (after 4 or more iterations).
