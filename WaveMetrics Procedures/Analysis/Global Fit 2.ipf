#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma version = 1.39
#pragma IgorVersion = 8.00
#pragma ModuleName= WM_NewGlobalFit1

#include <BringDestToFront>
#include <SaveRestoreWindowCoords>
#include <WaveSelectorWidget> version>=1.22
#include <PopupWaveSelector>

//**************************************
// Changes in Global Fit procedures
// 
//	1.00	first release of Global Fit 2. Adds multi-function capability and ability to link fit coefficients
//			in arbitrary groups. Thus, a coefficient that is not linked to any other coefficient is a "local"
//			coefficient. A coefficient that has all instances linked together is global. This is what the original
//			Global Fit package allowed. In addition, Global Fit 2 allows you to link coefficients into groups that
//			span different fitting functions, or include just a subset of instances of a coefficient.
//
//	1.01	Fixed bugs in contextual menu that pops up from the Initial Guess title cell in the coefficient list
//				on the Coefficient Control tab.
//			Now handles NaN's in data sets, mask waves and weight waves
//
//	1.02	Now uses global string variable for hold string to avoid making the command too long.
//
//	1.03	Cleaned up contextual menus a bit. Click in Data Sets and Functions list requires Control key to present menu.
//			Coefficient list on Coefficient Control tab has items that read "... Selection to(from) wave..." when a selection is present.
//
//	1.04 	Fixed bug: On Windows, if the Global Fit panel was minimized, it gave an error when the window resize code tried to
//			arrange the controls in a too-small window.
//
//	1.05	Fixed bugs:
//				Mask wave panel didn't get full paths for Y waves, so it didn't work correctly when Y waves were
//				not in root:
//
//				Coefficient Control list didn't update when Y waves were replaced using the Set Y Wave menu.
//
//  1.06	If the Global Fit control panel was re-sized very large to see lots of coefficients, the coefficient control
//				tab could be seen at the right edge.
//
//			Waves named "fit_<data set name>" were created but not used. They are no longer made.
//
//	1.07	Fixed a bug in NewGF_SetCoefsFromWaveProc that caused problems with the Set from Wave menu.
//	1.08	Fixed a bug in NewGF_CoefRowForLink() that caused problems connected linked cells on the Coefficient
//				Control tab.
//	1.09	Added option for log-spaced X axis for destination waves.
//	1.10	Fixed the bug caused by the fix at 1.08. Had to create a new function: NewGF_CoefListRowForLink(); 
//			NewGF_CoefRowForLink() was being used for two different but related purposes.
//	1.11	Fixed endless feedback between data sets list and linkage list if scrolling in either ocurred very rapidly. It is
//			relatively easy to do with a scroll wheel.
//	1.12	Fixed a bug that could cause problems with the display of coefficient names in the list on the right in the
//			Data Sets and Functions tab.
//	1.13	Uses features new in 6.10 to improve error reporting.
//	1.14	Added control for setting maximum iterations.
//	1.15	Added draggable divider between lists on Data Sets and Functions tab.
//			Added creation of per-dataset sigma waves to go with the per-dataset coefficient waves.
//	1.16	New data set selector
//			fixed minor bug in New Data Folder option for choosing data folder for results: added ":" to the parent data folder choice.
//	1.17	Fixed bug: Null String error ocurred if you didn't have Fit Progress Graph selected.
//	1.18	 Fixed bugs:
//			When re-opening the control panel, call to WC_WindowCoordinatesSprintf had a zero last parameter instead of one, resulting in bad sizing on Windows.
//			When re-opening the control panel after closing it, InitNewGlobalFitGlobals() was called, destroying the last set-up.
//			Fixed several index-out-of-range errors.
//	1.19	Fixed bugs:
//			If you used fit functions with unequal numbers of parameters, NewGlblFitFunc and NewGlblFitFuncAllAtOnce would cause an index out of range error
//				during assignment to SC, due to -1 stored as a dummy in the extra slots in the CoefDataSetLinkage wave.
//			The use of a pre-made scratch wave as the temporary coefficient wave inside NewGlblFitFunc and NewGlblFitFuncAllAtOnce when using fit functions
//				having unequal numbers of parameters caused some fit functions to fail, if they depended on the number of points in the coefficient wave being exactly right.
//			Changed:
//			The temporary coefficent wave SC is now a free wave created inside NewGlblFitFunc and NewGlblFitFuncAllAtOnce instead of ScratchCoefs. That saves looking up
//				the ScratchCoefs wave, and the code required to maintain ScratchCoefs. The ScratchCoefs wave has been eliminated.
//	1.20	Fixed bug:
//			Index out-of-range error in DataSetsMvSelectedWavesUpOrDown()
//	1.21	Fixed bug:
//			If the coefficient wave has no column with dimension label "Hold", it gave an error while printing the coefficients to the history window.
//	1.22	Removed usage comments for DoNewGlobalFit. More accurate and extensive help for using DoNewGlobalFit are have been put into the Global Fit 2 help file.
//	1.23	Fixed index-out-of-range error assigning colors to traces in the Global Analysis Progress graph. Now, if the number of traces is larger than the number
//				of colors in the color index wave, it uses the mod function to recycle through the colors.
//	1.24	Added /W=2 flag to FuncFit call so that the Curve Fit Progress window doesn't show. May make Global Fit run faster, and avoids some problems on Windows
//			if a breakpoint is set in the user's fit function.
//	1.25	Add flag so that if the template fit function runs, it only alerts once per fit.
//	1.26	PanelResolution for compatibility with Igor 7.
//	1.27	Changed routine for enforcing minimum window size to avoid screwing up when the Maximize button is clicked on Windows.
// 1.28 JP160517: Uses SetWindow sizeLimit for Igor 7
// 1.29 JP161114: Corrected some popup menus to fix dividing lines.
// 1.30	JW 170911 Added NewGFOptionGLOBALFITVARS options flag to allow a programmer to get some of the fit results as global variables if desired.
// 1.31	JW 171212 Fixed broken Help link for the Help button in the control panel.
// 1.32	JW 180625 Added code to patch up old experiments that have a 2D data sets list wave.
// 1.33 JW 190415 Added code to patch up old experiments that have a 2D main coefficients wave (the one with colors to indicate linkages)
// 1.34	JW 190710
//			Fixed broken Help link for the Help button in the control panel.
//			Corrected position of Help button when the panel is resized.
//			Fixed bug: if you replaced a fit function with a different one, and there were cells linked to the old function coefficients, an Index Out of Range error resulted.
//			Fixed bug: with the bug just described fixed, if you replaced the fit function and then tried to set new linkaged,
//				an Index Out of Range error resulted because the Coefficient Control list had not been re-built yet.
//			Added Select Coefs Named popup menu to Data Sets and Functions tab allowing you to select all coefficients regardless of the fit function
//				that have the same name.
// 1.35 JW 200807
//			Fixed a bug: In the Add/Remove Data Sets panel, the From Target checkbox had never been implemented.
// 		ST 200812
//			Implemented layout tweaks for the Add/Remove Data Sets panel.
// 1.36 ST 210602
//			Tweaked the layout of most controls and sizes of the main panel.
//			The help button now aligns with the panel edge on Windows and has enough space to the tab control.
//			The tab controls in the main panel are fully visible now (the sub-panels are made transparent).
//			The Weighting, Masking and Constraints panels now scale the controls with panel size, and the layout was improved.
//			Now the constraints checkbox reverts to the disabled state when there are no entries made in the Constraints panel.
//			The menu call when starting the panel will not be printed in the history anymore.
// 1.36 ST 210603
//			Fixed bugs in the Create Folder panel: It was possible to open multiple panels (successive panels did not work), and an empty folder name led to errors.
//			Improved layout and fixed the minimal size of the Create Folder panel.
//			Fixed bug: The coefficient column may show NaN or Inf if an invalid input was made.
// 1.36 ST 210607
//			Re-added Clear Selection and Clear All buttons to Weighting panel.
//			Converted wave selection in the Mask and Weighting panels into wave selector widgets.
//			Fixed bug: Data Wave Selector panel allowed to select 2D waves.
//			Now the Mask and Weighting check-boxes revert to the disabled state when there are no entries made in the respective panels.
//			Fixed bug: Mask and Weighting panel - direct selection of waves inside the list-box works now.
//			Mask and Weighting panel: A warning message is displayed when the size of the data waves and the selected waves do not match.
// 1.36 ST 210615
//			Mask and Weighting panel - the title is not displayed anymore inside the wave selector widget's list.
//			Weighting panel - increased size of Select Weight Wave control.
//			Make sure the help button is not overlapping with the tab control on Mac.
//			Weighting / masking waves can be omitted now for selected data sets. The fit will assume no weighting / masking for these sets.
// 1.36 ST 210617
//			Prevent keyboard events from being printed for the data set list.
//			Command / ctrl + a will select the whole function column in the data set list.
//			Fixed bug: if a new function was selected for a row with linked coefficients then the link color was not reset.
// 1.36 ST 210624
//			Implemented coefficient list filtering and sorting.
//			Added new entries to the coefficient list's right-click menus: Copy value to same coefs, clear coef values and fill coef with linear series.
// 1.36 ST 210626
//			Fixed bug: if values were loaded from a wave into the master coefficient list for a limited selection then linked coefficients were not set properly.
//			Added "built-in" fit-functions: Gauss, Lorentzian, exponential, double-exponential and exponentially modified Gaussian.
// 1.36 ST 210630
//			Added two more "built-in" fit-functions: Voigt and the error function.
// 1.37 ST 211006
//			Fixed bug: When an older panel without sorting functionality was used then the Coefficient Control list was not properly updated.
// 1.37 ST 220130
//			Fixed bug: Hold values were not written correctly with sorting, since the sorted => unsorted conversion was done wrong within NewGF_DoTheFitButtonProc().
// 1.38 JW 221205
//			Global Fit no longer sets the current data folder during the call to FuncFit, allowing user's fit functions to run in their expected data folder.
//			That change results (annoyingly) in having W_sigma and M_covar being saved into the user's data folder. Oh, well.
//			Fixed a bug in the try-catch block around FuncFit that prevented the catch from actually catching FuncFit errors.
// 1.38 ST 230127
//			Fixed two bugs with 'divider line' between the data and coefficient lists: Drag area was appearing outside the valid area and was not expansion-aware.
// 1.38 ST 230719
//			Fixed bug in DoNewGlobalFit(): Missing wave errors for W_sigma and M_Covar when user aborted fitting.
// 		JW 230720
//			Removed duplicated printing of V_FitQuitReason results
// 1.39 JW 231108
//			Fixed bug: Selecting a fitting function didn't rebuild the master coefficient list, resulting in index-out-of-range
//			errors when you tried to link coefficients.
//**************************************

//**************************************
// Things to add in the future:
// 
//		Mask, constraint, weight panels should use wave selector widgets - DONE!
//
// 		Want something? Tell support@wavemetrics.com about it!
//**************************************

Menu "Analysis"
	"Global Fit",/Q, WM_NewGlobalFit1#InitNewGlobalFitPanel()			// ST: 210602 - silence the menus
	"Unload Global Fit",/Q, WM_NewGlobalFit1#UnloadNewGlobalFit()
end

// This is the prototype function for the user's fit function
// If you create your fitting function using the New Fit Function button in the Curve Fitting dialog,
// it will have the FitFunc keyword, and that will make it show up in the menu in the Global Fit control panel.
Function GFFitFuncTemplate(w, xx) : FitFunc
	Wave w
	Variable xx
	
	NVAR/Z templateAlerted = root:Packages:NewGlobalFit:runningTemplateAlerted
	if (!NVAR_Exists(templateAlerted) || templateAlerted == 0)
		Variable/G root:Packages:NewGlobalFit:runningTemplateAlerted=1
		DoAlert 0, "Global Fit is running the template fitting function for some reason."
	endif
	return nan
end

Function GFFitAllAtOnceTemplate(pw, yw, xw) : FitFunc
	Wave pw, yw, xw
	
	NVAR/Z templateAlerted = root:Packages:NewGlobalFit:runningTemplateAlerted
	if (!NVAR_Exists(templateAlerted) || templateAlerted == 0)
		Variable/G root:Packages:NewGlobalFit:runningTemplateAlerted=1
		DoAlert 0, "Global Fit is running the template fitting function for some reason."
	endif
	yw = nan
	return nan
end

// ST: 210626 - add built-in functions => this list is displayed in the selection dialogue
strConstant NewGFBuiltInFuncList = "GF_Gauss;GF_Lorentz;GF_Voigt;GF_Exp;GF_DoubleExp;GF_ExpModGauss;GF_ErrorFunc;"

Function GF_Gauss(w,xx)
	Wave w
	Variable xx
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = w
	return Gauss1D(w, xx)
End

Function GF_Lorentz(w,xx)
	Wave w
	Variable xx
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = w
	return w[0]+w[1]/((xx-w[2])^2+w[3])
End

Function GF_Exp(w,xx)
	Wave w
	Variable xx
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = invtau
	return w[0]+w[1]*exp(-w[2]*xx)
End

Function GF_DoubleExp(w,xx)
	Wave w
	Variable xx
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A1
	//CurveFitDialog/ w[2] = invtau1
	//CurveFitDialog/ w[3] = A2
	//CurveFitDialog/ w[4] = invtau3
	return w[0]+w[1]*exp(-w[2]*xx)+w[3]*exp(-w[4]*xx)
End

Function GF_ExpModGauss(w,x) : FitFunc			// ST: 210626 - this function is exposed to the user to be able to fit with curve fit dialogue
	Wave w
	Variable x
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*w/abs(tau)*sqrt(2*pi)/2 * exp((x0-x)/tau + 0.5*(w/abs(tau))^2) * erfc(sqrt(1/2)*(sign(tau)*(x0-x)/w + w/abs(tau))) + y0
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = x0
	//CurveFitDialog/ w[2] = y0
	//CurveFitDialog/ w[3] = w
	//CurveFitDialog/ w[4] = tau
	return w[0]*w[3]/abs(w[4])*sqrt(2*pi)/2 * exp((w[1]-x)/w[4] + 0.5*(w[3]/abs(w[4]))^2) * erfc(sqrt(1/2)*(sign(w[4])*(w[1]-x)/w[3] + w[3]/abs(w[4]))) + w[2]
End

static Constant GFsqrtln2=0.832554611157698			// sqrt(ln(2))
static Constant GFsqrtln2pi=0.469718639349826		// sqrt(ln(2)/pi)

Function GF_Voigt(w,xx)
	Wave w
	Variable xx
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ Variable ratio = sqrtln2/gw
	//CurveFitDialog/ Variable xprime = ratio*(xx-x0)
	//CurveFitDialog/ Variable voigtY = ratio*shape
	//CurveFitDialog/ f(xx) = y0 + area*sqrtln2pi*VoigtFunc(xprime, voigtY)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ xx
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = area
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = gw (FWHM)
	//CurveFitDialog/ w[4] = shape (Lw/Gw)
	Variable voigtX = 2*GFsqrtln2*(xx-w[2])/w[3]
	Variable voigtY = GFsqrtln2*w[4]
	return w[0] + (w[1]/w[3])*2*GFsqrtln2pi*VoigtFunc(voigtX, voigtY)
End

Function GF_ErrorFunc(w,x) : FitFunc			// ST: 210626 - this function is exposed to the user to be able to fit with curve fit dialogue
	Wave w
	Variable x
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+A*erf((x-x0)/d)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = d
	return w[0]+w[1]*erf((x-w[2])/w[3])
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

static constant FuncPointerCol = 0
static constant FirstPointCol = 1
static constant LastPointCol = 2
static constant NumFuncCoefsCol = 3
static constant FirstCoefCol = 4

Function NewGlblFitFunc(inpw, inyw, inxw)
	Wave inpw, inyw, inxw

	Wave Xw = root:Packages:NewGlobalFit:XCumData
	Wave DataSetPointer = root:Packages:NewGlobalFit:DataSetPointer
	
	Wave CoefDataSetLinkage = root:Packages:NewGlobalFit:CoefDataSetLinkage
	Wave/T FitFuncList = root:Packages:NewGlobalFit:FitFuncList
	Make/FREE/N=0/D SC
	
	Variable numSets = DimSize(CoefDataSetLinkage, 0)
	Variable CoefDataSetLinkageIndex, i	
	
	for (i = 0; i < NumSets; i += 1)
		Variable firstP = CoefDataSetLinkage[i][FirstPointCol]
		Variable lastP = CoefDataSetLinkage[i][LastPointCol]

		CoefDataSetLinkageIndex = DataSetPointer[firstP]
		FUNCREF GFFitFuncTemplate theFitFunc = $(FitFuncList[CoefDataSetLinkage[CoefDataSetLinkageIndex][FuncPointerCol]])

		Redimension/N=(CoefDataSetLinkage[i][NumFuncCoefsCol]) SC
		SC = inpw[CoefDataSetLinkage[CoefDataSetLinkageIndex][FirstCoefCol+p]]
		inyw[firstP, lastP] = theFitFunc(SC, Xw[p])
	endfor
end

Function NewGlblFitFuncAllAtOnce(inpw, inyw, inxw)
	Wave inpw, inyw, inxw
	
	Wave DataSetPointer = root:Packages:NewGlobalFit:DataSetPointer
	
	Wave CoefDataSetLinkage = root:Packages:NewGlobalFit:CoefDataSetLinkage
	Wave/T FitFuncList = root:Packages:NewGlobalFit:FitFuncList
	Make/FREE/N=0/D SC
	
	Variable CoefDataSetLinkageIndex, i
	
	Variable numSets = DimSize(CoefDataSetLinkage, 0)
	for (i = 0; i < NumSets; i += 1)
		Variable firstP = CoefDataSetLinkage[i][FirstPointCol]
		Variable lastP = CoefDataSetLinkage[i][LastPointCol]

		CoefDataSetLinkageIndex = DataSetPointer[firstP]
		FUNCREF GFFitAllAtOnceTemplate theFitFunc = $(FitFuncList[CoefDataSetLinkage[CoefDataSetLinkageIndex][FuncPointerCol]])

		Duplicate/O/R=[firstP,lastP] inxw, TempXW, TempYW
		TempXW = inxw[p+firstP]

		Redimension/N=(CoefDataSetLinkage[i][NumFuncCoefsCol]) SC
		SC = inpw[CoefDataSetLinkage[i][p+FirstCoefCol]]
		theFitFunc(SC, TempYW, TempXW)
		inyw[firstP, lastP] = TempYW[p-firstP]
	endfor
end

//---------------------------------------------
//  Function that actually does a global fit, independent of the GUI
//---------------------------------------------	

constant NewGlobalFitNO_DATASETS = -1
constant NewGlobalFitBAD_FITFUNC = -2
constant NewGlobalFitBAD_YWAVE = -3
constant NewGlobalFitBAD_XWAVE = -4
constant NewGlobalFitBAD_COEFINFO = -5
constant NewGlobalFitNOWTWAVE = -6
constant NewGlobalFitWTWAVEBADPOINTS = -7
constant NewGlobalFitNOMSKWAVE = -8
constant NewGlobalFitMSKWAVEBADPOINTS = -9
constant NewGlobalFitXWaveBADPOINTS = -10
constant NewGlobalFitBADRESULTDF = -11

static Function/S GF_DataSetErrorMessage(code, errorname)
	Variable code
	string errorname
	
	switch (code)
		case NewGlobalFitNO_DATASETS:
			return "There are no data sets in the list of data sets."
			break
		case NewGlobalFitBAD_YWAVE:
			return "The Y wave \""+errorname+"\" does not exist"
			break
		case NewGlobalFitBAD_XWAVE:
			return "The X wave \""+errorname+"\" does not exist"
			break
		case NewGlobalFitNOWTWAVE:
			return "The weight wave \""+errorname+"\" does not exist."
			break
		case NewGlobalFitWTWAVEBADPOINTS:
			return "The weight wave \""+errorname+"\" has a different number of points than the corresponding data set wave."
			break
		case NewGlobalFitNOMSKWAVE:
			return "The mask wave \""+errorname+"\" does not exist."
			break
		case NewGlobalFitMSKWAVEBADPOINTS:
			return "The mask wave \""+errorname+"\" has a different number of points than the corresponding data set wave."
			break
		case NewGlobalFitXWaveBADPOINTS:
			return "The X wave \""+errorname+"\" has a different number of points than the corresponding Y wave."
			break
		default:
			return "Unknown problem with data sets. Error name: "+errorname
	endswitch
end

constant NewGFOptionAPPEND_RESULTS = 1
constant NewGFOptionCALC_RESIDS = 2
constant NewGFOptionCOV_MATRIX = 4
constant NewGFOptionFIT_GRAPH = 8
constant NewGFOptionQUIET = 16
constant NewGFOptionWTISSTD = 32
constant NewGFOptionMAKE_FIT_WAVES = 64
constant NewGFOptionCOR_MATRIX = 128
constant NewGFOptionLOG_DEST_WAVE = 256
constant NewGFOptionGLOBALFITVARS = 512

// As of Igor 6.10, return value is the error code from FuncFit if FuncFit stops due to syntax or running errors.
// JW 110505 Cinco De Mayo Comments were inaccurate and hard to understand, so I revised them and moved them to the Global Fit 2 Help file.
// YOU CAN USE THIS FUNCTION IN YOUR OWN CODE- see help file for details.
Function DoNewGlobalFit(FitFuncNames, DataSets, CoefDataSetLinkage, CoefWave, CoefNames, ConstraintWave, Options, FitCurvePoints, DoAlertsOnError, [errorName, errorMessage, maxIters, resultWavePrefix, resultDF])
	Wave/T FitFuncNames
	Wave/T DataSets
	Wave CoefDataSetLinkage
	Wave CoefWave
	Wave/T/Z CoefNames
	Wave/T/Z ConstraintWave
	Variable Options
	Variable FitCurvePoints	
	Variable DoAlertsOnError
	String &errorName	
	String &errorMessage
	Variable maxIters
	String resultWavePrefix
	String resultDF	
	
	if (ParamIsDefault(resultWavePrefix))
		resultWavePrefix = ""
	endif

	Variable specialResultDF = 1
	if (ParamIsDefault(resultDF))
		resultDF = ""
		specialResultDF = 0
	else
		if (strlen(resultDF) == 0)
			specialResultDF = 0
		else
			Variable lastChar = strlen(resultDF)-1
			if (cmpstr(":", resultDF[lastChar,lastChar]) != 0)
				resultDF = resultDF+":"
			endif
			if (!DataFolderExists(resultDF))
				return NewGlobalFitBADRESULTDF
			endif
		endif
	endif

	Variable i,j
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:NewGlobalFit
	
	Variable err
	Variable errorWaveRow, errorWaveColumn
	String errorWaveName
	Variable IsAllAtOnce
	
	IsAllAtOnce = GF_FunctionType(FitFuncNames[0])
	for (i = 0; i < DimSize(FitFuncNames, 0); i += 1)
		Variable functype = GF_FunctionType(FitFuncNames[i])
		if (functype == GF_FuncType_BadFunc)
			if (DoAlertsOnError)
				DoAlert 0, "The function "+FitFuncNames[i]+" is not of the proper format."
				return -1
			endif
		elseif (functype == GF_FuncType_NoFunc)
			if (DoAlertsOnError)
				DoAlert 0, "The function "+FitFuncNames[i]+" does not exist."
				return -1
			endif
		endif
		if (functype != IsAllAtOnce)
			if (DoAlertsOnError)
				DoAlert 0, "All your fit functions must be either regular fit functions or all-at-once functions. They cannot be mixed."
				return -1
			endif
		endif
	endfor
	
	Duplicate/O CoefDataSetLinkage, root:Packages:NewGlobalFit:CoefDataSetLinkage
	Wave privateLinkage = root:Packages:NewGlobalFit:CoefDataSetLinkage
	Duplicate/O/T FitFuncNames, root:Packages:NewGlobalFit:FitFuncList
	
	Variable DoResid=0
	Variable doWeighting=0
	Variable doMasking=0
	
DoUpdate
	err = NewGF_CheckDSets_BuildCumWaves(DataSets, privateLinkage, doWeighting, doMasking, errorWaveName, errorWaveRow, errorWaveColumn)
DoUpdate
	if (err < 0)
		if (err == NewGlobalFitNO_DATASETS)
			DoAlert 0, "There are no data sets in the list of data sets."
		elseif (DoAlertsOnError)
			DoAlert 0, GF_DataSetErrorMessage(err, errorWaveName)
		endif
		if (!ParamIsDefault(errorName))
			errorName = errorWaveName
		endif
		return err
	endif
	
	if (ParamIsDefault(maxIters))
		maxIters = 40
	endif
	
	Wave Xw = root:Packages:NewGlobalFit:XCumData
	Wave Yw = root:Packages:NewGlobalFit:YCumData
	Duplicate/O YW, root:Packages:NewGlobalFit:FitY
	Wave FitY = root:Packages:NewGlobalFit:FitY
	FitY = NaN
	
	Make/D/O/N=(DimSize(CoefWave, 0)) root:Packages:NewGlobalFit:MasterCoefs	
	Wave MasterCoefs = root:Packages:NewGlobalFit:MasterCoefs
	MasterCoefs = CoefWave[p][0]
	
	if (!WaveExists(CoefNames))
		Make/T/O/N=(DimSize(CoefWave, 0)) root:Packages:NewGlobalFit:CoefNames
		Wave/T CoefNames = root:Packages:NewGlobalFit:CoefNames
		// go through the matrix backwards so that the name we end up with refers to it's first use in the matrix
		for (i = DimSize(privateLinkage, 0)-1; i >= 0 ; i -= 1)
			String fname = FitFuncNames[privateLinkage[i][FuncPointerCol]]
			for (j = DimSize(privateLinkage, 1)-1; j >= FirstCoefCol; j -= 1)
				if (privateLinkage[i][j] < 0)
					continue
				endif
				CoefNames[privateLinkage[i][j]] = fname+":C"+num2istr(j-FirstCoefCol)
			endfor
		endfor
	endif
	
	if (Options & NewGFOptionCALC_RESIDS)
		DoResid = 1
	endif
	String residWave = ""

	if (options & NewGFOptionFIT_GRAPH)	
		if (WinType("GlobalFitGraph") != 0)
			DoWindow/K GlobalFitGraph
		endif
		String SavedWindowCoords = WC_WindowCoordinatesGetStr("GlobalFitGraph", 0)
		if (strlen(SavedWindowCoords) > 0)
			Execute "Display/W=("+SavedWindowCoords+") as \"Global Analysis Progress\""
		else
			Display as "Global Analysis Progress"
		endif
		DoWindow/C GlobalFitGraph
		ColorTab2Wave Rainbow
		Wave M_colors
		Duplicate/O M_colors, root:Packages:NewGlobalFit:NewGF_TraceColors
		Wave colors = root:Packages:NewGlobalFit:NewGF_TraceColors
		Variable index = 0, size = DimSize(M_colors, 0)
		for (i = 0; i < size; i += 1)
			colors[i][] = M_colors[index][q]
			index += 37
			if (index >= size)
				index -= size
			endif
		endfor
		KillWaves/Z M_colors
		Variable nTraces = DimSize(privateLinkage, 0)
		for (i = 0; i < nTraces; i += 1)
			Variable start = privateLinkage[i][FirstPointCol]
			Variable theEnd = privateLinkage[i][LastPointCol]
			AppendToGraph Yw[start, theEnd] vs Xw[start, theEnd]
			AppendToGraph FitY[start, theEnd] vs Xw[start, theEnd]
		endfor
		DoUpdate
		Variable colorindex
		for (i = 0; i < nTraces; i += 1)
			ModifyGraph mode[2*i]=2
			ModifyGraph marker[2*i]=8
			ModifyGraph lSize[2*i]=2
			colorindex = mod(i, DimSize(colors, 0))
			ModifyGraph rgb[2*i]=(colors[colorindex][0],colors[colorindex][1],colors[colorindex][2])
			ModifyGraph rgb[2*i+1]=(colors[colorindex][0],colors[colorindex][1],colors[colorindex][2])
		endfor		
		ModifyGraph gbRGB=(17476,17476,17476)
		if (options & NewGFOptionLOG_DEST_WAVE)
			WaveStats/Q/M=1 xW
			if ( (V_min <= 0) || (V_max <= 0) )
				// bad x range for log- cancel the option
				options = options & ~NewGFOptionLOG_DEST_WAVE
			else
				// the progress graph should have log X axis
				ModifyGraph/W=GlobalFitGraph log(bottom)=1
			endif
		endif
		SetWindow GlobalFitGraph, hook = WC_WindowCoordinatesHook
		
		if (DoResid)
			Duplicate/O Yw, root:Packages:NewGlobalFit:NewGF_ResidY
			Wave rw = root:Packages:NewGlobalFit:NewGF_ResidY
			residWave = "root:Packages:NewGlobalFit:NewGF_ResidY"
			for (i = 0; i < nTraces; i += 1)
				start = privateLinkage[i][FirstPointCol]
				theEnd = privateLinkage[i][LastPointCol]
				AppendToGraph/L=ResidLeftAxis rw[start, theEnd] vs Xw[start, theEnd]
			endfor
			DoUpdate
			for (i = 0; i < nTraces; i += 1)
				ModifyGraph mode[2*nTraces+i]=2
				colorindex = mod(i, DimSize(colors, 0))
				ModifyGraph rgb[2*nTraces+i]=(colors[colorindex][0],colors[colorindex][1],colors[colorindex][2])
				ModifyGraph lSize[2*nTraces+i]=2
			endfor
			ModifyGraph lblPos(ResidLeftAxis)=51
			ModifyGraph zero(ResidLeftAxis)=1
			ModifyGraph freePos(ResidLeftAxis)={0,kwFraction}
			ModifyGraph axisEnab(left)={0,0.78}
			ModifyGraph axisEnab(ResidLeftAxis)={0.82,1}
		endif
	endif
	
	Duplicate/D/O MasterCoefs, root:Packages:NewGlobalFit:EpsilonWave
	Wave EP = root:Packages:NewGlobalFit:EpsilonWave
	if (FindDimLabel(CoefWave, 1, "Epsilon") == -2)
		EP = 1e-4
	else
		EP = CoefWave[p][%Epsilon]
	endif

	Variable quiet = ((Options & NewGFOptionQUIET) != 0)
	if (!quiet)
		Print "*** Doing Global fit ***"
	endif
	
	if (Options & NewGFOptionCOR_MATRIX)
		Options = Options | NewGFOptionCOV_MATRIX
	endif
	
	Variable covarianceArg = 0
	if (Options & NewGFOptionCOV_MATRIX)
		covarianceArg = 2
	endif
	
DoUpdate
	string funcName=""
	if (isAllAtOnce)
		funcName = "NewGlblFitFuncAllAtOnce"
	else
		funcName = "NewGlblFitFunc"
	endif
		
	String/G root:Packages:NewGlobalFit:newGF_HoldString
	SVAR newGF_HoldString = root:Packages:NewGlobalFit:newGF_HoldString
	newGF_HoldString = MakeHoldString(CoefWave, quiet, 1)		// MakeHoldString() returns "" if there are no holds
	WAVE/Z workingxw = $""
	if (isAllAtOnce)
		WAVE workingxw = $"root:Packages:NewGlobalFit:XCumData"
	endif
	
	String cwavename = ""
	if (WaveExists(ConstraintWave))
		cwavename = GetWavesDataFolder(ConstraintWave, 2)
	endif
	
	String weightName = ""
	Variable weightType = 0
	if (doWeighting)
		weightName = "GFWeightWave"
		if (Options & NewGFOptionWTISSTD)
			weightType = 1
		endif
	endif
DoUpdate
		Variable V_FitQuitReason=0
		Variable V_FitNumIters
