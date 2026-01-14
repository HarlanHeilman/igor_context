#include <Axis Utilities>
// Version 1.0

// The SetAxisRangeToVisibleData function examines the top graph and autoscales all traces.
// Unlike what Igor does automatically, this function takes into account the range
// of the associated horizontal axis.  That is, if you have set a range for the horizontal
// axis that is less than the full x range of the trace, when Igor autoscales the vertical
// axis it (he?) looks at all the data, not just data that fall within the given X range.
// This function scales the vertical axes only according to the data that fall within
// the given X range.

//Example:
//  Suppose you have a graph with a wave having a range in Y of -40 to 80, and an
//  X range of 0 to 100.  You make a graph, and Igor autoscales to show the data at
//  maximum possible size.  Now you set the range of the X axis to 50 to 80, Igor
//  still sets the range of the vertical axis to -40 to 80, even though some of the data
//  don't show.  Run SetAxisRangeToVisibleData(), and the vertical axis is re-scaled to show the 
//  restricted range of data at maximum possible size.

//The function handles waveform data, XY data, multiple vertical axes, and multiple
//instances of the save wave in the graph.  It works only on the top graph.  
//IF YOU HAVE SOME OTHER GRAPH AT THE TOP, YOU RUN THE RISK OF TOTALLY SCREWING IT UP!

//USAGE:
//To use the procedure file, put it into the User Procedures folder in the Igor Pro folder.
//Add this line to the top of your Procedure window:
//#include "SetAxisRangeToVisibleData"
//
//When you close the procedure window, the procedure is compiled and ready to go.
//You can execute the function on the command line by typing "SetAxisRangeToVisibleData()" on the
//command line, or you can select "Scale to visible data" from the Macros menu.

Menu "Macros"
	"Scale to visible data", SetAxisRangeToVisibleData()
end

Function SetAxisRangeToVisibleData()

	String WindowName
	String VAxes
	String ThisHAxis, ThisVAxis, TrialVAxis, ThisWave, ThisXWave
	String TrInfo
	
	Variable/C limits
	Variable MyVMin, MyVMax
	Variable XMin, XMax
	
	Variable i,j,k,kiters,n
	
	WindowName=WinName(0,1)
	if (strlen(WindowName) == 0)
		Abort "No graphs"
	endif
	
	DoWindow/F $WindowName
	
	VAxes=HVAxisList(WindowName,0)
	if (strlen(VAxes) == 0)
		Abort "No vertical axes in top graph"
	endif
	
	i = 0
	do
		ThisVAxis=StringFromList(i, VAxes)
//print "ThisVAxis = \"", ThisVAxis, "\""
		if (strlen(ThisVAxis) == 0)
			break
		endif
		
		j=0
		MyVMin=NaN
		MyVMax=NaN
		do 
			ThisWave=WaveName("", j, 1)
//print "\tThisWave = \"", ThisWave, "\""
			if (strlen(ThisWave) == 0)
				break
			endif
			n=0
			do
				TrInfo=TraceInfo("", ThisWave, n)
				if (strlen(TrInfo) == 0)
					break
				endif
				TrialVAxis=StringByKey("YAXIS",TrInfo)
				if (cmpstr(TrialVAxis, ThisVAxis) == 0)
					ThisHAxis = StringByKey("XAXIS",TrInfo)
					GetAxis/Q $ThisHAxis
					XMin=V_min
					XMax=V_max
					ThisXWave=StringByKey("XWAVE",TrInfo)
//print "\t\tThisXWave = \"", ThisXWave, "\""
					if (strlen(ThisXWave) == 0)
						WaveStats/Q/R=(XMin,XMax) $ThisWave
						if (numtype(MyVMin) == 2)
							MyVMin=V_min
						else
							if (V_min < MyVMin)
								MyVMin=V_min
							endif
						endif
						if (numtype(MyVMax) == 2)
							MyVMax=V_max
						else
							if (V_max > MyVMax)
								MyVMax=V_max
							endif
						endif
					else
//print "\t\t\tDoing XY branch"
						k=0
						Wave xw=$ThisXWave
						Wave yw=$ThisWave
						kiters=numpnts(xw)
						do
							if ((xw[k] >= XMin) %& (xw[k] <= XMax))
								if (numtype(MyVMin) == 2)
									MyVMin=yw[k]
								else
									if (yw[k] < MyVMin)
										MyVMin=yw[k]
									endif
								endif
								if (numtype(MyVMax) == 2)
									MyVMax=yw[k]
								else
									if (yw[k] > MyVMax)
										MyVMax=yw[k]
									endif
								endif
							endif
	
							k += 1
						while(k < kiters)
					endif
				endif
				n += 1
			while (1)
		
			j += 1
		while (1)
		
		SetAxis $ThisVAxis,MyVMin,MyVMax
	
		i += 1
	while(1)
end

