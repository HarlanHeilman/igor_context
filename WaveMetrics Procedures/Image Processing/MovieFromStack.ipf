#pragma rtGlobals=1		// Use modern global access method.
#include <WaveSelectorWidget>
#include <Image Common>

//*********************************************************************************************************

Function WM_MakeStackMovie()

	DoWindow/F WM_StackToMovie
	if(V_Flag==1)
		return 0
	endif
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S StackMovie
	Variable/G frameRate=10

	NewPanel /K=1/W=(309,44,600,380) as "Stack To Movie"
	DoWindow/C WM_StackToMovie
	SetDrawLayer UserBack
	DrawText 20,68,"Choose a 3D wave:"
	ListBox waveListWidget,pos={20,77},size={243,183},proc=WaveSelectorListProc
	Button WMMovieButton,pos={18,303},size={120,20},proc=WM_MakeAMovieButtonProc,title="Make a Movie"
	CheckBox WM_TopImageCheck,pos={20,18},size={153,14},proc=WMUseTopImageCheckProc,title="Use the image in the top graph"
	CheckBox WM_TopImageCheck,value= 0
	Button WMDisplayImageButton,pos={18,270},size={120,20},proc=WM_displayImageButtonProc,title="Display Image"
	SetWindow kwTopWin,hook(WaveSelectorWidgetHook)=WMWS_WinHook
	SetWindow kwTopWin,userdata(WaveWidgetList)=  "WindowName=WM_StackToMovie,ListName=waveListWidget;"

	MakeListIntoWaveSelector("WM_StackToMovie", "waveListWidget",content=WMWS_Waves, selectionMode=WMWS_SelectionSingle,listoptions="MINLAYERS:3")
	WS_ClearSelection("WM_StackToMovie", "waveListWidget")
	
	SetDataFolder oldDF
End

//*********************************************************************************************************

Function WM_MakeAMovieButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2:
			String topWaveName=WMGetImageWave("")
			String imageName=WMTopImageName()
			if(strlen(topWaveName)<=0)
				doAlert 0,"You need to have an image in the top graph."
				break
			endif
			Wave/Z srcWave=$topWaveName
			Variable i,planes=DimSize(srcWave,2)
			if(DimSize(srcWave,3)>0)					// handle RGB chunks
				planes=DimSize(srcWave,3)
			endif
			if(planes<=0)
				doAlert 0,"You must have a stack image in the top graph."
				break
			endif
			
			NewMovie/i/Z
			if(V_Flag==0)
				for(i=0;i<planes;i+=1)
					ModifyImage $imageName, plane=(i)
					doUpdate
					AddMovieFrame
				endfor	
				CloseMovie
			endif
		break
	endswitch

	return 0
End

//*********************************************************************************************************

Function WMUseTopImageCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(checked)
				ListBox waveListWidget, disable=1
				Button WMDisplayImageButton, disable=2
			else
				ListBox waveListWidget disable=0
				Button WMDisplayImageButton, disable=0
			endif
		break
	endswitch

	return 0
End

//*********************************************************************************************************

Function WM_displayImageButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String selectedWaveStr= WS_SelectedObjectsList("WM_StackToMovie", "waveListWidget")
			String srcWaveName=selectedWaveStr[0,strlen(selectedWaveStr)-2]
			Wave/Z ww=$srcWaveName
			if(WaveExists(ww))
				NewImage/K=1 ww
			endif
		break
	endswitch

	return 0
End

//*********************************************************************************************************
