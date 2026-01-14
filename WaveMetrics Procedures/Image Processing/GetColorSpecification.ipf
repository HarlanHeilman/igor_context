#include <Image Common>


Proc GetColorSpecification() : GraphMarquee
 
	Silent 1;PauseUpdate
	String list= ImageNameList("",";")
	if( strlen(GetStrFromList(list, 1, ";")) )	// two or more images, comment this test out to make it work with the first of several images
		Abort "GetColorSpecification works only with a single image in a graph"
	endif
	String imagePlot = GetStrFromList(list, 0, ";")
	if (strlen(imagePlot))	// one image
		String info,vaxis,haxis,image,df,xwave,ywave
		Variable i
		info=ImageInfo("",imagePlot,0)
		vaxis=StrByKey("YAXIS",info)
		haxis=StrByKey("XAXIS",info)
		image=StrByKey("ZWAVE",info)
		df=StrByKey("ZWAVEDF",info)
		xwave=StrByKey("XWAVE",info)
		ywave=StrByKey("YWAVE",info)
		if( strlen(xwave)+strlen(ywave) )
			Abort "GetColorSpecification does not work on images with X or Y waves"
		endif
		string modInfo=StrByKey("RECREATION",info)
		info= AxisInfo("",haxis)
		String axisFlags= StrByKey("AXFLAG",info)
		info= AxisInfo("",vaxis)
		axisFlags+=StrByKey("AXFLAG",info)
		String winStyle= WinRecreation("",1)
		Variable swapxy= strsearch(winStyle,"swapXY=1",0) >= 0
		GetMarquee $haxis,$vaxis		
		NewDataFolder/O/S WM_tmpKillFolder
		String copy="M_ColorSrc"
		WMCopySubMatrix(df+PossiblyQuoteName(image),copy,V_left,V_right,V_top,V_bottom,swapxy)
		ImageTransform rgb2hsl M_ColorSrc
		Make/O/N=(DimSize(M_ColorSrc,0),DimSize(M_ColorSrc,1)) onePlane		// AG17JUN99 fixed second dimension.
		onePlane=M_RGB2HSL[p][q][0]
		WaveStats/Q onePlane
		// flip the limits if we are around the origin
		if(mod(V_min+90,360)>mod(V_max+90,360))
			Variable temp=V_min
			V_min=V_max
			V_max=tmp
		endif
		printf "minHue=%.2f\t\t maxHue=%.2f\r",V_min*360/255,V_max*360/255
		
		onePlane=M_RGB2HSL[p][q][1]
		WaveStats/Q onePlane
		printf "minSat=%.2f\t\t\t maxSat=%.2f\r",V_min/255,V_max/255
		
		onePlane=M_RGB2HSL[p][q][2]
		WaveStats/Q onePlane
		printf "minLightness=%.2f\t maxLightness=%.2f\r",V_min/255,V_max/255
		KillDataFolder :
		
		
	endif
End

Function WMCopySubMatrix(inmatrix,outmatrix,left,right,top,bottom,swapxy)
	String inmatrix,outmatrix
	Variable left,right,top,bottom,swapxy

	if( swapxy )
		Duplicate/O/R=(bottom,top)(left,right) $inmatrix,$outmatrix
	else
		Duplicate/O/R=(left,right)(bottom,top) $inmatrix,$outmatrix
	endif
End

