#pragma rtGlobals=2		// Use modern global access method.
#include <Image Common>

// AG17JUN99 Modified the update by calling the hook directly after panel creation.
 
// Image Histogram Panel package
// Version 0.5, LH971211
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageHistPanel()

// 22JUN06 added print commands

Function WMCreateImageHistPanel()

	DoWindow/F WMImageHistPanel
	if( V_Flag==1 )
		return 0
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMImProcess
	NewDataFolder/O root:Packages:WMImProcess:ImageHistogram
	
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageHistogram
	
	String/G ImGrfName= WMTopImageGraph()
	if( NumVarOrDefault("inited",0) == 0 )
		Variable/G inited=1
		Variable/G AdaptHistXDivisions= 4, AdaptHistYDivisions= 4,AdaptHistContrast=10
	endif

	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(ImGrfName)
	
	Wave/Z histw= $WMImageHistDoHist(ImGrfName)
	if( !WaveExists(histw) )
		Abort "No Image graph found"
		return 0
	endif
	WMImageHistGraph(histw)

	AutoPositionWindow/E/M=1/R=$ImGrfName
	
	return 0;
end

Function WMImageHistUpdateProc()
	String newImGrfName= WMTopImageGraph()
	SVAR ImGrfName= root:Packages:WMImProcess:ImageHistogram:ImGrfName
	
	Wave w= $WMGetImageWave(newImGrfName)
	
	Wave/Z histw= $WMImageHistDoHist(newImGrfName)
	if( !WaveExists(histw) )
//		beep
		return 0
	endif
	if( CmpStr(newImGrfName,ImGrfName)!= 0 )
		ReplaceWave trace=hist,histw
	endif
	ImGrfName= newImGrfName
end
	
Function WMImageHistWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0 )
		WMImageHistUpdateProc()
		return 1
	endif
	return 0
end



Function/S WMImageHistDoHist(ImGrfName)
	String ImGrfName
	
	Wave/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return ""
	endif
	
	String pu= WMGetWaveAuxDF(w)
	String dfSav= GetDataFolder(1)
	SetDataFolder pu
	Make/O/N=100 hist
	Histogram/B=1 w,hist
	SetScale d,0,0,"Counts" hist

	SetDataFolder dfSav

	return GetWavesDataFolder(hist,2)		// full path to wave including name
end

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function WMImageHistGraph(histw)
	Wave histw

	// specify size in pixels to match user controls
	Variable x0=324*PanelResolution("")/ScreenResolution, y0= 156*PanelResolution("")/ScreenResolution
	Variable x1=932*PanelResolution("")/ScreenResolution, y1= 313*PanelResolution("")/ScreenResolution

	Display/K=1/W=(x0,y0,x1,y1) histw as "Image Histogram"

	ModifyGraph mode(hist)=1

	DoWindow/C WMImageHistPanel

	ControlBar 28
	Button Equalize,pos={7,6},size={77,20},proc=WMHistogramButtonProc,title="Equalize"
	Button Equalize,help={"Performs Histogram Equalization on the top image."}
	Button AdaptiveEqualize,pos={94,6},size={136,20},proc=WMHistogramButtonProc,title="Adaptive Equalize"
	Button AdaptiveEqualize,help={"Performs Adaptive Histogram Equalization.  The image is subdivided into horizontal and vertical blocks."}
	Button HistUndo,pos={339,5},size={56,20},proc=WMHistogramButtonProc,title="Undo"
	Button HistUndo,help={"Returns the image to its values prior to the last operation."}
	Button HistRevert,pos={403,5},size={77,20},proc=WMHistogramButtonProc,title="Revert"
	Button HistRevert,help={"Return to the original image."}
	Button histHelpButt,pos={281,5},size={50,20},proc=histHelpProc,title="Help"
	CheckBox IPHCheck0,pos={494,8},size={91,14},title="Print Commands",value= 0
	DoUpdate
	SetWindow kwTopWin,hook=WMImageHistWindowProc
	WMImageHistWindowProc("EVENT:activate")
EndMacro

Function histHelpProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic  "ImageHistModification"
End


Function WMDoHistEqualize(w)
	Wave w
	
	WMSaveWaveBackups(w)
	String cmd
	
	ImageGenerateROIMask/W=$WMTopImageGraph()/E=255/I=0 $NameOfWave(w)
	if( V_FLag )
		sprintf cmd,"ImageHistModification/O/R=M_ROIMask %s",NameOfWave(w)
		ImageHistModification/O/R=M_ROIMask w
		KillWaves M_ROIMask
	else
		ImageHistModification/O w
		sprintf cmd,"ImageHistModification/O %s",NameOfWave(w)
	endif

	ControlInfo/W=WMImageHIstPanel IPHCheck0
	if(V_Value)
		Print cmd
	endif
	
	WMImageHistUpdateProc()
end


