# StatsStudentPDF

StatsStudentCDF
V-979
number of runs is 5 or more. This probability applies to either positive or negative differences and should 
be divided by two if a specific sign is selected.
References
Bradley, J.V., Distribution-Free Statistical Tests, Prentice Hall, Englewood Cliffs, New Jersey, 1968. 
 P.S., Distribution of sample arrangements for runs up and down, Annals of Mathematical Statistics, 17, 24-
33, 1946.
Wallis, W.A., and G.H. Moore, A significance test for time series, J. Amer. Statist. Assoc., 36, 401-409, 1941.
Young, L.C., On randomness in ordered sequences, Annals of Mathematical Statistics, 12, 153-162, 1941.
See, in particular, Chapter 25 of:
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsNPNominalSRTest and 
StatsRunsCDF.
StatsStudentCDF 
StatsStudentCDF(t, n)
The StatsStudentCDF function returns the Student (uniform) cumulative distribution function
where n>0 is degrees of freedom and is the incomplete beta function betai.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsStudentPDF and 
StatsInvStudentCDF functions.
StatsStudentPDF 
StatsStudentPDF(t, n)
The StatsStudentPDF function returns the Student (uniform) probability distribution function
where n>0 is degrees of freedom and B() is the beta function.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsStudentCDF and 
StatsInvStudentCDF functions.
F(t,n) =
1
2 1+ I
n
2 , 1
2;1



  I
n
2 , 1
2;
n
n + t 2










t > 0
1
2 1+ I
n
2 , 1
2;
n
n + t 2



  I
n
2 , 1
2;1










t < 0
1
2
t = 0


 
 
 

 
 
 
 
f (t,n) =
n
n + t 2




(n+1)/2
nB n
2 , 1
2




.
