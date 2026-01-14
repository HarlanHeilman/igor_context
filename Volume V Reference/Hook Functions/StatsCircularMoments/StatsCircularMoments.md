# StatsCircularMoments

StatsCircularMoments
V-918
References
Zar, J.H., Biostatistical Analysis, 4th ed., 929 pp., Prentice Hall, Englewood Cliffs, New Jersey, 1999.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsCircularMoments, 
StatsInvMooreCDF, and StatsInvFCDF.
StatsCircularMoments 
StatsCircularMoments [flags] srcWave
The StatsCircularMoments operation computes circular statistical moments and optionally performs 
angular uniformity tests for the data in srcWave. The extent of the calculation is determined by the requested 
moment. The default results are stored in the W_CircularStats wave in the current data folder and are 
optionally displayed in a table. Additional results are listed under the corresponding flags.
Flags
/ALPH=alpha
Sets an alpha value for computing confidence intervals (default is 0.05).
/AXD=p
Designates the input as p-axial data. For example, if the input represents undirected 
lines then p =2 and the operation multiplies the angles by a factor p (after shifting 
/ORGN and accounting for /CYCL). It does not back-transform the mean or median 
axis.
/CYCL=cycle
Specifies the length of the data cycle. You do not need to do so if you are using one of 
the built-in modes, but this is still a useful option, as for setting the length of a 
particular month when using /MODE=5.
/GRPD={start, delta}
Computes circular statistics for grouped data. In this case srcWave contains 
frequencies or the number of events that belong to a particular angle group. There are 
as many groups as there are elements in srcWave. The first group is centered at start 
radians and each consecutive group is centered delta radians away. You must set both 
the start and delta to sensible values. srcWave may contain NaNs but it is an error if all 
values are NaN. The only other flags that work in combination with this flag are /Q, 
/T, and /Z.
/KUPR[=k]
Tests the uniformity of a circular distribution of ungrouped data using the Kuiper 
statistic. The data are converted into a set {xi} by normalizing the input angles to the 
range [0,1], ranking the results then using the two quantities D+ and D- to compute the 
Kuiper statistic. Use k=0 for Fisher's version:
,
Use k=1, added in Igor Pro 8.00, for the more common definition of the Kuiper 
statistic:
Here
,
,
and n is the number of valid points in srcWave. You can find the results in the wave 
W_CircularStats under row label “Kuiper V” and “Kuiper CDF(V)”. See Fisher and 
Press et al. for more information.
V= D+ + D
(
)
n+0.155+0.24/ n
(
)
V = D+ + D−
(
).
D+= Max of: 1
n -x0, 2
n -x1,... ,1-xn-1
D-= Max of: x0, x
1- 1
n
,... , x
n-1- n-1
n
,

StatsCircularMoments
V-919
 /LOS
Computes Linear Order Statistics by sorting the angle values from small to large, 
dividing each angle by 2 and shifting the origin so that the output range is [0,1]. The 
results are stored in the wave W_LinearOrderStats in the current data folder. The X 
scaling of the wave is set so that the offset and the delta are 1/(n+1) where n is the 
number of non-NaN points in the input.
/M=moment
Computes specified moments. By default, it computes the second order moments as 
well as skewness, kurtosis, median, and mean deviation. Use /M=1 for the first 
moment. For higher moments, both the specified moment and all the default 
quantities are computed.
/MODE=mode
/ORGN=origin
Specifies the origin of the data (the value corresponding to an angle of zero degrees). 
For example, if you are using Igor date format and you want the origin to be the first 
second in year YYYY, use /ORGN=(date2secs(YYYY,1,1)).
/Q
No results printed in the history area.
/RAYL[=meanDirection]
Performs the Rayleigh test for uniformity. If the “alternative” mean direction is 
specified (in radians), the test computes
r0Bar=rBar cos(tBar-meanDirection)
and then computes the significance probability of r0Bar. The null hypothesis H0 
corresponds to uniformity. It is rejected when r0Bar is too large. If the mean direction 
is not specified then r0Bar is rBar which is always calculated as part of the first 
moments so the operation only computes the relevant significance probability (P-
Value). The critical values for both cases are computed according to Durand and 
Greenwood.
/SAW
Saves the translated angle data in the wave W_AngleWave in the current data folder.
/T=k
The table is associated with the test and not with the data. If you repeat the test, it will 
update the table with the new results unless you moved the output wave to a different 
data folder. If the named table exists, but does not display the output wave from the 
current data folder, the table is renamed and a new table is created.
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
Handles special types of data.
mode
Data in srcWave
0
Angles in radians [0,2]
1
Angles in radians [-, ]
2
Angles in degrees [0,360]
3
Angles in degrees [-180,180]
4
Igor date format for one year cycles.
5
Igor date format for one month cycles.
6
Igor date format for one week cycles.
7
Igor date format for one day cycles.
8
Igor date format for one hour cycles.
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.

StatsCircularMoments
V-920
Details
StatsCircularMoments is equivalent to WaveStats but it applies to circular data, which are distributed on 
the perimeter of a circle representing some period or cycle. If your data are not described by one of the built-
in modes, you can specify the value of the origin (/ORGN), which is mapped to zero degrees and the size 
of a cycle or period.
When you use Igor date formats with the built-in modes for dates, the default origin is set to zero. The 
default cycle in the case of Mode 4 is 366. This is done in order to handle both leap and nonleap years. 
Similarly, Mode 5 uses a cycle of 31 days. Note that the internal conversion from Igor date to (year, month, 
day) is independent of the cycle specification and is therefore not affected by this choice. You should use 
the /CYCL flag if you use one of these modes with a fixed size of year or month.
The parameters listed below are computed and displayed (see row labels) in the table. Here N is the number 
of valid (non-NaN) angles {i}
median is the value which minimizes
 
mean deviation = The minimum of the last equation when   median.
Higher order moments are denoted with the moment number such that t3Bar is the uncentered third 
moment of the angle while primed quantities are relative to mean direction tBar. Using this notation
C=
cos i
i=1
n

S=
sin i
i=1
n

R =
C 2 + S2
cBar = C = C n
sBar = S = S n
rBar = R = R n
tBar =  =
atan(S C)
S > 0,C > 0
atan(S C) + 
C < 0
atan(S C) + 2
S < 0,C > 0



V = 1 R
ν =
−2ln(1−V )
d() =   1
n
  i 
i=1
n

 
2 = 1
n
cos2 i 
(
)
i=1
n

circulardispersion = 1 2
2R
2
