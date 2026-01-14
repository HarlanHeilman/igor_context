# Fitting to a User-Defined Function

Chapter III-8 — Curve Fitting
III-190
When you do a fit using a built-in fit function that uses a constant, the output includes the wave W_fitCon-
stants. Each element of this wave holds the value of one constant for the equation. At present, the wave will 
have just one element because there are no built-in fit functions that use more than one constant.
See Built-in Curve Fitting Functions on page III-206 for details on the constants used with specific fit func-
tions.
Fitting to a User-Defined Function
Fitting to a user-defined function is much like fitting to a built-in function, with two main differences:
•
You must define the fitting function.
•
You must supply initial guesses.
To illustrate the creation of a user-defined fit function, we will create a function to fit a log function: 
.
Creating the Function
To create a user-defined fitting function, click the New Fit Function button in the Function and Data tab of 
the Curve Fitting Dialog. The New Fit Function dialog is displayed:
You must fill in a name for your function, fill in the Fit Coefficients list with names for the coefficients, fill 
in the Independent Variables list with names for independent variables, and then enter a fit expression in 
the Fit Expression window.
The function name must conform to nonliberal naming rules. That means it must start with a letter, contain 
only letters, numbers or underscore characters, and it must be 255 or fewer bytes in length (see Object 
Names on page III-501). It must not be the same as the name of another object like a built-in function, user 
procedure, or wave name.
For the example log function, we enter “LogFit”:
y
C1
C
+
2
x

ln
=

Chapter III-8 — Curve Fitting
III-191
Press Tab to move to the first entry in the Fit Coefficient list. There is always one blank entry in the list where 
you can add a new coefficient name; since we haven’t entered anything yet, there is only one blank entry.
Each time you enter a name, press Return (Macintosh) or Enter (Windows). Igor accepts that name and makes 
a new blank entry where you can enter the next name. We enter C1 and C2 as the names:
Click in the first blank entry in the Independent Variables list. Most fit functions will require just a single 
independent variable. We choose to name our independent variable x: 
It is now time to enter the fit expression. You will notice that when you have entered a name in the Independent 
Variables list, some text is entered in the expression window. The return value of the fit function (the Y value in 
most cases) is marked with something like “f(x) = ”. If you had entered “temperature” as the independent vari-
able, it would say “f(temperature) = ”.
This “f() = “ text is required; otherwise the return value of the function will be unknown.
The fit expression is not an algebraic expression. It must be entered in the same form as a command on the 
command line. If you need help constructing a legal expression, you may wish to read Assignment State-
ments on page IV-4. The expression you need to type is simply the right-hand side of an assignment state-
ment. The log expression in our example will look like this:
Multiplication requires an explicit *.
The dialog will check the fit expression for simple errors. For instance, it will not make the Save Fit Function 
Now button available if any of the coefficients or independent variables are missing from the expression.
The dialog cannot check for correct expression syntax. If all the easily-checked items are correct, the Save 
Fit Function Now and Test Compile buttons are made available. Clicking either of them will enter a new 
function in the Procedure window and attempt to compile procedures. If you click the Save Fit Function 
Now button and compilation is successful, you are returned to the Curve Fitting dialog with the new func-
tion chosen in the Function menu.

Chapter III-8 — Curve Fitting
III-192
If compile errors occur, the compiler’s error message is displayed in the status box, and the offending part of 
your expression is highlighted. A common error might be to misspell a coefficient name somewhere in your 
expression. For instance, if you had typed CC1 instead of C1 somewhere you might see something like this:
Note that C1 appears in the expression. Otherwise, the dialog would show that C1 is missing.
When everything is ready to go, click the Save Fit Function Now button to construct a function in the Pro-
cedure window. It includes comments in the function code that identify various kinds of information for 
the dialog. Our example function looks like this:
Function LogFit(w,x) : FitFunc
WAVE w
Variable x
//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
//CurveFitDialog/ Equation:
//CurveFitDialog/ f(x) = C1+C2*log(x)
//CurveFitDialog/ End of Equation
//CurveFitDialog/ Independent Variables 1
//CurveFitDialog/ x
//CurveFitDialog/ Coefficients 2
//CurveFitDialog/ w[0] = C1
//CurveFitDialog/ w[1] = C2
return w[0]+w[1]*log(x)
End
You shouldn’t have to deal with the code in the Procedure window unless your function is so complex that 
the dialog simply can’t handle it. You can look at User-Defined Fitting Functions on page III-250 for details 
on how to write a fitting function in the Procedure window.
Having entered the fit expression correctly, click the Save Fit Function Now button, which returns you to 
the main Curve Fitting dialog. The Function menu will now have LogFit chosen as the fitting function.
Coefficients Tab for a User-Defined Function
To fit a user-defined function, you will need to enter initial guesses in the Coefficients tab.
Having created a user-defined fitting function (or simply having selected a preexisting one) you will find 
that the error message window at the bottom of the dialog now states: “You have selected a user-defined 
fit function so you must enter an initial guess for every fit coefficient. Go to the Coefficients Tab to do this.”
When you have selected a user-defined fitting function, the Initial Guess column of the Coefficients List is 
available. You must enter a number in each row. Some functions may be difficult to fit; in such a case the 
initial guess may have to be pretty close to the final solution.
To help you find good initial guesses, the Coefficients tab includes the Graph Now button. This button will add 
a trace to the top graph showing your fitting function using the initial guesses you have entered. For instance:

Chapter III-8 — Curve Fitting
III-193
You can change the values in the initial guess column and click the Graph Now button as many times as 
you wish. The trace will be updated with the changes each time.
The Graph Now button works as describe in The Destination Wave on page III-196, with one exception: if 
you selected _none_ in the Destination pop-up menu of the Output Options tab, the Graph Now button 
works as if you selected _auto_. The Graph Now button honors your choices for destination wave style, and 
it makes a new wave if you selected _New Wave_. Unless you change the destination wave settings before 
clicking Do It, the wave set by Graph Now will be overwritten by the fit.
On the Coefficients tab you have the option of selecting an “epsilon” wave. An epsilon wave contains one 
epsilon value for each point in your coefficients wave. By default the Epsilon menu is set to _none_ indicat-
ing that the epsilon values are set to the default values.
Each epsilon value is used to calculate partial derivatives with respect to the fit coefficients. The partial 
derivatives are used to determine the search direction for coefficients that give the smallest chi-square.
In most cases the epsilon values are not critical. However, you can supply your own if you have reason to 
believe that the default epsilon values are not providing acceptable partial derivatives (sometimes a singu-
lar matrix error can be avoided by using custom epsilon values). To specify epsilon values, either select a 
pre-existing wave from the Epsilon Wave menu, or select _New Wave_. Only waves having a number of 
points equal to the number of fit coefficients are shown in the menu. Either choice causes the Epsilon 
column to be shown in the Coefficients list, where you can enter values for epsilon.
If you select a wave from the Epsilon menu, the values in that wave are entered in the list. If you select _New 
Wave_, the dialog generates commands to create an epsilon wave and fill it with the values in the Epsilon 
column.
For more information about the epsilon wave and what it does, see The Epsilon Wave on page III-267.
