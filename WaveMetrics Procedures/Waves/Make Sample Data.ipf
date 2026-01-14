#pragma rtGlobals=1

// HR, 12/95. Updated and revised for Igor Pro 3.0.
//		Used rtGlobals and data folders to store globals.
//		Changed all macros into functions. Then added dialog routines (e.g., MakeSamplePeriodicDialog).

Function/S SetMakeSampleDataFolderCurrent()	// Returns previous current data folder.
	String dfSav = GetDataFolder(1)

	NewDataFolder/O/S root:Packages				// Put our data folder in standard packages data folder.
	NewDataFolder/O/S :'Make Sample Data'
	return dfSav
End

Function MakeSampleDataGeneralGlobals()
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gNumPoints") == 0)
		Variable/G gNumPoints = 500
		Variable/G gXMin = 0
		Variable/G gXMax = 6
		Variable/G gPercentXNoise = 0
		Variable/G gPercentYNoise = 0
		Variable/G gAutoDisplay = 1		
	endif
	SetDataFolder dfSav
End

Function SetSampleDataSettings(numPoints, xMin, xMax, percentXNoise, percentYNoise, autoDisplay)
	Variable numPoints						// Number of points in output waves
	Variable xMin
	Variable xMax
	Variable percentXNoise
	Variable percentYNoise
	Variable autoDisplay						// 1 = yes, 2 = no

	String dfSav = SetMakeSampleDataFolderCurrent()
	
	MakeSampleDataGeneralGlobals()
	Variable/G gNumPoints, gXMin, gXMax, gPercentXNoise, gPercentYNoise, gAutoDisplay	// This just creates NVAR references. The variables were created above.
	
	gNumPoints = numPoints
	gXMin = xMin
	gXMax = xMax
	gPercentXNoise = percentXNoise
	gPercentYNoise = percentYNoise
	gAutoDisplay = autoDisplay==1
	
	SetDataFolder dfSav
End

Proc SetSampleDataSettingsDialog(numPoints, xMin, xMax, percentXNoise, percentYNoise, autoDisplay)
	Variable numPoints = NumVarOrDefault("root:Packages:Make Sample Data:gNumPoints", 500)
	Prompt numPoints, "Number of points in output waves"
	Variable xMin = NumVarOrDefault("root:Packages:Make Sample Data:gXMin", 0)
	Variable xMax = NumVarOrDefault("root:Packages:Make Sample Data:gXMax", 6)
	Variable percentXNoise = NumVarOrDefault("root:Packages:Make Sample Data:gPercentXNoise", 0)
	Prompt percentXNoise, "Percent X Noise"
	Variable percentYNoise = NumVarOrDefault("root:Packages:Make Sample Data:gPercentYNoise", 0)
	Prompt percentYNoise, "Percent Y Noise"
	Variable autoDisplay
	Prompt autoDisplay, "Auto-display output", popup "Yes;No"
	
	Silent 1
	SetSampleDataSettings(numPoints, xMin, xMax, percentXNoise, percentYNoise, autoDisplay)
End

Function MakeSampleDataWaves(xWave, yWave, numPoints, parameterWave)
	String xWave				// name of x wave or "" if waveform data
	String yWave
	Variable numPoints
	Wave parameterWave
	
	PauseUpdate; Silent 1
	
	Variable xMin = parameterWave[0]
	Variable xMax = parameterWave[1]
	Variable offset = parameterWave[2]
	Variable amplitude = parameterWave[3]
	Variable percentXNoise = parameterWave[4]
	Variable percentYNoise = parameterWave[5]
	
	Variable xNoise = amplitude * percentXNoise / 100
	Variable yNoise = amplitude * percentYNoise / 100
	
	Variable isXY = strlen(xWave) > 0
	
	Make/O/N=(numPoints) $yWave
	Wave yw = $yWave

	if (isXY)
		Make/O/N=(numPoints) $xWave
		Wave xw = $xWave
		SetScale/P x 0, 1, xw, yw
		xw = xMin + (xMax - xMin) * p / (numPoints -1)
		if (xNoise)
			xw += gnoise(xNoise)
		endif
	else
		SetScale/I x xMin, xMax, yw
	endif
	
	yw = offset + gnoise(yNoise)
