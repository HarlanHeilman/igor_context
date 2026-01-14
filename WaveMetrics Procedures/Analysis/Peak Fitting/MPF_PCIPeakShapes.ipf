#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access.
#pragma IgorVersion = 9.00
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version = 1.01

#include <Multipeak Fitting>

// Author: Stephan Thuermer
// Original date: 4/15/2020
// Implements the Post-Collision Interaction peak shapes for the Multipeak Fit package.
// To use, just add this line to your Procedure window:
//#include <MPF2_PCIPeakShapes>

// rev 1.01 ST 211105
//		FIxed sign error in guess function

// ********* Post-Collision Interaction shapes *********

Function/S PCI_HighEnergy_PeakFuncInfo(InfoDesired)	// Approximate Post-Collision Interaction shape useable for higher energies
	Variable InfoDesired

	String info=""
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:
			info = "Position;Gamma;Height;Asymmetry;GaussWidth;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "PCI_Approx_Peak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "PCI_Approx_Guess"
			break;
		case PeakFuncInfo_ParameterFunc:
			info = "PCI_Approx_PeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;ApproxArea;FWHM;PCI shift;Asymmetry;"
			break;
		default:
			break;
	EndSwitch
	return info
End

// ************************************

Function/S PCI_Threshold_PeakFuncInfo(InfoDesired)	// Strict Post-Collision Interaction shape for very low energies
	Variable InfoDesired

	String info=""
	Switch (InfoDesired)
		case PeakFuncInfo_ParamNames:	
			info = "Position;Gamma;Height;Asymmetry;GaussWidth;"
			break;
		case PeakFuncInfo_PeakFName:
			info = "PCI_Strict_Peak"
			break;
		case PeakFuncInfo_GaussConvFName:
			info = "PCI_Approx_Guess"				// same guess as for the approximate version
			break;
		case PeakFuncInfo_ParameterFunc:	
			info = "PCI_Strict_PeakParams"
			break;
		case PeakFuncInfo_DerivedParamNames:
			info = "Location;Height;ApproxArea;FWHM;PCI shift;Asymmetry;"
			break;
		default:
			break;
	EndSwitch
	return info
End

// ************************************
// An asymmetric shaped lorentian to model the PCI effect in electron spectra
// (after van der Straten et al., Z. Phys. D, vol. 8, p. 35 (1988) expression [12])
// A clear write up of the formula can be found in Lindblad et al. JCP 123, 211101 (2005)
Function PCI_Approx_Peak(Wave w, Wave yw, Wave xw) : FitFunc

	Variable Points = NumPnts(yw)
	Variable xDelta = (xw[numpnts(xw)-1]-xw[0])/(numpnts(xw)-1) 
	Make/FREE/D/N=(2*Points+1) yWave								// create a wave two times as big to have space before and after the peak for the convolution
	SetScale/P x xw[0]-(Points-1)/2*Xdelta, Xdelta, yWave			// reserve 1/2 size of space before the x wave starts and 1/2 after
			
	// w: "PCIPos;PCIGamma;PCIHeight;Asymmetry;GaussWidth;"
	Variable Wi = abs(w[1]) / 2										// width = gamma / 2
	Variable S  = w[3]												// shape asymmetry
	if (S == 0)														// if no asymmetry
		yWave = Wi /(Wi^2 + (x-w[0])^2) /pi							// just the Lorentz part
	else
		yWave = Wi /(Wi^2 + (x-w[0])^2) * S/sinh(Pi*S) * exp(2*S*atan((x-w[0])/Wi))	// PCI shape: Lorentz function times asymmetry
	endif

	PeakConvolveGaussHelper(yWave, w[4])							// Gauss convolution
	
	Variable height = WaveMax(yWave)								// now normalize to the height
	yWave /= height
	
	yw = w[2] * yWave(xw[p])
End

