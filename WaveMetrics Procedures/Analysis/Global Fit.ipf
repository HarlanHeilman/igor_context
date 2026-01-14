#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 2.22
#pragma IgorVersion = 5.01
#pragma ModuleName= WM_GlobalFit220

//**************************************
// Changes in Global Fit procedures
// 
//	1.01: 	Added ability to hold parameters and calculate residuals Jan 31, 1997
//	2.00: 	Complete re-design of the control panel to use ListBox controls
//			Use FUNCREF variable to pass the user's fitting function
//	2.01:	Changed GlobalFitFunc template function to indicate that the wrong function was called.
//			Removed /D's from GlobalFitFunc that made it look like it was different from user's function,
//				causing the FUNCREF to use the template instead.
//			Added menus to copy initial guesses to/from waves
//			Allow resize of control panel to change size of list boxes
//			Added divider between list boxes to allow changing relative sizes of the lists
// 			Added memory of window size and position
// 2.10:	Added support for constraints
//			Added support for weighting
//			Moved the Global Fit menu item to the Analysis menu
//			New Wave... item in the Copy List To Wave menu
//			The fit coefficient wave is now copied to the current data folder, into GlobalFitCoefficients
// 2.11:	Added support for all-at-once fit functions
//			Added covariance matrix option
// 2.12:	Fixed a bug: if you have two traces with waves having the same names, the wrong X wave is selected when
//				the All From Target button was clicked.
// 2.13:	Added support for data masking.
// 2.14:	Added creation of coefficient waves for each data set.
//     	Fixed a liberal-name bug in the Add Wave menu handling.
// 2.15:	Added support for epsilon.
//			Made a GlobalParams and LocalParams waves double precision.
// 2.16:	Added "Require FitFunc keyword checkbox. Moved creation of fit_ waves to a point inside the DoTheFit
//			function for increased reliability. Add control to set the number of points in the fit_ waves.
// 2.20:	Igor 5 version.
//				Separated the GUI from the function that does the work, so it can be used from user's code.
// 2.21:	Removed over-zealous use of Module#staticFuncName syntax, which hadn't been done thoroughly enough.
//			Fixed a bug: fits with many coefficients can overflow the command string length limit if fit coefficients
//				are held. As a shortcut, I had generated an unnecessary zero for every coefficient even if there
//				were no 1's after a certain point. I now truncate the zeroes to reduce the length of the string.
//				NOTE that it is still possible to overflow the command length limit by holding a coefficient very far
//				down the list, as this requires all the zeroes before it.
// 2.22:	PanelResolution for compatibility with Igor 7
//**************************************

//**************************************
// Things to add in the future:
//	1) Somehow support graph cursors to restrict fit range.
//
//	2) Allow moving the list column dividers. That's really Larry's job...
// 
// 		Anything else? tell support@wavemetrics.com about it!
//**************************************

Menu "Analysis"
	"Global Fit", InitGlobalFitPanel()
	"Unload Global Fit", UnloadGlobalFit()
end

// This is the prototype function for the user's fit function
// If you create your fitting function using the New Fit Function button in the Curve Fitting dialog,
// it will have the FitFunc keyword, and that will make it show up in the menu in the Global Fit control panel.
Function GlobalFitFunc(w, xx) : FitFunc
	Wave w
	Variable xx
	
	DoAlert 0, "Global Fit is running the template fitting function for some reason."
	return nan
end

Function GlobalFitAllAtOnce(pw, yw, xw) : FitFunc
	Wave pw, yw, xw
	
	DoAlert 0, "Global Fit is running the template fitting function for some reason."
	yw = nan
	return nan
end

// The fitting functions use two waves to find the proper coefficients for a given data point.
// One is a 1D wave root:Packages:GlobalFit:IndexPointer. This wave has a point for each data point in the cumulative data waves. 
// The value of each point is the data set number. That is, it is the number of the row in the data sets list wave for the 
// corresonding data set.
// This number is used to pick out a row from root:Packages:GlobalFit:Index. This wave is set up with a row for each data set.
// The zero column contains the starting point number of each data set in the cumulative data set. After the zero column, 
// each column corresponds to one of the basic fit coefficients. Each value is an index into the wave AllCoefs. 
// Finally, AllCoefs contains the actual fitting coefficients. The first N row of AllCoefs contain the N Global coefficients. 
// The remaining rows contain a set of local coefficients for each data set.
// So AllCoefs is set up like this:
// 		GlobalCoef0
// 		GlobalCoef1
//			.
//			.
//			.
//		GlobalCoefN
// 		LocalCoef0		for first data set
//		LocalCoef1
//			.
//			.
//			.
//		LocalCoefN
// 		LocalCoef0		for second data set
//		LocalCoef1
//			.
//			.
//			.
//		LocalCoefN
//			etc.
//
// For instance, if you have 5 data sets and a fitting funtion with 4 coefficients, and coefficient 1 and 3 are global, Index
// would be laid out like this:
//
//		0		2	0	3	1
//		25		4	0	5	1
//		35		6	0	7	1
//		50		8	0	9	1
//		75		10	0	11	1
//
//	Note that a column corresponding to a global coefficient has the same value in every row.
Function GlblFitFunc(w, pp)
	Wave w
	Variable pp
	
	Wave Xw = root:Packages:GlobalFit:XCumData
	Wave IndexW = root:Packages:GlobalFit:Index
	Wave SC=root:Packages:GlobalFit:ScratchCoefs
	Wave IndexP = root:Packages:GlobalFit:IndexPointer

	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	NVAR DoFitFunc=root:Packages:GlobalFit:DoFitFunc
	
	SVAR UserFitFunc=root:Packages:GlobalFit:UserFitFunc
	FUNCREF GlobalFitFunc theFitFunc = $UserFitFunc
	
	Variable IndexPvar, i
	
	if (DoFitFunc)
		IndexPvar = DoFitFunc-1
	else
		IndexPvar = IndexP[pp]
	endif
	
	SC = w[IndexW[IndexPvar][p+1]]
	
	if (DoFitFunc)
		return theFitFunc(SC, pp)
	else
		return theFitFunc(SC, Xw[pp])
	endif
end

Function GlblFitFuncAllAtOnce(inpw, inyw, inxw)
	Wave inpw, inyw, inxw
	
	Wave Xw = root:Packages:GlobalFit:XCumData
	Wave IndexW = root:Packages:GlobalFit:Index
	Wave SC=root:Packages:GlobalFit:ScratchCoefs
	Wave IndexP = root:Packages:GlobalFit:IndexPointer

	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	NVAR DoFitFunc=root:Packages:GlobalFit:DoFitFunc
	NVAR NumSets=root:Packages:GlobalFit:NumSets
	
	SVAR UserFitFunc=root:Packages:GlobalFit:UserFitFunc
	FUNCREF GlobalFitAllAtOnce theFitFunc = $UserFitFunc
	
	Variable IndexPvar, i, firstP, lastP
	
	if (DoFitFunc)
		Variable whichSet = DoFitFunc-1
		SC = inpw[IndexW[whichSet][p+1]]
		theFitFunc(SC, inyw, inxw)
	else
		for (i = 0; i < NumSets-1; i += 1)
			firstP = IndexW[i][0]
			lastP = IndexW[i+1][0] - 1
			Duplicate/O/R=[firstP,lastP] Xw, TempXW, TempYW
			TempXW = Xw[p+firstP]
			SC = inpw[IndexW[i][p+1]]
			theFitFunc(SC, TempYW, TempXW)
			inyw[firstP, lastP] = TempYW[p-firstP]
		endfor
		i = NumSets-1
		firstP = IndexW[i][0]
		lastP = numpnts(inyw)-1
		Duplicate/O/R=[firstP,lastP] Xw, TempXW, TempYW
		TempXW = Xw[p+firstP]
		SC = inpw[IndexW[i][p+1]]
		theFitFunc(SC, TempYW, TempXW)
		inyw[firstP, lastP] = TempYW[p-firstP]
	endif
end

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

//---------------------------------------------
//  Function that actually does a global fit, independent of the GUI
//---------------------------------------------	

constant GlobalFitNO_DATASETS = -1
constant GlobalFitBAD_FITFUNC = -2
constant GlobalFitBAD_YWAVE = -3
constant GlobalFitBAD_XWAVE = -4
constant GlobalFitBAD_COEFINFO = -5
constant GlobalFitNOWTWAVE = -6
constant GlobalFitWTWAVEBADPOINTS = -7
constant GlobalFitNOMSKWAVE = -8
constant GlobalFitMSKWAVEBADPOINTS = -9

constant GFOptionAPPEND_RESULTS = 1
constant GFOptionCALC_RESIDS = 2
constant GFOptionCOV_MATRIX = 4
constant GFOptionFIT_GRAPH = 8
constant GFOptionQUIET = 16
constant GFOptionWTISSTD = 32