End

Function/S MakeSampleTempWave(which, xWave, yWave)
	Variable which				// 1 = x, 2 = y
	String xWave					// name of x output wave or "" if none
	String yWave					// name of y output wave
	
	Variable isXY = strlen(xWave) > 0
	String xTempWaveName, yTempWaveName
	
	if (which == 1)
		if (isXY)
			xTempWaveName = "xSampleDataTemp"
			Duplicate/O $xWave, $xTempWaveName
		else
			xTempWaveName = ""
		endif
		return xTempWaveName
	endif
	
	if (which == 2)
		yTempWaveName = "ySampleDataTemp"
		Duplicate/O $yWave, $yTempWaveName
		return yTempWaveName
	endif
End

Function FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	Variable mode					// 1 = Set Output Wave, 2 = Add to Output Wave, 3 = Multiply Output Wave
	String xWave					// name of x output wave or "" if none
	String yWave					// name of y output wave
	String xTempWaveName		// name of wave containing new x data or "" if none
	String yTempWaveName		// name of wave containing new y data
	
	Variable isXY = strlen(xWave) > 0

	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName

	if (mode == 1)									// setting output wave?
		Duplicate/O ytw, $yWave
		if (isXY)
			Duplicate/O xtw, $xWave
		endif
	endif
	
	Wave yw = $yWave
	
	if (mode == 2)									// adding to output wave?
		if (isXY)
			yw += ytw
		else
			yw += ytw
		endif
	endif
	
	if (mode == 3)									// multiplying output wave?
		if (isXY)
			yw *= ytw
		else
			yw *= ytw
		endif
	endif

	KillWaves/Z ytw
	if (isXY)
		KillWaves/Z xtw
	endif
End

Function CheckMakeSampleDataDisplay(xWave, yWave)
	String xWave, yWave
	
	MakeSampleDataGeneralGlobals()
	
	Variable isXY = strlen(xWave) > 0
	String topGraphName = WinName(0, 1)					// "" if no graphs
	Variable waveIsDisplayed

	NVAR gAutoDisplay = root:Packages:'Make Sample Data':gAutoDisplay
	if (gAutoDisplay == 1)									// want to make sure new waves are displayed ?
		waveIsDisplayed = 0
		if (strlen(topGraphName))
			CheckDisplayed/W=$topGraphName $yWave
			waveIsDisplayed = V_flag
		endif
		if (waveIsDisplayed == 0)							// wave not displayed in top graph?
			if (strlen(topGraphName) == 0)				// no graph?
				Display as "Make Sample Data Graph"		// make a new graph
			endif
			if (isXY)
				AppendToGraph $yWave vs $xWave
			else
				AppendToGraph $yWave
			endif
		endif
	endif
End

Function/S MakeSampleModePrompt()
	String s

	MakeSampleDataGeneralGlobals()
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	
	sprintf s, "Mode (xMin=%.4g, xMax=%.4g)\r" gXMin, gXMax
	return s
End

