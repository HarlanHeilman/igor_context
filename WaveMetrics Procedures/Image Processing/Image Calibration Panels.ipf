#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=2		// Use modern global access method.
#include <Graph Utility Procs>
#include <Image Common>

// AG 30MAR07
// This procedure file requires IGOR Pro 6.01 or newer.

//   This procedure file adds the two main panels: 
//		WMCalibration()
//   and
//		WMSpatialMeasurements()
//
//  WMCalibration() needs to be called first in order to initialize various quantities and set up the general calibration for 
// the displayed image.  After a calibration set was applied, WMSpatialMeasurements() provides access to various spatial 
// measurements panels.
//************************************************************************************************
// 30MAR07
Function	WM_DrawCursors(numCursors)
	Variable numCursors
	
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	Wave 	w=$imageWaveName
	
	// offsets calculated so cursors are on the graph and not on top of each other.
	Variable xCenter,yCenter,dx,dy
	xCenter=(DimOffset(w,0)+dimDelta(w,0)*DimSize(w,0)/2)
	yCenter=(DimOffset(w,1)+dimDelta(w,1)*DimSize(w,1)/2)
	dx=dimDelta(w,0)*DimSize(w,0)/5
	dy=dimDelta(w,1)*DimSize(w,1)/5
	Wave/Z xMarker=root:Packages:WMCalibrations:xMarker
	Wave/Z yMarker=root:Packages:WMCalibrations:yMarker
	
	switch(numCursors)
		case 0:
			cursor/K A
			cursor/K B
			cursor/K C
			RemoveFromGraph/Z yMarker
		break
		
		case 1:
			cursor/I/A=1/S=1/C=(65000,0,0)/W=$WMTopImageGraph() A,$WMTopImageName(),xCenter,yCenter
			cursor/K B
			cursor/K C
		break
		
		case 2:
			cursor/I/A=1/S=1/C=(65000,0,0)/W=$WMTopImageGraph() A,$WMTopImageName(),xCenter-dx,yCenter
			cursor/I/A=1/S=1/C=(0,65000,0)/W=$WMTopImageGraph() B,$WMTopImageName(),xCenter+dx,yCenter
			cursor/K C
			if(WaveExists(xMarker)&& WaveExists(yMarker))
				xMarker[0]=xCenter-dx
				yMarker[0]=yCenter
				xMarker[1]=xCenter+dx
				yMarker[1]=yCenter
			endif
		break
		
		case 3:
			cursor/I/A=1/S=1/C=(65000,0,0)/W=$WMTopImageGraph() A,$WMTopImageName(),xCenter-dx,yCenter
			cursor/I/A=1/S=1/C=(0,65000,0)/W=$WMTopImageGraph() B,$WMTopImageName(),xCenter,yCenter-dy
			cursor/I/A=1/S=1/C=(0,0,65000)/W=$WMTopImageGraph() C,$WMTopImageName(),xCenter+dx,yCenter
			if(WaveExists(xMarker)&& WaveExists(yMarker))
				xMarker[0]=xCenter-dx
				yMarker[0]=yCenter
				xMarker[1]=xCenter
				yMarker[1]=yCenter-dy
				xMarker[2]=xCenter+dx
				yMarker[2]=yCenter
			endif
		break
	endswitch
End

//************************************************************************************************
// 30MAR07
Function WM_MarkOriginButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F WMMarkOriginPanel
	if(V_Flag==0)
		NewPanel/K=2 /W=(150,50,500,149) as "Mark Origin"
		DoWindow/C WMMarkOriginPanel
		AutoPositionWindow /E/M=1/R=$WMTopImageGraph()
		SetDrawLayer UserBack
		DrawText 19,30,"Drag the cursor to mark the origin"
		Button markOriginDoneButton,pos={128,50},size={80,20},title="Done",proc=WMSetOriginDone
	endif
		
	WM_initImageCursors(1)
	WM_DrawCursors(1)
End
//************************************************************************************************
// 30MAR07
Function WMSetOriginDone(ctrlName) : ButtonControl
	String ctrlName
		
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	Wave w=$imageWaveName
	// read the position from the cursor
	XOrigin=(hcsr(a)-DimOffset(w,0))/DimDelta(w,0)
	YOrigin=(vcsr(a)-DimOffset(w,1))/DimDelta(w,1)
	Cursor/K A
	DoWindow/K WMMarkOriginPanel
End

//************************************************************************************************
// 30MAR07
Function markAngleButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F WMMarkOffsetAnglePanel
	if(V_Flag==0)
		NewPanel /k=2/W=(574.8,321.2,925.2,420.2) as "Mark Offset Angle"
		DoWindow/C WMMarkOffsetAnglePanel
		AutoPositionWindow /E/M=1/R=$WMTopImageGraph()
		SetDrawLayer UserBack
		DrawText 13,23,"Drag the two cursors to"
		DrawText 14,43,"establish the offset angle"
		Button markOriginDoneButton,pos={128,61},size={120,20},proc=WMSetOffsetAngleDone,title="Done"
	endif
	
	String cdf=GetDataFolder(1)
	WM_initImageCursors(2)	// two cursors needed to draw a line for offset angle
	WM_DrawCursors(2)
	SetDataFolder cdf
End

//************************************************************************************************
// 30MAR07 
Function WMcalibrationHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	switch(s.eventCode)
		case 2:		// kill
		break
		
		case 7:		// cursormoved
			Wave/Z xMarker=root:Packages:WMCalibrations:xMarker
			Wave/Z yMarker=root:Packages:WMCalibrations:yMarker
			if(WaveExists(xMarker) && WaveExists(yMarker))
				String info
				strswitch(s.cursorName)
					case "A":
						info=csrInfo(A)
						if(strlen(info)>0)
							xMarker[0]=hcsr(A)
							yMarker[0]=vcsr(A)
						else
							xMarker[0]=NaN
							yMarker[0]=NaN
						endif
					break
					
					case "B":
						info=csrInfo(B)
						if(strlen(info)>0)
							xMarker[1]=hcsr(B)
							yMarker[1]=vcsr(B)
						else
							xMarker[1]=NaN
							yMarker[1]=NaN
						endif
					break
					
					case "C":
						info=csrInfo(C)
						if(strlen(info)>0)
							xMarker[2]=hcsr(C)
							yMarker[2]=vcsr(C)
						else
							xMarker[2]=NaN
							yMarker[2]=NaN
						endif
					break
				endswitch
				
				NVAR 	curLength=root:Packages:WMCalibrations:curLength
				curLength=sqrt((xMarker[0]-xMarker[1])^2+(yMarker[0]-yMarker[1])^2)
				NVAR 	curAngle=root:Packages:WMCalibrations:curAngle
				curAngle=atan2(abs(yMarker[1]-yMarker[0]),abs(xMarker[1]-xMarker[0]))*180/pi
				
				if(numType(xMarker[2])!=2)
					NVAR 	curAngle=root:Packages:WMCalibrations:curAngle
					Variable a2=(xMarker[0]-xMarker[1])^2+(yMarker[0]-yMarker[1])^2
					Variable b2=(xMarker[1]-xMarker[2])^2+(yMarker[1]-yMarker[2])^2
					Variable c2=(xMarker[0]-xMarker[2])^2+(yMarker[0]-yMarker[2])^2
					
					curAngle=acos((a2+b2-c2)/(2*sqrt(a2*b2)))*180/pi
				endif
			endif
		break
	EndSwitch

	return rval