DoUpdate
		DebuggerOptions
		Variable savedDebugOnError = V_debugOnError
		DebuggerOptions debugOnError=0
		Variable V_FItMaxIters = maxIters
		Variable/G root:Packages:NewGlobalFit:runningTemplateAlerted=0
		try
			FuncFit/Q=(quiet)/H=(newGF_HoldString)/M=(covarianceArg)/W=2 $funcname, MasterCoefs, Yw /X=workingxw/D=FitY/E=EP/R=$residWave/C=$cwavename/W=$weightName/I=(weightType)/NWOK; AbortOnRTE
		catch
			String fitErrorMessage = GetRTErrMessage()
			Variable errorCode = GetRTError(1)
			Variable semiPos = strsearch(fitErrorMessage, ";", 0)
			if (semiPos >= 0)
				fitErrorMessage = fitErrorMessage[semiPos+1, inf]
			endif
			if (!quiet)
				DoAlert 0, fitErrorMessage
			endif
		endtry
		DebuggerOptions debugOnError=savedDebugOnError
		
		Variable fit_npnts = V_npnts
		Variable fit_numNaNs = V_numNaNs
		Variable fit_numINFs = V_numINFs
	
	if (options & NewGFOptionGLOBALFITVARS)
		  Variable/G GF_chisq = V_chisq
        Variable/G GF_npnts = V_npnts
        Variable/G GF_numNaNs = V_numNaNs
        Variable/G GF_numINFs = V_numINFs
        Variable/G GF_quitReason = V_FitQuitReason
        Variable/G GF_numIters = V_FitNumIters
	endif
		
	if (Options & NewGFOptionCOV_MATRIX)
		Wave/Z M_Covar				// ST: 230719 - check for wave's existence (may be absent when user aborted the fit)
		if ((Options & NewGFOptionCOR_MATRIX) && WaveExists(M_Covar))
			Duplicate/O M_Covar, M_Correlation
			M_Correlation = M_Covar[p][q]/sqrt(M_Covar[p][p]*M_Covar[q][q])
		endif
	endif
	
	CoefWave[][0] = MasterCoefs[p]
	Duplicate/O MasterCoefs, GlobalFitCoefficients
	
	if (!ParamIsDefault(errorMessage))
		errorMessage = fitErrorMessage
	endif

	if (!quiet)
		Print "\rGlobal fit results"
		if (errorCode)
			print fitErrorMessage
			return errorCode
		else
			switch (V_FitQuitReason)
				case 0:
					print "\tFit converged normally"
					break;
				case 1:
					print "\tFit exceeded limit of iterations"
					break;
				case 2:
					print "\tFit stopped because the user cancelled the fit"
					break;
				case 3:
					print "\tFit stopped due to limit of iterations with no decrease in chi-square"
					break;
				default:
					print "Hmm... Global Fit stopped for an unknown reason."
			endswitch
		endif
		print "V_chisq =",V_chisq,"V_npnts=",fit_npnts, "V_numNaNs=", fit_numNaNs, "V_numINFs=",fit_numINFs
		print "Number of iterations:",V_FitNumIters 
		// and print the coefficients by data set into the history
		Variable numRows = DimSize(privateLinkage, 0)
		Variable numCols = DimSize(privateLinkage, 1)
		Variable firstUserow, firstUsecol, linkIndex
		Wave/Z W_sigma
		Variable hasHoldCol = FindDimLabel(CoefWave, 1, "Hold") > 0
		for (i = 0; i < numRows; i += 1)
			print "Data Set: ",DataSets[i][0]," vs ",DataSets[i][1],"; Function: ",FitFuncNames[privateLinkage[i][FuncPointerCol]]
			for (j = FirstCoefCol; j < (privateLinkage[i][NumFuncCoefsCol] + FirstCoefCol); j += 1)
				linkIndex = privateLinkage[i][j]
				Variable sigVal = NaN
				if (WaveExists(W_sigma))				// ST: 230719 - check for wave's existence
					sigVal = W_sigma[privateLinkage[i][j]]
				endif
				FirstUseOfIndexInLinkMatrix(linkIndex, privateLinkage, firstUserow, firstUsecol)
				//printf "\t%d\t%s\t%g +- %g", j-FirstCoefCol, CoefNames[privateLinkage[i][j]], MasterCoefs[privateLinkage[i][j]], W_sigma[privateLinkage[i][j]]
				printf "\t%d\t%s\t%g +- %g", j-FirstCoefCol, CoefNames[privateLinkage[i][j]], MasterCoefs[privateLinkage[i][j]], sigVal
				if (hasHoldCol && CoefWave[privateLinkage[i][j]][%Hold])
					printf " *HELD* "
				endif
				if ( (firstUserow != i) || (firstUseCol != j) )
					printf " ** LINKED to data set %s coefficient %d: %s", DataSets[firstUserow][0], firstUseCol-FirstCoefCol, CoefNames[privateLinkage[i][j]]
				endif
				print "\r"
			endfor
		endfor
	endif

	if (FitCurvePoints == 0)
		FitCurvePoints = 200
	endif

	if (options & NewGFOptionAPPEND_RESULTS)
		options = options | NewGFOptionMAKE_FIT_WAVES
	endif
	
	if (options & NewGFOptionCALC_RESIDS)
		options = options | NewGFOptionMAKE_FIT_WAVES
	endif
	
	if ( (options & NewGFOptionMAKE_FIT_WAVES) || (options & NewGFOptionCALC_RESIDS) )
		Wave/Z fitxW = root:Packages:NewGlobalFit:fitXCumData
		if (WaveExists(fitxW))
			KillWaves fitxW
		endif
		Rename xW, fitXCumData
		Wave/Z fitxW = root:Packages:NewGlobalFit:fitXCumData
Duplicate/O Yw, fitYCumData	
		String ListOfFitCurveWaves = ""
		Wave/Z W_sigma
	
		for (i = 0; i < DimSize(DataSets, 0); i += 1)
			String YFitSet = DataSets[i][0]
			
			// copy coefficients for each data set into a separate wave
			Wave YFit = $YFitSet
			DFREF resultDFR = GetWavesDatafolderDFR(YFit)
			if (specialResultDF)
				resultDFR = $resultDF
			endif
			String YWaveName = NameOfWave(YFit)
			if (CmpStr(YWaveName[0], "'") == 0)
				YWaveName = YWaveName[1, strlen(YWaveName)-2]
			endif
			// this is a good thing, but doesn't belong here. Individual coefficient waves should be made above
			String coefname = CleanupName(resultWavePrefix+"Coef_"+YWaveName, 0)
			String sigmaName = CleanupName(resultWavePrefix+"sig_"+YWaveName, 0)
			Make/D/O/N=(privateLinkage[i][NumFuncCoefsCol]) resultDFR:$coefname
			Make/D/O/N=(privateLinkage[i][NumFuncCoefsCol]) resultDFR:$sigmaName
			Wave w = resultDFR:$coefname
			Wave s = resultDFR:$sigmaName
			w = MasterCoefs[privateLinkage[i][p+FirstCoefCol]]
			if (WaveExists(W_sigma))				// ST: 230719 - check for wave's existence
				s = W_sigma[privateLinkage[i][p+FirstCoefCol]]
			else
				s = NaN
			endif
			
			if (options & NewGFOptionMAKE_FIT_WAVES)
				String fitCurveName = CleanupName(resultWavePrefix+"GFit_"+YWaveName, 0)
				Make/D/O/N=(FitCurvePoints) resultDFR:$fitCurveName
				Wave fitCurveW = resultDFR:$fitCurveName
				Variable minX, maxX
				WaveStats/Q/R=[privateLinkage[i][FirstPointCol], privateLinkage[i][LastPointCol]] fitxW
				minX = V_min
				maxX = V_max
				if (options & NewGFOptionLOG_DEST_WAVE)
					String fitCurveXName = CleanupName("GFitX_"+YWaveName, 0)
					Duplicate/O fitCurveW, resultDFR:$fitCurveXName
					Wave  fitCurveXW = resultDFR:$fitCurveXName
					
					Variable logXMin = ln(minX)
					Variable logXMax = ln(maxX)
					Variable logXInc = (logXMax - logXMin)/(FitCurvePoints-1)
					
					// if there's something wrong with the X range, there will be inf or nan in one of these numbers
					if ( (numtype(logXMin) != 0) || (numtype(logXMax) != 0) || (numtype(logXInc) != 0) )
						// something wrong- cancel the log spacing option
						options = options & ~NewGFOptionLOG_DEST_WAVE
					else
						// it's OK- go ahead with log spacing
						fitCurveXW = exp(logXMin+p*logXInc)
					
						// make auxiliary waves required by the fit function
						// so that we can use the fit function in an assignment
						Duplicate/O fitCurveXW, root:Packages:NewGlobalFit:XCumData
						Wave xw = root:Packages:NewGlobalFit:XCumData
					endif
				endif
				// check this again in case it was set but cancelled due to bad numbers
				if (!(options & NewGFOptionLOG_DEST_WAVE))
					SetScale/I x minX, maxX, fitCurveW
				
					// make auxiliary waves required by the fit function
					// so that we can use the fit function in an assignment
					Duplicate/O fitCurveW, root:Packages:NewGlobalFit:XCumData
					Wave xw = root:Packages:NewGlobalFit:XCumData
					xw = x
				endif
				
				Duplicate/O fitCurveW, root:Packages:NewGlobalFit:DataSetPointer
				Wave dspw = root:Packages:NewGlobalFit:DataSetPointer
				dspw = 0
				
				Duplicate/O privateLinkage, copyOfLinkage
				Make/O/D/N=(1,DimSize(copyOfLinkage, 1)) root:Packages:NewGlobalFit:CoefDataSetLinkage
				Wave tempLinkage = root:Packages:NewGlobalFit:CoefDataSetLinkage
				tempLinkage = copyOfLinkage[i][q]
				tempLinkage[0][FirstPointCol] = 0
				tempLinkage[0][LastPointCol] = FitCurvePoints-1
				if (IsAllAtOnce)
					NewGlblFitFuncAllAtOnce(MasterCoefs, fitCurveW, xw)
				else
					NewGlblFitFunc(MasterCoefs, fitCurveW, xw)
				endif
				Duplicate/O copyOfLinkage, root:Packages:NewGlobalFit:CoefDataSetLinkage
				KillWaves/Z copyOfLinkage
				
				if (options & NewGFOptionAPPEND_RESULTS)
					String graphName = FindGraphWithWave(YFit)
					if (strlen(graphName) > 0)
						CheckDisplayed/W=$graphName fitCurveW
						if (V_flag == 0)
							String axisflags = StringByKey("AXISFLAGS", TraceInfo(graphName, YFitSet, 0))
							String resultDFpath = GetDataFolder(1, resultDFR)
							if (options & NewGFOptionLOG_DEST_WAVE)
								String AppendCmd = "AppendToGraph/W="+graphName+axisFlags+" "+resultDFpath+fitCurveName+" vs "+resultDFpath+fitCurveXName
							else
								AppendCmd = "AppendToGraph/W="+graphName+axisFlags+" "+resultDFpath+fitCurveName
							endif
							Execute AppendCmd
						endif
					endif
				endif
			endif
			
			if (options & NewGFOptionCALC_RESIDS)
				String resCurveName = CleanupName(resultWavePrefix+"GRes_"+YWaveName, 0)
				Make/D/O/N=(numpnts(YFit)) resultDFR:$resCurveName
				Wave resCurveW = resultDFR:$resCurveName
				Wave/Z XFit = resultDFR:$(DataSets[i][1])
				
				// make auxiliary waves required by the fit function
				// so that we can use the fit function in an assignment
				Duplicate/O resCurveW, root:Packages:NewGlobalFit:XCumData
				Wave xw = root:Packages:NewGlobalFit:XCumData
				if (WaveExists(XFit))
					xw = XFit
				else
					xw = pnt2x(YFit, p)
				endif
				
				Duplicate/O resCurveW, root:Packages:NewGlobalFit:DataSetPointer
				Wave dspw = root:Packages:NewGlobalFit:DataSetPointer
				dspw = 0
				
				//if (IsAllAtOnce)
					Duplicate/O/FREE privateLinkage, copyOfLinkage
					Make/O/D/N=(1,DimSize(copyOfLinkage, 1)) root:Packages:NewGlobalFit:CoefDataSetLinkage
					Wave tempLinkage = root:Packages:NewGlobalFit:CoefDataSetLinkage
					tempLinkage = copyOfLinkage[i][q]
					tempLinkage[0][FirstPointCol] = 0
					tempLinkage[0][LastPointCol] = numpnts(resCurveW)-1
					if (IsAllAtOnce)
						NewGlblFitFuncAllAtOnce(MasterCoefs, resCurveW, xw)
					else
						NewGlblFitFunc(MasterCoefs, resCurveW, xw)
					endif
					resCurveW = YFit[p] - resCurveW[p]
					Duplicate/O copyOfLinkage, root:Packages:NewGlobalFit:CoefDataSetLinkage
					//KillWaves/Z copyOfLinkage
				//else
				//	resCurveW = YFit[p] - NewGlblFitFunc(MasterCoefs, p)
				//endif
			endif
		endfor
	endif
	
	return 0
end

static constant GF_FuncType_Regular = 0
static constant GF_FuncType_AllAtOnce = 1
static constant GF_FuncType_BadFunc = -1
static constant GF_FuncType_NoFunc = -2

static Function GF_FunctionType(functionName)
	String functionName
	
	Variable FuncType = GF_FuncType_BadFunc
	
	string FitFuncs = FunctionList("*", ";", "NPARAMS:2;VALTYPE:1")
	if (FindListItem(functionName, FitFuncs) >= 0)
		FuncType = GF_FuncType_Regular
	else
		FitFuncs = FunctionList("*", ";", "NPARAMS:3;VALTYPE:1")
		if (FindListItem(functionName, FitFuncs) >= 0)
			FuncType = GF_FuncType_AllAtOnce
		endif
	endif
	
	if (FuncType == GF_FuncType_BadFunc)
		Variable funcExists = Exists(functionName)
		if ((funcExists != 6) && (funcExists != 3) )
			FuncType = GF_FuncType_NoFunc
		endif
	endif
	return FuncType
end

static Function FirstUseOfIndexInLinkMatrix(index, linkMatrix, row, col)
	Variable index
	Wave linkMatrix
	Variable &row
	Variable &col
	
	Variable i, j
	Variable numRows = DimSize(linkMatrix, 0)
	Variable numCols = DimSize(linkMatrix, 1)
	for (i = 0; i < numRows; i += 1)
		for (j = FirstCoefCol; j < numCols; j += 1)
			if (linkMatrix[i][j] == index)
				row = i
				col = j
				return 0
			endif
		endfor
	endfor
	
	row = -1
	col = -1
	return -1
end

// Checks list of data sets for consistency, etc.
// Makes the cumulative data set waves.
static Function NewGF_CheckDSets_BuildCumWaves(DataSets, linkageMatrix, doWeighting, doMasking, errorWaveName, errorWaveRow, errorWaveColumn)
	Wave/T DataSets
	Wave linkageMatrix
	Variable &doWeighting
	Variable &doMasking
	String &errorWaveName
	Variable &errorWaveRow
	Variable &errorWaveColumn
	
	errorWaveName = ""

	Variable i, j
	String XSet, YSet
	Variable numSets = DimSize(DataSets, 0)
	Variable wavePoints
	Variable npnts
	
	if (numSets == 0)
		return 0
	endif
	
	Variable totalPoints = 0
	
	Variable MaskCol = FindDimLabel(DataSets, 1, "Masks")
	doMasking = 0
	if (MaskCol >= 0)
//		Make/D/N=(totalPoints)/O root:Packages:NewGlobalFit:GFMaskWave
		doMasking = 1
	endif

	doWeighting = 0
	Variable WeightCol = FindDimLabel(DataSets, 1, "Weights")
	if (WeightCol >= 0)
//		Make/D/N=(totalPoints)/O root:Packages:NewGlobalFit:GFWeightWave
		doWeighting = 1
	endif
	
	// pre-scan to find the total number of points. This is done so that the concatenated wave
	// can be made at the final size all at one time, avoiding problems with virtual memory
	// that can be caused by re-sizing a memory block many times.
	
	// JW 040818 Failing to check for NaN's in the data waves causes a failure of synchronization between
	// the data structures and the data passed to the fit function by FuncFit. I will have to check for NaN's
	// and not include them.
	// I am removing the check for masked points in this loop. If there are masked points or NaN's, the wave
	// will be too big and will be reduced at the end. However, I will do a check here for bad wave names or bad numbers of
	// points so that I don't have to clutter up the second loop with checks.
	for (i = 0; i < numSets; i += 1)
		// check the Y wave
		YSet = DataSets[i][0]
		XSet = DataSets[i][1]
		Wave/Z Ysetw = $YSet
		Wave/Z Xsetw = $XSet
		if (!WaveExists(YSetw))
			errorWaveName = YSet
			errorWaveRow = i
			errorWaveColumn = 0
			return NewGlobalFitBAD_YWAVE
		endif
		wavePoints = numpnts(Ysetw)
		
		// check the X wave
		if (cmpstr(XSet, "_Calculated_") != 0)
			if (!WaveExists(Xsetw)) 
				errorWaveName = XSet
				errorWaveRow = i
				errorWaveColumn = 1
				return NewGlobalFitBAD_XWAVE
			endif
			if (wavePoints != numpnts(Xsetw))
				errorWaveRow = i
				errorWaveColumn = 1
				return NewGlobalFitXWaveBADPOINTS
			endif
		endif		
		
		// check mask wave if necessary
		if (doMasking)
			Wave/Z mw = $(DataSets[i][MaskCol])
			if (!WaveExists(mw) && strlen(DataSets[i][MaskCol]))			// ST: 210615 - allow for omitted mask waves
				errorWaveRow = i
				errorWaveColumn = MaskCol
				return NewGlobalFitNOMSKWAVE
			endif
			if (WaveExists(mw) && wavePoints != numpnts(mw))
				errorWaveRow = i
				errorWaveColumn = MaskCol
				return NewGlobalFitMSKWAVEBADPOINTS
			endif
		endif
		
		// check weighting wave if necessary
		if (doWeighting)
			Wave/Z ww = $(DataSets[i][WeightCol])
			if (!WaveExists(ww) && strlen(DataSets[i][WeightCol]))			// ST: 210615 - allow for omitted weighting waves
				errorWaveRow = i
				errorWaveColumn = WeightCol
				return NewGlobalFitNOWTWAVE
			endif
			if (WaveExists(ww) && wavePoints != numpnts(ww))
				errorWaveRow = i
				errorWaveColumn = WeightCol
				return NewGlobalFitWTWAVEBADPOINTS
			endif
		endif

		totalPoints += numpnts(Ysetw)
	endfor
	
	if (doWeighting)
		Make/D/N=(totalPoints)/O root:Packages:NewGlobalFit:GFWeightWave
	endif

	// make the waves that will contain the concatenated data sets and the wave that points
	// to the appropriate row in the data set linkage matrix
	Make/D/N=(totalPoints)/O root:Packages:NewGlobalFit:XCumData, root:Packages:NewGlobalFit:YCumData
	Make/U/W/N=(totalPoints)/O root:Packages:NewGlobalFit:DataSetPointer
	
	Wave Xw = root:Packages:NewGlobalFit:XCumData
	Wave Yw = root:Packages:NewGlobalFit:YCumData
	Wave DataSetPointer = root:Packages:NewGlobalFit:DataSetPointer
	Wave/Z Weightw = root:Packages:NewGlobalFit:GFWeightWave
//	Wave/Z Maskw = root:Packages:NewGlobalFit:GFMaskWave
	
	Variable realTotalPoints = 0
	Variable wavePoint = 0

	// second pass through the list, this time copying the data into the concatenated sets, and
	// setting index numbers in the index wave
	for (i = 0; i < numSets; i += 1)
		YSet = DataSets[i][0]
		XSet = DataSets[i][1]
		Wave/Z Ysetw = $YSet
		Wave/Z Xsetw = $XSet
		if (doMasking)
			Wave/Z mw = $(DataSets[i][MaskCol])
		endif
		if (doWeighting)
			Wave/Z ww = $(DataSets[i][WeightCol])
		endif
		wavePoints = numpnts(Ysetw)
		for (j = 0; j < wavePoints; j += 1)
			if (numtype(Ysetw[j]) != 0)
				continue
			endif
			
			if (doMasking && WaveExists(mw))			// ST: 210615 - allow for omitted mask waves 
				if ( (numtype(mw[j]) != 0) || (mw[j] == 0) )
					continue
				endif
			endif
			
			if (doWeighting && WaveExists(ww))			// ST: 210615 - allow for omitted weighting waves
				if ( (numtype(ww[j]) != 0) || (ww[j] == 0) )
					continue
				endif
			endif
			
			DataSetPointer[wavePoint] = i
			
			Yw[wavePoint] = Ysetw[j]

			if (cmpstr(XSet, "_Calculated_") == 0)
				Xw[wavePoint] = pnt2x(Ysetw, j)
			else
				if (numtype(Xsetw[j]) != 0)
					continue
				endif
				Xw[wavePoint] = Xsetw[j]
			endif
			
			if (doWeighting)
				if (!WaveExists(ww))					// ST: 210615 - for omitted weight waves set all to one
					Weightw[wavePoint] = 1
				else
					Weightw[wavePoint] = ww[j]
				endif
			endif
			
			wavePoint += 1
		endfor
		
		linkageMatrix[i][FirstPointCol] = realTotalPoints
		linkageMatrix[i][LastPointCol] = wavePoint-1
		realTotalPoints = wavePoint
	endfor
	
	if (totalPoints > realTotalPoints)
		Redimension/N=(realTotalPoints) Yw, Xw
		if (doWeighting)
			Redimension/N=(realTotalPoints) Weightw
		endif			
	endif
	
	return numSets
end

//********************
//	The GUI part
//********************

static strconstant SMALL_DOWNARROW_STRING=" \Zr075\W523\M"		// large-to-small sorting
static strconstant SMALL_UPARROW_STRING=" \Zr075\W517\M"		// small-to-large sorting
static strconstant GRAY_TEXT_STRING="\K(39321,39321,39321)\k(39321,39321,39321)"

static Function NewGF_PossiblyMake2DListWave3D()
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	if (Wavedims(ListWave) < 3)
		// JW 180625 Old versions of Global Fit had a 2D ListWave; now we store the full path to waves in the second layer.
		// This patches up experiments that saved such a wave, by guessing that the waves were in root:. That isn't necessarily
		// the case, but it's a good guess.
		Redimension/N=(-1,-1,2) ListWave
		Variable j
		Variable nrows = DimSize(ListWave, 0)
		for (j = 0; j < nrows; j++)
			WAVE w = $(ListWave[j][NewGF_DSList_YWaveCol][0])
			ListWave[j][NewGF_DSList_YWaveCol][1] = GetWavesDataFolder(w, 2)
			ListWave[j][NewGF_DSList_YWaveCol][0] = NameOfWave(w)
			if (CmpStr(ListWave[j][NewGF_DSList_XWaveCol][0], "_calculated_") == 0)
				ListWave[j][NewGF_DSList_XWaveCol][1] = "_calculated_"
			else
				WAVE w = $(ListWave[j][NewGF_DSList_XWaveCol][0])
				ListWave[j][NewGF_DSList_XWaveCol][1] = GetWavesDataFolder(w, 2)
				ListWave[j][NewGF_DSList_XWaveCol][0] = NameOfWave(w)
			endif
		endfor
	endif
end

static Function InitNewGlobalFitGlobals()
	
	DFREF GFfolder = root:Packages:NewGlobalFit
	if (DataFolderRefStatus(GFFolder) > 0)
		NewGF_PossiblyMake2DListWave3D()
		return 0		// if the folder already exists, just use it so the set-up will be the same as before. This risks using a damaged folder...
	endif
	
	DFREF saveFolder = GetDataFolderDFR()
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S NewGlobalFit
	
	Make/O/T/N=(1,4,2) NewGF_DataSetListWave = ""
	SetDimLabel 1, 0, 'Y Waves', NewGF_DataSetListWave
	SetDimLabel 1, 1, 'X Waves', NewGF_DataSetListWave
	SetDimLabel 1, 2, Function, NewGF_DataSetListWave
	SetDimLabel 1, 3, '# Coefs', NewGF_DataSetListWave
	
	Make/O/T/N=(1,1,2) NewGF_MainCoefListWave = ""
	SetDimLabel 1, 0, 'Coefs- K0', NewGF_MainCoefListWave

	Make/O/N=(1,4,2) NewGF_DataSetListSelWave = 0	

	Make/O/N=(1,1,2) NewGF_MainCoefListSelWave = 0
	SetDimLabel 2, 1, backColors, NewGF_MainCoefListSelWave
	ColorTab2Wave Pastels
	Wave M_colors
	Duplicate/O M_colors, NewGF_LinkColors
	Variable i, index = 0, size = DimSize(M_colors, 0)
	for (i = 0; i < size; i += 1)
		NewGF_LinkColors[i][] = M_colors[index][q]
		index += 149
		if (index >= size)
			index -= size
		endif
	endfor
	KillWaves/Z M_colors
	
	Make/O/T/N=(1,5) NewGF_CoefControlListWave = ""
	Make/O/T/N=(1,7) NewGF_CoefControlMasterWave = ""			// ST: 210624 - this is the master list in the background (additional columns: 5 = coef name, 6 = func name)
	Make/O/T/N=(5) NewGF_CoefControlTitleWave = ""				// ST: 210617 - dedicated title wave for sorting functionality
	Make/O/N=(1) NewGF_CoefControlSortWave = p					// ST: 210617 - additional wave to keep track of the original row positions after sorting and filtering
	Make/O/N=(1,5) NewGF_CoefControlListSelWave
	SetDimLabel 1, 0, 'Data Set', NewGF_CoefControlListWave
	SetDimLabel 1, 1, Name, NewGF_CoefControlListWave
	SetDimLabel 1, 2, 'Initial Guess', NewGF_CoefControlListWave
	SetDimLabel 1, 3, 'Hold?', NewGF_CoefControlListWave
	SetDimLabel 1, 4, Epsilon, NewGF_CoefControlListWave
	NewGF_CoefControlListSelWave[][3] = 0x20
	
	NewGF_CoefControlTitleWave[0] = "Data Set" + GRAY_TEXT_STRING + SMALL_UPARROW_STRING
	NewGF_CoefControlTitleWave[1] = "Name"
	NewGF_CoefControlTitleWave[2] = "Initial Guess"
	NewGF_CoefControlTitleWave[3] = "Hold?"
	NewGF_CoefControlTitleWave[4] = "Epsilon"
	
	Variable/G NewGF_RebuildCoefListNow = 1
	
	Variable points = NumVarOrDefault("FitCurvePoints", 200)
	Variable/G FitCurvePoints = points
	
	String setupName = StrVarOrDefault("NewGF_NewSetupName", "NewGlobalFitSetup")
	String/G NewGF_NewSetupName = setupName
	Variable/G NewGF_MaxIters = 40

	SetDataFolder saveFolder
end

static Function UpgradeNewGlobalFitPanelCoefList()				// ST: 210624 - upgrades old experiments and open panels with the new coef list setup
	DFREF saveFolder = GetDataFolderDFR()
	DFREF GFFolder = root:Packages:NewGlobalFit
	SetDataFolder GFFolder
	
	Wave/T NewGF_CoefControlListWave
	Variable rows = DimSize(NewGF_CoefControlListWave,0)
	Make/O/T/N=(rows,7) NewGF_CoefControlMasterWave = ""
	Make/O/T/N=(5) NewGF_CoefControlTitleWave = ""
	Make/O/N=(rows) NewGF_CoefControlSortWave = p
	
	NewGF_CoefControlTitleWave[0] = "Data Set" + GRAY_TEXT_STRING + SMALL_UPARROW_STRING
	NewGF_CoefControlTitleWave[1] = "Name"
	NewGF_CoefControlTitleWave[2] = "Initial Guess"
	NewGF_CoefControlTitleWave[3] = "Hold?"
	NewGF_CoefControlTitleWave[4] = "Epsilon"
	SetDataFolder saveFolder
	
	WM_NewGlobalFit1#NewGF_UpdateMasterControlList()			// ST: 210624 - writes listbox entries into the new master list
	
	if (WinType("NewGlobalFitPanel") == 7)						// update the listbox control
		ListBox NewGF_CoefControlList ,win=NewGlobalFitPanel#Tab1ContentPanel ,titleWave=root:Packages:NewGlobalFit:NewGF_CoefControlTitleWave
		ListBox NewGF_CoefControlList ,win=NewGlobalFitPanel#Tab1ContentPanel ,clickEventModifiers=4
		Variable vleft, vtop, vright, vbottom
		PanelCoordEdges("NewGlobalFitPanel#Tab1ContentPanel", vleft, vtop, vright, vbottom)
		TitleBox NewGF_CoefControlIGTitle	 ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={(vright - vleft)-NewGF_CoefListWidthMargin-205,9}	,size={75,15}	,title="Initial Guess:"
		PopupMenu NewGF_SetCoefsFromWaveMenu ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={(vright - vleft)-NewGF_CoefListWidthMargin-120,7}	,size={100,20}	,title="Load"
		PopupMenu NewGF_SaveCoefstoWaveMenu	 ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={(vright - vleft)-NewGF_CoefListWidthMargin-55,7}	,size={100,20}	,title="Save"
	endif
	return 0
End

static Function InitNewGlobalFitPanel()

	if (wintype("NewGlobalFitPanel") == 0)
		InitNewGlobalFitGlobals()
		fNewGlobalFitPanel()
	else
		DoWindow/F NewGlobalFitPanel
	endif
end

static Function UnloadNewGlobalFit()
	if (WinType("NewGlobalFitPanel") == 7)
		DoWindow/K NewGlobalFitPanel
	endif
	if (WinType("GlobalFitGraph") != 0)
		DoWindow/K GlobalFitGraph
	endif
	if (WinType("NewGF_GlobalFitConstraintPanel"))
		DoWindow/K NewGF_GlobalFitConstraintPanel
	endif
	if (WinType("NewGF_WeightingPanel"))
		DoWindow/K NewGF_WeightingPanel
	endif
	if (WinType("NewGF_GlobalFitMaskingPanel"))
		DoWindow/K NewGF_GlobalFitMaskingPanel
	endif
	Execute/P "DELETEINCLUDE  <Global Fit 2>"
	Execute/P "COMPILEPROCEDURES "
	KillDataFolder/Z root:Packages:NewGlobalFit
end

static constant NewGF_DSList_YWaveCol = 0
static constant NewGF_DSList_XWaveCol = 1
static constant NewGF_DSList_FuncCol = 2
static constant NewGF_DSList_NCoefCol = 3

// moved to separate wave
//static constant NewGF_DSList_FirstCoefCol = 4
static constant NewGF_DSList_FirstCoefCol = 0
static strconstant NewGF_NewDFMenuString = "New Data Folder ..."

// Panel Units
static constant NewGF_defaultWidthPU= 715 // (765-50)
static constant NewGF_defaultHeightPU= 641 // (711-70)

static Function fNewGlobalFitPanel()

	Variable defLeft = 50
	Variable defTop = 70
	Variable defRight = defLeft + NewGF_defaultWidthPU 
	Variable defBottom = defTop + NewGF_defaultHeightPU
	
	DoWindow/K NewGlobalFitPanel
	String fmt="NewPanel/K=1/N=NewGlobalFitPanel/W=(%s) as \"Global Analysis\""
	String cmd = WC_WindowCoordinatesSprintf("NewGlobalFitPanel", fmt, defLeft, defTop, defRight, defBottom, 1)
	Execute cmd

	DefineGuide TabAreaLeft={FL,13}			// this is changed to FR, 25 when tab 0 is hidden
	DefineGuide TabAreaRight={FR,-10}
	DefineGuide TabAreaTop={FT,37}
	DefineGuide TabAreaBottom={FB,-280}		// ST: 210602 - make options area mor compact
	DefineGuide GlobalControlAreaTop={FB,-270}
	DefineGuide Tab0ListTopGuide={TabAreaTop,130}

	TabControl NewGF_TabControl,pos={10,17},size={730,330},proc=WM_NewGlobalFit1#NewGF_TabControlProc		// ST: 210602 - move a bit down to make space for the help button
	TabControl NewGF_TabControl,tabLabel(0)="Data Sets and Functions"
	TabControl NewGF_TabControl,tabLabel(1)="Coefficient Control",value= 0,focusring=0						// ST: 210602 - remove focus ring
	
	Button NewGF_HelpButton,pos={657,6},size={50,20},proc=NewGF_HelpButtonProc,title="Help"

	NewPanel/FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom) /HOST=#
		RenameWindow #,Tab0ContentPanel
		ModifyPanel cbRGB=(60000,60000,60000,0), frameStyle=0, frameInset=0 								// ST: 210602 - make sub-panel transparent to show tab control
	
		GroupBox NewGF_DataSetsGroup,pos={10,5},size={320,113},title="Data Sets"							// ST: 210602 - match position with list and tweak control positions
		GroupBox NewGF_DataSetsGroup,fSize=12,fStyle=1
	
			PopupMenu NewGF_AddDataSetMenu,pos={23,30},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_AddYWaveMenuProc,title="Add Data Sets"
			PopupMenu NewGF_AddDataSetMenu,mode=0,value= #"NewGF_YWaveList(1)"

			Button NewGF_AddRemoveWavesButton,pos={23,58},size={295,20},proc=NewGF_AddRemoveWavesButtonProc,title="Add/Remove Waves..."

//			PopupMenu NewGF_SetDataSetMenu,pos={23,59},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_SetDataSetMenuProc,title="Choose Y Wave"
//			PopupMenu NewGF_SetDataSetMenu,mode=0,value= #"NewGF_YWaveList(0)"
//
//			PopupMenu NewGF_SetXDataSetMenu,pos={175,59},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_SetXWaveMenuProc,title="Choose X Wave"
//			PopupMenu NewGF_SetXDataSetMenu,mode=0,value= #"NewGF_XWaveList()"

			PopupMenu NewGF_RemoveDataSetMenu1,pos={178,30},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_RemoveDataSetsProc,title="Remove"
			PopupMenu NewGF_RemoveDataSetMenu1,mode=0,value= #"NewGF_RemoveMenuList()"

			PopupMenu NewGF_SetFunctionMenu,pos={23,86},size={140,20},bodyWidth=140,proc=NewGF_SetFuncMenuProc,title="Choose Fit Function"
			PopupMenu NewGF_SetFunctionMenu,mode=0,value= #"NewGF_FitFuncList()"

		GroupBox NewGF_CoefficientsGroup,pos={358,5},size={325,113},title="Coefficients"					// ST: 210602 - match size with list and tweak control positions
		GroupBox NewGF_CoefficientsGroup,fSize=12,fStyle=1

			Button NewGF_LinkCoefsButton,pos={373,86},size={140,20},proc=NewGF_LinkCoefsButtonProc,title="Link Selection"

			Button NewGF_UnLinkCoefsButton,pos={528,86},size={140,20},proc=NewGF_UnLinkCoefsButtonProc,title="Unlink Selection"

			PopupMenu NewGF_SelectAllCoefMenu,pos={373,30},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_SelectAllCoefMenuProc,title="Select Coef Column"
			PopupMenu NewGF_SelectAllCoefMenu,mode=0,value= #"WM_NewGlobalFit1#NewGF_ListFunctionsAndCoefs()"

			PopupMenu NewGF_SelectAlsoCoefMenu,pos={528,30},size={140,20},bodyWidth=140,proc=WM_NewGlobalFit1#NewGF_SelectAllCoefMenuProc,title="Add To Selection"
			PopupMenu NewGF_SelectAlsoCoefMenu,mode=0,value= #"WM_NewGlobalFit1#NewGF_ListFunctionsAndCoefs()"

			PopupMenu NewGF_SelectCoefName,pos={373.00,58},size={140.00,23.00},bodyWidth=140,proc=NewGF_SelectAllCoefsNamedProc,title="Select Coefs Named"
			PopupMenu NewGF_SelectCoefName,mode=0,value= #"WM_NewGlobalFit1#NewGF_ListAllUniqueCoefNames()"

