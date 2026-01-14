#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.38
#pragma IgorVersion = 8.00
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName=TransformAxis1_2

#include <ProcessProbabilityData1.01>
#include <String Substitution>
#include <SaveRestoreWindowCoords>
#include <Axis Utilities>

static constant debugInfo = 0
static constant debugUpdates = 0

static constant TRANSFORMAXISVERSION = 1.2			// is saved in the graph's user data to keep track of the tick generation algorithm
static constant TRANSAX_UPDATEPANELVERSION = 1.36	// is saved in the unified panel's user data for version control

static constant TransformType = 0
static constant MirrorType = 1

static constant TA_ResizeEvent = 6

Menu "Graph"
	Submenu "Transform Axis"
		"New, Modify or Undo Transform Axis...",/Q, TransformAxis1_2#DoUnifiedTransformAxisPanel()		// ST: 210524 - new unified control panel
		//"Transform Axis...",/Q, TransformAxis1_2#DoTransformAxisPanel(0)								// ST: 210524 - old control panels not accessible but still functional
		//"Untransform Axis...",/Q, TransformAxis1_2#DoTransformAxisPanel(2)
		//"Modify Transform Axis...",/Q, TransformAxis1_2#DoTransformAxisPanel(1)
		//"Edit Ticks on Transform Axis...",/Q, TransformAxis1_2#TransformEditTicksShowPanel()
		"Refresh Graph", /Q, TransformAxis1_2#RefreshGraph()
//		"-"
//		TransformAxisUpdateMenuItem(),/Q, fUpdateTransAxGraphsPanel()
//		help = {"Transform axes were detected that were made with on older version of the package. Select this to update them.", "Not available because the transform axes in this experiment file were made with the current version of the package."}
	end
end

Menu "GraphPopup"		// ST: 210524 - quick access via graph right-click menu
	Submenu "Transform Axis"
		"Transform Axis...",/Q, TransformAxis1_2#DoUnifiedTransformAxisPanel()
		"Refresh Graph", /Q, TransformAxis1_2#RefreshGraph()
	end
End

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
//		1) AdjustTickLabelSpacing() doesn't yet handle horizontal axes. 								DONE (but does it work correctly?)
//		2) Window Hook for re-sizing the graph window. 													DONE
//		3) Mouse hooks for clicking on a transformed axis. 												***Decided not to do this.
//		4) If 3) then we need to be able to invoke the regular Modify Axis dialog at need.				*** and this is why.
// 		5) Check it out on Windows. 																	DONE if such a thing can be done
//		6) Add option for exponential labels.															DONE
//		7) Apply button for Modify Transform Axis panel 												DONE
//		8) Panels should remember position																DONE
// 		9) Mirror axis 																					DONE
//		10) It would be nice if the transform function could be changed without undoing and re-doing
//		11) "Refresh the Graph" in the Graph menu														DONE
//		12) When a user edits the ticks, the edits should be preserved when the axis is re-drawn			DONE
//		13) changing the range of an axis with an inverting function swaps the axis ends				I THINK THIS IS FIXED BY ACCIDENT...
//		14) Transform mirror axes need to calculate the space required and automatically set the margin.
//		15) Need to save a recreation macro...
//				Actually, as long as the data stays around, the regular recreation macro is fine.
//		16) FOR VERSION 5: put Abort statement in TransAx_ModifiedReciprocal function instead of the DoAlert
//			statement that is currently commented out. Add Try-Catch blocks in appropriate places
//			to catch any possible aborts from axis transform functions.									DONE
//		17) FOR VERSION 5: look at new hook functions to improve the way Transform Axis responds to
//			events like adding a trace to an axis, or changing the range of an axis.					DONE
//		18) FOR VERSION 5: use Truly Free Axis for mirror axes.											DONE
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
//   Tightened up the FindRoots tolerances to allow inverting functions that are asymptotic to some value. This was
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
//
// after 1.12, jumped to 1.20 which will run only on Igor 5
//
// version 1.20:
//		First Igor 5 implementation of Transform Axis.
//		Altered TransformMirrorAxis to use new Truly Free Axes.
//		TransformMirrorAxis now does the right thing when a trace is added to the main axis.
//		TransformMirrorAxis now follows changes in the main axis style, but changes to the mirror axis style persist
//			unless a particular style is changed on the main axis.
//		You can add traces to a transformed axis and the new data is transformed properly.
//		You can modify a transformed trace in various ways that weren't previosly possible.
//		You can change the lengths of waves in a transform axis graph and the transform axes will update properly.
//		You can zoom in on a transform axis trace and the axis will update properly.
//		Pre-version 1.20 graphs will be updated to make them 1.20-compatible. This is not backwards compatible!
//		Added function CloseTransformAxisGraph(saveData) function so that you can close a graph containing a transform
//			axis without getting the alert about whether you want to save the data.
// version 1.21:
//		improved calculation of function derivatives for ranges near the limits of a transform function's allowed range.
// version 1.22:
//		added square root transformation.
// version 1.23:
//		Fixed bug: killing a graph, if you say Yes to save transform axis info, it failed to restore the data folder.
// version 1.24:
//		Changed to #pragma rtGlobals=3 (strict wave reference checking) and fixed compile errors that resulted.
// version 1.25:
//		Another index-out-of-range error
//	version 1.26 JW 101001
//		Added ability to have scientific format tick labels. Uses GrepString and SplitString, so now requires Igor 6.20 (yeah, yeah- not really 6.2, but that's easiest for me).
//	version 1.27 JW 101116
//		Fixed additional index-out-of-range error in CullTicksDirtyWork().
//	version 1.28 JW 120206
//		Fixed a bug that could cause the loss of a tick label right at the end of a transform mirror axis when editing the ticks.
// version 1.29 JW 170119
//		Made several functions static to avoid conflicts with other packages. Motivated by a report of a compile
//		error from a customer who had another procedure file (not ours) that contained a function GetAxisType().
// version 1.30 JW 190215
//		Fixed bug: RestoreEditsAfterTicking() could cause an Index Out of Range error when deleting a tick.
// version 1.32 JW 191008
//		The Refresh Graph menu item didn't work because at some point I made the RefreshGraph() function static. That seems
// 	like a good idea, so I added a ModuleName pragma and use function double names in the menu.
// version 1.33 JW 191202
//		Make TransformAxis safe for Edit->Duplicate Graph or for creating a copy using the recreation macro.
//		If something happens that causes an error in TicksForTransformAxis, the error is indicated by an error textbox
//			added to the graph instead of potentially putting up an infinite string of DoAlert boxes. A subsequent 
//			successful call removes the error textbox.
//		Removing a regular transform axis now actually works, instead of giving an error on KillWaves.
//		Removing a regular transform axis failed to undo the user ticks from waves.
//		Removing the last regular transform axis now checks for transform mirror axes before removing the window hooks and user data.
//		Removing the last transform mirror axis now checks for regular transform axes before removing the window hooks and user data.
// version 1.34 ST 210520
//		Added a check for the number of tick vals (and abort if too small) in case the transformation function is not well behaved.
// version 1.35 ST 210524
//		Added support for optional direct creation of scientific axes in SetupTransformTraces() and SetupTransformMirrorAxis().
//		Added unified control panel, which merges the New, Modify and Undo panels.
//		Added graph popup menu for quick access.
//		Fixed display issues with the Edit Ticks panel when starting with or switching from a graph without ticks.
// version 1.35 ST 210525
//		Unified panel: axis popup menus were not properly refreshed after creating or killing an axis.
// version 1.35 ST 210526
//		Unified panel: now axis modifications get immediately applied to the graph without the need to press 'Do it'.
//		Unified panel: now the Modify tab disappears instead of getting disabled when no modification is possible.
// version 1.35 ST 210531
//		Fixed bug: CullMinorTicks() threw an error if there is only one major tick as the first item in the ticks list.
//		Fixed bug: a temporary 'dummyPWave' was accidentally created in the main folder.
//		Fixed bug: if the left axis is already transformed then transforming the bottom axis was loading the transformed wave ('wavename_T')
//			instead of the source wave for the dependency, which made it impossible to undo the transformation of the left axis.
//		Added button to create a transform function template to the unified panel.
//		Added edit tab to the unified panel which replaces the old edit panel.
//		Added right-click menu in edit tab to quickly select tick type from a list.
//		Fixed inconsistency: 'Undo Previous Edits' did not restore the ticks in a value-sorted way.
//		Edit panel / tab: Now tick labels can be edited with one click and there is an additional right-click menu for the tick position column.
//		Now the unified panel recognizes when there is no open graph to work with.
// version 1.35 ST 210604
//		Fixed bug: if creating a new axis failed for some reason then the panel still switched to the modify tab (with no proper axis present).
//		Fixed bug: the coefficient wave was not properly copied over into the graph's sub-folder (regression bug from 210531).
//		Fixed bug: the apply button (edit tab) did not update the listboxCompareWave, which kept triggering a warning that changes have not been applied yet.
// version 1.35 ST 210609
//		Fixed bug: transformable axes were displayed as available in the panel even after closing all graphs.
//		Fixed bug: if a trace is added to the graph after an axis was transformed then the transformed axis could not be removed anymore.
//		Fixed bug: if a trace is removed the dependency and transformed waves were not deleted and made it impossible to untransform the axis.
//		Fixed bug: renaming the source waves threw an error when trying to revert the axis. Now The transformed data is updated automatically.
//		If an axis is reverted back to a normal axis then any associated error boxes are deleted as well.
//		Now a transformed axis is scaled to the transformed start and end values if possible.
//		Changes in the coefficient wave associated with the transformed axis are utilized now for axis updates.
// version 1.35 ST 210610
//		Fixed bug: the axis may be displayed in reverse upon first creation.
//		The Create New Function Template tool is now inside the Function popup as an entry instead of a button.
//		The tick list now shows little arrows next to the tick type and this entry can only be edited via a menu.
//		Fixed bug: the Scientific Labels checkbox was not updating the graph.
//		Fixed bug: the Edit tab's Axis popup was not updated properly. Merged with the Modify tab popop now.
// version 1.35 ST 210611
//		The Revert to Default button deletes manual changes as well so that edited ticks do not reappear.
//		Major ticks at Ends get scientific treatment now.
//		Fixed bug: scientific formatting properly shows x10^0 labels now.
//		The panel aligns to the bottom of the graph if possible.
//		The decimal precision for Major ticks at Ends was one too high.
// version 1.35 ST 210615
//		Fixed bug: the current folder selection was stuck inside the package folders after closing the panel.
//		Selecting the same axis in the Axis popup of the Edit tab does not ask if updates should be applied.
//		The unified panel is now centered on the screen when opened.
//		Edited ticks are now persistent even when applied via an alert box after switching away from the Edit tab.
// version 1.35 ST 210616
//		Setting the range directly in the graph is now prohibited for transformed axes. The Modify tab should be used instead.
//		Fixed bug: switching back to Auto Scale did not properly update the tick spacing.
// version 1.35 ST 210619
//		Transformed axes now accept range changes directly via mouse wheel and user settings (Modify Axis dialog).
//			If the transformed range is invalid the axis snaps back to the previous values.
// version 1.35 ST 210707
//		Fixed bug: setTransformAxisRange() was hanging forever while searching bracket limits sometimes.
// version 1.35 JW 210708
//		Rename setTransformAxisRange() to getTransformAxisRootBrackets() because that's what it does.
//		Removed calls to DoWindow/F that made the graph containing the transformed axis come to the
//			front too much.
// version 1.35 ST 210711
//		Fixed the live axis-range update code (mouse wheel and user settings) for transformed axes,
//			after setTransformAxisRange() was changed. Inverse (untransformed) values for setting
//			the new axis range are now calculated via the function getUntransformedValuesForAxisRange().
// version 1.35 JW/ST 210730
//		Fixed an infinite loop inside getUntransformedValuesForAxisRange() when the automatic axis range was used.
//		Fixed bug: Controls were sometimes appearing in the graph when the intention was to update the panel.
//		Fixed bug: HandleResizeOrModifiedEvent() was running in an infinite update-loop with a coefficient wave present.
//		Reduced the number of SetDataFolder calls and instead used DFREF inside folderForThisGraph() and findDatafolderForAxis().
// version 1.35 ST 210731
//		Added manual refresh button to the unified panel.
//		Now NumberToTickLabel() cleans up zero numbers like "-0.0" to be just "0".
//		User coefficient waves are now linked via a dependency to the dummyPWave for instant updates.
//		Offsetting or scaling transformed traces is now prevented (modifications are reset). This does not apply to mirrored axes.
//		Added a check whether the free axis already exists before adding a mirror axis, and remove previous waves. This prevents errors
//			 if the free axis was not properly removed previously for some reason.
//		Fixed another infinite update-loop within HandleResizeOrModifiedEvent(), when the axis range was running out-of-bounds (NaN).
// version 1.36 JW 210909
//		The control panel and package now work with panels, graph and layouts containing graph subwindows.
// version 1.36 ST 210913
//		Fetching target graphs when activating the unified panel happens now in the operation queue (Execute/P) to catch recently closed graphs.
//		getTopGraph() returns the topmost valid graph or sub-graph and just ignores windows which cannot contain a graph.
//		Made more space for the target title-box inside the panel to accommodate sub-window names.
//		Fixed bug: Killing the target graph failed to update the target in the panel when the panel was not activated.
//		Transforming a graph which contains duplicated trace instances leads to a range of problems. Transformation is prevented in this case for now.
// version 1.36 JW 210914
//		Now you can transform a graph that contains multiple traces for a single wave.
// version 1.36 ST 210916
//		Made even more space the target title-box. The help button is now below the title-box.
// version 1.36 JW 210916
//		Inserting a sub-graph with a transformed axis attached will now automatically patch up folders and dependencies, avoiding overlap with the source graph. 
// version 1.36 ST 210920
//		Fixed bug: Prevent accidental control creation in the wrong window within TransformPresetAxisOptions.
// version 1.36 JW 210920
//		Added recursive check for existing TA axes in subwindows to prevent removing the window hook
//		when removing TA axes from a window that has other TA axes in other subwindows. See TA_WindowHasTAAxisSomewhere().
// version 1.36 ST 210923
//		The unified panel's version number is checked now, and the panel is reopened if the version number was bumped.
//		Fixed bug: The unified panel was always created in the center of the screen and did not adapt its previous screen position. Now the position is remembered.
// version 1.36 ST 210926
//		Removing / leaving the working folders upon killing a graph is now decided automatically without user interaction, depending on whether or not recreation
//			or style macros for the graph in question exist. Folders remain when a macro with TransAx-specific SetWindow commands is found.
//		Fixed bug: Applying a style macro from a graph with transformed axes was broken. Now the transformed axes are correctly applied together with the style.
// version 1.36 ST 210930
//		Style macros do not set the graph hook correctly. This is fixed when activating or starting the panel on-the-fly by moving the hook to the main window.
// version 1.37 ST 211108
//		Fixed error message: Closing the panel summons the debugger if WAVE checking is on.
// version 1.37 ST 211117
//		Improved error handling: A message is displayed if a graph has the hook function but not the associated mirror axis attached for some reason.
// version 1.37 ST 220908
//		Fixed bug: tickLabels was not properly used as 2D wave in many places (changed tickLabels[num] => tickLabels[num][0])
// version 1.38 JW 221102
//		Added code to ApplyAxisRecreationDifferences() to allow NOT copying selected axis appearance (ModifyGraph) settings.
//		See avoidModGraphKeys constant for a list of omitted modifier keys - these include grid options, label position, rotation etc. 
// version 1.38 ST 221108
//		Added new option to toggle removing extra trailing zeros in tick labels.
//		Rearranged the panel to incorporate the new zero-trimming option better.
//		Fixed bug: Scientific labels ending with x10^0 were not properly displayed.
//		Negative scientific labels now have no leading zero (e.g., 10^-01) anymore.
//		Now labels are padded to have the same length after the decimal symbol when 'remove trailing zeroes' is off.
//*********************************

// TAType should be either TransformType or MirrorType
static Function/S TA_MakeDFNameForThisGraph(String gname, Variable TAType)
	String dfname = ""
	
	if (TAType == TransformType)
		dfName = "AxisTransform_"+gname
	elseif (TAType == MirrorType)
		dfName = "TransformMirror_"+gname
	else
		return ""
	endif
	
	dfName = CleanupName(dfName, 0)
	
	return dfname
end

// Changed for version 1.2: now uses graph user data to get the data folder associated with the graph.
// If you really need to get the data folder in the pre-1.2 way, use OldFolderForThisGraph()
Function/S folderForThisGraph(theGraph, TAType, [FullPath])
	String theGraph
	Variable TAType			// 0 for transform axis; 1 for mirror axis; but use the constants defined above: TransformType and MirrorType
	Variable FullPath
	
	if (ParamIsDefault(FullPath ))
		FullPath = 1
	endif
	
	String saveDF = GetDatafolder(1)
	if (!DataFolderExists("root:Packages:"))
		return ""
	endif
	
	if (WinType(theGraph) != 1)
		return ""
	endif

	String theDF=""
	String leafName = ""
	
	if (TAType == TransformType)
		theDF = GetUserData(theGraph, "", "TransAxFolder")
		if (strlen(theDF) > 0)
			//SetDataFolder $theDF						// ST: 210730 - reduce the number of SetDataFolder events
			//leafName = GetDataFolder(0)
			//SetDataFolder $saveDF
			leafName = ParseFilePath(0, theDF, ":", 1, 0)
			if (isTransformAxisDFName(leafName))
				if (FullPath)
					return theDF
				else
					return leafName
				endif
			endif
		endif
	endif
	if (TAType == MirrorType)
		theDF = GetUserData(theGraph, "", "TransAxMirrorFolder")
		if (strlen(theDF) > 0)
			//SetDataFolder $theDF						// ST: 210730 - reduce the number of SetDataFolder events
			//leafName = GetDataFolder(0)
			//SetDataFolder $saveDF
			leafName = ParseFilePath(0, theDF, ":", 1, 0)
			if (isTransformMirrorDFName(leafName))
				if (FullPath)
					return theDF
				else
					return leafName
				endif
			endif
		endif
	endif
	
	return ""
end
	
// this function searches for a datafolder for the named graph. It does this
// by first searching all the datafolders in the Packages datafolder for one
// containing a global string containing the graph name. If it can't find it,
// it then tries to generate a datafolder name from the graph name and tries
// to find that. If it succedes, it returns the name of the found datafolder.
// If it fails, it returns "".
//
// This is how it was done pre-version 1.2
Function/S OldFolderForThisGraph(theGraph, TAType)
	String theGraph
	Variable TAType			// 0 for transform axis; 1 for mirror axis; but use the constants defined above: TransformType and MirrorType
	
	String saveDF = GetDatafolder(1)
	if (!DataFolderExists("root:Packages:"))
		return ""
	endif
	
	if (WinType(theGraph) != 1)
		return ""
	endif

	String theDF=""
	
	SetDatafolder root:Packages:
	Variable foundIt = 0
	String dfName
	
	Variable i=0
	String aDF=""
	do
		aDF = GetIndexedObjName("", 4, i)
		if (strlen(aDF) == 0)
			break
		endif
		if ( ((TAType == TransformType) && (CmpStr(aDF[0,13], "AxisTransform_") == 0)) || ((TAType == MirrorType) && (CmpStr(aDF[0,15], "TransformMirror_") == 0)) )
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
		dfName = TA_MakeDFNameForThisGraph(theGraph, TAType)
			
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
Function/S makeUniqueDFNameForGraph(theGraph, TAType)
	String theGraph
	Variable TAType		// 0 for transform axis; 1 for mirror axis

	String dfName = TA_MakeDFNameForThisGraph(theGraph, TAType)
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
Function/S findDatafolderForAxis(theAxis, TAType)
	String theAxis
	Variable TAType		// 0 for transform axis; 1 for mirror axis
	
	//String gDF = GetDatafolder(1)
	DFREF gDFR = GetDataFolderDFR()						// ST: 210730 - reduce the number of SetDataFolder events
	
	Variable i=0
	Variable foundIt = 0
	String aDF
	String theDF = ""
	do
		//aDF = GetIndexedObjName("", 4, i)
		aDF = GetIndexedObjNameDFR(gDFR, 4, i)
		if (strlen(aDF) == 0)
			break
		endif
		DFREF aDFR = gDFR:$(aDF)
		if ( ((TAType == TransformType) && (CmpStr(aDF[0,13], "AxisTransform_") == 0)) || ((TAType == MirrorType) && (CmpStr(aDF[0,15], "TransformMirror_") == 0)) )
			//SetDatafolder $aDF
			//SVAR/Z ActualAxisName
			SVAR/Z ActualAxisName = aDFR:ActualAxisName
			if (SVAR_Exists(ActualAxisName) && (CmpStr(theAxis, ActualAxisName) == 0) )
				theDF = GetDatafolder(1,aDFR)
				//SetDatafolder $gDF
				break
			endif
			//SetDatafolder $gDF
		endif
		i += 1
	while (1)
	//SetDatafolder $gDF
	return theDF
end

// This function uses the axis name in theAxis to create a new datafolder name.
// It is guaranteed to be a new name, so make sure the axis doesn't already
// have a datafolder made for it.
// Returns the new name; just the name, not a full path.
// Assumes that the current datafolder is the datafolder for the graph that's being worked on
Function/S makeUniqueDFNameForAxis(theAxis, TAType)
	String theAxis
	Variable TAType		// 0 for transform axis; 1 for mirror axis

	String dfName
	if (TAType == TransformType)
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

Function XAxisWaveFormDependency(theFunc, RawYData, TransformXData, CoefW)
	String theFunc
	Wave RawYData, TransformXData, CoefW
	
	String theNote = Note(TransformXData)								// ST: 210609 - handle rename events of the raw data
	String oldWave = StringByKey("OldYWave", theNote, "=", ";")
	String newWave = GetWavesDataFolder(RawYData, 2)
	if (CmpStr(oldWave, newWave) != 0)
		theNote = ReplaceStringByKey("OldYWave",theNote,newWave,"=")
		Note/K TransformXData, theNote
		Rename TransformXData, $(NameOfWave(RawYData)+"_TX")
	endif
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc
	if (numpnts(RawYData) != numpnts(TransformXData))
		Redimension/N=(numpnts(RawYData)) TransformXData
	endif
	
	TransformXData = axisFunc(CoefW, pnt2x(RawYData, p))
end

Function XAxisXYDataDependency(theFunc, RawXData, TransformXData, CoefW)
	String theFunc
	Wave RawXData, TransformXData, CoefW
	
	String theNote = Note(TransformXData)								// ST: 210609 - handle rename events of the raw data
	String oldWave = StringByKey("OldWave", theNote, "=", ";")
	String newWave = GetWavesDataFolder(RawXData, 2)
	if (CmpStr(oldWave, newWave) != 0)
		theNote = ReplaceStringByKey("OldWave",theNote,newWave,"=")
		Note/K TransformXData, theNote
		Rename TransformXData, $(NameOfWave(RawXData)+"_TX")
	endif
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc
	if (numpnts(RawXData) != numpnts(TransformXData))
		Redimension/N=(numpnts(RawXData)) TransformXData
	endif
	
	TransformXData = axisFunc(CoefW, RawXData)
end

Function YAxisDataDependency(theFunc, RawYData, TransformYData, CoefW)
	String theFunc
	Wave RawYData, TransformYData, CoefW
	
	String theNote = Note(TransformYData)								// ST: 210609 - handle rename events of the raw data
	String oldWave = StringByKey("OldWave", theNote, "=", ";")
	String newWave = GetWavesDataFolder(RawYData, 2)
	if (CmpStr(oldWave, newWave) != 0)
		theNote = ReplaceStringByKey("OldWave",theNote,newWave,"=")
		Note/K TransformYData, theNote
		Rename TransformYData, $(NameOfWave(RawYData)+"_T")
	endif
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc
	if (numpnts(RawYData) != numpnts(TransformYData))
		Redimension/N=(numpnts(RawYData)) TransformYData
	endif
	
	TransformYData = axisFunc(CoefW, RawYData)
end

// JW 210904 Added to support keeping track of already transformed waves
static Function WaveWaveContainsWave(Wave/WAVE wavewave, Wave awave)
	if (numpnts(wavewave) == 0)
		return 0
	endif
	if (!WaveExists(awave))
		return 0
	endif
	Make/N=(numpnts(wavewave))/FREE flags
	flags = WaveRefsEqual(wavewave[p], awave)
	return sum(flags) != 0
end

// This function is used to transform the data from graph traces for a transformed axis (not a mirror axis). It does not use try-catch
// to handle function aborts- the setup code should have detected any abort before getting here.
Function TransformAxisTransformNewTraces(theGraph, oneAxis, newTraces, theFunc, pw, axisLeftForWaveNote, axisRightForWaveNote)
	String theGraph, oneAxis, newTraces
	String theFunc
	Wave pw
	Variable axisLeftForWaveNote, axisRightForWaveNote		// for added traces, read out of an existing wave note. For new axis, already have the real info
	
	Variable isXAxis = IsHorizAxis(theGraph, oneAxis)
	Variable i
	String oneTrace
	String partialWaveNote = TransformedWaveNotePreamble(theGraph, oneAxis, axisLeftForWaveNote, axisRightForWaveNote)
	String theWaveNote
	
	String DepVarName
	String DepFormula

	FUNCREF TransformAxisTemplate axisFunc=$theFunc
	Make/FREE/WAVE/N=0 originalwaves												// JW 210914 Added to keep track of already transformed waves
	
	Variable ntraces = ItemsInList(newTraces)
	if (isXAxis)
		i = ntraces - 1																// JW 210914 ReplaceWave can change the trace names if there are duplicate traces, so go through them backwards
		do
			oneTrace = StringFromList(i, newTraces)
			if (strlen(oneTrace) == 0)
				break
			endif
			// JW 210914 Removed protection against duplicate traces
			Wave/Z oldXw = XWaveRefFromTrace(theGraph, oneTrace)
			theWaveNote = "TransformAxis="+oneAxis+";"
			theWaveNote += "AxisType=X;"
			DepVarName = "TransformDependencyVar"
			DepVarName = UniqueName(DepVarName, 4, 0)
			Variable/G $DepVarName
			NVAR depvar = $DepVarName
			
			String transformedWaveName=""											// JW 210914 Used to generate the name string over and over!
			Variable originalWavesIndex = numpnts(originalwaves)					// JW 210914 When a wave has been transformed, we append it to this WAVE wave
			
			if (!WaveExists(oldXw))		// Needs an X wave
				Wave w = TraceNameToWaveRef(theGraph, oneTrace)
				transformedWaveName = NameOfWave(w)+"_TX"
				if (!WaveWaveContainsWave(originalwaves, w))						// JW 210914 Only do this once for a given wave!
					InsertPoints originalWavesIndex, 1, originalwaves
					originalwaves[originalWavesIndex] = w
					String baseWave = StringByKey("OldWave", Note(w), "=", ";")		// ST: 210531 - the current trace may already be transformed
					if (strlen(baseWave) > 0 && Exists(baseWave) == 1)				// ST: 210531 - use the source data for the dependency instead
						Wave w = $baseWave
					endif
					
					Duplicate/O w, $transformedWaveName
					Wave Xw = $transformedWaveName
					Xw = axisFunc(pw, pnt2x(w, p))
					DepFormula = "XAxisWaveFormDependency(\""+theFunc+"\","
					DepFormula += GetWavesDatafolder(w,2)+","
					DepFormula += GetWavesDatafolder(Xw,2)+","
					DepFormula += GetWavesDatafolder(pw,2)+")"
					SetFormula depvar, DepFormula
				else
					Wave Xw = $transformedWaveName									// JW 210914 If we didn't make a new wave, we need to connect with the already-made one
				endif
				ReplaceWave/X/W=$theGraph trace=$oneTrace, Xw
				theWaveNote += "OldWave=;"
				theWaveNote += "OldYWave="+GetWavesDatafolder(w, 2)+";"
			else
				transformedWaveName = NameOfWave(oldXw)+"_TX"
				if (!WaveWaveContainsWave(originalwaves, oldXw))					// JW 210914 As above- only do it once
					InsertPoints originalWavesIndex, 1, originalwaves
					originalwaves[originalWavesIndex] = oldXw
					Duplicate/O oldXw, $transformedWaveName
					Wave Xw = $transformedWaveName
					Xw = axisFunc(pw, oldXw)
					DepFormula = "XAxisXYDataDependency(\""+theFunc+"\","	// XAxisXYDataDependency(theFunc, RawXData, TransformXData, CoefW)
					DepFormula += GetWavesDatafolder(oldXw,2)+","
					DepFormula += GetWavesDatafolder(Xw,2)+","
					DepFormula += GetWavesDatafolder(pw,2)+")"
					SetFormula depvar, DepFormula
				endif
				Wave Xw = $transformedWaveName
				ReplaceWave/X/W=$theGraph trace=$oneTrace, Xw
				theWaveNote += "OldWave="+GetWavesDatafolder(oldXw, 2)+";"
				Wave w = TraceNameToWaveRef(theGraph, oneTrace)
				theWaveNote += "OldYWave="+GetWavesDatafolder(w, 2)+";"
			endif
			Note/K Xw
			Note Xw, partialWaveNote+theWaveNote
			i -= 1																	// JW 210914 as before: do it backwards
		while (1)
	else
		i = ntraces - 1																// JW 210914 Backward...
		do
			oneTrace = StringFromList(i, newTraces)
			if (strlen(oneTrace) == 0)
				break
			endif
			// JW 210914 Removed protection against duplicate traces
			Wave w = TraceNameToWaveRef(theGraph, oneTrace)
			transformedWaveName = NameOfWave(w)+"_T"
			theWaveNote = "TransformAxis="+oneAxis+";"
			theWaveNote += "AxisType=Y;"
			if (!WaveWaveContainsWave(originalwaves, w))							// JW 210914 Only do it once
				InsertPoints originalWavesIndex, 1, originalwaves
				originalwaves[originalWavesIndex] = w
				Duplicate/O w, $transformedWaveName
				Wave wDup = $transformedWaveName
				wDup = axisFunc(pw, w)
				DepVarName = "TransformDependencyVar"
				DepVarName = UniqueName(DepVarName, 4, 0)
				Variable/G $DepVarName
				NVAR depvar = $DepVarName
				DepFormula = "YAxisDataDependency(\""+theFunc+"\","	// YAxisDataDependency(theFunc, RawYData, TransformYData, CoefW)
				DepFormula += GetWavesDatafolder(w,2)+","
				DepFormula += GetWavesDatafolder(wDup,2)+","
				DepFormula += GetWavesDatafolder(pw,2)+")"
				SetFormula depvar, DepFormula
			endif
			Wave wDup = $transformedWaveName
			ReplaceWave/W=$theGraph trace=$oneTrace, wDup
			theWaveNote += "OldWave="+GetWavesDatafolder(w, 2)+";"
			Note/K wDup
			Note wDup, partialWaveNote+theWaveNote
			i -= 1																	// JW 210914 backwards. Should replace with a for loop!
		while (1)
	endif
	
	return 0		// success
