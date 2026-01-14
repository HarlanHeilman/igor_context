#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion= 7.0	// for ExperimentModified
#pragma version=8.05		// shipped with Igor 8.05
#pragma moduleName=GizmoMovie

#include <GizmoUtils>
#include <Resize Controls>

// 18DEC02 initial work.
// 24DEC02 added screenResolution so display window size appears correctly on the PC
// 10SEP08 commented the Macros below -- this is part of the Gizmo procedures package
// that will get included through the Gizmo menu.
// 10SEP08 added help button and fixed error of possible multiple display windows.
// 09JUN10 (JP): use named gizmo hook, avoided doUpdate altering the rotation range
// 17NOV11 (JP): no longer complains if there is more than one Gizmo window,
// uses GizmoUtils, panel resizing, added PlayMovie button, requires Igor 6.23.
// 18MAY20 (JP): prevented a newly-launched experiment from being marked as unsaved.

#if 0	// set to 1 for debugging
Menu "Macros"
	"Gizmo Movie Panel", gizmoMovieSetup()
End
#endif

static StrConstant ksNone="\K(65535,0,0)<none>"

//=====================================================================================
// The following procedure creates a data folder under packages for storing relevant parameters for the movie creation
// and then proceeds to create the Gizmo Moview control panel.  It assumes that there is a valid Gizmo window from which some parameters can be read.
// A window hook is added to make sure that if a new movie has been started, it is properly closed.  Another window hook is added that connects
// the rotation of Gizmo with the display in the panel.  This one is also removed when the panel is killed.

static Function/S GizmoMovieVar(varName)
	String varName

	String moviesDF= GizmoMovieDF()
	return moviesDF+":"+PossiblyQuoteName(varName)
End

static Function/S GizmoMovieDF()
	String moviesDF= WMGizmoDF()+":Movies"
	NewDataFolder/O $moviesDF
	return moviesDF	// no trailing ":"
End

static Function/S SetGizmoMoviesDF()
	String oldDF= GetDataFolder(1)
	String moviesDF= GizmoMovieDF()
	NewDataFolder/O/S $moviesDF
	return oldDF
End
	