// ************************************
//	A complex calculation of the PCI shape for low PE energies near the threshold
//	(after van der Straten et al., Z. Phys. D, vol. 8, p. 35 (1988) expression [8])
//	For this peak shape to work, kinetic energy position of the peak must be correct and > 0!
//	To use angular dependent peak shape create variables with the names
//	"PCI_beta" and "PCI_angle" inside the set folder and insert the values for the
//	anisotropy beta and the angle between polarization vector and detector.
Function PCI_Strict_Peak(Wave w, Wave yw, Wave xw) : FitFunc
	
	Variable Points = NumPnts(yw)
	Variable xDelta = (xw[numpnts(xw)-1]-xw[0])/(numpnts(xw)-1) 
	Make/FREE/D/N=(2*Points+1) yWave, ew							// create a wave two times as big to have space before and after the peak for the convolution
	SetScale/P x xw[0]-(Points-1)/2*Xdelta, Xdelta, yWave, ew		// reserve 1/2 size of space before the x wave starts and 1/2 after
	
	MPF2_DisplayStatusMessage("Note: Use PCI_Thres. with correct kinetic energies.", GetWavesDataFolderDFR(w))	// ST: 200530 - display explanation inside the graph
	
	// w: "PCIPos;PCIGamma;PCIHeight;Asymmetry;GaussWidth;"
	if (w[0]<0)		// this peak shape does not work with negative positions
		return NaN
	endif
	//+++++++++++++++++++++++++++ now calculate the threshold PCI ++++++++++++++++++++++++++++++
	Variable E = w[0]/27.2, width = abs(w[1])/27.2 / 2				// extract the parameters (convert energies to atomic units: 1 hartree = 27.2 eV)
	Variable s = w[3]												// the asymmetry
	Variable Ep, Ea, derivedE = 1 /( 1/sqrt(E) + sqrt(2)*s )^2		// photon and Auger energies calculated from the shape input
	
	Ea	= s > 0 ? E : derivedE										// decide if peak is an Auger peak or photoelectron peak
	Ep	= s > 0 ? derivedE : E
//	Print "Auger Energy:", Ea*27.2, "PE Energy:", Ep*27.2			// debug

	NVAR/Z Anisotropy_beta		= DFRPath:PCI_beta					// hidden functionality: definied variables for polarization dependence
	NVAR/Z Polarization_angle	= DFRPath:PCI_angle
	
	Variable PolDependence = 0										// including polarization-angle dependence
	if (NVAR_Exists(Anisotropy_beta) && NVAR_Exists(Polarization_angle))			// look for the used variables
		PolDependence = 1/10*Anisotropy_beta*(3*cos(Polarization_angle*(Pi/180))^2 - 1)
	endif
	
	Variable C = 1 - sqrt(Ep/Ea) - PolDependence*(Ep/Ea)^1.5		// van der Straten shortcut
	if(Ep >= Ea)
		C = PolDependence*(Ep/Ea)
	endif
//	Print/D "Aysmmetry factor:",C									// debug

	Variable/C Ec = cmplx(Ep,width)									// the complex energy in the phase
	Variable E1 = 1													// potential energy of the electron at radius i (does not influence the shape at all)
	ew = sign(s)*(x/27.2 - E)										// energy axis = energy difference between nominal and observed energy

	if (s == 0)
		yWave = width*27.2 / (ew^2 + width^2) / pi					// a simple Lorentz if there is no assymetry
	else
		yWave = Imag( PCI_I(E1,Ec,1) - PCI_I(cmplx(ew/C,width/C),Ec,1) - PCI_I(E1,Ep-ew,1+C) + PCI_I(cmplx(ew/C,width/C),Ep-ew,1+C) )	// calculate the imaginary phase
		yWave = exp( 2*sqrt(2)*yWave)																									// exponent of the phase
		yWave /= (ew^2 + width^2) * ( (Ep + ew/C)^2 + width^2 * (1+1/C)^2 )^0.25														// including the denominator
	endif
	
	FastOp ew = ywave												// copy for MatrixOp
	MatrixOp/O yWave = replaceNaNs(ew,0)							// make sure there are no NaNs or Infs which screw up the Convolution
	PeakConvolveGaussHelper(yWave, w[4])							// Gauss convolution
	
	Variable height = WaveMax(yWave)								// now normalize to the height
	yWave /= height// (pi*width*27.2)
	
	yw = w[2] * yWave(xw[p])										// write the calculated values into the resultwave
