#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=2		// Use modern global access method.
#pragma version=6.2		// shipped with Igor 6.2
#pragma IgorVersion=6.01	// Requires Igor 6.01 for ToCommandLine
#pragma independentModule=WMImageSaver

// Save Image Dialog
// 6/7/2010, version 6.2: Added /IGOR support, file name automatically follows selected wave name.
// 3/16/2007, version 6.01: Added /S (stack) support, made it into an independent module.
//				 Since Igor 6 can't paste to the command line from a procedure, To Cmd Line now uses the ToCommandLine operation. Requires Igor 6.01.
// 6/25/2003, version 5.0: removed use of SaveFloatingPointTIFF.ipf, in favor of new ImageSave/F options. Support for new 16-bit TIFF /U option. Renamed routines for consistentency.
// 6/25/2003, version 4.09: removed "command" showing up in command line.
// 6/2003, version 4.08: fixed resizing bug on Windows, problem with quality slider not being hidden, use SetVariable rather than titlebox for command,

Menu "Save Waves"
	"Save Image...",  WMSaveImagePanel()
End

Function WMSaveImagePanel()

	DoWindow/F WMSaveImagefilePanel
	if( V_Flag )
		return 0
	endif
	WMSaveImageInitGlobals()
	NewPanel/K=1/W=(36,76,505,419) as "Save Image File"
	DoWindow/C WMSaveImagefilePanel

	// file Types must preceed depth, because available depths depends on the image type.
	PopupMenu fileTypes,pos={19,160},size={108,20},proc=WMSaveImageFileTypePopProc,title="File Type"
	NVAR ftMenuItem= $WMSaveImageGlobal_Var("fileTypeMenuItem")
	PopupMenu fileTypes,mode=ftMenuItem,value=#GetIndependentModuleName()+"#WMSaveImageListOfFileTypes(2)"

	SVAR imagePath= $WMSaveImageGlobal_Var("imagePath")  	// do this before the radio check, else it gets overwritten
	String savedImagePath=imagePath
	PopupMenu images,pos={19,16},size={127,20},proc=WMSaveImagesPopMenuProc,title="Image"
	PopupMenu images,mode=1,value=#GetIndependentModuleName()+"#WMSaveImagePopupListOfImages()"
	CheckBox fromTarget,pos={47,47},size={113,14},proc=WMSaveImageTargetCheckProc,title="from target window"
	CheckBox fromTarget,value= 0,mode=1
	CheckBox fromAllGraphs,pos={47,65},size={94,14},proc=WMSaveImageTargetCheckProc,title="from all graphs"
	CheckBox fromAllGraphs,value= 0,mode=1
	CheckBox fromCurDF,pos={47,83},size={137,14},proc=WMSaveImageTargetCheckProc,title="from current data folder"
	CheckBox fromCurDF,value= 1,mode=1
	TitleBox imageinfo,pos={279,21},size={74,12},title="",frame=0
	TitleBox imageinfo,anchor= RT

	PopupMenu depth,pos={19,119},size={208,20},proc=WMSaveImageDepthPopMenuProc,title="Bit Depth"
	NVAR depthMenuItem= $WMSaveImageGlobal_Var("bitDepthMenuItem")
	PopupMenu depth,mode=depthMenuItem,value=#GetIndependentModuleName()+"#WMSaveImageBitDepths()"

	Slider quality,pos={146,147},size={218,45},fSize=9,proc=WMSaveImageQualitySliderProc
	Slider quality,limits={0,100,5},variable= root:Packages:SaveImagePanel:quality,side= 2,vert= 0,ticks= 10

	CheckBox stackCheckbox,pos={145,162},title="Stack",variable= $WMSaveImageGlobal_Var("stack")
	CheckBox stackCheckbox,proc=WMSaveImageInteractiveCheckProc
	
	CheckBox useIgorTIFFCheckbox,pos={290,162},title="Save Igor TIFF (not QuickTime TIFF)",variable= $WMSaveImageGlobal_Var("useIgorTIFF")
	CheckBox useIgorTIFFCheckbox,proc=WMSaveImageInteractiveCheckProc

	CheckBox unnormalized,pos={200,162},size={85,14},disable=1,title="Unnormalized"
	CheckBox unnormalized,value= 0, proc=WMSaveImageInteractiveCheckProc

	SetVariable fileName,pos={19,200},size={256,15},proc=WMSaveImageFileName,title="File Name"
	SetVariable fileName,value= root:Packages:SaveImagePanel:fileName

	PopupMenu path,pos={19,230},size={132,20},proc=WMSaveImagePathNamePopProc,title="Path Name"
	SVAR pn=$WMSaveImageGlobal_Var("pathName")
	Variable pnItem= max(1,1+WhichListItem(pn,PathList("*",";","")))
	String pathName=StringFromList(pnItem-1,PathList("*",";",""))
	PopupMenu path,mode=pnItem,popvalue=pathName,value= #"\"_none_;\"+PathList(\"*\",\";\",\"\")"

	CheckBox interactive,pos={290,223},size={102,14},proc=WMSaveImageInteractiveCheckProc,title="Force Interactive"
	CheckBox interactive,variable= $WMSaveImageGlobal_Var("interactive")

	CheckBox overwrite,pos={290,240},size={68,14},proc=WMSaveImageInteractiveCheckProc,title="Overwrite"
	CheckBox overwrite,variable= $WMSaveImageGlobal_Var("overwrite")

	GroupBox imageGroup,pos={1,105},size={464,3}

	Variable frameWidth=456, frameLeft= 9
	GroupBox commandframe,pos={frameLeft,262},size={frameWidth,40},labelBack=(65535,65535,65535)
	Variable margin=10
	SetVariable command,pos={frameLeft+margin,275},size={frameWidth-2*margin,12},frame=0, noEdit=1, labelBack=(65535,65535,65535)
	SetVariable command,variable= root:Packages:SaveImagePanel:command, title=" "

	Button toCmd,pos={108,315},size={99,20},proc=WMSaveImageButtonProc,title="To Cmd Line"
	Button doit,pos={22,315},size={60,20},proc=WMSaveImageButtonProc,title="Do It"
	Button cancel,pos={388,315},size={60,20},proc=WMSaveImageButtonProc,title="Cancel"
	Button toClip,pos={241,315},size={60,20},proc=WMSaveImageButtonProc,title="To Clip"

	SVAR rn= $WMSaveImageGlobal_Var("radioName")
	if( strlen(rn) )
		WMSaveImageTargetCheckProc(rn,1)	// overwrites  $WMSaveImageGlobal_Var("imagePath")
	endif
	if( strlen(savedImagePath) )
		WMSaveImageSetImageList(savedImagePath)
	else
		WMSaveImageRefillImageList()
	endif

	SetWindow kwTopWin,hook=WMSaveImagePanelResizeHook
	WMSaveImageGenerateCommand()
