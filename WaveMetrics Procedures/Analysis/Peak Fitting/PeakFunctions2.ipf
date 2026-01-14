#pragma rtGlobals=3		// Use modern global access method.
#pragma version = 3.05
#pragma IgorVersion=9.00
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

// Goes with Multipeak Fitting package
//
// JW 080508 Added LogNormal peak shape
// 				Added LogCubic background function
// JW 080513	Added LogPoly5 background function
//
// rev 2.01 JW 110217
//		Changed ExpModGauss peak shape to allow negative exponential tau for long tales to the left.
// rev 2.02 JW 120612
//		Removed unneeded Redimension commands in derived parameter functions: MultipeakFit2 v. 2.14
//		has been fixed so it makes the wave the correct size!
//		Also added better comments so that this file can be used for an example to users who want to
// 		write their own peak functions.
//
// Version 3 JW 190916
//		Replaces use of peak functions from the obsolete PeakFunctions2 XOP with built-in MPFXxxxPeak functions.
//		Renamed the file from "PeakFunctions2.ipf" to "PeakFunctions2_V3.ipf".
//
//		Extended the MPF2_BLFitStruct definition to directly take the raw data wave pointers for the
//		use in backgrounds which need it.
//		Added new BLFuncInfo member InitGuessFunc for backgrounds which have initializing functions.
//		Added Doniach-Sunjic and Post-Collision Interaction peak shape functions.
//		Added Shirley and ArcTangent background functions.
//		Added GaussArea, LorentzHeight and VoigtArea functions
//		Implemented a more accurate FHWM calculation for the Voigt function and corrected the error output
//
// rev 3.02 ST 211105
//		Added function GetGaussParamsFromPeakCoefs() which converts peak coef waves back to Gauss-'guess' parameters
//		Tweaked width guess of Lorentz, LorentzHeight, ExpConvExp and DS peak types
//		Fixed bug: DS peak shape guess had a wrong sign for inverse peaks
//		Fixed bug: DS peak results output was garbage if the x scaling is much larger or much smaller than ~1-100.
//		FindPeakStatsHelper() now outputs a free wave with all parameters add once; includes left and right width components
// rev 3.02 ST 211111
//		Adjusted the Voigt and VoigtArea guess functions to give a closer height approximation.
// rev 3.03 JW/ST 211103
//		Added error output for the width value of the Voigt and VoigtArea peak shapes
// rev 3.04 JW 220706
//		Derived parameters for the EMG peak were wrong for small asymmetry values. EMGFunction2 fixes that.
// rev 3.05 ST 221020
//		Derived FWHM for the ExpConvExp function are now calculated with the XOP version within ExpConvExpFunc2.

// constants to use with the peak function info function
constant PeakFuncInfo_ParamNames = 0
constant PeakFuncInfo_PeakFName = 1
constant PeakFuncInfo_GaussConvFName = 2
constant PeakFuncInfo_ParameterFunc = 3
constant PeakFuncInfo_DerivedParamNames = 4

// constants to use with the peak function info function
constant BLFuncInfo_ParamNames = 0
constant BLFuncInfo_BaselineFName = 1
constant BLFuncInfo_InitGuessFunc = 2

// ************
// Gauss Parameter Conversion
// ************
// This function calculates approximate 'Gauss' peak parameters from the peak coefficients of any known peak shape.
// Useful for converting peak parameters back to their respective Gaussian representation, e.g., as used by the peak finder.
// The MPF UI makes use of this function to update W_AutoPeakInfo after peak coefficients have changed.
// If new official peak shapes are introduced then the respective back-conversion is added here.
// For unknown (user) functions then peak shape is grabbed directly and the peak parameters are extracted from there.

Function/Wave GetGaussParamsFromPeakCoefs(String PeakTypeName, Wave coefs)
	
	Variable peakloc = coefs[0]		// location is the minimal output for unknown peaks => assumes that user functions have location as the first parameter
	Variable width = NaN			// width for displaying the peaks in the MPF2 graph
	Variable height = NaN
	Variable lwidth = NaN			// asymmetric widths => only written for asymmetric input shapes
	Variable rwidth = NaN
	
	String peakFuncName = ""
	
	StrSwitch (PeakTypeName)
		case "Gauss":
			peakloc	= coefs[0]
			width	= abs(coefs[1])
			height	= coefs[2]
		break
		case "GaussArea":
			peakloc	= coefs[0]
			width	= abs(coefs[1])
			height	= coefs[2]/(abs(coefs[1])*sqrt(pi))
		break
		case "Lorentzian":
			peakloc	= coefs[0]
			width	= abs(coefs[1])/(2*sqrt(ln(2)))
			height	= coefs[2]/(abs(coefs[1])*sqrt(pi))
		break
		case "LorentzianHeight":
			peakloc	= coefs[0]
			width	= abs(coefs[1])/(2*sqrt(ln(2)))
			height	= coefs[2]*(sqrt(pi)/2)
		break
		case "Voigt":
			peakloc	= coefs[0]
			if (DimSize(coefs,0) == 3)
				//width	= abs((1 + abs(coefs[3]))/coefs[1])
				Variable wg = SqrtLn2/abs(coefs[1])		// gaussian width
				Variable wl = abs(coefs[3]/coefs[1]) 	// lorentzian width
				width	= (0.5346*wl + sqrt(0.2166*wl^2 + wg^2)) / (SqrtLn2)
				height	= coefs[2]*exp(coefs[3]^2)*erfc(coefs[3])
			endif
		break
		case "VoigtArea":
			peakloc	= coefs[0]
			if (DimSize(coefs,0) == 4)
				Variable shape = abs(coefs[3]/coefs[1])* sqrtln2
				//width	= (abs(coefs[1]) + abs(coefs[3])) / (2*sqrtln2)
				width	= (0.5346*abs(coefs[3]) + sqrt(0.2166*coefs[3]^2 + coefs[1]^2)) / (2*SqrtLn2)
				height	= (coefs[2]/abs(coefs[1]))* exp(shape^2) * erfc(shape) * (2*sqrtln2)/sqrt(pi)
			endif
		break
		case "ExpModGauss":
			if (DimSize(coefs,0) == 4)
				Variable widthRatio = abs(coefs[3]/coefs[1])
				peakloc	= coefs[0]+(coefs[3])/2
				height	= coefs[2]*(1-(widthRatio/(widthRatio+1.2))^2)
				width	= abs(coefs[1]*(1+widthRatio))
				lwidth	= (width-coefs[3]/3)/2
				rwidth	= (width+coefs[3]/3)/2
			endif
		break
		case "ExpConvExp":
			if (DimSize(coefs,0) == 4)
				peakloc	= expexp_Location(coefs)
				height	= expexp_Height(coefs)
				lwidth	= 1/abs(coefs[2])
				rwidth	= 1/abs(coefs[3])
				width	= lwidth + rwidth
			endif
		break
		case "LogNormal":
			peakloc	= coefs[0]
			width	= abs(coefs[0] * coefs[1])
			height	= coefs[2]
		break
		case "DoniachSunjic":
			if (!strlen(peakFuncName))
				peakFuncName = "DoniachSunjicPeak"
			endif
		case "PCI_HighEnergy":
			if (!strlen(peakFuncName))
				peakFuncName = "PCI_Approx_Peak"
			endif
		case "PCI_Threshold":
			if (!strlen(peakFuncName))
				peakFuncName = "PCI_Strict_Peak"
			endif
			if (DimSize(coefs,0) == 5)
				Wave peakStats = FindPeakStatsHelper(coefs, peakFuncName)	// output of Amplitude, Location, FWHM, PeakArea, leftFWHM, rightFWHM as free wave
				peakloc	= peakStats[1]
				width	= peakStats[2] / (2*SqrtLn2)
				height	= peakStats[0]
				lwidth	= peakStats[4] / (2*SqrtLn2)
				rwidth	= peakStats[5] / (2*SqrtLn2)
			endif
		break
		default:			// unknown (user) peak shape
			String peakName = RemoveEnding(ReplaceString("'",NameOfWave(coefs),"")," Coefs")
			Wave/Z peak = $(GetWavesDataFolder(coefs, 1) + PossiblyQuoteName(peakName))		// if the respective peak output exists then grab the parameters numerically
			if (WaveExists(peak))
				Wave peakStats = FindPeakStatsFromPeakShape(peak)
				peakloc	= peakStats[1]
				width	= peakStats[2] / (2*SqrtLn2)
				height	= peakStats[0]
				lwidth	= peakStats[4] / (2*SqrtLn2)
				rwidth	= peakStats[5] / (2*SqrtLn2)
			endif
	Endswitch
	
	Make/Free/D output = {peakloc, width, height, lwidth, rwidth}
	return output