End

//************************************************************************************************
// 30MAR07
Function/S WMGetAxesForCommand()

	String image=WMGetImageWave(WMTopImageGraph())
	image=WMGetLeafName(image)
	String verticalAxis=StringByKey("YAXIS",ImageInfo("",image,0))
	String horizontalAxis=StringByKey("XAXIS",ImageInfo("",image,0))
	String out=""
	
	 // now we need to figure out if the verticalAxis is a left or right axis
	 String type=StringByKey("AXTYPE",AxisInfo("",verticalAxis))
	 if(cmpstr(type,"left")==0)
	 	out += "/L="+verticalAxis
	 else
	 	out += "/R="+verticalAxis
	 endif
	 
	 // now we figure if the horizontal axis is bottom or top
	 type=StringByKey("AXTYPE",AxisInfo("",horizontalAxis))
	 if(cmpstr(type,"bottom")==0)
	 	out += "/B="+horizontalAxis
	 else
	 	out += "/T="+horizontalAxis
	 endif
	
	return out
End

//************************************************************************************************
// 30MAR07
Function WMSetOffsetAngleDone(ctrlName):ButtonControl
	String ctrlName
	
	// here we need to store the new offset angle in the calibration globals
	String cdf=GetDataFolder(1)
	SetDataFolder root:Packages:WMCalibrations
	Wave xMarker
	Wave yMarker	
	NVAR 	OffsetAngle
	OffsetAngle=atan2(yMarker[1]-yMarker[0],xMarker[1]-xMarker[0])*180/pi

	// cleanup now also involves removing the dependency
	DoWindow/K WMMarkOffsetAnglePanel
	WM_DrawCursors(0)
	SetDataFolder cdf
End

//************************************************************************************************
// 30MAR07
Function WMInitCalibrations()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMCalibrations
	
	if(exists("root:Packages:WMCalibrations:S_curCalibration")!=2)
		String/G 		root:Packages:WMCalibrations:S_curCalibration=""
	endif
	Variable/G 	root:Packages:WMCalibrations:XUnitsPerPixel=1
	Variable/G 	root:Packages:WMCalibrations:YUnitsPerPixel=1
	Variable/G 	root:Packages:WMCalibrations:YOrigin=0
	Variable/G 	root:Packages:WMCalibrations:XOrigin=0
	Variable/G 	root:Packages:WMCalibrations:OffsetAngle=0
	Variable/G	root:Packages:WMCalibrations:curLength
	Variable/G	root:Packages:WMCalibrations:curAngle
	Variable/G	root:Packages:WMCalibrations:curArea
	Variable/G	root:Packages:WMCalibrations:curX	
	Variable/G	root:Packages:WMCalibrations:curY
	Variable/G	root:Packages:WMCalibrations:calibrationMarkerLength
	String/G	root:Packages:WMCalibrations:unitsName=""
	String/G	root:Packages:WMCalibrations:S_curMeasurement=""
	String/G	root:Packages:WMCalibrations:S_curNote=""
End

//************************************************************************************************
//	In the following function we create a string for a popup menu.  The entries start
//   with the default _none_ and proceed with the names of data folders.  We assume
// 	that each data folder contains a valid calibration set.  This is tested by verifying that
//	each data folder contains (at least) the required calibration components.

Function/S 	WMGetCalibrationsList()

	String theList="_none_;"
	String saveDF=GetDataFolder(1)
	SetDataFolder root:Packages:WMCalibrations
	Variable i=0
	Variable itemCount,status,sum
	String itemsList
	
	do
		String df=GetIndexedObjName(":",4,i)
		if(strlen(df)==0)
			break
		endif
		SetDataFolder df
		itemCount=CountObjects("",2)
		if(itemCount>=5)
			itemsList=DataFolderDir(12)
			status=strsearch(itemsList,"XUnitsPerPixel",0)
			status*=strsearch(itemsList,"unitsName",0)
			status*=strsearch(itemsList,"YUnitsPerPixel",0)
			status*=strsearch(itemsList,"XOrigin",0)
			status*=strsearch(itemsList,"YOrigin",0)
			status*=strsearch(itemsList,"OffsetAngle",0)
			if(status>0)
				theList+=df+";"
			endif
		endif
		SetDataFolder root:Packages:WMCalibrations
		i+=1
	while(1)
	
	SetDataFolder saveDF
	return theList
End

//************************************************************************************************
// 	The following is called in response to a selection from the popup menu.  If a valid
//	calibration set is selected, the functions updates the necessary parameters in the
//	panel.

Function WMUpdateCalibrationPanel(ctrlName,popNum,popStr) 
	String ctrlName
	Variable popNum
	String popStr

	SVAR S_curCalibration=root:Packages:WMCalibrations:S_curCalibration
	NVAR 	XUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	YUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	NVAR 	OffsetAngle=root:Packages:WMCalibrations:OffsetAngle
	SVAR	unitsName=root:Packages:WMCalibrations:unitsName

	if(cmpstr(popStr,"_none_")==0)
		S_curCalibration=""
		XUnitsPerPixel=1
		YUnitsPerPixel=1
		YOrigin=0
		XOrigin=0
		OffsetAngle=0
		unitsName=""
		return 0
	endif

	S_curCalibration=popStr
	String calDF="root:Packages:WMCalibrations:"+popStr;
	if(DataFolderExists(calDF))
		String df=GetDataFolder(1)
		
		SetDataFolder calDF
		calDF+=":"
		NVAR aXUnitsPerPixel=$(calDF+"XUnitsPerPixel")
		NVAR aYUnitsPerPixel=$(calDF+"YUnitsPerPixel")
		NVAR aYOrigin=$(calDF+"YOrigin")
		NVAR aXOrigin=$(calDF+"XOrigin")
		NVAR aOffsetAngle=$(calDF+"OffsetAngle")
		SVAR aunitsName=$(calDF+"unitsName")
		
		XUnitsPerPixel=aXUnitsPerPixel
		YUnitsPerPixel=aYUnitsPerPixel
		YOrigin=aYOrigin
		XOrigin=aXOrigin
		OffsetAngle=aOffsetAngle
		unitsName=aunitsName
		
		SetDataFolder df
	endif
	
	WMApplyScalingToImage()
