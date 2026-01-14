# StatsCorrelation

StatsCorrelation
V-925
•
Mutual independence by testing if all three variables are independent of each other.
•
Partial dependence (rows) by testing if rows independent of columns and layers.
•
Partial dependence (columns) by testing if columns independent of rows and layers.
•
Partial dependence (layers) by testing if layers independent of rows and columns.
In each case you should compare the statistic with the critical value and reject H0 if the statistic exceeds or 
equals the critical value.
You should examine the table entries to determine if the Chi-square statistic is appropriate (if the frequency 
is smaller than 6 for /ALPH=0.05 you should consider computing the Fisher exact test).
V_flag will be set to -1 for any error and to zero otherwise.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsInvChiCDF.
StatsCorrelation 
StatsCorrelation(waveA [, waveB])
The StatsCorrelation function computes Pearson’s correlation coefficient between two real valued arrays of 
data of the same length. Pearson r is give by:
Here A is the average of the elements in waveA, B is the average of the elements of waveB and the sum is 
over all wave elements.
Details
If you use both waveA and waveB then the two waves must have the same number of points but they could 
be of different number type. If you use only the waveA parameter then waveA must be a 2D wave. In this 
case StatsCorrelation will return 0 and create a 2D wave M_Pearson where the (i,j) element is Pearson’s r 
corresponding to columns i and j.
Fisher’s z transformation converts Person’s r above to a normally distributed variable z:
with a standard error
You can convert between the two representations using the following functions:
Function pearsonToFisher(inr)
Variable inr
return 0.5*(ln(1+inr)-ln(1-inr))
End
Function fisherToPearson(inz)
Variable inz
return tanh(inz)
End
See Also
Correlate, StatsLinearCorrelationTest, and StatsCircularCorrelationTest.
r =
waveA[i] A
(
) waveB[i] B
(
)
i=0
n1

waveA[i] A
(
)
2
waveB[i] B
(
)
2
i=0
n1

i=0
n1

z = 1
2 ln 1+ r
1 r
 


 ,
 z =
1
n  3
.
