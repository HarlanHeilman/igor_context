# FIFO2Wave

FGetPos
V-228
See Also
See Fourier Transforms on page III-270 for discussion. The inverse operation is IFFT.
Spectral Windowing on page III-275. For 2D windowing see ImageWindow. Also the Hanning window 
operation.
IFFT, DWT, CWT, STFT, HilbertTransform, WignerTransform, DSPPeriodogram, LombPeriodogram, 
Unwrap, MatrixOp
References
For more information about the use of window functions see:
Harris, F.J., “On the use of windows for harmonic analysis with the discrete Fourier Transform“, Proc, IEEE, 
66, 51-83, 1978.
Heinzel, G., Rüdiger, A., & Schilling, R. (2002). “Spectrum and spectral density estimation by the Discrete 
Fourier transform (DFT), including a comprehensive list of window functions and some new at-top 
windows“, http://hdl.handle.net/11858/00-001M-0000-0013-557A-5.
FGetPos 
FGetPos refNum
The FGetPos operation returns the file position for a file.
FGetPos is a faster alternative to FStatus if the only thing you are interested in is the file position.
The FGetPos operation was added in Igor Pro 7.00.
Parameters
refNum is a file reference number obtained from the Open operation.
Details
FGetPos supports very big files theoretically up to about 4.5E15 bytes in length.
FGetPos sets the following variables:
See Also
Open, FSetPos, FStatus
FIFO2Wave 
FIFO2Wave [/R/S] FIFOName, channelName, waveName
The FIFO2Wave operation copies FIFO data from the specified channel of the named FIFO into the named 
wave. FIFOs are used for data acquisition.
Flags
Details
The FIFO must be in the valid state for FIFO2Wave to work. When you create a FIFO, using NewFIFO, it is 
initially invalid. It becomes valid when you issue the start command via the CtrlFIFO operation. It remains 
valid until you change a FIFO parameter using CtrlFIFO.
V_flag
Nonzero (true) if refNum is valid.
V_filePos
Current file position for the file in bytes from the start.
/R=[startPoint,endPoint]
Dumps the specified FIFO points into the wave.
/S=s
Controls the wave’s X scaling and number type:
s=0:
Same as no /S.
s=1:
Sets the wave’s X scaling x0 value to the number of the first 
sample in the FIFO.
s=2:
Changes the wave’s number type to match the FIFO channel’s 
type.
s=3:
Combination of s=1 and s=2.
