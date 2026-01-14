#pragma rtGlobals=2		// Use modern global access method.

#include <Image Common>
 
 //==============================================================================
 // 	30APR03 Added buttons for 90 degree increments and flips.
 //  All operations are done in place but there is a backup which is only necessary in the arbitrary rotation
 // case.
 // 	WMCreateImageRotatePanel() is the main call that sets up the panel and the necessary globals.
 // 
 // 30NOV05 changed horizontal and vertical flips to use the ImageRotate operation to support RGB images.
 // 22JUN06 added printing and copying commands.
 //==============================================================================
Function WMCreateImageRotatePanel()

	DoWindow/F ImageRotatePanel
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
	NewDataFolder/O/S root:Packages:WMImProcess:ImageRotate
	
	Variable/G angle,fill,inited
	variable/G xxx
	if( inited!=1 )
		angle=10
		fill=0
	endif

	SetDataFolder dfSav

	NewPanel /K=1 /W=(50,238,383,423) as "Image Rotate"
	DoWindow/C ImageRotatePanel
	AutoPositionWindow/E/M=1/R=$igName
	SetDrawLayer UserBack
	Button rotate,pos={12,11},size={109,20},proc=WMRotateButtonProc,title="Rotate"
	Button rotate,help={"Rotate top image"}
	Button buttonUndo,pos={118,96},size={56,20},proc=WMImageBPUndo,title="Undo"
	Button buttonRestore,pos={196,95},size={77,20},proc=WMImageBPUndo,title="Revert"
	SetVariable angle,pos={133,14},size={90,15},title="Angle"
	SetVariable angle,help={"Rotation angle in degrees."}
	SetVariable angle,limits={-360,360,1},value= root:Packages:WMImProcess:ImageRotate:angle
	SetVariable fill,pos={235,14},size={68,15},title="Fill"
	SetVariable fill,help={"Value to use for area ouside data."}
	SetVariable fill,limits={-inf,inf,0},value= root:Packages:WMImProcess:ImageRotate:fill
	Button rotateHelpButton,pos={41,96},size={50,20},proc=rotateHelpButton,title="Help"
	Button rotateFlipHoriz,pos={174,65},size={110,20},proc=rotFlipHButtonProc,title="Flip Horizontal"
	Button rotateFlipVert,pos={31,65},size={110,20},proc=rotFlipVertButtonProc,title="Flip Vertical"
	Button rotate90,pos={137,38},size={50,20},proc=rotate90CWButtonProc,title="90 CW"
	Button rotate90CCW,pos={222,38},size={70,20},proc=rotate90CCButtonProc,title="90 CCW"
	Button rotate180,pos={26,38},size={70,20},proc=rotate180ButtonProc,title="180"
	CheckBox IR_PrintCmdCheck,pos={15,129},size={135,14},title="Print Command to History"
	CheckBox IR_PrintCmdCheck,value= 0
	CheckBox IR_SaveCmdToClip,pos={15,148},size={144,14},title="Save Command To Clipboard"
	CheckBox IR_SaveCmdToClip,value= 0
	ModifyPanel fixedSize=1
end

 //==============================================================================
static Function doCmdRequests(str)
	string str
	
	ControlInfo/W=ImageRotatePanel IR_PrintCmdCheck
	if(V_Value)
		Print str
	endif
	
	ControlInfo/W=ImageRotatePanel IR_SaveCmdToClip
	if(V_Value)
		PutScrapText str
	endif
End
 //==============================================================================
Function rotateHelpButton(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ImageRotate"
	doCmdRequests("DisplayHelpTopic \"ImageRotate\"")
End
 //==============================================================================
Function WMRotateButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	NVAR angle= root:Packages:WMImProcess:ImageRotate:angle
	NVAR fill= root:Packages:WMImProcess:ImageRotate:fill
	
	ImageRotate /A=(angle)/E=(fill)/O w
	String cmd
	sprintf cmd, "ImageRotate /A=(%g)/E=(%g)/O %s",angle,fill,NameOfWave(w)
	doCmdRequests(cmd)
end	

 //==============================================================================
Function rotFlipHButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	ImageRotate/H/O w
	String cmd
	sprintf cmd, "ImageRotate/H/O %s",NameOfWave(w)
	doCmdRequests(cmd)
End

 //==============================================================================
Function rotFlipVertButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	ImageRotate/V/O w
	String cmd
	sprintf cmd, "ImageRotate/V/O %s",NameOfWave(w)
	doCmdRequests(cmd)
End

 //==============================================================================
Function rotate90CWButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	NVAR fill= root:Packages:WMImProcess:ImageRotate:fill
	ImageRotate /A=(90)/E=(fill)/O w
	String cmd
	sprintf cmd, "ImageRotate /A=(90)/E=(%g)/O  %s",fill,NameOfWave(w)
	doCmdRequests(cmd)

End

 //==============================================================================
Function rotate90CCButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	NVAR fill= root:Packages:WMImProcess:ImageRotate:fill
	ImageRotate /A=(-90)/E=(fill)/O w
	String cmd
	sprintf cmd, "ImageRotate /A=(-90)/E=(%g)/O  %s",fill,NameOfWave(w)
	doCmdRequests(cmd)
End
 //==============================================================================

Function rotate180ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	
	WMSaveWaveBackups(w)
	NVAR fill= root:Packages:WMImProcess:ImageRotate:fill
	ImageRotate /A=(180)/E=(fill)/O w
	String cmd
	sprintf cmd, "ImageRotate /A=(180)/E=(%g)/O  %s",fill,NameOfWave(w)
	doCmdRequests(cmd)
End
 //==============================================================================

