#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 1.14		// shipped with Igor 8

#pragma IgorVersion=6.2

#include <Wave Lists>, version >= 2.00
#include <SaveRestoreWindowCoords>

// Enhancements:
//    Make it handle a multi-column wave as the source wave

// version 1.01: 
//	fixed rows/columns menu initialization problem
//	added outliers to box and whisker plot

// version 1.02:
//	fixed inifinite loop that occurred if on category was entirely NaN's
//	made it possible to plot outliers on a category box plot by using a dangerous kludge
//	fixed a bug that caused the Modify Box Plot panel to fail to come forward if it already existed

// version 1.03:
// fixed bug in outlier display; when using a numeric X axis, outliers didn't show up.

// version 1.04:
// Fixed bug in percentile calculation: 100th percentile tried to get a number past the last good value, which could result
// in a value of NaN. Changed percentile calculation to return the number closest to N*q where q is the quantile (percentile/100).
// The median still reports the average of the middle numbers if N is even.
// This change to the closest value will change the results somewhat, since previously the quantiles were interpolated by the fractional
// part of the position number.

// version 1.05:
// Change in syntax for popupmenu value=# required a change for Igor 5px

// version 1.06, JW 100219
// Improved layout a bit
// Quieted menu commands and Execute/P commands that print in the history

// Version 1.07, JW 110922
// Fixed bug in outlier extraction based on percentiles. Previous algorithm extracted one too many points at each end, at least in some cases.

// Version 1.08, JW 130703
// Made category plot version of box plot work better: fixed the left end range at zero to eliminate the wide gap caused by Igor's axis code leaving
// room for error bars.
// Made the line size for the median line zero so that you don't see the trace dot superposed on top of a wide median line.

// Version 1.09, LH 140526
// PanelResolution for compatibility with Igor 7

// Version 1.10, JP 151006
// Top Table choice shows waves that will be selected.

// Version 1.11, JP 160511
// More PanelResolution for compatibility with Igor 7, added SetWindow sizeLimit.

// Version 1.12, JW 161117
// Fixed line 359 so that a group with no data points doesn't report 1 data point.

// Version 1.13, JW 180115
// Added panel about the box plot control panel being obsolete in IP8.

// Version 1.14, JW 190716
// Changed "ModifyBoxPlot" to "DoModifyBoxPlot" to avoid conflict with new built-in operation name.

Menu "Analysis"
	"Calculate Percentiles", /Q, MakeWavePercentilePanel(1)
end
Menu "New"
	"Box Plot (Obsolete Package)", /Q, MakeWavePercentilePanel(0)
end
Menu "Graph"
	"Modify Box Plot", /Q, ShowBoxPlotFormatPanel("Modify")
end

Static Constant DOUBLECLICKTIME = 30
Static Constant DOUBLECLICKSLOP = 5

Proc MakeWavePercentilePanel(DoCalcPercentiles)
	Variable DoCalcPercentiles

	if (WinType("WavePercentilePanel") == 7)
		DoWindow/F WavePercentilePanel
		PCTypeMenuProc("",DoCalcPercentiles+1,"")
	else
		InitWavePercentileGlobals()
		fWavePercentilePanel(DoCalcPercentiles)
	endif
end

// If the values in this function are changed, be sure to change the defaults in PCSetGlobalsToDefaults()
Function InitWavePercentileGlobals()

	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_WavesPercentile
	
	if (Exists("PCWaveSource") != 2)
		Variable/G PCWaveSource=2
	endif
	
	if (Exists("PercentileBaseName") != 2)
		String/G PercentileBaseName="W_Percentile"
	endif
	if (Exists("PercentileList") != 2)
		String/G PercentileList="0;25;50;75;100"
	endif
	if (Exists("PCListExpression") != 2)
		String/G PCListExpression="wave*"
	endif
	String/G WP_ListOfWaves
	
	if (Exists("PercentileType") != 2)
		Variable/G PercentileType=1
	endif
	
	if (Exists("PCBoxTop") != 2)
		Variable/G PCBoxTop=75
	endif
	if (Exists("PCBoxBottom") != 2)
		Variable/G PCBoxBottom=25
	endif
	if (Exists("PCWhiskerTop") != 2)
		Variable/G PCWhiskerTop=90
	endif
	if (Exists("PCWhiskerBottom") != 2)
		Variable/G PCWhiskerBottom=10
	endif
	if (Exists("PCCheckWhiskerTop") != 2)
		Variable/G PCCheckWhiskerTop=1
	endif
	if (Exists("PCCheckWhiskerBottom") != 2)
		Variable/G PCCheckWhiskerBottom=1
	endif

	if (Exists("PCOutliersMethod") != 2)
		Variable/G PCOutliersMethod=0
	endif
	if (Exists("PCOutliersPercentile") != 2)
		Variable/G PCOutliersPercentile=1
	endif
	if (Exists("PCOutliersFactor") != 2)
		Variable/G PCOutliersFactor=1.25
	endif

	// Box Plot formatting options
	// box fill
	if (Exists("PCColoredBoxesCheck") != 2)
		Variable/G PCColoredBoxesCheck=0
	endif
	if (!Exists("PCBoxFillColorRed") != 2)
		Variable/G PCBoxFillColorRed = 50000
	endif
	if (!Exists("PCBoxFillColorGreen") != 2)
		Variable/G PCBoxFillColorGreen = 50000
	endif
	if (!Exists("PCBoxFillColorBlue") != 2)
		Variable/G PCBoxFillColorBlue = 50000
	endif
	
	// box frame
	if (Exists("PCBoxWidth") != 2)
		Variable/G PCBoxWidth=.3			// This is good for a category plot or for point scaling
	endif
	if (Exists("PCBoxFrameThickness") != 2)
		Variable/G PCBoxFrameThickness=1
	endif
	if (!Exists("PCBoxFrameColorRed") != 2)
		Variable/G PCBoxFrameColorRed = 0
	endif
	if (!Exists("PCBoxFrameColorGreen") != 2)
		Variable/G PCBoxFrameColorGreen = 0
	endif
	if (!Exists("PCBoxFrameColorBlue") != 2)
		Variable/G PCBoxFrameColorBlue = 0
	endif
	
	// whiskers
	if (Exists("PCWhiskerCaps") != 2)
		Variable/G PCWhiskerCaps=0
	endif
	if (Exists("PCWhiskerCapWidth") != 2)
		Variable/G PCWhiskerCapWidth=0		// auto
	endif
	if (Exists("PCWhiskerCapThickness") != 2)
		Variable/G PCWhiskerCapThickness=1
	endif
	if (Exists("PCWhiskerThickness") != 2)
		Variable/G PCWhiskerThickness=1
	endif
	if (!Exists("PCWhiskerColorRed") != 2)
		Variable/G PCWhiskerColorRed = 0
	endif
	if (!Exists("PCWhiskerColorGreen") != 2)
		Variable/G PCWhiskerColorGreen = 0
	endif
	if (!Exists("PCWhiskerColorBlue") != 2)
		Variable/G PCWhiskerColorBlue = 0
	endif

	// median line
	if (Exists("PCMedianLineThickness") != 2)
		Variable/G PCMedianLineThickness=1
	endif
	if (!Exists("PCMedianLineColorRed") != 2)
		Variable/G PCMedianLineColorRed = 0
	endif
	if (!Exists("PCMedianLineColorGreen") != 2)
		Variable/G PCMedianLineColorGreen = 0
	endif
	if (!Exists("PCMedianLineColorBlue") != 2)
		Variable/G PCMedianLineColorBlue = 0
	endif
	
	// Outliers
	if (!Exists("PCOutlierMarker") != 2)
		Variable/G PCOutlierMarker = 8
	endif
	if (!Exists("PCOutlierMarkerSize") != 2)
		Variable/G PCOutlierMarkerSize = 0		// auto
	endif
	if (!Exists("PCOutlierColorRed") != 2)
		Variable/G PCOutlierColorRed = 0
	endif
	if (!Exists("PCOutlierColorGreen") != 2)
		Variable/G PCOutlierColorGreen = 0
	endif
	if (!Exists("PCOutlierColorBlue") != 2)
		Variable/G PCOutlierColorBlue = 0
	endif

	if (Exists("PCCheckAppendToGraph") != 2)
		Variable/G PCCheckAppendToGraph=1
	endif
	if (Exists("PCNewPercentileGraph") != 2)
		Variable/G PCNewPercentileGraph=3
	endif
	
	SetDataFolder $SaveDF
end
	
Function UnloadPercentilePackageProc(ctrlName) : ButtonControl
	String ctrlName
	
	if (WinType("BoxPlotFormatting") != 0)
		DoWindow/K BoxPlotFormatting
	endif
	if (WinType("DoModifyBoxPlot") != 0)
		DoWindow/K DoModifyBoxPlot
	endif
	if (WinType("WavePercentilePanel") != 0)
		DoWindow/K WavePercentilePanel
	endif
	if (DatafolderExists("root:Packages:WM_WavesPercentile"))
		KillDataFolder root:Packages:WM_WavesPercentile
	endif
	Execute/P "DELETEINCLUDE <Percentile and Box Plot>";Execute/P "COMPILEPROCEDURES ";
end

Function fWavePercentile(ListOfWaves, PercentileList, PercentileBaseName, RepsAreRows, MakeOutlierWaves, OutlierDistance)
	String ListOfWaves, PercentileList, PercentileBaseName
	Variable RepsAreRows		// if 0: columns represent replicated data; if 1: rows represent replicated data
	Variable MakeOutlierWaves	// 0- don't make outlier wave; 
								// 1- outliers are points whose values are less than OutlierDistance times Median-(first percentile in list) or greater than OutlierDistance times Median-(last percentile in list)
								// 2- outliers are points that are outside the OutlierDistance or 100-OutlierDistance percentiles.
								// 3- outliers are points at a distance from the median greater than OutlierDistance times the interquartile distance
	Variable OutlierDistance
	
	if (strlen(ListOfWaves) <= 1)
		Abort "Waves percentile: You don't have any waves in the list of waves"
	endif
	String theWaveName=StringFromList(0,ListOfWaves, ";")
	Wave w = $theWaveName
	Variable OneWaveLen = DimSize(w,0)
	Variable NWaves, MultiCol=0
	Variable nReps, NCategories
	Variable nextOutlierPoint = 0
	Variable nOutliers, percentileCutoff
	Variable i,j
	Variable lastElement, nPnts
	Variable CutoffTop
	Variable CutoffBottom
	Variable Median
	String PC
	
	Variable NPercentiles = CountListItems(PercentileList, ";")
	if (WaveDims(w) == 2)
		NWaves = DimSize(w, 1)
		if (RepsAreRows)
			nReps = DimSize(w,1)
			NCategories = DimSize(w,0)
		else
			nReps = DimSize(w,0)
			NCategories = DimSize(w,1)
		endif
		MultiCol=1
	else
		NWaves = CountListItems(ListOfWaves, ";")
		if (RepsAreRows)
			nReps = NWaves
			NCategories = 0
		else
			NCategories = NWaves
			nReps = 0
		endif
		for (i = 0; i < NWaves; i += 1)
			theWaveName=StringFromList(i,ListOfWaves, ";")
			Wave w = $theWaveName
			if (RepsAreRows)
				NCategories = max(DimSize(w, 0), NCategories)
			else
				nReps = max(DimSize(w, 0), nReps)
			endif
		endfor
	endif
	
	Make/D/O/N=(nReps) TempSort
	Make/D/O/N=(NCategories, nReps) TempMatrix=NaN	// any unused cells will be NaN after we're done
	Make/D/O/N=(NPercentiles) TmpPercentiles
	Make/O/N=(NPercentiles)/T PCNames
	i = 0
	do
		PC = StringFromList(i, PercentileList, ";")
		TmpPercentiles[i] = str2num(PC)/100
		PCNames[i] = PercentileBaseName+"_"+PC
		Make/O/N=(NCategories) $(PCNames[i])
		i += 1
	while(i < NPercentiles)
	
	sort TmpPercentiles, TmpPercentiles, PCNames		// so the smallest is always first and the largest is always last
	if (MakeOutlierWaves)
		Make/N=0/O $(PercentileBaseName+"OUT"), $(PercentileBaseName+"OUTX")
		WAVE out = $(PercentileBaseName+"OUT")
		WAVE outx = $(PercentileBaseName+"OUTX")
	endif
	
	if (MultiCol)
		if (RepsAreRows)
			TempMatrix = w
		else
			TempMatrix = w[q][p]
		endif
	else
		i = 0
		do
			theWaveName = StringFromList(i,ListOfWaves, ";")
			Wave w = $theWaveName
			lastElement = numpnts(w)-1
			if (RepsAreRows)
				TempMatrix[0,lastElement][i] = w[p]
			else
				TempMatrix[i][0,lastElement] = w[q]
			endif
			i += 1
		while (i < NWaves)
	endif
	
	nPnts = nReps
	lastElement = nPnts-1
	Make/O/N=(NCategories) $(PercentileBaseName+"_N")
	Wave NRepsWave = $(PercentileBaseName+"_N")
	for (i = 0; i < NCategories; i += 1)
		TempSort = TempMatrix[i][p]
		sort TempSort,TempSort			// sorts NaN to the end, among other things
