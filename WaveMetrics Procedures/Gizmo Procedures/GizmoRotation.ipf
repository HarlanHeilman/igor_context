#pragma rtGlobals=3		// Use modern global access method.
#pragma ModuleName=GizmoRotation
#pragma Igorversion=6.2	// for #pragma rtGlobals=3
#pragma version=6.2		// this version shipped with Igor 6.2
#include <GizmoUtils>

// 23AUG02			(Initial version) Procedure that adds a panel with rotation controls.
//						The panel gets updated via a Gizmo window hook function.
// 22OCT03				Removed DoWindow/F GizmoRotationPanel which caused double entry into WM_LB clicks.
// 05DEC03				Added win=GizmoRotationPanel to make sure the checkbox appears on the correct window.
// 09AUG07 JP: 6.02:	Uses named hook function instead of global un-named hookFunction.
//						Added #pragma ModuleName=GizmoRotation, made some functions static.
//			 			Arranged for Execute of Gizmo commands in temp data folder to avoid littering global variables into the root data folder.
// 02SEP07 JP: 6.03:	Update of Rotation panel blocked unless gizmo is TopGizmo.
// 02JAN08 JP: 6.03A:	Corrected WMXSideViewButtonProc() and WMYSideViewButtonProc().
// 18SEP08 JP: 6.05:	Now works when included into an independent module. Most functions made static.
//						ModifyGizmo namedHookStr requires the Gizmo that shipped with Igor 6.05 and Igor 6.1
// 11MAY10 JP: 6.2:	#pragma rtGlobals=3

Function WMInitGizmoRotation()

	String gizmoName= TopGizmo()
	if(strlen(gizmoName) )
		DoWindow/F GizmoRotationPanel
		if(V_Flag==0)
			String oldDF=SetTempDF()
			Variable/G 	eulerA=0,eulerB=0,eulerC=0, spinRight=0, spinUp=0
			SetDataFolder oldDF
			WMMakeGizmoRotationPanel()
		endif
		UpdateHookFunction(gizmoName, "GizmoRotation", GizmoNamedHookFunction(), "GizmoRotationHook")
	else
		DoAlert 0, "You must have an open Gizmo Window."
	endif
End

static Function WMMakeGizmoRotationPanel()

	NewPanel /K=1 /W=(11,494,256,684) as "Gizmo Rotation"
	DoWindow/C GizmoRotationPanel
	SetDrawLayer UserBack
	DrawText 23,19,"Euler Angles"
	SetVariable wmGizmoEulerASetVar,pos={9,23},size={96,15},proc=GizmoRotation#WMEulerSetVarProc,title="A:"
	SetVariable wmGizmoEulerASetVar,format="%3.1f", live=1
	SetVariable wmGizmoEulerASetVar,value= root:Packages:WMGizmoRotation:eulerA
	
	SetVariable wmGizmoEulerBSetVar,pos={9,42},size={96,15},proc=GizmoRotation#WMEulerSetVarProc,title="B:"
	SetVariable wmGizmoEulerBSetVar,format="%3.1f", live=1
	SetVariable wmGizmoEulerBSetVar,value= root:Packages:WMGizmoRotation:eulerB
	
	SetVariable wmGizmoEulerCSetVar,pos={9,61},size={96,15},proc=GizmoRotation#WMEulerSetVarProc,title="C:"
	SetVariable wmGizmoEulerCSetVar,format="%3.1f", live=1
	SetVariable wmGizmoEulerCSetVar,value= root:Packages:WMGizmoRotation:eulerC
	
	Button wmFlattenButton,pos={131,5},size={100,20},proc=GizmoRotation#WMFlattenButtonProc,title="Top View"
	Button WMXSideButton,pos={131,32},size={100,20},proc=GizmoRotation#WMXSideViewButtonProc,title="X-Side"
	Button WMYViewButton,pos={131,57},size={100,20},proc=GizmoRotation#WMYSideViewButtonProc,title="Y-Side"

	CheckBox lockMouseCheck,pos={8,85},size={116,14},proc=GizmoRotation#lockMouseCheckProc,title="Lock Mouse Rotation"
	CheckBox lockMouseCheck,value= 0

	CheckBox axesCueCheck,pos={134,85},size={87,14},proc=GizmoRotation#axisCueCheckProc,title="Show Axis Cue"
	CheckBox axesCueCheck,value= 0
	
	Button spinLeft,pos={32,135},size={65,20},proc=GizmoRotation#SpinButtonProc,title="\\W646Spin "
	Button spinRight,pos={154,135},size={65,20},proc=GizmoRotation#SpinButtonProc,title="Spin\\W649"
	Button spinStop,pos={109,135},size={35,20},proc=GizmoRotation#SpinButtonProc,title="\\W616"
	Button spinUp,pos={109,107},size={35,20},proc=GizmoRotation#SpinButtonProc,title="\\Z12\\W617"
	Button spinDown,pos={109,162},size={35,20},proc=GizmoRotation#SpinButtonProc,title="\\Z12\\W623"

	ModifyPanel fixedSize=1, noEdit=1
