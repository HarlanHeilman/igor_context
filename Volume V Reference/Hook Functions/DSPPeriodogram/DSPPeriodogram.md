# DSPPeriodogram

DSPDetrend
V-182
the case if one of the previously existing layers were used. For consistency, this layer is also available in 
control panels.
See Also
Chapter III-3, Drawing.
SetDrawEnv, SetDrawLayer, DrawBezier, DrawPoly, DrawAction
DSPDetrend 
DSPDetrend [flags] srcWave
The DSPDetrend operation removes from srcWave a trend defined by the best fit of the specified function 
to the data in srcWave.
Flags
Details
DSPDetrend sets V_flag to zero when the operation succeeds, otherwise it will be set to -1 or will contain 
an error code from the curve fitting routines. Results are saved in the wave W_Detrend (for 1D input) or 
M_Detrend (for 2D input) in the current data folder. If a wave by that name already exists in the current 
data folder it will be overwritten.
See Also
CurveFit for more information about V_FitQuitReason and the built-in fitting functions.
DSPPeriodogram 
DSPPeriodogram [flags] srcWave [srcWave2]
The DSPPeriodogram operation calculates the periodogram, cross-spectral density or the degree of 
coherence of the input waves. The result of the operation is stored in the wave W_Periodogram in the 
current data folder or in the wave that you specify using the /DEST flag.
To compute the cross-spectral density or the degree of coherence, you need to specify the second wave 
using the optional srcWave2 parameter. In this case, W_Periodogram will be complex and the /DB and /DBR 
flags do not apply.
Flags
/A
Subtracts the average of srcWave before performing any fitting. Added in Igor Pro 
7.00.
/F= function
function is the name of a built-in curve fitting function:
gauss, lor, exp, dblexp, sin, line, poly (requires /P flag), hillEquation, sigmoid, power, 
lognormal, poly2d (requires /P flag), gauss2d.
If function is unspecified, the defaults are line if srcWave is 1D or poly2d if srcWave is 
2D.
/M=maskWave
Detrending will only affect points that are nonzero in maskWave. Note that maskWave 
must have the same dimensionality as srcWave.
/P=n
Specifies polynomial order for poly or poly2d functions (see CurveFit for details).
When used with the 1D poly function n specifies the number of terms in the 
polynomial.
By default n=3 for the 1D case and n=1 for poly2d.
/Q
Quiet mode; no error reporting.
/DB
Expresses results in dB using the maximum value as reference.
/DBR=ref
Express the results in dB using the specified ref value.
/COHR
Computes the degree of coherence. This flag applies when the input consists of two 
waves.

DSPPeriodogram
V-183
/DEST=destWave
Specifies the output wave created by the operation.
The /DEST flag was added in Igor Pro 8.00.
It is an error to specify the same wave as both srcWave and destWave.
When used in a function, the DSPPeriodogram operation by default creates a real 
wave reference for the destination wave. See Automatic Creation of WAVE 
References on page IV-72 for details.
/DLSG
When computing the periodogram, cross-spectral density or the degree of coherence 
using multiple segments the operation by default pads the last segment with zeros as 
necessary. If you specify this flag, an incomplete last segment is dropped and not 
included in the calculation.
/DTRD
Detrends segments by subtracting the linear regression of each segment before 
multiplication by the window function. /DTRD affects segments and is not 
compatible with /NODC=1. /DTRD was added in Igor Pro 8.00.
/NODC=val
/NOR=N
/PARS
Sets the normalization to satisfy Parseval's theorem even when using a window 
function.
The /PARS flag was added in Igor Pro 8.00. It overrides the /NOR flag.
See Normalization Satisfying Parseval's Theorem on page V-185 for further 
information.
/Q
Quiet mode; suppresses printing in the history area.
/SEGN={ptsPerSegment, overlapPts}
Use this flag to compute the periodogram, cross-spectral density or degree of 
coherence by averaging over multiple segments taken from the input waves. The size 
of each interval is ptsPerSegment. overlapPts determines the number of points at the 
end of each interval that are included in the next segment.
/R=[startPt, endPt]
Calculates the periodogram for a limited range of the wave. startPt and endPt are 
expressed in terms of point numbers in srcWave.
/R=(startX, endX)
Calculates the periodogram for a limited range of the wave. startX and endX are 
expressed in terms of x-values. Note that this option will convert your x-specifications 
to point numbers and some roundoff may occur.
/WIN=windowKind Specifies the window type. If you omit the /W flag, DSPPeriodogram uses a 
rectangular window for the full wave or the range of data selected by the /R flag.
Choices for windowKind are:
Bartlett, Blackman367, Blackman361, Blackman492, Blackman474, Cos1, Cos2, Cos3, 
Cos4, Hamming, Hanning, KaiserBessel20, KaiserBessel25, KaiserBessel30, Parzen, 
Poisson2, Poisson3, Poisson4, and Riemann.
See FFT for window equations and details.
Suppresses the DC term:
val=1:
Removes the DC by subtracting the average value of the signal before 
processing and before applying any window function (see /Win 
below).
val=2:
Suppresses the DC term by setting it equal to the second term in the 
FFT array.
val=0:
Computes the DC term using the FFT (default).
Sets the normalization, N, in the periodogram equation. By default, it is the number 
of data points times the square norm of the window function (if any).
Any other value of N is used as the only normalization.
N=0 or 1:
Skips default normalization.

DSPPeriodogram
V-184
Details
The default periodogram is defined as
where F (s) is the Fourier transform of the signal s and N is the number of points.
In most practical situations you need to account for using a window function (when computing the Fourier 
transform) which takes the form
where w is the window function, Np is the number of points and Nw is the normalization of the window 
function.
If you compute the periodogram by subdividing the signal into multiple segments (with any overlap) and 
averaging the results over all segments, the expression for the periodogram is
where si is the ith segment s, Ns is the number of points per segment and M is the number of segments.
When calculating the cross-spectral density (csd) of two waves s1 and s2, the operation results in a complex 
valued wave
which contains the normalized product of the Fourier transform of the first wave SA with the complex 
conjugate of the Fourier transform of the second wave SB. The extension of the csd calculation to segment 
averaging has the form
where SAi is the ith segment of the first wave, M is the number of segments and Ns is the number of points 
in a segment.
The degree of coherence is a normalized version of the cross-spectral density. It is given by
/Z
Do not report errors. When an error occurs, V_flag is set to -1.
Periodogram = F(s)
2
N
,
Periodogram = F(s w)
2
N pNw
,
Periodogram =
F(si w)
2
i=1
M

MNsNw
,
csd = F(sA)[F(sB)]*
N
,
csd =
F(sAi)[F(sBi)]*
i=0
M

MNsNw
,