Function gizmoMovieSetup()

	DoWindow/F gizmoMoviePanel				// check if the window already exists
	if(V_Flag)
		return 0
	endif
	
	String oldDF=SetGizmoMoviesDF()
	
	Variable num= NumVarOrDefault(GizmoMovieVar("numFrames"), 180)	// full circle spin
	Variable/G numFrames=num
	
	num= NumVarOrDefault(GizmoMovieVar("startEulerA"), 0)
	Variable/G startEulerA=num
	num= NumVarOrDefault(GizmoMovieVar("dA"), 0)
	Variable/G dA=num

	num= NumVarOrDefault(GizmoMovieVar("startEulerB"), 0)
	Variable/G startEulerB=num
	num= NumVarOrDefault(GizmoMovieVar("dB"), 2)	// full circle spin
	Variable/G dB= num

	num= NumVarOrDefault(GizmoMovieVar("startEulerC"), 0)
	Variable/G startEulerC=num
	num= NumVarOrDefault(GizmoMovieVar("dC"), 0)
	Variable/G dC=num

	Variable/G isNewMovie=0		
	Variable/G frameCounter=0
	
	String fileStr= StrVarOrDefault(GizmoMovieVar("fileNameStr"), ksNone)
	String/G $GizmoMovieVar("fileNameStr") = fileStr

	SetDataFolder oldDF
			
	// check to see that we have an open gizmo
	String gizmoName= TopGizmo()
	if(strlen(gizmoName)<=0)
		doAlert 0,"You must have a Gizmo window for this operation"
		SetDataFolder oldDF
		return 0
	endif
	
	SetMovieRotationForGizmo(gizmoName)

	DoWindow/K gizmoMoviePanel
	
	NewPanel/N=gizmoMoviePanel /K=1 /W=(12,388,428,663) as "Gizmo Movie"
	//ModifyPanel fixedSize=1,noedit=1
	ModifyPanel noedit=1

	SetDrawLayer UserBack
	DrawText 16,50,"Starting orientation:"
	Button startMovieButton,pos={18,7},size={100,20},proc=newMovieButtonProc,title="New Movie"
	TitleBox movieFileTitle,pos={143,11},size={45,12},title="Movie File:",frame=0
	TitleBox movieFileTitle,anchor= RT
	TitleBox movieFile,pos={194,11},size={33,24},frame=0
	TitleBox movieFile,variable= root:Packages:WMGizmo:Movies:fileNameStr

	SetVariable eulerASetVar,pos={16,56},size={100,15},title="Euler A:"
	SetVariable eulerASetVar,format="%.1f"
	SetVariable eulerASetVar,limits={-Inf,Inf,0.1},value= $GizmoMovieVar("startEulerA")
	SetVariable eulerBSetVar,pos={15,75},size={100,15},title="Euler B:"
	SetVariable eulerBSetVar,format="%.1f"
	SetVariable eulerBSetVar,limits={-Inf,Inf,0.1},value= $GizmoMovieVar("startEulerB")
	SetVariable eulerCSetVar,pos={16,94},size={100,15},title="Euler C:"
	SetVariable eulerCSetVar,format="%.1f"
	SetVariable eulerCSetVar,limits={-Inf,Inf,0.1},value= $GizmoMovieVar("startEulerC")

	SetVariable dAsetvar,pos={148,56},size={72,15},title="dA:"
	SetVariable dAsetvar,value= $GizmoMovieVar("dA")
	SetVariable dBsetvar,pos={147,75},size={72,15},title="dB:"
	SetVariable dBsetvar,value= $GizmoMovieVar("dB")
	SetVariable dCsetvar,pos={148,94},size={72,15},title="dC:"
	SetVariable dCsetvar,value= $GizmoMovieVar("dC")

	SetVariable numFramesSetVar,pos={255,54},size={120,15},title="Num Frames:"
	SetVariable numFramesSetVar,value= $GizmoMovieVar("numFrames")
	ValDisplay frameNumberSetVar,pos={272,74},size={103,13},title="Frame #:"
	ValDisplay frameNumberSetVar,value=#GizmoMovieVar("frameCounter")

	Button testRotButton,pos={10,122},size={170,20},proc=testRotationButtonProc,title="Test Rotation Range"
	Button createMovieButton,pos={10,173},size={170,20},proc=createMovieButtonProc,title="Append Rotation Frames",disable=2
	Button appendFrameButton,pos={10,198},size={170,20},proc=appendFrameButtonProc,title="Append Current Frame",disable=2
	Button closeMovieButton,pos={10,223},size={170,20},proc=closeMovieButtonProc,title="Close Movie",disable=0
	Button playMovieButton,pos={10,248},size={170,20},proc=playMovieButtonProc,title="Play Movie"
	Button playMovieButton,disable=CanPlayMovie() ? 0 : 2
	Button WM_GMHelp,pos={281,223},size={90,20},proc=wm_GMHelpButtonProc,title="Help"

	SetWindow gizmoMoviePanel,hook=moviePanelCloseHook

	// panel resizing support
	SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	SetWindow kwTopWin,userdata(ResizeControlsInfo)= A"!!*'\"z!!#C5!!#BCJ,fQL!!*'\"zzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"

	SetDataFolder oldDF
End

// Set up the hook function that will update the rotation coordinates in the panel.
//	Execute "ModifyGizmo hookFunction=WMGizmoRotationHook, hookEvents=7"
// Igor 6.2: use a named hook to avoid overwriting the only unnamed hook.		 
Function SetMovieRotationForGizmo(gizmoName)
	String gizmoName	// set to "" to unset the movie rotation hook from all Gizmo windows
	
	String format= "ModifyGizmo/N=%s namedHookStr={MovieRotation,\"%s\"}"	// gizmoName,namedHookFunction
	String cmd

	String oldDF=SetGizmoMoviesDF()

	String allGizmos= GizmoList(gizmoName, "gizmoNameList")
	Variable i, n= ItemsInList(allGizmos)
	for( i=0;i<n; i+=1 )
		String gn= StringFromList(i,allGizmos)
		if( CmpStr(gizmoName,gn) != 0 )			// different gizmo (test result is true if gizmoName is "")
			RemoveMovieRotationFromGizmo(gn)	// removes the hook to prevent competition
		endif
	endfor

	// check to see that we have an open gizmo
	if( (strlen(gizmoName) <= 0) || WinType(gizmoName) != 13 )
		return 0
	endif

	// always set (or reset) the rotation hook
	String namedHookFunction= GetIndependentModuleName()+"#WMGizmoMovieRotationNamedHook"
	sprintf cmd, format, gizmoName, namedHookFunction
	Execute/Q/Z cmd

	// And get (or re-get) the gizmo's rotation
	GetGizmoRotation(gizmoName)

	SetDataFolder oldDF
