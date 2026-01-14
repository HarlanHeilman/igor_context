# FindSequence

FindSequence
V-252
The results of finding roots of a single 1D function are put into several variables:
Results for roots of a system of nonlinear functions are reported in waves:
Roots of a polynomial are reported in a wave:
See Also
Finding Function Roots on page III-338.
The FindRoots operation uses the Jenkins-Traub algorithm for finding roots of polynomials:
Jenkins, M.A., Algorithm 493, Zeros of a Real Polynomial, ACM Transactions on Mathematical Software, 1, 
178-189, 1975. Used by permission of ACM (1998).
FindSequence 
FindSequence [flags] srcWave
The FindSequence operation finds the location of the specified sequence starting the search from the 
specified start point. The result of the search stored in V_value is the index of the entry in the wave where 
the first value is found or -1 if the sequence was not found.
Flags
V_numRoots
The number of roots found. Either 1 or 2.
V_Root
The root.
V_YatRoot
The Y value of the function at the root. Always check this; some discontinuous 
functions may give an indication of success, but the Y value at the found root isn’t 
even close to zero.
V_Root2
Second root if FindRoots found two roots.
V_YatRoot2
The Y value at the second root.
W_Root
X values of the root of a system of nonlinear functions. If you used /X=xWave, the root 
is reported in your wave instead.
W_YatRoot
The Y values of the functions at the root of a system of nonlinear functions.
Only one root is found during a single call to FindRoots.
W_polyRoots
A complex wave containing the roots of a polynomial. The number of roots should be 
equal to the degree of the polynomial, unless a root is doubled.
/FNAN
Specifies searching for a NaN value when srcWave is floating point.
This flag was added in Igor Pro 7.00.
/I=wave
Specifies an integer sequence wave for integer search.
/M=val
If there are repeating entries in the match sequence, val is a tolerance value that specifies 
the maximum difference between the number of repeats. So, for example, if the match 
sequence is aaabbccc and the srcWave contains a sequence aabbcc then the sequence will 
not be considered a match if val=0 but will be considered a match if val=1.
/R
Searches in reverse from the point in srcWave specified by /S or, if you omit /S, from 
the end of srcWave. /R was added in Igor Pro 9.00.
/S=start
Sets starting point of the search.
If you omit /S, the search starts from the start of srcWave or, if you include /R, from the 
end of srcWave.
/T=tolerance
Defines the tolerance (value ± tolerance will be accepted) when comparing floating 
point numbers.
/U=uValueWave
Specifies the match sequence wave in case of unsigned long range.