Function DoGlobalFit(FitFuncName, DataSets, CoefTypes, CoefWave, ConstraintWave, Options, FitCurvePoints, DoAlertsOnError, [errorName])
	String FitFuncName
	Wave/T DataSets			// Wave containing a list of data sets
								// Column 0 contains Y data sets
								// Column 1 contains X data sets. Enter _calculated_ in a row if appropriate
								// A column with label "Weights", if it exists, contains names of weighting waves for each dataset
								// A column with label "Masks", if it exists, contains names of mask waves for each data set.
	Wave CoefTypes			// a 1 in a row says that the corresponding coefficient is global. Number of rows gives the
								// number of basic coefficients.
	Wave CoefWave				// Wave containing initial guesses. First N rows contain guesses for N global coefficients.
								// Remaining rows contain guesses for local coefficients. All coefficients for a given data set are grouped together;
								// the groups of guesses are in the same order as the data sets in the YDataWaves list.
								// Column 0 contains initial guesses
								// A column with label "Hold", if it exists, specifies held coefficients
								// A column with label "Epsilon", if it exists, holds epsilon values for the coefficients
	Wave/T/Z ConstraintWave	// This constraint wave will be used straight as it comes, so K0, K1, etc. refer to the order of 
								// coefficients as laid out in CoefWave.
								// If no constraints, use $"".
	Variable Options			// 1: Append Results to Top Graph
								// 2: Calculate Residuals
								// 4: Covariance Matrix
								// 8: Do Fit Graph (a graph showing the actual fit in progress)
								// 16: Quiet- No printing in History
								// 32: Weight waves contain Standard Deviation (0 means 1/SD)
	Variable FitCurvePoints	// number of points for auto-destination waves
	Variable DoAlertsOnError	// if 1, this function puts up alert boxes with messages about errors. These alert boxes
									// may give more information than the error code returned from the function.
	String &errorName			// Wave name that was found to be in error. Only applies to certain errors.
	

	Variable i,j
	
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O GlobalFit
	SetDataFolder $saveDF
	
	Variable/G root:Packages:GlobalFit:NumSets
	NVAR NumSets = root:Packages:GlobalFit:NumSets

	Variable quiet = ((Options & GFOptionQUIET) != 0)

	Variable/G root:Packages:GlobalFit:DoFitFunc
	NVAR DoFitFunc=root:Packages:GlobalFit:DoFitFunc
	Variable/G root:Packages:GlobalFit:NBasicCoefs
	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	NBParams = DimSize(CoefTypes, 0)
	
	String errName, errorYName
	Variable errorRow
	Variable err
	String msg
	
	Variable errorWaveRow, errorWaveColumn
	String errorWaveName
	err = CheckDataSetsAndBuildCumWaves(DataSets, NBParams, errorWaveName, errorWaveRow, errorWaveColumn)
	if (err < 0)
		if (err == GlobalFitNO_DATASETS)
			DoAlert 0, "There are no data sets in the list of data sets."
		elseif (DoAlertsOnError)
			DoAlert 0, "The data set "+errorWaveName+" does not exist."
		endif
		errorName = errorWaveName
		return err
	endif
	numsets = err
	Wave Xw = root:Packages:GlobalFit:XCumData
	Wave Yw = root:Packages:GlobalFit:YCumData

	String TopGraph = WinName(0,1)
	
	String/G root:Packages:GlobalFit:UserFitFunc = FitFuncName
	SVAR UserFitFunc=root:Packages:GlobalFit:UserFitFunc
	Variable/G root:Packages:GlobalFit:isAllAtOnceFunc			// 0 for normal, 1 for all-at-once
	NVAR isAllAtOnceFunc = root:Packages:GlobalFit:isAllAtOnceFunc
	string FitFuncs = FunctionList("*", ";", "NPARAMS:2;VALTYPE:1")
	if (FindListItem(UserFitFunc, FitFuncs) >= 0)
		isAllAtOnceFunc = 0
	else
		FitFuncs = FunctionList("*", ";", "NPARAMS:3;VALTYPE:1")
		if (FindListItem(UserFitFunc, FitFuncs) >= 0)
			isAllAtOnceFunc = 1
		else
			if (DoAlertsOnError)
				DoAlert 0, "The fit function "+UserFitFunc+" does not exist or does not have the correct format for a fit function."
			endif
			errorName = UserFitFunc
			return GlobalFitBAD_FITFUNC
		endif
	endif
	
	Variable nLocalCoefs = 0
	for (i = 0; i < NBParams; i += 1)
		if (CoefTypes[i] == 0)
			nLocalCoefs += 1
		endif
	endfor
	Variable nTotalCoefs = nLocalCoefs*NumSets + NBParams - nLocalCoefs		// NBParams - nLocalCoefs is the number of global coefficients
	if (nTotalCoefs != DimSize(CoefWave, 0))
		if (DoAlertsOnError)
			DoAlert 0, "Mismatch between coefficient information and number of data sets."
		endif
		return GlobalFitBAD_COEFINFO
	endif
	
	Make/O/D/N=(NBParams) root:Packages:GlobalFit:ScratchCoefs
	
	Make/D/O/N=(nTotalCoefs) root:Packages:GlobalFit:AllCoefs	
	Wave AllCoefs = root:Packages:GlobalFit:AllCoefs
	AllCoefs = CoefWave[p][0]
	
	Wave Xw = root:Packages:GlobalFit:XCumData
	Wave Yw = root:Packages:GlobalFit:YCumData
	
	Wave IndexW = root:Packages:GlobalFit:Index
	
	SetIndexWave(IndexW, CoefTypes, NumSets)

	Variable DoResid=0
	Variable doWeighting=0
	Variable doMasking=0
	
	String ResidString=""
	String Command=""
	
	String YFitSet
	String YWaveName=""
	
	if (options & GFOptionFIT_GRAPH)	
		if (WinType("GlobalFitGraph") != 0)
			DoWindow/K GlobalFitGraph
		endif
		Display Yw vs Xw
		DoWindow/C GlobalFitGraph
		ModifyGraph Mode(YCumData)=3,Marker(YCumData)=8
		Duplicate/D/O Yw, root:Packages:GlobalFit:FitY
		Wave FitY = root:Packages:GlobalFit:FitY
		FitY = NaN
		AppendToGraph FitY vs Xw
		ModifyGraph Mode(FitY)=3,Marker(FitY)=0
	endif
	
	Duplicate/D/O AllCoefs, root:Packages:GlobalFit:EpsilonWave
	Wave EP = root:Packages:GlobalFit:EpsilonWave
	if (FindDimLabel(CoefWave, 1, "Epsilon") == -2)
		EP = 1e-4
	else
		EP = CoefWave[p][%Epsilon]
	endif

	Variable WeightCol = FindDimLabel(DataSets, 1, "Weights")
	if (WeightCol == -2)
		doWeighting = 0
	else
		err = CheckAndBuildDataSetWave(DataSets, WeightCol, "GFWeightWave", errName, errorYName, errorRow)
		if (err < 0)
			errorName = errName
			msg = "Weight Wave: \""+errName+"\" for Y Wave: \""+errorYName+"\" in row "+num2str(errorRow)+"."
			switch(err)
				case GlobalFitNOWTWAVE:
					if (DoAlertsOnError)
						msg = "Weight wave does not exist- "+msg
						DoAlert 0, msg
					endif
					return err
				case GlobalFitWTWAVEBADPOINTS:
					if (DoAlertsOnError)
						msg = "Weight wave number of points does not match Y wave- "+msg
						DoAlert 0, msg
					endif
					return err
				default:
					if (DoAlertsOnError)
						msg = "Unknown problem with weight wave- "+msg
						DoAlert 0, msg
					endif
					return err
			endswitch
		endif
		doWeighting = 1
		if (Options & GFOptionWTISSTD)
			Wave WtWave = root:Packages:GlobalFit:GFWeightWave
			WtWave = 1/WtWave
		endif
	endif
	
	Variable MaskCol = FindDimLabel(DataSets, 1, "Masks")
	if (MaskCol == -2)
		doMasking = 0
	else
		err = CheckAndBuildDataSetWave(DataSets, MaskCol, "GFMaskWave", errName, errorYName, errorRow)
		if (err < 0)
			errorName = errName
			msg = "Mask Wave: \""+errName+"\" for Y Wave: \""+errorYName+"\" in row "+num2str(errorRow)+"."
			switch(err)
				case GlobalFitNOWTWAVE:
					if (DoAlertsOnError)
						msg = "Mask wave does not exist- "+msg
						DoAlert 0, msg
					endif
					return GlobalFitNOMSKWAVE
				case GlobalFitWTWAVEBADPOINTS:
					if (DoAlertsOnError)
						msg = "Mask wave number of points does not match Y wave- "+msg
						DoAlert 0, msg
					endif
					return GlobalFitMSKWAVEBADPOINTS
				default:
					if (DoAlertsOnError)
						msg = "Unknown problem with Mask wave- "+msg
						DoAlert 0, msg
					endif
					return err
			endswitch
		endif
		doMasking = 1
	endif
	
	if (!quiet)
		Print "*** Doing Global fit ***"
	endif
	
	DoFitFunc = 0						// Makes GlblFitFunc do a global fit
	
	if (Options & GFOptionCALC_RESIDS)
		DoResid = 1
		ResidString="/R"
	endif
	
	String CovarianceString = ""
	if (Options & GFOptionCOV_MATRIX)
		CovarianceString="/M=2"
	endif
	
	string funcName
	if (isAllAtOnceFunc)
		funcName = " GlblFitFuncAllAtOnce"
	else
		funcName = " GlblFitFunc"
	endif
	
	Command =  "FuncFit"+CovarianceString+" "
	Command += MakeHoldString(CoefWave, quiet)+funcName+", "		// MakeHoldString() returns "" if there are no holds
	Command += "root:Packages:GlobalFit:AllCoefs, "
	Command += "root:Packages:GlobalFit:YCumData "
	Command += "/D=root:Packages:GlobalFit:FitY "
	Command += "/E=root:Packages:GlobalFit:EpsilonWave"+ResidString
	if (WaveExists(ConstraintWave))
		Command += "/C="+GetWavesDataFolder(ConstraintWave, 2)
	endif
	if (doWeighting)
		Command += "/W=root:Packages:GlobalFit:GFWeightWave"
	endif
	if (doMasking)
		Command += "/M=root:Packages:GlobalFit:GFMaskWave"
	endif
	Execute Command
	
	CoefWave[][0] = AllCoefs[p]
	
	if (!quiet)
		Print "\rGlobal fit to function "+	UserFitFunc+"\r"
	endif

	if (FitCurvePoints == 0)
		FitCurvePoints = 200
	endif
	MakeFitCurveWaves(DataSets, FitCurvePoints)

	for (i = 0; i < numSets; i += 1)
		YFitSet = DataSets[i][0]
		
		// copy coefficients for each data set into a separate wave
		Wave YFit = $YFitSet
		saveDF = GetDatafolder(1)
		SetDatafolder $GetWavesDatafolder(YFit, 1)
		YWaveName = NameOfWave(YFit)
		if (CmpStr(YWaveName[0], "'") == 0)
			YWaveName = YWaveName[1, strlen(YWaveName)-2]
		endif
		String coefname = CleanupName("Coef_"+YWaveName, 0)
		Make/D/O/N=(NBParams) $coefname
		Wave w = $coefname
		w = AllCoefs[IndexW[i][p+1]]
		SetDataFolder $saveDF
		
		// and print the coefficients by data set into the history
		if (!quiet)
			Print "Coefficients for data set", YFitSet
			printf "{"
			j = 0
			do
				printf "%g", AllCoefs[IndexW[i][j+1]]
				if (FindDimLabel(CoefWave, 1, "Hold") > 0)			// won't be zero, because that's the actual coefficient column
					if (CoefWave[IndexW[i][j+1]][%Hold])
						printf "(held)"
					endif
				endif
				j += 1
				if (j >= NBParams)
					break
				endif
				printf ", "
			while (1)
			printf "}\r"
		endif
	endfor
	
	if (Options & GFOptionAPPEND_RESULTS)
		DoWindow/F $TopGraph
		for (i = 0; i < NumSets; i += 1)
			YFitSet = DataSets[i][0]
			Wave YFit = $YFitSet
			saveDF = GetDatafolder(1)
			SetDatafolder $GetWavesDatafolder(YFit, 1)
			YWaveName = NameOfWave(YFit)
			if (CmpStr(YWaveName[0], "'") == 0)
				YWaveName = YWaveName[1, strlen(YWaveName)-2]
			endif
			YFitSet = "Fit_"+YWaveName
			Wave YFit = $YFitSet
			DoFitFunc = i+1			// Makes GlblFitFunc select a certain set of parameters, and pass X directly to the fitting function
			if (isAllAtOnceFunc)
				Duplicate/O YFit, dummyX
				dummyX = x
				GlblFitFuncAllAtOnce(AllCoefs, YFit, dummyX)
			else
				YFit = GlblFitFunc(AllCoefs, x)
			endif
			CheckDisplayed YFit
			if (!V_flag)
				AppendToGraph YFit
			endif
			SetDatafolder $saveDF
		
			if (DoResid)
				Wave Yw=$(DataSets[i][0])
				saveDF = GetDatafolder(1)
				SetDatafolder $GetWavesDatafolder(Yw, 1)
				YWaveName = NameOfWave(Yw)
				if (CmpStr(YWaveName[0], "'") == 0)
					YWaveName = YWaveName[1, strlen(YWaveName)-2]
				endif
				YWaveName = "Res_"+YWaveName
				Duplicate/O Yw, $YWaveName
				Wave Rw = $YWaveName
				Wave/Z Xw=$(DataSets[i][1])
				if (isAllAtOnceFunc)
					if (!WaveExists(Xw))
						Duplicate/O Rw, dummyX
						Wave Xw=dummyX
						Xw = x
					endif
					GlblFitFuncAllAtOnce(AllCoefs, Rw, Xw)
					Rw = Yw - Rw
				else
					if (WaveExists(Xw))
						Rw=Yw-GlblFitFunc(AllCoefs, Xw)
					else
						Rw=Yw-GlblFitfunc(AllCoefs, x)
					endif
				endif
				SetDatafolder $saveDF
			endif
		endfor
	endif
	
	Wave/Z w = dummyX
	if (WaveExists(w))
		KillWaves w
	endif
	Wave/Z w = TempXW
	if (WaveExists(w))
		KillWaves w
	endif
	Wave/Z w = TempYW
	if (WaveExists(w))
		KillWaves w
	endif
end

static Function CheckAndBuildDataSetWave(DataSets, SourceCol, DestName, errorName, errorYName, errorRow)
	Wave/T DataSets
	Variable SourceCol
	String DestName
	String &errorName
	String &errorYName
	Variable &errorRow
	
	Variable nsets = DimSize(DataSets, 0)
	Variable i
	Variable totalPnts = 0
	Variable startPoint = 0
	Make/N=0/D/O $("root:Packages:GlobalFit:"+DestName)
	Wave GFDestWave = $("root:Packages:GlobalFit:"+DestName)
	for (i = 0; i < nsets; i += 1)
		String YName = DataSets[i][0]
		Wave YW = $YName							// it is assumed that DataSets has been checked for valid Y waves already
		String WtName = DataSets[i][SourceCol]
		Wave/Z WtW = $WtName
		if (!WaveExists(WtW))
			errorName = WtName
			errorYName = YName
			errorRow = i
			return GlobalFitNOWTWAVE
		endif
		Variable nPnts = DimSize(WtW, 0)
		if (nPnts != DimSize(YW, 0))
			errorName = WtName
			errorYName = YName
			errorRow = i
			return GlobalFitWTWAVEBADPOINTS
		endif
		totalPnts += nPnts
		InsertPoints totalPnts, nPnts, GFDestWave
		GFDestWave[startPoint, ] = WtW[p-startPoint]
		startPoint += nPnts
	endfor
	
	return 0
end

//---------------------------------------------
//  All the setup stuff
//---------------------------------------------	

Function DoTheFit(ctrlName) : ButtonControl
	String ctrlName
	
	Variable Options = 0
	NVAR FitCurvePoints = root:Packages:GlobalFit:FitCurvePoints
	
	NVAR NumSets = root:Packages:GlobalFit:NumSets
	if (NumSets <= 0)
		DoAlert 0, "No Data Sets Selected"
		return -1
	endif
	
	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	
	SVAR UserFitFunc=root:Packages:GlobalFit:UserFitFunc
	
	Wave/U/B  GuessListSelection=root:Packages:GlobalFit:GuessListSelection
	Wave/T GuessListWave = root:Packages:GlobalFit:GuessListWave
	WAVE/T DataSetList=root:Packages:GlobalFit:DataSetList
	Duplicate/O/R=[0,DimSize(DataSetList,0)-2][0,1] DataSetList, root:Packages:GlobalFit:GFUI_DataSets
	Wave DataSets = root:Packages:GlobalFit:GFUI_DataSets

	Variable i,j