End

// ****************** helper function: Grab peak parameters for arbitrary peak shapes numerically ********************

Static Function/Wave FindPeakStatsFromPeakShape(Wave peak)
	Variable Amplitude = NaN, Location = NaN, FWHM = NaN, leftFWHM = NaN, rightFWHM = NaN
	Variable PeakArea = area(peak)
	WaveStats/Q peak
	if (numtype(V_max + V_min) == 0)
		Amplitude	= abs(V_max) > abs(V_min) ? V_max : V_min
		Location	= abs(V_max) > abs(V_min) ? V_maxloc : V_minloc
	endif
	Make/D/Free/n=2 Levels
	FindLevels/Q/D=Levels peak, Amplitude/2			// find the half-maximum positions
	if (V_LevelsFound == 2)
		FWHM	= abs(Levels[0]-Levels[1])
		leftFWHM  = abs(Levels[0]-Location)
		rightFWHM = abs(Location-Levels[1])
	endif
	Make/Free output = {Amplitude, Location, FWHM, PeakArea, leftFWHM, rightFWHM}
	return output
End

// ************
// Peak Functions
// ************

// The Parameter Function takes as input the fitted parameters and returns values of various derived quantities.
// For all peak types, the first four *must* be Location, Height, Area, and FWHM in that order. A given peak type may
// add additional derived parameters. For instance, Voigt peaks will have Gaussian and Lorentzian widths.
//
// The location and height parameters may be trivial for peaks that use those as fundamental fitted parameters. But
// some peak types use other fit parameters, or the actual location, height, etc., may be a combination of two or more
// of the fitted parameters.

// ********* GAUSS *********

Function/S Gauss_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;Width;Height;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "GaussPeak"						// a user-defined function is available below, but...
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToGaussGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "GaussPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"		// just the standard derived parameters
			break;
		default:
			break;
	endSwitch
	
	return info
end

// Since the guesses are based on Gaussian peaks, we don't have to do anything for the Gaussian peak type guesses
Function GaussToGaussGuess(w)
	Wave w
	
	Redimension/N=3 w
//	w[2] *= 0.7
	return 0
end

// This user-defined function version uses only the fundamental computation of a Gaussian peak. The other version
// below gives better performance.
//Function GaussPeak(w, yw, xw)
//	Wave w
//	Wave yw, xw
//	
//	yw = w[2]*exp(-((xw-w[0])/w[1])^2)
//end

static Constant SqrtPi = 1.77245385090552
static Constant sqrt2 = 1.4142135623731

// user-defined function version that uses the built-in gauss() function. It is only used if the commented line above is uncommented and the XOP
// version is commented.
Function GaussPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Variable dummy = MPFXGaussPeak(w, yw, xw)
end

// function gets coefficient wave corresponding to the fit to a single Gaussian peak (cw) and the portion of the 
// covariance matrix from the fit that is relevant to that peak. Calling code creates outWave, but doesn't
// fill it in. It is a wave with four rows and two columns:
//
//	position of real maximum		sigma of real maximum
//	real amplitude					sigma of real amplitude
//	peak area						sigma of peak area
//	FWHM							sigma of FWHM
//
// If you don't know how to calculate one of the sigmas, fill it in with NaN

Function GaussPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location		... pretty easy for a Gaussian peak
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	Variable amp = cw[2]
	Variable ampSigma = sqrt(sw[2][2])
	
	// amplitude	... also easy for a Gaussian peak
	outWave[1][0] = amp
	outWave[1][1] = ampSigma
	
	// area
	Variable width = abs(cw[1])
	Variable widthsigma = sqrt(sw[1][1])
	
	outWave[2][0] = amp*width*sqrt(Pi)
	// computation of sigma for area is based on standard formulae for propagation of errors
	outWave[2][1] = sqrt( (outWave[2][0]^2)*((sw[2][2]/cw[2]^2) + (sw[1][1]/cw[1]^2) + 2*sw[1][2]/(cw[1]*cw[2])) )
	
	// FWHM
	outWave[3][0] = width*2*sqrt(ln(2))
	outWave[3][1] = widthSigma*2*sqrt(ln(2))
end


// ********* GAUSSAREA *********

Function/S GaussArea_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;Width;Area;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "GaussAreaPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToGaussAreaGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "GaussPeakAreaParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"
			break;
		default:
			break;
	endSwitch
	
	return info
End

Function GaussToGaussAreaGuess(w)
	Wave w
	
	Redimension/N=3 w
	w[2] *= abs(w[1])*SqrtPi
	return 0
End

Function GaussAreaPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Duplicate/Free w, w2
	w2[2] /= abs(w2[1])*sqrtPi
	Variable dummy = MPFXGaussPeak(w2, yw, xw)
End

Function GaussPeakAreaParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// amplitude
	outWave[1][0] = cw[2]/abs(cw[1])/sqrt(pi)
	outWave[1][1] = outWave[1][0] * sqrt( (sw[2][2]/cw[2]^2) + (sw[1][1]/cw[1]^2) - 2*sw[1][2]/(cw[1]*cw[2]) )
	
	// area
	outWave[2][0] = cw[2]
	outWave[2][1] = sqrt(sw[2][2])
	
	// FWHM
	outWave[3][0] = abs(cw[1])*2*sqrt(ln(2))
	outWave[3][1] = sqrt(sw[1][1])*2*sqrt(ln(2))
End


// ********* LORENTZIANHEIGHT *********

Function/S LorentzianHeight_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;FWHM;Height;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "LorentzianHeightPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToLorentzianHeightGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "LorentzianHeightPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"
			break;
		default:
			break;
	endSwitch
	
	return info
End

Function GaussToLorentzianHeightGuess(w)
	Wave w
	
	Redimension/N=3 w
	w[2] /= sqrtPi/2
	return 0
end

Function LorentzianHeightPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Duplicate/Free w, w2
	w2[1] *= 2*sqrt(ln(2)) * 0.9 	// ST: 211105 - keep a bit slimmer than ideal to not overshoot fit
	w2[2] *= w2[1]*pi/2
	Variable dummy = MPFXLorentzianPeak(w2, yw, xw)
end

Function LorentzianHeightPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// amplitude
	outWave[1][0] = cw[2]
	outWave[1][1] = sqrt(sw[2][2])
	
	// area
	outWave[2][0] = cw[2]*(pi*abs(cw[1]))/2
	outWave[2][1] = outWave[1][0] * sqrt( (sw[2][2]/cw[2]^2) + (sw[1][1]/cw[1]^2) + 2*sw[1][2]/(cw[1]*cw[2]) )
	
	// FWHM
	outWave[3][0] = abs(cw[1])
	outWave[3][1] = sqrt(sw[1][1])
End

// ********* LORENTZIAN *********

Function/S Lorentzian_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;FWHM;Area;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "LorentzianPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToLorentzianGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "LorentzianPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"
			break;
		default:
			break;
	endSwitch
	
	return info
end

Function GaussToLorentzianGuess(w)
	Wave w
	
	Redimension/N=3 w
	// width of Lorenzian needs to be modified from the estimated Gaussian width
	w[1] *= 2*sqrt(ln(2)) * 0.9 	// ST: 211105 - keep a bit slimmer than ideal to not overshoot fit
	w[2] = w[1]*w[2]*sqrt(pi)
	return 0
end

Function LorentzianPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Duplicate/Free w, w2
	w2[1] = abs(w[1])				// make sure the peak gets a positive width
	Variable dummy = MPFXLorentzianPeak(w2, yw, xw)
end

// function gets coefficient wave corresponding to the fit to a single Gaussian peak (cw) and the portion of the 
// covariance matrix from the fit that is relevant to that peak. Calling code creates outWave, but doesn't
// fill it in. It is a wave with three rows and two columns:
//
//	Real position of the peak		sigma of the real location
//	position of real maximum		sigma of real maximum
//	peak area						sigma of peak area
//	FWHM							sigma of FWHM
//
// If you don't know how to calculate one of the sigmas, fill it in with NaN