tempMatrix[i][] = tempsort[q]
		nReps = nPnts
		if (numtype(TempSort[lastElement]) != 0)
			for (j = lastElement; ((j >= 0) != 0) && numtype(TempSort[j]); j -= 1)
			endfor
			nReps = j+1
		endif
		NRepsWave[i] = nReps
		for (j=0; j < NPercentiles; j += 1)
			Wave PCWave = $(PCNames[j])
			// the following corresponds to Q3 on http://mathworld.wolfram.com/Quantile.html
			
			// This combined with Igor's auto interpolation results in the standard definition of the median:
			// 		if N is even, average the two middle values; if N is odd, take the middle value.
//			percentileCutoff = TmpPercentiles[j]*nReps - 0.5
//			// for percentiles other than 0.5 (the median) we simply pick the value whose sequence number is
//			// closest to N*quantile. This also guarantees that the 1 quantile (100th percentile) takes the last good number,
//			// not the next number past the last good number.
//			if (TmpPercentiles[j] != 0.5)
//				percentileCutoff = floor(percentileCutoff)
//				if (percentileCutoff > nReps-1)
//					percentileCutoff = nReps - 1
//				endif
//			endif

			// This is the formula advocated by NIST on http://www.itl.nist.gov/div898/handbook/prc/section2/prc252.htm
			// It corresponds to Q6 on the URL above.
			percentileCutoff = TmpPercentiles[j]*(nReps+1) - 1
			if (percentileCutoff < 0)
				percentileCutoff = 0
			elseif (percentileCutoff > nReps-1)
				percentileCutoff = nReps-1
			endif
			
			// According to NIST, Excel uses this which corresponds to Q7 on the mathworld web site.
//			percentileCutoff = TmpPercentiles[j]*(nReps-1)
//			if (percentileCutoff < 0)
//				percentileCutoff = 0
//			elseif (percentileCutoff > nReps-1)
//				percentileCutoff = nReps-1
//			endif
			
			PCWave[i] = TempSort[percentileCutoff]
		endfor
		switch(MakeOutlierWaves)
			case 1:
				Median = TempSort[(0.5*nReps+0.5)-1]
				CutoffTop = Median+(TempSort[(TmpPercentiles[NPercentiles-1]*nReps+0.5)-1]-Median)*outlierDistance
				CutoffBottom = Median-(Median-TempSort[(TmpPercentiles[0]*nReps+0.5)-1])*outlierDistance
				for (j=0; j < numpnts(TempSort); j += 1)
					if ( (TempSort[j] >= CutoffTop) || (TempSort[j] <= CutoffBottom) )
						InsertPoints nextOutlierPoint, 1, out, outx
						out[nextOutlierPoint] = TempSort[j]
						outx[nextOutlierPoint] = i
						nextOutlierPoint += 1
					endif
				endfor
				break
			case 2:
				// This uses the forumula used above to compute the data values corresponding to 100-p and p percentiles. Then
				// it uses Extract to get the data values that are larger and smaller than those data values. Kind of indirect and brute-force,
				// but it works reliably and maybe faster because it uses built-in operations for extraction and concatenation
				Variable hiCutoff = (1-outlierDistance/100)*(nReps+1) - 1
				if (hiCutoff < 0)
					hiCutoff = 0
				elseif (hiCutoff > nReps-1)
					hiCutoff = nReps-1
				endif
				hiCutoff = TempSort[hiCutoff]
				Variable lowCutoff = (outlierDistance/100)*(nReps+1) - 1
				if (lowCutoff < 0)
					lowCutoff = 0
				elseif (lowCutoff > nReps-1)
					lowCutoff = nReps-1
				endif
				lowCutoff = TempSort[lowCutoff]
				Extract/O/FREE TempSort, extractedData, TempSort < lowCutoff || TempSort > hiCutoff
				Concatenate/NP {extractedData}, out
				extractedData = i
				Concatenate/NP {extractedData}, outx
				break
			case 3:
				Median = TempSort[(0.5*nReps+0.5)-1]
				Variable Q25 = TempSort[(0.25*nReps+0.5)-1]
				Variable Q75 = TempSort[(0.75*nReps+0.5)-1]
				Variable Distance = outlierDistance*(Q75-Q25)
				CutoffTop = Median+Distance
				CutoffBottom = Median-Distance
				for (j=0; j < numpnts(TempSort); j += 1)
					if ( (TempSort[j] >= CutoffTop) || (TempSort[j] <= CutoffBottom) )
						InsertPoints nextOutlierPoint, 1, out, outx
						out[nextOutlierPoint] = TempSort[j]
						outx[nextOutlierPoint] = i
						nextOutlierPoint += 1
					endif
				endfor
				break
		endswitch	
	endfor
end

Function CountListItems(theList, sep)
	String theList, sep
	
	Variable i=0
	do
		if (strlen(StringFromList(i, theList,sep)) == 0)
			break
		endif
		i += 1
	while (1)
	
	return i
end

// 000823 sets wave note with database of wave names, trace names and formatting values
// returns zero for success, -1 for failure
Function fBoxPlot(median, boxTop, boxBottom, whiskerTop, whiskerBottom, XWave, BoxWidth, ColoredBoxes, OUTY, OUTX, FillRed, FillGreen, FillBlue)
	WAVE/Z median, boxTop, boxBottom, whiskerTop, whiskerBottom
	WAVE/Z XWave		// if null wave, use X scaling, which will be point scaling.
	Variable BoxWidth	// width of the box part of the display, in X units of the X wave.
	Variable ColoredBoxes // setting this to non-zero puts a colored rectangle behind each box. You can color them individually if you want.
	WAVE/Z OUTY, OUTX
	Variable FillRed, FillGreen, FillBlue
	
	String WName, WCompleteName, medianCompleteName, medianName
	String GraphNote=""
	
	GraphNote += "BOXWIDTH="+num2str(BoxWidth)+";"
	if (ColoredBoxes)
		GraphNote += "COLOREDBOXES=1;"
	else
		GraphNote += "COLOREDBOXES=0;"
	endif
	GraphNote += "FILLRED="+Num2str(FillRed)+";"
	GraphNote += "FILLGREEN="+Num2str(FillGreen)+";"
	GraphNote += "FILLBLUE="+Num2str(FillBlue)+";"
	
	if (!WaveExists(median))
		DoAlert 0, "The median wave does not exists"
		return -1
	endif
	if (!WaveExists(boxTop))
		DoAlert 0,  "The wave giving the tops of the boxes does not exist"
		return -1
	endif
	if (!WaveExists(boxBottom))
		DoAlert 0,  "The wave giving the bottoms of the boxes does not exist"
		return -1
	endif
	
	medianCompleteName = GetWavesDataFolder(median, 2)
	medianName = NameOfWave(median)
	Variable nWavePnts=numpnts(median)
	String boxTopCompleteName = GetWavesDataFolder(boxTop, 2)
	String boxBottomCompleteName = GetWavesDataFolder(boxBottom, 2)
	
	GraphNote += "MEDIANWAVE="+medianCompleteName+";"
	GraphNote += "BOXTOPWAVE="+boxTopCompleteName+";"
	GraphNote += "BOXBOTTOMWAVE="+boxBottomCompleteName+";"
	
	if (!WaveExists(boxTop))
		DoAlert 0,  "The wave specifying the tops of the boxes does not exist"
		return -1
	endif
	if (numpnts(boxTop) != nWavePnts)
		DoAlert 0,  "The wave "+NameOfWave(boxTop)+" does not have the same number of points as "+NameOfWave(median)
		return -1
	endif
		
	if (!WaveExists(boxBottom))
		DoAlert 0,  "The wave specifying the bottoms of the boxes does not exist"
		return -1
	endif
	if (numpnts(boxBottom) != nWavePnts)
		DoAlert 0,  "The wave "+NameOfWave(boxBottom)+" does not have the same number of points as "+NameOfWave(median)
		return -1
	endif
		
	// make a dependency formula for the error bar wave for the box tops
	WName = NameOfWave(boxTop)
	WCompleteName = GetWavesDataFolder(boxTop,2)
	Duplicate/O boxTop, $(WName+"EB")
	Wave boxTopEB = $(WName+"EB")
	SetFormula boxTopEB, WCompleteName+"-"+medianCompleteName
	
	GraphNote += "BOXTOPEBWAVE="+GetWavesDataFolder(boxTopEB,2)+";"
	
	// make a dependency formula for the error bar wave for the box bottoms
	WName = NameOfWave(boxBottom)
	WCompleteName = GetWavesDataFolder(boxBottom,2)
	Duplicate/O boxBottom, $(WName+"EB")
	Wave boxBottomEB = $(WName+"EB")
	SetFormula boxBottomEB, medianCompleteName+"-"+WCompleteName
	
	GraphNote += "BOXBOTTOMEBWAVE="+GetWavesDataFolder(boxBottomEB,2)+";"
	
	if (WaveExists(whiskerTop))
		// make a dependency formula for the error bar wave for the whisker tops
		WName = NameOfWave(whiskerTop)
		WCompleteName = GetWavesDataFolder(whiskerTop,2)
		Duplicate/O whiskerTop, $(WName+"EB")
		Wave whiskerTopEB = $(WName+"EB")
		SetFormula whiskerTopEB, WCompleteName+"-"+boxTopCompleteName
	
		GraphNote += "WHISKERTOPEBWAVE="+GetWavesDataFolder(whiskerTopEB,2)+";"
	else
		GraphNote += "WHISKERTOPEBWAVE=_NONE_;"
	endif
	
	if (WaveExists(whiskerBottom))
		// make a dependency formula for the error bar wave for the whisker bottoms
		WName = NameOfWave(whiskerBottom)
		WCompleteName = GetWavesDataFolder(whiskerBottom,2)
		Duplicate/O whiskerBottom, $(WName+"EB")
		Wave whiskerBottomEB = $(WName+"EB")
		SetFormula whiskerBottomEB, boxBottomCompleteName+"-"+WCompleteName
	
		GraphNote += "WHISKERBOTTOMEBWAVE="+GetWavesDataFolder(whiskerBottomEB,2)+";"
	else
		GraphNote += "WHISKERBOTTOMEBWAVE=_NONE_;"
	endif
	
	// now make the graph
	String gname=""
	if (WaveExists(XWave))
		Display median vs XWave
		gname = s_name
		AppendToGraph/W=$gname median vs XWave
		AppendToGraph/W=$gname boxTop vs XWave
		AppendToGraph/W=$gname boxBottom vs XWave
		GraphNote += "XWAVE="+GetWavesDatafolder(XWave,2)+";"
	else
		Display median, median, boxTop, boxBottom
		gname = s_name
		GraphNote += "XWAVE=_NONE_;"
	endif

	GraphNote += "BOXTRACE="+medianName+"#1;"
	GraphNote += "MEDIANLINETRACE="+medianName+";"

	ModifyGraph/W=$gname mode=2,lsize=0
	ErrorBars/W=$gname/L=0 $(medianName+"#1") BOX,const=(BoxWidth),wave=(boxTopEB,boxBottomEB)
	ErrorBars/W=$gname/T=0 $(medianName) X,const=(BoxWidth)
	if (WaveExists(whiskerBottom))
		ErrorBars/W=$gname/T=0 $(NameOfWave(boxBottom)) Y,wave=(,whiskerBottomEB)
		GraphNote += "WHISKERBOTTOMTRACE="+NameOfWave(boxBottom)+";"
	else
		GraphNote += "WHISKERBOTTOMTRACE=_NONE_;"
	endif
	if (WaveExists(whiskerTop))
		ErrorBars/W=$gname/T=0 $(NameOfWave(boxTop)) Y,wave=(whiskerTopEB,)
		GraphNote += "WHISKERTOPTRACE="+NameOfWave(boxTop)+";"
	else
		GraphNote += "WHISKERTOPTRACE=_NONE_;"
	endif
	if ( WaveExists(XWave) %& (WaveType(XWave) == 0) )
		ModifyGraph/W=$gname toMode=-1
	endif
	if (WaveExists(OUTY) && WaveExists(OUTX))
		if (WaveExists(XWave))
			OUTX = XWave[OUTX[p]]
		endif
		if (WaveExists(XWave) && (WaveType(XWave) == 0))		// Added WaveExists() 040227. Turns out WaveType(NULL) = 0!
			AppendToGraph/W=$gname/T OUTY vs OUTX
		else
			AppendToGraph/W=$gname OUTY vs OUTX
		endif
		ModifyGraph/W=$gname mode($NameOfWave(OUTY))=3,marker($NameOfWave(OUTY))=8
		if (WaveExists(XWave) && (WaveType(XWave) == 0))		// Added WaveExists() 040227. Turns out WaveType(NULL) = 0!
			// we're making a category X axis
			SetAxis/W=$gname bottom 0,*
			SetAxis/W=$gname top -0.5, numpnts(XWave)-.5	// I have a bad feeling about this...
			ModifyGraph/W=$gname noLabel(top)=2,axThick(top)=0
		endif
		GraphNote += "OUTLIERWAVEY="+GetWavesDataFolder(OUTY, 2)+";"
		GraphNote += "OUTLIERWAVEX="+GetWavesDataFolder(OUTX, 2)+";"
		GraphNote += "OUTLIERTRACE="+NameOfWave(OUTY)+";"
	else
		GraphNote += "OUTLIERWAVEY=_NONE_;"
		GraphNote += "OUTLIERWAVEX=_NONE_;"
		GraphNote += "OUTLIERTRACE=_NONE_;"
	endif
	SetWindow $gname, note=GraphNote
	DoUpdate
	BoxPlotColorBoxes(gname)
	return 0