end

Function/S TransformedWaveNotePreamble(theGraph, theAxis, axisLeftValue, axisRightValue)
	String theGraph, theAxis
	Variable axisLeftValue, axisRightValue

	String StrAxisLeft
	sprintf StrAxisLeft, "%.14g", axisLeftValue
	String StrAxisRight
	sprintf StrAxisRight, "%.14g", axisRightValue

	String partialWaveNote = "SETAXISFLAGS="+StringByKey("SETAXISFLAGS", AxisInfo(theGraph,theAxis))+";"
	partialWaveNote += "AXISLEFT="+StrAxisLeft+";"		// this value will be used when un-doing the axis to restore the original axis range, if it was user-scaled
	partialWaveNote += "AXISRIGHT="+StrAxisRight+";"	// this value will be used when un-doing the axis to restore the original axis range, if it was user-scaled
	partialWaveNote += "RECREATION="+GetAxisRecreation(theGraph, theAxis)+";"
	
	return partialWaveNote
end

//*****************************
// This function does the actual work of creating transformed data waves and replacing the waves in the graph
//
// Things yet to deal with:
//		If axis has a hard-balled range, we have to transform that range
//		
//*****************************

Function SetupTransformTraces(theGraph, theAxis, theFunc, FuncCoefWave, numTicks, wantMinor, minSep, TicksAtEnds [,doScientific, doTrimZeros])
	String theGraph
	String theAxis
	String theFunc
	Wave/Z FuncCoefWave
	Variable numTicks, wantMinor, minSep		// info to be stored away later for referencing by TicksForTransformAxis()
	Variable TicksAtEnds						// if 1, try to add major ticks at the ends of the axis
	Variable doScientific						// ST: 210524 - new optional parameter for scientific axes
	Variable doTrimZeros						// ST: 221105 - new optional parameter to toggle zero removal in version 1.38
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
	String saveDF = GetDatafolder(1)
	
	Variable dummy, dataMin, dataMax, axisMinimum, axisMaximum
	if (WaveExists(FuncCoefWave))
		Duplicate/free/D FuncCoefWave, dummyPWave_free		// ST: 210524 - create just a temporary wave for AxisTransformableDataMinMax() for now
	else
		Make/D/free/N=1 dummyPWave_free
	endif
	Wave dpw = dummyPWave_free
	
	FUNCREF TransformAxisTemplate axisFunc=$theFunc


	// need to run this before the data are transformed and the graph waves replaced
	try
		AxisTransformableDataMinMax(theGraph, theAxis, theFunc, dpw, dataMin, dataMax)		// dataMin and dataMax are in raw units
	catch
		DoAlert 0, "Transform Axis encountered serious problems with the transformation function, and is bailing out."
		return -1
	endtry
	if ( (numtype(dataMin) == 2) || (numtype(dataMax) == 2) )
		DoAlert 0, "The transform function "+theFunc+" failed to return any good transformed points within the range of your data."
		return -1
	endif
	Variable AxisWasAutoScaled = IsAutoScaled(theGraph, theAxis)

	String traces = AxisTraceList(theGraph, theAxis)
	// JW 210904 Removed protection against duplicate traces

	// Make the appropriate datafolder to hold waves and variables specific to this graph
	String graphFolderName = folderForThisGraph(theGraph, 0, FullPath = 0)
	if (strlen(graphFolderName) == 0)			// the graph doesn't have a folder yet
		graphFolderName = makeUniqueDFNameForGraph(theGraph, 0)
		NewDatafolder/O/S $("root:Packages:"+graphFolderName)
	else
		SetDataFolder root:Packages:
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

	String oneTrace
	Variable numTraces = ItemsInList(traces)
	String theWaveNote = ""

	// We always need a coefficient wave even if the function doesn't use it.
	if (WaveExists(FuncCoefWave))
		//String/G funcCoefSource = GetWavesDataFolder(FuncCoefWave,2)		// ST: 210609 - save the coef location for later updates
		Duplicate/O/D FuncCoefWave, dummyPWave
		SetFormula dummyPWave, GetWavesDataFolder(FuncCoefWave, 2)			// ST: 210731 - setup a wave dependency for updates
	else
		Make/D/O/N=1 dummyPWave
	endif
	Wave pw = dummyPWave

	// we need to store away information on the present axis scaling and range so that we can put it back if the axis is un-transformed
	GetAxis/W=$theGraph /Q $theAxis
	Variable oldAxisLeft = V_min
	Variable oldAxisRight = V_max
	
	// Store information about the original axis in the wave note so that we can restore the axis to exactly the same appearance it had before
	// making the transform axis. The information will stored into the wave note by TransformAxisTransformNewTraces().
	String partialWaveNote = TransformedWaveNotePreamble(theGraph, theAxis, oldAxisLeft, oldAxisRight)
	
	Variable/G doTicksAtEnds = TicksAtEnds
	Variable/G DoAutoScale = AxisWasAutoScaled
	Variable/G transformedAxisleft = axisFunc(pw, oldAxisLeft)				// to be used only if DoAutoScale is zero
	Variable/G transformedAxisRight = axisFunc(pw, oldAxisRight)			// to be used only if DoAutoScale is zero
	
	TransformAxisTransformNewTraces(theGraph, theAxis, traces, theFunc, pw, oldAxisLeft, oldAxisRight)

	if ( (numtype(transformedAxisleft) == 0) && (numtype(transformedAxisRight) == 0) && !AxisWasAutoScaled)	// ST: 210610 - if possible properly scale the axis to the transformed values
		if (transformedAxisRight < transformedAxisleft)
			Variable temp = transformedAxisRight
			transformedAxisRight = transformedAxisleft
			transformedAxisleft = temp
		endif
		SetAxis/W=$theGraph $theAxis, transformedAxisleft, transformedAxisRight
	endif
	
	// store variables for deciding when the axis range has changed, but use NaN so the first time an update is guaranteed
	Variable/G MainAxisMin = NaN		
	Variable/G MainAxisMax = NaN
	Variable/G MainAxisLength = NaN

	Variable/G nticks = numTicks
	Variable/G doMinor = wantMinor
	Variable/G minTickSep = minSep
	Variable/G doTicksAtEnds = doTicksAtEnds
	Variable/G doScientificFormat=ParamIsDefault(doScientific) ? 0 : doScientific	// ST: 210524 - add direct creation of scientific axes
	Variable/G doRemoveExtraZeroes=ParamIsDefault(doTrimZeros) ? 1 : doTrimZeros	// ST: 221105 - toggle zero removal

	String toplevelWindow = StringFromList(0, theGraph, "#")
	SetWindow $toplevelWindow, hook(TransformAxisHook)=TransformAxisWindowHook1_2

	SetDatafolder ::
	SetWindow $theGraph, UserData(TransAxFolder) = GetDatafolder(2)
	SetWindow $theGraph, UserData(TransAxVersion) = num2str(TRANSFORMAXISVERSION)
	
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

static Function IsAutoScaled(theGraph, theAxis)
	String theGraph, theAxis
	
	Variable yesitis = 1
	String setaxisflags = StringByKey("SETAXISFLAGS", AxisInfo(theGraph, theAxis))
	if (StrSearch(setaxisflags, "/A", 0) < 0)
		yesitis = 0
	endif
	
	return yesitis
end

// Does not use try-catch to check the calls to the axis function. The calling code should do to manage a graceful exit from trying to use the function.
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
	Variable funcValue
	
	Variable i,j
	for (i = 0; i < numTraces; i += 1)
		oneTrace = StringFromList(i, traces)
		Wave/Z yw = TraceNameToWaveRef(theGraph, oneTrace)
		if (isXAxis)
			Wave/Z xw = XWaveRefFromTrace(theGraph, oneTrace)
			if (WaveExists(xw))
				for (j = 0; j < numpnts(yw); j += 1)
					funcValue = theFunc(dummyPWave, xw[j])
					if (numtype(funcValue) == 0)
						dataMin = min(dataMin, xw[j])
						dataMax = max(dataMax, xw[j])
						foundAGoodPoint = 1
					endif
				endfor
			else
				for (j = 0; j < numpnts(yw); j += 1)
					aNum = pnt2x(yw, j)
					funcValue = theFunc(dummyPWave, aNum)
					if (numtype(funcValue) == 0)
						dataMin = min(dataMin, aNum)
						dataMax = max(dataMax, aNum)
						foundAGoodPoint = 1
					endif
				endfor
			endif
		else
			for (j = 0; j < numpnts(yw); j += 1)
				funcValue = theFunc(dummyPWave, yw[j])
				if (numtype(funcValue) == 0)
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
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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

Function GetTransAxVersionFromGraph(theGraph)
	String theGraph

	Variable version = Str2Num(GetUserData(theGraph, "", "TransAxVersion"))
	if (numtype(version) != 0)
		version = 0					// The earliest possible "version"
	endif

	return version
end	
	
// new named hook as of versin 1.2. It takes over the duties of the old hook function.
// JW 210916 This code used to assume that the window hook is attached to a top-level
// graph window. But now a transform axis may be part of a subwindow graph contained
// in a panel, layout or graph
Function TransformAxisWindowHook1_2(H_Struct)
	STRUCT WMWinHookStruct &H_Struct

	String theWindow = H_Struct.winName
	
	strSwitch (H_Struct.eventName)
		case "activate":
			TA_PatchUpDuplicatedGraphs(theWindow)
			break
		case "kill":
			return HandleKillEvent(theWindow, 0)
			break
		case "subwindowKill":
			return HandleKillEvent(theWindow, 1)
			break
		case "resize":
			HandleResizeOrModifiedEvent(theWindow, H_Struct.eventCode)
			break
		case "modified":
			// JW 191105 The process of un-transforming an axis in a graph with more than one
			// transform axis will trigger modified events that can run this code during the
			// removal processing. That can cause surprising things, like the removed transformed
			// wave trace being put back before the transformed wave can be killed!
			String removaldata = GetUserData(theWindow, "", "TA_Removal")
			if (strlen(removaldata) > 0)
				break
			endif
			TA_PatchUpDuplicatedGraphs(theWindow)
			HandleResizeOrModifiedEvent(theWindow, H_Struct.eventCode)
			return 1			// ST: 210710 - block calls from within HandleResizeOrModifiedEvent
			break
	endswitch
	return 0
end

// find traces associated with a given axis that haven't been transformed yet.
Function/S ListAddedTracesOnTransAxis(theGraph, theAxis)
	String theGraph, theAxis
	
	String traces = AxisTraceList(theGraph, theAxis)
	Variable i
	Variable nTraces = ItemsInList(traces)
	String outputList = ""
	
	for (i = 0; i < nTraces; i += 1)
		String aTrace = StringFromList(i, traces)
		if (isHorizAxis(theGraph, theAxis))
			Wave/Z w = XWaveRefFromTrace(theGraph, aTrace )
		else
			Wave w = TraceNameToWaveRef(theGraph, aTrace )
		endif
		if (WaveExists(w))
			String wnote = note(w)
			String TA_AxisKeyValue = StringByKey("TransformAxis", wnote, "=", ";")
		else
			TA_AxisKeyValue = ""
		endif
		if (strlen(TA_AxisKeyValue) == 0)
			outputList += aTrace+";"
		endif
	endfor
	
	return outputList
end

// ST: 210609 - find transformed traces associated with a given axis that have been removed by the user.
Function/S ListRemovedTracesOnTransAxis(theGraph, theAxis)
	String theGraph, theAxis
	
	String saveDF = GetDatafolder(1)
	if (SetGraphAndAxisDataFolder(theGraph, theAxis))		// if setting the folder does not work, then it is probably a mirror axis -> exit
		SetDatafolder $saveDF								// mirror axes do not need any handling of removed traces
		return ""
	endif
	Variable isXAxis = IsHorizAxis(theGraph, theAxis)
	String traces = ReplaceString("'",AxisTraceList(theGraph, theAxis,getXwave=isXAxis),"")
	String waves = ""
	if (isXAxis)
		waves = WaveList("*_TX", ";", "")
	else
		waves = WaveList("*_T", ";", "")
	endif
	String leftOver = RemoveFromList(traces,waves)
	
	SetDatafolder $SaveDF
	if (CmpStr(leftOver,waves) == 0)						// something is wrong when the output includes ALL waves
		return ""
	else
		return leftOver
	endif
end

Function/S GetFirstTraceName(theGraph, theAxis)
	String theGraph, theAxis
	
	String traces = AxisTraceList(theGraph, theAxis)
	return StringFromList(0, traces)
end

Function/S GetTransformAxisNoteFromTrace(theGraph, theAxis, theTrace)
	String theGraph, theAxis, theTrace

	if (IsHorizAxis(theGraph, theAxis))
		Wave w = XWaveRefFromTrace(theGraph, theTrace)		// transformed traces are never waveform traces so this should never fail
	else
		Wave w = TraceNameToWaveRef(theGraph, theTrace)
	endif
	return note(w)
end

// This function handles both modified and resize events because both events can result from actions that require
// that the ticks be recomputed. A resize event implies that the axis length, and therefor the tick layout, may have changed.
// A modified event can be a result of adding a new trace to the graph, which then needs to be accounted for and possibly transformed.
// Also used to implement the RefreshGraph() function, which is tied to the Graph->Transform Axis->Refresh Graph menu item.
Function HandleResizeOrModifiedEvent(theGraph, event)
	String theGraph
	Variable event
	
	String topLevelWindow = StringFromList(0, theGraph, "#")
	
	String theAxes = AxisList(theGraph)
	String oneAxis
	// JW 191204 Looks like at some point I changed the meaning of the return value- below there were two places
	// where retVal was set to 1 but they were commented. So this function always returns zero now.
	Variable retVal = 0
	
	String saveDF = GetDatafolder(1)

	Variable axisLength, newSize

	// If this function is called during the process of removing a transform axis, lots of bad things can happen
	String removaldata = GetUserData(theGraph, "", "TA_Removal")
	if (strlen(removaldata) > 0)
		return 0
	endif
	
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
			NVAR DoAutoScale
			NVAR transformedAxisleft
			NVAR transformedAxisright
			NVAR/Z MainAxisLength
			if (!NVAR_Exists(MainAxisLength))
				Variable/G MainAxisLength=NaN
			endif
			NVAR/Z doScientificFormat
			if (!NVAR_Exists(doScientificFormat))
				Variable/G doScientificFormat=0
			endif
			NVAR/Z doRemoveExtraZeroes							// ST: 221105 - new option to toggle zero removal in ver. 1.38
			if (!NVAR_Exists(doRemoveExtraZeroes))
				Variable/G doRemoveExtraZeroes=1				// ST: 221105 - default is on
			endif
			SVAR axisTransformFunction
			
			// SVAR/Z funcCoefSource
			// Wave dummyPWave
			// if (SVAR_Exists(funcCoefSource))					// ST: 210609 - update any new coef values from the original source
				// Wave/Z funcCoefWave = $funcCoefSource
				// if (WaveExists(funcCoefWave))
					// if(!EqualWaves(FuncCoefWave,dummyPWave,1))	// ST: 210730 - only copy the wave if something has changed (prevents triggering an infinite modify loop)
						// Duplicate/O/D funcCoefWave, dummyPWave
					// endif
				// endif
			// endif
			Wave pw = dummyPWave
			
			String newTraces = ListAddedTracesOnTransAxis(theGraph, oneAxis)
			if (strlen(newTraces) != 0)
//print "Added new traces: ", newTraces
				String firsttrace = GetFirstTraceName(theGraph, oneAxis)
				String wnote = GetTransformAxisNoteFromTrace(theGraph, oneAxis, firsttrace)
				Variable AxisLeft = NumberByKey("AXISLEFT", wnote, "=", ";")
				Variable AxisRight = NumberByKey("AXISRIGHT", wnote, "=", ";")
				TransformAxisTransformNewTraces(theGraph, oneAxis, newTraces, axisTransformFunction, pw, AxisLeft, AxisRight)
				MainAxisLength = NaN		// to trigger re-ticking below
				String cmd = " TicksForTransformAxis("
				cmd += "\""+theGraph+"\","
				cmd += "\""+oneAxis+"\","
				cmd += num2str(nticks)+","
				cmd += num2str(doMinor)+","
				cmd += num2str(minTickSep)+","
				cmd += "\"\","
				cmd += num2str(doTicksAtEnds)+","
				cmd += num2str(doScientificFormat)+","
				cmd += num2str(doRemoveExtraZeroes)+")"
				Execute/P/Q cmd
				SetDatafolder $saveDF
				return 0
			endif
			
			String removedTraces = ListRemovedTracesOnTransAxis(theGraph, oneAxis)		// ST: 210609 - check for transformed traces which have been removed by the user
			if (strlen(removedTraces))
//print "Removed traces: ", removedTraces
				RemovedTraceDependencyfromTransAxis(theGraph, oneAxis, removedTraces)
				SetDatafolder $saveDF
				return 0
			endif
			
			String currTraces = ReplaceString("'",AxisTraceList(theGraph, oneAxis),"")	// ST: 210731 - check if any trace has been offset or scaled
			Variable tr_i
			for ( tr_i = 0; tr_i < ItemsInList(currTraces); tr_i += 1) 
				Variable xOff, yOff, xScale, yScale
				Variable isXAxis = IsHorizAxis(theGraph, oneAxis)
				String trace= StringFromList(tr_i,currTraces)
				String info = TraceInfo(theGraph,trace,0)
				sscanf StringByKey("offset(x)", info, "="), "{%f,%f}", xOff, yOff
				sscanf StringByKey("muloffset(x)", info, "="), "{%f,%f}", xScale, yScale
				if ( (xOff != 0 || xScale != 0) && isXAxis)
					ModifyGraph/W=$theGraph offset($trace)={0,}, muloffset($trace)={0,}
				endif
				if ( (yOff != 0 || yScale != 0) && !isXAxis)
					ModifyGraph/W=$theGraph offset($trace)={,0}, muloffset($trace)={,0}
				endif
			endfor
			
			axisLength = CalculateAxisLength(theGraph, oneAxis)
			newSize = MainAxisLength != axisLength

//print "GetAxis in event handler"
			GetAxis/Q/W=$theGraph $oneAxis
			Variable getAxisMin = V_min
			Variable getAxisMax = V_max
			Variable newRange = ( (transformedAxisleft != getAxisMin) || (transformedAxisright != getAxisMax) )
//print "HandleResizeOrModifiedEvent: axisLength = ",axisLength, " MainAxisLength = ", MainAxisLength, " event = ", event
//print "transformedAxisleft = ", transformedAxisleft, "getAxisMin = ", getAxisMin, "transformedAxisright = ", transformedAxisright, "getAxisMax = ", getAxisMax, "newRange = ", newRange
			
			Variable oldIsAutoScale = DoAutoScale						// ST: 210731 - preserve previous setting to revert back later
			if (numtype(transformedAxisleft*getAxisMin*transformedAxisright*getAxisMax) != 0)	// ST: 210731 - something is wrong, probably tick generation failed -> only set newRange if auto-scale is active, otherwise skip
				oldIsAutoScale = IsAutoScaled(theGraph, oneAxis)		// ST: 210731 - oldIsAutoScale needs to be set to successfully recover inside getUntransformedValuesForAxisRange()
				newRange = oldIsAutoScale								// ST: 210731 - auto-scale recovers from the fail-state -> go into newRange
			endif
			
			if (newRange)												// ST: 210711 - support direct scrolling via mouse wheel and axis range settings
				// rescaleMin and rescaleMax are the globals behind the panel's
				// min and max controls in the Range box
				NVAR panelMin = root:Packages:TransformAxis:rescaleMin
				NVAR panelMax = root:Packages:TransformAxis:rescaleMax
				
				DoAutoScale = IsAutoScaled(theGraph, oneAxis)				
				Variable isInverted = panelMin > panelMax && !DoAutoScale				// look for inverted axis settings in the panel
				
				Variable minVal = getAxisMin											// input is the (transformed) current axis scale
				Variable maxVal = getAxisMax
				FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
				getUntransformedValuesForAxisRange(theGraph, oneAxis, axisFunc, pw, minVal, maxVal, oldIsAutoScale)		// try to calculate the inverse (untransformed) values for the axis range
//print "newRange: transformed input = ", getAxisMin, getAxisMax			
//print "newRange: inverse output = ", minVal, maxVal

				if (numtype(maxVal) == 0 && numtype(minVal) == 0)						// if valid, apply new range
					DoWindow/F $topLevelWindow											// bring the graph to the top if not already (because mouse scrolling also works on background graphs)
					
					if ( (maxVal < minVal) == !isInverted)								// keep axis orientation
						Variable temp = maxVal
						maxVal = minVal
						minVal = temp
					endif
					
					if (!DoAutoScale)
						NewTransformAxisRange(theGraph, oneAxis, minVal, maxVal)		// set the graph to the new data range
					endif
					panelMin = minVal													// update panel range values
					panelMax = maxVal
					
					if (WinType("UnifiedTransformAxisPanel") == 7)						// update auto-scale and panel range controls
						NVAR LastMainTab = root:Packages:TransformAxis:LastMainTabUsed
						if (LastMainTab == 1)
							TransformRangeCheckBoxToggle("UnifiedTransformAxisPanel",DoAutoScale)
						endif
						if (LastMainTab == 2)
							Execute/P/Q "EditTicksGraphHasChanged()"					// handle graph updates (also updates the ticks list)
						endif
					endif
					if (WinType("ModTransformAxisPanel") == 7)
						NVAR LastModTab = root:Packages:TransformAxis:LastTabUsed
						if (LastModTab == 1)
							TransformRangeCheckBoxToggle("ModTransformAxisPanel",DoAutoScale)
						endif
					endif
				else																	// otherwise snap back to old values
					if (!oldIsAutoScale)
						SetAxis/W=$theGraph $oneAxis, transformedAxisleft, transformedAxisright
					endif
					newRange = 0
				endif
			endif
			
			// if (newRange)															// ST: 210616 - don't allow user range changes => force back to transformed values
				// NVAR/Z DoAutoScale
				// Variable autoScale = NVAR_Exists(DoAutoScale) ? DoAutoScale : 1
				// if (autoScale)
					// SetAxis/W=$theGraph/A $oneAxis
				// else
					// SetAxis/W=$theGraph $oneAxis, transformedAxisleft, transformedAxisright
				// endif
				// newRange = 0
			// endif
			
			if ( (event == TA_ResizeEvent) || newSize || newRange )
//print "calling TicksForTransformAxis() for transform axis"
				TicksForTransformAxis(theGraph, oneAxis, nticks, doMinor, minTickSep, "", doTicksAtEnds, doScientificFormat, doRemoveExtraZeroes)
//print "DONE calling TicksForTransformAxis() for transform axis"
				MainAxisLength = axisLength
			endif
		endif
		if (SetDataFolderForMirrorAxis(theGraph, oneAxis) == 0)
//print "HandleResizeOrModifiedEvent: theGraph = ",theGraph, " oneAxis = ", oneAxis
			NVAR nticks
			NVAR doMinor
			NVAR minTickSep
			SVAR MirrorAxis
			NVAR doTicksAtEnds
			NVAR/Z MainAxisLength
			if (!NVAR_Exists(MainAxisLength))
				Variable/G MainAxisLength=NaN
			endif
			NVAR/Z doScientificFormat
			if (!NVAR_Exists(doScientificFormat))
				Variable/G doScientificFormat=0
			endif
			NVAR/Z doRemoveExtraZeroes						// ST: 221105 - new option to toggle zero removal in ver. 1.38
			if (!NVAR_Exists(doRemoveExtraZeroes))
				Variable/G doRemoveExtraZeroes=1			// ST: 221105 - default is on
			endif
			GetAxis/W=$theGraph/Q $MirrorAxis				// ST: 211117 - check whether the mirror axis is actually there
			if (V_flag)
				TA_ErrorTextBox(theGraph, "The mirror axis "+MirrorAxis+" is not used on "+theGraph+".\rThe transformed axis may be broken.")
				break
			endif
			
			// SVAR/Z funcCoefSource
			// if (SVAR_Exists(funcCoefSource))				// ST: 210609 - update any new coef values from the original source
				// Wave/Z funcCoefWave = $funcCoefSource
				// if (WaveExists(funcCoefWave))
					// Duplicate/O/D FuncCoefWave, dummyPWave
				// endif
			// endif
			
			axisLength = CalculateAxisLength(theGraph, oneAxis)
