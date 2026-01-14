#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 2
#pragma IgorVersion=4.00
#pragma Version=1.1

#include <Value Report>

//************
// Assuming the top graph contains data that has just been fitted to a built-in function
//  this macro adds or modifies a text box containing the fit parameters using the
//  value(error) notation.  
//  The textbox is given the name 'fitres'. 
//  Note that substitutions had to be made for () and <> in the popup menu due to the fact
//	that these are 'magic' characters in Apple menus.
//	

Menu "Macros"
	"Append Built-in Fit Results", mAppendBIFitResults()
	"Append User Fit Results", mAppendUserFitResults()
end

Function mAppendBIFitResults()

	String fitCoefs="W_coef"
	Prompt fitCoefs,"Wave containing fit coefficients:",popup WaveList("*",";","")
	variable fitType=1
	Prompt fitType,"Fit type:",popup,"gauss;lor;exp;dblexp;sine;line;poly;Hill Equation;sigmoid;power;log normal; Gauss 2D; poly 2D;"
	variable method=4
	Prompt method,"reporting method:",popup,"b.bbb;b.bbb±s.sss;b.bbb {s.sss};b.bbb{ss}"
	Variable errorType=1
	Prompt errorType, "Error source:", popup, "Standard Deviation; Confidence Interval"
	DoPrompt "Append Built-in Fit Results", fitCoefs, fitType, method, errorType
	if (V_flag == 0)
		AppendBIFitResultsWithNames(fitCoefs,fitType,method, errorType)
	endif
end

// Old version, updated to a function, with new programming constructs
Function AppendBIFitResults(fitType,method)
	variable fitType
	variable method

	variable i,ilim
	
	if( (fitType<1) %| (fitType>13) )
		Abort "unknown fit type"
	endif
	
	Wave ErrorWave = W_sigma
	if (!WaveExists(ErrorWave))
		Abort "The wave containing error information does not exist. Maybe you haven't done a fit yet."
	endif

	Wave W_coef
	if(  numpnts(ErrorWave) != numpnts(W_coef) )	// at least a little error check
		Abort "The error wave doesn't match the coefficient wave; either the coefficients wave isn't W_coef, or you have selected the wrong error type option."
	endif

	
	String noteText="",tmpText	
	ilim= numpnts(ErrorWave)

	for (i = 0; i < ilim; i += 1)
		if( i==0 )
			sprintf tmpText,"K%d=\t",i
		else
			sprintf tmpText,"\rK%d=\t",i
		endif
		noteText += tmpText + MakeValueReportString(W_coef[i],ErrorWave[i],method-1,"",1)
	endfor

	Textbox/C/N=fitres noteText
End

// New version with new CurveFit features supported
Function AppendBIFitResultsWithNames(fitCoefs, fitType,method, errorType)
	String fitCoefs
	variable fitType
	variable method
	Variable errorType		// 1= W_sigma, 2=W_ParamConfidenceInterval

	variable i,ilim
	
	if( (fitType<1) %| (fitType>13) )
		Abort "unknown fit type"
	endif
	
	Wave W_coef = $fitCoefs
	if (!WaveExists(W_coef))
		abort "The coefficient wave, "+fitCoefs+", doesn't exist."
	endif
	Variable nCoefs = GetBINumCoefs(fitType)
	if ( (nCoefs != 0) && (nCoefs != numpnts(W_coef)) )
		abort "The length of the coefficient wave doesn't match the fit function. Maybe you chose the wrong fit function or the wrong wave."
	endif
	ilim= numpnts(W_coef)
	
	String noteText="",tmpText
	String CR
	if (method == 1)
		Wave ErrorWave = W_sigma		// just to avoid null wave
		CR = ""
	else
		if (errorType == 1)
			Wave ErrorWave = W_sigma
			if(  numpnts(ErrorWave) != ilim)	// at least a little error check
				Abort "The error wave doesn't match the coefficient wave; either the coefficients wave isn't W_coef, or you have selected the wrong error type option."
			endif
		else	
			Wave ErrorWave = W_ParamConfidenceInterval
			if(  numpnts(ErrorWave)-1 != ilim)	// at least a little error check
				Abort "The error wave doesn't match the coefficient wave; either the coefficients wave isn't W_coef, or you have selected the wrong error type option."
			endif
		endif
		if (!WaveExists(ErrorWave))
			Abort "The wave containing error information does not exist. Maybe you selected the wrong error type option."
		endif
	
		if (ErrorType == 1)
			noteText = "Coef ± Standard Deviation"
		else
			noteText = "Coef ± "+num2str(ErrorWave[ilim]*100)+"% confidence"
		endif
		CR = "\r"
	endif
	
	for (i = 0; i < ilim; i += 1)
		tmpText = CR+GetCoefNameForBIFunction(fitType, i)+"=\t"
		noteText += tmpText + MakeValueReportString(W_coef[i],ErrorWave[i],method-1,"",1)
		CR = "\r"
	endfor
	
	Textbox/C/N=fitres noteText
