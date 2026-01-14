# Problems with the Curve Fitting Dialog

Chapter III-8 — Curve Fitting
III-205
4.
Click the Coefficients tab (the error box at the bottom shows that we must enter initial guesses).
5.
Enter initial guesses: we set z0 to 0, A to 2, x0 to 0.5, y0 to -0.3, and width to 0.5.
6.
For our problem, residuals and destination aren’t really important since we just want to know the coor-
dinates of the spot center. We click Do It and get this in history:
FuncFit SimpleGaussian W_coef SpotZData /X={SpotXData,SpotYData} /D
Fit converged properly
fit_SpotZData= SimpleGaussian(W_coef,x,y)
Res_SpotZData= SpotZData[p] - SimpleGaussian(W_coef,SpotXData[p],SpotYData[p])
W_coef={1.9797,0.54673,-0.2977,0.19962,-0.0067009}
V_chisq= 3.06428;V_npnts= 300;V_numNaNs= 0;V_numINFs= 0;
V_startRow= 0;V_endRow= 299;
W_sigma={0.065,0.00559,0.00553,0.00529,0.00622}
Coefficient values ± one standard deviation
 A =1.9797 ± 0.065
 x0 =0.54673 ± 0.00559
 y0 =-0.2977 ± 0.00553
 w =0.19962 ± 0.00529
 z0 =-0.0067009 ± 0.00622
The output shows that the fit has determined that the center of the spot is {0.54697, -0.30557}.
Problems with the Curve Fitting Dialog
Occasionally you may find that things don’t work the way you expect when using the Curve Fitting dialog. 
Common problems are:
•
You can’t find your user-defined function in the Function menu.
This usually happens for one of two reasons: either your function is a multivariate function or it is 
an old-style function. The problem is solved by choosing Show Multivariate Functions or Show Old-
Style Functions from the Function menu on the Function and Data tab.
If you find that choosing Show Old-Style Functions makes your fit function appear, you may want 
to consider clicking the Edit Fit Function button, which makes the Edit Fit Function dialog appear. 
Part of the initialization for the dialog involves revising your fit function to make it conform to cur-
rent standards. While you’re there you can give your fit coefficients mnemonic names.
•
You get a message that “Igor can’t determine the number of coefficients…”.
This happens when you click the Coefficients tab when you are using an external function or a user-
defined function that is so complicated that the dialog can’t parse the function code to determine 
how many coefficients are required.
The only way to get around this is to choose an explicit coefficient wave (The Coefficient Wave on 
page III-195). The dialog will then use the number of points in the coefficient wave to determine the 
number of coefficients.