End

Function WMSaveImageInitGlobals()
	String df= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:SaveImagePanel
	String/G command
	String/G fileName
	Variable/G quality
	NVAR quality
	if( quality==0 )
		quality=100
	endif
	String/G imagePath		// SVAR imagePath= $WMSaveImageGlobal_Var("imagePath")
	String/G radioName		// SVAR rn= $WMSaveImageGlobal_Var("radioName")

	Variable/G bitDepthMenuItem	// NVAR depthMenuItem= $WMSaveImageGlobal_Var("bitDepthMenuItem")
	NVAR bitDepthMenuItem
	if( bitDepthMenuItem < 1 )
		bitDepthMenuItem= 1
	endif
	
	Variable/G fileTypeMenuItem	// NVAR ftMenuItem= $WMSaveImageGlobal_Var("fileTypeMenuItem")
	NVAR fileTypeMenuItem
	if( fileTypeMenuItem < 1 )
		fileTypeMenuItem= 1
	endif
	
	String/G pathName	// SVAR pn= $WMSaveImageGlobal_Var("pathName")
	Variable/G interactive	// NVAR interact= $WMSaveImageGlobal_Var("interactive")
	Variable/G overwrite	// NVAR over= $WMSaveImageGlobal_Var("overwrite")
	
	Variable/G stack		// NVAR stack= $WMSaveImageGlobal_Var("stack")
	Variable/G useIgorTIFF	// NVAR over= $WMSaveImageGlobal_Var("useIgorTIFF")
	
	SetDatafolder df
End

Function/S WMSaveImageGlobal_Var(varName)
	String varName
	
	return "root:Packages:SaveImagePanel:"+PossiblyQuoteName(varName)
End

Function WMSaveImagesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String/G $WMSaveImageGlobal_Var("imagePath")= popStr	// remember...
	Wave/Z image= $popStr
	WMSaveImagePanelWaveInfo(image)
	WMSaveImageSetBitDepthForImage(image)
	String/G $WMSaveImageGlobal_Var("fileName")= popStr
	WMSaveImageSetFileTypeForDepth(0)	// this will append the extension.
	WMSaveImageGenerateCommand()