//	Variable DoResid=0
//	Variable doConstraints=0
	
	String ResidString=""
	String CovarianceString = ""
	String Command=""
	
	String YFitSet
	String YWaveName=""
	String saveDF
	
	Variable nCoefs = DimSize(GuessListWave, 0)
	Make/D/O/N=(nCoefs, 3)  root:Packages:GlobalFit:GFUI_CoefWave
	Wave CoefWave = root:Packages:GlobalFit:GFUI_CoefWave
	SetDimLabel 1, 1, Hold, CoefWave
	SetDimLabel 1, 2, Epsilon, CoefWave

	// initial guesses
	CoefWave[][0] = str2num(GuessListWave[p][%'Initial Guess'])
	for (i = 0; i < nCoefs; i += 1)
		if (numtype(CoefWave[i][0]) != 0)					// INF or NaN
			GuessListSelection = ~1 & GuessListSelection
			GuessListSelection[i][%'Initial Guess'] = 3				// editable and selected
			DoUpdate
			DoAlert 0,  "One of your initial guess values is not a number."
			return -1
		endif
	endfor

	// holds
	CoefWave[][1] = (GuessListSelection[p][%'Hold?'] & 16) != 0

	// Epsilon
	CoefWave[][2] = str2num(GuessListWave[p][%Epsilon])
	for (i = 0; i < nCoefs; i += 1)
		if (numtype(CoefWave[i][2]) != 0)					// INF or NaN
			GuessListSelection = ~1 & GuessListSelection
			GuessListSelection[i][%Epsilon] = 3				// editable and selected
			DoUpdate
			DoAlert 0, "One of your Epsilon guess values is not a number."
			return -1
		endif
		if (CoefWave[i][2] <= 0)
			GuessListSelection = ~1 & GuessListSelection
			GuessListSelection[i][%Epsilon] = 3				// editable and selected
			DoUpdate
			DoAlert 0, "Epsilon values should be positive and non-zero."
			return -1
		endif
	endfor
	
	
	//  Constraints
	Wave/Z GlobalFitConstraintWave = $""
	ControlInfo/W=GlobalFitPanel ConstraintsCheckBox
	if (V_value)
		GlobalFitMakeConstraintWave()
		Wave GlobalFitConstraintWave = root:Packages:GlobalFit:GFUI_GlobalFitConstraintWave
		if (numpnts(GlobalFitConstraintWave) == 0)
			Wave/Z GlobalFitConstraintWave = $""
		endif
	endif
	
	//  Weighting
	Variable doWeighting=0
	ControlInfo/W=GlobalFitPanel WeightingCheckBox
	if (V_value)
		// GFUI_AddWeightWavesToDataSets() adds the weighting wave list column to DataSets. If it does not succede,
		// DataSets is restored to just the X and Y columns
		doWeighting = (GFUI_AddWeightWavesToDataSets(DataSets) == 0)
		if (!doWeighting)
			return -1
		endif
		NVAR/Z GlobalFit_WeightsAreSD= root:Packages:GlobalFit:GlobalFit_WeightsAreSD
		if (NVAR_Exists(GlobalFit_WeightsAreSD) && GlobalFit_WeightsAreSD)
			Options += GFOptionWTISSTD
		endif
	endif
	
	//  Masking
	Variable doMasking=0
	ControlInfo/W=GlobalFitPanel MaskingCheckBox
	if (V_value)
		// GFUI_AddMaskWavesToDataSets()() adds the mask wave list column to DataSets. If it does not succede,
		// DataSets is restored to its previous state
		doMasking = (GFUI_AddMaskWavesToDataSets(DataSets) == 0)
		if (!doMasking)
			return -1
		endif
	endif

	ControlInfo/W=GlobalFitPanel DoResidualCheck
	if (V_value)
		Options += GFOptionCALC_RESIDS
	endif
	
	ControlInfo/W=GlobalFitPanel DoCovarMatrix
	if (V_value)
		Options += GFOptionCOV_MATRIX
	endif

	ControlInfo/W=GlobalFitPanel AppendResultsCheck
	if (V_value)
		Options += GFOptionAPPEND_RESULTS
	endif

	Options += GFOptionFIT_GRAPH
	
	Wave CTypes = root:Packages:GlobalFit:CoefIsGlobal

	String errName = ""
	Variable err = DoGlobalFit(UserFitFunc, DataSets, CTypes, CoefWave, GlobalFitConstraintWave, Options, FitCurvePoints, 0, errorName = errName)
	
	if (err)
		switch (err)
			case GlobalFitNO_DATASETS:
				DoAlert 0, "You have not selected any data sets."
				break;
			case GlobalFitBAD_FITFUNC:
				DoAlert 0, "The fit function "+UserFitFunc+" does not exist or does not have the correct format for a fit function."
				break;
			case GlobalFitBAD_YWAVE:
			case GlobalFitBAD_XWAVE:
				Variable col = err == GlobalFitBAD_YWAVE ? 0 : 1
				Wave DataSetListSelection = root:Packages:GlobalFit:DataSetListSelection
				for (i = 0; i < DimSize(DataSetListSelection, 0); i += 1)
					if ( ((strlen(errName) == 0) && (strlen(DataSetList[i][col]) == 0)) || (CmpStr(errName, DataSetList[i][col]) == 0) )
						DataSetListSelection = 0
						DataSetListSelection[i][col] = 1
						DoUpdate
						break;
					endif
				endfor
				DoAlert 0, "Bad data set: \""+errName+"\""
				break;
			case GlobalFitBAD_COEFINFO:
				// this one can't happen in this code, because we set it up correctly :)
				break;
			case GlobalFitNOWTWAVE:
				DoAlert 0, "The weight wave \""+errName+"\" does not exist."
				break;
			case GlobalFitWTWAVEBADPOINTS:
				DoAlert 0, "The weight wave \""+errName+"\" has a different number of points than the corresponding data set wave."
				break;
			case GlobalFitNOMSKWAVE:
				DoAlert 0, "The mask wave \""+errName+"\" does not exist."
				break;
			case GlobalFitMSKWAVEBADPOINTS:
				DoAlert 0, "The mask wave \""+errName+"\" has a different number of points than the corresponding data set wave."
				break;
		endswitch
	else
		for (i = 0; i < nCoefs; i += 1)
			String dummy
			sprintf dummy, "%.15G", CoefWave[i][0]
			GuessListWave[i][%'Initial Guess'] = dummy
		endfor
	endif
End

static Function MakeFitCurveWaves(DataSets, FitCurvePoints)
	Wave/T DataSets
	Variable FitCurvePoints

	Variable i
	Variable numSets = DimSize(DataSets, 0)
	String XSet, YSet
	String saveDF

	String WaveDF
	Variable CalcX=0
	Variable x1, x2
	
	for (i = 0; i < numSets; i += 1)
		YSet = DataSets[i][0]
		Wave/Z Ysetw = $YSet
		if (strlen(YSet) == 0)
			break
		endif
		XSet = DataSets[i][1]
		Wave/Z Xsetw = $XSet
		if (cmpstr(XSet, "_Calculated_") == 0)
			CalcX = 1
		else
			CalcX = 0
		endif

		saveDF = GetDatafolder(1)
		SetDatafolder $GetWavesDataFolder(Ysetw, 1)
		WaveDF = NameofWave(Ysetw)
		if (CmpStr(WaveDF[0], "'") == 0)
			WaveDF = WaveDF[1, strlen(WaveDF)-2]
		endif
		WaveDF = "Fit_"+WaveDF
		Make/O/D/N=(FitCurvePoints) $WaveDF
		Wave YFit = $WaveDF
		if (WaveExists(Xsetw))
			WaveStats/Q Xsetw
			x1 = V_min
			x2 = V_max
			SetScale/I x x1,x2,YFit
		else
			CopyScales/I Ysetw, YFit
		endif
		SetDatafolder $saveDF
	endfor
end


static Function InitGlobalFitGlobals()
	
	String saveFolder = GetDataFolder(1)
	if (DatafolderExists("root:Packages:GlobalFit"))
		return 0
	endif
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S GlobalFit
	
	NVAR/Z NBasicCoefs = NBasicCoefs
	if (!NVAR_Exists(NBasicCoefs))
		Variable/G NBasicCoefs = 1
	endif
	Variable/G NGlobalParams
	Variable/G NLocalParams
	Variable/G NumSets=0
	Variable/G TotalParams = NBasicCoefs	// undoubtedly wrong...
	Variable/G DoFitFunc=0
	Variable/G FitCurvePoints = 200

	Make/T/N=(NBasicCoefs,2)/O ParamTypesText
	SetDimLabel 1,0,'Parameter',ParamTypesText
	SetDimLabel 1,1,'Global?',ParamTypesText
	Wave/Z CoefIsGlobal = CoefIsGlobal
	if (!WaveExists(CoefIsGlobal))
		Make/O/N=(NBasicCoefs) CoefIsGlobal = 0
	endif
	Make/N=(NBasicCoefs,2)/O/U/B ParamTypesSel
	ParamTypesSel[][1] = 32+16*CoefIsGlobal[p]
	ParamTypesSel[][0]=0
	ParamTypesText[][0] = "Coef "+num2istr(p)
	NGlobalParams = sum(CoefIsGlobal, -inf, inf)
	NLocalParams = NBasicCoefs - NGlobalParams
	
	Make/N=1/O/T GuessListWave="No Data Sets Selected"
	Make/N=1/O/U/B GuessListSelection=0
	
	Make/T/N=(1,2)/O DataSetList=""
	SetDimLabel 1,0,'Y Data Sets',DataSetList
	SetDimLabel 1,1,'X Data Sets',DataSetList
	Make/N=(1,2,2)/O DataSetListSelection		// one plane for colors?
	DataSetListSelection[0][0]=1
	DataSetListSelection[0][1]=0
	
	String/G TopGraph=""
	String/G UserFitFunc="GlobalFitFunc"
	
	SetDataFolder $saveFolder
end

Function InitGlobalFitPanel()

	Silent 1; PauseUpdate
	
	if (wintype("GlobalFitPanel") == 0)
		InitGlobalFitGlobals()
		fGlobalFitPanel()
		SetNumBasicParamsProc("",0,"","")
	else
		DoWindow/F GlobalFitPanel
	endif
end

Function UnloadGlobalFit()
	if (WinType("GlobalFitPanel") == 7)
		DoWindow/K GlobalFitPanel
	endif
	if (WinType("GlobalFitGraph") != 0)
		DoWindow/K GlobalFitGraph
	endif
	if (WinType("CopyToFromInitialGuessesPanel") != 0)
		DoWindow/K CopyToFromInitialGuessesPanel
	endif
	if (DatafolderExists("root:Packages:GlobalFit"))
		KillDatafolder root:Packages:GlobalFit
	endif
	Execute/P "DELETEINCLUDE  <Global Fit>"
	Execute/P "COMPILEPROCEDURES "
end

