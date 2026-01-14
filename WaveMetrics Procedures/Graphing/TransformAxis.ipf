#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.15
#pragma IgorVersion = 5.01

#include <ProcessProbabilityData>
#include <String Substitution>
#include <SaveRestoreWindowCoords>

static constant debugInfo = 0
static constant debugUpdates = 0

Menu "Graph"
	Submenu "Transform Axis"
		"Transform Axis...",/Q, DoTransformAxisPanel(0)
		"Untransform Axis...",/Q, DoTransformAxisPanel(2)
		"Modify Transform Axis...",/Q, DoTransformAxisPanel(1)
		"Edit Ticks on Transform Axis...",/Q, TransformEditTicksShowPanel()
		"Refresh Graph",/Q, RefreshGraph()
//		"-"
//		"Update to Transform Axis 1.2", ShowUpdate1_2_Panel()
	end
end

Menu "New"
		"Probability Graph",/Q, DoProcessProbabilityDataPanel()
end

//*********************************
// Procedures to make an axis that plots data transformed by a user-defined transform function (like a log axis, but arbitrary function instead of log)
//
//	Problems with having it implemented this way include at least:
//		1) So far, we don't get "re-draw" messages, so we don't know to adjust the axis for a change in the data or window re-size, etc.
//		2) Adding a new trace to the axis will require either doing it through a procedure, or undoing the transform, adding
//			the trace, then re-doing the transform.
//		3) In the case where the axis range is hard-balled, must handle the possibility that the range includes numbers that
//			aren't in the range of the transformation function (and FindRoots will fail)
//
//	Things to do:
//		1) AdjustTickLabelSpacing() doesn't yet handle horizontal axes. 						DONE (but does it work correctly?)
//		2) Window Hook for re-sizing the graph window. 											DONE
//		3) Mouse hooks for clicking on a transformed axis. 											***Decided not to do this.
//		4) If 3) then we need to be able to invoke the regular Modify Axis dialog at need.				*** and this is why.
// 		5) Check it out on Windows. 																	DONE if such a thing can be done
//		6) Add option for exponential labels.
//		7) Apply button for Modify Transform Axis panel 											DONE
//		8) Panels should remember position															DONE
// 		9) Mirror axis 																					DONE
//		10) It would be nice if the transform function could be changed without undoing and re-doing
//		11) "Refresh the Graph" in the Graph menu													DONE
//		12) When a user edits the ticks, the edits should be preserved when the axis is re-drawn		DONE
//		13) changing the range of an axis with an inverting function swaps the axis ends	I THINK THIS IS FIXED BY ACCIDENT...
//		14) Transform mirror axes need to calculate the space required and automatically set the margin.
//		15) Need to save a recreation macro...
//*********************************

//*********************************
// version 1.01:
//   Fixes a problem with deriving data folder names from very long graph names.
//   Tweaks to the algorithms to make better tick and label spacing.
//   Added Refresh Graph to the Graph->Transform Axis menu.
// version 1.02:
//   Checks for quotes when parsing the AxisInfo string to figure out the axis font. Required for bug-fix in Igor 4.02b.
//   Checks for legal axis range when creating a transform mirror axis.
//   Turned off debugUpdates to prevent "Recursion Attempted" error messages.
// version 1.03:
//   Fixed bug that caused an infinite loop if there were other traces on the graph attached to non-transformed axes
//     having the same orientation as the transformed axis.
// version 1.04:
//   Major revision of the algorithms for selecting ticks.
// version 1.05:
//   Tightened up the FindRoots tolerances to allow inverting functions that are assymptotic to some value. This was
//     inspired by a data set to be plotted on a probability axis having P=0.99999999997495 and P= 3.5799848615418e-09!
//   Tightened up the FindRoots tolerance used by TransAx_Probability() to invert the erf function. The new tolerance
//     allows values to at least 9 or 10 nines and down to at least 1e-10.
//   Fixes for various roundoff problems caused by tick deltas that are very small relative to the magnitude of the
//     the tick values.
//   Made changes to the control panels to improve convenience. Most obviously, the axis menus list all transform
//     axes, both regular and mirror axes. The panels decide internally how to deal with the chosen axis.
// version 1.06:
//		fixed possible infinite loop in FindTransformLimit()
// version 1.07:
//		fixed bug- a new transform mirror axis would not display the added ticks at end or minor ticks, but they could
//			be added later.
// version 1.08:
//		fixed bug- edit ticks panel for a mirror axis needed to transform the axis end points before comparing with
//			label values. If a label happened to be almost exactly equal to the axis end point, it was moved to the end.
// version 1.09:
//		Added alert to ask if you want to keep transformation information when a graph is closed. This allows
// 			you to save a recreation macro for the graph.
// version 1.10:
//		Fixed bug that prevented proper transmission of transform function's coefficient wave
//			to the datafolder for the transform axis.
// version 1.11:
//		Fixed bug that caused an error message if the graph's window hook was set, but no
//			Packages datafolder exists.
// version 1.12:
//		Fixed bug that caused multiple alert boxes to appear if you selected Modified Reciprocal transform
//			as the function to use to make a transformed axis (not a mirror axis).
//		Fixed bug that left the current data folder set to a folder deep in Packages when you clicked the Apply
//			button in the Modify Transform Axis panel.
// version 1.13:
//		Fixed bug that caused a failure to set up the Edit Ticks control panel.
// version 1.14:
//		Added code to upgrade to Transform Axis 1.20
// version 1.15, JP160517
//		PanelResolution changes for Igor 7.
//*********************************

//Function ShowUpdate1_2_Panel()
//
//	if (WinType("TransformAxisUpdate1_2Panel") != 0)
//		DoWindow/F TransformAxisUpdate1_2Panel
//	else
//		fUpdate1_2_Panel()
//	endif
//end
//
//Function fUpdate1_2_Panel()
//
//	NewPanel /W=(44,49,344,249) as "Update to Transform Axis 1.2"
//	DoWindow/C TransformAxisUpdate1_2Panel
//	SetDrawLayer UserBack
//	SetDrawEnv fsize= 10
//	DrawText 36,22,"You are using an old version of the Transform"
//	SetDrawEnv fsize= 10
//	DrawText 36,38,"Axis package. Click Update to 1.2 below to load"
//	SetDrawEnv fsize= 10
//	DrawText 36,54,"the new version. There are advantages and"
//	SetDrawEnv fsize= 10
//	DrawText 36,70,"disadvantages to updating to the new version."
//	SetDrawEnv fsize= 10
//	DrawText 36,86,"Click the Help button to learn more."
//	Button TransAxUpdate1_2Button,pos={63,131},size={150,20},proc=TransAxUpdate1_2ButtonProc,title="Update to 1.2"
//	Button TransAxNoUpdate1_2Button,pos={63,164},size={150,20},proc=TransAxNoUpdate1_2ButtonProc,title="DO NOT Update"
//	Button TransAxUpdateTo12HelpButton,pos={112,94},size={50,20},proc=TransAxUpdateTo12HelpButtonProc,title="Help"
//end
//
//Function TransAxUpdate1_2ButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	Execute/P/Q/Z "DELETEINCLUDE <ProcessProbability>"
//	Execute/P/Q/Z "DELETEINCLUDE <TransformAxis>"
//	Execute/P/Q/Z "INSERTINCLUDE <TransformAxis1.2>"
//	Execute/P/Q/Z "Variable/G root:Packages:TransformAxis:TransAxisUpdateLock = 1"
//	NVAR/Z DontUpdate = root:Packages:TransformAxis:DontUpdate
//	if (NVAR_EXISTS(DontUpdate))
//		KillVariables DontUpdate
//	endif
//	Execute/P/Q/Z "COMPILEPROCEDURES "
//	Execute/P/Q/Z "fUpdateTransAxGraphsPanel()"
//	DoWindow/K TransformAxisUpdate1_2Panel
//End
//
//Function TransAxNoUpdate1_2ButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	Variable/G root:Packages:TransformAxis:DontUpdate = 1
//	DoWindow/K TransformAxisUpdate1_2Panel
//End
//
//Function TransAxUpdateTo12HelpButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	DisplayHelpTopic "Transform Axis Package[Updating Graphs from Previous Versions]"
//End

// this function searches for a datafolder for the named graph. It does this
// by first searching all the datafolders in the Packages datafolder for one
// containing a global string containing the graph name. If it can't find it,
// it then tries to generate a datafolder name from the graph name and tries
// to find that. If it succedes, it returns the name of the found datafolder.
// If it fails, it returns "".
Function/S folderForThisGraph(theGraph, Type)
	String theGraph
	Variable type			// 0 for transform axis; 1 for mirror axis
	
	String saveDF = GetDatafolder(1)
	if (!DataFolderExists("root:Packages:"))
		return ""
	endif
	
	SetDatafolder root:Packages:
	String theDF=""
	Variable foundIt = 0
	String dfName
	
	Variable i=0
	String aDF=""
	do
		aDF = GetIndexedObjName("", 4, i)
		if (strlen(aDF) == 0)
			break
		endif
		if ( ((Type == 0) && (CmpStr(aDF[0,13], "AxisTransform_") == 0)) || ((Type == 1) && (CmpStr(aDF[0,15], "TransformMirror_") == 0)) )
			SetDatafolder $aDF
			SVAR/Z actualGraphName
			if (SVAR_Exists(actualGraphName) && (CmpStr(theGraph, actualGraphName) == 0) )
				theDF = GetDatafolder(1)
				foundIt = 1
				break
			endif
			SetDatafolder root:Packages:
		endif
		i += 1
	while (1)
	if (!foundIt)
		if (Type == 0)
			dfName = "AxisTransform_"+theGraph
		else
			dfName = "TransformMirror_"+theGraph
		endif
		dfName = CleanupName(dfName, 0)
		if (DataFolderExists(dfName))
			SetDatafolder $dfName
			SVAR/Z actualGraphName
			if (!SVAR_Exists(actualGraphName))	// if actualGraphName exists, it was already found in the loop above
				theDF = GetDatafolder(1)
			endif
		endif
	endif
	
	SetDatafolder $saveDF
	return theDF
end

// This function uses the graph name in theGraph to create a new datafolder name.
// It is guaranteed to be a new name, so make sure the graph doesn't already
// have a datafolder made for it.
// Returns the new name; just the name, not a full path.
Function/S makeUniqueDFNameForGraph(theGraph, Type)
	String theGraph
	Variable Type		// 0 for transform axis; 1 for mirror axis

	String dfName
	if (Type == 0)
		dfName = "AxisTransform_"+theGraph
	else
		dfName = "TransformMirror_"+theGraph
	endif
	dfName = CleanUpName(dfName, 0)
	if (DatafolderExists("root:Packages:"+dfName))
		String saveDF = GetDatafolder(1)
		SetDatafolder root:Packages:
		dfName = UniqueName(dfName, 11, 0)
		SetDatafolder $saveDF
	endif
	
	return dfName
end

// returns full path to the datafolder for the named axis. Assumes that the current datafolder
// is the correct one for the graph you are working on.
Function/S findDatafolderForAxis(theAxis, Type)
	String theAxis
	Variable Type		// 0 for transform axis; 1 for mirror axis
	
	String gDF = GetDatafolder(1)
	
	Variable i=0
	Variable foundIt = 0
	String aDF
	String theDF = ""
	do
		aDF = GetIndexedObjName("", 4, i)
		if (strlen(aDF) == 0)
			break
		endif
		if ( ((Type == 0) && (CmpStr(aDF[0,13], "AxisTransform_") == 0)) || ((Type == 1) && (CmpStr(aDF[0,15], "TransformMirror_") == 0)) )
			SetDatafolder $aDF
			SVAR/Z ActualAxisName
			if (SVAR_Exists(ActualAxisName) && (CmpStr(theAxis, ActualAxisName) == 0) )
				theDF = GetDatafolder(1)
				SetDatafolder $gDF
				break
			endif
			SetDatafolder $gDF
		endif
		i += 1
	while (1)

	SetDatafolder $gDF
	return theDF
end

// This function uses the axis name in theAxis to create a new datafolder name.
// It is guaranteed to be a new name, so make sure the axis doesn't already
// have a datafolder made for it.
// Returns the new name; just the name, not a full path.
// Assumes that the current datafolder is the datafolder for the graph that's being worked on
Function/S makeUniqueDFNameForAxis(theAxis, Type)
	String theAxis
	Variable Type		// 0 for transform axis; 1 for mirror axis

	String dfName
	if (Type == 0)
		dfName = "AxisTransform_"+theAxis
	else
		dfName = "TransformMirror_"+theAxis
	endif
	dfName = CleanUpName(dfName, 0)
	if (DatafolderExists("root:Packages:"+dfName))
		dfName = UniqueName(dfName, 11, 0)
	endif
	
	return dfName
end

//*****************************
// This function does the actual work of creating transformed data waves and replacing the waves in the graph
//
// Things yet to deal with:
//		If axis has a hard-balled range, we have to transform that range
//		
//*****************************

Function SetupTransformTraces(theGraph, theAxis, theFunc, FuncCoefWave, numTicks, wantMinor, minSep, TicksAtEnds)
	String theGraph
	String theAxis
	String theFunc
	Wave/Z FuncCoefWave
	Variable numTicks, wantMinor, minSep		// for call to TicksForTransformAxis
	Variable TicksAtEnds						// if 1, try to add major ticks at the ends of the axis
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	String saveDF = GetDatafolder(1)
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc
	
	Variable dummy, dataMin, dataMax, axisMinimum, axisMaximum
	if (WaveExists(FuncCoefWave))
		Duplicate/O/D FuncCoefWave, $"dummyPWave"
	else
		Make/D/O/N=1 $"dummyPWave"
	endif
	Wave dpw = $"dummyPWave"

	// need to run this before the data are transformed and the graph waves replaced
	AxisTransformableDataMinMax(theGraph, theAxis, theFunc, dpw, dataMin, dataMax)		// dataMin and dataMax are in raw units
	if ( (numtype(dataMin) == 2) || (numtype(dataMax) == 2) )
		DoAlert 0, "The transform function "+theFunc+" failed to return any good transformed points within the range of your data."
		return -1
	endif
	Variable AxisWasAutoScaled = IsAutoScaled(theGraph, theAxis)

	// Make the appropriate datafolder to hold waves and variables specific to this graph
	String graphFolderName = folderForThisGraph(theGraph, 0)
	if (strlen(graphFolderName) == 0)			// the graph doesn't have a folder yet
		graphFolderName = makeUniqueDFNameForGraph(theGraph, 0)
		NewDatafolder/O/S $("root:Packages:"+graphFolderName)
		String/G actualGraphName = theGraph
	else
		SetDatafolder $graphFolderName
	endif

	// Make the appropriate datafolder to hold waves and variables specific to this axis
	String folderName = findDatafolderForAxis(theAxis, 0)
	if (strlen(folderName) == 0)			// the axis doesn't have a folder yet
		folderName = makeUniqueDFNameForAxis(theAxis, 0)
		NewDatafolder/O/S $folderName
		// store away the axis name for later user (extracting it from the folder name is inconvenient, and if the axis name is long, it won't be complete)
		String/G ActualAxisName = theAxis
	else
		SetDatafolder $folderName
	endif
	
	// store away the function name
	String/G axisTransformFunction = theFunc
	
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	Variable i

	String traces = AxisTraceList(theGraph, theAxis)
	String oneTrace
	Variable numTraces = ItemsInList(traces)
	String theWaveNote = ""

	
	// We always need a coefficient wave even if the function doesn't use it.
	if (WaveExists(FuncCoefWave))
		Duplicate/O/D FuncCoefWave, $"dummyPWave"
	else
		Make/D/O/N=1 $"dummyPWave"
	endif
	Wave pw = $"dummyPWave"

	// Store information about the original axis in the wave note so that we can restore the axis to exactly the same appearance it had before
	// making the transform axis.
	String partialWaveNote
	// we need to store away information on the present axis scaling and range so that we can put it back if the axis is un-transformed
	GetAxis/W=$theGraph /Q $theAxis
	Variable oldAxisLeft = V_min
	String StrAxisLeft
	sprintf StrAxisLeft, "%.14g", oldAxisLeft
	Variable oldAxisRight = V_max
	String StrAxisRight
	sprintf StrAxisRight, "%.14g", oldAxisRight
	partialWaveNote = "SETAXISFLAGS="+StringByKey("SETAXISFLAGS", AxisInfo(theGraph,theAxis))+";"
	partialWaveNote += "AXISLEFT="+StrAxisLeft+";"		// this value will be used when un-doing the axis to restore the original axis range, if it was user-scaled
	partialWaveNote += "AXISRIGHT="+StrAxisRight+";"	// this value will be used when un-doing the axis to restore the original axis range, if it was user-scaled
	partialWaveNote += "RECREATION="+GetAxisRecreation(theGraph, theAxis)+";"
	
	Variable/G doTicksAtEnds = TicksAtEnds
	Variable/G DoAutoScale = AxisWasAutoScaled
	Variable/G transformedAxisleft = axisFunc(pw, oldAxisLeft)				// to be used only if DoAutoScale is zero
	Variable/G transformedAxisRight = axisFunc(pw, oldAxisRight)			// to be used only if DoAutoScale is zero
	
	if (isXAxis)
		i = 0
		do
			oneTrace = StringFromList(i, traces)
			if (strlen(oneTrace) == 0)
				break
			endif
			Wave/Z oldXw = XWaveRefFromTrace(theGraph, oneTrace)
			theWaveNote = "TransformAxis="+theAxis+";"
			theWaveNote += "AxisType=X;"
			if (!WaveExists(oldXw))		// Needs an X wave
				Wave w = TraceNameToWaveRef(theGraph, oneTrace)
				Duplicate/O w, $(NameOfWave(w)+"_TX")
				Wave Xw = $(NameOfWave(w)+"_TX")
				Xw = axisFunc(pw, pnt2x(w, p))
				SetFormula Xw, axisTransformFunction+"("+GetWavesDatafolder(pw,2)+",pnt2x("+GetWavesDatafolder(w,2)+", p))"
				ReplaceWave/X/W=$theGraph trace=$oneTrace, Xw
				theWaveNote += "OldWave=;"
				theWaveNote += "OldYWave="+GetWavesDatafolder(w, 2)+";"
			else
				Duplicate/O oldXw, $(NameOfWave(oldXw)+"_TX")
				Wave Xw = $(NameOfWave(oldXw)+"_TX")
				Xw = axisFunc(pw, oldXw)
				SetFormula Xw, axisTransformFunction+"("+GetWavesDatafolder(pw,2)+","+GetWavesDatafolder(oldXw, 2)+")"
				ReplaceWave/X/W=$theGraph trace=$oneTrace, Xw
				Note/K Xw
				theWaveNote += "OldWave="+GetWavesDatafolder(oldXw, 2)+";"
				Wave w = TraceNameToWaveRef(theGraph, oneTrace)
				theWaveNote += "OldYWave="+GetWavesDatafolder(w, 2)+";"
			endif
			Note/K Xw
			Note Xw, partialWaveNote+theWaveNote
			i += 1
		while (1)
	else
		i = 0
		do
			oneTrace = StringFromList(i, traces)
			if (strlen(oneTrace) == 0)
				break
			endif
			Wave w = TraceNameToWaveRef(theGraph, oneTrace)
			theWaveNote = "TransformAxis="+theAxis+";"
			theWaveNote += "AxisType=Y;"
			Duplicate/O w, $(NameOfWave(w)+"_T")
			Wave wDup = $(NameOfWave(w)+"_T")
			wDup = axisFunc(pw, w)
			SetFormula wDup, axisTransformFunction+"("+GetWavesDatafolder(pw,2)+","+GetWavesDatafolder(w, 2)+")"
			ReplaceWave/W=$theGraph trace=$oneTrace, wDup
			theWaveNote += "OldWave="+GetWavesDatafolder(w, 2)+";"
			Note/K wDup
			Note wDup, partialWaveNote+theWaveNote
			i += 1
		while (1)
	endif
	
	DoUpdate	
	
	if (TicksForTransformAxis(theGraph, theAxis, numTicks, wantMinor, minSep, "", doTicksAtEnds) < 0)		// ticking failed
		UndoTransformTraces(theGraph, theAxis)
	endif
	SetWindow $theGraph, hook=TransformAxisWindowHook
	
	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

Function/S GetAxisRecreation(theGraph, theAxis)
	String theGraph, theAxis
	
	return GetAxisRecreationFromInfoString(AxisInfo(theGraph, theAxis), ":")
end

Function/S GetAxisRecreationFromInfoString(info, keySeparator)
	String info, keySeparator
	
	Variable sstop = strsearch(info, "RECREATION"+keySeparator, 0)
	info= info[sstop+strlen("RECREATION"+keySeparator),1e6]		// want just recreation stuff
	return info
end

Function IsAutoScaled(theGraph, theAxis)
	String theGraph, theAxis
	
	Variable yesitis = 1
	String setaxisflags = StringByKey("SETAXISFLAGS", AxisInfo(theGraph, theAxis))
	if (StrSearch(setaxisflags, "/A", 0) < 0)
		yesitis = 0
	endif
	
	return yesitis
end

Function AxisTransformableDataMinMax(theGraph, theAxis, funcName, dummyPWave, outMin, outMax)
	String theGraph
	String theAxis
	String funcName
	Wave/Z dummyPWave
	Variable &outMin, &outMax
	
	// assume failure
	Variable foundAGoodPoint = 0
	outMin = NaN
	outMax = NaN

	FUNCREF TransformAxisTemplate theFunc=$funcName
	String traces = AxisTraceList(theGraph, theAxis)
	String oneTrace
	Variable numTraces = ItemsInList(traces)
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	Variable dataMin = inf
	Variable dataMax = -inf
	Variable aNum
	
	Variable i,j
	for (i = 0; i < numTraces; i += 1)
		oneTrace = StringFromList(i, traces)
		Wave/Z yw = TraceNameToWaveRef(theGraph, oneTrace)
		if (isXAxis)
			Wave/Z xw = XWaveRefFromTrace(theGraph, oneTrace)
			if (WaveExists(xw))
				for (j = 0; j < numpnts(yw); j += 1)
					if (numtype(theFunc(dummyPWave, xw[j])) == 0)
						dataMin = min(dataMin, xw[j])
						dataMax = max(dataMax, xw[j])
						foundAGoodPoint = 1
					endif
				endfor
			else
				for (j = 0; j < numpnts(yw); j += 1)
					aNum = pnt2x(yw, j)
					if (numtype(theFunc(dummyPWave, aNum)) == 0)
						dataMin = min(dataMin, aNum)
						dataMax = max(dataMax, aNum)
						foundAGoodPoint = 1
					endif
				endfor
			endif
		else
			for (j = 0; j < numpnts(yw); j += 1)
				if (numtype(theFunc(dummyPWave, yw[j])) == 0)
					dataMin = min(dataMin, yw[j])
					dataMax = max(dataMax, yw[j])
					foundAGoodPoint = 1
				endif
			endfor
		endif
	endfor
	
	if (foundAGoodPoint)
		outMin = dataMin
		outMax = dataMax
	endif
end


// finds the minimum and maximum values of the *untransformed* data for a transform axis
// Can be applied only after the axis has been transformed
Function AxisDataMinMax(theGraph, theAxis, outMin, outMax)
	String theGraph
	String theAxis
	Variable &outMin, &outMax
	
	Variable Failure = 1
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return Failure
	endif
	
	String saveDF = GetDatafolder(1)
	if (SetGraphAndAxisDataFolder(theGraph, theAxis))
		SetDatafolder $saveDF
		return Failure
	endif
	
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	
	String theTraces = TraceNameList(theGraph, ";", 1)
	String aTrace, yWaveName
	
	
	String aWave, theNote, noteAxis, oldWave
	outMin = inf
	outMax = -inf
	
	Variable j
	Variable i = 0
	do
		aTrace = StringFromList(i, theTraces)
		if (strlen(aTrace) == 0)
			break
		endif
		if (isTransformMirrorTrace(theGraph, aTrace))
			i += 1
			continue		// don't include mirror axis dummy waves
		endif
		if (isXAxis)
			Wave/Z w = XWaveRefFromTrace(theGraph, aTrace)
			if (!WaveExists(w))
				i += 1
				continue		// might be an un-transformed trace with no X wave
			endif
		else
			Wave/Z w = TraceNameToWaveRef(theGraph, aTrace)
		endif
		
		if (!WaveExists(w))
			i += 1
			continue
		endif
		theNote = Note(w)

		noteAxis = StringByKey("TransformAxis", theNote, "=", ";")
		if (CmpStr(noteAxis, theAxis) == 0)
			oldWave = StringByKey("OldWave", theNote, "=", ";")
			Wave/Z oW = $oldWave
			if (isXAxis && !WaveExists(oW))
				yWaveName = StringByKey("OldYWave", theNote, "=", ";")
				Wave/Z yW = $yWaveName
				if (WaveExists(yW))
					for (j = 0; j < numpnts(w); j += 1)
						if (NumType(w[j]) == 0)					// was this point successfully transformed?
							outMin = min(outMin, pnt2x(yW, j))
							outMax = max(outMax, pnt2x(yW, j))
						endif
					endfor
					Failure = 0
				endif
			else
				for (j = 0; j < numpnts(oW); j += 1)
					if (NumType(w[j]) == 0)						// was this point successfully transformed?
						outMin = min(outMin, oW[j])
						outMax = max(outMax, oW[j])
					endif
				endfor
				Failure = 0
			endif
		endif
		i += 1
	while (1)
	
	SetDatafolder $saveDF
	return Failure
end

Function TransformAxisWindowHook(infoStr)
	String infoStr
	
//	NVAR/Z DontUpdate = root:Packages:TransformAxis:DontUpdate
//	if (!NVAR_EXISTS(DontUpdate))
//		Execute/P/Q/Z "ShowUpdate1_2_Panel()"
//	endif

	String event = StringByKey("EVENT",infoStr)
	String theGraph = StringByKey("WINDOW",infoStr)
	strswitch (event)
		case "kill":
			return HandleKillEvent(theGraph)
			break
		case "resize":
			return HandleResizeEvent(theGraph)
			break
	endswitch
	return 0
end

Function HandleResizeEvent(theGraph)
	String theGraph
	
	String theAxes = AxisList(theGraph)
	String oneAxis
	Variable retVal = 0		// didn't do anything
	
	String saveDF = GetDatafolder(1)
	
	Variable i=0
	do
		oneAxis = StringFromList(i, theAxes)
		if (strlen(oneAxis) == 0)
			break
		endif
		i += 1
		if (SetGraphAndAxisDataFolder(theGraph, oneAxis) == 0)
			NVAR nticks
			NVAR doMinor
			NVAR minTickSep
			NVAR doTicksAtEnds
			TicksForTransformAxis(theGraph, oneAxis, nticks, doMinor, minTickSep, "", doTicksAtEnds)
			retVal = 1		// did something
		endif
		if (SetDataFolderForMirrorAxis(theGraph, oneAxis) == 0)
			NVAR nticks
			NVAR doMinor
			NVAR minTickSep
			SVAR MirrorAxis
			NVAR doTicksAtEnds
			TicksForTransformAxis(theGraph, oneAxis, nticks, doMinor, minTickSep, MirrorAxis, doTicksAtEnds)
			retVal = 1		// did something
		endif
	while (1)
	
	SetDatafolder $saveDF
	
	return retVal
