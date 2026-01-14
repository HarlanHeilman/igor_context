#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>
 
// LH980206
// Image Particle Panel, version 0.9
// Requires Igor Pro 3.12 or later
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageParticlePanel()
// AG17JUN99
// Modified positions of buttons.
// AG17JUN99 Modified the update by calling the hook directly after panel creation.
// AG28MAY02 small bug fixes.
// AG01DEC03 added a redimension on the thresholded wave in case there is an ROI on an image that is not /B/U.


Function WMCreateImageParticlePanel()

	DoWindow/F ImageParticlePanel
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
	NewDataFolder/O/S root:Packages:WMImProcess:Particle
	
	if( NumVarOrDefault("inited",0) == 0 )
		Variable/G inited=1
		Variable/G threshMethod= 2	// memory for thresholding method. Manual and ImageThreshold Methods 1,2,4 and 5 or -1 for no thresholding
		Variable/G level= 128		// threshold level
		Variable/G printit= 0		// memory for print command checkbox
		Variable/G black= 0
		Variable/G zapHoles= 0		// truth we want to zap any holes in particles
		Variable/G fillParts= 0		// truth we want to fill the particle areas
		Variable/G labelParts= 0	// truth we want to label the particle areas
		variable/G excludeBoundaryParticles=0		// 08JUL09
		Variable/G ellipseParts= 0
		Variable/G Crosshair= 0
		Variable/G table= 0
		Variable/G sortby= 1		// see sortpop
		Variable/G sortdown= 1		// direction of sort
		Variable/G minArea= 5		//minimum pixels area for a particle
		
		String/G curImageName=""			// so we know when we have switched to a different image graph

		Variable/G thePartNum= NaN		// number of current particle
		Variable/G PartArea= NaN			// readout of area for current particle
		Variable/G PartPerimeter= NaN		// readout of perimeter for current particle
		Variable/G PartCircularity= NaN	// readout of circularity for current particle
		Variable/G PartRectangularity= NaN	// readout of rectangularity for current particle

		Make/O HairCursor={0,0,0,NaN,Inf,0,-Inf}
		Make/O HairCursorX={-Inf,0,Inf,NaN,0,0,0}
		Variable/G hairDummy				// used in a dependency
		Variable/G hairX=50,hairY=50		// position of the crosshair cursor
	endif

	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(igName)
	
	NewPanel /K=1 /W=(75,470,568,828) as "Image Particle Analysis"
	DoWindow/C ImageParticlePanel
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	Button DoIt,pos={360,285},size={80,20},proc=WMBPPartDoIt,title="Do It"
	CheckBox printit,pos={346,315},size={105,16},proc=WMImagePartCheckProc,title="Print command"
	CheckBox printit,help={"When checked, the Imagexxx command is printed to history."}
	CheckBox printit,fSize=12,value= 0
	Button buttonRemoveOverlay,pos={149,285},size={150,20},proc=WMImageParticleRemoveOverlay,title="Remove overlay"
	CheckBox zapHoles,pos={282,44},size={73,16},proc=WMImagePartCheckProc,title="Zap holes"
	CheckBox zapHoles,help={"Deletes holes in particles."},fSize=12,value= 0
	CheckBox AreaCheck,pos={20,111},size={70,16},proc=WMImagePartCheckProc,title="Fill Areas"
	CheckBox AreaCheck,help={"Fills in the area of a particle. Makes more visible but obscures structure."}
	CheckBox AreaCheck,fSize=12,value= 0
	CheckBox LabelCheck,pos={178,111},size={55,16},proc=WMImagePartCheckProc,title="Labels"
	CheckBox LabelCheck,help={"Labels each partice with its ID number."},fSize=12
	CheckBox LabelCheck,value= 0
	CheckBox EllipseCheck,pos={341,111},size={60,16},proc=WMImagePartCheckProc,title="Ellipses"
	CheckBox EllipseCheck,help={"Draws best fit ellipse for each particle."}
	CheckBox EllipseCheck,fSize=12,value= 0
	CheckBox TableCheck,pos={20,142},size={84,16},proc=WMImagePartCheckProc,title="Show Table"
	CheckBox TableCheck,help={"Display a table of measurements for each particle."}
	CheckBox TableCheck,fSize=12,value= 0
	PopupMenu sortpop,pos={284,137},size={159,20},proc=WMImagePartSortPopProc,title="Sort by:"
	PopupMenu sortpop,fSize=12
	PopupMenu sortpop,mode=5,popvalue="Rectangularity",value= #"\"Number;Area;Perimeter;Circularity;Rectangularity\""
	CheckBox SortDownCheck,pos={178,140},size={77,16},proc=WMImagePartCheckProc,title="Sort down"
	CheckBox SortDownCheck,help={"Sort from larger to smaller"},fSize=12,value= 1
	CheckBox Crosshair,pos={20,167},size={119,16},proc=WMImagePartCheckProc,title="Crosshair Identify"
	CheckBox Crosshair,help={"Puts Crosshair on image. Use to identify a specific object."}
	CheckBox Crosshair,fSize=12,value=0
	SetVariable minArea,pos={18,67},size={203,19},title="Minimum area (pixels):"
	SetVariable minArea,help={"Enter minimum area (in pixels) for a particle."}
	SetVariable minArea,fSize=12
	SetVariable minArea,limits={1,inf,1},value= root:Packages:WMImProcess:Particle:minArea
	PopupMenu thresh,pos={17,18},size={166,20},proc=WMImagePartThreshPopMenuProc,title="Thresholding:"
	PopupMenu thresh,fSize=12
	PopupMenu thresh,mode=2,popvalue="Iterated",value= #"\"User Level;Iterated;Bimodal fit;Fuzzy-Entropy;Fuzzy-Mean Gray\""
	CheckBox blackCheck,pos={282,19},size={95,16},proc=WMImagePartCheckProc,title="black objects"
	CheckBox blackCheck,help={"Check if your objects are black on a white background."}
	CheckBox blackCheck,fSize=12,value= 0
	Button particleHelpButt,pos={30,285},size={80,20},proc=particleHelpProc,title="Help"
	CheckBox ebpcCheck,pos={282,70},size={173,16},proc=WMImagePartCheckProc,title="Exclude boundary particles"
	CheckBox ebpcCheck,help={"Deletes holes in particles."},fSize=12,value= 0
	GroupBox group0,pos={10,100},size={458,164}
	GroupBox group1,pos={11,10},size={460,84}
	GroupBox group2,pos={11,273},size={459,72}
	
	SetWindow kwTopWin,hook=WMImagePartWindowProc
	WMImageUpdatePartPanel()
	doUpdate
	SetWindow kwTopWin,hook=WMImagePartWindowProc
	WMImagePartWindowProc("EVENT:activate")
