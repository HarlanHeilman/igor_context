#pragma rtGlobals=1		// Use modern global access method.

// Log Color Tables for Image plots
//
// This procedure file adds "Log Image Color Table" and "Update Log Image Color Table" menu items
// to the "Graph Menu".
//
// The "Log Image Color Table" menu item is checked if the first image in the top graph has a log color
// table applied to it. To apply a log color table, select the menu item when it is not checked.
// To remove a log color table, select the menu item when it is checked.
//
// Limitations: The log color scale needs to be updated whenever the color min, color max, or reverse settings change.
// (It does not need to be updated when changing the colors (the color table name).
//
// Select the "Update Log Image Color Table" menu item whenever you adjust any of color min, color max,
// or reverse settings.
//
// 2/13/2003 - jsp
// Version 1.01 - added missing #include <WMImageInfo>
//
// 8/27/2009 - AL
// Version 1.02 - 	* Fixed WMImageLookupWavePath() to work with liberal wave names.
// 				* Removed MyWM_ImageColorLookupWave() and replaced calls to that function
// 				  with calls to WM_ImageColorLookupWave() in WMImageInfo.ipf, which I have
// 				  also fixed to work correctly with liberal wave names.
//
// 2/13/2003 - jsp
// Version 1.03 - Revised min limit when data is negative
//
// 9/18/2014 - jsp
// Version 6.355 - disabled menu items when image isn't using a color table. Require fixed WMImageInfo.ipf
//
#pragma version=6.355	// released with Igor 6.35A5
#include <WMImageInfo>, version >= 6.355

StrConstant ksImageLogCTabSuffix="_LogLU"

Menu "Graph", dynamic

	WMImageLogColorTableMenu(),/Q, WMImageToggleLogColorTable(WinName(0,1),WMIndexedImageInGraph(WinName(0,1),0))
	WMImageUpdateLogColorTableMenu(), /Q, WMImageUpdateLogColorTable(WinName(0,1),WMIndexedImageInGraph(WinName(0,1),0))
End

Function/S WMImageLogColorTableMenu()

	String menutext="\\M0:(:Log Image Color Table"
	
	// if no top graph, disable the menu
	String graphName= WinName(0,1)
	if( strlen(graphName) == 0 )
		return menuText
	endif
	
	// if no image, disable the menu
	String imageName= WMIndexedImageInGraph(graphName,0)
	if( strlen(imageName) == 0 )
		return menuText
	endif
	
	// Igor 6.35A5: if top graph's first image isn't using a color table, disable the menu
	String colorTable= WM_ColorTableForImage(graphName, imageName)
	if( strlen(colorTable) == 0 )
		return menuText
	endif
	
	// if top graph's first image is logarithmic, add checkmark
	menuText = "Log Image Color Table"
	if( WMImageHasLogColorTable(graphName,imageName))	// yep, it's our log lookup
		menuText = "\\M0:!"+ num2char(18) + ":Log Image Color Table"	// checked
	endif		

	return menuText
End

Function/S WMImageUpdateLogColorTableMenu()

	String menutext="\\M0:(:No Log Image Color Table to update"
	
	// if no top graph, disable the menu
	String graphName= WinName(0,1)
	if( strlen(graphName) == 0 )
		return menuText
	endif
	
	// if no image, disable the menu
	String imageName= WMIndexedImageInGraph(graphName,0)
	if( strlen(imageName) == 0 )
		return menuText
	endif
	
	// Igor 6.35A5: if top graph's first image isn't using a color table, disable the menu
	String colorTable= WM_ColorTableForImage(graphName, imageName)
	if( strlen(colorTable) == 0 )
		return menuText
	endif

	// if top graph's first image is logarithmic, enable the menu item
	if( WMImageHasLogColorTable(graphName,imageName))	// yep, it's our log lookup
		menuText = "Update Log Image Color Table"
	endif		

	return menuText
End

Function WMImageHasLogColorTable(graphName,imageName)
	String graphName,imageName

	Variable isLog= 0
	Wave/Z wlookup= $WM_ImageColorLookupWave(graphName,imageName)
	if( WaveExists(wlookup) )
		// is this a wave we created?
		Variable suffixLen= strlen(ksImageLogCTabSuffix)
		Variable nameLen= strlen(NameOfWave(wlookup))
		String EndOfName= NameOfWave(wlookup)[nameLen-suffixLen,nameLen-1]
		if( CmpStr(EndOfName, ksImageLogCTabSuffix) == 0 )	// yep, it's our log lookup
			isLog= 1
		endif		
	endif
	return isLog
End