End

Function RemoveMovieRotationFromGizmo(gizmoName)
	String gizmoName

	String oldDF=SetGizmoMoviesDF()
	Execute/Q/Z "ModifyGizmo/N="+gizmoName+" namedHookStr={MovieRotation,\"\"}"
	SetDataFolder oldDF
End

//=====================================================================================
Function wm_GMHelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "Gizmo Movie Panel"
		break
	endswitch

	return 0
End

//=====================================================================================
Function/S openGraphWindow()
	// This is the silliest part: you have to have an open graph in order to start a movie.
	// Therefore, we create a graph that the user should not close while we are messing 
	// around.  The graph is created with the same size of a Gizmo window which must also
	// exist at this time.
	// Get the size of the Gizmo window
	String gizmoName= TopGizmo()
	if( strlen(gizmoName) == 0 )
		DoAlert 0, "Need a Gizmo window!"
		return ""
	endif
	SetMovieGizmo(gizmoName)
	SetMovieRotationForGizmo(gizmoName)
	
	String oldDF=SetGizmoMoviesDF()
	Execute "ModifyGizmo/N="+gizmoName+" BringToFront"
	SetDataFolder oldDF

	// Create the graph window, if necessary; otherwise modify its size
	Variable left, top, right, bottom
	GetGizmoPoints(gizmoName, left, top, right, bottom)
	Variable widthPoints= right-left
	Variable heightPoints= bottom-top
	
	if(WinType("wm_tmpGizmoMovieWindow") != 1)
		DoWindow/K wm_tmpGizmoMovieWindow
		Display/K=2/W=(50,50,50+widthPoints,50+heightPoints)/N=wm_tmpGizmoMovieWindow
	else
		MoveWindow/W=wm_tmpGizmoMovieWindow  50,50,50+widthPoints,50+heightPoints
	endif
	
	return gizmoName
End

//=====================================================================================

// Returns gizmo that was topmost when New Movie was clicked, or else the top gizmo.
static Function/S GetMovieGizmo()
	String movieGizmo = StrVarOrDefault(GizmoMovieVar("movieGizmo"),"")
	if( strlen(movieGizmo) == 0 || Wintype(movieGizmo) != 13 )
		movieGizmo= TopGizmo()
	endif
	return movieGizmo
End

static Function/S SetMovieGizmo(gizmoName)
	String gizmoName	// "" to set to "no movie gizmo", then GetMovieGizmo() will return TopGizmo().
	String prevousMovieGizmo = StrVarOrDefault(GizmoMovieVar("movieGizmo"),"")
	String/G $GizmoMovieVar("movieGizmo")= gizmoName
	return prevousMovieGizmo
End

//=====================================================================================
// Pre-Igor 6.2 hook
Function WMGizmoRotationHook(str)
	String str
	
	NVAR/Z eulerA=$GizmoMovieVar("startEulerA")
	NVAR/Z eulerB=$GizmoMovieVar("startEulerB")
	NVAR/Z eulerC=$GizmoMovieVar("startEulerC")

	if( NVAR_Exists(eulerA) && NVAR_Exists(eulerB) && NVAR_Exists(eulerC) )
		String val
		val=StringByKey("EULERA", str)
		if(strlen(val)>0)
			eulerA=str2num(val)
		endif 
		val=StringByKey("EULERB", str)
		if(strlen(val)>0)
			eulerB=str2num(val)
		endif
		val=StringByKey("EULERC", str)
		if(strlen(val)>0)
			eulerC=str2num(val)
		endif
	endif
End