// MakeSampleDataCheckWaves(proposedXWaveName, proposedYWaveName)
//	proposedXWaveName is "_none_", "_new_" or a name of a wave which may or may not exist.
//	proposedYWaveName is "_new_" or a name of a wave which may or may not exist.
//	
//	This routine generates wave names if the proposed name is "_new_".
//	It then makes the wave or waves if they do not already exist.
//
//	It returns the names as a semicolon-separated string. For example: "xData0;yData0".
//	The x wave name may be zero-length. There is no semicolon at the end.
Function/S MakeSampleDataCheckWaves(proposedXWaveName, proposedYWaveName)
	String proposedXWaveName, proposedYWaveName

	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	
	Variable i
	String xBase, xWave, yBase, yWave
	Variable needNewXWaveName, needNewYWaveName

	needNewXWaveName = CmpStr(proposedXWaveName, "_new_") == 0
	needNewYWaveName = CmpStr(proposedYWaveName, "_new_") == 0
	xWave = proposedXWaveName
	yWave = proposedYWaveName
	xBase = "xData"
	yBase = "yData"
	
	if (CmpStr(proposedXWaveName, "_none_") == 0)
		xWave = ""
	endif
	if (needNewXWaveName)
		i = 0
		do
			xWave = xBase + num2istr(i)
			if (exists(xWave) == 0)									// x name is free but check
				if (needNewYWaveName == 0)						// NOT making XY pair ?
					break												// we're done
				endif
				// Here if making XY pair. We want the appended digit to be the same for X and Y.
				yWave = yBase + num2istr(i)
				if (exists(yWave) == 0)								// is yData<nnn> free also
					needNewYWaveName = 0							// so that we don't try to make another y wave below
					break												// we're done
				endif
			endif
			i += 1
		while (1)
	endif

	if (needNewYWaveName)
		i = 0
		do
			yWave = yBase + num2istr(i)
			if (exists(yWave) == 0)									// y name is free ?
				break													// yes, we're done
			endif
			i += 1
		while (1)
	endif

	// At this point we have generated wave names, if necessary. Now make the waves.
	
	if (strlen(xWave) > 0)							// x wave needed ?
		if (exists(xWave) == 0)						// need to make it ?
			Make/N=(gNumPoints) $xWave
			Printf "Created new X wave: %s\r", xWave
		endif
	endif
	
	if ((exists(yWave) == 0))						// need to make it ?
		Make/N=(gNumPoints) $yWave
		Printf "Created new Y wave: %s\r", yWave
	endif

	return xWave + ";" + yWave						// e.g. "xData0;yData0"
End

Function FMakeSampleTriangle(x)		// x goes from 0 to 1
	Variable x
	
	if (x < .5)
		return 2*x
	else
		return 2*(1 - x)
	endif
End

Function SetSamplePeriodicGlobals(type, offset, amplitude, phase, cycles)
	Variable type, offset, amplitude, phase, cycles
	
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gPeriodicType") == 0)
		Variable/G gPeriodicType = type
		Variable/G gPeriodicOffset = offset
		Variable/G gPeriodicAmplitude = amplitude
		Variable/G gPeriodicPhase = phase
		Variable/G gPeriodicCycles = cycles
	endif
	SetDataFolder dfSav
End

Function MakeSamplePeriodic(xWave, yWave, mode, type, offset, amplitude, phase, cycles)
	String xWave					// name of x wave, "_none_" or "_new_"
	String yWave					// name of y wave or "_new_"
	Variable mode					// 1 = set output wave, 2 = add to output wave, 3 = multiply with output wave
	Variable type					// 1 = sine, 2 = square wave, 3 = triangle wave, 4 = sawtooth
	Variable offset					// DC offset
	Variable amplitude			// signal amplitude
	Variable phase					// phase in degrees
	Variable cycles				// number of cycles
	
	// Save settings for next time
	SetSamplePeriodicGlobals(type, offset, amplitude, phase, cycles)
	
	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	NVAR gPercentXNoise = root:Packages:'Make Sample Data':gPercentXNoise
	NVAR gPercentYNoise = root:Packages:'Make Sample Data':gPercentYNoise
	
	Variable isXY
	String xTempWaveName, yTempWaveName
	Variable omega
	
	String temp = MakeSampleDataCheckWaves(xWave, yWave)	// returns, for example, "xData0;yData0"
	Variable pos = strsearch(temp,";",0)			// Find semicolon between x and y wave names
	xWave = temp[0, pos-1]							// Extract x wave name
	yWave = temp[pos+1, strlen(temp)]			// Extract y wave name
	isXY = strlen(xWave) > 0

	phase = phase*PI/180						// convert to radians
	omega = 2*PI*cycles / (gXMax - gXMin)
	omega *= (gNumPoints-1) / gNumPoints		// one cycle goes up to but not including start of next cycle
	
	xTempWaveName = MakeSampleTempWave(1, xWave, yWave)
	yTempWaveName = MakeSampleTempWave(2, xWave, yWave)
	
	Make/O/N=6 pwMakeSampleData			// parameter wave for MakeSampleData
	pwMakeSampleData[0] = gXMin
	pwMakeSampleData[1] = gXMax
	pwMakeSampleData[2] = offset
	pwMakeSampleData[3] = amplitude
	pwMakeSampleData[4] = gPercentXNoise
	pwMakeSampleData[5] = gPercentYNoise
	MakeSampleDataWaves(xTempWaveName, yTempWaveName, gNumPoints, pwMakeSampleData)
	KillWaves/Z pwMakeSampleData

	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName
	
	if (type == 1)			// sine ?
		if (isXY)
			ytw += amplitude*sin(phase + omega*xtw)
		else
			ytw += amplitude*sin(phase +  omega*x)
		endif
	endif
	
	if (type == 2)			// square wave ?
		if (isXY)
			ytw += amplitude*(sawtooth(phase + omega*xtw) < .5)
		else
			ytw += amplitude*(sawtooth(phase +  omega*x) < .5)
		endif
	endif
	
	if (type == 3)			// Triangle wave ?
		if (isXY)
			ytw += amplitude*(FMakeSampleTriangle(sawtooth(phase + omega*xtw)))
		else
			ytw += amplitude*(FMakeSampleTriangle(sawtooth(phase +  omega*x)))
		endif
	endif
	
	if (type == 4)			// sawtooth wave ?
		if (isXY)
			ytw += amplitude*sawtooth(phase + omega*xtw)
		else
			ytw += amplitude*sawtooth(phase +  omega*x)
		endif
	endif

	FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	CheckMakeSampleDataDisplay(xWave, yWave)		// display new data if desired
