#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 2.01
#pragma IgorVersion = 4.00

//These procedures allow you to do a bivariate histogram- a matrix in which
//each cell is a count of values between two X values and two Y values. You
//can do a histogram with bins having equal spacing, log spacing or
//arbitrary spacing.

//The primary user interface is through the Macros menu: select Bivariate
//Histogram to pop up a sub-menu with several choices of histogram style.

//If you want an equally-spaced histogram, you can specify the number of bins
//and let Igor figure out the boundaries (Automatic Bins), you can specify
//the first bin edge and the number of bins in each direction (Manual Bins),
//or you can specify the bins by supplying your own matrix wave with the X
//and Y scaling set to the desired binning (Bins from Existing Wave).

//If you want log-spaced bins, you have two choices. With Automatic bins you
//specify the number of bins and Igor calculates log-spaced bins from the
//minimum and maximum data values. With Manual bins you spcify the number of
//bins and the first and last bin edge in each direction.

//With a log histogram, the procedure makes four auxiliary waves in addition
//to the histogram matrix. You specify a name for the histogram matrix wave,
//and Igor makes two 1D waves with "_XB" and "_YB" appended to the name. These
//waves contain the numerical values of the bin edges. There are N+1 points
//in these waves for a histogram with N rows or columns. The procedure also
//makes two waves with "_XC" and "_YC" appended to the name. These waves are
//for your convenience- they contain N points for N rows or columns and
//contain values equal to the logarhithmic center of each bin. You can use
//these waves as the X and Y waves to make a contour plot. To make an image
//plot of the histogram, use the bin edge waves.

//Finally, you can choose General Bins. For this option, you must prepare
//ahead of time a matrix to receive the histogram and two waves with N+1
//points (that is, one with a number of points equal to the histogram rows
//plus one, and one with a number of points equal to the histogram columns
//plus one). Fill these waves with histogram bin edge values.  The values in
//these waves must be monotonic or you will get unpredictable (that is,
//screwy) results.

//With General Bins you can also choose to make the histogram cumulative-
//that is, the results of the histogram are added to the contents already in
//your histogram wave.

//To make a cumulative log histogram, make the first log histogram using one
//of the log histogram choices. This will not be cumulative, but it's the
//first one. To accumulate more data into the same histogram, use General
//Bins and choose the "_XB" and  "_YB" waves created by the first histogram
//operation as the X and Y bin waves.

//With both log and general histograms you can choose whether points that
//fall outside any bin should be counted. If you choose to Exclude Outliers,
//these points are ignored. Otherwise, they are counted into the closest edge
//bin.

// With all binning options, you can choose to make a "classification" wave. This is a wave
// having the same number of points as the input waves. When finished, for each row it will
// contain a number indicating how many points are in the bin that contains that particular
// point. This is useful, for instance, for coloring an XY scatter plot with Color as f(z) such
// that the color indicates the point density.

//You can make histograms programmatically by calling the basic histogramming
//functions. In all cases, the doClassWave parameter is an optional parameter; set to 1 to have
// the classification wave generated. For information on using optional paremters, select this line
// (but don't include the comment slashes in the selection) and press control-enter:

// DisplayHelpTopic "Using Optional Parameters"

//BivariateHist(XWave, YWave, XBins, YBins, histWaveName [, doClassWave])
//
//  Implements the Automatic Bins option.

//BiHistSetBins(XWave, YWave, XBins, FirstXBin, XBinDelta, YBins, FirstYBin,
//		YBinDelta, histWaveName [, doClassWave])
//
//  Implements the Manual Bins  option.

//BiHistWave(XWave, YWave, histWave [, doClassWave])
//
//  Implements the Bins from Existing Wave option.

//LogBiHistSetNBins(XWave, YWave, NBinsX, NBinsY, histWaveName, excludeOutliers [, doClassWave])
//
//  Implements a log histogram with automatic bins.

//LogBiHistSetAll(XWave, YWave, XLeft, XRight, NBinsX, YLeft, YRight, NBinsY,
//		histWaveName, Accumulate, excludeOutliers [, doClassWave])
//
//  Implements a log histogram with manual bins.

//GeneralBiHistWave(XWave, YWave, histWave, xBinWave, yBinWave, accumulate,
//		excludeOutliers [, doClassWave])
//
//  Implements a General histogram.

