#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.00
#pragma IgorVersion = 4.00

// Preliminary version b01

#include <TransformAxis>

Function DoProcessProbabilityDataPanel()
	if (WinType("ProcessProbabilityData") == 7)
		DoWindow/F ProcessProbabilityData
	else
		ProbProcessInitGlobals()
		fProcessProbabilityDataPanel()
	endif
end

Function ProbProcessInitGlobals()

	String SaveDF = GetDatafolder(1)
	SetDatafolder root:
	NewDatafolder/O/S Packages
	NewDatafolder/O/S ProcessProbabilityData
	
	String/G ProbOutputWaveName = "ProcessedProbabilityData"
	
	SetDatafolder $SaveDF
end

Function fProcessProbabilityDataPanel()

	NewPanel /K=1/W=(395,157,717,411) as "Process Probability Data"
	DoWindow/C ProcessProbabilityData
	PopupMenu ProbRawWaveMenu,pos={16,27},size={248,20},title="Raw Data Wave:"
	PopupMenu ProbRawWaveMenu,mode=1,bodyWidth= 150,value= #"WaveList(\"*\",\";\", \"\")"
	GroupBox ProbInputBox,pos={11,7},size={300,51},title="Input"
	GroupBox ProbOutputBox,pos={11,71},size={300,124},title="Output"
	SetVariable ProbSetOutputWaveName,pos={18,95},size={286,15},title="Output Wave Name:"
	SetVariable ProbSetOutputWaveName,limits={-Inf,Inf,1},value= root:Packages:ProcessProbabilityData:ProbOutputWaveName
	CheckBox ProbPercentCheckbox,pos={18,116},size={126,14},title="Process to Percent"
	CheckBox ProbPercentCheckbox,value= 0
	Button ProbProcessDoIt,pos={136,217},size={50,20},proc=ProbProcessDoItButtonProc,title="Do It"
	CheckBox ProbMakeIndexCheck,pos={18,136},size={113,14},title="Make Sort Index"
	CheckBox ProbMakeIndexCheck,value= 0
	CheckBox ProbMakeGraph,pos={18,156},size={97,14},title="Graph Results",value= 0
	CheckBox ProbGraphAsX,pos={42,173},size={191,14},title="Probability on Horizontal Axis"
	CheckBox ProbGraphAsX,value= 0
EndMacro

Function ProbProcessDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo ProbRawWaveMenu
	Wave iw = $S_value
	SVAR ProbOutputWaveName = root:Packages:ProcessProbabilityData:ProbOutputWaveName
	ControlInfo ProbPercentCheckbox
	Variable DoPercentOutput = V_value
	ControlInfo ProbMakeIndexCheck
	Variable MakeSortIndex = V_value
	String ProbFunction = "TransAx_Probability"
	
	Variable retval = probAxisProcess(iw, ProbOutputWaveName, DoPercentOutput, MakeSortIndex)
	if (retval == -1)
		abort "Your output name is too long."
	endif
	if (retval == -2)
		abort "Your output name contains illegal characters. You cannot control characters, quite marks, ';' or ':' in a wave name."
	endif
	
	ControlInfo ProbMakeGraph
	if (V_value)
		Wave/Z wp = $(ProbOutputWaveName+"_P")
		Wave/Z wx = $(ProbOutputWaveName+"_X")
		if ( !WaveExists(wp) || !WaveExists(wx) )
			abort "For some reason, the processed probability waves are not present."
		endif
		ControlInfo ProbGraphAsX
		if (DoPercentOutput)
			ProbFunction = "TransAx_Probability_Percent"
		endif
		if (!DataFolderExists("root:Packages:TransformAxis"))
			TransformAxisPanelInitGlobals()
		endif
		if (V_value)
			Display wx vs wp
			SetupTransformTraces("", "Bottom", ProbFunction, $"", 3, 0, 5, 1)	// tick density 3, no minor ticks, min sep = 5, do ticks at ends
		else
			Display wp vs wx
			SetupTransformTraces("", "Left", ProbFunction, $"", 3, 0, 5, 1)	// tick density 3, no minor ticks, min sep = 5, do ticks at ends
		endif
	endif
	
	DoWindow/K ProcessProbabilityData
End

// This function takes the input wave and produces two output waves. One output wave contains the values
// of the input wave sorted into ascending order. The other wave contains simply ascending numbers that
// represent the percentiles for each point in the sorted wave.

// The output waves are given names derived from the string input in processedName. The sorted version
// of the input is in processedName+"_X". The percentiles are in processedName+"_P". If DoPercentOutput
// is non-zero, the perentile wave contains numbers in the range (0,100). If it is zero, the
// percentile wave contains numbers in the range (0,1).

// If MakeSortIndex is non-zero, a sort index wave is created that can be used to put another wave
// into the same ordering as the sorted output wave. This wave has the name processedName+"_I". To use it,
// do this:
//   Duplicate wave1, newWave
//   newWave = wave1[indexWave[p]]

// Before doing anthing, processedName is checked for length and legality. If it is too long, probAxisProcess
// returns -1. If it is not a legal wave name, it returns -2. Success returns 0.
Function probAxisProcess(w1,processedName, DoPercentOutput, MakeSortIndex)
	Wave w1					// wave containing samples from some random population
	String processedName		// desired name for processed wave
	Variable DoPercentOutput	// do probabilities as percent (0-100) instead of fractions (0-1)
	Variable MakeSortIndex		// Provide a sorting index wave that reflects the ordering of the processed data
	
	Variable returnValue = 0
	
	if (strlen(processedName) > 29)		// we will be adding two characters to this name
		returnValue = -1
	endif
	
	if (returnValue == 0)
		if (CheckName(processedName, 1) == 0)
			Duplicate/O w1, $(processedName+"_P")
			Duplicate/O w1, $(processedName+"_X")
			Wave outPW = $(processedName+"_P")
			Wave outXW = $(processedName+"_X")
			
			Duplicate/O w1, $(processedName+"_I")
			Wave outIW = $(processedName+"_I")
			MakeIndex w1, $(processedName+"_I")
		
			outXW = w1[outIW[p]]
			outPW = (p+.5)/numpnts(w1)
			if (DoPercentOutput)
				outPW *= 100
			endif
			
			if (!MakeSortIndex)
				KillWaves/Z outIW
			endif
		endif
	endif
	
	return returnValue
end
