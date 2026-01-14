#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>

// AG30AUG11: added test to avoid width -> NaN and storing the value in the dedicated df.
// AG16JUL10:  modified width conversion from width/2 to (width-1)/2
// LH090308: made some waves double to support date-time
// AG18DEC07 added root:Packages:WMImProcess:LineProfile:treatAsGrayFlag to allow shorter than 4 planes to be treated as gray.
// AG01NOV07 changed scaling of the width parameter so that the call to the built-in op remains in pixels.  Affects only modes 1 and 2.
// AG05SEP06 replaced Surface Plotter with Gizmo plot.
// AG14JAN05 moved WM_GetDisplayed3DPlane to Image Common.
// AG09JAN04 added error checking and error suppression.  Made changes so that dependency is killed if user closes the lineprofile window.
// AG08JAN04 added support for 3D images displayed with plane=x.
// AG21FEB03 added update for freehand modes when width control changes.
// also added /Z to wave declaration in checkpoint procedure.
// AG17FEB03 changed width control so that it does not re-initialize the path for freehand.
// AG15FEB02  added a kill for wmTmp in the freehand branch.
// AG18JAN02 modified the width passed from the panel to full width. 
// AG24SEP01 added/Z flag to wave declarations so it does not complain when running under the debugger.
// AG23AUG01 Removed support for wave scaling because now it is included in the ImageLineProfile operation.
// AG21AUG01 Change to wmTmp so that it does not keep creating this folder
// AG15MAR00 Attempt to rewrite this kludge.
// AG 22FEB00 support for color; tried to make it a bit more friendly.
// AG17JUN99 Modified the update by calling the hook directly after panel creation.
// LH980211
// Image Line Profile, version 0.9
// Requires Igor Pro 3.12 or later
// Requires the Surface Plotter XOP.
//  
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageLineProfileGraph()

