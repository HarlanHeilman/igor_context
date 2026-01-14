#pragma rtGlobals = 2
#include <Value Report>
#pragma IgorVersion=4.00
#pragma Version=1.11

//************
//	Procs to support AppendFitEquation() and the test routines...
//************

//************
// version 1.2:
//		Changed "Wave" to "Wave/Z" to avoid dropping into the debugger when a fit hasn't been done yet.		JW 050630
//************

Menu "Macros"
	"Append Fit Equation", mAppendFitEquation()
end

//************
// Returns string containing a built-in curve fit equation
//  fitType is an integer selector

Function/S GenFitEquation(fitType,nterms)
	variable fitType				// 1= Gaussian, 2= Lorentzian etc
	variable nterms				// need not be valid except for poly and Poly 2D
	
	Variable i,j
	Variable termNumber
	String s

	switch (fitType)
		case 1: 		// gauss
			return "K0+K1*exp(-((x-K2)/K3)^2)"
			break
		case 2:		// lorentzian
			return "K0+K1/((x-K2)^2+K3)"
			break
		case 3:		// exp
			return " K0+K1*exp(-K2*x)"
			break
		case 4:		// dblexp
			return " K0+K1*exp(-K2*x)+K3*exp(-K4*x)"
			break
		case 5:		// sine
			return " K0+K1*sin(K2*x+K3)"
			break
		case 6:		// line
			return " K0+K1*x"
			break
		case 7:		// poly
			s= " K0+K1*x"
			if( (nterms<3))
				return "GenFitEquation: bad number of terms for poly eqn"
			endif
			string t
			i=2
			do
				sprintf t,"+K%d*x^%d",i,i
				s += t
				i +=1
			while(i<nterms)
			return s
			break
		case 8:		// Hill Equation
			return "K0+(K1-K0)*(x^K2/(x^K2+K3^K2))"
			break
		case 9:		// sigmoid
			return "K0+K1/(1+exp(-(x-K2)/K3))"
			break
		case 10:	// power
			return "K0+K1*x^K2"
			break
		case 11:	// log normal
			return "K0+K1*exp(-(ln(x/K2)/K3)^2)"
			break
		case 12:	// Gauss 2D	if they're smart, they won't do this...
			return "K0+K1*exp((-1/(2*(1-K6^2)))*(((x-K2)/K3)^2 + ((y-K4)/K5)^2 - (2*K6*(x-K2)*(y-K4)/(K3*K5))))"
			break
		case 13:	// poly 2D
			Variable Order = (sqrt(8*nterms+1)-3)/2
			s = "K0"
			termNumber = 0
			for (i = 1; i <= Order; i += 1)
				for (j = i; j >= 0; j -= 1)
					termNumber += 1
					s += "+K"+num2istr(termNumber)
					if (j != 0)
						if (j==1)
							s += "*x"
						else
							s += "*x^"+num2istr(j)
						endif
					endif
					if (i-j != 0)
						if (i-j == 1)
							s += "*y"
						else
							s += "*y^"+num2istr(i-j)
						endif
					endif
				endfor
			endfor
			return s
			break
		default:
			return "GenFitEquation: unknown fit type"
			break;
	endswitch
End

//************
// Generic substring replacement routine. 
//
Function/S SubStrReplace(theStr,beforeSub,afterSub,caseSensitive)
	string theStr					// string to do the replacement on
	string beforeSub				// substring in theStr to replace by ...
	string afterSub				// ... this string
	variable caseSensitive		// non-zero if case sensitive search is desired

	string tmp= theStr			// working copy
	variable start					// start of substring
	
	if(!caseSensitive)
		tmp= UpperStr(tmp)
		beforeSub= UpperStr(beforeSub)
	endif
	start= strsearch(tmp,beforeSub,0)
	if( start >= 0 )
		theStr[start,start+strlen(beforeSub)-1]= afterSub
	endif
	return theStr
End



//************
// Assuming the top graph contains data that has just been fitted to a built-in function
//  this macro adds or modifies a text box containing the fitted equation using
//  the actual values from the fit.  The values are rounded depending on the estimated errors.
//  The textbox is given the name 'fiteqn'. 
//  If you want an extra digit of precision shown change vrsFlags to 2 (see below)
//
// REQUIRES: IGOR V1.2; MakeValueReportString();GenFitEquation();SubStrReplace()
//	
Function AppendFitEquation(fitType)
	variable fitType

	Silent 1
	
	if( (fitType<1) || (fitType>13) )
		Abort "unknown fit type"
	endif
	
	String tmpText
	String afestr_tmp,afestr_tmp2
	Wave/Z W_sigma
	if (!WaveExists(W_sigma))
		abort "The wave W_sigma does not exist. It is likely that you have not just done a curve fit."
	endif
	Variable nterms= numpnts(W_sigma),start
	Variable vrsFlags= 4+2					// 1 digit, use E notation
	afestr_tmp= GenFitEquation(fitType,nterms)
	
	Wave/Z W_coef
	if (!WaveExists(W_coef))
		abort "The wave W_coef does not exist. Did you rename it after the fit?"
	endif
	Variable i
	for (i = 0; i < nterms; i += 1)
		tmpText= "K"+num2istr(i)
		afestr_tmp2= MakeValueReportString(W_coef[i],W_sigma[i],0,"",vrsFlags)
		afestr_tmp= SubStrReplace(afestr_tmp,tmpText,afestr_tmp2,0)
	endfor
	// may have '+-' and/or '--' as a result of the direct substitution
	start= 0
	do
		start= strsearch(afestr_tmp,"+-",start)
		if(start<0)
			break;
		endif
		afestr_tmp[start,start+1]= "-"
	while(1)
	start= 0
	do
		start= strsearch(afestr_tmp,"--",start)
		if(start<0)
			break;
		endif
		afestr_tmp[start,start+1]= "-"
	while(1)
	Textbox/C/N=fiteqn afestr_tmp
End

Function mAppendFitEquation()

	Variable fitType=1
	Prompt fitType,"Fit type:",popup,"gauss;lor;exp;dblexp;sine;line;poly;Hill Equation;sigmoid;power;log normal; Gauss 2D; poly 2D;"
	DoPrompt "Append Fit Equation", fitType
	AppendFitEquation(fitType)
end