//=====================================================================================
// Igor 6.2+ uses this named Gizmo hook
Function WMGizmoMovieRotationNamedHook(s)
	STRUCT WMGizmoHookStruct &s

	strswitch(s.eventName)
		case "rotation":
			NVAR eulerA=$GizmoMovieVar("startEulerA")
			NVAR eulerB=$GizmoMovieVar("startEulerB")
			NVAR eulerC=$GizmoMovieVar("startEulerC")
			if( NVAR_Exists(eulerA) && NVAR_Exists(eulerB) && NVAR_Exists(eulerC) )
				eulerA= s.eulerA
				eulerB= s.eulerB
				eulerC= s.eulerC
			endif
			break
	endswitch
	return 0
End


//=====================================================================================
static Function AfterFileOpenHook(refNum,file,pathName,type,creator,kind)
	Variable refNum,kind
	String file,pathName,type,creator
	// Check that the file is open (read only), and of correct type
	if( (kind ==1) || (kind==2) )  	// this experiment, no movie can be open over an experiment load.
		ExperimentModified
		Variable wasModified= V_flag
		Variable/G $GizmoMovieVar("isNewMovie") = 0
		DoWindow gizmoMoviePanel
		if( V_Flag )
			ModifyControl startMovieButton, win=gizmoMoviePanel, disable=0
		endif
		ExperimentModified wasModified // don't mark a newly-opened experiment as initially modified
	endif
	return 0
End

//=====================================================================================
// The following function will force the user to enter file name in the dialog.
Function newMovieButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable isNew= NumVarOrDefault(GizmoMovieVar("isNewMovie"),0)
	Variable fc= NumVarOrDefault(GizmoMovieVar("frameCounter"),0)

	if(isNew)
		DoAlert 0,"You must close the current movie before opening a new one"
		return 0
	endif
	
	String movieGizmo= openGraphWindow()
	// now we should finally be able to start a new movie.
	String cmd
	NewMovie/L/I/Z	// 6.23: creates S_filename
	if(V_Flag==0)
		Variable/G $GizmoMovieVar("isNewMovie") = 1
		Variable/G $GizmoMovieVar("frameCounter") = 0
		String/G $GizmoMovieVar("fileNameStr") = S_filename
		// here we can enable the rest of the buttons.
		DoWindow/F gizmoMoviePanel
		if( V_Flag )
			AutoPositionWindow/R=wm_tmpGizmoMovieWindow/E/M=1 gizmoMoviePanel
			Button startMovieButton win=gizmoMoviePanel, disable=2
			Button createMovieButton,win=gizmoMoviePanel,disable=0
			Button appendFrameButton,win=gizmoMoviePanel,disable=0
			Button closeMovieButton,win=gizmoMoviePanel,disable=0
			Button playMovieButton,win=gizmoMoviePanel,disable=2
			TitleBox movieFile,win=gizmoMoviePanel,help={S_filename}
			TitleBox movieFileTitle,win=gizmoMoviePanel,help={S_filename}
		endif
	elseif(V_Flag!=-1)
		Printf  "Error in creating movie file (error %d)\r", V_Flag
		Beep
	endif
End

//=====================================================================================

static Function CanPlayMovie()

	String fileStr=StrVarOrDefault(GizmoMovieVar("fileNameStr"),ksNone)
	return strlen(fileStr) && CmpStr(fileStr,ksNone) != 0
End

// Play a previously saved movie
Function playMovieButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String fileStr=StrVarOrDefault(GizmoMovieVar("fileNameStr"),ksNone)
	if( strlen(fileStr) && CmpStr(fileStr,ksNone) != 0 )
		PlayMovie/Z as fileStr
	else
		PlayMovie/Z
	endif
End
	

//=====================================================================================
// This is  like a play button that lets the user see the range of rotation that will be 
// covered in the movie without actually creating the movie.
// Note: this uses either the movie or top gizmo

Function testRotationButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= GetMovieGizmo()
	// check to see that we have an open gizmo
	if(strlen(gizmoName)<=0)
		DoAlert 0, "You must have a Gizmo window for this operation!"
		return 0
	endif

	SetMovieRotationForGizmo(gizmoName)
	String oldDF=SetGizmoMoviesDF()
