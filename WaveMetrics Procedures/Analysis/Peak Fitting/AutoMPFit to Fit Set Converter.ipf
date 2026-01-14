#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma moduleName=WMAutoMPFConverter
#pragma version=1.03
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#include <Multipeak Fitting>

static StrConstant kMPF_WorkingDir = "root:Packages:MultiPeakFit2:"
static Constant kMPF_ConvVerbose = 1	// print status messages

//***************************************
// A converter tool to copy result folders from MPF2_AutoMPFit() into MPF sets and back.
// Goes with the Multipeak Fitting package.
//
// Run with the exact same input as MPF2_AutoMPFit(), i.e., just replace 'MPF2_AutoMPFit'
// with 'MPF2_ConvertToMPFSetFolder' or 'MPF2_CopyFromMPFSetFolder'and run the command.
// Both functions work from the current data folder. If no result folders are found, then
// the current folder is probably set wrong.
//
// Two conversion functions are provided:
//
// MPF2_ConvertToMPFSetFolder():	AutoMPFit folder => MPFit GUI
//  - One (or more) MPF sets will be added to copy the content of the selected results folder.
//    !! Assumes that the order (and number) of folders with the resultDFBase name
//    matches with the wave names provided in yWaveList, xWaveList !!
//	  => since ver. 1.02 the provided global strings are used to fetch the waves instead
//  - Constraints are all converted into a constraints list which can be viewed by clicking
//    'More Constraints' in the expanded Multipeak Fit panel.
//
// MPF2_CopyFromMPFSetFolder():		MPFit GUI => AutoMPFit folder
//  - For best results, make sure to complete a fit just before converting the set, i.e.,
//    don't change parameters without fitting once afterwards to ensure everything is up to date.
//  - Choosing NEW for the target folder will create a new results folder.
//    Note that this may create a mismatch between the number of input waves
//    (to be fitted) and number of the results folders!
//
// Version 1.00, 2021/03/23, ST - initial version of this add-on
// Version 1.01, 2021/04/07, ST - added support for negativePeakGuess parameter
// Version 1.02, 2021/04/14, ST - added support for usedYWave / usedXWave global strings
// Version 1.03, 2021/10/23, ST - added support for multidimensional constraints waves
//								  Fixed bug: Constraints were not written correctly to MPF sets if the number of parameters exceeded 10.
//								  Fixed bug: W_AutoPeakInfo may not be present (guess modes 0-2) and needs to be created for MPF to work.
// Version 1.03, 2021/11/05, ST - W_AutoPeakInfo creation uses new MPF2_UpdateWPIwaveFromPeakCoef() function
//***************************************

