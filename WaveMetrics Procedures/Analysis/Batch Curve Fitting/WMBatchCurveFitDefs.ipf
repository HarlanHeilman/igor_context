#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#pragma IgorVersion=9.00
#pragma version=9.00 // ship with Igor 9
#include <WMSelectorControlSet>

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// Change Log /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
// 10-17-2014 - Changed the default size of the Results Panel
// 10-20-2014 - Reduced the default size of the Results Panel to 600x615 (width x height)

////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// Module Constants //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////// version info ///////////////////////////
strconstant BCF_VERSIONSTRING="1.3"
constant BCF_UPDATEPANELVERSION=1.3

////////////// base directory ///////////////////////
strConstant constBatchCurveFitDir = "root:Packages:WMBatchCurveFit"
////////////// directory for individual batch runs //////////////
strConstant constBatchRunsDirName = "WMBatchCurveFitRuns"

constant WMBCFBaseFontSize = 12

////////////// string constants for various menus ////////////
// Initial guess constants
strConstant cCtrl_oneForAll = "Same Initial Guesses for Each Batch"
strConstant cCtrl_lastSuccess = "Use Coefficients from Last Successful Fit"
strConstant cCtrl_2DWave = "2D Wave, one column per fit"

// Constraint constants
strConstant cCtrl_setWithControls = "Use controls - common constraints for all fits"
strConstant cCtrl_setWithTextWave = "Use text wave - 2D wave for per fit constraints"

////////////////// control button enum-style descriptive constants
constant constShowDataDirButton = 1
constant constShowWaveSelectButton = 2
constant constShowXValsSelectButton = 3

//////////////// Intial Guess coefficient entry style //////////////////////
constant WMcoefStyleOneForAll = 1
constant WMcoefStyleLastGood = 2
constant WMcoefStylePerFitWave = 3

//////////////// Constraint entry style //////////////////////
constant WMconstrStyleControls = 1
constant WMconstrStyle2DWave = 2

/////////////// size constants
constant WMBCFRenamePanelWidth = 500
constant WMBCFRenamePanelHeight = 130

//////////// Error variables: bit-wise /////////////////////
constant constNoYWave = 1
constant constNoXWave = 2
constant constNoMaskWave = 4
constant constNoWeightWave = 8
constant constIndexOutOfRange = 16
constant constNoInitOnUserFunc = 32
constant constWaveDimMismatch = 64
constant constNoEpsilonWave = 128
constant constConstrLineOrPoly = 256

///////////// Standard wave names used to launch a batch //////////////
strConstant strConstCoefWaveName = "WMcoefWave"
strConstant strConstCoefHoldWaveName = "WMcoefHold"
strConstant strConstConstrWaveName = "WMconstraints"

// Results panel constants
constant WMnotConstantAxis = 0
constant WMmanualConstantAxis = 1
constant WMautoConstantAxis = 2

constant WMBatchFitExportPanelWidth = 600
constant WMBatchFitExportPanelHeight = 600

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////// Function for accessing module constants ////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Function WMBCFGetModuleConstant(constantName)
	String constantName
	
	strswitch (constantName)
		case "WMconstSingle2DInput":
			return WMconstSingle2DInput
			break
		case "WMconstCollection1DInput":
			return WMconstCollection1DInput
			break
		case "WMconstWaveScalingInput":
			return WMconstWaveScalingInput
			break
		case "WMconstCommonWaveInput":
			return WMconstCommonWaveInput
			break
		case "WMconstXyPairsInput":
			return WMconstXyPairsInput
			break
		default:
			return -1
	endswitch
End

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// Utility Functions //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function /S getAllDimLabels(aWave, dim)
	WAVE aWave
	Variable dim
	
	String ret=""
	Variable n = DimSize(aWave, dim), i

	for (i=0; i<n ;i+=1)
		ret += GetDimLabel(aWave, dim, i) +";"
	endfor
	
	return ret
End

///// Igor needs better associative array functions.  Here's my local attempt to provide some /////
///// keysOrValues = 0 for keys, 1 for values
Function /S getStringListKeysOrValues(sList, [keysOrValues, separator])
	String sList, separator
	Variable keysOrValues

	if (ParamIsDefault(separator))
		separator = ";"
	endif
	if (ParamIsDefault(keysOrValues))
		keysOrValues=0
	endif

	String ret=""
	Variable nItems = ItemsInList(sList, separator)
	Variable i, n
	String keyValPair
	for (i=0; i<nItems; i+=1) 
		keyValPair = StringFromList(i, sList)
		n = strsearch(keyValPair, "=", 0)
		if (keysOrValues==0)
			ret+=keyValPair[0,n-1]+separator
		else 
			ret+=keyValPair[n+1, strlen(keyValPair)-1]+separator
		endif
	endfor

	return ret	
End

Function isUserFitFunc(fitFunc)
	String fitFunc
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	Wave nInArgsBuiltIn = packageDFR:nInputArgsHashBuiltIn
	String userFitFuncsList = getAllDimLabels(nInArgsBuiltIn, 0)
	if (FindListItem(fitFunc, userFitFuncsList)<0)
		return 1
	else
		return 0
	endif
End

Function /S getUniqueStrLimNameAndTag(baseName, tagStr, maxLen, type)
	String baseName, tagStr
	Variable maxLen, type
	
	Variable iLast = strlen(tagStr)+2, i=0, iStart
	String ret = CleanupName(baseName, 1)
	String cleanedNamePlusTag
	do
		if (i==0)
			iStart = 0 
		else
			iStart = 10^i
		endif
		
		if (type==10) /// Notebooks do not seem to do liberal names, at least in UniqueName()
			cleanedNamePlusTag = CleanupName(ret[0,min(maxLen-iLast, strlen(ret)-1)]+tagStr, 0)
		else
			cleanedNamePlusTag = CleanupName(ret[0,min(maxLen-iLast, strlen(ret)-1)]+tagStr, 1)		
		endif

		ret = UniqueName(cleanedNamePlusTag, type, iStart)
		iLast += 1
		i+=1
	while (strlen(ret)==0 || strlen(ret) > maxLen)
					
	return ret
End

/////////////////// Make sure there is a batch folder in a given data folder /////////////////
//// If the batchDataDir doesn't exist for some reason - say the user deleted it, display an error alert
Function /DF getBatchFolderDFR(batchDataDir, batchName)
	String batchDataDir, batchName
		
	DFREF batchOutDFR		

	NewDataFolder /O $(ReplaceString("::", batchDataDir+":"+constBatchRunsDirName, ":"))
	String dataFolderStr = ReplaceString("::", batchDataDir+":"+constBatchRunsDirName+":"+PossiblyQuoteName(batchName), ":") 
	dataFolderStr = RemoveEnding(dataFolderStr, ":")
	NewDataFolder /O $dataFolderStr
	batchOutDFR = $dataFolderStr
	
	Return batchOutDFR
End

