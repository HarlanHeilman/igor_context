#pragma version=6.1
// CopyImageSubset
// copies a subrange of an image displayed in an image plot.
// To use, drag out a marquee in an image plot, click within the marquee,
//  and choose "CopyImageSubset" from the popup menu that appears.
// Version 1.1, LH971111:
//  Added call to AutoSizeImage and removed unneeded textbox.
// Version 6.1, JP090514:
//	Removed use of obsolete Strings as Lists and Keyword-Value,
//	used new WMGetRECREATIONFromInfo(), and now uses all of the
//	ImageInfo recreation settings when creating the image plot copy.

#include <Graph Utility Procs> version >= 6.1
#include <Autosize Images>

Proc CopyImageSubset() : GraphMarquee
	Silent 1;PauseUpdate
	String list= ImageNameList("",";")
	if( strlen(StringFromList(1, list)) )	// two or more images, comment this test out to make it work with the first of several images
		Abort "CopyImageSubset works only with a single image in a graph"
	endif
	String imagePlot = StringFromList(0, list)
	if (strlen(imagePlot))	// one image
		String info,vaxis,haxis,image,df,xwave,ywave
		Variable i
		info=ImageInfo("",imagePlot,0)
		vaxis=StringByKey("YAXIS",info)
		haxis=StringByKey("XAXIS",info)
		image=StringByKey("ZWAVE",info)
		df=StringByKey("ZWAVEDF",info)
		xwave=StringByKey("XWAVE",info)
		ywave=StringByKey("YWAVE",info)
		if( strlen(xwave)+strlen(ywave) )
			Abort "CopyImageSubset does not work on images with X or Y waves"
		endif
		String modInfo= WMGetRECREATIONFromInfo(info)
		info= AxisInfo("",haxis)
		String axisFlags= StringByKey("AXFLAG",info)
		info= AxisInfo("",vaxis)
		axisFlags+=StringByKey("AXFLAG",info)
		String winStyle= WinRecreation("",1)
		Variable swapxy= strsearch(winStyle,"swapXY=1",0) >= 0
		GetMarquee/K $haxis,$vaxis
		if( V_Flag != 1)
			Abort "CopyImageSubset() requires a marquee in the target graph"
		endif
		// copy the marqueed image subset into a clean, liberal, unique name.
		String copy= UniqueName(CleanupName(image+"Copy",1),1,0)
		CopyMatrix(df+PossiblyQuoteName(image),copy,V_left,V_right,V_top,V_bottom,swapxy)
		// make a graph just like the source graph
		copy=PossiblyQuoteName(copy)
		Preferences 1
		Display
		String cmd="AppendImage"+axisFlags+" "+copy
		Execute cmd
		if( strlen(modInfo) )
			// modInfo has ALL the recreation pieces separated by semicolons, not commas
			modInfo= RemoveEnding(ReplaceString(";", modInfo, ","),",")
			cmd="ModifyImage "+copy+" "+modInfo
			Execute cmd 
		endif
		ApplyStyleMacro(winStyle)
		
		DoAutoSizeImage(0,-1)			// -1 for flip vert flag new. Means don't change current setting.
	else	// no images
		Abort "No Image in graph"
	endif
End


Proc CopyMatrix(inmatrix,outmatrix,left,right,top,bottom,swapxy)
	String inmatrix,outmatrix
	Variable left,right,top,bottom,swapxy
	
	if( swapxy )
		Duplicate/O/R=(bottom,top)(left,right) $inmatrix,$outmatrix
	else
		Duplicate/O/R=(left,right)(bottom,top) $inmatrix,$outmatrix
	endif
End