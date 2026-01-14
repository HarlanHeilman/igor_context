#pragma rtGlobals=1		// Use modern global access method.

//==========================================================================================
// 19APR07 Factored strings for J version.
//  23MAR07 Added several notebook writing utilities.
// 31OCT05
// Stats Plotting
// This file contains a number of functions for plotting various derived quantities.  Unlike built-in plots, these plots do not update 
// automatically when the original data changes.  If you need to have this behavior you should add a dependency that will rebuild the
// graph as necessary.  Note also that these functions also produce derived waves which are meant to be created in a unique data 
// folder as in the following example:
//
//	String oldDF=GetDataFolder(1)
//  NewDataFolder/O/S myUniqueFolderName
// 	statsAutoCorrPlot(inWave)
// 	SetDataFolder oldDF
//
//
//=====================================================================================================
//  Begin String Block
//=====================================================================================================
static StrConstant ksLagPlot="Lag Plot"
static StrConstant ksAutoCorrelationPlot="Autocorrelation plot"
static StrConstant ksAutocorrelation="Autocorrelation"
static StrConstant ksLag="Lag"
static StrConstant ksHistogram="Histogram"
static StrConstant ksCounts="Counts"
static StrConstant ksY="Y"
static StrConstant ksOuterFence="Outer Fence"
static StrConstant ksInnerFence="Inner Fence"
static StrConstant ksMedian="Median"
static StrConstant ksLowerHinge="Lower Hinge"
static StrConstant ksUpperHinge="Upper Hinge"

static StrConstant ksNormalProbPlot="Normal Probability plot"
static StrConstant ksAlertText1="The dog ate the report notebook.  You will have to restart the analysis."

//=====================================================================================================
// End String Block
//=====================================================================================================


//==========================================================================================
// The following function displays a simple lag plot and names the window so that it is easy to kill from another
// function.
Function statsPlotLag(inWave)
	Wave inWave

	Variable num=numpnts(inWave)
	Display /W=(5,45,470,405)  inWave[1,num-1] vs inWave[0,num-2]
	// comment the following line if you don't want to name the window.
	DoWindow/C WM_LAG_PLOT
	ModifyGraph margin(top)=26
	ModifyGraph mode=3
	ModifyGraph lblMargin(left)=9,lblMargin(bottom)=17
	ModifyGraph axOffset(bottom)=2
	ModifyGraph lblLatPos(left)=1
	Label left "Y\\Bi"
	Label bottom "Y\\Bi-1"
	TextBox/N=text0/F=0/A=MC/X=-39.70/Y=55.51 ksLagPlot
End
//==========================================================================================
// The following function plots an autocorrelation for the input wave.  It also names the window so it can be killed from
// another procedure.
Function statsAutoCorrPlot(inWave)
	Wave inWave
	
	Duplicate/O inWave,corWave
	Correlate/C corWave,corWave
	Display /W=(5,45,470,405)  corWave
	DoWindow/C WM_AutoCor_PLOT
	Label left ksAutoCorrelation
	Label bottom ksLag
	TextBox/N=text0/F=0/A=MC/X=-26.90/Y=46.31 ksAutoCorrelationPlot