End


static Function WMEulerSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if( strlen(TopGizmo()) )
		String oldDF=SetTempDF()
		NVAR eulerA=root:Packages:WMGizmoRotation:eulerA
		NVAR eulerB=root:Packages:WMGizmoRotation:eulerB
		NVAR eulerC=root:Packages:WMGizmoRotation:eulerC
		String cmd
		sprintf cmd,"ModifyGizmo euler={%g,%g,%g}",eulerA,eulerB,eulerC
		Execute cmd
		SetDataFolder oldDF
	else
		NoGizmo()
	endif
End

Static Function NoGizmo()

	Beep
	DoWindow GizmoRotationPanel
	if( V_Flag &&(strlen(TopGizmo())== 0) )
		TitleBox doh,win=GizmoRotationPanel,pos={8,109},size={93,12},title="\\K(65535,0,0)No Gizmo Window", frame=0,fStyle=1
		ControlUpdate/W=GizmoRotationPanel doh
		Sleep/S 1
		KillControl/W=GizmoRotationPanel doh
	endif

End

Static Function GizmoRotationFunction(a,b,c)
	Variable a,b,c
	
	NVAR eulerA=root:Packages:WMGizmoRotation:eulerA
	NVAR eulerB=root:Packages:WMGizmoRotation:eulerB
	NVAR eulerC=root:Packages:WMGizmoRotation:eulerC
	
	eulerA=a
	eulerB=b
	eulerC=c
End


// new named Gizmo hook
static Function GizmoRotationNamedHook(s)
	STRUCT WMGizmoHookStruct &s

	strswitch(s.eventName)
		case "rotation":
			if(CmpStr(TopGizmo(),s.winName)== 0 )	// 6.03
				GizmoRotationFunction(s.eulerA,s.eulerB,s.eulerC)
			endif
			break
		case "activate":
			WMUpdateControlsFromGizmo()
			break
	endswitch
	return 0
End

// old unnamed Gizmo hook must remain public so old rotation panels can be updated
Function GizmoRotationHook(str)
	String str

	STRUCT WMGizmoHookStruct s
	
	s.winName= StringByKey("WINDOW",str)
	s.eventName= StringByKey("EVENT",str)
	s.eulerA= NumberByKey("EULERA", str)						
	s.eulerB= NumberByKey("EULERB", str)						
	s.eulerC= NumberByKey("EULERC", str)	

	UpdateHookFunction(s.winName, "GizmoRotation", GizmoNamedHookFunction(), "GizmoRotationHook")

	return GizmoRotationNamedHook(s)
End

Static Function/S SetTempDF()

	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WMGizmoRotation

	return oldDF
End

// gets the un-named hook function
Static Function/S GetGizmoHookFunction(gizmoName)
	String gizmoName
	
	String code= WinRecreation(gizmoName, 0) // 	ModifyGizmo hookFunction=GizmoRotationHook
	String hookFunction=""
	String key="ModifyGizmo hookFunction="
	Variable start= Strsearch(code, key, 0)
	if( start >= 0 )
		start += strlen(key)	// point past what we just found.
		key= num2char(13)
		Variable theEnd= strsearch(code,key, start)
		if( theEnd >= 0 )
			hookFunction= code[start,theEnd-1]
		endif
	endif
	return hookFunction
End

// Igor 6.04 doesn't support independent module names for XOP calls using CallFunction(),
// so only if we're running under Igor 6.1 do we try to establish a GizmoHook function
// with an independent module name.
//
// We're relying on <All Gizmo Procedures> to NOT include gizmo procedures
// into an independent module unless we're running Igor 6.1 or later.
//
static Function/S GizmoNamedHookFunction()

	String hookPath= "GizmoRotation#GizmoRotationNamedHook"
#if NumberByKey("IGORVERS", IgorInfo(0)) >= 6.1
	hookPath= GetIndependentModuleName()+"#"+hookPath
#endif
	return hookPath
End