End

Proc MakeSamplePeriodicDialog(xWave, yWave, mode, type, offset, amplitude, phase, cycles)
	String xWave					// name of x wave or "" if waveform data
	Prompt xWave, "X Wave", popup "_none_;_new_;" + WaveList("*", ";", "")
	String yWave
	Prompt yWave, "Y Wave", popup "_new_;" + WaveList("*", ";", "")
	Variable mode = 1
	Prompt mode, MakeSampleModePrompt(), popup "Set Output Wave;Add to Output Wave;Multiply Output Wave"
	Variable type = NumVarOrDefault("root:Packages:'Make Sample Data':gPeriodicType", 1)
	Prompt type, "Type", popup "Sine;Square;Triangle;Sawtooth"
	Variable offset = NumVarOrDefault("root:Packages:'Make Sample Data':gPeriodicOffset", 0)
	Prompt offset, "Offset"
	Variable amplitude = NumVarOrDefault("root:Packages:'Make Sample Data':gPeriodicAmplitude", 1)
	Prompt amplitude, "Amplitude"
	Variable phase = NumVarOrDefault("root:Packages:'Make Sample Data':gPeriodicPhase", 0)
	Prompt phase, "Phase in Degrees"
	Variable cycles = NumVarOrDefault("root:Packages:'Make Sample Data':gPeriodicCycles", 1)
	Prompt cycles, "Cycles"

	PauseUpdate; Silent 1

	MakeSamplePeriodic(xWave, yWave, mode, type, offset, amplitude, phase, cycles)
End

Function FMakeSamplePulse(x, pulseStart, pulseEnd)		// all in radians
	Variable x
	Variable pulseStart
	Variable pulseEnd
	
	if (x < 0)
		x = 2*PI + mod(x, 2*PI)		// convert negative phase to equivalent positive
	endif
	x = mod(abs(x), 2*PI)
	if ((x >= pulseStart) %& (x < pulseEnd))
		return 1
	else
		return 0
	endif
End

Function SetSamplePulseGlobals(offset, amplitude, phase, cycles, widthInDegrees)
	Variable offset, amplitude, phase, cycles, widthInDegrees
	
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gPulseOffset") == 0)
		Variable/G gPulseOffset = offset
		Variable/G gPulseAmplitude = amplitude
		Variable/G gPulsePhase = phase
		Variable/G gPulseCycles = cycles
		Variable/G gPulseWidthInDegrees = widthInDegrees
	endif
	SetDataFolder dfSav
End