// Revisions:
// 2.0 		First release (?)
// 2.01 	Fixed binning bugs (made BiHistWave() use uncentered wave scaling, just like Igor's built-in histogram)
//			Made linear histogram functions ignore values outside any bin
//			Made the functions ignore NaN's
// 2.02		Added ability to generate a classification wave
//			Added memory of previous choices for the Simple Input Dialog

Menu "Macros"
	SubMenu "Bivariate Histogram"
		"Automatic Bins", /Q, BiHistInterface(0)
		"Manual Bins", /Q, BiHistInterface(1)
		"Bins From Existing Wave", /Q, BiHistInterface(2)
		"Log Automatic Bins", /Q, BiHistInterface(3)
		"Log Manual Bins", /Q, BiHistInterface(4)
		"General Bins", /Q, GeneralBiHistInterface()
	end
end

Function BiHistInterface(whichFunction)
	Variable whichFunction		// 0 = BivariateHist; 1 = BiHistSetBins; 2 = BiHistWave; 3 = Log Auto Bins; 4 = Log Manual Bins
	
	String XWName = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gXWName", "")
	String YWName = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gYWName", "")
	String histWaveName = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:ghistWaveName", "BivariateHistWave")
	String existingHistWaveName = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gexistingHistWaveName", "")
	Variable XBins = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gXBins", 0)
	Variable FirstXBin = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gFirstXBin", 0)
	Variable XBinDelta = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gXBinDelta", 0)
	Variable YBins = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gYBins", 0)
	Variable FirstYBin = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gFirstYBin", 0)
	Variable YBinDelta = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gYBinDelta", 0)
	Variable LastXBinEdge = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gLastXBinEdge", 0)
	Variable LastYBinEdge = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gLastYBinEdge", 0)
	variable excludeOutliers = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gexcludeOutliers", 1)
	Variable generateClassWave = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:ggenerateClassWave", 2)

	Prompt XWName, "Raw X Data Wave:", popup, WaveList("*", ";","DIMS:1")
	Prompt YWName, "Raw Y Data Wave:", popup, WaveList("*", ";","DIMS:1")
	Prompt XBins, "Number of X Bins:"
	Prompt YBins, "Number of Y Bins:"
	Prompt XBinDelta, "Width of X Bins:"
	Prompt YBinDelta, "Width of Y Bins:"
	Prompt FirstXBin, "First X Bin Value:"
	Prompt FirstYBin, "First Y Bin Value:"
	Prompt LastXBinEdge, "Last X Bin Edge Value:"
	Prompt LastYBinEdge, "Last Y Bin Edge Value:"
	Prompt existingHistWaveName, "Wave for histogram:", popup, WaveList("*", ";","DIMS:2")
	Prompt histWaveName, "Name for new  histogram matrix wave:"
	Prompt excludeOutliers, "Exclude Points Beyond Extreme Bins?", popup, "Yes; No"
	Prompt generateClassWave, "Generate classification wave?", popup, "Yes; No"
	
	String saveDF = GetDataFolder(1)
	
	Variable returnValue
	switch (whichFunction)
		case 0:
			DoPrompt "Bivariate Histogram", XWName, YWName, XBins, YBins, HistWaveName, generateClassWave
			if (V_flag == 0)
				NewDataFolder/O/S Packages
				NewDataFolder/O/S WMBivariateHistogramGlobals
				String/G gXWName = XWName
				String/G gYWName = YWName
				String/G ghistWaveName=HistWaveName
				Variable/G gXBins = XBins
				Variable/G gYBins = YBins
				Variable/G gFirstYBin
				Variable/G ggenerateClassWave=generateClassWave
				SetDataFolder saveDF
				returnValue = BivariateHist($XWName, $YWName, XBins, YBins, HistWaveName, doClassWave=(generateClassWave==1))
			endif
			break
		case 1:
			DoPrompt "Bivariate Histogram", XWName, YWName, XBins, YBins, FirstXBin, FirstYBin, XBinDelta, YBinDelta, HistWaveName, generateClassWave
			if (V_flag == 0)
				NewDataFolder/O/S Packages
				NewDataFolder/O/S WMBivariateHistogramGlobals
				String/G gXWName = XWName
				String/G gYWName = YWName
				String/G ghistWaveName=HistWaveName
				Variable/G gXBins = XBins
				Variable/G gFirstXBin = FirstXBin
				Variable/G gXBinDelta = XBinDelta
				Variable/G gYBins = YBins
				Variable/G gFirstYBin = FirstYBin
				Variable/G gYBinDelta = YBinDelta
				Variable/G ggenerateClassWave=generateClassWave
				SetDataFolder saveDF
				returnValue = BiHistSetBins($XWName, $YWName, XBins, FirstXBin, XBinDelta, YBins, FirstYBin, YBinDelta, histWaveName, doClassWave=(generateClassWave==1))
			endif
			break
		case 2:
			DoPrompt "Bivariate Histogram w Pre-existing Wave", XWName, YWName, existingHistWaveName, generateClassWave
			if (V_flag == 0)
				NewDataFolder/O/S Packages
				NewDataFolder/O/S WMBivariateHistogramGlobals
				String/G gXWName = XWName
				String/G gYWName = YWName
				String/G gexistingHistWaveName=existingHistWaveName
				Variable/G ggenerateClassWave=generateClassWave
				SetDataFolder saveDF
				returnValue = BiHistWave($XWName, $YWName, $existingHistWaveName, doClassWave=(generateClassWave==1))
			endif
			break
		case 3:
			DoPrompt "Log Bivariate Histogram w Automatic Bins", XWName, YWName, HistWaveName, XBins, YBins, excludeOutliers, generateClassWave
			if (V_flag == 0)
				NewDataFolder/O/S Packages
				NewDataFolder/O/S WMBivariateHistogramGlobals
				String/G gXWName = XWName
				String/G gYWName = YWName
				String/G ghistWaveName=HistWaveName
				Variable/G gXBins = XBins
				Variable/G gYBins = YBins
				Variable/G gexcludeOutliers = excludeOutliers
				Variable/G ggenerateClassWave=generateClassWave
				SetDataFolder saveDF
				returnValue = LogBiHistSetNBins($XWName, $YWName, XBins, YBins, histWaveName, excludeOutliers == 1 ? 1 : 0, doClassWave=(generateClassWave==1))
			endif
			break
		case 4:
			DoPrompt "Bivariate Histogram w Pre-existing Wave", XWName, YWName, HistWaveName, XBins, FirstXBin, LastXBinEdge, YBins, FirstYBin, LastYBinEdge, excludeOutliers
			if (V_flag == 0)
				NewDataFolder/O/S Packages
				NewDataFolder/O/S WMBivariateHistogramGlobals
				String/G gXWName = XWName
				String/G gYWName = YWName
				String/G ghistWaveName=HistWaveName
				Variable/G gXBins = XBins
				Variable/G gFirstXBin = FirstXBin
				Variable/G gYBins = YBins
				Variable/G gFirstYBin = FirstYBin
				Variable/G gLastXBinEdge = LastXBinEdge
				Variable/G gLastYBinEdge = LastYBinEdge
				Variable/G gexcludeOutliers = excludeOutliers
				Variable/G ggenerateClassWave=generateClassWave
				SetDataFolder saveDF
				
				DoAlert 2, "Generate classification wave?"
				if (V_flag < 3)
					NewDataFolder/O/S Packages
					NewDataFolder/O/S WMBivariateHistogramGlobals
					Variable/G ggenerateClassWave = V_flag
					SetDataFolder saveDF
					returnValue = LogBiHistSetAll($XWName, $YWName, FirstXBin, LastXBinEdge, XBins, FirstYBin, LastYBinEdge, YBins, histWaveName, 0, excludeOutliers == 1 ? 1 : 0, doClassWave=(ggenerateClassWave==1))
				endif
			endif
			break
	endswitch
	
	Switch (returnValue)
		case 0:
			break
		case -1:
			DoAlert 0, "X Wave doesn't exist."
			break
		case -2:
			DoAlert 0, "Y Wave doesn't exist."
			break
		case -3:
			DoAlert 0, "X and Y Waves must have equal number of points."
			break
		case -4:
			DoAlert 0, "Histogram output wave doesn't exist"
			break;
		case -5:
			DoAlert 0, "X Bin Wave must have one more point than the histogram matrix has rows."
			break;
		case -6:
			DoAlert 0, "Y Bin Wave must have one more point than the histogram matrix has columns."
			break;
		default:
			break
	endswitch
	
	return returnValue