static Function fGlobalFitPanel()

	Variable left = 45
	Variable top = 55
	Variable right = 451
	Variable bottom = 531
	Variable DividerTop = 263

	NewPanel /K=1 /W=(left, top, right, bottom) as "Global Analysis"
	DoWindow/C GlobalFitPanel
	
	PopupMenu GlobalFitFuncMenu,pos={20,6},size={142,20},proc=BasicFitFunctionMenuProc,title="Basic Fit Function"
	PopupMenu GlobalFitFuncMenu,mode=0,value= #"ListPossibleFitFunctions()"
	SetVariable SetBasicFitFunction,pos={171,9},size={150,15},title=" "
	SetVariable SetBasicFitFunction,limits={-Inf,Inf,1},value= root:Packages:GlobalFit:UserFitFunc
	CheckBox RequireFitFuncCheckbox,pos={191,25},size={183,14},title="Require FitFunc Function Subtype"
	CheckBox RequireFitFuncCheckbox,value= 1

	Button GlobalFitHelpButton,pos={351,6},size={50,20},title="Help",proc=GlobalFitHelpButtonProc

	GroupBox ParametersGroupBox,pos={5,30},size={397,100},title="Parameters"
	SetVariable SetNumBasicParms,pos={12,46},size={161,15},proc=SetNumBasicParamsProc,title=" # Basic Parameters:"
	SetVariable SetNumBasicParms,limits={1,Inf,1},value= root:Packages:GlobalFit:NBasicCoefs
	ListBox ParamTypesListBox,pos={208,47},size={154,79},proc=ParamTypeListBoxProc
	ListBox ParamTypesListBox,frame=2
	ListBox ParamTypesListBox,listWave=root:Packages:GlobalFit:ParamTypesText
	ListBox ParamTypesListBox,selWave=root:Packages:GlobalFit:ParamTypesSel,mode= 5
	ListBox ParamTypesListBox,widths= {70,40}

	GroupBox DataSetsGroupBox,pos={5,132},size={397,126},title="Data Sets"
	PopupMenu AddWaveMenu,pos={15,148},size={51,20},proc=AddWaveProc,title="Add"
	PopupMenu AddWaveMenu,mode=0,value= #"AddWaveMenuContents()"
	PopupMenu RemoveWaveMenu,pos={75,148},size={63,20},proc= RmveWaveProc,title="Rmve"
	PopupMenu RemoveWaveMenu,mode=0,value= #"\"Remove Selection;Remove Entire Row;Remove All\""
	Button WavesFromTarget,pos={286,148},size={110,20},proc=FromTargetProc,title="All From Target"
	ListBox xdatalist,pos={11,175},size={386,86},frame=2
	ListBox xdatalist,listWave=root:Packages:GlobalFit:DataSetList
	ListBox xdatalist,selWave=root:Packages:GlobalFit:DataSetListSelection,mode= 5

	GroupBox GuessesGroupBox,pos={5,270},size={397,146},title="Initial Guesses"
	Button CopyInitialGuessListButton,pos={12,289},size={161,20},proc=CopyInitialGuessButtonProc,title="Copy To/From Wave..."
	ListBox GuessesList,pos={11,317},size={386,93},frame=2
	ListBox GuessesList,listWave=root:Packages:GlobalFit:GuessListWave
	ListBox GuessesList,selWave=root:Packages:GlobalFit:GuessListSelection,mode= 7
	ListBox GuessesList,editStyle= 1,widths= {19,10,8,8}

	Variable BottomGroupBoxTop = bottom - top - 71
	GroupBox BottomGroupBox,pos={4,BottomGroupBoxTop},size={398,67}
	Variable CheckboxTops = BottomGroupBoxTop + 7
	CheckBox ConstraintsCheckBox,pos={11,CheckboxTops},size={114,14},proc=ConstraintsCheckProc,title="Apply Constraints..."
	CheckBox ConstraintsCheckBox,value= 0
	CheckBox WeightingCheckBox,pos={130,CheckboxTops},size={76,14},proc=WeightingCheckProc,title="Weighting..."
	CheckBox WeightingCheckBox,value= 0
	CheckBox MaskingCheckBox,pos={211,CheckboxTops},size={67,14},proc=MaskingCheckProc,title="Masking..."
	CheckBox MaskingCheckBox,value= 0
	CheckBox DoCovarMatrix,pos={285,CheckboxTops},size={108,14},title="Covariance Matrix"
	CheckBox DoCovarMatrix,value= 0
	CheckboxTops += 19
	CheckBox AppendResultsCheck,pos={11,CheckboxTops},size={166,14},title="Append fit results to top graph"
	CheckBox AppendResultsCheck,value= 1
	CheckBox DoResidualCheck,pos={201,CheckboxTops},size={111,14},title="Calculate Residuals"
	CheckBox DoResidualCheck,value= 0
	CheckboxTops += 19
	SetVariable GFSetFitCurveLength,pos={35,CheckboxTops},size={137,15},bodyWidth= 50,title="Fit Curve Points:"
	SetVariable GFSetFitCurveLength,limits={2,Inf,1},value= root:Packages:GlobalFit:FitCurvePoints

	Button DoFitButton,pos={336,CheckboxTops-9},size={50,20},proc=DoTheFit,title="Fit!"
	
	GroupBox ListDivider,pos={3,DividerTop},size={400,2}

	Variable PixelsToPoints = PanelResolution("")/ScreenResolution
	left = NumVarOrDefault("root:Packages:GlobalFit:GlobalFitPanelLeft", 45*PixelsToPoints)
	top = NumVarOrDefault("root:Packages:GlobalFit:GlobalFitPaneltop", 55*PixelsToPoints)
	right = NumVarOrDefault("root:Packages:GlobalFit:GlobalFitPanelright", 451*PixelsToPoints)
	bottom = NumVarOrDefault("root:Packages:GlobalFit:GlobalFitPanelbottom", 531*PixelsToPoints)
	DividerTop = NumVarOrDefault("root:Packages:GlobalFit:GlobalFitPanelDividerTop", 263)
	SaveGlobalFitPanelSize()

	MoveWindow/W=GlobalFitPanel left, top, right, bottom
	GlobalFitResize()
	
	GroupBox ListDivider,pos={3, DividerTop}
	HandleDividerMoved(DividerTop)
	
	SetWindow GlobalFitPanel,hook=GlobalFitWindowHook, hookevents=3
EndMacro

static Function SaveGlobalFitPanelSize()

	String saveDF=GetDatafolder(1)
	Variable pointsToPixels = ScreenResolution/PanelResolution("GlobalFitPanel")
	SetDatafolder root:Packages:GlobalFit
	GetWindow GlobalFitPanel wsize			// sets root:Packages:GlobalFit:V_top, etc.
	Variable/G GlobalFitPanelTop = V_top*pointsToPixels
	Variable/G GlobalFitPanelBottom = V_bottom*pointsToPixels
	Variable/G GlobalFitPanelLeft = V_Left*pointsToPixels
	Variable/G GlobalFitPanelRight = V_Right*pointsToPixels
	ControlInfo ListDivider
	Variable/G GlobalFitPanelDividerTop = V_top
	SetDatafolder $saveDF
end

Function/S ListPossibleFitFunctions()

	string theList="", UserFuncs, XFuncs
	
	string options = "KIND:10"
	ControlInfo/W=GlobalFitPanel RequireFitFuncCheckbox
	if (V_value)
		options += ",SUBTYPE:FitFunc"
	endif
	options += ",NINDVARS:1"
	
	UserFuncs = FunctionList("*", ";",options)
	UserFuncs = RemoveFromList("GlobalFitFunc", UserFuncs)
	UserFuncs = RemoveFromList("GlobalFitAllAtOnce", UserFuncs)
	UserFuncs = RemoveFromList("GlblFitFunc", UserFuncs)
	UserFuncs = RemoveFromList("GlblFitFuncAllAtOnce", UserFuncs)

	XFuncs = FunctionList("*", ";", "KIND:12")
	
	if (strlen(UserFuncs) > 0)
		theList +=  "\\M1(User-defined functions:;"
		theList += UserFuncs
	endif
	if (strlen(XFuncs) > 0)
		theList += "\\M1(External Functions:;"
		theList += XFuncs
	endif
	
	if (strlen(theList) == 0)
		theList = "\\M1(No Fit Functions"
	endif
	
	return theList
end

Function BasicFitFunctionMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR UserFitFunc=root:Packages:GlobalFit:UserFitFunc
	
	UserFitFunc = popStr
End

Function GlobalFitHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayHelpTopic "Global Curve Fitting"
end

Function/S AddWaveMenuContents()

	String theContents=""
	Variable DoingX=0
	Variable workingRow
	
	WAVE/T List=root:Packages:GlobalFit:DataSetList
	WAVE ListSelection=root:Packages:GlobalFit:DataSetListSelection
	
	FindSelection(ListSelection, workingRow, DoingX)
	if (DoingX)
		theContents += "_Calculated_;-;"
	endif
	theContents += WaveList("*", ";", "")
	
	return theContents
end

Function SetNumBasicParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Wave CTypes = root:Packages:GlobalFit:CoefIsGlobal
	Wave/T ParamTypesText = root:Packages:GlobalFit:ParamTypesText
	Wave ParamTypesSel = root:Packages:GlobalFit:ParamTypesSel
	
	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	Variable OldNBParams = DimSize(CTypes, 0)
	Redimension/N=(NBParams, -1) CTypes, ParamTypesText, ParamTypesSel
	if (OldNBParams < NBParams)
		CTypes[OldNBParams,NBParams-1] = 0
		ParamTypesText[][0] = "Coef "+num2istr(p)
		ParamTypesText[][1] = ""
		ParamTypesSel[][1] = 32+16*CTypes[p]
		ParamTypesSel[][0]=0
	endif
	
	ParamTypeListBoxProc("",0,1,2)
	setParams()
End

Function ParamTypeListBoxProc(ctrlName,row,col,event)
	String ctrlName     // name of this control
	Variable row        // row if click in interior, -1 if click in title
	Variable col        // column number
	Variable event      // event code

	if (event != 2)
		return 0
	endif
	if (col != 1)
		return 0
	endif
	if (row < 0)
		return 0
	endif
	
	// now we have only a mouse-up in the Global? checkbox column
	Wave CTypes = root:Packages:GlobalFit:CoefIsGlobal
	Wave ParamTypesSel = root:Packages:GlobalFit:ParamTypesSel

	CTypes = (ParamTypesSel[p][1] & 16)!=0
	
	setParams()
   	return 0            // other return values reserved
end

static Function setParams()

	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	Make/O/N=(NBParams) root:Packages:GlobalFit:CoefIsGlobal
	Wave CTypes = root:Packages:GlobalFit:CoefIsGlobal
	NVAR NGlobalParams=root:Packages:GlobalFit:NGlobalParams
	NVAR NLocalParams=root:Packages:GlobalFit:NLocalParams
	
	NGlobalParams = 0
	NLocalParams = 0
	
	Variable i=0
	do
		if (CTypes[i])
			NGlobalParams += 1
		else
			NLocalParams += 1
		endif
		i += 1
	while (i < NBParams)
	
	Make/D/O/N=(NGlobalParams) root:Packages:GlobalFit:GlobalParams
	Make/D/O/N=(NLocalParams) root:Packages:GlobalFit:LocalParams
	Wave GParams=root:Packages:GlobalFit:GlobalParams
	Wave LParams=root:Packages:GlobalFit:LocalParams
	
	Variable theLocal = 0
	Variable theGlobal = 0
	i = 0
	do
		if (CTypes[i])
			GParams[theGlobal] = i
			theGlobal += 1
		else
			LParams[theLocal] = i
			theLocal += 1
		endif
		i += 1
	while (i < NBParams)
end


static Function FindSelection(w, row, col)
	Wave w
	Variable &row
	Variable &col
	
	Variable numRows = DimSize(w, 0)
	Variable numCols = DimSize(w,1)
	Variable i,j
	for (i = 0; i < numRows; i += 1)
		for (j=0; j < numCols; j += 1)
			if (w[i][j] != 0)
				row = i
				col = j
				return 0
			endif
		endfor
	endfor
end

Function AddWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	Variable DoingX=0
	
	WAVE/T List=root:Packages:GlobalFit:DataSetList
	WAVE ListSelection=root:Packages:GlobalFit:DataSetListSelection
	Variable workingRow
	FindSelection(ListSelection, workingRow, DoingX)
	
	String CDF=GetDataFolder(1)
	String thisWave
	Variable i, wavetype
	Variable nItems
	
	Variable lastRow = DimSize(List, 0)-1
	
	if (workingRow == lastRow)
		InsertPoints lastRow+1, 1, List, ListSelection
		ListSelection = 0
		ListSelection[workingRow+1][DoingX] = 1
	endif
	if (DoingX %& (cmpstr(popStr, "_Calculated_") == 0))
		thisWave = "_Calculated_"
	else
		thisWave = CDF+PossiblyQuoteName(popStr)
	endif
	List[workingRow][DoingX] = thisWave
	
	DataSetsOKProc()
End

Function RmveWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable DoingX=0
	
	WAVE/T List=root:Packages:GlobalFit:DataSetList
	WAVE ListSelection=root:Packages:GlobalFit:DataSetListSelection
	Variable workingRow
	FindSelection(ListSelection, workingRow, DoingX)
	
	Variable lastRow = DimSize(List, 0)-1

	strswitch (popStr)
		case "Remove Selection":
			List[workingRow][DoingX] = ""
			if ( (strlen(List[workingRow][0]) == 0) && (strlen(List[workingRow][1]) == 0) )
				if (workingRow != lastRow)
					DeletePoints workingRow, 1, List, ListSelection
				endif
			endif
			break
		case "Remove Entire Row":
			if (workingRow != lastRow)
				DeletePoints workingRow, 1, List, ListSelection
			endif
			break
		case "Remove All":
			Redimension/N=(1,2) List,ListSelection
			List = ""
			ListSelection = 0
			ListSelection[0][DoingX] = 1
			break
	endswitch
	
	DataSetsOKProc()
End