end

Function HandleKillEvent(theGraph)
	String theGraph
	
	DoAlert 1, "You are closing a graph with transformed axes. Keep the transform axis info? \rClick Yes if you will save a recreation macro and intend to restore the graph later."
	if (V_flag == 1)		// Yes was clicked
		return 0
	endif

	String theAxes = AxisList(theGraph)
	String oneAxis
	Variable retVal = 0		// didn't do anything
	
	String saveDF = GetDatafolder(1)

	Variable i=0
	do
		oneAxis = StringFromList(i, theAxes)
		if (strlen(oneAxis) == 0)
			break
		endif
		i += 1
		if (SetGraphAndAxisDataFolder(theGraph, oneAxis) == 0)
			SetDatafolder $saveDF
			UndoTransformTraces(theGraph, oneAxis)
			retVal = 1		// did something
		endif
		if (SetDataFolderForMirrorAxis(theGraph, oneAxis) == 0)
			SetDatafolder $saveDF
			UndoTransformMirror(theGraph, oneAxis)
			retVal = 1		// did something
		endif
	while (1)
	
	SetDatafolder $saveDF
	return retVal
end

// Causes a re-draw of the top graph as if it had been resized
// Does *not* handle the case where a trace has been added or removed. Only handles zooming, etc.
// which changes the range of the graph but doesn't trigger the hook function.
Function RefreshGraph()

	String theGraph = WinName(0,1)
	HandleResizeEvent(theGraph)
end

Function getInverseValueWithinBounds(theNum, HighBracket, LowBracket, precision, theFunc, theCoefWave)
	Variable theNum, HighBracket, LowBracket, precision
	FUNCREF TransformAxisTemplate theFunc
	Wave theCoefWave
	
	if (AlmostEqual(theFunc(theCoefWave,theNum), HighBracket, precision))
		return HighBracket
	elseif (AlmostEqual(theFunc(theCoefWave,theNum), LowBracket, precision))
		return LowBracket
	else
		FindRoots/T=1e-14/Q/B=0/Z=(theNum)/H=(HighBracket)/L=(LowBracket) theFunc, theCoefWave
		if (V_flag)
			return NaN		// most likely not within brackets
		else
			return V_root
		endif
	endif
end

// Sets parameters for TicksForTransformAxis() to use in calculating tick marks.
// Also sets up the axis range itself as required based on autoscaling, transform function limits, pre-set range...
// Only used with transform axes, NOT transform mirror axes.
// If justBrackets is non-zero, the function does NOT set the axis range, just calculates bracket values for FindRoots.
Function setTransformAxisRange(theGraph, theAxis, axisFunc, pw, transformedRightValue, transformedLeftValue, autorange, lowBracket, highBracket, justBracket)
	String theGraph
	String theAxis
	FUNCREF TransformAxisTemplate axisFunc
	Wave pw
	Variable &autorange					// input and output: if autorange==1 on input, we try to autorange. If it doesn't work out, we set this to zero and calculate some default axis range

	Variable &transformedRightValue	// both input and output; if autorange==0, it sets the right (top) value of the transform axis; if autorange==1, outputs the actual range of the axis
	Variable &transformedLeftValue	// both input and output; same for left (bottom) value
	Variable justBracket				// input- if non-zero don't set the axis range, just calculate brackets for FindRoots
	
	Variable &lowBracket			// value to be used with /L flag with FindRoots
	Variable &highBracket			// value to be used with /H flag with FindRoots
	
	Variable rawdataMin, rawdataMax
	Variable tbracketMin, tbracketMax
	Variable newBracket
	Variable transformSwapsAxis = 0

	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return -1
	endif

	String saveDF = GetDatafolder(1)

	if (!isTransformAxis(theGraph, theAxis))
		return -1
	endif

	Variable err
	if (SetGraphAndAxisDataFolder(theGraph, theAxis))
		SetDatafolder $saveDF
		return -1
	endif
	
	// Various calculations below assume that left value is less than right value
	if (transformedRightValue < transformedLeftValue)
		newBracket = transformedRightValue
		transformedRightValue = transformedLeftValue
		transformedLeftValue = newBracket
	endif
	
	AxisDataMinMax(theGraph, theAxis, rawdataMin, rawdataMax)

	if (autorange)
		if (!justBracket)
			SetAxis/W=$theGraph/A $theAxis
			DoUpdate
		endif
		GetAxis/W=$theGraph /Q $theAxis
		transformedRightValue = max(V_max, V_min)
		transformedLeftValue = min(V_max, V_min)
	else
		if (numtype(transformedLeftValue) != 0)
			transformedLeftValue = min(axisFunc(pw, rawdataMin), axisFunc(pw, rawdataMax))
		endif
		if (numtype(transformedRightValue) != 0)
			transformedRightValue = max(axisFunc(pw, rawdataMin), axisFunc(pw, rawdataMax))
		endif
		if (!justBracket)
			SetAxis/W=$theGraph $theAxis, transformedLeftValue, transformedRightValue
			DoUpdate
		endif
	endif
	
	// need to figure out good bracketing values- start with the range of the raw data points that were successfully transformed
	lowBracket = rawdataMin
	highBracket = rawdataMax
	// make sure low bracketing value is OK
	tbracketMin = axisFunc(pw, lowBracket)		// find transformed value for the current low bracket
	if ( (tbracketMin >= transformedLeftValue) && (tbracketMin <= transformedRightValue) )		// min bracket is inside the axis range- we need to expand
		do
			newBracket = 2*lowBracket - highBracket			// double the bracket range
			if (numtype(axisFunc(pw, newBracket)) != 0)		// make sure the new bracket value transforms successfully
				newBracket = FindTransformLimit(axisFunc, pw, lowBracket, newBracket)				// no- find the limiting transform value
				break
			endif
			tbracketMin = axisFunc(pw, lowBracket)
		while ( (tbracketMin > transformedLeftValue) && (tbracketMin < transformedRightValue) )
		lowBracket = newBracket
	endif
	
	// make sure high bracketing value is OK
	tbracketMax = axisFunc(pw, highBracket)
	if ( (tbracketMax >= transformedLeftValue) && (tbracketMax <= transformedRightValue) )		// max bracket is inside the axis range- we need to expand
		do
			newBracket = 2*highBracket - lowBracket			// double the bracket range
			if (numtype(axisFunc(pw, newBracket)) != 0)
				newBracket = FindTransformLimit(axisFunc, pw, highBracket, newBracket)
				break
			endif
			tbracketMax = axisFunc(pw, lowBracket)
		while ( (tbracketMax > transformedLeftValue) && (tbracketMax < transformedRightValue) )
		highBracket = newBracket
	endif
	
	// now we have two good brackets. Make sure they are outside the range of the axis; if they aren't set to NOT autorange and make up axis ranges
	tbracketMin = axisFunc(pw, lowBracket)
	tbracketMax = axisFunc(pw, highBracket)
	if (tbracketMin > tbracketMax)
		newBracket = tbracketMin
		tbracketMin = tbracketMax
		tbracketMax = newBracket
		transformSwapsAxis = 1
	endif
	if ( (tbracketMin > transformedLeftValue) || (tbracketMax < transformedRightValue) )
		autorange = 0
		if (tbracketMin > transformedLeftValue)
			if (transformSwapsAxis)
				transformedLeftValue = axisFunc(pw, rawdataMax)
			else
				transformedLeftValue = axisFunc(pw, rawdataMin)
			endif
		endif
		if (tbracketMax < transformedRightValue)
			if (transformSwapsAxis)
				transformedRightValue = axisFunc(pw, rawdataMin)
			else
				transformedRightValue = axisFunc(pw, rawdataMax)
			endif
		endif
		if (!justBracket)
			SetAxis/W=$theGraph $theAxis, transformedLeftValue, transformedRightValue
			DoUpdate
		endif
	endif
	
	SetDatafolder $saveDF
	return 0
end

static Function testFindTransformLimit(axisFuncName, pw, goodInputValue, badInputValue)
	String axisFuncName
	Wave pw
	Variable goodInputValue, badInputValue

	FUNCREF TransformAxisTemplate axisFunc=$axisFuncName
	printf "The answer is %.18g\r" FindTransformLimit(axisFunc, pw, goodInputValue, badInputValue)
end

static Function FindTransformLimit(axisFunc, pw, goodInputValue, badInputValue)
	FUNCREF TransformAxisTemplate axisFunc
	Wave pw
	Variable goodInputValue, badInputValue
	
	Variable newInputValue = (goodInputValue + badInputValue)/2
	if (numtype(axisFunc(pw, badInputValue)) == 0)			// the bad input is really OK
		return badInputValue
	endif
	if (numtype(axisFunc(pw, goodInputValue)) != 0)		// the good input is really bad!
		return NaN
	endif
	
	do
		if (numtype(axisFunc(pw, newInputValue)) == 0)		// it's a good value
			goodInputValue = newInputValue
			newInputValue = (newInputValue + badInputValue)/2
//			if (AlmostEqual(newInputValue, badInputValue, 2e-16))
			if ( (newInputValue == badInputValue) || (newInputValue == goodInputValue) )
				return goodInputValue
			endif
		else
			badInputValue = newInputValue
			newInputValue = (newInputValue + goodInputValue)/2
//			if (AlmostEqual(newInputValue, goodInputValue, 2e-16))
			if ( (newInputValue == badInputValue) || (newInputValue == goodInputValue) )
				return goodInputValue
			endif
		endif
	while (1)
end

Function TicksForTransformAxis(theGraph, theAxis, numTicks, wantMinor, minSep, MirrorAxisName, TicksAtEnds)
	String theGraph
	String theAxis
	Variable numTicks
	Variable wantMinor, minSep
	String MirrorAxisName
	Variable TicksAtEnds
	
	if (numTicks <= 0)
		DoAlert 0, "The tick density must be greater than zero."
		return -1
	endif
	
	// For a transformed axis, theAxis is the name of the transformed axis.
	// For a mirror axis, theAxis is the name of the source axis, and MirrorAxisName is the name of the mirror axis
	// derived from theAxis.
	
	Variable isMirror = strlen(MirrorAxisName)>0
	Variable setDatafolderError
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	
	String saveDF = GetDatafolder(1)
	
	if (isMirror)
		setDatafolderError = SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (setDatafolderError)
			ReportSetMirrorDFError(theGraph, theAxis, setDatafolderError, 1)
			SetDatafolder $saveDF
			return -1
		endif
	else
		setDatafolderError = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (setDatafolderError)
			ReportSetGraphAndAxisDFError(theGraph, theAxis, setDatafolderError, 1)
			SetDatafolder $saveDF
			return -1
		endif
	endif
	
	SVAR axisTransformFunction = axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
	Wave wp = dummyPWave
	
	if (isMirror)
		SVAR MainAxis
		SVAR MirrorAxis
		SVAR PerpendicularAxis
	endif
	
	GetAxis/Q $theAxis
	if (V_flag)
		SetDatafolder $saveDF
		DoAlert 0, "The axis "+theAxis+" is not used on "+theGraph
		return -1
	endif	

	Variable aRange
	Variable leftValue				
	Variable rightValue
	Variable rawLeftValue
	Variable rawRightValue
	Variable rawMiddleValue
	Variable lowBracket, highBracket
	Variable autoRange
	Variable temp		

	if (isMirror)
		GetAxis/Q $theAxis
		leftValue = V_min
		rightValue = V_max
		rawLeftValue = axisFunc(wp, leftValue)
		rawRightValue = axisFunc(wp, rightValue)
		rawMiddleValue = axisFunc(wp, (leftValue+rightValue)/2)
		lowBracket = min(leftValue, rightValue)
		highBracket = max(leftValue, rightValue)
	else
		NVAR/Z DoAutoScale
		if (!NVAR_Exists(DoAutoScale))
			Variable/G DoAutoScale=1
		endif
		NVAR/Z AxisMin
		NVAR/Z AxisMax
		Variable transformedRightValue, transformedLeftValue
		if (!DoAutoScale)
			if (!NVAR_Exists(AxisMin) || !NVAR_Exists(AxisMax))
				DoAutoScale = 1
			else
				transformedRightValue = axisFunc(wp, AxisMax)
				transformedLeftValue = axisFunc(wp, AxisMin)
			endif
		endif
		
		// setTransformAxisRange accepts as input transformedRightValue, transformedLeftValue andd autoRange. It sets the actual axis range
		// appropriately according to these inputs. It also calculates lowBracket, highBracket and returns them via these variables. These
		// are numbers suitable for use with FindRoots. If it is not possible to autoscale the axis, autoRange is modified to reflect that.
		autoRange = DoAutoScale			// can't use a global as a reference variable
		setTransformAxisRange(theGraph, theAxis, axisFunc, wp, transformedRightValue, transformedLeftValue, autoRange, lowBracket, highBracket, 0)
		DoAutoScale = autoRange
		
		leftValue = transformedLeftValue
		rightValue = transformedRightValue
				
		aRange = rightValue - leftValue
		FindRoots/T=1e-14/B=0/Q/Z=(leftValue)/H=(highBracket)/L=(lowBracket) axisFunc, wp
		if (V_flag)
			leftValue += aRange*0.001			// root finder failed, move leftValue inward from the end by 0.1 per cent of the range of the axis
			FindRoots/T=1e-14/B=0/Q/Z=(leftValue)/H=(highBracket)/L=(lowBracket) axisFunc, wp
			if (V_flag)
				SetDatafolder $saveDF
				DoAlert 0, "FindRoots error while computing transformed axis: "+num2str(V_flag)
				return -1
			endif
		endif
		rawLeftValue = V_Root
		FindRoots/T=1e-14/B=0/Q/Z=(rightValue)/H=(highBracket)/L=(lowBracket) axisFunc, wp
		if (V_flag)
			rightValue -= aRange*0.001		// root finder failed, move rightValue inward from the end by 0.1 per cent of the range of the axis
			FindRoots/T=1e-14/B=0/Q/Z=(rightValue)/H=(highBracket)/L=(lowBracket) axisFunc, wp
			if (V_flag)
				SetDatafolder $saveDF
				DoAlert 0, "FindRoots error while computing transformed axis: "+num2str(V_flag)
				return -1
			endif
		endif
		rawRightValue = V_Root
		
		// Now we want the raw value corresponding to the middle of the axis. Shouldn't be any problem with that!
		FindRoots/T=1e-14/B=0/Q/Z=((leftValue+rightValue)/2)/H=(highBracket)/L=(lowBracket) axisFunc, wp		// shouldn't fail if transform function is well-behaved. If it fails, I don't know what to do about it
		rawMiddleValue = V_Root
	endif		// isMirror
	
