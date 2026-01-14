# FMaxFlat

FitFunc
V-255
FitFunc 
FitFunc
Marks a user function as a user-defined curve fit function. By default, only functions marked with this 
keyword are displayed in the Function menu in the Curve Fit dialog.
If you wish other functions to be displayed in the Function menu, you can select the checkbox labelled 
“Show old-style functions (missing FitFunc keyword)”.
See Also
User-Defined Fitting Functions on page III-250.
floor 
floor(num)
The floor function returns the closest integer less than or equal to num.
The result for INF and NAN is undefined.
See Also
The round, ceil, and trunc functions.
FMaxFlat
FMaxFlat [/SYM[=sym] /Z[=z]] beta, gamma, coefsWave
The FMaxFlat operation calculates the coefficients of Kaiser's maximally flat filter.
FMaxFlat is primarily used for the Kaiser maximally flat filter feature of the Igor Filter Design Laboratory 
(IFDL) package.
Flags
Parameters
beta is the transition frequency ("cutoff") expressed as a fraction of the sampling frequency, more than 0 and 
less than 0.5.
gamma is the transition width in fraction of sampling frequency, a number more than 0 and less than 0.5, 
and less than both beta*2 and 1-2*beta.
coefsWave is the 1D single- or double-precision floating point wave that receives the resulting coefficients. 
In Igor8 or later, FMaxFlat resizes coefsWave as necessary to fit the number of returned values. The upper 
bound on the number of coefficients can be computed as: ceil(5/16/gamma/gamma)+1
Details
The operation is based on the "mxflat" program as found in Elliot and Kaiser (see references below).
Use the /SYM flag to return a coefsWave with symmetrical coefficients suitable for use with FilterFIR, in 
which case the number of points in coefsWave identifies the number of filter coefficients.
If you omit /SYM or specify /SYM=0, only half of the coefficients are computed by FMaxFlat. The rest can 
be obtained by symmetry, but the first point of coefsWave contains the number of computed coefficients in 
the designed filter. This unusual format is compatible with pre-Igor8 IFDL procedures.
Example
// Make a maximally-flat low pass filter with cutoff at 1/4 sampling frequency
Make/O/D/N=0 coefs
// coefs will be resized
/SYM[=sym]
Return symmetrical FIR filter coefficients without a leading length point (see Details 
below). The /SYM flag was added in Igor Pro 8.00.
/Z[=z]
Prevents procedure execution from aborting if FMaxFlat generates an error. The /Z 
flag was added in Igor Pro 8.00.
V_Flag is set to a non-zero error code or zero if no error occurred. 
Use /Z or the equivalent, /Z=1, if you want to handle errors in your procedures rather 
than having execution abort. Unlike some other operations /Z does suppress invalid 
beta and gamma value parameter errors.