Function MakeSamplePulse(xWave, yWave, mode, offset, amplitude, phase, cycles, widthInDegrees)
	String xWave					// name of x wave, "_none_" or "_new_"
	String yWave					// name of y wave or "_new_"
	Variable mode					// 1 = set output wave, 2 = add to output wave, 3 = multiply with output wave
	Variable offset					// DC offset
	Variable amplitude			// signal amplitude
	Variable phase					// phase in degrees
	Variable cycles				// number of cycles
	Variable widthInDegrees		// pulse width
	
	// Save settings for next time
	SetSamplePulseGlobals(offset, amplitude, phase, cycles, widthInDegrees)
	
	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	NVAR gPercentXNoise = root:Packages:'Make Sample Data':gPercentXNoise
	NVAR gPercentYNoise = root:Packages:'Make Sample Data':gPercentYNoise
	
	Variable isXY
	String xTempWaveName, yTempWaveName
	Variable omega, pulseStart, pulseEnd
	
	String temp = MakeSampleDataCheckWaves(xWave, yWave)	// returns, for example, "xData0;yData0"
	Variable pos = strsearch(temp,";",0)			// Find semicolon between x and y wave names
	xWave = temp[0, pos-1]							// Extract x wave name
	yWave = temp[pos+1, strlen(temp)]			// Extract y wave name
	isXY = strlen(xWave) > 0

	phase = phase*PI/180						// convert to radians
	omega = 2*PI*cycles / (gXMax - gXMin)
	omega *= (gNumPoints-1) / gNumPoints	// one cycle goes up to but not including start of next cycle
	pulseStart = 0
	pulseEnd = widthInDegrees*PI/180			// convert to radians
	
	xTempWaveName = MakeSampleTempWave(1, xWave, yWave)
	yTempWaveName = MakeSampleTempWave(2, xWave, yWave)
	
	Make/O/N=6 pwMakeSampleData			// parameter wave for MakeSampleData
	pwMakeSampleData[0] = gXMin
	pwMakeSampleData[1] = gXMax
	pwMakeSampleData[2] = offset
	pwMakeSampleData[3] = amplitude
	pwMakeSampleData[4] = gPercentXNoise
	pwMakeSampleData[5] = gPercentYNoise
	MakeSampleDataWaves(xTempWaveName, yTempWaveName, gNumPoints, pwMakeSampleData)
	KillWaves/Z pwMakeSampleData
	
	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName

	if (isXY)
		ytw += amplitude*(FMakeSamplePulse(phase + omega*xtw, pulseStart, pulseEnd))
	else
		ytw += amplitude*(FMakeSamplePulse(phase +  omega*x, pulseStart, pulseEnd))
	endif

	FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	CheckMakeSampleDataDisplay(xWave, yWave)		// display new data if desired
End

Proc MakeSamplePulseDialog(xWave, yWave, mode, offset, amplitude, phase, cycles, widthInDegrees)
	String xWave					// name of x wave or "" if waveform data
	Prompt xWave, "X Wave", popup "_none_;_new_;" + WaveList("*", ";", "")
	String yWave
	Prompt yWave, "Y Wave", popup "_new_;" + WaveList("*", ";", "")
	Variable mode = 1
	Prompt mode, MakeSampleModePrompt(), popup "Set Output Wave;Add to Output Wave;Multiply Output Wave"
	Variable offset = NumVarOrDefault("root:Packages:'Make Sample Data':gPulseOffset", 0)
	Prompt offset, "Offset"
	Variable amplitude = NumVarOrDefault("root:Packages:'Make Sample Data':gPulseAmplitude", 1)
	Prompt amplitude, "Amplitude"
	Variable phase = NumVarOrDefault("root:Packages:'Make Sample Data':gPulsePhase", 0)
	Prompt phase, "Phase in Degrees"
	Variable cycles = NumVarOrDefault("root:Packages:'Make Sample Data':gPulseCycles", 1)
	Prompt cycles, "Cycles"
	Variable widthInDegrees = NumVarOrDefault("root:Packages:'Make Sample Data':gPulseWidthInDegrees", 30)
	Prompt widthInDegrees, "Width in Degrees"
	
	PauseUpdate; Silent 1
	MakeSamplePulse(xWave, yWave, mode, offset, amplitude, phase, cycles, widthInDegrees)
End

Function SetSampleExpGlobals(offset, amplitude, timeConstant)
	Variable offset, amplitude, timeConstant
	
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gExpOffset") == 0)
		Variable/G gExpOffset = offset
		Variable/G gExpAmplitude = amplitude
		Variable/G gExpTimeConstant = timeConstant
	endif
	SetDataFolder dfSav