//	Variable rawRangeLeft = rawRangeOfTransformFunction(leftValue, delta, 1e-3, wp, axis_max, axis_min)
	aRange = rightValue - leftValue
	Variable fraction = 1e-2
	Variable delta = aRange*fraction
	Variable rawRangeLeft = rawRangeOfTransformFunction(leftValue, delta, fraction, wp, highBracket, lowBracket, isMirror)
	if (rawRangeLeft == 0)	// pathological case
		DoAlert 0, "At the left or bottom end of the axis the transform function has infinite slope. I can't handle that!"
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeLeft)!=0)
		DoAlert 0, "At the left or bottom end of the axis calculation of the transform function slope failed."
		SetDatafolder $saveDF
		return -1
	endif
	Variable rawRangeRight = rawRangeOfTransformFunction(rightValue, delta, fraction, wp, highBracket, lowBracket, isMirror)
	if (rawRangeRight == 0)	// pathological case
		DoAlert 0, "At the right or top end of the axis the transform function has infinite slope. I can't handle that!"
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeRight) != 0)
		DoAlert 0, "At the right or top end of the axis calculation of the transform function slope failed."
		SetDatafolder $saveDF
		return -1
	endif
	Variable rawRangeMiddle = rawRangeOfTransformFunction((leftValue+rightValue-delta)/2, delta, fraction, wp, highBracket, lowBracket, isMirror)
	if (rawRangeMiddle == 0)	// pathological case
		DoAlert 0, "At the middle of the axis the transform function has infinite slope. I can't handle that!"
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeMiddle)!=0)
		DoAlert 0, "At the middle of the axis calculation of the transform function slope failed."
		SetDatafolder $saveDF
		return -1
	endif
	if (debugInfo)
		print "	rawRangeLeft, rawRangeRight, rawRangeMiddle: ", rawRangeLeft, rawRangeRight, rawRangeMiddle
	endif
	Variable Mode			// 1- extreme derivative at one end; 2- extreme value in middle, break into halves and work on each half separately
	// This idea could be extended to handle any number of minima and maxima, but I don't think a useful transform function will have
	// more than one extreme point. In Mode 1, the transformation compresses one end and expands the other. In Mode 2, the middle is expanded at
	// the expense of the ends, or the ends are expanded at the expense of the middle.
	// I'm sure a customer will come up with a counter-example...
	if (	((rawRangeLeft < rawRangeMiddle) && (rawRangeMiddle < rawRangeRight)) || ((rawRangeLeft > rawRangeMiddle) && (rawRangeMiddle > rawRangeRight)) )
		Mode = 1
	else
		Mode = 2
	endif
	
	Make/O/N=(0,2)/T tickLabels
	SetDimLabel 1, 1, 'Tick Type',tickLabels
	Make/O/N=(0)/D tickVals
	Variable TickDelta, NumPlaces, InversePrecision
	Variable anyWholeNumber = 1
	Variable smaller = 1
	Variable nextWholeNumber, wholeNumberDelta
	Variable TickValue 
		
	Variable rawTickValue, rawRange
	Variable i
	Variable pNum
	Variable CanTickValue
	String ticklbl
	anyWholeNumber = 0
	
	// Try a bit more intelligent method- start at end with closer spacing (smaller "range") and work toward the other end
	// until the spacing is too small. Then calculate a new spacing based on the derivative at the last tick mark and march along
	// until the spacing is again too small.
	// This should work well for an inverse transform because it just gets smaller and smaller.  A transform like a probability axis
	// that is small at the ends and large in the middle will be more difficult.
	Variable isX = isHorizAxis(theGraph, theAxis)
	String axInfo
	if (isMirror)
		axInfo = AxisInfo(theGraph, MirrorAxis)
	else
		axInfo = AxisInfo(theGraph, theAxis)
	endif		
	String tLabelRot = StringByKey("tkLblRot(x)", axInfo, "=", ";")
	Variable wideSpacing, labelSpace
	Variable tickDeltaSign, fDigit
	Variable previousTickPos, newTickPos, previousLabelPos, recalcTicking
	Variable minTickSpacing
	Variable firstWholeNumber, rangeStart, rangeEnd, tickDeltaMantissa, numMinor, emphasizeEvery
	Variable majorDistance, previousMajor,jj, majorDif, previousTickValue
	// Figure out if we need space for the length or the height of labels
	// ****** haven't handled horizontal axes yet ********
	if (isX)
		strswitch(tLabelRot)
			case "0":
			case "180":
				wideSpacing = 1
				break
			case "90":
			case "270":
				wideSpacing = 0
				break
		endswitch
	else
		strswitch(tLabelRot)
			case "0":
			case "180":
				wideSpacing = 0
				break
			case "90":
			case "270":
				wideSpacing = 1
				break
		endswitch
	endif
	// Some ad-hoc values for development
	// tick spacing in fractions of total axis span
	GetWindow $theGraph, psize
	Variable plotSize = isX ? (V_right-V_left) : (V_bottom-V_top)
	if (debugInfo)
		print "value2pixels = ", plotSize/abs(rightValue-leftValue)
	endif
	if (wideSpacing)
		labelSpace = FontSizeStringWidth(defaultFontForAxis(theGraph, theAxis), getdefaultfontsize(theGraph, theAxis), getdefaultfontstyle(theGraph, theAxis), "800")	// in points; "800" is just a poor stand-in for the real tick label
		labelSpace /= plotSize	// in fraction of the axis length
	else
		labelSpace = fontsizeheight(defaultFontForAxis(theGraph, theAxis), getdefaultfontsize(theGraph, theAxis), getdefaultfontstyle(theGraph, theAxis))	// in points
		labelSpace /= plotSize	// in fraction of the axis length
		labelSpace *= 0.9		// numbers don't have descenders
	endif
	minTickSpacing = abs(rightValue-leftValue)*labelSpace		// now it's in units of the transformed data
	if (debugInfo)
		print "leftValue, rightValue", leftValue, rightValue
		print "minTickSpacing =", minTickSpacing
	endif

	Variable Done = (Mode==1)
	Variable NeedRecalc
	Variable Pass = 1
	Variable precision
	do			// while (!done)
		if (Mode == 2)
			// See the Mode==1 comments about tickDeltaSign. They apply here also, we've just split the axis into two sections. We
			// will work either from the middle outward or from the outside toward the middle. The choice will be made based on
			// where the ticks have close spacing.
			if (debugInfo)
				print "*** Pass number",Pass
			endif
			if (Pass == 2)
				// second do right (top) end
				if(abs(rawRangeMiddle) < abs(rawRangeRight))
					if (debugInfo)
						print "Top half- starting from middle"
					endif
					tickDeltaSign = 1*sign(rawRangeMiddle)
					rawRange = rawRangeMiddle
					rawTickValue = rawMiddleValue
					previousLabelPos = leftValue-2*minTickSpacing
				else
					if (debugInfo)
						print "Top half- starting from right"
					endif
					tickDeltaSign = -1*sign(rawRangeRight)
					rawRange = rawRangeRight
					rawTickValue = rawRightValue
					previousLabelPos = rightValue+2*minTickSpacing
				endif
				rangeStart = rawMiddleValue
				rangeEnd = rawRightValue
				Done = 1	
			else
				// first do left (bottom) end
				if(abs(rawRangeLeft) < abs(rawRangeMiddle))
					if (debugInfo)
						print "Bottom half- starting from left"
					endif
					tickDeltaSign = 1*sign(rawRangeLeft)
					rawRange = rawRangeLeft
					rawTickValue = rawLeftValue
					previousLabelPos = leftValue-2*minTickSpacing
				else
					if (debugInfo)
						print "Bottom half- starting from middle"
					endif
					tickDeltaSign = -1*sign(rawRangeMiddle)
					rawRange = rawRangeMiddle
					rawTickValue = rawMiddleValue
					previousLabelPos = rightValue+2*minTickSpacing
				endif
				rangeStart = rawLeftValue
				rangeEnd = rawMiddleValue	
			endif
		else
			// Figure out which end to start from. We go from the end with small range (smaller tick spacing)
			if(abs(rawRangeLeft) < abs(rawRangeRight))
				if (debugInfo)
					print "Mode 1- starting from left"
				endif
				// We always start at the end where the magnitude of the raw range is smaller. That is, the tick spacing in un-transformed numbers is smaller.
				// That way, as we work along the axis, the ticks get closer together and we have less chance of missing ticks because we've suddenly jumped past 
				// the end of the axis. Here, we will start at the left (bottom) end of the axis.
				
				// Since we are starting at the left, we are starting from smaller transformed numbers. If rawRangeLeft is negative, that means the left end
				// has larger raw numbers. Since we are working from larger raw numbers, we must use a negative tickDelta to iterate along the axis.
				tickDeltaSign = 1*sign(rawRangeLeft)
				rawRange = rawRangeLeft
				rawTickValue = rawLeftValue
				previousLabelPos = leftValue-2*minTickSpacing	// set previousLabelPos well away from the place where we will put the first tick.
			else
				if (debugInfo)
					print "Mode 1- starting from right"
				endif
				// invert the long comments just above.
				tickDeltaSign = -1*sign(rawRangeRight)
				rawRange = rawRangeRight
				rawTickValue = rawRightValue
				previousLabelPos = rightValue+2*minTickSpacing
			endif
			rangeStart = rawLeftValue
			rangeEnd = rawRightValue	
		endif
		if (Pass == 1)
			pNum = 0
		endif
		
		// Now we must figure out what values to start with at the end we have selected to start at.
		if (tickDeltaSign < 0)
			smaller = rawTickValue > 0
		else
			smaller = rawTickValue < 0
		endif
		if (debugInfo)
			print "About to call NextNiceNumber before loop; rawRange, rawTickValue, numTicks, smaller, tickDeltaSign:", rawRange, rawTickValue, numTicks, smaller, tickDeltaSign
		endif
		CanTickValue = NextNiceNumber(rawRange, rawTickValue, numTicks, smaller, 0, TickDelta, NumPlaces, nextWholeNumber, wholeNumberDelta, tickDeltaMantissa)
		if (debugInfo)
			print "After call to NextNiceNumber before loop; firstWholeNumber, nextWholeNumber, CanTickValue, wholeNumberDelta, tickDelta", firstWholeNumber, nextWholeNumber, CanTickValue, wholeNumberDelta, tickDelta
		endif
		if (NumType(CanTickValue) != 0)
			DoAlert 0, "Got a bad value while trying to calculate tick interval"
			SetDatafolder $saveDF
			return -1
		endif
		if (tickDeltaSign > 0)		// need nextWholeNumber to be bigger than CanTickValue
			if (debugInfo)
				print "tickDelta is positive"
			endif
			// bring CanTickValue within the axis range
			if (CanTickValue < rawTickValue)
				if (debugInfo)
					print "Adjust CanTickValue; CanTickValue, rawTickValue", CanTickValue, rawTickValue
				endif
				do
					CanTickValue += TickDelta
				while(CanTickValue < rawTickValue)
			endif
			// make sure nextWholeNumber is beyond CanTickValue in the direction in which we will be making tick marks.
			if (nextWholeNumber < CanTickValue)
				if (debugInfo)
					print "Adjust nextWholeNumber; nextWholeNumber, CanTickValue", nextWholeNumber, CanTickValue
				endif
				do
					nextWholeNumber += wholeNumberDelta
				while (nextWholeNumber <= CanTickValue)
			endif
			// Now make sure firstWholeNumber and nextWholeNumber bracket CanTickValue
			firstWholeNumber = nextWholeNumber-wholeNumberDelta
			// make sure the tickDelta breaks occur only at 1 or 5 (that is, .001, .005, .1,.5,10,50, etc.)
			fDigit = PickDigit(NextWholeNumber, tickDelta)
			if (fDigit != 0)
				do
					NextWholeNumber += WholeNumberDelta
					fDigit = PickDigit(NextWholeNumber, tickDelta)
				while (fDigit != 0)
			endif
		else
			if (debugInfo)
				print "tickDelta is negative"
			endif
			// Above comments apply here, but with signs reversed, and the conditionals > replaced with <
			if (CanTickValue > rawTickValue)
				if (debugInfo)
					print "Adjust CanTickValue; CanTickValue, rawTickValue", CanTickValue, rawTickValue
				endif
				do
					CanTickValue -= TickDelta
				while(CanTickValue > rawTickValue)
			endif
			if (nextWholeNumber > CanTickValue)
				if (debugInfo)
					print "Adjust nextWholeNumber; nextWholeNumber, CanTickValue", nextWholeNumber, CanTickValue
				endif
				do
					nextWholeNumber -= wholeNumberDelta
				while (nextWholeNumber >= CanTickValue)
			endif
			firstWholeNumber = nextWholeNumber+wholeNumberDelta
			fDigit = PickDigit(NextWholeNumber, TickDelta)
			if (fDigit != 0)
				do
					NextWholeNumber -= WholeNumberDelta
					fDigit = PickDigit(NextWholeNumber, TickDelta)
				while (fDigit != 0)
			endif
			wholeNumberDelta = -wholeNumberDelta
		endif

		// Here we are about to finally make the first tick mark
		if (debugInfo)
			print "firstWholeNumber, nextWholeNumber, CanTickValue, wholeNumberDelta, tickDelta", firstWholeNumber, nextWholeNumber, CanTickValue, wholeNumberDelta, tickDelta
			Print "About to do firstWholeNumber tick- firstWholeNumber, rangeStart, rangeEnd", firstWholeNumber, rangeStart, rangeEnd
		endif
		// pick the best starting value. In some cases firstWholeNumber will be barely on the graph, in which case it is the best starting point
		if (isNearlyBetween(firstWholeNumber, rangeStart, rangeEnd, 1e-6) == 1)
			tickValue = firstWholeNumber
		else
			tickValue = CanTickValue
		endif
		if (isMirror)
			InversePrecision = min(10^(-numPlaces-2), 1e-6)
			temp = getInverseValueWithinBounds(tickValue, HighBracket, LowBracket, InversePrecision, axisFunc, wp)
		else
			temp = axisFunc(wp, tickValue)
		endif
		if (numType(temp) == 0)	// make sure the tranaformation function is defined here before making a tick mark
			InsertPoints pNum+1, 1, tickLabels, tickVals
			sprintf ticklbl, "%.*f", numPlaces, tickValue			// appropriate label
			tickLabels[pNum][0] = ticklbl
			tickLabels[pNum][1] = "Major"
			tickVals[pNum] = temp
			previousLabelPos = tickVals[pNum]
			if (debugInfo)
				print "1) tickLabels["+num2str(pNum)+"] = ", tickLabels[pNum], "  tickVals = ", tickVals[pNum], " previousLabelPos = ", previousLabelPos
			endif
			if (debugUpdates)
				DoUpdate
			endif
			previousMajor = tickVals[pNum]
			previousTickValue = tickValue
			pNum += 1
		endif
		// Start iterating, making new ticks at a spacing of TickDelta in the untransformed space. These will be "nice" numbers.
		i = 1		// start with 1 because we already made the first tick above
		do
			// Calculate the raw data value for the next tick mark
			tickValue = CanTickValue + i*tickDeltaSign*TickDelta
			if (isNearlyBetween(tickValue, rangeStart, rangeEnd, 1e-10) == 0)
				// finished because the next tick value is off the end of the range we're working on. That might be the middle if we're in Mode 2.
				if (debugInfo)
					print "done 1: tickValue, rangeStart, rangeEnd", tickValue, rangeStart, rangeEnd
				endif
				break
			endif
			precision = min(1e-6, abs(TickDelta/2))
			NeedRecalc = (isNearlyBetween(tickValue, firstWholeNumber, nextWholeNumber, precision) == 0)		
			if (debugInfo)
				printf "NeedRecalc = %d; tickValue = %.20g; firstWholeNumber = %.20g; nextWholeNumber = %.20g; difference tv-nwn: %.20g\r", NeedRecalc, tickValue, firstWholeNumber, nextWholeNumber, tickValue-nextWholeNumber
			endif
			if (NeedRecalc)		// Time to recalculate
				// The next tick mark is outside the the range of firstWholeNumber, nextWholeNumber. We will now re-calculate the raw range, TickDelta, etc.
				if (isMirror)		// calculate new tick info at the end of the previous range
					InversePrecision = min(10^(-numPlaces-2), 1e-6)
					newTickPos = getInverseValueWithinBounds(nextWholeNumber, HighBracket, LowBracket, InversePrecision, axisFunc, wp)
				else
					newTickPos = axisFunc(wp, nextWholeNumber)
				endif
				rawRange = rawRangeOfTransformFunction(newTickPos,  tickDeltaSign*delta, tickDeltaSign*fraction, wp, highBracket, lowBracket, isMirror)
				if (rawRange == 0)	// pathological case
					DoAlert 0, "Found a place on the axis where the transform function has infinite slope. I can't handle that!"
					if (debugInfo)
						print "done 2"
					endif
					SetDatafolder $saveDF
					return -1
				endif
				if (numtype(rawRange) != 0)
					SetDatafolder $saveDF
					return -1					// failure alert already put up by rawRangeOfTransformFunction
				endif
				firstWholeNumber = nextWholeNumber		// so the next range of ticks starts with the last tick we did previously
				if (tickDeltaSign < 0)
					smaller = nextWholeNumber > 0
				else
					smaller = nextWholeNumber < 0
				endif
				if (debugInfo)
					print "About to calculate new ticking; rawRange, nextWholeNumber", rawRange, nextWholeNumber
				endif
				CanTickValue = NextNiceNumber(rawRange, nextWholeNumber, numTicks, smaller, anyWholeNumber, TickDelta, NumPlaces, nextWholeNumber, wholeNumberDelta, tickDeltaMantissa)
				if (debugInfo)
					print "After NextNiceNumber: CanTickValue, TickDelta, NumPlaces, nextWholeNumber, wholeNumberDelta", CanTickValue, TickDelta, NumPlaces, nextWholeNumber, wholeNumberDelta
				endif
				if (NumType(CanTickValue) != 0)
					DoAlert 0, "Got a bad value while trying to calculate tick interval"
					SetDatafolder $saveDF
					return -1
				endif

				if (tickDeltaSign > 0)		// need nextWholeNumber to be bigger than CanTickValue
					if (nextWholeNumber < CanTickValue)
						if (debugInfo)
							print "tickDeltaSign is positive; Adjust nextWholeNumber; nextWholeNumber, CanTickValue", nextWholeNumber, CanTickValue
						endif
						do
							nextWholeNumber += wholeNumberDelta
						while (nextWholeNumber < CanTickValue)
					endif
					fDigit = PickDigit(NextWholeNumber, tickDelta)
					if (fDigit != 0)
						do
							NextWholeNumber += WholeNumberDelta
							fDigit = PickDigit(NextWholeNumber, tickDelta)
						while (fDigit != 0)
					endif
				else
					if (nextWholeNumber > CanTickValue)
						if (debugInfo)
							print "tickDeltaSign is negative; Adjust nextWholeNumber; nextWholeNumber, CanTickValue", nextWholeNumber, CanTickValue
						endif
						do
							nextWholeNumber -= wholeNumberDelta
						while (nextWholeNumber > CanTickValue)
					endif
					fDigit = PickDigit(NextWholeNumber, tickDelta)
					if (fDigit != 0)
						do
							NextWholeNumber -= WholeNumberDelta
							fDigit = PickDigit(NextWholeNumber, tickDelta)
						while (fDigit != 0)
					endif
					wholeNumberDelta = -wholeNumberDelta
				endif
				if (isMirror)
					InversePrecision = min(10^(-numPlaces-2), 1e-6)
					temp = getInverseValueWithinBounds(nextWholeNumber, HighBracket, LowBracket, InversePrecision, axisFunc, wp)
				else
					temp = axisFunc(wp, nextWholeNumber)
				endif
				if (abs(temp-previousLabelPos) <= minTickSpacing)
					if (debugInfo)
						print "nextWholeNumber too close to last label"	// Do I need to adjust the TickDelta here? Hmm...
					endif
					nextWholeNumber = nextWholeNumber + wholeNumberDelta			// The next tick range isn't big enough for a label, and we really need to be able to put a label in every range
				endif
				if (debugInfo)
					print "** new nextWholeNumber = ", nextWholeNumber, " CanTickValue = ", CanTickValue, " firstWholeNumber = ", firstWholeNumber, "wholeNumberDelta = ", wholeNumberDelta, "tickDelta = ", tickDelta
				endif
				TickValue = nextWholeNumber		// Hmm... this makes a label at the end of the range. Subsequent iterations will fill in between. This makes a 
													// problem for making sure the labels don't collide. So, we just fill in all possible major ticks.
													// After the loop exits, we adjust the ticks to remove colliding labels and to remove duplicates
				i = 0
			else				// if (NeedRecalc)
				if (isMirror)
					InversePrecision = min(10^(-numPlaces-2), 1e-6)
					if (debugInfo)
						print "Before getInverseValueWithinBounds, tickValue, HighBracket, LowBracket, InversePrecision", tickValue, HighBracket, LowBracket, InversePrecision
					endif
					temp = getInverseValueWithinBounds(tickValue, HighBracket, LowBracket, InversePrecision, axisFunc, wp)
				else
					temp = axisFunc(wp, tickValue)
				endif
				if (numtype(temp) == 0)
					InsertPoints pNum+1, 1, tickLabels, tickVals
					tickVals[pNum] = temp
					
					sprintf ticklbl, "%.*f", numPlaces, TickValue			// appropriate label
					tickLabels[pNum][0] = ticklbl
					tickLabels[pNum][1] = "Major"
					previousLabelPos = tickVals[pNum]
					if (debugInfo)
						print "5) tickLabels["+num2str(pNum)+"] = ", tickLabels[pNum], "Tick Value = ", TickValue,  "tickVals = ", tickVals[pNum], " previousLabelPos = ", previousLabelPos
					endif
					if (debugUpdates)
						DoUpdate
					endif
					pNum += 1
					previousMajor = tickVals[pNum]
					previousTickValue = TickValue
				endif
				i += 1
			endif			// if (NeedRecalc)
		while (1)
		Pass += 1
	while (!done)
	
	if (isMirror)
		ModifyGraph/W=$theGraph userticks($MirrorAxisName)={tickVals,tickLabels}
	else
		ModifyGraph/W=$theGraph userticks($theAxis)={tickVals,tickLabels}
	endif
	DoUpdate		// if it's a mirror axis, we need to do this to force Igor to create the axis.
	if (debugUpdates)
		DoUpdate
	endif

	// At this point, the tickVals and tickLabels waves are full of major tick labels that may be too close together, and may have duplicates.
	//    sort the waves so that duplicate ticks are next to each other
	Duplicate/O tickVals, sortIndex, sortVals
	Duplicate/T/O tickLabels, sortLabels
	MakeIndex tickVals, sortIndex
	tickVals = sortVals[sortIndex[p]]
	tickLabels = sortLabels[sortIndex[p]]
	KillWaves/Z sortIndex, sortVals, sortLabels
	if (debugInfo)
		print "minTickSpacing, wantMinor:",minTickSpacing, wantMinor
	endif

	String actualAxisName
	if (isMirror)
		actualAxisName = MirrorAxisName
	else
		actualAxisName = theAxis
	endif
	GetAxis/Q/W=$theGraph $actualAxisName
	Variable values2pixels = plotSize/abs(V_max-V_min)
	if (debugUpdates)
		DoUpdate
	endif
	RemoveDuplicates(tickVals, tickLabels)
	if (debugUpdates)
		DoUpdate
	endif
	
	AddMissingMajorTicks(tickVals, tickLabels, values2pixels, minSep, axisFunc, wp, leftValue, rightValue, isMirror, highBracket, lowBracket, numPlaces)
	if (debugUpdates)
		DoUpdate
	endif

	if (TicksAtEnds)
		AddTicksAtEnds(tickVals, tickLabels, values2pixels, minSep, axisFunc, wp, leftValue, rightValue, isMirror, highBracket, lowBracket, numPlaces)
	endif
	if (debugUpdates)
		DoUpdate
	endif
	
	// AddTicksAtEnds() will add ticks out of order. We sort here because various operations that follow need the ticks to be in order.
	// The complexity of sorting here is caused by two considerations- one is that Sort doesn't know about multi-column waves; that
	// forces us to use MakeIndex. The other is that once we have the index, the values must be copied from a different wave in sorted order.
	// If that copy were done in place, early copies would wipe out values that haven't been moved yet.
	Duplicate/O tickVals, sortIndex, sortVals
	Duplicate/T/O tickLabels, sortLabels
	MakeIndex tickVals, sortIndex
	tickVals = sortVals[sortIndex[p]]
	tickLabels = sortLabels[sortIndex[p]]
	KillWaves/Z sortIndex, sortVals, sortLabels
	if (debugInfo)
		print "minTickSpacing, wantMinor:",minTickSpacing, wantMinor
	endif

	// Now demote major ticks if the labels are too close together
	RemoveExtraZeroesFromLabels(tickLabels)
	if (debugUpdates)
		DoUpdate
	endif
	AdjustTickLabelSpacing(theGraph, actualAxisName, tickVals, tickLabels, minTickSpacing, wantMinor, wideSpacing, plotSize)
	if (debugUpdates)
		DoUpdate
	endif
	
	CheckMinorTickDensity(theGraph, actualAxisName, tickVals, tickLabels, minSep, plotSize)
	if (debugUpdates)
		DoUpdate
	endif
	
	CullMinorTicks(tickVals, tickLabels)
	if (debugUpdates)
		DoUpdate
	endif
	
	if (wantMinor)
		RemoveAnyMinorTicks(tickVals, tickLabels)
		AddMinorTicks(tickVals, tickLabels, values2pixels, minSep, axisFunc, wp, isMirror, highBracket, lowBracket, numPlaces, leftValue, rightValue)
		if (debugUpdates)
			DoUpdate
		endif
	endif
	if (debugUpdates)
		DoUpdate
	endif
	
	if (debugInfo)
		print "minTickSpacing, wantMinor:",minTickSpacing, wantMinor
	endif

	removeLabelsFromEmphasizedTicks(tickLabels)
	if (debugUpdates)
		DoUpdate
	endif
	
	// store for resize events
	Variable/G nticks = numTicks
	Variable/G doMinor = wantMinor
	Variable/G minTickSep = minSep
	Variable/G doTicksAtEnds = TicksAtEnds
	
	// Duplicate the tick waves to make a pristine copy for comparison with edited waves
	Duplicate/O tickVals, cleanTickVals
	Duplicate/O tickLabels, cleanTickLabels
	
	// Now re-apply edits that were trashed when new tick waves were made. Depending on why the axis was re-ticked, this may be more or less of a good idea...
	// If the axis is now much longer or shorter, there may be lots of extra/missing ticks compared to the version that was edited.
	RestoreEditsAfterTicking(theGraph, theAxis, MirrorAxisName)
	if (debugUpdates)
		DoUpdate
	endif
	
	// some things we might do later may work better with the ticks sorted by value...
	Duplicate/O tickVals, sortIndex, sortVals
	Duplicate/T/O tickLabels, sortLabels
	MakeIndex tickVals, sortIndex
	tickVals = sortVals[sortIndex[p]]
	tickLabels = sortLabels[sortIndex[p]]
	KillWaves/Z sortIndex, sortVals, sortLabels

	if (debugInfo)
		print "•//"
	endif

	SetDatafolder $saveDF
	return 0
end

Function RestoreEditsAfterTicking(theGraph, theAxis, MirrorAxisName)
	String theGraph, theAxis, MirrorAxisName
	
	Variable isMirror = strlen(MirrorAxisName)>0
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	
	String saveDF = GetDatafolder(1)
	Variable setDatafolderError
	
	if (isMirror)
		setDatafolderError =SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (setDatafolderError)
			ReportSetMirrorDFError(theGraph, theAxis, setDatafolderError, 1)
			SetDatafolder $saveDF
			return -1
		endif
	else
		setDatafolderError = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (setDatafolderError)
			ReportSetGraphAndAxisDFError(theGraph, theAxis, setDatafolderError, 1)
			SetDatafolder $saveDF
			return -1
		endif
	endif
	
	Wave tickVals
	Wave/T tickLabels
	Wave/Z deletedTicks
	Wave/Z addedTicks
	Wave/Z/T addedTickLabels
	Wave/Z changedTicks
	Wave/Z/T changedTickLabels
	
	Variable i, j, points, points2
	
	if (WaveExists(deletedTicks))
		points = numpnts(deletedTicks)
		points2 = numpnts(tickVals)
		for (i = 0; i < points2; i += 1)
			for (j = 0; j < points; j += 1)
				if (AlmostEqual(tickVals[i], deletedTicks[j], 1e-6))
					DeletePoints/M=0 i, 1, tickVals, tickLabels
					i -= 1
					points2 -= 1
				endif
			endfor
		endfor
	endif
	if (WaveExists(changedTicks))
		points = numpnts(changedTicks)
		points2 = numpnts(tickVals)
		for (i = 0; i < points2; i += 1)
			for (j = 0; j < points; j += 1)
				if (AlmostEqual(tickVals[i], changedTicks[j], 1e-6))
					tickLabels[i] = changedTickLabels[j]
				endif
			endfor
		endfor
	endif
	if (WaveExists(addedTicks))
		points = numpnts(addedTicks)
		points2 = numpnts(tickVals)
		InsertPoints points2, points, tickVals, tickLabels
		tickVals[points2, points2+points-1] = addedTicks[p-points2]
		tickLabels[points2, points2+points-1] = addedTickLabels[p-points2]
	endif
	
	SetDatafolder $SaveDF
	return 0
end

Function RemoveDuplicates(tickVals, tickLabels)
	Wave tickVals
	Wave/T tickLabels
	
	Variable npnts = numpnts(tickVals)
	Variable i, pnum
	for (i = 1, pnum=1; i < npnts; i += 1, pnum += 1)
		if (tickVals[pnum] == tickVals[pnum-1])
			DeletePoints pnum, 1, tickVals, tickLabels
			pnum -= 1
		endif
	endfor
end

//**********************************************
// Support routines for AdjustTickLabelSpacing()
//**********************************************

constant HLABELGROUT = 3
constant VLABELGROUT = 0

// this is probably more complicated than necessary, but this is how whole numbers are
// calculated in NextNiceNumber(), so this guarantees agreement.
Function isWholeNumber(theNumber, spacing)
	Variable theNumber
	Variable spacing
	
	Variable theMod = mod(theNumber, spacing)
	if (abs(theMod/spacing) < 1e-6 || AlmostEqual(theMod, spacing, 1e-6))		// first test is "almost zero"
		return 1
	else
		return 0
	endif
end

// returns 1 if the two labels at indices label1Index and label2Index bump into each other.
// returns 0 if they are OK. Depends on infoW being set up correctly...
static Function checkLabelConflict(infoW, label1Index, label2Index, labelGrout)
	Wave infoW
	Variable label1Index, label2Index
	Variable labelGrout
	
	return (infoW[label1Index][2]/2 + infoW[label2Index][2]/2 + labelGrout) > (abs(infoW[label1Index][3] - infoW[label2Index][3])) 
end
// returns True if any labels overlap within the range of indices specified
// Uses as input data the special wave constructed in AdjustTickLabelSpacing()
// Checks the half-open interval [startIndex, endIndex).
// Does not check for demoted ticks
static Function checkForLabelConflicts(infoW, startIndex, endIndex, labelGrout)
	Wave infoW
	Variable startIndex, endIndex
	Variable labelGrout
	
	Variable i, labelsBump = 0
	
	for (i = startIndex+1; i < endIndex; i += 1)
		if (checkLabelConflict(infoW, i, i-1, labelGrout))		// if (label width > label spacing)
			labelsBump = 1
			break
		endif
	endfor
	
	return labelsBump
end

// returns True if tick corresponding to oneIndex conflicts with any other
// label that is currently not marked for demotion
static Function checkOneLabelForConflicts(infoW, oneIndex, labelGrout)
	Wave infoW
	Variable  oneIndex, labelGrout
	
	Variable npnts = DimSize(infoW, 0)
	Variable i
	
	// look backward from oneIndex for conflicting labels
	if (oneIndex > 0)
		for (i = oneIndex-1; i >= 0; i -= 1)
			if (infoW[i][4] != 1)		// found a tick with it's label turned on
				if (checkLabelConflict(infoW, oneIndex, i, labelGrout))		// if (label width > label spacing)
					return 1
				endif
				break		// found the previous labeled tick; don't need to check further
			endif
		endfor
	endif
	if (oneIndex < npnts-1)
		for (i = oneIndex+1; i < npnts; i += 1)
			if (infoW[i][4] != 1)		// found a tick with it's label turned on
				if (checkLabelConflict(infoW, oneIndex, i, labelGrout))		// if (label width > label spacing)
					return 1
				endif
				break		// found the next labeled tick; don't need to check further
			endif
		endfor
	endif
	
	return 0				// no conflict with the labelled tick before or after the tick at oneIndex
end

// checks infoW within the closed range [starti, endi] for labels that can be labelled
// according to the criteria in the comment above AdjustTickLabelSpacing(().
// If any  ticks are marked to be labelled (infoW[][4] == 0) it is assumed that they *must* be labelled, so
// this routine leaves them alone and they become part of the checks for conflicts.
// This routine assumes that you have already checked that the tick interval within the range
// is uniform. It will *not* do the right thing if the tick interval changes!
static Function adjustLabelsInRange(infoW, tickLabels, starti, endi, labelGrout)
	Wave infoW
	Wave/T tickLabels
	Variable  starti, endi, labelGrout
	
	Variable i
	
	if (endi == DimSize(infoW, 0))
		endi -= 1
	endif
	
	Variable tickSpacing = abs(str2num(tickLabels[starti]) - str2num(tickLabels[endi]))/(endi - starti)
	
	Variable tickPower = 10^floor(log(tickSpacing))
	
	// look for ticks that are a multiple of 10 times the tick spacing; these are most-preferred ticks
	for (i = starti; i <= endi; i += 1)
		if (infoW[i][4] == 1)
			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*10))
				infoW[i][4] = checkOneLabelForConflicts(infoW, i, labelGrout)
			endif
		endif
	endfor		
	
	if (debugUpdates)
		DoUpdate
	endif
		
	// look for whole-number ticks that end with '5'
	for (i = starti; i <= endi; i += 1)
		if (infoW[i][4] == 1)
			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*5))
				infoW[i][4] = checkOneLabelForConflicts(infoW, i, labelGrout)
			endif
		endif
	endfor		
	
	if (debugUpdates)
		DoUpdate
	endif
	
	// look for whole-number ticks with even-number labels
	for (i = starti; i <= endi; i += 1)
		if (infoW[i][4] == 1)
			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*2))
				infoW[i][4] = checkOneLabelForConflicts(infoW, i, labelGrout)
			endif
		endif
	endfor		
	
	if (debugUpdates)
		DoUpdate
	endif
	
	// now look through the remaining ticks and promote the ones that still fit
	for (i = starti; i <= endi; i += 1)
		if (infoW[i][4])		// no need to check ticks that are marked for labelling
			infoW[i][4] = checkOneLabelForConflicts(infoW, i, labelGrout)
		endif
	endfor
	
	if (debugUpdates)
		DoUpdate
	endif
end

// Checks the labels for overlap and removes labels that do, subject to certain criteria.
// This function follows the following procedure:
// 		1) Identify a block of ticks that all have the same tick delta.
//		2) Check labels for overlap, if none, go back to 1)
//		3) Must keep the labels at the ends of the block where the delta changes.
// 		4) Mark all other ticks for demotion.
//		5) Check fit of any whole-number ticks (that is, log(tick) is an integer) within the block
//			for fit. Promote any that fit.
//		6) Check fit of other ticks and promote any that fit.
//		7) If the block is at either end of the axis, discard demoted ticks that are at the ends.
//			It will be necessary to also find the minor ticks and discard them, also.

//		When the above have been applied to all the ticks on the axis, it may be necessary to put back the
//		the minor ticks at the ends based on minor tick intervals in the surviving tick blocks.