//	NVAR startEulerA,startEulerB,startEulerC,numFrames,dA,dB,dC
	Variable/G startEulerA,startEulerB,startEulerC,numFrames,dA,dB,dC

	String cmd
	Variable i

	// Igor 6.2: use copies of startEulerA, etc because they get reset in WMGizmoMovieRotationNamedHook
	Variable eulerA=startEulerA
	Variable eulerB=startEulerB
	Variable eulerC=startEulerC
	
	for(i=0;i<numFrames;i+=1)
		sprintf cmd,"ModifyGizmo/N=%s euler={%g,%g,%g}",gizmoName,eulerA+i*dA,eulerB+i*dB,eulerC+i*dC
		Execute/Q/Z cmd
		doUpdate	// causes WMGizmoMovieRotationNamedHook() to run
	endfor

	// Igor 6.2: return to the original start
	startEulerA=eulerA	// re-assignment needed because the gizmo hook updates startEulerA, etc during rotation
	startEulerB=eulerB
	startEulerC= eulerC
	sprintf cmd,"ModifyGizmo/N=%s euler={%g,%g,%g}",gizmoName,startEulerA,startEulerB,startEulerC
	Execute/Q/Z cmd
	doUpdate	// causes WMGizmoMovieRotationNamedHook() to run
	
	SetDataFolder oldDF
End

static Function GetGizmoRotation(gizmoName)
	String gizmoName
	
	// check to see that we have an open gizmo
	if( strlen(gizmoName) == 0 )
		gizmoName= TopGizmo()
		if( strlen(gizmoName) <= 0 )
			return 0
		endif
	endif
		
	String oldDF=SetGizmoMoviesDF()

	Variable/G startEulerA,startEulerB,startEulerC
	NVAR startEulerA,startEulerB,startEulerC

	Execute "GetGizmo/N="+gizmoName+" curRotation"
	NVAR GizmoEulerA,GizmoEulerB,GizmoEulerC
	startEulerA=GizmoEulerA
	startEulerB=GizmoEulerB
	startEulerC= GizmoEulerC
	SetDataFolder oldDF
	return 1
End

//=====================================================================================
// This function actually loads the frames on the movie
// The top gizmo is assigned as the "movie gizmo"; other gizmo windows are ignored until the movie is closed.
Function createMovieButtonProc(ctrlName) : ButtonControl	//	Really "Append Rotation Frames"
	String ctrlName

	Variable isNewMovie=NumVarOrDefault(GizmoMovieVar("isNewMovie"),0)
	if( !isNewMovie )
		DoAlert 0, "You must first open a new movie."
		return 0
	endif

	DoWindow wm_tmpGizmoMovieWindow
	if( V_Flag==0)
		DoAlert 0, "The wm_tmpGizmoMovieWindow graph is missing!"
		return 0
	endif
	
	// (Re)assign the movie gizmo or top gizmo as the "movie gizmo"
	String gizmoName= GetMovieGizmo()
	
	if( strlen(gizmoName) <= 0 )
		DoAlert 0,"You must have a Gizmo window for this operation!"
		return 0
	endif

	SetMovieGizmo(gizmoName)
	SetMovieRotationForGizmo(gizmoName)

	String oldDF=SetGizmoMoviesDF()
	Variable/G startEulerA,startEulerB,startEulerC,numFrames,frameCounter, dA,dB,dC
	// NVAR startEulerA,startEulerB,startEulerC,numFrames,frameCounter,dA,dB,dC
	String cmd
	Variable i
	
	sprintf cmd,"ModifyGizmo/N=%s euler={%g,%g,%g}",gizmoName,startEulerA,startEulerB,startEulerC
	Execute/Q/Z cmd
	MakeGizmoTopmost(gizmoName)	// ExportGizmo has no /N=name, so regrettably we have to BringToFront
	Execute "ExportGizmo Clip"
	LoadPict/Q/O "Clipboard",wm_GizmoMoviePict
	DoWindow/F wm_tmpGizmoMovieWindow
	Setdrawlayer/k/w=wm_tmpGizmoMovieWindow userFront									// 13OCT10
	DrawPict /w=wm_tmpGizmoMovieWindow 0,0,1,1,GalleryGlobal#wm_GizmoMoviePict		// 30APR09
	
	// Igor 6.2: use copies of startEulerA, etc because they get reset in WMGizmoMovieRotationNamedHook
	Variable eulerA=startEulerA
	Variable eulerB=startEulerB
	Variable eulerC=startEulerC

	for(i=0;i<numFrames;i+=1)
		sprintf cmd,"ModifyGizmo/N=%s euler={%g,%g,%g}",gizmoName,eulerA+i*dA,eulerB+i*dB,eulerC+i*dC
		Execute cmd
		Execute "ExportGizmo Clip"
		LoadPict/Q/O "Clipboard",wm_GizmoMoviePict
		DoUpdate
		DoWindow/F wm_tmpGizmoMovieWindow
		AddMovieFrame
		frameCounter+=1
	endfor

	// Igor 6.2: return to the original start
	startEulerA=eulerA	// re-assignment needed because the gizmo hook updates startEulerA, etc during rotation
	startEulerB=eulerB
	startEulerC= eulerC
	sprintf cmd,"ModifyGizmo/N=%s euler={%g,%g,%g}",gizmoName,startEulerA,startEulerB,startEulerC
	Execute cmd
	DoUpdate

	SetDataFolder oldDF
