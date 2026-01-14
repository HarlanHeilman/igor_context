# MultiTaperPSD

MultiTaperPSD
V-672
MultiTaperPSD
MultiTaperPSD [flags] srcWave
The MultiTaperPSD operation estimates the power spectral density of srcWave using Slepian (DPSS) tapers.
The MultiTaperPSD operation was added in Igor Pro 7.00.
Flags
/A
Uses Thomson's adaptive algorithm. In this case the operation also creates the wave 
W_MultiTaperDF that contains the effective degrees of freedom. For each frequency 
of the PSD the algorithm is expected to converge within few iterations. When it fails 
to converge, the operation prints in the history the total number of frequencies where 
it did not converge while the actual output contains the last iteration estimate.
/DB
Scale the PSD results as 10*log10(spectralEst(f)).
/DBF=f0
Scale the PSD results as 10*log10(spectralEst(f)/spectralEst(f0)) where 
f0 must be in the range [0,0.5/DimDelta(srcWave,0)].
/DEST=destWave
Saves the PSD estimate in a wave specified by destWave. The destination wave is 
created or overwritten if it already exists.
Creates a wave reference for the destination wave in a user function. See Automatic 
Creation of WAVE References on page IV-72 for details.
If you omit /DEST the operation saves the resulting spectral estimate in the wave 
W_MultiTaperPSD in the current data folder.
/F
Computes F-test statistic for each output frequency. The results are stored in the wave 
W_MultiTaperF.
If /DEST is also used then the F-test results are stored in the same data folder as 
destWave. Otherwise W_MultiTaperF is created in the current data folder.
The statistic is a variance ratio, of the background and the power at the specific 
frequency. Since the PSDs of the background and the line are assumed to be 
distributed as Chi-squared with 2 and 2*nTapers-2 degrees of freedom respectively, 
the relevant critical value for computing confidence intervals can be obtained from:
StatsInvFCdf(percentSignificance/100,2,2*nTapers-2)
/NOR=N
Sets the normalization factor that is used to multiply each element of the output. For 
example, if you want to normalize the output such that the sum of the PSD estimate 
matches the variance of the input use /NOR=2/(np*np) where np is the number of 
points in srcWave.
/NTPR=nTapers
Specifies the number of Slepian tapers to be used. If you do not specify a number of 
tapers, the operation uses 2*nw(twice the time-bandwidth product).
/NW=nw
Specifies the time-bandwidth product. This value should typically be in the range 
[2,6]. Given a time-bandwidth product nw it is recommended to use no more than 
2*nw tapers in order to maximize variance efficiency.
/Q
Quiet mode; suppresses printing in the history area.
/R=[startPoint,endPoint]
Calculates the PSD estimate for a specified input range. startPoint and endPoint are 
expressed in terms of point numbers of the source wave.
/R=(startX,endX)
Calculates the PSD estimate for a specified input range. startX and endX are expressed 
in terms of X values. Note that this option converts your X specifications to point 
numbers and some roundoff may occur.
/Z
Do not report errors.