//		GroupBox NewGF_Tab0ListGroup,pos={2,86},size={641,143},disable=1

		ListBox NewGF_DataSetsList,pos={10,130},size={339,160},proc=WM_NewGlobalFit1#NewGF_DataSetListBoxProc,frame=2
		ListBox NewGF_DataSetsList,listWave=root:Packages:NewGlobalFit:NewGF_DataSetListWave
		ListBox NewGF_DataSetsList,selWave=root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
		ListBox NewGF_DataSetsList,mode= 10,editStyle= 1,widths={10,10,10,6},userColumnResize= 1, clickEventModifiers=5

		ListBox NewGF_Tab0CoefList,pos={358,130},size={364,160},proc=WM_NewGlobalFit1#NewGF_DataSetListBoxProc,frame=2
		ListBox NewGF_Tab0CoefList,listWave=root:Packages:NewGlobalFit:NewGF_MainCoefListWave
		ListBox NewGF_Tab0CoefList,selWave=root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
		ListBox NewGF_Tab0CoefList,colorWave=root:Packages:NewGlobalFit:NewGF_LinkColors
		ListBox NewGF_Tab0CoefList,mode= 10,editStyle= 1,widths={100},userColumnResize= 1, clickEventModifiers=5
		
		GroupBox NewGF_Tab0ListDragLine,pos={353,130},size={1,160},frame=0

	SetActiveSubwindow ##
	
	NewPanel/FG=(TabAreaLeft,TabAreaTop,TabAreaRight,TabAreaBottom)/HOST=# 			// ST: 210602 - don't fix the width, so that the sub-panel scales with the main window
		RenameWindow #, Tab1ContentPanel
		ModifyPanel cbRGB=(60000,60000,60000,0), frameStyle=0, frameInset=0 		// ST: 210602 - make sub-panel transparent to show tab control
		
		ListBox NewGF_CoefControlList,pos={4,34},size={440,291},proc = WM_NewGlobalFit1#NewGF_CoefListBoxProc,frame=2
		ListBox NewGF_CoefControlList,listWave=root:Packages:NewGlobalFit:NewGF_CoefControlListWave
		ListBox NewGF_CoefControlList,selWave=root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
		ListBox NewGF_CoefControlList,titleWave=root:Packages:NewGlobalFit:NewGF_CoefControlTitleWave		// ST: 210617 - add dedicated title wave for sorting
		ListBox NewGF_CoefControlList,mode= 10,editStyle= 1,widths= {15,15,7,4,5},userColumnResize=1
		ListBox NewGF_CoefControlList,clickEventModifiers=4													// ST: 210617 - don't react on right-clicks (a popup menu will be presented)
		
		PopupMenu NewGF_FilterCoefsListByCoef,pos={18,7},size={115,20},title="Filter by Coef:"				// ST: 210617 - selects the coefficient to filter the list for
		PopupMenu NewGF_FilterCoefsListByCoef,mode=1,value= #"WM_NewGlobalFit1#NewGF_ListForCoefNameSelector()"
		PopupMenu NewGF_FilterCoefsListByCoef,bodywidth=45,proc=NewGF_FilterCoefControlListPopup
		
		PopupMenu NewGF_FilterCoefsListByFunc,pos={108,7},size={190,20},title="Func:"						// ST: 210617 - selects the function to filter the list for
		PopupMenu NewGF_FilterCoefsListByFunc,mode=1,value= #"WM_NewGlobalFit1#NewGF_ListForFuncNameSelector()"
		PopupMenu NewGF_FilterCoefsListByFunc,bodywidth=120,proc=NewGF_FilterCoefControlListPopup
		
		PopupMenu NewGF_FilterCoefsListBySet,pos={268,7},size={190,20},title="Data:"							// ST: 210625 - selects the data set to filter the list for
		PopupMenu NewGF_FilterCoefsListBySet,mode=1,value= #"WM_NewGlobalFit1#NewGF_ListForDSNameSelector()"
		PopupMenu NewGF_FilterCoefsListBySet,bodywidth=120,proc=NewGF_FilterCoefControlListPopup
		
		TitleBox NewGF_CoefControlIGTitle,pos={485,9},size={75,15},title="Initial Guess:"					// ST: 210617 - align these controls to the right edge
		TitleBox NewGF_CoefControlIGTitle,fSize=12,frame=0,anchor= RC

		PopupMenu NewGF_SetCoefsFromWaveMenu,pos={570,7},size={60,20},title="Load",mode=0,value=NewGF_ListInitGuessWaves(0, 0)
		PopupMenu NewGF_SetCoefsFromWaveMenu,proc=NewGF_SetCoefsFromWaveProc

		PopupMenu NewGF_SaveCoefstoWaveMenu,pos={635,7},size={60,20},title="Save",mode=0,value="New Wave...;\\M1-;"+NewGF_ListInitGuessWaves(0, 0)
		PopupMenu NewGF_SaveCoefstoWaveMenu,proc=NewGF_SaveCoefsToWaveProc

	SetActiveSubwindow ##
	
	NewPanel/W=(495,313,643,351)/FG=(FL,GlobalControlAreaTop,FR,FB)/HOST=# 			// ST: 210602 - tweaked most control positions and sizes of this sub-panel
		ModifyPanel frameStyle=0, frameInset=0
		RenameWindow #,NewGF_GlobalControlArea
	
		TitleBox NewGF_ResultWavesTitle,pos={23,5},size={77,16},title="Result Waves"
		TitleBox NewGF_ResultWavesTitle,fSize=12,frame=0,fStyle=1
		
			CheckBox NewGF_MakeFitCurvesCheck,pos={27,30},size={145,16},proc=WM_NewGlobalFit1#NewGF_FitCurvesCheckProc,title="Make Fit Curve Waves"
			CheckBox NewGF_MakeFitCurvesCheck,fSize=12,value= 1
		
			CheckBox NewGF_AppendResultsCheckbox,pos={50,52},size={186,16},proc=WM_NewGlobalFit1#NewGF_AppendResultsCheckProc,title="And Append Them to Graphs"
			CheckBox NewGF_AppendResultsCheckbox,fSize=12,value= 1
		
			CheckBox NewGF_DoResidualCheck,pos={50,74},size={127,16},proc=WM_NewGlobalFit1#NewGF_CalcResidualsCheckProc,title="Calculate Residuals"
			CheckBox NewGF_DoResidualCheck,fSize=12,value= 1
		
			SetVariable NewGF_SetFitCurveLength,pos={27,105},size={150,20},bodyWidth=50,title="Fit Curve Points:"
			SetVariable NewGF_SetFitCurveLength,fSize=12
			SetVariable NewGF_SetFitCurveLength,limits={2,inf,1},value= root:Packages:NewGlobalFit:FitCurvePoints
		
			CheckBox NewGF_DoDestLogSpacingCheck,pos={50,128},size={135,16},title="Logarithmic Spacing"
			CheckBox NewGF_DoDestLogSpacingCheck,fSize=12,value= 0
		
			SetVariable NewGF_ResultNamePrefix,pos={27,160},size={230,20},bodyWidth=70,title="Result Wave Name Prefix:"
			SetVariable NewGF_ResultNamePrefix,fSize=12,value= _STR:""
		
			TitleBox NewGF_ResultWavesDFTitle,pos={27,185},size={200,20},title="Make Result Waves in Data Folder:"
			TitleBox NewGF_ResultWavesDFTitle,fSize=12,frame=0

			Button NewGF_ResultsDFSelector,pos={27,205},size={230,20},fSize=12
			Button NewGF_ResultsDFSelector, UserData(NewGF_SavedSelection)="Same as Y Wave"
			MakeButtonIntoWSPopupButton("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", "NewGF_ResultsDFSelectorNotify", content = WMWS_DataFolders)
			PopupWS_AddSelectableString("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", "Same as Y Wave")
			PopupWS_AddSelectableString("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", NewGF_NewDFMenuString)
			PopupWS_SetSelectionFullPath("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", "Same as Y Wave")

		GroupBox NewGF_GlobalDivider1,pos={280,7},size={4,220}

		TitleBox NewGF_OptionsTitle,pos={303,5},size={45,16},title="Options",fSize=12
		TitleBox NewGF_OptionsTitle,frame=0,fStyle=1

			CheckBox NewGF_FitProgressGraphCheckBox,pos={318,30},size={124,16},title="Fit Progress Graph"
			CheckBox NewGF_FitProgressGraphCheckBox,fSize=12,value= 1

			CheckBox NewGF_Quiet,pos={318,55},size={318,16},title="No History Output"
			CheckBox NewGF_Quiet,fSize=12,value= 0

			CheckBox NewGF_DoCovarMatrix,pos={318,80},size={120,16},proc=WM_NewGlobalFit1#NewGF_CovMatrixCheckProc,title="Covariance Matrix"
			CheckBox NewGF_DoCovarMatrix,fSize=12,value= 1

			CheckBox NewGF_CorrelationMatrixCheckBox,pos={339,102},size={120,16},proc=WM_NewGlobalFit1#NewGF_CorMatrixCheckProc,title="Correlation Matrix"
			CheckBox NewGF_CorrelationMatrixCheckBox,fSize=12,value= 1

			SetVariable NewGF_SetMaxIters,pos={318,127},size={135,20},bodyWidth=50,title="Max Iterations",fSize=12
			SetVariable NewGF_SetMaxIters,limits={5,500,1},value= root:Packages:NewGlobalFit:NewGF_MaxIters
	
			CheckBox NewGF_ConstraintsCheckBox,pos={318,205},size={95,16},proc=WM_NewGlobalFit1#ConstraintsCheckProc,title="Constraints..."
			CheckBox NewGF_ConstraintsCheckBox,fSize=12,value= 0

			CheckBox NewGF_WeightingCheckBox,pos={318,155},size={87,16},proc=WM_NewGlobalFit1#NewGF_WeightingCheckProc,title="Weighting..."
			CheckBox NewGF_WeightingCheckBox,fSize=12,value= 0

			CheckBox NewGF_MaskingCheckBox,pos={318,180},size={75,16},proc=WM_NewGlobalFit1#NewGF_MaskingCheckProc,title="Masking..."
			CheckBox NewGF_MaskingCheckBox,fSize=12,value= 0

		GroupBox NewGF_SaveSetupGroup,pos={489,7},size={4,250}

		TitleBox NewGF_SaveSetupTitle,pos={513,5},size={65,16},title="Save Setup"
		TitleBox NewGF_SaveSetupTitle,fSize=12,frame=0,fStyle=1

			SetVariable NewGF_SaveSetSetName,pos={523,30},size={170,20},bodyWidth=140,title="Name:",fSize=12
			SetVariable NewGF_SaveSetSetName,value= root:Packages:NewGlobalFit:NewGF_NewSetupName
		
			CheckBox NewGF_StoredSetupOverwriteOKChk,pos={555,63},size={95,20},title="Overwrite OK"
			CheckBox NewGF_StoredSetupOverwriteOKChk,fSize=12,value= 0
		
			Button NewGF_SaveSetupButton,pos={553,90},size={95,20},proc=WM_NewGlobalFit1#NewGF_SaveSetupButtonProc,title="Save",fSize=12
		
			PopupMenu NewGF_RestoreSetupMenu,pos={513,127},size={180,20},bodyWidth=180,proc=WM_NewGlobalFit1#NewGF_RestoreSetupMenuProc,title="Restore Setup"
			PopupMenu NewGF_RestoreSetupMenu,fSize=12,mode=0,value= #"WM_NewGlobalFit1#NewGF_ListStoredSetups()"

		Button DoFitButton,pos={210,240},size={140,20},proc=WM_NewGlobalFit1#NewGF_DoTheFitButtonProc,title="\f01Fit!"
		Button DoFitButton,fSize=12,fColor=(16385,49025,65535)

	SetActiveSubwindow ##
	
	NewGF_SetTabControlContent(0)
	
	SetWindow NewGlobalFitPanel, hook = WC_WindowCoordinatesHook
	SetWindow NewGlobalFitPanel, hook(NewGF_Resize) = NewGF_PanelHook
	
	DFREF savedSetup = root:Packages:NewGlobalFit_StoredSetups:$saveSetupName
	if (DataFolderRefStatus(savedSetup) > 0)
		NewGF_RestoreSetup(saveSetupName)
	endif

	NewGF_MoveControls()
end

Function IsMinimized(windowName)
	String windowName
	
	if (strsearch(WinRecreation(windowName, 0), "MoveWindow 0, 0, 0, 0", 0, 2) > 0)
		return 1
	endif
	
	return 0
end

// PanelCoordEdges is a panel-coordinate replacement for GetWindow wsizeDC.
// NOTE: using GetWindow wsize or wsizeDC based on PanelResolution(win) == 72
// will not work for a subwindow, because GetWindow Panel0#subwindow wsize
// will instead actually return GetWindow Panel0#subwindow wsizeDC.
//
// A control with these corner coordinates will fill the entire (sub)window.
//
// PanelCoordEdges works with Graph windows, too, but we don't recommend
// putting controls in graphs; put the controls in a panel subwindow within graphs.

static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))
	vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
	vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
	vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
End

static Function insideRect(r, p)
	STRUCT Rect &r
	STRUCT Point &p
	
	return (p.v > r.top) && (p.v < r.bottom) && (p.h > r.left) && (p.h < r.right)
end

static Function ControlRect(wName, cName, r)
	String wName, cName
	STRUCT Rect &r
	
	ControlInfo/W=$wName $cName
	r.left = V_left
	r.top = V_top
	r.right = V_left+V_width
	r.bottom = V_top+V_height
end

static Function OffsetRect(r, dx, dy)
	STRUCT Rect &r
	Variable dx, dy
	
	r.top += dy
	r.bottom += dy
	r.left += dx
	r.right += dx
end

static Function getHotRect(r, dx, dy)
	STRUCT Rect &r
	Variable dx, dy
	
	STRUCT Rect leftListRect
	STRUCT Rect rightListRect

	ControlRect("NewGlobalFitPanel#Tab0ContentPanel", "NewGF_DataSetsList", leftListRect)
	ControlRect("NewGlobalFitPanel#Tab0ContentPanel", "NewGF_Tab0CoefList", rightListRect)
	r = leftListRect
	r.left = leftListRect.right-3
	r.right = rightListRect.left+3
	OffsetRect(r, dx, dy)
	
	GetWindow NewGlobalFitPanel#Tab0ContentPanel expand		// ST: 230127 - apply expansion factor to rectangle
	Variable panelExpansion = V_value
	r.top *= panelExpansion
	r.bottom *= panelExpansion
	r.left *= panelExpansion
	r.right *= panelExpansion
end

static constant charOne=49
static constant charZero=48

static structure ListSizeInfo
	Variable DataSetsListWidth
	Variable CoefListLeft
	Variable CoefListWidth
	STRUCT Point mouseDownLoc
endstructure

StrConstant saveSetupName = "LastSetupSaved"

Function NewGF_PanelHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable statusCode = 0

	STRUCT Rect hotRect
	STRUCT ListSizeInfo lsi
	String listInfoStructString
		
	strswitch (s.eventName)
		case "keyboard":
			if ( (s.keycode == 13) || (s.keyCode == 3) )			// return or enter key
				NewGF_DoTheFitButtonProc("")
				statusCode = 1
			endif
			break;
		case "kill":
			NewGF_SaveSetup(saveSetupName)
			if (WinType("NewGF_GlobalFitConstraintPanel"))
				DoWindow/K NewGF_GlobalFitConstraintPanel
			endif
			if (WinType("NewGF_WeightingPanel"))
				DoWindow/K NewGF_WeightingPanel
			endif
			if (WinType("NewGF_GlobalFitMaskingPanel"))
				DoWindow/K NewGF_GlobalFitMaskingPanel
			endif
			break
		case "resize":
			if (IsMinimized(s.winName))
				break;
			endif
			NewGF_MainPanelMinWindowSize()
			NewGF_MoveControls()
			break
		case "mousedown":
			ControlInfo/W=NewGlobalFitPanel NewGF_TabControl
			if (V_value > 0)
				break;
			endif

			getHotRect(hotRect, s.winRect.left, s.winRect.top)
			if (insideRect(hotRect, s.mouseLoc) && CmpStr("NewGlobalFitPanel#Tab0ContentPanel",s.winName) == 0)		// ST: 230127 - make sure this only applies to sub-panel with the lists
				
				lsi.mouseDownLoc = s.mouseLoc
				SetWindow $(s.winName) UserData(GlobalFitListDrag) = "1"
				ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_DataSetsList
				lsi.DataSetsListWidth = V_width
				ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_Tab0CoefList
				lsi.CoefListLeft = V_left
				lsi.CoefListWidth = V_width
				StructPut/S lsi, listInfoStructString
				SetWindow $(s.winName) UserData(DragListsInfo)=listInfoStructString
				statusCode = 1
			endif
			break;
		case "mouseup":
			ControlInfo/W=NewGlobalFitPanel NewGF_TabControl
			if (V_value > 0)
				break;
			endif
 
			if (Char2Num(GetUserData(s.winName, "", "GlobalFitListDrag")) == charOne)
				SetWindow $(s.winName) UserData(GlobalFitListDrag) = "0"
			endif
			break;
		case "mousemoved":
			ControlInfo/W=NewGlobalFitPanel NewGF_TabControl
			if (V_value > 0)
				break;
			endif

			getHotRect(hotRect, s.winRect.left, s.winRect.top)
			if ( (Char2Num(GetUserData(s.winName, "", "GlobalFitListDrag")) == charOne) && (s.eventMod & 1) )
				listInfoStructString = GetUserData(s.winName, "", "DragListsInfo")
				StructGet/S lsi, listInfoStructString
				Variable dx = s.mouseLoc.h-lsi.mouseDownLoc.h
				ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_DataSetsList
				Variable listWidth = lsi.DataSetsListWidth+dx
				if (listWidth < 40)
					break;
				endif
				ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_DataSetsList
				Variable listRight = V_left+listWidth
				if (lsi.CoefListWidth-dx < 40)
					Break;
				endif
				ListBox NewGF_DataSetsList,win=NewGlobalFitPanel#Tab0ContentPanel,size={listWidth, V_height}
				
				Groupbox NewGF_Tab0ListDragLine,win=NewGlobalFitPanel#Tab0ContentPanel, pos={listRight+(NewGF_Tab0ListGrout/2-1), V_top}

				ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_Tab0CoefList
				ListBox NewGF_Tab0CoefList,win=NewGlobalFitPanel#Tab0ContentPanel,pos={lsi.CoefListLeft+dx, V_top},size={lsi.CoefListWidth-dx, V_height}
				statusCode = 1
			elseif (insideRect(hotRect, s.mouseLoc) && CmpStr("NewGlobalFitPanel#Tab0ContentPanel",s.winName) == 0)		// ST: 230127 - make sure this only applies to sub-panel with the lists
				s.doSetCursor = 1
				s.cursorCode = 5
			endif
			break;
	endswitch
	 
	return statusCode		// 0 if nothing done, else 1
End

// These sizes are in "Panel Units"
static constant NewGF_MainPanelMinWidth = 715
static constant NewGF_MainPanelMinHeight = 550

static constant NewGF_TabWidthMargin = 15
static constant NewGF_TabHeightMargin = 122

static constant NewGF_Tab0ListGroupWidthMargin  = 5
static constant NewGF_Tab0ListGroupBottomMargin  = 8	// ST: 210602 - slightly more space towards the edge
//static constant NewGF_Tab0ListGroupHeightMargin = 88
static constant NewGF_Tab0ListGroupHeightMargin = 92
static constant NewGF_Tab0ListGrout = 9

static constant NewGF_DataSetListGrpWidthMargin = 341
//static constant NewGF_DataSetListGrpHghtMargin = 4

static constant NewGF_Tab0CoefListTopMargin = 88
static constant NewGF_Tab0CoefListLeftMargin = 1
static constant NewGF_Tab0CoefListRightMargin = 10		// ST: 210602 - slightly more space towards the edge

static constant NewGF_CoefListWidthMargin = 10
static constant NewGF_CoefListHeightMargin = 40

static Function NewGF_MainPanelMinWindowSize()

	GetWindow NewGlobalFitPanel, wsize // points
	Variable minimized= (V_right == V_left) && (V_bottom==V_top)
	if( minimized )
		return 0
	endif
	Variable width= (V_right - V_left)
	Variable height= (V_bottom - V_top)
	Variable PanelUnitsToPoints= PanelResolution("NewGlobalFitPanel")/ScreenResolution
	Variable minWidthPoints= NewGF_MainPanelMinWidth*PanelUnitsToPoints
	Variable minHeightPoints= NewGF_MainPanelMinHeight*PanelUnitsToPoints
#if IgorVersion() >= 7
	SetWindow NewGlobalFitPanel sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	Variable newwidth= max(width, minWidthPoints)
	Variable newheight= max(height, minHeightPoints)
	if (newwidth != width || newheight != height)
		// Turns out that on Windows, if the window is maximized MoveWindow puts the window into a weird state that
		// you can't get out of. So here we do this only if we need to override the minimum size.
		MoveWindow/W=NewGlobalFitPanel V_left, V_top, V_left+newwidth, V_top+newheight
	endif
#endif
End

static Function CalcListSizes(listTop, listHeight, dataSetsListWidth, dataSetsListRight, coefsListleft, coefsListWidth)
	Variable &listTop, &listHeight, &dataSetsListWidth, &dataSetsListRight, &coefsListleft, &coefsListWidth
	
	String leftGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaLeft")
	Variable leftGuideX = NumberByKey("POSITION", leftGuideInfo)
	String rightGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaRight")
	Variable rightGuideX = NumberByKey("POSITION", rightGuideInfo)
	String topGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaTop")
	Variable topGuideY = NumberByKey("POSITION", topGuideInfo)
	String bottomGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaBottom")
	Variable bottomGuideY = NumberByKey("POSITION", bottomGuideInfo)
	String listTopGuideInfo = GuideInfo("NewGlobalFitPanel", "Tab0ListTopGuide")
	listTop = NumberByKey("POSITION", listTopGuideInfo) - topGuideY
	listHeight = bottomGuideY - topGuideY - listTop - NewGF_Tab0ListGroupBottomMargin

	ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel NewGF_DataSetsList
	dataSetsListWidth = V_width		// constant width
	dataSetsListRight = V_left + V_width
	Variable dataSetsListLeft = V_left

	coefsListleft = dataSetsListRight + NewGF_Tab0ListGrout
	coefsListWidth = (rightGuideX - leftGuideX) - coefsListleft - NewGF_Tab0CoefListRightMargin
	
	if (coefsListWidth < 40)
		Variable delta = 40 - coefsListWidth
		coefsListWidth = 40
		dataSetsListWidth -= delta
		dataSetsListRight = dataSetsListLeft + dataSetsListWidth
		coefsListleft = dataSetsListRight + NewGF_Tab0ListGrout
	endif
end

static Function NewGF_MoveControls()

	String tabBottomGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaBottom")
	Variable tabBottom = NumberByKey("POSITION", tabBottomGuideInfo)
	String tabRightGuideInfo = GuideInfo("NewGlobalFitPanel", "TabAreaRight")
	Variable tabRight = NumberByKey("POSITION", tabRightGuideInfo)
	ControlInfo/W=NewGlobalFitPanel NewGF_TabControl
	Variable tabTop = V_top
	Variable tabLeft = V_left
	TabControl NewGF_TabControl, win=NewGlobalFitPanel,size={tabRight-tabLeft+3, tabBottom-tabTop+3}

	Variable listTop, listHeight, dataSetsListWidth, dataSetsListRight, coefsListleft, coefsListWidth

	CalcListSizes(listTop, listHeight, dataSetsListWidth, dataSetsListRight, coefsListleft, coefsListWidth)
	ListBox NewGF_DataSetsList, win=NewGlobalFitPanel#Tab0ContentPanel, pos={dataSetsListRight-dataSetsListWidth, listTop}, size={dataSetsListWidth, listHeight}
	ListBox NewGF_Tab0CoefList, win=NewGlobalFitPanel#Tab0ContentPanel, pos={coefsListleft, listTop}, size={coefsListWidth, listHeight}			
	Groupbox NewGF_Tab0ListDragLine,win=NewGlobalFitPanel#Tab0ContentPanel, pos={dataSetsListRight+(NewGF_Tab0ListGrout/2-1), listTop},size={1, listHeight}

	Variable vleft, vtop, vright, vbottom
	PanelCoordEdges("NewGlobalFitPanel#Tab1ContentPanel", vleft, vtop, vright, vbottom)
	Variable panelWidth = (vright - vleft)
	Variable panelHeight = (vbottom - vtop)
	ListBox NewGF_CoefControlList, win=NewGlobalFitPanel#Tab1ContentPanel,size={panelWidth-NewGF_CoefListWidthMargin, panelHeight-NewGF_CoefListHeightMargin}
	
	TitleBox NewGF_CoefControlIGTitle	 ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={panelWidth-NewGF_CoefListWidthMargin-205,9}	,size={75,15}	// ST: 210617 - keep controls at the right edge
	PopupMenu NewGF_SetCoefsFromWaveMenu ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={panelWidth-NewGF_CoefListWidthMargin-120,7}	,size={100,20}
	PopupMenu NewGF_SaveCoefstoWaveMenu	 ,win=NewGlobalFitPanel#Tab1ContentPanel	,pos={panelWidth-NewGF_CoefListWidthMargin-55,7}	,size={100,20}
	
	GetWindow NewGlobalFitPanel, wsize
	Variable px = ScreenResolution / PanelResolution("NewGlobalFitPanel")
	Button NewGF_HelpButton,win=NewGlobalFitPanel,pos={V_right*px-V_left*px-60, 6}		// ST: 210602 - proper positioning even on windows via scaling factor
end


static Function/S NewGF_ListStoredSetups()

	String SaveDF = GetDataFolder(1)
	SetDataFolder root:Packages:
	
	if (!DataFolderExists("NewGlobalFit_StoredSetups"))
		SetDataFolder $saveDF
		return "\\M1(No Stored Setups"
	endif
	
	SetDataFolder NewGlobalFit_StoredSetups
	
	Variable numDFs = CountObjects(":", 4)
	if (numDFs == 0)
		SetDataFolder $saveDF
		return "\\M1(No Stored Setups"
	endif
	
	Variable i
	String theList = ""
	for (i = 0; i < numDFs; i += 1)
		theList += (GetIndexedObjName(":", 4, i)+";")
	endfor
	
	SetDataFolder $saveDF
	return theList
end

// Expects a legal name as input. If the folder already exists, it will be overwritten.
Function NewGF_SaveSetup(saveName)
	String saveName
	
	DFREF SaveDF = GetDataFolderDFR()
	SetDataFolder root:Packages:
	NewDataFolder/O/S NewGlobalFit_StoredSetups

	DFREF targetDF = $saveName
	if (DataFolderRefStatus(targetDF) > 0)
		KillDataFolder targetDF
	endif
	DuplicateDataFolder ::NewGlobalFit, $saveName
	SetDataFolder $saveName
	
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_ConstraintsCheckBox
	Variable/G DoConstraints = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_WeightingCheckBox
	Variable/G DoWeighting = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_MaskingCheckBox
	Variable/G DoMasking = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoCovarMatrix
	Variable/G DoCovarMatrix = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_CorrelationMatrixCheckBox
	Variable/G DoCorelMatrix = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_MakeFitCurvesCheck
	Variable/G MakeFitCurves = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_AppendResultsCheckbox
	Variable/G AppendResults = V_value 
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoResidualCheck
	Variable/G DoResiduals = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoDestLogSpacingCheck
	Variable/G DoLogSpacing = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_Quiet
	Variable/G DoQuiet = V_value
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_FitProgressGraphCheckBox
	Variable/G DoFitProgressGraph = V_value
	
	Wave/Z YCumData, FitY, NewGF_LinkageMatrix, NewGF_CoefWave
	Wave/T/Z NewGF_FitFuncNames, NewGF_DataSetsList
	KillWaves/Z YCumData, FitY, NewGF_FitFuncNames, NewGF_LinkageMatrix, NewGF_DataSetsList, NewGF_CoefWave
	
	Wave/Z CoefDataSetLinkage, DataSetPointer, MasterCoefs, EpsilonWave
	Wave/Z/T NewGF_CoefficientNames, FitFuncList
	KillWaves/Z NewGF_CoefficientNames, CoefDataSetLinkage, FitFuncList, DataSetPointer, MasterCoefs, EpsilonWave

	Wave/Z GFWeightWave
	Wave/Z GFMaskWave
	Wave/T/Z GFUI_GlobalFitConstraintWave
	KillWaves/Z GFWeightWave, GFMaskWave, GFUI_GlobalFitConstraintWave

	Wave/Z M_Correlation, fitXCumData, XCumData, M_Covar, W_sigma, W_ParamConfidenceInterval
	KillWaves/Z M_Correlation, fitXCumData, XCumData, M_Covar, W_sigma, W_ParamConfidenceInterval 
	
	KillVariables/Z V_Flag, V_FitQuitReason, V_FitError, V_FitNumIters, V_numNaNs, V_numINFs, V_npnts, V_nterms, V_nheld
	KillVariables/Z V_startRow, V_endRow, V_startCol, V_endCol, V_chisq
	
	SetDataFolder saveDF
end

static Function NewGF_SaveSetupButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR NewGF_NewSetupName = root:Packages:NewGlobalFit:NewGF_NewSetupName
	
	DFREF SaveDF = GetDataFolderDFR()
	SetDataFolder root:Packages:
	NewDataFolder/O/S NewGlobalFit_StoredSetups

	if (CheckName(NewGF_NewSetupName, 11))
		if (DataFolderExists(NewGF_NewSetupName))
			ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_StoredSetupOverwriteOKChk
			if (V_value)
				KillDataFolder $NewGF_NewSetupName
			else
				DoAlert 1, "The setup name "+NewGF_NewSetupName+" already exists. Make a unique name and continue?"
				if (V_flag == 1)
					NewGF_NewSetupName = UniqueName(NewGF_NewSetupName, 11, 0)
				else
					SetDataFolder saveDF
					return 0							// ******* EXIT *********
				endif
			endif
		else
			DoAlert 1, "The setup name is not a legal name. Fix it up and continue?"
			if (V_flag == 1)
				NewGF_NewSetupName = CleanupName(NewGF_NewSetupName, 1)
				NewGF_NewSetupName = UniqueName(NewGF_NewSetupName, 11, 0)
			endif
		endif
	endif

	SetDataFolder saveDF
	
	NewGF_SaveSetup(NewGF_NewSetupName)
end	

Function NewGF_RestoreSetup(savedSetupName)
	String savedSetupName
	
	DFREF saveDF = GetDataFolderDFR()
	DFREF savedSetupDF = root:Packages:NewGlobalFit_StoredSetups:$(savedSetupName)
	if (DataFolderRefStatus(savedSetupDF) == 0)
		return -1
	endif
	
	SetDataFolder savedSetupDF
	Variable i = 0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		
		Duplicate/O w, root:Packages:NewGlobalFit:$(NameOfWave(w))
		NewGF_PossiblyMake2DListWave3D()
		i += 1
	while (1)
	
	String vars = VariableList("*", ";", 4)
	Variable nv = ItemsInList(vars)
	for (i = 0; i < nv; i += 1)
		String varname = StringFromList(i, vars)
		NVAR vv = $varname
		Variable/G root:Packages:NewGlobalFit:$varname = vv
	endfor
	
	String strs = StringList("*", ";")
	Variable nstr = ItemsInList(strs)
	for (i = 0; i < nstr; i += 1)
		String strname = StringFromList(i, strs)
		SVAR ss = $strname
		String/G root:Packages:NewGlobalFit:$strname = ss
	endfor
	
	SetDataFolder root:Packages:NewGlobalFit
	NVAR DoConstraints
	CheckBox NewGF_ConstraintsCheckBox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoConstraints
	NVAR DoWeighting
	CheckBox NewGF_WeightingCheckBox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoWeighting
	NVAR DoMasking
	CheckBox NewGF_MaskingCheckBox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoMasking
	NVAR DoCovarMatrix
	CheckBox NewGF_DoCovarMatrix,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoCovarMatrix
	NVAR DoCorelMatrix
	CheckBox NewGF_CorrelationMatrixCheckBox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoCorelMatrix
	NVAR MakeFitCurves
	CheckBox NewGF_MakeFitCurvesCheck,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=MakeFitCurves
	NVAR AppendResults
	CheckBox NewGF_AppendResultsCheckbox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=AppendResults
	NVAR DoResiduals
	CheckBox NewGF_DoResidualCheck,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoResiduals
	Variable/G DoLogSpacing = NumVarOrDefault("DoLogSpacing", 0)
	CheckBox NewGF_DoDestLogSpacingCheck,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoLogSpacing
	NVAR DoQuiet
	CheckBox NewGF_Quiet,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoQuiet
	NVAR DoFitProgressGraph
	CheckBox NewGF_FitProgressGraphCheckBox,win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=DoFitProgressGraph
	KillVariables/Z DoConstraints, DoWeighting, DoMasking, DoCovarMatrix, DoCorelMatrix, MakeFitCurves, AppendResults, DoResiduals, DoQuiet, DoFitProgressGraph
	
	SetDataFolder saveDF	
	return 0