End


Function WMSaveImageDisableButtons(disable)
	Variable disable
	
	ControlInfo/W=WMSaveImagefilePanel doit
	if( V_disable != disable )		// avoid flashing by checking the disable state
		Button doit win=WMSaveImagefilePanel, disable=disable
	endif
	ControlInfo/W=WMSaveImagefilePanel toCmd
	if( V_disable != disable )
		Button toCmd win=WMSaveImagefilePanel, disable=disable
	endif
	ControlInfo/W=WMSaveImagefilePanel toClip
	if( V_disable != disable )
		Button toClip win=WMSaveImagefilePanel, disable=disable
	endif
End

// this also shows and hides or disables controls as needed
Function WMSaveImageGenerateCommand()

	String/G $WMSaveImageGlobal_Var("command")
	SVAR cmd=$WMSaveImageGlobal_Var("command")
	
	ControlInfo/W=WMSaveImagefilePanel images
	String pathToWave= S_Value
	Wave/Z image= $pathToWave
	if( !WaveExists(image) )
		cmd= "*** select an image ***"
		WMSaveImageDisableButtons(2)	// disable
		return 0
	endif
	
	// as "<file name>"
	
	SVAR fileName=$WMSaveImageGlobal_Var("fileName")
	Variable isMacintosh= strsearch(IgorInfo(2),"Macintosh",0) >= 0
	if( isMacintosh )	// limit file name to 31 chars
		if( strlen(fileName) > 31 )
			cmd= "*** file name is longer than 31 characters ***"
			SetVariable fileName, win=WMSaveImagefilePanel, activate
			WMSaveImageDisableButtons(2)	// disable
			return 0
		endif
	endif

	ControlInfo/W=WMSaveImagefilePanel path
	String pathName= S_Value

	Variable depth= WMSaveImageGetDepthBitsFromItem(0) 	// 0 means get the menu item from the control
	Variable saveAsFloat32 = depth==64	// 64 is a bogus depth meaning "TIFF Float"

	cmd="ImageSave"
	// Overwrite
	ControlInfo/W=WMSaveImagefilePanel overwrite
	if( V_Value )
		cmd += "/O"
	endif
	
	// Interactive
	ControlInfo/W=WMSaveImagefilePanel interactive
	if( V_Value )
		cmd += "/I"
	endif
	
// Depth
	if( saveAsFloat32 )
		cmd += "/F"	// /F is new to Igor 5.
	else
		cmd += "/D="+num2istr(depth)
	endif
	// Type
	ControlInfo/W=WMSaveImagefilePanel fileTypes
	Variable index= WMSaveImageIndexFromDescription(S_Value)	// 0-based
	String type= StringFromList(index,WMSaveImageListOfFileTypes(1))
	cmd += "/T=\"" + type+"\""
	
	// Path
	if( CmpStr(pathName,"_none_") != 0 )
		cmd +="/P="+pathName
	endif
	
	// Quality /100
	if( CmpStr(type,"JPEG") == 0 )
		ControlInfo/W=WMSaveImagefilePanel quality
		String qual
		sprintf qual, "/Q=%.2f", V_Value/100		// 1 is 100%
		cmd +=qual
	endif
	
	// /U=unnormalized
	if( CmpStr(type,"TIFF") == 0 && depth == 16 )
		ControlInfo/W=WMSaveImagefilePanel unnormalized
		if( V_Value )
			cmd +="/U"
		endif
	endif

	// /S
	Variable dimensions= WaveDims(image)
	Variable isTIFF= CmpStr(type,"TIFF") == 0
	Variable canStack= isTIFF && (dimensions >=3)
	if( canStack )
		ControlInfo/W=WMSaveImagefilePanel stackCheckbox
		if( V_Value )
			cmd +="/S"
		endif
	endif
	
	// /IGOR
	if( isTIFF )
		ControlInfo/W=WMSaveImagefilePanel useIgorTIFFCheckbox
		if( V_Value )
			cmd +="/IGOR"
		endif
	endif

	// wave path
	cmd +=" "+GetWavesDataFolder(image,4)
	
	// optional file
	if( strlen(fileName) )
		cmd += " as \""+fileName+"\""
	endif

	WMSaveImageDisableButtons(0)
End