//print "HandleResizeOrModifiedEvent: axisLength = ",axisLength, " MainAxisLength = ", MainAxisLength, " event = ", event
//SVAR xxx
			newSize = MainAxisLength != axisLength
			if ( (event == TA_ResizeEvent) || newSize )
				TicksForTransformAxis(theGraph, oneAxis, nticks, doMinor, minTickSep, MirrorAxis, doTicksAtEnds, doScientificFormat, doRemoveExtraZeroes)
				MainAxisLength = axisLength
			endif
		endif
	while (1)
	
	SetDatafolder $saveDF
	
	return retVal
end

// ST: 210609 - deletes dependencies and transformed waves for traces which have been removed from the graph
Function RemovedTraceDependencyfromTransAxis(theGraph, theAxis, traceList)
	String theGraph, theAxis, traceList
	
	String saveDF = GetDatafolder(1)
	if (!strlen(traceList))
		return 0
	endif
	if (SetGraphAndAxisDataFolder(theGraph, theAxis))						// this should be a transformed axis (not a mirror axis)
		SetDatafolder $saveDF
		return -1
	endif
	
	String DepVarList = VariableList("TransformDependencyVar*", ";", 4)
	if (!strlen(DepVarList))												// something is wrong here -> exit
		SetDatafolder $saveDF
		return -1
	endif
	
	Variable var_i, wave_i
	for (var_i = 0; var_i < ItemsInList(DepVarList); var_i++)				// check all dependency variables
		String currVar = StringFromList(var_i, DepVarList)
		String formula = GetFormula($currVar)
		
		for (wave_i = 0; wave_i < ItemsInList(traceList); wave_i++)
			String currWave = StringFromList(wave_i, traceList)
			Wave w = $currWave
			if (StringMatch(formula,"*"+NameOfWave(w)+"*"))					// if the dependency matches with one of the removed waves then delete the dependency
				NVAR depvar = $currVar
				SetFormula depvar, ""
				KillVariables depvar
				DoUpdate
				KillWaves/Z w
				traceList = RemoveFromList(currWave,traceList)
				break
			endif
		endfor
	endfor

	SetDatafolder $saveDF
	return 0
End

Function getUntransformedValuesForAxisRange(theGraph, theAxis, axisFunc, pw, minVal, maxVal, autorange)			// calculates inverse values for a transformed input, such as axis start and end points
	String theGraph, theAxis
	FUNCREF TransformAxisTemplate axisFunc
	Wave pw
	Variable &minVal, &maxVal								// the values to be inversed (input = transformed values, output = untransformed values)
	Variable autorange
	
	Variable transformedLeftValue = minVal
	Variable transformedRightValue = maxVal
	
	if (transformedRightValue < transformedLeftValue)
		Variable temp = transformedRightValue
		transformedRightValue = transformedLeftValue
		transformedLeftValue = temp
	endif
	
	NVAR/Z AxisMin
	NVAR/Z AxisMax
	Variable funcValue, tempBracket, newBracket	
	Variable lowBracket, highBracket
	
	Variable rawdataMin, rawdataMax							// ST: 210730 - use the exact same code as in the old setTransformAxisRange()
	if (!autorange)
		if (!NVAR_Exists(AxisMin) || !NVAR_Exists(AxisMax))
			autorange = 1
		else
			lowBracket = min(AxisMax, AxisMin)
			highBracket = max(AxisMax, AxisMin)
		endif
	endif
	if (autorange)
		AxisDataMinMax(theGraph, theAxis, rawdataMin, rawdataMax)
		lowBracket = rawdataMin
		highBracket = rawdataMax
	endif
	
	tempBracket = axisFunc(pw, lowBracket)					// find transformed value for the current low bracket
	if ( (tempBracket >= transformedLeftValue) && (tempBracket <= transformedRightValue) )			// min bracket is inside the axis range- we need to expand
		do
			newBracket = 2*lowBracket - highBracket			// double the bracket range
			funcValue = axisFunc(pw, newBracket)
			if (numtype(funcValue) != 0 || numtype(newBracket) != 0)								// make sure the new bracket value transforms successfully
				newBracket = FindTransformLimit(axisFunc, pw, lowBracket, newBracket)				// no- find the limiting transform value
				break
			endif
			lowBracket = newBracket							// ST: 210619 - this needs to be inside the loop
			tempBracket = funcValue
		while ( (tempBracket > transformedLeftValue) && (tempBracket < transformedRightValue) )
		lowBracket = newBracket
	endif

	tempBracket = axisFunc(pw, highBracket)					// make sure high bracketing value is OK
	if ( (tempBracket >= transformedLeftValue) && (tempBracket <= transformedRightValue) )
		do
			newBracket = 2*highBracket - lowBracket			// double the bracket range
			funcValue = axisFunc(pw, newBracket)
			if (numtype(funcValue) != 0 || numtype(newBracket) != 0)
				newBracket = FindTransformLimit(axisFunc, pw, highBracket, newBracket)
				break
			endif
			highBracket = newBracket						// ST: 210619 - this needs to be inside the loop
			tempBracket = funcValue
		while ( (tempBracket > transformedLeftValue) && (tempBracket < transformedRightValue) )
		highBracket = newBracket
	endif

	maxVal = getInverseValueWithinBounds(maxVal, HighBracket, LowBracket, 1e-14, axisFunc, pw)
	minVal = getInverseValueWithinBounds(minVal, HighBracket, LowBracket, 1e-14, axisFunc, pw)
	return 0
End



// Provided for those who use Transform Axis from their own code.
// Closes a graph containing a transform axis without putting up the alert asking if you want to save the transform axis data.
// Set saveTransformData to 0 if you do not want to save the transform axis data. Use this if you will not save a recreation macro and you don't need to use the graph again.
// Set saveTransformData to 1 if DO want to save the data. This is necessary if you want to recreate the graph from a recreation macro.
Function CloseTransformAxisGraph(theGraphName, saveTransformData)
	String theGraphName			// set to "" to close the top graph
	Variable saveTransformData		// set to 1 to save the data folders associated with thie graph. Do this if you have saved a recreation macro and you want to save the data that goes with the axes
									// set to 0 to NOT save the data folders. Do this if you are truly getting rid of all traces of the graph, and you don't need to re-create it later.
	
	if (strlen(theGraphName) == 0)
		theGraphName = getTopGraph()		// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraphName) != 1)
		return 0							// not a graph
	endif
	
	Variable isSubwindowGraph = (StrSearch(theGraphName, "#", 0) >= 0)
	
	String saveDF = GetDataFolder(1)
	if (SetGraphDataFolder(theGraphName))
		SetDataFolder $saveDF				// not a graph with a transform axis
		return 0
	endif
	
	Variable/G KillWithoutAlertSaveDataFlag = saveTransformData
	SetDataFolder $saveDF

	if (isSubwindowGraph)
		KillWindow $theGraphName
	else
		DoWindow/K $theGraphName			// will trigger the window hook, which will run HandleKillEvent()	
	endif
end

static Function/S TA_ListAllChildGraphs(String topWindow)
end

static Function/S TA_ListAllGraphs()
	String allContainerWindows = WinList("*", ";", "WIN:69")
	Variable nwindows = ItemsInList(allContainerWindows)
	Variable i
	String allGraphs = ""
	
	for (i = 0; i < nwindows; i++)
		String oneWindow = StringFromList(i, allContainerWindows)
		if (WinType(oneWindow) == 1)
			allGraphs += oneWindow + ";"
		endif
		String childGraphs = TA_ListAllChildGraphs(oneWindow)
		allGraphs += childGraphs
	endfor
end

// Performs that actual test that a given graph, either top-level or subwindow, uses the given data folders
// for a transform axis, distinguishing transform vs mirror uses
static Function [Variable usesTransform, Variable usesMirror] TA_DFinUseByGraph(String gname, String transformDFFullPath, String mirrorDFFullPath)
		Variable tuse = 0
		Variable muse = 0
		String theTransformDF = GetUserData(gname, "", "TransAxFolder")
		String theMirrorDF = GetUserData(gname, "", "TransAxMirrorFolder")
		if (strlen(transformDFFullPath) > 0 && cmpstr(theTransformDF, transformDFFullPath) == 0)
			tuse = 1
		endif
		if (strlen(mirrorDFFullPath) > 0 && cmpstr(theMirrorDF, mirrorDFFullPath) == 0)
			muse = 1
		endif
		
		return [tuse, muse]
end

// Given a window, if it is a graph, tests to see if it uses the given data folder paths.
// Then recursively applies the test to any child subwindows.
static Function [Variable transformUse, Variable mirrorUse] TA_UseCountForTAFolderInGraph(String windowname, String transformDFFullPath, String mirrorDFFullPath)
	if (wintype(windowname) == 1)
		[Variable tuse, Variable muse] = TA_DFinUseByGraph(windowname, transformDFFullPath, mirrorDFFullPath)
		transformUse += tuse
		mirrorUse += muse
	endif

	String children = ChildWindowList(windowname)
	Variable nchildren = ItemsInList(children)
	if (nchildren > 0)
		Variable j
		for (j = 0; j < nchildren; j++)
			String child = StringFromList(j, children)
			String childpath = windowname + "#" + child
			// Recursive
			[transformUse, mirrorUse] = TA_UseCountForTAFolderInGraph(childpath, transformDFFullPath, mirrorDFFullPath)
		endfor
	endif
end

// This function is called from TA_PatchUpDuplicatedGraphs(). The calling function cycles through all
// the graphs looking for graphs that contain transform axes. If it finds one, it calls this function which then
// goes through all graphs looking for any graph that uses the same transform axis graph folder and counts the
// number of times that happens.
static Function [Variable transformUse, Variable mirrorUse] TA_UseCountForTAFolder(String transformDFFullPath, String mirrorDFFullPath)
	String wlist = WinList("*", ";", "WIN:69")			// any window type that can contain a subwindow
	Variable nwins = ItemsInList(wlist)
	Variable i
	transformUse = 0
	mirrorUse = 0
	for (i = 0; i < nwins; i++)
		String awin = StringFromList(i, wlist)
		[transformUse, mirrorUse] = TA_UseCountForTAFolderInGraph(awin, transformDFFullPath, mirrorDFFullPath)
	endfor

	return [transformUse, mirrorUse]
end

// If the use count for a transform axis graph folder as determined by TA_UseCountForTAFolder() is greater than one,
// then some graph(s) need to be patched up because more than one graph using the same transform data is bad.
// This function determines which graph should actually own the original data folder and leaves it alone.
// Other graphs using that same folder are patched:
// 	A duplicate of the original data folder is made
//		The graph's user data that identifies it's transform graph folder is changed to point to the new folder
// That's all that's necessary to patch up a Transform Mirro axis.
// If the graph contains a Transform Axis (not mirror) then there is a transformed wave. Things must be reconnected:
//		Each trace needs to have the transformed data wave from the old folder replaced with waves in the new one.
//		The transformation is driven by a dependency formula:
//			A dummy variable is used as the target for a function that does the transformation. Because that variable
//				was duplicated, its dependency formula must be re-written to point to data in the new folder.
//		The actual ticks and tick labels use user ticks from waves. That must be correct with a new ModifyGraph userticks call.

static Function TA_PatchUpOverusedDFforTransform(String theGraph, String theTransformDF)
	String transformLeafName = ParsefilePath(0, theTransformDF, ":", 1, 0)
	String graphsTransformDFName = TA_MakeDFNameForThisGraph(theGraph, TransformType)
	if (CmpStr(graphsTransformDFName, transformLeafName) == 0)
		// This is the proper owner of the data folder
	else
		DFREF savedf = GetDataFolderDFR()

		// This graph should not be using this data folder, so we have to copy the old data folder and
		// patch up the graph to use the stuff from the duplicated folder
		SetDataFolder root:Packages

		String NewTransformName = makeUniqueDFNameForGraph(theGraph, TransformType)
		DuplicateDataFolder $transformLeafName, $NewTransformName
		SetWindow $theGraph, UserData(TransAxFolder) = "root:Packages:"+NewTransformName+":"

		SetDataFolder :$NewTransformName

		Variable i,j

		String traces = TraceNameList(theGraph, ";", 1)
		Variable numtraces = ItemsInList(traces)
		for (i = 0; i < numtraces; i++)
			String oneTrace = StringFromList(i, traces)

			// Run through the Y waves for each trace, looking for ones that match the folder path of the old graph
			Wave ywave = TraceNameToWaveRef(theGraph, oneTrace)
			String ywavepath = GetWavesDataFolder(ywave, 2)
			if (StringMatch(ywavepath, theTransformDF+"*"))
				ywavepath = ReplaceString(":"+transformLeafName+":", ywavepath, ":"+NewTransformName+":")
				Wave/Z newYWave = $ywavepath
				if (WaveExists(newYWave))
					ReplaceWave/W=$theGraph trace=$oneTrace, newYWave
				endif
			endif
			
			// ST: 210930 - check if there was a transformed wave which is however not yet in the graph (happens with style macros)
			DFREF TransAxDFR = $ReplaceString(":"+transformLeafName+":", theTransformDF, ":"+NewTransformName+":")
			String TransAxList = DataFolderList("AxisTransform_*", ";" , TransAxDFR)
			for (j = 0; j < ItemsInList(TransAxList); j++)
				DFREF axisDF = TransAxDFR:$(StringFromList(j, TransAxList))
				Wave/Z oldTransformedWave = axisDF:$(NameOfWave(ywave)+"_T")
				if (WaveExists(oldTransformedWave))
					String wNote = Note(oldTransformedWave)
					if (CmpStr(StringByKey("OldWave", wNote, "=", ";"), ywavepath) == 0 || CmpStr(StringByKey("OldYWave", wNote, "=", ";"), ywavepath) == 0)
						ReplaceWave/W=$theGraph trace=$oneTrace, oldTransformedWave
					endif
				endif
			endfor
			
			// Run through the X waves for each trace, looking for ones that match the folder path of the old graph
			Wave/Z xwave = XWaveRefFromTrace(theGraph, oneTrace)
			if (WaveExists(xwave))
				String xwavepath = GetWavesDataFolder(xwave, 2)
				if (StringMatch(xwavepath, theTransformDF+"*"))
					xwavepath = ReplaceString(":"+transformLeafName+":", xwavepath, ":"+NewTransformName+":")
					Wave/Z newXWave = $xwavepath
					if (WaveExists(newXWave))
						ReplaceWave/W=$theGraph/X trace=$oneTrace, newXWave
					endif
				endif
			endif
		endfor

		j = 0
		do
			String dfname = GetIndexedObjName(":", 4, j)
			if (strlen(dfname) == 0)
				break
			endif

			SetDataFolder $dfname

			String varlist = VariableList("TransformDependencyVar*", ";", 4)
			Variable numberOfVars = ItemsInList(varlist)
			for (i = 0; i < numberOfVars; i++)
				String onevarname = StringFromList(i, varlist)
				NVAR onevar = $onevarname
				String formula = GetFormula($onevarname)
				// Presently, formula contains a dependency formula referencing the transformed wave
				// in the original data folder. Patch the formula to point to the new one:
				formula = ReplaceString(":"+transformLeafName+":", formula, ":"+NewTransformName+":")
				SetFormula onevar, formula
			endfor

			SVAR actualAxisName
			if (SVAR_Exists(actualAxisName))
				Wave tickVals
				Wave/T tickLabels
				ModifyGraph/W=$theGraph userticks($actualAxisName) = {tickVals, tickLabels}
			endif

			SetDataFolder ::
			j++
		while(1)
		SetDataFolder savedf
	endif
end

static Function/S TA_PatchUpOverusedDFforMirror(String theGraph, String theMirrorDF)
	String mirrorLeafName = ParsefilePath(0, theMirrorDF, ":", 1, 0)
	String graphsMirrorDFName = TA_MakeDFNameForThisGraph(theGraph, MirrorType)
	if (CmpStr(graphsMirrorDFName, mirrorLeafName) == 0)
		// This is the proper owner of the data folder
		return mirrorLeafName
	else
		DFREF savedf = GetDataFolderDFR()

		// This graph should not be using this data folder, so we have to copy the old data folder. A Transform Mirror axis
		// simply needs a duplicated data folder, and to change the user data pointing to it. None of the data folder data
		// is actually used as part of the graph, unlike the case for a regular Transform axis.
		SetDataFolder root:Packages

		String NewMirrorName = makeUniqueDFNameForGraph(theGraph, MirrorType)
		DuplicateDataFolder $mirrorLeafName, $NewMirrorName
		SetWindow $theGraph, UserData(TransAxMirrorFolder) = "root:Packages:"+NewMirrorName+":"

		SetDataFolder savedf
		return NewMirrorName
	endif
end

Function TA_PatchUpDuplicatedGraph(String theWindow)
	DFREF savedf = GetDataFolderDFR()
	
	String theTransformDF = GetUserData(theWindow, "", "TransAxFolder")
	String theMirrorDF = GetUserData(theWindow, "", "TransAxMirrorFolder")
	Variable mirrorUse, transformUse, count
	[transformUse, mirrorUse] = TA_UseCountForTAFolder(theTransformDF, theMirrorDF)
	if (transformUse > 1)
		TA_PatchUpOverusedDFforTransform(theWindow, theTransformDF)
	endif
	if (mirrorUse > 1)
		String oldMirrorLeaf = ParsefilePath(0, theMirrorDF, ":", 1, 0)
		String newMirrorLeaf = TA_PatchUpOverusedDFforMirror(theWindow, theMirrorDF)
		DFREF mirroDFR = $ReplaceString(oldMirrorLeaf,theMirrorDF,newMirrorLeaf)
		
		// ST: 210926 - if a graph style was applied then the mirror axes do not yet exist in the new graph => create
		String TransAxList = DataFolderList("TransformMirror_*", ";" , mirroDFR)
		for (count = 0; count < ItemsInList(TransAxList); count++)
			DFREF axisDF = mirroDFR:$(StringFromList(count, TransAxList))
			SVAR MirrorAxis		= axisDF:MirrorAxis
			SVAR MainAxis		= axisDF:MainAxis
			SVAR AxRecreation	= axisDF:AxisRecreationString
			GetAxis/W=$theWindow /Q $MirrorAxis
			if (V_flag)		// axis is missing
				AddTrulyFreeAxisForAxis(theWindow, MainAxis)
				ApplyAxisRecreation(MirrorAxis, theWindow, AxRecreation, 0)
				ModifyGraph/W=$theWindow freePos($MirrorAxis)=0
				ModifyFreeAxis/W=$theWindow $MirrorAxis, master = $MainAxis, hook=TransformMirrorAxisHook
			endif
		endfor
	endif
	
	SetDataFolder savedf
end

Function TA_PatchUpDuplicatedGraphs(String theWindow)
	if (WinType(theWindow) == 1)
		TA_PatchUpDuplicatedGraph(theWindow)
	endif
	
	String children = ChildWindowList(theWindow)
	Variable nchildren = ItemsInList(children)
	if (nchildren > 0)
		Variable i
		for (i = 0; i < nchildren; i++)
			String child = StringFromList(i, children)
			String childpath = theWindow + "#" + child
			TA_PatchUpDuplicatedGraph(childpath)
		endfor
	endif
end

Function HandleKillEvent(String theGraph, Variable isSubwindowKill)
	String theAxes = AxisList(theGraph)
	String oneAxis
	Variable retVal = 0		// didn't do anything
	
	Execute/P/Q "UnifiedTransformAxisPanelUpdateTarget(\"UnifiedTransformAxisPanel\")"	// ST: 210913 - update the panel target, if possible
	
	String saveDF = GetDatafolder(1)
	if (SetGraphDataFolder(theGraph))
		SetDataFolder $saveDF
		return 0
	endif
	
//	if (!isSubwindowKill)
	NVAR/Z KillWithoutAlertSaveDataFlag
	if (!NVAR_Exists(KillWithoutAlertSaveDataFlag))
//		DoAlert 1, "You are closing a graph with transformed axes. Keep the transform axis info? \rClick Yes if you will save a recreation macro and intend to restore the graph later."
//		if (V_flag == 1)		// Yes was clicked
		if (hasGraphOrStyleMacro(theGraph, 0) || hasGraphOrStyleMacro(theGraph, 1))	// ST: 210926 - automatically determine whether to keep the folders => if a macro exists then keep
			SetDataFolder $saveDF
			return 0
		endif
	endif
	if (KillWithoutAlertSaveDataFlag == 1)
		SetDataFolder $saveDF
		return 0
	endif
//	endif

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

// ST: 210926 - searches for recreation or style macros and returns 1 if an existing macro contains TransAx code for the current window
static Function hasGraphOrStyleMacro(String theGraph, Variable wantStyle)
	String styleStr = SelectString(wantStyle, "", "Style")		// look for style macros instead of recreation macros
	String findGraph = MacroList(theGraph+styleStr,";","KIND:5,SUBTYPE:Graph"+styleStr)
	if (!strlen(findGraph))
		return 0
	endif
	String procLines = ProcedureText(theGraph+styleStr)
	if (strsearch(procLines,"hook(TransformAxisHook)",0) != -1)
		String folderLines = GrepList(procLines, "(.+)userdata\(TransAx(Mirror|)Folder\)(.+)", 0 , "\r")	// find folder related lines
		if (strlen(folderLines) && strsearch(procLines,GetDatafolder(1),0) != -1)   						// if the folder does not match then it was probably a macro for a previous version of this graph
			return 1	// found something
		endif
	endif
	return 0			// if we end up here nothing was found
End

// Causes a re-draw of the top graph as if it had been resized
// Does *not* handle the case where a trace has been added or removed. Only handles zooming, etc.
// which changes the range of the graph but doesn't trigger the hook function.
static Function RefreshGraph()

	String theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	HandleResizeOrModifiedEvent(theGraph, TA_ResizeEvent)
end

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function getInverseValueWithinBounds(theNum, HighBracket, LowBracket, precision, theFunc, theCoefWave)
	Variable theNum, HighBracket, LowBracket, precision
	FUNCREF TransformAxisTemplate theFunc
	Wave theCoefWave
	
	Variable funcValue
	funcValue = theFunc(theCoefWave,theNum)
	
	if (AlmostEqual(funcValue, HighBracket, precision))
		return HighBracket
	elseif (AlmostEqual(funcValue, LowBracket, precision))
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
// JW 210708 All calls set JustBracket to 1, so I have eliminated the axis-setting part of this code.

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function getTransformAxisRootBrackets(theGraph, theAxis, axisFunc, pw, transformedRightValue, transformedLeftValue, autorange, lowBracket, highBracket, useGetAxis)
	String theGraph
	String theAxis
	FUNCREF TransformAxisTemplate axisFunc
	Wave pw
	Variable &autorange				// input and output: if autorange==1 on input, we try to autorange. If it doesn't work out, we set this to zero and calculate some default axis range

	Variable &transformedRightValue	// both input and output; if autorange==0, it sets the right (top) value of the transform axis; if autorange==1, outputs the actual range of the axis
	Variable &transformedLeftValue	// both input and output; same for left (bottom) value
//	Variable justBracket			// input- if non-zero don't set the axis range, just calculate brackets for FindRoots
	
	Variable &lowBracket			// value to be used with /L flag with FindRoots
	Variable &highBracket			// value to be used with /H flag with FindRoots
	
	Variable useGetAxis			// if set, and autorange == 0, use GetAxis for the initial brackets. If not set and autorange = 0, use the global AxisMin and AxisMax
	
	Variable rawdataMin, rawdataMax
	Variable tbracketMin, tbracketMax
	Variable newBracket
	Variable transformSwapsAxis = 0
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()	// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
		Variable temp = transformedRightValue
		transformedRightValue = transformedLeftValue
		transformedLeftValue = temp
	endif
	
	// JW 210623 Try to make a reasonable guess at the brackets. 
	// We want the brackets to enclose the entire axis range if possible. If the
	// transformation in use isn't defined over that entire range, then later we shrink it.
	// If our guess here isn't good, then we expand the range.
	// lowBracket and highBracket are un-transformed values.
	// 
	NVAR/Z AxisMin
	NVAR/Z AxisMax
	Variable tlowbracket		// transformed value of the bracket having the lower magnitude, note that the transform function could make this the higher transformed value
	Variable thighbracket		// transformed value of the bracket having the higher magnitude, note that the transform function could make this the lower transformed value
	if (!autorange)
//		if (!NVAR_Exists(AxisMin) || !NVAR_Exists(AxisMax))
//			autorange = 1
//		else
			if (useGetAxis)
			GetAxis/Q/W=$theGraph $theAxis
				lowBracket = min(V_min, V_max)
				highBracket = max(V_min, V_max)
			else
				lowBracket = min(AxisMax, AxisMin)
				highBracket = max(AxisMax, AxisMin)
			endif
			tlowbracket = axisFunc(pw, lowBracket)
			thighbracket = axisFunc(pw, highBracket)
			if (numtype(tlowbracket) && !numtype(thighbracket))
				lowbracket = FindTransformLimit(axisFunc, pw, highbracket, lowbracket)
			elseif (!numtype(tlowbracket) && numtype(thighbracket))
				highbracket = FindTransformLimit(axisFunc, pw, lowbracket, highbracket)
			elseif (numtype(tlowbracket) && numtype(thighbracket))
				autorange = 1
			endif
//		endif
	endif
	if (autorange)
		// AxisDataMinMax() discards values that transform to NaN or Inf
		AxisDataMinMax(theGraph, theAxis, rawdataMin, rawdataMax)
		lowBracket = rawdataMin
		highBracket = rawdataMax
		// calling axisFunc here shouldn't cause a problem because the numbers came from AxisDataMinMax
		// and AxisDataMinMax already succeed with it (right?)
//		transformedRightValue = max(axisFunc(pw, rawdataMin), axisFunc(pw, rawdataMax))
//		transformedLeftValue = min(axisFunc(pw, rawdataMin), axisFunc(pw, rawdataMax))
	endif
	// at this point lowBracket and highBracket are known good numbers because if autorange, then we used AxisDataMinMax() to get them, and
	// AxisDataMinMax() checks for bad numbers. If !autorange, we checked the values above and re-set them to the function limits
	transformedRightValue = max(axisFunc(pw, lowBracket), axisFunc(pw, highBracket))
	transformedLeftValue = min(axisFunc(pw, lowBracket), axisFunc(pw, highBracket))
	
	if (numtype(transformedRightValue) == 1)
		print "Oops- infinite transformed right value"
	elseif (numtype(transformedLeftValue) == 1)
		print "Oops- infinite transformed left value"
	endif
	// JW 210623 Now we patch up problems with the brackets
	// make sure low bracketing value is OK
