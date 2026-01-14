// Median.ipf
#pragma rtGlobals=1
#pragma version=6.01
#pragma IgorVersion=6		// requires Igor 6 (StatsMedian)

// This crude GUI is obsolete, use ShowMedianXYSmoothingPanel(), instead:
// #include <Median XY Panel>

Menu "Analysis"
	"Median XY Smoothing", MedianXYSmoothing()
End

Proc MedianXYSmoothing(wxn,wyn,xwidth,nameOfMedianYWave)
	String wxn= StrVarOrDefault("root:Packages:MedianXY:lastMedianXInputWave","")
	String wyn= StrVarOrDefault("root:Packages:MedianXY:lastMedianYInputWave","")
	String nameOfMedianYWave=StrVarOrDefault("root:Packages:MedianXY:lastMedianYOutputWave","medianWave")
	Variable xwidth=NumVarOrDefault("root:Packages:MedianXY:medianXWidth",0)
	Prompt wxn,"X wave",popup,WaveList("*",";","")+";_none_"
	Prompt wyn,"Y wave",popup,WaveList("*",";","")+";_none_"
	Prompt xwidth,"median x range"
	Prompt nameOfMedianYWave,"name of output median wave"

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:MedianXY
	String/G root:Packages:MedianXY:lastMedianXInputWave= wxn
	String/G root:Packages:MedianXY:lastMedianYInputWave= wyn
	Variable/G root:Packages:MedianXY:medianXWidth= xwidth
	String/G root:Packages:MedianXY:lastMedianYOutputWave= nameOfMedianYWave
	MedianXY($wxn,$wyn,xwidth,nameOfMedianYWave)
End


// MedianEO(w, x1, x2)
//	Based on Numerical Recipes in C pp. 476-477.
//	Returns median value of wave w from x=x1 to x=x2.
//	Pass -INF and +INF for x1 and x2 to get median of the entire wave.
//	This version averages the two middle points of the sorted result if the number of points is even,
//	returns the middle (median) point if the number of points is odd.
// This version accounts for NaN Y values, which sort to the end of tempMedianWave.
Function MedianEO(w, x1, x2)
	Wave w
	Variable x1, x2
	
	Variable result=NaN

	Duplicate/O/R=(x1, x2) w, tempMedianWave	// Make a clone of wave
	Variable n= numpnts(tempMedianWave)
	if( n>0 )
		Sort tempMedianWave, tempMedianWave			// Sort clone, puts NaNs at the end
		WaveStats/Q/M=1 tempMedianWave
		n= V_npnts		// excludes NaNs
		if( n>0 )
			result= tempMedianWave[floor((n-1)/2)]		// if n=3, index= 1 (center value). if n=4, index=1, the left-most of two middle values
			if( (n & 0x1) == 0 )	// even
				result= (result + tempMedianWave[n/2])/2	// if n=4, index= 2, the right-most of two middle values
			endif
		endif
	endif
	KillWaves/Z tempMedianWave
	return result
End

#if IgorVersion() < 7
// median function is built into Igor 7.

// Obsolete: use MedianEO() or StatsMedian(), instead
//
// Median(w, x1, x2)
//	Based on Numerical Recipes in C pp. 476-477.
//	Returns median value of wave w from x=x1 to x=x2.
//	Pass -INF and +INF for x1 and x2 to get median of the entire wave.
Function Median(w, x1, x2)
	Wave w
	Variable x1, x2
	
	Variable result

	Duplicate/R=(x1, x2) w, tempMedianWave			// Make a clone of wave
	Sort tempMedianWave, tempMedianWave			// Sort clone
	SetScale/P x 0,1,tempMedianWave
	result = tempMedianWave((numpnts(tempMedianWave)-1)/2)
	KillWaves tempMedianWave

	return result
End
#endif

// Keep this function callable from the command line
Function/S MedianXY(wx,wy,xwidth,pathToOutputWave [,threshold,replacementValue])
	Wave wx,wy
	Variable xwidth	// compute the median over this X-range centered on the result's x value
	String pathToOutputWave
	Variable threshold			// 0 to replace every value (this is the default)
	Variable replacementValue	// if specified, replace values whose distance from the median exceeds the threshold with this value (which can be NaN, Inf, -Inf, or any value you want)
									// if not specified, the median replces values whose distance from the median exceeds the threshold
	
	Variable replaceWithMedian = ParamIsDefault(replacementValue)
	if( ParamIsDefault(threshold) )
		threshold= 0
	endif
	
	Variable wd2= xwidth/2
	
	Duplicate/O wy, $pathToOutputWave
	WAVE medianY= $pathToOutputWave
	
	Variable n= numpnts(wy)	// must be same as wx
	Variable i
	for(i=0; i<n; i+=1)
		Variable xmin= wx[i]-wd2
		Variable xmax= xmin+xwidth
		// extract the y values in the x range - this could be avoided if wx is monotonic.
		// Extract doesn't extract values where the x is NaN
		Extract/O wy, ysInXRange, wx>=xmin && wx<=xmax
		Variable originalValue= medianY[i]
		Variable theMedian= MedianEO(ysInXRange,-inf,inf)
		Variable distance= abs(theMedian-originalValue)
		if( distance >= threshold || numtype(distance) != 0)
			if( replaceWithMedian )
				medianY[i]= theMedian
			else
				medianY[i]= replacementValue
			endif
		endif
	endfor
	
	KillWaves/Z ysInXRange
	
	return GetWavesDataFolder(medianY,2)
End