end

static Function NewGF_RestoreSetupMenuProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)			// mouse up
		if (NewGF_RestoreSetup(PU_Struct.popStr))
			DoAlert 0, "The saved setup was not found."
		endif
	endif
End

Function NewGF_SetTabControlContent(whichTab)
	Variable whichTab
	
	switch(whichTab)
		case 0:
			SetWindow NewGlobalFitPanel#Tab1ContentPanel hide=1
			SetWindow NewGlobalFitPanel#Tab0ContentPanel hide=0
			break;
		case 1:
			NVAR/Z NewGF_RebuildCoefListNow = root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow
			if (!NVAR_Exists(NewGF_RebuildCoefListNow) || NewGF_RebuildCoefListNow)
				NewGF_RebuildCoefListWave()
			endif
			SetWindow NewGlobalFitPanel#Tab0ContentPanel hide=1
			SetWindow NewGlobalFitPanel#Tab1ContentPanel hide=0
			WM_NewGlobalFit1#NewGF_SortCoefControlList()		// ST: 210617 - update list sorting
			break;
	endswitch
//	NewGF_MoveControls()
end

static Function NewGF_TabControlProc(TC_Struct)
	STRUCT WMTabControlAction &TC_Struct

	if (TC_Struct.eventCode == 2)
		NewGF_SetTabControlContent(TC_Struct.tab)
	endif
End

static Function isControlOrRightClick(eventMod)
	Variable eventMod
	
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		if ( (eventMod & 24) == 16)
			return 1
		endif
	else
		if ( (eventMod & 16) == 16)
			return 1
		endif
	endif
	
	return 0
end

static Function NewGF_UnlinkCellsLinkedToThisOne(cellText)
	String cellText
	
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
	Variable rows = DimSize(CoefListWave, 0)
	Variable cols = DimSize(CoefListWave, 1)

	String linktext = "LINK:"+cellText
	Variable i, j
	for (i = 0; i < rows; i++)
		for (j = 0; j < cols; j++)
			if (CmpStr(CoefListWave[i][j][0], linktext) == 0)
				CoefListWave[i][j][0] = CoefListWave[i][j][1]
				CoefSelWave[i][j][1] = 0
			endif
		endfor
	endfor
end

Function NewGF_SetFunctionForRow(funcName, row)
	String funcName
	Variable row
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave

	String CoefList
	Variable NumCoefs = GetNumCoefsAndNamesFromFunction(FuncName, coefList)

	Variable i, j
	
	if (strlen(ListWave[row][NewGF_DSList_FuncCol][0]) > 0)
		// The new function is replacing one already selected. We need to adjust linkages that might point to this row.
		Variable nOldCoefs = str2num(ListWave[row][NewGF_DSList_NCoefCol][0])
		if (NumType(nOldCoefs) == 0 && nOldCoefs > 0)
			for (i = 0; i < nOldCoefs; i++)
				if (IsLinkText(CoefListWave[row][NewGF_DSList_FirstCoefCol+i][0]))
					CoefSelWave[row][NewGF_DSList_FirstCoefCol+i][1] = 0			// wipe out the linkage coloring; the new function isn't linked yet. Will be replaced with new text in the loop below
					continue
				endif
				NewGF_UnlinkCellsLinkedToThisOne(CoefListWave[row][NewGF_DSList_FirstCoefCol+i][0])
			endfor
		endif
	endif

	if (numType(NumCoefs) == 0)
		if (NumCoefs > DimSize(CoefListWave, 1)-NewGF_DSList_FirstCoefCol)
			Redimension/N=(-1,NumCoefs+NewGF_DSList_FirstCoefCol, -1) CoefListWave, CoefSelWave
			for (i = 1; i < NumCoefs; i += 1)
				SetDimLabel 1, i+NewGF_DSList_FirstCoefCol,$("K"+num2str(i)), CoefListWave
			endfor
		endif
	endif
	
	Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
	ListWave[row][NewGF_DSList_FuncCol][0] = FuncName
	if (numType(NumCoefs) == 0)
		ListWave[row][NewGF_DSList_NCoefCol][0] = num2istr(NumCoefs)
		for (j = 0; j < NumCoefs; j += 1)
			String coeftitle = StringFromList(j, coefList)
			if (strlen(coeftitle) == 0)
				coeftitle = "r"+num2istr(row)+":K"+num2istr(j)
			else
				coeftitle = "r"+num2istr(row)+":"+coeftitle
			endif
			CoefListWave[row][NewGF_DSList_FirstCoefCol+j][] = coeftitle
			CoefSelWave[row][NewGF_DSList_FirstCoefCol+j][] = 0
		endfor
		SelWave[row][NewGF_DSList_NCoefCol][0] = 0
	else
		SelWave[row][NewGF_DSList_NCoefCol][0] = 2
	endif
	for (j = j+NewGF_DSList_FirstCoefCol;j < DimSize(CoefListWave, 1); j += 1)
		CoefListWave[row][j][] = ""
	endfor
end

static Function NewGF_DataSetListBoxProc(s)
	STRUCT WMListboxAction &s
	
	Variable numcoefs
	String funcName
	Variable i,j
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
	Variable numrows = DimSize(ListWave, 0)
	Variable numcols = DimSize(Listwave, 1)
	
	switch (s.eventCode)
		case 7:							// finish edit
			if (CmpStr(s.ctrlName, "NewGF_Tab0CoefList") == 0)
				return 0
			endif
				
			if (s.col == NewGF_DSList_NCoefCol)
			
				numcoefs = str2num(ListWave[s.row][s.col][0])
				if (numtype(numcoefs) != 0)													// ST: 210603 - no valid input
					break
				endif
				
				funcName = ListWave[s.row][NewGF_DSList_FuncCol][0]
				Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
				
				if (NumCoefs > DimSize(CoefListWave, 1)-NewGF_DSList_FirstCoefCol)
					Redimension/N=(-1,NumCoefs+NewGF_DSList_FirstCoefCol, -1) CoefListWave, CoefSelWave
					for (i = 1; i < NumCoefs; i += 1)
						SetDimLabel 1, i+NewGF_DSList_FirstCoefCol,$("K"+num2str(i)), CoefListWave
					endfor
				endif
				for (i = 0; i < numrows; i += 1)
					if (CmpStr(funcName, ListWave[i][NewGF_DSList_FuncCol][0]) == 0)
						ListWave[i][NewGF_DSList_NCoefCol][0] = num2str(numCoefs)
						for (j = 0; j < numCoefs; j += 1)
							if (!IsLinkText(CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]))		// don't change a LINK specification
								CoefListWave[i][NewGF_DSList_FirstCoefCol+j] = "r"+num2istr(i)+":K"+num2istr(j)
							endif
						endfor
					endif
				endfor
				
				NewGF_CheckCoefsAndReduceDims()
			endif
			break;
		case 1:							// mouse down
			Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
				
			if (s.row == -1 && (s.eventMod == 1))					// left-click in title row
				if (CmpStr(s.ctrlName, "NewGF_Tab0CoefList") == 0)
					Wave SelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
				else
					Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
				endif
				SelWave[][][0] = SelWave[p][q] & ~9						// de-select everything to make sure we don't leave something selected in another column
				SelWave[][s.col][0] = SelWave[p][s.col] | 1				// select all rows
			elseif ( s.row == -1 && (s.eventMod & 16))				// context-click in title row
				if (CmpStr(s.ctrlName, "NewGF_Tab0CoefList") == 0)
					return 0
				endif
				if (s.col == 0)												// Y Wave list
				elseif (s.col == 1)											// X Wave list
					SelWave[][][0] = SelWave[p][q] & ~9						// de-select everything to make sure we don't leave something selected in another column
					SelWave[][s.col][0] = SelWave[p][s.col] | 1				// select all rows
					ControlUpdate/W=$(s.win) $(s.ctrlName)
					PopupContextualMenu "_calculated_;"+WaveList("*",";","DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
					if (V_flag > 0)
						Wave w = $S_selection
						for (i = 0; i < numrows; i += 1)
							Wave/Z w = $S_selection
							NewGF_SetXWaveInList(w, i)
							SelWave[s.row][s.col][0] = 0
						endfor
					endif
				elseif (s.col == 2)											// function list
					SelWave[][][0] = SelWave[p][q] & ~9						// de-select everything to make sure we don't leave something selected in another column
					SelWave[][s.col][0] = SelWave[p][s.col] | 1				// select all rows
					ControlUpdate/W=$(s.win) $(s.ctrlName)
					PopupContextualMenu NewGF_FitFuncList()
					if (V_flag > 0)
						for (i = 0; i < numrows; i += 1)
							NewGF_SetFunctionForRow(S_selection, i)
						endfor
						NewGF_CheckCoefsAndReduceDims()
						NewGF_RebuildCoefListWave()
					endif
				endif
			elseif ( (s.row >= 0) && (s.row < DimSize(SelWave, 0)) )
				if (CmpStr(s.ctrlName, "NewGF_Tab0CoefList") == 0)
					return 0
				endif
				
				if (isControlOrRightClick(s.eventMod))				// right-click or ctrl-click
					switch(s.col)
						case NewGF_DSList_YWaveCol:
							PopupContextualMenu NewGF_YWaveList(-1)
							if (V_flag > 0)
								Wave w = $S_selection
								NewGF_SetYWaveForRowInList(w, $"", s.row)
								SelWave[s.row][s.col][0] = 0
							endif
							break
						case NewGF_DSList_XWaveCol:
							Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
							Wave w = $(ListWave[s.row][NewGF_DSList_YWaveCol][1])
							if (WaveExists(w))
								if ( (SelWave[s.row][s.col] & 9) == 0 )		// context-click on selected cell? If not, select the clicked cell
									SelWave[][][0] = SelWave[p][q] & ~9						// de-select everything to make sure we don't leave something selected in another column
									SelWave[s.row][s.col][0] = SelWave[s.row][s.col] | 1				// select all rows
									ControlUpdate/W=$(s.win) $(s.ctrlName)
								endif
								String RowsText = num2str(DimSize(w, 0))
								PopupContextualMenu "_calculated_;"+WaveList("*",";","MINROWS:"+RowsText+",MAXROWS:"+RowsText+",DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
								if (V_flag > 0)
									Wave/Z w = $S_selection
									for (i = 0; i < numrows; i += 1)
										if (SelWave[i][s.col] & 9)
											NewGF_SetXWaveInList(w, i)
										endif
									endfor
								endif
							endif
							break
						case NewGF_DSList_FuncCol:
							if ( (SelWave[s.row][s.col] & 9) == 0 )		// context-click on selected cell? If not, select the clicked cell
								SelWave[][][0] = SelWave[p][q] & ~9						// de-select everything to make sure we don't leave something selected in another column
								SelWave[s.row][s.col][0] = SelWave[s.row][s.col] | 1				// select all rows
								ControlUpdate/W=$(s.win) $(s.ctrlName)
							endif
							PopupContextualMenu NewGF_FitFuncList()
							if (V_flag > 0)
								for (i = 0; i < numrows; i += 1)
									if (SelWave[i][s.col] & 9)
										NewGF_SetFunctionForRow(S_selection, i)
									endif
								endfor
								NewGF_CheckCoefsAndReduceDims()
								NewGF_RebuildCoefListWave()
							endif
							break
					endswitch
				endif
			endif
			break;
		case 8:		// vertical scroll (responding to 10, programmatically set top row, caused feedback if scrolling ocurred very rapidly, as with a scroll wheel)
			String otherCtrl = ""
			if (CmpStr(s.ctrlName, "NewGF_DataSetsList") == 0)
				otherCtrl = "NewGF_Tab0CoefList"
			else 
				otherCtrl = "NewGF_DataSetsList"
			endif
			ControlInfo/W=NewGlobalFitPanel#Tab0ContentPanel $otherCtrl
	//print s.ctrlName, otherCtrl, "event = ", s.eventCode, "row = ", s.row, "V_startRow = ", V_startRow
			if (V_startRow != s.row)
				ListBox $otherCtrl win=NewGlobalFitPanel#Tab0ContentPanel,row=s.row
				DoUpdate
			endif
			break;
		case 12:	// keys
	// print "listbox "+s.win+" got key "+num2char(s.row)+" ("+num2str(s.row)+") and modifiers "+num2str(s.eventMod)
			if ( ((s.row == char2num("a")) || (s.row == char2num("A"))) && (s.eventMod & 8) )		// ST: 210617 - select function row with cmd / ctrl + a
				SelWave[][2] = SelWave[p][q] | 1
			endif
			break;
	endswitch
End
//xstatic constant NewGF_DSList_YWaveCol = 0
//xstatic constant NewGF_DSList_XWaveCol = 1
//xstatic constant NewGF_DSList_FuncCol = 2
//xstatic constant NewGF_DSList_NCoefCol = 3
//xstatic constant NewGF_DSList_FirstCoefCol = 4

Function NewGF_AddYWaveMenuProc(PU_Struct)
	STRUCT WMPopupAction &PU_Struct

	Variable i, nInList
	
	if (PU_Struct.eventCode == 2)			// mouse up
		strswitch (PU_Struct.popStr)
			case "All From Top Graph":
				String tlist = TraceNameList("", ";", 1)
				String tname
				i = 0
				do
					tname = StringFromList(i, tlist)
					if (strlen(tname) == 0)
						break;
					endif
					
					Wave w = TraceNameToWaveRef("", tname)
					Wave/Z xw = XWaveRefFromTrace("", tname)
					if (WaveExists(w) && !NewGF_WaveInListAlready(w))
						NewGF_AddYWaveToList(w, xw)
					endif
					i += 1
				while(1)
				break;
			case "All From Top Table":
				do
					Wave/Z w = WaveRefIndexed(WinName(0, 2), i, 1)
					if (!WaveExists(w))
						break;
					endif
					
					NewGF_AddYWaveToList(w, $"")
					i += 1
				while (1)
				break;
			default:
				Wave/Z w = $(PU_Struct.popStr)
				if (WaveExists(w) && !NewGF_WaveInListAlready(w))
					NewGF_AddYWaveToList(w, $"")
				endif
				break;
		endswitch
	endif
	
	return 0
end


Function NewGF_AddRemoveWavesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			BuildDataSetSelector()
			break
	endswitch

	return 0
End

static Function NewGF_WaveInListAlready(w)
	Wave w
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Variable i
	Variable nrows = DimSize(ListWave, 0)
	for (i = 0; i < nrows; i += 1)
		Wave/Z rowWave = $(ListWave[i][NewGF_DSList_YWaveCol][1])
		if (WaveExists(rowWave) && (CmpStr(ListWave[i][NewGF_DSList_YWaveCol][1], GetWavesDataFolder(w, 2)) == 0))
			return 1
		endif
	endfor
	
	return 0
end

static Function NewGF_AddYWaveToList(w, xw)
	Wave w
	Wave/Z xw
	
	if (!NewGF_WaveIsSuitable(w))
		return 0
	endif
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
	
	Variable nextRow
	
	if (DimSize(ListWave, 0) == 1)
		if (AllFieldsAreBlank(ListWave, 0))
			nextRow = 0
		else
			nextRow = 1
		endif
	else
		nextRow = DimSize(ListWave, 0)
	endif
	
	Redimension/N=(nextRow+1, -1, -1) ListWave, SelWave, CoefListWave, CoefSelWave
	SelWave[nextRow] = 0
	CoefSelWave[nextRow] = 0
	SelWave[nextRow][NewGF_DSList_NCoefCol][0] = 2
	ListWave[nextRow] = ""
	CoefListWave[nextRow] = ""
	
	NewGF_SetYWaveForRowInList(w, xw, nextRow)
	
//	ListWave[nextRow][NewGF_DSList_YWaveCol][0] = NameOfWave(w)
//	ListWave[nextRow][NewGF_DSList_YWaveCol][1] = GetWavesDataFolder(w, 2)
//	if (WaveExists(xw))
//		ListWave[nextRow][NewGF_DSList_XWaveCol][0] = NameOfWave(xw)
//		ListWave[nextRow][NewGF_DSList_XWaveCol][1] = GetWavesDataFolder(xw, 2)
//	else
//		ListWave[nextRow][NewGF_DSList_XWaveCol][0] = "_calculated_"
//		ListWave[nextRow][NewGF_DSList_XWaveCol][1] = "_calculated_"
//	endif
	
	Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
end

static Function NewGF_SetYWaveForRowInList(w, xw, row)
	Wave/Z w
	Wave/Z xw
	Variable row
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	
	if (WaveExists(w))
		ListWave[row][NewGF_DSList_YWaveCol][0] = NameOfWave(w)
		ListWave[row][NewGF_DSList_YWaveCol][1] = GetWavesDataFolder(w, 2)
	else
		ListWave[row][NewGF_DSList_YWaveCol][0] = ""			// this allows us to clear the data set from a row
		ListWave[row][NewGF_DSList_YWaveCol][1] = ""
	endif
	if (WaveExists(xw))
		ListWave[row][NewGF_DSList_XWaveCol][0] = NameOfWave(xw)
		ListWave[row][NewGF_DSList_XWaveCol][1] = GetWavesDataFolder(xw, 2)
	else
		ListWave[row][NewGF_DSList_XWaveCol][0] = "_calculated_"
		ListWave[row][NewGF_DSList_XWaveCol][1] = "_calculated_"
	endif
	
	// Whatever happens above, something in the list has changed, so we need to flag the change  for the next time the tab changes
	NVAR/Z NewGF_RebuildCoefListNow = root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow
	if (!NVAR_Exists(NewGF_RebuildCoefListNow))
		Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1
	endif
	NewGF_RebuildCoefListNow = 1
end

static Function NewGF_SetDataSetMenuProc(PU_Struct)
	STRUCT WMPopupAction &PU_Struct

	Variable i, j, nInList
	
	if (PU_Struct.eventCode == 2)			// mouse up
		Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
		Variable numRows = DimSize(SelWave, 0)

		strswitch (PU_Struct.popStr)
			case "From Top Graph":
				String tlist = TraceNameList("", ";", 1)
				String tname
				i = 0; j = 0
				for (j = 0; j < numRows; j += 1)
					if ( (SelWave[j][NewGF_DSList_YWaveCol] & 9) != 0)
						NewGF_SetYWaveForRowInList($"", $"", j)
					endif
				endfor
				for (j = 0; j < numRows; j += 1)
					if ( (SelWave[j][NewGF_DSList_YWaveCol] & 9) != 0)
						tname = StringFromList(i, tlist)
						if (strlen(tname) == 0)
							break;
						endif
						
						Wave w = TraceNameToWaveRef("", tname)
						Wave/Z xw = XWaveRefFromTrace("", tname)
						if (WaveExists(w))
							if  (!NewGF_WaveInListAlready(w))
								NewGF_SetYWaveForRowInList(w, xw, j)
							else
								j -= 1		// we didn't use this row, so counteract the increment for loop (??)
							endif
						endif
						i += 1
					endif
				endfor
				break;
			case "From Top Table":
				i = 0; j = 0
				for (j = 0; j < numRows; j += 1)
					if ( (SelWave[j][NewGF_DSList_YWaveCol] & 9) != 0)
						NewGF_SetYWaveForRowInList($"", $"", j)
					endif
				endfor
				for (j = 0; j < numRows; j += 1)
					if ( (SelWave[j][NewGF_DSList_YWaveCol] & 9) != 0)
						Wave w = WaveRefIndexed(WinName(0, 2), i, 1)
						if (!WaveExists(w))
							break;
						endif
						
						NewGF_SetYWaveForRowInList(w, $"", j)
						i += 1
					endif
				endfor
				break;
			default:
				Wave/Z w = $(PU_Struct.popStr)
				if (WaveExists(w) && !NewGF_WaveInListAlready(w))
					for (j = 0; j < numRows; j += 1)
						if ( (SelWave[j][NewGF_DSList_YWaveCol] & 9) != 0)
							NewGF_SetYWaveForRowInList($"", $"", j)
							NewGF_SetYWaveForRowInList(w, $"", j)
							break				// a data set should appear in the list only once
						endif
					endfor
				endif
				break;
		endswitch
	endif
	
	return 0
End

Function NewGF_SetXWaveInList(w, row)
	Wave/Z w
	Variable row
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	
	if (WaveExists(w))
		Wave/Z yWave = $(ListWave[row][NewGF_DSList_YWaveCol][1])
		if (WaveExists(yWave))
			if (DimSize(yWave, 0) != DimSize(w, 0))
				DoAlert 0, "The wave "+NameOfWave(yWave)+"in row "+num2istr(row)+" has different number of point from the X wave "+NameOfWave(w)
				return -1
			endif
		endif
		
		ListWave[row][NewGF_DSList_XWaveCol][0] = NameOfWave(w)
		ListWave[row][NewGF_DSList_XWaveCol][1] = GetWavesDataFolder(w, 2)
	else
		ListWave[row][NewGF_DSList_XWaveCol][0] = "_calculated_"
		ListWave[row][NewGF_DSList_XWaveCol][1] = "_calculated_"
	endif
	
	// Whatever happens above, something in the list has changed, so we need to flag the change  for the next time the tab changes
	NVAR/Z NewGF_RebuildCoefListNow = root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow
	if (!NVAR_Exists(NewGF_RebuildCoefListNow))
		Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1
	endif
	NewGF_RebuildCoefListNow = 1
end

static Function AllFieldsAreBlank(w, row)
	Wave/T w
	Variable row
	
	Variable i
	Variable lastRow = DimSize(w, 1)
	for (i  = 0; i < lastRow; i += 1)
		if (strlen(w[row][i][0]) != 0)
			return 0
		endif
	endfor
	
	return 1
end

static Function NewGF_WaveIsSuitable(w)
	Wave w
	
	String wname = NameOfWave(w)
	
	if (CmpStr(wname[0,3], "fit_") == 0)
		return 0
	endif
	if (CmpStr(wname[0,3], "res_") == 0)
		return 0
	endif
	if (CmpStr(wname[0,4], "GFit_") == 0)
		return 0
	endif
	if (CmpStr(wname[0,4], "GRes_") == 0)
		return 0
	endif
	
	return 1
end

static Function NewGF_SetXWaveMenuProc(PU_Struct)
	STRUCT WMPopupAction &PU_Struct

//For a PopupMenu control, the WMPopupAction structure has members as described in the following table:
//WMPopupAction Structure Members	
//Member	Description
//char ctrlName[MAX_OBJ_NAME+1]	Control name.
//char win[MAX_WIN_PATH+1]	Host (sub)window.
//STRUCT Rect winRect	Local coordinates of host window.
//STRUCT Rect ctrlRect	Enclosing rectangle of the control.
//STRUCT Point mouseLoc	Mouse location.
//Int32 eventCode	Event that caused the procedure to execute. Main event is mouse up=2.
//String userdata	Primary (unnamed) user data. If this changes, it is written back automatically.
//Int32 popNum	Item number currently selected (1-based).
//char popStr[MAXCMDLEN]	Contents of current popup item.

	Variable i, nInList, waveindex

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Variable numListrows = DimSize(ListWave, 0)
	
	if (PU_Struct.eventCode == 2)			// mouse up
		strswitch (PU_Struct.popStr)
			case "Top Table to List":
				for (i = 0; i < numListrows; i += 1)
					Wave/Z w = WaveRefIndexed(WinName(0, 2), i, 1)
					if (!WaveExists(w))
						break;
					endif
					
					if (NewGF_SetXWaveInList(w, i))
						break
					endif
				endfor
				break;
			case "Top Table to Selection":
				waveindex = 0
				for (i = 0; i < numListrows; i += 1)
					if (SelWave[i][NewGF_DSList_XWaveCol][0] & 9)
						Wave/Z w = WaveRefIndexed(WinName(0, 2), waveindex, 1)
						if (!WaveExists(w))
							break;
						endif
						if (NewGF_SetXWaveInList(w, i))
							break
						endif
						waveindex += 1
					endif
				endfor
				break;
			case "Set All to _calculated_":
				for (i = 0; i < numListrows; i += 1)
					ListWave[i][NewGF_DSList_XWaveCol] = "_calculated_"
				endfor
				break;
			case "Set Selection to _calculated_":
				for (i = 0; i < numListrows; i += 1)
					if (SelWave[i][NewGF_DSList_XWaveCol][0] & 9)
						ListWave[i][NewGF_DSList_XWaveCol] = "_calculated_"
					endif
				endfor
				break;
			default:
				Wave/Z w = $PU_Struct.popStr
				if (WaveExists(w))
					for (i = 0; i < numListrows; i += 1)
						if (SelWave[i][NewGF_DSList_XWaveCol][0] & 9)
							NewGF_SetXWaveInList(w, i)
							//break
						endif
					endfor
				endif
				break;
		endswitch
	endif
	
	return 0
end

Function NewGF_RemoveAllDataSets()

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave

	Redimension/N=(1, 4, -1) ListWave, SelWave
	Redimension/N=(1, 1, -1) CoefListWave, CoefSelWave
	ListWave = ""
	CoefListWave = ""
	SelWave = 0
	CoefSelWave = 0
	Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
end

static Function NewGF_RemoveDataSetsProc(PU_Struct)
	STRUCT WMPopupAction &PU_Struct

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
	
	Variable i,j
	Variable ncols = DimSize(ListWave, 1)
	Variable nrows = DimSize(ListWave, 0)
	
	if (PU_Struct.eventCode == 2)			// mouse up
		strswitch (PU_Struct.popStr)
			case "Remove All":
				NewGF_RemoveAllDataSets()
				break
			case "Remove Selection":
				for (i = nrows-1; i >= 0; i -= 1)
					for (j = 0; j < ncols; j += 1)
						if (SelWave[i][j][0] & 9)
							DeletePoints i, 1, ListWave, SelWave, CoefListWave, CoefSelWave
							Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
							break
						endif
					endfor
				endfor
				break
			default:
				for (i = 0; i < nrows; i += 1)
					if (CmpStr(PU_Struct.popStr, ListWave[i][NewGF_DSList_YWaveCol][0]) == 0)
						DeletePoints i, 1, ListWave, SelWave, CoefListWave, CoefSelWave
						Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
						break
					endif
				endfor
				break
		endswitch
	endif
end

Function NewGF_FitFuncSetSelecRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable SetSelect = (CmpStr(ctrlName, "NewGF_FitFuncSetSelectionRadio") == 0) ^ checked
	
	CheckBox NewGF_FitFuncSetSelectionRadio, win=NewGlobalFitPanel#Tab0ContentPanel, value = SetSelect
	
	CheckBox NewGF_FitFuncSetAllRadio, win=NewGlobalFitPanel#Tab0ContentPanel, value = !SetSelect
End

static Function NewGF_CheckCoefsAndReduceDims()
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave

	Variable i
	Variable numListRows = DimSize(ListWave, 0)
	Variable maxCoefs = 0
	
	// collect the maximum number of coefficients from the # Coefs column
	for (i = 0; i < numListRows; i += 1)
		Variable numCoefs = str2num(ListWave[i][NewGF_DSList_NCoefCol])
		maxCoefs = max(maxCoefs, numCoefs)
	endfor
	
	if (maxCoefs < DimSize(CoefListWave, 1)-NewGF_DSList_FirstCoefCol)
		Variable needCols = maxCoefs + NewGF_DSList_FirstCoefCol
		DeletePoints/M=1 needCols, DimSize(CoefListWave, 1)-needCols, CoefListWave, CoefSelWave
	endif
end

Function NewGF_SetFuncMenuProc(PU_Struct)
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)			// mouse up
	
		Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
		Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
		Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
		
		Variable numListrows = DimSize(ListWave, 0)
		String CoefList
		Variable NumCoefs = GetNumCoefsAndNamesFromFunction(PU_Struct.popStr, coefList)
		Variable i, j
		
//		ControlInfo NewGF_FitFuncSetSelectionRadio
//		Variable SetSelection = V_value
		
		if (numType(NumCoefs) == 0)
			if (NumCoefs > DimSize(CoefListWave, 1)-NewGF_DSList_FirstCoefCol)
				Redimension/N=(-1,NumCoefs+NewGF_DSList_FirstCoefCol, -1) CoefListWave, CoefSelWave
				for (i = 1; i < NumCoefs; i += 1)
					SetDimLabel 1, i+NewGF_DSList_FirstCoefCol,$("K"+num2str(i)), CoefListWave
				endfor
			endif
		endif
		
		for (i = 0; i < numListRows; i += 1)
			if ((SelWave[i][NewGF_DSList_FuncCol][0] & 9) == 0)
				continue		// skip unselected rows
			endif
			
			Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
			ListWave[i][NewGF_DSList_FuncCol][0] = PU_Struct.popStr
			if (numType(NumCoefs) == 0)
				ListWave[i][NewGF_DSList_NCoefCol][0] = num2istr(NumCoefs)
				for (j = 0; j < NumCoefs; j += 1)
					String coeftitle = StringFromList(j, coefList)
					if (strlen(coeftitle) == 0)
						coeftitle = "r"+num2istr(i)+":K"+num2istr(j)
					else
						coeftitle = "r"+num2istr(i)+":"+coeftitle
					endif
					CoefListWave[i][NewGF_DSList_FirstCoefCol+j] = coeftitle
					CoefSelWave[i][NewGF_DSList_FirstCoefCol+j][] = 0					// ST: 210617 - remove color and deselect
				endfor
				SelWave[i][NewGF_DSList_NCoefCol][0] = 0
			else
				SelWave[i][NewGF_DSList_NCoefCol][0] = 2
			endif
		endfor
		
		NewGF_CheckCoefsAndReduceDims()
	endif
end

static Function NewGF_PatchUp2dMainCoefsSelwave()
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave

	if (WaveDims(CoefSelWave) < 3)
		Redimension/N=(-1, -1, 2) CoefSelWave
		SetDimLabel 2, 1, backColors, CoefSelWave
		
		Wave/Z colors = root:Packages:NewGlobalFit:NewGF_LinkColors
		if (!WaveExists(colors))
			ColorTab2Wave Pastels
			Wave M_colors
			Duplicate/O M_colors, root:Packages:NewGlobalFit:NewGF_LinkColors/WAVE=colors
			Variable i, index = 0, size = DimSize(M_colors, 0)
			for (i = 0; i < size; i += 1)
				colors[i][] = M_colors[index][q]
				index += 149
				if (index >= size)
					index -= size
				endif
			endfor
			KillWaves/Z M_colors
		endif
	endif	
end

Function NewGF_LinkCoefsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
	
	NewGF_PatchUp2dMainCoefsSelwave()
	
	Variable listRows = DimSize(CoefListWave, 0)
	Variable listCols = DimSize(CoefListWave, 1)
	Variable i,j
	String linkCellText = ""
	Variable linkrow, linkcol
	Variable lastCol
	Variable colorIndex = 1

	// scan for link color indices in order to set the color index to use this time to the first free color
	do
		Variable startOver = 0
		for (i = 0; i < listRows; i += 1)
			for (j = NewGF_DSList_FirstCoefCol; j < listCols; j += 1)
				if (CoefSelWave[i][j][%backColors] == colorIndex)
					colorIndex += 1
					startOver = 1
					break;
				endif
			endfor
			if (startOver)
				break;
			endif
		endfor
	while (startOver)
	
	// find the first cell in the selection to record the link row and column, and to set the color index if it is already linked.
	for (i = 0; i < listRows; i += 1)
		lastCol = NewGF_DSList_FirstCoefCol + str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
		for (j = NewGF_DSList_FirstCoefCol; j < lastCol; j += 1)
			if (CoefSelWave[i][j][0] & 9)
				linkCellText = CoefListWave[i][j][0]
				linkrow = i
				linkcol = j
				if (CoefSelWave[i][j][%backColors] != 0)
					colorIndex = CoefSelWave[i][j][%backColors]
				endif
				break;
			endif
		endfor
		if (strlen(linkCellText) > 0)
			break;
		endif
	endfor
	// if the first cell in the selection is a link, we want to set the link text to be the original, not derived from the current first selection cell.
	if (IsLinkText(linkCellText))
		linkCellText = linkCellText[5, strlen(linkCellText)-1]
	endif
	CoefSelWave[linkrow][linkcol][0] = 0		// de-select the first selected cell
	
	Wave/Z/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	//Wave/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	//Wave Tab1CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	
	if (!WaveExists(Tab1CoefListWave))			// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif

	Variable accumulatedGuess = 0
	Variable numAccumulatedGuesses = 0
	Variable linkGuessListIndex = CoefIndexFromTab0CoefRowAndCol(linkrow, linkcol)
	if (linkGuessListIndex < DimSize(Tab1CoefListWave,0))
		Variable initGuess = str2num(Tab1CoefListWave[linkGuessListIndex][2])
		if (numtype(initGuess) == 0)
			accumulatedGuess += initGuess
			numAccumulatedGuesses += 1
		endif
		string listOfLinkedRows = num2str(linkGuessListIndex)+";"
		string tab1LinkCellText = Tab1CoefListWave[linkGuessListIndex][1]
		string tab1LinkCellCoef = Tab1CoefListWave[linkGuessListIndex][5]					// ST: 210624 - also save the linked coefficient name (for coefficient list filtering)
	endif
	
	// now scan from the cell after the first selected cell looking for selected cells to link to the first one
	j = linkcol+1
	for (i = linkrow; i < listRows; i += 1)
		lastCol = NewGF_DSList_FirstCoefCol + str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
		do
			if (j >= listCols)
				break
			endif
			if (CoefSelWave[i][j][0] & 9)
				Variable nCoefs = str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
				if (j >= nCoefs)
					CoefSelWave[i][j][0] = 0		// un-select this cell
					break			// this column isn't used for in this row because this function has fewer coefficients than the maximum
				endif
			
				CoefListWave[i][j][0] = "LINK:"+linkCellText
				CoefSelWave[i][j][%backColors] = colorIndex
				CoefSelWave[linkRow][linkCol][%backColors] = colorIndex						// don't want to set the color of this cell unless another cell is linked to it
				CoefSelWave[i][j][0] = 0
				linkGuessListIndex = CoefIndexFromTab0CoefRowAndCol(i, j)
				if (linkGuessListIndex < DimSize(Tab1CoefListWave, 0))
					initGuess = str2num(Tab1CoefListWave[linkGuessListIndex][2])
					if (numtype(initGuess) == 0)
						accumulatedGuess += initGuess
						numAccumulatedGuesses += 1
					endif
					Tab1CoefListWave[linkGuessListIndex][1] = "LINK:"+tab1LinkCellText
					Tab1CoefListWave[linkGuessListIndex][3] = ""							// ST: 210624 - delete any possible links
					Tab1CoefListWave[linkGuessListIndex][5] = tab1LinkCellCoef				// ST: 210624 - also save the linked coefficient name
					//Tab1CoefSelWave[linkGuessListIndex][1] = 0							// ST: 210624 - selWave update happens in the listbox update function instead
					//Tab1CoefSelWave[linkGuessListIndex][2] = 0
					//Tab1CoefSelWave[linkGuessListIndex][3] = 0							// no more checkbox for holding
				endif
				listOfLinkedRows += num2str(linkGuessListIndex)+";"
//				Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
			endif
						
			j += 1
		while(1)
		j = NewGF_DSList_FirstCoefCol
	endfor
	
	// Trying to update the initial guesses depends on having a re-built initial guess list if something has happened to invalidate the list
	NVAR/Z NewGF_RebuildCoefListNow = root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow
	if (!NVAR_Exists(NewGF_RebuildCoefListNow) || NewGF_RebuildCoefListNow)
		NewGF_RebuildCoefListWave()
	else
		WM_NewGlobalFit1#NewGF_SortCoefControlList()										// ST: 210624 - will update the list box
	endif
	
	// finally, install the average initial guess into all the linked rows in the tab1 coefficient control list
	if (numAccumulatedGuesses > 0)
		accumulatedGuess /= numAccumulatedGuesses
		Variable endindex = ItemsInList(listOfLinkedRows)
		for (i = 0; i < endindex; i += 1)
			Tab1CoefListWave[str2num(StringFromList(i, listOfLinkedRows))][2] = num2str(accumulatedGuess)
		endfor
	endif
End

// returns the row in the coefficient guess list (tab 1) for a given row and column in the coefficient list on tab 0
static Function CoefIndexFromTab0CoefRowAndCol(row, col)
	Variable row, col
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave

	Variable i, j
	col -= NewGF_DSList_FirstCoefCol
	
	Variable coefListIndex = 0
	for (i = 0; i < row; i += 1)
		coefListIndex += str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
	endfor
	coefListIndex += col
	
	return coefListIndex
end

Function NewGF_UnLinkCoefsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
//	Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave

	Wave/Z/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	//Wave/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	//Wave Tab1CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	
	if (!WaveExists(Tab1CoefListWave))			// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T Tab1CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	
	Variable listRows = DimSize(CoefListWave, 0)
	Variable listCols = DimSize(CoefListWave, 1)
	Variable i,j
	
	for (i = 0; i < listRows; i += 1)
		for (j = NewGF_DSList_FirstCoefCol; j < listCols; j += 1)
			if (CoefSelWave[i][j][0] & 9)
				Variable nCoefs = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
				if (j >= nCoefs)
					CoefSelWave[i][j][] = 0		// sets color to white AND un-selects
					continue			// this column isn't used for in this row because this function has fewer coefficients than the maximum
				endif
				CoefListWave[i][j][0] = CoefListWave[i][j][1]
				CoefSelWave[i][j][] = 0		// sets color to white AND un-selects
				Variable linkGuessListIndex = CoefIndexFromTab0CoefRowAndCol(i, j)
				if (linkGuessListIndex <  DimSize(Tab1CoefListWave, 0))
					//Tab1CoefSelWave[linkGuessListIndex][1] = 2							// ST: 210624 - selWave update happens in the listbox update function instead
					//Tab1CoefSelWave[linkGuessListIndex][2] = 2
					//Tab1CoefSelWave[linkGuessListIndex][3] = 0x20							// checkbox
					String coefName = CoefNameFromListText(CoefListWave[i][NewGF_DSList_FirstCoefCol + j][1])
					Tab1CoefListWave[linkGuessListIndex][1] = coefName+"["+DataSetListWave[i][NewGF_DSList_FuncCol][0]+"]["+DataSetListWave[i][NewGF_DSList_YWaveCol][1]+"]"	// last part is full path to Y wave
					Tab1CoefListWave[linkGuessListIndex][5] = coefName						// ST: 210624 - write back coef name
				endif
//				Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 1			// this change invalidates the coefficient list on the Coefficient Control tab
			endif
		endfor
	endfor
	WM_NewGlobalFit1#NewGF_SortCoefControlList()											// ST: 210624 - will update list box
End

static Function NewGF_SelectAllCoefMenuProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)			// mouse up
		Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