static Function SetIndexWave(IndexWave, ParamTypes, nSets)
	Wave IndexWave
	Wave ParamTypes
	Variable nSets
	
	Variable i, j
	Variable nBasicCoefs = DimSize(ParamTypes, 0)
	
	Variable nGlobals = 0
	for (i = 0; i < nBasicCoefs; i += 1)
		if (ParamTypes[i])
			IndexWave[][i+1] = nGlobals		// fills a column of IndexWave
			nGlobals += 1
		endif
	endfor
	
	Variable nLocals = nBasicCoefs - nGlobals
	Variable whichLocal = 0
	for (i = 0; i < nBasicCoefs; i += 1)
		if (ParamTypes[i] == 0)
			IndexWave[][i+1] = nGlobals + p*nLocals + whichLocal
			whichLocal += 1
		endif
	endfor	
end


// Checks list of data sets for consistency, etc.
// Makes the cumulative data set waves.
Function CheckDataSetsAndBuildCumWaves(DataSets, NBParams, errorWaveName, errorWaveRow, errorWaveColumn)
	Wave/T DataSets
	Variable NBParams
	String &errorWaveName
	Variable &errorWaveRow
	Variable &errorWaveColumn
	
	errorWaveName = ""

	Variable i
	String XSet, YSet
	Variable numSets = DimSize(DataSets, 0)
	
	Make/D/N=0/O root:Packages:GlobalFit:XCumData, root:Packages:GlobalFit:YCumData, root:Packages:GlobalFit:IndexPointer
	Make/O/N=(numSets, NBParams+1) root:Packages:GlobalFit:Index
	Wave Xw = root:Packages:GlobalFit:XCumData
	Wave Yw = root:Packages:GlobalFit:YCumData
	Wave IndexW = root:Packages:GlobalFit:Index
	
	Variable totalPoints = 0
	
	for (i = 0; i < numSets; i += 1)
		YSet = DataSets[i][0]
		Wave/Z Ysetw = $YSet
		if (!WaveExists(YSetw))
			errorWaveName = YSet
			errorWaveRow = i
			errorWaveColumn = 0
			return GlobalFitBAD_YWAVE
		endif
		XSet = DataSets[i][1]
		Wave/Z Xsetw = $XSet
		if (cmpstr(XSet, "_Calculated_") != 0)
			if (!WaveExists(Xsetw))
				errorWaveName = XSet
				errorWaveRow = i
				errorWaveColumn = 1
				return GlobalFitBAD_XWAVE
			endif
		endif
		IndexW[i][0] = totalPoints
		totalPoints += numpnts(Ysetw)
	endfor
	
	if (numSets == 0)
		return 0
	endif
	
	Make/D/N=(totalPoints)/O root:Packages:GlobalFit:IndexPointer
	Wave IndexP = root:Packages:GlobalFit:IndexPointer
	Variable NumSetsMinusOne = NumSets-1
	for (i = 0; i < NumSetsMinusOne; i += 1)
		IndexP[IndexW[i][0],IndexW[i+1][0]] = i
	endfor	
	IndexP[IndexW[NumSetsMinusOne],] = NumSetsMinusOne
	
	String listOfWaves = TextWaveToList(DataSets, 0)
	Concatenate/NP listOfWaves, Yw
	
	ConcatenateXWaves(DataSets, Xw)

	return numSets
end

// Calls CheckDataSetsAndBuildCumWaves() and does the right things with the UI
static Function DataSetsOKProc()

	WAVE/T List=root:Packages:GlobalFit:DataSetList
	WAVE ListSelection=root:Packages:GlobalFit:DataSetListSelection
	
	Wave/T GuessListWave = root:Packages:GlobalFit:GuessListWave
	WAVE/U/B GuessListSelection=root:Packages:GlobalFit:GuessListSelection

	Wave CTypes = root:Packages:GlobalFit:CoefIsGlobal
	NVAR NBParams=root:Packages:GlobalFit:NBasicCoefs
	NVAR NGlobalParams=root:Packages:GlobalFit:NGlobalParams
	NVAR NLocalParams=root:Packages:GlobalFit:NLocalParams
	NVAR NumSets=root:Packages:GlobalFit:NumSets
	
	Duplicate/O List, root:Packages:GlobalFit:DataSetsWave
	Wave/T DataSetsWave = root:Packages:GlobalFit:DataSetsWave
	Redimension/N=(DimSize(List, 0)-1, 2) DataSetsWave
	String errorWaveName
	Variable errorWaveRow, errorWaveColumn
	String msg
	Variable err = CheckDataSetsAndBuildCumWaves(DataSetsWave, NBParams, errorWaveName, errorWaveRow, errorWaveColumn)
	if (err <= 0)
		switch (err)
			case 0:
				KillWaves/Z Xw, Yw
				Redimension/N=1 GuessListWave
				GuessListWave = "No Data Sets Selected"
				Redimension/N=1 GuessListSelection
				GuessListSelection = 0
				ListBox GuessesList,listWave=GuessListWave, mode=0
				ListBox GuessesList,selWave=GuessListSelection
				return 0
			case GlobalFitBAD_YWAVE:
				ListSelection = 0
				ListSelection[errorWaveRow][errorWaveColumn] = 1
				DoUpdate
				msg="The Y wave \""+errorWaveName+"\" does not exist"
				abort msg
			case GlobalFitBAD_XWAVE:
				ListSelection = 0
				ListSelection[errorWaveRow][errorWaveColumn] = 1
				DoUpdate
				msg="The X wave \""+errorWaveName+"\" does not exist"
				abort msg
			default:
				abort "An unknown error has occurred while checking data sets. Error: "+num2str(NumSets)+" Error wave: "+errorWaveName+" Error Row: "+num2str(errorWaveRow)+" Error Column: "+num2str(ErrorWaveColumn)
		endswitch
	endif
	NumSets = err
	
	Wave IndexW = root:Packages:GlobalFit:Index
	NVAR TotalParams= root:Packages:GlobalFit:TotalParams
	TotalParams = NGlobalParams+NumSets*NLocalParams
	
	Make/O/D/N=(TotalParams) root:Packages:GlobalFit:AllCoefs
	Wave/D AllCoefs = root:Packages:GlobalFit:AllCoefs
	
	Wave GlobalParams=root:Packages:GlobalFit:GlobalParams
	Wave LocalParams=root:Packages:GlobalFit:LocalParams
	
	Make/N=(TotalParams, 4)/T/O root:Packages:GlobalFit:GuessListWave
	Wave/T GuessListWave = root:Packages:GlobalFit:GuessListWave
	Make/N=(TotalParams, 4)/O/U/B root:Packages:GlobalFit:GuessListSelection=0
	Wave/U/B GuessListSelection = root:Packages:GlobalFit:GuessListSelection

	SetDimLabel 1, 0, 'Coefficient', GuessListWave, GuessListSelection
	SetDimLabel 1, 1, 'Initial Guess', GuessListWave, GuessListSelection
	SetDimLabel 1, 2, 'Hold?', GuessListWave, GuessListSelection
	SetDimLabel 1, 3, Epsilon, GuessListWave, GuessListSelection

	Variable i, j
	for (i = 0;  i < NGlobalParams; i += 1)
		GuessListWave[i][%Coefficient] = "Global Parameter; Coef["+num2istr(GlobalParams[i])+"]"
		for (j = 0; j < NumSets; j += 1)
			IndexW[j][GlobalParams[i]+1] = i
		endfor
	endfor
	
	for (i = 0; i < NumSets; i += 1)
		for (j = 0; j < NLocalParams; j += 1)
			GuessListWave[NGlobalParams+i*NLocalParams+j][%Coefficient] = List[i][0]+"; Coef["+num2istr(LocalParams[j])+"]"
			IndexW[i][LocalParams[j]+1] = NGlobalParams+i*NLocalParams+j
		endfor
	endfor
	
	GuessListSelection[][%Coefficient] = 0				// labels for the coefficients
	GuessListSelection[][%'Initial Guess'] = 2			// editable field to enter initial guesses
	GuessListSelection[][%'Hold?'] = 32					// checkbox for holds
	GuessListSelection[][%Epsilon] = 2					// editable field to enter epsilon values
	GuessListWave[][%'Initial Guess'] = "0"
	GuessListWave[][%'Hold?'] = "Hold"
	GuessListWave[][%Epsilon] = "1e-4"
	ListBox GuessesList,listWave=GuessListWave, mode=7
	ListBox GuessesList,selWave=GuessListSelection,editstyle=1
	ListBox GuessesList,widths={19,10,8,8}
	
	Wave/Z HoldWave = root:Packages:GlobalFit:'Enter 1 to Hold'
	if (WaveExists(HoldWave))
		KillWaves HoldWave
	endif

	return(NumSets)
End

Function/S ListPossibleInitialGuessWaves()

	Wave/T/Z GuessListWave = root:Packages:GlobalFit:GuessListWave
	NVAR/Z TotalParams= root:Packages:GlobalFit:TotalParams
	if ( (!WaveExists(GuessListWave)) || (!NVAR_Exists(TotalParams)) || (TotalParams <= 0) )
		return "Data sets not initialized"
	endif
	
	Variable numpoints = DimSize(GuessListWave, 0)
	String theList = ""
	Variable i=0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		if ( (DimSize(w, 0) == numpoints) && (WaveType(w) & 6) )		// select floating-point waves with the right number of points
			theList += NameOfWave(w)+";"
		endif
		i += 1
	while (1)
	
	if (i == 0)
		return "None Available"
	endif
	return theList
end


Function CopyInitialGuessButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if (WinType("CopyToFromInitialGuessesPanel") == 7)
		DoWindow/F CopyToFromInitialGuessesPanel
	else
		Variable panelWidth = 200
		Variable panelHeight = 160
		ControlInfo/W=GlobalFitPanel GuessesList
		Variable top = V_top
		Variable left = V_left+V_width
		Variable bottom = top + panelHeight
		Variable right = left+panelWidth
		GetWindow GlobalFitPanel, wsize
		top += V_top
		bottom += V_top
		left += V_left
		right += V_left
		NewPanel/K=1/W=(left,top,right,bottom) as "Copy to/from Waves"
		DoWindow/C CopyToFromInitialGuessesPanel
		
		Variable/G root:Packages:GlobalFit:CopyInitialGuessRadioValue = NumVarOrDefault("root:Packages:GlobalFit:CopyInitialGuessRadioValue", 1)
		NVAR CopyInitialGuessRadioValue = root:Packages:GlobalFit:CopyInitialGuessRadioValue
		
		PopupMenu InitGuessToWaveMenu,pos={22,90},size={145,20},proc=InitGuessToWaveMenuProc,title="Copy List To Wave"
		PopupMenu InitGuessToWaveMenu,mode=0,value= #"ListPossibleInitialGuessWaves()+\"-;New Wave...\""
		PopupMenu WaveToInitGuessMenu,pos={22,61},size={145,20},proc=WaveToInitGuessMenuProc,title="Copy Wave To List"
		PopupMenu WaveToInitGuessMenu,mode=0,value= #"ListPossibleInitialGuessWaves()"
		CheckBox CopyInitialGuessRadio,pos={36,13},size={115,14},title="Copy Initial Guesses"
		CheckBox CopyInitialGuessRadio,value = CopyInitialGuessRadioValue,mode=1, proc=CopyInitialGuessRadioProc
		CheckBox CopyEpsilonRadio,pos={36,30},size={80,14},title="Copy Epsilon"
		CheckBox CopyEpsilonRadio,value= !CopyInitialGuessRadioValue,mode=1, proc=CopyInitialGuessRadioProc
		Button CopyInitialGuessDoneButton,pos={65,123},size={50,20},title="Done", proc=CopyGuessWavesDoneButtonProc
	endif
End

Function CopyGuessWavesDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR CopyInitialGuessRadioValue = root:Packages:GlobalFit:CopyInitialGuessRadioValue
	ControlInfo CopyInitialGuessRadio
	CopyInitialGuessRadioValue = V_Value
	DoWindow/K CopyToFromInitialGuessesPanel
end

Function CopyInitialGuessRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (CmpStr(ctrlName, "CopyInitialGuessRadio") == 0)
		CheckBox CopyInitialGuessRadio, value=checked
		CheckBox CopyEpsilonRadio, value=!checked
	else
		CheckBox CopyInitialGuessRadio, value=!checked
		CheckBox CopyEpsilonRadio, value=checked
	endif
End

Function WaveToInitGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=CopyToFromInitialGuessesPanel CopyInitialGuessRadio
	Variable DoInitialGuesses = V_value
	
	Wave/T/Z GuessListWave = root:Packages:GlobalFit:GuessListWave
	Wave/Z cWave = $popStr
	if (!WaveExists(cWave))
		DoAlert 0, "Strange- the wave "+popStr+" doesn't exist"
		return -1
	endif
	if (DoInitialGuesses)
		GuessListWave[][%'Initial Guess'] = num2str(cWave[p])
	else
		GuessListWave[][%'Epsilon'] = num2str(cWave[p])
	endif
	return 0