Function WMSaveImageQualitySliderProc(name, value, event)
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, 
				//   2: mouse up, 3: mouse moved
	
	if( event & 0x4 )	// value set
		WMSaveImageGenerateCommand()
	endif
	return 0	// other return values reserved
End


Function WMSaveImagePanelWaveInfo(image)
	Wave/Z image
	
	String title=""
	if( WaveExists(image) )
		Variable waveIsComplex = WaveType(image) & 0x01
		Variable waveIs32BitFloat = WaveType(image) & 0x02
		Variable waveIs64BitFloat = WaveType(image) & 0x04
		Variable waveIs8BitInteger = WaveType(image) & 0x08
		Variable waveIs16BitInteger = WaveType(image) & 0x10
		Variable waveIs32BitInteger = WaveType(image) & 0x20
		Variable waveIsUnsigned = WaveType(image) & 0x40
		String integerType="I"
		if( waveIsUnsigned )
			integerType="U"
		endif
		if( waveIs32BitFloat )
			title="FP32"
		elseif( waveIs64BitFloat)
			title="FP64"
		elseif( waveIs8BitInteger )
			title= integerType+"8"
		elseif( waveIs16BitInteger )
			title= integerType+"16"
		elseif( waveIs32BitInteger )
			title= integerType+"32"
		endif
		title += " "
		if( DimSize(image,1) == 0 )	// 1-d
			title += num2istr(numpnts(image))+" points"
		else // multi-dimensional
			title += "("
			Variable dim
			for( dim=0; dim < 3; dim += 1 )
				Variable size= DimSize(image,dim)
				if( size == 0 )
					break
				endif
				title +=  num2istr(size)+","
			endfor
		
			title = title[0,strlen(title)-2] + ")"
		endif
	endif
	titlebox imageinfo, win=WMSaveImagefilePanel, title=title
End

Function WMSaveImageSetBitDepthForImage(image)
	Wave/Z image
	
	if( WaveExists(image) )
		Variable waveIs32BitFloat = WaveType(image) & 0x02
		Variable waveIs16BitInteger = WaveType(image) & 0x10
		Variable waveIs8BitInteger = WaveType(image) & 0x08
		Variable waveIsRGB= waveIs8BitInteger && DimSize(image,2) == 3
		Variable waveIsGrayscale= DimSize(image,2) == 0
		PopupMenu depth, win= WMSaveImagefilePanel, disable=0	// show
		ControlInfo/W=WMSaveImagefilePanel depth
		if( waveIs32BitFloat )
			PopupMenu fileTypes, win= WMSaveImagefilePanel, mode=9	//  9= TIFF
			Variable/G $WMSaveImageGlobal_Var("fileTypeMenuItem")=9

			PopupMenu depth, win= WMSaveImagefilePanel, mode=7	// 7 = floatingpoint
			Variable/G $WMSaveImageGlobal_Var("bitDepthMenuItem")=7
		else
			if( waveIsRGB )
				PopupMenu depth, win= WMSaveImagefilePanel, mode=5			// 5= 24 bit rgb
				Variable/G $WMSaveImageGlobal_Var("bitDepthMenuItem")=5
			elseif( waveIs16BitInteger )
				PopupMenu fileTypes, win= WMSaveImagefilePanel, mode=9	//  9= TIFF
				Variable/G $WMSaveImageGlobal_Var("fileTypeMenuItem")=9

				PopupMenu depth, win= WMSaveImagefilePanel, mode=4			// 4=16-bits
				Variable/G $WMSaveImageGlobal_Var("bitDepthMenuItem")=4
			elseif( waveIs8BitInteger )
				if( waveIsGrayscale )
					PopupMenu depth, win= WMSaveImagefilePanel, mode=3	// 3=8-bit grayscale TIFF
					Variable/G $WMSaveImageGlobal_Var("bitDepthMenuItem")=3
				else
					PopupMenu depth, win= WMSaveImagefilePanel, mode=2	// 2=8-bit with color table TIFF
					Variable/G $WMSaveImageGlobal_Var("bitDepthMenuItem")=2
				endif
			endif
		endif
	else
		PopupMenu depth, win= WMSaveImagefilePanel, disable=2 // disable
	endif
End

