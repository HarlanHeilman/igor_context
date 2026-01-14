#pragma rtGlobals=1		// Use modern global access method.
#pragma version=3.0

//
//	Log Histogram.ipf
//
// Version 3.1, 2/3/2021 -- JW
//		Added floor() to the line that computes the bin point number in DoLogHist()
//		Did we change the way point indexing works at some point in the past 25 years?
//	Version 3.0, 6/7/2007
//		Added LogHistBins. -- jsp
//	Version 2.0, 1/3/2000
//		Corrected bin x value bug, modified LogHist to use more intuitive parameters, added auto-graphing. -- jsp
//	Version 1.10, 12/28/95
//		Updated for Igor Pro 3.0. Removed /D which is no longer needed.
//	Version 1.01, 5/17/94
//		Used Wave/D instead of Wave in several places.

Menu "Analysis"
	"Log Histogram using Decades...", LogHist()
	"Log Histogram using Number of Bins...", LogHistBins()
End

//	DoLogHist(sw, dwX, dwY, logStartX, logDeltaX)
//		Creates the logarithmic histogram of the source wave by summing
//		the appropriate numbers into the destination y wave.
//		sw is the source wave.
//		dwX is the destination x wave.
//		dwY is the destination y wave.
//		logStartX, logDeltaX are explained below in LogHist().
Function DoLogHist(sw, dwX, dwY, logStartX, logDeltaX)
	Wave sw, dwX, dwY
	Variable logStartX, logDeltaX
	
	Variable pt, pp, dpnts, spnts
	
	// first find bin edges and put them in dwX
	dpnts = numpnts(dwX)
	pt = 0
	do
		dwX[pt] = 10^(pt*logDeltaX+logStartX)	// this value is 10^logStartX when p == 0
		pt += 1
	while (pt < dpnts)
	
	// now find which bin of dwY each Y value in sw belongs in and increment it.
	spnts = numpnts(sw)
	pt = 0
	do
		pp = floor((log(sw[pt]) - logStartX) / logDeltaX)
		if( pp == limit(pp,0,dpnts) )	// unless it is out of range or NaN
			dwY[pp] += 1
		endif
		pt += 1
	while (pt < spnts)
End	

//	LogHist(sourceWave, numDecades, startDecade, binsPerDecade)
//		Creates XY pair of waves that represent the logarithmic histogram of the source wave.
//		If the source wave is named "data" then the output waves will be named "data_hx" and "data_hy".
//		The product of numDecades and binsPerDecade specifies the number of bins in the histogram.
//		startDecade specifies the X coordinate of the left edge of first bin. The bin starts at 10^startDecade.
//		binsPerDecade specifies the bin width. Values less than 1 result in bins that span multiple decades.
//		For example, set binsPerDecade to 0.5 to create bins that span two decades.
//	Example:

	Make/O/N=100 test = 10^(1+p/33)	// 10 to 10,000 (10^1 to 10^4)
	Display test; ModifyGraph log(left)=1, mode=8,msize=2
	LogHist("test",12,0,1)

Proc LogHist(sourceWave, numDecades, startDecade, binsPerDecade)
	String sourceWave= StrVarOrDefault("root:Packages:LogHist:sourceWave","_demo_")
	Variable numDecades =  NumVarOrDefault("root:Packages:LogHist:numDecades",10)
	Variable startDecade = NumVarOrDefault("root:Packages:LogHist:startDecade",-4)	// first bin at 0.0001
	Variable binsPerDecade = NumVarOrDefault("root:Packages:LogHist:binsPerDecade",1)
	Prompt sourceWave, "Source wave", popup, "_demo_;"+WaveList("*", ";", "")
	Prompt startDecade, "start decade  (first bin starts at 10^startDecade)"
	Prompt numDecades, "Number of decades in destination waves"
	Prompt binsPerDecade, "bins per decade"
	
	Silent 1
	
	if( CmpStr(sourceWave,"_demo_") == 0 )
		sourceWave= "demoData"
		Make/O/N=100 $sourceWave = 0.0001+10^(gnoise(2))	// about 10^-4 to 10^6
		CheckDisplayed/A $sourceWave
		if( V_Flag == 0 )
			Display $sourceWave; ModifyGraph log(left)=1, mode=8,msize=2
		endif
		startDecade=-4
		numDecades=10
		binsPerDecade=1
		Printf "Using demo settings: start decade= 10^%g, num decades=%g, bins per decade= %g\r", startDecade, numDecades, binsPerDecade
	endif
	
	if( binsPerDecade < 0 )
		binsPerDecade = 1
	endif
	
	// Save values for next attempt
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LogHist
	String/G root:Packages:LogHist:sourceWave = sourceWave
	Variable/G root:Packages:LogHist:numDecades= numDecades
	Variable/G root:Packages:LogHist:startDecade= startDecade
	Variable/G root:Packages:LogHist:binsPerDecade= binsPerDecade
	
	String destXWave, destYWave
	
	// Concoct names for dest waves.
	// This does not work if sourceWave is a full or partial path requiring single quotes (e.g., root:Data:'wave 0').
	Variable numBins= numDecades * binsPerDecade
	Variable logDeltaX= 1/binsPerDecade // Log delta X value (1.0 gives 1 decade per bin)
	
	destXWave = sourceWave + "_hx"
	destYWave = sourceWave + "_hy"
	Make/O/N=(numBins+1) $destXWave=0, $destYWave=0

	DoLogHist($sourceWave, $destXWave, $destYWave, startDecade, logDeltaX)
	CheckDisplayed/A $destYWave
	if( V_Flag == 0 )
		Display $destYWave vs $destXWave
		AutoPositionWindow/E/M=1
		ModifyGraph mode=4, marker=19,  log(bottom)=1
	endif