End

Function MakeSampleExponential(xWave, yWave, mode, offset, amplitude, timeConstant)
	String xWave					// name of x wave, "_none_" or "_new_"
	String yWave					// name of y wave or "_new_"
	Variable mode					// 1 = set output wave, 2 = add to output wave, 3 = multiply with output wave
	Variable offset					// DC offset
	Variable amplitude			// signal amplitude
	Variable timeConstant			// time constant in seconds

	// Save settings for next time
	SetSampleExpGlobals(offset, amplitude, timeConstant)
	
	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	NVAR gPercentXNoise = root:Packages:'Make Sample Data':gPercentXNoise
	NVAR gPercentYNoise = root:Packages:'Make Sample Data':gPercentYNoise
	
	Variable isXY
	String xTempWaveName, yTempWaveName
	
	String temp = MakeSampleDataCheckWaves(xWave, yWave)	// returns, for example, "xData0;yData0"
	Variable pos = strsearch(temp,";",0)			// Find semicolon between x and y wave names
	xWave = temp[0, pos-1]							// Extract x wave name
	yWave = temp[pos+1, strlen(temp)]			// Extract y wave name
	isXY = strlen(xWave) > 0
	
	xTempWaveName = MakeSampleTempWave(1, xWave, yWave)
	yTempWaveName = MakeSampleTempWave(2, xWave, yWave)
	
	Make/O/N=6 pwMakeSampleData			// parameter wave for MakeSampleData
	pwMakeSampleData[0] = gXMin
	pwMakeSampleData[1] = gXMax
	pwMakeSampleData[2] = offset
	pwMakeSampleData[3] = amplitude
	pwMakeSampleData[4] = gPercentXNoise
	pwMakeSampleData[5] = gPercentYNoise
	MakeSampleDataWaves(xTempWaveName, yTempWaveName, gNumPoints, pwMakeSampleData)
	KillWaves/Z pwMakeSampleData

	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName
	
	if (isXY)
		ytw += amplitude*exp(-xtw/timeConstant)
	else
		ytw += amplitude*exp(-x/timeConstant)
	endif

	FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	CheckMakeSampleDataDisplay(xWave, yWave)		// display new data if desired
End

Proc MakeSampleExponentialDialog(xWave, yWave, mode, offset, amplitude, timeConstant)
	String xWave					// name of x wave or "" if waveform data
	Prompt xWave, "X Wave", popup "_none_;_new_;" + WaveList("*", ";", "")
	String yWave
	Prompt yWave, "Y Wave", popup "_new_;" + WaveList("*", ";", "")
	Variable mode = 1
	Prompt mode, MakeSampleModePrompt(), popup "Set Output Wave;Add to Output Wave;Multiply Output Wave"
	Variable offset = NumVarOrDefault("root:Packages:'Make Sample Data':gExpOffset", 0)
	Prompt offset, "Offset"
	Variable amplitude = NumVarOrDefault("root:Packages:'Make Sample Data':gExpAmplitude", 1)
	Prompt amplitude, "Amplitude"
	Variable timeConstant = NumVarOrDefault("root:Packages:'Make Sample Data':gExpTimeConstant", 1)
	Prompt timeConstant, "Time constant"

	PauseUpdate; Silent 1
	MakeSampleExponential(xWave, yWave, mode, offset, amplitude, timeConstant)
End

Function SetSampleGaussianGlobals(offset, amplitude, xCenter, FWHM)
	Variable offset, amplitude, xCenter, FWHM
	
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gGaussOffset") == 0)
		Variable/G gGaussOffset = offset
		Variable/G gGaussAmplitude = amplitude
		Variable/G gGaussXCenter = xCenter
		Variable/G gGaussFWHM = FWHM
	endif
	SetDataFolder dfSav
End