Function LorentzianPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// amplitude
	outWave[1][0] = 2*cw[2]/(pi*abs(cw[1]))
	outWave[1][1] = sqrt( (outWave[1][0]^2)*((sw[2][2]/cw[2]^2) + (sw[1][1]/cw[1]^2) - 2*sw[1][2]/(cw[1]*cw[2])) )
	
	// area
	outWave[2][0] = cw[2]
	outWave[2][1] = sqrt(sw[2][2])
	
	// FWHM
	outWave[3][0] = abs(cw[1])
	outWave[3][1] = sqrt(sw[1][1])
end

// ********* VOIGT *********

Function/S Voigt_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;Width;Height;Shape;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "MPVoigtPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToVoigtGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "VoigtPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			// Voigt peaks add the Gaussian and Lorenzian contributions to the total width as derived parameters
			info = "Location;Height;Area;FWHM;Gauss Width;Lorentz Width;"
			break;
		default:
			break;
	endSwitch
	
	return info
end

Function GaussToVoigtGuess(w)
	Wave w
	
	Redimension/N=4 w
	// w[0] = location is the same
	Variable shape = 0.5			// an OK first cut for most
	//Variable amp = (shape+1)*w[2]
	w[1] = 1/w[1] * 2/(shape+1)
	w[2] = w[2]   * 2/(shape+1) * 1.15	// ST: 211111 - a closer approximation for the Voigt height
	w[3] = shape  * SqrtLn2
	return 0
end

Function MPVoigtPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Variable dummy = MPFXVoigtPeak(w, yw, xw)
end

Function VoigtPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location		... pretty easy for a Voigt peak
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	Variable amp = cw[2]
	Variable ampSigma = sqrt(sw[2][2])
	
	// amplitude
	Variable erfc3 = erfc(cw[3])
	Variable expc3_2 = exp(cw[3]^2)
			 
	outWave[1][0] = cw[2]*expc3_2*erfc3
	
	// this is derived by applying the fundamental propagation of errors formula from Bevington page 59, equation 4-8.
	// if x = f(u,v), var(x) = var(u)*df/du^2 + var(v)*df/dv^2 + 2*covar(u,v)*df/du*df/dv        var() = variance, covar() = covariance
	Variable c22sqpi = 2*cw[2]/sqrt(pi)
	Variable insideTerm = 2*cw[2]*cw[3]*expc3_2*erfc3 - c22sqpi
	outWave[1][1] = sw[2][2]*(expc3_2*erfc3)^2 + sw[3][3]*insideTerm^2 + 2*sw[2][3]*erfc3*expc3_2*insideTerm
	outWave[1][1] = sqrt(outWave[1][1])
	
	Variable width = abs(cw[1])							// This is the width affecting parameter but not a real width
	Variable widthSigma = sqrt(sw[1][1])
	Variable shape = cw[3]
	Variable shapeSigma = sqrt(sw[3][3])

	// area
	Variable parea= amp*sqrt(pi)/width
	Variable areaSigma= parea*sqrt( (ampSigma/amp)^2 + (widthSigma/width)^2 - 2*sw[2][1]/(amp*cw[1]) )
	outWave[2][0] = parea
	outWave[2][1] = abs(areaSigma)
	
	// FWHM
	Variable wg = SqrtLn2/width							// gaussian width
	Variable wgSigma = (wg/width)*widthSigma			// gaussian width sigma

	Variable wl = shape/width 							// lorentzian width
	Variable wlSigma = wl*sqrt( (shapeSigma/shape)^2 + (widthSigma/width)^2 - 2*sw[3][1]/(shape*cw[1]) )	// lorentzian width sigma

	Variable C1 = 0.5346
	Variable C2 = 0.2166
	
	// Real width: this is an approximation so we do not calculate an error.
	Variable totSigma
	totSigma  = shapeSigma^2 * (C1 + C2*wl/sqrt(C2*wl^2 + wg^2))^2		// 211103 - error propagation of the above equation: first term
	totSigma += widthSigma^2 * (C1*wl + sqrt(C2*wl^2 + wg^2))^2			// second term
	totSigma -= 2*abs(sw[3][1]) * (C1 + C2*wl/sqrt(C2*wl^2 + wg^2)) * (C1*wl + sqrt(C2*wl^2 + wg^2))		// covariance
	totSigma  = sqrt(totSigma)/width
	
	width = C1*wl + sqrt(C2*wl^2 + wg^2)				// voigt width: An approximation with an accuracy of 0.02% from Olivero and Longbothum, 1977, JQSRT 17, 233
	
	outWave[3][0] = width*2								// the above were half width at half max and we report fwhm
	outWave[3][1] = totSigma*2
	
	outWave[4][0] = wg*2
	outWave[4][1] = wgSigma*2
	
	outWave[5][0] = wl*2
	outWave[5][1] = wlSigma*2
end

// ********* VOIGTAREA *********

Function/S VoigtArea_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;GaussFWHM;Area;LorentzFWHM;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "VoigtAreaPeak"
//			info = "MPFXVoigtPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToVoigtAreaGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "VoigtAreaPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			// Voigt peaks add the Gaussian and Lorenzian contributions to the total width as derived parameters
			info = "Location;Height;Area;FWHM;Gauss Width;Lorentz Width;Shape;"
			break;
		default:
			break;
	endSwitch
	
	return info
End

Function GaussToVoigtAreaGuess(w)
	Wave w
	
	Redimension/N=4 w
	// w[0] = location is the same
	Variable width  = w[1]
	Variable height = w[2]
	w[1] = 1.5*SqrtLn2*width								// it is better to not give the full width to the Gauss and leave some for the Lorentz
	w[2] = height*width*sqrt(pi) * 1.15						// ST: 211111 - a closer approximation for the Voigt height
	w[3] = w[1]/2
	return 0
End

Function VoigtAreaPeak(Wave w, Wave yw, Wave xw) : FitFunc
	// w[0] = loc
	// w[1] = GaussFWHM
	// w[2] = area
	// w[3] = LorentzFWHM

	Variable shape = w[1] == 0 ? 1e16 : abs(w[3]/w[1])		// don't let the shape really get infinite
	Variable width = w[1] == 0 ? abs(w[3]/shape) : abs(w[1])
	
	Duplicate/Free w, w2
	w2[1] = 2*SqrtLn2/width									// Affects the width
	w2[2] = (w[2]/width)*2*SqrtLn2/sqrt(pi)					// Amplitude factor
	w2[3] = SqrtLn2*shape									// Shape factor
	
	Variable dummy = MPFXVoigtPeak(w2, yw, xw)
End

// Function VoigtAreaPeak(w, yw, xw)
	// Wave w
	// Wave yw, xw
	
	// w[0] = loc
	// w[1] = GaussFWHM
	// w[2] = area
	// w[3] = LorentzFWHM
	
	// Variable shape = w[1] == 0 ? 1e16 : abs(w[3]/w[1])	// don't let the shape really get infinite
	// Variable width = w[1] == 0 ? abs(w[3]/shape) : abs(w[1])
	// yw = (w[2]/width)*2*SqrtLn2/sqrt(pi)*VoigtFunc(2*SqrtLn2*(xw-w[0])/width, SqrtLn2*shape)
// End

