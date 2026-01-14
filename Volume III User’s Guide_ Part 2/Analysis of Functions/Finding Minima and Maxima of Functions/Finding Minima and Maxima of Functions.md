# Finding Minima and Maxima of Functions

Chapter III-10 — Analysis of Functions
III-343
Caveats for Multidimensional Root Finding
Finding roots of multidimensional nonlinear 
functions is not straightforward. There is no gen-
eral, foolproof way to do it. The method Igor uses 
is to search for minima in the sum of the squares 
of the functions. Since the squared values must 
be positive, the only places where this sum can be 
zero is at points where all the functions are zero 
at the same time. That point is a root, and it is also 
a minimum in the summed squares of the func-
tions.
To find the zero points, Igor searches for local 
minima by travelling downhill from the start-
ing point. Unfortunately, a local minimum 
doesn’t have to be a root, it just has to be some-
place where the sum of squares of the functions 
is less than surrounding points.
The adjacent graph shows how this can 
happen.
The two heavy lines are the zero contours for 
two functions (they happen to be fifth-order 
2D polynomials). Where these zero contours 
cross are the roots for the system of the two functions.
The thin lines are contours of f1(x,y)2+f2(x,y)2, with dotted lines for high values; minima are surrounded by thin, 
solid contours. You can see that every intersection between the heavy zero contours is surrounded by thin con-
tours showing that these are minima in the sum of the squared functions. One such point is labeled “Root”.
There is at least one point, labelled “False Root”, where there is a minimum but the zero contours don’t 
cross. That is not a root, but FindRoots may find it anyway. For instance, a real root:
FindRoots /x={3,6} MyPoly2d, nn1coefs, MyPoly2d, nn2coefs
Root found after 11 function evaluations.
W_Root={5.4623,7.28975}
Function values at root:
W_YatRoot={-4.15845e-13,1.08297e-12}
This point is the point marked “Root”. However:
FindRoots/x={9,10} MyPoly2d, nn1coefs, MyPoly2d, nn2coefs
Root found after 52 function evaluations.
W_Root={8.38701,9.10129}
Function values at root:
W_YatRoot={0.0686792,0.0129881}
You can see from the values in W_YatRoot that this is not a root. This point is marked “False root” on the 
figure above.
The polynomials used in this example have too many coefficients to be conveniently shown here. To see 
this example and others in action, try out the demo experiment. It is called “MD Root Finder Demo” and 
you will find it in your Igor Pro 7 folder, in the Examples:Analysis: folder.
Finding Minima and Maxima of Functions
The Optimize operation finds extreme values (maxima or minima) of a nonlinear function.
20
15
10
5
0
20
15
10
5
0
Possible
False Root
Zero contour
for f2(x,y)
Zero contour
for f1(x,y)
Root
