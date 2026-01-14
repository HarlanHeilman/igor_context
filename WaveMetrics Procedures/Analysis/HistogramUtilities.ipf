#pragma rtGlobals=1		// Use modern global access method.

//**********************************************
//
//	A package of simple utilities to ease the use of histogram results.
//
//	An Igor histogram goes into a wave with X scaling set such that the X values give the left edges of the histogram bins.
//	Thus, the X values from the wave give the boundaries of the bins, which makes a certain kind of sense. In particular,
//	if you make a graph and display the trace in bars mode, you get bars that are the correct width and show the correct
//	bin edges. 
//
//	Unfortunately, certain operations really need X values that fall at the bin centers. This would include plotting a 
//	marker instead of bars, adding error bars to a histogram, or doing a curve fit to a histogram. Three of these utitily 
//	functions are aimed at the centered-X problem. The fourth function makes a suitable weighting wave for correct
// 	curve fitting of histogram results.
//
//	This procedure file also defines a menu for easy access to the functions. Pull down the Analysis menu and select
//	Histogram Utilities to display a sub-menu. 
//
//	HistWaveToCenteredXScaling(histwave)
//		Adjusts the X scaling of a histogram result wave to put the X values of the wave's X scaling at the centers of bins.
//
//		histwave		name of a histogram result wave
//
//	CenteredHistWaveToLeftX(histwave)
//		Undoes the action of HistWaveToCenteredXScaling(), adjusting the X scaling of histwave to the left edges of the bins.
//
//		histwave		name of a histogram result wave
//
//	Note that HistWaveToCenteredXScaling() and CenteredHistWaveToLeftX() can't tell if a wave is really a histogram
//	result wave, or if these functions have already been applied to the waves. HistWaveToCenteredXScaling() simply
//	adds half the deltax value to the x0 value, and CenteredHistWaveToLeftX() simply subtracts half the deltax value
//	from the x0 value. If you apply either of these functions more than once to the same wave, it will simply keep shifting
// 	the X values farther and farther.
//
//	See the Igor User's Guide, Part 1, Waves chapter if wave scaling is an unfamiliar concept.
//
//	MakeCenteredXWaveForHistWave(histwave, NewWaveName)
//		Instead of altering the wave scaling of histwave, this function makes a new wave with centered X values. The original
//		histogram result wave (unmodified) can be used with the centered X wave as an XY pair for plotting markers,
//		error bars, or doing curve fits.
//
//		histwave		name of a histogram result wave
//		NewWaveName	string containing the name to use when making the new wave.
//
//	SqrtNWaveForHistWave(histwave, NewWaveName [, zerovalue])
//		In most cases, counting statistics like the values in a histogram, have errors with Poisson distribution, not a Gaussian
//		distribution. Fitting such data introduces a bias in the result. To remove the bias, you should use weighting
//		values proportional to sqrt(N) where N is the number in one of the histogram bins. This function creates a wave
//		suitable for use as a weighting wave when doing a curve fit to histogram data.
//
//		NOTE that the wave is made with values of sqrt(N) in it, not 1/sqrt(N). In the Curve Fit dialog, Data Options tab,
//		select the wave from the Weighting menu, and make sure the Wave Contains Standard Deviation radio button
//		is selected.
//
//		histwave		name of a histogram result wave
//		NewWaveName	string containing the name to use when making the new wave.
//		zerovalue		number to use to replace values of zero. The default value is 1.0. If zero is used, zero values are
//						ignored during curve fitting, which isn't really correct. This is an optional parameter- if you
//						don't include it when calling the function, the value is set to 1. To set it to something other than 1,
//						you must use the special syntax for optional parameters.
//		Example setting the zero value to 2:
//			SqrtNWaveForHistWave(myHistWave, "myHistWeightWave", zerovalue=2)
//
//**********************************************
// LH040721: fixed improper use of optional param

Menu "Analysis"
	SubMenu "Histogram Utilities"
		"Centered X Scaling...", /Q,  mHistWaveToCenteredXScaling()
		"Left X from Centered X Scaling...", /Q, mCenteredHistWaveToLeftX()
		"Centered X Wave...", /Q, mMakeCenteredXWaveForHistWave()
		"\M0Sqrt(N) Weighting Wave...", /Q, mSqrtNWaveForHistWave()
	end
end