End


//************
// Assuming the top graph contains data that has just be fitted to a user function
//  this macro adds or modifies a text box containing the fit parameters using the
//  value(error) notation.
//  The textbox is given the name 'fitres'. 
//	

Function mAppendUserFitResults()

	String fitCoefs
	Prompt fitCoefs,"Wave containing fit coefficients:",popup WaveList("*",";","")
	variable method=4
	Prompt method,"reporting method:",popup,"b.bbb;b.bbb±s.sss;b.bbb {s.sss};b.bbb{ss}"
	Variable errorType=1
	Prompt errorType, "Error source:", popup, "Standard Deviation; Confidence Interval"
	String FunctionName
	Prompt FunctionName, "Function:", popup, FunctionList("*", ";", "KIND:2,SUBTYPE:FitFunc")
	DoPrompt "Append User Fit Results", fitCoefs, method, errorType, FunctionName
	if (V_flag)
		return 0
	endif
	AppendUserFitResultsWithNames(fitCoefs,method, errorType, FunctionName)
end

// old version
Function AppendUserFitResults(fitCoefs, method)
	String fitCoefs
	variable method

	variable i,ilim
	
	Wave CoefsWave = $fitCoefs
	Wave ErrorWave = W_sigma
	
	if (!WaveExists(ErrorWave))
		Abort "The wave containing error information does not exist. Maybe you selected the wrong error type option."
	endif
	if(  numpnts(ErrorWave) != numpnts(CoefsWave) )	// at least a little error check
		Abort "incorrect fit coefficient wave"
	endif
	
	String noteText= "",tmpText
	
	i= 0; ilim= numpnts(ErrorWave)
	do
		if( i==0 )
			sprintf tmpText,"K%d=\t",i
		else
			sprintf tmpText,"\rK%d=\t",i
		endif
		noteText += tmpText + MakeValueReportString(CoefsWave[i],ErrorWave[i],method-1,"",1)
		i += 1
	while( i < ilim)

	Textbox/C/N=fitres noteText
End

// new version with support for new features
Function AppendUserFitResultsWithNames(fitCoefs, method, errorType, FunctionName)
	String fitCoefs
	variable method
	Variable errorType		// 1= W_sigma, 2=W_ParamConfidenceInterval
	String FunctionName

	variable i,ilim
	
	Wave CoefsWave = $fitCoefs
	ilim= numpnts(CoefsWave)
	if (method == 1)
		Wave ErrorWave = W_sigma
	else
		if (errorType == 1)
			Wave ErrorWave = W_sigma
			if(  numpnts(ErrorWave) != ilim)	// at least a little error check
				Abort "The error wave doesn't match the coefficient wave; either the coefficients wave isn't W_coef, or you have selected the wrong error type option."
			endif
		else	
			Wave ErrorWave = W_ParamConfidenceInterval
			if(  numpnts(ErrorWave)-1 != ilim)	// at least a little error check
				Abort "The error wave doesn't match the coefficient wave; either the coefficients wave isn't W_coef, or you have selected the wrong error type option."
			endif
		endif
		
		if (!WaveExists(ErrorWave))
			Abort "The wave containing error information does not exist. Maybe you selected the wrong error type option."
		endif
	endif
	
	String noteText= "",tmpText, CR
	if (method == 1)
		CR = ""
	else
		if (ErrorType == 1)
			noteText = "Coef ± Standard Deviation"
		else
			noteText = "Coef ± "+num2str(ErrorWave[ilim]*100)+"% confidence"
		endif
		CR = "\r"
	endif

	for (i = 0; i < ilim; i += 1)
		tmpText = CR+GetCoefNameFromUserFitFunction(FunctionName, i)+"=\t"
		noteText += tmpText + MakeValueReportString(CoefsWave[i],ErrorWave[i],method-1,"",1)
		CR = "\r"
	endfor

	Textbox/C/N=fitres noteText
End