Function MakeSampleGaussian(xWave, yWave, mode, offset, amplitude, xCenter, fwhm)
	String xWave					// name of x wave, "_none_" or "_new_"
	String yWave					// name of y wave or "_new_"
	Variable mode					// 1 = set output wave, 2 = add to output wave, 3 = multiply with output wave
	Variable offset					// DC offset
	Variable amplitude			// signal amplitude
	Variable xCenter				// center of Gaussian in x dimension
	Variable fwhm					// full width at half max
	
	// Save settings for next time
	SetSampleGaussianGlobals(offset, amplitude, xCenter, FWHM)
	
	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	NVAR gPercentXNoise = root:Packages:'Make Sample Data':gPercentXNoise
	NVAR gPercentYNoise = root:Packages:'Make Sample Data':gPercentYNoise
	
	Variable isXY
	String xTempWaveName, yTempWaveName
	Variable lk3
	
	String temp = MakeSampleDataCheckWaves(xWave, yWave)	// returns, for example, "xData0;yData0"
	Variable pos = strsearch(temp,";",0)			// Find semicolon between x and y wave names
	xWave = temp[0, pos-1]							// Extract x wave name
	yWave = temp[pos+1, strlen(temp)]			// Extract y wave name
	isXY = strlen(xWave) > 0
	
	xTempWaveName = MakeSampleTempWave(1, xWave, yWave)
	yTempWaveName = MakeSampleTempWave(2, xWave, yWave)
	
	Make/O/N=6 pwMakeSampleData			// parameter wave for MakeSampleData
	pwMakeSampleData[0] = gXMin
	pwMakeSampleData[1] = gXMax
	pwMakeSampleData[2] = offset
	pwMakeSampleData[3] = amplitude
	pwMakeSampleData[4] = gPercentXNoise
	pwMakeSampleData[5] = gPercentYNoise
	MakeSampleDataWaves(xTempWaveName, yTempWaveName, gNumPoints, pwMakeSampleData)
	KillWaves/Z pwMakeSampleData
	
	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName

	lk3 = fwhm / (2 * sqrt(ln(2)))		// K3 in Gaussian formula
	if (isXY)
		ytw += amplitude*exp(-((xtw-xCenter)/lk3)^2)
	else
		ytw += amplitude*exp(-((x-xCenter)/lk3)^2)
	endif

	FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	CheckMakeSampleDataDisplay(xWave, yWave)		// display new data if desired
End

Proc MakeSampleGaussianDialog(xWave, yWave, mode, offset, amplitude, xCenter, fwhm)
	String xWave					// name of x wave or "" if waveform data
	Prompt xWave, "X Wave", popup "_none_;_new_;" + WaveList("*", ";", "")
	String yWave
	Prompt yWave, "Y Wave", popup "_new_;" + WaveList("*", ";", "")
	Variable mode = 1
	Prompt mode, MakeSampleModePrompt(), popup "Set Output Wave;Add to Output Wave;Multiply Output Wave"
	Variable offset = NumVarOrDefault("root:Packages:'Make Sample Data':gGaussOffset", 0)
	Prompt offset, "Offset"
	Variable amplitude = NumVarOrDefault("root:Packages:'Make Sample Data':gGaussAmplitude", 1)
	Prompt amplitude, "Amplitude"
	Variable xCenter = NumVarOrDefault("root:Packages:'Make Sample Data':gGaussXCenter", 3)
	Prompt xCenter, "X Center"
	Variable fwhm = NumVarOrDefault("root:Packages:'Make Sample Data':gGaussFWHM", 1)
	Prompt fwhm, "Full Width at Half Max"

	PauseUpdate; Silent 1
	MakeSampleGaussian(xWave, yWave, mode, offset, amplitude, xCenter, fwhm)
End

Function SetSampleNoiseGlobals(offset, amplitude, type, whichWave)
	Variable offset, amplitude, type, whichWave
	
	String dfSav = SetMakeSampleDataFolderCurrent()
	if (exists("gNoiseOffset") == 0)
		Variable/G gNoiseOffset = offset
		Variable/G gNoiseAmplitude = amplitude
		Variable/G gNoiseType = type
		Variable/G gNoiseWhichWave = whichWave
	endif
	SetDataFolder dfSav
End