Static Function UpdateHookFunction(gizmoName, hookName, namedHookFunction, unnamedHookFunction)
	String gizmoName, hookName
	String namedHookFunction		// possibly compound name of named Gizmo hook function, like "ProcGlobal#GizmoRotation#GizmoRotationNamedHook"
	String unnamedHookFunction		// just terminal name of old unnamed Gizmo hook function that we want to replace with the named hook function
	
	String oldDF=SetTempDF()
	String currentHookFunction= GetGizmoHookFunction(gizmoName)
	currentHookFunction=PossiblyRemoveModuleName(currentHookFunction)
	// Is this my old hook un-named function?
	if( CmpStr(currentHookFunction, unnamedHookFunction) == 0 )
		// yep, disable it, because we're going to use the named hook function
		Execute "ModifyGizmo/N="+gizmoName+" hookFunction=$\"\""
		Execute "ModifyGizmo/N="+gizmoName+" hookEvents=0"
	endif
	// install the named hook function
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s namedHookStr={%s,\"%s\"}", gizmoName,hookName,namedHookFunction
	Execute cmd
	SetDataFolder oldDF
End	

static Function/S PossiblyRemoveModuleName(possiblyCompoundName)
	String possiblyCompoundName	// could be just a name, or "module#functionName", even "independentModuleName#moduleName#functionName"
	
	Variable numNames= ItemsInList(possiblyCompoundName,"#")
	if( numNames > 1 )
		possiblyCompoundName= StringFromList(numNames-1,possiblyCompoundName)
	endif
	return possiblyCompoundName
End

// Panel Hook
Function wmRotationPanelHook(str)
	String str
	
	String event= StringByKey("EVENT",str)
	strswitch(event)
		case "deactivate":
		case "activate":
			WMUpdateControlsFromGizmo()
		break
	endSwitch
	return 0
End

Static Function SetGizmoEuler(a,b,c)
	Variable a,b,c
	
	if( strlen(TopGizmo()) )
		String cmd
		sprintf cmd, "ModifyGizmo euler={%g,%g,%g}", a,b,c
		String oldDF=SetTempDF()
		Execute cmd
		SetDataFolder oldDF
		 GizmoRotationFunction(a,b,c)
	else
		NoGizmo()
	endif
 End

static Function WMFlattenButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SetGizmoEuler(0,0,0)
End

static Function WMXSideViewButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SetGizmoEuler(0,-90,-90)	// 6.03A
End

static Function WMYSideViewButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SetGizmoEuler(90,0,-180)	// 6.03A
End


Function WMIsGizmoLocked()

	String topGizmoName= TopGizmo()
	Variable isLocked=0
	String recStr=WinRecreation(topGizmoName,0)
	if(strsearch("lockMouseRotation",recStr,0)>-1)
		isLocked=1
	endif
	return isLocked
End

static Function lockMouseCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( strlen(TopGizmo()) )
		String oldDF=SetTempDF()
		if(!checked)
			Execute "ModifyGizmo lockMouseRotation=0"
		else
			Execute "ModifyGizmo lockMouseRotation=1"
		endif
		SetDataFolder oldDF
	else
		NoGizmo()
	endif
End

static Function axisCueCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( strlen(TopGizmo()) )
		String oldDF=SetTempDF()
		if(!checked)
			Execute "ModifyGizmo showAxisCue=0"
		else
			Execute "ModifyGizmo showAxisCue=1"
		endif
		SetDataFolder oldDF
	else
		NoGizmo()
	endif
End

Function WMUpdateControlsFromGizmo()

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		DoWindow GizmoRotationPanel
		if( V_Flag )
			String oldDF=SetTempDF()
			// this is the time to check for the mouseLock and axisCue
			Execute "GetGizmo MouseLockState"
			NVAR flag = V_Flag								// need something other than V_Flag because it is used below
			Checkbox lockMouseCheck,win=GizmoRotationPanel, value=flag
			Execute "GetGizmo axisCueState"
			NVAR flag = V_Flag
			SetDataFolder oldDF
			Checkbox axesCueCheck,win=GizmoRotationPanel, value=flag
			String titleStr=gizmoName+" Rotation"
			DoWindow/T GizmoRotationPanel, titleStr
			UpdateHookFunction(gizmoName, "GizmoRotation",  GetIndependentModuleName()+"#GizmoRotation#GizmoRotationNamedHook", "GizmoRotationHook")
		else
			// the user closed the window
			UpdateHookFunction(gizmoName, "GizmoRotation", "", "GizmoRotationHook")	// kill the hook
		endif
	endif
End

static Function SpinButtonProc(ctrlName) : ButtonControl
	String ctrlName	// "spinLeft", "spinStop", or "spinRight"	// around the z axis, usually
					// "spinUp", "spinDown"

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		Variable/G root:Packages:WMGizmoRotation:spinRight
		NVAR spinRight= root:Packages:WMGizmoRotation:spinRight
	
		Variable/G root:Packages:WMGizmoRotation:spinUp
		NVAR spinUp= root:Packages:WMGizmoRotation:spinUp
	
		strswitch(ctrlName)
			case "spinLeft":
				spinRight -= 2
				break
			case "spinStop":
				spinRight = 0
				spinUp = 0
				break
			case "spinRight":
				spinRight += 2
				break
			case "spinUp":
				spinUp += 2
				break
			case "spinDown":
				spinUp -= 2
				break
		endswitch
		String oldDF=SetTempDF()
		Execute "modifygizmo idleEventRotation = {"+num2str(spinRight)+","+num2str(spinUp)+"}"
		SetDataFolder oldDF
	else
		NoGizmo()
	endif
End