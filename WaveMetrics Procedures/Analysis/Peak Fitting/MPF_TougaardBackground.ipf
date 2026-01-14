#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 9.00
#pragma version = 1.00

#include <Multipeak Fitting>

// Author: Stephan Thuermer
// Original date: 4/15/2020
// Implements the Tougaard background for the Multipeak Fit package.
// To use, just add this line to your Procedure window:
//#include <MPF2_TougaardBackground>

Static Constant MPF2_TougaardDataSize = 500		// size of the data and CS waves for calculation (larger is slower)

// ********* TOUGAARD BASELINE *********

Function/S Tougaard_Three_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "B;C;D;t0"
			break;
		case BLFuncInfo_BaselineFName:
			info = "Tougaard_BLFunc"
			break;
		case BLFuncInfo_InitGuessFunc:
			info = "TougaardInit_BLFunc"
			break;	
	endswitch
	return info
End

// ************************************

Function/S Tougaard_Two_BLFuncInfo(InfoDesired)
	Variable InfoDesired
	String info=""
	switch(InfoDesired)
		case BLFuncInfo_ParamNames:
			info = "B;C;"
			break;
		case BLFuncInfo_BaselineFName:
			info = "Tougaard_BLFunc"
			break;
		case BLFuncInfo_InitGuessFunc:
			info = "TougaardInit_BLFunc"
			break;	
	endswitch
	return info
End

// ************************************

Function TougaardInit_BLFunc(s)
	STRUCT MPF2_BLFitStruct &s
	
	// recommended values from Tougaard et al., Surface and Interface Analysis 25, 137-154 (1997)
	Switch (numpnts(s.cWave))
		case 2:	// two-parameter universal CS
			s.cWave[0] = 2866 // metals in general
			s.cWave[1] = 1643
		break
		case 3:	// three-parameter universal CS
			s.cWave[0] = 325 // SiO2
			s.cWave[1] = 542
			s.cWave[2] = 275
		break
		case 4:	// three-paramter universal CS with band-gap parameter for semi-conductors / insulators
			s.cWave[0] = 325 // SiO2
			s.cWave[1] = 542
			s.cWave[2] = 275
			s.cWave[3] = 7
		break
	EndSwitch
End

// ************************************

Function Tougaard_BLFunc(STRUCT MPF2_BLFitStruct &s)
	DFREF workDir = GetWavesDataFolderDFR(s.cwave)			// fetch the current data to fit from the parameter wave
	
	Variable error = 0
	if (s.x == s.xStart)
		error = GenerateTougaardResultsHelper(s, workDir)	// generate parametric cross section for Tougaard once
	endif
	
	Wave/Z results = workDir:Bkg_TougaardResults
	if (!WaveExists(results))								// make sure to abort if some problem with the work waves occurs
		return NaN
	endif

	return results(s.x)
End

// ************************************

Static Function GenerateTougaardCSHelper(STRUCT MPF2_BLFitStruct &s, DFREF MPF2SetFolder)
	Make/D/O/N=(MPF2_TougaardDataSize) MPF2SetFolder:Bkg_TougaardCS /WAVE=CSdata
	
	Variable left	= pnt2x(s.yWave,0)
	Variable right	= pnt2x(s.ywave,numpnts(s.ywave)-1)
	if(WaveExists(s.xWave))
		left	= s.xWave[0]
		right	= s.xWave[numpnts(s.xWave)-1]
	endif
	SetScale/I x 0, abs(left-right), CSdata		// cross section data needs to be properly scaled from zero
	
	//s.cWave parameters: 0 = B, 1 = C, 2 = D
	Switch (numpnts(s.cWave))
		case 2:	// two-parameter universal CS
			CSData = s.cWave[0] * x / (s.cWave[1] + x^2)^2	// note the + sign
		break
		case 3:	// three-parameter universal CS
			CSdata = s.cWave[0] * x / ((s.cWave[1] - x^2)^2 + s.cWave[2] * x^2)	
		break
		case 4:	// three-paramter universal CS with band-gap parameter for semi-conductors / insulators
			CSdata = s.cWave[0] * x / ((s.cWave[1] - x^2)^2 + s.cWave[2] * x^2)	* 0.5*(1+tanh((x-s.cWave[3])/0.2))
		break
	EndSwitch
	
	return 0
End

// ************************************

Static Function GenerateTougaardResultsHelper(STRUCT MPF2_BLFitStruct &s, DFREF MPF2SetFolder)
	Variable error = 0
	
	error = GenerateTougaardCSHelper(s, MPF2SetFolder)	// generate parametric cross section for Tougaard
	
	Variable xExist	= WaveExists(s.xWave)	// for XY data	
	Make/O/D/N=(MPF2_TougaardDataSize) MPF2SetFolder:Bkg_TougaardResults /WAVE=WorkData				// ST: 200626 - create the destination beforehand
	if (xExist)								// create a temporary wave with reduced data size	
		SetScale/I x, s.xWave[0], s.xWave[DimSize(s.xWave, 0)-1], WorkData							// ST: 200626 - make sure the x scale includes the full x range
		Interpolate2/T=2/I=3/E=2/Y=WorkData s.xWave, s.yWave
	else
		SetScale/I x, DimOffset(s.yWave, 0), ((DimSize(s.yWave, 0)-1)*DimDelta(s.yWave, 0) + DimOffset(s.yWave, 0)), WorkData
		Interpolate2/T=2/I=3/E=2/Y=WorkData s.yWave
	endif
	
	Variable pEnd
	if(xExist)
		FindLevel/P/Q s.xWave, s.xEnd
		pEnd = V_LevelX
	else
		pEnd = x2pnt(s.yWave,s.xEnd)
	endif
	Variable Lower = s.yWave[pEnd]			// the lower baseline

	if (numtype(Lower) != 0)
		MPF2_DisplayStatusMessage("Tougaard BG: Found NaN or Inf at start point.", MPF2SetFolder)	// ST: 200626 - pass error message to MPF2 graph
		WorkData = 0
		return 1
	endif

	// Variable Clock = startMStimer		// ##### timing
	
	Variable delta = abs(DimDelta(WorkData,0))
	MatrixOp/free Data = delta * (WorkData - Lower)	

	Wave CSdata = MPF2SetFolder:Bkg_TougaardCS	
	MatrixOp/free SizeMat	= const(MPF2_TougaardDataSize, MPF2_TougaardDataSize, MPF2_TougaardDataSize)
	MatrixOp/free ShiftMat	= indexRows(SizeMat) + indexCols(SizeMat)
	MatrixOp/free Multiply	= waveMap(Data,ShiftMat) * greater(SizeMat , ShiftMat) * colRepeat(CSdata,MPF2_TougaardDataSize)	// shift data successively to the left and multiply with CS data (cut excess points)
	MatrixOp/O WorkData		= sumCols(Multiply)^t + Lower
	
	// Print stopMStimer(Clock)				// ##### timing
	
	return error
End