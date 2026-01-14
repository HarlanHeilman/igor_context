# ZernikeR

zcsr
V-1120
zcsr 
zcsr(cursorName [, graphNameStr])
The zcsr function returns a Z value when the specified cursor is on a contour, image, or waterfall plot. 
Otherwise, it returns NaN.
Parameters
cursorName identifies the cursor, which can be cursor A through J.
graphNameStr specifies the graph window or subwindow.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Examples
Print zcsr(A)
// not zcsr("A")
Print zcsr(A,"Graph0")
// specifies the graph
See Also
The hcsr, pcsr, qcsr, vcsr, and xcsr functions.
Programming With Cursors on page II-321.
zeta
zeta(a, b [, terms ])
The zeta function returns the Hurwitz Zeta function for real or complex arguments a and b
The Riemann zeta function is the special case:
The zeta function was added in Igor Pro 7.00.
Parameters
The terms parameter defaults to 40. In practice evaluation may terminate before the specified number of 
terms when convergence is achieved.
References
Olver, Frank W. J.; Lozier, Daniel W.; Boisvert, Ronald F.; Clark, Charles W., eds., "NIST Handbook of 
Mathematical Functions", 607 pp., Cambridge University Press, 2010.
See Also
Dilogarithm
ZernikeR 
ZernikeR(n,m,r)
The ZernikeR function returns the Zernike radial polynomials of degree n that contains no power of r that 
is less than m. Here m is even or odd according to whether n is even or odd, and r is in the range 0 to 1.
Note that the full circle polynomials are complex. For any angle t (theta), they are given by: 
ZernikeR(n,m,r)*exp(imt).
ζ (a,b) =
1
(k + b)a ,
k=0
∞
∑
ℜ(a) >1,
b ≠0,−1,−2,...
ζ (a) = ζ (a,1).
