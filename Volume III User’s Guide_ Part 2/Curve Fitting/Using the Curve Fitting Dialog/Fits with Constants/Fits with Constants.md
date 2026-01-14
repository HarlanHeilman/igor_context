# Fits with Constants

Chapter III-8 — Curve Fitting
III-189
In addition to the fact that the graphed fit curve doesn't follow the data points, the estimated uncertainty 
for the fit coefficients is unreasonably large.
The solution is to provide your own initial guesses. Click the Coefficients tab and choose Manual Guesses 
in the menu in the upper-right.
The Initial Guesses column in the Coefficients list is now available for you to type your own initial guesses, 
including a negative value for invTau. In this case, we might enter the following initial guesses:
y0
0
A
2
invTau-
3
In response, Igor generates some extra commands for setting the initial guesses and this time the fit works 
correctly:
•K0 = 0; K1 = 2; K2 = -3;
•CurveFit/G exp RisingExponential /D
Fit converged properly
fit_RisingExponential= W_coef[0]+W_coef[1]*exp(-W_coef[2]*x)
W_coef={-0.81174,2.2996,-2.8742}
V_chisq= 15.6292;V_npnts= 20;V_numNaNs= 0;V_numINFs= 0;
V_startRow= 0;V_endRow= 19;
W_sigma={0.798,0.41,0.171}
Coefficient values ± one standard deviation
y0 =-0.81174 ± 0.798
A =2.2996 ± 0.41
invTau=-2.8742 ± 0.171
It may well be that finding a set of initial guesses from scratch is difficult. Automatic guesses might be a 
good starting point which will provide adequate initial guesses when modified. For this the dialog provides 
the Only Guess mode.
When Only Guess is selected, click Do It to create the automatic initial guesses, and then stop without trying 
to do the fit. Now, when you bring up the Curve Fitting dialog again, you can choose the coefficient wave 
created by the auto guess (W_coef if you chose _default_ in the Coefficient Wave menu). Choosing this 
wave will set the initial guesses to the automatic guess values. Now choose Manual Guesses and modify 
the initial guesses. The Graph Now button may help you find good initial guesses (see Coefficients Tab for 
a User-Defined Function on page III-192).
Fits with Constants
A few of the built-in fit functions include constants that are not varied during the fit. They enter only to pro-
vide, for instance, a constant X offset to improve numerical stability. One such built-in fit function is the 
exp_XOffset fit function. It fits this equation:
Here, y0, A and tau are fit coefficients - they are varied during iterative fitting, and their final values are the 
solution to the fit. On the other hand, x0 is a constant - it is not varied, rather you give it any value you wish 
as part of the fit setup. In the case of the exp_XOffset fit function, if you do not set it yourself, it will be set 
by default to the minimum X value in your input data. For fits to data far from the origin, this improves 
numerical stability. Naturally, it affects the value of A in the final solution.
In the Curve Fitting dialog, when you select a built-in fit function that uses a constant, an additional edit 
box appears below the fit function menu where you can set the value of the constant. Setting it to the default 
value Auto causes Igor to set the constant to some reasonable value based on your input data.
y0
A
x x0
–

----------




exp
+
