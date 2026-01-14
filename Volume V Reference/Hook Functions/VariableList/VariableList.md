# VariableList

Variance
V-1066
Variance
Variance(inWave [, x1, x2 ] )
Returns the variance of the real-valued inWave. The function ignores NaN and INF values in inWave.
Parameters
inWave is expected to be a real-valued numeric wave. If inWave is a complex or text wave, Variance returns 
NaN.
x1 and x2 specify a range in inWave over which the variance is to be calculated. They are used only to locate 
the points nearest to x=x1 and x=x2 . The variance is then calculated over that range of points. The order of 
x1 and x2 is immaterial.
If omitted, x1 and x2 default to - and + respectively and the variance is calculated for the entire wave.
Details
The variance is defined by
where 
Examples
Make/O/N=5 test = p
SetScale/P x, 0, .1, test
// Print variance of entire wave
Print Variance(test)
// Print variance from x=0 to x=.2
Print Variance(test, 0, .2)
// Print variance for points 1 through 3
Variable x1=pnt2x(test, 1)
Variable x2=pnt2x(test, 3)
Print Variance(test, x1, x2)
See Also
mean, median, WaveStats, APMath
VariableList 
VariableList(matchStr, separatorStr, variableTypeCode [, dfr ])
The VariableList function returns a string containing a list of the names of global variables selected based 
on the matchStr and variableTypeCode parameters. The variables listed are all in the current data folder or the 
data folder specified by dfr.
Details
For a variable name to appear in the output string, it must match matchStr and also must fit the 
requirements of variableTypeCode. separatorStr is appended to each variable name as the output string is 
generated.
The name of each variable is compared to matchStr, which is some combination of normal characters and 
the asterisk wildcard character that matches anything. For example:
"*"
Matches all variable names.
var =
xi  x
(
)
2
i=1
n

n 1
x =
Xi
i=1
n

n
.