End
//++++++++++++++++++++++++++++++++ function shortcut of the phase ++++++++++++++++++++++++++++++
Static Function/C PCI_I(z,E,ex)										// helper function to calculate the phase sums
	Variable/C z,E,ex
	Variable/C C = sqrt(E + z*ex)
	return C/z - ex/(2*sqrt(E)) * ln((C-sqrt(E))/(C+sqrt(E)))
End

// ************************************

Function PCI_Approx_Guess(w)
	Wave w

	Variable x0		= w[0]											// extract the initial guesses
	Variable width	= w[1]
	Variable wdiff	= (w[4]-w[3])//*sign(w[2])						// ST: 211105 - don't use the sign of height here
	
	Redimension/N=5 w												// redimension to apropriate values
	// w values are: "PCIPos;PCIGamma;PCIHeight;Asymmetry;GaussWidth;"
	w[0] -= wdiff
	w[1] = 0.8*width												// 80% into lorentzian width
	w[3] = 5*wdiff/width											// asymmetry depending on width difference
	w[4] = 0.6*width												// 60% into gaussian width
	return 0
End

// ************************************

Function PCI_Approx_PeakParams(cw, sw, outWave)
	Wave cw, sw, outWave

	Variable Amplitude, Location, FWHM, PeakArea
	FindPeakStatsHelper(cw, "PCI_Approx_Peak", Amplitude, Location, FWHM, PeakArea)			// approximately calculates all the results from the parameters

	// cw values are: "PCIPos;PCIGamma;PCIHeight;Asymmetry;GaussWidth;"
	// output values are: "Location;Height;Area;FWHM;PCI shift;Asymmetry;"
	outWave[0][0] = Location		// position
	outWave[0][1] = NaN
	outWave[1][0] = Amplitude		// height
	outWave[1][1] = sqrt(sw[2][2])	// height is a scaled parameter
	outWave[2][0] = PeakArea		// area
	outWave[2][1] = NaN
	outWave[3][0] = FWHM			// FWHM
	outWave[3][1] = NaN
	outWave[4][0] = cw[1]/2*cw[3]	// PCI shift = Gamma/2*s
	outWave[4][1] = sqrt( (outWave[4][0]^2)*((sw[3][3]/cw[3]^2) + (sw[1][1]/cw[1]^2) + 2*sw[1][3]/(cw[1]*cw[3])) )
	outWave[5][0] = cw[3]			// Asymmetry
	outWave[5][1] = sqrt(sw[3][3])
End

// ************************************

Function PCI_Strict_PeakParams(cw, sw, outWave)
	Wave cw, sw, outWave

	Variable Amplitude, Location, FWHM, PeakArea
	FindPeakStatsHelper(cw, "PCI_Strict_Peak", Amplitude, Location, FWHM, PeakArea)			// approximately calculates all the results from the parameters

	// cw values are: "PCIPos;PCIGamma;PCIHeight;Asymmetry;GaussWidth;"
	// output values are: "Location;Height;Area;FWHM;PCI shift;Asymmetry;"
	outWave[0][0] = Location		// position
	outWave[0][1] = NaN
	outWave[1][0] = Amplitude		// height
	outWave[1][1] = sqrt(sw[2][2])	// height is a scaled parameter
	outWave[2][0] = PeakArea		// area
	outWave[2][1] = NaN
	outWave[3][0] = FWHM			// FWHM
	outWave[3][1] = NaN
	outWave[4][0] = cw[1]/2*cw[3]	// PCI shift = Gamma/2*s
	outWave[4][1] = sqrt( (outWave[4][0]^2)*((sw[3][3]/cw[3]^2) + (sw[1][1]/cw[1]^2) + 2*sw[1][3]/(cw[1]*cw[3])) )
	outWave[5][0] = cw[3]			// Asymmetry
	outWave[5][1] = sqrt(sw[3][3])