end

Function GeneralBiHistInterface()

	String XWaveN = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gXWName", "")
	String YWaveN = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gYWName", "")
	String histWaveN = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:ghistWaveName", "BivariateHistWave")
	String xBinWaveN = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gxBinWaveName", "")
	String yBinWaveN = StrVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gyBinWaveName", "")

	Variable Accumulate = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gAccumulate", 2)
	variable excludeOutliers = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:gexcludeOutliers", 1)
	Variable generateClassWave = NumVarOrDefault("root:Packages:WMBivariateHistogramGlobals:ggenerateClassWave", 2)
	
	Prompt XWaveN, "Raw X Data Wave:", popup, WaveList("*", ";","DIMS:1")
	Prompt YWaveN, "Raw Y Data Wave:", popup, WaveList("*", ";","DIMS:1")
	Prompt histWaveN, "Matrix Wave for Histogram Results:", popup, WaveList("*", ";","DIMS:2")
	Prompt xBinWaveN, "Bin Edge Wave for X:", popup, WaveList("*", ";","DIMS:1")
	Prompt yBinWaveN, "Bin Edge Wave for Y:", popup, WaveList("*", ";","DIMS:1")
	Prompt Accumulate, "Accumulate Histogram Results?", popup, "Yes; No"
	Prompt excludeOutliers, "Exclude Points Beyond Extreme Bins?", popup, "Yes; No"
	Prompt generateClassWave, "Generate classification wave?", popup, "Yes; No"
	
	DoPrompt "General Bi-variate histogram", XWaveN, YWaveN, histWaveN, xBinWaveN, yBinWaveN, Accumulate, excludeOutliers, generateClassWave
	
	String saveDF = GetDataFolder(1)

	Variable returnValue
	if (V_flag == 0)
		NewDataFolder/O/S Packages
		NewDataFolder/O/S WMBivariateHistogramGlobals
		String/G gXWName = XWaveN
		String/G gYWName = YWaveN
		String/G ghistWaveName=histWaveN
		String/G gxBinWaveName = xBinWaveN
		String/G gyBinWaveName = yBinWaveN
	
		Variable/G gAccumulate = Accumulate
		Variable/G gexcludeOutliers = excludeOutliers
		Variable/G ggenerateClassWave = generateClassWave
		SetDataFolder saveDF
		
		returnValue = GeneralBiHistWave($XWaveN, $YWaveN, $histWaveN, $xBinWaveN, $yBinWaveN, Accumulate == 1 ? 1 : 0, excludeOutliers == 1 ? 1 : 0, doClassWave=(generateClassWave==1))
	endif
	
	Switch (returnValue)
		case 0:
			break
		case -1:
			DoAlert 0, "X Wave doesn't exist."
			break
		case -2:
			DoAlert 0, "Y Wave doesn't exist."
			break
		case -3:
			DoAlert 0, "X and Y Waves must have equal number of points."
			break
		case -4:
			DoAlert 0, "Histogram output wave doesn't exist"
			break;
		case -5:
			DoAlert 0, "X Bin Wave must have one more point than the histogram matrix has rows."
			break;
		case -6:
			DoAlert 0, "Y Bin Wave must have one more point than the histogram matrix has columns."
			break;
		default:
			break
	endswitch