//		Wave SelWave = root:Packages:NewGlobalFit:NewGF_DataSetListSelWave
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
		Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
		Variable i,j
		Variable numRows = DimSize(CoefListWave, 0)
		
		if (CmpStr(PU_Struct.ctrlName, "NewGF_SelectAllCoefMenu") == 0)
			CoefSelWave[][][0] = CoefSelWave[p][q][0] & ~9		// clear selection if we're not adding to the selection
		endif
		
		String FuncName = FuncNameFromFuncAndCoef(PU_Struct.popstr)
		String CoefName = CoefNameFromListText(PU_Struct.popstr)
		for (i = 0; i < numRows; i += 1)
			if (CmpStr(FuncName, ListWave[i][NewGF_DSList_FuncCol][0]) == 0)
				Variable nc = str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
				for (j = 0; j < nc; j += 1)
					if (CmpStr(CoefName, CoefNameFromListText(CoefListWave[i][NewGF_DSList_FirstCoefCol + j][0])) == 0)
						CoefSelWave[i][NewGF_DSList_FirstCoefCol + j][0] = CoefSelWave[i][NewGF_DSList_FirstCoefCol + j][0] | 1
					endif
				endfor
			endif
		endfor
	endif
End

Function NewGF_SelectAllCoefsNamedProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	if (pa.eventCode == 2)		// mouse up
		Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
		Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_MainCoefListSelWave
		Variable i,j
		Variable numRows = DimSize(CoefListWave, 0)
		
		CoefSelWave[][][0] = CoefSelWave[p][q][0] & ~9		// clear selection first before selecting new
		
		String CoefName = CoefNameFromListText(pa.popstr)
		for (i = 0; i < numRows; i += 1)
			Variable nc = str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
			for (j = 0; j < nc; j += 1)
				if (CmpStr(CoefName, CoefNameFromListText(CoefListWave[i][NewGF_DSList_FirstCoefCol + j][0])) == 0)
					CoefSelWave[i][NewGF_DSList_FirstCoefCol + j][0] = CoefSelWave[i][NewGF_DSList_FirstCoefCol + j][0] | 1
				endif
			endfor
		endfor
	endif

	return 0
End

static Function/S CoefNameFromListText(listText)
	String listText
	
	Variable colonPos = strsearch(listText, ":", inf, 1)		// search backwards
	return listText[colonPos+1, strlen(listText)-1]
end

static Function/S FuncNameFromFuncAndCoef(theText)
	String theText
	
	Variable colonpos = strsearch(theText, ":", 0)
	return theText[0, colonPos-1]
end

static Function/S NewGF_ListFunctionsAndCoefs()

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Variable i, j
	Variable numRows = DimSize(ListWave, 0)
	String theList = ""
	
	for (i = 0; i < numRows; i += 1)
		Variable nCoefs = str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
		String FuncName = ListWave[i][NewGF_DSList_FuncCol][0]
		for (j = 0; j < nCoefs; j += 1)
			Variable coefIndex = j + NewGF_DSList_FirstCoefCol
			String coefText = CoefListWave[i][coefIndex][0]
			if (!IsLinkText(coefText))
				String theItem = FuncName+":"+CoefNameFromListText(coefText)
				if (WhichListItem(theItem, theList) < 0)
					theList += theItem+";"
				endif
			endif
		endfor
	endfor
	
	return theList
end

static Function/S NewGF_ListAllUniqueCoefNames()
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Variable i, j
	Variable numRows = DimSize(ListWave, 0)
	String theList = ""
	
	for (i = 0; i < numRows; i += 1)
		Variable nCoefs = str2num(ListWave[i][NewGF_DSList_NCoefCol][0])
		for (j = 0; j < nCoefs; j += 1)
			Variable coefIndex = j + NewGF_DSList_FirstCoefCol
			String coefText = CoefListWave[i][coefIndex][0]
			if (!IsLinkText(coefText))
				String theItem = CoefNameFromListText(coefText)
				if (WhichListItem(theItem, theList) < 0)
					theList += theItem+";"
				endif
			endif
		endfor
	endfor
	
	return theList
End

static Function/S NewGF_ListForDSNameSelector()			// ST: 210625 - for the list filter: data sets
	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Make/free/T/N=(DimSize(DataSetListWave,0)) temp = DataSetListWave[p][0]
	String list
	wfprintf list, "%s;", temp
	return "OFF;"+list
End

static Function/S NewGF_ListForCoefNameSelector()		// ST: 210617 - for the list filter: coefficients
	return "OFF;"+WM_NewGlobalFit1#NewGF_ListAllUniqueCoefNames()
End

static Function/S NewGF_ListForFuncNameSelector()		// ST: 210617 - for the list filter: functions
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Variable i, numRows = DimSize(ListWave, 0)
	String theList = ""
	
	for (i = 0; i < numRows; i += 1)
		String FuncName = ListWave[i][NewGF_DSList_FuncCol][0]
		if (FindListItem(FuncName, theList) < 0)
			theList += FuncName + ";"
		endif
	endfor
	
	return "OFF;"+theList
End

static Function IsWhiteSpaceChar(thechar)
	Variable thechar
	
	Variable spChar = char2num(" ")
	Variable tabChar = char2num("\t")

	if ( (thechar == spChar) || (thechar == tabChar) )
		return 1
	else
		return 0
	endif
end

static Function IsEndLine(theLine)
	String theLine
	
	Variable i = 0
	Variable linelength = strlen(theLine)
	
	for (i = 0; i < linelength; i += 1)
		Variable thechar = char2num(theLine[i])
		if (!IsWhiteSpaceChar(thechar))
			break
		endif
	endfor
	if (i == linelength)
		return 0
	endif
	return CmpStr(theLine[i, i+2], "end") == 0
end

static Function GetNumCoefsAndNamesFromFunction(funcName, coefList)
	String funcName
	String &coefList
	
	Variable i
	Variable numCoefs
	String funcCode = ProcedureText(funcName )
	
	coefList = ""
	
	if (strlen(funcCode) == 0)		// an XOP function?
		numCoefs = NaN
	else
		i=0
		Variable commentPos
		do
			String aLine = StringFromList(i, funcCode, "\r")
			if (IsEndLine(aLine))
				numCoefs = NaN
				break
			endif
			commentPos = strsearch(aLine, "//CurveFitDialog/ Coefficients", 0 , 2)
			if (commentPos >= 0)		// 2 means ignore case
				sscanf aLine[commentPos, inf], "//CurveFitDialog/ Coefficients %d", numCoefs
				i += 1
				break
			endif
			i += 1
		while (1)
		
		if (numType(numCoefs) == 0)
			do
				aLine = StringFromList(i, funcCode, "\r")
				if (IsEndLine(aLine))
					break
				endif
				commentPos = strsearch(aLine, "//CurveFitDialog/ w[", 0 , 2)
				if (commentPos >= 0)		// 2 means ignore case
					Variable equalPos = strsearch(aLine[commentPos, inf], "=", 0) + commentPos
					if (equalPos > 0)
						equalPos += 1
						Variable spChar = char2num(" ")
						Variable tabChar = char2num("\t")
						do
							Variable char = char2num(aLine[equalPos])
							if ( (char == spChar) || (char == tabChar) )
								equalPos += 1
							else
								string name
								sscanf aLine[equalPos, inf], "%s", name
								coefList += name+";"
								break
							endif
						while(1)
					endif
				endif
				i += 1
			while (1)
		endif
	endif
	
	return numCoefs
end

Function/S NewGF_YWaveList(UseAllWord)
	Variable UseAllWord			// 0: "From Top Graph", 1: "All From Top Graph", -1: Don't include top graph and top table options

	if (UseAllWord == 1)
		String theList = "All From Top Graph;All From Top Table;\\M1-;"
	elseif (UseAllWord == -1)
		theList = ""
	else
		theList = "From Top Graph;From Top Table;\\M1-;"
	endif
	theList += WaveList("*", ";", "DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
	return theList
end

Function/S NewGF_XWaveList()

	String theList = "Top Table to List;Top Table to Selection;Set All to _calculated_;Set Selection to _calculated_;\\M1-;"
	theList += WaveList("*", ";", "DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
	return theList
end

Function/S NewGF_RemoveMenuList()

	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave

	String theList = "Remove All;Remove Selection;\\M0:-:;"
	Variable i
	Variable nrows = DimSize(ListWave, 0)
	for (i = 0; i < nrows; i += 1)
		theList += (ListWave[i][NewGF_DSList_YWaveCol][0])+";"
	endfor
	
	return theList
end

Function/S NewGF_FitFuncList()

	string theList="", UserFuncs, XFuncs
	
	string options = "KIND:10"
//	ControlInfo/W=GlobalFitPanel RequireFitFuncCheckbox
//	if (V_value)
		options += ",SUBTYPE:FitFunc"
//	endif
	options += ",NINDVARS:1"
	
	UserFuncs = FunctionList("*", ";",options)
	UserFuncs = RemoveFromList("GFFitFuncTemplate", UserFuncs)
	UserFuncs = RemoveFromList("GFFitAllAtOnceTemplate", UserFuncs)
	UserFuncs = RemoveFromList("NewGlblFitFunc", UserFuncs)
	UserFuncs = RemoveFromList("NewGlblFitFuncAllAtOnce", UserFuncs)
	UserFuncs = RemoveFromList("GlobalFitFunc", UserFuncs)
	UserFuncs = RemoveFromList("GlobalFitAllAtOnce", UserFuncs)
	UserFuncs = RemoveFromList(NewGFBuiltInFuncList, UserFuncs)			// ST: 210626 - remove exposed built-in functions

	XFuncs = FunctionList("*", ";", "KIND:12")
	
	theList +=  "\\M1(   Built-in functions:;"+NewGFBuiltInFuncList		// ST: 210626 - built-in functions come first
	
	if (strlen(UserFuncs) > 0)
		theList +=  "\\M1(   User-defined functions:;"
		theList += UserFuncs
	endif
	if (strlen(XFuncs) > 0)
		theList += "\\M1(   External Functions:;"
		theList += XFuncs
	endif
	
	if (strlen(theList) == 0)
		theList = "\\M1(No Fit Functions"
	endif
	
	return theList
end

static Function NewGF_RebuildCoefListWave()

	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T Tab0CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave/T CoefDisplayWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave	// ST: 210624 - this wave is displayed in the list box
	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave	// ST: 210624 - this wave holds all the info in the background
	if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave/T CoefTitleWave = root:Packages:NewGlobalFit:NewGF_CoefControlTitleWave
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	
	Variable DSListRows = DimSize(DataSetListWave, 0)
	Variable i, j, k
	Variable numUnlinkedCoefs = 0
	Variable totalCoefs = 0
	Variable nc
	Variable coefColonPos
	Variable colonPos
	Variable linkRow
	
	// count total number of coefficient taking into account linked coefficients
	for (i = 0; i < DSListRows; i += 1)
		totalCoefs += str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
	endfor
	
	if (numtype(totalCoefs) != 0)
		return 0					// ****** EXIT ******
	endif
	
	Redimension/N=(totalCoefs, -1, -1) CoefListWave, CoefSelWave, CoefSortWave, CoefDisplayWave
	CoefListWave[][2] = ""			// clear out any initial guesses that might be left over from previous incarnations
	CoefSelWave[][3] = 0x20			// make the new rows have checkboxes in the Hold column
	CoefListWave[][3] = ""			// make the checkboxes have no label
	CoefSelWave[][1] = 2			// make the name column editable
	CoefSelWave[][2] = 2			// make the initial guess column editable
	CoefSelWave[][4] = 2			// make the epsilon column editable
	CoefListWave[][4] = "1e-6"		// a reasonable value for epsilon
	
	CoefTitleWave[0] = "Data Set" + GRAY_TEXT_STRING + SMALL_UPARROW_STRING						// ST: 210617 - reset titles
	CoefTitleWave[1] = "Name"
	CoefTitleWave[2] = "Initial Guess"
	CoefTitleWave[3] = "Hold?"
	CoefTitleWave[4] = "Epsilon"
	
	Variable coefIndex = 0
	for (i = 0; i < DSListRows; i += 1)
		nc = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
		for (j = 0; j < nc; j += 1)
			CoefListWave[coefIndex][0] = DataSetListWave[i][NewGF_DSList_YWaveCol][1]			// use the full path here
			String coefName = CoefNameFromListText(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol + j][1])
			// ST: 210624 - write additional entries 5 and 6 for list filtering
			CoefListWave[coefIndex][5] = coefName												// isolated coefficient name
			CoefListWave[coefIndex][6] = DataSetListWave[i][NewGF_DSList_FuncCol][0]			// isolated function name
			if (IsLinkText(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]))
				Variable linkIndex = NewGF_CoefRowForLink(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0])
				CoefListWave[coefIndex][1] = "LINK:"+CoefListWave[linkIndex][1]
				CoefListWave[coefIndex][2] = CoefListWave[linkIndex][2]
				CoefListWave[coefIndex][5] = CoefListWave[linkIndex][5]							// ST: 210624 - linked entries will be assigned the 'same' coef name to be filtered together
				CoefSelWave[coefIndex][1,] = 0		// not editable- this is a coefficient linked to another
			else
				CoefListWave[coefIndex][1] = coefName+"["+DataSetListWave[i][NewGF_DSList_FuncCol][0]+"]["+DataSetListWave[i][NewGF_DSList_YWaveCol][1]+"]"	// last part is full path to Y wave
//				CoefListWave[coefIndex][1] = DataSetListWave[i][NewGF_DSList_FuncCol][0]+":"+coefText
			endif
			coefIndex += 1
		endfor
	endfor
	
	CoefDisplayWave = CoefListWave[p][q]							// ST: 210624 - copy all value over into the display as well
	
	if (WinType("NewGlobalFitPanel") == 7)							// ST: 210626 - reset all filters
		ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListByCoef
		if (V_flag != 0)
			PopupMenu NewGF_FilterCoefsListByCoef	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1
			PopupMenu NewGF_FilterCoefsListByFunc	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1
			PopupMenu NewGF_FilterCoefsListBySet	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1
		endif
	endif
	
	Variable/G root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow = 0
end

static Function NewGF_CoefListBoxProc(lb) : ListboxControl			// ST: 210617 - converted into struct based control
	STRUCT WMListboxAction &lb

	Variable i,j, selectionExists, numRowsNeeded
	Variable coefIndex = 0
	
	Wave/T/Z CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	
	// if a coefficient name has been changed, we need to track down any linked coefficients and change them, too.
	Switch (lb.eventCode)			// ST: 210617 - change into switch based control
		case 7:	// end edit
		case 2:	// mouse up
			if ( (lb.col >= 1)	|| (lb.col <= 4) )				// edited a name, initial guess, hold, or epsilon
				if ( ((lb.eventCode == 2) && (lb.col != 3)) || lb.row < 0 )
					return 0
				endif
				WM_NewGlobalFit1#NewGF_UpdateMasterControlList()				// ST: 210624 - first, write the current change into the master list
				
				Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
				Wave/T Tab0CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
				Variable DSListRows = DimSize(DataSetListWave, 0)
				
				for (i = 0; i < DSListRows; i += 1)
					Variable nc = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
					for (j = 0; j < nc; j += 1)
						if (IsLinkText(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]))
							if (NewGF_CoefListRowForLink(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]) == CoefSortWave[lb.row])
								switch (lb.col)
									case 1:
										CoefListWave[coefIndex][1] = "LINK:"+lb.listWave[lb.row][1]
										break;
									case 2:
									case 4:
										CoefListWave[coefIndex][lb.col] = lb.listWave[lb.row][lb.col]
										break;
									case 3:
										if (lb.selWave[lb.row][3] & 0x10)		// is it checked?
											CoefListWave[coefIndex][3] = " X"
										else
											CoefListWave[coefIndex][3] = ""
										endif
										break;
								endswitch
							endif
						endif
						coefIndex += 1
					endfor
				endfor
				WM_NewGlobalFit1#NewGF_UpdateDisplayControlList()				// ST: 210624 - writes updates back into the display list
			endif
		break
		case 1:	// mouse press
			//if ( (lb.row == -1) && (lb.col >= 2) )	// atop name rows of guess, hold, epsilon
			if (lb.eventMod & 16)						// ST: 210617 - make this a right-click menu above all rows
				if (lb.col >= 2)
					selectionExists = (FindSelectedRows(lb.selWave) > 0)
					string menuStr = "Select All;De-select All;"
					string selCoef = ""
					if (lb.row >= 0)					// ST: 210624 - new copy and fill menu entries
						menuStr += "-;Copy Value to Same Coefs.;Clear All for This Coef.;"
						selCoef = CoefListWave[CoefSortWave[lb.row]][5]		// ST: 210624 - coefficient name of the selected row
					endif
					Variable clearCoefs = 0
					if (lb.row >= 0 && lb.col == 2)
						menuStr += "Fill Coef. with Linear Series...;"
					endif
					
					if (lb.col == 3)					// hold column
						menuStr += "Clear All Holds;"
					endif
					menuStr += "-;"						// ST: 210624 - add line break
					if (selectionExists)
						menuStr += "Save Selection to Wave...;Load Selection from Wave...;"
					else
						menuStr += "Save to Wave...;Load from Wave...;"
					endif
					PopupContextualMenu menuStr
					if (V_flag > 0)
						StrSwitch (S_selection)			// ST: 210624 - converted to string switch
							case "Select All":
								lb.selWave[][] = lb.selWave[p][q] & ~9				// clear all selections
								lb.selWave[][lb.col] = lb.selWave[p][lb.col] | 1	// select all in this column
								break;
							case "De-select All":
								lb.selWave[][] = lb.selWave[p][q] & ~9
								break;
							case "Save Selection to Wave...":	
							case "Save to Wave...":
								PopupContextualMenu "\\M1(  Save to Wave:;New Wave...;"+NewGF_ListInitGuessWaves(selectionExists, selectionExists)
								if (V_flag > 0)
									if (CmpStr(S_selection, "New Wave...") == 0)
										numRowsNeeded = selectionExists ? totalSelRealCoefsFromCoefList(1) : totalRealCoefsFromCoefList(0)
										String newName = NewGF_GetNewWaveName()
										if (strlen(newName) == 0)
											return 0
										endif
										Make/O/N=(numRowsNeeded)/D $newName
										Wave w = $newName
									else
										Wave w = $(S_selection)
									endif
									
									if (WaveExists(w))
										SaveCoefListToWave(w, lb.col, selectionExists, selectionExists)		// SaveOnlySelectedCells, OKToSaveLinkCells
									endif
								endif
								break;
							case "Load Selection from Wave...":
							case "Load from Wave...":
								selectionExists = (FindSelectedRows(lb.selWave) > 0)
								PopupContextualMenu "\\M1(  Load From Wave:;"+NewGF_ListInitGuessWaves(selectionExists, selectionExists)
								if (V_flag > 0)
									Wave w = $(S_selection)
									
									if (WaveExists(w))
										SetCoefListFromWave(w, lb.col, selectionExists, selectionExists)
									endif
								endif
								break;
							case "Clear All Holds":
								for (i = 0; i < DimSize(lb.selWave, 0); i += 1)
									Make/O/N=(DimSize(lb.selWave, 0)) GFTempHoldWave
									GFTempHoldWave = 0
									SetCoefListFromWave(GFTempHoldWave, 3, 0, 0)
									KillWaves/Z GFTempHoldWave
								endfor
								break;
							case "Clear All for This Coef.":
								clearCoefs = 1
							case "Copy Value to Same Coefs.":							// ST: 210624 - copies selected entry to all fields of the same coefficent
								for (i = 0; i < DimSize(CoefListWave,0); i += 1)
									if (CmpStr(selCoef,CoefListWave[i][5]) == 0)
										if (clearCoefs)
											CoefListWave[i][lb.col] = ""
										else
											CoefListWave[i][lb.col] = CoefListWave[CoefSortWave[lb.row]][lb.col]
										endif
									endif
								endfor
								WM_NewGlobalFit1#NewGF_UpdateDisplayControlList()		// ST: 210624 - writes updates back into the display list
								break;
							case "Fill Coef. with Linear Series...":
								Variable valStart=0, valIncr=0, count = 0
								Prompt valStart, "Start value:"
								Prompt valIncr, "Increment:"
								DoPrompt "Enter Values for Linear Fill", valStart, valIncr
								if (!V_Flag)
									for (i = 0; i < DimSize(CoefListWave,0); i += 1)
										if (CmpStr(selCoef,CoefListWave[i][5]) == 0)
											if (IsLinkText(CoefListWave[i][1]))			// ST: 210624 - don't increment values for linked coefficients
												CoefListWave[i][lb.col] = num2str(valStart)
											else
												CoefListWave[i][lb.col] = num2str(valStart+valIncr*count++)
											endif
										endif
									endfor
								endif
								WM_NewGlobalFit1#NewGF_UpdateDisplayControlList()		// ST: 210624 - writes updates back into the display list
								break;
						endswitch
						WM_NewGlobalFit1#NewGF_UpdateMasterControlList()				// ST: 210624 - writes updates into the master list as well
					endif
				endif
			else
				if (lb.row < 0 && WaveExists(lb.titleWave))								// ST: 210617 - add list sorting
					String CurrentTitle = lb.titleWave[lb.col]
					Variable StartOfArrowString = -1
					Variable doReverse = 0
					
					if (strsearch(CurrentTitle, SMALL_UPARROW_STRING, 0) >= 0)			// currently sorted small-to-large; use reverse sort
						doReverse = 1
						StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
						CurrentTitle = CurrentTitle[0,StartOfArrowString-1] + GRAY_TEXT_STRING + SMALL_DOWNARROW_STRING
						lb.titleWave[lb.col] = CurrentTitle
					elseif (strsearch(CurrentTitle, SMALL_DOWNARROW_STRING, 0) >= 0)	// currently sorted large-to-small (reversed); use forward sort
						doReverse = 0
						StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
						CurrentTitle = CurrentTitle[0,StartOfArrowString-1] + GRAY_TEXT_STRING + SMALL_UPARROW_STRING
						lb.titleWave[lb.col] = CurrentTitle
					else																// currently sorted by a different column; use forward sort, and find the current sort column in order to remove the sort arrow
						doReverse = 0
						Variable numCols = DimSize(lb.listWave, 1)
						for (i = 0; i < numCols; i += 1)								// search for current sort column and remove the sort-indicator arrow
							CurrentTitle = lb.titleWave[i]
							StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
							if (StartOfArrowString >= 0)
								CurrentTitle = CurrentTitle[0, StartOfArrowString-1]
								lb.titleWave[i] = CurrentTitle
								break;
							endif
						endfor
						lb.titleWave[lb.col] = (lb.titleWave[lb.col]) + GRAY_TEXT_STRING + SMALL_UPARROW_STRING		// set the up-arrow on the new sort column
					endif
					
					WM_NewGlobalFit1#NewGF_SortCoefControlList()
				endif
			endif
		break
	EndSwitch
	
	return 0
end

Function NewGF_FilterCoefControlListPopup(s) : PopupMenuControl		// ST: 210617 - sorts and highlights specific rows of the list
	STRUCT WMPopupAction &s
	if (s.eventCode == 2)
		WM_NewGlobalFit1#NewGF_SortCoefControlList()
	endif
	return 0
end

static Function NewGF_SortCoefControlList()							// ST: 210617 - the master sort function
	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	if (!WaveExists(CoefListWave))									// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave/T CoefDispWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	Wave/T CoefTitleWave = root:Packages:NewGlobalFit:NewGF_CoefControlTitleWave
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	Variable i, rows = DimSize(CoefListWave, 0)
	
	// ### filtering
	String coefFilter = "OFF"
	String funcFilter = "OFF"
	String setFilter = "OFF" 
	ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListByCoef
	if (V_flag != 0)
		ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListByCoef
		coefFilter = S_Value
		ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListByFunc
		funcFilter = S_Value
		ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListBySet
		setFilter = PossiblyQuoteName(S_Value) 
	endif
	
	// ST: 211006 - below 'filter' code runs even for old panels to properly update the display list
	Variable filterCoef = CmpStr(coefFilter,"OFF") != 0			// what to filter
	Variable filterFunc = CmpStr(funcFilter,"OFF") != 0
	Variable filterDset = CmpStr(setFilter,"OFF") != 0
	
	Duplicate/O/T CoefListWave, CoefDispWave					// prepare full-sized waves
	Redimension/N=(rows) CoefSortWave
	Redimension/N=(rows, 5, -1) CoefDispWave,  CoefSelWave
	CoefDispWave[][3] = ""
	CoefSelWave = StringMatch(CoefListWave[p][1],"LINK:*") ? 0 : 2
	CoefSelWave[][0] = 0
	CoefSelWave[][3] = StringMatch(CoefListWave[p][1],"LINK:*") ? 0 : 0x20
	//CoefSelWave[][3] = StringMatch(CoefListWave[p][1],"LINK:*") ? (CoefSelWave[p][3] | (0x80)) : (CoefSelWave[p][3] & ~(0x80))
	CoefSelWave[][3] = StringMatch(CoefListWave[p][3]," X") ? (CoefSelWave[p][3] | (0x10)) : (CoefSelWave[p][3] & ~(0x10)) // set hold state
	CoefSortWave = p
	
	for (i = rows-1; i >= 0; i -= 1)							// delete non-matching entries
		if (CmpStr(CoefListWave[i][5],coefFilter) != 0 && filterCoef)
			DeletePoints i,1, CoefDispWave, CoefSelWave, CoefSortWave
		endif
		if (CmpStr(CoefListWave[i][6],funcFilter) != 0 && filterFunc)
			DeletePoints i,1, CoefDispWave, CoefSelWave, CoefSortWave
		endif
		if (!StringMatch(CoefListWave[i][0],"*"+setFilter) && filterDset)
			DeletePoints i,1, CoefDispWave, CoefSelWave, CoefSortWave
		endif
	endfor
	rows = DimSize(CoefDispWave, 0)
	if (rows == 0)												// no match
		return 0
	endif
	
	// ### sorting
	Variable sortBy, sortReverse = 0
	FindValue/TEXT=SMALL_UPARROW_STRING CoefTitleWave				// find current sort column
	if (V_Value != -1)
		sortBy = V_Value
	else
		FindValue/TEXT=SMALL_DOWNARROW_STRING CoefTitleWave
		sortBy = V_Value
		sortReverse = 1
	endif
	
	Make/N=(rows)/free/T SortWave, nameWave
	Make/N=(rows)/free sortIndex, orderSortWave
	if (sortBy == 3)												// the hold column
		nameWave = CoefListWave[CoefSortWave[p]][1]
		nameWave = ReplaceString("LINK:",nameWave[p],"")
		// if selWave is checked or has no checkbox then fill in the current coef name (sorts by coefs) or sort last ("~" char is last in ASCII sorting)
		//SortWave = SelectString((CoefSelWave[p][3] & 0x10) || (CoefSelWave[p][3] & 0x20) == 0,"~",CoefListWave[CoefSortWave[p]][5])
		SortWave = SelectString((CoefSelWave[p][3] & 0x10) || (CoefSelWave[p][3] & 0x20) == 0,"~",nameWave[p])
	else
		SortWave = CoefDispWave[p][sortBy][0]						// first sort option is the current sort column
	endif
	SortWave = ReplaceString("LINK:",SortWave[p],"")
	orderSortWave = CoefSortWave[p]									// second sort option is the original order
	
	if (sortReverse)
		MakeIndex/A/R {SortWave,orderSortWave}, sortIndex
	else
		MakeIndex/A {SortWave,orderSortWave}, sortIndex	
	endif

	Duplicate/free/T CoefDispWave, TMPDispWave
	Duplicate/free CoefSortWave, TMPsortWave
	Duplicate/free CoefSelWave, TMPselWave
	CoefDispWave[][] = TMPDispWave[sortIndex[p]][q]
	CoefSelWave[][] = TMPselWave[sortIndex[p]][q]
	CoefSortWave[][] = TMPsortWave[sortIndex[p]][q]
	return 0