End
//************************************************************************************************
Function WMCalibration() 
	
	String topName=WMTopImageGraph()
	DoWindow/F WMCalibrationPanel
	if(V_Flag!=1)
		WMInitCalibrations()
		
		NewPanel /K=1 /W=(387,348.2,838.8,552.2) as "Calibration"
		if(strlen(topName)>0)
			AutoPositionWindow /E/R=$topName
		endif
	
		SetDrawLayer UserBack
		DrawText 158,47,"X"
		DrawText 237,47,"Y"
		Button saveCalibration,pos={146,176},size={120,20},proc=WMSaveCalibrationProc,title="Save Calibration"
		Button saveCalibration,help={"Saves a new calibration set or modifications to an existing one."}
		SetVariable uppxSetVar,pos={16,48},size={194,18},title="Units Per Sample:"
		SetVariable uppxSetVar,help={"Units/data sample in the X-direction."}
		SetVariable uppxSetVar,format="%g"
		SetVariable uppxSetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:XUnitsPerPixel
		SetVariable uppySetVar,pos={214,48},size={80,18},title=" "
		SetVariable uppySetVar,help={"Units per data sample in the Y-direction"}
		SetVariable uppySetVar,format="%g"
		SetVariable uppySetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:YUnitsPerPixel
		SetVariable originXsetVar,pos={86,73},size={124,18},title="Origin Pixel:"
		SetVariable originXsetVar,help={"The position of the origin using the units above."}
		SetVariable originXsetVar,format="%g",bodyWidth=80
		SetVariable originXsetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:XOrigin
		SetVariable originYsetVar,pos={214,73},size={80,18},title=" "
		SetVariable originYsetVar,help={"The position of the origin in the units above."}
		SetVariable originYsetVar,format="%g"
		SetVariable originYsetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:YOrigin
		SetVariable offsetAngleSetVar,pos={77,98},size={163,18},title="Offset Angle:"
		SetVariable offsetAngleSetVar,help={"Displays the current rotation angle for this calibration set."}
		SetVariable offsetAngleSetVar,format="%g"
		SetVariable offsetAngleSetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:offsetAngle
		Button markAngleButton,pos={305,98},size={120,20},proc=markAngleButtonProc,title="Mark on Image"
		Button markAngleButton,help={"Obtain the value of the offset angle by interactive adjustment of the angle on the image."}
		Button markOriginButton,pos={305,73},size={120,20},proc=WM_MarkOriginButtonProc,title="Mark on Image"
		Button markOriginButton,help={"Obtain the position of the origin by interactive  positioning a cross on the image."}
		SetVariable unitsNamesetvar,pos={84,124},size={150,18},title="Units Name:"
		SetVariable unitsNamesetvar,help={"Use e.g., mm, km, etc."},font="Arial"
		SetVariable unitsNamesetvar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:unitsName
		PopupMenu calibrationPopup,pos={18,4},size={185,24},proc=WMUpdateCalibrationPanel,title="Calibration Set:"
		PopupMenu calibrationPopup,help={"Select an existing calibration set from this menu.  You can later edit this set using the other controls in this window."}
		PopupMenu calibrationPopup,mode=1,popvalue="_none_",value= #"WMGetCalibrationsList()"
		Button fromWaveButton,pos={304,48},size={120,20},proc=WM_FromwaveButtonProc,title="From Image"
		Button fromWaveButton,help={"Uses top-image  wave scaling to establish units/sample point  in each direction."}
		Button applyClibrationButton,pos={145,149},size={120,20},proc=WMApplyCalibrationProc,title="Apply to image"
		Button applyClibrationButton,help={"Changes the wave scaling for the top-image to the units/sample and origin values."}
		ModifyPanel fixedSize=1

		// auto-load the first real calibration, or the last one used if available
		String theList=WMGetCalibrationsList()
		SVAR	S_curCalibration=root:Packages:WMCalibrations:S_curCalibration
		Variable inited=0
		if(strlen(S_curCalibration)>0)
			if(strSearch(theList,S_curCalibration,0)>-1)
				PopupMenu calibrationPopup,pos={3,4},size={168,24},title="Calibration Set:"
				PopupMenu calibrationPopup,value= #"WMGetCalibrationsList()"
				PopupMenu calibrationPopup, proc=WMUpdateCalibrationPanel
				PopupMenu calibrationPopup,popvalue=S_curCalibration,mode=1
				WMUpdateCalibrationPanel("",2,S_curCalibration)
				inited=1
			endif
		endif
		if(inited==0)
			if(strlen(theList)>7)			// pass the _none_; item 
				PopupMenu calibrationPopup,pos={3,4},size={168,24},title="Calibration Set:"
				PopupMenu calibrationPopup,value= #"WMGetCalibrationsList()"
				PopupMenu calibrationPopup, proc=WMUpdateCalibrationPanel
				PopupMenu calibrationPopup,mode=2
				ControlInfo calibrationPopup
				WMUpdateCalibrationPanel("",2,S_Value)
			else
				PopupMenu calibrationPopup,pos={3,4},size={168,24},title="Calibration Set:"
				PopupMenu calibrationPopup,value= #"WMGetCalibrationsList()"
				PopupMenu calibrationPopup, proc=WMUpdateCalibrationPanel
				PopupMenu calibrationPopup,mode=1
			endif
		endif
	endif
End

//************************************************************************************************
Function WMSpatialMeasurements()

	String topName=WMTopImageGraph()
	DoWindow/F WMSpatialMeasurementPanel
	if(V_Flag==1)
		if(strlen(topName)>0)
			AutoPositionWindow /E/R=$topName
		endif
		return 0
	endif
	
	NewPanel /k=1/W=(586.2,51.8,853.8,258.8) as "Spatial Measurements"
	DoWindow/C/T WMSpatialMeasurementPanel,"Spatial Measurements"
	if(strlen(topName)>0)
		AutoPositionWindow /E/M=1/R=$topName
	endif
	Button markPositionthbutton,pos={17,23},size={225,20},proc=WM_MarkPositionButtonProc,title="Mark Position"
	Button markPositionthbutton,help={"Click here to mark a position on the image.  You will get a new panel with various marker options."}
	Button measureLengthbutton,pos={17,49},size={225,20},proc=WM_measureLengthButtonProc,title="Measure length + angle"
	Button measureLengthbutton,help={"Click here to measure length and angle on the top image.  You will get a new panel with relevant options."}
	Button showmeasurementTablebutton,pos={17,105},size={225,20},proc=WMMeasurementTableButtonProc,title="Show measurement table"
	Button showmeasurementTablebutton,help={"Click here to get a table showing all the measurements that you have done for the top image."}
	Button measureAnglebutton,pos={17,76},size={225,20},proc=WM_MeasureAngleButtonProc,title="Measure differential angle"
	Button measureAnglebutton,help={"Click here to mark and measure differential angles.  You will get a new panel with relevant options."}
	Button erasemeasurementTablebutton,pos={17,136},size={225,20},proc=WMEraseMeasurementButtonProc,title="Erase measurements"
	Button erasemeasurementTablebutton,help={"Removes traces from the image and kills the associated waves."}
	Button eraseCalibraionbutton,pos={17,166},size={225,20},proc=WMEraseCalibraionButtonProc,title="Erase Calibration Markers"
	Button eraseCalibraionbutton,help={"Erase all calibration markers from the top image."}
	ModifyPanel fixedSize=1
End