Function MPF2_ConvertToMPFSetFolder(resultDFBase, peakType, PeakCoefWaveFormat, BLType, BLCoefWaveName, yWaveList, xWaveList, InitialGuessOptions [, noiseEst, smFact, noiseEstMult, smFactMult, minAutoFindFraction, negativePeakGuess, doDerivedResults, doFitCurves, constraints, startPoint, endPoint])
	String resultDFBase						// uses the same basic input as MPF2_AutoMPFit()
	String peakType, PeakCoefWaveFormat
	String BLType, BLCoefWaveName
	String yWaveList, xWaveList				// only used if wave-path global strings are not available
	Variable noiseEst, smFact
	Variable minAutoFindFraction
	Variable negativePeakGuess
	Variable InitialGuessOptions			// not used here
	Variable noiseEstMult, smFactMult		// not used here
	Variable doDerivedResults, doFitCurves	// not used here
	Wave/Z/T constraints
	Variable startPoint, endPoint
	
	// ++++++++++++++++++++ find and select the desired folder to copy +++++++++++++++++++++++++++
	
	String resultDFs = ReplaceString(",",StringByKey("FOLDERS", DataFolderDir(1), ":", ";"),";")
	resultDFs = GrepList(resultDFs,"^"+resultDFBase+"_([0-9]+)$")								// match exact folder description: resultDFBase + "_n", where n is a number
	Variable numDirs = ItemsInList(resultDFs)
	if (numDirs == 0)
		if (kMPF_ConvVerbose)
			Print "No AutoMPFit folders with prefix "+resultDFBase+" found in current data folder."
		endif
		return -1
	endif
	
	// if (numDirs != ItemsInList(yWaveList))													// give an alert message if numbers do not add up
		// DoAlert/T="Input Wave vs Result Folder Number Mismatch" 1, "The number of provided input waves ("+ num2str(ItemsInList(yWaveList)) +") and found result folders (" + num2str(numDirs) + ") is not the same. Are you sure everything is correct?"
		// if (V_flag == 2)
			// return -1
		// endif
	// endif
	
	String selFolderStr, allFolderStr = "All " + num2str(numDirs) + " folders"					// user prompt -> select folder
	Prompt selFolderStr,"Select the folder you want to convert:",popup, allFolderStr + ";" + resultDFs
	DoPrompt/HELP="The selected folder(s) will be converted into one (multiple) standard MPF set." "AutoMPFit to MPF GUI converter",selFolderStr
	if (V_Flag)
		return -1
	endif
	
	Variable selWave, lastWave
	if (StringMatch(selFolderStr,allFolderStr))													// process all folders
		selWave = 0
		lastWave = numDirs-1
	else																						// process just the selected folder
		selWave = WhichListItem(selFolderStr, resultDFs)
		lastWave = selWave
	endif
	
	if (selWave == -1)
		return -1
	endif	
	
	Variable i,j
	DFREF saveDF = GetDataFolderDFR()
	DFREF main = $kMPF_WorkingDir
	if (!DataFolderRefStatus(main))																// if MPF was not started yet => create basic folder structure
		SetDataFolder root:
		for (i = 1; i < ItemsInList(kMPF_WorkingDir,":"); i++)
			NewDataFolder/O/S $StringFromList(i,kMPF_WorkingDir,":")
		endfor
		Variable/G currentSetNumber = 0
		SetDataFolder saveDF
		DFREF main = $kMPF_WorkingDir
	endif
	NVAR setNum = main:currentSetNumber
	
	// +++++++++++++++++++++++++++ now copy to MPF set folder(s) +++++++++++++++++++++++++++++++++
	
	if (WaveExists(constraints) && kMPF_ConvVerbose)											// give warning message -> only works correctly if peakType & BLType is correct							
		Print "Converting constraints wave... make sure you have input the correct baseline and peak types."
	endif
	
	do
		setNum += 1
		selFolderStr = StringFromList(selWave,resultDFs)										// only really necessary if 'all folders' were selected
		DFREF source = $selFolderStr
		if (!DataFolderRefStatus(source))														// this should not happen, but just to make sure
			return -1
		endif
				
		String currWaveStr = StringFromList(selWave,yWaveList)
		SVAR/Z yWPath = source:usedYWave														// use saved wave location if available
		if (SVAR_Exists(yWPath))
			currWaveStr = yWPath
		endif
		Wave/Z yWaveData = $currWaveStr
		if (!WaveExists(yWaveData))
			if (kMPF_ConvVerbose)
				Print "y Data "+currWaveStr+" not found."
			endif
			return -1
		endif
		
		if (kMPF_ConvVerbose)
			Print "Converting folder " + selFolderStr + " (" + NameOfWave(yWaveData) + ") to Multipeak Fit set " + num2str(setNum)
		endif
		
		DuplicateDataFolder/O=1/Z source, main:$("MPF_SetFolder_"+num2str(setNum))
		DFREF target = main:$("MPF_SetFolder_"+num2str(setNum))

		// +++++++++++++++++ rename contents and fill standard variables +++++++++++++++++++++++++

		SetDataFolder target
			KillVariables/Z gNumPeaks, MPFError													// these globals are not used by the MPF GUI
			KillWaves/Z MPF2BaselineCurve, MPF2FitCurve, MPF2FitCurve_X, MPF2FitCurve_PlusBL	// these fit output waves will be recreated by the GUI in a different form
			
			String wStr = WaveList(ReplaceString("%d",PeakCoefWaveFormat,"*")+"*",";","")
			String wList_coef = GrepList(wStr,"^"+ReplaceString("%d",PeakCoefWaveFormat,"([0-9]+)")+"$")
			String wList_eps  = GrepList(wStr,"^"+ReplaceString("%d",PeakCoefWaveFormat,"([0-9]+)")+"eps$")
			
			Variable wItems = ItemsInList(wList_eps), wNum
			for (i = 0; i < wItems; i++)														// rename peak coefeps waves first
				wStr  = StringFromList(i, wList_eps)
				sscanf wStr, PeakCoefWaveFormat+"eps", wNum
				Rename $wStr,  $("Peak "+num2str(wNum)+" Coefseps")
			endfor
			
			wItems = ItemsInList(wList_coef)													// wItems will be used again further below
			for (i = 0; i < wItems; i++)														// rename peak coef waves
				wStr = StringFromList(i, wList_coef)
				sscanf wStr, PeakCoefWaveFormat, wNum
				Rename $wStr, $("Peak "+num2str(wNum)+" Coefs")
				wStr = "MPF2PeakCurve"+num2str(wNum)											// possible peak fit curve (will be re-created upon resuming the fit anyway)
				if (Exists(wStr))
					Rename $wStr, $("Peak "+num2str(wNum))
				endif
				sprintf wStr, PeakCoefWaveFormat+"DER", wNum									// delete possible derived output waves
				KillWaves/Z $wStr
			endfor
			
			NVAR/Z v_chisq = MPFChiSquare
			if (NVAR_Exists(v_chisq))
				Rename v_chisq, MPF2_FitChiSq
			endif
			if (CmpStr(BLType, "None") != 0 && Exists(BLCoefWaveName))
				Rename $BLCoefWaveName, $("Baseline Coefs")										// rename baseline
			endif
			
			Variable/G AutoFindNoiseLevel = ParamIsDefault(noiseEst) ? 1 : noiseEst
			Variable/G AutoFindSmoothFactor = ParamIsDefault(smFact) ? 1 : smFact
			Variable/G AutoFindTrimFraction = ParamIsDefault(minAutoFindFraction) ? 0.05 : minAutoFindFraction
			Variable/G negativePeaks = ParamIsDefault(negativePeakGuess) ? 0 : (negativePeakGuess > 0)
			
			Variable/G displayPeaksFullWidth = 0
			Variable/G IgnoreOutOfRangePeaks = 1												// ignore out-of-range peaks (AutoMPFit does not care either)
			Variable/G MPF2_CoefListPrecision = 5
			Variable/G MPF2_UserCursors = 0
			Variable/G panelPosition = 0														// standard panel to the right
			Variable/G V_FitTol = 0.001
			
			Variable/G XPointRangeBegin = ParamIsDefault(startPoint) ? 0 : startPoint
			Variable/G XPointRangeEnd = ParamIsDefault(endPoint) ? DimSize(yWaveData,0)-1 : endPoint
			Variable/G XPointRangeReversed = DimDelta(yWaveData,0) < 0 ? 1 : 0
			
			Variable/G MPF2_FitDate = DateTime													// needs to have the current time since the copied coef waves have a new time stamp
			
			String/G GraphName = "MultipeakFit_Set"+num2str(setNum)
			String/G MPF2MaskWaveName = ""
			String/G MPF2WeightWaveName = ""
			String/G UserNotes = "From AutoMPFit folder "+ selFolderStr
			
			String/G XWvName = ""
			SVAR/Z usedXWave																	// use saved wave location if available
			if (SVAR_Exists(usedXWave))
				String/G XWvName = usedXWave
			elseif (strlen(xWaveList))
				Wave/Z xWaveData = $StringFromList(selWave,xWaveList)
				if (WaveExists(xWaveData))
					String/G XWvName = GetWavesDataFolder(xWaveData, 2)
				endif
			endif
			String/G yWvName = GetWavesDataFolder(yWaveData, 2)
			
			KillStrings/Z usedYWave, usedXWave, notes											// clean up wave-path globals
			// +++++++++++++++++ peak type list and constraints handling +++++++++++++++++++++++++
			
			String constraintsList = ""
			Make/T/Free/N=(0,0) replaceParamList
			Variable nparams, paramCount = 0													// paramCount is the global parameter counter for K## constraint parameters
			if (WaveExists(constraints))
				if (DimSize(constraints,1) > 1)													// ST: 211023 - add support for multidimensional constraints
					Make/T/Free/N=(DimSize(constraints,0)) currConstraints = constraints[p][selWave]
					wfprintf constraintsList, "%s;", currConstraints
					constraintsList = RemoveFromList("",constraintsList)
				else
					wfprintf constraintsList, "%s;", constraints								// create a list for conversion below
				endif
				
				if (CmpStr(BLType, "None") != 0)												// convert constraints parameters for the baseline K## -> BLK#
					FUNCREF MPF2_FuncInfoTemplate BLinfoFunc=$(BLType+BL_INFO_SUFFIX)
					nparams = ItemsInList(BLinfoFunc(BLFuncInfo_ParamNames))
					for (j = 0; j < nparams; j++)
						replaceParamList[DimSize(replaceParamList,0)] = {{"K"+num2str(paramCount++)},{"BL@"+num2str(j)}}
						//constraintsList = ReplaceString("K"+num2str(paramCount++),constraintsList,"BLK"+num2str(j))
					endfor
				endif
			endif
			
			Variable reconstructWPI = 0
			Wave/Z wpi = W_AutoPeakInfo
			if (!WaveExists(wpi))																// ST: 211023 - if AutoPeakInfo is missing it needs to be reconstructed during the copy operation
				reconstructWPI = 1
				Make/D/O/N=(wItems,5) W_AutoPeakInfo
				Wave wpi = W_AutoPeakInfo
			endif
			
			Variable peakTypeNum = ItemsInList(peakType)
			String peakTypeList = "", currPeakType = ""
			for (i = 0; i < wItems; i++)
				if (i > peakTypeNum-1)															// support for peak-type lists
					currPeakType = StringFromList(0,peakType)
				else
					currPeakType = StringFromList(i,peakType)
				endif
				peakTypeList += currPeakType + ";"
				
				if (reconstructWPI)																// ST: 211023 - guess the wpi parameters from the peak coefs => will be off a bit for peak types other than Gauss
					Wave peakCoefs = $("Peak "+num2str(i)+" Coefs")										
					MPF2_UpdateWPIwaveFromPeakCoef(wpi, i, currPeakType, peakCoefs)				// ST: 211105 - use peak coefs to update the full WPI
					
					// Wave gaussParam = GetGaussParamsFromPeakCoefs(currPeakType, peakCoefs)		// ST: 211105 - conversion may fail if the peak type is unknown => no problem, WPI is only needed if the peak type is changed in the MPF GUI
					// Variable width = gaussParam[1]												// ST: 211101 - gaussParam contains the same info as a row in W_AutoPeakInfo (width is the second value)
					// wpi[DimSize(wpi,0)]={{gaussParam[0]},{width},{gaussParam[2]},{width/2},{width/2}}
				endif
				
				if (WaveExists(constraints))													// convert constraints parameters for peaks K## -> P#K#
					FUNCREF MPF2_FuncInfoTemplate PKinfoFunc=$(currPeakType+PEAK_INFO_SUFFIX)
					nparams = ItemsInList(PKinfoFunc(PeakFuncInfo_ParamNames))
					for (j = 0; j < nparams; j++)
						replaceParamList[DimSize(replaceParamList,0)] = {{"K"+num2str(paramCount++)},{"P"+num2str(i)+"@"+num2str(j)}}
						//constraintsList = ReplaceString("K"+num2str(paramCount++),constraintsList,"P"+num2str(i)+"K"+num2str(j))
					endfor
				endif
			endfor
			
			for (i = DimSize(replaceParamList,0)-1; i > -1; i--)								// ST: 211023 - replace all parameters backwards to avoid replacing K10 after K1 etc.
				constraintsList = ReplaceString(replaceParamList[i][0],constraintsList,replaceParamList[i][1])
			endfor
			constraintsList = ReplaceString("@",constraintsList,"K")							// ST: 211023 - "@" was a placeholder for "K" to avoid double replacements => will still fail if already invalid parameters were in the constraints wave
			
			String/G SavedFunctionTypes = BLType+";"+peakTypeList
			
			if (WaveExists(constraints) && strlen(constraintsList))								// write constraints string if applicable
				String/G interPeakConstraints = constraintsList
				Variable/G MPF2ConstraintsShowing = 1											// apply constraints and make buttons visible
				Variable/G MPF2OptionsShowing = 1
			else
				Variable/G MPF2ConstraintsShowing = 0
				Variable/G MPF2OptionsShowing = 0
			endif
		SetDataFolder saveDF
		
		if (selWave == lastWave)
			break
		endif
		selWave += 1
	while(1)
	return 0