End

// ************************************

Static Function PeakConvolveGaussHelper(Wave in, Variable width)	// convolve with a prepared gaussian
	if (width == 0 || numtype(width) != 0)
		return 0
	endif
	
	Variable pnt, dx  = DimDelta(in,0)
	width = abs(width/dx)/sqrt(2)		// width normalized by x scaling and convert to expected Gauss 'width'
	pnt = round(max(abs(10*width),11))	// create a wave 10 times the Gauss width to get the full Gauss in (5 sigma on each side)
	pnt = min(pnt, 2*numpnts(in)+1)		// doesn't have to be larger than two times the full input data
	pnt = pnt+!mod(pnt, 2)				// force odd size

	Make/FREE/D/N=(pnt) GaussWave	
	GaussWave = Gauss(x, (pnt-1)/2, width)

	Variable A = sum(GaussWave)			// make sure the gauss area limited even for a few points
	if (A > 1)
		GaussWave /= A
	endif

	Convolve/A GaussWave in
End

// ************************************

Static Function FindPeakStatsHelper(cw, PeakFunc, Amplitude, Location, FWHM, PeakArea)	// recalculate the (almost) full peak and extract all result values numerically
	Wave cw
	String PeakFunc
	Variable &Amplitude, &Location, &FWHM, &PeakArea
	
	Funcref GaussPeak PeakFunction = $PeakFunc				// reference the passed peak function
	
	// cw should be: 0) peakPos, 1) width, 2) height, 3) asymmetry, 4) Gausswidth
	Variable width = abs(cw[1]) + abs(cw[4])				// combined width
	Variable pntSize = 5000									// create a big wave (fine increments) => decides the numberic resoluton
	Variable SetRange = 50 * width							// a fixed size from the peak center in the direction of the asymmetry => makes the area a bit more stable
	Variable MinRange = 7 * width							// minimal range to generate in each direction
	SetRange = SetRange < MinRange ? MinRange : SetRange	// if the peak is even wider
	
	Variable Left	= cw[3] > 0 ? MinRange : SetRange
	Variable Right	= cw[3] > 0 ? SetRange : MinRange
	
	Make/FREE/N=(pntSize+1) yw, xw
	SetScale/I x, cw[0] - Left, cw[0] + Right, xw
	xw = x
	
	PeakFunction(cw, yw, xw)								// recalculate the peak with the coef set
	PeakArea = AreaXY(xw, yw)								// the area may depend on the width => should be standardized somehow
		
	WaveStats/Q yw
	if (numtype(V_max + V_min) == 0)						// ST: 211105 - make sure that there is some result
		Amplitude	= cw[2] > 0 ? V_max : V_min
		Location	= cw[2] > 0 ? xw[V_maxloc] : xw[V_minloc]
	endif

	FWHM = NaN	// set to NaN for now
	Make/D/Free/n=2 Levels
	FindLevels/Q/D=Levels yw, Amplitude/2					// find the half-maximum positions
	if (V_LevelsFound == 2)
		Left	= xw[Levels[0]]
		Right	= xw[Levels[1]]	
		FWHM	= abs(Left - Right)
	endif
	
	if (numtype(FWHM) == 0)									// recalculate with higher resolution
		SetScale/I x, Left - 2*FWHM/(pntsize+1), Right + 2*FWHM/(pntsize+1), xw		// choose a range just a bit bigger than the FWHM
		xw = x
		PeakFunction(cw, yw, xw)
	
		WaveStats/Q yw
		Amplitude	= cw[2] > 0 ? V_max : V_min
		Location	= cw[2] > 0 ? xw[V_maxloc] : xw[V_minloc]
		FindLevels/Q/D=Levels yw, Amplitude/2
		if (V_LevelsFound == 2)
			FWHM = abs(xw[Levels[0]] - xw[Levels[1]])
		endif
	endif

	return 0
End