end

Function BoxPlotColorBoxes(GraphName)
	String GraphName
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	
	Variable ColoredBoxes = NumberByKey("COLOREDBOXES", GraphNote, "=", ";")
	if (NumType(ColoredBoxes) != 0)
		return -1
	endif
	if (ColoredBoxes)
		// extract info from window note
		String medianWaveName = StringByKey("MEDIANWAVE", GraphNote, "=", ";")
		Wave/Z median=$medianWaveName
		if (!WaveExists(median))
			return -2
		endif
		String X_WaveName = StringByKey("XWAVE", GraphNote, "=", ";")
		Wave/Z XWave = $X_WaveName
		Variable BoxWidth = NumberByKey("BOXWIDTH", GraphNote, "=", ";")
		if (numtype(BoxWidth) != 0)
			return -3
		endif
		String BoxTopWave = StringByKey("BOXTOPWAVE", GraphNote, "=", ";")
		Wave/Z boxTop = $BoxTopWave
		if (!WaveExists(boxTop))
			return -4
		endif
		String BoxBottomWave = StringByKey("BOXBOTTOMWAVE", GraphNote, "=", ";")
		Wave/Z boxBottom = $BoxBottomWave
		if (!WaveExists(boxBottom))
			return -4
		endif
		Variable FillRed = NumberByKey("FILLRED", GraphNote, "=", ";")
		if (NumType(FillRed) != 0)
			return -1
		endif
		Variable FillGreen = NumberByKey("FILLGREEN", GraphNote, "=", ";")
		if (NumType(FillGreen) != 0)
			return -1
		endif
		Variable FillBlue = NumberByKey("FILLBLUE", GraphNote, "=", ";")
		if (NumType(FillBlue) != 0)
			return -1
		endif
		
		Variable NBoxes=numpnts(median)
		Variable i=0
		Variable left, right
		SetDrawLayer/W=$GraphName/K UserAxes
		do
			if ( (WaveExists(XWave) %& (WaveType(XWave) != 0)) )
				left = XWave[i]-BoxWidth
				right = XWave[i]+BoxWidth
			else
				Variable Offset = .5*WaveExists(XWave)
				left = i-BoxWidth+Offset
				right = 	i+BoxWidth+Offset
			endif
			SetDrawLayer/W=$GraphName UserAxes
			SetDrawEnv/W=$GraphName fillfgc=(FillRed, FillGreen, FillBlue),fillpat=1,xcoord=bottom, ycoord=left, linethick=0
			DrawPoly/W=$GraphName left, boxTop[i], 1, 1, {left, boxTop[i], right, boxTop[i], right, boxBottom[i], left, boxBottom[i]}
			i += 1
		while (i < NBoxes)
	else
		SetDrawLayer/W=$GraphName/K UserAxes
	endif
	
	return 0
end

Function BoxPlotChangeBoxWidth(GraphName, NewWidth, presentWidth)
	String GraphName
	Variable NewWidth
	Variable presentWidth
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	if (strlen(GraphNote) == 0)
		return -1
	endif
	if (presentWidth != NewWidth)
		Variable/G root:Packages:WM_WavesPercentile:PCBoxWidth
		GraphNote =ReplaceNumberByKey("BOXWIDTH", GraphNote, NewWidth,"=", ";")
		SetWindow $GraphName, note=GraphNote
		BoxPlotApplyStoredTraceOptions(GraphName)
		BoxPlotColorBoxes(GraphName)
		String X_WaveName = StringByKey("XWAVE", GraphNote, "=", ";")
		String outlierY = StringByKey("OUTLIERWAVEY", GraphNote, "=", ";")
		Wave/Z XWave = $X_WaveName
		if ( WaveExists(XWave) && (WaveType(XWave) == 0) && CmpStr(outlierY, "_NONE_") != 0)
			SetAxis/W=$GraphName top -.5, numpnts(XWave)-.5	// I have a bad feeling about this...
		endif
	endif
end

Function BoxPlotChangeBoxFillColor(graphName, DoFill, red, green, blue)
	String graphName
	Variable DoFill
	Variable red, green, blue
	
	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	if (strlen(GraphNote) == 0)
		return -1
	endif
	Variable PresentRed = NumberByKey("FILLRED", GraphNote, "=", ";")
	if (numtype(PresentRed) != 0)
		return -2
	endif
	GraphNote = ReplaceNumberByKey("COLOREDBOXES", GraphNote, DoFill, "=", ";")
	GraphNote = ReplaceNumberByKey("FILLRED", GraphNote, red, "=", ";")
	GraphNote = ReplaceNumberByKey("FILLGREEN", GraphNote, green, "=", ";")
	GraphNote = ReplaceNumberByKey("FILLBLUE", GraphNote, blue, "=", ";")
	SetWindow $GraphName, note=GraphNote
	BoxPlotColorBoxes(GraphName)
end

Function BoxPlotSetupFormatting(GraphName)
	String GraphName
	

	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	if (strlen(GraphNote) == 0)
		return -1
	endif
	
	// Now do the other colored parts of the graph
	NVAR/Z PCBoxFrameColorRed = root:Packages:WM_WavesPercentile:PCBoxFrameColorRed
	NVAR/Z PCBoxFrameColorGreen = root:Packages:WM_WavesPercentile:PCBoxFrameColorGreen
	NVAR/Z PCBoxFrameColorBlue = root:Packages:WM_WavesPercentile:PCBoxFrameColorBlue
	NVAR/Z PCWhiskerColorRed = root:Packages:WM_WavesPercentile:PCWhiskerColorRed
	NVAR/Z PCWhiskerColorGreen = root:Packages:WM_WavesPercentile:PCWhiskerColorGreen
	NVAR/Z PCWhiskerColorBlue = root:Packages:WM_WavesPercentile:PCWhiskerColorBlue
	NVAR/Z PCMedianLineColorRed = root:Packages:WM_WavesPercentile:PCMedianLineColorRed
	NVAR/Z PCMedianLineColorGreen = root:Packages:WM_WavesPercentile:PCMedianLineColorGreen
	NVAR/Z PCMedianLineColorBlue = root:Packages:WM_WavesPercentile:PCMedianLineColorBlue
	NVAR/Z PCOutlierColorRed = root:Packages:WM_WavesPercentile:PCOutlierColorRed
	NVAR/Z PCOutlierColorGreen = root:Packages:WM_WavesPercentile:PCOutlierColorGreen
	NVAR/Z PCOutlierColorBlue = root:Packages:WM_WavesPercentile:PCOutlierColorBlue
	GraphNote =ReplaceNumberByKey("FRAMECOLORRED", GraphNote, PCBoxFrameColorRed,"=", ";")
	GraphNote =ReplaceNumberByKey("FRAMECOLORGREEN", GraphNote, PCBoxFrameColorGreen,"=", ";")
	GraphNote =ReplaceNumberByKey("FRAMECOLORBLUE", GraphNote, PCBoxFrameColorBlue,"=", ";")
	GraphNote =ReplaceNumberByKey("WHISKERCOLORRED", GraphNote, PCWhiskerColorRed,"=", ";")
	GraphNote =ReplaceNumberByKey("WHISKERCOLORGREEN", GraphNote, PCWhiskerColorGreen,"=", ";")
	GraphNote =ReplaceNumberByKey("WHISKERCOLORBLUE", GraphNote, PCWhiskerColorBlue,"=", ";")
	GraphNote =ReplaceNumberByKey("MEDIANLINECOLORRED", GraphNote, PCMedianLineColorRed,"=", ";")
	GraphNote =ReplaceNumberByKey("MEDIANLINECOLORGREEN", GraphNote, PCMedianLineColorGreen,"=", ";")
	GraphNote =ReplaceNumberByKey("MEDIANLINECOLORBLUE", GraphNote, PCMedianLineColorBlue,"=", ";")
	GraphNote =ReplaceNumberByKey("OUTLIERCOLORRED", GraphNote, PCOutlierColorRed,"=", ";")
	GraphNote =ReplaceNumberByKey("OUTLIERCOLORGREEN", GraphNote, PCOutlierColorGreen,"=", ";")
	GraphNote =ReplaceNumberByKey("OUTLIERCOLORBLUE", GraphNote, PCOutlierColorBlue,"=", ";")
	
	// Now the other trace formatting options
	NVAR/Z PCBoxFrameThickness = root:Packages:WM_WavesPercentile:PCBoxFrameThickness
	GraphNote =ReplaceNumberByKey("BOXFRAMETHICKNESS", GraphNote, PCBoxFrameThickness,"=", ";")
	NVAR/Z PCBoxWidth = root:Packages:WM_WavesPercentile:PCBoxWidth
	GraphNote =ReplaceNumberByKey("BOXWIDTH", GraphNote, PCBoxWidth,"=", ";")
	NVAR/Z PCWhiskerCaps = root:Packages:WM_WavesPercentile:PCWhiskerCaps
	GraphNote =ReplaceNumberByKey("WHISKERCAPS", GraphNote, PCWhiskerCaps,"=", ";")
	NVAR/Z PCWhiskerCapWidth = root:Packages:WM_WavesPercentile:PCWhiskerCapWidth
	GraphNote =ReplaceNumberByKey("WHISKERCAPWIDTH", GraphNote, PCWhiskerCapWidth,"=", ";")
	NVAR/Z PCWhiskerCapThickness = root:Packages:WM_WavesPercentile:PCWhiskerCapThickness
	GraphNote =ReplaceNumberByKey("WHISKERCAPTHICKNESS", GraphNote, PCWhiskerCapThickness,"=", ";")
	NVAR/Z PCWhiskerThickness = root:Packages:WM_WavesPercentile:PCWhiskerThickness
	GraphNote =ReplaceNumberByKey("WHISKERTHICKNESS", GraphNote, PCWhiskerThickness,"=", ";")
	NVAR/Z PCMedianLineThickness = root:Packages:WM_WavesPercentile:PCMedianLineThickness
	GraphNote =ReplaceNumberByKey("MEDIANLINETHICKNESS", GraphNote, PCMedianLineThickness,"=", ";")
	NVAR/Z PCOutlierMarker = root:Packages:WM_WavesPercentile:PCOutlierMarker
	GraphNote =ReplaceNumberByKey("OUTLIERMARKER", GraphNote, PCOutlierMarker,"=", ";")
	NVAR/Z PCOutlierMarkerSize = root:Packages:WM_WavesPercentile:PCOutlierMarkerSize
	GraphNote =ReplaceNumberByKey("OUTLIERMARKERSIZE", GraphNote, PCOutlierMarkerSize,"=", ";")
	
	SetWindow $GraphName, note=GraphNote
end

Function BoxPlotApplyStoredColors(GraphName)
	String GraphName

	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	if (strlen(GraphNote) == 0)
		return -1
	endif
	
	// Box frame
	Variable Red = NumberByKey("FRAMECOLORRED", GraphNote, "=", ";")
	Variable Green = NumberByKey("FRAMECOLORGREEN", GraphNote, "=", ";")
	Variable Blue = NumberByKey("FRAMECOLORBLUE", GraphNote, "=", ";")
	String Trace = StringByKey("BOXTRACE", GraphNote, "=", ";")
	if ( (CmpStr(Trace, "_NONE_") != 0) && (numtype(Red)==0) && (numtype(Green)==0) && (numtype(Blue)==0) )
		ModifyGraph/W=$GraphName rgb($Trace)=(Red, Green, Blue)
	endif

	// median line
	Trace = StringByKey("MEDIANLINETRACE", GraphNote, "=", ";")
	Red = NumberByKey("MEDIANLINECOLORRED", GraphNote, "=", ";")
	Green = NumberByKey("MEDIANLINECOLORGREEN", GraphNote, "=", ";")
	Blue = NumberByKey("MEDIANLINECOLORBLUE", GraphNote, "=", ";")
	if ( (CmpStr(Trace, "_NONE_") != 0) && (numtype(Red)==0) && (numtype(Green)==0) && (numtype(Blue)==0) )
		ModifyGraph/W=$GraphName rgb($Trace)=(Red, Green, Blue)
	endif
	
	// whiskers 
	Red = NumberByKey("WHISKERCOLORRED", GraphNote, "=", ";")
	Green = NumberByKey("WHISKERCOLORGREEN", GraphNote, "=", ";")
	Blue = NumberByKey("WHISKERCOLORBLUE", GraphNote, "=", ";")
	Trace = StringByKey("WHISKERBOTTOMTRACE", GraphNote, "=", ";")
	if ( (CmpStr(Trace, "_NONE_") != 0) && (numtype(Red)==0) && (numtype(Green)==0) && (numtype(Blue)==0) )
		ModifyGraph/W=$GraphName rgb($Trace)=(Red, Green, Blue)
	endif
	Trace = StringByKey("WHISKERTOPTRACE", GraphNote, "=", ";")
	if ( (CmpStr(Trace, "_NONE_") != 0) && (numtype(Red)==0) && (numtype(Green)==0) && (numtype(Blue)==0) )
		ModifyGraph/W=$GraphName rgb($Trace)=(Red, Green, Blue)
	endif
	
	// outliers 
	Red = NumberByKey("OUTLIERCOLORRED", GraphNote, "=", ";")
	Green = NumberByKey("OUTLIERCOLORGREEN", GraphNote, "=", ";")
	Blue = NumberByKey("OUTLIERCOLORBLUE", GraphNote, "=", ";")
	Trace = StringByKey("OUTLIERTRACE", GraphNote, "=", ";")
	if ( (CmpStr(Trace, "_NONE_") != 0) && (numtype(Red)==0) && (numtype(Green)==0) && (numtype(Blue)==0) )
		ModifyGraph/W=$GraphName rgb($Trace)=(Red, Green, Blue)
	endif