End

Function InitGuessToWaveMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=CopyToFromInitialGuessesPanel CopyInitialGuessRadio
	Variable DoInitialGuesses = V_value
	
	Wave/T/Z GuessListWave = root:Packages:GlobalFit:GuessListWave
	if (CmpStr(popStr, "New Wave...") == 0)
		Variable npnts = DimSize(GuessListWave, 0)
		String newWaveName = NewGuessWaveName()
		if (Exists(newWaveName) == 1)
			newWaveName = UniqueName(newWaveName, 1, 0)
		endif
		Make/D/N=(npnts) $newWaveName
		Wave/Z cWave = $newWaveName
		if (!WaveExists(cWave))
			return -1
		endif
	else
		Wave/Z cWave = $popStr
		if (!WaveExists(cWave))
			DoAlert 0, "Strange- the wave "+popStr+" doesn't exist"
			return -1
		endif
	endif
	if (DoInitialGuesses)
		cWave = str2num(GuessListWave[p][%'Initial Guess'])
	else
		cWave = str2num(GuessListWave[p][%'Epsilon'])
	endif
	return 0
End

static Function/S NewGuessWaveName()

	String theName = "GlobalFitCoefs"
	Prompt theName, "Enter a name for the wave:"
	DoPrompt "Save Global Fit Coefficients", theName
	
	return theName
end

static Function ConcatenateXWaves(DataSets, Xw)
	Wave/T DataSets
	Wave Xw
	
	Variable numSets = DimSize(DataSets, 0)
	Variable i
	for (i = 0; i < numSets; i += 1)
		String wName = (DataSets[i][1])+";"
		if (CmpStr(wname, "_Calculated_;") == 0)
			Wave NextYWave = $(DataSets[i][0])
			Variable nNewData = numpnts(NextYWave)
			Variable nOldData = numpnts(Xw)
			InsertPoints nOldData, nNewData, Xw
			Xw[nOldData,] = pnt2x(NextYWave, p-nOldData)			
		else
			Concatenate/NP wName, Xw
		endif
	endfor
end

Function FromTargetProc(ctrlName) : ButtonControl
	String ctrlName
	
	WAVE/T List=root:Packages:GlobalFit:DataSetList
	WAVE ListSelection=root:Packages:GlobalFit:DataSetListSelection
	
	Variable i
	Variable pointInList
	String TName
	String theGraph=WinName(0,1)
	
	Redimension/N=(1,2) List, ListSelection
	List = ""
	ListSelection = 0
	i = 0
	pointInList = 0
	
	String tlist = TraceNameList(theGraph, ";", 1)
	String aTrace
	do
		aTrace = StringFromList(i, tlist)
		if (strlen(aTrace) == 0)
			break
		endif
		
		Wave/Z w = TraceNameToWaveRef(theGraph, aTrace)
		TName = NameOfWave(w)
		if (cmpstr(TName[0,3], "Fit_") != 0)
			if (!WaveExists(w))
				break
			endif
			InsertPoints pointInList+1, 1, List, ListSelection
			List[pointInList][0] += GetWavesDataFolder(w, 2)
			WAVE/Z w = XWaveRefFromTrace(theGraph, aTrace)
			if (WaveExists(w))
				List[pointInList][1] = GetWavesDataFolder(w, 2)
			else
				List[pointInList][1] = "_Calculated_"
			endif
			pointInList += 1
		endif
		i += 1
	while(1)
	ListSelection[i][0] = 1
	
	DataSetsOKProc()
End


static Function/S MakeHoldString(CoefWave, quiet)
	Wave CoefWave
	Variable quiet

	Variable HoldCol = FindDimLabel(CoefWave, 1, "Hold")
	if (HoldCol > 0)
		String HS="/H=\""
		Variable nCoefs=DimSize(CoefWave, 0)
		Variable i
		for (i = 0; i < nCoefs; i += 1)
			if (CoefWave[i][HoldCol])
				HS += "1"
			else
				HS += "0"
			endif
		endfor
		// work from the end of the string removing extraneous zeroes
		if (strlen(HS) > 1)
			for (i = strlen(HS)-1; i >= 0; i -= 1)
				if (CmpStr(HS[i], "1") == 0)
					break
				endif
			endfor
			if (i > 0)
				HS = HS[0,i]
			endif
		endif
		HS += "\""
		if (!quiet)
			print "Hold String=", HS
		endif
		return HS
	else
		return ""
	endif
end

Static Constant MOVECONTROLSDYNAMICALLY=0

Function GlobalFitWindowHook (infoStr)
	String infoStr

	Variable statusCode = 0
	Variable MouseX
	Variable MouseY

	String Event = StringByKey("EVENT", infoStr)
	strswitch (Event)
		case "kill":
			SaveGlobalFitPanelSize()
			DoAlert 1, "Closing Global Fit control panel. Remove private Global Fit data structures (your data fits will not be affected)?"
			if (V_flag == 1)
				if (WinType("GlobalFitGraph") != 0)
					DoWindow/K GlobalFitGraph
				endif
				KillDatafolder root:Packages:GlobalFit
				statusCode = 1
			endif
			break
		case "resize":
			String win= StringByKey("WINDOW",infoStr)
			Variable pixelsToPoints = ScreenResolution/72
			GlobalFitPanelMinWindowSize(win, 406/pixelsToPoints, 474/pixelsToPoints)	// make sure the window isn't too small
			GlobalFitResize()
			statusCode=1
			break
		case "mousedown":
			MouseX = NumberByKey("MOUSEX", infoStr)
			MouseY = NumberByKey("MOUSEY", infoStr)
			ControlInfo/W=GlobalFitPanel ListDivider
			if ( (MouseX >= V_left) && (MouseX <= V_left+V_width) && (MouseY >= V_top-3) && (MouseY <= V_top+V_height+3) )
				Variable/G root:Packages:GlobalFit:MovingDivider = 1
				Variable/G root:Packages:GlobalFit:lastMouseX = mouseX
				Variable/G root:Packages:GlobalFit:lastMouseY = mouseY
				Variable/G root:Packages:GlobalFit:dividerTop = V_top
				Variable/G root:Packages:GlobalFit:dividerLeft = V_left
				SetMinMaxDividerY()
			endif
			break
		case "mousemoved":
			NVAR/Z MovingDivider = root:Packages:GlobalFit:MovingDivider
			MouseX = NumberByKey("MOUSEX", infoStr)
			MouseY = NumberByKey("MOUSEY", infoStr)
			if (NVAR_Exists(MovingDivider) && (MovingDivider) )
				NVAR lastMouseX = root:Packages:GlobalFit:lastMouseX
				NVAR lastMouseY = root:Packages:GlobalFit:lastMouseY
				NVAR dividerTop = root:Packages:GlobalFit:dividerTop
				NVAR dividerLeft = root:Packages:GlobalFit:dividerLeft
				NVAR minDividerY = root:Packages:GlobalFit:minDividerY
				NVAR maxDividerY = root:Packages:GlobalFit:maxDividerY
				Variable deltaY = mouseY - lastMouseY
				dividerTop += deltaY
				if (dividerTop < minDividerY)
					dividerTop = minDividerY
				elseif (dividerTop > maxDividerY)
					dividerTop = maxDividerY
				endif
				ControlInfo/W=GlobalFitPanel ListDivider
				if (dividerTop != V_top)
					GroupBox ListDivider pos={dividerLeft, dividerTop}
					lastMouseY = mouseY
					lastMouseX = mouseX
					if (MOVECONTROLSDYNAMICALLY)
						HandleDividerMoved(dividerTop)
					endif
				endif
			else
				ControlInfo/W=GlobalFitPanel ListDivider
				if ( (MouseX >= V_left) && (MouseX <= V_left+V_width) && (MouseY >= V_top-3) && (MouseY <= V_top+V_height+3) )
					SetWindow GlobalFitPanel hookcursor=6
				else
					SetWindow GlobalFitPanel hookcursor=0
				endif
			endif
			break
		case "mouseup":
			NVAR/Z MovingDivider = root:Packages:GlobalFit:MovingDivider
			if (NVAR_Exists(MovingDivider) && (MovingDivider) )
				// update everything...
				ControlInfo/W=GlobalFitPanel ListDivider
				HandleDividerMoved(V_top)
			endif
			Variable/G root:Packages:GlobalFit:MovingDivider = 0
			break
	endswitch

	return statusCode				// 0 if nothing done, else 1
End

static Function SetMinMaxDividerY()

	ControlInfo/W=GlobalFitPanel DataSetsGroupBox
	Variable/G root:Packages:GlobalFit:minDividerY = V_top+94
	ControlInfo/W=GlobalFitPanel GuessesGroupBox
	Variable/G root:Packages:GlobalFit:maxDividerY = V_top+V_height-100
end

static Function HandleDividerMoved(DividerTop)
	Variable DividerTop

	// resize the data sets list box and the group box containing it
	ControlInfo/W=GlobalFitPanel xdatalist
	ListBox xdatalist, win=GlobalFitPanel, size={V_Width,DividerTop-V_top-11}
	ControlInfo/W=GlobalFitPanel DataSetsGroupBox
	GroupBox DataSetsGroupBox, win=GlobalFitPanel, size={V_Width,DividerTop-V_top-5}

	// move all the controls below the data sets list
	ControlInfo/W=GlobalFitPanel GuessesGroupBox
	Variable deltaTop = DividerTop-V_top+7
	
	GroupBox GuessesGroupBox, win=GlobalFitPanel, pos={V_left,V_top+deltaTop}
	ControlInfo/W=GlobalFitPanel CopyInitialGuessListButton
	Button CopyInitialGuessListButton, win=GlobalFitPanel, pos={V_left,V_top+deltaTop}
	ControlInfo/W=GlobalFitPanel GuessesList
	ListBox GuessesList, win=GlobalFitPanel, pos={V_left,V_top+deltaTop}

	// resize the initial guesses listbox and it's group box
	ControlInfo/W=GlobalFitPanel BottomGroupBox
	Variable BottomGroupBoxTop = V_top
	
	ControlInfo/W=GlobalFitPanel GuessesList
	ListBox GuessesList, win=GlobalFitPanel, size={V_Width,BottomGroupBoxTop - V_top - 13}
	ControlInfo/W=GlobalFitPanel GuessesGroupBox
	GroupBox GuessesGroupBox, win=GlobalFitPanel, size={V_Width,BottomGroupBoxTop - V_top - 7}
End