//	tbracketMin = axisFunc(pw, lowBracket)					// find transformed value for the current low bracket
//	Variable funcValue
//	if ( (tbracketMin >= transformedLeftValue) && (tbracketMin <= transformedRightValue) )			// min bracket is inside the axis range- we need to expand
//		do
//			newBracket = 2*lowBracket - highBracket			// double the bracket range
//			funcValue = axisFunc(pw, newBracket)
//			if (numtype(funcValue) != 0 || abs(newBracket) > 10^300)								// make sure the new bracket value transforms successfully
//				newBracket = FindTransformLimit(axisFunc, pw, lowBracket, newBracket)				// no- find the limiting transform value
//				break
//			endif
//			lowBracket = newBracket							// ST: 210619 - this needs to be inside the loop
//			tbracketMin = funcValue
//		while ( (tbracketMin > transformedLeftValue) && (tbracketMin < transformedRightValue) )
//		lowBracket = newBracket
//	endif
//	
//	// make sure high bracketing value is OK
//	tbracketMax = axisFunc(pw, highBracket)
//	if ( (tbracketMax >= transformedLeftValue) && (tbracketMax <= transformedRightValue) )
//		do
//			newBracket = 2*highBracket - lowBracket			// double the bracket range
//			funcValue = axisFunc(pw, newBracket)
//			if (numtype(funcValue) != 0 || abs(newBracket) > 10^300)
//				newBracket = FindTransformLimit(axisFunc, pw, highBracket, newBracket)
//				break
//			endif
//			highBracket = newBracket						// ST: 210619 - this needs to be inside the loop
//			tbracketMax = funcValue
//		while ( (tbracketMax > transformedLeftValue) && (tbracketMax < transformedRightValue) )
//		highBracket = newBracket
//	endif
//	
//	// now we have two good brackets. Make sure they are outside the range of the axis; if they aren't, set to NOT autorange and make up axis ranges
//	tbracketMin = axisFunc(pw, lowBracket)
//	tbracketMax = axisFunc(pw, highBracket)
//	if (tbracketMin > tbracketMax)
//		newBracket = tbracketMin
//		tbracketMin = tbracketMax
//		tbracketMax = newBracket
//		transformSwapsAxis = 1
//	endif
//	if ( (tbracketMin > transformedLeftValue) || (tbracketMax < transformedRightValue) )
//		autorange = 0
//		if (transformSwapsAxis)
//			if (tbracketMin > transformedLeftValue)
//				transformedLeftValue = axisFunc(pw, highBracket)
//			endif
//			if (tbracketMax < transformedRightValue)
//				transformedRightValue = axisFunc(pw, lowBracket)
//			endif
//		else
//			if (tbracketMin > transformedLeftValue)
//				transformedLeftValue = axisFunc(pw, lowBracket)
//			endif
//			if (tbracketMax < transformedRightValue)
//				transformedRightValue = axisFunc(pw, highBracket)
//			endif
//		endif
//	endif
	
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

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
static Function FindTransformLimit(axisFunc, pw, goodInputValue, badInputValue)
	FUNCREF TransformAxisTemplate axisFunc
	Wave pw
	Variable goodInputValue, badInputValue
	Variable FuncValue
	
	Variable newInputValue = (goodInputValue + badInputValue)/2
	FuncValue = axisFunc(pw, badInputValue)
	if (numtype(FuncValue) == 0)			// the bad input is really OK
		return badInputValue
	endif
	FuncValue = axisFunc(pw, goodInputValue)
	if (numtype(FuncValue) != 0)		// the good input is really bad!
		return NaN
	endif
	
	do
		FuncValue = axisFunc(pw, newInputValue)
		if (numtype(FuncValue) == 0)		// it's a good value
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


static Function/S NormalizeMantissa(mantissaStr)
	String mantissaStr
	
	Variable nchars = strlen(mantissaStr)
	Variable i = nchars
	Variable zerochar = char2num("0")
	Variable char
	do
		i -= 1
		char = char2num(mantissaStr[i,i])
	while(char == zerochar && i > 0)
	
	if (char2num(mantissaStr[i,i]) == char2num("."))
		i -= 1
	endif
	
	return mantissaStr[0,i]
end

static Function/S NormalizeExponent(exponentStr)
	String exponentStr
	
	Variable zerochar = char2num("0")
	Variable plussign = char2num("+")
	Variable lastCharPos = strlen(exponentStr)-1
	Variable isMinus = char2num(exponentStr[0,0]) != plussign		// ST: 221109 - make sure to also process negative exponents
	
	//if (char2num(exponentStr[0,0]) == plussign)
		exponentStr = exponentStr[1,lastCharPos]
		lastCharPos -= 1
	//endif
	do
		if (char2num(exponentStr[0,0]) != zerochar)
			break;
		endif
		exponentStr = exponentStr[1,lastCharPos]
		lastCharPos -= 1
	while (1)
	if (!strlen(exponentStr))		// ST: 210611 - nothing left? Must have been a zero from the start ...
		exponentStr = "0"
	elseif (isMinus)				// ST: 221109 - add back minus sign
		exponentStr[0] = "-"
	endif
	return exponentStr
end

Function/S NumberToTickLabel(number, numPlaces, doScientific)
	Variable number
	Variable numPlaces
	Variable doScientific
	
	String result
	
	if (doScientific)
		String temp
		sprintf temp, "%.*e", 6, number
		string grepstr="([0-9.\\-]+)(e)([0-9\\-\\+]+)"
		string p1, p2, p3
		SplitString /E=grepstr temp, p1,p2,p3
		p1 = NormalizeMantissa(p1)
		p3 = NormalizeExponent(p3)
		result = p1+"x10\\S"+p3
	else
		sprintf result, "%.*f", numPlaces, number			// appropriate label
		if (str2num(result) == 0)	// ST: 210731 - clean up values very close to zero like "0.0" or "-0.00"
			result = "0"
		endif
	endif
	
	return result
end

Function TickLabelToNumber(tickLabel)
	String tickLabel
	Variable doScientific
	
	Variable result
	
	if (TickLabelIsScientific(tickLabel))
		String grepstr="([0-9.\\-\\+]+)(x10\\\\S)([0-9\\+\\-]+)"
		string p1, p2, p3
		SplitString /E=grepstr tickLabel, p1,p2,p3
		result = str2num(p1)*10^str2num(p3)
	else
		result = str2num(tickLabel)
	endif
	
	return result
end

Function TickLabelIsScientific(tickLabel)
	String tickLabel
	
	return GrepString(tickLabel, "[0-9.\\-\\+]+x10\\\\S[0-9\\+\\-]+")
end

static StrConstant TAErrorTextBox = "TransformAxisErrorBox"

static function TA_ErrorTextBoxExists(String theGraph)
	String AnnoList = AnnotationList(theGraph)
	return WhichListItem(TAErrorTextBox, AnnoList) >= 0
end

static function TA_ErrorTextBox(String theGraph, String theMessage)
	if (TA_ErrorTextBoxExists(theGraph))
		TextBox/W=$theGraph/N=$TAErrorTextBox/C/A=MC/F=2/S=0 theMessage
	else
		TextBox/W=$theGraph/N=$TAErrorTextBox/A=MC/F=2/S=0 theMessage
	endif
end

static function TA_ErrorForTicks(String theGraph, String theAxis, Variable AxisType, String theMessage)
	if (TA_ErrorTextBoxExists(theGraph))
		if (strlen(theMessage) == 0)
			TextBox/K/W=$theGraph/N=$TAErrorTextBox
		endif
		return 0			// only report this once, or leave here after a successful computation that deleted an existing error box
	endif
	
	if (strlen(theMessage) == 0)
		return 0
	endif
	
	DFREF saveddf = GetDataFolderDFR()
	
	if (AxisType == MirrorType)
		Variable setDatafolderError = SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (setDatafolderError)
			return -1
		endif
	elseif (AxisType == TransformType)
		setDatafolderError = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (setDatafolderError)
			return -1
		endif
	endif
	
	String message = "Transform Axis error\r"
	message += "Graph: "+theGraph+"\r"
	message += "Axis: "+theAxis+"\r"
	message += theMessage
	TA_ErrorTextBox(theGraph, message)
	
	// When there's an error, the axis range saved in the axis' data folder isn't updated.
	// Subsequently, if the error is fixed, that old range info can prevent TicksForTransformAxis() being called,
	// which means that the error text box isn't removed. This sets the range such that when proper function is restored,
	// it will surely call TicksForTransformAxis().
	if (AxisType == TransformType)
		NVAR transformedAxisleft
		transformedAxisleft = nan
		NVAR transformedAxisRight
		transformedAxisRight = nan
	endif
		
	SetDataFolder saveddf
end

Function TicksForTransformAxis(theGraph, theAxis, numTicks, wantMinor, minSep, MirrorAxisName, TicksAtEnds, doScientific, doTrimZeros)
	String theGraph
	String theAxis
	Variable numTicks
	Variable wantMinor, minSep
	String MirrorAxisName
	Variable TicksAtEnds
	Variable doScientific
	Variable doTrimZeros						// ST: 221105 - remove trailing zeros
	
			String removaldata = GetUserData(theGraph, "", "TA_Removal")
			if (strlen(removaldata) > 0)
				print "BUG in TransformAxis, TicksForTransformAxis(): Computing ticks while transform is being removed; graph:", theGraph, "axis:", theAxis
			endif

	// For a transformed axis, theAxis is the name of the transformed axis.
	// For a mirror axis, theAxis is the name of the source axis, and MirrorAxisName is the name of the mirror axis
	// derived from theAxis.
	
	Variable isMirror = strlen(MirrorAxisName)>0
	Variable setDatafolderError
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "Transform Axis: The graph \""+theGraph+"\" doesn't exist"
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
	
	if (numTicks <= 0)
		SetDatafolder $saveDF
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "The tick density must be greater than zero.")
		return -1
	endif
	
	SVAR axisTransformFunction = axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
	Wave wp = dummyPWave
	
	if (isMirror)
		SVAR MainAxis
		SVAR MirrorAxis
	endif
	
	GetAxis/W=$theGraph/Q $theAxis
	if (V_flag)
		SetDatafolder $saveDF
		TA_ErrorTextBox(theGraph, "The axis "+theAxis+" is not used on "+theGraph)
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
		GetAxis/W=$theGraph/Q $theAxis
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
		
		// getTransformAxisRootBrackets accepts as input transformedRightValue, transformedLeftValue and autoRange. It sets the actual axis range
		// appropriately according to these inputs. It also calculates lowBracket, highBracket and returns them via these variables. These
		// are numbers suitable for use with FindRoots. If it is not possible to autoscale the axis, autoRange is modified to reflect that.
		autoRange = DoAutoScale			// can't use a global as a reference variable
		Variable useGetAxis = 0
		getTransformAxisRootBrackets(theGraph, theAxis, axisFunc, wp, transformedRightValue, transformedLeftValue, autoRange, lowBracket, highBracket, useGetAxis)
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
				TA_ErrorForTicks(theGraph, theAxis, isMirror, "FindRoots error while computing transformed axis: "+num2str(V_flag))
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
				TA_ErrorForTicks(theGraph, theAxis, isMirror, "FindRoots error while computing transformed axis: "+num2str(V_flag))
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
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the left or bottom end of the axis the transform function has infinite slope. I can't handle that!")
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeLeft)!=0)
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the left or bottom end of the axis calculation of the transform function slope failed.")
		SetDatafolder $saveDF
		return -1
	endif

	Variable rawRangeRight = rawRangeOfTransformFunction(rightValue, delta, fraction, wp, highBracket, lowBracket, isMirror)
	if (rawRangeRight == 0)	// pathological case
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the right or top end of the axis the transform function has infinite slope. I can't handle that!")
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeRight) != 0)
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the right or top end of the axis calculation of the transform function slope failed.")
		SetDatafolder $saveDF
		return -1
	endif
	Variable rawRangeMiddle = rawRangeOfTransformFunction((leftValue+rightValue-delta)/2, delta, fraction, wp, highBracket, lowBracket, isMirror)
	if (rawRangeMiddle == 0)	// pathological case
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the middle of the axis the transform function has infinite slope. I can't handle that!")
		SetDatafolder $saveDF
		return -1
	endif
	if (NumType(rawRangeMiddle)!=0)
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "At the middle of the axis calculation of the transform function slope failed.")
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
			SetDatafolder $saveDF
			TA_ErrorForTicks(theGraph, theAxis, isMirror, "Got a bad value while trying to calculate tick interval")
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
//			sprintf ticklbl, "%.*f", numPlaces, tickValue			// appropriate label
//			tickLabels[pNum][0] = ticklbl
			tickLabels[pNum][0] = NumberToTickLabel(tickValue, numPlaces, doScientific)
			tickLabels[pNum][1] = "Major"
			tickVals[pNum] = temp
			previousLabelPos = tickVals[pNum]
			if (debugInfo)
				print "1) tickLabels["+num2str(pNum)+"][0] = ", tickLabels[pNum][0], "  tickVals = ", tickVals[pNum], " previousLabelPos = ", previousLabelPos
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
					TA_ErrorForTicks(theGraph, theAxis, isMirror, "Found a place on the axis where the transform function has infinite slope. I can't handle that!")
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
					SetDatafolder $saveDF
					TA_ErrorForTicks(theGraph, theAxis, isMirror, "Got a bad value while trying to calculate tick interval")
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
					
//					sprintf ticklbl, "%.*f", numPlaces, TickValue			// appropriate label
//					tickLabels[pNum][0] = ticklbl
					tickLabels[pNum][0] = NumberToTickLabel(tickValue, numPlaces, doScientific)
					tickLabels[pNum][1] = "Major"
					previousLabelPos = tickVals[pNum]
					if (debugInfo)
						print "5) tickLabels["+num2str(pNum)+"][0] = ", tickLabels[pNum][0], "Tick Value = ", TickValue,  "tickVals = ", tickVals[pNum], " previousLabelPos = ", previousLabelPos
					endif
					if (debugUpdates)
						DoUpdate
					endif
					previousMajor = tickVals[pNum]
					previousTickValue = TickValue
					pNum += 1
				endif
				i += 1
			endif			// if (NeedRecalc)
		while (1)
		Pass += 1
	while (!done)
	
	if (DimSize(tickVals,0) < 2)	// ST: 210520 - stop here if there is no useful result
		SetDatafolder $saveDF
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "The transform function did not yield useful tick values in this range.\rMake sure the function is monotonic and well defined!")
		return -1
	endif
	
	if (isMirror)
		ModifyGraph/W=$theGraph userticks($MirrorAxisName)={tickVals,tickLabels}
	else
		ModifyGraph/W=$theGraph userticks($theAxis)={tickVals,tickLabels}
	endif
//	DoUpdate		// if it's a mirror axis, we need to do this to force Igor to create the axis.
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
	
	if (DimSize(tickVals,0) < 2)	// ST: 210524 - check again after duplicates have been removed
		SetDatafolder $saveDF
		TA_ErrorForTicks(theGraph, theAxis, isMirror, "Not enough ticks were left to display.\rMaybe there is a problem with the transform function or range.")
		return -1
	endif
	
	AddMissingMajorTicks(tickVals, tickLabels, values2pixels, minSep, axisFunc, wp, leftValue, rightValue, isMirror, highBracket, lowBracket, numPlaces, doScientific)
	if (debugUpdates)
		DoUpdate
	endif

	if (TicksAtEnds)
		AddTicksAtEnds(tickVals, tickLabels, values2pixels, minSep, axisFunc, wp, leftValue, rightValue, isMirror, highBracket, lowBracket, numPlaces, doScientific)		// ST: 210611 - add scientific label option
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
		if (DimSize(tickVals,0) < 2)	// ST: 210520 - stop here if there is no useful result
			SetDatafolder $saveDF
			TA_ErrorForTicks(theGraph, theAxis, isMirror, "The transform function did not yield useful tick values in this range.\rMake sure the function is monotonic and well defined!")
			return -1
		endif
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
	
	// Now demote major ticks if the labels are too close together
	RemoveExtraZeroesFromLabels(tickLabels)				// ST: 221109 - moved down the processing stack, and always cut first before adding zeros back
	if (!doTrimZeros)									// ST: 221109 - add zeros instead
		PadLabelsWithZeroes(tickLabels)
	endif
	if (debugUpdates)
		DoUpdate
	endif
	
	// store for resize events
	Variable/G nticks = numTicks
	Variable/G doMinor = wantMinor
	Variable/G minTickSep = minSep
	Variable/G doTicksAtEnds = TicksAtEnds
	Variable/G doScientificFormat=doScientific
	Variable/G doRemoveExtraZeroes=doTrimZeros			// ST: 221105 - save new option
	
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

	if (!isMirror)
		NVAR transformedAxisleft
		NVAR transformedAxisright
//print "GetAxis in TicksForTransformAxis"
		GetAxis/Q/W=$theGraph $theAxis
		transformedAxisleft = V_min
		transformedAxisright = V_max
	endif

	TA_ErrorForTicks(theGraph, theAxis, isMirror, "")		// zero-length message means success; if there is an error text box, remove it
	SetDatafolder $saveDF
	return 0
end

Function RestoreEditsAfterTicking(theGraph, theAxis, MirrorAxisName)
	String theGraph, theAxis, MirrorAxisName
	
	Variable isMirror = strlen(MirrorAxisName)>0
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
					break;
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

static Function RemoveDuplicates(tickVals, tickLabels)
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

static constant HLABELGROUT = 3
static constant VLABELGROUT = 0

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
//	Variable tickSpacing = abs(str2num(tickLabels[starti]) - str2num(tickLabels[endi]))/(endi - starti)
	Variable tickSpacing = abs(TickLabelToNumber(tickLabels[starti][0]) - TickLabelToNumber(tickLabels[endi][0]))/(endi - starti)
	
	Variable tickPower = 10^floor(log(tickSpacing))
	
	// look for ticks that are a multiple of 10 times the tick spacing; these are most-preferred ticks
	for (i = starti; i <= endi; i += 1)
		if (infoW[i][4] == 1)
//			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*10))
			if (isWholeNumber(TickLabelToNumber(tickLabels[i][0]), tickPower*10))
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
//			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*5))
			if (isWholeNumber(TickLabelToNumber(tickLabels[i][0]), tickPower*5))
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
//			if (isWholeNumber(str2num(tickLabels[i][0]), tickPower*2))
			if (isWholeNumber(TickLabelToNumber(tickLabels[i][0]), tickPower*2))
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

//	TempTickInfoWave[0][0] = str2num(tickLabels[1][0]) - str2num(tickLabels[0][0])
	TempTickInfoWave[0][0] = TickLabelToNumber(tickLabels[1][0]) - TickLabelToNumber(tickLabels[0][0])
	TempTickInfoWave[0][1] = 0
	
//	TempTickInfoWave[1,npnts-1][0] = str2num(tickLabels[p][0]) - str2num(tickLabels[p-1][0])
	TempTickInfoWave[1,npnts-1][0] = TickLabelToNumber(tickLabels[p][0]) - TickLabelToNumber(tickLabels[p-1][0])
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


static Function PickDigit(theNum, delta)
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

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function AddMissingMajorTicks(tickVals, tickLabels, values2pixels, minorSep, axisFunc, axisFuncPWave, axisStart, axisEnd, isMirror, highBracket, lowBracket, precision, doScientific)
	Wave tickVals
	Wave/T tickLabels
	Variable values2pixels, minorSep
	FUNCREF TransformAxisTemplate axisFunc
	Wave axisFuncPWave
	Variable axisStart, axisEnd
	Variable isMirror, highBracket, lowBracket, precision
	Variable doScientific
	
	Variable funcValue
	Variable i,jj
	Variable tickDelta, tickDeltaPwr,tickDeltaMantissa
	Variable majorDif, majorDistance, decimalPos, numPlaces
	Variable numMinor, lastMajor, nextToLastMajor, newMajor, tickDeltaSign, newRawMajor
	Variable inversePrecision = min(1e-6, 10^(-precision-2))
	String ticklbl
	
	// at the row zero end of the tick label waves
//	lastMajor = str2num(tickLabels[0])
//	nextToLastMajor = str2num(tickLabels[1])
	lastMajor = TickLabelToNumber(tickLabels[0][0])
	nextToLastMajor = TickLabelToNumber(tickLabels[1][0])
	majorDif = nextToLastMajor - lastMajor
	newMajor = lastMajor - majorDif
	if (isMirror)
		newRawMajor = getInverseValueWithinBounds(newMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		newRawMajor = axisFunc(axisFuncPWave, newMajor)
	endif
	if ( (numType(newRawMajor) == 0) && isNearlyBetween(newRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0][0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0][0])-decimalPos
		else
			numPlaces = 0
		endif
		InsertPoints 0, 1, tickLabels, tickVals
		tickLabels[0][1] = "Major"
//		sprintf ticklbl, "%.*f", numPlaces, newMajor			// appropriate label
//		tickLabels[0][0] = ticklbl
		tickLabels[0][0] = NumberToTickLabel(newMajor, numPlaces, doScientific)
		tickVals[0] = newRawMajor
	endif

	Variable npnts = numpnts(tickVals)
	Variable nextRow = npnts

	// at the other end
//	lastMajor = str2num(tickLabels[npnts-1])
//	nextToLastMajor = str2num(tickLabels[npnts-2])
	lastMajor = TickLabelToNumber(tickLabels[npnts-1][0])
	nextToLastMajor = TickLabelToNumber(tickLabels[npnts-2][0])
	majorDif = nextToLastMajor - lastMajor
	newMajor = lastMajor - majorDif
	if (isMirror)
		newRawMajor = getInverseValueWithinBounds(newMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		newRawMajor = axisFunc(axisFuncPWave, newMajor)
	endif
	if ( (numType(newRawMajor) == 0) && isNearlyBetween(newRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0][0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0][0])-decimalPos
		else
			numPlaces = 0
		endif
		InsertPoints npnts, 1, tickLabels, tickVals
		tickLabels[nextRow][1] = "Major"
//		sprintf ticklbl, "%.*f", numPlaces, newMajor			// appropriate label
//		tickLabels[nextRow][0] = ticklbl
		tickLabels[nextRow][0] = NumberToTickLabel(newMajor, numPlaces, doScientific)
		tickVals[nextRow] = newRawMajor
	endif
end
	
// This function assumes that the tick waves have only major ticks.

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
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
//	numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
//	lastMajor = str2num(tickLabels[0])
	numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[1][0]), TickLabelToNumber(tickLabels[0][0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
	lastMajor = TickLabelToNumber(tickLabels[0][0])
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
//		numMinor = CalculateNumMinorTicks(str2num(tickLabels[i]), str2num(tickLabels[i-1]), tickVals[i]*values2pixels, tickVals[i-1]*values2pixels, minorSep, minorDif, emphasizeEvery)
		numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[i][0]), TickLabelToNumber(tickLabels[i-1][0]), tickVals[i]*values2pixels, tickVals[i-1]*values2pixels, minorSep, minorDif, emphasizeEvery)
	
//		lastMajor = str2num(tickLabels[i-1])
		lastMajor = TickLabelToNumber(tickLabels[i-1][0])
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
//	lastMajor = str2num(tickLabels[npnts-1])
	lastMajor = TickLabelToNumber(tickLabels[npnts-1][0])
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

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function AddTicksAtEnds(tickVals, tickLabels, values2pixels, minorSep, axisFunc, axisFuncPWave, axisStart, axisEnd, isMirror, highBracket, lowBracket, precision, doScientific)
	Wave tickVals
	Wave/T tickLabels
	Variable values2pixels, minorSep
	FUNCREF TransformAxisTemplate axisFunc
	Wave axisFuncPWave
	Variable axisStart, axisEnd
	Variable isMirror, highBracket, lowBracket, precision
	Variable doScientific
	
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
	
//	Variable majordif = str2num(tickLabels[1]) - str2num(tickLabels[0])
	Variable majordif = TickLabelToNumber(tickLabels[1][0]) - TickLabelToNumber(tickLabels[0][0])
	if (almostEqual(abs(majordif), 0, 1e-6))
		return 0
	endif
	
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
//	lastMajor = str2num(tickLabels[0])
	lastMajor = TickLabelToNumber(tickLabels[0][0])
	nextMajor = lastMajor - majorDif
	if (isMirror)
		nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
	endif
	if ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		decimalPos = strsearch(tickLabels[0][0], ".", 0)
		if (decimalPos >= 0)
			numPlaces = strlen(tickLabels[0][0])-decimalPos
		else
			numPlaces = 0
		endif
		do
			InsertPoints 0, 1, tickLabels, tickVals
			tickLabels[0][1] = "Major"
			//sprintf ticklbl, "%.*f", numPlaces, nextMajor			// appropriate label
			//tickLabels[0][0] = ticklbl
			tickLabels[0][0] = NumberToTickLabel(nextMajor, numPlaces, doScientific)				// ST: 210611 - do scientific labeling
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
		while ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) && !almostEqual(abs(majorDif), 0, 1e-6) )
	endif
	
	if (debugUpdates)
		DoUpdate
	endif
	
	Variable thePnt = numMajor
//	lastMajor = str2num(tickLabels[thePnt-1])
//	majordif = str2num(tickLabels[thePnt-2]) - str2num(tickLabels[thePnt-1])
	lastMajor = TickLabelToNumber(tickLabels[thePnt-1][0])
	majordif = TickLabelToNumber(tickLabels[thePnt-2][0]) - TickLabelToNumber(tickLabels[thePnt-1][0])
	nextMajor = lastMajor - majorDif
	if (isMirror)
		nextRawMajor = getInverseValueWithinBounds(nextMajor, HighBracket, LowBracket, inversePrecision, axisFunc, axisFuncPWave)
	else
		nextRawMajor = axisFunc(axisFuncPWave, nextMajor)
	endif
	if ( (numType(nextRawMajor) == 0) && isNearlyBetween(nextRawMajor, axisStart, axisEnd, 1e-6) )	// another major tick at the last spacing fits, so put it in and work from there
		Variable isSciFormat = TickLabelIsScientific(tickLabels[thePnt-1][0])
		if (isSciFormat)
			numPlaces = 0
		else
			decimalPos = strsearch(tickLabels[thePnt-1][0], ".", 0)
			if (decimalPos >= 0)
				numPlaces = strlen(tickLabels[thePnt-1][0])-decimalPos
			else
				numPlaces = 0
			endif
		endif
		do
			InsertPoints thePnt, 1, tickLabels, tickVals
			tickLabels[thePnt][1] = "Major"
//			sprintf ticklbl, "%.*f", numPlaces, nextMajor			// appropriate label
//			tickLabels[thePnt][0] = ticklbl
			tickLabels[thePnt][0] = NumberToTickLabel(nextMajor, numPlaces, isSciFormat)
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
		while ( (numType(nextMajor) == 0) && isNearlyBetween(nextMajor, axisStart, axisEnd, 1e-6) && !almostEqual(abs(majorDif), 0, 1e-6) )
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
	
//	lastMajor = str2num(tickLabels[0])
	lastMajor = TickLabelToNumber(tickLabels[0][0])
	// figure out the number of digits required by the labels from the last label already on the graph
	dummyString = tickLabels[0][0]
	decimalPos = strsearch(dummyString, ".", 0)
	lableLen = strlen(dummyString)
	if (decimalPos >= 0)
		numPlaces = lableLen - decimalPos//+1
	else
		if ( (lableLen > 1) && (CmpStr(dummyString[lableLen-1], "0") == 0) )
			numPlaces = 0
		else
			numPlaces = 1
		endif
	endif
//	numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
	numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[1][0]), TickLabelToNumber(tickLabels[0][0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, minorSep, minorDif, emphasizeEvery)
	if (numMinor <= 1)
//		numMinor = CalculateNumMinorTicks(str2num(tickLabels[1]), str2num(tickLabels[0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, 0, minorDif, emphasizeEvery)
		numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[1][0]), TickLabelToNumber(tickLabels[0][0]), tickVals[1]*values2pixels, tickVals[0]*values2pixels, 0, minorDif, emphasizeEvery)
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
			//sprintf ticklbl, "%.*f", numPlaces, lastMajor + jj*minorDif			// appropriate label
			//tickLabels[nextRow][0] = ticklbl
			tickLabels[nextRow][0] = NumberToTickLabel(lastMajor + jj*minorDif, numPlaces, doScientific)		// ST: 210611 - do scientific labeling
			tickLabels[nextRow][1] = "Major"
			tickVals[nextRow] = minorToUse
			nextRow += 1
		endif
	endif

	if (debugUpdates)
		DoUpdate
	endif
	
	dummyString = tickLabels[numMajor-1][0]
	decimalPos = strsearch(dummyString, ".", 0)
	lableLen = strlen(dummyString)
	if (decimalPos >= 0)
		numPlaces = lableLen - decimalPos//+1
	else
		if ( (lableLen > 1) && (CmpStr(dummyString[lableLen-1], "0") == 0) )
			numPlaces = 0
		else
			numPlaces = 1
		endif
	endif
//	numMinor = CalculateNumMinorTicks(str2num(tickLabels[numMajor-1]), str2num(tickLabels[numMajor-2]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, minorSep, minorDif, emphasizeEvery)
	numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[numMajor-1][0]), TickLabelToNumber(tickLabels[numMajor-2][0]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, minorSep, minorDif, emphasizeEvery)
	if (numMinor <= 1)