end

Function BoxPlotApplyStoredTraceOptions(GraphName)
	String GraphName

	if (strlen(GraphName) == 0)
		GraphName = WinName(0,1)
	endif
	GetWindow $GraphName,note
	String GraphNote = S_value
	if (strlen(GraphNote) == 0)
		return -1
	endif
	
	Variable Thickness = NumberByKey("BOXFRAMETHICKNESS", GraphNote, "=", ";")
	Variable Width = NumberByKey("BOXWIDTH", GraphNote, "=", ";")
	String Trace = StringByKey("BOXTRACE", GraphNote, "=", ";")
	String theWaveName = StringByKey("BOXBOTTOMEBWAVE", GraphNote, "=", ";")
	Wave/Z boxBottomEB = $theWaveName
	theWaveName = StringByKey("BOXTOPEBWAVE", GraphNote, "=", ";")
	Wave/Z boxTopEB = $theWaveName
	if ( (strlen(Trace)>0) && (CmpStr(Trace, "_NONE_") != 0) && (numtype(Thickness)==0) && (numtype(Width)==0) && WaveExists(boxBottomEB) && WaveExists(boxTopEB) )
		ErrorBars/W=$GraphName/L=0/T=(Thickness) $Trace BOX,const=(Width),wave=(boxTopEB,boxBottomEB)
	endif

	Variable CapThickness = NumberByKey("WHISKERCAPTHICKNESS", GraphNote, "=", ";")
	Thickness = NumberByKey("WHISKERTHICKNESS", GraphNote, "=", ";")
	Width = NumberByKey("WHISKERCAPWIDTH", GraphNote, "=", ";")
	Variable DoCaps = NumberByKey("WHISKERCAPS", GraphNote, "=", ";")
	CapThickness = DoCaps ? CapThickness : 0
	theWaveName = StringByKey("WHISKERBOTTOMEBWAVE", GraphNote, "=", ";")
	Wave/Z whiskerBottomEB = $theWaveName
	Trace = StringByKey("WHISKERBOTTOMTRACE", GraphNote, "=", ";")
	if ( (strlen(Trace)>0) && (CmpStr(Trace, "_NONE_") != 0) && (numtype(Thickness)==0) && (numtype(Width)==0) && (numtype(CapThickness)==0) && WaveExists(whiskerBottomEB) )
		ErrorBars/W=$GraphName/T=(CapThickness)/L=(Thickness)/Y=(Width) $Trace Y,wave=(,whiskerBottomEB)
	endif
	theWaveName = StringByKey("WHISKERTOPEBWAVE", GraphNote, "=", ";")
	Wave/Z whiskerTopEB = $theWaveName
	Trace = StringByKey("WHISKERTOPTRACE", GraphNote, "=", ";")
	if ( (strlen(Trace)>0) && (CmpStr(Trace, "_NONE_") != 0) && (numtype(Thickness)==0) && (numtype(Width)==0) && (numtype(CapThickness)==0) && WaveExists(whiskerTopEB) )
		ErrorBars/W=$GraphName/T=(CapThickness)/L=(Thickness)/Y=(Width) $Trace Y,wave=(whiskerTopEB,)
	endif
	
	Thickness = NumberByKey("MEDIANLINETHICKNESS", GraphNote, "=", ";")
	Width = NumberByKey("BOXWIDTH", GraphNote, "=", ";")
	Trace = StringByKey("MEDIANLINETRACE", GraphNote, "=", ";")
	if ( (strlen(Trace)>0) && (CmpStr(Trace, "_NONE_") != 0) && (numtype(Thickness)==0) && (numtype(Width)==0) )
		ErrorBars/W=$GraphName/T=0/L=(Thickness) $Trace X,const=(Width)
	endif

	Variable Marker = NumberByKey("OUTLIERMARKER", GraphNote, "=", ";")
	Variable MarkerSize = NumberByKey("OUTLIERMARKERSIZE", GraphNote, "=", ";")
	Trace = StringByKey("OUTLIERTRACE", GraphNote, "=", ";")
	if ( (strlen(Trace)>0) && (CmpStr(Trace, "_NONE_") != 0) )
		if (numtype(Marker)==0)
			ModifyGraph/W=$GraphName marker($Trace)=Marker
		endif
		if (numtype(MarkerSize)==0)
			ModifyGraph/W=$GraphName msize($Trace)=MarkerSize
		endif
	endif
end

static constant bestWidth = 240 // panel units
static constant bestHeight = 450
static constant defaultLeft= 50
static constant defaultTop= 100

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

static Function SavedPanelTopLeftPanelUnits(win, defaultLeftPU, defaultTopPU)
	String win
	Variable &defaultLeftPU, &defaultTopPU	// "PU" = Panel Units
	
	Variable savedLeft, savedTop, savedRight, savedBottom
	if( WC_WindowCoordinatesGetNums(win, savedLeft, savedTop, savedRight, savedBottom) )
		Variable PointsToPanelUnits= ScreenResolution / PanelResolution(win)
		defaultLeftPU = savedLeft * PointsToPanelUnits
		defaultTopPU = savedTop * PointsToPanelUnits
	endif
End

Function fWavePercentilePanel(DoCalcPercentiles)
	Variable DoCalcPercentiles

	Variable savedLeft= defaultLeft	// panel units
	Variable savedTop= defaultTop
	SavedPanelTopLeftPanelUnits("WavePercentilePanel", savedLeft, savedTop)
	Variable savedRight= savedLeft+bestWidth
	Variable savedBottom= savedTop+bestHeight

	DoWindow/K WavePercentilePanel
	NewPanel/K=1/W=(savedLeft, savedTop, savedRight, savedBottom)/N=WavePercentilePanel as "Wave Percentiles"
//	ModifyPanel/W=WavePercentilePanel fixedSize=1	// don't cut off list of table's wave names
#if IgorVersion() >= 7
	Variable PanelUnitsToPoints= PanelResolution("WavePercentilePanel") / ScreenResolution
	Variable minWidthPoints= bestWidth * PanelUnitsToPoints
	Variable minHeightPoints= bestHeight * PanelUnitsToPoints
	SetWindow WavePercentilePanel sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#endif
	ModifyPanel/W=WavePercentilePanel noEdit=1
	
	NVAR PercentileType = root:Packages:WM_WavesPercentile:PercentileType
	NVAR PCWaveSource = root:Packages:WM_WavesPercentile:PCWaveSource
	PercentileType = DoCalcPercentiles+1
	
	TitleBox PercentileSelectWavesTitle,pos={5,6},size={78,16},title="Select Waves"
	TitleBox PercentileSelectWavesTitle,fSize=12,frame=0,fStyle=1

	TitleBox PercentileWhatToDoTitle,pos={5,94},size={69,16},title="What to do:"
	TitleBox PercentileWhatToDoTitle,fSize=12,frame=0,fStyle=1

	TitleBox PercentileReplicatesAreTitle,pos={30,71},size={67,13},title="Replicates are"
	TitleBox PercentileReplicatesAreTitle,fSize=10,frame=0

	TitleBox PercentileDestinationBaseTitle,pos={5,355},size={137,16},title="Destination Base Name:"
	TitleBox PercentileDestinationBaseTitle,fSize=12,frame=0,fStyle=1

	PopupMenu PCWaveSourceMenu,pos={30,23},size={125,19},proc=PCWaveFromMenuProc
	PopupMenu PCWaveSourceMenu,mode=PCWaveSource,value= #"\"by Name;from Top Graph;from Top Table\""
	PopupMenu PCRowsOrColumns,pos={101,68},size={60,19}
	PopupMenu PCRowsOrColumns,mode=2,value= #"\"Columns;Rows;\""
	SetVariable SetPercentileBaseName,pos={29,373},size={140,15},title=" ",fSize=10
	SetVariable SetPercentileBaseName,limits={-Inf,Inf,1},value= root:Packages:WM_WavesPercentile:PercentileBaseName
	Button PercentileDoItButton,pos={11,394},size={50,22},proc=PercentileDoItButtonProc,title="Do It"
	Button PercentileHelpButton,pos={176,394},size={50,22},proc=PercentileHelpButtonProc,title="Help"
	Button PercentileUnloadPackageButton,pos={63,420},size={111,22},proc=UnloadPercentilePackageProc,title="Unload Package"
	PCWaveFromMenuProc("",PCWaveSource,"")

	PopupMenu PCTypeMenu,pos={19,111},size={164,19},proc=PCTypeMenuProc
	PopupMenu PCTypeMenu,mode=PercentileType,value= #"\"Box and Whisker Plot;Calculate Percentiles\""

	if (PercentileType == 1)		// Box and Whisker Plot selected in menu
		BoxPlotControls()
	endif
	if (PercentileType == 2)		// Calculcate Percentiles selected
		CalcPercentileControls()
	endif
	
	SetWindow WavePercentilePanel,hook(percentile)=WavePercentilePanelNamedHook
EndMacro

Function WavePercentilePanelNamedHook(hs)
	STRUCT WMWinHookStruct &hs

	strswitch(hs.eventName)
		case "activate":
			NVAR PCWaveSource = root:Packages:WM_WavesPercentile:PCWaveSource
			PCWaveFromMenuProc("",PCWaveSource,"")
			break
	endswitch

	Variable statusCode= WC_WindowCoordinatesNamedHook(hs)
	return statusCode
End

Function BoxPlotControls()

	

	NVAR PCCheckWhiskerTop = root:Packages:WM_WavesPercentile:PCCheckWhiskerTop
	NVAR PCCheckWhiskerBottom = root:Packages:WM_WavesPercentile:PCCheckWhiskerBottom
	NVAR PCColoredBoxesCheck = root:Packages:WM_WavesPercentile:PCColoredBoxesCheck

	TitleBox BoxPlotPercentilesTitle,pos={19,138},size={56,13},title="Percentiles:"
	TitleBox BoxPlotPercentilesTitle,fSize=10,frame=0

	SetVariable PCSetBoxTop,pos={31,177},size={123,16},title="Box Top:",fSize=10
	SetVariable PCSetBoxTop,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCBoxTop
	
	SetVariable PCSetWhiskerTop,pos={47,156},size={133,16},title="Whisker Top:"
	SetVariable PCSetWhiskerTop,fSize=10
	SetVariable PCSetWhiskerTop,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCWhiskerTop
	SetVariable PCSetBoxBottom,pos={31,198},size={123,16},title="Box Bottom:"
	SetVariable PCSetBoxBottom,fSize=10
	SetVariable PCSetBoxBottom,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCBoxBottom
	SetVariable PCSetWhiskerBottom,pos={46,219},size={134,16},title="Whisker Bottom:"
	SetVariable PCSetWhiskerBottom,fSize=10
	SetVariable PCSetWhiskerBottom,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCWhiskerBottom
	CheckBox PCIncludeWhiskerTop,pos={30,158},size={16,14},title=""
	CheckBox PCIncludeWhiskerTop,variable= root:Packages:WM_WavesPercentile:PCCheckWhiskerTop
	CheckBox PCIncludeWhiskerBottom,pos={30,220},size={16,14},title=""
	CheckBox PCIncludeWhiskerBottom,variable= root:Packages:WM_WavesPercentile:PCCheckWhiskerBottom
	
	NVAR PCOutliersMethod= root:Packages:WM_WavesPercentile:PCOutliersMethod
	NVAR PCOutliersFactor= root:Packages:WM_WavesPercentile:PCOutliersFactor
	NVAR PCOutliersPercentile= root:Packages:WM_WavesPercentile:PCOutliersPercentile
	PopupMenu OutlierMethodMenu,pos={18,243},size={110,20},proc=OutliersMethodMenuProc,title="Outliers:",fSize=10
	PopupMenu OutlierMethodMenu,mode=1,popvalue="_None_",value= #"\"_None_;F*whisker length; < percentile P, > 100-P;F*Interquartile Distance\""
	SetVariable PCSetOutliersFactor,pos={70,267},size={64,15},title="F:",fSize=10
	SetVariable PCSetOutliersFactor,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCOutliersFactor,bodyWidth= 50
	SetVariable PCSetOutliersPercentile,pos={71,267},size={64,15},title="P:",fSize=10
	SetVariable PCSetOutliersPercentile,limits={0,100,1},value= root:Packages:WM_WavesPercentile:PCOutliersPercentile,bodyWidth= 50



	SetOutliersDistanceControls()
	
	TitleBox BoxPlotXWaveTitle,pos={21,289},size={39,13},title="X Wave:",fSize=10
	TitleBox BoxPlotXWaveTitle,frame=0

	PopupMenu BoxAndWhiskerXWave,pos={39,304},size={110,19}
	PopupMenu BoxAndWhiskerXWave,mode=1,popvalue="_Calculated_",value= #"\"_Calculated_;-;\"+WaveList(\"*\",\";\",\"\")"

	Button PCShowFormattingButton,pos={37,329},size={133,22},proc=ShowBoxPlotFormatPanel,title="Format Options..."
	
	BoxPlotPanelObsoletePanel()