Function/S GetCoefNameForBIFunction(fitType, coefN)
	Variable fitType
	Variable coefN

	String ListOfNames=""
	switch (fitType)
		case 1: 		// gauss
			ListOfNames = "y0;A;x0;width;"
			break
		case 2:		// lorentzian
			ListOfNames = "y0;A;x0;B;"
			break
		case 3:		// exp
			ListOfNames = "y0;A;invTau;"
			break
		case 4:		// dblexp
			ListOfNames = "y0;A1;invTau1;A2;invTau2;"
			break
		case 5:		// sine
			ListOfNames = "y0;A;f;phi;"
			break
		case 6:		// line
			ListOfNames = "a;b;"
			break
		case 7:		// poly
			return "K"+num2istr(coefN)
			break
		case 8:		// Hill Equation
			ListOfNames = "base;max;rate;xhalf;"
			break
		case 9:		// sigmoid
			ListOfNames = "base;max;xhalf;rate;"
			break
		case 10:	// power
			ListOfNames = "y0;A;pow;"
			break
		case 11:	// log normal
			ListOfNames = "y0;A;x0;width;"
			break
		case 12:	// Gauss 2D
			ListOfNames = "z0;A;x0;xWidth;y0;yWidth;cor;"
			break
		case 13:	// poly 2D
			return "K"+num2istr(coefN)
			break
		default:
			return "Unknown Function"
			break;
	endswitch
	return StringFromList(coefN, ListOfNames)
end

Function GetBINumCoefs(fitType)
	Variable fitType

	Variable nCoefs=-1	// bad fit type
	switch (fitType)
		case 1: 	// gauss
			nCoefs = 4
			break
		case 2:		// lorentzian
			nCoefs = 4
			break
		case 3:		// exp
			nCoefs = 3
			break
		case 4:		// dblexp
			nCoefs = 5
			break
		case 5:		// sine
			nCoefs = 4
			break
		case 6:		// line
			nCoefs = 2
			break
		case 7:		// poly
			nCoefs = 0		// can't tell
			break
		case 8:		// Hill Equation
			nCoefs = 4
			break
		case 9:		// sigmoid
			nCoefs = 4
			break
		case 10:	// power
			nCoefs = 3
			break
		case 11:	// log normal
			nCoefs = 4
			break
		case 12:	// Gauss 2D
			nCoefs = 7
			break
		case 13:	// poly 2D
			nCoefs = 0
			break
	endswitch
	return nCoefs
end	

Function GetUserFitFuncNumCoefs(FunctionName)
	String FunctionName

	String CoefsComment = "//CurveFitDialog/ Coefficients"
	Variable CoefsCommentLength = strlen(CoefsComment)
	String commentPrefix = "//CurveFitDialog/ "
	
	Variable startPos, endPos
	Variable numCoefs
	Variable i
	
	String FunctionText = ProcedureText(functionName)
	if (strlen(FunctionText) == 0)
		return -1
	endif
	startPos = strsearch(FunctionText, CoefsComment,0)
	if (startPos < 0)
		return 0
	endif
	startPos += CoefsCommentLength
	endPos = strsearch(FunctionText, "\r", startPos)
	numCoefs = str2num(FunctionText[startPos+1, endPos-1])
	return numCoefs
end	

Function/S GetCoefNameFromUserFitFunction(functionName, coefN)
	String functionName
	Variable coefN
	
	String CoefsComment = "//CurveFitDialog/ Coefficients"
	Variable CoefsCommentLength = strlen(CoefsComment)
	String commentPrefix = "//CurveFitDialog/ "
	
	Variable startPos, endPos
	Variable numCoefs
	Variable i
	
	String FunctionText = ProcedureText(functionName)
	if (strlen(FunctionText) == 0)
		return "Unknown Function"
	endif
	startPos = strsearch(FunctionText, CoefsComment,0)
	if (startPos < 0)
		return "K"+num2istr(coefN)
	endif
	startPos += CoefsCommentLength
	endPos = strsearch(FunctionText, "\r", startPos)
	numCoefs = str2num(FunctionText[startPos+1, endPos-1])
	if (coefN >= numCoefs)
		return "K"+num2istr(coefN)
	endif
	for (i = 0; i <= coefN; i += 1)
		startPos = endPos
		startPos = strsearch(FunctionText, commentPrefix,startPos)
		endPos = strsearch(FunctionText, "\r", startPos)
		if (startPos < 0)
			return "K"+num2istr(coefN)
		endif
	endfor
	startPos = strsearch(FunctionText, "=",startPos)
	if (startPos < 0)
		return "K"+num2istr(coefN)
	endif
	endPos = strsearch(FunctionText, "\r", startPos)
	return FunctionText[startPos+1, endPos-1]
end