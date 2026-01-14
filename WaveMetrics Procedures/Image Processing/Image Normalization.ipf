#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>
//*********************************************************************************
// 	The main call to set up the panel is:  	WMNormalizationPanel()
//*********************************************************************************
 
Function imageNormalizeDoit(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo norSrcImagePop
	String theWave=S_value
	if(WaveExists($theWave)==0)
		Abort  "The operation applies only to waves in the current data folder"
		return 0
	endif
	
	ControlInfo norTypePop
	Variable normalizationType=V_value
	
	ControlInfo norOverwriteCheck
	Variable isOverwrite=V_value
	
	if(!isOverwrite)
		Duplicate/O $theWave M_NormalizedImage
		Wave srcWave=M_NormalizedImage
	else
		Wave srcWave=$theWave
	endif

	// first we start by evaluating wavestats
	WaveStats/Q srcWave
	Variable min=V_min
	Variable delta=1.0/(V_max-V_min)
	Variable deltaM

	// In the following I use fastOp.  This requires that the factor delta is a number .
	// It is therefore written using parents.
	switch(normalizationType)
		case 1:
			deltaM=delta*min
			Fastop srcWave=(delta)*srcWave-(deltaM)
		break
		
		case 2:
			delta*=2
			deltaM=delta*min+1
			FastOp srcWave=(delta)*srcWave-(deltaM)
		break
		
		case 3:
			delta*=255
			deltaM=delta*min
			FastOp srcWave=(delta)*srcWave-(deltaM)
		break
		
		case 4:
			delta*=65535
			deltaM=delta*min
			FastOp srcWave=(delta)*srcWave-(deltaM)
		break		
	endSwitch
	print delta,deltaM
End

//*********************************************************************************
// creates a wave list of 2D and 3D waves in the current data folder
//*********************************************************************************
Function/s imageWaveList()
	
	String initialList=WaveList("*",";","DIMS:2")+WaveList("*",";","DIMS:3")		
	return initialList
End

//*********************************************************************************
//*********************************************************************************
Function WMNormalizationPanel()

	DoWindow/F NormalizationPanel
	if(V_Flag==1)
		return 0
	endif
	NewPanel /K=1 /W=(438,173,706,284)
	DoWindow/C NormalizationPanel
	Button button0,pos={202,80},size={50,20},proc=imageNormalizeDoit,title="Do It"
	PopupMenu norSrcImagePop,pos={4,2},size={149,19},title="Source Image:"
	PopupMenu norSrcImagePop,mode=1,value= #"imageWaveList()"
	PopupMenu norTypePop,pos={5,30},size={165,19},title="Normalization"
	PopupMenu norTypePop,mode=1,value= #"\" 0 -> 1; -1 -> 1; 0 -> 255; 0 -> 65535\""
	CheckBox norOverwriteCheck,pos={5,60},size={185,20},title="Overwrite source image",value=0
	ModifyPanel fixedSize=1
	AutoPositionWindow/E/M=1/R=$WMTopImageGraph()
End

//*********************************************************************************
//*********************************************************************************