// This funtion assumes that the tick wave haven't been sorted yet- that is, the major ticks are all in a block at the beginning
// followed by minor ticks.
Function AdjustTickLabelSpacing(theGraph, theAxis, tickVals, tickLabels, minTickSpacing, minorTicks, wideSpacing, plotSize)
	String theGraph
	String theAxis			// name of the actual axis in question (if it's a transform mirror axis, the name of the mirror axis itself, not the original axis)
	Wave tickVals
	Wave/T tickLabels
	Variable minTickSpacing	// this number is in units of the tickVals wave
	Variable minorTicks		// this affects what kind of tick to use when demoting a major tick
	Variable wideSpacing		// set if horizontal axis with horizontal labels, or vertical axis with vertical labels
	Variable plotSize
	
	Variable i,j
	Variable npnts = numpnts(tickVals)
	for (i = 0; i < npnts; i += 1)
		if (CmpStr("Major", tickLabels[i][1]) != 0)
			break
		endif
	endfor
	npnts = i
												
	Variable lastWavePoint = npnts-1
	Variable firstpoint, lastpoint
	Variable tickDelta
	Variable tickDif
	Variable previousPos, firstPos, lastPos, previousTickNumber, firstTickNumber
	Variable previousPosPixels, previousLabelWidth, currentPosPixels, currentLabelWidth, zapLastOK
	Variable fSize
	Variable fStyle
	String theFont
	Variable values2pixels
	
	GetAxis/Q/W=$theGraph $theAxis
	values2pixels = plotSize/abs(V_max-V_min)
	
	Variable currentL, currentR, previousL, previousR
	Variable labelGrout

	String infoString = GetAxisRecreation(theGraph, theAxis)
	theFont = defaultFontForAxis(theGraph, theAxis)
	fSize = str2num(StringByKey("fSize(x)", infoString, "=", ";"))
	if (fSize == 0)
		fSize = GetDefaultFontSize(theGraph, theAxis)
	endif
	fStyle = str2num(StringByKey("fStyle(x)", infoString, "=", ";"))
	if (fStyle == 0)
		fStyle = GetDefaultFontStyle(theGraph, theAxis)
	endif

	Make/O/N=(npnts, 6) TempTickInfoWave = 0	// c 0: tick delta from last tick. (for first tick, set the same delta as next tick)
												// c 1: 1 if this tick is at the end of a block of all same delta (that is, it is transitional tick)
												// c 2: dimension of label in pixels (width if wideSpacing is true, height otherwise)
												// c 3: position of tick on axis, in pixels
												// c 4: 1 to demote, 0 to keep label
												// c 5: 1 if this tick is a whole-number tick

	TempTickInfoWave[0][0] = str2num(tickLabels[1][0]) - str2num(tickLabels[0][0])
	TempTickInfoWave[0][1] = 0
	
	TempTickInfoWave[1,npnts-1][0] = str2num(tickLabels[p][0]) - str2num(tickLabels[p-1][0])
	if (debugUpdates)
		DoUpdate
	endif
	for (i = 0; i < npnts-1; i += 1)
		TempTickInfoWave[i][1] = (TempTickInfoWave[i][0] != TempTickInfoWave[i+1][0])
	endfor
	TempTickInfoWave[npnts-1][1] = 0		// the last tick is never a transitional tick
	if (debugUpdates)
		DoUpdate
	endif
	Variable dummy = fontsizeheight(theFont, fSize, fStyle)
	if (wideSpacing)
		labelGrout = HLABELGROUT
		TempTickInfoWave[][2] = FontSizeStringWidth(theFont, fSize, fStyle, tickLabels[p][0])
	else
		labelGrout = VLABELGROUT
		TempTickInfoWave[][2] = minTickSpacing*values2pixels
	endif
	TempTickInfoWave[][3] = tickVals[p]*values2pixels
	TempTickInfoWave[][4] = 0

	
	if (debugUpdates)
		DoUpdate
	endif
	
	// check ranges between transitional ticks for label conflicts and adjust as necessary
	Variable labelsBump
	Variable startIndex = 0

	TempTickInfoWave[][4] = !TempTickInfoWave[p][1]

	if (debugUpdates)
		DoUpdate
	endif
	
	for (i = 0; i < npnts; i += 1)
		if ( TempTickInfoWave[i][1] || (i == npnts-1) )		// i is either a transitional tick or it is the last tick
			labelsBump = checkForLabelConflicts(TempTickInfoWave, startIndex, i+1, labelGrout)	// i+1 because checkForLabelConflicts() takes a half-open interval
			if (labelsBump)
				adjustLabelsInRange(TempTickInfoWave, tickLabels, startIndex, i, labelGrout)
				if (debugUpdates)
					DoUpdate
				endif
			else
				TempTickInfoWave[startIndex, i][4] = 0			// no conflicts, mark all the ticks in this range as being OK to label
			endif
			startIndex = i
		endif
	endfor
	
	if (debugUpdates)
		DoUpdate
	endif

	// Check for the special case of a transitional tick that is the second (or second-to-last) tick on the axis,
	// and the first (or last) tick has been demoted. That means that the demoted tick is not bracketed by labels
	// so it is not possible to look at the labels that exist to figure out what value the non-major tick represents.
	// In that case, the demoted tick  and any minor ticks beyond the transitional tick need to be removed
	// and replaced with minor ticks at the spacing of minor ticks after (before) the transitional tick.

	if ( (TempTickInfoWave[0][4] == 1) && (TempTickInfoWave[1][1] == 1) )			// if first tick is demoted and second tick is transitional
		DeletePoints 0, 1, tickLabels, tickVals, TempTickInfoWave
		npnts -= 1
	endif
	
	if (debugUpdates)
		DoUpdate
	endif
	
	if ( (TempTickInfoWave[npnts-1][4] == 1) && (TempTickInfoWave[npnts-2][1] == 1) )			// if last tick is demoted and second to last tick is transitional
		DeletePoints npnts-1, 1, tickLabels, tickVals, TempTickInfoWave
		npnts -= 1
	endif
	
	if (debugUpdates)
		DoUpdate
	endif

	// Now we've checked and marked ticks for demotion; here we actually alter the tick waves to match
	for (i = 0; i < npnts; i += 1)
		if (TempTickInfoWave[i][4])
			tickLabels[i][1] = "Emphasized"		// demote the tick type; if this should be a minor tick, CullMinorTicks will do it
		endif
	endfor	
	
	if (debugUpdates)
		DoUpdate
	endif
end

Function removeLabelsFromEmphasizedTicks(tickLabels)
	Wave/T tickLabels
	
	Variable npnts = DimSize(tickLabels, 0)
	Variable i
	for (i = 0; i < npnts; i += 1)
		if ( (CmpStr(tickLabels[i][1], "Emphasized") == 0) || (CmpStr(tickLabels[i][1], "Minor") == 0) )
			tickLabels[i][0] = ""
		endif
	endfor
end


Function CheckMinorTickDensity(theGraph, theAxis, tickVals, tickLabels, minTickSpacing, plotSize)
	String theGraph
	String theAxis			// name of the actual axis in question (if it's a transform mirror axis, the name of the mirror axis itself, not the original axis)
	Wave tickVals
	Wave/T tickLabels
	Variable minTickSpacing	// this number is in units of the tickVals wave
	Variable plotSize
	
	GetAxis/Q/W=$theGraph $theAxis
	Variable values2pixels = plotSize/abs(V_max-V_min)

	Variable tooDense = 0
	Variable i, j, jj
	Variable firstPoint, lastPoint, numToDelete
	Variable npnts = DimSize(tickVals, 0)-1
	i = 0
	j = 1
	do
		if ( (j == npnts) || (CmpStr(tickLabels[j][1], "Major") == 0) )	// found a matching major tick, now cull the minor and emphasized ticks between
			
			if (j == i+1)
				i = j
				j += 1
				if (j > npnts)
					break
				endif
			endif
			
			tooDense = 0
			for (jj = i; jj < j; jj += 1)
				if (abs(tickVals[jj+1] - tickVals[jj])*values2pixels < minTickSpacing)
					tooDense = 1
					break
				endif
			endfor
			
			if (tooDense)
				firstPoint = i
				if (CmpStr(tickLabels[firstPoint][1], "Major") == 0)	
					firstPoint += 1
				endif
				lastPoint = j
				if (CmpStr(tickLabels[lastPoint][1], "Major") == 0)
					lastPoint -= 1
				endif
				numToDelete = lastPoint-firstPoint+1
				DeletePoints firstPoint, numToDelete, tickVals, tickLabels
				j = firstPoint			// -1 because j will be incremented just before we loop around again
				npnts -= numToDelete
			endif
			i = j
		endif
		j += 1
	while (j <= npnts)
end


Function PickDigit(theNum, delta)
	Variable theNum
	Variable delta
	
	Variable WhichDigit = log(abs(delta))
	WhichDigit = floor(WhichDigit)
	Variable factor = 10^(whichDigit)
	Variable intermediate = abs(theNum)/factor		// assign to variable so I can see it in the debugger
	Variable scaledNum = round(intermediate)		// desired digit now in place just left of decimal point
	Variable newNum = round(scaledNum/10)*10
	if (debugInfo)
		print "In PickDigit --- theNum, delta, scaledNum, newNum, scaledNum-newNum: ", theNum, delta, scaledNum, newNum, scaledNum-newNum
	endif	
	return scaledNum-newNum
end
	