//		numMinor = CalculateNumMinorTicks(str2num(tickLabels[numMajor-1]), str2num(tickLabels[numMajor-2]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, 0, minorDif, emphasizeEvery)
		numMinor = CalculateNumMinorTicks(TickLabelToNumber(tickLabels[numMajor-1][0]), TickLabelToNumber(tickLabels[numMajor-2][0]), tickVals[numMajor-1]*values2pixels, tickVals[numMajor-2]*values2pixels, 0, minorDif, emphasizeEvery)
	endif
	emphasizedLabel = -1

	if (numMinor > 1)
//		lastMajor = str2num(tickLabels[numMajor-1])
		lastMajor = TickLabelToNumber(tickLabels[numMajor-1][0])
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
			//sprintf ticklbl, "%.*f", numPlaces, lastMajor - jj*minorDif			// appropriate label
			//tickLabels[nextRow][0] = ticklbl
			tickLabels[nextRow][0] = NumberToTickLabel(lastMajor - jj*minorDif, numPlaces, doScientific)		// ST: 210611 - do scientific labeling
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
	
	Variable numMinor = 0									// in rare cases, default to no minor ticks. See below, default case of the switch.

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
//			print "BUG: in CalculateNumMinorTicks, took the default case"
			// turns out this isn't really a bug-if an axis changes very rapidly at one end, then a very large number of closely-spaced
			// major ticks may be created by the initial ticking algorithm. When these are culled, you can get a pretty odd spacing, and it may have a
			// spacing larger than 9. I think the proper thing to do is to keep whatever major ticks survive, and to just not make minor ticks
			// in the funny intervals.
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
		if (firstMajorIndex > 0)						// ST: 210531 - make sure to not get out of bounds
			if (CmpStr(tickLabels[firstMajorIndex-1][1], "Major") == 0)	// the tick after the first major tick is another major tick
				erase = 1
			else
				if (!AlmostEqual(abs(tickVals[lastIndex] - tickVals[lastIndex-1]), abs(tickVals[firstMajorIndex] - tickVals[firstMajorIndex-1]), 1e-6))
					erase = 1
				endif
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
			if ( (i > 0) && (i < (DimSize(tickLabels, 0)-1)) && ((CmpStr(tickLabels[i-1][1], "Major") == 0) || (CmpStr(tickLabels[i+1][1], "Major") == 0)) )
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

Function PadLabelsWithZeroes(Wave/T tickLabels)					// ST: 221108 - pads numbers after the decimal dot with zeros to bring them to the same lengths
	Variable npnts = DimSize(tickLabels, 0)
	String mainStr, expStr = ""
	
	Variable i, expPos, dotPos
	Variable maxSignificant = 0, curSignificant, minMajor = inf
	for (i = 0; i < npnts; i += 1)								// ST: 221108 - first, find the longest string of significant digits
		mainStr = tickLabels[i][0]
		dotPos = strsearch(mainStr,".",0)
		expPos = strsearch(mainStr,"x10",0)
		if (!strlen(mainStr) || dotPos < 0)
			continue
		endif
		if (expPos != -1)										// ST: 221108 - must be scientific
			mainStr	= mainStr[0,expPos-1]
		endif
		curSignificant = strlen(mainStr)-dotPos-1
		if (curSignificant > maxSignificant)
			maxSignificant = curSignificant
			minMajor = dotPos < minMajor ? dotPos : minMajor	// smallest length before the decimal dot => to make smallest values uniform 
		endif
	endfor
	if (maxSignificant == 0)									// ST: 221108 - nothing to do here => abort
		return 0
	endif
	
	for (i = 0; i < npnts; i += 1)								// ST: 221108 - now pad with zeroes
		mainStr = tickLabels[i][0]
		dotPos = strsearch(mainStr,".",0)
		expPos = strsearch(mainStr,"x10",0)
		if (expPos != -1)
			mainStr	= (tickLabels[i][0])[0,expPos-1]
			expStr	= (tickLabels[i][0])[expPos,inf]
		endif
		if (!strlen(mainStr))
			continue
		endif
		curSignificant = dotPos < 0 ? inf : strlen(mainStr)-dotPos-1
		if (dotPos < 0)											// no trailing numbers
			if(expPos > -1 || strlen(mainStr) == minMajor)		// if scientific or the smallest number, add anyway
				curSignificant = 0
				mainStr	+= "."
			endif
		endif
		if (maxSignificant > curSignificant)					// we need to add zeroes
			mainStr	+= ReplicateString("0", maxSignificant - curSignificant)
		endif
		tickLabels[i][0] = mainStr+expStr
	endfor
	
	Variable zerochar = char2num("0"), dotchar = char2num("."), curchar
	do															// clean up occasional excessive zeros introduced by the tick generator
		Variable counter = 0
		for (i = 0; i < npnts; i += 1)
			curchar = char2num((tickLabels[i][0])[strlen(tickLabels[i][0])-1])
			dotPos = strsearch(mainStr,".",0)					// only work on labels with decimal point
			expPos = strsearch(mainStr,"x10",0)					// don't work on scientific labels
			if ((curchar == zerochar || curchar == dotchar) && dotPos > -1 && expPos < 0)
				counter++
			endif
		endfor
		if (counter == npnts)									// all labels end with zero or dots
			for (i = 0; i < npnts; i += 1)						// remove one char at the end
				mainStr = tickLabels[i][0]
				tickLabels[i][0] = mainStr[0,strlen(mainStr)-2]
			endfor
		else
			break
		endif
	while(1)
	return 0
end

Function RemoveExtraZeroesFromLabels(Wave/T tickLabels)			// ST: 221106 - rewrote function to properly account for scientific labels
	Variable i, npnts = DimSize(tickLabels, 0)
	String mainStr, expStr = ""
	for (i = 0; i < npnts; i += 1)
		mainStr = tickLabels[i][0]
		Variable expPos = strsearch(mainStr,"x10",0)
		if (expPos != -1)										// ST: 221106 - must be scientific
			mainStr	= (tickLabels[i][0])[0,expPos-1]
			expStr	= (tickLabels[i][0])[expPos,inf]
		endif
		
		Variable nchars = strlen(mainStr)
		if (!strlen(mainStr) || strsearch(mainStr,".",0) < 0)
			continue
		endif
		Variable zerochar = char2num("0"), char, j = nchars
		do
			j -= 1
			char = char2num(mainStr[j,j])
		while(char == zerochar && j > 0)
		if (char2num(mainStr[j,j]) == char2num("."))			// only remove zeroes the right of the decimal point and allow ".0" but not ".00" or ".50"
			Variable hasDot_pos = 0, hasDot_neg = 0
			if (i > 0)											// ST: 221109 - does the adjacent labels have a decimal point as well?
				hasDot_neg = strsearch(tickLabels[i-1][0],".",0) > 0
			endif
			if (i < npnts-1)
				hasDot_pos = strsearch(tickLabels[i+1][0],".",0) > 0
			endif
			if (hasDot_pos || hasDot_neg)						// ST: 221109 - match adjacent labels
				j += 1
			else
				j -= 1
			endif
		endif
		
		tickLabels[i][0] = mainStr[0,j]+expStr
	endfor
end

// Function RemoveExtraZeroesFromLabels(tickLabels)
	// Wave/T tickLabels
	
	// Variable npnts = DimSize(tickLabels, 0)
	// Variable i
	// Variable labelLen
	// String theLabel
	// Variable decimalPos
	
	// for (i = 0; i < npnts; i += 1)
		// labelLen = strlen(tickLabels[i][0])
		// if (labelLen > 0)
			// theLabel = tickLabels[i][0]
			// decimalPos = StrSearch(theLabel, ".", 0)
			// only remove zeroes the right of the decimal point and allow ".0" but not ".00" or ".50"
			// if ( (decimalPos > 0) && (decimalPos < labelLen-2) )
				// if (CmpStr(theLabel[labelLen-1], "0") == 0)
					// tickLabels[i][0] = theLabel[0,labelLen-2]
				// endif
			// endif
		// endif
	// endfor
// end

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

static Function TA_WindowHasTAAxis(String theWin)
	if (WinType(theWin) != 1)		// if it's not a graph, it can't have axes!
		return 0
	endif
	
	if (strlen(ListTransformAxes(theWin)) > 0)
		return 1
	endif
	if (strlen(ListTransformMirrorAxes(theWin)) > 0)
		return 1
	endif
	
	return 0
end

static Function TA_Recursively_WindowHasTAAxes(String theWin)
	if (TA_WindowHasTAAxis(theWin))
		return 1
	endif
	
	String children = ChildWindowList(theWin)
	Variable nchildren = ItemsInList(children)
	if (nchildren > 0)
		Variable j
		for (j = 0; j < nchildren; j++)
			String child = StringFromList(j, children)
			String childpath = theWin + "#" + child
			// Recursive
			if (TA_Recursively_WindowHasTAAxes(childpath))
				return 1
			endif
		endfor
	endif
	
	return 0
end

static Function TA_WindowHasTAAxisSomewhere(String theGraph)
	String toplevelHost = StringFromList(0, theGraph, "#")
	if (TA_WindowHasTAAxis(toplevelHost))
		return 1
	endif
	
	return TA_Recursively_WindowHasTAAxes(toplevelHost)
end

// This function untransforms traces that were transformed in order to implement a regular transform axis.
// It is not called for mirror axes.
Function UndoTransformTraces(theGraph, theAxis)
	String theGraph
	String theAxis

	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif

	String saveDF = GetDatafolder(1)
	
	String theGraphFolder = folderForThisGraph(theGraph, TransformType)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		DoAlert 0, "This graph has no transformed axes"
		SetDatafolder $saveDF
		return -1
	endif
	SetDatafolder $theGraphFolder
	
	SetWindow $theGraph, userData(TA_Removal) = "In progress"
	
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
	Variable ntraces = ItemsInList(theTraces)								// JW 2109014 Convert do-while to for loops
	String theWaveNote
	String oneTrace
	String oneKeyvalue
	String axisRecreation
	Variable AxisLeft	
	Variable AxisRight
	String SetAxisFlags
	
	String DepVarList = VariableList("TransformDependencyVar*", ";", 4)
	i = 0
	do
		String OneDepVar = StringFromList(i, DepVarList)
		if (strlen(OneDepVar) == 0)
			break
		endif
		NVAR depvar = $OneDepVar
		SetFormula depvar, ""
		KillVariables depvar
		i += 1
	while(1)
	DoUpdate
	for (i = ntraces-1; i >= 0; i--)										// JW 2109014 Convert do-while to for loops
		oneTrace =  StringFromList(i, theTraces)
		if (strlen(oneTrace) == 0)
			break
		endif
		// JW 210914 Removed protection against duplicate traces
		String TraceAxis = AxisForTrace(theGraph, oneTrace, 0, isXAxis ? 0 : 1)
		if (CmpStr(TraceAxis, theAxis) != 0)
			continue					// JW 191106 this trace is not using the axis that's being untransformed
		endif

		if (isXAxis)
			Wave/Z w = XWaveRefFromTrace(theGraph, oneTrace)
			if (!WaveExists(w))
				continue
			endif
		else
			Wave w = TraceNameToWaveRef(theGraph, oneTrace)
		endif
		theWaveNote = Note(w)
		oneKeyValue = StringByKey("TransformAxis", theWaveNote, "=", ";")
		if (CmpStr(oneKeyValue, theAxis) != 0)
			continue		// either this axis wasn't transformed, or this wave wasn't on the axis when it was transformed, or ...
		endif
		AxisLeft = NumberByKey("AXISLEFT", theWaveNote, "=", ";")
		AxisRight = NumberByKey("AXISRIGHT", theWaveNote, "=", ";")
		SetAxisFlags = StringByKey("SETAXISFLAGS", theWaveNote, "=", ";")
		axisRecreation = GetAxisRecreationFromInfoString(theWaveNote, "=")		// it's overkill to get it from every wave, but this protects it from being over-written if a transformed axis is transformed
		oneKeyValue = StringByKey("OldWave", theWaveNote, "=", ";")
		Wave/Z oldW = $oneKeyValue
		if (isXAxis)
			ReplaceWave/W=$theGraph/X trace=$oneTrace, oldW		// replace transformed wave with the original in this trace (if there was no X wave, it will transform it back into a waveform trace)
		else
			ReplaceWave/W=$theGraph trace=$oneTrace, oldW			// replace transformed wave with the original in this trace
		endif
		DoUpdate
		KillWaves/Z w
	endfor																// JW 2109014 Convert do-while to for loops
	
	ModifyGraph/W=$theGraph userTicks($theAxis)=0

	if (strlen(SetAxisFlags) > 0)
		Execute "SetAxis"+SetAxisFlags+"/Z "+theAxis
	else
		Execute "SetAxis "+theAxis+","+num2str(AxisLeft)+","+num2str(AxisRight)
	endif

	// It's OK to compute the ticks now
	SetWindow $theGraph, userData(TA_Removal) = ""

	if (strlen(WaveList("*_T", ";", "")) != 0)		// the axis was transformed more than once, and there are still transform waves in use. The axis recreation string is not useful.
		NVAR doTicksAtEnds
		TicksForTransformAxis(theGraph, theAxis, 5, 0,3, "", doTicksAtEnds, 0, 1)	// default values for this because the tickLabel and tickValue waves get overwritten
	else
		ApplyAxisRecreation(theAxis, theGraph, axisRecreation, 0)
		SetDatafolder ::
		KillDatafolder $theAxisFolder
		if (CountObjects(":", 4) == 0)				// no transformed axes left for this graph
			SetDatafolder ::
			KillDatafolder $theGraphFolder
			SetWindow $theGraph UserData(TransAxFolder) = ""
			if (debugInfo)
				print "Remaining TA's:", ListTransformAxes(theGraph)
			endif
			if (!TA_WindowHasTAAxisSomewhere(theGraph))
				String toplevelWindow = StringFromList(0, theGraph, "#")
				SetWindow $toplevelWindow hook(TransformAxisHook) = $""
				SetWindow $theGraph UserData(TransAxVersion) = ""
			endif
		endif
	endif
	
	if (TA_ErrorTextBoxExists(theGraph))			// ST: 210609 - kill the error text box when the axis in question is untrasformed
		String ErrorContents = StringByKey("TEXT", AnnotationInfo(theGraph, TAErrorTextBox,1), ":")
		String ErrorAxis = StringByKey("Axis", ErrorContents, ": ", "\r")
		if (CmpStr(ErrorAxis,theAxis) == 0)
			TextBox/K/W=$theGraph/N=$TAErrorTextBox
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

// JW 210914 Not presently in use, at least not in this file
// And converted to for loop instead of do-while
Function/S FindTransformTraceGivenWave(theGraph, theWave)
	String theGraph
	Wave theWave
	
	String tList = TraceNameList(theGraph, ";", 1)
	Variable ntraces = ItemsInList(tList)
	String aTrace
	String WaveWithPath = GetWavesDatafolder(theWave, 2)
	String wNote, xwNote
	Variable i=0
	for (i = 0; i < nTraces; i++)
		aTrace = StringFromList(i, tList)
		if (strlen(aTrace) == 0)
			break
		endif
		if (!isTransformTrace(theGraph, aTrace))
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
	endfor
	
	return ""
end

// Remove a Transform Mirror axis. There are only two things to do:
// 	Remove the slave truly free axis that was made to be the transformed mirror axis
//		Remove the data folder containing data that is used by that axis.
// If, when that's done, there are no other mirror axes, and no regular transform axes,
// the remove the traces of the Transform Axis package from the graph so it goes back
// to being a regular axis.
Function UndoTransformMirror(theGraph, theAxis)
	String theGraph
	String theAxis

	String saveDF = GetDatafolder(1)
	
	if  (SetDataFolderForMirrorAxis(theGraph, theAxis) != 0)
		SetDatafolder $saveDF
		return 0									// no transform mirror axis for this axis, so don't do anything
	endif
	String theDataFolder = GetDatafolder(0)
	
	SVAR MirrorAxis
	GetAxis/W=$theGraph/Q $MirrorAxis				// ST: 211117 - check whether the mirror axis is actually there
	if (V_flag)
		SetDatafolder $saveDF
		return 0									// no transform mirror axis in the graph => this must be an error, so don't do anything
	endif
	KillFreeAxis/W=$theGraph $MirrorAxis

	SetDatafolder ::
	KillDatafolder $theDataFolder
	theDataFolder = GetDatafolder(0)
	if (CountObjects(":", 4) == 0)					// no mirror axes left for this graph
		SetDatafolder ::
		KillDatafolder $theDataFolder
		SetWindow $theGraph UserData(TransAxMirrorFolder) = ""
		if (!TA_WindowHasTAAxisSomewhere(theGraph))
			String toplevelWindow = StringFromList(0, theGraph, "#")
			SetWindow $toplevelWindow hook(TransformAxisHook) = $""
			SetWindow $theGraph UserData(TransAxVersion) = ""
		endif
	endif

	if (TA_ErrorTextBoxExists(theGraph))			// ST: 210609 - kill the error text box when the axis in question is untrasformed
		String ErrorContents = StringByKey("TEXT", AnnotationInfo(theGraph, TAErrorTextBox,1), ":")
		String ErrorAxis = StringByKey("Axis", ErrorContents, ": ", "\r")
		if (CmpStr(ErrorAxis,theAxis) == 0)
			TextBox/K/W=$theGraph/N=$TAErrorTextBox
		endif
	endif

	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

Function ApplyAxisRecreation(theAxis, theGraph, theRecreationString, UpdateEachCommand)
	String theAxis, theGraph, theRecreationString
	Variable UpdateEachCommand
	
	Variable i=0
	String dstr= "("+theAxis+")"	// i.e., (left)
	String sitem,xstr

	do
		sitem= StringFromList(i, theRecreationString, ";")
		if( strlen(sitem) == 0 )
			break;
		endif
		xstr= "ModifyGraph /W="+theGraph+" "+StrSubstitute("(x)",sitem,dstr)
		if (!StringMatch(xstr,"*userticks("+theAxis+")={tickVals,tickLabels}"))				// ST: 210609 - don't reapply the user ticks
			Execute xstr
		endif
		if (UpdateEachCommand)
			DoUpdate
		endif
		i+=1
	while(1)
end

Function/S GetKeyFromModAxisInfoItem(sitem)
	string sitem
	
	Variable endPos = strsearch(sitem, "=", 0)
	return sitem[0, endPos-1]
end

static StrConstant avoidModGraphKeys = "grid(x);userticks(x);lblPos(x);lblPosMode(x);lblMargin(x);lblPos(x);freePos(x);lblMargin(x);lblLatPos(x);lblRot(x);tkLblRot(x);tlOffset(x);"	// JW / ST : 2022-11-03 : certain axis modifications should not be mirrored.

Function ApplyAxisRecreationDifferences(theAxis, theGraph, oldRecreationString, newRecreationString, DoUpdates)
	String theAxis, theGraph, oldRecreationString, newRecreationString
	Variable DoUpdates
	
	Variable i=0
	String dstr= "("+theAxis+")"	// i.e., (left)
	String sitem,xstr

	do
		sitem= StringFromList(i, newRecreationString, ";")
		if( strlen(sitem) == 0 )
			break;
		endif
		string itemKey = GetKeyFromModAxisInfoItem(sitem)
		string oldItemValue = StringByKey(itemKey, oldRecreationString, "=", ";")
		string newItemValue = StringByKey(itemKey, newRecreationString, "=", ";")
		if (CmpStr(oldItemValue, newItemValue) != 0)
			if ( FindListItem(itemKey, avoidModGraphKeys) < 0)
				xstr= "ModifyGraph /W="+theGraph+" "+StrSubstitute("(x)",sitem,dstr)
				Execute xstr
				if (DoUpdates)
					DoUpdate
				endif
			endif
		endif
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

// for aborts, it is assumed that the brackets are good, and that the function is well-behaved between the brackets.

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
//				DoAlert 0, "FindRoots error while computing derivatives for transformed axis: "+num2str(V_flag)
				return NaN
			endif
			Value = V_root
		endif
	else
		Value = axisFunc(paramWave, atValue)
	endif
	
	Variable minusDelta = 0
	atValuePlus = atValue+delta
		
	Do
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
//					DoAlert 0, "could not calculate derivative- delta is outside the axis range"
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
//					DoAlert 0, "FindRoots error while computing derivatives for transformed axis: "+num2str(V_flag)
					return NaN
				endif
				ValuePlus = V_root
			endif
		else
			ValuePlus = axisFunc(paramWave, atValuePlus)
		endif
	
		if ( (minusDelta == 1) || (NumType(ValuePlus) == 0) )
			break
		endif

		minusDelta = 1
		atValuePlus = atValue-delta
	while (1)

	Variable returnvalue = (ValuePlus-Value)/fraction
	if (minusDelta)
		returnvalue = -returnvalue
	endif
	
	return returnvalue
end

static Function isHorizAxis(theGraph, theAxis)
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

Function isTransformAxisDFName(theDFName)
	String theDFName
	
	return CmpStr(theDFName[0,13], "AxisTransform_") == 0
end

Function isTransformMirrorDFName(theDFName)
	String theDFName
	
	return CmpStr(theDFName[0,15], "TransformMirror_") == 0
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
	Variable YesItIs
//	if (SVAR_Exists(MainAxis) && SVAR_Exists(MirrorAxis) && SVAR_Exists(PerpendicularAxis) && SVAR_Exists(DummyWaveName))
	if (SVAR_Exists(MainAxis) && SVAR_Exists(MirrorAxis))
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

// JW 210914 Converted to for loop instead of do-while
static Function/S AxisTraceList(theGraph, theAxis [,getXwave])		// ST: 210609 - add optional parameter to fetch x waves from traces
	String theGraph
	String theAxis
	Variable getXWave
	
	Variable getX = ParamIsDefault(getXwave) ? 0 : getXwave
	
	Variable isXAxis = isHorizAxis(theGraph, theAxis)
	
	String traces = TraceNameList(theGraph, ";", 1)	// will need to add ContourNameList and ImageNameList
	Variable ntraces = ItemsInList(traces)
	String oneTrace = ""
	String outTraces = ""
	
	String tInfo
	String tAxis
	Variable i=0
	for (i = 0; i < ntraces; i++)
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
			if (getX)												// ST: 210609 - output the x waves instead
				outTraces += StringByKey("XWAVE", tInfo)+";"
			else
				outTraces += oneTrace+";"
			endif
		endif
	endfor

	return outTraces	
end

static Function isNearlyBetween(theNum, a, b, precision)
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

static Function AlmostEqual(num1, num2, precision)
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

static Function isBetween(theNum, a, b)
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
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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

//This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function NewTransformAxisRange(theGraph, theAxis, minVal, maxVal)
	String theGraph, theAxis
	Variable minVal, maxVal
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraph) != 1)
		DoAlert 0, "The graph \""+theGraph+"\" doesn't exist"
		return -1
	endif
//	DoWindow/F $theGraph
	
	String saveDF = GetDatafolder(1)
	
	Variable setDatafolderError = SetGraphAndAxisDataFolder(theGraph, theAxis)
	if (setDatafolderError)
		ReportSetGraphAndAxisDFError(theGraph, theAxis, setDatafolderError, 1)
		SetDatafolder $saveDF
		return -1
	endif
	
	SVAR axisTransformFunction = axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction	
	
	GetAxis/W=$theGraph/Q $theAxis
	if (V_flag)
		SetDatafolder $saveDF
		DoAlert 0, "The axis "+theAxis+" is not used on "+theGraph
		return -1
	endif
	
	Wave dummyPWave = dummyPWave
	Variable transformedMin, transformedMax
	transformedMin = axisFunc(dummyPWave, minVal)
	if (numtype(transformedMin) != 0)
		SetDatafolder $saveDF
		DoAlert 0, "The axis range could not be set because the minimum value transforms to an undefined value."
		return -1
	endif
	transformedMax = axisFunc(dummyPWave, maxVal)
	if (numtype(transformedMax) != 0)
		SetDatafolder $saveDF
		DoAlert 0, "The axis range could not be set because the maximum value transforms to an undefined value."
		return -1
	endif
	if ( (transformedMin < transformedMax) %^ (minVal < maxVal) )
		Variable temp = transformedMin
		transformedMin = transformedMax
		transformedMax = temp
	endif
	SetAxis/W=$theGraph $theAxis, transformedMin, transformedMax
//	DoUpdate
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
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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

Function SetGraphDataFolder(theGraph)
	String theGraph
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	endif
	if (WinType(theGraph) != 1)
		return 1
	endif
	
	String theGraphFolder = folderForThisGraph(theGraph, 0)
	if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
		theGraphFolder = folderForThisGraph(theGraph, 1)
		if ((strlen(theGraphFolder) == 0) || !DatafolderExists(theGraphFolder))
			return 2
		endif
	endif
	SetDatafolder $theGraphFolder
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
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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

static Function/S GetAxisType(theGraph, theAxis)
	String theGraph
	String theAxis
	
	String aInfo = AxisInfo(theGraph, theAxis)
	String aType = StringByKey("AXTYPE", aInfo)
	return aType
end

//Function/S GetPerpendicularAxis(theGraph, theAxis)
//	String theGraph
//	String theAxis
//
//	String TraceList = AxisTraceList(theGraph, theAxis)
//	String aTrace = StringFromList(0, TraceList)
//	String tInfo = TraceInfo(theGraph, aTrace, 0)
//	String perpAxisName
//	if (isHorizAxis(theGraph, theAxis))
//		perpAxisName = StringByKey("YAXIS", tInfo)
//	else
//		perpAxisName = StringByKey("XAXIS", tInfo)
//	endif
//	
//	return perpAxisName
//end

// returns the new axis name
Function/S AddTrulyFreeAxisForAxis(theGraph, theAxis)
	String theGraph
	String theAxis

	String AxisType = GetAxisType(theGraph, theAxis)
	String AxisFlagsAndNames
	String MirrorAxisName = "MT_"+theAxis
		
	strswitch (AxisType)
		case "top":
			AxisFlagsAndNames = "/B "+MirrorAxisName
			break
		case "bottom":
			AxisFlagsAndNames = "/T "+MirrorAxisName
			break
		case "left":
			AxisFlagsAndNames = "/R "+MirrorAxisName
			break
		case "right":
			AxisFlagsAndNames = "/L "+MirrorAxisName
			break
	endswitch
	
	GetAxis/W=$theGraph/Q $MirrorAxisName
	if (V_flag == 0)							// ST: 210731 - check whether axis already exits for some reason
		KillFreeAxis/W=$theGraph $MirrorAxisName
	endif
	
	String FreeAxisCommand = "NewFreeAxis/W="+theGraph+" "+AxisFlagsAndNames
	Execute FreeAxisCommand
	
	return MirrorAxisName
end	
	