End

// ST: 211006 - NOTE: both below function only handle VALUE changes and do not update the LINK state!
static Function NewGF_UpdateMasterControlList()						// ST: 210624 - writes any changes from the displayed listbox list into the master list
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	Wave/T CoefDispWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	Variable i, rows = DimSize(CoefDispWave, 0)
	Variable isChecked
	for (i = 0; i < rows; i++)
		isChecked = (CoefSelWave[i][3] & 0x10) != 0
		CoefListWave[CoefSortWave[i]][0,4] = CoefDispWave[i][q]
		CoefListWave[CoefSortWave[i]][3] = SelectString(isChecked,""," X")	// save checked state in master list
	endfor
	return 0
End

static Function NewGF_UpdateDisplayControlList()					// ST: 210624 - writes any changes back from the master list into the display list
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	Wave/T CoefDispWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	Variable i, rows = DimSize(CoefDispWave, 0)
	Variable isChecked
	for (i = 0; i < rows; i++)
		isChecked = CmpStr(CoefListWave[CoefSortWave[i]][3]," X") == 0
		CoefDispWave[i][] = CoefListWave[CoefSortWave[i]][q]
		CoefSelWave[i][3] = isChecked ? (CoefSelWave[i][3] | (0x10)) : (CoefSelWave[i][3] & ~(0x10)) // set hold state
	endfor
	CoefDispWave[][3] = ""											// delete the " X"
	return 0
End

// finds the row number in the coefficient guess list (tab 1) corresponding to the cell in the tab0 coefficient list linked to by a linked cell
static Function NewGF_CoefRowForLink(linktext)
	String linktext
	
	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T Tab0CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave

	Variable i,j
	Variable DSListRows = DimSize(DataSetListWave, 0)
	Variable coefIndex = 0;
	
	for (i = 0; i < 	DSListRows; i += 1)
		Variable nc = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
		for (j = 0; j < nc; j += 1)
			if (CmpStr((Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]), linktext[5, strlen(linktext)-1]) == 0)
				return coefIndex
			endif
			if (!IsLinkText(Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]))
				coefIndex += 1
			endif
		endfor
	endfor
end

static Function NewGF_CoefListRowForLink(linktext)
	String linktext
	
	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T Tab0CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave

	Variable i,j
	Variable DSListRows = DimSize(DataSetListWave, 0)
	Variable coefIndex = 0;
	
	for (i = 0; i < DSListRows; i += 1)
		Variable nc = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])
		for (j = 0; j < nc; j += 1)
			if (CmpStr((Tab0CoefListWave[i][NewGF_DSList_FirstCoefCol+j][0]), linktext[5, strlen(linktext)-1]) == 0)
				return coefIndex
			endif
			coefIndex += 1
		endfor
	endfor
end


//******************************************************
// the function that runs when Fit! button is clicked
//******************************************************

//static constant NewGF_DSList_YWaveCol = 0
//static constant NewGF_DSList_XWaveCol = 1
//static constant NewGF_DSList_FuncCol = 2
//static constant NewGF_DSList_NCoefCol = 3

//static constant NewGF_DSList_FirstCoefCol = 0

//static constant FuncPointerCol = 0
//static constant FirstPointCol = 1
//static constant LastPointCol = 2
//static constant NumFuncCoefsCol = 3
//static constant FirstCoefCol = 4

static Function NewGF_DoTheFitButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_FilterCoefsListByCoef
	if (V_flag != 0)
		PopupMenu NewGF_FilterCoefsListByCoef	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1		// ST: 210624 - undo list filtering before doing the fit
		PopupMenu NewGF_FilterCoefsListByFunc	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1
		PopupMenu NewGF_FilterCoefsListBySet	,win=NewGlobalFitPanel#Tab1ContentPanel	,mode=1
		WM_NewGlobalFit1#NewGF_SortCoefControlList()
	endif

	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Wave/T Tab0CoefListWave = root:Packages:NewGlobalFit:NewGF_MainCoefListWave
	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	
	Variable numDataSets = DimSize(DataSetListWave, 0)
	if (numDataSets <= 1)
		if ( (numDataSets == 1) && (strlen(DataSetListWave[0][0][0]) == 0) )
			DoAlert 0, "You have not selected any data to fit."
			return -1
		endif
	endif
	
	Variable numCoefCols = DimSize(Tab0CoefListWave, 1)
	Variable i, j
	Variable nextFunc = 0

	Variable curveFitOptions = 0

	// build wave listing Fitting Function names. Have to check for repeats...
	Make/O/T/N=(numDataSets) root:Packages:NewGlobalFit:NewGF_FitFuncNames = ""
	Wave/T FitFuncNames = root:Packages:NewGlobalFit:NewGF_FitFuncNames
	
	for (i = 0; i < numDataSets; i += 1)
		if (!ItemListedInWave(DataSetListWave[i][NewGF_DSList_FuncCol][0], FitFuncNames))
			FitFuncNames[nextFunc] = DataSetListWave[i][NewGF_DSList_FuncCol][0]
			nextFunc += 1
		endif
	endfor
	Redimension/N=(nextFunc) FitFuncNames
	
	// build the linkage matrix required by DoNewGlobalFit
	// It is a coincidence that the matrix used by the list in the control panel has the same number of columns as the linkage matrix
	// so here we calculate the number of columns to protect against future changes
	
	Variable MaxNCoefs = numCoefCols - NewGF_DSList_FirstCoefCol
	Variable numLinkageCols = MaxNCoefs + FirstCoefCol
	
	Make/N=(numDataSets, numLinkageCols)/O root:Packages:NewGlobalFit:NewGF_LinkageMatrix
	Wave LinkageMatrix = root:Packages:NewGlobalFit:NewGF_LinkageMatrix
	
	Variable nRealCoefs = 0		// accumulates the number of independent coefficients (that is, non-link coefficients)
	for (i = 0; i < numDataSets; i += 1)
		Variable nc = str2num(DataSetListWave[i][NewGF_DSList_NCoefCol][0])

		LinkageMatrix[i][FuncPointerCol] = ItemNumberInTextWaveList(DataSetListWave[i][NewGF_DSList_FuncCol][0], FitFuncNames)
		LinkageMatrix[i][FirstPointCol] = 0		// this is private info used by DoNewGlobalFit(). It will be filled in by DoNewGlobalFit()
		LinkageMatrix[i][LastPointCol] = 0		// this is private info used by DoNewGlobalFit(). It will be filled in by DoNewGlobalFit()
		LinkageMatrix[i][NumFuncCoefsCol] = nc
		
		for (j = NewGF_DSList_FirstCoefCol; j < numCoefCols; j += 1)
			Variable linkMatrixCol = FirstCoefCol + j - NewGF_DSList_FirstCoefCol
			if (j-NewGF_DSList_FirstCoefCol < nc)
				String cellText = Tab0CoefListWave[i][j][0]
				if (IsLinkText(cellText))
					LinkageMatrix[i][linkMatrixCol] = NewGF_CoefRowForLink(cellText)
				else
					LinkageMatrix[i][linkMatrixCol] = nRealCoefs
					nRealCoefs += 1
				endif
			else
				LinkageMatrix[i][linkMatrixCol] = -1
			endif
		endfor
DoUpdate
	endfor
	
	// Build the data sets list wave
	Make/O/T/N=(numDataSets, 2) root:Packages:NewGlobalFit:NewGF_DataSetsList
	Wave/T DataSets = root:Packages:NewGlobalFit:NewGF_DataSetsList
	DataSets[][0,1] = DataSetListWave[p][q+NewGF_DSList_YWaveCol][1]		// layer 1 contains full paths
	
	// Add weighting, if necessary
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_WeightingCheckBox
	if (V_value)
		GFUI_AddWeightWavesToDataSets(DataSets)
		NVAR/Z GlobalFit_WeightsAreSD = root:Packages:NewGlobalFit:GlobalFit_WeightsAreSD
		if (NVAR_Exists(GlobalFit_WeightsAreSD) && GlobalFit_WeightsAreSD)
			curveFitOptions += NewGFOptionWTISSTD
		endif
	endif
	
	// Add Mask, if necessary
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_MaskingCheckBox
	if (V_value)
		GFUI_AddMaskWavesToDataSets(DataSets)
	endif

	// Build the Coefficient wave and CoefNames wave
	Make/O/D/N=(nRealCoefs, 3) root:Packages:NewGlobalFit:NewGF_CoefWave
	Wave coefWave = root:Packages:NewGlobalFit:NewGF_CoefWave
	SetDimLabel 1,1,Hold,coefWave
	SetDimLabel 1,2,Epsilon,coefWave
	Make/O/T/N=(nRealCoefs) root:Packages:NewGlobalFit:NewGF_CoefficientNames
	Wave/T CoefNames = root:Packages:NewGlobalFit:NewGF_CoefficientNames

	Variable coefIndex = 0, rowIndex = 0
	Variable nTotalCoefs = DimSize(CoefListWave, 0)
	for (i = 0; i < nTotalCoefs; i += 1)
		if (!IsLinkText(CoefListWave[i][1]))
			coefWave[coefIndex][0] = str2num(CoefListWave[i][2])
			FindValue/V=(i) CoefSortWave
			rowIndex = V_Value			// ST: 220130 - make sure to use the unsorted index here !!! this should always work, since no filters are applied.
			if (numtype(coefWave[coefIndex][0]) != 0)
				TabControl NewGF_TabControl, win=NewGlobalFitPanel,value=1
				NewGF_SetTabControlContent(1)
				DoAlert 0, "There is a problem with the initial guess value in row "+num2str(rowIndex+1)+": it is not a number."	// ST: 220130 - add +1 to name the row so that an user can find it
				CoefSelWave = (CoefSelWave & ~9)
				CoefSelWave[rowIndex][2] = 3
				return -1
			endif
			coefWave[coefIndex][%Hold] = ((CoefSelWave[rowIndex][3] & 0x10) != 0)
			coefWave[coefIndex][%Epsilon] = str2num(CoefListWave[i][4])
			if (numtype(coefWave[coefIndex][%Epsilon]) != 0)
				TabControl NewGF_TabControl, win=NewGlobalFitPanel,value=1
				NewGF_SetTabControlContent(1)
				CoefSelWave = (CoefSelWave & ~9)
				CoefSelWave[rowIndex][4] = 3
				DoAlert 0, "There is a problem with the Epsilon value in row "+num2str(rowIndex+1)+": it is not a number."
				return -1
			endif
			CoefNames[coefIndex] = CoefListWave[i][1]
			coefIndex += 1
		endif
	endfor
	
	// Build constraint wave, if necessary
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_ConstraintsCheckBox
	if (V_value)
		NewGF_MakeConstraintWave()
		Wave/T/Z ConstraintWave = root:Packages:NewGlobalFit:GFUI_GlobalFitConstraintWave
	else
		Wave/T/Z ConstraintWave = $""
	endif
	
	// Set options
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoCovarMatrix
	if (V_value)
		curveFitOptions += NewGFOptionCOV_MATRIX
	endif

	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_CorrelationMatrixCheckBox
	if (V_value)
		curveFitOptions += NewGFOptionCOR_MATRIX
	endif

	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_MakeFitCurvesCheck
	if (V_value)
		curveFitOptions += NewGFOptionMAKE_FIT_WAVES
	endif

	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea AppendResultsCheck
	if (V_value)
		curveFitOptions += NewGFOptionAPPEND_RESULTS
	endif
	
	NVAR FitCurvePoints = root:Packages:NewGlobalFit:FitCurvePoints
	
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoResidualCheck
	if (V_value)
		curveFitOptions += NewGFOptionCALC_RESIDS
	endif
	
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_DoDestLogSpacingCheck
	if (V_value)
		curveFitOptions += NewGFOptionLOG_DEST_WAVE
	endif
	
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_Quiet
	if (V_value)
		curveFitOptions += NewGFOptionQUIET
	endif

	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_FitProgressGraphCheckBox
	if (V_value)
		curveFitOptions += NewGFOptionFIT_GRAPH
	endif
	
	NVAR maxIters = root:Packages:NewGlobalFit:NewGF_MaxIters
	
	ControlInfo/W=NewGlobalFitPanel#NewGF_GlobalControlArea NewGF_ResultNamePrefix
	String prefix = S_Value
	
	String resultDF = PopupWS_GetSelectionFullPath("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector")
	if (!DataFolderExists(resultDF))
		resultDF = ""
	endif
	
	Variable err = DoNewGlobalFit(FitFuncNames, DataSets, LinkageMatrix, coefWave, CoefNames, ConstraintWave, curveFitOptions, FitCurvePoints, 1, maxIters=maxIters, resultWavePrefix=prefix, resultDF=resultDF)

	if (!err)
		SetCoefListFromWave(coefWave, 2, 0, 0)
	endif
end

static Function/S MakeHoldString(CoefWave, quiet, justTheString)
	Wave CoefWave
	Variable quiet
	Variable justTheString
	
	String HS=""

	Variable HoldCol = FindDimLabel(CoefWave, 1, "Hold")
	Variable nHolds = 0
	if (HoldCol > 0)
		if (!justTheString)
			HS="/H=\""
		endif
		Variable nCoefs=DimSize(CoefWave, 0)
		Variable i
		for (i = 0; i < nCoefs; i += 1)
			if (CoefWave[i][HoldCol])
				HS += "1"
				nHolds += 1
			else
				HS += "0"
			endif
		endfor
		if (nHolds == 0)
			return ""			// ******** EXIT ***********
		endif
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
		if (!justTheString)
			HS += "\""
		endif
//		if (!quiet)
//			print "Hold String=", HS
//		endif
		return HS				// ******** EXIT ***********
	else
		return ""				// ******** EXIT ***********
	endif
end

//***********************************
//
// Constraints
//
//***********************************

static Function ConstraintsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Variable NumSets = DimSize(ListWave, 0)
	Variable i

	if (checked)
		if (NumSets == 0)
			CheckBox NewGF_ConstraintsCheckBox, win=GlobalFitPanel, value=0
			DoAlert 0, "You cannot add constraints until you have selected data sets"
			return 0
		else
			NVAR/Z NewGF_RebuildCoefListNow = root:Packages:NewGlobalFit:NewGF_RebuildCoefListNow
			if (!NVAR_Exists(NewGF_RebuildCoefListNow) || NewGF_RebuildCoefListNow)
				NewGF_RebuildCoefListWave()
			endif
			Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
			if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
				WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
				Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
			endif
			Variable totalParams = 0
			Variable CoefSize = DimSize(CoefListWave, 0)
			for (i = 0; i < CoefSize; i += 1)
				if (!IsLinkText(CoefListWave[i][1]))
					totalParams += 1
				endif
			endfor

			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:NewGlobalFit
			
			Wave/T/Z SimpleConstraintsListWave
			if (!(WaveExists(SimpleConstraintsListWave) && (DimSize(SimpleConstraintsListWave, 0) == TotalParams)))
				Make/O/N=(TotalParams, 5)/T SimpleConstraintsListWave=""
			endif
			Variable CoefIndex = 0
			for (i = 0; i < CoefSize; i += 1)
				if (!IsLinkText(CoefListWave[i][1]))
					SimpleConstraintsListWave[CoefIndex][0] = "K"+num2istr(CoefIndex)
					SimpleConstraintsListWave[CoefIndex][1] = CoefListWave[i][1]
					SimpleConstraintsListWave[CoefIndex][3] = "< K"+num2istr(CoefIndex)+" <"
					CoefIndex += 1
				endif
			endfor
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
			
			if (WinType("NewGF_GlobalFitConstraintPanel") > 0)
				DoWindow/F NewGF_GlobalFitConstraintPanel
			else
				fNewGF_GlobalFitConstraintPanel()
			endif
		endif
	endif
End

static Function fNewGF_GlobalFitConstraintPanel()
	Variable w = 405, h = 370																	// ST: 210602 - panel size
	NewPanel/W=(340,200,340+w,200+h)/K=2/N=NewGF_GlobalFitConstraintPanel as "Fit Constraints"	// ST: 210602 - give panel a name and prevent killing
	//DoWindow/C NewGF_GlobalFitConstraintPanel
	AutoPositionWindow/M=0/E/R=NewGlobalFitPanel NewGF_GlobalFitConstraintPanel

	GroupBox SimpleConstraintsGroup,pos={5,7},size={w-10,h/2},title="Simple Constraints"
	
	Button SimpleConstraintsClearB,pos={20,25},size={140,20},proc=WM_NewGlobalFit1#SimpleConstraintsClearBProc,title="Clear List"
	
	ListBox constraintsList,pos={12,50},size={w-25,h/2-55},listwave=root:Packages:NewGlobalFit:SimpleConstraintsListWave
	ListBox constraintsList,selWave=root:Packages:NewGlobalFit:SimpleConstraintsSelectionWave, mode=7
	ListBox constraintsList,widths={30,189,50,40,50}, editStyle= 1,frame=2,userColumnResize=1

	GroupBox AdditionalConstraintsGroup,pos={5,h/2+10},size={w-10,h/2-45},title="Additional Constraints"
	
	ListBox moreConstraintsList,pos={12,h/2+55},size={w-25,h/2-100}, listwave=root:Packages:NewGlobalFit:MoreConstraintsListWave
	ListBox moreConstraintsList,selWave=root:Packages:NewGlobalFit:MoreConstraintsSelectionWave, mode=4
	ListBox moreConstraintsList,editStyle= 1,frame=2,userColumnResize=1
	
	Button NewConstraintLineButton,pos={20,h/2+30},size={140,20},title="Add a Line", proc=WM_NewGlobalFit1#NewGF_NewCnstrntLineButtonProc
	Button RemoveConstraintLineButton01,pos={w-160,h/2+30},size={140,20},title="Remove Selection", proc=WM_NewGlobalFit1#RemoveConstraintLineButtonProc

	Button GlobalFitConstraintsDoneB,pos={12,h-30},size={50,20},proc=WM_NewGlobalFit1#GlobalFitConstraintsDoneBProc,title="Done"
	
	Variable pnt = PanelResolution("NewGF_GlobalFitConstraintPanel")/ScreenResolution
	SetWindow NewGF_GlobalFitConstraintPanel sizeLimit={w*pnt, h*pnt, Inf, Inf}							// ST: 210602 - limit panel size
	SetWindow NewGF_GlobalFitConstraintPanel, hook(NewGF_Resize) = NewGF_ConstraintsPanelHook			// ST: 210602 - add a resize hook
End

Function NewGF_ConstraintsPanelHook(s)
	STRUCT WMWinHookStruct &s
	strswitch (s.eventName)
		case "resize":
			Variable w = s.winRect.right-s.winRect.left, h = s.winRect.bottom-s.winRect.top
			GroupBox SimpleConstraintsGroup		,pos={5,7}			,size={w-10,h/2}
			ListBox constraintsList				,pos={12,50}		,size={w-25,h/2-55}
			GroupBox AdditionalConstraintsGroup	,pos={5,h/2+10}		,size={w-10,h/2-45}
			ListBox moreConstraintsList			,pos={12,h/2+55}	,size={w-25,h/2-100}
			Button NewConstraintLineButton		,pos={20,h/2+30}	,size={140,20}
			Button RemoveConstraintLineButton01	,pos={w-160,h/2+30}	,size={140,20}
			Button GlobalFitConstraintsDoneB	,pos={12,h-30}		,size={50,20}
		break
	endswitch
	return 0
End

static Function SimpleConstraintsClearBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T SimpleConstraintsListWave = root:Packages:NewGlobalFit:SimpleConstraintsListWave
	SimpleConstraintsListWave[][2] = ""
	SimpleConstraintsListWave[][4] = ""
End

