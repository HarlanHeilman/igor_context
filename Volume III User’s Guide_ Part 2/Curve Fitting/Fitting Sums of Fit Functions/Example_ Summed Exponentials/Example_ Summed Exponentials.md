# Example: Summed Exponentials

Chapter III-8 — Curve Fitting
III-246
that you are not allowed to hold and constrain a fit coefficient simultaneously), and use "K4" for the ampli-
tude and "K5" for invTau.
Example: Summed Exponentials
This example fits a sum of three exponentials using the built-in exp fit function. For real work, we recom-
mend the exp_XOffset function; it handles data that’s not at X=0 better, and the decay constant fit coefficient 
is actually the decay constant. The exp fit function gives you the inverse of the decay constant.
First, make some fake data and graph it:
Make/D/N=1000 expSumData
SetScale/I x 0,1,expSumData
expSumData = 1 + exp(-x/0.5) + 1.5*exp(-x/.1) + 2*exp(-x/.01)+gnoise(.03)
Display expSumData
ModifyGraph mode=2,rgb=(1,4,52428)
The fake data was purposely made with a Y offset of 1.0 in order to illustrate how to handle the vertical 
offset terms in the fit function.
Next, we need to make a coefficient wave for each of the fit functions. In spite of the linear dependence 
between the vertical offset in each copy of the function, you must include all the fit coefficients in the coef-
ficient waves. Otherwise when the function is evaluated the fit won’t have all the needed information.
Make/D/O expTerm1 = {1, 1, 2}
Make/D/O expTerm2 = {0, 1.5, 10}
Make/D/O expTerm3 = {0, 2, 100}
Each of these lines makes one coefficient wave with three elements. The first element is y0, the second is 
amplitude, and the third is the inverse of the decay constant. Since the data is fake, we have a pretty good 
idea of the initial guesses!
To reflect the baseline offset of 1.0, the y0 coefficient for only the first exponential coefficient wave was set 
to 1. If y0 were set to 1.0 for all three, the offset would be 3.0.
Now we can do the fit. A FuncFit command with a list of fit functions and coefficient waves can be pretty long:
FuncFit {{exp, expTerm1},{exp, expTerm2, hold="1"},{exp, expTerm3, hold="1"}} 
expSumData/D
The entire list of functions is enclosed in braces and each fit function specification in the list is enclosed in 
braces as well. At a minimum you must provide a fit function and a coefficient wave for each function in 
the list, as was done here for the first exponential term.
The specification for each function can also contain various keywords; the second and third terms here 
contain the hold keyword in order to include a hold string. The string used will cause the fit to hold the y0 
coefficient for the second and third terms at zero. That prevents problems caused by linear dependence 
5
4
3
2
1.0
0.8
0.6
0.4
0.2
0.0
