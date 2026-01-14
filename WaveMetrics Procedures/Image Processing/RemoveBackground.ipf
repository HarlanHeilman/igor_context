#pragma rtGlobals=2		// Use modern global access method.

#include <Image Common>
#include <Image Calibration Panels>

 
//************************************************************************************************

Function WMRemoveBackgroundPanel() 
	PauseUpdate; Silent 1		// building window...
	initRemoveBackground()
	NewPanel/k=1 /W=(336,51,605,292) as "Remove Background Panel"
	Button roiStartButton,pos={21,19},size={230,20},proc=roiStartButtonProc,title="Start selecting background points"
	Button roiFinishButton,pos={21,47},size={230,20},proc=roiFinishButtonProc,title="Finish ROI creation"
	CheckBox OverwriteCheck,pos={25,77},size={216,20},title="Overwrite original image",value=0
	SetVariable setvar0,pos={23,105},size={216,17},title="Degree of polynomial"
	SetVariable setvar0,limits={1,Inf,1},value= root:Packages:WMRemoveBackground:polyOrder
	Button removeBGButton,pos={23,136},size={230,20},proc=removeBGButtonProc,title="Remove Background"
	Button clearButton,pos={23,176},size={220,20},proc=clearRoiButtonProc,title="Clear ROI"
	Button removeBackHelp,pos={23,212}, size={230,20},proc=removeBackgroundHelp,title="Help"
	ModifyPanel fixedSize=1
	AutoPositionWindow/E/M=1/R=$WMTopImageGraph()
EndMacro

//************************************************************************************************
Function removeBackgroundHelp(ctrlName):ButtonControl
	String ctrlName
	DisplayHelpTopic "ImageRemoveBackground"
End

//************************************************************************************************
Function clearRoiButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	KillWaves/Z root:Packages:WMRemoveBackground:M_ROIMask 
	String topGraph=WMTopImageGraph();
	DoWindow/f $topGraph
	SetDrawLayer/K ProgFront

End
//************************************************************************************************

Function roiStartButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String topGraph=WMTopImageGraph();
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	DoWindow/f $topGraph
	ShowTools/A rect
	SetDrawLayer ProgFront

	String iminfo= ImageInfo(topGraph, imageWaveName, 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	SetDrawEnv linefgc= (65535,65535,0),fillpat= 0,xcoord=$xax,ycoord=$yax,save

End
//************************************************************************************************

Function roiFinishButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String topGraph=WMTopImageGraph();
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	imageWaveName=WMGetLeafName(imageWaveName)
	DoWindow/f $topGraph
	HideTools
	
	print  imageWaveName
	String curFolder=GetDataFolder(1);
	SetDataFolder root:Packages:WMRemoveBackground
	ImageGenerateROIMask $imageWaveName
	SetDataFolder curFolder
End

//************************************************************************************************

Function removeBGButtonProc(ctrlName) : ButtonControl
	String ctrlName

	// first need to get the state of the checkbox
	String cmd="ImageRemoveBackground/R=root:Packages:WMRemoveBackground:M_ROIMask "
	ControlInfo OverwriteCheck
	if(V_Value)
		cmd+="/O "
	endif
	
	NVAR polyOrder=root:Packages:WMRemoveBackground:polyOrder
	if(polyOrder>1)
		cmd+="/p="+num2str(polyOrder)+" "
	endif
	
	String imageWaveName=WMGetImageWave(WMTopImageGraph())

	cmd += imageWaveName
	Execute cmd

End

//************************************************************************************************

Function initRemoveBackground()
	
	String curFolder=GetDataFolder(1);
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WMRemoveBackground
	
	Variable/G polyOrder=1
	SetDataFolder curFolder
End