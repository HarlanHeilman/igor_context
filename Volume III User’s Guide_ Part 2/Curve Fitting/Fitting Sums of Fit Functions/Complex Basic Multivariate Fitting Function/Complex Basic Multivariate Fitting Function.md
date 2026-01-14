# Complex Basic Multivariate Fitting Function

Chapter III-8 — Curve Fitting
III-248
String/G root:myDataFolder:holdStr="1"
String myFunctions="{exp, expTerm1}"
myFunctions+="{exp, expTerm2, hold=root:myDataFolder:holdStr}"
myFunctions+="{exp, expTerm3, hold=root:myDataFolder:holdStr}"
FuncFit {string = myFunctions} expSumData/D 
Fitting with Complex-Valued Functions
Prior to Igor Pro 9.00, to fit complex-valued functions to complex-valued data required writing a real-
valued fit function that used a special organization of the data to pack real and imaginary parts into a single 
real-valued wave. Now Igor supports fitting to complex-valued fitting functions directly.
The basic requirement for fitting complex-valued functions is to write a fit function that returns a complex 
result. Igor supports the traditional format for a user-defined fit function (see Format of a Basic Fitting 
Function on page III-251) and all-at-once format (All-At-Once Fitting Functions on page III-256), but the 
return type of a basic fit function or the Y wave in an all-at-once fit function must be complex. Complex 
fitting functions are not supported by structure fit functions or by the sum-of-fit-functions format.
No Dialog Support for Complex Fitting
The Curve Fitting dialog does not allow you to select complex waves, or fit functions that return complex 
values. It may be possible to use a real-valued function and waves to set up a fit in the dialog, then click the 
To Cmd Line button to copy the generated command to the command line where you can edit the com-
mand. It's probably easier to read the reference documentation for the FitFunc operation and simply 
compose a command.
Complex Basic Fitting Function
The basic format for a complex-valued function looks like this:
Function/C F(Wave w, Variable xx) : FitFunc
<body of function>
<return statement>
End
The /C in "Function/C" tells Igor that the function returns a complex value. As shown above, the function 
takes a real-valued coefficient wave and a real-valued independent variable. If your particular function 
needs the coefficient wave and/or independent variable to be complex-valued, add /C to the parameter dec-
laration:
Function/C F(Wave/C w, Variable/C xx) : FitFunc
<body of function>
<return statement>
End
We show here both the coefficient wave and the independent variable being complex; either one or both 
can be complex.
If you specify a complex independent variable, then you must supply a complex-valued X wave. Since 
Igor's wave scaling cannot be complex, if your fitting function requires a complex independent variable 
then you must have a separate X wave as input to the FitFunc operation.
Complex Basic Multivariate Fitting Function
As with normal real-valued fitting functions, you can write multivariate fitting functions that return 
complex values:
Function/C F(Wave w, Variable x1, Variable x2) : FitFunc
<body of function>
<return statement>
End