static Function GlobalFitResize()

	GetWindow GlobalFitPanel wsize
	Variable pointsToPixels = ScreenResolution/72
	V_top = round(V_top*pointsToPixels)			// points to pixels
	V_bottom = round(V_bottom*pointsToPixels)	// points to pixels
	V_left = round(V_left*pointsToPixels)		// points to pixels
	V_right = round(V_right*pointsToPixels)		// points to pixels
	Variable newHeight= V_bottom-V_top			// points
	Variable newWidth = V_right - V_left			// points
	
	NVAR oldTop = root:Packages:GlobalFit:GlobalFitPanelTop
	NVAR oldBottom = root:Packages:GlobalFit:GlobalFitPanelBottom
	NVAR oldLeft = root:Packages:GlobalFit:GlobalFitPanelLeft
	NVAR oldRight = root:Packages:GlobalFit:GlobalFitPanelright

	Variable oldHeight = oldBottom - oldTop
	Variable deltaHeight = newHeight - oldHeight
	Variable oldWidth = oldRight - oldLeft
	Variable deltaWidth = newWidth - oldWidth
	
	MoveWindow /W=GlobalFitPanel V_left/pointsToPixels, V_top/pointsToPixels, V_right/pointsToPixels, V_bottom/pointsToPixels
	SaveGlobalFitPanelSize()

	Variable DataSetsGroupBoxTop = 132		// this never moves!	
	
	// move all the controls below the initial guesses group box
	if ( (deltaHeight != 0) || (deltaWidth != 0) )
		ControlInfo/W=GlobalFitPanel ParametersGroupBox
		GroupBox ParametersGroupBox, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel ParamTypesListBox
		ListBox ParamTypesListBox, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel DataSetsGroupBox
		GroupBox DataSetsGroupBox, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel xdatalist
		ListBox xdatalist, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel WavesFromTarget
		Button WavesFromTarget, win=GlobalFitPanel, pos={V_left+deltaWidth, V_top}
		
		ControlInfo/W=GlobalFitPanel ListDivider
		GroupBox ListDivider, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel BottomGroupBox
		Variable BottomGroupBoxTop = V_top+deltaHeight
		GroupBox BottomGroupBox, win=GlobalFitPanel, pos={V_left,BottomGroupBoxTop}, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel GuessesGroupBox
		GroupBox GuessesGroupBox, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel GuessesList
		ListBox GuessesList, win=GlobalFitPanel, size = {V_width+deltaWidth, V_height}
		
		ControlInfo/W=GlobalFitPanel ConstraintsCheckBox
		CheckBox ConstraintsCheckBox, win=GlobalFitPanel, pos={V_left,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel WeightingCheckBox
		Variable DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
//		Variable DeltaControlPosition = 0
		CheckBox WeightingCheckBox, win=GlobalFitPanel, pos={DeltaControlPosition,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel MaskingCheckBox
		DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
		CheckBox MaskingCheckBox, win=GlobalFitPanel, pos={DeltaControlPosition,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel DoCovarMatrix
//		DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
		CheckBox DoCovarMatrix, win=GlobalFitPanel, pos={V_left + deltaWidth,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel AppendResultsCheck
		CheckBox AppendResultsCheck, win=GlobalFitPanel, pos={V_left,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel DoResidualCheck
		DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
		CheckBox DoResidualCheck, win=GlobalFitPanel, pos={DeltaControlPosition,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel GFSetFitCurveLength
		DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
		SetVariable GFSetFitCurveLength, win=GlobalFitPanel, pos={DeltaControlPosition,V_top+deltaHeight}
		
		ControlInfo/W=GlobalFitPanel DoFitButton
		DeltaControlPosition = round(NewWidth*(V_left/oldWidth))
		Button DoFitButton, win=GlobalFitPanel, pos={V_left + deltaWidth,V_top+deltaHeight}
		
		// Make sure that the lists won't be too short after resize
		ControlInfo/W=GlobalFitPanel ListDivider
		Variable DividerTop = V_top
		Variable DividerLeft = V_left
		
		if ( (BottomGroupBoxTop - DividerTop) < 107)
			DividerTop = BottomGroupBoxTop - 107
		endif
		
		if ( (DividerTop - DataSetsGroupBoxTop) < 94)
			DividerTop = DataSetsGroupBoxTop + 94
		endif
		
		if (DividerTop != V_top)
			// move the divider between the guess list and the datasets list
			GroupBox ListDivider, pos={DividerLeft, DividerTop}
		endif
		
		// and adjust everything around the divider
		HandleDividerMoved(DividerTop)
	endif
End

// keep the width always the same, allow height resize
static Function GlobalFitPanelMinWindowSize(winName,minwidth,minheight)
	String winName
	Variable minwidth,minheight

	GetWindow $winName wsize
	Variable width= max(V_right - V_left, minwidth)
	Variable height= max(V_bottom-V_top,minheight)
	MoveWindow/W=$winName V_left, V_top, V_left+width, V_top+height
End


//***********************************
//
// Constraints
//
//***********************************

Function ConstraintsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Wave/T/Z GuessListWave = root:Packages:GlobalFit:GuessListWave
	NVAR TotalParams= root:Packages:GlobalFit:TotalParams
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	if (checked)
		if (NumSets == 0)
			CheckBox ConstraintsCheckBox, win=GlobalFitPanel, value=0
			DoAlert 0, "You cannot add constraints until you have selected data sets"
			return 0
		else
			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:GlobalFit
			
			Wave/T/Z SimpleConstraintsListWave
			if (!(WaveExists(SimpleConstraintsListWave) && (DimSize(SimpleConstraintsListWave, 0) == TotalParams)))
				Make/O/N=(TotalParams, 5)/T SimpleConstraintsListWave=""
			endif
			SimpleConstraintsListWave[][0] = "K"+num2istr(p)
			SimpleConstraintsListWave[][1] = GuessListWave[p][%Coefficient]
			SimpleConstraintsListWave[][3] = "< K"+num2istr(p)+" <"
			Make/O/N=(TotalParams,5) SimpleConstraintsSelectionWave
			SimpleConstraintsSelectionWave[][0] = 0		// K labels
			SimpleConstraintsSelectionWave[][1] = 0		// coefficient labels
			SimpleConstraintsSelectionWave[][2] = 2		// editable- greater than constraints
			SimpleConstraintsSelectionWave[][3] = 0		// "< Kn <"
			SimpleConstraintsSelectionWave[][4] = 2		// editable- less than constraints
			SetDimLabel 1, 0, 'Kn', SimpleConstraintsListWave
			SetDimLabel 1, 1, 'Actual Coefficient', SimpleConstraintsListWave
			SetDimLabel 1, 2, 'Min', SimpleConstraintsListWave
			SetDimLabel 1, 3, ' ', SimpleConstraintsListWave
			SetDimLabel 1, 4, 'Max', SimpleConstraintsListWave
			
			Wave/Z/T MoreConstraintsListWave
			if (!WaveExists(MoreConstraintsListWave))
				Make/N=(1,1)/T/O  MoreConstraintsListWave=""
				Make/N=(1,1)/O MoreConstraintsSelectionWave=6
				SetDimLabel 1,0,'Enter Constraint Expressions', MoreConstraintsListWave
			endif
			MoreConstraintsSelectionWave=6
			
			SetDatafolder $saveDF
			
			if (WinType("GlobalFitConstraintPanel") > 0)
				DoWindow/F GlobalFitConstraintPanel
			else
				fGlobalFitConstraintPanel()
			endif
		endif
	endif
End

static Function fGlobalFitConstraintPanel()

	NewPanel /W=(45,203,451,568)
	DoWindow/C GlobalFitConstraintPanel
	AutoPositionWindow/M=1/E

	GroupBox SimpleConstraintsGroup,pos={5,7},size={394,184},title="Simple Constraints"
	Button SimpleConstraintsClearB,pos={21,24},size={138,20},proc=SimpleConstraintsClearBProc,title="Clear List"
	ListBox constraintsList,pos={12,49},size={380,127},listwave=root:Packages:GlobalFit:SimpleConstraintsListWave
	ListBox constraintsList,selWave=root:Packages:GlobalFit:SimpleConstraintsSelectionWave, mode=7
	ListBox constraintsList,widths={30,189,50,40,50}, editStyle= 1,frame=2

	GroupBox AdditionalConstraintsGroup,pos={5,192},size={394,138},title="Additional Constraints"
	ListBox moreConstraintsList,pos={12,239},size={380,85}, listwave=root:Packages:GlobalFit:MoreConstraintsListWave
	ListBox moreConstraintsList,selWave=root:Packages:GlobalFit:MoreConstraintsSelectionWave, mode=4
	ListBox moreConstraintsList, editStyle= 1,frame=2
	Button NewConstraintLineButton,pos={21,211},size={138,20},title="Add a Line", proc=NewConstraintLineButtonProc
	Button RemoveConstraintLineButton01,pos={185,211},size={138,20},title="Remove Selection", proc=RemoveConstraintLineButtonProc

	Button GlobalFitConstraintsDoneB,pos={6,339},size={50,20},proc=GlobalFitConstraintsDoneBProc,title="Done"
EndMacro

Function SimpleConstraintsClearBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T SimpleConstraintsListWave = root:Packages:GlobalFit:SimpleConstraintsListWave
	SimpleConstraintsListWave[][2] = ""
	SimpleConstraintsListWave[][4] = ""
End

Function NewConstraintLineButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = root:Packages:GlobalFit:MoreConstraintsListWave
	Wave/Z MoreConstraintsSelectionWave = root:Packages:GlobalFit:MoreConstraintsSelectionWave
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	InsertPoints nRows, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
	MoreConstraintsListWave[nRows] = ""
	MoreConstraintsSelectionWave[nRows] = 6
	Redimension/N=(nRows+1,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

Function RemoveConstraintLineButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = root:Packages:GlobalFit:MoreConstraintsListWave
	Wave/Z MoreConstraintsSelectionWave = root:Packages:GlobalFit:MoreConstraintsSelectionWave
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	Variable i = 0
	do
		if (MoreConstraintsSelectionWave[i] & 1)
			if (nRows == 1)
				MoreConstraintsListWave[0] = ""
				MoreConstraintsSelectionWave[0] = 6
			else
				DeletePoints i, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
				nRows -= 1
			endif
		else
			i += 1
		endif
	while (i < nRows)
	Redimension/N=(nRows,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End


Function GlobalFitConstraintsDoneBProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K GlobalFitConstraintPanel
End

static Function GlobalFitMakeConstraintWave()

	Wave/Z/T SimpleConstraintsListWave = root:Packages:GlobalFit:SimpleConstraintsListWave
	Wave/Z/T MoreConstraintsListWave = root:Packages:GlobalFit:MoreConstraintsListWave
	
	Make/O/T/N=0 root:Packages:GlobalFit:GFUI_GlobalFitConstraintWave
	Wave/T GlobalFitConstraintWave = root:Packages:GlobalFit:GFUI_GlobalFitConstraintWave
	Variable nextRow = 0
	String constraintExpression
	Variable i, nPnts=DimSize(SimpleConstraintsListWave, 0)
	for (i=0; i < nPnts; i += 1)
		if (strlen(SimpleConstraintsListWave[i][2]) > 0)
			InsertPoints nextRow, 1, GlobalFitConstraintWave
			sprintf constraintExpression, "K%d > %s", i, SimpleConstraintsListWave[i][2]
			GlobalFitConstraintWave[nextRow] = constraintExpression
			nextRow += 1
		endif
		if (strlen(SimpleConstraintsListWave[i][4]) > 0)
			InsertPoints nextRow, 1, GlobalFitConstraintWave
			sprintf constraintExpression, "K%d < %s", i, SimpleConstraintsListWave[i][4]
			GlobalFitConstraintWave[nextRow] = constraintExpression
			nextRow += 1
		endif
	endfor
	
	nPnts = DimSize(MoreConstraintsListWave, 0)
	for (i = 0; i < nPnts; i += 1)
		if (strlen(MoreConstraintsListWave[i]) > 0)
			InsertPoints nextRow, 1, GlobalFitConstraintWave
			GlobalFitConstraintWave[nextRow] = MoreConstraintsListWave[i]
			nextRow += 1
		endif
	endfor
end

//***********************************
//
// Weighting
//
//***********************************

Function WeightingCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	WAVE/T DataSetList=root:Packages:GlobalFit:DataSetList
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	if (checked)
		if (NumSets == 0)
			CheckBox WeightingCheckBox, win=GlobalFitPanel, value=0
			DoAlert 0, "You cannot add weighting waves until you have selected data sets."
			return 0
		else
			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:GlobalFit
			
			Wave/T/Z WeightingListWave
			if (!(WaveExists(WeightingListWave) && (DimSize(WeightingListWave, 0) == NumSets)))
				Make/O/N=(NumSets, 2)/T WeightingListWave=""
			endif
			WeightingListWave[][0] = DataSetList[p][0]
			Make/O/N=(NumSets, 2) WeightingSelectionWave
			WeightingSelectionWave[][0] = 0		// Data Sets
			WeightingSelectionWave[][1] = 0		// Weighting Waves; not editable- select from menu
			SetDimLabel 1, 0, 'Data Set', WeightingListWave
			SetDimLabel 1, 1, 'Weight Wave', WeightingListWave
			
			SetDatafolder $saveDF
			
			if (WinType("GlobalFitWeightingPanel") > 0)
				DoWindow/F GlobalFitWeightingPanel
			else
				fGlobalFitWeightingPanel()
			endif
			
			Variable/G root:Packages:GlobalFit:GlobalFit_WeightsAreSD = NumVarOrDefault("root:Packages:GlobalFit:GlobalFit_WeightsAreSD", 1)
			NVAR GlobalFit_WeightsAreSD = root:Packages:GlobalFit:GlobalFit_WeightsAreSD
			if (GlobalFit_WeightsAreSD)
				WeightsSDRadioProc("WeightsSDRadio",1)
			else
				WeightsSDRadioProc("WeightsInvSDRadio",1)
			endif
						
		endif
	endif	
end

static Function fGlobalFitWeightingPanel() : Panel

	NewPanel /W=(339,193,745,408)
	DoWindow/C GlobalFitWeightingPanel
	AutoPositionWindow/M=1/E
	
	ListBox WeightWaveListBox,pos={9,63},size={387,112}, mode=2, listWave = root:Packages:GlobalFit:WeightingListWave
	ListBox WeightWaveListBox, selWave = root:Packages:GlobalFit:WeightingSelectionWave, frame=2
	Button GlobalFitWeightDoneButton,pos={24,186},size={50,20},proc=GlobalFitWeightDoneButtonProc,title="Done"
	Button GlobalFitWeightCancelButton,pos={331,186},size={50,20},proc=GlobalFitWeightCancelButtonProc,title="Cancel"
	PopupMenu GlobalFitWeightWaveMenu,pos={9,5},size={152,20},title="Select Weight Wave"
	PopupMenu GlobalFitWeightWaveMenu,mode=0,value= #"ListPossibleWeightWaves()", proc=WeightWaveSelectionMenu
	Button WeightClearSelectionButton,pos={276,5},size={120,20},proc=WeightClearSelectionButtonProc,title="Clear Selection"
	Button WeightClearAllButton,pos={276,32},size={120,20},proc=WeightClearSelectionButtonProc,title="Clear All"

	GroupBox WeightStdDevRadioGroup,pos={174,4},size={95,54},title="Weights  are"
	CheckBox WeightsSDRadio,pos={185,22},size={60,14},proc=WeightsSDRadioProc,title="Std. Dev."
	CheckBox WeightsSDRadio,value= 0, mode=1
	CheckBox WeightsInvSDRadio,pos={185,38},size={73,14},proc=WeightsSDRadioProc,title="1/Std. Dev."
	CheckBox WeightsInvSDRadio,value= 0, mode=1
EndMacro


Function GlobalFitWeightDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z WeightingListWave=root:Packages:GlobalFit:WeightingListWave
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	Variable i
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(WeightingListWave[i][1])
		if (!WaveExists(w))
			ListBox WeightWaveListBox, win=GlobalFitWeightingPanel, selRow = i
			DoAlert 0, "The wave \""+WeightingListWave[i][1]+"\" does not exist."
			WeightingListWave[i][1] = ""
			return -1
		endif
	endfor
		
	DoWindow/K GlobalFitWeightingPanel
End

Function GlobalFitWeightCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K GlobalFitWeightingPanel
	CheckBox WeightingCheckBox, win=GlobalFitPanel, value=0
End

Function/S ListPossibleWeightWaves()

	Wave/T/Z WeightingListWave=root:Packages:GlobalFit:WeightingListWave
	Wave/Z WeightingSelectionWave=root:Packages:GlobalFit:WeightingSelectionWave
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	String DataSetName=""
	Variable i
	
	ControlInfo/W=GlobalFitWeightingPanel WeightWaveListBox
	DataSetName = WeightingListWave[V_value][0]
	
	if (strlen(DataSetName) == 0)
		return "No Selection;"
	endif
	
	Wave/Z ds = $DataSetName
	if (!WaveExists(ds))
		return "Unknown Data Set;"
	endif
	
	Variable numpoints = DimSize(ds, 0)
	String theList = ""
	i=0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		if ( (DimSize(w, 0) == numpoints) && (WaveType(w) & 6) )		// select floating-point waves with the right number of points
			theList += NameOfWave(w)+";"
		endif
		i += 1
	while (1)
	
	if (i == 0)
		return "None Available;"
	endif
	
	return theList
end

Function WeightWaveSelectionMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/Z w = $popStr
	if (WaveExists(w))
		Wave/T WeightingListWave=root:Packages:GlobalFit:WeightingListWave
		ControlInfo/W=GlobalFitWeightingPanel WeightWaveListBox
		WeightingListWave[V_value][1] = GetWavesDatafolder(w, 2)
	endif
end

Function WeightClearSelectionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z WeightingListWave=root:Packages:GlobalFit:WeightingListWave
	StrSwitch (ctrlName)
		case "WeightClearSelectionButton":
			ControlInfo/W=GlobalFitWeightingPanel WeightWaveListBox
			if (V_flag == 11)
				WeightingListWave[V_value][1] = ""
			else
				DoAlert 0, "BUG: couldn't access weight list box for Global Fit"
			endif
			break;
		case "WeightClearAllButton":
			WeightingListWave[][1] = ""
			break;
	endswitch
End

Function WeightsSDRadioProc(name,value)
	String name
	Variable value
	
	NVAR GlobalFit_WeightsAreSD= root:Packages:GlobalFit:GlobalFit_WeightsAreSD
	
	strswitch (name)
		case "WeightsSDRadio":
			GlobalFit_WeightsAreSD = 1
			break
		case "WeightsInvSDRadio":
			GlobalFit_WeightsAreSD = 0
			break
	endswitch
	CheckBox WeightsSDRadio, win=GlobalFitWeightingPanel, value= GlobalFit_WeightsAreSD==1
	CheckBox WeightsInvSDRadio, win=GlobalFitWeightingPanel, value= GlobalFit_WeightsAreSD==0
End

// This function is strictly for the use of the Global Analysis control panel. It assumes that the DataSets
// wave so far has just two columns, the Y and X wave columns
static Function GFUI_AddWeightWavesToDataSets(DataSets)
	Wave/T DataSets
	
	Wave/T/Z WeightingListWave=root:Packages:GlobalFit:WeightingListWave
	
	Redimension/N=(-1, 3) DataSets
	SetDimLabel 1, 2, Weights, DataSets
	
	Variable numSets = DimSize(DataSets, 0)
	Variable i
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(WeightingListWave[i][1])
		if (WaveExists(w))
			wave/Z yw = $(DataSets[i][0])
			if (WaveExists(yw) && (numpnts(w) != numpnts(yw)))
				DoAlert 0,"The weighting wave \""+WeightingListWave[i][1]+"\" has a different number points than Y wave \""+(DataSets[i][0])+"\""
				return -1
			endif
			DataSets[i][2] = WeightingListWave[i][1]
		else
			Redimension/N=(-1,2) DataSets
			DoAlert 0,"The weighting wave \""+WeightingListWave[i][1]+"\" for Y wave \""+(DataSets[i][0])+"\" does not exist."
			return -1
		endif
	endfor
	
	return 0
end

static Function GFUI_AddMaskWavesToDataSets(DataSets)
	Wave/T DataSets
	
	Wave/T/Z MaskingListWave=root:Packages:GlobalFit:MaskingListWave
	
	Variable startingNCols = DimSize(DataSets, 1)
	Redimension/N=(-1, startingNCols+1) DataSets
	SetDimLabel 1, startingNCols, Masks, DataSets
	
	Variable numSets = DimSize(DataSets, 0)
	Variable i
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(MaskingListWave[i][1])
		if (WaveExists(w))
			wave/Z yw = $(DataSets[i][0])
			if (WaveExists(yw) && (numpnts(w) != numpnts(yw)))
				DoAlert 0,"The mask wave \""+MaskingListWave[i][1]+"\" has a different number points than Y wave \""+(DataSets[i][0])+"\""
				return -1
			endif
			DataSets[i][startingNCols] = MaskingListWave[i][1]
		else
			Redimension/N=(-1,startingNCols) DataSets
			DoAlert 0,"The mask wave \""+MaskingListWave[i][1]+"\" for Y wave \""+(DataSets[i][0])+"\" does not exist."
			return -1
		endif
	endfor
	
	return 0
end

//***********************************
//
// Data masking
//
//***********************************

Function MaskingCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	WAVE/T DataSetList=root:Packages:GlobalFit:DataSetList
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	if (checked)
		if (NumSets == 0)
			CheckBox MaskingCheckBox, win=GlobalFitPanel, value=0
			DoAlert 0, "You cannot add Masking waves until you have selected data sets."
			return 0
		else
			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:GlobalFit
			
			Wave/T/Z MaskingListWave
			if (!(WaveExists(MaskingListWave) && (DimSize(MaskingListWave, 0) == NumSets)))
				Make/O/N=(NumSets, 2)/T MaskingListWave=""
			endif
			MaskingListWave[][0] = DataSetList[p][0]
			Make/O/N=(NumSets, 2) MaskingSelectionWave
			MaskingSelectionWave[][0] = 0		// Data Sets
			MaskingSelectionWave[][1] = 0		// Masking Waves; not editable- select from menu
			SetDimLabel 1, 0, 'Data Set', MaskingListWave
			SetDimLabel 1, 1, 'Mask Wave', MaskingListWave
			
			SetDatafolder $saveDF
			
			if (WinType("GlobalFitMaskingPanel") > 0)
				DoWindow/F GlobalFitMaskingPanel
			else
				fGlobalFitMaskingPanel()
			endif
		endif
	endif	
end

static Function fGlobalFitMaskingPanel() : Panel

	NewPanel /W=(339,193,745,408)
	DoWindow/C GlobalFitMaskingPanel
	AutoPositionWindow/M=1/E
	
	ListBox MaskWaveListBox,pos={9,63},size={387,112}, mode=2, listWave = root:Packages:GlobalFit:MaskingListWave
	ListBox MaskWaveListBox, selWave = root:Packages:GlobalFit:MaskingSelectionWave, frame=2
	Button GlobalFitMaskDoneButton,pos={24,186},size={50,20},proc=GlobalFitMaskDoneButtonProc,title="Done"
	Button GlobalFitMaskCancelButton,pos={331,186},size={50,20},proc=GlobalFitMaskCancelButtonProc,title="Cancel"
	PopupMenu GlobalFitMaskWaveMenu,pos={9,5},size={152,20},title="Select Mask Wave"
	PopupMenu GlobalFitMaskWaveMenu,mode=0,value= #"ListPossibleMaskWaves()", proc=MaskWaveSelectionMenu
	Button MaskClearSelectionButton,pos={276,5},size={120,20},proc=MaskClearSelectionButtonProc,title="Clear Selection"
	Button MaskClearAllButton,pos={276,32},size={120,20},proc=MaskClearSelectionButtonProc,title="Clear All"
EndMacro


Function GlobalFitMaskDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z MaskingListWave=root:Packages:GlobalFit:MaskingListWave
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	Variable i
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(MaskingListWave[i][1])
		if (!WaveExists(w))
			if (strlen(MaskingListWave[i][1]) != 0)
				ListBox MaskWaveListBox, win=GlobalFitMaskingPanel, selRow = i
				DoAlert 0, "The wave \""+MaskingListWave[i][1]+"\" does not exist."
				MaskingListWave[i][1] = ""
				return -1
			endif
		endif
	endfor
		
	DoWindow/K GlobalFitMaskingPanel
End

Function GlobalFitMaskCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K GlobalFitMaskingPanel
	CheckBox MaskingCheckBox, win=GlobalFitPanel, value=0
End

Function/S ListPossibleMaskWaves()

	Wave/T/Z MaskingListWave=root:Packages:GlobalFit:MaskingListWave
	Wave/Z MaskingSelectionWave=root:Packages:GlobalFit:MaskingSelectionWave
	NVAR NumSets= root:Packages:GlobalFit:NumSets

	String DataSetName=""
	Variable i
	
	ControlInfo/W=GlobalFitMaskingPanel MaskWaveListBox
	DataSetName = MaskingListWave[V_value][0]
	
	if (strlen(DataSetName) == 0)
		return "No Selection;"
	endif
	
	Wave/Z ds = $DataSetName
	if (!WaveExists(ds))
		return "Unknown Data Set;"
	endif
	
	Variable numpoints = DimSize(ds, 0)
	String theList = ""
	i=0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		if ( (DimSize(w, 0) == numpoints) && (WaveType(w) & 6) )		// select floating-point waves with the right number of points
			theList += NameOfWave(w)+";"
		endif
		i += 1
	while (1)
	
	if (i == 0)
		return "None Available;"
	endif
	
	return theList
end

Function MaskWaveSelectionMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/Z w = $popStr
	if (WaveExists(w))
		Wave/T MaskingListWave=root:Packages:GlobalFit:MaskingListWave
		ControlInfo/W=GlobalFitMaskingPanel MaskWaveListBox
		MaskingListWave[V_value][1] = GetWavesDatafolder(w, 2)
	endif
end

Function MaskClearSelectionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z MaskingListWave=root:Packages:GlobalFit:MaskingListWave
	StrSwitch (ctrlName)
		case "MaskClearSelectionButton":
			ControlInfo/W=GlobalFitMaskingPanel MaskWaveListBox
			if (V_flag == 11)
				MaskingListWave[V_value][1] = ""
			else
				DoAlert 0, "BUG: couldn't access Mask list box for Global Fit"
			endif
			break;
		case "MaskClearAllButton":
			MaskingListWave[][1] = ""
			break;
	endswitch
End

//***********************************
//
// Utility functions
//
//***********************************

// returns semicolon-separated list of items in a selected column of a 1D or 2D text wave
static Function/S TextWaveToList(twave, column)
	Wave/T twave
	Variable column
	
	String returnValue = ""
	Variable nRows = DimSize(twave, 0)
	Variable i
	
	for (i = 0; i < nRows; i += 1)
		returnValue += (twave[i][column])+";"
	endfor
	
	return returnValue
end

// makes a 1D or 2D text wave with each item from a semicolon-separated list in the wave's rows
// in the selected column. You are free to fill other columns as you wish.
static Function ListToTwave(theList, twaveName, columns, column)
	String theList
	String twaveName
	Variable columns
	Variable column
	
	Variable nRows = ItemsInList(theList)
	Variable i
	
	Make/T/O/N=(nRows, columns) $twaveName
	Wave/T twave = $twaveName
	
	for (i = 0; i < nRows; i += 1)
		twave[i][column] = StringFromList(i, theList)
	endfor

end