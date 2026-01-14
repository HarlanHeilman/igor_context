# StatsFriedmanCDF

StatsFCDF
V-930
See Also
Chapter III-12, Statistics for a function and operation overview; StatsExpCDF and StatsInvExpCDF. 
StatsFCDF 
StatsFCDF(x, n1, n2)
The StatsFCDF function returns the cumulative distribution function for the F distribution with shape 
parameters n1 and n2
where Betai is the incomplete beta function.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFPDF and StatsInvFCDF.
StatsFPDF 
StatsFPDF(x, n1, n2)
The StatsFPDF function returns the probability distribution function for the F distribution with shape 
parameters n1 and n2
See Also
Chapter III-12, Statistics for a function and operation overview; StatsFCDF and StatsInvFCDF.
StatsFriedmanCDF 
StatsFriedmanCDF(x, n, m, method, useTable)
The StatsFriedmanCDF function returns the cumulative probability distribution of the Friedman 
distribution with m rows and n columns. The exact Friedman distribution is computationally intensive, 
taking on the order of (n!)m iterations. You may be able to use a range of precomputed exact values by 
passing a nonzero value for useTable, which will use method only if the value is not in the table. For large m, 
consider using the Chi-squared or the Monte-Carlo approximations. To abort execution, press the User 
Abort Key Combinations.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsInvFriedmanCDF and 
StatsFriedmanTest.
method
What It Does
0
Exact computation.
1
Chi-square approximation.
2
Monte-Carlo approximation.
3
Use built-table only and return NaN if not in table.
F(x;n1,n2) = 1 Betai n2
2 , n1
2 ,
n2
n2 + n1x
 


 ,
f (x;n1,n2) =
 n1 + n2
2



 
n1
n2



 
n1
2
x
n1
2 1
 n1
2



  n2
2



 1+ n1x
n2



 
n1 +n2
2
.