Function WMImageUpdateLogColorTable(graphName,imageName)
	String graphName,imageName

	if( strlen(graphName) == 0 || strlen(imageName) == 0 )
		return 0
	endif
	
	Variable wantLog= WMImageHasLogColorTable(graphName,imageName)
	return WMImageLogColorTable(graphName,imageName,wantLog)
End


Function WMImageToggleLogColorTable(graphName,imageName)
	String graphName,imageName

	if( strlen(graphName) == 0 || strlen(imageName) == 0 )
		return 0
	endif
	
	Variable wantLog= !WMImageHasLogColorTable(graphName,imageName)
	return WMImageLogColorTable(graphName,imageName,wantLog)
End


Function WMImageLogColorTable(graphName,imageName, wantLog)
	String graphName,imageName
	Variable wantLog

	if( strlen(graphName) == 0 || strlen(imageName) == 0 )
		return 0
	endif
	
	if( wantLog )
		Variable colorMin, colorMax
		WM_GetColorTableMinMax(graphName, imageName, colorMin, colorMax)

		if( colorMax <= 0 )
			colorMax= 1
		endif
		if( colorMin <= 0 )
			colorMin= .001	// prior to version 1.03 was =1
		endif
		Variable reversed=WM_ColorTableReversed(graphName, imageName)

		Variable n= (10*(colormax/colorMin))^1.02
		n= max(200,min(65536,n))
		String lookupWavePath= WMImageLookupWavePath(graphName,imageName)	// new or existing
		String path = WMImageMakeLogLookupWave(lookupWavePath,colorMin, colorMax, reversed, n)
		ModifyImage/W=$graphName $imageName, lookup=$path, cindex=$""

	else	// linear
		ModifyImage/W=$graphName $imageName, lookup=$"", cindex=$""
	endif

	// if the graph contains a colorscale attached to the image, switch it to linear or log
	String colorScaleName= WMImageColorScaleForImage(graphName,imageName)
	if( strlen(colorScaleName) )
		ColorScale/W=$graphName/C/N=$colorScaleName log=(wantLog ? 1 : 0 )
	endif
	BuildMenu "Graph"
End


Function/S WMImageLookupWavePath(graphName,imageName)	// new or existing
	String graphName,imageName

	Wave/Z image= ImageNameToWaveRef(graphName,imageName)
	if( !WaveExists(image) )
		return "image"+ksImageLogCTabSuffix
	endif
	Wave/Z wlookup= $WM_ImageColorLookupWave(graphName,imageName)
	if( WaveExists(wlookup) )
		return GetWavesDataFolder(wlookup,2)
	endif
	// need to create one, we append the suffix to the image's data folder and name
	String imageDF= GetWavesDataFolder(image,1)
	String path=imageDF+possiblyquotename((nameofwave(image)[0,31-strlen(ksImageLogCTabSuffix)]) + ksImageLogCTabSuffix)
	return path
End

Function/S WMImageMakeLogLookupWave(lookupWaveName, colorMin, colorMax, reversed, n)
	String lookupWaveName
	Variable colorMin, colorMax, reversed, n
	
	Variable logMin= log(colorMin)
	Variable logMax= log(colorMax)
	Variable const, mult

	if( reversed )
		Make/O/N=(n) $lookupWaveName = 1-p/(n-1)
		WAVE wlookup= $lookupWaveName
		SetScale/I x, colorMax, colorMin, "", wlookup
		
		const= 1+(logMin/(logMax-logMin))
		mult = 1/(logMin - logMax)
	else
		Make/O/N=(n) $lookupWaveName = p/(n-1)
		WAVE wlookup= $lookupWaveName
		SetScale/I x, colorMin, colorMax, "", wlookup

		Variable logRange= logMax-logMin
		const= - logMin/logRange
		mult = 1/logRange
	endif
	wlookup = mult * log(x) + const
	wlookup[0]= 0

	String path= GetWavesDataFolder(wlookup,2)
	return path
End

Function/S WMImageColorScaleForImage(graphName,imageName)
	String graphName,imageName

	String list= AnnotationList(graphName)
	String name, info, type, imageInstance
	Variable i=0
	do
		name= StringFromList(i,list)
		if( strlen(name) == 0 )
			break
		endif
		info=AnnotationInfo(graphName, name)
		type= StringByKey("TYPE", info, ":")
		if( CmpStr(type, "ColorScale") == 0 )
			info= StringByKey("COLORSCALE", info, ":")
			imageInstance= StringByKey("image", info, "=", ",")
			if( CmpStr(imageInstance, imageName) == 0 )
				return name	// found it.
			endif
		endif
		i+=1
	while(1)
	return name	
End


Function/S WMIndexedImageInGraph(graphName,index)	// 0 for first image
	String graphName
	Variable index

	String list= ImageNameList(graphName,";")	
	return StringFromList(index,list)
End