End
//==========================================================================================
// The following function can be used to display a histogram of inWave.  The function names the window so it is easy to kill from
// another procedure.
Function statsPlotHistogram(inWave)
	Wave inWave
	
	Make/O hResults
	Histogram/B=3 inWave,hResults					// /B=4 is another option.
	Display /W=(5,45,470,405)  hResults,hResults	// the second is used for the outline.
	DoWindow/C WM_HIST_PLOT
	ModifyGraph margin(top)=32
	ModifyGraph mode=5
	ModifyGraph rgb(hResults#1)=(0,0,65535)
	ModifyGraph hbFill(hResults)=2
	Label left ksCounts
	Label bottom ksY
	TextBox/N=text0/F=0/A=MC/X=-39.63/Y=56.23 ksHistogram
End

//==========================================================================================
// The following function creates a single box plot.  It uses Sort which is probably not as elegant as using StatsQuantiles but it
// was written before StatsQuantiles and if it aint broke...
// 13OCT06 changed to returning the name of the graph window.

constant kStartFence=1
constant kStartx=1.25
constant kEndX=1.75
constant kEndFence=2
constant kMidX=1.5

Function/S statsBoxPlot(inWave)
	Wave inWave
	
	String outWinName=""
	String folderName=UniqueName(NameOfWave(inWave), 11, 0)
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S BoxPlot
	NewDataFolder/O/S $folderName
	
	Duplicate/O inWave, tmpWave
	Sort tmpWave,tmpWave
	Variable N=DimSize(tmpWave,0)
	Variable theMedian=tmpWave((N-1)/2)
	Variable Q25=tmpWave((N-1)/4)
	Variable Q75=tmpWave(3*(N-1)/4)
	Variable H=Q75-Q25
	Variable step=1.5*H
	Variable upperInnerFence=Q75+step
	Variable upperOuterFence=upperInnerFence+step
	Variable lowerInnerFence=Q25-step
	Variable lowerOuterFence=lowerInnerFence-step

	Make/O/N=(21,2) fencesWave=NaN
	fencesWave[][0]=mod(p,3)==0 ? kStartFence : kEndFence
	fencesWave[][0]=mod(p+1,3)==0 ? NaN : fencesWave
	fencesWave[0,2][1]=lowerOuterFence
	fencesWave[3,5][1]=lowerInnerFence
	fencesWave[6,8][1]=Q25
	fencesWave[9,11][1]=theMedian
	fencesWave[12,14][1]=Q75
	fencesWave[15,17][1]=upperInnerFence
	fencesWave[18,20][1]=upperOuterFence
	
	Duplicate/O tmpWave, xWave
	xWave=1.5
	
	Display/W=(5,45,470,405)  fencesWave[*][1] vs fencesWave[*][0]
	// 13OCT06 if used from Ancilla we want to name it and kill it later.
	outWinName=UniqueName("WM_BOX_PLOT",6,0)
	DoWindow/C $outWinName
	
	AppendToGraph tmpWave vs xWave
	ModifyGraph rgb(tmpWave)=(0,0,0)
	ModifyGraph margin(right)=221
	ModifyGraph mode(tmpWave)=3
	ModifyGraph marker(tmpWave)=8
	ModifyGraph zColor(fencesWave)={fencesWave[*][1],*,*,Rainbow}
	Tag/N=text0/F=0/X=44.96/Y=0.00 fencesWave, 1, ksOuterFence
	Tag/N=text1/F=0/X=44.96/Y=0.00 fencesWave, 4, ksInnerFence
	Tag/N=text4/F=0/X=44.96/Y=0.00 fencesWave, 10, ksMedian
	Tag/N=text3/F=0/X=44.96/Y=0.00 fencesWave, 7, ksLowerHinge
	Tag/N=text5/F=0/X=44.96/Y=0.00 fencesWave, 13, ksUpperHinge
	Tag/N=text6/F=0/X=44.96/Y=0.00 fencesWave, 16, ksInnerFence
	Tag/N=text7/F=0/X=44.96/Y=0.00 fencesWave, 19,ksOuterFence
	
	// Now the box & wiskers:
	Make/O/N=(20,2) boxLine=NaN
	boxLine[0,3][1]=lowerInnerFence
	boxLine[0][0]=kStartX
	boxLine[1][0]=kEndX
	
	boxLine[3,4][0]=kMidX
	boxLine[4,7][1]=Q25
	boxLine[6][0]=kStartX
	boxLine[7,8][0]=kEndX
	boxLine[8,9][1]=Q75
	boxLine[9,10][0]=kStartX
	boxLine[10][1]=Q25
	boxLine[12][0]=kStartX
	boxLine[12,13][1]=theMedian
	boxLine[13][0]=kEndX
	boxLine[15,16][0]=kMidX
	boxLine[15][1]=Q75
	boxLine[16,19][1]=upperInnerFence
	boxLine[18][0]=kStartX
	boxLine[19][0]=kEndX
	
	AppendToGraph 	boxLine[*][1] vs boxLine[*][0]
	ModifyGraph lsize(boxLine)=2
	SetDataFolder oldDF
	return outWinName
End
//==========================================================================================
// The following function produces a probability plot using the style described by NIST
//  http://www.itl.nist.gov/div898/handbook/eda/section3/normprpl.htm
// The same principle can be applied with non-normal distributions.  The only change is that
// StatsInvNormalCDF() should be replaced by the inverseCDF of the appropriate function.  Note
// that in this case the inverse CDF if computed for previously computed mean and stdv.
// 13OCT06 changed to return window name.
//  22MAR07 added /K=1 to the display command.

Function/S statsProbPlot(inWave)
	Wave inWave
	
	String outWinName=""
	Duplicate/O inWave,tmpWave,xWave
	Sort tmpWave,tmpWave
	Variable num=numpnts(inWave)
	xWave=(p-0.3175)/(num+0.365)
	WaveStats/Q inWave
	xWave=StatsInvNormalCDF(xWave,V_avg,V_sdev)
	Variable/G V_fitOptions=4
	CurveFit/Q line  tmpWave /X=xWave /D
	Wave fit_tmpWave
	Display/K=1 /W=(5,45,470,405)  tmpWave vs xWave
	outWinName=UniqueName("WM_PROB_PLOT",6,0)
	DoWindow/C $outWinName
	AppendToGraph fit_tmpWave
	ModifyGraph mode(tmpWave)=4
	TextBox/N=text0/F=0/A=MC/X=-26.90/Y=47.62 ksNormalProbPlot
	return outWinName
End
//==========================================================================================
// Given two histograms in wave1 and wave2, the following function displays them as a bi-histogram, i.e.,
// one above the other.
Function WM_PlotBiHistogram(wave1,wave2)
	Wave wave1,wave2

	Display /L=L1/B=btm wave1
	AppendToGraph/L=L2/B=btm wave2
	ModifyGraph margin(left)=58
	ModifyGraph mode=5
	ModifyGraph freePos(L1)={0,kwFraction}
	ModifyGraph freePos(btm)={0.5,kwFraction}
	ModifyGraph freePos(L2)={0,kwFraction}
	ModifyGraph axisEnab(L1)={0.5,1}
	ModifyGraph axisEnab(L2)={0,0.5}
	SetAxis/A/R L2
End
//==========================================================================================
// The following are general notebook writing utilities:
//========================================================================================
Function WM_catNotebookPlain(notebookName,str)
	String notebookName,str
	
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlertText1
		return 0
	endif
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=0
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
// The following function adds the provided string to the bottom of the current notebook and appends a CR.
Function WM_catNotebookBold(notebookName,str)
	String notebookName,str
	
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlertText1
		return 0
	endif
	Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
Function WM_catNotebookPair(notebookName,str,value)
	String notebookName,str
	Variable value
	
	String valueStr
	sprintf valueStr,"%g",value
	if(WinType(notebookName)!=5)				// check that the notebook was not closed
		DoAlert 0,ksAlertText1
		return 0
	endif

	str+="="
	Notebook $notebookName selection={endOfFile,endOfFile},fStyle=1
	Notebook $notebookName selection={endOfFile,endOfFile},text=str,fStyle=0
	Notebook $notebookName selection={endOfFile,endOfFile},text=valueStr
	Notebook $notebookName selection={endOfFile,endOfFile},text="\r",fStyle=0
End
//==========================================================================================