// Sometimes the main ticking algorithm fails to create the last major tick that fits.
// This function will add a major tick at either end at the same spacing as the last 
// existing major ticks.
Function AddMissingMajorTicks(tickVals, tickLabels, values2pixels, minorSep, axisFunc, axisFuncPWave, axisStart, axisEnd, isMirror, highBracket, lowBracket, precision)
	Wave tickVals
	Wave/T tickLabels
	Variable values2pixels, minorSep
	FUNCREF TransformAxisTemplate axisFunc
	Wave axisFuncPWave
	Variable axisStart, axisEnd
	Variable isMirror, highBracket, lowBracket, precision
	
	Variable i,jj
	Variable tickDelta, tickDeltaPwr,tickDeltaMantissa
	Variable majorDif, majorDistance, decimalPos, numPlaces
	Variable numMinor, lastMajor, nextToLastMajor, newMajor, tickDeltaSign, newRawMajor
	Variable inversePrecision = min(1e-6, 10^(-precision-2))
	String ticklbl

	// at the row zero end of the tick label waves
	lastMajor = str2num(tickLabels[0])
	nextToLastMajor = str2num(tickLabels[1])
	majorDif = nextToLastMajor - lastMajor
	newMajor = lastMajor - majorDif
	if (isMirror)
		newRawMajor = getInverseValueWithinBounds(newMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		newRawMajor = axisFunc(axisFuncPWave, newMajor)
	endif
	if ( (numType(newRawMajor) == 0) && isNearlyBetween(newRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0])-decimalPos
		else
			numPlaces = 0
		endif
		InsertPoints 0, 1, tickLabels, tickVals
		tickLabels[0][1] = "Major"
		sprintf ticklbl, "%.*f", numPlaces, newMajor			// appropriate label
		tickLabels[0][0] = ticklbl
		tickVals[0] = newRawMajor
	endif

	Variable npnts = numpnts(tickVals)
	Variable nextRow = npnts

	// at the other end
	lastMajor = str2num(tickLabels[npnts-1])
	nextToLastMajor = str2num(tickLabels[npnts-2])
	majorDif = nextToLastMajor - lastMajor
	newMajor = lastMajor - majorDif
	if (isMirror)
		newRawMajor = getInverseValueWithinBounds(newMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		newRawMajor = axisFunc(axisFuncPWave, newMajor)
	endif
	if ( (numType(newRawMajor) == 0) && isNearlyBetween(newRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0])-decimalPos
		else
			numPlaces = 0
		endif
		InsertPoints npnts, 1, tickLabels, tickVals
		tickLabels[nextRow][1] = "Major"
		sprintf ticklbl, "%.*f", numPlaces, newMajor			// appropriate label
		tickLabels[nextRow][0] = ticklbl
		tickVals[nextRow] = newRawMajor
	endif
end
	
// This function assumes that the tick waves have only major ticks.
Function AddMinorTicks(tickVals, tickLabels, values2pixels, minorSep, axisFunc, axisFuncPWave, isMirror, highBracket, lowBracket, numPlaces, axisStart, axisEnd)
	Wave tickVals
	Wave/T tickLabels
	Variable values2pixels, minorSep
	FUNCREF TransformAxisTemplate axisFunc
	Wave axisFuncPWave
	Variable isMirror, highBracket, lowBracket, numPlaces
	Variable axisStart, axisEnd
	
	Variable npnts = numpnts(tickVals)		// if there are any minor ticks already in the tick waves, this will be wrong!
	Variable i,jj
	Variable nextRow = npnts
	Variable tickDelta, tickDeltaPwr,tickDeltaMantissa, InversePrecision
	Variable majorDif, minorDif, majorDistance, emphasizeEvery
	Variable numMinor, lastMajor, tickDeltaSign, rawMinor
	
	// first, minor ticks prior to the first major tick, at the spacing of the minor ticks between the first pair of major ticks
	numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
	lastMajor = str2num(tickLabels[0])
	for (jj = 1; jj < numMinor; jj += 1)
		if (isMirror)
			InversePrecision = min(10^(-numPlaces-2), 1e-6)
			rawMinor = getInverseValueWithinBounds( lastMajor + jj*minorDif, HighBracket, LowBracket, InversePrecision, axisFunc, axisFuncPWave)
		else
			rawMinor = axisFunc(axisFuncPWave, lastMajor + jj*minorDif)
		endif
		if ( (numType(rawMinor) != 0) || !isNearlyBetween(rawMinor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
			break;
		endif
		InsertPoints nextRow, 1, tickLabels, tickVals
		if (mod(jj,emphasizeEvery) == 0)
			tickLabels[nextRow][1] = "Emphasized"
		else
			tickLabels[nextRow][1] = "Minor"
		endif
		tickVals[nextRow] = rawMinor
		tickLabels[nextRow][0] = ""
		if (DebugUpdates)
			DoUpdate
		endif
		nextRow += 1
	endfor

	for (i = 1; i < npnts; i += 1)
		numMinor = CalculateNumMinorTicks(str2num(tickLabels[i]), str2num(tickLabels[i-1]), tickVals[i]*values2pixels, tickVals[i-1]*values2pixels, minorSep, minorDif, emphasizeEvery)
	
		lastMajor = str2num(tickLabels[i-1])
		for (jj = 1; jj < numMinor; jj += 1)
			InsertPoints nextRow, 1, tickLabels, tickVals
			if (mod(jj,emphasizeEvery) == 0)
				tickLabels[nextRow][1] = "Emphasized"
			else
				tickLabels[nextRow][1] = "Minor"
			endif
			tickLabels[nextRow][0] = ""
			if (isMirror)
				InversePrecision = min(10^(-numPlaces-2), 1e-6)
				tickVals[nextRow] = getInverseValueWithinBounds( lastMajor - jj*minorDif, HighBracket, LowBracket, InversePrecision, axisFunc, axisFuncPWave)
			else
				tickVals[nextRow] = axisFunc(axisFuncPWave, lastMajor - jj*minorDif)
			endif
			if (DebugUpdates)
				DoUpdate
			endif
			nextRow += 1
		endfor
	endfor
	
	// now continue the last spacing to fill out the minor ticks to the end of the axis
	lastMajor = str2num(tickLabels[npnts-1])
	for (jj = 1; jj < numMinor; jj += 1)
		if (isMirror)
			InversePrecision = min(10^(-numPlaces-2), 1e-6)
			rawMinor = getInverseValueWithinBounds( lastMajor - jj*minorDif, HighBracket, LowBracket, InversePrecision, axisFunc, axisFuncPWave)
		else
			rawMinor = axisFunc(axisFuncPWave, lastMajor - jj*minorDif)
		endif
		if ( (numType(rawMinor) != 0) || !isNearlyBetween(rawMinor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
			break;
		endif
		InsertPoints nextRow, 1, tickLabels, tickVals
		if (mod(jj,emphasizeEvery) == 0)
			tickLabels[nextRow][1] = "Emphasized"
		else
			tickLabels[nextRow][1] = "Minor"
		endif
		tickVals[nextRow] = rawMinor
		tickLabels[nextRow][0] = ""
		if (DebugUpdates)
			DoUpdate
		endif
		nextRow += 1
	endfor
	
end

// this function assumes that minor ticks may have been added, but they are all at the end of the tick waves.
// That is, it can safely assume that row zero is a major tick, and that as it indexes through the waves,
// the first time a non-major tick is encountered, there are no more major ticks.
Function AddTicksAtEnds(tickVals, tickLabels, values2pixels, minorSep, axisFunc, axisFuncPWave, axisStart, axisEnd, isMirror, highBracket, lowBracket, precision)
	Wave tickVals
	Wave/T tickLabels
	Variable values2pixels, minorSep
	FUNCREF TransformAxisTemplate axisFunc
	Wave axisFuncPWave
	Variable axisStart, axisEnd
	Variable isMirror, highBracket, lowBracket, precision
	
	Variable inversePrecision = min(1e-6, 10^(-precision-2))
	Variable numMajor = 0
	Variable npnts = numpnts(tickVals)
	Variable i
	for (i = 0; i < npnts; i += 1)
		if (CmpStr("Major", tickLabels[i][1] ) != 0)
			break;
		endif
	endfor
	numMajor = i
	
	Variable majordif = str2num(tickLabels[1]) - str2num(tickLabels[0])
	Variable nextMajor, numPlaces, nextRawMajor
	Variable decimalPos
	String ticklbl
	Variable numMinor, minorDif
	Variable nextRow = npnts
	Variable lastGoodTick = 0
	Variable lastMajor, nextMinor, lastTick, lastLabel
	Variable emphasizeEvery, jj
	Variable lableLen
	String dummyString
	Variable emphasizedLabel, labelThis, lastEmphLabel

	// Here we will add ticks at the interval of the last major tick, adding minor ticks between if desired
	// (Sometimes the main ticking algorithm fails to create the last major tick that fits).
	lastMajor = str2num(tickLabels[0])
	nextMajor = lastMajor - majorDif
	if (isMirror)
		nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
	endif
	if ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0])-decimalPos
		else
			numPlaces = 0
		endif
		do
			InsertPoints 0, 1, tickLabels, tickVals
			tickLabels[0][1] = "Major"
			sprintf ticklbl, "%.*f", numPlaces, nextMajor			// appropriate label
			tickLabels[0][0] = ticklbl
			if (isMirror)
				tickVals[0] = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				tickVals[0] = axisFunc(axisFuncPWave, nextMajor)
			endif
			nextRow += 1
			npnts += 1
			numMajor += 1
			if (debugUpdates)
				DoUpdate
			endif
			lastMajor = nextMajor
			nextMajor = lastMajor - majorDif		
			if (isMirror)
				nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
			endif
		while ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) )
	endif
	
	if (debugUpdates)
		DoUpdate
	endif
	
	Variable thePnt = numMajor
	lastMajor = str2num(tickLabels[thePnt-1])
	majordif = str2num(tickLabels[thePnt-2]) - str2num(tickLabels[thePnt-1])
	nextMajor = lastMajor - majorDif
	if (isMirror)
		nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
	endif
	if ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[thePnt], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[thePnt])-decimalPos
		else
			numPlaces = 0
		endif
		do
			InsertPoints thePnt, 1, tickLabels, tickVals
			tickLabels[thePnt][1] = "Major"
			sprintf ticklbl, "%.*f", numPlaces, nextMajor			// appropriate label
			tickLabels[thePnt][0] = ticklbl
			if (isMirror)
				tickVals[thePnt] = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				tickVals[thePnt] = axisFunc(axisFuncPWave, nextMajor)
			endif
			nextRow += 1
			npnts += 1
			thePnt += 1
			numMajor += 1
			lastMajor = nextMajor
			nextMajor = lastMajor + majorDif		
			if (isMirror)
				nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
			endif
		while ( (numType(nextMajor) == 0) && isNearlyBetween(nextMajor, axisStart, axisEnd, 1e-6) )
	endif
	
	if (debugUpdates)
		DoUpdate
	endif
	
	// Here we add ticks at positions appropriate for minor ticks based on the last major tick interval. 
	// The last minor tick that fits will be made a major tick so that the ends of the axis are appropriately labeled.
	// If no minor ticks are allowed by the standard algorithm, then calculate minor ticks at tighter spacing and only add the
	// last of them as a major tick.
	
	// woops- it turns out that the procedure outlined above has the potential to make a major tick at a delta from the previous
	// tick that makes it difficult to add minor ticks, like the new tick might be 0.005 and the next major tick is at .04.
	// To fix this, we add a major tick for *all* minor ticks that fit between the last major tick and the axis end. Since
	// AddTicksAtEnds is called before AdjustTickLabelSpacing, the extras will be removed.
	
	lastMajor = str2num(tickLabels[0])
	// figure out the number of digits required by the labels from the last label already on the graph
	dummyString = tickLabels[0]
	decimalPos = strsearch(dummyString, ".", 0)
	lableLen = strlen(dummyString)
	if (decimalPos >= 0)
		numPlaces = lableLen - decimalPos+1
	else
		if ( (lableLen > 1) && (CmpStr(dummyString[lableLen-1], "0") == 0) )
			numPlaces = 0
		else
			numPlaces = 1
		endif
	endif
	numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
	if (numMinor <= 1)
		numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, 0, minorDif, emphasizeEvery)
	endif
	emphasizedLabel = -1
	Variable minorToUse
	if (numMinor > 1)
		for (jj = 1; jj < numMinor; jj += 1)
			if (isMirror)
				nextMinor = getInverseValueWithinBounds(lastMajor + jj*minorDif, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				nextMinor = axisFunc(axisFuncPWave, lastMajor + jj*minorDif)
			endif
			if ( (numType(nextMinor) != 0) || !isNearlyBetween(nextMinor, axisStart, axisEnd, 1e-6) )
				break
			endif
			minorToUse = nextMinor
		endfor
		jj -= 1
		if (jj > 0)			
			InsertPoints nextRow, 1, tickLabels, tickVals
			sprintf ticklbl, "%.*f", numPlaces, lastMajor + jj*minorDif			// appropriate label
			tickLabels[nextRow][0] = ticklbl
			tickLabels[nextRow][1] = "Major"
			tickVals[nextRow] = minorToUse
			nextRow += 1
		endif
	endif

	if (debugUpdates)
		DoUpdate
	endif
	
	dummyString = tickLabels[numMajor-1]
	decimalPos = strsearch(dummyString, ".", 0)
	lableLen = strlen(dummyString)
	if (decimalPos >= 0)
		numPlaces = lableLen - decimalPos+1
	else
		if ( (lableLen > 1) && (CmpStr(dummyString[lableLen-1], "0") == 0) )
			numPlaces = 0
		else
			numPlaces = 1
		endif
	endif
	numMinor = CalculateNumMinorTicks(str2num(tickLabels[numMajor-1]), str2num(tickLabels[numMajor-2]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, minorSep, minorDif, emphasizeEvery)
	if (numMinor <= 1)
		numMinor = CalculateNumMinorTicks(str2num(tickLabels[numMajor-1]), str2num(tickLabels[numMajor-2]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, 0, minorDif, emphasizeEvery)
	endif
	emphasizedLabel = -1

	if (numMinor > 1)
		lastMajor = str2num(tickLabels[numMajor-1])
		for (jj = 1; jj < numMinor; jj += 1)
			if (isMirror)
				nextMinor = getInverseValueWithinBounds(lastMajor - jj*minorDif, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
			else
				nextMinor = axisFunc(axisFuncPWave, lastMajor - jj*minorDif)
			endif
			if ( (numType(nextMinor) != 0) || !isNearlyBetween(nextMinor, axisStart, axisEnd, 1e-6) )
				break
			endif
			minorToUse = nextMinor
		endfor
		jj -= 1
		if (jj > 0)			
			InsertPoints nextRow, 1, tickLabels, tickVals
			sprintf ticklbl, "%.*f", numPlaces, lastMajor - jj*minorDif			// appropriate label
			tickLabels[nextRow][0] = ticklbl
			tickLabels[nextRow][1] = "Major"
			tickVals[nextRow] = minorToUse
			nextRow += 1
		endif
	endif
	
	if (debugUpdates)
		DoUpdate
	endif
end

// Returns number of minor ticks that should go in the interval (firstNum, secondNum)
// Actually, it returns the number of divisions of the major tick interval, so it's number of minor ticks plus one.
// Other interesting numbers are passed back via reference parameters

// note that this function does not take into account the (possibly) changing slope of the transformation function
Function CalculateNumMinorTicks(firstNum, secondNum, firstPos, secondPos, minorSep, minorTickDelta, emphasizeEvery)
	Variable firstNum, secondNum, firstPos, secondPos, minorSep
	Variable &minorTickDelta
	Variable &emphasizeEvery
	
	Variable numMinor

	Variable majorDistance = abs(secondPos - firstPos)		// used to calculate the actual distance between minor ticks
	
	Variable tickDelta = secondNum - firstNum
	Variable tickDeltaSign = sign(tickDelta)
	tickDelta = abs(tickDelta)
	Variable tickDeltaPwr = log(tickDelta)
	Variable tickDeltaMantissa = round(tickDelta / 10^floor(tickDeltaPwr))		// this calculates the manitissa of a number with one digit (that is, 0.01 yields 1, .002 yields 2)
																								// round avoid annoying things like 1.99999 instead of 2.
	if (abs(tickDeltaMantissa - tickDelta/10^floor(tickDeltaPwr))/tickDeltaMantissa > 1e-6)
//		print "Must be a two-digit tickdelta: firstNum = ", firstNum, " secondNum = ", secondNum
//		we need to extract the fractional part, and set allowed minor tick delta based on the fraction:
//		.1		.1
//		.2		.1, .2
//		.3		.1
//		.4		.1, .2
//		.5		.1, .5		<-- this is the different one!
//		.6		.1, .2
//		.7		.1
//		.8		.1, .2
//		.9		.1
	endif
	
	// tickDelta is subject to roundoff error, so here we make a number like 0.00999 into 0.01
	Variable tickDeltaFactor = 1e6/(10^floor(tickDeltaPwr))
	tickDelta = round(tickDelta*tickDeltaFactor)/tickDeltaFactor
	tickDeltaPwr = log(tickDelta)
	tickDeltaMantissa = round(tickDelta / 10^floor(tickDeltaPwr))		
	
	emphasizeEvery = 50		// 50 is so large, it will never happen!															I think.
	switch (tickDeltaMantissa)
		case 1:
			if (majorDistance /10 > minorSep)
				numMinor = 10
				emphasizeEvery = 5
			elseif (majorDistance /5 > minorSep)
				numMinor = 5
			elseif (majorDistance /2 > minorSep)
				numMinor =2
			else
				numMinor = 1
			endif
			break
		case 2:
			if (majorDistance /4 > minorSep)
				numMinor = 4
				emphasizeEvery = 2
			elseif (majorDistance /2 > minorSep)
				numMinor = 2
			else
				numMinor = 1
			endif
			break
		case 3:
			if (majorDistance/6 > minorSep)
				numMinor = 6
				emphasizeEvery = 2
			elseif (majorDistance/3 > minorSep)
				numMinor = 3
			endif
			break
		case 4:
			if (majorDistance /8 > minorSep)
				numMinor = 8
				emphasizeEvery = 2
			elseif (majorDistance /4 > minorSep)
				numMinor = 4
			else
				numMinor = 1
			endif
			break
		case 5:
			if (majorDistance /10 > minorSep)
				numMinor = 10
				emphasizeEvery = 2
			elseif (majorDistance /5 > minorSep)
				numMinor = 5
			else
				numMinor = 1
			endif
			break
		case 6:
			if (majorDistance/12 > minorSep)
				numMinor = 12
				emphasizeEvery = 2
			elseif (majorDistance/6 > minorSep)
				numMinor = 6
				emphasizeEvery = 2
			elseif (majorDistance/3 > minorSep)
				numMinor = 3
			endif
			break
		case 7:
			if (majorDistance/7 > minorSep)
				numMinor = 7
			endif
			break;
		case 8:
			if (majorDistance /8 > minorSep)
				numMinor = 8
				emphasizeEvery = 2
			elseif (majorDistance /4 > minorSep)
				numMinor = 4
			else
				numMinor = 1
			endif
			break
		case 9:
			if (majorDistance/9 > minorSep)
				numMinor = 9
			endif
			break
		default:
			print "BUG: in CalculateNumMinorTicks, took the default case"
			break
	endswitch
	minorTickDelta = tickDeltaSign*tickDelta/numMinor
	return numMinor
end	

Function RemoveAnyMinorTicks(tickVals, tickLabels)
	Wave tickVals
	Wave/T tickLabels

	Variable npnts = DimSize(tickVals, 0)
	Variable i
	for (i = 0; i < npnts; i += 1)
		if (CmpStr(tickLabels[i][1], "Major") != 0)			// it's not a major tick
			DeletePoints i, 1, tickVals, tickLabels
			i -= 1
			npnts -= 1
		endif
	endfor
end

// this function looks for ranges between major ticks where there are emphasized ticks without any minor ticks,
// or emphasized ticks and minor ticks, but there isn't a minor tick between every emphasized tick.
// Any minor ticks in such a range are removed and the emphasized ticks are demoted to minor ticks.

// Also checks the ends of the axis for bad minor ticks- that is, minor ticks with spacing different from 
// the minor ticks in the previous major tick interval. Minor ticks don't have labels, so they only make sense if
// they are bounded on both sides by labelled (major) ticks, or if they simply continue the minor ticking from
// a range that is bounded by labels.
Function CullMinorTicks(tickVals, tickLabels)
	Wave tickVals
	Wave/T tickLabels

	// sort so that the major and minor ticks are in order (AddMinorTicks() puts the minor ticks at the end of the waves)
	Duplicate/O tickVals, sortIndex, sortVals
	Duplicate/T/O tickLabels, sortLabels
	MakeIndex tickVals, sortIndex
	tickVals = sortVals[sortIndex[p]]
	tickLabels = sortLabels[sortIndex[p]]
	KillWaves/Z sortIndex, sortVals, sortLabels
	
	if (debugUpdates)
		DoUpdate
	endif
	
	Variable i, j, jj
	Variable startIndex = 0
	for (j = startIndex+1; j < DimSize(tickVals, 0); j += 1)
		if (CmpStr(tickLabels[j][1], "Major") == 0)	// found a matching major tick, now cull the minor and emphasized ticks between
			CullTicksDirtyWork(tickVals, tickLabels, startIndex, j)	// may alter j
			startIndex = j
		endif
	endfor
	
	if (debugUpdates)
		DoUpdate
	endif
	
	Variable lastIndex = DimSize(tickVals, 0)-1
	Variable erase = 0
	Variable firstMajorIndex, nextTickAfter
	if (CmpStr(tickLabels[0][1], "Major") != 0)	// tick at beginning of axis is NOT a major tick- we gotta check it out
		for (i = 1; i <= lastIndex; i += 1)
			if (CmpStr(tickLabels[i][1], "Major") == 0)	// found the first major tick
				firstMajorIndex = i
				break
			endif
		endfor
		if (CmpStr(tickLabels[firstMajorIndex+1][1], "Major") == 0)	// the tick after the first major tick is another major tick
			erase = 1
		else
			if (!AlmostEqual(abs(tickVals[1] - tickVals[0]), abs(tickVals[firstMajorIndex+1] - tickVals[firstMajorIndex]), 1e-6))
				erase = 1
			endif
		endif
		if (erase)
			DeletePoints 0, firstMajorIndex, tickVals, tickLabels
		endif
	endif
	if (debugUpdates)
		DoUpdate
	endif
	
	lastIndex = DimSize(tickVals, 0)-1
	if (CmpStr(tickLabels[lastIndex][1], "Major") != 0)	// tick at end of axis is NOT a major tick- we gotta check it out
		for (i = lastIndex-1; i >= 0; i -= 1)
			if (CmpStr(tickLabels[i][1], "Major") == 0)	// found the first major tick
				firstMajorIndex = i
				break
			endif
		endfor
		if (CmpStr(tickLabels[firstMajorIndex-1][1], "Major") == 0)	// the tick after the first major tick is another major tick
			erase = 1
		else
			if (!AlmostEqual(abs(tickVals[lastIndex] - tickVals[lastIndex-1]), abs(tickVals[firstMajorIndex] - tickVals[firstMajorIndex-1]), 1e-6))
				erase = 1
			endif
		endif
		if (erase)
			DeletePoints firstMajorIndex+1, lastIndex-firstMajorIndex, tickVals, tickLabels
		endif
	endif
	if (debugUpdates)
		DoUpdate
	endif
end

Function CullTicksDirtyWork(tickVals, tickLabels, startPoint, endPoint)
	Wave tickVals
	Wave/T tickLabels
	Variable &startPoint, &endPoint	// point numbers of two consecutive major ticks
	
	Variable i
	Variable foundEmph = 0
	Variable foundAtLeastOneEmph = 0
	Variable foundEmphTooClose = 0
	Variable foundEmphNextToMajor = 0
	Variable foundMinor = 1
	Variable doCullMinor = 0
	Variable doDemoteEmph = 0

	for (i = startPoint; i < endPoint; i += 1)
		if (CmpStr(tickLabels[i][1], "Minor") == 0)
			foundMinor = 1
			foundEmph = 0
		endif
		if (CmpStr(tickLabels[i][1], "Emphasized") == 0)
			foundAtLeastOneEmph = 1
			if (foundEmph)
				foundEmphTooClose = 1
			else
				foundEmph = 1
			endif
			if ( (CmpStr(tickLabels[i-1][1], "Major") == 0) || (CmpStr(tickLabels[i+1][1], "Major") == 0) )
				foundEmphNextToMajor = 1
			endif
		endif
	endfor
	doCullMinor = foundAtLeastOneEmph && foundMinor && (foundEmphTooClose || foundEmphNextToMajor)
	doDemoteEmph = doCullMinor || (foundAtLeastOneEmph && !foundMinor)
	if (doCullMinor)
		i = startPoint+1
		do
			if (CmpStr(tickLabels[i][1], "Minor") == 0)
				DeletePoints i, 1, tickVals, tickLabels
				endPoint -= 1
			else
				i += 1
			endif
		while (i < endPoint)
	endif
	if (doDemoteEmph)
		for (i = startPoint+1; i < endPoint; i += 1)
			if (CmpStr(tickLabels[i][1], "Emphasized") == 0)
				tickLabels[i][1] = "Minor"
			endif
		endfor
	endif
end

Function RemoveExtraZeroesFromLabels(tickLabels)
	Wave/T tickLabels
	
	Variable npnts = DimSize(tickLabels, 0)
	Variable i
	Variable labelLen
	String theLabel
	Variable decimalPos
	
	for (i = 0; i < npnts; i += 1)
		labelLen = strlen(tickLabels[i][0])
		if (labelLen > 0)
			theLabel = tickLabels[i][0]
			decimalPos = StrSearch(theLabel, ".", 0)
			// only remove zeroes the right of the decimal point and allow ".0" but not ".00" or ".50"
			if ( (decimalPos > 0) && (decimalPos < labelLen-2) )
				if (CmpStr(theLabel[labelLen-1], "0") == 0)
					tickLabels[i][0] = theLabel[0,labelLen-2]
				endif
			endif
		endif
	endfor
end


Function NextNiceNumber(Range, fromValue, numTicks, smaller, anyWholeNumer, outTickDelta, outNumPlaces, nextWholeNumber, wholeNumberDelta, outTickDeltaMantissa)
	Variable Range		// range to be used for calculating digits
	Variable fromValue	// value near to the nice number we need
	Variable numTicks
	Variable smaller	// returned value should be smaller than fromValue
	Variable anyWholeNumer
	Variable &outTickDelta
	Variable &outNumPlaces
	Variable &nextWholeNumber
	Variable &wholeNumberDelta
	Variable &outTickDeltaMantissa
	
	// if the calling routine feeds us bad data, we return NaN. Better be checking for it!
	if (Range == 0)
		outTickDelta = NaN
		outNumPlaces = NaN
		nextWholeNumber = NaN
		wholeNumberDelta = NaN
		outTickDeltaMantissa = NaN
		return NaN
	endif
	
	Variable resolution = log(abs(Range)/NumTicks)
	Variable intRes = trunc(resolution)
//	Variable intRes = round(resolution)
	if (resolution < 0)
		intRes -= 1
	endif
	Variable tickDelta = resolution - intRes
	Variable numPlaces = intRes
	Variable Delta
	Variable wholeNumberModulus
	if (anyWholeNumer)
		Delta= 1;
		if( tickDelta > 0.875 )			// delta>log10(7.5)? */
			tickDelta=  10;
			numPlaces += 1;
			wholeNumberModulus = 1
		else
			tickDelta=  1;
			wholeNumberModulus = 10
		endif
	else
		if( tickDelta > 0.875 )			// delta>log10(7.5)? */
			Delta= 1;
			tickDelta=  10;
			numPlaces += 1;
			wholeNumberModulus = 1
		elseif( tickDelta > 0.544 )		// delta>log10(3.5)? */
			Delta= 5;
			tickDelta=  5;
			wholeNumberModulus = 2
		elseif( tickDelta > 0.176 )		// delta>log10(1.5)? */
			Delta= 2;
			tickDelta=  2;
			wholeNumberModulus = 5
		else
			Delta= 1;
			tickDelta=  1;
			wholeNumberModulus = 10
		endif
	endif

	outTickDeltaMantissa = Delta
	tickDelta= tickDelta*10^intRes;
	numPlaces = min(15, -min(0,numPlaces))

	Variable theSign = sign(fromValue)
	fromValue = abs(fromValue)
	Variable tickValue = 0
	Variable i = floor(fromValue/tickDelta)
	do
		tickValue = i*tickDelta
		i += 1
	while (tickValue < fromValue)
	i -= 1
	if (smaller)
		i -= 1
	endif
	variable nextTick = i*tickDelta
	wholeNumberDelta = wholeNumberModulus*tickDelta
	Variable j = floor(nextTick/wholeNumberDelta)
	do
		nextWholeNumber = j*wholeNumberDelta
		j += 1
	while (nextWholeNumber < nextTick)
	j -= 1
	nextWholeNumber = j*wholeNumberDelta*theSign
	if (smaller && (nextWholeNumber > nextTick) )
		nextWholeNumber -= wholeNumberDelta
	endif
	if (debugInfo)
		print "In NextNiceNumber(), smaller, wholeNumberModulus, j, nextTick, wholeNumberDelta, tickDelta, theSign, nextWholeNumber", smaller, wholeNumberModulus, j, nextTick, wholeNumberDelta, tickDelta, theSign, nextWholeNumber
	endif

	outTickDelta = tickDelta
	outNumPlaces = numPlaces
	return i*tickDelta*theSign
end

Function UndoTransformTraces(theGraph, theAxis)
	String theGraph
	String theAxis

	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif

	String saveDF = GetDatafolder(1)
	
	String theGraphFolder = folderForThisGraph(theGraph, 0)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		DoAlert 0, "This graph has no transformed axes"
		SetDatafolder $saveDF
		return -1
	endif
	SetDatafolder $theGraphFolder
	String theAxisFolder = findDatafolderForAxis(theAxis, 0)
	if ((strlen(theAxisFolder) == 0) || !DatafolderExists(theAxisFolder))
		DoAlert 0, "The axis "+theAxis+" is not a transformed axis"
		SetDatafolder $saveDF
		return -1
	endif
	SetDatafolder $theAxisFolder
	
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	Variable i
	String theTraces = TraceNameList(theGraph, ";", 1)
	String theWaveNote
	String oneTrace
	String oneKeyvalue
	String axisRecreation
	Variable AxisLeft	
	Variable AxisRight
	String SetAxisFlags
	
	i = 0
	do
		oneTrace =  StringFromList(i, theTraces)
		if (strlen(oneTrace) == 0)
			break
		endif
		if (isTransformMirrorTrace(theGraph, oneTrace))
			Wave w = TraceNameToWaveRef(theGraph, oneTrace)
			NVAR AxisMin, AxisMax
			if (isXAxis)
				SetScale/I x AxisMin, AxisMax,w
			else
				w[0] = AxisMin
				w[1] = AxisMax
			endif
		else
			if (isXAxis)
				Wave/Z w = XWaveRefFromTrace(theGraph, oneTrace)
				if (!WaveExists(w))
					i += 1
					continue
				endif
			else
				Wave w = TraceNameToWaveRef(theGraph, oneTrace)
			endif
			theWaveNote = Note(w)
			oneKeyValue = StringByKey("TransformAxis", theWaveNote, "=", ";")
			if (CmpStr(oneKeyValue, theAxis) != 0)
				i += 1
				continue		// either this axis wasn't transformed, or this wave wasn't on the axis when it was transformed, or ...
			endif
			AxisLeft = NumberByKey("AXISLEFT", theWaveNote, "=", ";")
			AxisRight = NumberByKey("AXISRIGHT", theWaveNote, "=", ";")
			SetAxisFlags = StringByKey("SETAXISFLAGS", theWaveNote, "=", ";")
			axisRecreation = GetAxisRecreationFromInfoString(theWaveNote, "=")		// it's overkill to get it from every wave, but this protects it from being over-written if a transformed axis is transformed
			oneKeyValue = StringByKey("OldWave", theWaveNote, "=", ";")
			Wave/Z oldW = $oneKeyValue
			if (isXAxis)
				ReplaceWave/X trace=$oneTrace, oldW		// replace transformed wave with the original in this trace (if there was no X wave, it will transform it back into a waveform trace)
			else
				ReplaceWave/Y trace=$oneTrace, oldW		// replace transformed wave with the original in this trace
			endif
			SetFormula w, ""
			KillWaves w
		endif
		i += 1
	while (1)
	if (strlen(SetAxisFlags) > 0)
		Execute "SetAxis"+SetAxisFlags+"/Z "+theAxis
	else
		Execute "SetAxis "+theAxis+","+num2str(AxisLeft)+","+num2str(AxisRight)
	endif
	if (strlen(WaveList("*_T", ";", "")) != 0)		// the axis was transformed more than once, and there are still transform waves in use. The axis recreation string is not useful.
		NVAR doTicksAtEnds
		TicksForTransformAxis(theGraph, theAxis, 5, 0,3, "", doTicksAtEnds)	// default values for this because the tickLabel and tickValue waves get overwritten
	else
		ApplyAxisRecreation(theAxis, theGraph, axisRecreation)
		SetDatafolder ::
		KillDatafolder $theAxisFolder
		if (CountObjects(":", 4) == 0)		// no transformed axes left for this graph
			SetDatafolder ::
			KillDatafolder $theGraphFolder
		endif
	endif

	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

static Function PrintLongString(theString, lineLength, prefix)
	String theString
	Variable lineLength
	String prefix
	
	Variable stringLength = strlen(theString)
	Variable startC=0, endC=lineLength-1
	do
		print prefix+theString[startC, endC]
		startC += lineLength
		endC += lineLength
	while(startC < stringLength)
end

Function/S FindTransformTraceGivenWave(theGraph, theWave)
	String theGraph
	Wave theWave
	
	String tList = TraceNameList(theGraph, ";", 1)
	String aTrace
	String WaveWithPath = GetWavesDatafolder(theWave, 2)
	String wNote, xwNote
	Variable i=0
	do
		aTrace = StringFromList(i, tList)
		if (strlen(aTrace) == 0)
			break
		endif
		if (!isTransformTrace(theGraph, aTrace))
			i += 1
			continue
		endif
		Wave/Z w = TraceNameToWaveRef(theGraph, aTrace)
		Wave/Z xw = XWaveRefFromTrace(theGraph, aTrace)
		if (WaveExists(w))
			wNote = Note(w)
			if (strlen(wNote) > 0)
				if (CmpStr(StringByKey("OldWave", wNote, "=", ";"), WaveWithPath) == 0)
					return aTrace
				elseif (CmpStr(StringByKey("OldYWave", wNote, "=", ";"), WaveWithPath) == 0)
					return aTrace
				endif
			endif
		endif
		if (WaveExists(xw))
			wNote = Note(xw)
			if (strlen(wNote) > 0)
				if (CmpStr(StringByKey("OldWave", wNote, "=", ";"), WaveWithPath) == 0)
					return aTrace
				elseif (CmpStr(StringByKey("OldYWave", wNote, "=", ";"), WaveWithPath) == 0)
					return aTrace
				endif
			endif
		endif
		i += 1
	while (1)
	
	return ""
end

Function UndoTransformMirror(theGraph, theAxis)
	String theGraph
	String theAxis

	String saveDF = GetDatafolder(1)
	
	if  (SetDataFolderForMirrorAxis(theGraph, theAxis) != 0)
		SetDatafolder $saveDF
		return 0		// no transform mirror axis for this axis, so don't do anything
	endif
	String theDataFolder = GetDatafolder(0)
	
	Variable MirrorWasTransformed
	SVAR DummyWaveName
	Wave/Z DummyWave = $DummyWaveName
	if (!WaveExists(DummyWave))
		DoAlert 0, "The dummy wave for the mirror axis is missing. Someone's been tampering..."
		SetDatafolder $saveDF
		return -1
	endif	
	String theGraphTrace = DummyWaveName
	Wave/Z w = TraceNameToWaveRef(theGraph, DummyWaveName)
	if (!WaveExists(w))	// maybe the trace was transformed and it has a new name now
		theGraphTrace = FindTransformTraceGivenWave(theGraph, DummyWave)
		if (strlen(theGraphTrace) == 0)
			DoAlert 0, "Can't track down the trace for the mirror axis."
			SetDatafolder $saveDF
			return -1
		endif
		MirrorWasTransformed = 1
	else
		MirrorWasTransformed = isTransformTrace(theGraph, theGraphTrace)
	endif
	if (MirrorWasTransformed)
		// if this is a transfrom trace, we have to kill off the transformed wave before we can kill the original mirror axis dummy wave
		// because the wave that is actually graphed has a dependency on the original dummy wave.
		Wave/Z w = TraceNameToWaveRef(theGraph, theGraphTrace)
		Wave/Z xw = XWaveRefFromTrace(theGraph, theGraphTrace)
		String wNote, xwNote
		if (WaveExists(w))
			wNote = Note(w)
		else
			wNote = ""
		endif
		if (WaveExists(xw))
			xwNote = Note(xw)
		else
			xwNote = ""
		endif
		// This takes care of all possible waves
		Wave ow1 = $StringByKey("OldWave", wNote, "=", ";")
		Wave ow2 = $StringByKey("OldWave", xwNote, "=", ";")
		Wave oyw1 = $StringByKey("OldYWave", wNote, "=", ";")
		Wave oyw2 = $StringByKey("OldYWave", xwNote, "=", ";")
	endif
	
	RemoveFromGraph/W=$theGraph/Z $theGraphTrace
	
	if (MirrorWasTransformed)
		KillWaves/Z w, xw
		KillWaves/Z ow1, ow2, oyw1, oyw2
	endif
	SetDatafolder ::
	KillDatafolder $theDataFolder
	theDataFolder = GetDatafolder(0)
	if (CountObjects(":", 4) == 0)		// no transformed axes or mirror axes left for this graph
		SetDatafolder ::
		KillDatafolder $theDataFolder
	endif

	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

Function ApplyAxisRecreation(theAxis, theGraph, theRecreationString)
	String theAxis, theGraph, theRecreationString
	
	Variable i=0
	String dstr= "("+theAxis+")"	// i.e., (left)
	String sitem,xstr

	do
		sitem= StringFromList(i, theRecreationString, ";")
		if( strlen(sitem) == 0 )
			break;
		endif
		xstr= "ModifyGraph /W="+theGraph+" "+StrSubstitute("(x)",sitem,dstr)
		Execute xstr
		i+=1
	while(1)
end

// rawRangeOfTransformFunction calculates the range of the axis for a given place on the axis as if the untransformed
// data had uniform spacing the same as the derivative at the chosen spot. This will be used as the basis for calculating
// the tick spacing for some region of the graph. A negative raw range indicates that the transform inverts- that is, small raw
// numbers become large transformed numbers. That is, numbers at the bottom of the axis transform to numbers at the top.

// This function must be called with the datafolder set to the datafolder for the graph and axis in question

// If isMirror is non-zero, the calculation is to be done for a mirror axis. The trace is drawn un-transformed, but ticks are
// spaced and labelled according to a transform function. This is the inverse of the transform axis problem.

Function rawRangeOfTransformFunction(atValue, delta, fraction, paramWave, highBracket, lowBracket, isMirror)
	Variable atValue
	Variable delta
	Variable fraction
	Wave paramWave
	Variable highBracket, lowBracket
	Variable isMirror

	SVAR axisTransformFunction = axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction

	Variable Value
	Variable ValuePlus
	Variable atValuePlus
	
	if (!isMirror)
		Variable fofhighbracket = axisFunc(paramWave, highBracket)
		Variable foflowbracket = axisFunc(paramWave, lowBracket)
		if (debugInfo)
			print/D "**rawRangeOfTransformFunction; fofhighbracket = ", fofhighbracket, "foflowbracket = ", foflowbracket
		endif
		
		if ( AlmostEqual(atValue, foflowbracket, 1e-9) )
			Value = lowBracket
		elseif  ( AlmostEqual(atValue, fofhighbracket, 1e-9) )
			Value = highBracket
		else
			if (debugInfo)
				print/D "\trawRangeOfTransformFunction; about to call FindRoots 1; atValue = ", atValue, "highBracket = ", highBracket, "lowBracket = ", lowBracket
			endif
			FindRoots/T=1e-14/B=0/Q/Z=(atValue)/H=(highBracket)/L=(lowBracket) axisFunc, paramWave
			if (V_flag)
				DoAlert 0, "FindRoots error while computing derivatives for transformed axis: "+num2str(V_flag)
				return NaN
			endif
			Value = V_root
		endif
	else
		Value = axisFunc(paramWave, atValue)
	endif
	
	atValuePlus = atValue+delta
	
	if (!isMirror)
		if (!isBetween(atValuePlus, fofhighbracket, foflowbracket))
			if (debugInfo)
				print "atValuePlus is not between brackets, first try"
			endif
			delta = -delta
			fraction = -fraction
			atValuePlus = atValue+delta
			if (!isBetween(atValuePlus, fofhighbracket, foflowbracket))
				if (debugInfo)
					print "atValuePlus is not between brackets, second try"
				endif
				DoAlert 0, "could not calculate derivative- delta is outside the axis range"
				return NaN
			endif
		endif
	
		if ( AlmostEqual(atValuePlus, foflowbracket, 1e-9) )
			ValuePlus = lowBracket
		elseif  ( AlmostEqual(atValuePlus, fofhighbracket, 1e-9) )
			ValuePlus = highBracket
		else
			if (debugInfo)
				print/D "\trawRangeOfTransformFunction; about to call FindRoots 2; atValue = ", atValue, "highBracket = ", highBracket, "lowBracket = ", lowBracket
			endif
			FindRoots/T=1e-14/B=0/Q/Z=(atValuePlus)/H=(highBracket)/L=(lowBracket) axisFunc, paramWave
			if (V_flag)
				DoAlert 0, "FindRoots error while computing derivatives for transformed axis: "+num2str(V_flag)
				return NaN
			endif
			ValuePlus = V_root
		endif
	else
		ValuePlus = axisFunc(paramWave, atValuePlus)
	endif

	return (ValuePlus-Value)/fraction
end

Function isHorizAxis(theGraph, theAxis)
	String theGraph
	String theAxis
	
	String aInfo = AxisInfo(theGraph, theAxis)
	String aType = StringByKey("AXTYPE", aInfo)
	Variable isXAxis = 0
	if ( (cmpstr(aType, "Top") == 0) %| (cmpstr(aType, "Bottom") == 0) )
		isXAxis = 1
	endif
	
	return isXAxis
end

Function isTransformAxis(theGraph, theAxis)
	String theGraph
	String theAxis
	
	String saveDF = GetDatafolder(1)
	Variable YesItIs = (SetGraphAndAxisDataFolder(theGraph, theAxis) == 0)
	SetDatafolder $saveDF
	return YesItIs
end

Function isTransformMirrorAxis(theGraph, theAxis)
	String theGraph
	String theAxis
	
	String saveDF = GetDatafolder(1)
	Variable YesItIs = (SetDataFolderForMirrorAxis(theGraph, theAxis) == 0)
	SetDatafolder $saveDF
	return YesItIs
end

Function/S getMirrorAxisName(theGraph, theAxis)
	String theGraph
	String theAxis

	if (isTransformMirrorAxis(theGraph, theAxis))
		String saveDF = GetDatafolder(1)
		SetDataFolderForMirrorAxis(theGraph, theAxis)
		SVAR MirrorAxis
		SetDatafolder $saveDF
		return MirrorAxis
	else
		return ""
	endif
end	

Function isTransformMirrorTrace(theGraph, theTrace)
	String theGraph
	String theTrace
	
	String saveDF = GetDatafolder(1)
	Wave w = TraceNameToWaveRef(theGraph, theTrace)
	String TraceDF = GetWavesDataFolder(w, 1)
	SetDatafolder $TraceDF
	SVAR/Z MainAxis
	SVAR/Z MirrorAxis
	SVAR/Z PerpendicularAxis
	SVAR/Z DummyWaveName
	Variable YesItIs
	if (SVAR_Exists(MainAxis) && SVAR_Exists(MirrorAxis) && SVAR_Exists(PerpendicularAxis) && SVAR_Exists(DummyWaveName))
		YesItIs = 1
	else
		YesItIs = 0
	endif
	
	SetDatafolder $saveDF
	return YesItIs
end

// Give it a trace name and it returns truth that it is a trace involved with a transformed axis
// It does this by looking for a wave note in the X or Y wave. If there is no note in either, it can't be a transform axis trace because
// such traces store information in a wave note.
// If there is a wave note, it looks for a string using a keyword search, using one of the transform trace keywords. If this fails in both wave notes,
// it can't be a transfrom trace.
Function isTransformTrace(theGraph, theTrace)
	String theGraph
	String theTrace
	
	String saveDF = GetDatafolder(1)
	Wave/Z w = TraceNameToWaveRef(theGraph, theTrace)
	Wave/Z xw = XWaveRefFromTrace(theGraph, theTrace)

	Variable YesItIs
	String wNote, xwNote
	if (WaveExists(w))
		wNote = Note(w)
	else
		wNote = ""
	endif
	if (WaveExists(xw))
		xwNote = Note(xw)
	else
		xwNote = ""
	endif
	if ( (strlen(wNote) == 0) && (strlen(xwNote) == 0) )
		YesItIs = 0
	else
		if ( (strsearch("oldWave=", wNote, 0) >= 0) || (strsearch("oldYWave=", wNote, 0) >= 0) )
			YesItIs = 1
		else
			if ( (strsearch("oldWave=", xwNote, 0) >= 0) || (strsearch("oldYWave=", xwNote, 0) >= 0) )
				YesItIs = 1
			else
				YesItIs = 0
			endif
		endif
	endif
	SetDatafolder $saveDF
	return YesItIs
end

Function/S AxisTraceList(theGraph, theAxis)
	String theGraph
	String theAxis
	
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	
	String traces = TraceNameList(theGraph, ";", 1)	// will need to add ContourNameList and ImageNameList
	String oneTrace = ""
	String outTraces = ""
	
	String tInfo
	String tAxis
	Variable i=0
	do
		oneTrace = StringFromList(i, traces)
		if (strlen(oneTrace) == 0)
			break
		endif
		tInfo = TraceInfo(theGraph, oneTrace, 0)
		if (isXAxis)
			tAxis = StringByKey("XAXIS", tInfo)
		else
			tAxis = StringByKey("YAXIS", tInfo)
		endif
		if (CmpStr(tAxis, theAxis) == 0)
			outTraces += oneTrace+";"
		endif
		i += 1
	while (1)

	return outTraces	
end

Function isNearlyBetween(theNum, a, b, precision)
	Variable theNum
	Variable a, b, precision
	
	if (AlmostEqual(theNum,a,precision))
		return 1
	endif
	if (AlmostEqual(theNum,b,precision))
		return 1
	endif
	if (a > b)
		return !(theNum > a || theNum < b)
	else
		return !(theNum < a || theNum > b)
	endif
end

Function AlmostEqual(num1, num2, precision)
	Variable num1, num2, precision
	
	if (num1 == num2)
		return 1
	endif
	Variable divisor = max(abs(num1), abs(num2))
	if (divisor == 0)
		divisor = precision		// not really the same, but what can you do?
	endif
	if (abs((num1-num2)/divisor) < precision)
		return 1
	else
		return 0
	endif
end

Function isBetween(theNum, a, b)
	Variable theNum, a, b
	
	if (a < b)
		return ( (theNum >= a) && (theNum <= b) )
	else
		return ( (theNum >= b) && (theNum <= a) )
	endif
end

Function/S defaultFontForAxis(theGraph, theAxis)
	String theGraph, theAxis
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return ""
	endif

	String aInfo = axisInfo(theGraph, theAxis)
	String theFont = StringByKey("font(x)", aInfo, "=", ";")
	if (CmpStr(theFont[0], "\"") == 0)
		Variable fontLength = strlen(theFont)
		theFont = theFont[1,fontLength-2]
	endif
	if (CmpStr(theFont, "default") == 0)
		return GetDefaultFont(theGraph)
	else
		return theFont
	endif
end

Function NewTransformAxisRange(theGraph, theAxis, minVal, maxVal)
	String theGraph, theAxis
	Variable minVal, maxVal
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	DoWindow/F $theGraph
	
	String saveDF = GetDatafolder(1)
	
	Variable setDatafolderError = SetGraphAndAxisDataFolder(theGraph, theAxis)
	if (setDatafolderError)
		ReportSetGraphAndAxisDFError(theGraph, theAxis, setDatafolderError, 1)
		SetDatafolder $saveDF
		return -1
	endif
	
	SVAR axisTransformFunction = axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction	
	
	GetAxis/Q $theAxis
	if (V_flag)
		SetDatafolder $saveDF
		DoAlert 0, "The axis "+theAxis+" is not used on "+theGraph
		return -1
	endif
	
	Wave dummyPWave = dummyPWave
	Variable transformedMin, transformedMax
	transformedMin = axisFunc(dummyPWave, minVal)
	transformedMax = axisFunc(dummyPWave, maxVal)
	if (numtype(transformedMin) != 0)
		SetDatafolder $saveDF
		DoAlert 0, "The axis range could not be set because the minimum value transforms to an undefined value."
		return -1
	endif
	if (numtype(transformedMax) != 0)
		SetDatafolder $saveDF
		DoAlert 0, "The axis range could not be set because the maximum value transforms to an undefined value."
		return -1
	endif
	SetAxis/W=$theGraph $theAxis, transformedMin, transformedMax
	DoUpdate
	Variable/G AxisMin = minVal
	Variable/G AxisMax = maxVal
	Variable/G DoAutoScale = 0
	
	SetDatafolder $saveDF
	return 0
end

// Sets the current data folder to the  graph and axis specified. Returns various values depending on circumstances.
// If theAxis is "", sets the current data folder to the appropriate folder for theGraph.
// If theAxis is not "", sets the current data folder the appropriate folder for theGraph, theAxis if possible.
// If theGraph is "", sets the current data folder to the appropriate folder for the top graph window.
// *** the calling function is responsible for saving and restoring the current data folder as appropriate!
// *** Even if the requested action can't be carried out successfully, the current data folder may change!
//
// return value:  0, success; 1, graph doesn't exist; 2 the graph has no transformed axes; 3 axis is not a transformed axis
Function SetGraphAndAxisDataFolder(theGraph, theAxis)
	String theGraph
	String theAxis
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return 1
	endif
	
	String theGraphFolder = folderForThisGraph(theGraph, 0)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		return 2
	endif
	SetDatafolder $theGraphFolder
	String theAxisFolder = findDatafolderForAxis(theAxis, 0)
	if ((strlen(theAxisFolder) == 0) || !DatafolderExists(theAxisFolder))
		return 3
	endif
	SetDatafolder $theAxisFolder
	return 0
end

Function ReportSetGraphAndAxisDFError(theGraph, theAxis, error, reportType)
	String theGraph
	String theAxis
	Variable error
	Variable reportType		// 0: print in history; 1: alert box; 2: abort
	
	String message
	
	if (error != 0)
		switch (error)
			case 1:
				message = "The graph "+theGraph+" does not exist."
				break
			case 2:
				message = "The graph "+theGraph+" contains no transformed axes."
				break
			case 3:
				message = "The axis "+theAxis+" is not a transformed axis."
				break
			default:
				message = "BUG: Error is not a valid SetGraphAndAxisDataFolder() error."
				break
		endswitch
		switch (reportType)
			case 0:
				print message
				return error
			case 1:
				DoAlert 0,message
				return error
			case 2:
				Abort message
				break		// nothing is required here, really...
		endswitch
	endif
end

// Just like SetGraphAndAxisDataFolder, but looks for a transform mirror axis instead of a transform axis
// Always save the current datafolder before calling this function. Even if it fails, it may leave 
// the current data folder set to the wrong datafolder, and doesn't restore the right one.
Function SetDataFolderForMirrorAxis(theGraph, theAxis)
	String theGraph
	String theAxis
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return 1
	endif
	
	String theGraphFolder = folderForThisGraph(theGraph, 1)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		return 2
	endif
	SetDatafolder $theGraphFolder
	String theAxisFolder = findDatafolderForAxis(theAxis, 1)
	if ((strlen(theAxisFolder) == 0) || !DatafolderExists(theAxisFolder))
		return 3
	endif
	SetDatafolder $theAxisFolder
	return 0
end

Function ReportSetMirrorDFError(theGraph, theAxis, error, reportType)
	String theGraph
	String theAxis
	Variable error
	Variable reportType		// 0: print in history; 1: alert box; 2: abort
	
	String message
	
	if (error != 0)
		switch (error)
			case 1:
				message = "The graph "+theGraph+" does not exist."
				break
			case 2:
				message = "The graph "+theGraph+" contains no transform mirror axes."
				break
			case 3:
				message = "The axis "+theAxis+" is not a transform mirror axis."
				break
			default:
				message = "BUG: Error is not a valid ReportSetMirrorDFError() error."
				break
		endswitch
		switch (reportType)
			case 0:
				print message
				return error
			case 1:
				DoAlert 0,message
				return error
			case 2:
				Abort message
				break		// nothing is required here, really...
		endswitch
	endif
end

//********************************
// Stuff for transformed mirror axes
//********************************

//*****************************
// This function does the actual work of creating transformed data waves and replacing the waves in the graph
//
// Things yet to deal with:
//		If axis has a hard-balled range, we have to transform that range
//		
//*****************************

Function/S GetAxisType(theGraph, theAxis)
	String theGraph
	String theAxis
	
	String aInfo = AxisInfo(theGraph, theAxis)
	String aType = StringByKey("AXTYPE", aInfo)
	return aType
end

Function/S GetPerpendicularAxis(theGraph, theAxis)
	String theGraph
	String theAxis

	String TraceList = AxisTraceList(theGraph, theAxis)
	String aTrace = StringFromList(0, TraceList)
	String tInfo = TraceInfo(theGraph, aTrace, 0)
	String perpAxisName
	if (isHorizAxis(theGraph, theAxis))
		perpAxisName = StringByKey("YAXIS", tInfo)
	else
		perpAxisName = StringByKey("XAXIS", tInfo)
	endif
	
	return perpAxisName
end
	
Function SetupTransformMirrorAxis(theGraph, theAxis, theFunc, FuncCoefWave, numTicks, wantMinor, minSep, TicksAtEnds)
	String theGraph
	String theAxis
	String theFunc
	Wave/Z FuncCoefWave
	Variable numTicks, wantMinor, minSep		// for call to TicksForTransformAxis
	Variable TicksAtEnds
	
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	String saveDF = GetDatafolder(1)
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc

	// Do some preliminary testing before making special datafolders, etc.
	GetAxis/W=$theGraph /Q $theAxis
	if (V_flag)
		DoAlert 0, "The axis "+theAxis+" doesn't exist on the graph "+theGraph+"."
		return -1
	endif
	if (WaveExists(FuncCoefWave))
		Duplicate/O/D FuncCoefWave, dummyPWave
	else
		Make/D/O/N=1 dummyPWave
	endif
	if (numtype(axisFunc(dummyPWave, V_min)) != 0)
		DoAlert 0, "The left or bottom end of the axis isn't within the range of the transformation function."
		return -1
	endif
	if (numtype(axisFunc(dummyPWave, V_max)) != 0)
		DoAlert 0, "The right or top end of the axis isn't within the range of the transformation function."
		return -1
	endif
	KillWaves/Z dummyPWave

	// Make the appropriate datafolder to hold waves and variables specific to this graph
	String graphFolderName = folderForThisGraph(theGraph, 1)
	if (strlen(graphFolderName) == 0)			// the graph doesn't have a folder yet
		graphFolderName = makeUniqueDFNameForGraph(theGraph, 1)
		NewDatafolder/O/S $("root:Packages:"+graphFolderName)
		String/G actualGraphName = theGraph
	else
		SetDatafolder $graphFolderName
	endif

	// Make the appropriate datafolder to hold waves and variables specific to this axis
	String folderName = findDatafolderForAxis(theAxis, 1)
	if (strlen(folderName) == 0)			// the axis doesn't have a folder yet
		folderName = makeUniqueDFNameForAxis(theAxis, 1)
		NewDatafolder/O/S $folderName
		// store away the axis name for later user (extracting it from the folder name is inconvenient, and if the axis name is long, it won't be complete)
		String/G ActualAxisName = theAxis
	else
		SetDatafolder $folderName
	endif
	
	String/G axisTransformFunction = theFunc
	if (WaveExists(FuncCoefWave))
		Duplicate/O/D FuncCoefWave, dummyPWave
	else
		Make/D/O/N=1 dummyPWave
	endif
	
	String AxisType = GetAxisType(theGraph, theAxis)
	String AppendFlag, MirrorAxisName = "MT_"+theAxis
	String PerpAxis = GetPerpendicularAxis(theGraph, theAxis)
	String PerpAxisType = GetAxisType(theGraph, PerpAxis)
	String DWaveName = "MTW_"+theAxis	
	Make/D/O/N=2 $DWaveName
	WAVE MirrorDummy = $DWaveName

		
	// Get the present range of the axis and the perpendicular axis
	GetAxis/W=$theGraph /Q $theAxis
	Variable AxisLeft = V_min
	Variable AxisRight = V_max
	GetAxis/W=$theGraph /Q $PerpAxis
	Variable PerpAxisLeft = V_min
	Variable PerpAxisRight = V_max
	
	strswitch (AxisType)
		case "top":
			AppendFlag = "/B="+MirrorAxisName
			SetScale/I x AxisLeft, AxisRight, MirrorDummy
			break
		case "bottom":
			AppendFlag = "/T="+MirrorAxisName
			SetScale/I x AxisLeft, AxisRight, MirrorDummy
			break
		case "left":
			AppendFlag = "/R="+MirrorAxisName
			MirrorDummy[0] = AxisLeft
			MirrorDummy[1] = AxisRight
			break
		case "right":
			AppendFlag = "/L="+MirrorAxisName
			MirrorDummy[0] = AxisLeft
			MirrorDummy[1] = AxisRight
			break
	endswitch
	
	strswitch (PerpAxisType)
		case "top":
			AppendFlag += "/T="+PerpAxis
			SetScale/I x PerpAxisLeft, PerpAxisRight, MirrorDummy
			break
		case "bottom":
			AppendFlag += "/B="+PerpAxis
			SetScale/I x PerpAxisLeft, PerpAxisRight, MirrorDummy
			break
		case "left":
			AppendFlag += "/L="+PerpAxis
			MirrorDummy[0] = PerpAxisLeft
			MirrorDummy[1] = PerpAxisRight
			break
		case "right":
			AppendFlag += "/R="+PerpAxis
			MirrorDummy[0] = PerpAxisLeft
			MirrorDummy[1] = PerpAxisRight
			break
	endswitch

	String AppendCommand = "AppendToGraph /W="+theGraph+AppendFlag+" "+DWaveName
	Execute AppendCommand
	ApplyAxisRecreation(MirrorAxisName, theGraph, GetAxisRecreation(theGraph, theAxis))	// make the mirror axis look like the other
	ModifyGraph freePos($MirrorAxisName)=0
	ModifyGraph lsize($DWaveName)=0

	String/G MainAxis = theAxis
	String/G MirrorAxis = MirrorAxisName
	String/G PerpendicularAxis = PerpAxis
	String/G DummyWaveName = DWaveName
	Variable/G doTicksAtEnds = TicksAtEnds

	if (TicksForTransformAxis(theGraph, theAxis, numTicks, wantMinor, minSep, MirrorAxisName, TicksAtEnds) < 0)		// it failed
		UndoTransformMirror(theGraph, theAxis)
	endif
	SetWindow $theGraph, hook=TransformAxisWindowHook
	
	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

//********************************
// Stuff for control panels
//********************************

Function DoTransformAxisPanel(ModifyIt)
	Variable ModifyIt
	
	switch (ModifyIt)
		case 0:
			if (WinType("NewTransformAxisPanel") == 7)
				DoWindow/F NewTransformAxisPanel
			else
				TransformAxisPanelInitGlobals()
				fNewTransformAxisPanel()
			endif
			break
		case 1:
			if (WinType("ModTransformAxisPanel") == 7)
				DoWindow/F ModTransformAxisPanel
			else
				TransformAxisPanelInitGlobals()
				fModTransformAxisPanel()
			endif
			break
		case 2:
			if (WinType("UndoTransformAxisPanel") == 7)
				DoWindow/F UndoTransformAxisPanel
			else
				TransformAxisPanelInitGlobals()
				fUndoTransformAxisPanel()
			endif
			break
	endswitch
end

//********************************
// Common control panel routines
//********************************


Function TransformAxisPanelInitGlobals()
	String saveDF = GetDatafolder(1)
	NewDatafolder/O/S root:Packages
	NewDatafolder/O/S TransformAxis
	
	Variable/G rescaleMin
	Variable/G rescaleMax
	
	NVAR/Z tickDensity
	if (!NVAR_Exists(tickDensity))
		Variable/G tickDensity = 3
	endif
	NVAR/Z tickSep
	if (!NVAR_Exists(tickSep))
		Variable/G tickSep = 5
	endif
	
	NVAR/Z LastTabUsed = LastTabUsed
	if (!NVAR_Exists(LastTabUsed))
		Variable/G LastTabUsed = 0		// the Modify Transform Axis will show this tab when it is displayed
	endif
	String/G TargetName = "Target: "+WinName(0,1)
	
	SetDatafolder $saveDF
end

Function/S makeTargetName()
	return 	makeTargetNamePreamble()+WinName(0,1)
end

Function/S makeTargetNamePreamble()
	return "Target: \\K(1,16019,65535)\f01"
end

Function TransformAxisPanelHookFunction(infoStr)
	String infoStr

	String theWindow = StringByKey("WINDOW", infoStr)
	GetWindow $theWindow, note
	String WindowNote = S_value

	Variable ModifyingTransformAxis = CmpStr(theWindow, "ModTransformAxisPanel")==0
	Variable UndoingTransformAxis = CmpStr(theWindow, "UndoTransformAxisPanel")==0
	Variable DoingMirrorAxis = 0
	
	String theGraph = WinName(0,1)
	String theAxis
	Variable theAxisSelectionNum
	String oldGraph = StringByKey("GRAPH", WindowNote)
	String oldAxis = StringByKey("AXIS", WindowNote)
	String oldAxisType = StringByKey("AXISTYPE", WindowNote)
	
	String CurrentAxisList = ListAllTransformAxes(theGraph)
	Variable GraphHasChanged = 1
	Variable AxisHasChanged = 1
	Variable AxisTypeHasChanged = 1
	Variable AxisPositionInList = 1
	
	String EventType = StringByKey("EVENT", infoStr)
	if (WC_WindowCoordinatesHook(infoStr))
		return 1
	endif

	if (CmpStr(EventType, "activate") == 0)
		if (CmpStr(theGraph, oldGraph) == 0)		// it's the same graph as before
			GraphHasChanged = 0
			AxisPositionInList = WhichListItem(oldAxis, CurrentAxisList)
			if (AxisPositionInList < 0)
				AxisHasChanged = 1
				PopupMenu TransformAxisAxisMenu,mode=1
				AxisTypeHasChanged = 1
			else
				theAxis = oldAxis
				AxisHasChanged = 0
				PopupMenu TransformAxisAxisMenu, mode=AxisPositionInList+1
				if ( (CmpStr(oldAxisType, "Mirror") == 0) && (IsTransformMirrorAxis(theGraph, oldAxis)) )
					AxisTypeHasChanged = 0
				elseif ( (CmpStr(oldAxisType, "Transform") == 0) && (IsTransformAxis(theGraph, oldAxis)) )
					AxisTypeHasChanged = 0
				endif
			endif
		else
			PopupMenu TransformAxisAxisMenu, mode=1
		endif
		
		if ( (GraphHasChanged + AxisHasChanged + AxisTypeHasChanged) == 0)
			return 0
		endif
		
		ControlUpdate /W=$theWindow TransformAxisAxisMenu
		ControlInfo TransformAxisAxisMenu
		theAxis = S_Value
		theAxisSelectionNum = V_value
		
		if (GraphHasChanged)
			SVAR TargetName = root:Packages:TransformAxis:TargetName
			TargetName = makeTargetName()
			if (ModifyingTransformAxis || UndoingTransformAxis)
				if (CmpStr(CurrentAxisList, "None Available") == 0)
					TargetName += "\f]0  \\K(65535,0,0)Has no transformed axes"
				endif
			endif
		endif
		if ( ModifyingTransformAxis && (AxisHasChanged || AxisTypeHasChanged) )
			NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
			if (!NVAR_Exists(LastTabUsed))
				Variable/G LastTabUsed = 0
			elseif (IsTransformMirrorAxis(theGraph, theAxis))
				LastTabUsed = 0
			endif
			ModTransformAxisMenuProc("", theAxisSelectionNum, theAxis)
		endif
		
		return 1
	elseif (CmpStr(EventType, "deactivate") == 0)
		ControlInfo/W=$theWindow TransformAxisAxisMenu
		theAxis = S_value
		SetWindow $theWindow note = MakeModPanelNote(theGraph, theAxis)		
	endif	// activate event

	return 0
end

Function/S ListAllTransformAxes(theGraph)
	String theGraph

	String theList = ListTransformAxes(theGraph)
	theList += ListTransformMirrorAxes(theGraph)
	if (strlen(theList) == 0)
		theList = "None Available"
	endif

	return theList
end

Function/S ListTransformAxes(theGraph)
	String theGraph
	
	String saveDF = GetDatafolder(1)
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return "No Graphs!"
	endif
	
	String theGraphFolder = folderForThisGraph(theGraph, 0)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		return ""
	endif
	SetDatafolder $theGraphFolder
	Variable nDataFolders = CountObjects("", 4 )
	if (nDataFolders <= 0)
		SetDatafolder $saveDF
		return ""
	endif
	Variable i
	String aFolderName
	String theList = ""
	String dummy
	for (i = 0; i < nDataFolders; i += 1)
		aFolderName = GetIndexedObjName("",4,i )
		dummy = ":"+PossiblyQuoteName(aFolderName)+":ActualAxisName"
		SVAR/Z ActualAxisName = $dummy
		if (SVAR_Exists(ActualAxisName))
			theList += ActualAxisName+";"
		endif
	endfor
	
	if (strlen(theList) == 0)
		theList = "None Available"
	endif
	SetDatafolder $saveDF
	return theList
end

Function/S ListTransformMirrorAxes(theGraph)
	String theGraph
	
	String saveDF = GetDatafolder(1)
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return "No Graph!"
	endif
	
	String theGraphFolder = folderForThisGraph(theGraph, 1)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		return ""
	endif
	SetDatafolder $theGraphFolder
	Variable nDataFolders = CountObjects("", 4 )
	if (nDataFolders <= 0)
		SetDatafolder $saveDF
		return ""
	endif
	Variable i
	String aFolderName
	String theList = ""
	String dummy
	for (i = 0; i < nDataFolders; i += 1)
		aFolderName = GetIndexedObjName("",4,i )
		dummy = ":"+PossiblyQuoteName(aFolderName)+":MainAxis"
		SVAR ActualAxisName = $dummy
		theList += ActualAxisName+";"
	endfor
	
	if (strlen(theList) == 0)
		theList = "None Available"
	endif
	SetDatafolder $saveDF
	return theList
end

Function/S ListTransformFunctions()

	String theList = FunctionList("*", ";", "NPARAMS:2,VALTYPE:1,KIND:6")
	String outList=""
	String aFuncName
	Variable nameEnd
	
	Variable i
	for (i = 0; i < ItemsInList(theList); i += 1)
		aFuncName = StringFromList(i, theList)
		if (CmpStr(aFuncName[0,7], "TransAx_") == 0)
			nameEnd = strlen(aFuncName)-1
			outList += aFuncName[8,nameEnd]+";"
		endif
	endfor
	
	return outList
end

//********************************
// New Transform Axis panel
//********************************

Function fNewTransformAxisPanel()

	String SaveDF = GetDatafolder(1)
	SetDatafolder root:Packages:TransformAxis
	
	// initialize defaults
	Variable/G tickDensity = 3
	Variable/G tickSep = 5

	String/G TargetName
	TargetName = makeTargetName()

	String fmt="NewPanel/K=1/W=(%s) as \"New Transform Axis\""
	Variable usePixels= PanelResolution("") == 72 ? 1 : 0
	Execute WC_WindowCoordinatesSprintf("NewTransformAxisPanel",fmt,44,60,508,331,usePixels)

//	NewPanel /K=1 /W=(44,60,508,331) as "New Transform Axis"
	DoWindow/C NewTransformAxisPanel
	ModifyPanel fixedSize = 1
	
	TitleBox TransformAxisTargetTitle, pos={10,7}, size={41,20}, variable=root:Packages:TransformAxis:TargetName, frame=1
	
	PopupMenu TransformAxisAxisMenu,pos={28,62},size={180,20},title="Axis:"
	PopupMenu TransformAxisAxisMenu,font="Geneva"
	PopupMenu TransformAxisAxisMenu,mode=1,bodyWidth= 140
	PopupMenu TransformAxisAxisMenu,value= #"ListPlainAxes(WinName(0,1))"

	PopupMenu TransformFunctionMenu,pos={7,37},size={201,20},title="Function:"
	PopupMenu TransformFunctionMenu,font="Geneva"
	PopupMenu TransformFunctionMenu,mode=1,bodyWidth= 140,value= #"ListTransformFunctions()"
		
	PopupMenu TransformFuncCoefWaveMenu,pos={215,37},size={240,20},title="Coefficient Wave:"
	PopupMenu TransformFuncCoefWaveMenu,font="Geneva"
	PopupMenu TransformFuncCoefWaveMenu,mode=1,bodyWidth= 140,value= #"\"_None_;\"+WaveList(\"*\", \";\", \"DIMS:1\")"
		
	CheckBox TransformAxisMirrorCheck,pos={155,96},size={157,15},title="Make it a Mirror Axis"
	CheckBox TransformAxisMirrorCheck,font="Chicago",fSize=12,value= 0

	SetVariable SetTickDensity,pos={274,143},size={115,15},title="Tick Density"
	SetVariable SetTickDensity,font="Geneva"
	SetVariable SetTickDensity,limits={0,50,1},value= root:Packages:TransformAxis:tickDensity,bodyWidth= 50

	CheckBox TransformAxisMinorTicksCheck,pos={76,143},size={77,14},title="Minor Ticks"
	CheckBox TransformAxisMinorTicksCheck,font="Geneva"
	CheckBox TransformAxisMinorTicksCheck,value=0

	CheckBox TicksAtEndsCheckbox,pos={76,169},size={114,14},title="Major Ticks at Ends"
	CheckBox TicksAtEndsCheckbox,font="Geneva"
	CheckBox TicksAtEndsCheckbox,value= 0

	SetVariable SetTickSep,pos={226,169},size={163,15},title="Minor Tick Separation"
	SetVariable SetTickSep,font="Geneva"
	SetVariable SetTickSep,limits={0,50,1},value= root:Packages:TransformAxis:tickSep,bodyWidth= 50

	Button TransformAxisDoItButton,pos={41,239},size={60,20},proc=NewTAxisDoItButtonProc,title="Do It"

	Button TransformCancelButton,size={60,20},proc=NewTAxisCancelButtonProc,title="Cancel"
	Button TransformCancelButton,pos={367,238}

	Button TransformHelpButton,pos={199,237},size={70,20},proc=TransAxNewHelpButtonProc,title="Help"

	Variable/G root:Packages:TransformAxis:ModifyingTransformAxis=0
	
	SetWindow NewTransformAxisPanel,note="GRAPH:"+WinName(0,1)
	SetWindow NewTransformAxisPanel,hook=TransformAxisPanelHookFunction
	
	SetDatafolder $SaveDF
end

Function TransAxNewHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Converting a Standard Axis Into a Transform Axis]"
	Button TransformHelpButton,title = "Help"
End

Function NewTAxisDoItButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String saveDF = GetDatafolder(1)
	
	ControlInfo TransformAxisAxisMenu
	String theAxis = S_value
	String theGraph = WinName(0, 1)

	if (CmpStr(theAxis, "None Available") == 0)
		SetDatafolder $saveDF
		return 0
	endif
	
	ControlInfo TransformFunctionMenu
	String theFunc = "TransAx_"+S_value

	ControlInfo TransformFuncCoefWaveMenu
	Wave/Z coefWave = $S_value
	
	ControlInfo SetTickDensity
	Variable tickDensity = V_value
	
	ControlInfo SetTickSep
	Variable tickSep = V_value
	
	ControlInfo TransformAxisMinorTicksCheck
	Variable doMinorTicks = V_value
	
	ControlInfo TicksAtEndsCheckbox
	Variable TicksAtEnds = V_value
	
	ControlInfo TransformAxisMirrorCheck
	if (V_value)
		SetupTransformMirrorAxis(theGraph, theAxis, theFunc, coefWave, tickDensity, doMinorTicks, tickSep, TicksAtEnds)
	else
		SetupTransformTraces(theGraph, theAxis, theFunc, coefWave, tickDensity, doMinorTicks, tickSep, TicksAtEnds)
	endif
	
	DoWindow/K NewTransformAxisPanel
	SetDatafolder $saveDF
end

Function NewTAxisCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DoWindow/K NewTransformAxisPanel
end

Function/S ListPlainAxes(theGraph)
	String theGraph
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0, 1)
	endif
	if (WinType(theGraph) != 1)
		return ""
	endif
	String oneAxis
	String allAxes = AxisList(theGraph)
	String theList = ""
	Variable i = 0
	do
		oneAxis = StringFromList(i, allAxes)
		if (strlen(oneAxis) == 0)
			break
		endif
		if (isTransformMirrorAxis(theGraph, oneAxis))
			String saveDF = GetDatafolder(1)
			if (SetDataFolderForMirrorAxis(theGraph, oneAxis) == 0)
				SVAR MirrorAxis
				allAxes = RemoveFromList(MirrorAxis, allAxes)		// this should work because the mirror axis will be listed after the main axis because it is created after
				SetDatafolder $saveDF
			endif
		endif
		if (!isTransformAxis(theGraph, oneAxis) && !isTransformMirrorAxis(theGraph, oneAxis))
			theList += oneAxis+";"
		endif
		i += 1
	while (1)
	
	if (strlen(theList) == 0)
		theList = "None Available"
	endif
	return theList
end

//********************************
// Modify Transform Axis Panel
//********************************

Function fModTransformAxisPanel()

	SVAR TargetName = root:Packages:TransformAxis:TargetName
	TargetName = makeTargetName()

	Variable hasTransformAxes = strlen(ListTransformAxes(WinName(0,1))) > 0
	Variable hasTransformMirrorAxes = strlen(ListTransformMirrorAxes(WinName(0,1))) > 0
	
	String fmt="NewPanel/K=1/W=(%s) as \"Modify Transform Axis\""
	Variable usePixels= PanelResolution("") == 72 ? 1 : 0
	Execute WC_WindowCoordinatesSprintf("ModTransformAxisPanel",fmt,44,60,508,331,usePixels)

//	NewPanel /K=1 /W=(44,60,508,331) as "Modify Transform Axis"
	DoWindow/C ModTransformAxisPanel
	ModifyPanel fixedSize = 1
	
	TitleBox TransformAxisTargetTitle, pos={10,7}, size={41,20}, variable=root:Packages:TransformAxis:TargetName, frame=1
	
	PopupMenu TransformAxisAxisMenu,pos={43,46},size={180,20},title="Axis:"
	PopupMenu TransformAxisAxisMenu,font="Geneva"
	PopupMenu TransformAxisAxisMenu,mode=1,bodyWidth= 140
	PopupMenu TransformAxisAxisMenu,proc=ModTransformAxisMenuProc
	PopupMenu TransformAxisAxisMenu,value= #"ListAllTransformAxes(WinName(0,1))"

	SetVariable SetTickDensity,pos={274,143},size={115,15},title="Tick Density"
	SetVariable SetTickDensity,font="Geneva"
	SetVariable SetTickDensity,limits={0,50,1},value= root:Packages:TransformAxis:tickDensity,bodyWidth= 50

	CheckBox TransformAxisMinorTicksCheck,pos={76,143},size={77,14},title="Minor Ticks"
	CheckBox TransformAxisMinorTicksCheck,font="Geneva"
	CheckBox TransformAxisMinorTicksCheck, value = 0

	CheckBox TicksAtEndsCheckbox,pos={76,169},size={114,14},title="Major Ticks at Ends"
	CheckBox TicksAtEndsCheckbox,value= 0

	SetVariable SetTickSep,pos={226,169},size={163,15},title="Minor Tick Separation"
	SetVariable SetTickSep,font="Geneva"
	SetVariable SetTickSep,limits={0,50,1},value= root:Packages:TransformAxis:tickSep,bodyWidth= 50

	Button TransformAxisDoItButton,pos={41,247},size={60,20},proc=ModTransformAxisApplyButtonProc,title="Apply"

	Button TransformCancelButton,pos={367,247},size={60,20},proc=ModTAxisCancelButtonProc,title="Done"

	Button TransformHelpButton,pos={199,247},size={70,20},proc=TransAxModifyHelpButtonProc,title="Help"

	NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
	TabControl ModTransformAxisTab,pos={25,80},size={419,153},proc=TransformAxisPanelTabProc
	TabControl ModTransformAxisTab,font="Geneva",fSize=10,tabLabel(0)="Options"
	TabControl ModTransformAxisTab,tabLabel(1)="Range",value=LastTabUsed
	
	CheckBox TransformAxisManualScale,pos={57,138},size={84,14},title="Manual Scale:"
	CheckBox TransformAxisManualScale,font="Geneva",fSize=10,value= 0,mode=1, proc=TransformRangeCheckBoxProc
	
	CheckBox TransformAxisAutoScale,pos={57,114},size={67,14},title="Auto Scale"
	CheckBox TransformAxisAutoScale,font="Geneva",fSize=10,value= 1,mode=1, proc=TransformRangeCheckBoxProc
	
	SetVariable transformRangeSetMin,pos={98,164},size={154,15},title="Minimum:"
	SetVariable transformRangeSetMin,font="Geneva"
	SetVariable transformRangeSetMin,limits={-Inf,Inf,1},value= root:Packages:TransformAxis:rescaleMin,bodyWidth= 100
	
	SetVariable transformRangeSetMax,pos={97,185},size={155,15},title="Maximum:"
	SetVariable transformRangeSetMax,font="Geneva"
	SetVariable transformRangeSetMax,limits={-Inf,Inf,1},value= root:Packages:TransformAxis:rescaleMax,bodyWidth= 100
	
	ControlInfo TransformAxisAxisMenu
	String selectedAxis = S_value
	if (IsTransformAxis(WinName(0,1), selectedAxis))
		TransformPresetRangeControls(WinName(0,1), selectedAxis)
		TransformAxisPanelTabProc("", 0)
		TabControl ModTransformAxisTab,disable = 0
	elseif (IsTransformMirrorAxis(WinName(0,1), selectedAxis))
		TransformAxisPanelTabProc("", LastTabUsed)
		TabControl ModTransformAxisTab,disable = 2
	endif
	TransformPresetAxisOptions(WinName(0,1), selectedAxis)
	
	SetWindow ModTransformAxisPanel, note=MakeModPanelNote(WinName(0,1), selectedAxis)
	SetWindow ModTransformAxisPanel,hook=TransformAxisPanelHookFunction
EndMacro

Function/S MakeModPanelNote(theGraph, theAxis)
	String theGraph, theAxis
	
	String WNote = "GRAPH:"+theGraph+";"
	WNote += "AXIS:"+theAxis+";"
	WNote += "AXISTYPE:"
	if  (IsTransformMirrorAxis(theGraph, theAxis))
		WNote += "Mirror"+";"
	else
		WNote += "Transform"+";"
	endif

	return WNote
end

Function TransAxModifyHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Changing Transform Axis Options]"
	Button TransformHelpButton,title = "Help"
End

Function ModTAxisCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K ModTransformAxisPanel
end

Function ModTransformAxisApplyButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo TransformAxisAxisMenu
	String theAxis = S_value
	String theGraph = WinName(0, 1)
	Variable error
	Variable isMirror = isTransformMirrorAxis(theGraph, theAxis)
	
	Variable oldAxisMin, oldAxisMax, oldIsAutoScale
	
	if (CmpStr(theAxis, "None Available") == 0)
		return 0
	endif
	
	String saveDF = GetDataFolder(1)
	if (isMirror)
		if (SetDataFolderForMirrorAxis(theGraph, theAxis))
			SetDatafolder $saveDF
			DoAlert 0, "BUG: could not set the datafolder for the axis."
			return -1
		endif
	else
		if (SetGraphAndAxisDataFolder(theGraph, theAxis))
			SetDatafolder $saveDF
			DoAlert 0, "BUG: could not set the datafolder for the axis."
			return -1
		endif
	endif

	Variable TicksAtEnds
	ControlInfo/W=ModTransformAxisPanel TicksAtEndsCheckbox
	TicksAtEnds = V_value

	Variable doMinorTicks
	ControlInfo/W=ModTransformAxisPanel TransformAxisMinorTicksCheck
	doMinorTicks = V_value

	Variable tickDensity
	ControlInfo/W=ModTransformAxisPanel SetTickDensity
	tickDensity = V_value

	Variable tickSep
	ControlInfo/W=ModTransformAxisPanel SetTickSep
	tickSep = V_value

	Variable rescaleMin
	ControlInfo/W=ModTransformAxisPanel transformRangeSetMin
	rescaleMin = V_value

	Variable rescaleMax
	ControlInfo/W=ModTransformAxisPanel transformRangeSetMax
	rescaleMax = V_value


	if (!isMirror)
		NVAR/Z DoAutoScale
		if (!NVAR_Exists(DoAutoScale))
			Variable/G DoAutoScale
		endif
		NVAR/Z AxisMin
		NVAR/Z AxisMax

		oldIsAutoScale = DoAutoScale
		oldAxisMin = AxisMin
		oldAxisMax = AxisMax
		DoAutoScale = 0
		ControlInfo TransformAxisAutoScale
		if (V_value)
			SetAxis/W=$theGraph/A $theAxis
			DoUpdate
			DoAutoScale = 1
		else
			if (NewTransformAxisRange(theGraph, theAxis, rescaleMin, rescaleMax) == -1)		// -1 = failed
				if (oldIsAutoScale)
					SetAxis/W=$theGraph/A $theAxis
					DoUpdate
					TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, "", TicksAtEnds)
				elseif (!oldIsAutoScale)
					NewTransformAxisRange(theGraph, theAxis, oldAxisMin, oldAxisMax)
					TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, "", TicksAtEnds)
				endif
			endif
		endif
	endif
	String MName = getMirrorAxisName(theGraph, theAxis)
	if (TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, MName, TicksAtEnds) < 0)		// getMirrorAxisName returns "" if the axis does not have a transform mirror axis
		DoAlert 0, "Ticking failed for modified axis options."
		if (oldIsAutoScale && !DoAutoScale)
			SetAxis/W=$theGraph/A $theAxis
			DoUpdate
			TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, MName, TicksAtEnds)
		elseif (!oldIsAutoScale)
			NewTransformAxisRange(theGraph, theAxis, oldAxisMin, oldAxisMax)
			TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, MName, TicksAtEnds)
		endif
	endif
	SetDatafolder $saveDF
