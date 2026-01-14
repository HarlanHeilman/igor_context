# StatsInvFriedmanCDF

StatsInvExpCDF
V-938
StatsEValueCDF, StatsEValuePDF, StatsGEVCDF, StatsGEVPDF
StatsInvExpCDF 
StatsInvExpCDF(cdf, , )
The StatsInvExpCDF function returns the inverse of the exponential cumulative distribution function
It returns NaN for cdf <0 or cdf > 1.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsExpCDF and StatsExpPDF.
StatsInvFCDF 
StatsInvFCDF(x, n1, n2)
The StatsInvFCDF function returns the inverse of the F distribution cumulative distribution function for x 
and shape parameters n1 and n2. The inverse is also known as the percent point function.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFCDF and StatsFPDF.
StatsInvFriedmanCDF 
StatsInvFriedmanCDF(cdf, n, m, method, useTable)
The StatsInvFriedmanCDF function returns the inverse of the Friedman distribution cumulative distribution 
function of cdf with m rows and n columns. Use this typically to compute the critical values of the distribution
Print StatsInvFriedmanCDF(1-alpha,n,m,0,1)
where alpha is the significance level of the associated test.
The complexity of the computation of Friedman CDF is on the order of (n!)m. For nonzero values of useTable, 
searches are limited to the built-in table for distribution values. If n and m are not in the table the calculation 
may still proceed according to the method.
For large m and n, consider using the Chi-squared or the Iman and Davenport approximations. To abort 
execution, press the User Abort Key Combinations.
Precomputed tables use these values:
method
What It Does
0
Exact computation(slow, not recommended).
1
Chi-square approximation.
2
Monte-Carlo approximation (slow).
3
Use built-in table only and return a NaN if not in table.
Note:
Table values are different from computed values for both methods. Table values use more 
conservative criteria than computed values. Table values are more consistent with 
published values because the Friedman distribution is a highly irregular function with 
multiple steps of arbitrary sizes. The standard for published tables provides the X value 
of the next vertical transition to the one on which the specified P is found.
n
m
3
2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
4
2, 3, 4, 5, 6, 7, 8, 9
5
2, 3, 4, 5, 6
x = μ   ln 1 cdf
(
).
