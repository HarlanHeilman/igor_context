# FSetPos

fresnelCos
V-264
fresnelCos 
fresnelCos(x)
The fresnelCos function returns the Fresnel cosine function C(x).
See Also
The fresnelSin and fresnelCS functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
fresnelCS 
fresnelCS(x)
The fresnelCS function returns both the Fresnel cosine in the real part of the result and the Fresnel sine in 
the imaginary part of the result.
See Also
The fresnelSin and fresnelCos functions.
fresnelSin 
fresnelSin(x)
The fresnelSin function returns the Fresnel sine function S(x).
See Also
The fresnelCos and fresnelCS functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
FSetPos 
FSetPos refNum, filePos
The FSetPos operation attempts to set the current file position to the given position.
Parameters
refNum is a file reference number obtained from the Open operation when the file was opened.
filePos is the desired position of the file in bytes from the start of the file.
Details
FSetPos generates an error if filePos is greater than the number of bytes in the file. You can ascertain this 
limit with the FStatus operation.
When a file that is open for writing is closed, any bytes past the end of the current file position are deleted 
by the operating system. Therefore, if you use FSetPos, make sure to set the current file position properly 
before closing the file.
FSetPos supports files of any length.
See Also
Open, FGetPos, FStatus
C(x) =
cos π
2 t 2
⎛
⎝⎜
⎞
⎠⎟dt.
0
x∫
S(x) =
sin π
2 t 2
⎛
⎝⎜
⎞
⎠⎟dt.
0
x∫