// Todo: 	support RGB in the surface plotter option for freehand.
//		Rewrite the whole ugly kludge from scratch :)
//*******************************************************************************************************

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function WMCreateImageLineProfileGraph()

	DoWindow/F WMImageLineProfileGraph
	if( V_Flag==1 )							// is the "panel" up already?
		return 0
	endif

	String imageName= WMTopImageGraph()		// find one top image in the top graph window
	if( strlen(imageName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	Wave w= $WMGetImageWave(imageName)	// get the wave associated with the top image.	
	String dfSav= GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WMImProcess
	NewDataFolder/O/S root:Packages:WMImProcess:LineProfile
	
		String/G imageGraphName= ""			// Let the activate event fill this in
		Variable/G profileMode=1			// truth want horizonal (x) profile
		Variable/G oldProfileMode=1		// for update testing
		Variable/G width= 5				// colums or rows to average
		Variable/G position=0				// this means 0 offset for the initial points (which are the center of the image).
		Variable/G isColor=isColorWave(w)
		
		if(isColor==0)
			Make/O profile
			Wave profile= profile
		else
			Make/O profileR,profileG,profileB
			Wave profileR
			Wave profileG
			Wave profileB
		endif
	
	SetDataFolder dfSav
	NVAR horiz= root:Packages:WMImProcess:LineProfile:profileMode
	
	// specify size in pixels to match user controls
	Variable x0=40*PanelResolution("")/ScreenResolution, y0= 349*PanelResolution("")/ScreenResolution
	Variable x1=560*PanelResolution("")/ScreenResolution, y1= 569*PanelResolution("")/ScreenResolution

	if(isColor==0)
		Display/K=1/W=(x0,y0,x1,y1) profile as "Image Line Profile"
	else
		Display/K=1/W=(x0,y0,x1,y1) profileR,profileG,profileB as "Image Line Profile"
		ModifyGraph rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
	endif
	
	DoWindow/C WMImageLineProfileGraph
	AutoPositionWindow/E/M=1/R=$imageName

	Variable isWin= CmpStr(IgorInfo(2)[0,2],"Win")==0
	Variable fsize=12
	if( isWin )
		fsize=10
	endif
	
	ControlBar 60
	PopupMenu profileModePop,pos={2,4},size={144,20},proc=WMImLineProfileModeProc
	PopupMenu profileModePop,help={"Profile mode selection.  Freehand modes allow you to edit the path by adding and moving points in the trace."}
	PopupMenu profileModePop,mode=3,popvalue="Horizontal Freehand",value= #"\"Horizontal;Vertical;Horizontal Freehand;Vertical Freehand;Freehand\""
	SetVariable width,pos={298,36},size={90,15},proc=WMImLineProfileWidthSetVarProc,title="width"
	SetVariable width,help={"Number of rows or columns to average."},format="%g"
	SetVariable width,limits={0,inf,0.5},value= root:Packages:WMImProcess:LineProfile:width
	SetVariable position,pos={408,36},size={107,15},proc=WMImLineProfileWidthSetVarProc,title="position"
	SetVariable position,help={"Center row or column."},format="%g"
	SetVariable position,value= root:Packages:WMImProcess:LineProfile:position
	Button checkpoint,pos={355,4},size={87,20},proc=WMImLineProfileCPButtonProc,title="Checkpoint"
	Button checkpoint,help={"Click to save and graph current profile."}
	Button remove,pos={446,4},size={69,20},proc=WMImLineProfileRemoveButtonProc,title="Remove"
	Button remove,help={"Removes profile lines (if any) from target image."}
	Button lineProfileHelpButt,pos={301,4},size={50,20},proc=lineProfileHelpProc,title="Help"
	Button startPathProfileButton,pos={4,34},size={130,20},proc=WMStartEditingPathProfile,title="Start Editing Path"
	Button startPathProfileButton,help={"After clicking in this button edit the path drawn on the top image.  Click in the Finished button when you are done."}
	Button finishPathProfileButton,pos={140,34},size={130,20},proc=WMFinishFHPathProfile,title="Finished Editing"
	Button finishPathProfileButton,help={"Click in this button to terminate the path editing mode."}
	CheckBox IPLCheck0,pos={183,7},size={86,14},title="Print Command",value= 0
	SetWindow kwTopWin,hook=WMImageLineProfileWindowProc

	WMImLineProfileModeProc("",1,"")

//	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
//	ModifyGraph/W=$imageGraphName offset(lineProfileY)={0,0}	
End

//*******************************************************************************************************
Function lineProfileHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic  "ImageLineProfile"
End

//*******************************************************************************************************
// Call after changing either position, width or profileMode
//  This creates the waves that are used with the lineProfile operation.
Function WMUpdatePositionAndWidth(initLines)
	Variable initLines																	// 17FEB03
	
	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	if(numType(width)==2)																// 30AUG11
		width=0
	endif
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	NVAR position= root:Packages:WMImProcess:LineProfile:position

	WAVE/Z w= $WMGetImageWave(imageGraphName)		// the target matrix
	WAVE/Z LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	WAVE/Z LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	WAVE/Z FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	WAVE/Z FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	
	if( (WaveExists(w)==0) %| (WaveExists(LineProfileY)==0) %| (WaveExists(LineProfileX)==0) %| (WaveExists(FHLineProfileX)==0)%| (WaveExists(FHLineProfileY)==0))
		return -1
	endif
	
	// 05JUN00 extract the actual min and max values displayed in the graph
	Variable xmin, ymin,xmax,ymax			
	GetAxis /W=$imageGraphName /Q left
	if(V_Flag==0)
		ymin=V_min
		ymax=V_max
	else
		 ymin=DimOffset(w,1)
		 ymax=ymin+DimSize(w,1)*DimDelta(w,1)
	endif
	
	GetAxis /W=$imageGraphName /Q top
	if(V_flag==0)
		xmin=V_min
		xmax=V_max
	else
		GetAxis /W=$imageGraphName /Q bottom
		if(V_Flag==0)
			xmin=V_min
			xmax=V_max
		else
			xmin=DimOffset(w,0)
			xmax=xmin+DimSize(w,0)*DimDelta(w,0)
		endif
	endif

	Variable w2=width/2
	if(w2<0)
		w2=0
	endif
	
	if( profileMode==1 )
		LineProfileY= {position+w2,position+w2,NaN,position-w2,position-w2}
		LineProfileX={-INF,INF,NaN,-INF,INF}
	else
		if( profileMode==2 )
			LineProfileX= {position+w2,position+w2,NaN,position-w2,position-w2}
			LineProfileY={-INF,INF,NaN,-INF,INF}
		else
			// for all other freehand modes hide the regular lines
			LineProfileX=NaN
			LineProfileY=NaN
			if(initLines)						// 17FEB03
				if(profileMode==3)				// FH Horizontal
					FHLineProfileX={xmin,xmax}
					ymin+=(ymax-ymin)/2
					FHLineProfileY={ymin,ymin}
				else
					if(profileMode==4)			// FH Vertical
						xmin+=(xmax-xmin)/2
						FHLineProfileX={xmin,xmin}
						FHLineProfileY={ymin,ymax}
					else
						if(profileMode==5)		// FreeHand
							xmin+=(xmax-xmin)/2
							FHLineProfileX={xmin,xmin}
							FHLineProfileY={ymin,ymax}
						endif
					endif
				endif
			else
 				 WMFHLineProfileDependency($"",$"") 			// 21FEB03 make it update the curves
			endif
		endif
	endif


	CheckDisplayed/W=$imageGraphName lineProfileY
	if(V_Flag==1)
		ModifyGraph/W=$imageGraphName offset(lineProfileY)={0,0}
	endif
		
	return 0
End

//*******************************************************************************************************
// have never seen this image plot before

Function WMImageLineProfileNew(newImageGraphName)			
	String newImageGraphName

	// 18OCT11 Check that the image is not displayed relative to aux waves:
	// This will put up a dialog when first activating or will print a warning in the history
	// because the alert is not supported when the hook function is active.
	String testXStr=stringbykey("XWAVE", imageinfo(newImageGraphName,"",0),":",";")
	String testYStr=stringbykey("YWAVE", imageinfo(newImageGraphName,"",0),":",";")
	if(strlen(testXStr)>0 || strlen(testYStr)>0)
		doAlert 0,"Line Profile does not work with images plotted against auxiliary waves."
		return 0
	endif
	
	WAVE/Z w= $WMGetImageWave(newImageGraphName)			// the target matrix
	if( !WaveExists(w) )
		return 0
	endif

	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR oldProfileMode= root:Packages:WMImProcess:LineProfile:oldProfileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	if(numType(width)==2)
		width=0
	endif
	
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	NVAR position= root:Packages:WMImProcess:LineProfile:position

	// store the final width and position
	if(strlen(imageGraphName)>0)
		NVAR WMLP_width= root:WinGlobals:$(imageGraphName):WMLP_width
		NVAR WMLP_pos= root:WinGlobals:$(imageGraphName):WMLP_pos
		NVAR WMLP_profileMode= root:WinGlobals:$(imageGraphName):WMLP_profileMode
		WMLP_pos=position
		WMLP_width=width
		WMLP_profileMode=profileMode
	endif
	
	String oldImageName=imageGraphName
	Variable newTarget
	imageGraphName= newImageGraphName						// this is also executed in the calling function.

	Variable newColor=isColorWave(w)							// check to see if the change requires new waves.
	if(newColor!=isColor)										// changing to a new image
		String oldDF=GetDataFolder(1)
		SetDataFolder root:Packages:WMImProcess:LineProfile
		if(newColor==0)
			Make/O profile
			RemoveFromGraph/z/w=WMImageLineProfileGraph profileR,profileG,profileB
			killWaves/Z profileR,profileG,profileB
		else
			RemoveFromGraph/z/w=WMImageLineProfileGraph profile
			Make/O profileR,profileG,profileB
			killwaves/z profile
		endif
		
		if(WinType(oldImageName)==1)						// 09JAN04 /Z does not work on bad graph name.
			RemoveFromGraph/Z/W=$oldImageName LineProfileY
		endif
		
		isColor=newColor
		WMImLineProfileModeProc("",1,"") 
		SetDataFolder oldDF
		newTarget=1
	else
		newTarget=0
	endif

	if(oldProfileMode!=profileMode)
		newTarget=1
		oldProfileMode=profileMode
	endif
	
	imageGraphName= newImageGraphName // WMImLineProfileModeProc makes it ""
	
	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:WinGlobals
	if(DataFolderExists(newImageGraphName )==0)	// if we need to build a new data folder
		NewDataFolder/O/S $newImageGraphName
		String/G S_TraceOffsetInfo= ""
		Variable/G WMLP_profileMode= profileMode
		Variable/G WMLP_width= width
		Variable/G WMLP_pos	=position			// center row or column of profile line
		Variable/G WMLP_checkpoint			// serial number incremented when user presses checkpoint button
	
		switch(profileMode)
			case 1:
				position=DimDelta(w,1)*DimSize(w,1)/2+Dimoffset(w,1);
			break
			
			case 2:
				position=DimDelta(w,0)*DimSize(w,0)/2+Dimoffset(w,0);
			break
			
			default:
				position=0
		endswitch
		
		WMLP_pos=position
	else										// this is a revisit, but we could have a new mode so check the boundaries on position.
		SetDataFolder $newImageGraphName
		NVAR LP_width= root:WinGlobals:$(newImageGraphName):WMLP_width
		NVAR LP_pos= root:WinGlobals:$(newImageGraphName):WMLP_pos
		NVAR LP_profileMode= root:WinGlobals:$(newImageGraphName):WMLP_profileMode
		width=LP_width
		if(numType(width)==2)				// 30AUG11
			width=0
		endif
		position=LP_pos
		profileMode=LP_profileMode
		
		// 05JUN00 extract the actual min and max values displayed in the graph
		Variable xmin, ymin,xmax,ymax,midx,midy			
		GetAxis /W=$imageGraphName /Q left
		if(V_Flag==0)
			ymin=V_min
			ymax=V_max
		else
			 ymin=DimOffset(w,1)
			 ymax=ymin+DimSize(w,1)*DimDelta(w,1)
		endif
		
		GetAxis /W=$imageGraphName /Q top
		if(V_flag==0)
			xmin=V_min
			xmax=V_max
		else
			GetAxis /W=$imageGraphName /Q bottom
			if(V_Flag==0)
				xmin=V_min
				xmax=V_max
			else
				xmin=DimOffset(w,0)
				xmax=xmin+DimSize(w,0)*DimDelta(w,0)
			endif
		endif
		
		midx=(xmin+xmax)/2
		midy=(ymin+ymax)/2
		
		// also, we need to check that the width does not exceed the range
		if(profileMode==1)
			if((position<ymin) || (position>ymax))
				position=midy
			endif
			if(width> abs(ymax-ymin))
				width=abs(ymax-ymin)/20											// arbitrary but reasonable 5%
			endif
		endif
		if(profileMode==2)
			if((position<xmin) || (position>xmax))
				position=midx
			endif
			if(width> abs(xmax-xmin))
				width=abs(xmax-xmin)/20											// arbitrary but reasonable 5%
			endif
		endif
		
	endif
	
	PopupMenu profileModePop mode=profileMode

	Make/O/D/N=5 LineProfileY,LineProfileX		// make the waves needed for the operation.
	Make/O/D FHLineProfileY,FHLineProfileX		// Freehand waves
	SetDataFolder $dfSav
	
	WMUpdatePositionAndWidth(1)				// 3

	RemoveFromGraph/W=$newImageGraphName/Z lineProfileY,FHLineProfileY
	String imax= StringByKey("AXISFLAGS",ImageInfo(newImageGraphName, NameOfWave(w), 0))+" "
	Execute "AppendToGraph/W="+newImageGraphName+" "+imax+GetWavesDataFolder(LineProfileY,2)+" vs "+GetWavesDataFolder(LineProfileX,2)
	ModifyGraph/W=$newImageGraphName rgb(lineProfileY)=(1,4,52428)
	ModifyGraph/W=$newImageGraphName quickdrag(lineProfileY)=1,live(lineProfileY)=1
	
	if(profileMode>2)
		Execute "AppendToGraph/W="+newImageGraphName+" "+imax+ GetWavesDataFolder(FHLineProfileY,2)+" vs "+GetWavesDataFolder(FHLineProfileX,2)
	endif

	S_TraceOffsetInfo=""	// make sure the following does nothing yet
	dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:LineProfile
	Variable/G lineProfileDummy
	SetFormula lineProfileDummy,"WMLineProfileDependency(root:WinGlobals:"+newImageGraphName+":S_TraceOffsetInfo)"
	SetDataFolder dfSav

	ModifyGraph/W=$newImageGraphName offset(lineProfileY)={0,0}			// This will fire the S_TraceOffsetInfo dependency
End
//*******************************************************************************************************
// we are revisiting this image plot and all the variables are assumed to exist
Function WMImageLineProfileUpdate(newImageGraphName)		
	String newImageGraphName

	Wave w= $WMGetImageWave(newImageGraphName)		// the target matrix

	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	NVAR position= root:Packages:WMImProcess:LineProfile:position
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	
	imageGraphName= newImageGraphName

	NVAR WMLP_profileMode= root:WinGlobals:$(imageGraphName):WMLP_profileMode
	NVAR WMLP_width= root:WinGlobals:$(imageGraphName):WMLP_width
	NVAR WMLP_pos= root:WinGlobals:$(imageGraphName):WMLP_pos
	SVAR S_TraceOffsetInfo= root:WinGlobals:$(imageGraphName):S_TraceOffsetInfo
	
	profileMode= WMLP_profileMode
	PopupMenu profileModePop, mode=profileMode

	width= WMLP_width
	if(numType(width)==2)						// 30AUG11
		width=0
	endif
	position= WMLP_pos
	
	WMUpdatePositionAndWidth(1)				// 4
	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	Wave LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	
	Variable xoff,yoff

	Variable w2=width/2
	if(w2<0)
		w2=0
	endif
		
	if( profileMode==1 )
		LineProfileY= {position+w2,position+w2,NaN,position-w2,position-w2}
		LineProfileX={-INF,INF,NaN,-INF,INF}
	else
		if( profileMode==2 )
			LineProfileX= {position+w2,position+w2,NaN,position-w2,position-w2}
			LineProfileY={-INF,INF,NaN,-INF,INF}
		endif
	endif
	
	S_TraceOffsetInfo=""	// make sure the following does nothing yet
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:LineProfile
	Variable/G lineProfileDummy
	SetFormula lineProfileDummy,"WMLineProfileDependency(root:WinGlobals:"+newImageGraphName+":S_TraceOffsetInfo)"
	SetDataFolder dfSav

	CheckDisplayed/W=$newImageGraphName lineProfileY
	if(V_Flag==1)
		ModifyGraph/W=$newImageGraphName offset(lineProfileY)={0,0}		// This will fire the S_TraceOffsetInfo dependency
	endif
End

//*******************************************************************************************************
// Fires on a dependency. s is S_TraceOffsetInfo from the quickdrag stuff
Function WMLineProfileDependency(s)
	String s

	if( StrSearch(s,"TNAME:LineProfileY;",0)<=0 )
		return 0
	endif

	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	NVAR position= root:Packages:WMImProcess:LineProfile:position
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:WMImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:WMImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:WMImProcess:LineProfile:profileB
	
	// remember current params for possible revisit
	NVAR WMLP_width=  root:WinGlobals:$(imageGraphName):WMLP_width
//	WMLP_width= width		// save for reactivate after visiting a different image plot
	NVAR WMLP_pos= root:WinGlobals:$(imageGraphName):WMLP_pos
//	WMLP_pos= position
	NVAR WMLP_profileMode= root:WinGlobals:$(imageGraphName):WMLP_profileMode
//	WMLP_profileMode= profileMode

	WAVE/Z w= $WMGetImageWave(imageGraphName)		// the target matrix

	if( WaveExists(w)==0 )
		return 0
	endif
	
	if(isColor)
		if(WaveExists(profileR)*WaveExists(profileG)*WaveExists(profileB)==0)
			return 0
		endif
	else
		if(WaveExists(profile)==0)
			return 0
		endif
	endif
	

	Variable pos	
	if( profileMode==1 )
		pos= NumberByKey("YOFFSET",s)
		//pos= (dy - DimOffset(w, 1))/DimDelta(w,1)
	else
		if( profileMode==2 )
			pos= NumberByKey("XOFFSET",s)
			//pos= (dx - DimOffset(w, 0))/DimDelta(w,0)
		endif
	endif
		  
	position+=pos
	WMDoLineProfile(w,pos,width,profileMode)
	WMUpdatePositionAndWidth(1)					// 5 update the wave for no offset.
	return 0
End
//*******************************************************************************************************
// given a matrix (wsrc), calculates a horizontal (columnwise) or vertical (rowwise)
// profile by averaging with rows or columns centered on pos
// wprofile is forced to double precision and with same scaling as given dimension of wsrc

Function WMDoLineProfile(wsrc,pos,width,profileMode)
	Wave wsrc
	Variable pos,width,profileMode
	
	Variable n,dim1=0,dim2=1
	WAVE/Z wprofile= root:Packages:WMImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:WMImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:WMImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:WMImProcess:LineProfile:profileB
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
			
	// horiz, vertical, fh-horiz, fh-vert, freehand
	if( (profileMode ==1) || (profileMode==3))
		dim1=1
		dim2=0
	endif

	n= DimSize(wsrc, dim2)
	
	if(isColor==0)
		Redimension/D/N=(n) wprofile
		SetScale/P x,DimOffset(wsrc, dim2),DimDelta(wsrc, dim2),WaveUnits(wsrc, dim2),wprofile
	else
		Redimension/D/N=(n) profileR,profileG,profileB
		SetScale/P x,DimOffset(wsrc, dim2),DimDelta(wsrc, dim2),WaveUnits(wsrc, dim2),profileR,profileG,profileB	
	endif
	
	NewDataFolder/O/S wmTmp
	Make/O/D/N=2 xWave,yWave

	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	Wave LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	
	// the ImageLineProfile operation works in pixels.  We therefore need to translate
	// between the values in the waves and true pixel numbers.
	Wave w= $WMGetImageWave(imageGraphName)

	Variable pmFlag=1							// 22OCT02
	Variable allowSliderControl=0				// 08JAN04
	Variable thePlane=0
	
	Variable treatAsGray=0						// 18DEC07
	NVAR/Z treatAsGrayFlag=root:Packages:WMImProcess:LineProfile:treatAsGrayFlag
	if(NVAR_Exists(treatAsGrayFlag))
		treatAsGray=treatAsGrayFlag
	endif
	
	if(DimSize(w,2)>4  || treatAsGray)			// 08JAN04; 18DEC07
			thePlane=WM_GetDisplayed3DPlane(imageGraphName)
			allowSliderControl=1
	endif
	
	String cmd
	variable wp	// 19JUL10 for reporting width later

	switch(profileMode)
		case 1:
			yWave=LineProfileY+pos	 
			yWave-=width/2					// 30OCT00 KD Correction
			// 24AUG01 yWave=(yWave-DimOffset(w,1))/DimDelta(w,1)  
			xWave={DimOffset(wsrc,dim2),DimOffset(wsrc,dim2)+DimDelta(wsrc,dim2)*DimSize(wsrc, dim2)}	// 24AUG01
			// 18JAN02 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width/2
			if(allowSliderControl==0)
				// 01NOV07 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
				// since the built-in op wants a width parameter in pixels
				// 29JAN08 added abs() around width
				wp=abs(width/DimDelta(wsrc,1))	
				ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=wp
				sprintf cmd,"ImageLineProfile srcWave=%s, xWave=%s, yWave=%s, width=%g",NameOfWave(wsrc),NameOfWave(xWave),NameOfWave(yWave),wp
			else
				// 01NOV07 ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
				// since the built-in op wants a width parameter in pixels
				// 29JAN08 added abs() around width
				wp=abs(width/DimDelta(wsrc,1))
				ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=wp	
				sprintf cmd,"ImageLineProfile/P=(%d) srcWave=%s, xWave=%s, yWave=%s, width=%g",thePlane,NameOfWave(wsrc),NameOfWave(xWave),NameOfWave(yWave),wp
			endif
		break
		
		case 2:
			xWave=LineProfileX+pos
			xWave-=width/2					// 30OCT00 KD Correction
			// 24AUG01 xWave=(xWave-DimOffset(w,0))/DimDelta(w,0)
			yWave={DimOffset(wsrc,dim2),DimOffset(wsrc,dim2)+DimDelta(wsrc,dim2)*DimSize(wsrc, dim2)}	// 24AUG01
			// 18JAN02 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width/2
			if(allowSliderControl==0)
				// 01NOV07 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
				// 29JAN08 added abs() around width
				wp=abs(width/DimDelta(wsrc,0))
				ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=wp
				sprintf cmd,"ImageLineProfile srcWave=%s, xWave=%s, yWave=%s, width=%g",NameOfWave(wsrc),NameOfWave(xWave),NameOfWave(yWave),wp
			else
				// 01NOV07 ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
				// 29JAN08 added abs() around width
				wp=abs(width/DimDelta(wsrc,0))
				ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=wp
				sprintf cmd,"ImageLineProfile/P=(%d) srcWave=%s, xWave=%s, yWave=%s, width=%g",thePlane,NameOfWave(wsrc),NameOfWave(xWave),NameOfWave(yWave),wp
			endif
		break

		
		default:	   // all the freehand modes
			pmFlag=0							// 22OCT02
			SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
			Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
			// 24AUG01 FHLineProfileY=(FHLineProfileY-DimOffset(w,1))/DimDelta(w,1)
			Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
			// 24AUG01 FHLineProfileX=(FHLineProfileX-DimOffset(w,0))/DimDelta(w,0)
			// 23OCT02 added /SC
			if(allowSliderControl==0)
				ImageLineProfile/SC srcWave=wsrc, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
				sprintf cmd,"ImageLineProfile/SC srcWave=%s, xWave=%s, yWave=%s, width=%g",NameOfWave(wsrc),NameOfWave(FHLineProfileX),NameOfWave(FHLineProfileY),width
			else
				ImageLineProfile/P=(thePlane) /SC srcWave=wsrc, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
				sprintf cmd,"ImageLineProfile/P=(%d) /SC srcWave=%s, xWave=%s, yWave=%s, width=%g",thePlane,NameOfWave(wsrc),NameOfWave(FHLineProfileX),NameOfWave(FHLineProfileY),width
			endif
			if(isColor)
				Wave M_ImageLineProfile
				profileR= M_ImageLineProfile[p][0]
				profileG= M_ImageLineProfile[p][1]
				profileB= M_ImageLineProfile[p][2]
			else
				Wave W_ImageLineProfile
				wprofile= W_ImageLineProfile
			endif
	endswitch

	if(pmFlag)							// 22OCT02
		if(isColor)
			Wave M_ImageLineProfile
			profileR= M_ImageLineProfile[p][0]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileR
			profileG= M_ImageLineProfile[p][1]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileG
			profileB= M_ImageLineProfile[p][2]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileB
		else
			Wave W_ImageLineProfile
			wprofile= W_ImageLineProfile
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", wprofile
		endif
	endif
	
	KillDataFolder :								// 21AUG01 uncommented this line
												// 09JAN04 remove possible error but report it in history.
	if (GetRTError(0))							// check if there was any runtime error.
		printf "Error in WMDoLineProfile:  %s\r", GetRTErrMessage()
		variable dummy=GetRTError(1)		// clear the error so there are no pesky alerts.
	endif
	
	ControlInfo/W=WMImageLineProfileGraph IPLCheck0
	if(V_Value)
		Print cmd
	endif

	return 0
End
//*******************************************************************************************************
Function WMImageLineProfileUpdateProc()
	String newImageGraphName= WMTopImageGraph()
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName

	if(CmpStr(newImageGraphName,imageGraphName)!= 0 )
		WMImageLineProfileNew(newImageGraphName)		
	endif
	imageGraphName= newImageGraphName
End
//*******************************************************************************************************

Function WMImageLineProfileWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0 )
		WMImageLineProfileUpdateProc()
		return 1
	endif
	if( StrSearch(infoStr,"EVENT:kill",0) >= 0 )				// 09JAN04 do some cleanup here:
			SVAR imageGraphName=root:Packages:WMImProcess:LineProfile:imageGraphName
			imageGraphName=""
			SetFormula root:Packages:WMImProcess:LineProfile:lineProfileDummy,""
			// if you want to automatically remove the blue lines when the window is closed, uncomment the next line.
			// WMImLineProfileRemoveButtonProc
		return 1
	endif
	return 0
End
//*******************************************************************************************************
	

// makes a permanent copy of the current profile, graphs (or appends)
// and sets the wave note to include info about the trace
// Adds a tag to trace with info about the trace (but the tag is often outside the graph)
//
Function WMImageLineProfileCheckpoint()

	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	NVAR position= root:Packages:WMImProcess:LineProfile:position
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	Wave/Z profile=root:Packages:WMImProcess:LineProfile:profile
	Wave/Z profileR=root:Packages:WMImProcess:LineProfile:profileR
	Wave/Z profileG=root:Packages:WMImProcess:LineProfile:profileG
	Wave/Z profileB=root:Packages:WMImProcess:LineProfile:profileB
	NVAR WMLP_checkpoint= root:WinGlobals:$(imageGraphName):WMLP_checkpoint
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	
	WMLP_checkpoint += 1							// start at 1

	WAVE/Z w= $WMGetImageWave(imageGraphName)			// the target matrix

	if( WaveExists(w)==0 )									// sanity check
		return 0
	endif
	
	if(!isColor)
		if(WaveExists(profile)==0)
			return 0
		endif
	else
		if(WaveExists(profileR)*WaveExists(profileG)*WaveExists(profileB)==0)
			return 0
		endif
	endif
	
	String profName= NameOfWave(w)+"_Prof"+num2str(WMLP_checkpoint)
	String cpGrfName= imageGraphName+"_Prof"
	
	String dfSav= GetDataFolder(1)
	SetDataFolder $GetWavesDataFolder(w,1)
	if(!isColor)
		Duplicate/O profile,$profName						// this might be just the red part in case of color.
	else	
		Duplicate/O profileR, $profName+"R"
		Duplicate/O profileG, $profName+"G"
		Duplicate/O profileB, $profName+"B"
		
		Wave wr=$profName+"R"
		Wave wg=$profName+"G"
		Wave wb=$profName+"B"
	endif

	if(profileMode>2)
		String profNamex=profName+"_x"
		if(profileMode==3)
			Wave W_LineProfileX=root:Packages:WMImProcess:LineProfile:W_LineProfileX
			Duplicate/O W_LineProfileX,$profNamex
		else
			if(profileMode==4)
				Wave W_LineProfileY=root:Packages:WMImProcess:LineProfile:W_LineProfileY
				Duplicate/O W_LineProfileY,$profNamex
			endif
		endif
	endif
		
	Wave/Z pw= $profName							// 21FEB03
	
	SetDataFolder dfSav
	
	String wnote
	sprintf wnote,"HORIZ:%d;WIDTH:%d;POSITION:%d;",profileMode,width,position
	if(!isColor)
		Note pw,wnote
	else
		Note wr,wnote
	endif

	// now prepare a note string suitable for a tag
	String dimName= ""
	String Sposition=""
	do
		if( profileMode==1 )
			dimName= "Column"
			sposition=num2str(position)
			break
		endif
		if( profileMode==2 )
			dimName= "Row"
			sposition=num2str(position)
			break
		endif
		if( profileMode==3 )
			dimName= "FH-Horizontal"
			break
		endif
		if( profileMode==4 )
			dimName= "FH-Vertical"
			break
		endif
		if( profileMode==5 )
			dimName= "FH"
			break
		endif
	while(0)

	Variable treatAsGray=0						// 18DEC07
	NVAR/Z treatAsGrayFlag=root:Packages:WMImProcess:LineProfile:treatAsGrayFlag
	if(NVAR_Exists(treatAsGrayFlag))
		treatAsGray=treatAsGrayFlag
	endif
	
	if(DimSize(w,2)>4  || treatAsGray)			// 08JAN04; 18DEC07
		Variable thePlane=WM_GetDisplayed3DPlane(imageGraphName)
		sprintf wnote,"profile #%d of %s. Layer=%d\r%s %s,width= %d",WMLP_checkpoint,NameOfWave(w),thePlane,dimName,Sposition,width
	else
		sprintf wnote,"profile #%d of %s.\r%s %s,width= %d",WMLP_checkpoint,NameOfWave(w),dimName,Sposition,width
	endif

	
	DoWindow/F $cpGrfName
	
	if(isColor)
		string greenName=profName+"G"
		string blueName=profName+"B"
	endif
	
	if(! V_Flag )
		if( (profileMode<3) %| (profileMode==5))
			if(!isColor)
				Display pw
			else
				Display wr,wg,wb
			endif
		else
			if(!isColor)
				Display pw vs $profNamex
			else
				Display wr,wg,wb vs $profNamex
			endif
		endif
		
		DoWindow/C $cpGrfName
		if(isColor)
			ModifyGraph/W=$cpGrfName  rgb($greenName)=(0,65535,0),rgb($blueName)=(0,0,65535)
		endif
	else
		if( (profileMode<3) %| (profileMode==5))
			if(!isColor)
				AppendToGraph pw
			else
				AppendToGraph wr,wg,wb
			endif
		else
			if(!isColor)
				AppendToGraph pw vs	$profNamex
			else
				AppendToGraph wr,wg,wb  vs$profNamex		
			endif
		endif
		if(isColor)
			ModifyGraph/W=$cpGrfName  rgb($greenName)=(0,65535,0),rgb($blueName)=(0,0,65535)
		endif
	endif
	
	if(!isColor)
		WaveStats/Q pw
		Tag/A=LB $profName,V_maxloc,wnote
	endif
End
//*******************************************************************************************************

Function WMImLineProfileModeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:LineProfile:profileMode=popNum	
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	NVAR oldProfileMode= root:Packages:WMImProcess:LineProfile:oldProfileMode
	
	oldProfileMode=-1		// to force an update even if  it is the same item
	
	if(strlen(imageGraphName)<=0)
		// this could happen after Remove
		WMImageLineProfileUpdateProc()
	endif
	
	NVAR WMLP_profileMode= root:WinGlobals:$(imageGraphName):WMLP_profileMode
	WMLP_profileMode= popNum

	WMUpdatePositionAndWidth(1)				// 1
	
	if(popNum>2)								// Freehand modes have an additional panel
		WMPrepareFHPathProfilePanel()		// must be done after the two lines above because they bring the image to the front
	else
		WMClearFHTraces()
	endif
	
	// now make sure the graph displays what we want
	String cdf=GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:LineProfile
	
	Wave/Z profile=root:Packages:WMImProcess:LineProfile:profile
	Wave/Z profileR=root:Packages:WMImProcess:LineProfile:profileR
	Wave/Z profileG=root:Packages:WMImProcess:LineProfile:profileG
	Wave/Z profileB=root:Packages:WMImProcess:LineProfile:profileB
	if(isColor==0)
		RemoveFromGraph/Z/W=WMImageLineProfileGraph/Z profile
	else
		RemoveFromGraph/Z/W=WMImageLineProfileGraph/Z profileR,profileG,profileB
	endif
	
	switch(popNum)
		case 1:
		case 2:
			if(isColor==0)
				AppendToGraph/W=WMImageLineProfileGraph profile
			else
				AppendToGraph/W=WMImageLineProfileGraph profileR,profileG,profileB			
				ModifyGraph/W=WMImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			break
		break
		
		case 3:
			if(WaveExists(W_LineProfileX)==0)
				Make/O/D/N=(DimSize($WMGetImageWave(imageGraphName) ,0)) W_LineProfileX=x
			endif
			if(isColor==0)
				AppendToGraph/W=WMImageLineProfileGraph profile vs W_LineProfileX
			else
				AppendToGraph/W=WMImageLineProfileGraph profileR,profileG,profileB vs W_LineProfileX		
				ModifyGraph/W=WMImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			DoWindow/F WMFHPathProfilePanel
		break
		
		case 4:
			if(WaveExists(W_LineProfileY)==0)
				Make/O/D/N=(DimSize($WMGetImageWave(imageGraphName) ,1)) W_LineProfileY=x
			endif
			if(isColor==0)
				AppendToGraph/W=WMImageLineProfileGraph profile vs W_LineProfileY
			else
				AppendToGraph/W=WMImageLineProfileGraph profileR,profileG,profileB vs W_LineProfileY		
				ModifyGraph/W=WMImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			DoWindow/F WMFHPathProfilePanel
		break
		
		case 5:
			if(isColor==0)
				AppendToGraph/W=WMImageLineProfileGraph profile
			else
				AppendToGraph/W=WMImageLineProfileGraph profileR,profileG,profileB			
				ModifyGraph/W=WMImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			
			if(exists("NewGizmo")!=4)									// make sure that Gizmo is around
				break
			endif
			
			if(WaveExists(W_LineProfileY)==0)
				Make/O/D/N=(numpnts(profile)) W_LineProfileY=x
			else
				Wave W_LineProfileY=W_LineProfileY
				Redimension/N=(numpnts(profile)) W_LineProfileY
			endif
			if(WaveExists(W_LineProfileX)==0)
				Make/O/D/N=(numpnts(profile)) W_LineProfileX=x
			else
				Wave W_LineProfileX=W_LineProfileX
				Redimension/N=(numpnts(profile)) W_LineProfileX
			endif
	
			// 14AUG06: replacing Surface Plotter with Gizmo
	
			WMLPFHupdate()
			
			// check to see if we have an open Gizmo:
			Variable namePos=-2
			Execute "GetGizmo GizmoNameList"
			SVAR/Z S_GizmoNames
			
			// check if it matches the unique name:
			if(SVAR_exists(S_GizmoNames) && strlen(S_GizmoNames)>0)
				namePos=strsearch(S_GizmoNames, "WMLineProfileGizmo",0)
			endif
			
			if(namePos<0)
				Execute "NewGizmo/N=WMLineProfileGizmo"
				Execute "AppendToGizmo Axes=boxAxes,name=axes0"
				Execute "ModifyGizmo ModifyObject=axes0,property={-1,axisScalingMode,1}"
				Execute "ModifyGizmo ModifyObject=axes0,property={-1,axisColor,0,0,0,1}"
				Execute "ModifyGizmo setDisplayList=0, object=axes0"

				if(isColor==0)		// Gray
					Execute "AppendToGizmo Path=root:Packages:WMImProcess:LineProfile:M_Triplet,name=path0"
					Execute "ModifyGizmo ModifyObject=path0 property={ pathColor,1,0,0,1}"
					Execute "ModifyGizmo setDisplayList=1, object=path0"
				else					// Color
					Wave/z wr=root:Packages:WMImProcess:LineProfile:M_TripletR
					if(WaveExists(wr))
						Execute "AppendToGizmo Path=root:Packages:WMImProcess:LineProfile:M_TripletR,name=pathR"
						Execute "AppendToGizmo Path=root:Packages:WMImProcess:LineProfile:M_TripletG,name=pathG"
						Execute "AppendToGizmo Path=root:Packages:WMImProcess:LineProfile:M_TripletB,name=pathB"
						Execute "ModifyGizmo ModifyObject=pathR property={ pathColorType,1}"
						Execute "ModifyGizmo ModifyObject=pathR property={ pathColor,1,0,0,1}"
						Execute "ModifyGizmo ModifyObject=pathG property={ pathColorType,1}"
						Execute "ModifyGizmo ModifyObject=pathG property={ pathColor,0,1,0,1}"
						Execute "ModifyGizmo ModifyObject=pathB property={ pathColorType,1}"
						Execute "ModifyGizmo ModifyObject=pathB property={ pathColor,0,0,1,1}"
						Execute "ModifyGizmo setDisplayList=1, object=pathR"
						Execute "ModifyGizmo setDisplayList=2, object=pathG"
						Execute "ModifyGizmo setDisplayList=3, object=pathB"
						Execute "ModifyGizmo SETQUATERNION={0.5,-0.1,-0.15,0.85}"
					endif
				endif
				Execute "ModifyGizmo showAxisCue=1"
			endif
			
			DoWindow/F WMFHPathProfilePanel
		break
	endswitch
	
	//	update the buttons depending on the mode
	if(popNum<3)
		WMupdateStartEndButtons(0)
	else
		WMupdateStartEndButtons(1)
	endif
	
	SetDataFolder cdf
End

//*******************************************************************************************************
// 14AUG06 added to build the triplet waves for Gizmo

Function WMLPFHupdate()
	
	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:LineProfile
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	if(isColor==0)
		Wave/Z W_LineProfileX,W_LineProfileY,profile
		if(WaveExists(W_LineProfileX))
			Concatenate/O {W_LineProfileX,W_LineProfileY,profile},M_Triplet
		endif
	else
		Wave/Z W_LineProfileX,W_LineProfileY,profileR,profileG,profileB
		if(WaveExists(W_LineProfileX) && WaveExists(profileR) && numpnts(W_LineProfileX)>0)
			Concatenate/O {W_LineProfileX,W_LineProfileY,profileR},M_TripletR
			Concatenate/O {W_LineProfileX,W_LineProfileY,profileG},M_TripletG
			Concatenate/O {W_LineProfileX,W_LineProfileY,profileB},M_TripletB
		endif
		Wave/Z wr=M_TripletR
		if(WaveExists(wr) && DimSize(wr,1)==3)
		else
			Make/O/N=(10,3) M_TripletR=0,M_TripletG=0,M_TripletB=0
		endif
	endif
	SetDataFolder curDF
End

//*******************************************************************************************************
Function WMImLineProfileWidthSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WMUpdatePositionAndWidth(0)		// 2
End
//*******************************************************************************************************

Function WMImLineProfileCPButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WMImageLineProfileCheckpoint()
End
//*******************************************************************************************************

Function WMImLineProfileRemoveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:WMImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:WMImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:WMImProcess:LineProfile:profileB
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	
	SetFormula root:Packages:WMImProcess:LineProfile:lineProfileDummy,""
	 
	 if(!isColor)
		profile= 0
	else
		profileR=0
		profileG=0
		profileB=0
	endif
	
	if(strlen(imageGraphName)>0)
		SetWindow kwTopWin,hook=$""
		DoWindow/F $imageGraphName
		RemoveFromGraph/Z LineProfileY,FHLineProfileY
		KillDataFolder root:WinGlobals:$(imageGraphName)
		DoWindow/F WMImageLineProfileGraph		// this be us
		DoUpdate									// don't let following fire
		SetWindow kwTopWin,hook=WMImageLineProfileWindowProc
		WMImageLineProfileWindowProc("EVENT:activate")
		imageGraphName= ""

		if(profileMode>2)
			WMupdateStartEndButtons(0)
		endif
		
		if(profileMode==5)
			WM_closeGizmo()						// 14AUG06
		endif
	else
		beep	// trying to remove something that does not exist.
	endif
End

//*******************************************************************************************************
Function WMPrepareFHPathProfilePanel()	

	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	Wave w= $WMGetImageWave(imageGraphName)	
	DoWindow/F $imageGraphName
	
	// before we try to append the waves to the image, check if they are not already there:
	CheckDisplayed/W=$imageGraphName FHLineProfileY
	if(V_Flag==0)
		String imax= StringByKey("AXISFLAGS",ImageInfo(imageGraphName, NameOfWave(w), 0))+" "
		Execute "AppendToGraph "+imax+ GetWavesDataFolder(FHLineProfileY,2)+" vs "+GetWavesDataFolder(FHLineProfileX,2)
	endif

	WMSetFHDependency()
End
//*******************************************************************************************************
Function WMSetFHDependency()
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	String cdf= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:LineProfile
	Variable/G lineProfileDummy
	String s="WMFHLineProfileDependency(root:WinGlobals:"+imageGraphName+":FHLineProfileY"+",root:WinGlobals:"+imageGraphName+":FHLineProfileX)"
	SetFormula lineProfileDummy,s
	SetDataFolder cdf
End
//*******************************************************************************************************
Function WMFinishFHPathProfile(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR curImageName= root:Packages:WMImProcess:LineProfile:imageGraphName
	String origImageName=StrVarOrDefault("root:Packages:WMImProcess:LineProfile:editingTarget",curImageName)
	
	if(strlen(origImageName)>0)
		DoWindow/F 	$origImageName
		GraphNormal
	endif
	SetFormula root:Packages:WMImProcess:LineProfile:lineProfileDummy,""
End
//*******************************************************************************************************

Function WMStartEditingPathProfile(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	String/G	root:Packages:WMImProcess:LineProfile:editingTarget=imageGraphName
	
	WMSetFHDependency()		// in case the user wants to re-edit
	DoWindow/F 	$imageGraphName

	// now check to see if this is a new image, in which case we need to append the wave
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	CheckDisplayed/W=$imageGraphName FHLineProfileY
	
	if(V_Flag==0)
		WMPrepareFHPathProfilePanel()
	endif
	
	GraphWaveEdit  FHLineProfileY
End

//*******************************************************************************************************
Function WMFHLineProfileDependency(ywave,xwave)
	wave/z ywave,xwave

	NVAR profileMode= root:Packages:WMImProcess:LineProfile:profileMode
	NVAR width= root:Packages:WMImProcess:LineProfile:width
	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	NewDataFolder/O/S WMtmp
	
	Wave src=$WMGetImageWave(imageGraphName)

	// 08JAN04
	Variable allowSliderControl=0
	Variable thePlane=0
	
	Variable treatAsGray=0						// 18DEC07
	NVAR/Z treatAsGrayFlag=root:Packages:WMImProcess:LineProfile:treatAsGrayFlag
	if(NVAR_Exists(treatAsGrayFlag))
		treatAsGray=treatAsGrayFlag
	endif
	
	if(DimSize(src,2)>4  || treatAsGray)			// 08JAN04; 18DEC07;16FEB10
		thePlane=WM_GetDisplayed3DPlane(imageGraphName)
		allowSliderControl=1
	endif
	
	String cmd
	// in case the horrid wave scaling is used.

	if(allowSliderControl==0)
		if(profileMode!=5)		// 23OCT02
			ImageLineProfile srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
			sprintf cmd,"ImageLineProfile srcWave=%s, xWave=%s, yWave=%s, width=%g",NameOFWave(src),NameOfWave(FHLineProfileX),NameOfWave(FHLineProfileY),width
		else
			if(WaveExists(FHLineProfileX))
				ImageLineProfile/SC srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
				sprintf cmd,"ImageLineProfile/SC srcWave=%s, xWave=%s, yWave=%s, width=%g",NameOFWave(src),NameOfWave(FHLineProfileX),NameOfWave(FHLineProfileY),width
			endif
			WMLPFHupdate()
		endif
	else							// 08JAN04
		if(profileMode!=5)	
			ImageLineProfile/P=(thePlane) srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
			cmd="ImageLineProfile/P=(thePlane) srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width"
		else
			ImageLineProfile/P=(thePlane)/SC srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
			cmd="ImageLineProfile/P=(thePlane)/SC srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width"
		endif
	endif
	
	ControlInfo/W=WMImageLineProfileGraph IPLCheck0
	if(V_Value)
		Print cmd
	endif
	
	
	
	// 23AUG01 KillWaves/Z tx,ty
	Wave tLineProfileX=W_LineProfileX			// 22OCT02
	Wave tLineProfileY=W_LineProfileY			// 22OCT02
	
	Duplicate/O W_LineProfileX,root:Packages:WMImProcess:LineProfile:W_LineProfileX
	Duplicate/O W_LineProfileY,root:Packages:WMImProcess:LineProfile:W_LineProfileY
	
	NVAR isColor=root:Packages:WMImProcess:LineProfile:isColor
	
	if(!isColor)
		Wave wout= W_ImageLineProfile
		Duplicate/O wout,root:Packages:WMImProcess:LineProfile:profile
	else
		Wave mw=M_ImageLineProfile
		String oldDF=GetDataFolder(1)
		SetDataFolder root:Packages:WMImProcess:LineProfile 
		Variable len=DimSize(mw,0)
		Make/O/N=(len) profileR,profileG,profileB
		profileR=mw[p][0]
		profileG=mw[p][1]
		profileB=mw[p][2]
		// 22OCT02
		if(profileMode==5)
//			Variable wSize=DimSize(profileR,0)
//			Make/O/N=(3*wSize+2) profile
//			// fill the three waves into a single path wave with NaN separation
//			WM_fillWaveWithThreeWaves(profile,profileR,profileG,profileB)
//			Wave W_LineProfileX=root:Packages:WMImProcess:LineProfile:W_LineProfileX
//			Wave W_LineProfileY=root:Packages:WMImProcess:LineProfile:W_LineProfileY
//			Wave/Z M_PathColorWave=root:Packages:WMImProcess:LineProfile:M_PathColorWave
//			WM_fillWaveWithThreeWaves(W_LineProfileX,tLineProfileX,tLineProfileX,tLineProfileX)
//			WM_fillWaveWithThreeWaves(W_LineProfileY,tLineProfileY,tLineProfileY,tLineProfileY)
//			if(WaveExists(M_PathColorWave)==0)
//				Make/O/N=(wSize,3) M_PathColorWave
//			endif
//			WM_MakeSurferPathColorWave(M_PathColorWave,wSize)
//			Execute "ModifySurfer pathRGBWave=M_PathColorWave"
		endif
		SetDataFolder oldDF
	endif
	
	if(profileMode==5)
	//	WAVE/Z profile= root:Packages:WMImProcess:LineProfile:profile
	//	profile+=0;		// just to make the surface plotter update if it is already open.
		WMLPFHupdate()						// 14AUG06 support for Gizmo.
		DoXOPIdle
	endif
	
	KillDataFolder :								// 15FEB02
	return 0
End

//*******************************************************************************************************
// Close the Gizmo window if we are packing up.
Function WM_closeGizmo()
	Execute "GetGizmo gizmoName"
	SVAR/Z S_GizmoName
	if(SVAR_Exists(S_GizmoName) && strlen(S_GizmoName)>0)
		DoWindow/K $S_GizmoName
	endif
End

//*******************************************************************************************************
Function WM_MakeSurferPathColorWave(M_PathColorWave,wSize)
	Wave M_PathColorWave
	Variable wSize
	
	Redimension/N=(3*wSize+2,3) M_PathColorWave
	Variable i,wSize1=wSize+1,wSize2=2*wSize+2

	M_PathColorWave=0
	
	for(i=0;i<wSize;i+=1)
		M_PathColorWave[i][0]=65535				// red
		M_PathColorWave[i+wSize1][1]=65535		// green
		M_PathColorWave[i+wSize2][2]=65535		// blue
	endfor
	
End
//*******************************************************************************************************
Function WM_fillWaveWithThreeWaves(w0,w1,w2,w3)
	Wave w0,w1,w2,w3
	
	Variable d1=DimSize(w1,0)
	Variable d2=DimSize(w2,0)
	Variable d3=DimSize(w3,0)
	Variable wSize=d1+d2+d3+2
	
	Redimension/N=(wSize) w0
	w0[0,d1]=w1[p]
	w0[d1]=NaN
	d1+=1
	w0[d1,d1+d2]=w2[p-d1]
	d1+=d2
	w0[d1]=NaN
	d1+=1
	w0[d1,d1+d3]=w3[p-d1]
End

//*******************************************************************************************************
Function WMupdateStartEndButtons(turnOn)
	Variable turnOn
	
	DoWindow/F WMImageLineProfileGraph		// make sure the buttons are on the right graph
	if(turnOn)
		Button startPathProfileButton,pos={4,34},size={130,20},proc=WMStartEditingPathProfile,title="Start Editing Path"
		Button startPathProfileButton,help={"After clicking in this button edit the path drawn on the top image.  Click in the Finished button when you are done."}
		Button finishPathProfileButton,pos={140,34},size={130,20},proc=WMFinishFHPathProfile,title="Finished Editing"
		Button finishPathProfileButton,help={"Click in this button to terminate the path editing mode."}
	else
		KillControl startPathProfileButton
		KillControl finishPathProfileButton
	Endif
End
//*******************************************************************************************************
Function WMClearFHTraces()

	SVAR imageGraphName= root:Packages:WMImProcess:LineProfile:imageGraphName
	DoWindow/F $imageGraphName
	RemoveFromGraph/Z  FHLineProfileY
	imageGraphName= ""						// vip to get initializations right
End
//*******************************************************************************************************
Function minWave(w,d)
	Wave w
	Variable d
	
	if(DimDelta(w,d)>0)
		return DimOffset(w,d)
	endif
	
	return DimOffset(w,d)+DimSize(w,d)*DimDelta(w,d)
End

//*******************************************************************************************************
Function maxWave(w,d)
	Wave w
	Variable d
	
	if(DimDelta(w,d)<0)
		return DimOffset(w,d)
	endif
	
	return DimOffset(w,d)+DimSize(w,d)*DimDelta(w,d)
End

Function printwaves(wa,wb)
	Wave wa,wb
	
	Variable i
	for(i=0;i<Dimsize(wa,0);i+=1)
		print wa[i],wb[i]
	endfor
End
//*******************************************************************************************************