Function VoigtAreaPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	// cw: "Location;GaussFWHM;Area;LorentzFWHM;"

	// location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// amplitude
	Variable shape = abs(cw[3]/cw[1])
	Variable erfc3 = erfc(shape*sqrtln2)
	Variable expc3_2 = exp((shape*sqrtln2)^2)
	Variable k = 2*SqrtLn2/sqrt(pi)
	
	outWave[1][0] = (cw[2]/abs(cw[1]))*k*expc3_2*erfc3
	
	// fundamental propagation of uncertainties:
	// if x = f(u,v,w), var(x)^2 = var(u)^2*df/du^2 + var(v)^2*df/dv^2  + var(w)^2*df/dw^2 + 2*covar(u,v)*df/du*df/dv + 2*covar(u,w)*df/du*df/dw + 2*covar(v,w)*df/dv*df/dw
	Variable insideTerm = (2*cw[1]/cw[2]*shape*expc3_2*erfc3/sqrt(pi) - 2*cw[1]*cw[2] / pi)*k
	
	outWave[1][1]  = sw[1][1] * (k/cw[2]*expc3_2*erfc3)^2
	outWave[1][1] += sw[2][2] * (k*cw[1]/cw[2]^2*expc3_2*erfc3)^2 
	outWave[1][1] += sw[3][3] * insideTerm^2
	outWave[1][1] -= 2*sw[1][2] * k*cw[1]/cw[2]^3*(expc3_2*erfc3)^2 
	outWave[1][1] += 2*sw[1][3] * k/cw[2]*expc3_2*erfc3 * insideTerm
	outWave[1][1] -= 2*sw[2][3] * k*cw[1]/cw[2]^2*expc3_2*erfc3 * insideTerm
	outWave[1][1] = sqrt(outWave[1][1])

	// area
	outWave[2][0] = cw[2]
	outWave[2][1] = sqrt(sw[2][2])
	
	Variable wg = abs(cw[1])				// gaussian width
	Variable wl = abs(cw[3])				// lorentzian width
	Variable wgSigma = sqrt(sw[1][1])		// gaussian width sigma
	Variable wlSigma = sqrt(sw[3][3])		// lorentzian width sigma
	
	Variable C1 = 0.5346
	Variable C2 = 0.2166
	
	// FWHM: this is an approximation so we do not calculate an error.
	Variable width = C1*wl + sqrt(C2*wl^2 + wg^2)						// voigt width: An approximation with an accuracy of 0.02% from Olivero and Longbothum, 1977, JQSRT 17, 233
	Variable totSigma
	totSigma  = wlSigma^2  * (C1 + C2*wl/sqrt(C2*wl^2 + wg^2))^2		// 211103 - error propagation of the above equation: first term
	totSigma += wgSigma^2  * (wg^2/(C2*wl^2 + wg^2))					// second term
	totSigma += 2*abs(sw[3][1]) * (C1 + C2*wl/sqrt(C2*wl^2 + wg^2))*(wg/sqrt(C2*wl^2 + wg^2))	// covariance
	
	outWave[3][0] = width
	outWave[3][1] = sqrt(totSigma)
	
	outWave[4][0] = cw[1]
	outWave[4][1] = sqrt(sw[1][1])
	
	outWave[5][0] = cw[3]
	outWave[5][1] = sqrt(sw[3][3])
	
	Variable shapeError = cw[1] == 0 ? NaN : sqrt( sw[1][1]/cw[1]^2 + sw[3][3]/cw[3]^2 + 2*sw[1][3]/(cw[1]*cw[3]) )
	outWave[6][0] = shape
	outWave[6][1] = outWave[6][0] * shapeError
End

// ************
// GaussConvExp
// ************

Function/S ExpModGauss_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "GaussX0;GaussWidth;Height;ExpTau;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "EMGPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToGaussConvExpGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "GaussConvExpPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;Gauss Loc;Gauss Height;Gauss FWHM;Exp Tau;"
			break;
		default:
			break;
	endSwitch
	
	return info
end

Function GaussToGaussConvExpGuess(w)
	Wave w
	
	Variable x0 = w[0]
	Variable width = w[1]
	Variable height = w[2]
	Variable lwidth = w[3]
	Variable rwidth = w[4]
	
	Redimension/N=4 w
	
	Variable widthdiff = lwidth - rwidth
	w[0] += widthdiff/2				// ST: move the peak over a bit

	if (lwidth > rwidth)			// left tail is longer
		w[1] = rwidth
		//w[3] = -3*lwidth			// Larry sez: NOTE: ExpGaussian goes wacko if k3 is greater than about 5/k2
		w[3] = -3*abs(widthdiff)	// ST: updated ExpTau calculation to work well with asymmetric peak edit
		w[3] = min(w[3],-0.2*w[1])	// ST: ExpModGauss needs some minimal asymmetry
	else
		w[1] = lwidth
		//w[3] = 3*rwidth			// Larry sez: NOTE: ExpGaussian goes wacko if k3 is greater than about 5/k2
		w[3] = 3*abs(widthdiff)
		w[3] = max(w[3],0.2*w[1])
	endif
	
	Variable widthRatio = abs(w[3])/w[1]
	w[2] = height/(1-(widthRatio/(widthRatio+1.2))^2)		// totally empirically determined
	
	return 0
end

Function EMGPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Variable dummy = MPFXEMGPeak(w, yw, xw)
end

// We need a version of the peak function in this format (coefficient wave, X value)
// to use as the object function to Optimize when estimating the real amplitude, and for the 
// object function for FindRoots when estimating the FWHM of the total peak.
Function EMGFunction(Wave w, Variable x)
	Make/D/FREE/N=1 ytemp, xtemp=x
	Variable dummy = MPFXEMGPeak(w, ytemp, xtemp)
	return ytemp[0]
end

Function/C dbgGaussConvExpFindAmpLoc(cw)
	Wave cw
	
	Variable amp, loc
	GaussConvExpFindAmpLoc(cw, amp, loc)
	return cmplx(amp, loc)
end

Function GaussConvExpFindAmpLoc(cw, amp, loc)
	Wave cw
	Variable &amp, &loc
	
	Variable x0 = cw[0]
	Variable width = cw[1]
	Variable height = cw[2]
	
	if (height > 0)
		Optimize/Q/A=1/L=(x0-10*width)/H=(x0+10*width) EMGFunction,cw
		if (V_flag == 0)
			amp = V_max
			loc = V_maxLoc
			return 0
		endif
	else
		Optimize/Q/A=0/L=(x0-10*width)/H=(x0+10*width)/Q EMGFunction,cw
		if (V_flag == 0)
			amp = V_min
			loc = V_minLoc
			return 0
		endif
	endif
	
	// If we get here, Optimize failed
	amp = NaN
	loc = NaN
	return -1
end

Function GaussConvExpFWHM(cw, amp, peakLoc)
	Wave cw
	Variable amp, peakLoc

	Variable area = cw[2]/abs(cw[3])
	Variable approxWidth = area/amp
	Variable highBracket, lowBracket
	
	if (amp > 0)
		highBracket = peakLoc
		lowBracket = peakLoc+5*approxWidth
	else
		highBracket = peakLoc+5*approxWidth
		lowBracket = peakLoc
	endif
	
	FindRoots/Q/H=(highBracket)/L=(lowBracket)/T=1e-15/Z=(amp/2) EMGFunction,cw
	if (V_flag)
		return NaN
	endif
	Variable highHalfWidth = V_Root
	
	if (amp > 0)
		highBracket = peakLoc
		lowBracket = peakLoc-5*approxWidth
	else
		highBracket = peakLoc-5*approxWidth
		lowBracket = peakLoc
	endif
	
	FindRoots/Q/H=(highBracket)/L=(lowBracket)/T=1e-15/Z=(amp/2) EMGFunction,cw
	if (V_flag)
		return NaN
	endif
	Variable LowHalfWidth = V_Root
	
	return highHalfWidth - LowHalfWidth
end

// function gets coefficient wave corresponding to the fit to a single Gaussian peak (cw) and the portion of the 
// covariance matrix from the fit that is relevant to that peak. Calling code creates outWave, but doesn't
// fill it in. It is a wave with three rows and two columns:
//
//	position of real maximum		sigma of real maximum
//	peak area						sigma of peak area
//	FWHM							sigma of FWHM
//
// If you don't know how to calculate one of the sigmas, fill it in with NaN
//
//			info = "Location;Height;Area;FWHM;Gauss Loc;Gauss Height;Gauss Area;Gauss FWHM;Exp Tau;"
//			info = "GaussX0;GaussWidth;Height;ExpTau;"
Function GaussConvExpPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	Variable amp,loc, fwhm
	GaussConvExpFindAmpLoc(cw, amp, loc)
	fwhm = GaussConvExpFWHM(cw, amp, loc)
	
	// location
	outWave[0][0] = loc
	outWave[0][1] = NaN
	
	// amplitude
	outWave[1][0] = amp
	outWave[1][1] = NaN
	
	// Area
	outWave[2][0] = cw[1]*cw[2]*sqrt(2*pi)
	outWave[2][1] = outWave[1][0]*sqrt( sw[1][1]/cw[1]^2 + sw[2][2]/cw[2]^2 + 2*sw[1][2]/(cw[1]*cw[2]) )
	
	// FWHM
	outWave[3][0] = fwhm
	outWave[3][1] = NaN
	
	// Gauss location
	outWave[4][0] = cw[0]
	outWave[4][1] = sqrt(sw[0][0])
	
	// Gauss height
	outWave[5][0] = cw[2]
	outWave[5][1] = sqrt(sw[2][2])
	
	// Gauss FWHM
	outWave[6][0] = cw[1]*2*sqrt(2*ln(2))
	outWave[6][1] = sqrt(sw[1][1])*2*sqrt(2*ln(2))
	
	// exponential decay constant
	outWave[7][0] = cw[3]
	outWave[7][1] = sqrt(sw[3][3])