end

Function BivariateHist(XWave, YWave, XBins, YBins, histWaveName [, doClassWave])
	Wave/Z XWave, YWave
	Variable XBins, YBins	// number of bins in each direction
	String histWaveName
	Variable doClassWave
	
	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif
	
	Make/O/N=(XBins, YBins) $histWaveName = 0
	Wave/Z w = $histWaveName
	WaveStats/Q XWave
	Variable eps = (V_max-V_min)*3e-16		// guarantees that the range includes the maximum point (which would otherwise fall exactly on the boundary, and therefore in the last+1 bin)
	SetScale x V_min, V_max + eps, w
	WaveStats/Q YWave
	eps = (V_max-V_min)*3e-16
	SetScale y V_min, V_max + eps, w
	
	return BiHistWave(XWave, YWave, w, doClassWave=doClassWave)
end

Function BiHistSetBins(XWave, YWave, XBins, FirstXBin, XBinDelta, YBins, FirstYBin, YBinDelta, histWaveName [, doClassWave])
	Wave/Z XWave, YWave
	Variable XBins, FirstXBin, XBinDelta
	Variable YBins, FirstYBin, YBinDelta
	String histWaveName
	Variable doClassWave
	
	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif
	
	Make/O/N=(XBins, YBins) $histWaveName = 0
	Wave/Z w = $histWaveName
	SetScale/P x FirstXBin, XBinDelta, w
	SetScale/P y FirstYBin, YBinDelta, w
	
	return BiHistWave(XWave, YWave, w, doClassWave=doClassWave)
end