static Function NewGF_NewCnstrntLineButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = root:Packages:NewGlobalFit:MoreConstraintsListWave
	Wave/Z MoreConstraintsSelectionWave = root:Packages:NewGlobalFit:MoreConstraintsSelectionWave
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	InsertPoints nRows, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
	MoreConstraintsListWave[nRows] = ""
	MoreConstraintsSelectionWave[nRows] = 6
	Redimension/N=(nRows+1,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

static Function RemoveConstraintLineButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = root:Packages:NewGlobalFit:MoreConstraintsListWave
	Wave/Z MoreConstraintsSelectionWave = root:Packages:NewGlobalFit:MoreConstraintsSelectionWave
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


static Function GlobalFitConstraintsDoneBProc(ctrlName) : ButtonControl
	String ctrlName
	
	Wave/Z/T MoreConstrW = root:Packages:NewGlobalFit:MoreConstraintsListWave
	Wave/Z/T SimpleConstrW = root:Packages:NewGlobalFit:SimpleConstraintsListWave
	String all = ""
	Variable i
	for (i=0; i<DimSize(MoreConstrW,0); i++)
		all += MoreConstrW[i]
	endfor
	for (i=0; i<DimSize(SimpleConstrW,0); i++)
		all += SimpleConstrW[i][2] + SimpleConstrW[i][4]
	endfor
	if (!strlen(all))							// if all entries are empty automatically disable checkbox
		CheckBox NewGF_ConstraintsCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
	endif
	
	DoWindow/K NewGF_GlobalFitConstraintPanel
End

static Function NewGF_MakeConstraintWave()

	Wave/Z/T SimpleConstraintsListWave = root:Packages:NewGlobalFit:SimpleConstraintsListWave
	Wave/Z/T MoreConstraintsListWave = root:Packages:NewGlobalFit:MoreConstraintsListWave
	
	Make/O/T/N=0 root:Packages:NewGlobalFit:GFUI_GlobalFitConstraintWave
	Wave/T GlobalFitConstraintWave = root:Packages:NewGlobalFit:GFUI_GlobalFitConstraintWave
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

static Function NewGF_WeightingCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if (checked)
		Wave/T ListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
		Variable numSets = DimSize(ListWave, 0)

		if (NumSets == 0)
			CheckBox NewGF_WeightingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
			DoAlert 0, "You cannot choose weighting waves until you have selected data sets."
			return 0
		else
			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:NewGlobalFit
			
			Wave/T/Z WeightingListWave
			if (!(WaveExists(WeightingListWave) && (DimSize(WeightingListWave, 0) == NumSets)))
				Make/O/N=(NumSets, 2)/T WeightingListWave=""
			endif
			WeightingListWave[][0] = ListWave[p][0][1]
			Make/O/N=(NumSets, 2) WeightingSelectionWave
			WeightingSelectionWave[][0] = 0		// Data Sets
			WeightingSelectionWave[][1] = 0		// Weighting Waves; not editable- select from menu
			WeightingSelectionWave[0][1] = 1	// ST: 210615 - have the first entry selected for a start
			SetDimLabel 1, 0, 'Data Set', WeightingListWave
			SetDimLabel 1, 1, 'Weight Wave', WeightingListWave
			
			SetDatafolder $saveDF
			
			if (WinType("NewGF_WeightingPanel") > 0)
				DoWindow/F NewGF_WeightingPanel
			else
				fNewGF_WeightingPanel()
			endif
			
			Variable/G root:Packages:NewGlobalFit:GlobalFit_WeightsAreSD = NumVarOrDefault("root:Packages:NewGlobalFit:GlobalFit_WeightsAreSD", 1)
			NVAR GlobalFit_WeightsAreSD = root:Packages:NewGlobalFit:GlobalFit_WeightsAreSD
			if (GlobalFit_WeightsAreSD)
				WeightsSDRadioProc("WeightsSDRadio",1)
			else
				WeightsSDRadioProc("WeightsInvSDRadio",1)
			endif
						
		endif
	endif	
end

static Function fNewGF_WeightingPanel() : Panel
	Variable w = 445, h = 215																	// ST: 210602 - panel size
	NewPanel/W=(340,200,340+w,200+h)/K=2/N=NewGF_WeightingPanel as "Data Weighting"				// ST: 210602 - give panel a name and prevent killing
	//DoWindow/C NewGF_WeightingPanel
	AutoPositionWindow/M=0/E/R=NewGlobalFitPanel NewGF_WeightingPanel
	
	ListBox WeightWaveListBox,pos={9,63},size={w-18,h-103}, mode=10, listWave = root:Packages:NewGlobalFit:WeightingListWave,userColumnResize=1
	ListBox WeightWaveListBox,selWave = root:Packages:NewGlobalFit:WeightingSelectionWave, frame=2,proc=WM_NewGlobalFit1#NewGF_WeightListProc

	Button GlobalFitWeightDoneButton,pos={25,h-30},size={50,20},proc=WM_NewGlobalFit1#GlobalFitWeightDoneButtonProc,title="Done"
	Button GlobalFitWeightCancelButton,pos={w-75,h-30},size={50,20},proc=WM_NewGlobalFit1#GlobalFitWeightCancelButtonProc,title="Cancel"

	//PopupMenu GlobalFitWeightWaveMenu,pos={11,25},size={152,20},title="Select Weight Wave"		// ST: 210602 - adjust position
	//PopupMenu GlobalFitWeightWaveMenu,mode=0,value= #"WM_NewGlobalFit1#ListPossibleWeightWaves()", proc=WM_NewGlobalFit1#WeightWaveSelectionMenu

	Button GlobalFitWeightWaveSelector,pos={11,25},size={170,20},title="Select Weight Wave"			// ST: 210607 - selector widget button
	MakeButtonIntoWSPopupButton("NewGF_WeightingPanel", "GlobalFitWeightWaveSelector", "NewGF_SubPanelSelectorNotify", options=PopupWS_OptionTitleInTitle)
	PopupWS_MatchOptions("NewGF_WeightingPanel", "GlobalFitWeightWaveSelector", nameFilterProc="NewGF_WeightWaveSelectorFilter")

	Button WeightClearSelectionButton,pos={w-130,7},size={120,20},proc=WM_NewGlobalFit1#WeightClearSelectionButtonProc,title="Clear Selection"		// ST: 210607 - added clear buttons
	Button WeightClearAllButton,pos={w-130,35},size={120,20},proc=WM_NewGlobalFit1#WeightClearSelectionButtonProc,title="Clear All"

	GroupBox WeightStdDevRadioGroup,pos={200,4},size={95,54},title="Weights are"

	CheckBox WeightsSDRadio,pos={210,22},size={60,14},proc=WM_NewGlobalFit1#WeightsSDRadioProc,title="Std. Dev."
	CheckBox WeightsSDRadio,value= 0, mode=1
	CheckBox WeightsInvSDRadio,pos={210,38},size={73,14},proc=WM_NewGlobalFit1#WeightsSDRadioProc,title="1/Std. Dev."
	CheckBox WeightsInvSDRadio,value= 0, mode=1
	
	Variable pnt = PanelResolution("NewGF_WeightingPanel")/ScreenResolution
	SetWindow NewGF_WeightingPanel sizeLimit={w*pnt, h*pnt, Inf, Inf}							// ST: 210602 - limit panel size
	SetWindow NewGF_WeightingPanel, hook(NewGF_Resize) = NewGF_WeightPanelHook					// ST: 210602 - add a resize hook
End

Function NewGF_WeightPanelHook(s)
	STRUCT WMWinHookStruct &s
	strswitch (s.eventName)
		case "resize":
			Variable w = s.winRect.right-s.winRect.left, h = s.winRect.bottom-s.winRect.top
			ListBox WeightWaveListBox 			,win=$(s.winName)	,pos={9,63} 		,size={w-18,h-103}
			Button GlobalFitWeightDoneButton	,win=$(s.winName)	,pos={25,h-30}		,size={50,20}
			Button GlobalFitWeightCancelButton	,win=$(s.winName)	,pos={w-75,h-30}	,size={50,20}
			Button WeightClearSelectionButton	,win=$(s.winName)	,pos={w-130,7}		,size={120,20}
			Button WeightClearAllButton			,win=$(s.winName)	,pos={w-130,35}		,size={120,20}
		break
	endswitch
	return 0
End

static Function NewGF_WeightListProc(s) : ListBoxControl										// ST: 210607 - switched to struct based control (will catch mouse clicks in normal rows as well)
	STRUCT WMListboxAction &s

	if (s.eventCode == 1)
		Wave/T/Z WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
		Variable NumSets = DimSize(WeightingListWave, 0)
		if ( (s.row == -1) && (s.col == 1) )
			Wave WeightingSelWave = root:Packages:NewGlobalFit:WeightingSelectionWave
			WeightingSelWave[][1] = 1
		elseif ( (s.col == 1) && (s.row >= 0) && (s.row < NumSets) )
			if (GetKeyState(0) == 0)
				Wave/Z w = $(WeightingListWave[s.row][0])
				if (WaveExists(w))
					String AvaiableWaves = WaveList("*",";","MINROWS:"+num2str(DimSize(w, 0))+",MAXROWS:"+num2str(DimSize(w, 0))+",DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
					if (strlen(AvaiableWaves))
						PopupContextualMenu AvaiableWaves										// ST: 210607 - present wave list from current folder
						if (V_flag > 0)
							Wave/Z w = $S_selection
							if (WaveExists(w))
								WeightingListWave[s.row][1] = GetWavesDataFolder(w, 2)
							endif
						endif
					endif
				endif
			endif
		endif
	endif 
end

static Function GlobalFitWeightDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
	Variable NumSets = DimSize(WeightingListWave, 0)
	
	Variable i, emptyRow = 0
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(WeightingListWave[i][1])
		if (!WaveExists(w))
			if (strlen(WeightingListWave[i][1]) != 0)						// ST: 210607 - make sure there is only a warning if something was inserted.
				ListBox WeightWaveListBox, win=NewGF_WeightingPanel, selRow = i
				DoAlert 0, "The wave \""+WeightingListWave[i][1]+"\" does not exist."
				WeightingListWave[i][1] = ""
				return -1
			else
				emptyRow++
			endif
		endif
	endfor
	if (emptyRow == NumSets)												// ST: 210607 - some rows are empty => undo checkbox
		CheckBox NewGF_WeightingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
	endif
	// if (emptyRow > 0)
		// CheckBox NewGF_WeightingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
		// if (emptyRow < NumSets)
			// DoAlert 0, "Some datasets have no weight wave assigned. Make sure to assign a valid weight wave to all sets."
		// endif
	// endif
		
	DoWindow/K NewGF_WeightingPanel
End

static Function GlobalFitWeightCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K NewGF_WeightingPanel
	CheckBox NewGF_WeightingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
End

static Function/S ListPossibleWeightWaves()

	Wave/T/Z WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
	Wave/Z WeightingSelectionWave=root:Packages:NewGlobalFit:WeightingSelectionWave

	String DataSetName=""
	Variable i
	
	ControlInfo/W=NewGF_WeightingPanel WeightWaveListBox
	DataSetName = WeightingListWave[V_value][0]
	
	if (strlen(DataSetName) == 0)
		return "No Selection;"
	endif
	
	Wave/Z ds = $DataSetName
	if (!WaveExists(ds))
		return "Bad Data Set:"+DataSetName+";"
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

static Function WeightWaveSelectionMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/Z w = $popStr
	if (WaveExists(w))
		Wave/T WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
		Wave WeightingSelWave = root:Packages:NewGlobalFit:WeightingSelectionWave
		Variable nrows = DimSize(WeightingListWave, 0)
		Variable i
		for (i = 0; i < nrows; i += 1)
			if ( (WeightingSelWave[i][0] & 1) || (WeightingSelWave[i][1]) )
				WeightingListWave[i][1] = GetWavesDatafolder(w, 2)
			endif
		endfor
	endif
end

Function NewGF_SubPanelSelectorNotify(event, selectionStr, windowName, ctrlName)		// ST: 210607 - call function for wave selector
	Variable event
	String selectionStr
	String windowName
	String ctrlName

	String buttonLabel = ""
	if (CmpStr(windowName,"NewGF_GlobalFitMaskingPanel") == 0)
		Wave/T/Z ListWave = root:Packages:NewGlobalFit:MaskingListWave
		Wave/Z SelWave = root:Packages:NewGlobalFit:MaskingSelectionWave
		buttonLabel = "Select Mask Wave"
	elseif (CmpStr(windowName,"NewGF_WeightingPanel") == 0)
		Wave/T ListWave = root:Packages:NewGlobalFit:WeightingListWave
		Wave SelWave = root:Packages:NewGlobalFit:WeightingSelectionWave
		buttonLabel = "Select Weight Wave"
	else
		return -1
	endif
	
	Variable i, wroteEntry = 0
	String mismatchList = ""
	Wave/Z w = $selectionStr
	if (WaveExists(w))
		for (i = 0; i < DimSize(ListWave, 0); i += 1)
			if ( (SelWave[i][0] & 1) || (SelWave[i][1]) )
				Wave/Z ds = $ListWave[i][0]
				if (WaveExists(ds))
					if ((DimSize(w, 0) != DimSize(ds, 0)))
						mismatchList += NameOfWave(ds)+", "
						continue
					endif
				endif
				ListWave[i][1] = GetWavesDatafolder(w, 2)
				wroteEntry = 1
			endif
		endfor
	endif
	if (event == 4)														// ST: 210607 - do error reports on selection event
		if (!wroteEntry)
			DoAlert 0, "Could not find suitable entry here. Make sure to select the correct data set in the list first and then choose an appropriate wave from the folders."
		endif
		if (strlen(mismatchList))
			DoAlert 0, "There was a size mismatch for the waves "+RemoveEnding(mismatchList,", ")+" with the selected weight wave "+NameOfWave(w)+". Both the data wave and the weight wave need to have the same size."
		endif
	endif

	return 0
end

Function NewGF_WeightWaveSelectorFilter(aName, contents)				// ST: 210607 - wave selector filter function for weight waves
	String aName
	Variable contents
	
	Wave/T/Z ListWave=root:Packages:NewGlobalFit:WeightingListWave
	Wave/Z SelWave=root:Packages:NewGlobalFit:WeightingSelectionWave
	return WM_NewGlobalFit1#NewGF_SelectorFilterWorker(aName, SelWave, ListWave)
End

Function NewGF_MaskWaveSelectorFilter(aName, contents)					// ST: 210607 - wave selector filter function for mask waves
	String aName
	Variable contents
	
	Wave/T/Z ListWave=root:Packages:NewGlobalFit:MaskingListWave
	Wave/Z SelWave=root:Packages:NewGlobalFit:MaskingSelectionWave
	return WM_NewGlobalFit1#NewGF_SelectorFilterWorker(aName, SelWave, ListWave)
End

static Function NewGF_SelectorFilterWorker(aName, SelWave, ListWave)
	String aName
	Wave SelWave
	Wave/T ListWave
	
	Variable i
	for (i = 0; i<DimSize(SelWave,0); i++)								// find wave selection
		if(SelWave[i][0] == 1 || SelWave[i][1] == 1)
			break
		endif
	endfor
	if (i >= DimSize(SelWave,0))
		return 0
	endif
	
	Wave/Z ds = $ListWave[i][0]
	if (!WaveExists(ds))
		return 0
	endif

	Wave/Z w = $aName
	if (!WaveExists(w))
		return 0
	endif
	
	if ( (DimSize(w, 0) == DimSize(ds, 0)) && (WaveType(w) & 6) )		// select floating-point waves with the right number of points
		return 1
	endif

	return 0
End

static Function WeightClearSelectionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
	StrSwitch (ctrlName)
		case "WeightClearSelectionButton":
			Wave WeightingSelWave = root:Packages:NewGlobalFit:WeightingSelectionWave
			Variable nrows = DimSize(WeightingListWave, 0)
			Variable i
			for (i = 0; i < nrows; i += 1)
				if ( (WeightingSelWave[i][0] & 1) || (WeightingSelWave[i][1]) )
					WeightingListWave[i][1] = ""
				endif
			endfor
			break;
		case "WeightClearAllButton":
			WeightingListWave[][1] = ""
			break;
	endswitch
End

static Function WeightsSDRadioProc(name,value)
	String name
	Variable value
	
	NVAR GlobalFit_WeightsAreSD= root:Packages:NewGlobalFit:GlobalFit_WeightsAreSD
	
	strswitch (name)
		case "WeightsSDRadio":
			GlobalFit_WeightsAreSD = 1
			break
		case "WeightsInvSDRadio":
			GlobalFit_WeightsAreSD = 0
			break
	endswitch
	CheckBox WeightsSDRadio, win=NewGF_WeightingPanel, value= GlobalFit_WeightsAreSD==1
	CheckBox WeightsInvSDRadio, win=NewGF_WeightingPanel, value= GlobalFit_WeightsAreSD==0
End

// This function is strictly for the use of the Global Analysis control panel. It assumes that the DataSets
// wave so far has just two columns, the Y and X wave columns
static Function GFUI_AddWeightWavesToDataSets(DataSets)
	Wave/T DataSets
	
	Wave/T/Z WeightingListWave=root:Packages:NewGlobalFit:WeightingListWave
	
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
			if (!strlen(WeightingListWave[i][1]))						// ST: 210615 - if the weight wave entry is empty just omit later
				DataSets[i][2] = WeightingListWave[i][1]
			else
				Redimension/N=(-1,2) DataSets
				DoAlert 0,"The weighting wave \""+WeightingListWave[i][1]+"\" for Y wave \""+(DataSets[i][0])+"\" does not exist."
				return -1
			endif
		endif
	endfor
	
	return 0
end

static Function GFUI_AddMaskWavesToDataSets(DataSets)
	Wave/T DataSets
	
	Wave/T/Z MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
	
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
			if (!strlen(MaskingListWave[i][1]))						// ST: 210615 - if the mask wave entry is empty just omit later
				DataSets[i][startingNCols] = MaskingListWave[i][1]
			else
				Redimension/N=(-1,startingNCols) DataSets
				DoAlert 0,"The mask wave \""+MaskingListWave[i][1]+"\" for Y wave \""+(DataSets[i][0])+"\" does not exist."
				return -1
			endif
		endif
	endfor
	
	return 0
end


static Function NewGF_CovMatrixCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (!checked)
		Checkbox NewGF_CorrelationMatrixCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=0
	endif
End

static Function NewGF_CorMatrixCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (checked)
		Checkbox NewGF_DoCovarMatrix, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=1
	endif
End


static Function NewGF_FitCurvesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (!checked)
		Checkbox NewGF_AppendResultsCheckbox, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=0
		Checkbox NewGF_DoResidualCheck, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=0
	endif
End

static Function NewGF_AppendResultsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (checked)
		Checkbox NewGF_MakeFitCurvesCheck, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=1
	endif
End

static Function NewGF_CalcResidualsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if (checked)
		Checkbox NewGF_MakeFitCurvesCheck, win=NewGlobalFitPanel#NewGF_GlobalControlArea,value=1
	endif
End


//***********************************
//
// Data masking
//
//***********************************

static Function NewGF_MaskingCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if (checked)
		Wave/T DataSetList = root:Packages:NewGlobalFit:NewGF_DataSetListWave
		Variable numSets = DimSize(DataSetList, 0)

		if (NumSets == 0)
			CheckBox NewGF_MaskingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
			DoAlert 0, "You cannot add Masking waves until you have selected data sets."
			return 0
		else
			String saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:NewGlobalFit
			
			Wave/T/Z MaskingListWave
			if (!(WaveExists(MaskingListWave) && (DimSize(MaskingListWave, 0) == NumSets)))
				Make/O/N=(NumSets, 2)/T MaskingListWave=""
			endif
			MaskingListWave[][0] = DataSetList[p][0][1]
			Make/O/N=(NumSets, 2) MaskingSelectionWave
			MaskingSelectionWave[][0] = 0		// Data Sets
			MaskingSelectionWave[][1] = 0		// Masking Waves; not editable- select from menu
			MaskingSelectionWave[0][1] = 1		// ST: 210615 - have the first entry selected for a start
			SetDimLabel 1, 0, 'Data Set', MaskingListWave
			SetDimLabel 1, 1, 'Mask Wave', MaskingListWave
			
			SetDatafolder $saveDF
			
			if (WinType("NewGF_GlobalFitMaskingPanel") > 0)
				DoWindow/F NewGF_GlobalFitMaskingPanel
			else
				fNewGF_GlobalFitMaskingPanel()
			endif
		endif
	endif	
end

static Function fNewGF_GlobalFitMaskingPanel() : Panel
	Variable w = 405, h = 215																	// ST: 210602 - panel size
	NewPanel/W=(340,200,340+w,200+h)/K=2/N=NewGF_GlobalFitMaskingPanel as "Data Masking"		// ST: 210602 - give panel a name and prevent killing
	//DoWindow/C NewGF_GlobalFitMaskingPanel
	AutoPositionWindow/M=0/E/R=NewGlobalFitPanel NewGF_GlobalFitMaskingPanel
	
	ListBox MaskWaveListBox,pos={9,63},size={w-18,h-103}, mode=10, listWave = root:Packages:NewGlobalFit:MaskingListWave,userColumnResize=1
	ListBox MaskWaveListBox,selWave = root:Packages:NewGlobalFit:MaskingSelectionWave, frame=2, proc=WM_NewGlobalFit1#NewGF_MaskListProc
	
	Button GlobalFitMaskDoneButton,pos={25,h-30},size={50,20},proc=WM_NewGlobalFit1#GlobalFitMaskDoneButtonProc,title="Done"
	Button GlobalFitMaskCancelButton,pos={w-75,h-30},size={50,20},proc=WM_NewGlobalFit1#GlobalFitMaskCancelButtonProc,title="Cancel"
	
	//PopupMenu GlobalFitMaskWaveMenu,pos={11,25},size={152,20},title="Select Mask Wave"			// ST: 210602 - adjust position
	//PopupMenu GlobalFitMaskWaveMenu,mode=0,value= #"WM_NewGlobalFit1#ListPossibleMaskWaves()", proc=WM_NewGlobalFit1#MaskWaveSelectionMenu
	
	Button GlobalFitMaskWaveSelector,pos={11,25},size={152,20},title="Select Mask Wave"			// ST: 210607 - selector widget button
	MakeButtonIntoWSPopupButton("NewGF_GlobalFitMaskingPanel", "GlobalFitMaskWaveSelector", "NewGF_SubPanelSelectorNotify", options=PopupWS_OptionTitleInTitle)
	PopupWS_MatchOptions("NewGF_GlobalFitMaskingPanel", "GlobalFitMaskWaveSelector", nameFilterProc="NewGF_MaskWaveSelectorFilter")
	
	Button MaskClearSelectionButton,pos={w-130,7},size={120,20},proc=WM_NewGlobalFit1#MaskClearSelectionButtonProc,title="Clear Selection"
	Button MaskClearAllButton,pos={w-130,35},size={120,20},proc=WM_NewGlobalFit1#MaskClearSelectionButtonProc,title="Clear All"

	Variable pnt = PanelResolution("NewGF_GlobalFitMaskingPanel")/ScreenResolution
	SetWindow NewGF_GlobalFitMaskingPanel sizeLimit={w*pnt, h*pnt, Inf, Inf}					// ST: 210602 - limit panel size
	SetWindow NewGF_GlobalFitMaskingPanel, hook(NewGF_Resize) = NewGF_MaskPanelHook				// ST: 210602 - add a resize hook
End

Function NewGF_MaskPanelHook(s)
	STRUCT WMWinHookStruct &s
	strswitch (s.eventName)
		case "resize":
			Variable w = s.winRect.right-s.winRect.left, h = s.winRect.bottom-s.winRect.top
			ListBox MaskWaveListBox 			,win=$(s.winName)	,pos={9,63} 		,size={w-18,h-103}
			Button GlobalFitMaskDoneButton		,win=$(s.winName)	,pos={25,h-30}		,size={50,20}
			Button GlobalFitMaskCancelButton	,win=$(s.winName)	,pos={w-75,h-30}	,size={50,20}
			Button MaskClearSelectionButton		,win=$(s.winName)	,pos={w-130,7}		,size={120,20}
			Button MaskClearAllButton			,win=$(s.winName)	,pos={w-130,35}		,size={120,20}
		break
	endswitch
	return 0
End

static Function NewGF_MaskListProc(s) : ListBoxControl										// ST: 210607 - switched to struct based control (will catch mouse clicks in normal rows as well)
	STRUCT WMListboxAction &s
	
	if (s.eventCode == 1)
		Wave/T/Z MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
		Variable numSets = DimSize(MaskingListWave, 0)
		if ( (s.row == -1) && (s.col == 1) )
			Wave MaskingSelWave = root:Packages:NewGlobalFit:MaskingSelectionWave
			MaskingSelWave[][1] = 1
		elseif ( (s.col == 1) && (s.row >= 0) && (s.row < NumSets) )
			if (GetKeyState(0) == 0)
				Wave/Z w = $(MaskingListWave[s.row][0])
				if (WaveExists(w))
					String AvaiableWaves = WaveList("*",";","MINROWS:"+num2str(DimSize(w, 0))+",MAXROWS:"+num2str(DimSize(w, 0))+",DIMS:1,CMPLX:0,TEXT:0,BYTE:0,WORD:0,INTEGER:0")
					if (strlen(AvaiableWaves))
						PopupContextualMenu AvaiableWaves										// ST: 210607 - present wave list from current folder
						if (V_flag > 0)
							Wave/Z w = $S_selection
							if (WaveExists(w))
								MaskingListWave[s.row][1] = GetWavesDataFolder(w, 2)
							endif
						endif
					endif
				endif
			endif
		endif
	endif 
end

static Function GlobalFitMaskDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
	Variable numSets = DimSize(MaskingListWave, 0)

	Variable i, emptyRow = 0
	for (i = 0; i < NumSets; i += 1)
		Wave/Z w = $(MaskingListWave[i][1])
		if (!WaveExists(w))
			if (strlen(MaskingListWave[i][1]) != 0)
				ListBox MaskWaveListBox, win=NewGF_GlobalFitMaskingPanel, selRow = i
				DoAlert 0, "The wave \""+MaskingListWave[i][1]+"\" does not exist."
				MaskingListWave[i][1] = ""
				return -1
			else
				emptyRow++
			endif
		endif
	endfor
	if (emptyRow == NumSets)								// ST: 210607 - all rows are empty => undo checkbox
		CheckBox NewGF_MaskingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
	endif
	// if (emptyRow > 0)
		// CheckBox NewGF_MaskingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
		// if (emptyRow < NumSets)
			// DoAlert 0, "Some datasets have no mask wave assigned. Make sure to assign a valid mask wave to all sets."
		// endif
	// endif
	
	DoWindow/K NewGF_GlobalFitMaskingPanel
End

static Function GlobalFitMaskCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K NewGF_GlobalFitMaskingPanel
	CheckBox NewGF_MaskingCheckBox, win=NewGlobalFitPanel#NewGF_GlobalControlArea, value=0
End

static Function/S ListPossibleMaskWaves()

	Wave/T/Z MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
	Wave/Z MaskingSelectionWave=root:Packages:NewGlobalFit:MaskingSelectionWave
	Variable NumSets= DimSize(MaskingListWave, 0)

	String DataSetName=""
	Variable i
	
	ControlInfo/W=NewGF_GlobalFitMaskingPanel MaskWaveListBox
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

static Function MaskWaveSelectionMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/Z w = $popStr
	if (WaveExists(w))
		Wave/T MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
		Wave MaskingSelWave = root:Packages:NewGlobalFit:MaskingSelectionWave
		Variable nrows = DimSize(MaskingListWave, 0)
		Variable i
		for (i = 0; i < nrows; i += 1)
			if ( (MaskingSelWave[i][0] & 1) || (MaskingSelWave[i][1]) )
				MaskingListWave[i][1] = GetWavesDatafolder(w, 2)
			endif
		endfor
	endif
end

static Function MaskClearSelectionButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/T/Z MaskingListWave=root:Packages:NewGlobalFit:MaskingListWave
	StrSwitch (ctrlName)
		case "MaskClearSelectionButton":
			Wave MaskingSelWave = root:Packages:NewGlobalFit:MaskingSelectionWave
			Variable nrows = DimSize(MaskingListWave, 0)
			Variable i
			for (i = 0; i < nrows; i += 1)
				if ( (MaskingSelWave[i][0] & 1) || (MaskingSelWave[i][1]) )
					MaskingListWave[i][1] = ""
				endif
			endfor
			break;
		case "MaskClearAllButton":
			MaskingListWave[][1] = ""
			break;
	endswitch
End



//***********************************
//
// Load/Save initial guesses from/to a wave
//
//***********************************

Function/S NewGF_ListInitGuessWaves(SelectedOnly, LinkRowsOK)
	Variable SelectedOnly
	Variable LinkRowsOK

	Variable numrows
//	ControlInfo/W=NewGlobalFitPanel#Tab1ContentPanel NewGF_InitGuessCopySelCheck
	if (SelectedOnly)
		numrows = totalSelRealCoefsFromCoefList(LinkRowsOK)
	else
		numrows = totalRealCoefsFromCoefList(LinkRowsOK)
	endif
	
	String numrowsstr = num2str(numrows)
	return WaveList("*", ";", "DIMS:1,MINROWS:"+numrowsstr+",MAXROWS:"+numrowsstr+",BYTE:0,INTEGER:0,WORD:0,CMPLX:0,TEXT:0")
end

char ctrlName[MAX_OBJ_NAME+1]	Control name.
char win[MAX_WIN_PATH+1]	Host (sub)window.
STRUCT Rect winRect	Local coordinates of host window.
STRUCT Rect ctrlRect	Enclosing rectangle of the control.
STRUCT Point mouseLoc	Mouse location.
Int32 eventCode	Event that caused the procedure to execute. Main event is mouse up=2.
String userdata	Primary (unnamed) user data. If this changes, it is written back automatically.
Int32 popNum	Item number currently selected (1-based).
char popStr[MAXCMDLEN]	Contents of current popup item.

Function NewGF_SetCoefsFromWaveProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)			// mouse up
		Wave w = $(PU_Struct.popStr)
		if (!WaveExists(w))
			DoAlert 0, "The wave you selected does not exist for some reason."
			return 0
		endif
		
		SetCoefListFromWave(w, 2, 0, 0)
	endif
end

Function NewGF_SaveCoefsToWaveProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)			// mouse up
		if (CmpStr(PU_Struct.popStr, "New Wave...") == 0)
			Variable numRowsNeeded = totalRealCoefsFromCoefList(0)
			String newName = NewGF_GetNewWaveName()
			if (strlen(newName) == 0)
				return 0
			endif
			Make/O/N=(numRowsNeeded)/D $newName
			Wave w = $newName
		else
			Wave w = $(PU_Struct.popStr)
		endif
		
		SaveCoefListToWave(w, 2, 0, 0)
	endif
end

Function/S NewGF_GetNewWaveName()

	String newName
	Prompt newName, "Enter a name for the new wave:"
	DoPrompt "Get New Wave Name", newName
	if (V_flag)
		return ""
	endif
	
	return newName
end

//***********************************
//
// Make new data folder
//
//***********************************

Function NewGF_ResultsDFSelectorNotify(event, selectionStr, windowName, ctrlName)
	Variable event
	String selectionStr
	String windowName
	String ctrlName

	if (CmpStr(selectionStr, NewGF_NewDFMenuString) == 0)
		if (WinType("NewGF_GetNewDFNamePanel") == 7)
			Execute/P/Q "DoWindow/F NewGF_GetNewDFNamePanel"
		else
			Execute/P/Q "WM_NewGlobalFit1#buildNewGF_GetNewDFNamePanel()"
		endif
		PopupWS_SetSelectionFullPath("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", GetUserData("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", "NewGF_SavedSelection"))
	else
		Button $ctrlName, win=$windowName,UserData(NewGF_SavedSelection)=selectionStr
	endif
end

Function buildNewGF_GetNewDFNamePanel()
	if (WinType("NewGF_GetNewDFNamePanel") == 7)											// ST: 210603 - prevent creation of multiple panels
		DoWindow/F NewGF_GetNewDFNamePanel
		return 0
	endif
	NewPanel/K=1/W=(400,100,685,330)/N=NewGF_GetNewDFNamePanel as "Create New Data Folder"	// ST: 210603 - more descriptive name				
	Variable pnt = PanelResolution("NewGF_GetNewDFNamePanel")/ScreenResolution
	SetWindow NewGF_GetNewDFNamePanel sizeLimit={285*pnt, 230*pnt, Inf, 230*pnt}			// ST: 210603 - minimal size limit and more tight control placement
	
	TitleBox NewGF_CDFTitle,pos={15.00,8.00},size={106.00,15.00},title="Current Data Folder:"
	TitleBox NewGF_CDFTitle,fSize=12,frame=0

	TitleBox NewGF_NewDFCDFTitle,pos={15.00,28.00},size={33.00,23.00},title=GetDataFolder(1)
	TitleBox NewGF_NewDFCDFTitle,fSize=12,frame=1,labelBack=(65535,65535,65535)				// ST: 210603 - more distinctive style
	
	Button NewGF_NewDFSelectParentDF,pos={15.00,83.00},size={255.00,20.00}
	MakeButtonIntoWSPopupButton("NewGF_GetNewDFNamePanel", "NewGF_NewDFSelectParentDF", "" , initialSelection=RemoveEnding(GetDataFolder(1)), content=WMWS_DataFolders)

	TitleBox NewGF_ParentDFTitle,pos={15.00,63.00},size={100.00,15.00},title="Parent Data Folder:"
	TitleBox NewGF_ParentDFTitle,fSize=12,frame=0
	
	SetVariable NewGF_NewDFSetFolderName,pos={15.00,138.00},size={255.00,18.00},bodyWidth=255,proc=NewDFSetFolderNameProc
	SetVariable NewGF_NewDFSetFolderName,fSize=12,value= _STR:"GF_results"					// ST: 210603 - preset a folder name suggestion
	
	TitleBox NewGF_NewDFTitle,pos={15.00,118.00},size={125.00,15.00},title="New Data Folder Name:"
	TitleBox NewGF_NewDFTitle,fSize=12,frame=0
	
	Button NewGF_NewDFOKButton,pos={70.00,163.00},size={150.00,20.00},proc=NewGF_NewDFOKButtonProc,title="Make Data Folder"
	
	Button NewGF_NewDFDoneButton,pos={95.00,198.00},size={100.00,20.00},proc=NewGF_NewDFDoneButtonProc,title="Done"
end

Function NewGF_NewDFOKButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ParentDFName = PopupWS_GetSelectionFullPath("NewGF_GetNewDFNamePanel", "NewGF_NewDFSelectParentDF") + ":"
	String saveDF = GetDataFolder(1)
	SetDataFolder ParentDFName
	ControlInfo/W=NewGF_GetNewDFNamePanel NewGF_NewDFSetFolderName
	String newDFName = S_value
	if (!strlen(newDFName))			// ST: 210603 - abort on empty folder string
		Abort "Folder name is empty!"
	endif
	NewDataFolder/O $newDFName
	SetDataFolder saveDF
	
	PopupWS_SetSelectionFullPath("NewGlobalFitPanel#NewGF_GlobalControlArea", "NewGF_ResultsDFSelector", ParentDFName+PossiblyQuoteName(newDFName))
	Button NewGF_ResultsDFSelector, win=NewGlobalFitPanel#NewGF_GlobalControlArea,UserData(NewGF_SavedSelection)=ParentDFName+PossiblyQuoteName(newDFName)
End

Function NewGF_NewDFDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K NewGF_GetNewDFNamePanel
End

Function NewDFSetFolderNameProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String sval = sva.sval
			if ( (strlen(sval) > 0) && (CmpStr(sval, CleanupName(sval, 1)) == 0) )
				Button NewGF_NewDFOKButton, win=$(sva.win), disable=0
			else
				Button NewGF_NewDFOKButton, win=$(sva.win), disable=2
			endif
			break
	endswitch

	return 0
End

//***********************************
//
// Data Wave Selector
//
//***********************************

Function BuildDataSetSelector()

	if (WinType("NewGF_SelectDataSetsPanel") == 7)
		DoWindow/F NewGF_SelectDataSetsPanel
		return 0
	endif
	
	Make/O/N=(0,2)/T root:Packages:NewGlobalFit:SelectedDataSetsListWave/WAVE=SelectedDataSetsListWave
	Make/O/N=(0,2) root:Packages:NewGlobalFit:SelectedDataSetsSelWave/WAVE=SelectedDataSetsSelWave
	SetDimLabel 1,0,'Y waves',SelectedDataSetsListWave
	SetDimLabel 1,1,'X waves',SelectedDataSetsListWave
	
	Wave/T DataSetListWave = root:Packages:NewGlobalFit:NewGF_DataSetListWave
	Variable nrows = DimSize(DataSetListWave, 0)
	if ( (nrows == 1) && AllFieldsAreBlank(DataSetListWave, 0))
		nrows = 0
	endif
	if (nrows > 0)
		Redimension/N=(nrows, 2) SelectedDataSetsListWave, SelectedDataSetsSelWave
		SelectedDataSetsListWave[][] = DataSetListWave[p][q][1]		// layer 1 contains full paths
	endif

	Variable left	= 300
	Variable top	= 300
	Variable width	= 620
	Variable height	= 470
	
	NewPanel/W=(left,top,left+width,top+height)/K=1/N=NewGF_SelectDataSetsPanel as "Add/Remove Data Sets"
	ModifyPanel/W=NewGF_SelectDataSetsPanel fixedSize=1
	
	CheckBox DataSets_FromTargetCheck		,pos={270.00,12.00}		,size={81.00,15.00}		,title="From Target"
	
	TitleBox SelectData_YWavesTitle			,pos={95.00,10.00}		,size={100.00,20.00}	,title="Select Y Waves"
	ListBox NewGF_SelectDataSetsYSelector	,pos={15.00,35.00}		,size={260.00,180.00}
	PopupMenu NewData_YListSortMenu			,pos={15.00,220.00}		,size={19.00,19.00}
	SetVariable DataSets_YListFilterString	,pos={50.00,220.00}		,size={130.00,18.00}	,title="Filter"
	PopupMenu DataSets_YListSelectMenu		,pos={195.00,220.00}	,size={80.00,19.00}		,title="Select"
	
	TitleBox SelectData_XWavesTitle			,pos={425.00,10.00}		,size={100.00,20.00}	,title="Select X Waves"
	ListBox NewGF_SelectDataSetsXSelector	,pos={345.00,35.00}		,size={260.00,180.00}
	PopupMenu NewData_XListSortMenu			,pos={345.00,220.00}	,size={19.00,19.00}
	SetVariable DataSets_XListFilterString	,pos={380.00,220.00}	,size={130.00,18.00}	,title="Filter"
	PopupMenu DataSets_XListSelectMenu		,pos={525.00,220.00}	,size={80.00,19.00}		,title="Select"
	
	Button NewGF_SelectDataSetsArrowButt	,pos={245.00,250.00}	,size={130.00,25.00}	,title="XY Set \\f01↓\\f00"
	Button NewGF_SelectDataSetsYArrowBtn	,pos={95.00,250.00}		,size={100.00,25.00}	,title="Y wave \\f01↓\\f00"
	Button NewGF_SelectDataSetsXArrowBtn	,pos={425.00,250.00}	,size={100.00,25.00}	,title="X wave \\f01↓\\f00"
	
	ListBox NewGF_SelectedDataSetsList		,pos={15.00,280.00}		,size={590.00,150.00}
	
	GroupBox SelectData_MoverBox			,pos={165.00,435.00}	,size={200.00,32.00}
		Button SelectData_MoveUpButton		,pos={282.00,439.00}	,size={35.00,22.00}		,title="\\f01↑\\f00"
		Button SelectData_MoveDnButton		,pos={322.00,439.00}	,size={35.00,22.00}		,title="\\f01↓\\f00"
		TitleBox SelectData_MoverTitle		,pos={184.00,443.00}	,size={81.00,15.00}		,title="Move Selection"
	
	Button DataSets_SelectAll				,pos={376.00,437.00}	,size={85.00,25.00}		,title="Select \f04A\f00ll"
	Button DataSets_OKButton				,pos={20.00,437.00}		,size={100.00,25.00}	,title="OK"
	Button DataSets_CancelButton			,pos={500.00,437.00}	,size={100.00,25.00}	,title="Cancel"
	
	String SortOptions = "All;Every Other;Every Other starting with second;Every Third;Every Third starting with second;Every Third starting with third;"
	
	CheckBox DataSets_FromTargetCheck						,fSize=12	,value=0							,proc=DataSets_FromTargetCheckProc
	
	TitleBox SelectData_YWavesTitle							,fSize=14	,frame=0	,fStyle=1
	TitleBox SelectData_XWavesTitle							,fSize=14	,frame=0	,fStyle=1
	TitleBox SelectData_MoverTitle							,fSize=12	,frame=0
	
	PopupMenu NewData_YListSortMenu																			,proc=DataSets_SelectPopupMenuProc
	PopupMenu NewData_XListSortMenu																			,proc=DataSets_SelectPopupMenuProc
	PopupMenu DataSets_YListSelectMenu		,bodyWidth=80	,mode=0		,value=#("\"" + SortOptions + "\"")	,proc=DataSets_SelectPopupMenuProc
	PopupMenu DataSets_XListSelectMenu		,bodyWidth=80	,mode=0		,value=#("\"" + SortOptions + "\"")	,proc=DataSets_SelectPopupMenuProc

	SetVariable DataSets_YListFilterString	,bodyWidth=100	,fSize=12	,value=_STR:"*"						,proc=DS_SelectorFilterSetVarProc
	SetVariable DataSets_XListFilterString	,bodyWidth=100	,fSize=12	,value=_STR:"*"						,proc=DS_SelectorFilterSetVarProc
	
	ListBox NewGF_SelectedDataSetsList		,mode= 10		,editStyle= 1									,proc=NewGF_SelectedDataListBoxProc
	ListBox NewGF_SelectedDataSetsList		,listWave=SelectedDataSetsListWave		,selWave=SelectedDataSetsSelWave
	
	Button NewGF_SelectDataSetsArrowButt	,proc=SelectDataSetsArrowButtonProc
	Button NewGF_SelectDataSetsYArrowBtn	,proc=SelectDataSetsArrowButtonProc
	Button NewGF_SelectDataSetsXArrowBtn	,proc=SelectDataSetsArrowButtonProc
	Button SelectData_MoveUpButton			,proc=DataSetsMvSelectedWavesUpOrDown
	Button SelectData_MoveDnButton			,proc=DataSetsMvSelectedWavesUpOrDown
	Button DataSets_SelectAll				,proc=DataSets_SelectAllBtnProc
	Button DataSets_OKButton				,proc=DataSets_OKButtonProc
	Button DataSets_CancelButton			,proc=DataSets_CancelButtonProc
	
	MakeListIntoWaveSelector("NewGF_SelectDataSetsPanel", "NewGF_SelectDataSetsYSelector", selectionMode=WMWS_SelectionNonContiguous, listoptions="MAXCOLS:0;MAXCHUNKS:0,MAXLAYERS:0,TEXT:0,WAVE:0,DF:0,CMPLX:0")		// ST: 210607 - limit selection to 1D waves
	MakeListIntoWaveSelector("NewGF_SelectDataSetsPanel", "NewGF_SelectDataSetsXSelector", selectionMode=WMWS_SelectionNonContiguous, listoptions="MAXCOLS:0;MAXCHUNKS:0,MAXLAYERS:0,TEXT:0,WAVE:0,DF:0,CMPLX:0")
	WS_AddSelectableString("NewGF_SelectDataSetsPanel", "NewGF_SelectDataSetsXSelector", "_calculated_")
	MakePopupIntoWaveSelectorSort("NewGF_SelectDataSetsPanel", "NewGF_SelectDataSetsYSelector", "NewData_YListSortMenu")
	MakePopupIntoWaveSelectorSort("NewGF_SelectDataSetsPanel", "NewGF_SelectDataSetsXSelector", "NewData_XListSortMenu")
	
	SetWindow NewGF_SelectDataSetsPanel, hook(DataSetsSelectorHook)=SelectDataSets_WindowHook
end

// Takes in currentOptionsString and modifies it to add or remove "WIN:"+targetname. Returns the resulting string.
// If fromTarget is non-zero, it is added; if zero, it is removed if present
static Function/S MakeTargetOptions(String currentOptionsString, Variable fromTarget)
		Variable WINpos = StrSearch(currentOptionsString, "WIN:", 0)
		if (WINpos >= 0)
			currentOptionsString = RemoveByKey("WIN", currentOptionsString, ":", ",")
		endif
		if (fromTarget)
			String targetWin = WinName(0, 3)		// 3 = graphs and tables
			if (strlen(targetWin) > 0)
				Variable fstrlen = StrLen(currentOptionsString)
				if (fstrlen > 0)
					if (CmpStr(currentOptionsString[fstrlen-1], ",") != 0)
						currentOptionsString += ","
					endif
				endif
				currentOptionsString += "WIN:"+targetWin
			endif
		endif
		
		return currentOptionsString
end

Function DataSets_FromTargetCheckProc(s)
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode == 2)		// mouse up
			string listboxName = "NewGF_SelectDataSetsYSelector"
			String currentOptions = WS_GetListOptionsStr(s.win, listboxName)
			WS_SetListOptionsStr(s.win, listboxName, MakeTargetOptions(currentOptions, s.checked))
			listboxName = "NewGF_SelectDataSetsXSelector"
			currentOptions = WS_GetListOptionsStr(s.win, listboxName)
			WS_SetListOptionsStr(s.win, listboxName, MakeTargetOptions(currentOptions, s.checked))
	endif
end