end

// ************
// ExpConvExp
// ************

Function/S ExpConvExp_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
//			info = "Location;Width;Height;Shape;"
			info = "Location;Height;k1;k2;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "ExpConvExpPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToExpConvExpGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "ExpConvExpPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"
			break;
		default:
			break;
	endSwitch
	
	return info
end

Function GaussToExpConvExpGuess(w)
	Wave w
	
	Variable x0 = w[0]
	Variable width = w[1]
	Variable height = w[2]
	Variable lwidth = w[3]
	Variable rwidth = w[4]
	
	Redimension/N=4 w
//	w[0] = x0
//	w[1] = width
//	w[2] = 2*height
//	w[3] = 10
//	w[3] = 0.3/width
//	w[2] = 10*w[3]
//	w[2] = .2/lwidth
//	w[3] = .2/rwidth

	w[2] = .6/lwidth				// ST: 211105 - make peaks narrower
	w[3] = .6/rwidth
	w[1] = 3*height
	if (w[2] == w[3])
		w[3] *= 1.1
	endif
	w[0] = x0 - (ln(w[2]/w[3])/(w[2]-w[3]))
	
	return 0
end

Function ExpConvExpPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Variable dummy = MPFXExpConvExpPeak(w, yw, xw)
end

Function ExpConvExpFunc(Wave w, Variable x)		// ST: 2022-10-20 - a possibly more precise variant of above
	Make/D/FREE/N=1 ytemp, xtemp=x
	Variable dummy = MPFXExpConvExpPeak(w, ytemp, xtemp)
	return ytemp[0]
end

// function gets coefficient wave corresponding to the fit to a single Gaussian peak (cw) and the portion of the 
// covariance matrix from the fit that is relevant to that peak. Calling code creates outWave, but doesn't
// fill it in. It is a wave with three rows and two columns:
//
//	position of real maximum		sigma of real maximum
//	peak area						sigma of peak area
//	FWHM							sigma of FWHM
//
// If you don't know how to calculate one of the sigmas, fill it in with NaN

// The following functions are equations derived via Mathematica. That's why they feature those huge globs of arithmetic.
Function expexp_Location(w)
	Wave w
	
	if (w[2] == w[3])
		return 1/w[3] + w[0]
	endif
	
	return ln(w[2]/w[3])/(w[2]-w[3]) + w[0]
end

Function expexp_DLocDw2(w)
	Wave w
	
	return 1/(w[2] * (w[2]-w[3]))-ln(w[2]/w[3])/(w[2]-w[3])^2
end

Function expexp_DLocDw3(w)
	Wave w
	
	return -(1/((w[2] - w[3]) * w[3])) + ln(w[2]/w[3])/(w[2] - w[3])^2
end

Function expexp_varLoc(w, sw)
	Wave w, sw
	
	if (w[2] == w[3])
		return sw[0][0] - sw[3][3]/w[3]^4 - 2*sw[0][3]/w[3]^2
	endif
	
	return sw[2][2]*expexp_DLocDw2(w)^2 + sw[3][3]*expexp_DLocDw3(w)^2 + 2*sw[2][3]*expexp_DLocDw2(w)*expexp_DLocDw3(w)
end

Function expexp_Height(w)
	Wave w

	if (w[2] == w[3])
		return w[1]/e
	endif
	
	return (w[1] * w[2] * ((w[2]/w[3])^(-(w[2]/(w[2] - w[3]))) - (w[2]/w[3])^(-(w[3]/(w[2] - w[3])))))/(-w[2] + w[3])
end

Function expexp_DHDw1(w)
	Wave w
	
	return (w[2] * ((w[2]/w[3])^(-(w[2]/(w[2]-w[3])))-(w[2]/w[3])^(-(w[3]/(w[2]-w[3])))))/(-w[2]+w[3])
end

Function expexp_DHDw2(w)
	Wave w
	
	Variable rat = w[2]/w[3]
	Variable dif = w[2]-w[3]
	return (w[1] * w[2] * ((rat)^(-(w[2]/(dif)))-(rat)^(-(w[3]/(dif)))))/(-w[2]+w[3])^2+(w[1] * ((rat)^(-(w[2]/(dif)))-(rat)^(-(w[3]/(dif)))))/(-w[2]+w[3])+(w[1] * w[2] * ((rat)^(-(w[2]/(dif))) * (-(1/(dif))+(w[2]/(dif)^2-1/(dif)) * ln(rat))-(rat)^(-(w[3]/(dif))) * (-(w[3]/(w[2] * (dif)))+(w[3] * ln(rat))/(dif)^2)))/(-w[2]+w[3])
end

Function expexp_DHDw3(w)
	Wave w
	
	return -((w[1] * w[2] * ((w[2]/w[3])^(-(w[2]/(w[2]-w[3])))-(w[2]/w[3])^(-(w[3]/(w[2]-w[3])))))/(-w[2]+w[3])^2)+(w[1] * w[2] * ((w[2]/w[3])^(-(w[2]/(w[2]-w[3]))) * (w[2]/((w[2]-w[3]) * w[3])-(w[2] * ln(w[2]/w[3]))/(w[2]-w[3])^2)-(w[2]/w[3])^(-(w[3]/(w[2]-w[3]))) * (1/(w[2]-w[3])+(-(1/(w[2]-w[3]))-w[3]/(w[2]-w[3])^2) * ln(w[2]/w[3]))))/(-w[2]+w[3])
end

Function expexp_VarH(w, sw)
	Wave w, sw
	
	if (w[2] == w[3])
		return sw[1][1]/e
	endif
	
	Variable variance = sw[1][1] * expexp_DHDw1(w)^2 + sw[2][2] * expexp_DHDw2(w)^2 + sw[3][3] * expexp_DHDw3(w)^2
	variance += 2 * sw[1][2] * expexp_DHDw1(w) * expexp_DHDw2(w)
	variance += 2 * sw[1][3] * expexp_DHDw1(w) * expexp_DHDw3(w)
	variance += 2 * sw[2][3] * expexp_DHDw2(w) * expexp_DHDw3(w)

	return variance
end

Function ExpExpFWHM(cw, amp, peakLoc)
	Wave cw
	Variable amp, peakLoc

	Variable area = cw[1]/cw[3]
	Variable approxWidth = area/amp
	Variable highBracket, lowBracket
	
	if (amp > 0)
		highBracket = peakLoc
		lowBracket = peakLoc+3*approxWidth
	else
		highBracket = peakLoc+3*approxWidth
		lowBracket = peakLoc
	endif
	FindRoots/Q/H=(highBracket)/L=(lowBracket)/T=1e-15/Z=(amp/2) ExpConvExpFunc,cw
	if (V_flag)
		return NaN
	endif
	Variable highHalfWidth = V_Root
	
	if (amp > 0)
		highBracket = peakLoc
		lowBracket = peakLoc-3*approxWidth
	else
		highBracket = peakLoc-3*approxWidth
		lowBracket = peakLoc
	endif
	FindRoots/Q/H=(highBracket)/L=(lowBracket)/T=1e-15/Z=(amp/2) ExpConvExpFunc,cw
	if (V_flag)
		return NaN
	endif
	Variable LowHalfWidth = V_Root
	
	return highHalfWidth - LowHalfWidth
end

Function ExpConvExpPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location
	outWave[0][0] = expexp_Location(cw)
	outWave[0][1] = sqrt(expexp_varLoc(cw, sw))
	
	// amplitude
	outWave[1][0] = expexp_Height(cw)
	outWave[1][1] = sqrt(expexp_VarH(cw, sw))
	
	// area
	outWave[2][0] = cw[1]/cw[3]
	outWave[2][1] = sqrt( (outWave[2][0]^2)*((sw[1][1]/cw[1]^2) + (sw[3][3]/cw[3]^2) - 2*sw[1][3]/(cw[1]*cw[3])) )
	
	// FWHM
	outWave[3][0] = ExpExpFWHM(cw, outWave[1][0], outWave[0][0])
	outWave[3][1] = NaN