//************************************************************************************************
Function WMEraseCalibraionButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String imageDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	String ywave="WMLengthMarkerY"
	String twave="WMLengthMarkerTag"
	String xwave="WMLengthMarkerX"
	SetDataFolder imageDF
	
	// first remove the traces from the graph
	
	String List=TraceNameList("",";",1)
	String tmp
	Variable i=0
	do
		tmp=StringFromList(i,List, ";")
		if(strlen(tmp)<=0)
			break
		endif
		
		if(strsearch(tmp,ywave,0)==0)
			Variable pos=strsearch(tmp,"#",0)		// handling the problem with multiple instances (Horizonatl only)
			if(pos>0)
				String part=tmp[0,pos-1]
				RemoveFromGraph/Z $part
			else
				RemoveFromGraph/Z $tmp
			endif
		else
			if(strsearch(tmp,twave,0)==0)
				RemoveFromGraph/Z $tmp
			endif
		endif
		i+=1
	while(1)
	
	// Now kill the waves
	
	List=WaveList("*",";","")
	i=0
	do
		tmp=StringFromList(i,List, ";")
		if(strlen(tmp)<=0)
			break
		endif
		if(strsearch(tmp,ywave,0)==0)
			KillWaves/Z $tmp
		else
			if(strsearch(tmp,twave,0)==0)
				KillWaves/Z $tmp
			else
				if(strsearch(tmp,xwave,0)==0)
					KillWaves/Z $tmp
				endif
			endif
		endif
		i+=1
	while(1)
	
	SetDataFolder cdf
End

//************************************************************************************************
Function WM_FromwaveButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	// obtain the scaling from the image wave
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
		
	NVAR 	XUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	YUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	SVAR	unitsName=root:Packages:WMCalibrations:unitsName
	
	Wave w=$imageWaveName
	XUnitsPerPixel=DimDelta(w,0)
	YUnitsPerPixel=DimDelta(w,1)
	XOrigin=-DimOffset(w,0)/DimDelta(w,0)
	YOrigin=-DimOffset(w,1)/DimDelta(w,1)
	unitsName=WaveUnits(w,0)
End

//************************************************************************************************
Function WMIsCalibrationApplied()

	NVAR 	XUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	YUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	SVAR	unitsName=root:Packages:WMCalibrations:unitsName
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	Wave 	w=$imageWaveName
	
	if(XUnitsPerPixel!=DimDelta(w,0))
		return 0
	endif
	
	if(YUnitsPerPixel!=DimDelta(w,1))
		return 0
	endif
	
	if(XOrigin!=-DimOffset(w,0)/DimDelta(w,0))
		return 0
	endif
	
	if(YOrigin!=-DimOffset(w,1)/DimDelta(w,1))
		return 0
	endif
	
	return 1
End
//************************************************************************************************
Function WMApplyScalingToImage()

	NVAR 	XUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	YUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	SVAR	unitsName=root:Packages:WMCalibrations:unitsName
	
	String imageWaveName=WMGetImageWave(WMTopImageGraph())
	
	SetScale/P x, (-XOrigin*XUnitsPerPixel),XUnitsPerPixel,unitsName, $imageWaveName
	SetScale/P y, (-YOrigin*YUnitsPerPixel),YUnitsPerPixel,unitsName, $imageWaveName
	
End
//************************************************************************************************
Function WM_measureLengthButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if(WMIsCalibrationApplied()==0)
		doalert 0, "Calibration must be applied to the image before proceeding"
		return 0
	endif
	
	DoWindow/F WMLengthMeasurePanel
	if(V_Flag==1)
		AutoPositionWindow /E/m=1/R=$WMTopImageGraph()
		return 0
	endif
	
	NewPanel /K=2 /W=(388.2,242,853.2,464) as "Measuring Length"
	DoWindow/C WMLengthMeasurePanel
	String topImage=WMTopImageGraph()
	if(strlen(topImage)>0)
		AutoPositionWindow /E/m=1/R=$topImage
	endif
	SetDrawLayer UserBack
	DrawText 13,18,"Adjust the red line on the image to the length that you want to measure."
	SetDrawEnv linefgc= (43520,43520,43520),fillpat= 0,fillfgc= (52224,52224,52224)
	DrawRect 21,116,267,215
	Button measureLengthDoneButton,pos={313,188},size={80,20},proc=WMMeasureLengthDoneButtonProc,title="Done"
	Button addCalibrationMarkerButton,pos={294,106},size={160,20},proc=WMAddCalibrationMakrerProc,title="Add Calibration Marker"
	Button addCalibrationMarkerButton,help={"Click here to access a panel with calibration maker choices."}
	SetVariable setvar0,pos={11,24},size={352,18},title="Title:"
	SetVariable setvar0,help={"Enter here the title of the measurement.  The title will be included in the optional tag."}
	SetVariable setvar0,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curMeasurement
	ValDisplay curLengthValdisp,pos={16,76},size={150,18},title="Length:"
	ValDisplay curLengthValdisp,help={"The length of the measured line using the current calibration set."}
	ValDisplay curLengthValdisp,limits={0,0,0},barmisc={0,1000}
	ValDisplay curLengthValdisp,value= #"root:Packages:WMCalibrations:curLength"
	Button addLengthToImageButton,pos={70,106},size={150,20},proc=WMAddLengthToImageButtonProc,title="Add to image"
	Button addLengthToImageButton,help={"Click here to add the current line/angle measurement to the image.  Check below if you want to add a tag with some information."}
	CheckBox lengthTagCheck,pos={74,135},size={120,20},title="Add with a tag"
	CheckBox lengthTagCheck,help={"Check here if you want a tag associated with the added length/angle measurement."},value=1
	CheckBox showLengthCheck,pos={73,162},size={140,20},title="Show length in tag",value=1
	SetVariable lengthNoteSetVar,pos={9,48},size={354,18},title="Note:"
	SetVariable lengthNoteSetVar,help={"Enter here text information associated with this measurement.  The note is not included in the optional tag."}
	SetVariable lengthNoteSetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curNote
	ValDisplay curAngleValdisp,pos={233,76},size={150,18},title="Angle:"
	ValDisplay curAngleValdisp,help={"The angle of the current line (in degrees)."}
	ValDisplay curAngleValdisp,format="%.2f degrees",limits={0,0,0},barmisc={0,1000}
	ValDisplay curAngleValdisp,value= #"root:Packages:WMCalibrations:curAngle"
	CheckBox showAngleCheck,pos={73,189},size={140,20},title="Show angle in tag",value=1
	
	// Measure Length & angle
	String cdf=GetDataFolder(1)
	WM_initImageCursors(2)	
	WM_DrawCursors(2)
	WMmakeMeasurementTextWave()			// saves text info
	SetDataFolder cdf
End