end

Function KillBoxPlotControls()

	SetDrawLayer/K ProgBack

	KillControl PCSetBoxTop
	KillControl PCSetWhiskerTop
	KillControl PCSetBoxBottom
	KillControl PCSetWhiskerBottom
	KillControl PCIncludeWhiskerTop
	KillControl PCIncludeWhiskerBottom
	KillControl BoxAndWhiskerXWave
	KillControl OutlierMethodMenu
	KillControl PCSetOutliersFactor
	KillControl PCSetOutliersPercentile
	KillControl PCShowFormattingButton
	KillControl BoxPlotPercentilesTitle
	KillControl BoxPlotXWaveTitle
end

Function CalcPercentileControls()

	NVAR PCNewPercentileGraph = root:Packages:WM_WavesPercentile:PCNewPercentileGraph

	TitleBox PercentileListTitle,pos={25,144},size={90,13},title="List of percentiles:"
	TitleBox PercentileListTitle,fSize=10,frame=0
	SetVariable SetPercentileList,pos={25,161},size={162,16},title=" ",fSize=10
	SetVariable SetPercentileList,value= root:Packages:WM_WavesPercentile:PercentileList
	PopupMenu SelectAPercentile,pos={25,182},size={52,20},proc=AddPrecentileProc,title="Add"
	PopupMenu SelectAPercentile,mode=0,value= #"ListOfNumbers(0,100)"
	PopupMenu RemovePercentile,pos={109,182},size={75,20},proc=RemovePrecentileProc,title="Remove"
	PopupMenu RemovePercentile,mode=0,value= #"root:Packages:WM_WavesPercentile:PercentileList"
	TitleBox PercentileDisplayResultsTitle,pos={26,213},size={73,13},title="Display results:"
	TitleBox PercentileDisplayResultsTitle,fSize=10,frame=0
	PopupMenu CalcPercentileWhatToDo,pos={41,230},size={105,20},proc=WhatToDoMenuProc
	PopupMenu CalcPercentileWhatToDo,mode=2,popvalue="in new graph",value= #"\"in top graph;in new graph;make a table;don't display\""
end

Function KillCalcPercentileControls()

	SetDrawLayer/K ProgBack

	KillControl SetPercentileList
	KillControl SelectAPercentile
	KillControl RemovePercentile
	KillControl PercentileListTitle
	KillControl PercentileDisplayResultsTitle
	KillControl CalcPercentileWhatToDo
end

CONSTANT PCFORMATBOX=0
CONSTANT PCFORMATMEDIANLINE=1
CONSTANT PCFORMATWHISKERS=2
CONSTANT PCFORMATOUTLIERS=3

// Function to build and display the box plot formatting panel.
// If ctrlName is "Modify" it means the function has been called as a result of selecting
// the Modify Box Plot item in the menu, which means that the box plot already exists and
// the desire is to re-format the plot.
Function ShowBoxPlotFormatPanel(ctrlName) : ButtonControl
	String ctrlName

	String PanelTitle
	Variable DoModifyBoxPlot = 0
	if (CmpStr(ctrlName, "Modify")==0)
		DoModifyBoxPlot = 1
	endif
	
	String/G root:Packages:WM_WavesPercentile:TargetGraphName = WinName(0,1)
	SVAR TargetGraphName = root:Packages:WM_WavesPercentile:TargetGraphName
	
	if (DoModifyBoxPlot)
		PanelTitle = "Modify Box Plot"
		if (WinType("BoxPlotFormatting") != 0)
			DoWindow/K BoxPlotFormatting
		endif
		if (WinType("DoModifyBoxPlot") != 0)
			DoWindow/F DoModifyBoxPlot
			return 0
		endif
		BoxPlotReadFormatAndSetGlobals(TargetGraphName)
	else
		PanelTitle = "Box Plot Formatting"
		if (WinType("DoModifyBoxPlot") != 0)
			DoWindow/K DoModifyBoxPlot
		endif
		if (WinType("BoxPlotFormatting") != 0)
			DoWindow/F BoxPlotFormatting
			return 0
		endif
	endif
	
	// We use a graph window so that we can display the selected outlier plot symbol in the panel in an
	Variable ScaleFactor = PanelResolution("")/ScreenResolution
//	Display/K=2/W=(353*ScaleFactor,154*ScaleFactor,627*ScaleFactor,390*ScaleFactor) as PanelTitle
	String fmt="Display/K=2/W=(%s) as \""+PanelTitle+"\""

	if (DoModifyBoxPlot)
		Execute WC_WindowCoordinatesSprintf("DoModifyBoxPlot",fmt,353*ScaleFactor,154*ScaleFactor,627*ScaleFactor,407*ScaleFactor,0)	// points
		DoWindow/C DoModifyBoxPlot
	else
		Execute WC_WindowCoordinatesSprintf("BoxPlotFormatting",fmt,353*ScaleFactor,154*ScaleFactor,627*ScaleFactor,407*ScaleFactor,0)	// points
		DoWindow/C BoxPlotFormatting
	endif
	ControlBar 0
	ControlInfo kwBackgroundColor
	ModifyGraph gbRGB=(V_red, V_green, V_blue)
	ModifyGraph wbRGB=(V_red, V_green, V_blue)
	
	TabControl PCFormatTabControl,pos={7,10},size={260,189},fsize=10
	TabControl PCFormatTabControl,tabLabel(PCFORMATBOX)="Box"
	TabControl PCFormatTabControl,tabLabel(PCFORMATMEDIANLINE)="Median Line"
	TabControl PCFormatTabControl,tabLabel(PCFORMATWHISKERS)="Whiskers"
	TabControl PCFormatTabControl,tabLabel(PCFORMATOUTLIERS)="Outliers"
	TabControl PCFormatTabControl,value= 0, proc=PCFormatTabControlProc

	Button PCFormatDefaultButton,pos={69,166},size={122,22},title="Default Settings", proc=PCFormatSetDefaults
	if (DoModifyBoxPlot)
		Button PCBoxPlotFormatDoneButton,pos={201,207},size={50,22},proc=PCFormatDoneProc,title="Done"
		Button PCBoxPlotFormatApplyButton,pos={25,207},size={50,22},proc=PCBoxPlotFormatApplyButtonProc,title="Apply"
	else
		Button PCBoxPlotFormatDoneButton,pos={105,207},size={50,22},title="Done",proc=PCFormatDoneProc		// inside the tab control, but appears on all tabs
	endif
	Button PercentileUnloadPackageButton,pos={83,234},size={111,22},proc=UnloadPercentilePackageProc,title="Unload Package"

	// Box controls
	CheckBox ColoredBoxesCheck,pos={29,109},size={67,14},title="Fill Boxes"
	CheckBox ColoredBoxesCheck,variable= root:Packages:WM_WavesPercentile:PCColoredBoxesCheck

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCBoxFillColorRed
	NVAR PCBoxFillColorGreen
	NVAR PCBoxFillColorBlue
	SetDatafolder $saveDF	
	PopupMenu PCBoxColorMenu,pos={73,129},size={127,20},title="Box Fill Color:",proc=PCBoxFillColorMenuProc
	PopupMenu PCBoxColorMenu,mode=1,popColor= (PCBoxFillColorRed,PCBoxFillColorGreen,PCBoxFillColorBlue),value= #"\"*COLORPOP*\""

	SetVariable PCSetBoxThickness,pos={30,61},size={195,15},title="Box Frame Thickness (points):"
	SetVariable PCSetBoxThickness,limits={0,Inf,1},value= root:Packages:WM_WavesPercentile:PCBoxFrameThickness,bodyWidth= 40

	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCBoxFrameColorRed
	NVAR PCBoxFrameColorGreen
	NVAR PCBoxFrameColorBlue
	SetDatafolder $saveDF	
	PopupMenu PCBoxFrameColorMenu,pos={27,83},size={140,20},title="Box Frame Color:",proc=PCBoxFrameColorMenuProc
	PopupMenu PCBoxFrameColorMenu,mode=1,popColor= (PCBoxFrameColorRed,PCBoxFrameColorGreen,PCBoxFrameColorBlue),value= #"\"*COLORPOP*\""
	SetVariable PCSetBoxWidth,pos={30,35},size={105,15},title="Box Width:"
	SetVariable PCSetBoxWidth,limits={0,Inf,0.1},value= root:Packages:WM_WavesPercentile:PCBoxWidth
	
	// Median line controls
	SetVariable PCMedianLineThickness,pos={30,61},size={201,15},title="Median Line Thickness (points):"
	SetVariable PCMedianLineThickness,limits={0,Inf,1},value= root:Packages:WM_WavesPercentile:PCMedianLineThickness,bodyWidth= 40
	PopupMenu PCMedianLineColorMenu,pos={26,83},size={143,20},title="MedianLine Color:", proc=PCMedianLineColorMenuProc

	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCMedianLineColorRed
	NVAR PCMedianLineColorGreen
	NVAR PCMedianLineColorBlue
	SetDatafolder $saveDF	
	PopupMenu PCMedianLineColorMenu,mode=1,popColor= (PCMedianLineColorRed,PCMedianLineColorGreen,PCMedianLineColorBlue),value= #"\"*COLORPOP*\""
	
	// Whisker controls
	CheckBox PCWhiskerCapsCheck,pos={18,85},size={123,14},title="Add Caps on Whiskers"
	CheckBox PCWhiskerCapsCheck,variable = root:Packages:WM_WavesPercentile:PCWhiskerCaps
	SetVariable PCSetWhiskerCapWidth,pos={54,104},size={186,15},title="Whisker Cap Width (points):"
	SetVariable PCSetWhiskerCapWidth,limits={0,Inf,1},value= root:Packages:WM_WavesPercentile:PCWhiskerCapWidth,bodyWidth= 40
	TitleBox zeromeansauto,pos={142,120},size={83,12},title="(zero means Auto)"
	TitleBox zeromeansauto,fSize=9,frame=0
	SetVariable PCSetWhiskerCapThickness,pos={34,137},size={206,15},title="Whisker Cap Thickness (Points):"
	SetVariable PCSetWhiskerCapThickness,limits={0,Inf,1},value= root:Packages:WM_WavesPercentile:PCWhiskerCapThickness,bodyWidth= 40
	SetVariable PCSetWhiskerThickness,pos={19,37},size={140,15},title="Whisker Thickness:"
	SetVariable PCSetWhiskerThickness,limits={0,Inf,1},value= root:Packages:WM_WavesPercentile:PCWhiskerThickness,bodyWidth= 40

	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCWhiskerColorRed
	NVAR PCWhiskerColorGreen
	NVAR PCWhiskerColorBlue
	SetDatafolder $saveDF	
	PopupMenu PCWhiskerColorMenu,pos={16,59},size={130,20},title="Whisker Color:", proc=PCWhiskerColorMenuProc
	PopupMenu PCWhiskerColorMenu,mode=1,popColor= (PCWhiskerColorRed,PCWhiskerColorGreen,PCWhiskerColorBlue),value= #"\"*COLORPOP*\""
	
	// Outlier controls
	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCOutlierColorRed
	NVAR PCOutlierColorGreen
	NVAR PCOutlierColorBlue
	SetDatafolder $saveDF	
	PopupMenu PCOutlierColorMenu,pos={25,121},size={125,20},proc=PCOutlierColorMenuProc,title="Marker Color:"
	PopupMenu PCOutlierColorMenu,mode=1,popColor= (PCOutlierColorRed,PCOutlierColorGreen,PCOutlierColorBlue),value= #"\"*COLORPOP*\""
	SetVariable PCSetOutlierMarker,pos={29,44},size={84,15},title="Marker:",proc=PCChangeOutlierMarkerProc
	SetVariable PCSetOutlierMarker,limits={0,44,1},value= root:Packages:WM_WavesPercentile:PCOutlierMarker,bodyWidth= 40
	Button PCSelectOutlierMarkerButton,pos={173,41},size={80,22},proc=PCSelectOutlierMarkerButtonProc,title="Select..."
	SetVariable PCSetOutlierMarkerSize,pos={29,75},size={120,15},title="Marker Size:",proc=PCChangeOutlierMarkerProc
	SetVariable PCSetOutlierMarkerSize,limits={0,15,1},value= root:Packages:WM_WavesPercentile:PCOutlierMarkerSize
	TitleBox Outlierzeromeansauto,pos={50,92},size={83,12},title="(zero means Auto)"
	TitleBox Outlierzeromeansauto,fSize=9,frame=0
	TextBox/N=DisplayOutlierMarker/D={1,1,0}/A=MC/X=1.5/Y=27.97/Z=1 ""
	if (DoModifyBoxPlot)
		UpdateOutlierMarkerDisplay("DoModifyBoxPlot")
	else
		UpdateOutlierMarkerDisplay("BoxPlotFormatting")
	endif
	
	PCFormatTabControlProc("",PCFORMATBOX)
	
	if (DoModifyBoxPlot)
		SetWindow DoModifyBoxPlot,hook=BoxPlotFormatPanelHook
	else
		SetWindow BoxPlotFormatting, hook=WC_WindowCoordinatesHook
	endif
end

Function isBoxPlot(theGraph)
	String theGraph
	
	String graphNote
	GetWindow $theGraph,note
	graphNote = S_value
	Variable dummy = NumberByKey("BOXWIDTH", graphNote, "=", ";")
	return NumType(dummy) == 0
