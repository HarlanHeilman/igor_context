# DWT

DWT
V-189
Output Variables
DuplicateDataFolder sets the following output variable:
Examples
DuplicateDataFolder root:DF0, root:DF0Copy
// Create a copy of DF0 named DF0Copy
See Also
MoveDataFolder, Data Folders on page II-107, Data Folder References on page IV-78, Free Data Folders 
on page IV-96
DWT 
DWT [flags] srcWaveName, destWaveName
The DWT operation performs discrete wavelet transform on the input wave srcWaveName. The operation 
works on one or more dimensions only as long as the number of elements in each dimension is a power of 
2 or when the /P flag is specified
Flags
V_flag
0 if the operation succeeded, -1 if the destination data folder already existed, or a non-
zero error code. The V_flag output variable was added in Igor Pro 8.00.
/D
Denoises the source wave. Performs the specified wavelet transform in the forward direction. It 
then zeros all transform coefficients whose magnitude fall below a given percentage (specified 
by the /V flag) of the maximum magnitude of the transform. It then performs the inverse 
transform placing the result in destWaveName. The /I flag is incompatible with the /D flag.
/I
Perform the inverse wavelet transform. The /S and /D flags are incompatible with the /I flag.
/N=num
Specifies the number of wavelet coefficients. See /T flag for supported combinations.
/P=num
/S
Smooths the source wave. This performs the specified wavelet transform in the forward 
direction. It then zeros all transform coefficients except those between 0 and the cut-off value 
(specified in % by /V flag). It then performs the inverse transform placing the result in 
destWaveName. The /I flag is incompatible with the /S flag.
/T=type
/V=value
Specifies the degree of smoothing with the /S and /D flags only.
For /S, value gives the cutoff as a percentage of data points above which coefficients are set to 
zero. For /D, value specifies the percentage of the maximum magnitude of the transform such 
that coefficients smaller than this value are set to zero.
Controls padding:
num=1:
Adds zero padding to the end of the dimension up to nearest power of 2 
when the number of data elements in a given dimension of srcWaveName is 
not a power of 2.
num=2:
Uses zero padding to compute the transform, but the resulting wave is 
truncated to the length of the input wave.
Performs the wavelet transform specified by type. The following table gives the transform 
name with the type code for the transform and the allowed values of the num parameter 
used with the /N flag. “NA” means that the /N flag is not applicable to the corresponding 
transform.
Wavelet Transform
type
num
Daubechies
1 (default)
4, 6, 8, 10, 12, 20
Haar
2
NA
Battle-Lemarie
4
NA
Burt-Adelson
8
NA
Coifman
16
2, 4, 6
Pseudo-Coifman
32
NA
splines
64
1 (2-2), 2 (2-4), 3 (3-3), 4 (3-7)
