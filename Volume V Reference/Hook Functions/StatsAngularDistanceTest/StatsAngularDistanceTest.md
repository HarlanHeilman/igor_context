# StatsAngularDistanceTest

StartMSTimer
V-906
StartMSTimer 
StartMSTimer
The StartMSTimer function creates a new microsecond timer and returns a timer reference number.
Details
You can create up to ten different microsecond timers using StartMSTimer. A valid timer reference number 
is a number between 0 and 9. If StartMSTimer returns -1, there are no free timers available. StartMSTimer 
works in conjunction with StopMSTimer.
See Also
StopMSTimer, ticks, DateTime
Static 
Static constant objectName = value
Static strconstant objectName = value
Static Function funcName()
Static Structure structureName
Static Picture pictName
The Static keyword specifies that a constant, user-defined function, structure, or Proc Picture is local to the 
procedure file in which it appears. Static objects can only be used by other functions; they cannot be 
accessed from macros; they cannot be accessed from other procedure files or from the command line.
See Also
Static Functions on page IV-105, Proc Pictures on page IV-56, and Constants on page IV-51.
StatsAngularDistanceTest 
StatsAngularDistanceTest [flags][srcWave1, srcWave2, srcWave3…]
The StatsAngularDistanceTest operation performs nonparametric tests on the angular distance between sample 
data and reference directions for two or more samples in individual waves. The angular distance is the shortest 
distance between two points on a circle (in radians). Specify the sample waves using /WSTR or by listing them 
following the flags. Set reference directions with /ANG, /ANGW, or the sample mean direction.
Flags
/ALPH=val
Sets the significance level (default 0.05).
/ANG={d1, d2} 
Sets reference directions (in radians) for two samples; for more than two samples use 
/ANGW.
/ANGM
Computes the mean direction of each sample and uses it as the reference direction.
/ANGW=dWave
Sets reference directions (in radians) for more than two samples using directions in 
dWave, which must be single or double precision.
/APRX=m
Controls the approximation method for computing the P-value in the case of two 
samples (Mann-Whitney Wilcoxon). See StatsWilcoxonRankTest for more details. 
The default value is 0, which may require long computation times if your sample size 
is large. Use /APRX=1 if you have a large sample and you expect ties in the data.
/Q
No results printed in the history area.
/T=k
Displays results in a table. k specifies the table behavior when it is closed.
k=0:
Normal with dialog (default).
k=1:
Kills with no dialog.
k=2:
Disables killing.
