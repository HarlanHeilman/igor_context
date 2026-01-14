# Fitting to an External Function (XFUNC)

Chapter III-8 — Curve Fitting
III-194
Making a User-Defined Function Always Available
Note that, because the fitting function is created in the Procedure window, it is stored as part of the exper-
iment file. That means that it will be available for fitting while you are working on the experiment in which 
it was created, but will not be available when you work on other experiment files.
You can make the fit function available whenever you start up Igor Pro. Make a new procedure window 
using the Procedure item under New in the Windows menu. Find the fit function in the Procedure window, 
select all the text from Function through End and choose Cut from the Edit menu. Paste the code into your 
new procedure window. Finally, choose Save Procedure Window from the File menu and save in"Igor Pro 
User Files/Igor Procedures" (see Igor Pro User Files on page II-31 for details). The next time you start Igor 
Pro you will find that the function is available in all your experiments.
Removing a User-Defined Fitting Function
To remove a user-defined fitting function that you don’t want any more, choose Procedure Window from 
the Windows menu. Find the function in the Procedure window (you can use Find from the Edit menu and 
search for the name of your function). Select all of the function definition text from the word “Function” 
through the word “End” and delete the text.
If you have followed the directions in the section above for making the function always available, find the 
procedure file in "Igor Pro User Files/Igor Procedures", remove it from the folder, and then restart.
User-Defined Fitting Function Details
The New Fit Function dialog is the easiest way to enter a user-defined fit function. But if your fit expression 
is very long, or it requires multiple lines with local variables or conditionals, the dialog can be cumbersome. 
Certain special situations may call for a format that is not supported by the dialog.
For a complete discussion of user-defined fit function formats and the uses for different formats, see User-
Defined Fitting Functions on page III-250.
Fitting to an External Function (XFUNC)
An external function, or XFUNC, is a function provided via an Igor extension or plug-in. A programmer 
uses the XOP Toolkit to build an XFUNC. You don’t need the toolkit to use one. An XFUNC must be 
installed before it can be used. See Igor Extensions on page III-511.
An XFUNC can speed up curve fitting greatly if your fitting function requires a great deal of computation. 
The speed of fitting is usually dominated by other kinds of overhead and the effort of writing an XFUNC 
is not justified.
Fitting to an external function is just like fitting to a user-defined function, except that the Curve Fitting 
dialog has no way to find out how many fit coefficients are required. When you switch to the Coefficients 
tab, you will see an alert telling you of that fact. The solution to this problem is to select a coefficient wave 
with the correct number of points. You must create the wave before entering the Curve Fitting dialog.
When you select a coefficient wave the contents of the wave are used to build the Coefficients list. The wave 
values are entered in the Initial Guess column. If you change an initial guess, the dialog will generate the 
commands necessary to enter the new values in the wave.
The Coefficient Wave menu normally shows only those waves whose length is the same as the number of fit 
coefficients required by the fitting function. When you choose an XFUNC for fitting, the menu shows all waves. 
You have to know which one to select. We suggest using a wave name that identifies what the wave is for.
Igor doesn’t know about coefficient names for an XFUNC. Coefficient names will be derived from the name 
of the coefficient wave you select. That is, if your coefficient wave is called “coefs”, the coefficient names 
will be “coefs_0”, “coefs_1”, etc.
Of course, implementing your function in C or C++ is more time-consuming and requires both the XOP 
Toolkit from WaveMetrics, and a software development environment. See Creating Igor Extensions on 
page IV-208 for details on using the XOP Toolkit to create your own external function.