end

Function BoxPlotFormatPanelHook(s)
	String s
	
	if (WC_WindowCoordinatesHook(s))
		return 1
	endif

	String win=StringByKey("WINDOW",s)
	String event = StringByKey("EVENT", s)
	if (CmpStr(event, "activate") == 0)
		String Target = WinName(0,1)
		if (CmpStr(Target, win) == 0)
			Target = WinName(1,1)
		endif
		SVAR/Z TargetGraphName = root:Packages:WM_WavesPercentile:TargetGraphName
		Variable dum1 = CmpStr(TargetGraphName, target) != 0
		Variable dum2 = isBoxPlot(target)
 		if ( dum1 && dum2 )
 			BoxPlotUpdateFormatControls(target, win)
 			TargetGraphName = Target
 		endif
	endif

	Variable returnVal= 0
end

Function UpdateOutlierMarkerDisplay(PanelName)
	String PanelName

	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile
	NVAR PCOutlierColorRed
	NVAR PCOutlierColorGreen
	NVAR PCOutlierColorBlue
	NVAR PCOutlierMarker
	NVAR PCOutlierMarkerSize
	SetDatafolder $saveDF
	
	String annoText
	
	String fontSize = num2str(3*PCOutlierMarkerSize)
	if (PCOutlierMarkerSize == 0)
		fontSize = "10"
	elseif (strlen(fontSize) == 1)
		fontSize = "0"+fontSize
	elseif(strlen(fontSize) > 2)
		fontSize = "20"
	endif
	String markerNumber = num2str(PCOutlierMarker)
	if (strlen(markerNumber) == 1)
		markerNumber = "0"+markerNumber
	elseif(PCOutlierMarker > 44)
		markerNumber = "44"
		PCOutlierMarker = 44
	endif
	Variable symbolSize = PCOutlierMarkerSize==0 ? 5 : PCOutlierMarkerSize+3
	sprintf annoText, "\\Z%s\\K(%d,%d,%d)\\W1%2s", fontSize, PCOutlierColorRed,PCOutlierColorGreen,PCOutlierColorBlue, markerNumber
	TextBox/W=$PanelName /N=DisplayOutlierMarker /H=(symbolSize)/C annoText
end

Function PCFormatTabControlProc(name,tab)
	String name
	Variable tab
	
	CheckBox ColoredBoxesCheck,disable= (tab!=PCFORMATBOX)
	PopupMenu PCBoxColorMenu,disable= (tab!=PCFORMATBOX)
	SetVariable PCSetBoxThickness,disable= (tab!=PCFORMATBOX)
	PopupMenu PCBoxFrameColorMenu,disable= (tab!=PCFORMATBOX)
	SetVariable PCSetBoxWidth,disable= (tab!=PCFORMATBOX)
	
	SetVariable PCMedianLineThickness,disable= (tab!=PCFORMATMEDIANLINE)
	PopupMenu PCMedianLineColorMenu,disable= (tab!=PCFORMATMEDIANLINE)
	
	CheckBox PCWhiskerCapsCheck,disable= (tab!=PCFORMATWHISKERS)
	SetVariable PCSetWhiskerCapWidth,disable= (tab!=PCFORMATWHISKERS)
	TitleBox zeromeansauto,disable= (tab!=PCFORMATWHISKERS)
	SetVariable PCSetWhiskerCapThickness,disable= (tab!=PCFORMATWHISKERS)
	SetVariable PCSetWhiskerThickness,disable= (tab!=PCFORMATWHISKERS)
	PopupMenu PCWhiskerColorMenu,disable= (tab!=PCFORMATWHISKERS)
	
	PopupMenu PCOutlierColorMenu,disable= (tab!=PCFORMATOUTLIERS)
	SetVariable PCSetOutlierMarker,disable= (tab!=PCFORMATOUTLIERS)
	Button PCSelectOutlierMarkerButton,disable= (tab!=PCFORMATOUTLIERS)
	SetVariable PCSetOutlierMarkerSize,disable= (tab!=PCFORMATOUTLIERS)
	TitleBox Outlierzeromeansauto,disable= (tab!=PCFORMATOUTLIERS)
	String WindowName
	if (WinType("DoModifyBoxPlot"))
		WindowName = "DoModifyBoxPlot"
	else
		WindowName = "BoxPlotFormatting"
	endif
	TextBox/W=$WindowName/N=DisplayOutlierMarker/C/V=(tab==PCFORMATOUTLIERS)
End

Function PCFormatDoneProc(ctrlName) : ButtonControl
	String ctrlName
	
	if (WinType("BoxPlotFormatting") != 0)
		DoWindow/K BoxPlotFormatting
	endif
	if (WinType("DoModifyBoxPlot") != 0)
		Dowindow/K DoModifyBoxPlot
	endif
	if (WinType("MarkerKeyGraph") != 0)
		DoWindow/K MarkerKeyGraph
	endif
end

Function PCBoxPlotFormatApplyButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR/Z TargetGraphName = root:Packages:WM_WavesPercentile:TargetGraphName
	if (!SVAR_Exists(TargetGraphName))
		DoAlert 0, "BUG: Don't know target graph"
		return -1
	endif
	string GraphName = WinName(0,1)
	GetWindow $GraphName,note
	String GraphNote = S_value
	Variable presentWidth = NumberByKey("BOXWIDTH", GraphNote, "=", ";")
	BoxPlotSetupFormatting(TargetGraphName)
	NVAR/Z NewWidth = root:Packages:WM_WavesPercentile:PCBoxWidth
	BoxPlotChangeBoxWidth(TargetGraphName, NewWidth, presentWidth)
	NVAR/Z DoFill = root:Packages:WM_WavesPercentile:PCColoredBoxesCheck
	NVAR/Z red = root:Packages:WM_WavesPercentile:PCBoxFillColorRed
	NVAR/Z green = root:Packages:WM_WavesPercentile:PCBoxFillColorGreen
	NVAR/Z blue = root:Packages:WM_WavesPercentile:PCBoxFillColorBlue
	BoxPlotChangeBoxFillColor(TargetGraphName, DoFill, red, green, blue)
	BoxPlotApplyStoredColors(TargetGraphName)
	BoxPlotApplyStoredTraceOptions(TargetGraphName)
End

