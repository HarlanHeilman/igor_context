# MandelbrotPoint

MandelbrotPoint
V-528
Flags
Details
MakeIndex is used in preparation for a subsequent IndexSort operation. If /R is used the ordering is from 
largest to smallest. Otherwise it is from smallest to largest.
When the /LOC flag is used, the bytes stored in the text wave at each point are converted into a Unicode 
string using the text encoding of the text wave data. These Unicode strings are then compared using OS 
specific text comparison routines based on the locale set in the operating system. This means that the order 
of sorted items may differ when the same sort is done with the same data under different operating systems 
or different system locales.
When /LOC is omitted the sort is done on the raw text without regard to the waves’ text encoding.
See Also
Sorting on page III-132, MakeIndex and IndexSort on page III-134, Sort, IndexSort
MandelbrotPoint
MandelbrotPoint(x, y, maxIterations, algorithm)
The MandelbrotPoint function returns a value between 0 and maxIterations based on the Mandelbrot set 
complex quadratic recurrence relation z[n] = z[n-1]^2 + c where x is the real component of c, y is the 
imaginary component of c and z[0] = 0.
The returned value is the number of iterations the equation was evaluated before |z[n]| > 2 (the escape 
radius of the Mandelbrot set), or maxIterations, whichever is less.
Parameters
See Also
The “MultiThread Mandelbrot Demo” experiment.
References
http://en.wikipedia.org/wiki/Mandelbrot_set
http://linas.org/art-gallery/escape/escape.html
/A
Alphanumeric. When sortKeyWaves includes text waves, the normal sorting places “wave1” 
and “wave10” before “wave9”. Use /A to sort the number portion numerically, so that 
“wave9” is sorted before “wave10”.
/C
Case-sensitive. When sortKeyWaves includes text waves, the ordering is case-insensitive unless 
you use the /C flag which makes it case-sensitive.
/LOC
Performs a locale-aware sort.
When sortKeyWaves includes text waves, the text encoding of the text waves’ data is taken into 
account and sorting is done according to the sorting conventions of the current system locale. 
This flag is ignored if the text waves’ data encoding is unknown, binary, Symbol, or Dingbats. 
This flag cannot be used with the /A flag. See Details for more information.
The /LOC flag was added in Igor Pro 7.00.
/R
Reverse the index so that ordering is from largest to smallest.
algorithm=0
The "Escape Time" algorithm returns the integer n which is the number of iterations 
until |z[n]| > 2.
algorithm=1
The "Renormalized Iteration Count Algorithm" algorithm returns a floating point 
value which is a refinement of the number of iterations n by adding the quantity:
5 - ln( ln( |z[n+4]| ) ) / ln(2)
(which requires four more iterations of the recurrence relation). The returned value is 
clipped to maxIterations.