end

// ********* LOGNORMAL *********

Function/S LogNormal_PeakFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""
		
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;Width;Height;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "MPF_LogNormal"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToLogNormalGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "LogNormalPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;Area;FWHM;"
			break;
		default:
			break;
	endSwitch
	
	return info
end

Function GaussToLogNormalGuess(w)
	Wave w
	
	Redimension/N=3 w
	w[1] = w[1]/w[0]
	return 0
end

Function MPF_LogNormal(Wave w, Wave yw, Wave xw) : FitFunc
	yw = w[2]*exp(-(ln(xw/w[0])/w[1])^2)
end

// function gets coefficient wave corresponding to the fit to a single LogNormal peak (cw) and the portion of the 
// covariance matrix from the fit that is relevant to that peak. Calling code creates outWave, but doesn't
// fill it in. It is a wave with four rows and two columns:
//
//	position of real maximum		sigma of real maximum
//	real height						sigma of real height
//	peak area						sigma of peak area
//	FWHM							sigma of FWHM
//
// If you don't know how to calculate one of the sigmas, fill it in with NaN

Function LogNormalPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave
	
	// location
	outWave[0][0] = cw[0]
	outWave[0][1] = sqrt(sw[0][0])
	
	// amplitude
	outWave[1][0] = cw[2]
	outWave[1][1] = sqrt(sw[2][2])
	
	// area
	outWave[2][0] = cw[0]*abs(cw[1])*cw[2]*sqrt(pi*exp(cw[1]^2/2))
	
	outWave[2][1] = sw[0][0]^2*LogNormalDAreaDw0(cw)^2
	outWave[2][1] += sw[1][1]^2*LogNormalDAreaDw1(cw)^2
	outWave[2][1] += sw[2][2]^2*LogNormalDAreaDw2(cw)^2
	outWave[2][1] += 2*sw[0][1]^2*LogNormalDAreaDw0(cw)*LogNormalDAreaDw1(cw)
	outWave[2][1] += 2*sw[0][2]^2*LogNormalDAreaDw0(cw)*LogNormalDAreaDw2(cw)
	outWave[2][1] += 2*sw[1][2]^2*LogNormalDAreaDw1(cw)*LogNormalDAreaDw2(cw)
	outWave[2][1] = sqrt(outWave[2][1])
	
	// FWHM
	outWave[3][0] = cw[0]*(exp(abs(cw[1])*sqrt(ln(2))) - exp(-abs(cw[1])*sqrt(ln(2))))
	outWave[3][1] = sw[0][0]^2*LogNormalDFWHMDw0(cw)^2
	outWave[3][1] += sw[1][1]^2*LogNormalDFWHMDw1(cw)^2
	outWave[3][1] += 2*sw[0][1]^2*LogNormalDFWHMDw0(cw)*LogNormalDFWHMDw1(cw)
	outWave[3][1] = sqrt(outWave[3][1])
end

// Stuff for computing error bars for derived parameters

Static Constant SqrtLn2 = 0.832554611157698		// sqrt(ln(2))

Function LogNormalDAreaDw0(w)
	Wave w
	
	// Sqrt[\[ExponentialE]^(w1^2/2)] Sqrt[\[Pi]] w1 w2
	return SqrtPi*w[1]*w[2]*sqrt(exp((w[1]^2)/2))
end

Function LogNormalDAreaDw1(w)
	Wave w
	
	// 1/2 Sqrt[\[ExponentialE]^(w1^2/2)] Sqrt[\[Pi]] w0 (2+w1^2) w2
	return 0.5*SqrtPi*w[0]*w[2]*(2+w[1]^2)*sqrt(exp((w[1]^2)/2))
end
	
Function LogNormalDAreaDw2(w)
	Wave w
	
	// Sqrt[\[ExponentialE]^(w1^2/2)] Sqrt[\[Pi]] w0 w1
	return sqrt(exp((w[1]^2)/2))*SqrtPi*w[0]*w[1]
end
	
Function LogNormalDFWHMDw0(w)
	Wave w
	
	// -\[ExponentialE]^(-w1 Sqrt[Ln[2]]) + \[ExponentialE]^(w1 Sqrt[Ln[2]])
	return exp(w[1]*SqrtLn2) - exp(-w[1]*SqrtLn2)
end
	
Function LogNormalDFWHMDw1(w)
	Wave w
	
	// w0 (\[ExponentialE]^(-w1 Sqrt[Ln[2]]) Sqrt[Ln[2]]+\[ExponentialE]^(w1 Sqrt[Ln[2]]) Sqrt[Ln[2]])
	return SqrtLn2 * w[0] * (exp(-w[1]*SqrtLn2) + exp(w[1]*SqrtLn2))
end

// ********* Doniach-Sunjic shape *********
Function/S DoniachSunjic_PeakFuncInfo(InfoDesired)
	Variable InfoDesired
 
	String info=""
 
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Location;Width;Height;Alpha;GaussWidth;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "DoniachSunjicPeak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "GaussToDSPeakGuess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "DSPeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;ApproxArea;FWHM;DS Loc;DS Width;Asymmetry;GaussWidth;"
			break;
		default:
			break;
	endSwitch
 
	return info
End

// ************************************

Function DoniachSunjicPeak(Wave w, Wave yw, Wave xw) : FitFunc
	Variable Points = NumPnts(yw)
	Variable xDelta = (xw[numpnts(xw)-1]-xw[0])/(numpnts(xw)-1)
	Make/FREE/D/N=(2*Points+1) yWave								// create a wave two times as big to have space before and after the peak for the convolution
	SetScale/P x xw[0]-(Points-1)/2*Xdelta, Xdelta, yWave			// reserve 1/2 size of space before the x wave starts and 1/2 after
	
	yWave = w[2] * cos(Pi*w[3]/2+(1-w[3])*atan((x-w[0])/abs(w[1]))) / ((x-w[0])^2+w[1]^2)^((1-w[3])/2)
	PeakConvolveGaussHelper(yWave, w[4])							// Gauss convolution
	
	Variable height = w[2] > 0 ? WaveMax(yWave)	: WaveMin(yWave)	// now normalize to the height
	yWave /= height
	
	yw = w[2] * yWave(xw[p])										// write the calculated values into the result wave
End

// ************************************

Function GaussToDSPeakGuess(w)
	Wave w
	
	Variable x0		= w[0]											// extract the initial guesses
	Variable width	= w[1]
	Variable height	= w[2]
	Variable wdiff	= (w[3]-w[4])//*sign(height)					// ST: 211105 - no sign flip needed here

	// output values are: "DSPeakPos;DSWidth;DSHeight;DSalpha;GaussWidth;"
	Redimension/N=5 w												// redimension to appropriate values
	w[0] += wdiff													// nudge the peak over against the direction of the asymmetry 
	w[1] = 0.5*width												// 50% into lorentzian width
	w[4] = 0.2*width												// 20% into gaussian width
	w[3] = wdiff/width												// the asymmetry depends on width difference
	w[3] = abs(w[3]) >= 1 ? sign(w[3])*0.5 : w[3]					// asymmetry should be (considerably) smaller than 1
	//w[2] = height*w[1]^(1-abs(w[3]))								// height of DS: amplitude / width^(1-asym) => not needed, since height is normalized to 1
	return 0
end

// ************************************

Function DSPeakParams(cw, sw, outWave)
	Wave cw, sw, outWave

	// ST: 211105 - output of Amplitude, Location, FWHM, PeakArea, leftFWHM, rightFWHM as free wave
	Wave peakStats = FindPeakStatsHelper(cw, "DoniachSunjicPeak")	// approximately calculates all the results from the parameters

	// cw values are: "DSPeakPos;DSWidth;DSHeight;DSalpha;GaussWidth;"
	// output values are: "Location;Height;ApproxArea;FWHM;DS Loc;DS Width;Asymmetry;GaussWidth;"
	
	outWave[0][0] = peakStats[1]		// position
	outWave[1][0] = peakStats[0]		// height
	//if(cw[4] == 0)					// no Gauss broadening => can use analytic values
	//	outWave[0][0] = cw[0] + sign(cw[3])*cw[1]*cot(pi/(2-abs(cw[3])))		// position
	//	outWave[1][0] = cw[2]/cw[1] * cos(pi/2 * abs(cw[3])/(2-abs(cw[3]))) * (sin(pi/(2-abs(cw[3]))))^(1-abs(cw[3]))		// height
	//endif
	outWave[0][1] = NaN
	outWave[1][1] = sqrt(sw[2][2])		// height is a scaled parameter
	outWave[2][0] = peakStats[4]		// area (probably wrong)
	outWave[2][1] = NaN
	outWave[3][0] = peakStats[2]		// FWHM
	outWave[3][1] = NaN
	outWave[4][0] = cw[0]				// DS loc
	outWave[4][1] = sqrt(sw[0][0])
	outWave[5][0] = cw[1]				// DS width
	outWave[5][1] = sqrt(sw[1][1])
	outWave[6][0] = cw[3]				// asymmetry value
	outWave[6][1] = sqrt(sw[3][3])
	outWave[7][0] = cw[4]				// gauss broadening width
	outWave[7][1] = sqrt(sw[4][4])