Function /DF getPackageBatchFolderDFR(batchDataDir, batchName)
	String batchDataDir, batchName

	String batchDataDirLeaf = ParseFilePath(0, batchDataDir, ":", 1, 0)
	if (!CmpStr(batchDataDirLeaf,"root"))
		batchDataDirLeaf=batchDataDirLeaf+"__"
	endif

	DFREF batchOutDFR = $(RemoveEnding("root:Packages:WMBatchCurveFit:DataFolders:"+batchDataDirLeaf+":"+PossiblyQuoteName(batchName), ":"))
	if (DataFolderRefStatus(batchOutDFR) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:WMBatchCurveFit
		NewDataFolder/O root:Packages:WMBatchCurveFit:DataFolders
		NewDataFolder/O $("root:Packages:WMBatchCurveFit:DataFolders:"+batchDataDirLeaf)
		NewDataFolder/O $(RemoveEnding("root:Packages:WMBatchCurveFit:DataFolders:"+batchDataDirLeaf+":"+PossiblyQuoteName(batchName), ":"))
		batchOutDFR = $(RemoveEnding("root:Packages:WMBatchCurveFit:DataFolders:"+batchDataDirLeaf+":"+PossiblyQuoteName(batchName), ":"))
	endif

	String dataFolderStr = RemoveEnding("root:Packages:WMBatchCurveFit:DataFolders:"+batchDataDirLeaf+":"+PossiblyQuoteName(batchName), ":")

	Variable localVar

	if (strlen(batchName)>0)
		//// Results Panel state variables ////
		localVar = NumVarOrDefault(dataFolderStr+":WMresultsPanelX", 50)
		Variable /G batchOutDFR:WMresultsPanelX = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMresultsPanelY", 50)
		Variable /G batchOutDFR:WMresultsPanelY = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMresultsPanelWidth", 600)
		Variable /G batchOutDFR:WMresultsPanelWidth = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMresultsPanelHeight", 615)
		Variable /G batchOutDFR:WMresultsPanelHeight = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMdoLogYaxis", 0)
		Variable /G batchOutDFR:WMdoLogYaxis = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMdoLogXaxis", 0)
		Variable /G batchOutDFR:WMdoLogXaxis = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMmanYMin", NaN)
		Variable /G batchOutDFR:WMmanYMin = localVar 
		localVar = NumVarOrDefault(dataFolderStr+":WMmanYMax", NaN)
		Variable /G batchOutDFR:WMmanYMax = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMmanXMin",  NaN)
		Variable /G batchOutDFR:WMmanXMin = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMmanXMax", NaN)
		Variable /G batchOutDFR:WMmanXMax = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMconstantYaxis", WMnotConstantAxis)
		Variable /G batchOutDFR:WMconstantYaxis = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMconstantXaxis", WMnotConstantAxis)
		Variable /G batchOutDFR:WMconstantXaxis = localVar
				
		localVar = NumVarOrDefault(dataFolderStr+":WMminRange", NaN)
		Variable /G batchOutDFR:WMminRange = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMmaxRange", NaN)
		Variable /G batchOutDFR:WMmaxRange = localVar
		localVar = NumVarOrDefault(dataFolderStr+":WMdoCovar", 0)
		Variable /G batchOutDFR:WMdoCovar = localVar
	endif

	Return batchOutDFR
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// Get Set Package Data Folder ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function InitBatchCurvePackageData(dfr)
	DFREF dfr
	
	String packageDFRString = GetDataFolder(1, dfr)

	///// data variables /////
	Variable localVar
	String localStr

	localStr = StrVarOrDefault(packageDFRString+"WMbatchDataDir", GetDataFolder(1))
	String /G dfr:WMbatchDataDir = localStr 
	localStr = StrVarOrDefault(packageDFRString+"WMcurrBatchName", "batchCurveFitRun0")
	String /G dfr:WMcurrBatchName = localStr
	localVar = NumVarOrDefault(packageDFRString+"WMhaltOnErr", 0)
	Variable /G dfr:WMHaltOnErr = localVar
	localVar = NumVarOrDefault(packageDFRString+"WMdoCovar", 0)
	Variable /G dfr:WMdoCovar = localVar	
	localVar = NumVarOrDefault(packageDFRString+"WMMaxIterations", 40)
	Variable /G dfr:WMMaxIterations = localVar
	localVar = NumVarOrDefault(packageDFRString+"WMnCoefs", 0)
	Variable /G dfr:WMnCoefs = localVar
		
	// variables for 2D coefficient and constraint waves
	// The WSPopup only displays the wave name, but not the full wave path (in the case of selecting a Dir it does show the full path)
	// 	Full path is stored, but in a userstring.  Accessing it would be a hack.  Without mucking with the WSPopup we'll have to use 2 global strings -
	//   one for the WSPopup, one for storing the full name
	localStr = StrVarOrDefault(packageDFRString+"WMInitGuessWaveName", "")
	String /G dfr:WMInitGuessWaveName = localStr
	localStr = StrVarOrDefault(packageDFRString+"WMInitGuessWaveFullPath", "")
	String /G dfr:WMInitGuessWaveFullPath = localStr 	
	localStr = StrVarOrDefault(packageDFRString+"WMConstrWaveName", "")
	String /G dfr:WMConstrWaveName = localStr 
	localStr = StrVarOrDefault(packageDFRString+"WMConstrWaveFullPath", "")
	String /G dfr:WMConstrWaveFullPath = localStr 	
	
	Wave /Z testExistRef = $(packageDFRString+"WMInitCoefs")
	if (!WaveExists(testExistRef))
		NVAR wmncoefs = dfr:WMnCoefs
		Make /D/O/N=(wmncoefs) dfr:WMInitCoefs
		Wave wminitcoefs = dfr:WMInitCoefs
		wminitcoefs = NaN
	endif	
	
	Wave /Z testExistRef = $(packageDFRString+strConstConstrWaveName)
	if (!WaveExists(testExistRef))
		NVAR wmncoefs = dfr:WMnCoefs
		Make /D/O/N=(wmncoefs, 2) dfr:$strConstConstrWaveName //WMConstraints
		Wave wmconstraints = dfr:$strConstConstrWaveName //WMConstraints
		wmconstraints = NaN
	endif
	
	localStr = StrVarOrDefault(packageDFRString+"WMConstraintStr", "")
	String /G dfr:WMConstraintStr = localStr 	
	
	localVar = NumVarOrDefault(packageDFRString+"WMXOffset", NaN)
	Variable /G dfr:WMXOffset = localVar

	Wave /Z/T testExistRef0 = $(packageDFRString+"WMbatchWaveNames")
	if (!WaveExists(testExistRef0))
		Make /T/O dfr:WMbatchWaveNames 
	endif
	localStr = StrVarOrDefault(packageDFRString+"WMfitFunc", "gauss")
	String /G dfr:WMfitFunc = localStr

	Variable nBI=16
	Make /O/N=(nBI) dfr:nInputArgsHashBuiltIn/WAVE=niahbi
	
	SetDimLabel 0, 0, gauss, niahbi
	SetDimLabel 0, 1, lor, niahbi
	SetDimLabel 0, 2, Voigt, niahbi
	SetDimLabel 0, 3, exp, niahbi
	SetDimLabel 0, 4, dblexp, niahbi
	SetDimLabel 0, 5, dblexp_peak, niahbi
	SetDimLabel 0, 6, sin, niahbi
	SetDimLabel 0, 7, line, niahbi
	SetDimLabel 0, 8, poly, niahbi
	SetDimLabel 0, 9, poly_XOffset, niahbi
	SetDimLabel 0, 10, HillEquation, niahbi	
	SetDimLabel 0, 11, Sigmoid, niahbi
	SetDimLabel 0, 12, Power, niahbi
	SetDimLabel 0, 13, LogNormal, niahbi
//	SetDimLabel 0, 12, Gauss2D, niahbi
//	SetDimLabel 0, 13, Poly2D, niahbi
	SetDimLabel 0, 14, exp_XOffset, niahbi
	SetDimLabel 0, 15, dblexp_XOffset, niahbi

	niahbi[%gauss] = 4
	niahbi[%lor] = 4
	niahbi[%Voigt] = 5
	niahbi[%exp] = 3
	niahbi[%dblexp] = 5
	niahbi[%dblexp_peak] = 5
	niahbi[%sin] = 4
	niahbi[%line] = 2
	niahbi[%poly] = NaN
	niahbi[%poly_XOffset] = NaN
	niahbi[%HillEquation] = 4
	niahbi[%Sigmoid] = 4
	niahbi[%Power] = 3
	niahbi[%LogNormal] = 4
//	niahbi[%gauss2D] = 7
//	niahbi[%poly2DN] = NaN
	niahbi[%exp_XOffset] = 3
	niahbi[%dblexp_XOffset] = 5
	
	Make /T/O/N=(nBI) dfr:inputArgsTextDescriptionBuiltIn/WAVE=inArgsTxtBI

	SetDimLabel 0, 0, gauss, inArgsTxtBI
	SetDimLabel 0, 1, lor, inArgsTxtBI
	SetDimLabel 0, 2, Voigt, inArgsTxtBI
	SetDimLabel 0, 3, exp, inArgsTxtBI
	SetDimLabel 0, 4, dblexp, inArgsTxtBI
	SetDimLabel 0, 5, dblexp_peak, inArgsTxtBI
	SetDimLabel 0, 6, sin, inArgsTxtBI
	SetDimLabel 0, 7, line, inArgsTxtBI
	SetDimLabel 0, 8, poly, inArgsTxtBI
	SetDimLabel 0, 9, poly_XOffset, inArgsTxtBI
	SetDimLabel 0, 10, HillEquation, inArgsTxtBI	
	SetDimLabel 0, 11, Sigmoid, inArgsTxtBI
	SetDimLabel 0, 12, Power, inArgsTxtBI
	SetDimLabel 0, 13, LogNormal, inArgsTxtBI
//	SetDimLabel 0, 12, gauss2D, inArgsTxtBI
//	SetDimLabel 0, 13, poly2D, inArgsTxtBI
	SetDimLabel 0, 14, exp_XOffset, inArgsTxtBI
	SetDimLabel 0, 15, dblexp_XOffset, inArgsTxtBI

	inArgsTxtBI[%gauss] = "y = y0+A*exp(-((x-x0)/width)^2)"
	inArgsTxtBI[%lor] = "y = y0+A/((x-x0)^2+B)"
	inArgsTxtBI[%Voigt] = "y = y0+(2*Area/Wg)*sqrt(ln(2)/pi)*Voigt((2*sqrt(ln(2))/Wg)*(x-x0), (Wl/Wg)*2*sqrt(ln(2)))"
	inArgsTxtBI[%exp] = "y = y0+A*exp(-invtau*x)"
	inArgsTxtBI[%dblexp] = "y = y0+A1*exp(-invtau1*x)+A2*exp(-invtau2*x)"
	inArgsTxtBI[%dblexp_peak] = "y = y0+A1*(-exp(-(x-x0)/tau1) + exp(-(x-x0)/tau2))"
	inArgsTxtBI[%sin] = "y = y0+A*sin(freq*x+phase)"
	inArgsTxtBI[%line] = "y = y0+slope*x"
	inArgsTxtBI[%poly] = "y = y0+deg1*x+deg2*x^2+..."
	inArgsTxtBI[%poly_XOffset] = "y = y0+deg1*(x-x0)+deg2*(x-x0)^2+..."
	inArgsTxtBI[%HillEquation] = "base+(max-base)*(x^rate/(1+(x^rate+xHalf^rate)))"
	inArgsTxtBI[%Sigmoid] = "y = base+max/(1+exp(-(x-x0)/rate))"
	inArgsTxtBI[%Power] = "y = y0+A*x^pow"
	inArgsTxtBI[%LogNormal] = "y = y0+A*exp(-(ln(x/x0)/width)^2)"
//	inArgsTxtBI[%gauss2D] = "y = K0+K1*exp((-1/(2*(1-K6^2)))*(((x-K2)/K3)^2 + ((y-K4)/K5)^2 - (2*K6*(x-K2)*(y-K4)/(K3*K5))))"
//	inArgsTxtBI[%poly2DN] = "y = K0+K1*x+K2*y+K3*x^2+K4*xy+K5*y^2+..."
	inArgsTxtBI[%exp_XOffset] = "y = y0+A*exp(-(x-x0)/tau)"//"y = K0+K1*exp(-(x-x0)/K2)"
	inArgsTxtBI[%dblexp_XOffset] = "y = y0+A1*exp(-(x-x0)/tau1)+A2*exp(-(x-x0)/tau2)"

	Make /T/O/N=(nBI) dfr:coefficientNamesBuiltIn/WAVE=coefNamesBI

	SetDimLabel 0, 0, gauss, coefNamesBI
	SetDimLabel 0, 1, lor, coefNamesBI
	SetDimLabel 0, 2, Voigt, coefNamesBI
	SetDimLabel 0, 3, exp, coefNamesBI
	SetDimLabel 0, 4, dblexp, coefNamesBI
	SetDimLabel 0, 5, dblexp_peak, coefNamesBI
	SetDimLabel 0, 6, sin, coefNamesBI
	SetDimLabel 0, 7, line, coefNamesBI
	SetDimLabel 0, 8, poly, coefNamesBI
	SetDimLabel 0, 9, poly_XOffset, coefNamesBI
	SetDimLabel 0, 10, HillEquation, coefNamesBI	
	SetDimLabel 0, 11, Sigmoid, coefNamesBI
	SetDimLabel 0, 12, Power, coefNamesBI
	SetDimLabel 0, 13, LogNormal, coefNamesBI
	SetDimLabel 0, 14, exp_XOffset, coefNamesBI
	SetDimLabel 0, 15, dblexp_XOffset, coefNamesBI

	coefNamesBI[%gauss] = "y0;A;x0;width"
	coefNamesBI[%lor] = "y0;A;x0;B"
	coefNamesBI[%Voigt] = "y0;Area;X0;G_fwhm;Wl/Wg"
	coefNamesBI[%exp] = "y0;A;invtau"
	coefNamesBI[%dblexp] = "y0;A1;invtau1;A2;invtau2"
	coefNamesBI[%dblexp_peak] = "y0;A;tau1;tau2;x0"
	coefNamesBI[%sin] = "y0;A;freq;phase"
	coefNamesBI[%line] = "y0;slope"
	coefNamesBI[%poly] = "y0;deg1;deg2"
	coefNamesBI[%poly_XOffset] = "y0;deg1;deg2"
	coefNamesBI[%HillEquation] = "base;max;rate;xHalf"
	coefNamesBI[%Sigmoid] = "base;max;x0;rate"
	coefNamesBI[%Power] = "y0;A;pow"
	coefNamesBI[%LogNormal] = "y0;A;x0;width"
	coefNamesBI[%exp_XOffset] = "y0;A;tau"
	coefNamesBI[%dblexp_XOffset] = "y0;A1;tau1;A2;tau2"

	///// Allow for user defined fit functions
	Wave /Z testExistRef1 = $(packageDFRString+"nInputArgsHash")
	Wave /Z/T testExistRef2 = $(packageDFRString+"inputArgsTextDescription")
	Wave /Z/T testExistRef3 = $(packageDFRString+"coefficientNames")	
	if (!WaveExists(testExistRef1) || !WaveExists(testExistRef2) || !WaveExists(testExistRef3))
		Duplicate /O niahbi dfr:nInputArgsHash
		Duplicate /O inArgsTxtBI dfr:inputArgsTextDescription
		Duplicate /O coefNamesBI dfr:coefficientNames

		updateFitFunctions()
	endif
End

Structure curveFitDialogComments
	Variable isFitFunc
	Variable isFromCurveFitDialogComplete
	String equationText
	Variable nIndependentVars 
	Wave /T independentVarNames
	Variable nCoefs
	Wave /T coefNames
EndStructure

Function GetCurveFitFuncInfo(FunctionName, returnStruct)
	String FunctionName
	Struct curveFitDialogComments & returnStruct
	
	Variable i, j
	Variable commentPos, varUtil
	String currFuncText = ProcedureText(FunctionName, 0, "[ProcGlobal]")
	String currFuncEquation, strUtil
	
	String aLine = StringFromList(0, currFuncText, "\r")
	returnStruct.isFitFunc = stringmatch(aLine, "*:*FitFunc") 
	if (!returnStruct.isFitFunc)
		return 0
	endif
	
	Variable nComments = 0
	Variable nCoefsEstimate = 0
	String coefWaveName = ""
	
	//// get the name given to the coefficient wave
	aLine = StringFromList(1, currFuncText, "\r")
	commentPos = strsearch(aLine, "Wave ", 0, 2)  
	sscanf aLine[commentPos+4, strlen(aLine)-1], "%s", strUtil
	coefWaveName = ReplaceString(" ", strUtil, "") 
	coefWaveName = ReplaceString(",", strUtil, "") 
	
	// initialize the number of coefficients
	returnStruct.nCoefs=0
	
	for (i=2; i<ItemsInList(currFuncText, "\r"); i+=1)
		aLine = StringFromList(i, currFuncText, "\r")
		if (IsEndLine(aLine))
			break
		endif	
	
		//// try to determine the number of coefficients from the text of the function
		j=0
		commentPos = strsearch(aLine, "//", 0)
		do 
			j = strsearch(aLine, coefWaveName, j, 2)
			if (commentPos >= 0 && commentPos < j)  // don't count comments
				break
			endif
			if (j >= 0)
				sscanf aLine[j, strlen(aLine)-1], coefWaveName+"[%d]", varUtil
				if (V_Flag > 0  && varUtil >= nCoefsEstimate)
					nCoefsEstimate = varUtil + 1
				endif
				j += strlen(coefWaveName)				
			endif
		while (j>0)
		
		//// read curve fit comments
		commentPos = strsearch(aLine, "//CurveFitDialog/ Equation:", 0, 2)
		if (commentPos >= 0)
			nComments +=1
			aLine = StringFromList(i+1, currFuncText, "\r")
			commentPos = strsearch(aLine, "//CurveFitDialog/", 0, 2)
			returnStruct.equationText = aLine[commentPos+18, strlen(aLine)-1]
		endif			
		
		commentPos = strsearch(aLine, "//CurveFitDialog/ Independent Variables ", 0, 2)
		if (commentPos >= 0)
			nComments +=1
			sscanf aLine[commentPos, strlen(aLine)-1], "//CurveFitDialog/ Independent Variables %d", varUtil
			returnStruct.nIndependentVars = varUtil
			
			Make /FREE/O/T/N=(returnStruct.nIndependentVars) returnStruct.independentVarNames 
			for (j=1; j <= returnStruct.nIndependentVars; j+=1)
				aLine = StringFromList(i+j, currFuncText, "\r")
				commentPos = strsearch(aLine, "//CurveFitDialog/ ", 0, 2)  
				
				sscanf aLine[commentPos+18, strlen(aLine)-1], "%s", strUtil   
				returnStruct.independentVarNames[j-1] = strUtil
			endfor
		endif
			
		commentPos = strsearch(aLine, "//CurveFitDialog/ Coefficients", 0, 2)
		if (commentPos >= 0)
			nComments += 1
			sscanf aLine[commentPos+31, strlen(aLine)-1], "%d", varUtil
			returnStruct.nCoefs = varUtil
			
			Make /FREE/O/T/N=(returnStruct.nCoefs) returnStruct.coefNames
			for (j=1; j <= returnStruct.nCoefs; j+=1)
				aLine = StringFromList(i+j, currFuncText, "\r")
				commentPos = strsearch(aLine, "//CurveFitDialog/ ", 0, 2)  
				
				sscanf aLine[commentPos+18, strlen(aLine)-1], "%*s = %s", strUtil 
				 returnStruct.coefNames[j-1] = strUtil
			endfor
		endif
	endfor
	
	returnStruct.isFromCurveFitDialogComplete = nComments>=3
	
	if (returnStruct.nCoefs == 0)
		returnStruct.nCoefs = nCoefsEstimate
	endif
	
	return 1
End

Structure batchDataStruct
	WAVE /T batchYWaveNames
	WAVE /T batchXWaveNames
	WAVE /T batchMaskWaveNames
	WAVE /T batchWeightWaveNames
	WAVE coefWave			// 1D wave with same init guess or last successful for each fit
	WAVE coefHold
	Variable yValsSourceType
	Variable xValsSourceType
	Variable maskSourceType
	Variable weightSourceType
	Variable nWaves
	String batchDir
	Variable coefStyle
	String fitFunc
	Variable nInCoefs
	Variable xoffset
	WAVE epsilon
	Variable haltOnErr
	Variable maxIter
	Wave /T yFilterSettings
	Wave /T xFilterSettings
	Wave /T maskFilterSettings
	Wave /T weightFilterSettings	
	
	// initial coefficient guess entry style
	String coefWaveFullPath			// for 2D per-fit constraint inputs
	
	// constraint variables
	Variable constrEntryStyle
	WAVE constraintsControlWave	
	String constraintStr
	WAVE /T constraintsTextWave
	String constrTextWaveFullPath
	
	// fit range limits variables
	Variable doRange
	Variable minRange
	Variable maxRange
	
	// output options
	Variable doCovar
EndStructure

Function initBatchDataStruct(batchInfo)
	Struct batchDataStruct & batchInfo

	batchInfo.yValsSourceType = 0
	batchInfo.xValsSourceType = 0
	batchInfo.maskSourceType = 0
	batchInfo.weightSourceType = 0
	batchInfo.nWaves = 0
	batchInfo.batchDir = ""
	batchInfo.coefStyle = WMcoefStyleOneForAll
	batchInfo.fitFunc = ""
	batchInfo.nInCoefs = 0
	batchInfo.xoffset = 0
	batchInfo.haltOnErr = 0
	batchInfo.maxIter = 40
	
	batchInfo.coefWaveFullPath = ""				// for 2D per-fit init coef guess wave - if exists	
	batchInfo.constrEntryStyle = WMconstrStyleControls
	batchInfo.constraintStr = ""
	batchInfo.constrTextWaveFullPath = ""
	
	batchInfo.doRange=0
	batchInfo.minRange=0
	batchInfo.maxRange=0
	batchInfo.doCovar=0
End

Function WMGetNWaves(batchDir, batchName)
	String batchDir, batchName
	
	DFREF batchDFR = getBatchFolderDFR(batchDir, batchName)
	
	NVAR /Z yValsSourceType = batchDFR:WMyValsSourceType
	NVAR /Z xValsSourceType = batchDFR:WMxValsSourceType
	
	Make /FREE/WAVE /N=0 batchWaves
	Make /FREE/WAVE /N=0 batchXWaves
	getYandXBatchData(batchDir, batchName, batchWaves, batchXWaves)
	
	Variable isXY = (xValsSourceType & WMconstXyPairsInput)/WMconstXyPairsInput
	Variable is2D = (yValsSourceType & WMconstSingle2DInput)/WMconstSingle2DInput
	Variable nWaves
	if (is2D)
		WAVE currWave2D = batchWaves[0]
		nWaves = floor(DimSize(currWave2D, 1)/(1+isXY))
	else
		nWaves = DimSize(batchWaves, 0)
	endif
	
	return nWaves
End

///////// optional yWaves, xWaves, maskWaves and weightWaves allow saving without having to get the names from the struct - this func will do it for you!
Function WMStoreBatchData(batchInfo, batchName, [yWaves, xWaves, maskWaves, weightWaves, yFilterWave, xFilterWave, maskFilterWave, weightFilterWave])
	Struct batchDataStruct & batchInfo
	String batchName
	WAVE /Z/Wave yWaves, xWaves, maskWaves, weightWaves, yFilterWave, xFilterWave, maskFilterWave, weightFilterWave
	
	DFREF batchOutDFR = getBatchFolderDFR(batchInfo.batchDir, PossiblyQuoteName(batchName))

	// fit function info
	if (numtype(strlen(batchInfo.fitFunc))!=2)
		String /G batchOutDFR:WMfitFunc=batchInfo.fitFunc
	endif
	if (numtype(batchInfo.nInCoefs)!=2)
		Variable /G batchOutDFR:WMnInCoefs=batchInfo.nInCoefs
	endif
	
	///// input data folder name
	if (numtype(strlen(batchInfo.batchDir))!=2)
		String /G batchOutDFR:WMbatchDir=batchInfo.batchDir
	endif	

	///// input type and number of fits (waves)
	Variable /G batchOutDFR:WMnWaves = batchInfo.nWaves	// this may need updating based on input type and actual inputs
	NVAR WMnWaves = batchOutDFR:WMnWaves
	
	/////  Y data fit waves ///// -- prefer passed in args over batchInfo struct data
	// input type
	Variable /G batchOutDFR:WMyValsSourceType=batchInfo.yValsSourceType
	// input info
	if (!ParamIsDefault(yWaves) &&WaveExists(yWaves))
		Make /T/O/N=(numpnts(yWaves)) batchOutDFR:WMbatchWaveNames
		Wave /T yWaveNames = batchOutDFR:WMbatchWaveNames
		Variable i
		for (i=0; i<numpnts(yWaves); i+=1)
			yWaveNames[i] = NameOfWave(yWaves[i])
		endfor

		Variable isXY = (batchInfo.xValsSourceType & WMconstXyPairsInput)/WMconstXyPairsInput
		Variable is2D = (batchInfo.yValsSourceType & WMconstSingle2DInput)/WMconstSingle2DInput

		if (is2D)
			WAVE /Z currWave2D = yWaves[0]
			if (waveExists(currWave2D))
				WMnWaves = floor(DimSize(currWave2D, 1)/(1+isXY))
			else
				WMnWaves = 0
			endif
		else
			WMnWaves = DimSize(yWaves, 0)
		endif
	elseif (WaveExists(batchInfo.batchYWaveNames))
		Duplicate batchInfo.batchYWaveNames batchOutDFR:WMbatchWaveNames
	else
		KillWaves /Z batchOutDFR:WMbatchWaveNames
	endif
	
	/////  X data, it exists ///// -- prefer passed in args over batchInfo struct data
	// input type
	Variable /G batchOutDFR:WMxValsSourceType=batchInfo.xValsSourceType
	// x offset info
	Variable /G batchOutDFR:WMXOffset=batchInfo.xoffset
	// input info
	if (!ParamIsDefault(xWaves) && WaveExists(xWaves))
		Make /T/O/N=(numpnts(xWaves)) batchOutDFR:WMbatchXWaveNames
		Wave /T xWaveNames = batchOutDFR:WMbatchXWaveNames
		for (i=0; i<numpnts(xWaves); i+=1)
			xWaveNames[i] = NameOfWave(xWaves[i])
		endfor
	elseif (WaveExists(batchInfo.batchXWaveNames))
		Duplicate batchInfo.batchXWaveNames batchOutDFR:WMbatchXWaveNames
	else
		KillWaves /Z batchOutDFR:WMbatchXWaveNames
	endif
	
	///// Mask Info /////
	// input type
	Variable /G batchOutDFR:WMmaskSourceType=batchInfo.maskSourceType
	// input info
	if (!ParamIsDefault(maskWaves) && WaveExists(maskWaves))
		Make /T/O/N=(numpnts(maskWaves)) batchOutDFR:WMbatchMaskWaveNames
		Wave /T maskWaveNames = batchOutDFR:WMbatchMaskWaveNames
		for (i=0; i<numpnts(maskWaves); i+=1)
			maskWaveNames[i] = NameOfWave(maskWaves[i])
		endfor
	elseif (WaveExists(batchInfo.batchMaskWaveNames))
		Duplicate batchInfo.batchMaskWaveNames batchOutDFR:WMbatchMaskWaveNames
	else
		KillWaves /Z batchOutDFR:WMbatchMaskWaveNames
	endif
	
	///// Weight Info /////
	// input type
	Variable /G batchOutDFR:WMweightSourceType=batchInfo.weightSourceType	
	// input info
	if (!ParamIsDefault(weightWaves) && WaveExists(weightWaves))
		Make /T/O/N=(numpnts(weightWaves)) batchOutDFR:WMbatchWeightWaveNames
		Wave /T weightWaveNames = batchOutDFR:WMbatchweightWaveNames
		for (i=0; i<numpnts(weightWaves); i+=1)
			weightWaveNames[i] = NameOfWave(weightWaves[i])
		endfor
	elseif (WaveExists(batchInfo.batchWeightWaveNames))
		Duplicate batchInfo.batchWeightWaveNames batchOutDFR:WMbatchWeightWaveNames
	else 
		KillWaves /Z batchOutDFR:WMbatchWeightWaveNames
	endif

	///// Coefficient Hold Info /////
	if (WaveExists(batchInfo.coefHold))
		Duplicate /O batchInfo.coefHold batchOutDFR:WMcoefHoldStored
	else
		KillWaves /Z batchOutDFR:WMcoefHoldStored
	endif

	///// Initial Coefficient Guess Info /////
	Variable /G batchOutDFR:WMcoefStyle=batchInfo.coefStyle						// initial guess input style
	
	if (numtype(strlen(batchInfo.coefWaveFullPath))!=2)
		String /G batchOutDFR:WMcoefWaveFullPath	= batchInfo.coefWaveFullPath		// for 2D per-fit init coef guess wave - if exists
	endif

	// A 1D wave representing the initial guess settings in the controls	
	if (WaveExists(batchInfo.coefWave))
		Duplicate /O batchInfo.coefWave batchOutDFR:WMcoefWaveStored
	else
	 	KillWaves /Z batchOutDFR:WMcoefWaveStored
	endif
	
	///// Constraint info /////
	if (batchInfo.constrEntryStyle>=WMconstrStyleControls && batchInfo.constrEntryStyle <= WMconstrStyle2DWave)
		Variable /G batchOutDFR:WMconstrEntryStyle = batchInfo.constrEntryStyle
	endif
	// A nCoefs x 2 wave for the min/max constraint info from the listbox
	if (WaveExists(batchInfo.constraintsControlWave))
		Duplicate /O batchInfo.constraintsControlWave batchOutDFR:WMconstraintsControlWaveStored
	else
	 	KillWaves /Z batchOutDFR:WMconstraintsControlWaveStored
	endif
	
	// A string for inputing inter-coeficient constraints
	if (numtype(strlen(batchInfo.constraintStr)) != 2)
		String /G batchOutDFR:WMConstraintStr = batchInfo.constraintStr
	endif
	// A string for the location of a 2D per-fit constraint text wave
	if (numtype(strlen(batchInfo.constrTextWaveFullPath)) != 2)
		String /G batchOutDFR:WMconstrTextWaveFullPath = batchInfo.constrTextWaveFullPath
	endif

	if (waveExists(batchInfo.epsilon))
		Duplicate /O batchInfo.epsilon batchOutDFR:WMepsilon
	else
		KillWaves /Z batchOutDFR:WMepsilon
	endif

	Variable /G batchOutDFR:WMhaltOnErr=batchInfo.haltOnErr
	Variable /G batchOutDFR:WMmaxIter=batchInfo.maxIter
	if (!ParamIsDefault(yFilterWave))
		Duplicate /O yFilterWave batchOutDFR:WMyFilterSettings
	elseif (WaveExists(batchInfo.yFilterSettings))
		Duplicate /O batchInfo.yFilterSettings batchOutDFR:WMyFilterSettings
	endif
	
	if (!ParamIsDefault(xFilterWave))
		Duplicate /O xFilterWave batchOutDFR:WMxFilterSettings
	elseif (WaveExists(batchInfo.xFilterSettings))
		Duplicate /O batchInfo.xFilterSettings batchOutDFR:WMxFilterSettings
	endif
	
	if (!ParamIsDefault(maskFilterWave))
		Duplicate /O maskFilterWave batchOutDFR:WMmaskFilterSettings
	elseif (WaveExists(batchInfo.maskFilterSettings))
		Duplicate /O batchInfo.maskFilterSettings batchOutDFR:WMmaskFilterSettings
	endif
	
	if (!ParamIsDefault(weightFilterWave))
		Duplicate /O weightFilterWave batchOutDFR:WMweightFilterSettings
	elseif (WaveExists(batchInfo.weightFilterSettings))
		Duplicate /O batchInfo.weightFilterSettings batchOutDFR:WMweightFilterSettings
	endif
	
	Variable /G batchOutDFR:WMdoRange = batchInfo.doRange
	Variable /G batchOutDFR:WMminRange = batchInfo.minRange
	Variable /G batchOutDFR:WMmaxRange = batchInfo.maxRange
	Variable /G batchOutDFR:WMdoCovar = batchInfo.doCovar
End

// Gets the source data for the batch and places it the batchYData and batchXData /wave waves
Function getYandXBatchData(batchDataDir, batchName, batchYData, batchXData)
	String batchDataDir, batchName
	Wave /Wave batchYData, batchXData
	
	DFREF batchOutDFR = getBatchFolderDFR(batchDataDir, batchName)//, 1)
	
	Variable i
	String waveStr
	Wave /T/Z batchYWaveNames = batchOutDFR:WMbatchWaveNames
	if (waveExists(batchYWaveNames) && numPnts(batchYWaveNames))
		Redimension /N=(numPnts(batchYWaveNames)) batchYData
		for (i=0; i<numPnts(batchYWaveNames); i+=1)
			waveStr = ReplaceString("::", batchDataDir+":"+PossiblyQuoteName(batchYWaveNames[i]), ":")
			batchYData[i] = $waveStr
		endfor
	endif
	
	Wave /T/Z batchXWaveNames = batchOutDFR:WMbatchXWaveNames
	if (waveExists(batchXWaveNames) && numPnts(batchXWaveNames))
		Redimension /N=(numPnts(batchXWaveNames)) batchXData
		for (i=0; i<numPnts(batchXWaveNames); i+=1)
			waveStr = ReplaceString("::", batchDataDir+":"+PossiblyQuoteName(batchXWaveNames[i]), ":")
			batchXData[i] = $waveStr
		endfor
	endif	
End

Function getMaskandWeightWaves(batchDataDir, batchName, maskWaves, weightWaves)
	String batchDataDir, batchName
	Wave /Wave maskWaves, weightWaves

	DFREF batchOutDFR = getBatchFolderDFR(batchDataDir, batchName)//, 1)
	
	Variable i
	String waveStr
	Wave /T/Z batchMaskWaveNames = batchOutDFR:WMbatchMaskWaveNames
	if (waveExists(batchMaskWaveNames) && numPnts(batchMaskWaveNames))
		Redimension /N=(numPnts(batchMaskWaveNames)) maskWaves
		for (i=0; i<numPnts(batchMaskWaveNames); i+=1)
			waveStr = ReplaceString("::", batchDataDir+":"+PossiblyQuoteName(batchMaskWaveNames[i]), ":")
			maskWaves[i] = $waveStr
		endfor
	endif
	
	Wave /T/Z batchWeightWaveNames = batchOutDFR:WMbatchWeightWaveNames
	if (waveExists(batchWeightWaveNames) && numPnts(batchWeightWaveNames))
		Redimension /N=(numPnts(batchWeightWaveNames)) weightWaves
		for (i=0; i<numPnts(batchWeightWaveNames); i+=1)
			waveStr = ReplaceString("::", batchDataDir+":"+PossiblyQuoteName(batchWeightWaveNames[i]), ":")
			weightWaves[i] = $waveStr
		endfor
	endif
End

Function getBatchData(batchDataDir, batchName, batchInfoReturn)
	String batchDataDir, batchName
	Struct batchDataStruct & batchInfoReturn
	
	DFREF batchOutDFR = getBatchFolderDFR(batchDataDir, batchName)
	String batchOutDFRStr = GetDataFolder(1, batchOutDFR)
	
	WAVE /T/Z batchInfoReturn.batchYWaveNames = batchOutDFR:WMbatchWaveNames
	WAVE /T/Z batchInfoReturn.batchXWaveNames = batchOutDFR:WMbatchXWaveNames
	WAVE /T/Z batchInfoReturn.batchMaskWaveNames = batchOutDFR:WMbatchMaskWaveNames
	WAVE /T/Z batchInfoReturn.batchWeightWaveNames = batchOutDFR:WMbatchWeightWaveNames
	// if the init guess entry mode is cCtrl_2DWave its a 2D wave with, presumably, 1 column/fit.  Otherwise its a 1D wave
	WAVE /Z batchInfoReturn.coefHold = batchOutDFR:WMcoefHoldStored
	
	///// Initial Coefficient Guess Info /////
	// initial guess input style
	NVAR /Z cStyle = batchOutDFR:WMcoefStyle
	batchInfoReturn.coefStyle = NVAR_Exists(cStyle) ? cStyle : WMcoefStyleOneForAll
	if (batchInfoReturn.coefStyle<WMcoefStyleOneForAll || batchInfoReturn.coefStyle > WMcoefStylePerFitWave)
		batchInfoReturn.coefStyle = WMcoefStyleOneForAll
	endif
	
	SVAR /Z coefWaveFullPath = batchOutDFR:WMcoefWaveFullPath				// for 2D per-fit init coef guess wave - if exists	
	if (SVAR_Exists(coefWaveFullPath))
		batchInfoReturn.coefWaveFullPath = coefWaveFullPath
	else
		batchInfoReturn.coefWaveFullPath = ""
	endif			
	WAVE /Z batchInfoReturn.coefWave = batchOutDFR:WMcoefWaveStored		// A 1D wave representing the initial guess settings in the controls

	///// Constraint info /////
	NVAR /Z constrEntryStyle = batchOutDFR:WMconstrEntryStyle
	batchInfoReturn.constrEntryStyle = NVAR_Exists(constrEntryStyle) ? constrEntryStyle : WMconstrStyleControls
	if (batchInfoReturn.constrEntryStyle<WMconstrStyleControls || batchInfoReturn.constrEntryStyle > WMconstrStyle2DWave)
		batchInfoReturn.constrEntryStyle = WMconstrStyleControls
	endif
	
	WAVE /Z batchInfoReturn.constraintsControlWave = batchOutDFR:WMconstraintsControlWaveStored			// A nCoefs x 2 wave for the min/max constraint info from the listbox
	SVAR /Z constraintStr = batchOutDFR:WMconstraintStr														// A string for inputing inter-coeficient constraints	
	if (SVAR_Exists(constraintStr))
		batchInfoReturn.constraintStr = constraintStr
	else
		batchInfoReturn.constraintStr = ""
	endif
	
	SVAR /Z constrTextWaveFullPath = batchOutDFR:WMconstrTextWaveFullPath									// A string for inputing inter-coeficient constraints	
	if (SVAR_Exists(constraintStr))
		batchInfoReturn.constrTextWaveFullPath = constraintStr
	else
		batchInfoReturn.constrTextWaveFullPath = ""
	endif
	
	NVAR /Z yType = batchOutDFR:WMyValsSourceType
	batchInfoReturn.yValsSourceType = NVAR_Exists(yType) ? yType : 0
	NVAR /Z xType = batchOutDFR:WMxValsSourceType
	batchInfoReturn.xValsSourceType = NVAR_Exists(xType) ? xType : 0
	NVAR /Z mType = batchOutDFR:WMmaskSourceType
	batchInfoReturn.maskSourceType = NVAR_Exists(mType) ? mType : 0
	NVAR /Z wType = batchOutDFR:WMweightSourceType
	batchInfoReturn.weightSourceType = NVAR_Exists(wType) ? wType : 0
	NVAR /Z nWaves = batchOutDFR:WMnWaves
	batchInfoReturn.nWaves = NVAR_Exists(nWaves) ? nWaves : 0
	SVAR /Z batchDir = batchOutDFR:WMbatchDir
	if (SVAR_Exists(batchDir))
		batchInfoReturn.batchDir = batchDir
	else
		batchInfoReturn.batchDir = ""
	endif

	SVAR /Z fitF = batchOutDFR:WMfitFunc
	if (SVAR_Exists(fitF))
		batchInfoReturn.fitFunc = fitF
	else
		batchInfoReturn.fitFunc = ""
	endif
	NVAR /Z nInC = batchOutDFR:WMnInCoefs
	batchInfoReturn.nInCoefs = NVAR_Exists(nInC) ? nInC : 0
	NVAR /Z xoff = batchOutDFR:WMXOffset
	batchInfoReturn.xoffset = NVAR_Exists(xoff) ? xoff : 0
	WAVE /Z batchInfoReturn.epsilon = batchOutDFR:WMepsilon
	NVAR /Z hoe = batchOutDFR:WMhaltOnErr
	batchInfoReturn.haltOnErr = NVAR_Exists(hoe) ? hoe : 0
	NVAR /Z maxIter = batchOutDFR:WMmaxIter
	batchInfoReturn.maxIter = NVAR_Exists(maxIter) ? maxIter : 40
	SVAR /Z constraintStr = batchOutDFR:WMconstraintStr
	if (SVAR_Exists(constraintStr))
		batchInfoReturn.constraintStr = constraintStr
	else
		batchInfoReturn.constraintStr = ""
	endif
	
	WAVE /T/Z batchInfoReturn.yFilterSettings = batchOutDFR:WMyFilterSettings
	WAVE /T/Z batchInfoReturn.xFilterSettings = batchOutDFR:WMxFilterSettings
	WAVE /T/Z batchInfoReturn.maskFilterSettings = batchOutDFR:WMmaskFilterSettings
	WAVE /T/Z batchInfoReturn.weightFilterSettings = batchOutDFR:WMweightFilterSettings
	
	batchInfoReturn.doRange=NumVarOrDefault(batchOutDFRStr+"WMdoRange", 0)
	batchInfoReturn.minRange=NumVarOrDefault(batchOutDFRStr+"WMminRange", 0)
	batchInfoReturn.maxRange=NumVarOrDefault(batchOutDFRStr+"WMmaxRange", 0)
	batchInfoReturn.doCovar=NumVarOrDefault(batchOutDFRStr+"WMdoCovar", 0)
End

Function /WAVE GetCoefNames(currFitFunc, nInCoefs)
	String currFitFunc 
	Variable nInCoefs
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	
	Variable i		
	Wave /T allCoefNames = packageDFR:coefficientNames
	String coefStr =""
	
	if (FindDimLabel(allCoefNames, 0, currFitFunc) != -2 && !stringmatch(currFitFunc, "poly*"))
		coefStr = allCoefNames[%$currFitFunc]
	elseif (!isUserFitFunc(currFitFunc) && stringmatch(currFitFunc, "poly*")) 
		coefStr="y0;deg1;deg2"
		for (i=3; i<=nInCoefs; i+=1)
			coefStr+=";deg"+num2str(i)
		endfor
	endif

	Make /T/FREE/N=(nInCoefs) coefNames

	for (i=0; i<nInCoefs; i+=1)
		if (ItemsInList(coefStr)>i)
			coefNames[i] = StringFromList(i, coefStr)
		else
			coefNames[i] = "K"+num2str(i)
		endif
	endfor

	return coefNames
End

Function /S WMBCFGetCurrFormula(currFitFunc, nInCoefs)
	String currFitFunc
	Variable nInCoefs
	
	DFREF packageDFR = GetBatchCurveFitPackageDFR()
	WAVE /T inArgsTxt = packageDFR:inputArgsTextDescription
	
	String currFormula = inArgsTxt[%$currFitFunc]
	Variable i
	
	if (!CmpStr(currFitFunc, "poly") || !CmpStr(currFitFunc, "poly_XOffset"))
		String base2 = StringFromList(2, currFormula, "+")
		currFormula = currFormula[0,strlen(currFormula)-5]
		for (i=4; i<=nInCoefs; i+=1)
			currFormula += "+"+ReplaceString("2", base2, num2str(i-1))
		endfor
	endif
	
	return currFormula
End

Function /S getInitialGuesses()
	return cCtrl_oneForAll+";"+cCtrl_lastSuccess+";"+cCtrl_2DWave 
End	

Function /S getCoefInputMethod()
	return cCtrl_setWithControls+";"+cCtrl_setWithTextWave
End	

Function updateFitFunctions()
	DFREF packageDFR = GetBatchCurveFitPackageDFR()

	Wave nInArgsBI = packageDFR:nInputArgsHashBuiltIn
	Wave /T inArgsTxtBI = packageDFR:inputArgsTextDescriptionBuiltIn
	Wave /T coefNamesBI = packageDFR:coefficientNamesBuiltIn

	Wave /Z nInputArgsHash = packageDFR:nInputArgsHash
	if (waveExists(nInputArgsHash))
		Duplicate /FREE packageDFR:nInputArgsHash nInputArgsHashOld
	endif
	Duplicate /O nInArgsBI packageDFR:nInputArgsHash
	Wave nInputArgsHash = packageDFR:nInputArgsHash
	
	Duplicate /O inArgsTxtBI packageDFR:inputArgsTextDescription
	Wave /T inArgsTxt = packageDFR:inputArgsTextDescription
	Duplicate /O coefNamesBI packageDFR:coefficientNames
	Wave /T coefNames = packageDFR:coefficientNames
	
	String currFunc, currFuncText
	String currFuncEquation
		
	String userFFuncs = FunctionList("*", ";", "KIND:10,WIN:[ProcGlobal]")
		
	Variable i, j, nUserFFuncs, nBI, nAdded
	nUserFFuncs = ItemsInList(userFFuncs)
	nBI = numpnts(nInArgsBI)
	
	Redimension /N=(nBI+nUserFFuncs) nInputArgsHash
	Redimension /N=(nBI+nUserFFuncs) inArgsTxt
	Redimension /N=(nBI+nUserFFuncs) coefNames

	nAdded=0
	for (i=0; i<nUserFFuncs; i+=1)
		currFunc = StringFromList(i, userFFuncs)
		
		Struct curveFitDialogComments curveFitArgs
		GetCurveFitFuncInfo(currFunc, curveFitArgs)
		
		if (curveFitArgs.isFitFunc)
			SetDimLabel 0, nAdded+nBI, $currFunc, nInputArgsHash
			SetDimLabel 0, nAdded+nBI, $currFunc, inArgsTxt
			SetDimLabel 0, nAdded+nBI, $currFunc, coefNames
			nAdded += 1
		
			if (curveFitArgs.isFromCurveFitDialogComplete)
				nInputArgsHash[%$(currFunc)] = curveFitArgs.nCoefs
				inArgsTxt[%$(currFunc)] = curveFitArgs.equationText
				String tmpStr=""
				for (j=0; j<numpnts(curveFitArgs.coefNames); j+=1)
					tmpStr += curveFitArgs.coefNames[j]
					if (j<numpnts(curveFitArgs.coefNames)-1)
						tmpStr += ";"
					endif
				endfor
				coefNames[%$(currFunc)] = tmpStr
			else
				if (curveFitArgs.nCoefs)
					nInputArgsHash[%$(currFunc)] = curveFitArgs.nCoefs
				else
					if (WaveExists(nInputArgsHashOld) && FindDimLabel(nInputArgsHashOld, 0, currFunc) != -2)
						nInputArgsHash[%$(currFunc)] = nInputArgsHashOld[%$(currFunc)]
					else
						nInputArgsHash[%$(currFunc)] = NaN
					endif
				endif
				inArgsTxt[%$(currFunc)] = ""
				coefNames[%$(currFunc)] = ""
			endif
		endif
	endfor
	
	Redimension /N=(nBI+nAdded) nInputArgsHash
	Redimension /N=(nBI+nAdded) inArgsTxt
	Redimension /N=(nBI+nAdded) coefNames
End

///////////////// Utility Functions ///////////////////

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

// Creates the data folder if it does not already exist.  Includes X and Y locations for maintaining panel position when killed then re-created
Function /DF GetBatchCurveFitPackageDFR([doInitialization])
	Variable doInitialization

	DFREF dfr = $constBatchCurveFitDir 
	if (DataFolderRefStatus(dfr) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O $constBatchCurveFitDir
	
		DFREF dfr = $constBatchCurveFitDir	
		InitBatchCurvePackageData(dfr)
	elseif (!ParamIsDefault(doInitialization) && doInitialization)
		InitBatchCurvePackageData(dfr)		
	endif
	return dfr
End

////////////////////// function for collecting and validating constraint inputs ///////////////////
// returnConstraintTextWave is a text wave for returning valid constraints in the form described in DisplayHelpTopic "Fitting With Constraints"
// holdsWave is a numerical wave indicating whether coefficients are held.  It has the same length as the # of coefficients.  0 means not held, 1 means held
// constraintWave is a nCoefs X 2 wave with possible min vals in col 0, max vals in col 1.  NaN means no constraint.  
// constraintsStr is a ";" separated list of constraints.  
//
// If neither constraintWave nor constraintsStr are set then the trivial result of no errors is returned
// 
// ValidateConstraints checks the constraintWave has no coefs constrained that are also held
// 					    checks the constraintStr for held coefs and for out of range coefs
//					    adds the constraints in the constraintWave to the returnConstraintTextWave

Function /S ValidateConstraints(returnConstraintTextWave, holdsWave [, constraintWave, constraintStr])
	Wave /T returnConstraintTextWave
	Wave holdsWave
	Wave constraintWave
	String constraintStr
		
	Variable nCoefs = ParamIsDefault(constraintWave) ? 0 : dimSize(constraintWave,0)
	Variable nStrConstraints = ParamIsDefault(constraintStr) ? 0 : ItemsInList(constraintStr)
	
	Redimension /N=(nCoefs*2+nStrConstraints) returnConstraintTextWave		// make sure there's enough room to record all the constraints
	
	Variable i
	Variable nValidConstraints = 0
	String err=""
	
	Make /FREE /N=(nCoefs) heldConstraintReported = 0
	for (i=0; i<nCoefs; i+=1)
		if (numType(constraintWave[i][0])!=2)
			if (holdsWave[i])
				err+="K"+num2str(i)+" both held and constrained.\r"
				heldConstraintReported[i]=1
			else	
				returnConstraintTextWave[nValidConstraints]="K"+num2str(i)+" > "+num2str(constraintWave[i][0])
				nValidConstraints+=1
			endif
		endif
		if (numType(constraintWave[i][1])!=2)
			if (holdsWave[i])
				if (!heldConstraintReported[i])
					err+="K"+num2str(i)+" both held and constrained.\r"
					heldConstraintReported[i]=1
				endif
			else	
				returnConstraintTextWave[nValidConstraints]="K"+num2str(i)+" < "+num2str(constraintWave[i][1])
				nValidConstraints+=1
			endif
		endif
	endfor
	
	String regExprStr = "([Kk][0-9]+)(.*)"
	String substring1, substring2
	Variable coefNum
	
	for (i=0; i<nStrConstraints; i+=1)
		String currConstrStr = StringFromList(i, constraintStr)
			
		Variable constraintOk = 1	
		do 			// do peaks
			SplitString /E=(regExprStr) currConstrStr, substring1, substring2
			currConstrStr = substring2

			if (strlen(substring1))
				sscanf substring1, "%*[kK]%i", coefNum

				if (coefNum >= nCoefs)
					constraintOk=0
					err += "K"+num2str(coefNum)+" is greater than the largest possible constraint index.\r"
				elseif (holdsWave[coefNum])
					constraintOk=0
					if (!heldConstraintReported[coefNum])
						err+="K"+num2str(coefNum)+" both held and constrained.\r"
						heldConstraintReported[coefNum]=1
					endif
				endif	
			else
				break
			endif
		while(1)	
		if (constraintOk)
			returnConstraintTextWave[nValidConstraints]=StringFromList(i, constraintStr)
			nValidConstraints += 1
		endif
	endfor
	
	Redimension /N=(nValidConstraints) returnConstraintTextWave				// limit the constraints wave size to the number of the valid constraints
	
	return err
End
