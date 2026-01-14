#include <AnnotationInfo Procs>
#include <Keyword-Value>
// Remove Tags
// Version 1.01, JP, 1/5/2002 - a tag is also considered offscreen if the Y position of the anchor exceeds the axis range.
#pragma version=1.01
#pragma rtGlobals=1

Menu "Graph"
	"-"
	"Remove Tags..."
End

Proc RemoveTags(which)
	Variable which=1
	Prompt which,"Remove which tags?",popup,"all tags;all tags attached off-screen"
	
	Silent 1;PauseUpdate
	String ann,axis,wv,info,str=AnnotationList("")
	Variable offset1, offset2,len,del,instance,hash
	offset1 = 0
	do
		offset2 = StrSearch(str, ";" , offset1)
		if (offset2 == -1)
			break;
		endif
		ann= str[offset1, offset2-1]
		info=AnnotationInfo("",ann)
		if( CmpStr(AnnotationType(info),"Tag")==0 )
			del=1
			if(which == 2)	// delete only off-screen tags
				del=TagIsOffScreen(info)
			endif
			if( del )
				Tag/K/N=$ann
			endif
		endif
		offset1 = offset2+1
	while (1)
End


Function TagIsOffScreen(info)
	String info

	String axis,trace,tinfo
	Variable instance,hash,offscreen,tmp
	Variable xAttach= AnnotationAttachX(info)
	trace= AnnotationYWave(info)		// trace name tag is attached to
	hash=strsearch(trace,"#",0)
	if(hash != -1 )
		instance=str2num(trace[hash+1,99])
		trace[hash,99]=""
	endif
	tinfo=TraceInfo("",trace,instance)
	axis=StrByKey("XAXIS",tinfo)	// X axis wave is graphed against
	GetAxis/Q $axis
	if( V_Min > V_Max )		// V_Min and V_Max are actually left and right values
		tmp=V_Max
		V_Max= V_Min
		V_Min= tmp
	endif
	offscreen= xAttach != limit(xAttach,V_Min,V_Max)
	if( !offscreen ) 
		// see if the Y attachment point exceeds the Y axis range
		String df= AnnotationYWaveDataFolder(info)	// ends with ":"
		Wave wy= $(df+trace)
		Variable yAttach= wy[x2pnt(wy,xAttach)]
		axis=StrByKey("YAXIS",tinfo)	// X axis wave is graphed against
		GetAxis/Q $axis
		if( V_Min > V_Max )		// V_Min and V_Max are actually bottom and top values
			tmp=V_Max
			V_Max= V_Min
			V_Min= tmp
		endif
		offscreen= yAttach != limit(yAttach,V_Min,V_Max)
	endif
	return offscreen
End