//************************************************************************************************
Function WM_MarkPositionButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(WMIsCalibrationApplied()==0)
		doalert 0, "Calibration must be applied to the image before proceeding"
		return 0
	endif
	
	DoWindow/F WMMarkPositionsPanel
	if(V_Flag==1)
		AutoPositionWindow /E/m=1/R=$WMTopImageGraph()
		return 0
	endif
	
	NewPanel /K=2/W=(196.8,374,613.8,626) as "Marking Positions"
	DoWindow/C WMMarkPositionsPanel
	String topImage=WMTopImageGraph()
	if(strlen(topImage)>0)
		AutoPositionWindow /E/m=1/R=$topImage
	endif
	SetDrawLayer UserBack
		DrawText 13,18,"Move the red cursor to the location that you want to mark"
		SetDrawEnv linefgc= (43520,43520,43520),fillpat= 0
		DrawRect 21,143,267,242
		Button markPositionDoneButton,pos={313,215},size={80,20},proc=WMMarkPositionDoneButtonProc,title="Done"
		SetVariable setvar0,pos={33,28},size={352,18},title="Title:"
		SetVariable setvar0,help={"Enter here the title of the marked point.  The title will appear in the optional tag."}
		SetVariable setvar0,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curMeasurement
		ValDisplay curXValdisp,pos={16,96},size={150,18},title="X:"
		ValDisplay curXValdisp,help={"The X position of the marker using the current calibration set."}
		ValDisplay curXValdisp,limits={0,0,0},barmisc={0,1000}
		ValDisplay curXValdisp,value=#"root:Packages:WMCalibrations:xMarker[0]"	// #"root:Packages:WMCalibrations:curX"
		Button addPositionButton,pos={70,133},size={150,20},proc=WMAddPositionButtonProc,title="Add to image"
		Button addPositionButton,help={"Append the current marker and its associated information to the image.  If the tag option is checked, the tag will be appended to the image."}
		CheckBox positionTagCheck,pos={74,162},size={120,20},title="Add with a tag"
		CheckBox positionTagCheck,help={"Check this box to append a tag to the new marker."},value=1
		CheckBox showLengthCheck,pos={73,189},size={160,20},title="Show position in tag"
		CheckBox showLengthCheck,help={"Check this box for the tag to include the marker's position in addition to its title."},value=1
		SetVariable lengthNoteSetVar,pos={32,60},size={354,18},title="Note:"
		SetVariable lengthNoteSetVar,help={"Enter here general information that you want to associate with the marked point.  The note is not shown in the marker tag."}
		SetVariable lengthNoteSetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curNote
		ValDisplay curYValdisp,pos={233,96},size={150,18},title="Y:"
		ValDisplay curYValdisp,help={"The Y position of the marker in the current calibration set."}
		ValDisplay curYValdisp,format="%g",limits={0,0,0},barmisc={0,1000}
		ValDisplay curYValdisp,value=#"root:Packages:WMCalibrations:yMarker[0]"	//#"root:Packages:WMCalibrations:curY"
	String cdf=GetDataFolder(1)
	WM_initImageCursors(1)	
	WM_DrawCursors(1)
	WMmakeMeasurementTextWave()			// saves text info
	SetDataFolder cdf
End

//************************************************************************************************
Function WM_MeasureAngleButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if(WMIsCalibrationApplied()==0)
		doalert 0, "Calibration must be applied to the image before proceeding"
		return 0
	endif

	DoWindow/F WMAngleMeasurePanel
	if(V_Flag==1)
		AutoPositionWindow /E/m=1/R=$WMTopImageGraph()
		return 0
	endif

	NewPanel /K=2 /W=(678,267.2,1069.8,459.8) as "Measuring Angles"
	DoWindow/C WMAngleMeasurePanel
	String topImage=WMTopImageGraph()
	if(strlen(topImage)>0)
		AutoPositionWindow /E/m=1/R=$topImage
	endif
	SetDrawLayer UserBack
	DrawText 13,18,"Adjust the 3 points to represent the measured angle."
	SetDrawEnv linefgc= (43520,43520,43520),fillpat= 0,fillfgc= (52224,52224,52224)
	DrawRect 21,108,268,180
	Button measureAngleDoneButton,pos={284,155},size={80,20},proc=WMMeasureAngleDoneButtonProc,title="Done"
	SetVariable setvar0,pos={4,22},size={352,18},title="Title:"
	SetVariable setvar0,help={"Enter here a title for the measurement.  The title will appear in the optional tag."}
	SetVariable setvar0,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curMeasurement
	ValDisplay curLengthValdisp,pos={25,70},size={150,18},title="Angle:"
	ValDisplay curLengthValdisp,help={"This shows the angle (in degrees) between the two line segments."}
	ValDisplay curLengthValdisp,limits={0,0,0},barmisc={0,1000}
	ValDisplay curLengthValdisp,value= #"root:Packages:WMCalibrations:curAngle"
	Button addLengthToImageButton,pos={70,94},size={150,20},proc=WMAddAngleToImageButtonProc,title="Add to image"
	Button addLengthToImageButton,help={"Click here to add the measurement to the image.  Make sure to check the boxes below corresponding to the tag options."}
	CheckBox lengthTagCheck,pos={74,123},size={120,20},title="Add with a tag",value=1
	CheckBox showLengthCheck,pos={73,150},size={140,20},title="Show angle in tag",value=1
	SetVariable lengthNoteSetVar,pos={3,45},size={354,18},title="Note:"
	SetVariable lengthNoteSetVar,help={"Enter here some text notes about the measurement.  The note is not included in the tag."}
	SetVariable lengthNoteSetVar,limits={-Inf,Inf,1},value= root:Packages:WMCalibrations:S_curNote
	
	SVAR S_curNote=root:Packages:WMCalibrations:S_curNote
	SVAR S_curMeasurement=root:Packages:WMCalibrations:S_curMeasurement
	S_curNote=""
	S_curMeasurement=""

	String cdf=GetDataFolder(1)
	WM_initImageCursors(3)	
	WM_DrawCursors(3)
	WMmakeMeasurementTextWave()			// saves text info; checks if it needs to be recreated. 
	SetDataFolder cdf
End

//************************************************************************************************
Function WMMeasurementTableButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String waveName=WMGetImageDF()+"TW_measurementRecord"
	if(WaveExists($waveName))
		Edit $waveName
	else
		doAlert 0, "Measurement info cannot be found"
	endif
End

//************************************************************************************************
Function WMCreateSaveCalibrationPanel()

	DoWindow/F WMSaveCalibrationPanel
	if(V_Flag==1)
		return 0
	endif
	String/G root:Packages:WMCalibrations:newCalibrationName="Untitled"
	NewPanel /k=1/W=(547.2,227,915,354.8) as "Save Calibration"
	DoWindow/C/T WMSaveCalibrationPanel,"Save Calibration"
	String topName=WMTopImageGraph()
	if(strlen(topName)>0)
		AutoPositionWindow /E/R=$topName
	endif
	Button saveCalButton,pos={258,84},size={80,20},title="Save",proc=WMSaveCalButtonProc
	Button cancelCalButton,pos={152,84},size={80,20},title="Cancel",proc=WMCancelCalButtonProc
	SetVariable calNameSetvar,pos={25,25},size={317,18},title="Calibration Name:"
	SetVariable calNameSetvar,limits={-Inf,Inf,0},value= root:Packages:WMCalibrations:newCalibrationName
	CheckBox overWriteCalcheck size={150,20}, pos={25,54},title="Overwrite existing",value=1