Function BiHistWave(XWave, YWave, histWave [, doClassWave])
	Wave/Z XWave, YWave, histWave
	Variable doClassWave

	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif
	
	Variable i, xpnt, ypnt, dx, dy, x0, y0
	dx = DimDelta(histWave, 0)
	dy = DimDelta(histWave, 1)
//	x0 = DimOffset(histWave, 0)-dx/2
//	y0 = DimOffset(histWave, 1)-dx/2
	x0 = DimOffset(histWave, 0)
	y0 = DimOffset(histWave, 1)
	Variable maxXpnt = dimSize(histWave, 0)
	Variable maxYpnt = dimSize(histWave, 1)
	
	if (doClassWave)
		Duplicate/O YWave, $(NameOfWave(histWave)+"_hcls")
		Wave histclasses = $(NameOfWave(histWave)+"_hcls")
	endif
	
	for (i = 0; i < pnts; i += 1)
		if ( (numtype(XWave[i]) != 0) || (numtype(YWave[i]) != 0) )
			continue
		endif
		xpnt = floor((XWave[i]-x0)/dx)
		ypnt = floor((YWave[i]-y0)/dy)
		if ( (xpnt >= maxXpnt) || (ypnt >= maxYpnt) )
			continue
		endif
		histWave[xpnt][ypnt] += 1
	endfor

	if (doClassWave)
		for (i = 0; i < pnts; i += 1)
			if ( (numtype(XWave[i]) != 0) || (numtype(YWave[i]) != 0) )
				continue
			endif
			xpnt = floor((XWave[i]-x0)/dx)
			ypnt = floor((YWave[i]-y0)/dy)
			if ( (xpnt >= maxXpnt) || (ypnt >= maxYpnt) )
				continue
			endif
			
			histclasses[i] = histWave[xpnt][ypnt]
		endfor
	endif
	
	return 0
end

Function GeneralBiHistWave(XWave, YWave, histWave, xBinWave, yBinWave, accumulate, excludeOutliers [, doClassWave])
	Wave/Z XWave, YWave, histWave, xBinWave, yBinWave
	Variable accumulate		// if non-zero, does not initialize histWave to zero
	Variable excludeOutliers
	Variable doClassWave
	
	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif
	

	Variable nBinsX = DimSize(histWave, 0)
	Variable nBinsY = DimSize(histWave, 1)
	if (!WaveExists(histWave))
		return -4
	endif
	if (numpnts(xBinWave)-1 != nBinsX)
		return -5
	endif
	if (numpnts(yBinWave)-1 != nBinsY)
		return -6
	endif
	
	if (doClassWave)
		Duplicate/O YWave, $(NameOfWave(histwave)+"_hcls")
		Wave classWave = $(NameOfWave(histwave)+"_hcls")
	endif
	
	Variable i, xpnt, ypnt, dx, dy, x0, y0
	
	if (!accumulate)
		histWave = 0
	endif
	if (excludeOutliers)
		for (i = 0; i < pnts; i += 1)
			xpnt = BinarySearch(xBinWave, XWave[i])
			if (xpnt < 0)
				continue
			endif
			ypnt = BinarySearch(yBinWave, YWave[i])
			if (ypnt < 0)
				continue
			endif
			histWave[xpnt][ypnt] += 1
		endfor

		if (doClassWave)
			for (i = 0; i < pnts; i += 1)
				xpnt = BinarySearch(xBinWave, XWave[i])
				if (xpnt < 0)
					continue
				endif
				ypnt = BinarySearch(yBinWave, YWave[i])
				if (ypnt < 0)
					continue
				endif
				classWave[i] = histWave[xpnt][ypnt]
			endfor
		endif
	else
		for (i = 0; i < pnts; i += 1)
			if ( (numtype(XWave[i]) != 0) || (numtype(YWave[i]) != 0) )
				continue
			endif
			xpnt = BinarySearch(xBinWave, XWave[i])
			 if (xpnt == -1)
				xpnt = 0
			elseif (xpnt == -2)
				xpnt = nBinsX-1
			endif
			ypnt = BinarySearch(yBinWave, YWave[i])
			 if (ypnt == -1)
				ypnt = 0
			elseif (ypnt == -2)
				ypnt = nBinsY-1
			endif
			histWave[xpnt][ypnt] += 1
		endfor

		if (doClassWave)
			for (i = 0; i < pnts; i += 1)
				if ( (numtype(XWave[i]) != 0) || (numtype(YWave[i]) != 0) )
					continue
				endif
				xpnt = BinarySearch(xBinWave, XWave[i])
				 if (xpnt == -1)
					xpnt = 0
				elseif (xpnt == -2)
					xpnt = nBinsX-1
				endif
				ypnt = BinarySearch(yBinWave, YWave[i])
				 if (ypnt == -1)
					ypnt = 0
				elseif (ypnt == -2)
					ypnt = nBinsY-1
				endif
				classWave[i] = histWave[xpnt][ypnt]
			endfor
		endif
	endif
	
	return 0