Function SetupTransformMirrorAxis(theGraph, theAxis, theFunc, FuncCoefWave, numTicks, wantMinor, minSep, TicksAtEnds [,doScientific, doTrimZeros])
	String theGraph
	String theAxis
	String theFunc
	Wave/Z FuncCoefWave
	Variable numTicks, wantMinor, minSep		// for call to TicksForTransformAxis
	Variable TicksAtEnds
	Variable doScientific						// ST: 210524 - new optional parameter for scientific axes
	Variable doTrimZeros						// ST: 221105 - new optional parameter to toggle zero removal in version 1.38
	
	Variable funcValue
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
		Duplicate/D/free FuncCoefWave, dummyPWave_free
	else
		Make/D/free/N=1 dummyPWave_free
	endif
	Wave dpw = dummyPWave_free
	try
		funcValue = axisFunc(dpw, V_min)
	catch
		DoAlert 0, "A serious error was encountered running the axis transformation function. Transform Axis is bailing out."
		return -1
	endtry
	if (numtype(funcValue) != 0)
		DoAlert 0, "The left or bottom end of the axis isn't within the range of the transformation function."
		return -1
	endif
	try
		funcValue = axisFunc(dpw, V_max)
	catch
		DoAlert 0, "A serious error was encountered running the axis transformation function. Transform Axis is bailing out."
		return -1
	endtry
	if (numtype(funcValue) != 0)
		DoAlert 0, "The right or top end of the axis isn't within the range of the transformation function."
		return -1
	endif
	//KillWaves/Z dummyPWave

	// Make the appropriate datafolder to hold waves and variables specific to this graph
	String graphFolderName = folderForThisGraph(theGraph, 1, FullPath = 0)
	if (strlen(graphFolderName) == 0)			// the graph doesn't have a folder yet
		graphFolderName = makeUniqueDFNameForGraph(theGraph, 1)
		NewDatafolder/O/S $("root:Packages:"+graphFolderName)
//		String/G actualGraphName = theGraph
//		Variable/G TransformAxisVersion = TRANSFORMAXISVERSION
	else
		SetDataFolder root:Packages:
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
		//String/G funcCoefSource = GetWavesDataFolder(FuncCoefWave,2)		// ST: 210609 - save the coef location for later updates
		Duplicate/O/D FuncCoefWave, dummyPWave
		SetFormula dummyPWave, GetWavesDataFolder(FuncCoefWave, 2)			// ST: 210731 - setup a wave dependency for updates
	else
		Make/D/O/N=1 dummyPWave
	endif
	
	// Get the present range of the axis and the perpendicular axis
	GetAxis/W=$theGraph /Q $theAxis
	Variable AxisLeft = V_min
	Variable AxisRight = V_max
	
	String MirrorAxisName = AddTrulyFreeAxisForAxis(theGraph, theAxis)

	string axisRecreation = GetAxisRecreation(theGraph, theAxis)
	ApplyAxisRecreation(MirrorAxisName, theGraph, axisRecreation, 0)	// make the mirror axis look like the other
	ModifyGraph/W=$theGraph freePos($MirrorAxisName)=0
	
	String/G MainAxis = theAxis
	String/G MirrorAxis = MirrorAxisName
	String/G AxisRecreationString = axisRecreation
	Variable/G doTicksAtEnds = TicksAtEnds

	// store variables for deciding when the axis range has changed, but use NaN so the first time an update is guaranteed
	Variable/G MainAxisMin = NaN		
	Variable/G MainAxisMax = NaN
	Variable/G MainAxisLength = NaN

	// here we used to call TicksForTransformAxis(), but it caused certain problems. Instead, we store the critical
	// info in globals and depend on the window and axis hooks to fire and run TicksForTransformAxis().
	
	// store for resize events
	Variable/G nticks = numTicks
	Variable/G doMinor = wantMinor
	Variable/G minTickSep = minSep
	Variable/G doTicksAtEnds = TicksAtEnds
	Variable/G doScientificFormat=ParamIsDefault(doScientific) ? 0 : doScientific	// ST: 210524 - add direct creation of scientific axes
	Variable/G doRemoveExtraZeroes=ParamIsDefault(doTrimZeros) ? 1 : doTrimZeros	// ST: 221105 - toggle zero removal

	DoUpdate
	String toplevelWindow = StringFromList(0, theGraph, "#")
	SetWindow $toplevelWindow, hook(TransformAxisHook)=TransformAxisWindowHook1_2
	DoUpdate
	ModifyFreeAxis/W=$theGraph $MirrorAxisName, master = $theAxis, hook=TransformMirrorAxisHook
	
	SetDataFolder ::
	SetWindow $theGraph, UserData(TransAxMirrorFolder) = GetDatafolder(2)
	SetWindow $theGraph, UserData(TransAxVersion) = num2str(TRANSFORMAXISVERSION)
 
	
	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
	
	return 0
end

Function CalculateAxisLength(theGraph, theAxis)
	String theGraph, theAxis
	
	String axisRecreation = GetAxisRecreation(theGraph, theAxis)
	String enabItem = StringByKey("axisEnab(x)", axisRecreation, "=", ";")
	Variable enabStart, enabEnd
	sscanf enabItem, "{%g,%g}", enabStart, enabEnd
	GetWindow $theGraph, psize
	
	Variable returnSize
	if (isHorizAxis(theGraph, theAxis))
		returnSize = (V_right-V_left)*(enabEnd-enabStart)
	else
		returnSize = (V_bottom-V_top)*(enabEnd-enabStart)
	endif
	
	return returnSize
end

//	Structure WMAxisHookStruct
//		char win[MAX_WIN_PATH+1]			// host (sub)window
//		char axName[MAX_OBJ_NAME+1]			// This axis' name
//		char mastName[MAX_OBJ_NAME+1]		// master name or nil
//		
//		// User function can modify these->	
//		char units[MAX_UNITS+1]
//		double min,max
//	EndStructure

Function TransformMirrorAxisHook(info)
	STRUCT WMAxisHookStruct &info

	String theGraph = info.win
	
	String oneAxis = info.mastName
	
	String saveDF = GetDatafolder(1)
	
	if (SetDataFolderForMirrorAxis(theGraph, oneAxis) == 0)
		// these existed prior to version 1.2
		NVAR nticks
		NVAR doMinor
		NVAR minTickSep
		SVAR MirrorAxis
		NVAR doTicksAtEnds
		
		// these are new in version 1.2
		SVAR/Z AxisRecreationString
		if (!SVAR_Exists(AxisRecreationString))
			String/G AxisRecreationString=""
		endif
		NVAR/Z MainAxisMin
		if (!NVAR_Exists(MainAxisMin))
			Variable/G MainAxisMin=NaN
		endif
		NVAR/Z MainAxisMax
		if (!NVAR_Exists(MainAxisMax))
			Variable/G MainAxisMax=NaN
		endif
		NVAR/Z MainAxisLength
		if (!NVAR_Exists(MainAxisLength))
			Variable/G MainAxisLength=NaN
		endif
		NVAR/Z doScientificFormat
		if (!NVAR_Exists(doScientificFormat))
			Variable/G doScientificFormat=0
		endif
		NVAR/Z doRemoveExtraZeroes
		if (!NVAR_Exists(doRemoveExtraZeroes))
			Variable/G doRemoveExtraZeroes=1				// ST: 221105 - default is on
		endif
		
		String axisRecreation = GetAxisRecreation(theGraph, oneAxis)
		String mirrorRecreation = GetAxisRecreation(theGraph, mirrorAxis)
		if (CmpStr(AxisRecreationString, axisRecreation) != 0)
			ApplyAxisRecreationDifferences(MirrorAxis, theGraph, AxisRecreationString, axisRecreation, 0)		// 0: do updates. Set to 1 for debugging
			AxisRecreationString = axisRecreation
		endif
		
		Variable axisLength = CalculateAxisLength(theGraph, oneAxis)
		if ( (MainAxisMin != info.min) || (MainAxisMax != info.max) || (MainAxisLength != axisLength) )
			TicksForTransformAxis(theGraph, oneAxis, nticks, doMinor, minTickSep, MirrorAxis, doTicksAtEnds, doScientificFormat, doRemoveExtraZeroes)
			MainAxisMin = info.min
			MainAxisMax = info.max
			MainAxisLength = axisLength
		endif
	endif

	
	SetDatafolder $saveDF
	
	return 0
End

//********************************
// Stuff for control panels
//********************************

static Function DoTransformAxisPanel(ModifyIt)
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
	Variable/G numRowsToInsert=1					// ST: 210531 - variable for the edit tab (will not get deleted anymore)
	
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
		Variable/G LastTabUsed = 0					// the Modify Transform Axis will show this tab when it is displayed
	endif
	NVAR/Z LastTabUsed = LastMainTabUsed			// ST: 210531 - this global saves the last open tab in the unified panel (new or modify)
	if (!NVAR_Exists(LastTabUsed))
		Variable/G LastMainTabUsed = 0
	endif
	
	String/G TargetName = makeTargetName()
	String/G EditTicksTargetName = makeTargetName()	// ST: 210531 - the graph target for the edit panel
	
	SetDatafolder $saveDF
end

static Function/S makeTargetName()
	return 	makeTargetNamePreamble()+getTopGraph()	// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
end

static Function/S makeTargetNamePreamble()
	return "Target: \\K(1,16019,65535)\f01"
end

static Function/S makeTargetNameNoAxisSuffix()		// ST: 210524 - cast into function for consistency 
	if (strlen(getTopGraph()))
		return "\f]0 \\K(65535,0,0)(No transformed axes)"
	else
//		return "No open graph!"						// ST: 210531 - will be displayed when the list of graphs is empty
		return "Click a graph to activate it."		// JW: 210909 - Now that we can work on subwindows, it is problematic to have some other window listed when the top window might be a panel with graph subwindow.
	endif
end

Function TransformAxisPanelHookFunction(Struct WMWinHookStruct & s)

	String theWindow = s.winName
	GetWindow $theWindow, note
	String WindowNote = S_value

	Variable ModifyingTransformAxis = CmpStr(theWindow, "ModTransformAxisPanel")==0
	Variable UndoingTransformAxis = CmpStr(theWindow, "UndoTransformAxisPanel")==0
	Variable DoingMirrorAxis = 0
	
	String theGraph = getTopGraph()					// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
	
	String EventType = s.eventName
	if (WC_WindowCoordinatesNamedHook(s))
		return 1
	endif

	strswitch(EventType)
		case "activate":
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
		
			SetWindow $theWindow, UserData(LastUsedGraph)=theGraph
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
			break
			
		case "deactivate":
			ControlInfo/W=$theWindow TransformAxisAxisMenu
			theAxis = S_value
			SetWindow $theWindow note = MakeModPanelNote(GetUserData(theWindow, "", "LastUsedGraph"), theAxis)
			break		
	endswitch

	return 0
end

Function/S ListAllTransformAxes(theGraph)
	String theGraph

	if (strlen(theGraph) == 0)					// ST: 210609 - make sure the graph string is not empty
		theGraph = getTopGraph()
		if (strlen(theGraph) == 0)
			return "None Available"
		endif
	endif
	if (WinType(theGraph) != 1)
		return "None Available"
	endif

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
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
		if (!isTransformAxisDFName(aFolderName))
			continue
		endif
		dummy = ":"+PossiblyQuoteName(aFolderName)+":ActualAxisName"
		SVAR/Z ActualAxisName = $dummy
		if (SVAR_Exists(ActualAxisName))
			theList += ActualAxisName+";"
		endif
	endfor
	
	SetDatafolder $saveDF
	return theList
end

Function/S ListTransformMirrorAxes(theGraph)
	String theGraph
	
	String saveDF = GetDatafolder(1)
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()				// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
		if (!isTransformMirrorDFName(aFolderName))
			continue
		endif
		dummy = ":"+PossiblyQuoteName(aFolderName)+":MainAxis"
		SVAR ActualAxisName = $dummy
		theList += ActualAxisName+";"
	endfor
	
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

//static Function/S getTopGraph()							// ST: 210531 - use this instead of WinName(0,1), which is often stale
//	return StringFromList(0,WinList("*", ";", "WIN:1"))
//End

static Function/S getTopGraph()
	String windows = WinList("*", ";", "")
	String topwindow = StringFromList(0, windows)
	
	Variable i = 1
	do														// ST: 210913 - try finding a valid graph, even if it is not the top one
		Variable wtype = WinType(topwindow)
		if (wtype == 1 || wtype == 3 || wtype == 7)			// Top window is a graph or type that can contain a graph
			if (CmpStr("UnifiedTransformAxisPanel", topwindow) != 0)	// Top window isn't the TA control panel itself
				break
			endif
		endif
		topwindow = StringFromList(i++, windows)
	while (strlen(topWindow) > 0)
	
//	if (CmpStr("UnifiedTransformAxisPanel", topwindow) == 0)
//		topwindow = StringFromList(1, windows)				// JW 210909 Top window is the TA control panel! Get the next one down.
//	endif
//	Variable wtype = WinType(topwindow)
//	if (wtype != 1 && wtype != 3 && wtype != 7)
//		return ""											// JW 210909 Top window isn't a graph and isn't a type that can contain a graph
//	endif
	
	GetWindow $topwindow, activeSW							// JW 210909 Ask for the active subwindow. This can also be the top-level, if there are not children, or no child is active
	String activesubwin = S_value
	if (strlen(activesubwin) > 0 && WinType(activesubwin) == 1)
		return activesubwin									// JW 210909 This isn't necessarily an immediate child of topwindow
	elseif (WinType(topwindow) == 1)
		return topwindow
	else
		//return StringFromList(0,WinList("*", ";", "WIN:1"))
		return ""											// JW 210909 With the complexities of allowing subwindow graphs, if the top window doesn't have a graph, simply say No Graphs
	endif	
end

//********************************
// Unified Transform Axis panel							// ST: 210531 - new panel replaces the new axis, undo, modify and edit panels
//********************************
// NOTE: The unified panel reuses some of the control procedures from the old panels

static StrConstant SmallMenuArrowString = "\\Z09\\W623"

static Function DoUnifiedTransformAxisPanel()
	if (WinType("UnifiedTransformAxisPanel") == 7)
		DoWindow/F UnifiedTransformAxisPanel
		return 0
	endif
	
	KillWindow/Z  EditTransformTicksPanel				// better make sure that the old edit window is not open at the same time
	
	TransformAxisPanelInitGlobals()						// initialize globals if not done already
	DFREF TrAxDFR = root:Packages:TransformAxis
	NVAR LastTab = TrAxDFR:LastMainTabUsed				// this global saves the last open tab (new or modify)

	// ST: 210923 - panel centering is only done upon first creation
	// ### center the panel in the monitor or the Windows MDI window
	Variable pnt = ScreenResolution/PanelResolution("UnifiedTransformAxisPanel")
	Variable scrnLeft, scrnTop, scrnRight, scrnBottom, scrnW, scrnH
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		String scrnInfo = StringByKey("SCREEN1", IgorInfo(0))
		Variable rectPos = strsearch(scrnInfo, "RECT=", 0)
		scrnInfo = scrnInfo[rectPos+5, strlen(scrnInfo)-1]
		sscanf scrnInfo, "%d,%d,%d,%d", scrnLeft, scrnTop, scrnRight, scrnBottom
		scrnW = scrnRight-scrnLeft
		scrnH = scrnBottom-scrnTop
	elseif (CmpStr(IgorInfo(2), "Windows") == 0)
		GetWindow kwFrameInner, wsize
		scrnW = V_right-V_left
		scrnH = V_bottom-V_top
	endif
	
	Variable w = 500, h = 300							// size of the panel (will change with the edit tab active)
	Variable anchorLeft = scrnW/2*pnt - w/2, anchorTop = scrnH/2*pnt - h/2

	String fmt="NewPanel/K=1/W=(%s) as \"Transform Axis Control\""
	Execute WC_WindowCoordinatesSprintf("UnifiedTransformAxisPanel",fmt,anchorLeft,anchorTop,anchorLeft+w,anchorTop+h,1)	// pixels
	DoWindow/C UnifiedTransformAxisPanel
	ModifyPanel fixedSize = 1
	
	String theGraph = getTopGraph()
	// if (strlen(theGraph))							// align to top graph if available
		// AutoPositionWindow/M=1/E/R=$theGraph UnifiedTransformAxisPanel
	// endif
	
	// ST: 210916 - shifted all controls down to make more space for the TitleBox
	// controls
	TitleBox TransformAxisTargetTitle		,pos={10,5}	,size={w-20,23}		//,pos={w-105,7} ,size={90,20}			// ST: 210916 - new size for the target box
	TitleBox TransformAxisTargetTitle		,frame=1		,anchor=RT	,labelBack=(65535,65535,65535)	,variable=TrAxDFR:TargetName
	TitleBox TransformAxisTargetTitle		,fsize=12		

	TabControl TransformAxisTabs			,pos={10,60}	,size={w-20,h-65}
	TabControl TransformAxisTabs			,focusRing=0	,value=LastTab		,proc=UnifiedTransformAxisTabProc
	TabControl TransformAxisTabs			,tabLabel(0)="New Axis"
	TabControl TransformAxisTabs			,tabLabel(1)="Modify or Undo"
	TabControl TransformAxisTabs			,tabLabel(2)="Edit Ticks"		// these tab names are deleted and re-set when switching tabs inside UnifiedTransAxTabEnableDisable()
	
	Button TransformHelpButton				,pos={12,35}			,size={125,20}	,title="Help: New Axis"					,proc=UnifiedTransAxHelpButtonProc
	
	// ### New tab
	PopupMenu TransformAxisNewMenu			,pos={20,100}		,size={200,20}	,title="Axis:"
	PopupMenu TransformFunctionMenu			,pos={20,125}		,size={200,20}	,title="Function:"
	PopupMenu TransformFuncCoefWaveMenu		,pos={240,125}		,size={220,20}	,title="Coefficient Wave:"
	//Button TransformFuncCreateButton		,pos={235,125}		,size={220,20}	,title="Create New Transform Function"	,proc=CreateTransFuncButtonProc
	CheckBox TransformAxisMirrorCheck		,pos={245,100}		,size={160,20}	,title="Make it a Mirror Axis"
	SetVariable SetTickDensity				,pos={35,175}		,size={160,20}	,title="Tick Density"
	SetVariable SetTickSep					,pos={250,175}		,size={160,20}	,title="Minor Tick Separation"
	CheckBox TransformAxisMinorTicksCheck	,pos={80,205}		,size={120,20}	,title="Minor Ticks"
	CheckBox TicksAtEndsCheckbox			,pos={80,230}		,size={120,20}	,title="Major Ticks at Ends"
	CheckBox ScientificFormatCheckbox		,pos={250,205}		,size={120,20}	,title="Scientific Format Tick Labels"
	CheckBox RemoveExtraZerosCheckbox		,pos={250,230}		,size={120,20}	,title="Remove Trailing Zeros from Labels"
	
	Button TransformAxisDoItButton			,pos={w/2-30,257}	,size={60,24}	,title="Do It"		,fstyle=1			,proc=NewTAxisDoItButtonProc
	
	PopupMenu TransformAxisNewMenu			,mode=1	,bodyWidth= 140	,value= #"ListPlainAxes(\"\")"						// deliberately empty call here - the top graph will be fetched inside the function
	PopupMenu TransformFunctionMenu			,mode=1	,bodyWidth= 140	,value= #"UnifiedTransformFunctionsList()"			,proc=UnifiedTransformFunctionMenuProc
	PopupMenu TransformFuncCoefWaveMenu		,mode=1	,bodyWidth= 120	,value= #"\"_None_;\"+WaveList(\"*\", \";\", \"DIMS:1\")"
	SetVariable SetTickDensity						,bodyWidth= 50	,value= TrAxDFR:TickDensity	,limits={1,50,1}		,proc=UnifiedModVariableUpdateProc
	SetVariable SetTickSep							,bodyWidth= 50	,value= TrAxDFR:tickSep		,limits={0,50,1}		,proc=UnifiedModVariableUpdateProc
	CheckBox TransformAxisMirrorCheck				,fSize=12		,value= 0											,proc=UnifiedModCheckboxUpdateProc
	CheckBox TransformAxisMinorTicksCheck							,value= 0											,proc=UnifiedModCheckboxUpdateProc
	CheckBox TicksAtEndsCheckbox									,value= 0											,proc=UnifiedModCheckboxUpdateProc
	CheckBox ScientificFormatCheckbox								,value= 0											,proc=UnifiedModCheckboxUpdateProc
	CheckBox RemoveExtraZerosCheckbox								,value= 1											,proc=UnifiedModCheckboxUpdateProc
	
	// ### Modify tab
	PopupMenu TransformAxisAxisMenu			,pos={20,100}		,size={200,20}	,title="Axis:"
	Button TransformUndoItButton			,pos={80,130}		,size={140,25}	,title="Untransform Axis"				,proc=TransformAxisUndoItButtonProc
	
	GroupBox TransformAxisRangeGroup		,pos={240,85}		,size={225,85}	,title="Range"
	CheckBox TransformAxisAutoScale			,pos={250,110}		,size={80,20}	,title="Auto Scale"
	CheckBox TransformAxisManualScale		,pos={250,140}		,size={80,20}	,title="Manual Scale:"
	SetVariable transformRangeSetMin		,pos={290,110}		,size={160,20}	,title="Min:"
	SetVariable transformRangeSetMax		,pos={290,140}		,size={160,20}	,title="Max:"
	
	PopupMenu TransformAxisAxisMenu			,mode=1	,bodyWidth=140	,value= #"ListAllTransformAxes(\"\")"				,proc=UnifiedModTransformAxisMenuProc
	CheckBox TransformAxisAutoScale			,mode=1		,fSize=12	,value=1											,proc=TransformRangeCheckBoxProc
	CheckBox TransformAxisManualScale		,mode=1		,fSize=12	,value=0											,proc=TransformRangeCheckBoxProc
	SetVariable transformRangeSetMin				,bodyWidth=70	,value=TrAxDFR:rescaleMin ,limits={-Inf,Inf,1}		,proc=UnifiedModVariableUpdateProc
	SetVariable transformRangeSetMax				,bodyWidth=70	,value=TrAxDFR:rescaleMax ,limits={-Inf,Inf,1}		,proc=UnifiedModVariableUpdateProc
	Button TransformUndoItButton			,help={"Removes transformation from selected axis. The original data and the axis appearance will be restored to the way it was before."}
	
	// ### Edit tab
	ListBox EditTransformTicksListBox		,pos={215,95}		,size={320,270}											,proc=UnifiedTransAxresultsListProc
	
	GroupBox EditTransformTicksInsertGroup	,pos={18,135}		,size={185,105}	,title="Insert Row"
	SetVariable SetNumRowsToInsert			,pos={50,155}		,size={127,20}	,title="Rows to Insert:"
	
	Button EditTformTicksAddRows			,pos={28,180}		,size={165,20}	,title="Insert Before Selection"		,proc=EditTformTicksAddRowsButtonProc
	Button EditTformTicksAddRowsAfter		,pos={28,210}		,size={165,20}	,title="Insert After Selection"			,proc=EditTformTicksAddRowsButtonProc
	Button TransformTicksDeleteRows			,pos={28,245}		,size={165,20}	,title="Delete Selection"				,proc=EditTicksDeleteRowsButtonProc
	Button EditTicksUndoEditsButton			,pos={28,285}		,size={165,25}	,title="Revert to Default"				,proc=EditTicksUndoEditsButtonProc
	
	Button EditTransformTicksApply			,pos={28,325}		,size={65,35}	,title="Apply"		,fstyle=1			,proc=EditTransformTicksDoneProc
	Button EditTransformTicksCancel			,pos={107,325}		,size={85,35}	,title="Undo Last"	,fstyle=1			,proc=EditTransformTicksDoneProc
	
	SetVariable SetNumRowsToInsert					,bodyWidth=50	,value=TrAxDFR:numRowsToInsert	,limits={1,Inf,1}
	ListBox EditTransformTicksListBox		,mode=7	,editStyle=1	,disable=1	,focusRing=0
	Button EditTicksUndoEditsButton			,help={"Undoes all manual edits and reverts the axis to the default tick behavior."}
	
	// ### final panel setup
	SetWindow UnifiedTransformAxisPanel	,note="GRAPH:"+theGraph
	SetWindow UnifiedTransformAxisPanel	,hook(panelHook)=UnifiedTransformAxisPanelHookFunction
	SetWindow UnifiedTransformAxisPanel ,userdata(TRANSAX_UPDATEPANELVERSION)=num2str(TRANSAX_UPDATEPANELVERSION)		// ST: 210923 - write panel version
	
	if (strlen(theGraph))									// ST: 210930 - check for wrong sub-graph hooks
		String toplevelWindow = StringFromList(0, theGraph, "#")
		checkAllSubGraphHooks(toplevelWindow)
	endif
	
	ControlInfo TransformAxisAxisMenu
	if (CmpStr(S_value, "None Available") == 0)				// check available axes in modify tab
		UnifiedTransAxTabEnableDisable(0,0)					// disable all controls other than tab 0
	else
		UnifiedTransAxTabEnableDisable(lastTab,1)			// activate last used tab
	endif
	
	return 0
End

Function UnifiedTransAxresultsListProc(s)					// edit tab: listbox hook function
	STRUCT WMListboxAction &s
	Variable retValue = 0
	if (s.eventCode == 1)									// mouse-down
		Variable nRows = DimSize(s.listWave, 0)
		if (s. col == 2)									// add quick menu to directly insert tick type
			retValue = 1
			PopupContextualMenu "Major;Minor;Subminor;Emphasized;"
			if (V_Flag > 0 && s.row < nRows)
				s.listWave[s.row][2] = S_selection+SmallMenuArrowString
			endif
		endif
	endif
	return retValue
End

Function/S UnifiedTransformFunctionsList()					// adds a create new entry for triggering the function template insertion
	return ListTransformFunctions()+"Create New ...;"
End

Function CreateTransFuncButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.eventCode == 2)
		TransformAxis1_2#CreateTransformationFunctemplate()
	endif
	return 0
End

static Function CreateTransformationFunctemplate()			// insert function template into main procedure window
	String currScrap = GetScrapText()						// copy current scrap text
	DisplayProcedure/W=Procedure							// display main procedure window
	DoIgorMenu "Edit" "Select All"
	DoIgorMenu "Edit" "Copy"
	PutScrapText GetScrapText()+InsertTransAxTemplate()		// modify procedure code
	DoIgorMenu "Edit" "Paste"
	PutScrapText currScrap									// put previous scrap text back
	Execute/P/Q/Z "COMPILEPROCEDURES "						// recompile all
	return 0
End

Static Function/S InsertTransAxTemplate()					// writes out a small transformation function template into the main procedure window
	String funcName = "TransAx_yourname"					// first, find an unique function name (if users fail to rename the function)
	Variable i = 0
	do
		if (strlen(FunctionList(funcName,";","KIND:7")))	// if there is already a function with this name
			funcName = "TransAx_yourname" + num2str(i++)
		else
			break
		endif
	while(1)
	String template = "\r\r// ### This is a Transform Axis function template. Modify to your needs. ###\r"
	template += "// replace 'yourname' with a short name (no spaces; function must begin with 'TransAx_')\r"
	template += "// return a value calculated from input -> examples: (in^2) or (in*1.5+32) or another_func(in,coef)\r"
	template += "Function "+funcName+"(coef, in)\r"
	template += "\tWave/Z coef\t// your coefficient wave if available\r"
	template += "\tVariable in\t// input value from the original axis\r\r"
	template += "\treturn in\rEnd"
	return template
End

Function UnifiedTransAxHelpButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.eventCode == 2)
		Button TransformHelpButton	,win=$(s.win)	,title = "Looking..."
		ControlInfo/W=$(s.win) TransformAxisTabs
		Variable tab = V_Value
		Switch (tab)
			case 0:
				DisplayHelpTopic "Transform Axis Package[Converting a Standard Axis Into a Transform Axis]"
			break
			case 1:
				DisplayHelpTopic "Transform Axis Package[Changing Transform Axis Options]"
			break
			case 2:
				DisplayHelpTopic "Transform Axis Package[Editing the Tick Marks]"
			break
		EndSwitch
		Button TransformHelpButton	,win=$(s.win)	,title="Help: "+SelectString(tab-1,"New Axis","Modify Axis","Edit Ticks")
	endif
	return 0
End

Function UnifiedTransformAxisTabProc(tc) : TabControl
	STRUCT WMTabControlAction& tc
	if (tc.eventCode == 2)
		UnifiedTransAxTabToggleTab(tc.tab)
	endif
	return 0
End