End
//************************************************************************************************
Function WMCancelCalButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K WMSaveCalibrationPanel
	KillVariables/z  root:Packages:WMCalibrations:newCalibrationName
End
//************************************************************************************************
Function WMSaveCalButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR 	S_curCalibration=root:Packages:WMCalibrations:S_curCalibration
	SVAR	newCalibrationName=root:Packages:WMCalibrations:newCalibrationName
	S_curCalibration=newCalibrationName
	String	cdf=GetDataFolder(1)
	
	// now lets see if the folder already exists:
	String calDF="root:Packages:WMCalibrations:"+S_curCalibration
		
	if(DataFolderExists(calDF))
		ControlInfo overWriteCalcheck
		if(V_Value==0)
			DoAlert 0, "Cannot overwrite calibration set of the same name."
			return 0
		endif
	else
		NewDataFolder/O $calDF
	endif
	
	SetDataFolder calDF
	NVAR 	aXUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	aYUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	NVAR 	aYOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	aXOrigin=root:Packages:WMCalibrations:XOrigin
	NVAR 	aOffsetAngle=root:Packages:WMCalibrations:OffsetAngle
	SVAR	aunitsName=root:Packages:WMCalibrations:unitsName
	
	Variable/G XUnitsPerPixel=aXUnitsPerPixel
	Variable/G YUnitsPerPixel=aYUnitsPerPixel
	Variable/G YOrigin=aYOrigin
	Variable/G XOrigin=aXOrigin
	Variable/G OffsetAngle=aOffsetAngle
	String/G 	   unitsName=aunitsName
		
	DoWindow/K WMSaveCalibrationPanel
	KillVariables/z  root:Packages:WMCalibrations:newCalibrationName
	SetDataFolder cdf
	PopupMenu calibrationPopup,popvalue=S_curCalibration,mode=1		// update the menu
End

//************************************************************************************************
// numCursors=1 for setting origin, =2 for a line and =3 for angle.
// The second parameter type=0 for origin marker and for angle marker.  

Function WM_initImageCursors(numCursors)
	Variable numCursors
		
	SetWindow $WMTopImageGraph(), hook(calibrationHook)=WMcalibrationHook,hookEvents=4
	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:WMCalibrations
	Make/O/N=3 xMarker=nan,yMarker=nan
	String cmd  cmd="AppendToGraph "+WMGetAxesForCommand()+" yMarker vs xMarker"
	Execute cmd

	SetDataFolder curDF
End

//************************************************************************************************
// 02APR07
Function WMMeasureAngleDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	RemoveFromGraph/Z marker1y,marker2y,marker3y,markerDummyy
	RemoveFromGraph/Z markerLineY
	DoWindow/K WMAngleMeasurePanel
	WM_DrawCursors(0)
End

//************************************************************************************************
// 02APR07
Function WMMarkPositionDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	RemoveFromGraph/Z marker1y,markerDummyy
	DoWindow/K WMMarkPositionsPanel
	WM_DrawCursors(0)
End

//************************************************************************************************
Function WMAddCalibrationMakrerProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F WMCalibrationMarkerPanel
	if(V_Flag==1)
		return 0
	endif
	
	NewPanel /K=1/W=(340.8,402.8,669,603.2) as "Calibration Marker"
	DoWindow/C WMCalibrationMarkerPanel
	AutoPositionWindow /E/m=1/R=$WMTopImageGraph()
	Button addMarkerButton,pos={125,140},size={150,20},title="Add Marker",proc=WMAddMarkerButtonProc
	Button cancelMarkerButton,pos={125,166},size={150,20},title="Cancel",proc=WMCancelMarkerButtonProc
	SetVariable markerLengthSetVar,pos={35,31},size={180,18},title="Marker Length:"
	SetVariable markerLengthSetVar,limits={1,Inf,1},value= root:Packages:WMCalibrations:calibrationMarkerLength
	PopupMenu markerOrientationPop,pos={54,62},size={178,24},title="Orientation:"
	PopupMenu markerOrientationPop,mode=1,popvalue="Horizontal",value= #"\"Horizontal;Vertical\""
End

//************************************************************************************************
Function WMAddMarkerButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String cmd,trace2
	Variable orientation
	ControlInfo markerOrientationPop
	orientation=V_Value				// 1 for horizontal, 2 for vertical

	NVAR calibrationMarkerLength=root:Packages:WMCalibrations:calibrationMarkerLength
	SVAR unitsName=root:Packages:WMCalibrations:unitsName
	String imageDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageDF
	String uniqueWaveX=UniqueName("WMLengthMarkerX",1,0)
	String uniqueWaveY=UniqueName("WMLengthMarkerY",1,0)	
	String uniqueTagWave=UniqueName("WMLengthMarkerTag",1,0)
	String tagStr=num2str(calibrationMarkerLength)+ "  "+unitsName
	
	NVAR 	YOrigin=root:Packages:WMCalibrations:YOrigin
	NVAR 	XOrigin=root:Packages:WMCalibrations:XOrigin
	NVAR 	XUnitsPerPixel=root:Packages:WMCalibrations:XUnitsPerPixel
	NVAR	YUnitsPerPixel=root:Packages:WMCalibrations:YUnitsPerPixel
	
	// there are two waves for drawing the line with the appropriate length
	// the third wave has a single point and it is used to center the tag in the right place.
	
	Make/N=2 $uniqueWaveX,$uniqueWaveY
	Make/N=1 $uniqueTagWave
	Wave wx=$uniqueWaveX
	Wave wy=$uniqueWaveY
	Wave wt=$uniqueTagWave
	
	if(orientation==1)			// is it horizontal
		wx={15,15+calibrationMarkerLength/XUnitsPerPixel}
		wy={25,25}
		wt[0]=15+calibrationMarkerLength/(2*XUnitsPerPixel)		// wt will use the same wy 
		wy=wy*YUnitsPerPixel+YOrigin
		wx=wx*XUnitsPerPixel+XOrigin
		wt=wt*XUnitsPerPixel+XOrigin
		cmd="AppendToGraph "+WMGetAxesForCommand()+" "+uniqueWaveY+" vs "+ uniqueWaveX
		Execute cmd
		cmd="AppendToGraph "+WMGetAxesForCommand()+" "+uniqueWaveY+" vs "+ uniqueTagWave
		Execute cmd
		ModifyGraph mode($uniqueWaveY)=4,marker($uniqueWaveY)=10
		trace2=uniqueWaveY+"#1"
		ModifyGraph mode($trace2)=2
		Tag/F=0/A=MB/L=0/X=0/y=1 $trace2, 0,tagStr

	else						// it is vertical
		wy={15,15+calibrationMarkerLength/YUnitsPerPixel}
		wx={25,25}
		wy=wy*YUnitsPerPixel+YOrigin
		wx=wx*XUnitsPerPixel+XOrigin
		wt[0]=15+calibrationMarkerLength/(2*YUnitsPerPixel)		// wt will use the same wy 
		wt=wt*YUnitsPerPixel+YOrigin

		cmd="AppendToGraph "+WMGetAxesForCommand()+" "+uniqueWaveY+" vs "+ uniqueWaveX
		Execute cmd
		ModifyGraph mode($uniqueWaveY)=4,marker($uniqueWaveY)=9
		cmd="AppendToGraph "+WMGetAxesForCommand()+" "+uniqueTagWave+" vs "+ uniqueWaveX
		Execute cmd
		ModifyGraph mode($uniqueTagWave)=2
		Tag/F=0/A=RC/L=0/O=90/X=-1/y=0 $uniqueTagWave, 0,tagStr
	endif
	
	DoWindow/K WMCalibrationMarkerPanel
	SetDataFolder cdf
