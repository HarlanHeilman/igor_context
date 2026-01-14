// WMFitFunctions v1.1	- 11/1/93
// Comments added by JW 6/12/00
//
// JW 070110
// Reviewed the functions, added FuncFit sub-type, made some comments on them.
// Ran them through the Edit Fit Function dialog to get them in a more modern form,
// picked pretty much arbitrary names for the coefficients in the process. If you have
// your own favorite names for the coefficients, send them to support@wavemetrics.com
//
// These functions were contributed or suggested by Igor users.
// We have renamed them so that the last digit(s) is the number of coefficients.
// For example, power_3 has three coefficients, w[0], w[1], and w[2].
// When describing the equation, we use Kn for w[n] because it's a little easier to read.
//
// To use one of these functions, copy it and paste into your procedure window rather
// than opening or #including this entire file; it will shorten your compile time a little.

// **** the following POLYNOMIAL FUNCTIONS were provided to allow you to hold
// fit coefficients in line and polynomial curve fits. Igor Pro 4 allows you to hold
// the coefficients using the built-in line and poly fit functions.

// POLYNOMIAL FUNCTIONS
// JW 010710 OBSOLETE: These functions were made to allow holding coefficients for line and poly fits,
// since the built-in function were originally unable to do that. It is now possible to hold coefficients
// for line and poly fits, so these are obsolete.

// y = K0 +K1*x (Use this to hold K0 or K1 constant; built-in line fit can't do that)
Function lineHold_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+b*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b

	return w[0]+w[1]*x
End

// y = K0 +K1*x + K2*x^2 (Use this to hold K0 - K2 constant; built-in poly fit can't do that)
Function poly_ff3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+(b+ c*x)*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c

	return w[0]+(w[1]+ w[2]*x)*x
End

// y = K0 +K1*x + K2*x^2 +K3*x^3  (Use this to hold K0 - K3 constant; built-in poly fit can't do that)
Function poly_ff4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+(b+(c+d*x)*x)*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d

	return w[0]+(w[1]+(w[2]+w[3]*x)*x)*x
End

// y = K0 +K1*x + K2*x^2 +K3*x^3 +K4*x^4  (Use this to hold K0 - K4 constant; built-in poly fit can't do that)
Function poly_ff5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = a+ (b+ (c+(d+e*x)*x)*x)*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d
	//CurveFitDialog/ w[4] = e

	return w[0]+ (w[1]+ (w[2]+(w[3]+w[4]*x)*x)*x)*x
End


// EXPONENTIAL FUNCTIONS

// superceded by the built-in Power fit function; hold the A parameter constant at 1.0
// y= K0 + x**K1, x > 0
Function power_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + x^e
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = e

	return w[0] + x^w[1]
End

// superceded by the built-in Power fit function
// y= K0 + K1*x**K2, x > 0
Function power_ff3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A*(x^e)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = e

	return w[0] + w[1]*(x^w[2])
End

// y= K0 + K1**x
Function k1RaisedX_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + b^x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = B

	return w[0] + w[1]^x
End

// y= K0 + K1**x
Function k2RaisedX_3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A*b^x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = b

	return w[0] + w[1]*w[2]^x
End

