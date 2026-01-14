// Remove Axis Proc, Version 1.1, LH951107

// Version 1.1 created to be liberal name aware and data folder savvy

#include <Strings as Lists>
#include <Keyword-Value>
//#include <Graph Utility Procs>


#pragma rtGlobals=1		// This mainly acts as notice that this proc is Igor 3.0 savvy


Macro RemoveAxis(axName)
	String axName="left"
	Prompt axName,"axis to remove",popup AxisList("")
	
	DoRemoveAxis(axName)
End

Proc DoRemoveAxis(axName)
	String axName
	
	PauseUpdate; Silent 1

	String axInfo= AxisInfo("",axName),axType
	axType= StrByKey("AXTYPE",axInfo)
	if( strlen(axType) == 0 )
		Abort "FOOBAR"						// sanity check, from now on we ASSUME things work
	endif
	Variable isX= (CmpStr("bottom", axType)==0 ) %|  (CmpStr("top", axType)==0 )

	String tracesOnGraph
	String theTrace,tInfo
	String key1
	Variable i,didOne
	
	do
		didOne= 0
		i= 0
		tracesOnGraph= TraceNameList("", ";", 1)		// we have to get this fresh each time we remove a trace since the instance numbers change
		do
			theTrace= GetStrFromList(tracesOnGraph,i,";")
			if( strlen(theTrace) == 0 )
				break;
			endif
			
			do
				tInfo= TraceInfo("",theTrace,0)
				if( isX )
					key1= "XAXIS"
				else
					key1= "YAXIS"
				endif
				if( CmpStr(axName,StrByKey(key1,tInfo))== 0 )
					RemoveFromGraph $theTrace
					didOne= 1
				endif
			while(0)
				
			I+=1
		while(1)
	while(didOne)
end