End

//************************************************************************************************
Function WMCancelMarkerButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DoWindow/K WMCalibrationMarkerPanel
End

//************************************************************************************************

Function WMMeasureLengthDoneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	RemoveFromGraph/Z marker1y,marker2y,markerDummyy,markerLineY
	DoWindow/K WMLengthMeasurePanel
	WM_DrawCursors(0)
End

//************************************************************************************************
// The waves WMPositionMeasurementX & Y just save positions; they do not have NaNs
// separating segments because a segment consists of one point in each wave.

Function WMAddPositionButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String imageWaveDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageWaveDF
	// see if the proper waves exist
	if((WaveExists(WMPositionMeasurementX)==0)  %|  (WaveExists(WMPositionMeasurementY)==0))
		// if the waves do not exist create them
		Make/O/N=1	WMPositionMeasurementX=nan
		Make/O/N=1	WMPositionMeasurementY=nan
	else
		// the waves exist so add to each 3 points to accomodate the new data
		Variable numPoints=numpnts(WMPositionMeasurementX)
		Redimension/N=(numPoints+1) WMPositionMeasurementX,WMPositionMeasurementY
			WMPositionMeasurementX[numPoints]=nan
			WMPositionMeasurementY[numPoints]=nan
	endif

//	String cursorDF="root:WinGlobals:"+WMTopImageGraph()
	Wave xMarker=root:Packages:WMCalibrations:xMarker
	Wave yMarker=root:Packages:WMCalibrations:yMarker
	NVAR curX=root:Packages:WMCalibrations:curX
	NVAR curY=root:Packages:WMCalibrations:curY
	curX=xMarker[0]
	curY=yMarker[0]
		
	WMPositionMeasurementX[numPoints]=curX 
	WMPositionMeasurementY[numPoints]=curY 
	

	// now that we added the points, it is worthwhile to check if the waves are displayed.
	CheckDisplayed /W=$WMTopImageGraph() WMPositionMeasurementY
	if(V_flag==0)
		String cmd="AppendToGraph "+WMGetAxesForCommand()+" WMPositionMeasurementY vs WMPositionMeasurementX"
		Execute cmd
		ModifyGraph marker(WMPositionMeasurementY)=0,mode(WMPositionMeasurementY)=3,msize(WMPositionMeasurementY)=5
	endif

	SVAR S_curMeasurement=root:Packages:WMCalibrations:S_curMeasurement
	SVAR S_curNote=root:Packages:WMCalibrations:S_curNote

	// now check if we need to add a tag based on the checkbox in the panel
	String position="("+num2str(curX)+","+num2str(curY)+")"
	ControlInfo positionTagCheck
	if(V_Value==1)
		String tagString=S_curMeasurement
		if(strlen(tagString)<=0)
			tagString="\Z09"+position
		else
			tagString+="\r\Z09"+position
		endif
		Tag /F=0/X=2 WMPositionMeasurementY,Pnt2x(WMPositionMeasurementY,numPoints), tagString	
	endif

	WMAppendInfoToTextWave("Position",S_curMeasurement,position,S_curNote)

	RemoveFromGraph/Z marker1y,markerDummyy
	KillWaves/Z marker1y
	WM_initImageCursors(1)	// move it back to the original position

	WM_DrawCursors(1)
	SetDataFolder cdf
End
//************************************************************************************************
Function WMAddAngleToImageButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	// first check if we need to create the two waves that hold the permanent length
	// measurements
	
	String imageWaveDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageWaveDF
	
	if((WaveExists(WMAngleMeasurementX)==0)  %|  (WaveExists(WMAngleMeasurementY)==0))
		// if the waves do not exist create them
		Make/O/N=4	WMAngleMeasurementX
		Make/O/N=4	WMAngleMeasurementY
	else
		// the waves exist so add to each 3 points to accomodate the new data
		Variable numPoints=numpnts(WMAngleMeasurementX)
		Redimension/N=(numPoints+4) WMAngleMeasurementX,WMAngleMeasurementY
	endif
	
	// The two end points of the segment that we are adding are taken from the waves markerLineX &Y
	Wave xMarker=root:Packages:WMCalibrations:xMarker
	Wave yMarker=root:Packages:WMCalibrations:yMarker
		
	WMAngleMeasurementX[numPoints]=xMarker[0]
	WMAngleMeasurementY[numPoints]=yMarker[0]
	numPoints+=1
	WMAngleMeasurementX[numPoints]=xMarker[1]
	WMAngleMeasurementY[numPoints]=yMarker[1]
	numPoints+=1
	WMAngleMeasurementX[numPoints]=xMarker[2]
	WMAngleMeasurementY[numPoints]=yMarker[2]
	numPoints+=1
	WMAngleMeasurementX[numPoints]=NaN
	WMAngleMeasurementY[numPoints]=NaN
	
	// now that we added the points, it is worthwhile to check if the waves are displayed.
	CheckDisplayed /W=$WMTopImageGraph() WMAngleMeasurementY
	if(V_flag==0)
		String cmd="AppendToGraph "+WMGetAxesForCommand()+" WMAngleMeasurementY vs WMAngleMeasurementX"
		Execute cmd
		ModifyGraph marker(WMAngleMeasurementY)=19,mode(WMAngleMeasurementY)=4
	endif
	
	NVAR curAngle=root:Packages:WMCalibrations:curAngle
	SVAR S_curMeasurement=root:Packages:WMCalibrations:S_curMeasurement
	SVAR S_curNote=root:Packages:WMCalibrations:S_curNote
	
	String degree = "°"

	// now check if we need to add a tag based on the checkbox in the panel
	ControlInfo lengthTagCheck
	if(V_Value==1)
		String tagString=S_curMeasurement
		ControlInfo showLengthCheck
		if(V_Value==1)
			if(strlen(tagString)<=0)
				tagString="\Z09"+num2str(curAngle)+degree
			else
				tagString+="\r\Z09"+num2str(curAngle)+degree
			endif
		endif
		Tag /F=0 WMAngleMeasurementY,Pnt2x(WMAngleMeasurementY,numPoints-1), tagString	
	endif

	WMAppendInfoToTextWave("DiffAngle",S_curMeasurement,num2str(curAngle),S_curNote)

	RemoveFromGraph/Z marker1y,marker2y,marker3y,markerDummyy
	RemoveFromGraph/Z markerLineY
	KillWaves/Z marker1y,marker2y,marker3y,markerLineY
	WM_initImageCursors(3)	// move it back to the original position
	WM_DrawCursors(3)
	SetDataFolder cdf
End

