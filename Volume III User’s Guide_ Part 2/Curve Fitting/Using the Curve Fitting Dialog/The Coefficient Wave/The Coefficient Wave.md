# The Coefficient Wave

Chapter III-8 — Curve Fitting
III-195
The Coefficient Wave
When you fit to a user-defined function, your initial guesses are transmitted to the curve fitting operation 
via a coefficient wave. The coefficients that result from the fit are output in a coefficient wave no matter 
what kind of function you select. For the most part, the Curve Fitting dialog hides this from you.
When you create a user-defined function, the dialog creates a function that takes a wave as the input con-
taining the fit coefficients. But through special comments in the function code, the dialog gives names to 
each of the coefficients. A built-in function has names for the coefficients stored internally. Using these 
names, the dialog is able to hide from you some of the complexities of using a coefficient wave.
In the history printout following a curve fit, the coefficient values are reported both in the form of a wave 
assignment, using the actual coefficients wave, and as a list using the coefficient names. For instance, here is 
the printout from the example user-defined fit earlier (Fitting to a User-Defined Function on page III-190):
•FuncFit LogFit W_coef logData /D
 Fit converged properly
 fit_logData= LogFit(W_coef,x)
 W_coef={1.0041,0.99922}
 V_chisq= 0.00282525; V_npnts= 30; V_numNaNs= 0; V_numINFs= 0;
 W_sigma={0.00491,0.00679}
 Coefficient values ± one standard deviation
 C1 =
1.0041± 0.491
 C2 =
0.99922± 0.679
The wave assignment version can be copied to the command line and executed, or it can be used as a 
command in a user procedure. The list version is easier to read.
You control how to handle the coefficients wave using the Coefficient Wave menu on the Coefficients tab. 
Here are the options.
Default
When _default_ is chosen it creates a wave called W_coef. For built-in fits this wave is used only for output. 
For user-defined fits it is also input. The dialog generates commands to put your initial guesses into the 
wave before the fit starts.
Explicit Wave
The Coefficient Wave menu lists any wave whose length matches the number of fit coefficients. If you select 
one of these waves, it is used for input and output from any fit.
When you choose a wave from the menu the data in the wave is used to fill in the Initial Guess column in 
the Coefficients list. This can be used as a convenient way to enter initial guesses. If you choose an explicit 
wave and then edit the initial guesses, the dialog generates commands to change the values in the selected 
coefficient wave before the fit starts. To avoid altering the contents of the wave, after selecting a wave with 
the initial guesses you want, you can choose _default_ or _New Wave_. The initial guesses will be put into 
the new or default coefficients wave.
New Wave
A variation on the explicit coefficients wave is _New Wave_. This works just like an explicit wave except 
that the dialog generates commands to make the wave before the fit starts, so you don’t have to remember 
to make it before entering the dialog. The wave is filled in with the values from the Initial Guess column.
The _New Wave_ option is convenient if you are doing a number of fits and you want to save the fit coef-
ficients from each fit. If you use _default_ the results of a fit will overwrite the results from any previous fit.
Errors
Estimates of fitting errors (the estimated standard deviation of the fit coefficients) are automatically stored 
in a wave named W_sigma. There is no user choice for this output.
Fit Coefficient values as a wave assignment.
Fit Coefficient sigmas as a wave assignment.
Fit Coefficient values and sigmas in a list using the coefficient names.
