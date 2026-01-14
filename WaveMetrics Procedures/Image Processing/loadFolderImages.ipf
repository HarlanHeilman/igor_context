#pragma rtGlobals=1		// Use modern global access method.
#pragma ModuleName=loadImages

//==================================================================
// 18MAY11 some updates


Static Function loadImagesInFolder()

	ControlInfo/W=loadFolderPanel fileTypeMenu
	String fileType=S_Value
	String suffix="????"
	strswitch(fileType)
		case "TIFF":
			suffix=".tif"
		break
		
		case "JPEG":
			suffix=".jpg"
		break
		
		case "PNG":
			suffix=".png"
		break
		
		case "BMP":
			suffix=".bmp"
		break
	endswitch
	
	String listAllFiles=indexedfile(diskFolderPath,-1,suffix)
	if(ItemsInList(listAllFiles)<=0)
		doAlert 0,"Could not find files of the specified type."
		return 0
	endif
	
	String fileName
	String waveStr,myStr
	Variable i=0,numImages=0
	Variable renameFlag
	Variable makeStackFlag
	
	ControlInfo/W=loadFolderPanel	RenameCheck
	renameFlag=V_Value
	
	ControlInfo/W=loadFolderPanel StackCheck
	makeStackFlag=V_Value
	
	if(makeStackFlag && renameFlag==0)
		doAlert 0,"Stacking requires that you rename loaded waves sequentially."
		return 0
	endif
	
	String firstWave
	ControlInfo/w=loadFolderPanel   RenameCheck
	Variable isRename=V_Value
	SVAR baseName=root:Packages:loadFolderPackage:baseName	// 18MAY11
	
	do
		fileName=StringFromList(i,listAllFiles)
		if(strlen(fileName)<=0)
			break
		endif
		ImageLoad/Q/P=diskFolderPath/T=$fileType fileName
		
		if(renameFlag)												// 18MAY11
			waveStr=StringFromList(0,S_waveNames)
			if(isRename)
				sprintf myStr,"%s%04d",baseName,i
			else
				sprintf myStr,"W_%04d",i
			endif
			Rename $waveStr,$myStr
			if(GetRTError(1))
				doAlert 0,"Please check that there are no name conflicts in the current data folder."
				return 0
			endif
			if(i==0)
				firstWave=myStr
			endif
		endif
		numImages+=1
		i+=1
	while(1)

	if(makeStackFlag)
		ControlInfo/W=loadFolderPanel killWavesCheck
		if(V_value==0)
			ImageTransform stackImages $firstWave
		else
			ImageTransform/K stackImages $firstWave
		endif
	endif
End

//==================================================================

Function loadFolderImagePanel()

	String curDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S loadFolderPackage
		String/G folderPath="_none_"
		String/G baseName="wave"
	SetDataFolder curDF

	DoWindow/F loadFolderPanel			// 18MAY11
	if(V_Flag)
		return 0
	endif
	NewPanel/K=1 /W=(522,44,902,261) as "Load Folder"
	DoWindow/C loadFolderPanel
	SetDrawLayer UserBack
	DrawText 31,65,"Folder Path:"
	Button SetFolderButton,pos={32,15},size={113,20},proc=loadImages#setFolderButtonProc,title="Set Folder"
	TitleBox title0,pos={112,48},size={162,20}
	TitleBox title0,variable= root:Packages:loadFolderPackage:folderPath
	Button loadImagesButton,pos={33,180},size={111,19},proc=loadImages#loadNowButtonProc,title="Load Now"
	PopupMenu fileTypeMenu,pos={34,75},size={102,20},title="File Type:"
	PopupMenu fileTypeMenu,mode=2,popvalue="JPEG",value= #"\"TIFF;JPEG;PNG;BMP\""
	CheckBox RenameCheck,pos={36,105},size={84,14},title="Rename Waves",value= 1
	SetVariable baseNameSetVar,pos={99,122},size={166,15},title="Base Name:"
	SetVariable baseNameSetVar,format="%g"
	SetVariable baseNameSetVar,value= root:Packages:loadFolderPackage:baseName
	CheckBox StackCheck,pos={97,145},size={69,14},title="Make Stack",value= 1
	CheckBox killWavesCheck,pos={176,145},size={111,14},title="Kill Individual Waves"
	CheckBox killWavesCheck,value= 0
	ModifyPanel fixedSize=1
End

//==================================================================

Static Function setFolderButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			NewPath/O/Q/M="Locate Disk Folder"  diskFolderPath
			SVAR folderPath=root:Packages:loadFolderPackage:folderPath
			if(V_flag==0)
				PathInfo diskFolderPath
				folderPath=S_path
			else
				folderPath="_none_"
			endif
		break
	endswitch

	return 0
End

//==================================================================

Static Function loadNowButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			loadImages#loadImagesInFolder()
		break
	endswitch

	return 0
End

//==================================================================
