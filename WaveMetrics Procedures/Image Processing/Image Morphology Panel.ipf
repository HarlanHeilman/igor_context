#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>

// LH971226
// Image Morphology Panel, version 0.8
// Requires Igor Pro 3.11 or later
// To do: Support user defined structure elements
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageMorphPanel()
// AG20MAY03
// changed "struct" to other names that would not conflict with this new keyword.
// added checkbox for printing the command.
// added /W to controlInfo calls.
 


Function WMCreateImageMorphPanel()

	if(isColorImage())
		return 0;
	endif

	DoWindow/F ImageMorphPanel
	if( V_Flag==1 )
		return 0
	endif

	String igName= WMTopImageGraph()
	if( strlen(igName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	String dfSav= GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WMImProcess
	NewDataFolder/O/S root:Packages:WMImProcess:Morphology
	
	if( NumVarOrDefault("inited",0) == 0 )
		Variable/G inited=1
		Variable/G iterations= 1
		Variable/G structElement= 1		// memory for structure element
		Variable/G type= 1					// memory for type of morph
	endif

	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(igName)

	
	NewPanel/K=1 /W=(31.8,345.8,373.8,512) as "Image Morphology"
	DoWindow/C ImageMorphPanel
	AutoPositionWindow/E/M=1/R=$igName

	Variable isWin= CmpStr(IgorInfo(2)[0,2],"Win")==0
	Variable fsize=12
	if( isWin )
		fsize=10
	endif
	
	NVAR structElement= root:Packages:WMImProcess:Morphology:structElement
	NVAR type= root:Packages:WMImProcess:Morphology:type

	PopupMenu type,pos={13,10},size={145,19},proc=WMImageMorphTypePopMenuProc,title="Operation:"
	PopupMenu type,mode=type,value= #"\"BinaryErosion;BinaryDilation;Erosion;Dilation;Opening;Closing;TopHat;Watershed\""
	PopupMenu structPop,pos={49,38},size={209,19},proc=WMImageMorphStructPopMenuProc,title="Structure Element:"
	PopupMenu structPop,mode=structElement,value= #"\"2x2 Square;1x3 row;3x1 column;3x3 cross;5x5 circle\""
	SetVariable iters,pos={52,63},size={105,15},title="Iterations:"
	SetVariable iters,help={"Enter number of time the selcted operation will be performed."}
	SetVariable iters,limits={1,Inf,1},value= root:Packages:WMImProcess:Morphology:iterations
	Button DoItConv,pos={19,124},size={50,20},proc=WMBPMorphDoIt,title="Do It"
	Button buttonUndo,pos={192,124},size={50,20},proc=WMImageBPUndo,title="Undo"
	Button buttonRestore,pos={258,124},size={66,20},proc=WMImageBPUndo,title="Restore"
	Button morphHelpButt,pos={86,124},size={50,20},proc=morphHelpProc,title="Help"
	CheckBox IMPrintCmdCheck,pos={19,90},size={93,14},title="Print Command",value= 0
	ModifyPanel fixedsize=1
	
	WMImageUpdateMorphPanel()
end

Function morphHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic  "ImageMorphology"
End

Function WMImageMorphStructPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:Morphology:structElement= popNum
End

Function WMImageMorphTypePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:Morphology:type= popNum
	WMImageUpdateMorphPanel()
End

Function WMImageUpdateMorphPanel()
	ControlInfo/W=ImageMorphPanel type
	String keyword= S_value
	Variable isWater= CmpStr(keyword,"Watershed") == 0
	ControlInfo/W=ImageMorphPanel structPop

	if( isWater %& (V_Flag!=0) )
		KillControl structPop
		KillControl iters
		Checkbox eightNeighborsCheck, pos={49,38},size={209,19},title="Use 8-neighbors",value=1
		Checkbox NanFill, pos={49,60},size={209,19},title="Use NaN fill",value=0
	endif
	if( (isWater==0) %& (V_Flag==0) )
		KillControl eightNeighborsCheck
		KillControl NanFill
		NVAR structElement= root:Packages:WMImProcess:Morphology:structElement
		PopupMenu structPop,pos={49,38},size={209,19},title="Structure Element:"
		PopupMenu structPop,mode=structElement,value= #"\"2x2 Square;1x3 row;3x1 column;3x3 cross;5x5 circle;User defined\""
		SetVariable iters,pos={52,63},size={105,15},title="Iterations:"
		SetVariable iters,help={"Enter number of time the selcted operation will be performed."}
		SetVariable iters,limits={1,Inf,1},value= root:Packages:WMImProcess:Morphology:iterations
	endif
end

Function WMBPMorphDoIt(ctrlName) : ButtonControl
	String ctrlName

	Variable printCommand=0
	String ImGrfName= WMTopImageGraph()
	String pw= WMGetImageWave(ImGrfName)
	WAVE/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif
	
	if( WaveType(w) != 0x48 )
		Abort "Image must be unsigned byte"
	endif
	
	variable se= -1
	NVAR iterations= root:Packages:WMImProcess:Morphology:iterations
	Variable is8=0
	String sNan=""
	
	ControlInfo/W=ImageMorphPanel type
	String keyword= S_value
	Variable isWater=  CmpStr(keyword,"Watershed") == 0
	if( !isWater )
		ControlInfo/W=ImageMorphPanel structPop
		se= V_value
	endif

	ControlInfo/W=ImageMorphPanel eightNeighborsCheck
	if(V_Value==1)
		is8=1
	endif
	
	ControlInfo/W=ImageMorphPanel NanFill
	if(V_Value==1)
	 	sNan="/N "
	endif
	
	if(is8)
		sNan+="/L "
	endif
	
	ControlInfo/W=ImageMorphPanel IMPrintCmdCheck
	if(V_Value)
		printCommand=1
	endif
	
	WMSaveWaveBackups(w)
	String cmd=""
	
	ImageGenerateROIMask/E=1/I=0/W=$ImGrfName $NameOfWave(w)
	if( V_FLag )
		if( isWater )
			cmd="ImageMorphology/O/R=M_ROIMask "+ sNan + keyword+", " +pw
			Execute cmd
			if(printCommand)
				printf "%s\r",cmd
			endif
		else
			ImageMorphology/O/R=M_ROIMask/E=(se)/I=(iterations) $keyword, w
			if(printCommand)
				sprintf cmd,"ImageMorphology/O/R=M_ROIMask/E=(%d)/I=(%d) %s, %s\r",se,iterations,keyword,NameOfWave(w)
				print cmd
			endif
		endif
		KillWaves M_ROIMask
	else
		if( isWater )
			cmd="ImageMorphology/O "+sNan+ keyword+"," +pw
			Execute cmd
			if(printCommand)
				printf "%s\r",cmd
			endif
		else
			ImageMorphology/O/E=(se)/I=(iterations) $keyword, w
			if(printCommand)
				sprintf cmd,"ImageMorphology/O/E=(%d)/I=(%d) %s, %s\r",se,iterations,keyword,NameOfWave(w)
				print cmd
			endif
		endif
	endif
End