Static Function UnifiedTransAxTabEnableDisable(Variable tab, Variable enable)		// enables / disables and sets tabs
	SVAR TargetName = root:Packages:TransformAxis:TargetName
	TargetName = makeTargetName()
	if (enable == 0)																// create or deletes tabs instead of disabling the tab control
		TabControl TransformAxisTabs ,win=UnifiedTransformAxisPanel	,value=0	,tabLabel(1)=""	,tabLabel(2)=""
		TargetName += makeTargetNameNoAxisSuffix()
	else
		TabControl TransformAxisTabs ,win=UnifiedTransformAxisPanel	,value=tab	,tabLabel(1)="Modify or Undo"	,tabLabel(2)="Edit Ticks"
	endif
	UnifiedTransAxTabToggleTab(tab)
	return 0
End

Static Function/S UnifiedTransAxUpdatePopupLists()									// update axis popups to grab available axes
	PopupMenu TransformAxisAxisMenu	,win=UnifiedTransformAxisPanel ,mode = 1
	PopupMenu TransformAxisNewMenu	,win=UnifiedTransformAxisPanel ,mode = 1
	ControlUpdate/W=UnifiedTransformAxisPanel TransformAxisAxisMenu
	ControlUpdate/W=UnifiedTransformAxisPanel TransformAxisNewMenu
	ControlInfo/W=UnifiedTransformAxisPanel TransformAxisAxisMenu
	return S_Value
End

Static Function UnifiedTransAxTabToggleTab(Variable tab)						 	// handles switching tabs (new axis <=> modify or undo)
	String tab0="", tab1="", tab2=""
	NVAR LastTab = root:Packages:TransformAxis:LastMainTabUsed
	
	// ### New tab
	PopupMenu TransformAxisAxisMenu	,win=UnifiedTransformAxisPanel	,disable=(tab==0)
	tab0 += "TransformFunctionMenu;"
	tab0 += "TransformAxisNewMenu;"
	tab0 += "TransformFuncCoefWaveMenu;"
	tab0 += "TransformAxisMirrorCheck;"
	//tab0 += "TransformAxisDoItButton;"
	//tab0 += "TransformFuncCreateButton;"
	ModifyControlList tab0	,win=UnifiedTransformAxisPanel	,disable=(tab!=0)
	
	// ### Modify tab
	tab1 += "TransformUndoItButton;"
	tab1 += "TransformAxisRangeGroup;"
	tab1 += "TransformAxisAutoScale;"
	tab1 += "TransformAxisManualScale;"
	tab1 += "transformRangeSetMin;"
	tab1 += "transformRangeSetMax;"
	ModifyControlList tab1	,win=UnifiedTransformAxisPanel	,disable=(tab!=1)
	
	// ### Edit tab
	tab2 += "SetTickDensity;"
	tab2 += "SetTickSep;"
	tab2 += "TransformAxisMinorTicksCheck;"
	tab2 += "TicksAtEndsCheckbox;"
	tab2 += "ScientificFormatCheckbox;"
	tab2 += "RemoveExtraZerosCheckbox;"
	tab2 += "TransformAxisDoItButton;"
	ModifyControlList tab2	,win=UnifiedTransformAxisPanel	,disable=(tab>1)		// first, disable shared new & modify controls for edit tab
	tab2 = ""
	
	tab2 += "EditTransformTicksListBox;"
	tab2 += "EditTransformTicksInsertGroup;"
	tab2 += "SetNumRowsToInsert;"
	tab2 += "EditTformTicksAddRows;"
	tab2 += "EditTformTicksAddRowsAfter;"
	tab2 += "TransformTicksDeleteRows;"
	tab2 += "EditTicksUndoEditsButton;"
	tab2 += "EditTransformTicksApply;"
	tab2 += "EditTransformTicksCancel;"
	ModifyControlList tab2	,win=UnifiedTransformAxisPanel	,disable=(tab!=2)
	
	// adjust size to make edit tab fit
	Variable w = 500 + (tab == 2) * 55									// variable size of the panel (in pixel)
	Variable h = 300 + (tab == 2) * 90
	Variable Pnt = ScreenResolution/PanelResolution("UnifiedTransformAxisPanel")
	GetWindow UnifiedTransformAxisPanel wsize
	MoveWindow/W=UnifiedTransformAxisPanel V_left, V_top, V_left + w/Pnt, V_top + h/Pnt
	TabControl TransformAxisTabs, win=UnifiedTransformAxisPanel, size={w-20,h-65}
	TitleBox TransformAxisTargetTitle win=UnifiedTransformAxisPanel	,fixedsize=1 , pos={10,5}	,size={w-20,23}		// ST: 210916 - fixed size for the titlebox
	
	// additional control updates
	Button TransformHelpButton	,win=UnifiedTransformAxisPanel	,title="Help: "+SelectString(tab-1,"New Axis","Modify Axis","Edit Ticks")
	
	if (tab == 0)														// change into refresh graph button on the modify tab
		Button TransformAxisDoItButton ,win=UnifiedTransformAxisPanel ,pos={w/2-30,257} ,size={60,24}  ,title="Do It" ,fstyle=1 ,proc=NewTAxisDoItButtonProc
	elseif (tab == 1)
		Button TransformAxisDoItButton ,win=UnifiedTransformAxisPanel ,pos={w/2-90,257} ,size={180,24} ,title="Manually Refresh Graph" ,fstyle=0 ,proc=UnifiedModRefreshButtonProc
	endif
	
	if (tab == 2)														// use the same axis popup for both modify and edit tabs... just switch the position and proc
		PopupMenu TransformAxisAxisMenu	,win=UnifiedTransformAxisPanel ,pos={2,100}  ,size={200,20} ,proc=EditTicksTransformAxisMenuProc
	else
		PopupMenu TransformAxisAxisMenu	,win=UnifiedTransformAxisPanel ,pos={20,100} ,size={200,20} ,proc=UnifiedModTransformAxisMenuProc
	endif	
	
	ControlInfo/W=UnifiedTransformAxisPanel TransformAxisAxisMenu
	if (CmpStr(S_value, "None Available") != 0 && tab == 1)
		UnifiedUpdateControlsForAxis(S_value)							// update modify tab controls
	endif
	if (tab == 2)
		TransformAxisUpdateEditTicks()									// update listbox contents
	endif
	if (tab < 2 && LastTab == 2)										// if switched from the edit tab
		Execute/P/Q "EditTicksGraphHasChanged()"						// check if edits have been made, and ask user what to do
	endif
	
	LastTab = tab
	return 0
End

Function UnifiedModRefreshButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s
	if (s.eventCode == 2)
		RefreshGraph()
	endif
	return 0
End

Function UnifiedModCheckboxUpdateProc(s) : CheckBoxControl				// live update of axis when settings check-boxes within the modify tab
	STRUCT WMCheckboxAction &s
	if (s.eventCode == 2)
		ControlInfo/W=$(s.win) TransformAxisTabs
		if (V_Value == 1)												// modify tab selected
			TransformAxisApplyModifications(s.win)
		endif
	endif
	return 0
End

Function UnifiedModVariableUpdateProc(s) : SetVariableControl			// live update of axis when settings variables within the modify tab
	STRUCT WMSetVariableAction &s
	if (s.eventCode == 1 || s.eventCode == 2)
		ControlInfo/W=$(s.win) TransformAxisTabs
		if (V_Value == 1)												// modify tab selected
			TransformAxisApplyModifications(s.win)
		endif
	endif
	return 0
End

Function UnifiedModTransformAxisMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	if (s.eventCode == 2)
		UnifiedUpdateControlsForAxis(s.popStr)
	endif
	return 0
End

Function UnifiedTransformFunctionMenuProc(s) : PopupMenuControl			// the 'Create New' entry triggers the template insert function
	STRUCT WMPopupAction &s
	if (s.eventCode == 2)
		if (CmpStr(s.popStr,"Create New ...") == 0)
			TransformAxis1_2#CreateTransformationFunctemplate()
			PopupMenu TransformFunctionMenu	,win=$s.win ,mode=1
			ControlUpdate/W=$s.win TransformFunctionMenu
		endif
	endif
End

Static Function UnifiedUpdateControlsForAxis(theAxis)					// updates all modify controls (range + axis settings)
	String theAxis
	
	TransformPresetAxisOptions("UnifiedTransformAxisPanel", getTopGraph(), theAxis)	
	if (IsTransformAxis(getTopGraph(), theAxis))
		UnifiedTransAxRangeToggleDisable(1)
		TransformPresetRangeControls("UnifiedTransformAxisPanel",getTopGraph(), theAxis)
	elseif (IsTransformMirrorAxis(getTopGraph(), theAxis))
		UnifiedTransAxRangeToggleDisable(0)
	endif
	
	String panelNote = MakeModPanelNote(getTopGraph(), theAxis)
	SetWindow UnifiedTransformAxisPanel note=panelNote
End

Static Function UnifiedTransAxRangeToggleDisable(Variable activate)		// activate (1) or deactivate (0) manual range controls in modify tab - if 0 then 'automatic' stays selected
	if (activate == 0)
		CheckBox TransformAxisAutoScale	 	,win=UnifiedTransformAxisPanel	,value=1
		CheckBox TransformAxisManualScale 	,win=UnifiedTransformAxisPanel	,value=0
	endif
	CheckBox TransformAxisAutoScale	 		,win=UnifiedTransformAxisPanel							
	CheckBox TransformAxisManualScale 		,win=UnifiedTransformAxisPanel	,disable=2*(activate==0)
	SetVariable transformRangeSetMin 		,win=UnifiedTransformAxisPanel	,disable=2*(activate==0)
	SetVariable transformRangeSetMax 		,win=UnifiedTransformAxisPanel	,disable=2*(activate==0)
	return 0
End

Function UnifiedTransformAxisPanelHookFunction(Struct WMWinHookStruct & s)
	if (WC_WindowCoordinatesNamedHook(s))
		return 1
	endif

	NVAR LastMainTab = root:Packages:TransformAxis:LastMainTabUsed					// last main tab setting in unified control panel
	
	StrSwitch(s.eventName)
		case "activate":
			Variable updatePanelNum = str2num(GetUserData(s.WinName, "", "TRANSAX_UPDATEPANELVERSION"))
			updatePanelNum = numtype(updatePanelNum)==2 ? 1.2 : updatePanelNum		// ST: 210923 - check panel version; if there is no info assume it is version 1.2 (Igor 9 initial release)
			if (updatePanelNum < TRANSAX_UPDATEPANELVERSION)						// ST: 210923 - if panel is old then reopen
				Execute/P/Q "KillWindow "+s.WinName
				Execute/P/Q "TransformAxis1_2#DoUnifiedTransformAxisPanel()"
			endif
			Execute/P/Q "UnifiedTransformAxisPanelUpdateTarget(\""+s.WinName+"\")"	// ST: 210913 - push target update function into the queue
			break
		case "deactivate":
			ControlInfo/W=$s.winName TransformAxisAxisMenu
			SetWindow $s.winName note = MakeModPanelNote(GetUserData(s.winName, "", "LastUsedGraph"), S_value)
			break
		case "killVote":
			if (LastMainTab == 2)													// edit tab is active
				if (EditTicksChangesHaveBeenMade())									// some unsaved changes in the edit tab
					Execute/P/Q "EditTicksGraphHasChanged()"						// ask if edits should be applied
					Execute/P/Q "KillWindow/Z UnifiedTransformAxisPanel"			// kill the panel for real now (EditTicksChangesHaveBeenMade() should not trigger anymore)
					return 2
				endif
			endif
			break
		case "kill":
			EditTicksKillWaves()													// if panel is closed then the edit waves are killed (as replacement for a 'done' button)				
			break
	EndSwitch
	return 0
end

Function UnifiedTransformAxisPanelUpdateTarget(String panelName)
	if (WinType(panelName) != 7)
		return 0
	endif
	
	Variable GraphHasChanged = 1, AxisHasChanged = 1, AxisTypeHasChanged = 1, AxisPositionInList = 1
	String theAxis, theGraph = getTopGraph()										// theGraph comes out empty if there is no graph to work with
	String CurrentAxisList = ListAllTransformAxes(theGraph)
	
	GetWindow $panelName, note
	String oldGraph = StringByKey("GRAPH", S_value)
	String oldAxis = StringByKey("AXIS", S_value)
	String oldAxisType = StringByKey("AXISTYPE", S_value)
	
	if (strlen(theGraph))															// ST: 210930 - check for wrong sub-graph hooks
		String toplevelWindow = StringFromList(0, theGraph, "#")
		checkAllSubGraphHooks(toplevelWindow)
	endif
	
	if (CmpStr(theGraph, oldGraph) == 0 && strlen(theGraph))						// it's the same graph as before and there is actually a graph
		GraphHasChanged = 0
		AxisPositionInList = WhichListItem(oldAxis, CurrentAxisList)
		if (AxisPositionInList < 0)
			PopupMenu TransformAxisAxisMenu	,win=$panelName ,mode=1
		else
			AxisHasChanged = 0
			PopupMenu TransformAxisAxisMenu	,win=$panelName ,mode=AxisPositionInList+1
			if ( (CmpStr(oldAxisType, "Mirror") == 0) && (IsTransformMirrorAxis(theGraph, oldAxis)) )
				AxisTypeHasChanged = 0
			elseif ( (CmpStr(oldAxisType, "Transform") == 0) && (IsTransformAxis(theGraph, oldAxis)) )
				AxisTypeHasChanged = 0
			endif
		endif
	else
		PopupMenu TransformAxisNewMenu	,win=$panelName ,mode=1
		PopupMenu TransformAxisAxisMenu	,win=$panelName ,mode=1
	endif
		
	NVAR LastMainTab = root:Packages:TransformAxis:LastMainTabUsed					// last main tab setting in unified control panel
	if (LastMainTab == 2)															// this needs to come before LastMainTab is changes inside UnifiedTransAxTabEnableDisable()
		Execute/P/Q "EditTicksGraphHasChanged()"									// for edit tab: handle graph updates (also updates the ticks list)
	endif
	
	SetWindow $panelName, UserData(LastUsedGraph)=theGraph
	if ( (GraphHasChanged + AxisHasChanged + AxisTypeHasChanged) == 0)
		return 0
	endif
	
	ControlUpdate/W=$panelName TransformAxisNewMenu
	ControlUpdate/W=$panelName TransformAxisAxisMenu
	
	ControlInfo/W=$panelName TransformAxisAxisMenu
	theAxis = S_Value
	if (LastMainTab == 1 && (AxisHasChanged || AxisTypeHasChanged) )				// handle only if the modify tab is active
		UnifiedUpdateControlsForAxis(theAxis)										// set up range controls
	endif
	
	if (GraphHasChanged)
		if (CmpStr(CurrentAxisList, "None Available") == 0 || !strlen(theGraph))
			UnifiedTransAxTabEnableDisable(0,0)										// disable all controls other than tab 0
		else					
			UnifiedTransAxTabEnableDisable(LastMainTab,1)							// re-activate tab
		endif
	endif
	return 0
End

static Function checkAllSubGraphHooks(String theGraph)								// ST: 210930 - check all sub-graphs for misplaced hooks
	if (WinType(theGraph) == 1)
		checkAndFixSubGraphHook(theGraph)
	endif

	String Children = ChildWindowList(theGraph)
	Variable i, nChildren = ItemsInList(children)
	if (nChildren > 0)
		for (i = 0; i < nChildren; i++)
			checkAllSubGraphHooks(theGraph+"#"+StringFromList(i, Children))			// recursive
		endfor
	endif
End

static Function checkAndFixSubGraphHook(String theGraph)							// ST: 210930 - a function to remove sub-graph hooks placed by style macros) and attaches them to the main graph
	if (StrSearch(theGraph, "#", 0) == -1)			// not a subgraph
		return 0
	endif
	GetWindow/Z $theGraph hook(TransformAxisHook)
	String hookFunc = S_Value
	if (strlen(hookFunc))							// delete unnecessary hook
		SetWindow $theGraph hook(TransformAxisHook)=$""
		String toplevelWindow = StringFromList(0, theGraph, "#")
		GetWindow/Z $toplevelWindow hook(TransformAxisHook)
		if (!strlen(S_Value))						// top graph has no hook yet -> add
			SetWindow $toplevelWindow hook(TransformAxisHook)=$hookFunc
			TA_PatchUpDuplicatedGraphs(toplevelWindow)
			HandleResizeOrModifiedEvent(toplevelWindow, TA_ResizeEvent)				// refresh the graph
		endif
	endif
	return 0
End

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
	Execute WC_WindowCoordinatesSprintf("NewTransformAxisPanel",fmt,44,60,508,331,1)	// pixels

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
	SetVariable SetTickDensity,limits={0,50,1},value= TickDensity,bodyWidth= 50

	CheckBox TransformAxisMinorTicksCheck,pos={76,143},size={77,14},title="Minor Ticks"
	CheckBox TransformAxisMinorTicksCheck,font="Geneva"
	CheckBox TransformAxisMinorTicksCheck,value=0

	CheckBox TicksAtEndsCheckbox,pos={76,169},size={114,14},title="Major Ticks at Ends"
	CheckBox TicksAtEndsCheckbox,font="Geneva"
	CheckBox TicksAtEndsCheckbox,value= 0

	SetVariable SetTickSep,pos={226,169},size={163,15},title="Minor Tick Separation"
	SetVariable SetTickSep,font="Geneva"
	SetVariable SetTickSep,limits={0,50,1},value= tickSep,bodyWidth= 50

	Button TransformAxisDoItButton,pos={41,239},size={60,20},proc=NewTAxisDoItButtonProc,title="Do It"

	Button TransformCancelButton,size={60,20},proc=NewTAxisCancelButtonProc,title="Cancel"
	Button TransformCancelButton,pos={367,238}

	Button TransformHelpButton,pos={199,237},size={70,20},proc=TransAxNewHelpButtonProc,title="Help"

	Variable/G root:Packages:TransformAxis:ModifyingTransformAxis=0
	
	SetWindow NewTransformAxisPanel,note="GRAPH:"+WinName(0,1)
	SetWindow NewTransformAxisPanel,hook(PanelHook)=TransformAxisPanelHookFunction
	
	SetDatafolder $SaveDF
end

Function TransAxNewHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Converting a Standard Axis Into a Transform Axis]"
	Button TransformHelpButton,title = "Help"
End

Function NewTAxisDoItButtonProc(s) : ButtonControl		// ST: 210524 - switch to struct based control
	STRUCT WMButtonAction &s
	if (s.eventCode != 2)
		return 0
	endif
	
	Variable UnifiedTransformAxis = CmpStr(s.win, "UnifiedTransformAxisPanel")==0
	//String saveDF = GetDatafolder(1)
	
	if (UnifiedTransformAxis)							// ST: 210524 - in the unified panel the name is different
		ControlInfo/W=$(s.win) TransformAxisNewMenu
	else
		ControlInfo/W=$(s.win) TransformAxisAxisMenu
	endif
	String theAxis = S_value
	String theGraph = getTopGraph()						// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	if (CmpStr(theAxis, "None Available") == 0)
		//SetDatafolder $saveDF
		return 0
	endif
	
	ControlInfo/W=$(s.win) TransformFunctionMenu
	String theFunc = "TransAx_"+S_value

	ControlInfo/W=$(s.win) TransformFuncCoefWaveMenu
	Wave/Z coefWave = $S_value
	
	ControlInfo/W=$(s.win) SetTickDensity
	Variable tickDensity = V_value
	
	ControlInfo/W=$(s.win) SetTickSep
	Variable tickSep = V_value
	
	ControlInfo/W=$(s.win) TransformAxisMinorTicksCheck
	Variable doMinorTicks = V_value
	
	ControlInfo/W=$(s.win) TicksAtEndsCheckbox
	Variable TicksAtEnds = V_value
	
	ControlInfo/W=$(s.win) ScientificFormatCheckbox							// ST: 210524 - new option in the unified panel... create scientific axis from the start
	Variable Scientific = V_flag == 0? 0 : V_value
	
	ControlInfo/W=$(s.win) RemoveExtraZerosCheckbox							// ST: 221105 - added toggle for removing trailing zeros in version 1.38
	Variable doTrimZeros = V_flag == 2 ? V_value : 1						// ST: 221105 - default is on
	
	ControlInfo/W=$(s.win) TransformAxisMirrorCheck
	if (V_value)
		SetupTransformMirrorAxis(theGraph, theAxis, theFunc, coefWave, tickDensity, doMinorTicks, tickSep, TicksAtEnds, doScientific=Scientific, doTrimZeros=doTrimZeros)
	else
		SetupTransformTraces(theGraph, theAxis, theFunc, coefWave, tickDensity, doMinorTicks, tickSep, TicksAtEnds, doScientific=Scientific, doTrimZeros=doTrimZeros)
	endif
	
	if (UnifiedTransformAxis)
		theAxis = UnifiedTransAxUpdatePopupLists()					// ST: 210525 - update both pupup menus to reload available axes
		if (CmpStr(theAxis, "None Available") != 0)					// ST: 210604 - make sure the axis has been created properly
			UnifiedTransAxTabEnableDisable(1,1)
		endif
	else
		DoWindow/K NewTransformAxisPanel
	endif
end

Function NewTAxisCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DoWindow/K NewTransformAxisPanel
end

Function/S ListPlainAxes(theGraph)
	String theGraph
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()									// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
		if (strlen(theGraph) == 0)									// ST: 210531 - there are no open graphs
			return "None Available"
		endif
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
	Execute WC_WindowCoordinatesSprintf("ModTransformAxisPanel",fmt,44,60,508,331,1)	// pixels

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

	CheckBox ScientificFormatCheckbox,pos={76,194},size={142,14},title="Scientific Format Tick Labels"
	CheckBox ScientificFormatCheckbox,value= 0

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
		TransformPresetRangeControls("ModTransformAxisPanel",WinName(0,1), selectedAxis)
		TransformAxisPanelTabProc("", 0)
		TabControl ModTransformAxisTab,disable = 0
	elseif (IsTransformMirrorAxis(WinName(0,1), selectedAxis))
		TransformAxisPanelTabProc("", LastTabUsed)
		TabControl ModTransformAxisTab,disable = 2
	endif
	TransformPresetAxisOptions("ModTransformAxisPanel",WinName(0,1), selectedAxis)
	
	SetWindow ModTransformAxisPanel, note=MakeModPanelNote(WinName(0,1), selectedAxis)
	SetWindow ModTransformAxisPanel,hook(panelHook)=TransformAxisPanelHookFunction
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

Function ModTransformAxisApplyButtonProc(s) : ButtonControl		// ST: 210524 - switch to struct based control to get access to the calling panel name
	STRUCT WMButtonAction &s
	if (s.eventCode == 2)
		TransformAxisApplyModifications(s.win)
	endif
	return 0
End

Static Function TransformAxisApplyModifications(String panel)	// ST: 210526 - function separated out for easier calling in other code
	ControlInfo/W=$(panel) TransformAxisAxisMenu
	String theAxis = S_value
	String theGraph = getTopGraph()								// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	
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

	ControlInfo/W=$(panel) TicksAtEndsCheckbox
	Variable TicksAtEnds = V_value

	ControlInfo/W=$(panel) TransformAxisMinorTicksCheck
	Variable doMinorTicks = V_value

	ControlInfo/W=$(panel) SetTickDensity
	Variable tickDensity = V_value

	ControlInfo/W=$(panel) SetTickSep
	Variable tickSep = V_value

	ControlInfo/W=$(panel) transformRangeSetMin
	Variable rescaleMin = V_value

	ControlInfo/W=$(panel) transformRangeSetMax
	Variable rescaleMax = V_value

	ControlInfo/W=$(panel) ScientificFormatCheckbox
	Variable doScientific = V_value

	ControlInfo/W=$(panel) RemoveExtraZerosCheckbox					// ST: 221105 - added toggle for removing trailing zeros in version 1.38
	Variable doTrimZeros = V_flag == 2 ? V_value : 1				// ST: 221105 - default is on

	NVAR panelMin = root:Packages:TransformAxis:rescaleMin
	NVAR panelMax = root:Packages:TransformAxis:rescaleMax
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
		ControlInfo/W=$(panel) TransformAxisAutoScale
		if (V_value)
			SetAxis/W=$theGraph/A $theAxis
			DoAutoScale = 1
			DoUpdate/W=$theGraph								// ST: 210616 - update graph once to get the new range
		else
			if (NewTransformAxisRange(theGraph, theAxis, rescaleMin, rescaleMax) == -1)		// -1 = failed
				if (oldIsAutoScale)
					SetAxis/W=$theGraph/A $theAxis
				elseif (!oldIsAutoScale)
					NewTransformAxisRange(theGraph, theAxis, oldAxisMin, oldAxisMax)
				endif
				panelMin = oldAxisMin							// ST: 210623 - revert panel range as well
				panelMax = oldAxisMax
			endif
		endif
	endif

	String MName = getMirrorAxisName(theGraph, theAxis)
	if (TicksForTransformAxis(theGraph, theAxis, tickDensity, doMinorTicks, tickSep, MName, TicksAtEnds, doScientific, doTrimZeros) < 0)		// getMirrorAxisName returns "" if the axis does not have a transform mirror axis
		DoAlert 0, "Ticking failed for modified axis options."
		if (oldIsAutoScale && !DoAutoScale)
			SetAxis/W=$theGraph/A $theAxis
		elseif (!oldIsAutoScale)
			NewTransformAxisRange(theGraph, theAxis, oldAxisMin, oldAxisMax)
		endif
		panelMin = oldAxisMin									// ST: 210623 - revert panel range as well
		panelMax = oldAxisMax
	endif

	SetDatafolder $saveDF
	
	if (CmpStr(panel, "UnifiedTransformAxisPanel")==0)			// ST: 210526 - bring unified panel to front, since modifications are dynamic here
		DoWindow/F UnifiedTransformAxisPanel
	endif
	return 0
End

Function ModTransformAxisMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum	// which item is currently selected (1-based)
	String popStr		// contents of current popup item as string

	NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
	
	Variable theTab = LastTabUsed
	TransformPresetAxisOptions("ModTransformAxisPanel",WinName(0,1), popStr)
	if (IsTransformAxis(WinName(0,1), popStr))	// Transform axes are shown in menu, so range controls are appropriate
		TransformPresetRangeControls("ModTransformAxisPanel",WinName(0,1), popStr)
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
	CheckBox ScientificFormatCheckbox, disable= (tab!=0)

	CheckBox TransformAxisManualScale, disable= (tab!=1)
	CheckBox TransformAxisAutoScale, disable= (tab!=1)
	SetVariable transformRangeSetMin, disable= (tab!=1)
	SetVariable transformRangeSetMax, disable= (tab!=1)
	
	NVAR LastTabUsed = root:Packages:TransformAxis:LastTabUsed
	LastTabUsed = tab
end

Function TransformPresetRangeControls(thePanel,theGraph, theAxis)
	String thePanel,theGraph, theAxis
	
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
	
	TransformRangeCheckBoxToggle(thePanel,IsAutoScaled(theGraph, theAxis))// ST: 210526 - separated function for updating controls
	
	// if (IsAutoScaled(theGraph, theAxis))		// auto-scaled
		// TransformRangeCheckBoxProc("TransformAxisAutoScale",1)
	// else
		// TransformRangeCheckBoxProc("TransformAxisManualScale",1)
	// endif
	
	SetDatafolder $saveDF
end	