End

Function ModTransformAxisMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
	
	Variable theTab = LastTabUsed
	TransformPresetAxisOptions(WinName(0,1), popStr)
	if (IsTransformAxis(WinName(0,1), popStr))	// Transform axes are shown in menu, so range controls are appropriate
		TransformPresetRangeControls(WinName(0,1), popStr)
		TransformAxisPanelTabProc("", theTab)
		TabControl ModTransformAxisTab,disable = 0, value = theTab
	elseif (IsTransformMirrorAxis(WinName(0,1), popStr))
		TransformAxisPanelTabProc("", 0)
		TabControl ModTransformAxisTab,disable = 2, value = 0
	endif
	String panelNote =  MakeModPanelNote(WinName(0,1), popStr)
	SetWindow $(WinName(0,64)) note=panelNote
end

Function TransformAxisPanelTabProc(name, tab)
	String name
	Variable tab

	SetVariable SetTickDensity, disable= (tab!=0)
	CheckBox TransformAxisMinorTicksCheck, disable= (tab!=0)
	SetVariable SetTickSep, disable= (tab!=0)
	CheckBox TicksAtEndsCheckbox, disable= (tab!=0)
	
	CheckBox TransformAxisManualScale, disable= (tab!=1)
	CheckBox TransformAxisAutoScale, disable= (tab!=1)
	SetVariable transformRangeSetMin, disable= (tab!=1)
	SetVariable transformRangeSetMax, disable= (tab!=1)
	
	NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
	LastTabUsed = tab
