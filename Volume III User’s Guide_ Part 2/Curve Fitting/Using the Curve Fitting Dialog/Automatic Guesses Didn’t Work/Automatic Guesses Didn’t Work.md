# Automatic Guesses Didn’t Work

Chapter III-8 — Curve Fitting
III-187
Now when we click Do It, the fit is recalculated with a held at zero so that the line passes through the origin. 
Residuals are calculated and added to the graph:
Note that the line on the graph doesn’t cross the vertical axis at zero, because the horizontal axis doesn’t 
extend to zero.
Holding a at zero, the result of the fit printed in the history is:
•K0 = 0;
•CurveFit/H="10" line LineYData /X=LineXData /D /R
fit_LineYData= W_coef[0]+W_coef[1]*x
Res_LineYData= LineYData[p] - (W_coef[0]+W_coef[1]*LineXData[p])
W_coef={0,2.915}
V_chisq= 18.2565; V_npnts= 20; V_numNaNs= 0; V_numINFs= 0;
V_startRow= 0; V_endRow= 19; V_q= 1; V_Rab= 0; V_Pr= 0.956769;
V_r2= 0.906186;
W_sigma={0,0.0971}
Coefficient values ± one standard deviation
a
=
0 ± 0
b
=
2.915 ± 0.0971
Automatic Guesses Didn’t Work
Most built-in fits will work just like the line fit. You simply choose a function from the Function menu, 
choose your data wave (or waves if you have both X and Y waves) and select output options on the Output 
Options tab. For built-in fits you don’t need the Coefficients tab unless you want to hold a coefficient.
In a few cases, however, automatic guesses don’t work. Then you must use the Coefficient tab to set your 
own initial guesses. One important case in which this is true is if you are trying to fit a growing exponential, 
, where b is positive.
Here are commands to create an example for this section. Once again, you may wish to enter these com-
mands on the command line to follow along:
Make/N=20 RisingExponential
SetScale/I x 0,1,RisingExponential
SetRandomSeed 0.5
RisingExponential = 2*exp(3*x)+gnoise(1)
Display RisingExponential
ModifyGraph mode=3,marker=8
10
8
6
4
2
3.5
3.0
2.5
2.0
1.5
1.0
0.5
210
-1
-2
The /H flag shows that one or more coefficients are held.
a is zero because it was held.
y
aebx
=

Chapter III-8 — Curve Fitting
III-188
These commands make a 20-point wave, set its X scaling to cover the range from 0 to 1, fill it with exponen-
tial values plus a bit of noise, and make a graph:
The first-cut trial to fitting an exponential function is to select exp from the Function menu and the Rising-
Exponential wave in the Y Data menu (if you are continuing from the previous section, you may need to go 
to the Coefficients tab and un-hold the y0 coefficient, and to the Output Options tab and de-select _auto 
trace_ in the Residual menu). Automatic guesses assume that the exponential is well described by a nega-
tive coefficient in the exponential, so the fit doesn’t work:
•CurveFit exp RisingExponential /D
Fit converged properly
fit_RisingExponential= W_coef[0]+W_coef[1]*exp(-W_coef[2]*x)
W_coef={108.87,-113.32,0.32737}
V_chisq= 423.845;V_npnts= 20;V_numNaNs= 0;V_numINFs= 0;
V_startRow= 0;V_endRow= 19;
W_sigma={255,252,0.863}
Coefficient values ± one standard deviation
 
y0 =108.87 ± 255
 
 
A =-113.32 ± 252
 
invTau=0.32737 ± 0.863
40
30
20
10
1.0
0.8
0.6
0.4
0.2
0.0
40
30
20
10
0
1.0
0.8
0.6
0.4
0.2
0.0