Function TransformPresetAxisOptions(thePanel, theGraph, theAxis)
	String thePanel, theGraph, theAxis
	
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
	NVAR doScientificFormat
	NVAR/Z doRemoveExtraZeroes
	
	CheckBox TransformAxisMinorTicksCheck	,win=$thePanel ,value = doMinor			// ST: 210920 - make panel-aware
	CheckBox TicksAtEndsCheckbox			,win=$thePanel ,value = doTicksAtEnds
	CheckBox ScientificFormatCheckbox		,win=$thePanel ,value = doScientificFormat
	ControlInfo/W=$(thePanel) RemoveExtraZerosCheckbox
	if (V_flag == 2 && NVAR_Exists(doRemoveExtraZeroes))								// ST: 221105 - new option to toggle zero removal in version 1.38
		CheckBox RemoveExtraZerosCheckbox	,win=$thePanel ,value = doRemoveExtraZeroes
	endif
	tickDensity = nticks
	tickSep = minTickSep
	
	SetDatafolder $saveDF
end	

Function TransformRangeCheckBoxProc(s) : CheckBoxControl		// ST: 210526 - update to struct based control for access to panel name
	STRUCT WMCheckboxAction &s
	if (s.eventCode == 2)
		TransformRangeCheckBoxToggle(s.win, CmpStr(s.ctrlName, "TransformAxisAutoScale") == 0)
		if (CmpStr(s.win, "UnifiedTransformAxisPanel") == 0)	// ST: 210526 - apply changes immediately
			TransformAxisApplyModifications(s.win)
		endif
	endif
	return 0
End

Static Function TransformRangeCheckBoxToggle(string panelName, variable isAuto)	// ST: 210531 - separate out for easier use in the unified panel
	CheckBox TransformAxisManualScale	,win=$panelName	,value=(isAuto == 0)
	CheckBox TransformAxisAutoScale		,win=$panelName	,value=isAuto
	SetVariable transformRangeSetMin	,win=$panelName	,disable= (isAuto == 0 ? 0 : 2), frame = (isAuto ? 0 : 1)
	SetVariable transformRangeSetMax	,win=$panelName	,disable= (isAuto == 0 ? 0 : 2), frame = (isAuto ? 0 : 1)
	return 0
End

//********************************
// Untransform Axis Panel
//********************************

Function fUndoTransformAxisPanel()

	String SaveDF = GetDatafolder(1)
	SetDatafolder root:Packages:TransformAxis

	Variable hasTransformAxes = strlen(ListTransformAxes(WinName(0,1))) > 0
	Variable hasTransformMirrorAxes = strlen(ListTransformMirrorAxes(WinName(0,1))) > 0

	String fmt="NewPanel/K=1/W=(%s) as \"Undo Transform Axis\""
	Execute WC_WindowCoordinatesSprintf("UndoTransformAxisPanel",fmt,44,60,451,189,1)	// pixels

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
	SetWindow UndoTransformAxisPanel, hook(PanelHook)=TransformAxisPanelHookFunction

	SetDatafolder $SaveDF
end

Function TransAxUntransHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Button TransformHelpButton,title = "Looking..."
	DisplayHelpTopic "Transform Axis Package[Untransforming a Transform Axis]"
	Button TransformHelpButton,title = "Help"
End

Function TransformAxisUndoItButtonProc(s) : ButtonControl			// ST: 210524 - switch to struct based control
	STRUCT WMButtonAction &s
	if (s.eventCode != 2)
		return 0
	endif

	ControlInfo/W=$(s.win) TransformAxisAxisMenu
	String theAxis = S_value
	if (CmpStr(theAxis, "None Available") == 0)
		return 0
	endif
	
	if (IsTransformAxis(getTopGraph(), theAxis))					// transformed axes selected
		UndoTransformTraces(getTopGraph(), theAxis)
	elseif (isTransformMirrorAxis(getTopGraph(), theAxis))			// mirror transform axes selected
		UndoTransformMirror(getTopGraph(), theAxis)
	else
		DoAlert 0, "BUG: TransformAxisUndoItButtonProc called for an axis that isn't a transformed axis."
	endif
	PopupMenu TransformAxisAxisMenu ,win=$(s.win) ,mode = 1
	ControlUpdate/W=$(s.win) TransformAxisAxisMenu
	
	if (CmpStr(s.win,"UnifiedTransformAxisPanel") == 0)				// ST: 210524 - special handling of the unified panel
		theAxis = UnifiedTransAxUpdatePopupLists()					// ST: 210531 - updates both new and modify axis lists and returns the available axis to modify
		if (CmpStr(theAxis, "None Available") == 0)					// ST: 210524 - switch tabs to 'new' if there is no further axis
			UnifiedTransAxTabEnableDisable(0,0)
		else
			UnifiedUpdateControlsForAxis(theAxis)					// ST: 210524 - set up range controls
		endif
	endif
	
	return 0
End

Function UnTransformAxisCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K UndoTransformAxisPanel
end

//********************************
// Edit Transform Ticks Panel
//********************************

// this is called by the Edit Ticks menu item
static Function TransformEditTicksShowPanel()
	if (WinType("EditTransformTicksPanel") != 7)
		// panel doesn't exist yet
		TransformEditTicks(1)
	else
		// panel already exists. This will cause an activate event which will run the panel's window hook, which will
		// check that the top graph is still the same
		DoWindow/F EditTransformTicksPanel
	endif
end

Function TransformEditTicks(buildPanel)								// ST: 210531 - dummy function for backwards compatibility
	Variable buildPanel					// 1- need to actually make the panel. 0- just re-build the data structures because the selected axis or the top graph changed
	if (buildPanel)
		TransformAxisPanelInitGlobals()
		fEditTransformTicks()			// builds control panel with list box hidden
	endif
	TransformAxisUpdateEditTicks()
End

// Sets up data, etc. for the Edit Transform Ticks panel
// This function does not use try-catch to handle function aborts- the setup code should have detected any abort before getting here.
Function TransformAxisUpdateEditTicks()
	String saveDF = GetDatafolder(1)
	String theGraph = getTopGraph()										// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
	
	String thePanel
	Variable UnifiedTransAxis = 0
	if (CmpStr(StringFromList(0,WinList("*", ";","WIN:64")),"UnifiedTransformAxisPanel") == 0)		// ST: 210526 - add exception for unified panel (if the panel is in front)
		thePanel = "UnifiedTransformAxisPanel"
		UnifiedTransAxis = 1
	else
		thePanel = "EditTransformTicksPanel"
	endif
	
	SVAR EditTicksTargetName = root:Packages:TransformAxis:EditTicksTargetName
	EditTicksTargetName = makeTargetName();
	//DoWindow/F $thePanel
	
	if (UnifiedTransAxis)
		ControlUpdate/W=$thePanel TransformAxisAxisMenu
		ControlInfo/W=$thePanel TransformAxisAxisMenu
	else
		ControlUpdate/W=$thePanel transformAxisMenu
		ControlInfo/W=$thePanel transformAxisMenu
	endif
	String theAxis = S_value
	
	if (UnifiedTransAxis && CmpStr("None Available", theAxis) == 0)		// ST: 210531 - if there is no axis, then don't even try to change folders
		SetDatafolder $saveDF
		return 0
	endif
	
	Variable MirrorSelected = isTransformMirrorAxis(theGraph, theAxis), err
	if (MirrorSelected)
		err = SetDataFolderForMirrorAxis(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			ListBox EditTransformTicksListBox ,win=$thePanel ,disable=1	// ST: 210524 - make sure to disable the listbox here
			ReportSetMirrorDFError(theGraph, theAxis, err, 1)			// alert on error
			theAxis = "None Available"
		endif
	else
		err = SetGraphAndAxisDataFolder(theGraph, theAxis)
		if (err)
			SetDatafolder $saveDF
			ListBox EditTransformTicksListBox ,win=$thePanel ,disable=1	// ST: 210524 - make sure to disable the listbox here
			ReportSetGraphAndAxisDFError(theGraph, theAxis, err, 1)		// alert on error
			theAxis = "None Available"
		endif
	endif
	SetWindow $thePanel, note=MakeModPanelNote(theGraph, theAxis)
	
	if (CmpStr("None Available", theAxis) == 0)
		SetDatafolder $saveDF
		return 0
	endif
	
	Wave tickVals
	Wave/T tickLabels
	SVAR axisTransformFunction
	FUNCREF TransformAxisTemplate axisFunc=$axisTransformFunction
	Wave dummyPWave
	
	Variable funcValue, i, numTicks = DimSize(tickVals, 0)
	Make/O/T/N=(numTicks, 3) listboxWave
	Make/D/O/N=(numTicks, 3) listboxSelectionWave

	if (MirrorSelected)
		for (i = 0; i < numTicks; i += 1)
			funcValue = axisFunc(dummyPWave, tickVals[i])
			listboxWave[i][0] =  num2str(funcValue)
			listboxWave[i][1,2] = tickLabels[i][q-1]
			if (UnifiedTransAxis)
				listboxWave[i][2] += SmallMenuArrowString			// ST: 210610 - add drop-down arrow
			endif
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
		Variable useGetAxis = 0
		getTransformAxisRootBrackets(theGraph, theAxis, axisFunc, dummyPWave, tRightValue, tLeftValue, autoScale, lowBracket, highBracket, useGetAxis)
		for (i = 0; i < numTicks; i += 1)
			FindRoots/T=1e-14/Q/Z=(tickVals[i])/H=(highBracket)/L=(lowBracket) axisFunc, dummyPWave
			digits = LabelDigits(tickLabels, i)+1
			sprintf tempStr, "%.*g", digits, V_root
			listboxWave[i][0] = tempStr
			listboxWave[i][1,2] = tickLabels[i][q-1]
			if (UnifiedTransAxis)
				listboxWave[i][2] += SmallMenuArrowString			// ST: 210610 - add drop-down arrow
			endif
		endfor
	endif
	listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
	if (UnifiedTransAxis)
		listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
	endif
	//listboxSelectionWave = 6	// make all cells editable (2), editing requires double-click (4)
	SetDimLabel 1, 0, 'Transformed Data Value', listboxWave
	SetDimLabel 1, 1, 'Tick Label', listboxWave
	SetDimLabel 1, 2, 'Tick Type', listboxWave
	Duplicate/O tickVals, tickValsUndo
	Duplicate/O/T tickLabels, tickLabelsUndo
	Duplicate/T/O listboxWave, listboxCompareWave		// when a new axis is selected or the active graph changes, use this to see if changes have been made

	ListBox EditTransformTicksListBox, win=$thePanel, listWave=listboxWave, selWave=listboxSelectionWave
	if (!UnifiedTransAxis)				// ST: 210531 - don't control disable state here for unified panel
		ListBox EditTransformTicksListBox, win=$thePanel, disable=0
	endif
	
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
	String fmt="NewPanel/K=1/W=(%s) as \"Edit Transform Axis Ticks\""					// ST: 210524 - kill = 1 behavior for consistency
	Execute WC_WindowCoordinatesSprintf("EditTransformTicksPanel",fmt,35,67,596,404,1)	// pixels

//	NewPanel/K=2 /W=(35,67,596,404) as "Edit Transform Axis Ticks"
	DoWindow/C EditTransformTicksPanel
	ModifyPanel fixedSize = 1
	
	Variable TransformAxesExist = strlen(ListTransformAxes(WinName(0,1))) > 0
	Variable MirrorAxesExist = strlen(ListTransformMirrorAxes(WinName(0,1))) > 0
	
	PopupMenu transformAxisMenu,pos={47,46},size={130,20},proc=EditTicksTransformAxisMenuProc,title="Axis:"
	PopupMenu transformAxisMenu,mode=1,bodyWidth= 120									// ST: 210524 - make the axis a bit wider to fit text
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
	SetWindow EditTransformTicksPanel, hook=EditTicksPanelHookFunction
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
	
	if (WinType("UnifiedTransformAxisPanel") == 7)					// ST: 210531 - alternative call from unified panel
		GetWindow UnifiedTransformAxisPanel, note
	else
		GetWindow EditTransformTicksPanel, note
	endif
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
	if (WinType("UnifiedTransformAxisPanel") == 7)					// ST: 210531 - alternative call from unified panel
		GetWindow UnifiedTransformAxisPanel, note
	else
		GetWindow EditTransformTicksPanel, note
	endif
	String PanelNote = S_value
	return StringByKey("GRAPH", PanelNote)
end

// Returns the name of the axis stored in the panel's window note
// That is the axis the panel is set to work on
Function/S EditTicksGetPanelAxis()
	if (WinType("UnifiedTransformAxisPanel") == 7)					// ST: 210531 - alternative call from unified panel
		GetWindow UnifiedTransformAxisPanel, note
	else
		GetWindow EditTransformTicksPanel, note
	endif
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

		Execute/P/Q "EditTicksGraphHasChanged()"
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
	
	if (SetDFForEditTicksProcs(isMirror) < 0)				// sets it to the DF for the previously selected graph and axis so we can check for changes
		SetDatafolder $saveDF								// If we get here, it means that the axis stored in the panel note is no longer a transform axis.
		ChangesWereMade = 0
		oldAxisExists = 0
	endif

	if (ChangesWereMade)									// if this is still non-zero, it means that the axis stored in the panel note is some kind of
															// transform axis and it needs to be checked to see if it has been edited and changes are pending
		Wave/T listboxCompareWave
		Wave/T listboxWave
		Wave listboxSelectionWave		
		String theGraph = EditTicksGetPanelGraph()
		String theAxis = EditTicksGetPanelAxis()
		
		if (!WaveExists(listboxCompareWave) || !WaveExists(listboxWave) )
			ChangesWereMade = 0								// If we get here, it means that somehow things have been trashed. It could be that
															// the user untransformed and then re-transformed the axis since the last time the
															// panel was active. In that case it is appropriate to continue as if this axis had
															// never been edited.
		else
			ChangesWereMade = EditTicksChangesHaveBeenMade()
		endif
	endif
	
	Variable UnifiedTransAxis = WinType("UnifiedTransformAxisPanel") == 7
	
	if (ChangesWereMade)
		DoAlert 1, "You made changes to the transform axis \""+theAxis+"\" in the graph \""+theGraph+"\" and we are about to start editing a different axis. Apply previous changes?"
		if (V_Flag == 1)
			// apply the changes
//			String saveTopGraph = getTopGraph()		// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
//			DoWindow/F $theGraph
			
			Variable errorRow
			Variable result = EditTicksApplyChanges(errorRow)
			if (result == 1)
				listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
				//listboxSelectionWave = 6
				listboxSelectionWave[errorRow][2] = 7
				if (UnifiedTransAxis)
					listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
					listboxSelectionWave[errorRow][2] = 1
				endif
				// **** EXIT ****
				DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
				SetDatafolder $saveDF
				return 0
			elseif (result == 2)
				listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
				//listboxSelectionWave = 6
				listboxSelectionWave[errorRow][0] = 7
				if (UnifiedTransAxis)
					listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
					listboxSelectionWave[errorRow][0] = 3
				endif
				// **** EXIT ****
				DoAlert 0,  "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
				SetDatafolder $saveDF
				return 0
			else
				EditTicksMakeChangeWaves()			// ST: 210615 - Save changes to be persistent
//				DoWindow/F $saveTopGraph
			endif
		else
			// cancel the changes
			EditTicksUndoChanges()
		endif
		DoUpdate
	endif		// changes were made
	// re-build data structures to reflect new top graph
	if (oldAxisExists && !UnifiedTransAxis)
		EditTicksKillWaves()		// kill the old waves
	endif
	//TransformEditTicks(0)			// build data but don't create the panel
	TransformAxisUpdateEditTicks()	// ST: 210531 - new listbox update function
	
	SVAR EditTicksTargetName = root:Packages:TransformAxis:EditTicksTargetName
	EditTicksTargetName = makeTargetName();
	
	SetDatafolder $saveDF
end

Function EditTicksTransformAxisMenuProc(s) : PopupMenuControl		// ST: 210610 - change to struct based control to get access to the panel name
	STRUCT WMPopupAction &s
	if (s.eventCode != 2)
		return 0
	endif
	
	Variable isMirror, Changed = 1
	String SaveDF = GetDatafolder(1)
	Variable UnifiedTransAxis = CmpStr(s.win, "UnifiedTransformAxisPanel")==0
	
	if (SetDFForEditTicksProcs(isMirror) < 0)
		Changed = 0
	endif
	if (Changed)	
		Changed = EditTicksChangesHaveBeenMade()
	endif
	
	GetWindow $s.win, note
	String oldAxis = StringByKey("AXIS", S_value)
	if (CmpStr(s.popStr,oldAxis) == 0 && Changed)					// ST: 210615 - do nothing if it's the same axis
		SetDatafolder $saveDF
		return 0
	endif
	
	if (Changed)
		DoAlert 1, "You have made changes to the currently selected axis. Apply the changes?"
		if (V_Flag == 1)
			// apply the changes
			Variable errorRow
			Variable result = EditTicksApplyChanges(errorRow)
			Wave listboxSelectionWave
			
			if (result == 1)
				listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
				//listboxSelectionWave = 6
				listboxSelectionWave[errorRow][2] = 7
				if (UnifiedTransAxis)
					listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
					listboxSelectionWave[errorRow][2] = 1
				endif
				// **** EXIT ****
				DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
				SetDatafolder $saveDF
				return 0
			elseif (result == 2)
				listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
				//listboxSelectionWave = 6
				listboxSelectionWave[errorRow][0] = 7
				if (UnifiedTransAxis)
					listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
					listboxSelectionWave[errorRow][0] = 3
				endif
				// **** EXIT ****
				DoAlert 0,  "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
				SetDatafolder $saveDF
				return 0
			endif
			EditTicksMakeChangeWaves()				// ST: 210615 - Save changes to be persistent
		else
			// cancel the changes
			EditTicksUndoChanges()
		endif
	endif		// changes were made
	// re-build data structures to reflect new top graph
	if (UnifiedTransAxis)
		PopupMenu TransformAxisAxisMenu, win=UnifiedTransformAxisPanel, popMatch=s.popStr		// ST: 210615 - if edits were applied then the popup tends to jump back to the old entry... make sure it's properly set
		String panelNote = MakeModPanelNote(getTopGraph(), s.popStr)
		SetWindow UnifiedTransformAxisPanel note=panelNote
	else
		EditTicksKillWaves()		// kill the old waves
	endif
	//TransformEditTicks(0)			// build data but don't create the panel
	TransformAxisUpdateEditTicks()	// ST: 210531 - new listbox update function

	SetDatafolder $saveDF
end

Function EditTransformTicksDoneProc(s) : ButtonControl		// ST: 210604 - switch to struct based control
	STRUCT WMButtonAction &s
	if (s.eventCode != 2)
		return 0
	endif
	
	Variable doneBtn = (CmpStr(s.ctrlName, "EditTransformTicksDone") == 0)
	Variable applyBtn = (CmpStr(s.ctrlName, "EditTransformTicksApply") == 0)
	Variable undoBtn = (CmpStr(s.ctrlName, "EditTransformTicksCancel") == 0)
	
	if (CmpStr(s.win, "UnifiedTransformAxisPanel")==0)
		ControlInfo/W=$(s.win) TransformAxisAxisMenu
	else
		ControlInfo/W=$(s.win) transformAxisMenu
	endif
	if (CmpStr(S_value, "None Available") == 0)
		strswitch (s.ctrlName)
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

	if ( doneBtn || applyBtn )
		Variable errorRow
		Variable result = EditTicksApplyChanges(errorRow)		// result == 3 can't happen because we already changed df above
		if (result == 1)
			listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
			//listboxSelectionWave = 6
			listboxSelectionWave[errorRow][2] = 7
			if (CmpStr(s.win, "UnifiedTransformAxisPanel")==0)
				listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
				listboxSelectionWave[errorRow][2] = 1
			endif
			DoAlert 0, "The selected cell contains an illegal tick type code. It must be \"Major\",  \"Minor\",  \"Subminor\", or  \"Emphasized\"."
			SetDatafolder $saveDF
			return -1
		elseif (result == 2)
			listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
			//listboxSelectionWave = 6
			listboxSelectionWave[errorRow][0] = 7
			if (CmpStr(s.win, "UnifiedTransformAxisPanel")==0)
				listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
				listboxSelectionWave[errorRow][0] = 3
			endif
			DoAlert 0, "The selected cell contains a bad value, that is, a value that results in NaN when transformed."
			SetDatafolder $saveDF
			return -1
		endif
	endif

	if (undoBtn)
		EditTicksUndoChanges()
		//TransformEditTicks(0)
		TransformAxisUpdateEditTicks()	// ST: 210531 - new listbox update function
		SetDatafolder $saveDF
		return 0
	endif
	if ( doneBtn || applyBtn )
		EditTicksMakeChangeWaves()
		if (CmpStr(s.win, "UnifiedTransformAxisPanel")==0)							// ST: 210604 - update edit comparison for the unified panel
			Duplicate/T/O listboxWave, listboxCompareWave
		endif
	endif
	if (doneBtn)
		EditTicksKillWaves()
		//NVAR numRowsToInsert = root:Packages:TransformAxis:numRowsToInsert		// ST: 210531 - no need to kill global variable here
		//KillVariables numRowsToInsert
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

	Wave/Z tickValsUndo								// ST: 211108 - these waves may not exist.
	Wave/T/Z tickLabelsUndo
	Wave/T/Z listboxWave
	Wave/Z listboxSelectionWave		

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
	
	Duplicate/T/free listboxWave, cleanListbox		// ST: 210610 - need to remove drop-down arrows before proceeding
	
	errorRow = -1
	for (i = 0; i < nrows; i += 1)
		cleanListbox[i][2] = RemoveEnding(listboxWave[i][2],SmallMenuArrowString)
		
		if (CmpStr(cleanListbox[i][2], "Major") == 0)
			continue
		elseif (CmpStr(cleanListbox[i][2], "Minor") == 0)
			continue
		elseif (CmpStr(cleanListbox[i][2], "Subminor") == 0)
			continue
		elseif (CmpStr(cleanListbox[i][2], "Emphasized") == 0)
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
			Variable highBracket = V_max
			Variable lowBracket = V_min
			if (V_max < V_min)
				Variable dtemp = V_min
				V_min = V_max
				V_max = dtemp
			endif
			// at this point, everything should be OK and we don't need try-catch
			Variable untransformedMin = V_min
			Variable untransformedMax = V_max
			AxMin = axisFunc(dummyPWave, untransformedMin)
			AxMax = axisFunc(dummyPWave, untransformedMax)

			Redimension/N=(nrows) tickVals
			Redimension/N=(nrows, 2) tickLabels
			for (i = 0; i < nrows; i += 1)
				// JW 120206 I believe this solves a problem where occasionally FindRoots fails when the bracket and the sought-for value are nearly the same. It think the axis code
				// sometimes allows a tick label to appear when the axis range very nearly includes that tick label but doesn't quite (by a very small fractional amount). So since at the
				// ends of the axis we already know the number we need, we just use those numbers instead of using FindRoots.
				if (AlmostEqual(TickLabelToNumber(cleanListbox[i][0]), AxMax, 1e-4) )
					temp =  untransformedMax
				elseif (AlmostEqual(TickLabelToNumber(cleanListbox[i][0]), AxMin, 1e-4) )
					temp =  untransformedMin
				else
					FindRoots/T=1e-14/Q/Z=(TickLabelToNumber(cleanListbox[i][0]))/H=(highBracket)/L=(lowBracket) axisFunc, dummyPWave
					temp =  V_root
				endif
				if (V_flag)
					errorRow = i
					errorReturn = 2
				endif
				tickVals[i] = temp
				tickLabels[i] = cleanListbox[i][q+1]
			endfor
		else
			Redimension/N=(nrows) tickVals
			Redimension/N=(nrows, 2) tickLabels
			Wave dummyPWave
			for (i = 0; i < nrows; i += 1)
				temp = axisFunc(dummyPWave, TickLabelToNumber(cleanListbox[i][0]))
				if (numtype(temp) == 2)
					errorRow = i
					errorReturn = 2
					break
				endif
				tickVals[i] = temp
				tickLabels[i] = cleanListbox[i][q+1]
			endfor
		endif
	endif
	
	SetDatafolder $saveDF
	return errorReturn
end

Function EditTformTicksAddRowsButtonProc(s) : ButtonControl		// ST: 210610 - switch to struct based control
	STRUCT WMButtonAction &s
	if (s.eventCode != 2)
		return 0
	endif

	String SaveDF = GetDatafolder(1)
	Variable isMirror
	if (SetDFForEditTicksProcs(isMirror) < 0)
		SetDatafolder $saveDF
		return 0
	endif

	Wave/T listboxWave
	Wave listboxSelectionWave
	Variable AddBefore = 0
	if (CmpStr(s.ctrlName, "EditTformTicksAddRows") == 0)
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
	listboxSelectionWave = 2//+4*(q!=1)	// ST: 210531 - make tick label cells immediately editable
	if (CmpStr(s.win, "UnifiedTransformAxisPanel")==0)
		listboxSelectionWave[][2] = 0	// ST: 210610 - prevent editing the tick type
		listboxWave[insertionRow, insertionRow+numRowsToInsert-1][2] = "Select"+SmallMenuArrowString
	endif
	//listboxSelectionWave[insertionRow, insertionRow+numRowsToInsert-1] = 6		// make all cells editable (2), editing requires double-click (4)
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
	Wave tickLabelsUndo
	Wave tickValsUndo
	Duplicate/T/O cleanTickLabels, tickLabels
	Duplicate/O cleanTickVals, tickVals
	Duplicate/O tickLabelsUndo, tickLabelsUndoSave
	Duplicate/O tickValsUndo, tickValsUndoSave
	
	Duplicate/O tickVals, sortIndex, sortVals	// ST: 210531 - make sure the clean ticks are sorted for consistency
	Duplicate/T/O tickLabels, sortLabels
	MakeIndex tickVals, sortIndex
	tickVals = sortVals[sortIndex[p]]
	tickLabels = sortLabels[sortIndex[p]]
	KillWaves/Z sortIndex, sortVals, sortLabels

	//TransformEditTicks(0)
	TransformAxisUpdateEditTicks()				// ST: 210531 - new listbox update function
	
	Duplicate/O tickLabelsUndoSave, tickLabelsUndo
	Duplicate/O tickValsUndoSave, tickValsUndo
	KillWaves/Z tickLabelsUndoSave,tickValsUndoSave
	
	KillWaves/Z addedTicks, addedTickLabels, changedTicks, changedTickLabels, deletedTicks	// ST: 210611 - kill all changes made as well
	
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

// As of version 1.2, it should be OK to use Abort in transform axis functions. BUT-
// abort should be used ONLY for things that are fundamentally wrong and would prevent a function from working at all.
// For instance, TransformAxisTemplate includes Abort because the template should NEVER actually run. If it runs, it means
// that there was a problem with intended transformation function. Also, TransAx_ModifiedReciprocal() executes Abort if
// the coefficient wave is NULL or if it has too few points. The function can't give any meaningful results without a valid
// coefficient wave.
//
// Note that some of these functions check for input values in undefined ranges. If this is detected, the proper thing to do is
// to return NaN. DO NOT call Abort in this case. NaN values in undefined regions can be used to restrict an axis to defined ranges,
// but an abort will cause BIG problems.

Function TransformAxisTemplate(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	Abort "For some reason we are executing the template function."
	return NaN
end

Function TransAx_Reciprocal(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	if ( (val <= 0) )
		return NaN
	endif
	
	return 1/val
end

Function TransAx_ModifiedReciprocal(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	if (!WaveExists(w) || (numpnts(w) < 2))
		Abort "The ModifiedReciprocal transformation function requires a coefficient wave with two points."
	endif
	
	Variable xx = (val+w[1])

	if (xx <= 0)
		return NaN
	endif

	return w[0]/xx
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

Function TransAx_SquareRoot(w, val)
	Wave/Z w			// a parameter wave, if desired. Argument must be present for FindRoots.
	Variable val
	
	return sign(val)*sqrt(abs(val))
end



static Function PrintAxisInfo(theGraph, theAxis)
	String theGraph, theAxis
	
	if (strlen(theGraph) == 0)
		theGraph = getTopGraph()		// ST: 210531 - instead of WinName(0,1), which is stale when graphs close
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
