# STFT

STFT
V-994
STFT
STFT [flags] srcWave
The STFT operation computes the Short-Time Fourier Transform of srcWave. STFT was added in Igor Pro 
8.00.
Output is stored in the wave M_STFT in the current data folder or in a wave specified by the /DEST flag.
Flags
/DB=dbMode
/DEST=destWave
Specifies the output wave created by the FFT operation.
It is an error to attempt specify the same wave as both srcWave and destWave.
The default output wave name M_STFT is used if you omit /DEST.
When used in a function, the STFT operation by default creates a real wave reference 
for the destination wave. See Automatic Creation of WAVE References on page 
IV-72 for details.
/HOPS=hopSize
Specifies the offset in points between centers of consecutive source segments. By 
default this value is 1 and the transform is computed for segments that are offset by a 
single points from each other.
/OUT=mode
/PAD=newSize
Converts each segment of srcWave into a padded array of length newSize. The padded 
array contains the original data at the center of the array with zeros elements on both 
sides.
/RP=[startPoint, endPoint]
Specifies the range of srcWave from which data are sampled in point numbers. 
startPoint is the first point at which segments are centered. Wave data from points 
preceding startPoint are used as needed for the left parts of beginning segments.
/RX=(startX, endX)
Specifies the range of srcWave from which data are sampled in X values. The operation 
expects startX<endX. startX corresponds to the first point at which segments are 
centered. Data from points preceding startX are used as necessary to fill left parts of 
the beginning segments.
/SEGS=segSize
Sets the length of the segment sampled from srcWave in points. The segment is 
optionally padded to a larger dimension (see /PAD) and multiplied by a window 
function prior to FFT. The default segment size is 128 when the number of points in 
srcWave is greater than 128. Otherwise it is set to one less than the number of points 
in the srcWave. The operation requires that segSize is at least 32 points.
dbMode determines if output is scaled in decibels:
0:
No dB scaling (default)
1:
Scale the output to standard dB using 20*log(wave)
2:
Compute dBFS (dB relative to full scale where 0 is the maximum value)
Sets the output wave format.
The scaled quantities apply to transforms of real valued inputs where the output is 
normally folded in the first dimension (because of symmetry). The scaling applies 
a factor of 2 to the squared magnitude of all components except the DC. The scaled 
transforms should be used whenever Parseval's relation is expected to hold.
mode=1:
Complex output (default)
mode=2:
Real output
mode=3:
Magnitude
mode=4:
Magnitude square
mode=5:
Phase
mode=6:
Scaled magnitude
mode=7:
Scaled magnitude squared