//  sets preferred (not required) file type for the given depth
// returns file type popNum
Function WMSaveImageSetFileTypeForDepth(depthMenuItemNo)
	Variable depthMenuItemNo	// 0 to get the menu item from the control
	
	Variable depth=WMSaveImageGetDepthBitsFromItem(depthMenuItemNo)
	Variable popNum
	if (depth==64 )
		popNum= 9 // TIFF
		PopupMenu fileTypes, win= WMSaveImagefilePanel, mode=popNum
		Variable/G $WMSaveImageGlobal_Var("fileTypeMenuItem")=popNum
		WMSaveImageFixFileNameExt(popNum)
		WMSaveImageShowHideOptions("TIFF")
	else
		ControlInfo/W=WMSaveImagefilePanel fileTypes
		popNum= V_Value
		String description= S_value
		WMSaveImageFixFileNameExt(popNum)
		WMSaveImageShowHideOptions(description)
	endif
	return popNum
End

//returns ImageSave/D value
Function WMSaveImageGetDepthBitsFromItem(depthMenuItemNo)
	Variable depthMenuItemNo	// 0 to get the menu item from the control
	
	Variable depth=8	// generic default
	if( depthMenuItemNo < 1 )
		ControlInfo/W=WMSaveImagefilePanel depth	// "1 bit;8 bit with color lookup;8 bit grayscale;16 bit;24 bit (explicit RGB);32-bit (rgb+alpha), Single precision Floating point;"
		depthMenuItemNo=V_Value 
	endif	
	switch(depthMenuItemNo)
		case 1:
			depth=1	// black and white
			break
		case 2:
			depth=8	// 8 bit with color lookup. (for example, when saving RGB as 8-bit image).
			break
		case 3:
			depth=40	// special code meaning 8-bit grayscale
			break
		case 4:
			depth=16	// usually only TIFF can do this.
			break
		case 5:
			depth=24	// for rgb
			break
		case 6:
			depth=32	// rgb+alpha
			break
		case 7:
			depth=64	// fake value to clue in other routine that this is float or double as float, this item needs to be disabled if the type isnt TIFF.
			break
	endswitch
	return depth
End

Function WMSaveImageLimitBitDepthForType(fileTypeMenuItemNo)
	Variable fileTypeMenuItemNo	//	WMSaveImageListOfFileTypes(2)
	
	String fileType=StringFromList(fileTypeMenuItemNo-1,WMSaveImageListOfFileTypes(1))
	if( CmpStr(fileType,"TIFF") == 0 )
		// enable float bit depth
	else
		// disable float bit depth
		// if bit depth selection of "Single precision" force a choice of something else.
		ControlInfo/W=WMSaveImagefilePanel depth	// "1 bit;8 bit with color lookup;8 bit grayscale;16 bit;24 bit (explicit RGB);32-bit (rgb+alpha), Single precision Floating point;"
		Variable depthMenuItemNo=V_Value 
		if( depthMenuItemNo == 7 )// single-precision
			NVAR depthMenuItem= $WMSaveImageGlobal_Var("bitDepthMenuItem")
			depthMenuItem= 2 // 8 bit with color lookup.
			PopupMenu depth, win=WMSaveImagefilePanel, mode=depthMenuItem
		endif
	endif
	ControlUpdate/W=WMSaveImagefilePanel depth
End

Function/S WMSaveImageBitDepths()

	String depths=""
	ControlInfo/W=WMSaveImagefilePanel fileTypes	// "1 bit;8 bit with color lookup;8 bit grayscale;16 bit;24 bit (explicit RGB);32-bit (rgb+alpha), Single precision Floating point;"
	Variable index= WMSaveImageIndexFromDescription(S_Value)	// 0-based
	String fileType= StringFromList(index,WMSaveImageListOfFileTypes(1))
	if( CmpStr(fileType,"TIFF") == 0 )
		// enabled float bit depth
		depths= "1 bit;8 bit with color lookup;8 bit grayscale;16 bit;24 bit (explicit RGB);32 bit (explicit RGB+alpha);Single precision floating point;"
	else
		// return disabled float bit depth
		depths= "1 bit;8 bit with color lookup;8 bit grayscale;16 bit;24 bit (explicit RGB);32 bit (explicit RGB+alpha);\\M1:0:(Single precision floating point;"
	endif
	return depths
End

Function/S WMSaveImageRadioChecked()

	DoWindow WMSaveImagefilePanel
	if( V_Flag )
		ControlInfo/W=WMSaveImagefilePanel fromTarget
		if( V_Value )
			return "fromTarget"
		endif
	
		ControlInfo/W=WMSaveImagefilePanel fromAllGraphs
		if( V_Value )
			return "fromAllGraphs"
		endif
	
		ControlInfo/W=WMSaveImagefilePanel fromCurDF
		if( V_Value )
			return "fromCurDF"
		endif
	endif

	return ""