Function HistWaveToCenteredXScaling(histwave)
	Wave histwave
	
	SetScale/P x leftx(histwave)+deltax(histwave)/2, deltax(histwave),histwave
end

Function mHistWaveToCenteredXScaling()

	MakeHistUtilitiesFolderIfNeeded()
	
	SVAR histname = root:Packages:WM_HistUtilities:histwavename
	String histwavename = histname
	Prompt histwavename, "Select a histogram result wave:", popup, WaveList("*",";","")
	DoPrompt "Convert Histogram Wave to Centered X Scaling", histwavename
	if (V_flag)
		return NaN
	endif

	histname = histwavename
	HistWaveToCenteredXScaling($histwavename)
end

Function CenteredHistWaveToLeftX(histwave)
	Wave histwave
	
	SetScale/P x leftx(histwave)-deltax(histwave)/2, deltax(histwave),histwave
end

Function mCenteredHistWaveToLeftX()

	MakeHistUtilitiesFolderIfNeeded()
	
	SVAR histname = root:Packages:WM_HistUtilities:histwavename
	String histwavename = histname
	Prompt histwavename, "Select a histogram result wave with centered X scaling:", popup, WaveList("*",";","")
	DoPrompt "Convert Histogram Wave to Left Bin Edge Scaling", histwavename
	if (V_flag)
		return NaN
	endif
	
	histname = histwavename
	CenteredHistWaveToLeftX($histwavename)
end

Function MakeCenteredXWaveForHistWave(histwave, NewWaveName)
	Wave histwave
	String NewWaveName
	
	Duplicate/O histwave, $NewWaveName
	Wave w = $NewWaveName
	
	w = leftx(histwave) + deltax(histwave)*(p+0.5)
end

Function mMakeCenteredXWaveForHistWave()

	MakeHistUtilitiesFolderIfNeeded()
	
	SVAR histname = root:Packages:WM_HistUtilities:histwavename
	String histwavename = histname
	Prompt histwavename, "Select a histogram result wave:", popup, WaveList("*",";","")
	
	SVAR newname = root:Packages:WM_HistUtilities:newHistXWave
	String newWaveName = newname
	Prompt newWaveName, "Enter a name for the new X wave:"
	DoPrompt "Make Centered X Wave for Histogram Result", histwavename, newWaveName
	if (V_flag)
		return NaN
	endif
	
	histname = histwavename
	newname = newWaveName
	MakeCenteredXWaveForHistWave($histwavename, newWaveName)
end

Function SqrtNWaveForHistWave(histwave, NewWaveName [, zerovalue])
	Wave histwave
	String NewWaveName
	Variable zerovalue
	
	If( ParamIsDefault(zerovalue ) )
		zerovalue= 1
	endif

	Duplicate/O histwave, $NewWaveName
	Wave w = $NewWaveName
	
	w = histwave[p] == 0 ? zerovalue : sqrt(histwave[p])
end

Function mSqrtNWaveForHistWave()

	MakeHistUtilitiesFolderIfNeeded()
	
	SVAR histname = root:Packages:WM_HistUtilities:histwavename
	String histwavename = histname
	Prompt histwavename, "Select a histogram result wave:", popup, WaveList("*",";","")

	SVAR newname = root:Packages:WM_HistUtilities:newHistSqrtNWave
	String newWaveName = newname
	Prompt newWaveName, "Enter a name for the new X wave:"
	
	NVAR zerovalue = root:Packages:WM_HistUtilities:histZeroValue
	Variable zeronum = zerovalue
	Prompt zeronum, "Enter a value to use for bins containing zero:"
	DoPrompt "Make Square Root of N For Fit Weight Wave", histwavename, newWaveName, zeronum
	if (V_flag)
		return NaN
	endif
	
	histname = histwavename
	newname = newWaveName
	zerovalue = zeronum
	SqrtNWaveForHistWave($histwavename, newWaveName, zerovalue=zerovalue)
end

Function MakeHistUtilitiesFolderIfNeeded()

	if (DataFolderExists("root:Packages:WM_HistUtilities:"))
		return 0
	endif
	
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_HistUtilities

	String/G histwavename = ""
	String/G newHistXWave = "Hist_Centered_X"
	String/G newHistSqrtNWave = "Hist_Sqrt_N"
	Variable/G histZeroValue = 1
	
	SetDataFolder $saveDF
end