End

//	LogHist(sourceWave, startValue, endValue, numBins)
//		Creates XY pair of waves that represent the logarithmic histogram of the source wave.
//		If the source wave is named "data" then the output waves will be named "data_hx" and "data_hy".
//		startValue specifies the X coordinate of the left edge of first bin.
//		endValue specifies the X coordinate of the right edge of the last bin, and thus no value >= endValue is histogrammed.
//		numBins is the number of  bins.
//		If the binning looks wrong to  you, try numBins-1 or increasing endValue.
//	Example:

	Make/O/N=100 test = 10^(1+p/33)	// 10 to 10,000 (10^1 to 10^4)
	Display test; ModifyGraph log(left)=1, mode=8,msize=2
	LogHistBins("test",10^(-1), 10^6, 7)

Proc LogHistBins(sourceWave, startValue, endValue, numBins)
	String sourceWave= StrVarOrDefault("root:Packages:LogHist:sourceWave","_demo_")
	Variable startValue =  NumVarOrDefault("root:Packages:LogHist:startValue",10^(-4))
	Variable endValue = NumVarOrDefault("root:Packages:LogHist:endValue",10^5)	// 10 decades
	Variable numBins = NumVarOrDefault("root:Packages:LogHist:numBins",10)
	Prompt sourceWave, "Source wave", popup, "_demo_;"+WaveList("*", ";", "")
	Prompt startValue, "Start value  (first bin starts here)"
	Prompt endValue, "End value (values >= end value aren't histogrammed)"
	Prompt numBins, "Number of bins"
	
	Silent 1
	
	if( CmpStr(sourceWave,"_demo_") == 0 )
		sourceWave= "demoData"
		Make/O/N=100 $sourceWave = 0.0001+10^(gnoise(2))	// about 10^-4 to 10^6
		CheckDisplayed/A $sourceWave
		if( V_Flag == 0 )
			Display $sourceWave; ModifyGraph log(left)=1, mode=8,msize=2
		endif
		startValue=10^(-4)
		endValue=10^5
		numBins=10
		Printf "Using demo settings: start value=%g, end value=%g, number of bins= %g\r", startValue, endValue, numBins
	endif
	
	if( startValue <= 0 )
		DoAlert 0, "start value ("+num2str(startValue)+") can not be <= 0."
		return
	endif
	if( endValue <= startValue )
		DoAlert 0, "end value ("+num2str(endValue)+") can not be <= start value ("+num2str(startValue)+")."
		return
	endif
	Variable logStartX= log(startValue)
	Variable logEndX= log(endValue)
	Variable logDeltaX= (logEndX-logStartX)/numBins
	
	// Save values for next attempt
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:LogHist
	String/G root:Packages:LogHist:sourceWave = sourceWave
	Variable/G root:Packages:LogHist:startValue= startValue
	Variable/G root:Packages:LogHist:endValue= endValue
	Variable/G root:Packages:LogHist:numBins= numBins
	
	String destXWave, destYWave
	
	// Concoct names for dest waves.
	// This does not work if sourceWave is a full or partial path requiring single quotes (e.g., root:Data:'wave 0').
	destXWave = sourceWave + "_hx"
	destYWave = sourceWave + "_hy"
	Make/O/N=(numBins) $destXWave=0, $destYWave=0

	DoLogHist($sourceWave, $destXWave, $destYWave, logStartX, logDeltaX)
	CheckDisplayed/A $destYWave
	if( V_Flag == 0 )
		Display $destYWave vs $destXWave
		AutoPositionWindow/E/M=1
		ModifyGraph mode=4, marker=19,  log(bottom)=1
	endif
End
