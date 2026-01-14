# StatsCMSSDCDF

StatsCMSSDCDF
V-922
Details
The nonparametric paired-sample test (/NPR) is Moore’s test for paired angles applied in second order 
analysis. The input can consist of one or two column waves. When both waves contain a single column the 
operation proceeds as if all the vector length were identically 1. The Moore statistic (H0  pair equality) is 
computed and compared to the critical value from the Moore distribution (see StatsInvMooreCDF).
The nonparametric second-order two-sample test (/NSOA) consists of pre-processing where the grand 
mean is subtracted from the two inputs followed by application of Watson’s U2 test 
(StatsWatsonUSquaredTest) with H0 implying that the two samples came from the same population. The 
results of this test are stored in the wave W_WatsonUtest.
The parametric paired-sample test (/PPR) is due to Hotelling. In this test the input should consist of both angular 
and vector length data. The test statistic is compared with a critical value from the F distribution (StatsInvFCDF).
The parametric second order two-sample test (/PSOA) is an extension of Hotelling one-sample test to 
second order analysis where an F-like statistic is computed corresponding to H0 of equal mean angles.
References
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsInvMooreCDF, 
StatsWatsonUSquaredTest, and StatsInvFCDF.
StatsCMSSDCDF 
StatsCMSSDCDF(C, n)
The StatsCMSSDCDF function returns the cumulative distribution function of the C distribution (mean 
square successive difference), which is
where
The distribution (C>0) can then be expressed as
/PSOA
Performs parametric second order analysis of two samples. The input waves must 
each contain two columns.
/Q
No information printed in the history area.
/T= k
/Z
Ignores any errors.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
f (C,n) =
(2m + 2)
a22m+1 (m +1)
[
]
2 1 C 2
a2



 
m
,
a2 =
n2 + 2n 12
(
) n  2
(
)
n3 13n + 24
(
)
,
m =
n4  n3 13n2 + 37n  60
(
)
2 n3 13n + 24
(
)
.
