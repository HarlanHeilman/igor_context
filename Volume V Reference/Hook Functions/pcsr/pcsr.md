# pcsr

pcsr
V-741
Details
The input is either via /WSTR=waveListStr or a list of up to 100 1D waves or a single 2D wave following the 
last flag.
waveListStr is string containing a semicolon-separated list of 1D waves to be used for the data matrix. 
waveListStr can include any legal path to a wave. Liberal names can be quoted or not quoted. It is assumed 
that all waves are of the same numerical type (either single or double precision) and that all waves have the 
same number of points.
Regardless of the inputs, the operation expects that the number of rows in the resulting matrix is greater 
than or equal to the number of columns.
The operation starts by creating the data matrix from the input wave(s). If you provide a list of 1D waves 
they become the columns of the data matrix. You can choose to use the covariance matrix (/COV) as the data 
matrix and you can also choose to normalize each column of the data matrix to convert it into standard 
scores. This involves computing the average and standard deviation of each column and then setting the 
new values to be:
.
You can pre-process the input data using MatrixOp with the SubtractMean, NormalizeRows, and 
NormalizeCols functions.
After creating the data matrix the operation computes the singular value decomposition (SVD) of the data 
matrix. Results of the SVD can be saved or processed further. Save the C and R matrices using /SCMT and 
/SRMT. These are related to the input data matrix through: 
.
The remainder of the operation lets you compute various statistical quantities defined by Malinowski (see 
References). Use the flags to determine which ones are computed.
The operation generates a number of output waves. All waves are stored in the current data folder.
You can save the input matrix D in the wave M_D, the optional SVD results are stored in the waves M_C 
that contains the column matrix C, M_R that contains the row matrix R, and W_Eigen that contains the 
eigenvalues of the data matrix. Note that these can be the eigenvalues or the square of the eigenvalues 
depending on the input matrix being a covariance matrix or not (see /SQEV).
The optional 1D output waves (W_RSD, W_RMS, W_IE, W_IND, W_PSL) are saved with wave scaling to 
make it easier to display the wave as a function of the number of factors.
References
Kaiser, H., Computer Program for Varimax Rotation in Factor Analysis, Educational and Psychological 
Measurement, XIX, 413-420, 1959.
Malinowski, E.R., Factor Analysis in Chemistry, 3rd ed., John Wiley, 2002.
See Also
ICA
pcsr 
pcsr(cursorName [, graphNameStr])
The pcsr function returns the point number of the point which the specified cursor (A through J) is on in the 
top (or named) graph. When used with cursors on images or waterfall plots, pcsr returns the row number, 
and when used with a free cursor, it returns the relative X coordinate.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
Semicolon-separated string list of the names of all input waves.
/Z
No error reporting.
newValue
oldValue
colAverage
–
colStdv
------------------------------------------------------------
=
D
R C

=