Function MakeSampleNoise(xWave, yWave, mode, offset, amplitude, type, whichWave)
	String xWave					// name of x wave, "_none_" or "_new_"
	String yWave					// name of y wave or "_new_"
	Variable mode					// 1 = set output wave, 2 = add to output wave, 3 = multiply with output wave
	Variable offset					// DC offset
	Variable amplitude			// signal amplitude
	Variable type					// 1 = normal, 2 = even
	Variable whichWave			// 1 = add noise to x wave, 2 = add noise to y wave, 3 = add to both
	
	// Save settings for next time
	SetSampleNoiseGlobals(offset, amplitude, type, whichWave)
	
	MakeSampleDataGeneralGlobals()
	NVAR gNumPoints = root:Packages:'Make Sample Data':gNumPoints
	NVAR gXMin = root:Packages:'Make Sample Data':gXMin
	NVAR gXMax = root:Packages:'Make Sample Data':gXMax
	NVAR gPercentXNoise = root:Packages:'Make Sample Data':gPercentXNoise
	NVAR gPercentYNoise = root:Packages:'Make Sample Data':gPercentYNoise
	
	Variable isXY
	String xTempWaveName, yTempWaveName
	
	String temp = MakeSampleDataCheckWaves(xWave, yWave)	// returns, for example, "xData0;yData0"
	Variable pos = strsearch(temp,";",0)			// Find semicolon between x and y wave names
	xWave = temp[0, pos-1]							// Extract x wave name
	yWave = temp[pos+1, strlen(temp)]			// Extract y wave name
	isXY = strlen(xWave) > 0
	
	xTempWaveName = MakeSampleTempWave(1, xWave, yWave)
	yTempWaveName = MakeSampleTempWave(2, xWave, yWave)
	
	Make/O/N=6 pwMakeSampleData			// parameter wave for MakeSampleData
	pwMakeSampleData[0] = gXMin
	pwMakeSampleData[1] = gXMax
	pwMakeSampleData[2] = offset
	pwMakeSampleData[3] = amplitude
	pwMakeSampleData[4] = gPercentXNoise
	pwMakeSampleData[5] = gPercentYNoise
	MakeSampleDataWaves(xTempWaveName, yTempWaveName, gNumPoints, pwMakeSampleData)
	KillWaves/Z pwMakeSampleData

	Wave ytw = $yTempWaveName
	Wave/Z xtw = $xTempWaveName
	
	if (isXY)
		if ((whichWave == 1) %| (whichWave == 3))
			if (type == 1)									// Normal
				xtw += gnoise(amplitude)
			endif
			if (type == 2)									// Even
				xtw += enoise(amplitude)
			endif
		endif
	endif
	
	if ((whichWave == 2) %| (whichWave == 3))
		if (type == 1)										// Normal
			ytw += gnoise(amplitude)
		endif
		if (type == 2)										// Even
			ytw += enoise(amplitude)
		endif
	endif
	
	FinishMakeSampleData(mode, xWave, yWave, xTempWaveName, yTempWaveName)
	CheckMakeSampleDataDisplay(xWave, yWave)		// display new data if desired
End

Proc MakeSampleNoiseDialog(xWave, yWave, mode, offset, amplitude, type, whichWave)
	String xWave					// name of x wave or "" if waveform data
	Prompt xWave, "X Wave", popup "_none_;_new_;" + WaveList("*", ";", "")
	String yWave
	Prompt yWave, "Y Wave", popup "_new_;" + WaveList("*", ";", "")
	Variable mode = 1
	Prompt mode, MakeSampleModePrompt(), popup "Set Output Wave;Add to Output Wave;Multiply Output Wave"
	Variable offset = NumVarOrDefault("root:Packages:'Make Sample Data':gNoiseOffset", 0)
	Prompt offset, "Offset"
	Variable amplitude = NumVarOrDefault("root:Packages:'Make Sample Data':gNoiseAmplitude", 1)
	Prompt amplitude, "Amplitude"
	Variable type = NumVarOrDefault("root:Packages:'Make Sample Data':gNoiseType", 1)
	Prompt type, "Noise type", popup "Normal;Even"
	Variable whichWave = NumVarOrDefault("root:Packages:'Make Sample Data':gNoiseWhichWave", 2)
	Prompt whichWave, "Add noise to", popup "X Wave;Y Wave;X and Y Waves"

	PauseUpdate; Silent 1
	MakeSampleNoise(xWave, yWave, mode, offset, amplitude, type, whichWave)
End