end

Function TransformPresetRangeControls(theGraph, theAxis)
	String theGraph, theAxis
	
	String saveDF = GetDatafolder(1)
	
	SetDataFolder root:Packages:TransformAxis
	NVAR rescaleMin
	NVAR rescaleMax

	if (SetGraphAndAxisDataFolder(theGraph, theAxis))
		SetDatafolder $saveDF
		return 0
	endif
	
	NVAR/Z AxisMin
	NVAR/Z AxisMax
	NVAR/Z DoAutoScale

	Variable rawdataMin, rawdataMax
	AxisDataMinMax(theGraph, theAxis, rawdataMin, rawdataMax)
	if (!NVAR_Exists(AxisMin) || DoAutoScale)
		rescaleMin = rawdataMin
	else
		rescaleMin = AxisMin
	endif
	if (!NVAR_Exists(AxisMin) || DoAutoScale)
		rescaleMax = rawdataMax
	else
		rescaleMax = AxisMax
	endif

	String info=AxisInfo(theGraph, theAxis)
	String SetAxisFlags = StringByKey("SETAXISFLAGS", info)
	if (StrSearch(SetAxisFlags, "/A", 0) >= 0)		// auto-scaled
		TransformRangeCheckBoxProc("TransformAxisAutoScale",1)
	else
		TransformRangeCheckBoxProc("TransformAxisManualScale",1)
	endif
	
	SetDatafolder $saveDF
end	

Function TransformPresetAxisOptions(theGraph, theAxis)
	String theGraph, theAxis
	
	String saveDF = GetDatafolder(1)
	
	SetDataFolder root:Packages:TransformAxis
	NVAR tickSep
	NVAR tickDensity

	if (isTransformMirrorAxis(theGraph, theAxis))
		if (SetDataFolderForMirrorAxis(theGraph, theAxis))
			SetDatafolder $saveDF
			return 0
		endif
	else
		if (SetGraphAndAxisDataFolder(theGraph, theAxis))
			SetDatafolder $saveDF
			return 0
		endif
	endif
	
	NVAR nticks
	NVAR doMinor
	NVAR minTickSep
	NVAR doTicksAtEnds
	
	CheckBox TransformAxisMinorTicksCheck, value = doMinor
	CheckBox TicksAtEndsCheckbox, value = doTicksAtEnds
	tickDensity = nticks
	tickSep = minTickSep
	
	SetDatafolder $saveDF
end	

Function TransformRangeCheckBoxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if checked, 0 if not

	Variable isAuto = (CmpStr(ctrlName, "TransformAxisAutoScale") == 0)
	
	CheckBox TransformAxisManualScale,value=(isAuto == 0)
	CheckBox TransformAxisAutoScale,value=isAuto
	
	SetVariable transformRangeSetMin, disable= (isAuto == 0 ? 0 : 2), frame = (isAuto ? 0 : 1)
	SetVariable transformRangeSetMax, disable= (isAuto == 0 ? 0 : 2), frame = (isAuto ? 0 : 1)
End

//********************************
// Untransform Axis Panel
//********************************

Function fUndoTransformAxisPanel()

	String SaveDF = GetDatafolder(1)
	SetDatafolder root:Packages:TransformAxis

	Variable hasTransformAxes = strlen(ListTransformAxes(WinName(0,1))) > 0
	Variable hasTransformMirrorAxes = strlen(ListTransformMirrorAxes(WinName(0,1))) > 0

	Variable usePixels= PanelResolution("") == 72 ? 1 : 0
	String fmt="NewPanel/K=1/W=(%s) as \"Undo Transform Axis\""
	Execute WC_WindowCoordinatesSprintf("UndoTransformAxisPanel",fmt,44,60,451,189,usePixels)

//	NewPanel /K=1 /W=(44,60,451,189) as "Undo Transform Axis"
	DoWindow/C UndoTransformAxisPanel
	ModifyPanel fixedSize = 1

	TitleBox TransformAxisTargetTitle, pos={10,7}, size={41,20}, variable=root:Packages:TransformAxis:TargetName, frame=1
	
	PopupMenu TransformAxisAxisMenu,pos={43,52},size={180,20},title="Axis:"
	PopupMenu TransformAxisAxisMenu,font="Geneva"
	PopupMenu TransformAxisAxisMenu,mode=1,bodyWidth= 140
	PopupMenu TransformAxisAxisMenu,value= #"ListAllTransformAxes(WinName(0,1))"

	Button TransformUndoItButton,size={60,20},proc=TransformAxisUndoItButtonProc,title="Undo It"
	Button TransformUndoItButton,pos={79,96}

	Button TransformCancelButton,size={60,20},proc=UnTransformAxisCancelButtonProc,title="Close"
	Button TransformCancelButton,pos={274,96}

	Button TransformHelpButton,pos={170,96},size={70,20},proc=TransAxUntransHelpButtonProc,title="Help"

	ControlInfo TransformAxisAxisMenu
	SetWindow UndoTransformAxisPanel, note=MakeModPanelNote(WinName(0,1), S_value)
	SetWindow UndoTransformAxisPanel, hook=TransformAxisPanelHookFunction

	SetDatafolder $SaveDF
end

Function TransAxUntransHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Untransforming a Transform Axis]"
	Button TransformHelpButton,title = "Help"
End

Function TransformAxisUndoItButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=UndoTransformAxisPanel TransformAxisAxisMenu
	String theAxis = S_value
	if (CmpStr(theAxis, "None Available") == 0)
		return 0
	endif

	if (IsTransformAxis(WinName(0,1), theAxis))						// transformed axes selected
		UndoTransformTraces(WinName(0,1), theAxis)
	elseif (isTransformMirrorAxis	(WinName(0,1), theAxis))		// mirror transform axes selected
		UndoTransformMirror(WinName(0,1), theAxis)
	else
		DoAlert 0, "BUG: TransformAxisUndoItButtonProc called for an axis that isn't a transformed axis."
	endif
	PopupMenu TransformAxisAxisMenu, mode = 1
	ControlUpdate/W=UndoTransformAxisPanel TransformAxisAxisMenu
End

Function UnTransformAxisCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K UndoTransformAxisPanel
end

//********************************
// Edit Transform Ticks Panel
//********************************

// this is called by the Edit Ticks menu item
Function TransformEditTicksShowPanel()
	if (WinType("EditTransformTicksPanel") != 7)
		// panel doesn't exist yet
		TransformEditTicks(1)
	else
		// panel already exists. This will cause an activate event which will run the panel's window hook, which will
		// check that the top graph is still the same
		DoWindow/F EditTransformTicksPanel
	endif
end

// Sets up data, etc. for the Edit Transform Ticks panel
Function TransformEditTicks(buildPanel)
	Variable buildPanel		// 0- need to actually make the panel. 1- just re-build the data structures because the selected axis or the top graph changed

	String saveDF = GetDatafolder(1)
	String theGraph = WinName(0,1)
	String/G root:Packages:TransformAxis:EditTicksTargetName
	SVAR EditTicksTargetName = root:Packages:TransformAxis:EditTicksTargetName
	EditTicksTargetName = makeTargetName();
	Variable MirrorSelected
	Variable err
	
	if (buildPanel)
		fEditTransformTicks()			// builds control panel with list box hidden
	else
		DoWindow/F EditTransformTicksPanel
	endif
	
	ControlUpdate transformAxisMenu
	ControlInfo transformAxisMenu
	String theAxis = S_value
	MirrorSelected = isTransformMirrorAxis(theGraph, theAxis)
	if (MirrorSelected)
		err = SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			ReportSetMirrorDFError(theGraph, theAxis, err, 1)		// alert on error
			theAxis = "None Available"
		endif
	else
		err = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			ReportSetGraphAndAxisDFError(theGraph, theAxis, err, 1)		// alert on error
			theAxis = "None Available"
		endif
	endif
	
	SetWindow EditTransformTicksPanel, note=MakeModPanelNote(theGraph, theAxis)
	SetWindow EditTransformTicksPanel, hook=EditTicksPanelHookFunction
	
	if (CmpStr("None Available", theAxis) == 0)
		SetDatafolder $saveDF
		return 0
	endif
	
	Wave tickVals
	Wave/T tickLabels
	SVAR axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
	Wave dummyPWave
	
	Variable i
	
	Variable numTicks = DimSize(tickVals, 0)
	Make/O/T/N=(numTicks, 3) listboxWave
	Make/D/O/N=(numTicks, 3) listboxSelectionWave
	
	if (MirrorSelected)
		for (i = 0; i < numTicks; i += 1)
			listboxWave[i][0] =  num2str(axisFunc(dummyPWave, tickVals[i]))
			listboxWave[i][1,2] = tickLabels[i][q-1]
		endfor
	else
		NVAR/Z DoAutoScale
		if (!NVAR_Exists(DoAutoScale))
			Variable/G DoAutoScale = IsAutoScaled(theGraph, theAxis)
		endif
		Variable autoScale = DoAutoScale
		string tempStr
		Variable iValue, pValue, nValue, dif, digits, tRightValue = NaN, tLeftValue = NaN
		Variable lowBracket, highBracket
		GetAxis/Q/W=$theGraph $theAxis
		tRightValue = max(V_min, V_max)
		tLeftValue = min(V_min, V_max)
		setTransformAxisRange(theGraph, theAxis, axisFunc, dummyPWave, tRightValue, tLeftValue, autoScale, lowBracket, highBracket, 1)
		for (i = 0; i < numTicks; i += 1)
			FindRoots/T=1e-14/Q/Z=(tickVals[i])/H=(highBracket)/L=(lowBracket) axisFunc, dummyPWave
			digits = LabelDigits(tickLabels, i)+1
			sprintf tempStr, "%.*g", digits, V_root
			listboxWave[i][0] = tempStr
			listboxWave[i][1,2] = tickLabels[i][q-1]
		endfor
	endif
	listboxSelectionWave = 6	// make all cells editable (2), editing requires double-click (4)
	SetDimLabel 1, 0, 'Raw Data Value', listboxWave
	SetDimLabel 1, 1, 'Tick Label', listboxWave
	SetDimLabel 1, 2, 'Tick Type', listboxWave
	Variable/G root:Packages:TransformAxis:numRowsToInsert=1
	Duplicate/O tickVals, tickValsUndo
	Duplicate/O/T tickLabels, tickLabelsUndo
	Duplicate/T/O listboxWave, listboxCompareWave		// when a new axis is selected or the active graph changes, use this to see if changes have been made

	ListBox EditTransformTicksListBox, listWave=listboxWave, selWave=listboxSelectionWave
	ListBox EditTransformTicksListBox, disable=0
	
	SetDatafolder $saveDF
End

Function LabelDigits(w, whichRow)
	Wave/T w
	Variable whichRow
	
	Variable nRows = DimSize(w, 0)
	Variable nDigits = -inf
	Variable nDigits2
	Variable loopRow
	Variable i, lasti
	Variable zero = char2num("0")
	Variable dot = char2num(".")
	Variable theChar
	
	String theLabel
	if (CmpStr(w[whichRow][1], "Major") == 0)
		theLabel = w[whichRow][0]
		nDigits = strlen(theLabel)
		lasti = nDigits
		for (i = 0; i < lasti; i += 1)
			theChar = char2num(theLabel[i])
			if ( (theChar == zero) || (theChar == dot) )
				nDigits -= 1
			else
				break
			endif
		endfor
	else
		loopRow = whichRow
		do
			loopRow -= 1
			if (loopRow < 0)
				break
			endif
			if (CmpStr(w[loopRow][1], "Major") == 0)
				theLabel = w[loopRow][0]
				nDigits = strlen(theLabel)
				lasti = nDigits
				for (i = 0; i < lasti; i += 1)
					theChar = char2num(theLabel[i])
					if ( (theChar == zero) || (theChar == dot) )
						nDigits -= 1
					else
						break
					endif
				endfor
				break
			endif
		while (1)
		do
			loopRow += 1
			if (loopRow >= nRows)
				break
			endif
			if (CmpStr(w[loopRow][1], "Major") == 0)
				theLabel = w[loopRow][0]
				nDigits = strlen(theLabel)
				lasti = nDigits
				for (i = 0; i < lasti; i += 1)
					theChar = char2num(theLabel[i])
					if ( (theChar == zero) || (theChar == dot) )
						nDigits -= 1
					else
						break
					endif
				endfor
				break
			endif
		while (1)
		nDigits = max(nDigits, nDigits2)
	endif
	
	return nDigits
end

Function FindSignificantDigits(number, maxdigits)
	Variable number
	Variable maxdigits
	
	String tempStr
	sprintf tempStr, "%.*e", maxdigits, number
	Variable epos = StrSearch(tempStr, "e", 0)
	Variable theChar
	Variable nine = char2num("9")
	Variable zero = char2num("0")
	Variable dot = char2num(".")
	Variable fudge = 0
	
	Variable i
	for (i = epos-1; i >= 0; i -= 1)
		theChar = char2num(tempStr[i])
		if ( !((theChar == nine) || (theChar == zero) || (theChar == dot)) )
			break
		endif
		if (theChar == dot)
			fudge = 1
		endif
	endfor
	
	return i+fudge
end

// Actually builds the panel
Function fEditTransformTicks()

	String fmt="NewPanel/K=2/W=(%s) as \"Edit Transform Axis Ticks\""
	Execute WC_WindowCoordinatesSprintf("EditTransformTicksPanel",fmt,35,67,596,404,1)	// pixels

//	NewPanel/K=2 /W=(35,67,596,404) as "Edit Transform Axis Ticks"
	DoWindow/C EditTransformTicksPanel
	ModifyPanel fixedSize = 1
	
	Variable TransformAxesExist = (CmpStr(ListTransformAxes(WinName(0,1)), "None Available") != 0)
	Variable MirrorAxesExist = (CmpStr(ListTransformMirrorAxes(WinName(0,1)), "None Available") != 0)
	
	PopupMenu transformAxisMenu,pos={27,46},size={130,20},proc=EditTicksTransformAxisMenuProc,title="Axis:"
	PopupMenu transformAxisMenu,mode=1,bodyWidth= 100
	PopupMenu transformAxisMenu,value= #"ListAllTransformAxes(WinName(0,1))"

	ListBox EditTransformTicksListBox,pos={218,17},size={323,286}
	ListBox EditTransformTicksListBox,mode= 7,editStyle= 1
	ListBox EditTransformTicksListBox,disable=1	// hide the list box. This gives the calling function a chance to set up the list box waves before it is displayed
	
	Button EditTransformTicksDone,pos={389,311},size={60,20},proc=EditTransformTicksDoneProc,title="Done"
	Button EditTransformTicksCancel,pos={110,311},size={60,20},proc=EditTransformTicksDoneProc,title="Undo"
	Button EditTransformTicksApply,pos={28,311},size={60,20},proc=EditTransformTicksDoneProc,title="Apply"
	GroupBox EditTransformTicksInsertGroup,pos={18,129},size={187,108},title="Insert Row"
	SetVariable SetNumRowsToInsert,pos={49,149},size={127,15},title="Rows to Insert:"
	SetVariable SetNumRowsToInsert,limits={1,Inf,1},value= root:Packages:TransformAxis:numRowsToInsert,bodyWidth= 50
	Button EditTformTicksAddRows,pos={28,172},size={166,24},proc=EditTformTicksAddRowsButtonProc,title="Insert Before Selection"
	Button EditTformTicksAddRowsAfter,pos={28,203},size={166,24},proc=EditTformTicksAddRowsButtonProc,title="Insert After Selection"
	Button TransformTicksDeleteRows,pos={28,251},size={166,20},proc=EditTicksDeleteRowsButtonProc,title="Delete Selection"
	Button EditTicksUndoEditsButton,pos={198,311},size={166,20},proc=EditTicksUndoEditsButtonProc,title="Undo Previous Edits"
	Button TransformHelpButton,pos={471,311},size={70,20},proc=TransAxEditTicksHelpButtonProc,title="Help"
	TitleBox EditTicksTargetTitle,pos={10,7},size={87,20},frame=4
	TitleBox EditTicksTargetTitle,variable= root:Packages:TransformAxis:EditTicksTargetName