end

Function LogBiHistSetNBins(XWave, YWave, NBinsX, NBinsY, histWaveName, excludeOutliers [, doClassWave])
	Wave/Z XWave, YWave
	Variable NBinsX, NBinsY
	String histWaveName
	Variable excludeOutliers
	Variable doClassWave
	
	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif

	duplicate/O XWave, Temp__
	Temp__ = log(XWave)
	WaveStats/Q Temp__
	Variable XLeft = V_min
	Variable XRight = V_max
	duplicate/O YWave, Temp__
	Temp__ = log(YWave)
	WaveStats/Q Temp__
	Variable YLeft = V_min
	Variable YRight = V_max
	KillWaves/Z Temp__
	
	Make/O/D/N=(NBinsX, NBinsY) $histWaveName
	Wave histWave = $histWaveName
	Make/O/D/N=(NBinsX+1) $(histWaveName+"_XB")
	Wave xBinWave = $(histWaveName+"_XB")
	Make/O/D/N=(NBinsY+1) $(histWaveName+"_YB")
	Wave yBinWave = $(histWaveName+"_YB")
	
	
	Variable logInc = (XRight - XLeft)/NBinsX
	xBinWave = 10^(XLeft + p*logInc)
	logInc = (YRight - YLeft)/NBinsY
	yBinWave = 10^(YLeft + p*logInc)

	Variable err = GeneralBiHistWave(XWave, YWave, histWave, xBinWave, yBinWave, 0, excludeOutliers, doClassWave=doClassWave)
	if (err)
		return err
	endif
	
	Make/O/N=(NBinsX) $(histWaveName+"_XC")
	Wave xContourWave = $(histWaveName+"_XC")
	Make/O/N=(NBinsY) $(histWaveName+"_YC")
	Wave yContourWave = $(histWaveName+"_YC")
	xContourWave = 10^((log(xBinWave[p] * xBinWave[p+1]))/2)
	yContourWave = 10^((log(yBinWave[p] * yBinWave[p+1]))/2)
	
	return 0
end

Function LogBiHistSetAll(XWave, YWave, XLeft, XRight, NBinsX, YLeft, YRight, NBinsY, histWaveName, Accumulate, excludeOutliers [, doClassWave])
	Wave/Z XWave, YWave
	Variable XLeft, XRight, NBinsX
	Variable YLeft, YRight, NBinsY
	String histWaveName
	Variable Accumulate
	Variable excludeOutliers
	Variable doClassWave
	
	if (!WaveExists(XWave))
		return -1
	endif
	if (!WaveExists(YWave))
		return -2
	endif
	Variable pnts = numpnts(XWave)
	if (pnts != numpnts(YWave))
		return -3
	endif

	Make/D/O/N=(NBinsX, NBinsY) $histWaveName
	Wave histWave = $histWaveName
	Make/D/O/N=(NBinsX+1) $(histWaveName+"_XB")
	Wave xBinWave = $(histWaveName+"_XB")
	Make/D/O/N=(NBinsY+1) $(histWaveName+"_YB")
	Wave yBinWave = $(histWaveName+"_YB")
	
	Variable logInc = (log(XRight) - log(XLeft))/NBinsX
	xBinWave = 10^(log(XLeft) + p*logInc)
	logInc = (log(YRight) - log(YLeft))/NBinsY
	yBinWave = 10^(log(YLeft) + p*logInc)

	Variable err = GeneralBiHistWave(XWave, YWave, histWave, xBinWave, yBinWave, Accumulate, excludeOutliers, doClassWave=doClassWave)
	if (err)
		return err
	endif
	
	Make/D/O/N=(NBinsX) $(histWaveName+"_XC")
	Wave xContourWave = $(histWaveName+"_XC")
	Make/D/O/N=(NBinsY) $(histWaveName+"_YC")
	Wave yContourWave = $(histWaveName+"_YC")
	xContourWave = 10^((log(xBinWave[p] * xBinWave[p+1]))/2)
	yContourWave = 10^((log(yBinWave[p] * yBinWave[p+1]))/2)
	
	return 0
end