End

// ###############################################################################################

Function MPF2_CopyFromMPFSetFolder(resultDFBase, peakType, PeakCoefWaveFormat, BLType, BLCoefWaveName, yWaveList, xWaveList, InitialGuessOptions [, noiseEst, smFact, noiseEstMult, smFactMult, minAutoFindFraction, negativePeakGuess, doDerivedResults, doFitCurves, constraints, startPoint, endPoint])
	String resultDFBase						// uses the same basic input as MPF2_AutoMPFit()
	String peakType, PeakCoefWaveFormat
	String BLType, BLCoefWaveName
	String yWaveList, xWaveList				// not used here
	Variable noiseEst, smFact				// not used here
	Variable minAutoFindFraction			// not used here
	Variable InitialGuessOptions			// not used here
	Variable noiseEstMult, smFactMult		// not used here
	Variable negativePeakGuess				// not user here
	Variable doDerivedResults, doFitCurves
	Wave/Z/T constraints
	Variable startPoint, endPoint			// not used here
	
	Variable createFitW = !ParamIsDefault(doFitCurves) && doFitCurves > 0						// if set create fit waves later
	// ++++++++++++++++++++ find and select the desired folder to copy +++++++++++++++++++++++++++

	DFREF saveDF = GetDataFolderDFR()
	DFREF main = $kMPF_WorkingDir
	if (!DataFolderRefStatus(main))
		if (kMPF_ConvVerbose)
			Print "Multipeak Fit was not started yet. Create a fit set first."
		endif
		return -1
	endif
	NVAR setNum = main:currentSetNumber
	if (setNum == 0)
		if (kMPF_ConvVerbose)
			Print "No Multipeak Fit set found."
		endif
		return -1
	endif
	
	String allMPFitDFs = ReplaceString(",",StringByKey("FOLDERS", DataFolderDir(1,main), ":", ";"),";")
	allMPFitDFs = GrepList(allMPFitDFs,"^MPF_SetFolder_([0-9]+)$")								// exclude 'CP' checkpoint folders
	String resultDFs = ReplaceString(",",StringByKey("FOLDERS", DataFolderDir(1), ":", ";"),";")
	resultDFs = GrepList(resultDFs,"^"+resultDFBase+"_([0-9]+)$")								// match exact folder description: resultDFBase + "_n", where n is a number
	resultDFs = SortList(resultDFs, ";", 16) 													// sorting will make sure the NEW selection will use the highest available folder number
	Variable numDirs = ItemsInList(resultDFs)
	
	String selMPSetStr, selAutoFitStr															// user prompt -> select both the MPF set and AutoMPfit folder
	Prompt selMPSetStr,"Select the fit set you want to convert:",popup, allMPFitDFs
	Prompt selAutoFitStr,"Select the target AutoMPfit folder (overwrites contents):",popup, resultDFs + "NEW" + ";"
	DoPrompt/HELP="The selected fit set will be converted into an AutoMPFit result folder. Selecting 'NEW' creates a new result folder." "MPF GUI to AutoMPFit converter", selMPSetStr, selAutoFitStr
	if (V_Flag)
		return -1
	endif
	
	Variable wNum = 0, i
	if (CmpStr(selAutoFitStr,"NEW") == 0)														// create new results DF
		sscanf StringFromList(numDirs-1, resultDFs), resultDFBase+"_%d", wNum					// the current last folder
		DuplicateDataFolder/O=1 main:$(selMPSetStr), saveDF:$(resultDFBase+"_"+num2str(wNum+1))
		DFREF target = saveDF:$(resultDFBase+"_"+num2str(wNum+1))
	else
		DuplicateDataFolder/O=2 main:$(selMPSetStr), saveDF:$(selAutoFitStr)
		DFREF target = saveDF:$(selAutoFitStr)
	endif
	
	// +++++++++++++++++++ rename contents and fill standard variables +++++++++++++++++++++++++++
	
	SetDataFolder target
		Wave wpi = W_AutoPeakInfo
		
		Wave/Z/T MPF2_ConstraintsBackup
		if (WaveExists(MPF2_ConstraintsBackup) && WaveExists(constraints))						// copy constraints list into constraints wave
			Duplicate/O/T MPF2_ConstraintsBackup, constraints									// assumes a fit has been done just before the conversion took place
		endif
		
		Variable saveChisq = -1
		NVAR/Z MPF2_FitChiSq
		if (NVAR_Exists(MPF2_FitChiSq))
			saveChisq = MPF2_FitChiSq
		endif
				
		String saveFuncs = ""
		SVAR/Z SavedFunctionTypes
		if (SVAR_Exists(SavedFunctionTypes))
			saveFuncs = SavedFunctionTypes
		endif
		
		SVAR yWvName, XWvName
		String savYPath = yWvName
		String savXPath = XWvName
		
		STRUCT MPFitInfoStruct MPFs																// to get derived results later
		StructFill MPFs
		MPFs.NPeaks = DimSize(wpi,0)
		MPFs.ListOfFunctions = StringFromList(0,saveFuncs)+";"
		MPFs.ListOfCWaveNames = BLCoefWaveName+";"
		
		String wStr = WaveList("Peak "+"*",";","")
		String wList_coef = GrepList(wStr,"^Peak ([[:digit:]]+) Coefs$")
		String wList_eps  = GrepList(wStr,"^Peak ([[:digit:]]+) Coefseps$")
		Variable wItems = ItemsInList(wList_coef)
		for (i = 0; i < wItems; i++)															// rename peak coef waves
			String wCur_coef = StringFromList(i, wList_coef)
			String wCur_eps  = StringFromList(i, wList_eps)
			sscanf wCur_coef, "Peak %d Coefs", wNum
			
			sprintf wStr, PeakCoefWaveFormat, wNum
			Duplicate/O $wCur_coef, $(wStr)
			Duplicate/O $wCur_eps, $(wStr+"eps") 
			KillWaves/Z $wCur_coef, $wCur_eps
			
			Wave/Z fitPeak = $("Peak "+num2str(wNum))
			if (WaveExists(fitPeak))
				if (createFitW)																	// rename peak fit curve
					Duplicate/O fitPeak, $("MPF2PeakCurve"+num2str(wNum))
				endif
				KillWaves/Z fitPeak
			endif
			
			MPFs.ListOfCWaveNames += wStr+";"													// to get derived results later
			MPFs.ListOfFunctions += StringFromList(i+1,saveFuncs)+";"							// saveFuncs should have wItems+1 elements because of the baseline
		endfor
		
		// ++++++++ write folder notes from MPF information and create standard variables ++++++++
		
		String savNotes = "Y-Wave = "+savYPath
		if (strlen(savXPath))
			savNotes += "\rX-Wave = "+savXPath
		endif
		NVAR/Z MPF2_FitDate, XPointRangeBegin, XPointRangeEnd
		if (NVAR_Exists(MPF2_FitDate))
			savNotes += "\rFit completed = "+Secs2Time(MPF2_FitDate, 0)+" "+Secs2Date(MPF2_FitDate, 1)
		endif
		if (saveChisq != -1)
			savNotes += "\rChi square = "+num2str(saveChisq)
		endif
		Wave/Z yw = $savYPath
		if (WaveExists(yw))
			if ( (XPointRangeBegin != 0) || (XPointRangeEnd != numpnts(yw)-1) )
				savNotes += "\rFit range = "+num2str(XPointRangeBegin)+" to "+num2str(XPointRangeEnd)
			endif
		endif
		savNotes += "\rFitted points = "+num2str(abs(XPointRangeEnd-XPointRangeBegin+1))
		savNotes += "\rNo. of peaks = "+num2str(DimSize(wpi,0))
		SVAR/Z SavedFunctionTypes
		if (SVAR_Exists(SavedFunctionTypes))
			savNotes += "\rPeak type = "
			if (ItemsInList(RemoveFromList(StringFromList(1,SavedFunctionTypes),SavedFunctionTypes)) == 1)		// all the same peaks
				savNotes += StringFromList(1,SavedFunctionTypes)
			else
				for (i = 1; i < ItemsInList(SavedFunctionTypes); i++)
					savNotes += StringFromList(i,SavedFunctionTypes)+";"
				endfor
			endif
			savNotes += "\rBaseline type = "+StringFromList(0,SavedFunctionTypes)
		endif
		
		KillVariables/A/Z																		// clean-up of all globals and non-relevant waves from MPF
		KillStrings/A/Z
		KillWaves/Z MPF2_ConstraintsBackup, MPF2_ResultsListTitles, MPF2_ResultsListWave
		KillWaves/Z HoldStrings, constraintsTextWave, $(StringFromList(0,WaveList("Res_*",";","")))
		
		Variable/G MPFError = saveChisq > -1 ? 0 : -10001										// standard AutoMPFit globals (if ChiSq is not set, then probably there was a problem?)
		Variable/G gNumPeaks = DimSize(wpi,0)
		if (saveChisq != -1)
			Variable/G MPFChiSquare = saveChisq
		endif
		String/G usedYWave = savYPath
		String/G usedXWave = savXPath
		String/G notes = savNotes
		
		// +++++++++++++++++ create derived results and fit waves if desired +++++++++++++++++++++
		
		if (!ParamIsDefault(doDerivedResults) && doDerivedResults > 0 && strlen(saveFuncs))
			doMPF2DerivedResults(MPFs)
		endif

		Wave/Z fit_w = $(StringFromList(0,WaveList("fit_*",";","")))
		Wave/Z fitx_w = $(StringFromList(0,WaveList("fitX_*",";","")))
		Wave/Z bkg_w = $(StringFromList(0,WaveList("Bkg_*",";","")))
		
		if (WaveExists(fitx_w) && createFitW)
			Duplicate/O fitx_w, MPF2FitCurve_X
		elseif (WaveExists(fit_w) && createFitW)
			Duplicate/O fit_w, MPF2FitCurve_X
			Wave MPF2FitCurve_X
			MPF2FitCurve_X = x
		endif
		
		if (WaveExists(fit_w) && createFitW)
			Duplicate/O fit_w, MPF2FitCurve, MPF2FitCurve_PlusBL
			if (WaveExists(bkg_w))
				Wave MPF2FitCurve
				MPF2FitCurve -= bkg_w
			endif
		endif
		
		if (WaveExists(bkg_w) && createFitW)
			Duplicate/O bkg_w, MPF2BaselineCurve
		endif
		KillWaves/Z fit_w, fitx_w, bkg_w
	SetDataFolder saveDF
	
	return 0
End