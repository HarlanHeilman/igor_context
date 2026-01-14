#pragma rtGlobals=2		// Use modern global access method.

#include <Image Common>
 
 // Creates and applies a variable-frequency sinusoid lookup wave
 // to the top graph's first image plot, and also provides quick color table switching.
 
// 28FEB00
// This procedure file is for use with IGOR Pro 4.0 or later.

// 18FEB09
// Uses the CTabList function instead of a hard-coded list of color table names..

Function CreateColorizerPanel()

	DoWindow/F WMColorizer
	if(V_Flag==1)									// if the window is already up there.
		return 0
	endif
	
	if(isColorImage())
		return 0;
	endif

	String topImage=WMTopImageName()
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S Color

	String fname=WMTopImageGraph()
	String/G curTopImageName=fname
	String/G menuString=CTabList()
	
	NewDataFolder/O/S $getDFName(fname)
	Variable /G center=10
	Variable /G period=10
	String/G colormap="Rainbow"						// default startup cmap.
	
	Make/O/N=200 kkk=setKKK(x,center,period)
	SetFormula kkk, "setKKK(x,center,period)"
	
	NewPanel /K=1 /W=(69,286,315,392) as "Colorizer"
	DoWindow/C WMColorizer
	Slider slider0,pos={23,6},size={200,13}
	Slider slider0,limits={10,100,1},variable=root:Packages:Color:$(fname):period,side= 0,vert= 0
	Slider slider1,pos={21,22},size={203,13}
	Slider slider1,limits={0,100,1},variable= root:Packages:Color:$(fname):center,side= 0,vert= 0
	PopupMenu colorizerPop0,pos={16,49},size={169,24},proc=ctabMenuProc,title="Color table"
	PopupMenu colorizerPop0,mode=1,popvalue="Rainbow",value= CTabList()
	SetWindow kwTopWin,hook=WMColorizerWindowProc
	
	ModifyImage $topImage ctab= {*,*,Rainbow,0},lookup= kkk
	AutoPositionWindow/E/M=1/R=$WMTopImageGraph()

	SetDataFolder oldDF
End


Function WMColorizerWindowProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0 )
			WMColorizerUpdate()
		return 1
	endif
	return 0
End


Function WMColorizerUpdate()

	SVAR curTopImageName=root:Packages:color:curTopImageName
	String topImage=WMTopImageName()
	
	if(strlen(topImage)<=0)			// no other top images left.
		DoWindow/K WMColorizer
		return 0
	endif
	
	String topImageFolderName=getDFName(WMTopImageGraph())		// cleanup the name if necessary
	
	if(cmpstr(curTopImageName,topImageFolderName)==0)
		return 0
	endif
	
	
	// if we switched to a different image need to check first if there is an appropriate DF.
	String df="root:packages:color:"+topImageFolderName
	if(DataFolderExists(df))
		SVAR colormap=root:packages:color:$(topImageFolderName):colormap
		Wave kkk=root:packages:color:$(topImageFolderName):kkk
		ModifyImage $topImage ctab= {*,*,$colormap,0},lookup= kkk
	else
		// so this is a new image; create the appropriate data folder and objects
		String savedf=GetDataFolder(1)
		SetDataFolder root:packages:color
		NewDataFolder/O/S $topImageFolderName
		Variable /G center=10
		Variable /G period=10
		String/G colormap="Rainbow"						 
		Make/O/N=200 kkk=setKKK(x,center,period)
		SetFormula kkk, "setKKK(x,center,period)"
		ModifyImage $topImage ctab= {*,*,$colormap,0},lookup= kkk
		SetDataFolder savedf
	endif
	
	// now set the controls to the parameters in the appropriate data folder:
	SVAR cmap=root:Packages:Color:$(topImageFolderName):colormap
	Slider slider0,variable=root:Packages:Color:$(topImageFolderName):period
	Slider slider1,variable= root:Packages:Color:$(topImageFolderName):center
	SVAR menuString=root:packages:color:menuString
	Variable m=WhichListItem(cmap ,menuString)
	PopupMenu colorizerPop0,mode=m+1

	curTopImageName=topImageFolderName
End

Function setKKK(x,center,period)
	Variable x,center,period
	
	return 0.5*(1+sin((x-center)/period))
End


Function ctabMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String topImage=WMTopImageName()
	ModifyImage $topImage ctab= {*,*,$popStr,0}
	String topImageFolderName=getDFName(WMTopImageGraph())
	
	SVAR cmap=root:Packages:Color:$(topImageFolderName):colormap
	cmap=popStr
End

// might want to make this fancier
Function/S getDFName(imageName)
	String imageName
	
	imageName=CleanupName(imageName, 0 )
	return imageName
End