// y = K0 + K1*exp(x/K2) + K3*exp(x/K4), similar to dblexp
// JW 070110 Now you can use the built-in dblexp_XOffset.
Function dblexpInv_ff5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A1*exp(x/tau1) + A2*exp(x/tau2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A1
	//CurveFitDialog/ w[2] = tau1
	//CurveFitDialog/ w[3] = A2
	//CurveFitDialog/ w[4] = tau2

	return w[0] + w[1]*exp(x/w[2]) + w[3]*exp(x/w[4])
End

// LOGARITHMIC FUNCTIONS


// y= K0 + K1*ln(x), x > 0
Function ln_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A*ln(x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A

	return w[0] + w[1]*ln(x)
End

// y= K0 + K1*log(x), x > 0
Function logBaseTen_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A*log(x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A

	return w[0] + w[1]*log(x)
End

// y= K0 + K1*log2(x), x > 0
Function logBaseTwo_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + A*ln(x)/ln(2)	// for a different base b, replace ln(2) with ln(b).
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A

	return w[0] + w[1]*ln(x)/ln(2)	// for w[1] different base b, replace ln(2) with ln(b).
End


// SPECIAL-PURPOSE FUNCTIONS
// The following functions are classified by what they are used for,
// rather than their mathematical form.

// GEOLOGIC FUNCTIONS
// Dr. John D. Weeks
// john_weeks@brown.edu
// Here are two functions we have used in stress relaxation experiments
// studying rock friction.  In these experiments a load is applied, and the
// loading piston is held at a constant position.  Any creep of the sample
// results in decaying stress as the (relatively) compliant loading piston
// changes length.  A particular function giving stress as a function of slip
// velocity (stress = c1 + c2*ln(V)) yields a velocity decay described by a
// hyperbola in time:

// y = K0 /(K1+ x)
Function hyperbola_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A/(x0 + x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = x0

	return w[0]/(w[1] + x)
End

// This function also describes the decay of rate of aftershocks after an
// earthquake.  This is probably *not* a coincidence.
// 
// This decay in velocity results in the following function for decay of
// stress with time:

// y = K0 + K1*ln(K2+x)
Function logplus_ff3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0+A*ln(xoff+x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = xoff

	return w[0]+w[1]*ln(w[2]+x)
End
	
// KINETICS FUNCTIONS
// wishart@bnl.bnl.gov (James Wishart)
//
// y = K0 + K1/(1+K2*x)
Function kin2ndOrder_ff3(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/  f(x) = Y0 + R/(1+K*x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = R
	//CurveFitDialog/ w[2] = K

	 return w[0] + w[1]/(1+w[2]*x)
End

// y = K0 + K1*exp(K2*x) + K3*exp(K4*x)
Function KinTwo1stOrder_ff5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/  f(x) = Y0 + C1*exp(K1*x)+ C2*exp(K2*x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = C1
	//CurveFitDialog/ w[2] = K1
	//CurveFitDialog/ w[3] = C2
	//CurveFitDialog/ w[4] = K2

	 return w[0] + w[1]*exp(w[2]*x)+ w[3]*exp(w[4]*x)
End

// y = K0 +  K1/(1+K2*x) + K3*exp(K4*x)
Function Kin1st2ndOrder_ff5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/  f(x) = Y0 + C1/(1+K1*x)+ C2*exp(K2*x)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = C1
	//CurveFitDialog/ w[2] = K1
	//CurveFitDialog/ w[3] = C2
	//CurveFitDialog/ w[4] = K2

	 return w[0] + w[1]/(1+w[2]*x)+ w[3]*exp(w[4]*x)
End

// y = K0  + K1*exp(K2*x) + K3*exp(K4*x) + K5*x
Function KinTwo1stOrderSlope_ff6(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ 							// a slow subsequent kinetic process
	//CurveFitDialog/ 
	//CurveFitDialog/  f(x) = Y0 + C1*exp(K1*x)+ C2*exp(K2*x)+ b*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 6
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = C1
	//CurveFitDialog/ w[2] = K1
	//CurveFitDialog/ w[3] = C2
	//CurveFitDialog/ w[4] = K2
	//CurveFitDialog/ w[5] = b

								// a slow subsequent kinetic process
	
	 return w[0] + w[1]*exp(w[2]*x)+ w[3]*exp(w[4]*x)+ w[5]*x
End

// y = K0  + K1*exp(K2*x) + K3*x
Function Kin1stOrderSlope_ff4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0 + C*exp(K*x)+ b*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = C
	//CurveFitDialog/ w[2] = K
	//CurveFitDialog/ w[3] = b

	return w[0] + w[1]*exp(w[2]*x)+ w[3]*x
End

// y = K0  +  K1/(1+K2*x) + K3*x
Function Kin2ndOrderSlope_ff4(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/  f(x) = (Y0 + C/(1+K*x)+ b*x )
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = C
	//CurveFitDialog/ w[2] = K
	//CurveFitDialog/ w[3] = b

	 return (w[0] + w[1]/(1+w[2]*x)+ w[3]*x )
End

// BIOLOGICAL/THERMODYNAMICS FUNCTIONS
//
// Szoke Sz, Belgium
// "Szvke Sz." <szoke@geru.ucl.ac.be>
//  The following equations are used in water adsorption isotherms, etc.
// their inverse (x = f(y)) could be used as growing functions of living things
Function adsorpA_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = ln(ln(1/x) / R) / ln(C)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = C
	//CurveFitDialog/ w[1] = R

	return ln(ln(1/x) / w[1]) / ln(w[0])
End

Function adsorpB_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = ((-C / ln(x))^(1 / R))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return ((-w[1] / ln(x))^(1 / w[0]))
End

Function adsorpC_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = ((-C / ln(1 - x))^(1 / R))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return ((-w[1] / ln(1 - x))^(1 / w[0]))
End

Function adsorpD_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (R * (x / (1 - x)) + C)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return (w[0] * (x / (1 - x)) + w[1])
End

Function adsorpE_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (R / ln(x) + C)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return (w[0] / ln(x) + w[1])
End

Function adsorpF_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (C * (x / (1 - x))^R)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return (w[1] * (x / (1 - x))^w[0])
End

Function adsorpG_ff2(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (C - R * ln(1 - x))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = R
	//CurveFitDialog/ w[1] = C

	return (w[1] - w[0] * ln(1 - x))
End

// JW 070111
// This function can't work! It lacks w[0].
Function/D adsorpG_ff7(w, x):FitFunc
        Wave/D w; Variable/D x

	return(w[1] + (w[2] + w[3] * x) * (tanh(w[4] * (x - w[5])) + w[6]))
End

// temperature sensors can give Kelvin temperature versus electrical resistance as :
Function tempKelvinFromRes_ff4(w,Res) : FitFunc
	Wave w
	Variable Res

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(Res) = (1/(a + b * (Log(Res)) + c * (Log(Res))^2 + d * (Log(Res))^3))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ Res
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b
	//CurveFitDialog/ w[2] = c
	//CurveFitDialog/ w[3] = d

	return (1/(w[0] + w[1] * (Log(Res)) + w[2] * (Log(Res))^2 + w[3] * (Log(Res))^3))
End

// SIGMOIDS
// Basic power sigmoid
//  Alan Saul <SAUL@vms.cis.pitt.edu>
Function Sigmoid_ff3(w,xx) : FitFunc
	Wave w
	Variable xx

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Variable/D tmp
	//CurveFitDialog/ tmp=x50^e+xx^e
	//CurveFitDialog/ f(xx) = A*xx^e/tmp
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ xx
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = e
	//CurveFitDialog/ w[2] = x50

	Variable/D tmp
	tmp=w[2]^w[1]+xx^w[1]
	return w[0]*xx^w[1]/tmp
End

// This tanh function is the solution to the differential equation x'=x(1-x).
// It comes up in chemical waves or other such reaction-diffusion equations. 
//  Alan Saul <SAUL@vms.cis.pitt.edu>
Function tanh_ff3(w,xx) : FitFunc
	Wave w
	Variable xx

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(xx) = A/(1+exp(-r50*(xx-x50)))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ xx
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = r50
	//CurveFitDialog/ w[2] = x50

	return w[0]/(1+exp(-w[1]*(xx-w[2])))
End

// PEAK FUNCTIONS
// Voigt Approximation
// For w[4]==1, this is a Lorentzian, and for w[4] -> infinity it is a Gaussian.
// 	(actually for w[4]>50, it is really close to a Gaussian already).
// For this function, center = w[2]
//   Full Width at Half Maximum= 2*w[3]*sqrt((2^(1/w[4])-1)*w[4])
// For a Gaussian,  FWHM = 2*w[4]*sqrt(ln(2))
// For a Lorentzian, FWHM = 2*sqrt(w[4])
// zzt@ornl.gov (Jon Tischler)
Function Pearson_ff5(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = Y0+A / (  1 + (x-x0)^2/shape/W^2  )^shape
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = Y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = W
	//CurveFitDialog/ w[4] = shape

	return w[0]+w[1] / (  1 + (x-w[2])^2/w[4]/w[3]^2  )^w[4]
End

// Difference of Gaussians
//  Alan Saul <SAUL@vms.cis.pitt.edu>
Function DoG_ff4(w,xx) : FitFunc
	Wave w
	Variable xx

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Variable/D center,surround
	//CurveFitDialog/ center=Ac*exp(-0.5*(xx/Wc)^2)
	//CurveFitDialog/ surround=As*exp((-0.5*xx/Ws)^2)
	//CurveFitDialog/ f(xx) = center-surround
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ xx
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = Ac
	//CurveFitDialog/ w[1] = Wc
	//CurveFitDialog/ w[2] = As
	//CurveFitDialog/ w[3] = Ws

	Variable/D center,surround
	center=w[0]*exp(-0.5*(xx/w[1])^2)
	surround=w[2]*exp((-0.5*xx/w[3])^2)
	return center-surround
End
