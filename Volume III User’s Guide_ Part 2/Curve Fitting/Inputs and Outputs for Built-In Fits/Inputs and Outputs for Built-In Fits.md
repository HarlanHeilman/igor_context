# Inputs and Outputs for Built-In Fits

Chapter III-8 — Curve Fitting
III-212
lognormal
Fits a lognormal peak shape. This function is gaussian when plotted on a log X axis.
Coefficient y0 sets the baseline, A sets the amplitude, x0 sets the peak position in X and width sets the peak width.
Note that X values must be greater than 0. Including a data point at 
 will cause a singular matrix error 
and the message, “The fitting function returned NaN for at least one X value.”
gauss2D
Fits a Gaussian peak in two dimensions.
Coefficient cor is the cross-correlation term; it must be between -1 and 1 (the small illustration was done with 
cor equal to 0.5). A constraint automatically enforces this range. If you know that a value of zero for this term 
is appropriate, you can hold this coefficient. Holding cor at zero usually speeds up the fit quite a bit.
In contrast with the gauss fit function, xWidth and yWidth are standard deviations of the peak.
Note that the Gauss function lacks the cross-correlation parameter cor.
poly2D n
Fits a polynomial of order n in two dimensions.
A poly2D fit takes an additional parameter that specifies the order of the polynomial. When you choose 
poly2D from the Function menu, a box appears where you enter that value.
The minimum value is 1, corresponding to a first-order polynomial, a plane. The coefficient wave for 
poly2D has the constant term (C0) in point zero, and following points contain groups of increasing order. 
There are two first-order terms, C1*x and C2*y, then three second-order terms, etc. The total number of 
terms is (N+1)(N+2)/2, where N is the order.
Poly2d never requires manual guesses.
Inputs and Outputs for Built-In Fits
There are a number of variables and waves that provide various kinds of input and output to a curve fit. 
Usually you will use the Curve Fitting dialog and the dialog will make it clear what you need, and detailed 
y0
A
x x0



ln
width
---------------------




2
–
exp
+
X
0

z0
A
1
–
2 1
cor2
–


---------------------------
x
x0
–
xwidth
-----------------




2
y
y0
–
ywidth
-----------------




2
2cor x
x0
–

y
y0
–


xwidth ywidth

-------------------------------------------------
–
+




exp
+
C0
C1x
C2y
C3x2
C4xy
C5y2

+
+
+
+
+
+