Function WMHistogramButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR ImGrfName= root:Packages:WMImProcess:ImageHistogram:ImGrfName
	Wave w= $WMGetImageWave(ImGrfName)

	if( CmpStr(ctrlName,"Equalize") == 0 )
		WMDoHistEqualize(w)
	endif
	if( CmpStr(ctrlName,"AdaptiveEqualize") == 0 )
		WMCreateAdaptHistPanel()
	endif
	if( CmpStr(ctrlName,"HistUndo") == 0 )
		WMRestoreWaveBackups(w,0)				// if desired we could alert user to error return
	endif
	if( CmpStr(ctrlName,"HistRevert") == 0 )
		WMRestoreWaveBackups(w,1)				// if desired we could alert user to error return
	endif
	WMImageHistUpdateProc()
End

//******** adaptive ******


Function WMDoAdaptiveHistButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR AdaptHistXDivisions= root:Packages:WMImProcess:ImageHistogram:AdaptHistXDivisions
	NVAR AdaptHistYDivisions= root:Packages:WMImProcess:ImageHistogram:AdaptHistYDivisions
	NVAR AdaptHistContrast= root:Packages:WMImProcess:ImageHistogram:AdaptHistContrast
	SVAR ImGrfName= root:Packages:WMImProcess:ImageHistogram:ImGrfName
	Wave/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		beep
		return 0
	endif

	WMSaveWaveBackups(w)

	Variable nx= DimSize(w, 0),ny= DimSize(w, 1)
	Variable xdivsize= nx/AdaptHistXDivisions
	Variable ydivsize= ny/AdaptHistYDivisions
	if( xdivsize != Floor(xdivsize) )
		Variable xexpanded= Ceil(xdivsize)*AdaptHistXDivisions
		Redimension/N=(xexpanded,ny) w
		w[nx,*]= w[nx-1]
	endif
	if( ydivsize != Floor(ydivsize) )
		Variable yexpanded= Ceil(ydivsize)*AdaptHistYDivisions
		Redimension/N=(DimSize(w, 0),yexpanded) w
		w[][ny,*]= w[p][ny-1]
	endif
	
	String cmd
	ImageHistModification /C=(AdaptHistContrast)/O/A/H=(AdaptHistXDivisions)/V=(AdaptHistYDivisions) w
	sprintf cmd,"ImageHistModification /C=(%g)/O/A/H=(%g)/V=(%g) %s",AdaptHistContrast,AdaptHistXDivisions,AdaptHistYDivisions,NameOfWave(w)
	Redimension/N=(nx,ny) w
	
	ImageGenerateROIMask/W=$ImGrfName $NameOfWave(w)
	if( V_FLag )
		Wave wback= $(GetWavesDataFolder(w,1)+NameOfWave(w)+"_UnDo")
		Wave wroi= M_ROIMask
		w= (wroi==0)*wback + (wroi==1)*w
		KillWaves M_ROIMask
	endif

	DoWindow/K WMAdaptiveHistPanel
	ControlInfo/W=WMImageHIstPanel IPHCheck0
	if(V_Value)
		Print cmd
	endif

End

Function WMCreateAdaptHistPanel()

	DoWindow/F WMAdaptiveHistPanel
	if( V_Flag==1 )
		return 0
	endif
	
	NewPanel/K=1 /W=(12,541,168,674) as "Adaptive"
	DoWindow/C WMAdaptiveHistPanel
	DoUpdate
	AutoPositionWindow/E/M=1/R=WMImageHistPanel

	SetDrawLayer UserBack
	SetDrawEnv fsize= 10,textxjust= 2,textyjust= 1
	DrawText 76,27,"X Divisions:"
	SetDrawEnv fsize= 10,textxjust= 2,textyjust= 1
	DrawText 76,48,"Y Divisions:"
	SetDrawEnv fsize= 10,textxjust= 2,textyjust= 1
	DrawText 76,68,"Contrast:"
	SetVariable XDivs,pos={79,19},size={56,15},title=" "
	SetVariable XDivs,help={"Enter number of horizontal divisions.  Best if divides into image width with no remainder."}
	SetVariable XDivs,format="%d"
	SetVariable XDivs,limits={2,16,1},value= root:Packages:WMImProcess:ImageHistogram:AdaptHistXDivisions
	SetVariable YDivs,pos={80,40},size={55,15},title=" "
	SetVariable YDivs,help={"Enter number of vertical divisions.  Best if divides into image height with no remainder."}
	SetVariable YDivs,format="%d"
	SetVariable YDivs,limits={2,16,1},value= root:Packages:WMImProcess:ImageHistogram:AdaptHistYDivisions
	SetVariable contrast,pos={80,60},size={54,15},title=" "
	SetVariable contrast,help={"Enter contrast enhancement factor. One is no enhancment."}
	SetVariable contrast,format="%d"
	SetVariable contrast,limits={2,16,1},value= root:Packages:WMImProcess:ImageHistogram:AdaptHistContrast
	Button DoIt,pos={20,91},size={96,20},proc=WMDoAdaptiveHistButtonProc,title="Do Equalize"

End