end
	
Function particleHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic  "ImageAnalyzeParticles"
End

Function WMImagePartWindowProc(infoStr)
	String infoStr
	
	SVAR curImageName= root:Packages:WMImProcess:Particle:curImageName

	if( StrSearch(infoStr,"EVENT:activate",0) >=0 )
// see clipped out stuff
//		WMImagePartSwitch()
		WMImageUpdatePartPanel()
		WMImageUpdatePartTable()
		WMImageUpdatePartHair()
		return 1
	endif
	if( StrSearch(infoStr,"EVENT:kill;",0) > 0 )
		SetFormula root:Packages:WMImProcess:Particle:hairDummy,""
		curImageName= ""
		return 1
	endif
	return 0
end

Function WMImagePartCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if( CmpStr(ctrlName,"printit")==0 )
		Variable/G root:Packages:WMImProcess:Particle:printit= checked
	endif
	if( CmpStr(ctrlName,"blackCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:black= checked
	endif
	if( CmpStr(ctrlName,"zapHoles")==0 )
		Variable/G root:Packages:WMImProcess:Particle:zapHoles= checked
	endif
	if( cmpstr(ctrlName,"ebpcCheck")==0)
		Variable/G root:Packages:WMImProcess:Particle:excludeBoundaryParticles= checked
	endif
	if( CmpStr(ctrlName,"Crosshair")==0 )
		Variable/G root:Packages:WMImProcess:Particle:Crosshair= checked
		WMImageUpdatePartPanel()
		WMImageUpdatePartHair()
	endif
	if( CmpStr(ctrlName,"TableCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:table= checked
		WMImageUpdatePartTable()
	endif
	if( CmpStr(ctrlName,"SortDownCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:sortdown= checked
		WMImagePartSortTable()
	endif

	if( CmpStr(ctrlName,"AreaCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:fillParts= checked
		WMImageUpdatePartAnnotation()
	endif
	if( CmpStr(ctrlName,"LabelCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:labelParts= checked
		WMImageUpdatePartAnnotation()
	endif
	if( CmpStr(ctrlName,"EllipseCheck")==0 )
		Variable/G root:Packages:WMImProcess:Particle:ellipseParts= checked
		WMImageUpdatePartAnnotation()
	endif
End


Function WMImagePartThreshPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:Particle:threshMethod= popNum
	WMImageUpdatePartPanel()
End



Function WMImagePartSortPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:WMImProcess:Particle:sortby= popNum
	WMImagePartSortTable()
End

Function WMImagePartSortTable()
	NVAR sortby=  root:Packages:WMImProcess:Particle:sortby
	NVAR sortdown=  root:Packages:WMImProcess:Particle:sortdown


	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	// use the existance of one of the output waves as an indication that a measurement has taken place
	WAVE/Z warea= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj Area'")
	if( !WaveExists(warea) )
		return 0
	endif
	Wave wobjnum= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj number'")
	Wave wperim= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj Perimeter'")
	Wave wcirc= $(WMGetWaveAuxDFPath(w)+"Particles:Circularity")
	Wave wrect= $(WMGetWaveAuxDFPath(w)+"Particles:Rectangularity")
	
	Make/T/O WM_tmp={"'Obj number'","'Obj Area'","'Obj Perimeter'","Circularity","Rectangularity"}
	Wave sortkey= $(WMGetWaveAuxDFPath(w)+"Particles:"+WM_tmp[sortby-1])
	if( sortdown )
		Sort/R sortkey,wobjnum,warea,wperim,wcirc,wrect
	else
		Sort sortkey,wobjnum,warea,wperim,wcirc,wrect
	endif
	KillWaves WM_tmp
end



Function WMWaveIsBinary(w)
	Wave w
	
	if( WaveType(w) != 0x48 )				// must be unsiged byte
		return 0
	endif
	NewDataFolder/O/S WMWaveIsBinary
	Make/N=256 wtmp
	Histogram/B=2 w,wtmp
	Variable isBinary= wtmp[255]!=0		// must have vaues of 255...
	Variable got0= wtmp[0]!=0				//... and values of 0...
	wtmp[0]=0
	wtmp[64]=0
	wtmp[255]=0
	WaveStats/Q wtmp
	isBinary= isBinary %& got0 %& (V_sdev==0)	// ...and no other values except 64
	KillDataFolder :

	return isBinary
end

Function WMImageUpdatePartPanel()
	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		beep
		return 0
	endif
	
	Variable wantThresh= !WMWaveIsBinary(w)

	NVAR Crosshair=  root:Packages:WMImProcess:Particle:Crosshair
	Variable wantStats=Crosshair==1
	

	NVAR threshMethod= root:Packages:WMImProcess:Particle:threshMethod
	NVAR black= root:Packages:WMImProcess:Particle:black
	
	ControlInfo thresh
	Variable controlexists= V_Flag!=0
	if( wantThresh %& !controlexists )
		PopupMenu thresh,pos={23,12},size={182,19},proc=WMImagePartThreshPopMenuProc,title="Thresholding:"
		PopupMenu thresh,mode=threshMethod,value= #"\"User Level;Iterated;Bimodal fit;Fuzzy-Entropy;Fuzzy-Mean Gray\""
		CheckBox blackCheck,pos={327,12},size={125,20},proc=WMImagePartCheckProc,title="black objects"
		CheckBox blackCheck,help={"Check if your objects are black on a white background."},value=black
	endif
	if( !wantThresh %& controlexists )
		KillControl thresh
		KillControl blackCheck
	endif

	ControlInfo level
	controlexists= V_Flag!=0
	if( threshMethod!=1 )
		wantThresh= 0			// really means wantLevel
	endif
	if( wantThresh %& !controlexists )
		SetVariable level,pos={19,43},size={105,19},title="Level:"
		SetVariable level,help={"Enter level for threshold"},fSize=12
		SetVariable level,limits={0,255,1},value= root:Packages:WMImProcess:Particle:level
	endif
	if( !wantThresh %& controlexists )
		KillControl level
	endif

	ControlInfo PartArea
	controlexists= V_Flag!=0
	if( wantStats %& !controlexists )
		SetVariable PartArea,pos={68,214},size={114,19},title="Area:"
		SetVariable PartArea,help={"Readout of area of current particle."},fSize=12
		SetVariable PartArea,limits={inf,-inf,0},value= root:Packages:WMImProcess:Particle:PartArea
		SetVariable PartCircularity,pos={49,238},size={133,19},title="Circularity:"
		SetVariable PartCircularity,help={"Enter fraction  specifies the portion of the image pixels whose values are below the threshold."}
		SetVariable PartCircularity,fSize=12
		SetVariable PartCircularity,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:PartCircularity
		SetVariable PartRectangularity,pos={196,238},size={169,19},title="Rectangularity:"
		SetVariable PartRectangularity,help={"Enter fraction  specifies the portion of the image pixels whose values are below the threshold."}
		SetVariable PartRectangularity,fSize=12
		SetVariable PartRectangularity,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:PartRectangularity
		SetVariable PartPerimeter,pos={231,214},size={134,19},title="Perimeter:"
		SetVariable PartPerimeter,help={"Enter smoothing factor (noise reduction)."}
		SetVariable PartPerimeter,fSize=12
		SetVariable PartPerimeter,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:PartPerimeter
		SetVariable xsetvar,pos={201,189},size={75,19},proc=WMImagePartXSetVarProc,title="X:"
		SetVariable xsetvar,fSize=12
		SetVariable xsetvar,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:hairX
		SetVariable ysetvar,pos={291,189},size={75,19},proc=WMImagePartXSetVarProc,title="Y:"
		SetVariable ysetvar,fSize=12
		SetVariable ysetvar,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:hairY
		SetVariable curPart,pos={55,189},size={126,19},proc=WMImageCurPartSetVarProc,title="Particle:"
		SetVariable curPart,fSize=12
		SetVariable curPart,limits={-inf,inf,0},value= root:Packages:WMImProcess:Particle:thePartNum
	endif
	if( !wantStats %& controlexists )
		KillControl PartArea
		KillControl PartCircularity
		KillControl PartRectangularity
		KillControl PartPerimeter
		KillControl xsetvar
		KillControl ysetvar
		KillControl curPart
	endif

end


Function WMImageCurPartSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WMImagePartUpdateReadouts(varNum)
End


Function WMImagePartXSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR hairX=  root:Packages:WMImProcess:Particle:hairX
	NVAR hairY=  root:Packages:WMImProcess:Particle:hairY
	String ImGrfName= WMTopImageGraph()
	DoWindow/F $ImGrfName
	ModifyGraph offset(HairCursor)={hairX,hairY}		// This will fire the S_TraceOffsetInfo dependency
	DoWindow/F ImageParticlePanel
End


Function WMImageParticleRemoveOverlay(ctrlName) : ButtonControl
	String ctrlName

	// 28MAY02	removing the cross-hair when the overlay is removed.
	NVAR Crosshair=  root:Packages:WMImProcess:Particle:Crosshair
	Crosshair=0
	WMImageUpdatePartHair()
	
	String ImGrfName= WMTopImageGraph()
	String pw= WMGetImageWave(ImGrfName)
	WAVE/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif
	
	// one or the other of these are always displayed if we done the calcs and haven't yet removed overlay
	Wave/Z by= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryY")
	Wave/Z ey= $(WMGetWaveAuxDFPath(w)+"Particles:ellipseY")
	
	if( CmpStr(ctrlName,"buttonRemoveOverlay") == 0 )
		if(WaveExists(by))
			CheckDisplayed/W=$ImGrfName by
		endif
		
		Variable byDisp= V_Flag==1
		
		if(WaveExists(ey))
			CheckDisplayed/W=$ImGrfName ey
		endif
		
		if( V_Flag || byDisp )
			DoWindow/F $ImGrfName
			RemoveImage/Z M_Particle
			RemoveFromGraph/Z W_BoundaryY,hitPartY,HairCursor,W_SpotY,ellipseY
			DoWindow/F ImageParticlePanel
		endif
	endif
	
	// ??? should Remove Overlay zap the crosshair stuff ???
end


// Fires on a dependency. s is S_TraceOffsetInfo from the quickdrag stuff
Function WMImagePartDependency(s)
	String s

	String grfName= StringByKey("GRAPH",s)
	if( strlen(grfName)==0 )
		return 0
	endif

	NVAR hairX=  root:Packages:WMImProcess:Particle:hairX
	NVAR hairY=  root:Packages:WMImProcess:Particle:hairY

	hairX= NumberByKey("XOFFSET",s)
	hairY= NumberByKey("YOFFSET",s)
	
	WMBPPartMark(hairX,hairY)

	return 0
end


Function WMImageUpdatePartAnnotation()
	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	Variable isDisp,needDoWindow=0

	NVAR fillParts=  root:Packages:WMImProcess:Particle:fillParts
	NVAR labelParts=  root:Packages:WMImProcess:Particle:labelParts
	WAVE/Z mp= $(WMGetWaveAuxDFPath(w)+"Particles:M_Particle")
	WAVE/Z sy= $(WMGetWaveAuxDFPath(w)+"Particles:W_SpotY")
	WAVE/Z sx= $(WMGetWaveAuxDFPath(w)+"Particles:W_SpotX")
	WAVE/Z sc= $(WMGetWaveAuxDFPath(w)+"Particles:W_SpotCounter")
	
	WAVE/Z bx= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryX")
	WAVE/Z by= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryY")
	
	// ellipse stuff
	NVAR ellipseParts=  root:Packages:WMImProcess:Particle:ellipseParts
	WAVE/Z mw= $(WMGetWaveAuxDFPath(w)+"Particles:M_Moments")
	Wave/Z ey= $(WMGetWaveAuxDFPath(w)+"Particles:ellipseY")

	if(WaveExists(ey))
		CheckDisplayed/W=$ImGrfName ey
		isDisp= V_Flag!=0
	else
		isDisp=0
	endif
	
	if( (ellipseParts==0) %& isDisp )
		DoWindow/F $ImGrfName
		RemoveFromGraph/Z ellipseY
		needDoWindow= 1
	else
		if( ellipseParts %&  WaveExists(mw) )
			isDisp= WMImageDoPartEllipse(mw,w,ImGrfName)
			if( !isDisp )
				needDoWindow= 1
			endif
		endif
	endif
				
	
	if( WaveExists(mp) )
		CheckDisplayed/W=$ImGrfName mp
		isDisp= V_Flag!=0
		
		if( fillParts %& !isDisp )
			WMImageAppendOverlay(ImGrfName,w,mp)
			ModifyImage M_Particle,explicit=1,eval={16, 65535, 0, 0 },eval={18, 0, 65535, 0 }	// 16 is area, 18 is perim
			needDoWindow= 1
		endif
		if( !fillParts %& isDisp )
			DoWindow/F $ImGrfName
			RemoveImage/Z M_Particle
			needDoWindow= 1
		endif
	endif
	
	if( WaveExists(sy) )
		CheckDisplayed/W=$ImGrfName sy
		isDisp= V_Flag!=0

		if( labelParts %& !isDisp )
			WMImageAppendXYPair(ImGrfName,w,sy,sx)
			ModifyGraph mode(W_SpotY)=3, marker(W_SpotY)=19
			ModifyGraph textMarker(W_SpotY)={sc,"default",1,0,5,0,0}
			ModifyGraph msize(W_SpotY)=5,rgb(W_SpotY)=(2,39321,1)
			needDoWindow= 1
		endif
		if( !labelParts %& isDisp )
			DoWindow/F $ImGrfName
			RemoveFromGraph/Z W_SpotY
			needDoWindow= 1
		endif
	endif

	// Note: we do not show the boundary if the ellipse is requested - too confusing
	if( WaveExists(by) )
		CheckDisplayed/W=$ImGrfName by
		isDisp= V_Flag!=0

		if( (isDisp==0) %& (ellipseParts==0) )
			WMImageAppendXYPair(ImGrfName,w,by,bx)
			needDoWindow= 1
		endif
		if( (isDisp!=0) %& (ellipseParts!=0) )
			DoWindow/F $ImGrfName
			RemoveFromGraph/Z W_BoundaryY
			needDoWindow= 1
		endif
	endif

	if( needDoWindow )
		DoWindow/F ImageParticlePanel
	endif
end




Function WMImageUpdatePartHair()
	NVAR Crosshair=  root:Packages:WMImProcess:Particle:Crosshair
	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	Wave whair= root:Packages:WMImProcess:Particle:HairCursor
	Wave whairx= root:Packages:WMImProcess:Particle:HairCursorX
	
	if( Crosshair==0 )
		SetFormula root:Packages:WMImProcess:Particle:hairDummy,""
		if( WaveExists(w) )
			CheckDisplayed/W=$ImGrfName whair
			if( V_Flag )
				RemoveFromGraph/Z HairCursor,hitPartY
			endif
		endif
		return 0
	endif
	
	if( !WaveExists(w) )
		SetFormula root:Packages:WMImProcess:Particle:hairDummy,""
		return 0
	endif
	
	String theFormula= "WMImagePartDependency(root:WinGlobals:"+ImGrfName+":S_TraceOffsetInfo)"
	CheckDisplayed/W=$ImGrfName whair
	if( V_Flag )
		if( CmpStr(theFormula,GetFormula(root:Packages:WMImProcess:Particle:hairDummy)) != 0 )
			SetFormula root:Packages:WMImProcess:Particle:hairDummy,theFormula
		endif
		return 0			// Hair cursor was already displayed. At most we had to reset the formula
	endif

	// NOTE: Add /W=window flag to AppendToGraph,RemoveFromGraph, ModifyGraph
	// and then remove this DoWindow/F stuff
	// DoWindow/F $ImGrfName		// This is nasty because it may deactivate the particle panel in the middle of its activate
	WMImageAppendXYPair(ImGrfName,w,whair,whairx)
	ModifyGraph/W=$ImGrfName rgb(HairCursor)=(1,4,52428)
	ModifyGraph/W=$ImGrfName quickdrag(HairCursor)=1,live(HairCursor)=1

	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:WinGlobals
	NewDataFolder/O/S $ImGrfName
	String/G S_TraceOffsetInfo= ""
	SetDataFolder dfSav 
	
	NVAR hairX=  root:Packages:WMImProcess:Particle:hairX
	NVAR hairY=  root:Packages:WMImProcess:Particle:hairY
	
	GetAxis/Q/W=$ImGrfName top			// 05AUG09 added /Q
	if(V_flag!=0)
		GetAxis/W=$ImGrfName bottom
	endif
	
	if(hairX<V_min || hairX>V_max)
		hairX=(V_min+V_max)/2
	endif
	
	GetAxis/W=$ImGrfName left
	if(V_flag!=0)
		GetAxis/W=$ImGrfName right
	endif

	if(hairY<V_min || hairY>V_max)
		hairY=(V_min+V_max)/2
	endif

	SetFormula root:Packages:WMImProcess:Particle:hairDummy,theFormula

	ModifyGraph/W=$ImGrfName offset(HairCursor)={hairX,hairY}		// This will fire the S_TraceOffsetInfo dependency

	DoWindow/F ImageParticlePanel		
end

Function WMImageUpdatePartTable()
	DoWindow ImageParticleTable
	Variable tableExists= V_Flag
	NVAR table=  root:Packages:WMImProcess:Particle:table

	if( table==0 )
		if( tableExists )
			DoWindow/K ImageParticleTable
		endif
		return 0
	endif

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	
	if( !WaveExists(w) )
		if( tableExists )						// there was once an image graph but no longer...
			DoWindow/K ImageParticleTable	// ...so this should not exist
		endif
		return 0
	endif

	Wave/z wobjnum= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj number'")
	WAVE/Z warea= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj Area'")
	Wave/z wperim= $(WMGetWaveAuxDFPath(w)+"Particles:'Obj Perimeter'")
	Wave/z wcirc= $(WMGetWaveAuxDFPath(w)+"Particles:Circularity")
	Wave/z wrect= $(WMGetWaveAuxDFPath(w)+"Particles:Rectangularity")
	Wave/z wspotx= $(WMGetWaveAuxDFPath(w)+"Particles:W_Spotx")
	Wave/z wspoty= $(WMGetWaveAuxDFPath(w)+"Particles:W_Spoty")
	
	if( tableExists )
		if( !WaveExists(warea) )				// we have no data yet...
			DoWindow/K ImageParticleTable	// ...so this should not exist
			return 0
		endif
		CheckDisplayed/W=ImageParticleTable warea
		if( V_Flag )
			return 0							// already in table so do nothing
		endif
		// still here is table exists but no showing current data. Just kill are recreate
		DoWindow/K ImageParticleTable
	endif

	if( WaveExists(warea) )				// only if we have data
		Edit/K=2 wobjnum,warea,wperim,wcirc,wrect,wspotx,wspoty
		Execute "ModifyTable width(Point)=0"
		DoWindow/C ImageParticleTable
		AutoPositionWindow/E/M=1/R=ImageParticlePanel
		DoWindow/F ImageParticlePanel
	endif
end

Function WMBPPartDoIt(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		beep
		return 0
	endif
	
	String auxDF= WMGetWaveAuxDF(w)
	if( strlen(auxDF)==0 )
		return 0
	endif
	
	String dfSav= GetDataFolder(1)
	SetDataFolder auxDF
	
	NewDataFolder/O/S Particles		// put all particle related stuff here
	
	Variable doThresh= !WMWaveIsBinary(w)
	
	variable se= -1
	NVAR threshMethod= root:Packages:WMImProcess:Particle:threshMethod
	NVAR level= root:Packages:WMImProcess:Particle:level
	NVAR black= root:Packages:WMImProcess:Particle:black
	NVAR minArea= root:Packages:WMImProcess:Particle:minArea
	NVAR fillParts= root:Packages:WMImProcess:Particle:fillParts
	
	ImageGenerateROIMask/E=1/I=0/W=$ImGrfName $NameOfWave(w)
	Variable roiExists= V_Flag

	String options
	Variable threshParam=threshMethod-1
	if(threshParam==0)									// 14AUG00
		sprintf options, "/T=(%d)/Q",level
	else
		sprintf options, "/M=(%d)/Q",threshParam
	endif
	
	String command
	NVAR printit= root:Packages:WMImProcess:Particle:printit
	
	if( doThresh )
		if( roiExists )
			options += "/R=M_ROIMask"
		endif
		
		if( !black )
			options ="/I"+options
		endif
		
		command = "ImageThreshold"+ options + " "+GetWavesDataFolder(w,2)
		if( printit==1 )
			print command
		endif
		Execute command
		
		WAVE wthresh= M_ImageThresh
		Duplicate/O wthresh,root:M_ImageThresh				// 01FEB06
	else
		WAVE wthresh= w
	endif

	
	options="/E/W/Q/M=3"
	options += "/A="+num2str(minArea)
	if( roiExists )
		options += "/R=M_ROIMask"
	endif

	NVAR zapHoles=  root:Packages:WMImProcess:Particle:zapHoles
	if( zapHoles )
		options += "/F"
	endif
	
	NVAR excludeBoundaryParticles=root:Packages:WMImProcess:Particle:excludeBoundaryParticles		// 08JUL09
	if(excludeBoundaryParticles)
		options += "/EBPC"
	endif
	
	Redimension/B/U wthresh											// 01DEC03
	// 15NOV11
	// Check the number of layers here -- some people may try to operate on color or multi-layered image.
	if(DimSize(wthresh,2)>1)
		doAlert 0,"ImageAnalyzeParticles works on 2D images only."
		return 0
	endif
	
	command ="ImageAnalyzeParticles "+ options + " " + "stats" + ", "+GetWavesDataFolder(wthresh,2)
	if( printit==1 )
		print command
	endif
	Execute command
	Wave/Z W_ImageObjArea											// 15NOV11
	if(WaveExists(W_ImageObjArea)==0)
		doAlert 0,"ImageAnalyzeParticles failed to process the image."
		return 0
	endif
	
	Duplicate/O W_ImageObjArea,W_SpotCounter
	
	Wave W_spotX
	Wave W_spotY
	
	W_spotX=DimOffset(wthresh,0)+DimDelta(wthresh,0)*W_spotX		// 29JUN01 Account for wave scaling
	W_spotY=DimOffset(wthresh,1)+DimDelta(wthresh,1)*W_spotY
	
	W_SpotCounter= p

	// copies are made here so the names are better and so we can do sorting
	Duplicate/O W_ImageObjArea,'Obj Area','Obj number'
	Duplicate/O W_ImageObjPerimeter,'Obj Perimeter'
	Duplicate/O W_circularity,'Circularity'
	Duplicate/O W_rectangularity,'Rectangularity'
	Wave wobjnum= 'Obj number'
	wobjnum= p

	SetDataFolder dfSav

	WMImagePartSortTable()
	
	WMImageUpdatePartAnnotation()
End


Function WM_PointInPolys(x,y,wx,wy,windex)
	variable x,y
	Wave wx,wy,windex
	
	Make/O yHitTmp,xHitTmp,xTmp={x},yTmp={y}
	variable npart= numpnts(windex)-1
	Variable i=0,hitIt=0,maxIndex
	do
		if( i>=npart )		// 28MAY02 used to have >= which would not show the last particle.
			break
		elseif(i==npart-1)
			maxIndex=numPnts(wx)-1
		else
			maxIndex=windex[i+1]-2
		endif
		duplicate/O/R=[windex[i],maxIndex] wx,xHitTmp
		duplicate/O/R=[windex[i],maxIndex] wy,yHitTmp
		FindPointsInPoly xTmp,yTmp,xHitTmp,yHitTmp
		Wave win= W_inPoly
		hitit= win[0]
		KillWaves W_inPoly
		if( hitit )
			break
		endif
		i+=1
	while(1)
	
	KillWaves xTmp,yTmp,xHitTmp,yHitTmp
	
	if( hitit )
		return i
	else
		return -1
	endif
end
	
Function WMImageUpdateOnePart(ImGrfName,w,hitpart)
	String ImGrfName
	Wave w
	variable hitpart

	Wave/Z hit=$(WMGetWaveAuxDFPath(w)+"Particles:hitPartY")
	// CheckDisplayed/W=$ImGrfName $(WMGetWaveAuxDFPath(w)+"Particles:hitPartY")
	Variable isDisp=0
	if(WaveExists(hit))
		CheckDisplayed/W=$ImGrfName $(WMGetWaveAuxDFPath(w)+"Particles:hitPartY")
		isDisp= V_Flag!=0
	endif

	if( hitpart<0 )
		if( isDisp )
			DoWindow/F ImGrfName
			RemoveFromGraph/Z hitPartY
		endif
		return 0
	endif
	
	String dfSav= GetDataFolder(1)
	SetDataFolder $(WMGetWaveAuxDFPath(w)+"Particles:")

	Wave bx= W_BoundaryX
	Wave by= W_BoundaryY
	Wave bi= W_BoundaryIndex
	
	Make/O hitPartY,hitPartX
	Variable maxIndex=bi[hitpart+1]-2					// 27JUN07
	if(hitpart==numpnts(bi)-2)							// 27JUN07
		maxIndex=numpnts(bx)-2							// 27JUN07
	endif
	duplicate/O/R=[bi[hitpart],maxIndex] bx,hitPartX		// 27JUN07
	duplicate/O/R=[bi[hitpart],maxIndex] by,hitPartY		// 27JUN07

	SetDataFolder dfSav
	
	if(  !isDisp )
		WMImageAppendXYPair(ImGrfName,w,hitPartY,hitPartX)
		ModifyGraph lsize(hitPartY)=4,rgb(hitPartY)=(2,39321,1)
	endif
end


Function WMBPPartMark(xloc,yloc)
	Variable xloc,yloc

	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	WAVE/Z bx= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryX")
	Wave/Z by= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryY")
	Wave/Z bi= $(WMGetWaveAuxDFPath(w)+"Particles:W_BoundaryIndex")
	if( !WaveExists(bx) )
		return 0
	endif
	
	variable hitit= WM_PointInPolys(xloc,yloc,bx,by,bi)

	WMImagePartUpdateReadouts(hitit)
End

Function WMImagePartUpdateReadouts(partNum)
	Variable partNum
	
	String ImGrfName= WMTopImageGraph()
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	NVAR thePartNum= root:Packages:WMImProcess:Particle:thePartNum
	thePartNum= partNum

	WMImageUpdateOnePart(ImGrfName,w,partNum)

	// use the existance of one of the output waves as an indication that a measurement has taken place
	WAVE/Z warea= $(WMGetWaveAuxDFPath(w)+"Particles:W_ImageObjArea")
	if( !WaveExists(warea) )
		return 0
	endif
	Wave wperim= $(WMGetWaveAuxDFPath(w)+"Particles:W_ImageObjPerimeter")
	Wave wcirc= $(WMGetWaveAuxDFPath(w)+"Particles:W_circularity")
	Wave wrect= $(WMGetWaveAuxDFPath(w)+"Particles:W_rectangularity")

	NVAR PartArea= root:Packages:WMImProcess:Particle:PartArea
	NVAR PartPerimeter= root:Packages:WMImProcess:Particle:PartPerimeter
	NVAR PartCircularity= root:Packages:WMImProcess:Particle:PartCircularity
	NVAR PartRectangularity= root:Packages:WMImProcess:Particle:PartRectangularity

	if(partNum>=0)					// 27JUN07 was: if( NumType(partNum)==0 )
		PartArea= warea[partNum]
		PartPerimeter= wperim[partNum]
		PartCircularity= wcirc[partNum]
		PartRectangularity= wrect[partNum]
	else
		PartArea=NaN
		PartPerimeter= NaN
		PartCircularity= NaN
		PartRectangularity= NaN
	endif
End
	


// This could be general purpose but this file is the only application I can think of.
// assumes curMat is displayed as an image in the graph specified by winName
// XY pair is appended using the same axes. Does not honor multiple instances.
// Brings graph to the front. In future, when /W=win is supported, rewrite to avoid this effect.
Function WMImageAppendXYPair(winName,curMat,ywave,xwave)
	String winName
	Wave curMat,ywave,xwave
	
	DoWindow/F $winName
	if( V_Flag==0 )
		Abort "No graph named "+winName
	endif
	
	String info=ImageInfo("",NameOfWave(curMat),0)
	if( strlen(info)==0 )
		Abort "No image named "+NameOfWave(curMat)
	endif
	
	Execute "AppendToGraph"+StringByKey("AXISFLAGS",info)+" "+GetWavesDataFolder(ywave,2)+" vs "+GetWavesDataFolder(xwave,2)
end


Function WMMakeEllipse(wx,wy,cx,cy,major,minor,angle,NumPoints,counter)
	Wave wx,wy
	Variable cx,cy,major,minor,angle,NumPoints,counter
		
	Variable zk1,zk2,zk3,g11,g12,g22
	
	angle=-angle
	
	g11=(cos(angle)/major)^2+(sin(angle)/minor)^2
	g12=(1/(major*major)-1/(minor*minor))*sin(angle)*cos(angle)
	g22=(sin(angle)/major)^2+(cos(angle)/minor)^2
		
	Variable i=0,tmp,theta
	
	theta=0
	Variable dt=2*pi/(NumPoints-1)
	
	do
		theta=i*dt
		tmp=g11*cos(theta)^2+g12*sin(2*theta)+g22*sin(theta)^2
		if(tmp<0)
			print i
		endif
		tmp=1/tmp
		wy[counter+i]=cy+sqrt(tmp)*sin(theta)
		wx[counter+i]=cx+sqrt(tmp)*cos(theta)
		i+=1
	while(i<NumPoints)

End


// returns truth ellipse was already displayed
//
Function WMImageDoPartEllipse(mw,w,ImGrfName)
	Wave mw			// moments wave
	Wave w				// image wave
	String ImGrfName	// target image plot

	String dfSav= GetDataFolder(1)
	SetDataFolder $GetWavesDataFolder(mw,1)
	
	Variable numParticles=DimSize(mw,0)
	Variable index=0
	Variable counter=0
	
	Variable NumPoints=100			// for simplicity we use 100 points for each ellipse regardless of its size
	Make /O/N=((NumPoints+1)*numParticles)  ellipseX,ellipseY	// +1 for NaN separater
		
	SetDataFolder dfSav
	
	do
		WMMakeEllipse(ellipseX,ellipseY,mw[index][0],mw[index][1],mw[index][2],mw[index][3],mw[index][4],NumPoints,counter)
		index+=1
		counter+=NumPoints+1
		ellipseX[counter-1]=NaN
		ellipseY[counter-1]=NaN
	while(index<numParticles)

	CheckDisplayed/W=$ImGrfName ellipseY
	Variable wasDisp= V_Flag!=0

	// now correct for possible wave scaling in the image wave
	ellipseX=ellipseX*DimDelta(w,0)+DimOffset(w,0)
	ellipseY=ellipseY*DimDelta(w,1)+DimOffset(w,1)
	
	if( !wasDisp )
		WMImageAppendXYPair(ImGrfName,w,ellipseY,ellipseX)
	endif

	return wasDisp
end