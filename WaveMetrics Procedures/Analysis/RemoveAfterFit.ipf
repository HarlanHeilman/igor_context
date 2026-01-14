#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.0

#include <Strings As Lists>
#include <Keyword-Value>

//	RemoveAfterFit version 1.0

//	Removes the various automatically-added traces from a graph after doing a curve fit.
//	There are two user interfaces:  a control panel, and an item in the Macros menu that brings up
//	a missing-parameter dialog.  You can selectively remove the auto-trace, auto-residual,
//	auto-confidence bands and auto-prediction bands.  Does not handle error-bar style confidence
// 	and prediction bands.  In the case of the model trace and confidence and prediction bands, the
//	function simply searches for traces with the appropriate prefixes and removes those traces.
//	When removing a residual, it also searches for the vertical axis that was shortened to make
//	room for the residual plot, and restores it to full length.
//
//	Note that the residual removal is not very sophisticated.  It always restores the vertical data
//	axis to full length, even if it was not full-length before the fit.  It does not look for other
//	axes that might collide with the re-extended axis.  Thus, this procedure handles most cases:
//	those that result from a curve fit on a simple two-axis graph.  It may actually damage a
//	complicated graph using stacked free axes.

// NOTE ADDED 6/12/00
// The removal of a residual trace is done better by built-in code that automatically restores
// shortened axes. The built-in code is more sophisiticated than this procedure file.

Menu "Macros"
	"Remove After Fit...", RemoveAfterFit()
	"Remove After Fit Panel...", MakeRemovePanel()
end

Macro RemoveAfterFit(Fit, Resid, Conf,Pred, KillWvs)
	Variable Fit, Resid, Conf,Pred, KillWvs
	Prompt Fit, "Remove Model?", popup "No;Yes"
	Prompt Resid, "Remove Residual?", popup "No;Yes"
	Prompt Conf, "Remove Confidence Band?", popup "No;Yes"
	Prompt Pred, "Remove Prediction Band?", popup "No;Yes"
	Prompt KillWvs, "Kill waves after removal?", popup "No;Yes"
	
	Fit -= 1
	Resid -= 1
	Conf -= 1
	Pred -= 1
	KillWvs -= 1
	
	 fRemoveAfterFit(Fit, Resid, Conf,Pred, KillWvs)
end

Function fRemoveAfterFit(Fit, Resid, Conf,Pred,KillWvs)
	Variable Fit, Resid, Conf,Pred,KillWvs
	
	String TList=TraceNameList("", ";", 1)
	String theTrace, ResAxisInfo, ResAxis
	Variable AxisNameLen
	
	Variable i
	
	if (Fit)
		i = 0
		do
			theTrace = GetStrFromList(TList, i, ";")
			if (strlen(theTrace) == 0)
				break
			endif
			if (CmpStr(theTrace[0,3], "fit_")==0)
				if (KillWvs)
					Wave w=TraceNameToWaveRef("", theTrace)
				endif
				RemoveFromGraph $theTrace
				if (KillWvs)
					KillWaves w
				endif
			endif
			i += 1
		while (1)
	endif
	if (Conf)
		i = 0
		do
			theTrace = GetStrFromList(TList, i, ";")
			if (strlen(theTrace) == 0)
				break
			endif
			if ((CmpStr(theTrace[0,2], "UC_")==0) %| (CmpStr(theTrace[0,2], "LC_")==0))
				if (KillWvs)
					Wave w=TraceNameToWaveRef("", theTrace)
				endif
				RemoveFromGraph $theTrace
				if (KillWvs)
					KillWaves w
				endif
			endif
			i += 1
		while (1)
	endif
	if (Pred)
		i = 0
		do
			theTrace = GetStrFromList(TList, i, ";")
			if (strlen(theTrace) == 0)
				break
			endif
			if ((CmpStr(theTrace[0,2], "UP_")==0) %| (CmpStr(theTrace[0,2], "LP_")==0))
				if (KillWvs)
					Wave w=TraceNameToWaveRef("", theTrace)
				endif
				RemoveFromGraph $theTrace
				if (KillWvs)
					KillWaves w
				endif
			endif
			i += 1
		while (1)
	endif
	if (Resid)
		i = 0
		do
			theTrace = GetStrFromList(TList, i, ";")
			if (strlen(theTrace) == 0)
				break
			endif
			if (CmpStr(theTrace[0,3], "Res_")==0)
				ResAxisInfo = TraceInfo("", theTrace, 0)
				ResAxis = StrByKey("YAXIS", ResAxisInfo)
				AxisNameLen = strlen(ResAxis)-1
				if (KillWvs)
					Wave w=TraceNameToWaveRef("", theTrace)
				endif
				RemoveFromGraph $theTrace
				if (KillWvs)
					KillWaves w
				endif
				ModifyGraph axisEnab($(ResAxis[4,AxisNameLen]))={0,1}
			endif
			i += 1
		while (1)
	endif
end

Function RemoveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable Fit, Resid, Conf,Pred, KillWvs
	
	ControlInfo FitCheck
	Fit = V_value
	ControlInfo ResidCheck
	Resid = V_value
	ControlInfo ConfCheck
	Conf = V_value
	ControlInfo PredCheck
	Pred = V_value
	ControlInfo PredCheck
	KillWvs = V_value
	
	 fRemoveAfterFit(Fit, Resid, Conf,Pred, KillWvs)
End

Proc MakeRemovePanel()
	Silent 1
	
	if (WinType("RemoveAfterFitPanel"))
		DoWindow/F RemoveAfterFitPanel
	else
		RemoveAfterFitPanel()
	endif
end

Window RemoveAfterFitPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(147,127,382,325)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1
	DrawText 36,34,"Remove:"
	CheckBox FitCheck,pos={54,46},size={107,20},title="Model",value=0
	CheckBox ResidCheck,pos={54,65},size={107,20},title="Residual",value=0
	CheckBox ConfCheck,pos={54,84},size={135,20},title="Confidence Band",value=0
	CheckBox PredCheck,pos={54,104},size={135,20},title="Prediction Band",value=0
	Button RemoveButton,pos={77,172},size={94,20},proc=RemoveButtonProc,title="Remove Now"
	CheckBox KillCheck,pos={54,134},size={174,20},title="and Kill the Waves, too",value=0
EndMacro