End

// ************************************

Static Function PeakConvolveGaussHelper(Wave in, Variable width)	// convolve with a prepared gaussian
	if (width == 0 || numtype(width) != 0)
		return 0
	endif
	
	Variable pnt, dx  = DimDelta(in,0)
	width = abs(width/dx)/sqrt(2)									// width normalized by x scaling and convert to expected Gauss 'width'
	pnt = round(max(abs(10*width),11))								// create a wave 10 times the Gauss width to get the full Gauss in (5 sigma on each side)
	pnt = min(pnt, 2*numpnts(in)+1)									// doesn't have to be larger than two times the full input data
	pnt = pnt+!mod(pnt, 2)											// force odd size

	Make/FREE/D/N=(pnt) GaussWave	
	GaussWave = Gauss(x, (pnt-1)/2, width)

	Variable A = sum(GaussWave)										// make sure the gauss area limited even for a few points
	if (A > 1)
		GaussWave /= A
	endif

	Convolve/A GaussWave in
End

// ************************************

Static Function/Wave FindPeakStatsHelper(cw, PeakFunc)				// recalculate the (almost) full peak and extract all result values numerically
	Wave cw
	String PeakFunc
	Variable Amplitude = NaN, Location = NaN, FWHM = NaN, PeakArea = NaN, leftFWHM = NaN, rightFWHM = NaN
	
	Funcref GaussPeak PeakFunction = $PeakFunc											// reference the passed peak function
	
	// cw should be: 0) peakPos, 1) width, 2) height, 3) asymmetry, 4) Gausswidth
	Variable width = abs(cw[1]) + abs(cw[4])											// combined width
	Variable pntSize = 5000																// create a big wave (fine increments) => decides the numberic resoluton
	Variable SetRange = 50 * width														// a fixed size from the peak center in the direction of the asymmetry => makes the area a bit more stable
	Variable MinRange = 7 * width														// minimal range to generate in each direction
	SetRange = SetRange < MinRange ? MinRange : SetRange								// if the peak is even wider
	
	Variable Left	= cw[3] > 0 ? MinRange : SetRange
	Variable Right	= cw[3] > 0 ? SetRange : MinRange
	
	Make/FREE/N=(pntSize+1) yw, xw
	SetScale/I x, cw[0] - Left, cw[0] + Right, xw
	xw = x
	
	PeakFunction(cw, yw, xw)															// recalculate the peak with the coef set
	PeakArea = AreaXY(xw, yw)															// the area may depend on the width => should be standardized somehow
	
	WaveStats/Q yw
	if (numtype(V_max + V_min) == 0)													// ST: 211105 - make sure that there is some result
		Amplitude	= cw[2] > 0 ? V_max : V_min
		Location	= cw[2] > 0 ? xw[V_maxloc] : xw[V_minloc]
	endif

	FWHM = NaN	// set to NaN for now
	Make/D/Free/n=2 Levels
	FindLevels/Q/D=Levels yw, Amplitude/2												// find the half-maximum positions
	if (V_LevelsFound == 2)
		Left	= xw[Levels[0]]
		Right	= xw[Levels[1]]	
		FWHM	= abs(Left - Right)
		leftFWHM  = abs(Left-Location)
		rightFWHM = abs(Location-Right)
	endif
	
	if (numtype(FWHM) == 0)																// recalculate with higher resolution
		SetScale/I x, Left - 2*FWHM/(pntsize+1), Right + 2*FWHM/(pntsize+1), xw			// choose a range just a bit bigger than the FWHM
		xw = x
		PeakFunction(cw, yw, xw)
	
		WaveStats/Q yw
		Amplitude	= cw[2] > 0 ? V_max : V_min
		Location	= cw[2] > 0 ? xw[V_maxloc] : xw[V_minloc]
		FindLevels/Q/D=Levels yw, Amplitude/2
		if (V_LevelsFound == 2)
			FWHM = abs(xw[Levels[0]] - xw[Levels[1]])
			leftFWHM  = abs(xw[Levels[0]]-Location)
			rightFWHM = abs(Location-xw[Levels[1]])
		endif
	endif

	Make/Free output = {Amplitude, Location, FWHM, PeakArea, leftFWHM, rightFWHM}
	return output
End

// ************
// Baseline Functions
// ************

Structure MPF2_BLFitStruct
	Wave cWave
	Variable x
	Variable xStart
	Variable xEnd
	Wave yWave
	Wave xWave
endStructure

// ********* NO BASELINE *********
// This function is actually never called. It is present so that "None" will be one of the baseline functions offered in the menu of baseline functions.
Function/S None_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			// no parameters
			break;
		case BLFuncInfo_BaselineFName:
			info = "None_BLFunc"
			break;
	endswitch

	return info
end

Function None_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	return 0
end

// ********* CONSTANT OFFSET BASELINE *********
Function/S Constant_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "y0;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "Constant_BLFunc"
			break;
	endswitch

	return info
end

Function Constant_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	return s.cWave[0]
end

// ********* LINEAR BASELINE *********
Function/S Linear_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "a;b;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "Linear_BLFunc"
			break;
	endswitch

	return info
end

Function Linear_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	return s.cWave[0] + s.cWave[1]*s.x
end

// ********* CUBIC POLYNOMIAL BASELINE *********
Function/S Cubic_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "K0;K1;K2;K3;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "Cubic_BLFunc"
			break;
	endswitch

	return info
end

Function Cubic_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
//print w
//print/D "y=",poly(w, x)
	Variable xr = s.xEnd - s.xStart
	Variable x = (2*s.x - (s.xStart + s.xEnd))/xr
	return poly(s.cWave, x)
end

// ********* CUBIC POLYNOMIAL BASELINE IN LOG SPACE *********
Function/S LogCubic_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "K0;K1;K2;K3;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "LogCubic_BLFunc"
			break;
	endswitch

	return info
end

Function LogCubic_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
//print w
//print/D "y=",poly(w, x)
	Variable xr = log(s.xEnd/s.xStart)
	Variable x = (2*log(s.x) - log(s.xStart*s.xEnd))/xr
	return poly(s.cWave, x)
end

// ********* DEGREE-5 POLYNOMIAL BASELINE IN LOG SPACE *********
Function/S LogPoly5_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "K0;K1;K2;K3;K4;K5"
			break;
		case BLFuncInfo_BaselineFName:
			info = "LogPoly5_BLFunc"
			break;
	endswitch

	return info
end

Function LogPoly5_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
//print w
//print/D "y=",poly(w, x)
	Variable xr = log(s.xEnd/s.xStart)
	Variable x = (2*log(s.x) - log(s.xStart*s.xEnd))/xr
	return poly(s.cWave, x)
end

// ********* SHIRLEY BASELINE *********
Function/S ActiveShirley_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "scatterK;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "ActiveShirley_BLFunc"
			break;
		case BLFuncInfo_InitGuessFunc:
			info = "ActiveShirleyInit_BLFunc"
			break;	
	endswitch
	return info
End

// ************************************

Function/S PassiveShirley_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "No Effect;"							// no parameter needed
			break;
		case BLFuncInfo_BaselineFName:
			info = "PassiveShirley_FixCoef_BLFunc"		// the _FixCoef suffix makes sure the 'No Effect' parameter is ignored by the fit
			break;
		case BLFuncInfo_InitGuessFunc:
			info = "PassiveShirleyInit_BLFunc"
			break;	
	endswitch
	return info
End

// ************************************