Function DS_SelectorFilterSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			string listboxName = "NewGF_SelectDataSetsYSelector"
			if (CmpStr(sva.ctrlName, "DataSets_XListFilterString") == 0)
				listboxName = "NewGF_SelectDataSetsXSelector"
			endif
			if (strlen(sva.sval) == 0)
				sva.sval="*"
				SetVariable $sva.ctrlName,win=$sva.win,value= _STR:"*"
			endif
			WS_SetFilterString(sva.win, listboxName, sva.sval)
			break
	endswitch

	return 0
End

Function DataSets_SelectPopupMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	switch( s.eventCode )
		case 2: // mouse up
			String indexedPath = "", listofPaths = ""
			Variable index=0
			string listboxName = "NewGF_SelectDataSetsYSelector"
			if (CmpStr(s.ctrlName, "DataSets_XListSelectMenu") == 0)
				listboxName = "NewGF_SelectDataSetsXSelector"
				index=1
			endif
			switch (s.popNum)
				case 1:			// select all
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 1
					while (1)
					break;
				case 2:			// select every other
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 2
					while (1)
					break;
				case 3:			// select every other starting with second
					index += 1
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 2
					while (1)
					break;
				case 4:			// select every third
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
				case 5:			// select every third starting with second
					index += 1
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
				case 6:			// select every third starting with third
					index += 2
					do
						indexedPath = WS_IndexedObjectPath(s.win, listboxName, index)
						if (strlen(indexedPath) == 0)
							break;
						endif
						listofPaths += indexedPath+";"
						index += 3
					while (1)
					break;
			endswitch
			WS_ClearSelection(s.win, listboxName)
			WS_SelectObjectList(s.win, listboxName, listofPaths)
			break
	endswitch
end

Function SelectData_CheckForDupYWaves()

	Wave/T listwave = root:Packages:NewGlobalFit:SelectedDataSetsListWave
	Wave selwave = root:Packages:NewGlobalFit:SelectedDataSetsSelWave
	Variable nrows = DimSize(listwave, 0)
	Variable i,j

	// look for duplicate Y waves, an N^2 operation!
	nrows = DimSize(listwave, 0)
	if (nrows < 2)
		return 0
	endif
	
	for (i = 0; i < nrows-1; i += 1)
		for (j = i+1; j < nrows; j += 1)
			if (CmpStr(listwave[i][0], listwave[j][0]) == 0)		// found a duplicate
				selwave = 0
				selwave[i][0] = selwave[i][0] | 1
				selwave[j][0] = selwave[j][0] | 1
				DoUpdate
				DoAlert 0, "Found duplicate Y waves."
				return 1
				break;
			endif
		endfor
	endfor
	
	return 0
end

Function SelectDataSetsArrowButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String YWaves = WS_SelectedObjectsList(s.win, "NewGF_SelectDataSetsYSelector")
		String XWaves = WS_SelectedObjectsList(s.win, "NewGF_SelectDataSetsXSelector")
		Variable nwaves = ItemsInList(YWaves)
		Variable nXwaves = ItemsInList(Xwaves)
		
		if (nXwaves == 1)
			String singleXwave = StringFromList(0, XWaves)
		endif
		
		Wave/T listwave = root:Packages:NewGlobalFit:SelectedDataSetsListWave
		Wave selwave = root:Packages:NewGlobalFit:SelectedDataSetsSelWave
		Variable nrows = DimSize(listwave, 0)
		Variable i, j, index, startWave=0
		Variable DoingX=0, DoingY=0
		
		if (CmpStr(s.ctrlName, "NewGF_SelectDataSetsYArrowBtn") == 0)
			// first insert selections into cells that are selected
			index = 0
			for (i = 0; i < nrows; i += 1)
				if ( (strlen(listWave[i][0]) == 0) || (selwave[i][0] & 9) )
					listWave[i][0] = StringFromList(index, YWaves)
					index += 1
					if (index >= nwaves)
						break;
					endif
				endif
			endfor
			startWave = index
			// if any are left over, add rows to receive the waves, and leave the X cells blank
			DoingY = 1
		elseif  (CmpStr(s.ctrlName, "NewGF_SelectDataSetsXArrowBtn") == 0)
			if (nXwaves > 1)
				for (i = 0; i < nrows; i += 1)
					if ( (strlen(listWave[i][1]) == 0) || (selwave[i][1] & 9) )
						listWave[i][1] = StringFromList(index, XWaves)
						index += 1
						if (index >= nXwaves)
							break;
						endif
					endif
				endfor
				startWave = index
				DoingX = 1
				nwaves = nXwaves
			else
				for (i = 0; i < nrows; i += 1)
					if ( (strlen(listWave[i][1]) == 0) || (selwave[i][1] & 9) )
						listWave[i][1] = singleXwave
					endif
				endfor
			endif
		else
			if ( (nwaves != nXwaves) && (nXwaves != 1) )
				DoAlert 0, "You have selected "+num2str(nwaves)+" Y waves, but "+num2str(ItemsInList(Xwaves))+" X waves."
				return -1
			endif
			DoingX = 1
			DoingY = 1
		endif

		if (DoingX || DoingY)
			if (startWave < nwaves)
				Variable firstNewRow = nrows
				InsertPoints firstNewRow, nwaves-startWave, listwave, selwave
				for (i = startWave; i < nWaves; i += 1)
					index = firstNewRow+i
					if (DoingY)
						listwave[index][0] = StringFromList(i, YWaves)
					endif
					if (DoingX)
						if (nXwaves == 1)
							listwave[index][1] = singleXwave
						else
							listwave[index][1] = StringFromList(i, XWaves)
						endif
					endif
				endfor
			endif
		endif
		
		SelectData_CheckForDupYWaves()
	endif
End

Function SelectDataSets_WindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable returnValue = 0
	
	strswitch (s.eventName)
		case "keyboard":
			if ( (s.keycode == 8) || (s.keycode == 127) )			// delete or forward delete
				Wave/T listwave = root:Packages:NewGlobalFit:SelectedDataSetsListWave
				Wave selWave=root:Packages:NewGlobalFit:SelectedDataSetsSelWave
				Variable nrows = DimSize(listwave, 0)
				Variable i
				for (i = nrows-1; i >= 0; i -= 1)
					if ( (selwave[i][0] & 9) || ((selwave[i][1] & 9)) )
						DeletePoints i, 1, listwave, selwave
					endif
				endfor
				if (DimSize(listwave, 0) == 0)
					Redimension/N=(0,2) listwave, selwave
				endif
				SelectData_CheckForDupYWaves()
				returnValue = 1
			endif
			break;
	endswitch
	
	return returnValue
end

Function NewGF_SelectedDataListBoxProc(s) : ListBoxControl
	STRUCT WMListboxAction &s

	Variable row = s.row
	Variable col = s.col
	WAVE/T/Z listWave = s.listWave
	WAVE/Z selWave = s.selWave

	switch( s.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			if ( (s.row >= 0) && (s.row < DimSize(listWave, 0)) && (s.eventMod & 16) )
				
			endif
			break
		case 2:	// mouse up
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 12:	// key stroke
			if ( (s.row == 8) || (s.row == 127) )			// delete or forward delete
				Variable nrows = DimSize(listwave, 0)
				Variable i
				for (i = nrows-1; i >= 0; i -= 1)
					if ( (selwave[i][0] & 9) || ((selwave[i][1] & 9)) )
						DeletePoints i, 1, listwave, selwave
					endif
				endfor
				if (DimSize(listwave, 0) == 0)
					Redimension/N=(0,2) listwave, selwave
				endif
				SelectData_CheckForDupYWaves()
			elseif ( ((s.row == char2num("a")) || (s.row == char2num("A"))) && (s.eventMod & 8) )
				selwave = selwave[p][q] | 1
			else
//print "Listbox char code = ", s.row
			endif
			break;
	endswitch

	return 0
End

Function DataSets_SelectAllBtnProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave selWave=root:Packages:NewGlobalFit:SelectedDataSetsSelWave
			selwave = selwave[p][q] | 1
			break
	endswitch

	return 0
End

Function DataSetsMvSelectedWavesUpOrDown(s) : ButtonControl
	STRUCT WMButtonAction &s
	
	if (s.eventCode != 2)
		return 0
	endif

	Wave/T SelectedWavesListWave = root:Packages:NewGlobalFit:SelectedDataSetsListWave
	Wave SelectedWavesSelWave = root:Packages:NewGlobalFit:SelectedDataSetsSelWave
	
	Duplicate/O/T/FREE SelectedWavesListWave, DuplicateSelectedWaveListWave
	Duplicate/O/FREE SelectedWavesSelWave, DuplicateSelectedWavesSelWave
	
	Variable rowsInSelectedList = DimSize(SelectedWavesSelWave, 0)
	Variable firstSelectedRow = rowsInSelectedList
	Variable lastSelectedRow = rowsInSelectedList
	Variable nSelectedRows = 0
	Variable i
	Variable lastRow = rowsInSelectedList-1
	
	Variable moveUp = CmpStr(s.ctrlName, "SelectData_MoveUpButton") == 0
	
	if (moveUp)
		if ( (SelectedWavesSelWave[0][0] & 0x01) || (SelectedWavesSelWave[0][1] & 0x01) )
			return 0		// a cell in the top row is selected; can't move up
		endif
	else
		if ( (SelectedWavesSelWave[lastRow][0] & 0x01) || (SelectedWavesSelWave[lastRow][1] & 0x01) )
			return 0		// a cell in the bottom row is selected; can't move down
		endif
	endif
	
	Variable col
	for (col = 0; col < 2; col += 1)
		nSelectedRows = 0
		
		if (moveUp)
			for (i = 0; i < rowsInSelectedList; i += 1)
				if (SelectedWavesSelWave[i][col] & 0x09)
					SelectedWavesListWave[i-1][col] = DuplicateSelectedWaveListWave[i][col]
					SelectedWavesSelWave[i-1][col] = DuplicateSelectedWavesSelWave[i][col]
					SelectedWavesListWave[i][col] = DuplicateSelectedWaveListWave[i -1][col]
					SelectedWavesSelWave[i][col] = DuplicateSelectedWavesSelWave[i -1][col]
				endif
			endfor
		else
			for (i = rowsInSelectedList-1; i >= 0; i -= 1)
				if (SelectedWavesSelWave[i][col] & 0x09)
					SelectedWavesListWave[i+1][col] = DuplicateSelectedWaveListWave[i][col]
					SelectedWavesSelWave[i+1][col] = DuplicateSelectedWavesSelWave[i][col]
					SelectedWavesListWave[i][col] = DuplicateSelectedWaveListWave[i+1][col]
					SelectedWavesSelWave[i][col] = DuplicateSelectedWavesSelWave[i +1][col]
				endif
			endfor
		endif
	endfor
end

Function DataSets_CancelButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	switch( s.eventCode )
		case 2: // mouse up
			DoWindow/K $(s.win)
			break
	endswitch

	return 0
End

Function DataSets_OKButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T SelectedWavesListWave = root:Packages:NewGlobalFit:SelectedDataSetsListWave
			Wave SelectedWavesSelWave = root:Packages:NewGlobalFit:SelectedDataSetsSelWave
			Variable nSelected = DimSize(SelectedWavesListWave, 0)
			Variable i
			
			// Some sanity checks
			for (i = 0; i < nSelected; i += 1)
				if (CmpStr(SelectedWavesListWave[i][0], SelectedWavesListWave[i][1]) == 0)
					SelectedWavesSelWave = 0
					SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
					SelectedWavesSelWave[i][1] = SelectedWavesSelWave[i][1] | 1
					DoUpdate
					DoAlert 0, "You have selected the same wave for both the Y and the X waves."
					return 0
				endif
				Wave/Z w = $(SelectedWavesListWave[i][0])
				if (!WaveExists(w))
					SelectedWavesSelWave = 0
					SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
					DoUpdate
					DoAlert 0, "One of your Y waves is missing."
					return 0
				endif
				Wave/Z xw = $(SelectedWavesListWave[i][0])
				if (WaveExists(xw) && (numpnts(w) != numpnts(xw)))
					SelectedWavesSelWave = 0
					SelectedWavesSelWave[i][0] = SelectedWavesSelWave[i][0] | 1
					SelectedWavesSelWave[i][1] = SelectedWavesSelWave[i][1] | 1
					DoUpdate
					DoAlert 0, "The number of points in your Y wave does not match the number of points in the X wave."
					return 0
				endif
			endfor
			
			NewGF_RemoveAllDataSets()
			
			for (i = 0; i < nSelected; i += 1)
				Wave w = $(SelectedWavesListWave[i][0])
				Wave/Z xw = $(SelectedWavesListWave[i][1])
				
			//	if (WaveExists(w) && !NewGF_WaveInListAlready(w))
					NewGF_AddYWaveToList(w, xw)
			//	endif
			endfor
			DoWindow/K $(ba.win)
			break
	endswitch

	return 0
End

\$PICT$name=ProcGlobal#YellowRightArrow$/PICT$
// PNG: width= 13, height= 15
Picture YellowRightArrow
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!!.!!!!0#Qau+!3ec;+92BF&SXU":e=#A+Ad)sAnc'm!!%6Ejct6f;ca
	gUhg8S]67j<&+"Mut!MU:-TX#%.9DK:A.Ni)mf_4m`8_ZnK<"MHfLbcI'KGd$c5r4H.-E%cPS*3]36
	l.19*'-oQ)of[FC`9%U41F%cZ=pQD4ZBq7GMi:fF7+BmT(<#&`YBb%J-1<k9BhXL+p@-JR0*(6huXQ
	Ohu[d'<=p[Fb7fuu(%'+;_!"i%rq'IcR1A52Ngm9pL<_P\F56ar%/N'0e"['I0EDM?j]QgWbt8Aad_
	(D\.AY([=d?05&<ho=qNN6Ci[2Uio?<0Fe#YA^UQ/r=.M%MMmR8\X&o'#Xo)K2',,[s8_!X__o.!Y!
	1`T]ZYL2R\r#DL5?[=A%O.$i$d0^Ihlg\db\I>,_&qL#@Cs;&u!4O`ah4N$5VZ"a9K7saMjTYmWVo'
	K8cl,n2e&2LlQNpo'DDKK7BJMa>"L(c**4`!tef2h:J.g?fcl[625ELF/WhC*o@]if_FoWK%=5XP_$
	Ut/,N(G]NXgYQhX?Q>Y:7*oZqMrhPgt"IjG`B.em7u=F3nQKrGIlkJd\Y9Li3V4n4li1Jo5!1in@If
	3jJuAs+L:P[$b3jF1[*c&O+Sr/q@I5:4Bs)l7i3I@UG'P,?<*Q#0laU+P2r1nPfc`WA\?)nY'8O&8=
	;_Zc98"YNEM_=aa!bdEG`h/ZD`ZUD2,(F]?3?1fpc9V^]*t[e04_?ShJ5J_bM,rFIeVFHi#nL2,8YA
	@)amEUj$Y@Gk_D"ebc0-RET4<:[U3H@4leT(nr,l.\HsJ_@5Rfj^W/[1bQ\8E$HTg1!E=$N`bOJ>h3
	mQ_%C]/=ngQ*F*Gm.i,,a$[VN,Ib(8MR3"MP6>k?hYj;[!hi2N3l'K15.]S@;>>Nih86r^Wt/p:>P*
	-?:*7IXJPG_f_*+P]o\,83S$`?`GPj#=`bs1Qm^7oOZ3&a:$u(Y:ZZCD6k=FRBld`l;ZFcGEI/D,]H
	Voil/\#HAD\)L()l1LA,*-_'P5'XY1#g5i)#QoVkK)j^pS>ai=*qI+JR_pC&\1jAtE;"i6q=o*C&C$
	N#<0?r;ogd)&n+WZI!;`G-qY^+kNC^5,$\&G]Cis\!R`OL]/^M1+$C6DT7p1N:Fe68d(#]6/RLZ\6u
	\np-g^9m?s467=@eEn7@1?;K]pMoZn:jS/INtlh`n\'/A9_i9Rm.Z^#c7XQ-i9ZWj^n6o2Q?rfH8fC
	&(6e@'*9!ts1;+G,6XMPY-8M$'49Qj]O8/ofYP;SSqX(2j`o>pZ-C4rBuOd@6&['G(P11L.-cGnZtH
	Wk/Sl_R=h/]q+CgV[N&:3N7D4*RX4q9"ic4Z=G=>4?V/rC>n;-ABp`c&A&a(9^m]@Q@A#rq5\1:Ybu
	*d@"M71Tb)i!*Wh31)^-*XoWq@#f+%g^mPKO8,c,C!+(iiGd0'_f1V3p8cUmJol:eipU,%i?hqDomK
	'QA1mBqL:l9"-NZa`>-Ib(BUq2@5:m;;tM?:1`YFonAJY`q*8rs+2XocZF!@.c$:)O,_TL2M;W%Tp@
	;a;dXQ@T,%e>NT9&Q*3EJYM;+rr7T4msF;YasfW!(dOrC9D.S_HqIeg6Di4n`Dhk(,`'pL(5i<H@W;
	s]Zd``Y=S;al>]?I;qD=d?8Ord9rWFIFh=tSEmh>a%!AI)55u]6I9oqY9_a"W!4\7+lh$k)3;Kh::Z
	=_d-H4[6p<Tk#S94l-YU>u<N66V5l8U):DkYu]>rP-,7]!cJ)1gQDYT'%@j7)V(j2F-(`L<+ImGXbM
	\#$XO4B!\2"AJkKGU*rP5-uOS_PTYo878B`cg8GrZ,gB#&4RSX\A]6L*lfudO^L&U$>FN)?#uX0`92
	ql'/:4i6f.35&VUhG)dXNE2W'4sq]XO/J!CY:@]n5MTJV9Z\2+k7n?1eoo6:_@bCVZ,ErH<_J!M^I0
	74%+.m5.$iql]6mH,$qf@Da4#23$L4G`qd$<Co;P^>m,PHS;58j[Grpqn>#IL1+IHs,\i%\D;m;L,U
	]Q),](,*7l/_ch#o6g@(nQqG3h?l.QHJBg7;+Q/_!np<Wd>!!#SZ:.26O@"J
	ASCII85End
End
// PNG: width= 16, height= 12
Picture YellowDownArrow
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!!1!!!!-#Qau+!9Aj6ec5[R&SXU":e=#A+Ad)sAnc'm!!%6Ejct6f;ca
	gUhg8S]67j<&+"Mut!MU:-TX#%.9DK:A.Ni)mf_4m`8_ZnK<"MHfLbcI'KGd$c5r4H.-E%cPS*3]36
	l.19*'-oQ)of[FC`9%U41F%cZ=pQD4ZBq7GMi:fF7+BmT(<#&`YBb%J-1<k9BhXL+p@-JR0*(6huXQ
	Ohu[d'<=p[Fb7fuu(%'+;_!"i%rq'IcR1A52Ngm9pL<_P\F56ar%/N'0e"['I0EDM?j]QgWbt8Aad_
	(D\.AY([=d?05&<ho=qNN6Ci[2Uio?<0Fe#YA^UQ/r=.M%MMmR8\X&o'#Xo)K2',,[s8_!X__o.!Y!
	1`T]ZYL2R\r#DL5?[=A%O.$i$d0^Ihlg\db\I>,_&qL#@Cs;&u!4O`ah4N$5VZ"a9K7saMjTYmWVo'
	K8cl,n2e&2LlQNpo'DDKK7BJMa>"L(c**4`!tef2h:J.g?fcl[625ELF/WhC*o@]if_FoWK%=5XP_$
	Ut/,N(G]NXgYQhX?Q>Y:7*oZqMrhPgt"IjG`B.em7u=F3nQKrGIlkJd\Y9Li3V4n4li1Jo5!1in@If
	3jJuAs+L:P[$b3jF1[*c&O+Sr/q@I5:4Bs)l7i3I@UG'P,?<*Q#0laU+P2r1nPfc`WA\?)nY'8O&8=
	;_Zc98"YNEM_=aa!bdEG`h/ZD`ZUD2,(F]?3?1fpc9V^]*t[e04_?ShJ5J_bM,rFIeVFHi#nL2,8YA
	@)amEUj$Y@Gk_D"ebc0-RET4<:[U3H@4leT(nr,l.\HsJ_@5Rfj^W/[1bQ\8E$HTg1!E=$N`bOJ>h3
	mQ_%C]/=ngQ*F*Gm.i,,a$[VN,Ib(8MR3"MP6>k?hYj;[!hi2N3l'K15.]S@;>>Nih86r^Wt/p:>P*
	-?:*7IXJPG_f_*+P]o\,83S$`?`GPj#=`bs1Qm^7oOZ3&a:$u(Y:ZZCD6k=FRBld`l;ZFcGEI/D,]H
	Voil/\#HAD\)L()l1LA,*-_'P5'XY1#g5i)#QoVkK)j^pS>ai=*qI+JR_pC&\1jAtE;"i6q=o*C&C$
	N#<0?r;ogd)&n+WZI!;`G-qY^+kNC^5,$\&G]Cis\!R`OL]/^M1+$C6DT7p1N:Fe68d(#]6/RLZ\6u
	\np-g^9m?s467=@eEn7@1?;K]pMoZn:jS/INtlh`n\'/A9_i9Rm.Z^#c7XQ-i9ZWj^n6o2Q?rfH8fC
	&(6e@'*9!ts1;+G,6XMPY-8M$'49Qj]O8/ofYP;SSqX(2j`o>pZ-C4rBuOd@6&['G(P11L.-cGnZtH
	Wk/Sl_R=h/]q+CgV[N&:3N7D4*RX4q9"ic4Z=G=>4?V/rC>n;-ABp`c&A&a(9^m]@Q@A#rq5\1:Ybu
	*d@"M71Tb)i!*Wh31)^-*XoWq@#f+%g^mPKO8,c,C!+(iiGd0'_f1V3p8cUmJol:eipU,%i?hqDomK
	'QA1mBqL:l9"-NZa`>-Ib(BUq2@5:m;;tM?:1`YFonAJY`q*8rs+2XocZF!@.c$:)O,_TL2M;W%Tp@
	;a;dXQ@T,%e>NT9&Q*3EJYM;+rr7T4msF;YasfW!(dOrC9D.S_HqIeg6Di4n`Dhk(,`'pL(5i<H@W;
	s]Zd``Y=S;al>]?I;qD=d?8Ord9rWFIFh=tSEmh>a%!CB@G5u]6I<Kb$j!`9M_k:Xr=,Z_q5b"&sG;
	G[rt.URa>d`8".,_X;o-JD:!g2%lE_<cpGj#;o@9X6$%B?lo,H[!AD2QKe,8Wn`<%Yk.rhsWuZ:"/K
	Q$fbM`o$(bKT@Ra7=P=lK4oF_f1K0euP/;"a^"sdZJ#I%F-o)We?sqQ'\$PVTC)%<e31V8'Lb)IHNr
	b62^fD87ZU1:cDuo:0G)DdQFDfB7J#Q&!qPhp1hLa)F\\0&%%)_$:e\s_P,!>Do\E(hRl.9LUM%gqh
	^0(,R\>b<5.cE[-0pERbH(NXRFg%LmmHa#3BiSZ%EhDU^C;oKo&M2*<V&_m)Q6bM\GLf9&lE%1-lSU
	8[3D)sY(5kVVdI>j;+`Fck^r`C&+e]:,(I_beB!^aZfR#4p5D:&d;gs]Jcnh/CqI55pz8OZBBY!QNJ
	ASCII85End
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

static Function IsLinkText(theText)
	String theText
	
	return (CmpStr(theText[0,4], "LINK:") == 0)
end

static Function ItemListedInWave(Item, theWave)
	String Item
	Wave/T theWave
	
	return ItemNumberInTextWaveList(Item, theWave) >= 0
end

static Function ItemNumberInTextWaveList(Item, theWave)
	String Item
	Wave/T theWave
	
	Variable i
	Variable npnts = DimSize(theWave, 0)
	Variable itemNumber = -1
	
	for (i = 0; i < npnts; i += 1)
		if ( (strlen(theWave[i]) > 0) && (CmpStr(theWave[i], Item) == 0) )
			itemNumber = i
			break
		endif
	endfor
	
	return itemNumber
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

static Function totalCoefsFromCoefList()

	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	
	return DimSize(CoefListWave, 0)
end

static Function totalRealCoefsFromCoefList(LinkRowsOK)
	Variable LinkRowsOK

	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif

	Variable i
	Variable totalNonlinkRows = 0
	Variable numrows = DimSize(CoefListWave, 0)
	for (i = 0; i < numrows; i += 1)
		if (LinkRowsOK || !IsLinkText(CoefListWave[i][1]))
			totalNonlinkRows += 1
		endif
	endfor
	
	return totalNonlinkRows
end

static Function totalSelRealCoefsFromCoefList(LinkRowsOK)
	Variable LinkRowsOK

	Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave

	Variable i
	Variable totalNonlinkRows = 0
	Variable numrows = DimSize(CoefListWave, 0)
	for (i = 0; i < numrows; i += 1)
		if (LinkRowsOK || !IsLinkText(CoefListWave[i][1]))
			if (IsRowSelected(CoefSelWave, i))
				totalNonlinkRows += 1
			endif
		endif
	endfor
	
	return totalNonlinkRows
end

static Function SetCoefListFromWave(w, col, SetOnlySelectedCells, OKtoSetLinkRows)
	Wave w
	Variable col
	Variable SetOnlySelectedCells
	Variable OKtoSetLinkRows
	
	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave		// ST: 210624 - master list wave in the background
	Wave/T CoefDispWave = root:Packages:NewGlobalFit:NewGF_CoefControlListWave			// ST: 210624 - list actually displayed in the listbox
	if (!WaveExists(CoefListWave))														// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave

	Variable coefIndex = 0;
	Variable i,j
	Variable nTotalCoefs = DimSize(CoefListWave, 0)
	
	String linktext
	String formatStr = "%.15g"
	if ( (WaveType(w) & 4) == 0)		// it's not a double-precision wave
		formatStr = "%.6g"
	endif
	
	for (i = 0; i < nTotalCoefs; i += 1)		// indent 1
//		if ( SetOnlySelectedCells && ((CoefSelWave[i][col] & 9) == 0) )
//		if ( SetOnlySelectedCells && !IsRowSelected(CoefSelWave, i) )
		
		FindValue/V=(i) CoefSortWave			// ST: 210624 find the associated row in the sorted list
		Variable rowIndex = V_value
		if (rowIndex == -1)
			continue
		endif
		if ( SetOnlySelectedCells && !IsRowSelected(CoefSelWave, rowIndex) )
			continue
		endif
//		if (!OKtoSetLinkRows && !IsLinkText(CoefListWave[i][1]))
		if (!IsLinkText(CoefListWave[i][1]))		// indent 2
			// first part sets the coefficient list wave text from the appropriate element in the input wave
		
			if (col == 3)
				if (w[coefIndex][0])
					//CoefSelWave[i][col] = 0x20 + 0x10
					CoefListWave[i][col] = " X"			// ST: 210624 - save selection in master list instead (will be transferred to display later)
				else
					//CoefSelWave[i][col] = 0x20
					CoefListWave[i][col] = ""
				endif
			else
				string dumstr
				sprintf dumstr, formatStr, w[coefIndex][0]
				Variable nstr = strlen(dumstr)
				for (j = 0; j < nstr; j += 1)
					if (char2num(dumstr[j]) != char2num(" "))
						break
					endif
				endfor
				if (j > 0)
					dumstr = dumstr[j, strlen(dumstr)-1]
				endif
				CoefListWave[i][col] = dumstr
			endif
			
			if (SetOnlySelectedCells)					// ST: 210626 - make sure to set linked cells to the same value as well
				linktext = "LINK:"+CoefListWave[i][1]
				for (j = 0; j < nTotalCoefs; j += 1)
					if (CmpStr(linktext, CoefListWave[j][1]) == 0)
						if (col == 3)
							if (CmpStr(" X", CoefListWave[i][col]) == 0)
								CoefListWave[j][col] = " X"
							else
								CoefListWave[j][col] = ""
							endif
						else
							CoefListWave[j][col] = CoefListWave[i][col]
						endif
					endif
				endfor
			endif
		else		// indent 2
			// We've hit a link cell (refers to an earlier row)
			// 
			// If we are setting the entire wave, rather than setting the value in the row, we should instead copy the value
			// from the row containing the master copy (the row to which the link refers). (first IF block)
			//
			// If we are setting selected rows, and one of them is a link to another row, we should set the value of the master row
			// and any other rows that link to it.
			if (!SetOnlySelectedCells) 		// indent 3
				// copy linked text from master row when we encounter a linked cell. The links should always be after the cell they link to.
				linktext = (CoefListWave[i][1])[5,strlen(CoefListWave[i][1])-1]
				for (j = 0; j < nTotalCoefs; j += 1)
					if (CmpStr(linktext, CoefListWave[j][1]) == 0)
						if (col == 3)
							//if (CoefSelWave[j][col] & 0x10)
							if (CmpStr(" X", CoefListWave[j][col]) == 0)
								CoefListWave[i][col] = " X"
							else
								CoefListWave[i][col] = ""
							endif
						else
							CoefListWave[i][col] = CoefListWave[j][col]
						endif
						break
					endif
				endfor
				continue		// skip incrementing coefIndex
			elseif (OKtoSetLinkRows)		// indent 3
				linktext = (CoefListWave[i][1])[5,strlen(CoefListWave[i][1])-1]
				for (j = 0; j < nTotalCoefs; j += 1)		// indent 4
					if ( (CmpStr(linktext, CoefListWave[j][1]) == 0) || (CmpStr(CoefListWave[i][1], CoefListWave[j][1]) == 0) )		// indent 5
						// we have found the master row						or one of the linked rows
						if (col == 3)		// indent 6
							if (w[coefIndex][0])
								//CoefSelWave[j][col] = 0x20 + 0x10
								CoefListWave[j][col] = " X"
							else
								//CoefSelWave[j][col] = 0x20
								CoefListWave[j][col] = ""
							endif
						else		// indent 6
							sprintf dumstr, formatStr, w[coefIndex][0]
							nstr = strlen(dumstr)
							Variable k
							for (k = 0; k < nstr; k += 1)
								if (char2num(dumstr[k]) != char2num(" "))
									break
								endif
							endfor
							if (k > 0)
								dumstr = dumstr[k, strlen(dumstr)-1]
							endif
							CoefListWave[j][col] = dumstr
						endif		// indent 6
//						coefIndex += 1
					endif		// indent 5
				endfor		// indent 4
			endif		// indent 3
		endif		// indent 2
		coefIndex += 1
	endfor		// indent 1
	WM_NewGlobalFit1#NewGF_UpdateDisplayControlList()				// ST: 210624 - copies made changes into the displayed list
end

static Function SaveCoefListToWave(w, col, SaveOnlySelectedCells, OKToSaveLinkCells)
	Wave w
	Variable col
	Variable SaveOnlySelectedCells
	Variable OKToSaveLinkCells
	
	Wave/Z/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	if (!WaveExists(CoefListWave))	// ST: 210624 - must be an older panel => upgrade
		WM_NewGlobalFit1#UpgradeNewGlobalFitPanelCoefList()
		Wave/T CoefListWave = root:Packages:NewGlobalFit:NewGF_CoefControlMasterWave
	endif
	Wave CoefSortWave = root:Packages:NewGlobalFit:NewGF_CoefControlSortWave
	Wave CoefSelWave = root:Packages:NewGlobalFit:NewGF_CoefControlListSelWave
	Variable ntotalCoefs = totalCoefsFromCoefList()
	Variable i
	Variable waveIndex = 0, rowIndex = 0
	
	for (i = 0; i < ntotalCoefs; i += 1)
		if (OKToSaveLinkCells || !IsLinkText(CoefListWave[i][1]))
			//if ( SaveOnlySelectedCells && !IsRowSelected(CoefSelWave, i) )
			FindValue/V=(i) CoefSortWave		// ST: 210624 find the associated row in the sorted list
			rowIndex = V_value
			if (rowIndex == -1)
				continue
			endif
			if ( SaveOnlySelectedCells && !IsRowSelected(CoefSelWave, rowIndex) )
				continue
			endif
			if (col == 3)
				//w[waveIndex] = ((CoefSelWave[i][col] & 0x10) != 0)
				w[waveIndex] = (CmpStr(" X", CoefListWave[i][col]) == 0)
			else
				w[waveIndex] = str2num(CoefListWave[i][col])
			endif
			waveIndex += 1
		endif
	endfor
end

static Function FindSelectedRows(SelectionWave)
	Wave SelectionWave
	
	Variable rows = DimSize(SelectionWave, 0)
	Variable cols = DimSize(SelectionWave, 1)
	Variable i,j
	Variable rowsSelected = 0
	
	for (i = 0; i < rows; i += 1)
		for (j = 0; j < cols; j += 1)
			if (IsRowSelected(SelectionWave, i))
				rowsSelected += 1
				break;
			endif
		endfor
	endfor
	
	return rowsSelected;
end

static Function IsRowSelected(SelectionWave, row)
	Wave SelectionWave
	Variable row
	
	Variable cols = DimSize(SelectionWave, 1)
	Variable j
	
	for (j = 0; j < cols; j += 1)
		if (SelectionWave[row][j] & 9)
			return 1
			break;
		endif
	endfor
	
	return 0;
end

Function NewGF_HelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "Global Analysis or Global Fitting"
			break
	endswitch

	return 0
End
