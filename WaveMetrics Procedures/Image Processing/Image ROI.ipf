#pragma rtGlobals=2		// Use modern global access method.
 
#include <Image Common>

// ************ Image ROI **********************


Function WMCreateImageROIPanel()

	DoWindow/F WMImageROIPanel
	if( V_Flag==1 )
		return 0
	endif

	String igName= WMTopImageGraph()
	if( strlen(igName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif

	NewPanel /K=1 /W=(563,327,744,514) as "ROI"
	DoWindow/C WMImageROIPanel
	AutoPositionWindow/E/M=1/R=$igName
	ModifyPanel fixedSize=1
	Button StartROI,pos={14,9},size={150,20},proc=WMRoiDrawButtonProc,title="Start ROI Draw"
	Button StartROI,help={"Adds drawing tools to top image graph. Use rectangle, circle or polygon."}
	Button clearROI,pos={14,63},size={150,20},proc=WMRoiDrawButtonProc,title="Erase ROI"
	Button clearROI,help={"Erases previous ROI. Not undoable."}
	Button FinishROI,pos={14,35},size={150,20},proc=WMRoiDrawButtonProc,title="Finish ROI"
	Button FinishROI,help={"Click after you are finished editing the ROI"}
	Button saveROICopy,pos={14,92},size={150,20},proc=saveRoiCopyProc,title="Save ROI Copy"
	CheckBox zeroRoiCheck,pos={15,124},size={94,14},title="Zero ROI Pixels",value= 1
	Button roiPanelHelp,pos={15,145},size={150,20},proc=roiPanelButtonProc,title="Help"
end

// the following function creates the roi wave and saves it in the same data folder as the top
// image wave.

Function saveRoiCopyProc(ctrlName) : ButtonControl
	String ctrlName
	
	String topWave=WMGetImageWave(WMTopImageGraph())
	WAVE/Z ww=$topWave
	if(WaveExists(ww)==0)
		return 0
	endif
	
	String saveDF=GetDataFolder(1)
	String waveDF=GetWavesDataFolder(ww,1 )
	SetDataFolder waveDF
	
	ControlInfo zeroRoiCheck
	if(V_value)
		ImageGenerateROIMask/E=1/I=0 $WMTopImageName()		
	else
		ImageGenerateROIMask $WMTopImageName()		
	endif
	SetDataFolder saveDF
end

Function WMRoiDrawButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	if( strlen(ImGrfName) == 0 )
		return 0
	endif
	
	DoWindow/F $ImGrfName
	if( CmpStr(ctrlName,"StartROI") == 0 )
		ShowTools/A rect
		SetDrawLayer ProgFront
		Wave w= $WMGetImageWave(ImGrfName)		// the target matrix
		String iminfo= ImageInfo(ImGrfName, NameOfWave(w), 0)
		String xax= StringByKey("XAXIS",iminfo)
		String yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv linefgc= (3,52428,1),fillpat= 0,xcoord=$xax,ycoord=$yax,save
	endif
	if( CmpStr(ctrlName,"FinishROI") == 0 )
		GraphNormal
		HideTools/A
		SetDrawLayer UserFront
		DoWindow/F WMImageROIPanel
	endif
	if( CmpStr(ctrlName,"clearROI") == 0 )
		GraphNormal
		SetDrawLayer/K ProgFront
		SetDrawLayer UserFront
		DoWindow/F WMImageROIPanel
	endif
End
	

Function roiPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ROI Panel"
End