EndMacro

Function TransAxEditTicksHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Editing the Tick Marks]"
	Button TransformHelpButton,title = "Help"
End

// Looks at the window note for the Edit Ticks Panel to determine the graph and axis currently selected.
// Sets the data folder appropriately.
// If error setting the datafolder, puts up alert and return -1.
// Sucess, returns 0.
// Be sure to save the current datafolder before calling this routine.

// The information in the window note is set from the axis menu by TransformEditTicks()
Function SetDFForEditTicksProcs(isMirror)
	Variable &isMirror
	
	
	GetWindow EditTransformTicksPanel, note
	String PanelNote = S_value
	String theGraph = StringByKey("GRAPH", PanelNote)
	String theAxis = StringByKey("AXIS", PanelNote)
	String theAxisType = StringByKey("AXISTYPE", PanelNote)
	
	String saveDF = GetDatafolder(1)
	
	isMirror = (CmpStr(theAxisType, "Mirror")==0)					// this guarantees that we get a failure return if the type of the axis has changed

	Variable err
	if (isMirror)
		err = SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			return -1
		endif
	else
		err = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			return -1
		endif
	endif
	
//	SetDatafolder $saveDF
	return 0
end

// Returns the name of the graph stored in the panel's window note
// That is the graph the panel is set to work on
Function/S EditTicksGetPanelGraph()
	GetWindow EditTransformTicksPanel, note
	String PanelNote = S_value
	return StringByKey("GRAPH", PanelNote)
end

// Returns the name of the axis stored in the panel's window note
// That is the axis the panel is set to work on
Function/S EditTicksGetPanelAxis()
	GetWindow EditTransformTicksPanel, note
	String PanelNote = S_value
	return StringByKey("AXIS", PanelNote)
end

Function EditTicksPanelHookFunction(infoStr)
	String infoStr

	Variable returnValue = 0
	returnValue = WC_WindowCoordinatesHook(infoStr)
	if (returnValue)
		return returnValue
	endif
	
	String theWindow = StringByKey("WINDOW", infoStr)
	GetWindow $theWindow, note
	String WindowNote = S_value
	
	String theGraph = WinName(0,1)
	String theAxis
	Variable theAxisSelectionNum
	String oldGraph = StringByKey("GRAPH", WindowNote)
	String oldAxis = StringByKey("AXIS", WindowNote)
	String oldAxisType = StringByKey("AXISTYPE", WindowNote)
	
	String CurrentAxisList = ListAllTransformAxes(theGraph)
	Variable GraphHasChanged = 1
	Variable AxisHasChanged = 1
	Variable AxisTypeHasChanged = 1
	Variable AxisPositionInList = 1
	
	String EventType = StringByKey("EVENT", infoStr)
	if (CmpStr(EventType, "activate") == 0)
		if (CmpStr(theGraph, oldGraph) == 0)		// it's the same graph as before
			GraphHasChanged = 0
			if (CmpStr("None Available", oldAxis) == 0)
				return 0								// We've been around once with an alert about not having any axes available. That's why the oldAxis is "None Available". So we shouldn' do anything here.
			endif

			AxisPositionInList = WhichListItem(oldAxis, CurrentAxisList)
			if (AxisPositionInList < 0)
				AxisHasChanged = 1
				PopupMenu transformAxisMenu,mode=1
				AxisTypeHasChanged = 1
			else
				theAxis = oldAxis
				AxisHasChanged = 0
				PopupMenu transformAxisMenu, mode=AxisPositionInList+1
				if ( (CmpStr(oldAxisType, "Mirror") == 0) && (IsTransformMirrorAxis(theGraph, oldAxis)) )
					AxisTypeHasChanged = 0
				elseif ( (CmpStr(oldAxisType, "Transform") == 0) && (IsTransformAxis(theGraph, oldAxis)) )
					AxisTypeHasChanged = 0
				endif
			endif
		else
			PopupMenu transformAxisMenu, mode=1
		endif
		
		if ( (GraphHasChanged + AxisHasChanged + AxisTypeHasChanged) == 0)
			return 0
		endif

		Execute/P "EditTicksGraphHasChanged()"
		returnValue = 1
	endif		// activate event
	
	return returnValue
end

// Checks the saved data structures to find out if the user has edited the list box. Returns 1 if changes have been made, 0 otherwise
Function EditTicksChangesHaveBeenMade()

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF
		return 0				// if the axis that was being edited isn't a transform axis any more, it doesn't matter if edits are in progress
	endif

	Wave/T listboxCompareWave
	Wave/T listboxWave
	Variable ChangesWereMade = 0
	
	if (!WaveExists(listboxCompareWave) || !WaveExists(listboxWave) )
		SetDatafolder $saveDF
		return 0		// can't make the comparison, so just pretend. If we get here, things are probably pretty foo-bar
	endif
	if (DimSize(listboxCompareWave, 0) != DimSize(listboxWave, 0))
		ChangesWereMade = 1
	endif
	if (!ChangesWereMade)
		Variable i, j
		for (i = 0; i < DimSize(listboxWave, 0); i += 1)
			for (j = 0; j < DimSize(listboxWave, 1); j += 1)
				if (CmpStr(listboxWave[i][j], listboxCompareWave[i][j]) != 0)
					ChangesWereMade = 1
					break
				endif
			endfor
			if (ChangesWereMade)
				break
			endif
		endfor
	endif
	
	SetDatafolder $saveDF
	return ChangesWereMade
end

// Execute/P'ed by the panel window hook function on activate events.
// Determines if the target window has changed, determines if the old targets window was edited and if so,
// asks the user if they want to keep the changes, etc.
Function EditTicksGraphHasChanged()

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	Variable ChangesWereMade = 1
	Variable oldAxisExists = 1
	
	if (SetDFForEditTicksProcs(isMirror) < 0)		// sets it to the DF for the previously selected graph and axis so we can check for changes
		SetDatafolder $saveDF							// If we get here, it means that the axis stored in the panel note is no longer a transform axis.
		ChangesWereMade = 0
		oldAxisExists = 0
	endif

	if (ChangesWereMade)								// if this is still non-zero, it means that the axis stored in the panel note is some kind of
															// transform axis and it needs to be checked to see if it has been edited and changes are pending
		Wave/T listboxCompareWave
		Wave/T listboxWave
		Wave listboxSelectionWave		
		String theGraph = EditTicksGetPanelGraph()
		String theAxis = EditTicksGetPanelAxis()
		Variable i
	
		if (!WaveExists(listboxCompareWave) || !WaveExists(listboxWave) )
			ChangesWereMade = 0							// If we get here, it means that somehow things have been trashed. It could be that
															// the user untransformed and then re-transformed the axis since the last time the
															// panel was active. In that case it is appropriate to continue as if this axis had
															// never been edited.
		else
			ChangesWereMade = EditTicksChangesHaveBeenMade()
		endif
	endif
	if (ChangesWereMade)
		DoAlert 1, "You made changes to the transform axis \""+theAxis+"\" in the graph \""+theGraph+"\" and we are about to start editing a different axis. Apply previous changes?"
		if (V_Flag == 1)
			// apply the changes
			String saveTopGraph = WinName(0,1)
			DoWindow/F $theGraph
			
			Variable errorRow
			Variable result = EditTicksApplyChanges(errorRow)
			if (result == 1)
				listboxSelectionWave = 6
				listboxSelectionWave[errorRow][2] = 7
				// **** EXIT ****
				DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
				SetDatafolder $saveDF
				return 0
			elseif (result == 2)
				listboxSelectionWave = 6
				listboxSelectionWave[i][0] = 7
				// **** EXIT ****
				DoAlert 0,  "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
				SetDatafolder $saveDF
				return 0
			else
				DoWindow/F $saveTopGraph
			endif
		else
			// cancel the changes
			EditTicksUndoChanges()
		endif
		DoUpdate
	endif		// changes were made
	// re-build data structures to reflect new top graph
	if (oldAxisExists)
		EditTicksKillWaves()		// kill the old waves
	endif
	TransformEditTicks(0)		// build data but don't create the panel
	
	SVAR EditTicksTargetName = root:Packages:TransformAxis:EditTicksTargetName
	EditTicksTargetName = makeTargetName();
	
	SetDatafolder $saveDF
end

Function EditTicksTransformAxisMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string
	
	Variable Changed = 1
	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		Changed = 0
	endif
	if (Changed)	
		Changed = EditTicksChangesHaveBeenMade()
	endif
	if (Changed)
		DoAlert 1, "You have made changes to the currently selected axis. Apply the changes?"
		if (V_Flag == 1)
			// apply the changes
			Variable errorRow
			Variable result = EditTicksApplyChanges(errorRow)
			Wave listboxSelectionWave
			Variable i
			
			if (result == 1)
				listboxSelectionWave = 6
				listboxSelectionWave[errorRow][2] = 7
				// **** EXIT ****
				DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
				SetDatafolder $saveDF
				return 0
			elseif (result == 2)
				listboxSelectionWave = 6
				listboxSelectionWave[i][0] = 7
				// **** EXIT ****
				DoAlert 0,  "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
				SetDatafolder $saveDF
				return 0
			endif
		else
			// cancel the changes
			EditTicksUndoChanges()
		endif
	endif		// changes were made
	// re-build data structures to reflect new top graph
	EditTicksKillWaves()		// kill the old waves
	TransformEditTicks(0)		// build data but don't create the panel

	SetDatafolder $saveDF
end

Function EditTransformTicksDoneProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo transformAxisMenu
	if (CmpStr(S_value, "None Available") == 0)
		strswitch (ctrlName)
			case "EditTransformTicksApply":
			case "EditTransformTicksCancel":		// the Undo button. I never got around to changing the name
				return 0
			case "EditTransformTicksDone":
				DoWindow/K EditTransformTicksPanel
				return 0
		endswitch
	endif

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		DoAlert 0, "BUG in EditTransformTicksDoneProc; current axis is not valid."
		SetDatafolder $saveDF						// this should never happen- when the panel become active we make sure the axis being edited is valid
		return 0
	endif

	SVAR axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
	Wave dummyPWave
	Wave/T listboxWave
	Wave listboxSelectionWave		
	Wave tickVals
	Wave/T tickLabels
	Wave tickValsUndo
	Wave/T tickLabelsUndo
	Variable i
	Variable nrows = DimSize(listboxWave, 0)
	Variable temp	
	Variable changed = EditTicksChangesHaveBeenMade()

	if ( (CmpStr(ctrlName, "EditTransformTicksDone") == 0) || (CmpStr(ctrlName, "EditTransformTicksApply") == 0) )
		Variable errorRow
		Variable result = EditTicksApplyChanges(errorRow)		// result == 3 can't happen because we already changed df above
		if (result == 1)
			listboxSelectionWave = 6
			listboxSelectionWave[errorRow][2] = 7
			DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
			SetDatafolder $saveDF
			return -1
		elseif (result == 2)
			listboxSelectionWave = 6
			listboxSelectionWave[errorRow][0] = 7
			DoAlert 0, "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
			SetDatafolder $saveDF
			return -1
		endif
	endif

	if (CmpStr(ctrlName, "EditTransformTicksCancel") == 0)
		EditTicksUndoChanges()
		TransformEditTicks(0)
		SetDatafolder $saveDF
		return 0
	endif
	if ( (CmpStr(ctrlName, "EditTransformTicksDone") == 0) || (CmpStr(ctrlName, "EditTransformTicksApply") == 0) )
		EditTicksMakeChangeWaves()
	endif
	if ( (CmpStr(ctrlName, "EditTransformTicksDone") == 0) )
		EditTicksKillWaves()
		NVAR numRowsToInsert = root:Packages:TransformAxis:numRowsToInsert
		KillVariables numRowsToInsert
		DoWindow/K EditTransformTicksPanel
	endif
	
	SetDatafolder $saveDF
	return 0
End

Function EditTicksMakeChangeWaves()

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		DoAlert 0, "BUG in EditTicksMakeChangeWaves; current axis is not valid."
		SetDatafolder $saveDF						// shouldn't happen- 
		return 0
	endif
	
	Wave tickVals
	Wave/T tickLabels
	Wave cleanTickVals
	Wave/T cleanTickLabels
	
	Variable i,j
	Variable npointsNew = numpnts(tickVals)
	Variable npointsClean = numpnts(cleanTickVals)
	Variable lookFor
	
	Make/D/N=0/O deletedTicks
	Make/D/N=0/O addedTicks
	Make/D/N=0/O changedTicks
	Make/N=(0,2)/O/T addedTickLabels
	Make/N=(0,2)/O/T changedTickLabels
	Variable changedNextPoint = 0
	Variable deletedNextPoint = 0
	Variable addedNextPoint = 0
	
	for (i = 0; i < npointsNew; i += 1)
		lookFor = tickVals[i]
		for (j = 0; j < npointsClean; j += 1)
			if (AlmostEqual(lookFor, cleanTickVals[j], 1e-6))	// we've found the same tick position...
				// check if the labels are all the same
				if ( (CmpStr(tickLabels[i][0], cleanTickLabels[j][0]) != 0) || (CmpStr(tickLabels[i][1], cleanTickLabels[j][1]) != 0) )
					InsertPoints changedNextPoint, 1, changedTicks, changedTickLabels
					changedTicks[changedNextPoint] = lookFor
					changedTickLabels[changedNextPoint] = tickLabels[i]
					changedNextPoint += 1
				endif
				break		// found the tick, stop looking
			endif
		endfor
		if (j == npointsClean)	// didn't find lookFor in the clean wave, that means it was added in the editing process
			InsertPoints addedNextPoint, 1, addedTicks, addedTickLabels
			addedTicks[addedNextPoint] = lookFor
			addedTickLabels[addedNextPoint] = tickLabels[i]
			addedNextPoint += 1
		endif
	endfor
	for (i = 0; i < npointsClean; i += 1)
		lookFor = cleanTickVals[i]
		for (j = 0; j < npointsNew; j += 1)
			if (AlmostEqual(lookFor, tickVals[j], 1e-6))	// we've found the same tick position...
				break		// so we don't need to look for it any more
			endif
		endfor
		if (j == npointsNew)	// didn't find lookFor in the new wave, that means it was deleted in the editing process
			InsertPoints deletedNextPoint, 1, deletedTicks
			deletedTicks[deletedNextPoint] = lookFor
			deletedNextPoint += 1
		endif
	endfor
	
	if (numpnts(deletedTicks) == 0)
		KillWaves deletedTicks
	endif
	if (numpnts(addedTicks) == 0)
		KillWaves addedTicks, addedTickLabels
	endif
	if (numpnts(changedTicks) == 0)
		KillWaves changedTicks, changedTickLabels
	endif
	
	SetDatafolder $saveDF
end

// restores graph to the original ticking saved in the undo waves
Function EditTicksUndoChanges()

	// probably redundant, but it assures that things are hunky-dory
	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		DoAlert 0, "BUG in EditTicksUndoChanges; current axis is not valid."
		SetDatafolder $saveDF						// shouldn't happen- 
		return 0
	endif

	Wave/Z tickValsUndo
	WAVE/Z/T tickLabelsUndo
	
	if (!WaveExists(tickValsUndo) || !WaveExists(tickLabelsUndo))		// if one of these waves doesn't exist, not much we can do...
		SetDatafolder $SaveDF
		return -1
	endif
	
	Duplicate/O tickValsUndo, tickVals
	Duplicate/O/T tickLabelsUndo, tickLabels

	SetDatafolder $SaveDF
	return 0
end

Function EditTicksKillWaves()

	// probably redundant, but it assures that things are hunky-dory
	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF						// If the previous menu selection was "None Available" this will happen. In that case, there are no waves to kill. 
		return 0
	endif

	Wave tickValsUndo
	Wave/T tickLabelsUndo
	Wave/T listboxWave
	Wave listboxSelectionWave		

	KillWaves/Z tickValsUndo, tickLabelsUndo
	KillWaves/Z listboxWave, listboxSelectionWave

	SetDatafolder $saveDF
end

// applies changes in the listbox to the axis ticks waves
// return a code indicating outcome:
// 		0	success
//		1	bad tick type code
//		2	bad value
//		3	couldn't set the datafolder
// if a non-zero return is made, the errorRow parameter indicates the row number in the list containing the bad entry

Function EditTicksApplyChanges(errorRow)
	Variable &errorRow

	// probably redundant, but it assures that things are hunky-dory
	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		DoAlert 0, "BUG in EditTicksApplyChanges; current axis is not valid."
		SetDatafolder $saveDF
		return 0
	endif

	Wave/T listboxWave
	Wave listboxSelectionWave
	Variable i
	Variable nrows = DimSize(listboxWave, 0)
	Variable temp
	Wave tickVals
	Wave/T tickLabels
	Variable errorReturn = 0
		
	SVAR axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction

	errorRow = -1
	for (i = 0; i < nrows; i += 1)
		if (CmpStr(listboxWave[i][2], "Major") == 0)
			continue
		elseif (CmpStr(listboxWave[i][2], "Minor") == 0)
			continue
		elseif (CmpStr(listboxWave[i][2], "Subminor") == 0)
			continue
		elseif (CmpStr(listboxWave[i][2], "Emphasized") == 0)
			continue
		else
			errorRow = i
			errorReturn = 1 
			break
		endif
	endfor
	
	if (errorReturn == 0)		// meaning that the previous step completed without error
		if (isMirror)
			Variable AxMin, AxMax
			GetAxis/Q/W=$(EditTicksGetPanelGraph()) $(EditTicksGetPanelAxis())
			Wave dummyPWave
			AxMin = axisFunc(dummyPWave, V_min)
			AxMax = axisFunc(dummyPWave, V_max)

			Redimension/N=(nrows) tickVals
			Redimension/N=(nrows, 2) tickLabels
			for (i = 0; i < nrows; i += 1)
				if (AlmostEqual(str2num(listboxWave[i][0]), AxMax, 1e-4) )
					temp =  AxMax
				elseif (AlmostEqual(str2num(listboxWave[i][0]), AxMin, 1e-4) )
					temp =  AxMin
				else
					FindRoots/T=1e-14/Q/Z=(str2num(listboxWave[i][0]))/H=(AxMax)/L=(AxMin) axisFunc, dummyPWave
					temp =  V_root
				endif
				if (V_flag)
					errorRow = i
					errorReturn = 2
				endif
				tickVals[i] = temp
				tickLabels[i] = listboxWave[i][q+1]
			endfor
		else
			Redimension/N=(nrows) tickVals
			Redimension/N=(nrows, 2) tickLabels
			Wave dummyPWave
			for (i = 0; i < nrows; i += 1)
				temp = axisFunc(dummyPWave, str2num(listboxWave[i][0]))
				if (numtype(temp) == 2)
					errorRow = i
					errorReturn = 2
					break
				endif
				tickVals[i] = temp
				tickLabels[i] = listboxWave[i][q+1]
			endfor
		endif
	endif
	
	SetDatafolder $saveDF
	return errorReturn
end

Function EditTformTicksAddRowsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF
		return 0
	endif

	Wave listboxWave
	Wave listboxSelectionWave
	Variable AddBefore = 0
	if (CmpStr(ctrlName, "EditTformTicksAddRows") == 0)
		AddBefore = 1
	endif
	Variable firstRowSelected, lastRowSelected
	Variable foundSelection = findSelectionRow(listboxSelectionWave, firstRowSelected, lastRowSelected)
	if (foundSelection < 0)
		SetDatafolder $saveDF
		DoAlert 0, "There is no selection in the list."
		return -1
	endif
	listboxSelectionWave[firstRowSelected, lastRowSelected] = 6		// de-select the selection row
	NVAR numRowsToInsert = root:Packages:TransformAxis:numRowsToInsert
	Variable insertionRow = firstRowSelected
	if (!AddBefore)
		insertionRow = lastRowSelected+1
	endif
	InsertPoints insertionRow, numRowsToInsert, listboxWave, listboxSelectionWave
	DoUpdate
	listboxSelectionWave[insertionRow, insertionRow+numRowsToInsert-1] = 6	// make all cells editable (2), editing requires double-click (4)
	DoUpdate
	
	SetDatafolder $saveDF
	return 0
End

Function EditTicksDeleteRowsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF
		return 0
	endif

	Wave listboxWave
	Wave listboxSelectionWave
	Variable firstRowSelected, lastRowSelected
	Variable foundSelection = findSelectionRow(listboxSelectionWave, firstRowSelected, lastRowSelected)
	if (foundSelection < 0)
		SetDatafolder $saveDF
		DoAlert 0, "There is no selection in the list."
		return -1
	endif
	DeletePoints firstRowSelected, lastRowSelected-firstRowSelected+1, listboxWave, listboxSelectionWave
	
	SetDatafolder $saveDF
	return 0
End

Function EditTicksUndoEditsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF
		return 0
	endif

	Wave/T cleanTickLabels
	Wave cleanTickVals
	Duplicate/O cleanTickLabels, tickLabels
	Duplicate/O cleanTickVals, tickVals
	Duplicate/O tickLabelsUndo, tickLabelsUndoSave
	Duplicate/O tickValsUndo, tickValsUndoSave
	TransformEditTicks(0)
	Duplicate/O tickLabelsUndoSave, tickLabelsUndo
	Duplicate/O tickValsUndoSave, tickValsUndo
	KillWaves/Z tickLabelsUndoSave,tickValsUndoSave
	
	SetDatafolder $SaveDF
End

// returns first selected row in the Edit Ticks panel listbox control
// returns first and last selected row in parameters
Function findSelectionRow(selectionWave, firstRow, lastRow)
	Wave selectionWave
	Variable &firstRow, &lastRow
	
	Variable rows = DimSize(selectionWave, 0)
	Variable cols = DimSize(selectionWave, 1)
	Variable firstSelectedRow = -1
	Variable lastSelectedRow = -1
	
	if (cols == 1)
		cols = 0
	endif
	
	Variable i
	Variable j
	Variable done = 0
	for (i = 0; i < rows; i += 1)
		if (cols > 0)
			for (j = 0; j < cols; j += 1)
				if ( (selectionWave[i][j] & 1) == 1)
					firstSelectedRow = i
					done = 1
					break
				endif
			endfor
		else
			if ( (selectionWave[i] & 1) == 1)
					firstSelectedRow = i
					done = 1
					break
			endif
		endif
		if (done)
			break
		endif
	endfor

	lastSelectedRow = firstSelectedRow
	if (firstSelectedRow < 0)
		return -1						// **** EXIT ****
	endif
	
	Variable notSelected
	for (i = firstSelectedRow+1; i < rows; i += 1)
		if (cols > 0)
			notSelected = 0
			for (j = 0; j < cols; j += 1)
				if ( (selectionWave[i][j] & 1) == 1)
					lastSelectedRow = i
				endif
			endfor
			if (lastSelectedRow != i)
				break
			endif
		else
			if ( (selectionWave[i] & 1) == 1)
				lastSelectedRow = i
			else
				break
			endif
		endif
	endfor
	
	firstRow = firstSelectedRow
	lastRow = lastSelectedRow

	return firstSelectedRow
end

//*******************************************************
// transform functions
//*******************************************************

Function TransformAxisTemplate(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	DoAlert 0, "For some reason we are executing the template function."
	return NaN
end

Function TransAx_Reciprocal(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	if ( (val <= 0) || (NumType(val)!=0) )
		return NaN
	else
		return 1/val
	endif
end

Function TransAx_ModifiedReciprocal(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	if (!WaveExists(w) || (numpnts(w) < 2))
//		DoAlert 0, "The ModifiedReciprocal transformation function requires a coefficient wave with two points."
		return NaN
	endif
	Variable xx = (val+w[1])
	if (xx <= 0)
		return NaN
	else
		return w[0]/xx
	endif
end

Function TransAx_DegreesCtoF(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return val*1.8+32
end

Function TransAx_DegreesFtoC(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return (val-32)/1.8
end

Function TransAx_DegreesCtoK(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return val+273
end

Function TransAx_DegreesKtoC(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return val-273
end

Function TransAx_DegreesFtoK(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return TransAx_DegreesFtoC(w,val)+273
end

Function TransAx_DegreesKtoF(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return TransAx_DegreesCtoF(w,val-273)
end

Function TransAx_Probability_Percent(wp, xx)
	Wave/Z wp
	Variable xx
	
	return TransAx_Probability(wp, xx/100)
end

Function TransAx_Probability(wp, xx)
	Wave/Z wp
	Variable xx
	
	if(numType(xx)!=0)
		return(xx)
	endif
	
	if ( (xx <= 0) || (xx >= 1) )
		return NaN
	endif
	
	if(xx==0.5)									// simple case-no need to calculate
		return(0)
	endif
	
	Variable smaller
	if(xx<0.5)
		smaller=1
		xx=0.5-xx
	else
		smaller=0
		xx=xx-0.5
	endif
	
	FindRoots/T=1e-14/Q/Z=(xx)/H=10/L=0 erfForNormalTransform, wp
	if (V_flag != 0)
		return NaN
	endif
	
	if(smaller==0)
		return(V_Root)
	else
		return(-V_Root)
	endif
end

Function erfForNormalTransform(wp, xx)
	Wave/Z wp		// ignored
	Variable xx
	
	return 0.5*erf(xx/1.4142135623731)
end

Function PrintAxisInfo(theGraph, theAxis)
	String theGraph, theAxis
	
	if (strlen(theGraph) == 0)
		theGraph = WinName(0,1)
	endif
	
	print "Axis Info for graph "+theGraph+"; axis "+theAxis
	
	String theInfo = AxisInfo(theGraph, theAxis)
	String theRecreation = GetAxisRecreationFromInfoString(theInfo, ":")
	
	Variable i = 0
	String oneItem
	do
		oneItem = StringFromList(i, theInfo)
		if (strlen(oneItem) == 0)
			break
		endif
		if (CmpStr("RECREATION", oneItem[0,9]) == 0)
			break
		endif
		print "\t"+oneItem
		i += 1
	while (1)
	print "** axis recreation:"
	i = 0
	do
		oneItem = StringFromList(i, theRecreation)
		if (strlen(oneItem) == 0)
			break
		endif
		print "\t"+oneItem
		i += 1
	while (1)
end