//************************************************************************************************
Function WMAddLengthToImageButtonProc(ctrlName) : ButtonControl
	String ctrlName

	// first check if we need to create the two waves that hold the permanent length
	// measurements
	String imageWaveDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageWaveDF
	if((WaveExists(WMLengthMeasurementX)==0)  %|  (WaveExists(WMLengthMeasurementY)==0))
		// if the waves do not exist create them
		Make/O/N=3	WMLengthMeasurementX
		Make/O/N=3	WMLengthMeasurementY
	else
		// the waves exist so add to each 3 points to accomodate the new data
		Variable numPoints=numpnts(WMLengthMeasurementX)
		Redimension/N=(numPoints+3) WMLengthMeasurementX,WMLengthMeasurementY
	endif
	
	// The two end points of the segment that we are adding are taken from the waves markerLineX &Y
	Wave xMarker=root:Packages:WMCalibrations:xMarker
	Wave yMarker=root:Packages:WMCalibrations:yMarker
		
	WMLengthMeasurementX[numPoints]=xMarker[0]
	WMLengthMeasurementY[numPoints]=yMarker[0]
	numPoints+=1
	WMLengthMeasurementX[numPoints]=xMarker[1]
	WMLengthMeasurementY[numPoints]=yMarker[1]
	numPoints+=1
	WMLengthMeasurementX[numPoints]=NaN
	WMLengthMeasurementY[numPoints]=NaN
	
	// now that we added the points, it is worthwhile to check if the waves are displayed.
	CheckDisplayed /W=$WMTopImageGraph() WMLengthMeasurementY
	if(V_flag==0)
		String cmd="AppendToGraph "+WMGetAxesForCommand()+" WMLengthMeasurementY vs WMLengthMeasurementX"
		Execute cmd
		ModifyGraph marker(WMLengthMeasurementY)=19,mode(WMLengthMeasurementY)=4
	endif
	
	NVAR curLength=root:Packages:WMCalibrations:curLength
	NVAR curAngle=root:Packages:WMCalibrations:curAngle
	SVAR S_curMeasurement=root:Packages:WMCalibrations:S_curMeasurement
	SVAR S_curNote=root:Packages:WMCalibrations:S_curNote
	
	String degree = "°"

	// now check if we need to add a tag based on the checkbox in the panel
	ControlInfo lengthTagCheck
	if(V_Value==1)
		String tagString=S_curMeasurement
		ControlInfo showLengthCheck
		if(V_Value==1)
			if(strlen(tagString)<=0)
				tagString="\Z09"+num2str(curLength)
			else
				tagString+="\r\Z09"+num2str(curLength)
			endif
		endif
		ControlInfo showAngleCheck
		if(V_Value==1)
			if(strlen(tagString)<=0)
				tagString="\Z09"+num2str(curAngle)+degree
			else
				tagString+="\r\Z09"+num2str(curAngle)+degree
			endif
		endif

		Tag /F=0 WMLengthMeasurementY,Pnt2x(WMLengthMeasurementY,numPoints-1), tagString	
	endif

	WMAppendInfoToTextWave("Length",S_curMeasurement,num2str(curLength),S_curNote)
	ControlInfo showAngleCheck
	if(V_Value==1)
		WMAppendInfoToTextWave("Angle",S_curMeasurement,num2str(curAngle),S_curNote)
	endif

	RemoveFromGraph/Z marker1y,marker2y,markerDummyy
	RemoveFromGraph/Z markerLineY
	KillWaves/Z marker1y,marker2y,markerLineY
	WM_initImageCursors(2)	// move it back to the original position
	WM_DrawCursors(2)
	SetDataFolder cdf
End

//************************************************************************************************
Function WMEraseMeasurementButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String imageWaveDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageWaveDF
	// first remove from the graph
	CheckDisplayed /W=$WMTopImageGraph() WMLengthMeasurementY
	if(V_flag==1)
		RemoveFromGraph/Z WMLengthMeasurementY
	endif
	CheckDisplayed /W=$WMTopImageGraph() WMAngleMeasurementY
	if(V_flag==1)
		RemoveFromGraph/Z WMAngleMeasurementY
	endif
	CheckDisplayed/W=$WMTopImageGraph() WMPositionMeasurementY
	if(V_flag==1)
		RemoveFromGraph/Z WMPositionMeasurementY
	endif
	
	CheckDisplayed/W=$WMTopImageGraph() markerDummyy
	if(V_flag==1)
		RemoveFromGraph/Z markerDummyy
	endif
	
	// now we kill the actual waves in which the measurement data are stored
	KillWaves/Z  WMLengthMeasurementY,WMLengthMeasurementX,TW_measurementRecord,WMAngleMeasurementX,WMAngleMeasurementY
	KillWaves/Z WMPositionMeasurementX,WMPositionMeasurementY,markerDummyy,markerDummyx
	SetDataFolder cdf
End

//************************************************************************************************
Function WMmakeMeasurementTextWave()

	String imageWaveDF=WMGetImageDF()
	String cdf=GetDataFolder(1)
	SetDataFolder imageWaveDF
	
	WAVE/Z/T w=$"TW_measurementRecord"
	if(WaveExists(w))
		return 1
	endif
	
	Make/T/N=(1,4) TW_measurementRecord
	TW_measurementRecord[0][0]="Type"
	TW_measurementRecord[0][1]="Title"
	TW_measurementRecord[0][2]="Value"
	TW_measurementRecord[0][3]="Note"
	SetDataFolder cdf
End
//************************************************************************************************
Function WMAppendInfoToTextWave(str0,str1,str2,str3)
	String str0,str1,str2,str3

	String imageWaveDF=WMGetImageDF()+"TW_measurementRecord"
	Wave/T w=$imageWaveDF

	Variable row=DimSize(w,0)
	Redimension/N=(1+row,4) w
	w[row][0]=str0
	w[row][1]=str1
	w[row][2]=str2
	w[row][3]=str3
End
//************************************************************************************************

Function/S WMGetImageDF()

	String topName=WMTopImageGraph()
	if(strlen(topName)<=0)
		Abort  "You must have a displayed image for this operation."
	endif
	String imageWaveName=WMGetImageWave(topName)
	String imageWaveDF=GetWavesDataFolder($imageWaveName,1)
	return imageWaveDF
End
//************************************************************************************************
Function WMisWindows()

	String info=IgorInfo(2)
	if(cmpstr(info,"windows")==0)
		return 1
	endif
	return 0
End


//************************************************************************************************
Function/s WMGetLeafName(name)
	String name
	String out
	
	Variable len=strlen(name)
	Variable i=0
	do
		if(char2num(name[len-i-1])==58)		// found a colon
			break
		endif
		i+=1
	while(i<len)
	out=name[len-i,len]
	return out
End
//************************************************************************************************
Function WMSaveCalibrationProc(ctrlName) : ButtonControl
	String ctrlName
	WMCreateSaveCalibrationPanel()
End

//************************************************************************************************
Function WMApplyCalibrationProc(ctrlName) : ButtonControl
	String ctrlName
	
	WMApplyScalingToImage()
End

//************************************************************************************************
