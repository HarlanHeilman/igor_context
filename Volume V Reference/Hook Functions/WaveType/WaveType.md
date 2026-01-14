# WaveType

WaveType
V-1092
Flags
Examples
// Produce output values in the range [-1,1]:
WaveTransform /P={(pi)} phase complexWave
// Faster than myWave=myWave>1 ? 1 : myWave
WaveTransform /P={1}/O min myWave
See Also
The Rotate operation.
References
Shmueli, U. (Ed.), International Tables for Crystallography, Volume B: 3.3, Kluwer Academic Publishers, 
Dordrecht, The Netherlands, 1996.
WaveType 
WaveType(waveName [,selector ])
The WaveType function returns the type of data stored in the wave.
If selector = 1, WaveType returns 0 for a null wave, 1 if numeric, 2 if text, 3 if the wave holds data folder 
references or 4 if the wave holds wave references.
If selector = 2, WaveType returns 0 for a null wave, 1 for a normal global wave or 2 for a free wave or a wave 
that is stored in a free data folder.
If selector = 3, WaveType returns 0 for a null wave reference or a global wave, 1 for a free wave (a wave that 
is not stored in any data folder) or 2 for a local wave (a wave that is stored in a free data folder hierarchy).
If selector is omitted or zero, the returned value for numeric waves is a combination of bit values shown in 
the following table:
zapNaNs
Deletes elements whose value is NaN. This is relevant for 1D single-precision and 
double-precision floating point waves only and does nothing for other types of 1D 
waves. It is not suitable for multidimensional waves and returns an error if srcWave is 
multidimensional. Use MatrixOp replaceNaNs for multidimensional waves.
zapZeros
Deletes wave elements whose value is zero. zapZeros works only with 1D 8-bit, 16-
bit, and 32-bit integer waves and returns an error if srcWave is multidimensional or 
another data type. zapZeros was added in Igor Pro 9.00.
/D
If present, angles in wave data are interpreted as in degrees. Otherwise they are 
interpreted as in radians.
/O
Overwrites input wave.
/P={param1…}
Specifies parameters as appropriate for the keyword that you are using. The number 
of parameters and their order depends on the keyword.
/R=[startRow,endRow][startCol,endCol][startLayer,endLayer][startChunk,endChunk]
Specifies the range of elements to set for the setConstant keyword.
You can omit parameters for dimensions that don’t exist in srcWave. For example, if 
srcWave is 1D, specify just /R=[startRow,endRow].
/R was added in Igor Pro 7.00.
/V=value
Specifies the value to use for the setConstant keyword. /V was added in Igor Pro 7.00.
Type
Bit Number
Decimal Value
Hexadecimal Value
complex
0
1
1
32-bit float
1
2
2
64-bit float
2
4
4
