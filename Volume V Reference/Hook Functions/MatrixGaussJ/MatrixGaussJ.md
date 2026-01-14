# MatrixGaussJ

MatrixGaussJ
V-540
Flags
Details
This operation does not support complex waves.
See Also
ImageFilter operation for additional options. Matrix Math Operations on page III-138 for more about 
Igor’s matrix routines. The Loess operation.
References
Heckbert, Paul S., (Ed.), Graphics Gems IV, 575 pp., Morgan Kaufmann Publishers, 1994.
Zhang, T. Y., and C. Y. Suen, A fast thinning algorithm for thinning digital patterns, Comm. of the ACM, 27, 
236-239, 1984.
MatrixGaussJ 
MatrixGaussJ matrixA, vectorsB
The MatrixGaussJ operation solves matrix expression A*x=b for column vector x given matrix A and 
column vector b. The operation can also be used to calculate the inverse of a matrix.
Parameters
matrixA is a NxN matrix of coefficients and vectorsB is a NxM set of right-hand side vectors.
Details
On output, the array of solution vectors x is placed in M_x and the inverse of A is placed in M_Inverse.
If the result is a singular matrix, V_flag is set to 1 to indicate the error. All other errors result in an alert, and 
abort any calling procedure.
All output objects are created in the current data folder.
An error is generated if the dimensioning of the input arrays is invalid.
sharpenmore
3x3 sharpening filter=(9*center-outer).
thin
Calculates binary image thinning using neighborhood maps based on the algorithm 
in Graphics Gems IV, p. 465.
Note: The thin keyword to MatrixFilter will be removed someday. The functionality 
will be available — just not as a part of MatrixFilter. The /R flag does not apply to the 
lame duck thin keyword.
/B=b
Specifies value that is considered background. Used with thin. If object is black on 
white background, use 255. If object is white on a black background, use 0.
/F=value
Specifies the value in the ROI wave that marks excluded pixels. value is either 0 or 1.
This flag was added in Igor Pro 7.00.
By default, and for compatibility with Igor Pro 6, value=0. Use /F=1 if your ROI wave 
contains 1 for pixels to be excluded.
/M=rank
Assigns a pixel value other than the median when used with the median filter. Valid 
rank values are between 0 and n2-1 (for the default median rank= n2/2).
/N=n
For any method described above as “nxn”, you can specify that the filtering kernel 
will be a square matrix of size n. In the absence of the /N flag, the default size is 3.
/P=p
Filter passes over the data p times. The default is one pass.
/R=roiWave
Only the data outside the region of interest will be modified. roiWave should be an 8-
bit unsigned wave with the same dimensions as the data matrix. The exterior of the 
ROI is defined by zeros and the interior is any nonzero value.
/T
Applies the thining algorithm of Zhang and Suen with the thin parameter. The wave 
M_MatrixFilter contains the results; the input wave is not overwritten.