End

Function/S WMSaveImageRemoveDupsFromList(list)
	String list
	
	String cleanedList=""
	Variable i, n= ItemsInList(list)
	for( i=0; i < n; i+= 1 )
		String item= StringfromList(i,list)
		if( FindListItem(item,cleanedList) < 0 )	// not a duplicate
			cleanedList += item+";"
		endif	
	endfor
	
	return cleanedList
End

Function/S WMSaveImagePopupListOfImages()
	
	String images="", waves=""
	String ctrlName=WMSaveImageRadioChecked()
	strswitch( ctrlName )
		case "fromTarget":
			waves= WMSaveImagePathsFromWindows(WinName(0,3))
			break
		case "fromAllGraphs":
			waves= WMSaveImagePathsFromWindows(WinList("*",";","WIN:1"))
			break
		case "fromCurDF":
			waves= WaveList("*",";","")
			break
	endswitch	
	 images= WMSaveImageRemoveDupsFromList(SortList(WMSaveImageKeepOnlyImages(waves),";",8))
	 if( strlen(images) == 0 )
	 	images= "_none_"
	 endif
	return images
End

Function/S WMSaveImageKeepOnlyImages(listOfWavePaths)
	String listOfWavePaths
	
	String listOfImagePaths=""
	Variable i=0
	do
		String path= StringFromList(i,listOfWavePaths)
		if( strlen(path) == 0 )
			break
		endif
		WAVE/Z image= $path
		if( WaveExists(image) )
			if( DimSize(image,1) > 0 )
				Variable waveIsComplex = WaveType(image) & 0x01
//				Variable waveIs64BitFloat = WaveType(image) & 0x04
				Variable waveIsText = WaveType(image) == 0
				if( !waveIsComplex && !waveIsText )
					listOfImagePaths += path + ";"
				endif
			endif		
		endif
		i += 1
	while(1)
	
	return listOfImagePaths
End

Function/S WMSaveImagePathsFromWindows(listOfWindowNames)
	String listOfWindowNames
	
	String listOfWavePaths=""
	
	Variable i=0, type
	do
		String win= StringFromList(i,listOfWindowNames)
		if( strlen(win) == 0 )
			break
		endif
		switch( WinType(win) )
			case 1:	// graph
				listOfWavePaths += WMSaveImagePathsOfImagesInGraph(win)	// includes terminating ";"
				break
			case 2: // table
				listOfWavePaths += WMSaveImagePathsOfWavesInTable(win)	// includes terminating ";"
				break
		endswitch		
		i += 1
	while(1)
	

	return listOfWavePaths
End


Function/S WMSaveImageListOfFileTypes(extensionTypeOrDescription)
	Variable extensionTypeOrDescription // 0, 1, or 2
	
	String list=""
	
	switch( extensionTypeOrDescription )
		case 0:	// file extension
				list= ".jpg;.bmp;.psd;.pict;.png;.qtif;.sgi;.tga;.tif;"
				break;
		case 1:	// file type
				list= "JPEG;BMPf;8BPS;PICT;PNG;qtif;.SGI;TPIC;TIFF;"
				break;
		case 2:	// description
				list="JPEG;PC Bitmap;Photoshop;PICT;PNG;QuickTime;Silicon Graphics;Targa;TIFF;"
				break;
	endswitch
	return list
End


Function/S WMSaveImagePathsOfImagesInGraph(win)
	String win

	String 	listOfImagePaths=""
	String imageNames= ImageNameList(win,";")
	Variable index=0
	do
		String imageName= StringFromList(index,imageNames)
		if( strlen(imageName) == 0 )
			break
		endif
		WAVE w= ImageNameToWaveRef(win,imageName)
		String path= GetWavesDataFolder(w,4)
		listOfImagePaths += path+";"
		index += 1
	while(1)
	return listOfImagePaths
End
	
Function/S WMSaveImagePathsOfWavesInTable(win)
	String win
	
	String currentDF= GetDataFolder(1)
	String 	listOfWavePaths=""
	Variable index=0
	do
		WAVE/Z w= WaveRefIndexed(win,index,3) 	// x or y wave, shouldn't matter, because non-images will get screened out.
		if( !WaveExists(w) )
			break
		endif
		listOfWavePaths += GetWavesDataFolder(w,4)+";"
		index += 1
	while(1)
	return listOfWavePaths