Function BoxPlotReadFormatAndSetGlobals(GraphName)
	String GraphName
	
	String GraphNote
	GetWindow $GraphName,note
	GraphNote = S_value
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_WavesPercentile
	
	PCSetGlobalsToDefaults(1, 1, 1, 1, 1)
	Variable dummy
	
	// box fill
	dummy = NumberByKey("COLOREDBOXES", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCColoredBoxesCheck = dummy
	endif
	dummy = NumberByKey("FILLRED", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFillColorRed = dummy
	endif
	dummy = NumberByKey("FILLGREEN", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFillColorGreen = dummy
	endif
	dummy = NumberByKey("FILLBLUE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFillColorBlue = dummy
	endif
	
	// box frame
	dummy = NumberByKey("BOXWIDTH", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxWidth = dummy
	endif
	dummy = NumberByKey("BOXFRAMETHICKNESS", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFrameThickness = dummy
	endif
	dummy = NumberByKey("FRAMECOLORRED", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFrameColorRed = dummy
	endif
	dummy = NumberByKey("FRAMECOLORGEEN", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFrameColorGreen = dummy
	endif
	dummy = NumberByKey("FRAMECOLORBLUE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCBoxFrameColorBlue = dummy
	endif

	// whiskers
	dummy = NumberByKey("WHISKERCAPS", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerCaps = dummy
	endif
	dummy = NumberByKey("WHISKERCAPWIDTH", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerCapWidth = dummy
	endif
	dummy = NumberByKey("WHISKERCAPTHICKNESS", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerCapThickness = dummy
	endif
	dummy = NumberByKey("WHISKERTHICKNESS", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerThickness = dummy
	endif
	dummy = NumberByKey("WHISKERCOLORRED", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerColorRed = dummy
	endif
	dummy = NumberByKey("WHISKERCOLORGREEN", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerColorGreen = dummy
	endif
	dummy = NumberByKey("WHISKERCOLORBLUE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCWhiskerColorBlue = dummy
	endif

	// median line
	dummy = NumberByKey("MEDIANLINETHICKNESS", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCMedianLineThickness = dummy
	endif
	dummy = NumberByKey("MEDIANLINECOLORRED", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCMedianLineColorRed = dummy
	endif
	dummy = NumberByKey("MEDIANLINECOLORGREEN", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCMedianLineColorGreen = dummy
	endif
	dummy = NumberByKey("MEDIANLINECOLORBLUE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCMedianLineColorBlue = dummy
	endif

	// Outliers
	dummy = NumberByKey("OUTLIERMARKER", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCOutlierMarker = dummy
	endif
	dummy = NumberByKey("OUTLIERMARKERSIZE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCOutlierMarkerSize = dummy
	endif
	dummy = NumberByKey("OUTLIERCOLORRED", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCOutlierColorRed = dummy
	endif
	dummy = NumberByKey("OUTLIERCOLORGREEN", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCOutlierColorGreen = dummy
	endif
	dummy = NumberByKey("OUTLIERCOLORBLUE", GraphNote, "=", ";")
	if (numType(dummy) == 0)
		Variable/G PCOutlierColorBlue = dummy
	endif
	
	SetDataFolder $SaveDF
end

Function PCSetGlobalsToDefaults(BoxFill, BoxFrame, Whiskers, MedianLine, Outliers)
	Variable BoxFill, BoxFrame, Whiskers, MedianLine, Outliers
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_WavesPercentile

	if (BoxFill)
		Variable/G PCColoredBoxesCheck=0
		Variable/G PCBoxFillColorRed = 50000
		Variable/G PCBoxFillColorGreen = 50000
		Variable/G PCBoxFillColorBlue = 50000
	endif
			
	if (BoxFrame)
		Variable/G PCBoxWidth=.3			// This is good for a category plot or for point scaling
		Variable/G PCBoxFrameThickness=1
		Variable/G PCBoxFrameColorRed = 0
		Variable/G PCBoxFrameColorGreen = 0
		Variable/G PCBoxFrameColorBlue = 0
	endif
	
	if (Whiskers)
		Variable/G PCWhiskerCaps=0
		Variable/G PCWhiskerCapWidth=0		// auto
		Variable/G PCWhiskerCapThickness=1
		Variable/G PCWhiskerThickness=1
		Variable/G PCWhiskerColorRed = 0
		Variable/G PCWhiskerColorGreen = 0
		Variable/G PCWhiskerColorBlue = 0
	endif

	if (MedianLine)
		Variable/G PCMedianLineThickness=1
		Variable/G PCMedianLineColorRed = 0
		Variable/G PCMedianLineColorGreen = 0
		Variable/G PCMedianLineColorBlue = 0
		Variable/G PCCheckAppendToGraph=1
		Variable/G PCNewPercentileGraph=3
	endif
	
	if (Outliers)
		Variable/G PCOutlierMarker = 8
		Variable/G PCOutlierMarkerSize = 0		// auto
		Variable/G PCOutlierColorRed = 0
		Variable/G PCOutlierColorGreen = 0
		Variable/G PCOutlierColorBlue = 0
	endif
	
	SetDataFolder $SaveDF
end

Function BoxPlotUpdateFormatControls(graphName, panelName)
	String graphName
	String panelName
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:Packages:WM_WavesPercentile

	BoxPlotReadFormatAndSetGlobals(GraphName)
	NVAR/Z PCBoxFillColorRed 
	NVAR/Z PCBoxFillColorGreen
	NVAR/Z PCBoxFillColorBlue
	PopupMenu PCBoxColorMenu,popColor= (PCBoxFillColorRed,PCBoxFillColorGreen,PCBoxFillColorBlue)
	NVAR/Z PCBoxFrameColorRed
	NVAR/Z PCBoxFrameColorGreen
	NVAR/Z PCBoxFrameColorBlue
	PopupMenu PCBoxFrameColorMenu,popColor= (PCBoxFrameColorRed,PCBoxFrameColorGreen,PCBoxFrameColorBlue)
	NVAR/Z PCWhiskerColorRed
	NVAR/Z PCWhiskerColorGreen
	NVAR/Z PCWhiskerColorBlue
	PopupMenu PCWhiskerColorMenu,popColor= (PCWhiskerColorRed,PCWhiskerColorGreen,PCWhiskerColorBlue)
	NVAR/Z PCMedianLineColorRed
	NVAR/Z PCMedianLineColorGreen
	NVAR/Z PCMedianLineColorBlue
	PopupMenu PCMedianLineColorMenu,popColor= (PCMedianLineColorRed,PCMedianLineColorGreen,PCMedianLineColorBlue)
	NVAR/Z PCOutlierColorRed
	NVAR/Z PCOutlierColorGreen
	NVAR/Z PCOutlierColorBlue
	PopupMenu PCOutlierColorMenu,popColor= (PCOutlierColorRed,PCOutlierColorGreen,PCOutlierColorBlue)
	UpdateOutlierMarkerDisplay(panelName)
	
	SetDataFolder $saveDF
end

Function PCFormatSetDefaults(ctrlName) : ButtonControl
	String ctrlName
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_WavesPercentile
	
	ControlInfo PCFormatTabControl
	Variable whichTab = V_value
	
	switch (whichTab)
		case PCFORMATBOX:
			PCSetGlobalsToDefaults(1, 1, 0, 0, 0)
			// box fill
			NVAR/Z PCBoxFillColorRed 
			NVAR/Z PCBoxFillColorGreen
			NVAR/Z PCBoxFillColorBlue
			PopupMenu PCBoxColorMenu,popColor= (PCBoxFillColorRed,PCBoxFillColorGreen,PCBoxFillColorBlue)
			
			// box frame
			NVAR/Z PCBoxFrameColorRed
			NVAR/Z PCBoxFrameColorGreen
			NVAR/Z PCBoxFrameColorBlue
			PopupMenu PCBoxFrameColorMenu,popColor= (PCBoxFrameColorRed,PCBoxFrameColorGreen,PCBoxFrameColorBlue)
			break
		case PCFORMATWHISKERS:
			// whiskers
			PCSetGlobalsToDefaults(0, 0, 1, 0, 0)
			NVAR/Z PCWhiskerColorRed
			NVAR/Z PCWhiskerColorGreen
			NVAR/Z PCWhiskerColorBlue
			PopupMenu PCWhiskerColorMenu,popColor= (PCWhiskerColorRed,PCWhiskerColorGreen,PCWhiskerColorBlue)
			break
		case PCFORMATMEDIANLINE:
			// median line
			PCSetGlobalsToDefaults(0, 0, 0, 1, 0)
			NVAR/Z PCMedianLineColorRed
			NVAR/Z PCMedianLineColorGreen
			NVAR/Z PCMedianLineColorBlue
			PopupMenu PCMedianLineColorMenu,popColor= (PCMedianLineColorRed,PCMedianLineColorGreen,PCMedianLineColorBlue)
			Variable/G PCCheckAppendToGraph=1
			Variable/G PCNewPercentileGraph=3
			break
		case PCFORMATOUTLIERS:
			// Outliers
			PCSetGlobalsToDefaults(0, 0, 0, 0, 1)
			NVAR/Z PCOutlierColorRed
			NVAR/Z PCOutlierColorGreen
			NVAR/Z PCOutlierColorBlue
			PopupMenu PCOutlierColorMenu,popColor= (PCOutlierColorRed,PCOutlierColorGreen,PCOutlierColorBlue)
			// This works because this function is called by a click in the window
			String WindowName = WinName(0, 65)
			UpdateOutlierMarkerDisplay(WindowName)
			break			
	endswitch
	
	SetDataFolder $SaveDF
end

// take (r,g,b) string and extract numeric r,g,b values
Function ExtractRGBNumbers(rgbStr,r,g,b)
	String rgbStr
	Variable &r, &g, &b

	r= str2num(rgbStr[1,inf])
	variable spos= strsearch(rgbStr,",",0)
	g= str2num(rgbStr[spos+1,inf])
	spos= strsearch(rgbStr,",",spos+1)
	b= str2num(rgbStr[spos+1,inf])
	return 1
End

Function PCBoxFrameColorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile

	Variable Red, Green, Blue
	ExtractRGBNumbers(popStr, Red, Green, Blue)

	Variable/G PCBoxFrameColorRed = Red
	Variable/G PCBoxFrameColorGreen = Green
	Variable/G PCBoxFrameColorBlue = Blue

	SetDatafolder $saveDF
end

Function PCBoxFillColorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile

	Variable Red, Green, Blue
	ExtractRGBNumbers(popStr, Red, Green, Blue)
	
	Variable/G PCBoxFillColorRed = Red
	Variable/G PCBoxFillColorGreen = Green
	Variable/G PCBoxFillColorBlue = Blue

	SetDatafolder $saveDF
end

Function PCMedianLineColorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile

	Variable Red, Green, Blue
	ExtractRGBNumbers(popStr, Red, Green, Blue)
	
	Variable/G PCMedianLineColorRed = Red
	Variable/G PCMedianLineColorGreen = Green
	Variable/G PCMedianLineColorBlue = Blue

	SetDatafolder $saveDF
end

Function PCWhiskerColorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile

	Variable Red, Green, Blue
	ExtractRGBNumbers(popStr, Red, Green, Blue)
	
	Variable/G PCWhiskerColorRed = Red
	Variable/G PCWhiskerColorGreen = Green
	Variable/G PCWhiskerColorBlue = Blue

	SetDatafolder $saveDF
end

Function PCOutlierColorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WM_WavesPercentile

	Variable Red, Green, Blue
	ExtractRGBNumbers(popStr, Red, Green, Blue)
	
	Variable/G PCOutlierColorRed = Red
	Variable/G PCOutlierColorGreen = Green
	Variable/G PCOutlierColorBlue = Blue
	
	// this works because this is called by clicking in a button, so the right window must be the top window
	String WindowName = WinName(0, 65)
	if (WinType("DoModifyBoxPlot"))
		UpdateOutlierMarkerDisplay("DoModifyBoxPlot")
	else
		UpdateOutlierMarkerDisplay("BoxPlotFormatting")
	endif

	SetDatafolder $saveDF
end

Function PCChangeOutlierMarkerProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// this works because this is called by clicking in a button, so the right window must be the top window
	String WindowName = WinName(0, 65)
	
	if (WinType("DoModifyBoxPlot"))
		UpdateOutlierMarkerDisplay("DoModifyBoxPlot")
	else
		UpdateOutlierMarkerDisplay("BoxPlotFormatting")
	endif
End

Function MakeBoxPlotMarkerKeyGraph()

	BoxPlotMakeMarkerKeyWaves()
	DoWindow/K MarkerKeyGraph
	
	String MKY = "root:Packages:WM_WavesPercentile:MarkerKeyY"
	String MKX = "root:Packages:WM_WavesPercentile:MarkerKeyX"
	String MK = "root:Packages:WM_WavesPercentile:MarkerKey"
	Variable/G root:Packages:WM_WavesPercentile:OutlierMarker
	
	Display/K=1/W=(502,178,825,478) $MKY vs $MKX as "Marker Numbers"
	AppendToGraph $MKY vs $MKX
	DoWindow/C MarkerKeyGraph
	AutoPositionWindow/E/M=0 MarkerKeyGraph
	ModifyGraph margin(left)=20,margin(bottom)=40,margin(top)=20,margin(right)=20
	ModifyGraph mode=3
	ModifyGraph rgb=(0,0,0)
	ModifyGraph msize(MarkerKeyY)=5
	ModifyGraph zmrkNum(MarkerKeyY)={$MK}
	ModifyGraph textMarker(MarkerKeyY#1)={$MK,"default",0,0,5,0.00,-15.00}
	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	SetWindow MarkerKeyGraph hook=BoxPlotMarkerHook, hookEvents=1
EndMacro

Function BoxPlotMakeMarkerKeyWaves()

	Make/O/N=45 root:Packages:WM_WavesPercentile:MarkerKeyY
	Wave MKY=root:Packages:WM_WavesPercentile:MarkerKeyY
	Make/O/N=45 root:Packages:WM_WavesPercentile:MarkerKeyX
	Wave MKX=root:Packages:WM_WavesPercentile:MarkerKeyX
	Make/O/N=45 root:Packages:WM_WavesPercentile:MarkerKey= x
	MKY = -Floor(p/8)
	MKX = Mod(p, 8)
end

Function BoxPlotMarkerHook(s)
	String s

	Variable returnVal= 0
	
	NVAR/Z mouseDownTime = root:Packages:WM_WavesPercentile:mouseDownTime
	NVAR/Z sawDoubleClick = root:Packages:WM_WavesPercentile:sawDoubleClick
	NVAR/Z mouseDownX = root:Packages:WM_WavesPercentile:mouseDownX
	NVAR/Z mouseDownY = root:Packages:WM_WavesPercentile:mouseDownY
	if (!NVAR_Exists(mouseDownTime) || !NVAR_Exists(mouseDownTime) || !NVAR_Exists(mouseDownX) || !NVAR_Exists(mouseDownY))
		Variable/G root:Packages:WM_WavesPercentile:mouseDownTime = 0
		Variable/G root:Packages:WM_WavesPercentile:sawDoubleClick = 0
		Variable/G root:Packages:WM_WavesPercentile:mouseDownX = -10000
		Variable/G root:Packages:WM_WavesPercentile:mouseDownY = -10000
		NVAR/Z mouseDownTime = root:Packages:WM_WavesPercentile:mouseDownTime
		NVAR/Z sawDoubleClick = root:Packages:WM_WavesPercentile:sawDoubleClick
		NVAR/Z mouseDownTime = root:Packages:WM_WavesPercentile:mouseDownX
		NVAR/Z sawDoubleClick = root:Packages:WM_WavesPercentile:mouseDownY
	endif
	
	Variable xpix,ypix
	Variable clickTime
	String msg
	String win=StringByKey("WINDOW",s)

	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp + isMouseDown

	if( isClick )
		clickTime = NumberByKey("TICKS", s)
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if (isMouseDown)
			if ( ((clickTime - mouseDownTime) < DOUBLECLICKTIME) && (abs(xpix - mouseDownX) < DOUBLECLICKSLOP) && (abs(ypix - mouseDownY) < DOUBLECLICKSLOP)  )
				sawDoubleClick = 1
			else
				sawDoubleClick = 0
				mouseDownTime = clickTime
				mouseDownX = xpix
				mouseDownY = ypix
			endif
		else		// it's a mouseUp
			if (sawDoubleClick)
				if ( (abs(xpix - mouseDownX) < DOUBLECLICKSLOP) && (abs(ypix - mouseDownY) < DOUBLECLICKSLOP)  )
					// saw a double click, it's a mouse up and it's within the click slop- select the marker and done
					Variable xaxval= AxisValFromPixel(win,"bottom",xpix)
					Variable yaxval= AxisValFromPixel(win,"left",ypix)
					Variable marker= BoxPlotMarkerFromXY(xaxval,yaxval)
					Variable/G root:Packages:WM_WavesPercentile:PCOutlierMarker = marker
					if (WinType("DoModifyBoxPlot"))
						UpdateOutlierMarkerDisplay("DoModifyBoxPlot")
					else
						UpdateOutlierMarkerDisplay("BoxPlotFormatting")
					endif
					Execute/P/Q/Z "DoWindow/K MarkerKeyGraph"
				else
					// not within slop, start over
					mouseDownTime = 0
					mouseDownX = -10000
					mouseDownY = -10000
					sawDoubleClick = 0
				endif
			endif
		endif
		returnVal= 1
	endif
	return returnVal
end

Function BoxPlotMarkerFromXY(xx,yy)
	Variable xx,yy

	Variable marker
	Variable row= round(-yy)
	row= limit(row,0,5)
	Variable col= round(xx)
	col= limit(col,0,7)
	marker= row*8+col
	marker= limit(marker,0,44)
	return marker
End

Function PCSelectOutlierMarkerButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	MakeBoxPlotMarkerKeyGraph()
End

Function WhatToDoMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR PCNewPercentileGraph = root:Packages:WM_WavesPercentile:PCNewPercentileGraph
	PCNewPercentileGraph = popNum
End

Function PCTypeMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR PercentileType = root:Packages:WM_WavesPercentile:PercentileType
	
	PercentileType = popNum
	if (PercentileType == 1)		// Box and Whisker Plot selected in menu
		KillCalcPercentileControls()
		BoxPlotControls()
	endif
	if (PercentileType == 2)		// Calculcate Percentiles selected
		KillBoxPlotControls()
		CalcPercentileControls()
	endif
End

Function PCWaveFromMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR PCWaveSource = root:Packages:WM_WavesPercentile:PCWaveSource
	
	PCWaveSource = popNum
	if ( (popNum == 1) %| (popNum == 2) )
		PCListTableWavesKillControls()
		PCWaveNameControls()
	endif
	if (popNum == 3)
		PCWaveNameKillControls()
		PCListTableWaves("")
	endif
end

Function PCWaveNameControls()

	SetVariable PCSetListExpression,pos={30,49},size={160,14},title="Name Template:"
	SetVariable PCSetListExpression,fSize=10
	SetVariable PCSetListExpression,limits={-Inf,Inf,1},value= root:Packages:WM_WavesPercentile:PCListExpression
end

Function PCWaveNameKillControls()

	KillControl PCSetListExpression
end

Function PCListTableWavesKillControls()

	KillControl PCTableWaves
end

Function PCListTableWaves(tableName)
	String tableName
	
	if( strlen(tableName) == 0 )
		tableName= WinName(0,2)
	endif
	String text="\\K(65535,0,0)(no tables)"
	if( strlen(tableName) )
		String allwaves= PC_TableWaveList("*", ", ", tableName,ignoreSelection=1,justNames=1)
		String waves= PC_TableWaveList("*", ", ", tableName,justNames=1)
		Variable same=CmpStr(allwaves,waves) == 0
		waves= RemoveEnding(waves, ", ")
		if( same )	// no waves in table are being excluded
			text="\\K(0,0,65535)"+tableName+": "+waves
		else
			text="\\K(65535,0,0)"+tableName+" selection: "+waves
		endif
	endif
	TitleBox PCTableWaves,pos={30,49},frame=0,fSize=10,title=text
End


Function AddPrecentileProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR PercentileList = root:Packages:WM_WavesPercentile:PercentileList

	PercentileList += popStr+";"
End

Function RemovePrecentileProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR PercentileList = root:Packages:WM_WavesPercentile:PercentileList
	PercentileList = RemoveFromList(popStr, PercentileList, ";")
End

Function PCCheckWhiskerBottomCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR PCCheckWhiskerBottom = root:Packages:WM_WavesPercentile:PCCheckWhiskerBottom
	PCCheckWhiskerBottom = checked
End

Function PCCheckWhiskerTopCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR PCCheckWhiskerTop = root:Packages:WM_WavesPercentile:PCCheckWhiskerTop
	PCCheckWhiskerTop = checked
End

Function OutliersMethodMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR PCOutliersMethod= root:Packages:WM_WavesPercentile:PCOutliersMethod
	PCOutliersMethod = popNum-1
	SetOutliersDistanceControls()
End

Function SetOutliersDistanceControls()
	NVAR PCOutliersMethod= root:Packages:WM_WavesPercentile:PCOutliersMethod
	SetVariable PCSetOutliersFactor,disable= ((PCOutliersMethod!=1) && (PCOutliersMethod!=3))
	SetVariable PCSetOutliersPercentile,disable= (PCOutliersMethod!=2)
end

Function PercentileDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String theList
	String aWave
	String TopGraph=WinName(0,1)
	String TopTable=WinName(0,2)
	String PCWaveName
	String BoxPlotPCList
	
	String WhiskerBottomWave=""
	String WhiskerTopWave=""
	String BoxBottomWave=""
	String BoxTopWave=""
	String MedianWave=""
	String OutlierYWave=""
	String OutlierXWave=""
	
	Variable AppndGrph
	Variable i
	
	SVAR PercentileBaseName = root:Packages:WM_WavesPercentile:PercentileBaseName
	SVAR PCListExpression = root:Packages:WM_WavesPercentile:PCListExpression
	SVAR PercentileList = root:Packages:WM_WavesPercentile:PercentileList

	NVAR PCBoxWidth= root:Packages:WM_WavesPercentile:PCBoxWidth
	NVAR PCBoxTop= root:Packages:WM_WavesPercentile:PCBoxTop
	NVAR PCBoxBottom= root:Packages:WM_WavesPercentile:PCBoxBottom
	NVAR PCWhiskerTop= root:Packages:WM_WavesPercentile:PCWhiskerTop
	NVAR PCWhiskerBottom= root:Packages:WM_WavesPercentile:PCWhiskerBottom
	NVAR PCOutliersMethod= root:Packages:WM_WavesPercentile:PCOutliersMethod
	NVAR PCOutliersFactor= root:Packages:WM_WavesPercentile:PCOutliersFactor
	NVAR PCOutliersPercentile= root:Packages:WM_WavesPercentile:PCOutliersPercentile

	ControlInfo PCWaveSourceMenu
	Variable ListSource=V_value
	if (ListSource == 1)		// by Name
		theList = WaveList(PCListExpression, ";", "")
		if (strlen(theList) == 0)
			Abort "There are no waves matching the name template \""+PCListExpression+"\""
		endif
	endif
	if (ListSource == 2)		// from Top Graph
		if (strlen(TopGraph) == 0)
			abort "There are no graphs"
		endif
		theList = PCWaveListfromGraph(PCListExpression, ";", TopGraph)
		if (strlen(theList) == 0)
			Abort "There are no waves in the graph '"+TopGraph+"' matching the name template \""+PCListExpression+"\""
		endif
	endif
	if (ListSource == 3)		// from Top Table
		if (strlen(TopTable) == 0)
			abort "There are no tables"
		endif
		theList = PC_TableWaveList("*", ";", TopTable)
		if (strlen(theList) == 0)
			Abort "No waves were found in table '"+TopTable+"'"
		endif
	endif
	
	ControlInfo PCTypeMenu
	Variable DoWhat=V_value
	ControlInfo PCRowsOrColumns
	Variable RepsAreRows = V_value-1
	Variable OutlierDistance = 1
	Variable OutlierMethod = 0

	if (DoWhat == 1)		// make a box plot
		BoxPlotPCList = ""
		ControlInfo PCIncludeWhiskerBottom
		if (V_value)
			BoxPlotPCList += num2str(PCWhiskerBottom)+";"
			WhiskerBottomWave = PercentileBaseName+"_"+num2str(PCWhiskerBottom)
		else
			WhiskerBottomWave = ""
		endif
		BoxPlotPCList += num2str(PCBoxBottom)+";"
		BoxBottomWave = PercentileBaseName+"_"+num2str(PCBoxBottom)
		BoxPlotPCList += "50;"
		MedianWave = PercentileBaseName+"_50"
		BoxPlotPCList += num2str(PCBoxTop)+";"
		BoxTopWave = PercentileBaseName+"_"+num2str(PCBoxTop)
		ControlInfo PCIncludeWhiskerTop
		if (V_value)
			BoxPlotPCList += num2str(PCWhiskerTop)+";"
			WhiskerTopWave = PercentileBaseName+"_"+num2str(PCWhiskerTop)
		else
			WhiskerTopWave = ""
		endif
		ControlInfo OutlierMethodMenu
		OutlierMethod = V_value-1
		if (OutlierMethod != 0)
			OutlierYWave = PercentileBaseName+"OUT"
			OutlierXWave = PercentileBaseName+"OUTX"
		endif
		
	// 0- don't make outlier wave; 
	// 1- outliers are points whose values are less than OutlierDistance times Median-(first percentile in list) or greater than OutlierDistance times Median-(first percentile in list)
	// 2- outliers are points that are outside the OutlierDistance or 100-OutlierDistance percentiles.
		switch (OutlierMethod)
			case 1:
			case 3:
				OutlierDistance = PCOutliersFactor
				break
			case 2:
				OutlierDistance = PCOutliersPercentile
				break
		endswitch
		
		fWavePercentile(theList, BoxPlotPCList, PercentileBaseName, RepsAreRows, OutlierMethod, OutlierDistance)
		
		Wave/Z WB = $WhiskerBottomWave
		Wave BB = $BoxBottomWave
		Wave MM = $MedianWave
		Wave BT = $BoxTopWave
		Wave/Z WT = $WhiskerTopWave
		ControlInfo BoxAndWhiskerXWave
		Wave/Z XW = $S_value
		Variable cBoxes
		NVAR/Z ColoredBoxes = root:Packages:WM_WavesPercentile:PCColoredBoxesCheck
		if (!NVAR_EXISTS(ColoredBoxes))
			cBoxes = 0
		else
			cBoxes = ColoredBoxes
		endif
		if (OutlierMethod != 0)
			Wave OUTY = $OutlierYWave
			Wave OUTX = $OutlierXWave
		endif
		
		NVAR/Z FillRed = root:Packages:WM_WavesPercentile:PCBoxFillColorRed
		NVAR/Z FillGreen = root:Packages:WM_WavesPercentile:PCBoxFillColorGreen
		NVAR/Z FillBlue = root:Packages:WM_WavesPercentile:PCBoxFillColorBlue
		if (fBoxPlot(MM, BT, BB, WT, WB, XW, PCBoxWidth, cBoxes, OUTY, OUTX, FillRed, FillGreen, FillBlue) != 0)
			return -1
		endif

		BoxPlotSetupFormatting("")
		BoxPlotApplyStoredColors("")
		BoxPlotApplyStoredTraceOptions("")		
	endif
	if (DoWhat == 2)		// calculate percentiles
		fWavePercentile(theList, PercentileList, PercentileBaseName, RepsAreRows, 0, 0)
		
		ControlInfo CalcPercentileWhatToDo
		AppndGrph = V_value
		if ( (AppndGrph==1) %| (AppndGrph==2) )	// in top graph or in new graph
			if (AppndGrph==1)
				DoWindow/F $(TopGraph)
				aWave =  StringFromList(0, theList, ";")
				String TInfo = traceinfo("", NameOfWave($(aWave)),0)
				String AFlags=StringByKey("AXISFLAGS",TInfo)
				String XWaveInfo = PossiblyQuoteName(StringByKey("XWAVE", TInfo))
				i = 0
			else
				PCWaveName = PercentileBaseName
				PCWaveName = PercentileBaseName + "_"+StringFromList(0, PercentileList, ";")
				i = 1
				Display $PCWaveName
				TopGraph=WinName(0,1)
				XWaveInfo = ""
				AFlags=""
			endif
			do
				PCWaveName = PercentileBaseName
				PCWaveName = PercentileBaseName + "_"+StringFromList(i, PercentileList, ";")
				if ( (strlen(PercentileBaseName)+1) == strlen(PCWaveName) )
					break
				endif
				CheckDisplayed/W=$TopGraph $PCWaveName
				if (V_flag == 0)
					if (strlen(XWAveInfo) > 0)
						XWaveInfo = " vs "+StringByKey("XWAVEDF", TInfo)+XWaveInfo
					endif
					String AppCom = "AppendToGraph "+AFlags+" "+PCWaveName+XWaveInfo
					Execute AppCom
				endif
				i += 1
			while (1)
		endif
		if (AppndGrph == 3)						// in a table
			PCWaveName = PercentileBaseName
			PCWaveName = PercentileBaseName + "_"+StringFromList(0, PercentileList, ";")
			Edit $PCWaveName
			i = 1
			do
				PCWaveName = PercentileBaseName
				PCWaveName = PercentileBaseName + "_"+StringFromList(i, PercentileList, ";")
				if ( (strlen(PercentileBaseName)+1) == strlen(PCWaveName) )
					break
				endif
				AppendToTable $PCWaveName
				i += 1
			while (1)
		endif
	endif
End

// Prefers selected waves over list of all waves in table.
Function/S PC_TableWaveList(matchStr, sepStr, tableName [,ignoreSelection,justNames])
	String matchStr, sepStr, tableName
	Variable ignoreSelection	// optional, default false
	Variable justNames // optional, default false
	
	if( ParamIsDefault(ignoreSelection) )
		ignoreSelection = 0	// false
	endif
	if( ParamIsDefault(justNames) )
		justNames = 0	// false
	endif
	
	if (strlen(tableName) == 0)
		TableName=WinName(0,2)
	endif
	
	String ListofWaves=""
	String thisColName
	Variable i, nameLen
	
	GetSelection table, $TableName, 7
	String SelectedColNames=S_selection
	String SelectedDataFolders=S_dataFolder

	if( !ignoreSelection )
		// Get a listing of the table selection
		i = 0
		do
			thisColName = StringFromList(i, SelectedColNames, ";")
			if (strlen(thisColName) == 0)
				break
			endif
			nameLen = strlen(thisColName)
			if (CmpStr(thisColName[nameLen-2,nameLen-1], ".i") != 0)
				if (CmpStr(thisColName[nameLen-3,nameLen-3], "]") != 0)
					thisColName = thisColName[0,nameLen-3]
					if (stringmatch(thisColName, matchStr))
						String thisColWavePath = StringFromList(i, SelectedDataFolders,";")+thisColName
						if (Exists(thisColWavePath))
							if( justNames )
								ListofWaves += thisColName+sepStr
							else
								ListofWaves += thisColWavePath+sepStr
							endif
						endif
					endif
				endif
			endif
			i += 1
		while (1)
	endif

	if (strlen(ListofWaves) == 0)		// There is no selection or the selection doesn't make sense; use the whole table
		i = 0
		do
			Wave/Z w=WaveRefIndexed(TableName,i,1)
			if (!waveExists(w))
				break
			endif
			if( justNames )
				ListofWaves +=  NameOfWave(w)+sepStr
			else
				ListofWaves +=  GetWavesDataFolder(w, 2)+sepStr
			endif
			i += 1
		while (1)
	endif

	return ListofWaves
end

Function/S ListOfNumbers(firstNum, lastNum)
	Variable firstNum, lastNum
	
	String theList=""
	Variable i=firstNum
	do
		theList += num2str(i)+";"
		i += 1
	while (i <= lastNum)
	
	return theList
end

Function/S PCWaveListfromGraph(matchStr, sepStr, graphName)
	String matchStr, sepStr, graphName
	
	String theList=""
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	Variable i = 0
	do
		Wave/Z w = WaveRefIndexed(graphName,i,1)
		if (!WaveExists(w))
			break
		endif
		if (stringmatch(NameOfWave(w), matchStr))
			theList += GetWavesDataFolder(w, 2)+sepStr
		endif
		i += 1
	while (1)
	return theList
end

Function PercentileHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Percentile and Box Plot Control Panel"
End

Function BoxPlotPanelObsoletePanel()
	NewPanel/K=1/W=(841,310,1145,455)
	RenameWindow $S_name, ObsoleteBoxPlotPanel
	AutoPositionWindow/R=WavePercentilePanel ObsoleteBoxPlotPanel
	TitleBox Warning1,pos={18.00,20.00},size={263.00,30.00},title="Box Plots are now a built-in trace type, making\rthe old Box Plot control panel obsolete."
	TitleBox Warning1,fSize=12,frame=0
	TitleBox Warning2,pos={18.00,66.00},size={206.00,30.00},title="To learn more about the new built-in\rBox and Violin Plots:"
	TitleBox Warning2,fSize=12,frame=0
	Button BoxViolinHelpButton,pos={53.00,102.00},size={200.00,20.00},proc=BoxAndViolinPlotHelpButtonProc,title="Box and Violin Plot Help"
EndMacro

Function BoxAndViolinPlotHelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "Box Plots and Violin Plots"
			KillWindow ObsoleteBoxPlotPanel
			break
	endswitch

	return 0
End