Function ActiveShirleyInit_BLFunc(STRUCT MPF2_BLFitStruct &s)
	if(WaveExists(s.xWave))
		FindLevel/P/Q s.xWave, s.xStart
		Variable pStart = V_LevelX
		FindLevel/P/Q s.xWave, s.xEnd
		Variable pEnd = V_LevelX	
		s.cwave[0] = abs((s.yWave[pStart] - s.yWave[pEnd]) / areaXY(s.xWave,s.yWave,s.xStart,s.xEnd))
	else
		s.cwave[0] = abs((s.yWave(s.xStart) - s.yWave(s.xEnd)) / area(s.yWave,s.xStart,s.xEnd))	
	endif
End

// ************************************

Function PassiveShirleyInit_BLFunc(STRUCT MPF2_BLFitStruct &s)
	s.cwave[0] = 0
End

// ************************************

Function ActiveShirley_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	DFREF workDir = GetWavesDataFolderDFR(s.cwave)				// fetch the current data to fit from the parameter wave

	Variable error = 0
	if (s.x == s.xStart)										// generate the background only once at start
		error = GenerateShirleyBackgroundHelper(s, workDir, 1)	// generate active Shirley background using s.cwave
	endif
	
	Wave/Z BkgData = workDir:Bkg_Shirley
	if (!WaveExists(BkgData))
		return NaN
	endif
	
	Variable pos = x2pnt(BkgData, s.x)
	if (pos < 0 || pos > numpnts(BkgData)-1 || error)			// make sure the calculation never runs out of bounds
		return NaN
	endif
	
	return BkgData(s.x)
End

// ************************************

Function PassiveShirley_FixCoef_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	DFREF workDir = GetWavesDataFolderDFR(s.cwave)				// fetch the current data to fit from the parameter wave
	
	Variable error = 0
	if (s.x == s.xStart)										// generate the background only once at start
		error = GenerateShirleyBackgroundHelper(s, workDir, 0)	// generate passive Shirley background
	endif
	
	Wave/Z BkgData = workDir:Bkg_Shirley
	if (!WaveExists(BkgData))
		return NaN
	endif
	
	Variable pos = x2pnt(BkgData, s.x)
	if (pos < 0 || pos > numpnts(BkgData)-1 || error)			// make sure the calculation never runs out of bounds
		return NaN
	endif
	
	return BkgData(s.x)
End

// ************************************

Static Function GenerateShirleyBackgroundHelper(STRUCT MPF2_BLFitStruct &s, DFREF MPF2SetFolder, Variable ActiveType)
	Variable xExist	= WaveExists(s.xWave)														// for XY data
	Variable left	= pnt2x(s.yWave,0)
	Variable right	= pnt2x(s.ywave,numpnts(s.ywave)-1)
	if(xExist)
		left	= s.xWave[0]
		right	= s.xWave[numpnts(s.xWave)-1]
	endif
	
	Variable npnts = min(numpnts(s.ywave),800)													// limit the background calculation to max. 800 points
	Make/D/O/N=(npnts) MPF2SetFolder:Bkg_Shirley /WAVE=CurrShirley
	Make/D/Free/N=(npnts) PrevShirley, Difference
	SetScale/I x, left, right, CurrShirley, PrevShirley

	Variable UpperInt = 0																		// intensity to reach by the background
	Variable LowerInt = 0																		// baseline = starting point for the background
	if(xExist)
		FindLevel/P/Q s.xWave, s.xStart
		UpperInt = s.ywave[V_LevelX]
		FindLevel/P/Q s.xWave, s.xEnd
		LowerInt = s.ywave[V_LevelX]
	else
		UpperInt = s.ywave(s.xStart)
		LowerInt = s.ywave(s.xEnd)
	endif
	
	if (numtype(UpperInt) != 0 || numtype(LowerInt) != 0)
#if exists("MPF2_DisplayStatusMessage")									   
		MPF2_DisplayStatusMessage("Shirley BG: Found NaN or Inf at end points.", MPF2SetFolder)	// ST: 200626 -  pass error message to MPF2 graph
	  #endif
		CurrShirley = 0
		return 1
	endif
	
	Variable pStart	= max( x2pnt(CurrShirley,s.xStart) , 0 )									// range in points
	Variable pEnd	= min( x2pnt(CurrShirley,s.xEnd) , numpnts(CurrShirley)-1)

	Variable KFactor																			// Shirley scaling factor (scatterK)
	Variable MaxIterations = 50																	// Usually converges within 4-20 iternations; if more than 50 are needed then there is really something wrong
	Variable Convergelimit = 1e-6 * UpperInt													// converged if smaller than this value (scaled by data intensity)
	Variable counter = 1
	
	CurrShirley = 0
	PrevShirley = 0
	do																							// iterative Shirley background generation
		SetScale/I x, 0, numpnts(s.yWave)-1, Difference											// scale to wave points (makes sure the yWave assignment works for both scaled and XY data)
		Difference = s.yWave[x] - LowerInt - PrevShirley[p]										// data minus constant background and previous Shirley iteration
		MatrixOP/O Difference = replaceNaNs(Difference,0)										// make sure there are no NaNs which disturb the sum later
		SetScale/I x, left, right, Difference													// scale to Shirley data wave range
		
		if (ActiveType)																			// active or passive Shirley type
			KFactor = s.cwave[0]
		else 
			KFactor = abs((UpperInt - LowerInt) / area(Difference,s.xStart,s.xEnd))
		endif
		
		CurrShirley[pStart,pEnd] = KFactor * abs(area(Difference,x,s.xEnd))						// Shirley background calculation
		MatrixOP/free Rest = abs(sum(PrevShirley - CurrShirley))								// sum up remaining deviation
		Duplicate/free CurrShirley, PrevShirley													// save for next iteration

		counter += 1
		if (counter >= MaxIterations)															// print warning if convergence was not reached
#if exists("MPF2_DisplayStatusMessage")  
			MPF2_DisplayStatusMessage("Shirley BG didn't converge.", MPF2SetFolder)				// ST: 200530 -  pass error message to MPF2 graph
#endif	  
			// Print "Error: Shirley background calculation not converged after "+num2str(MaxIterations)+" iterations."
			CurrShirley = 0
			return 1
		endif
		// Print "Iteration:",counter,"K:",KFactor,"Variance:",Rest[0], "Limit:",Convergelimit	// debug
	while (Rest[0] > Convergelimit && counter < MaxIterations)
	
	if (!ActiveType)
#if exists("MPF2_DisplayStatusMessage")									   
		MPF2_DisplayStatusMessage("Passive Shirley BG: K factor = " + num2str(KFactor), MPF2SetFolder)	// ST: 200603 -  write current scatter coefficient to MPF2 graph
#endif	  
	endif
	
	CurrShirley += LowerInt																		// add baseline
	if (pStart > 0)
		CurrShirley[,pStart] = CurrShirley[pStart+1]											// connect to upper background (not necessary for fit; useful if working further with the data later, e.g., plotting the background)
	endif

	return 0
End

// ********* ArcTangent BASELINE *********
Function/S ArcTangent_BLFuncInfo(InfoDesired)
	Variable InfoDesired

	String info=""

	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "y0;x0;deltaY;dilation;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "arctan_BLFunc"
			break;
		case BLFuncInfo_InitGuessFunc:
			info = "arctanInit_BLFunc"
			break;	
	endswitch

	return info
End

// ************************************

Function arctanInit_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	Variable pStart, pEnd
	if(WaveExists(s.xWave))
		FindLevel/P/Q s.xWave, s.xStart
		pStart = V_LevelX
		FindLevel/P/Q s.xWave, s.xEnd
		pEnd = V_LevelX
	else
		pStart = x2pnt(s.yWave,s.xStart)
		pEnd = x2pnt(s.yWave,s.xEnd)
	endif
	Variable Upper = s.yWave[pStart]
	Variable Lower = s.yWave[pEnd]
	Variable Range = s.xEnd-s.xStart
	
	s.cwave[0] = Upper				// y0 = upper step
	s.cwave[1] = s.xStart+Range/2	// x0 = center
	s.cwave[2] = Lower-Upper		// deltaY = step height
	s.cwave[3] = Range/10			// 10% of full range
End

// ************************************

static Constant pio2 = 1.5707963267949
Function arctan_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	Variable xx = (s.x-s.cwave[1])/s.cwave[3]
	Variable scale = s.cwave[2]/pi
	
	return s.cwave[0] + (pio2 + atan(xx))*scale
End