End

Function WMSaveImageFileName(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WMSaveImageGenerateCommand()
End

Function WMSaveImageInteractiveCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WMSaveImageGenerateCommand()
End

Function WMSaveImagePathNamePopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String/G $WMSaveImageGlobal_Var("pathName")=popStr
	WMSaveImageGenerateCommand()
End

Function WMSaveImageFileTypePopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G $WMSaveImageGlobal_Var("fileTypeMenuItem")=popNum
	WMSaveImageLimitBitDepthForType(popNum)
	WMSaveImageShowHideOptions(popStr)
	WMSaveImageFixFileNameExt(popNum)
	WMSaveImageGenerateCommand()
End

Function WMSaveImageIndexFromDescription(description)
	String description
	
	String listOfDescriptions= WMSaveImageListOfFileTypes(0)
	Variable index= WhichListItem(description, WMSaveImageListOfFileTypes(2))	// 2=descriptions.
	return index
End

Function WMSaveImageFixFileNameExt(popNum)
	Variable popNum

	String extension= StringFromList(popNum-1,WMSaveImageListOfFileTypes(0))

//	SVAR/Z fileName= $WMSaveImageGlobal_Var("fileName")
	ControlInfo/W=WMSaveImagefilePanel fileName
	String path=S_DataFolder+S_Value
	SVAR/Z fileName= $path	// Change the control's underlying string variable directly

	if( SVAR_Exists(fileName) )
		if( strlen(fileName) == 0 )
			ControlInfo/W= WMSaveImagefilePanel images
			Wave/Z image= $S_Value
			if( WaveExists(image) )
				fileName= NameOfWave(image)+extension
			endif
			return 0
		endif
		
		Variable periodPos= strsearch(fileName,".",0)
		if( periodPos < 0 )
			fileName += extension
		else
			String existingExtension= fileName[periodPos,999]
			if( 	CmpStr(existingExtension,extension) != 0 )
				// edit the extension into the file name
				fileName[periodPos,999]= extension
			endif
		endif
	endif
End

Function WMSaveImageShowHideOptions(description)
	String description
	
	// /Q quality applies only to JPEG
	Variable dis= (Cmpstr(description,"JPEG") == 0 ) ? 0 : 1
	Slider quality, win= WMSaveImagefilePanel, disable= dis

	// /U normalization applies only to 16-bit TIFFs
	Variable currentDepth=WMSaveImageGetDepthBitsFromItem(0)
	dis= (currentDepth == 16 && Cmpstr(description,"TIFF") == 0 ) ? 0 : 1
	
	Checkbox unnormalized, win= WMSaveImagefilePanel, disable= dis
	
	Variable isTIFF=CmpStr(description,"TIFF") == 0
	dis= 1	// hide stackCheckbox if inappropriate (if just disabled, it can be disabled and checked, which looks wrong).
	Variable igorTIFFDisable= 1
	if( isTIFF )
		igorTIFFDisable= currentDepth == 8 ? 1 : 0	// show unless /D=8
		// /S applies only to 3D or 4D TIFF images
		Variable dimensions= 0
		ControlInfo/W=WMSaveImagefilePanel images
		String pathToWave= S_Value
		Wave/Z image= $pathToWave
		if( WaveExists(image) )
			dimensions= WaveDims(image)
		endif
		if( dimensions >= 3 )
			dis= 0	// enabled and visible
		endif
	endif
	ModifyControl stackCheckbox win=WMSaveImagefilePanel, disable=dis
	ModifyControl useIgorTIFFCheckbox win=WMSaveImagefilePanel, disable=igorTIFFDisable
End


Function WMSaveImageTargetCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked	// for radio buttons, checked is always true.
	
	Checkbox $ctrlName win= WMSaveImagefilePanel, value=1
	// turn off other radio butttons
	String radios="fromTarget;fromAllGraphs;fromCurDF;"
	String otherRadios= RemoveFromList(ctrlName, radios)
	Variable i, n= ItemsInList(otherRadios)
	for(i=0; i<n; i+= 1 )
		String radio= StringFromList(i,otherRadios)
		Checkbox $radio win= WMSaveImagefilePanel, value=0
	endfor
	SVAR rn= $WMSaveImageGlobal_Var("radioName")
	rn= ctrlName	// remember...
	WMSaveImageRefillImageList()
	WMSaveImageGenerateCommand()
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function WMSaveImageFitToWindowWidth(win, controlName)
	String win, controlName
	
	GetWindow $win wsize
	Variable winHeight= V_bottom-V_top	// points
	Variable winWidth= V_right-V_left
	winHeight *= ScreenResolution/PanelResolution(win)	// points to pixels
	winWidth *= ScreenResolution/PanelResolution(win)	// points to pixels

	// keep the same vertical and LHS coordinates, but make the control RHS equal the panel RHS - margin
	winWidth -= 4
	ControlInfo/W=$win $controlName
	if( V_Flag == 9 )
		GroupBox $controlName,win=$win, pos={V_left,V_Top},size={winWidth-V_Left,V_Height}
	endif
	if( V_Flag == 5 )
		winWidth -= 10
		SetVariable $controlName,win=$win, pos={V_left,V_Top},size={winWidth-V_Left,V_Height}
	endif
End

Function WMSaveImageMinWindowWidth(winName,minwidth,fixedheight)
	String winName
	Variable minwidth,fixedheight	// points

	GetWindow $winName wsize
	Variable width= max(V_right-V_left,minwidth)
	Variable height= fixedheight
	MoveWindow/W=$winName V_left, V_top, V_left+width, V_top+height
End


Function WMSaveImagePanelResizeHook(infoStr)
	String infoStr
	
	String event= StringByKey("EVENT",infoStr)
	String win= StringByKey("WINDOW",infoStr)
	Variable statusCode= 0
	strswitch (event) 
		case "activate":	// refill the list of images
			WMSaveImageRefillImageList()
			break
		case "resize":
			// 	NewPanel /W=(6,45,575,348) // l, t, r, b	 ( pixels)
			Variable width= (475-6) * PanelResolution(win) / ScreenResolution	// (r-l) width (points)
			Variable height= (348-5) * PanelResolution(win) / ScreenResolution	// (b-t) h (points)
			WMSaveImageMinWindowWidth(win,width,height)	// make sure the window isn't too small
			WMSaveImageFitToWindowWidth(win,"imageGroup")
			WMSaveImageFitToWindowWidth(win,"commandFrame")
			WMSaveImageFitToWindowWidth(win,"command")
			statusCode=1
			break
	endswitch
	return statusCode	// 0 if nothing done, else 1 or 2
End

Function WMSaveImageRefillImageList()

	String imageList=WMSaveImagePopupListOfImages()
	ControlInfo/W=WMSaveImagefilePanel images
	// set mode to the S_Value,
	// unless S_Value is "_none_", in which case we choose item 1
	if( CmpStr(S_Value,"_none_") == 0 )
		V_Value=1
		S_Value= StringFromList(0,imageList)
	elseif( V_Value > ItemsInList(imageList) )
		V_Value= 1
		S_Value= StringFromList(0,imageList)
	else
		S_Value= StringFromList(V_Value-1,imageList)
	endif
	WMSaveImagesPopMenuProc("images",V_Value,S_Value)
	PopupMenu images, win= WMSaveImagefilePanel, mode=V_Value
	ControlUpdate/W=WMSaveImagefilePanel images
End

Function WMSaveImageSetImageList(imagePath)
	string imagePath	// relative path to possibly quoted image name (GetWavesDataFolder(w,4))
	
	String imageList=WMSaveImagePopupListOfImages()
	Variable index= WhichListItem(imagePath,imageList)
	if( index >= 0 )
		WMSaveImagesPopMenuProc("images",index+1,imagePath)
		PopupMenu images, win= WMSaveImagefilePanel, mode=index+1
		ControlUpdate/W=WMSaveImagefilePanel images
	endif
End

Function WMSaveImageDepthPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR depthMenuItem= $WMSaveImageGlobal_Var("bitDepthMenuItem")
	depthMenuItem= popNum
	WMSaveImageSetFileTypeForDepth(popNum)
	WMSaveImageGenerateCommand()
End


Function WMSaveImageButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR cmd=$WMSaveImageGlobal_Var("command")
	strswitch( ctrlName )
		case "doit":
			Execute cmd
			Print "•" + cmd
			break
		case "toCmd":
			ToCommandLine cmd
			Execute/P/Q/Z "DoWindow/F/H"
			break
		case "toClip":
			PutScrapText cmd
			break
		case "cancel":
			break
	endswitch
	DoWindow/K WMSaveImagefilePanel
End