End

//=====================================================================================
// The following adds a single frame to the current movie.
Function appendFrameButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable isNewMovie=NumVarOrDefault(GizmoMovieVar("isNewMovie"),0)
	
	if(!isNewMovie)
		DoAlert 0,"You must first open a new movie."
		return 0
	endif

	// (Re)assign the movie gizmo or top gizmo as the "movie gizmo"
	String gizmoName= GetMovieGizmo()
	
	// check to see that we have an open gizmo
	if( strlen(gizmoName) <= 0 )
		DoAlert 0,"You must have a Gizmo window for this operation!"
		return 0
	endif

	SetMovieGizmo(gizmoName)
	SetMovieRotationForGizmo(gizmoName)
	
	MakeGizmoTopmost(gizmoName) // ExportGizmo has no /N=name, so regrettably we have to BringToFront
	
	String oldDF=SetGizmoMoviesDF()
	Execute "ExportGizmo Clip"
	LoadPict/Q/O "Clipboard",wm_GizmoMoviePict
	DoWindow/F wm_tmpGizmoMovieWindow
	Setdrawlayer/k/w=wm_tmpGizmoMovieWindow userFront									// 13OCT10
	DrawPict 0,0,1,1,GalleryGlobal#wm_GizmoMoviePict										// 30APR09
	AddMovieFrame
	Variable fc=NumVarOrDefault(GizmoMovieVar("frameCounter"),0)
	Variable/G $GizmoMovieVar("frameCounter")= fc+1
	SetDataFolder oldDF
End

// bring the gizmo to the front only if another is the TopGizmo
static Function MakeGizmoTopmost(gizmoName)
	String gizmoName
	
	if( strlen(gizmoName) )
		String top= TopGizmo()
		if( CmpStr(top,gizmoName) != 0 )
			String oldDF=SetGizmoMoviesDF()
			Execute "ModifyGizmo/N="+gizmoName+" BringToFront"	// ExportGizmo has no /N=name, so regrettably we have to BringToFront
			SetDataFolder oldDF
		endif
	endif
End

//=====================================================================================
Function closeMovieButtonProc(ctrlName) : ButtonControl
	String ctrlName

	CloseGizmoMovie()

	DoWindow gizmoMoviePanel
	if( V_Flag )
		Button startMovieButton disable=0
		Button createMovieButton,disable=2
		Button appendFrameButton,disable=2
		Button playMovieButton,disable=CanPlayMovie() ? 0 : 2
	endif
End

//=====================================================================================
// The following is the hook function that we want to be called when the window is closed.
Function moviePanelCloseHook(infoStr)
	String infoStr
	
	String event=StringByKey("EVENT",infoStr)
	if(cmpstr(event,"kill")==0)
		CloseGizmoMovie()
	endif
End

Function CloseGizmoMovie()

	DoWindow/K wm_tmpGizmoMovieWindow
	if ( strsearch(PICTList("*",";",""),"wm_GizmoMoviePict", 0) >= 0)
		KillPICTs/Z wm_GizmoMoviePict
	endif

	Variable err = GetRTError(0)
	CloseMovie
	if( err == 0 )
		Variable movieError= GetRTError(1)	// CloseMovie must have caused the error, and we don't care, so clear it.
	endif

	Variable/G $GizmoMovieVar("isNewMovie") = 0
	Variable/G $GizmoMovieVar("frameCounter")= 0
	SetMovieRotationForGizmo("")
	SetMovieGizmo("")	// now GetMovieGizmo() returns the top gizmo.
End

//=====================================================================================