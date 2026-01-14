#pragma rtGlobals=1		// Use modern global access method.

#include <StatsPlots>

//========================================================================================
// dataWave is a 2D matrix which has 4 rows and (n+2) columns where n is the number of replicates.
// The first two columns contain the levels of the two factors which represent each row.  You should use
// real levels -- these are converted internally into low/high normalized formats.  If you do not have 
// numrical values enter -1 for low and +1 for high.  The first column data is
// regarded as factor A and the second column as factor B.
// Equations are taken from R.H. Myers and D.C. Montgomery "Response Surface Methodology"
// ISBN 0-471-58100-3.

//========================================================================================
Function twoLevelSquareDesign(dataWave)
	Wave dataWave
	
	if(DimSize(dataWave,0)!=4)
		doAlert 0,"Improper input wave.  Check the documentation for required format."
	endif
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S twoLevelSquareDesign
	String/G notebookName=UniqueName("twoLevelSquare",10,0)
	NewNotebook /F=1/K=0/N=$notebookName  as "2^2 Design"
	DoWindow/B $notebookName
	String str="Analysis of 2^2 Design for the wave: "+NameOfWave(dataWave)
	WM_catNotebookBold(notebookName,str)
	WM_catNotebookBold(notebookName,"\r")
	str=date()+"; "+time()
	WM_catNotebookPlain(notebookName,str)
	WM_catNotebookBold(notebookName,"\r")
	
	// first convert the matrix into "standard" so that row0 corresponds to the origin (1), 
	// row1 to the max on x-axis (a), row2 to the max on y-axis (b) and row3 to the diagonal point (ab).
	ImageTransform/G=0 getCol dataWave
	Variable Amin,Amax,Bmin,Bmax
	Wave W_ExtractedCol
	Duplicate/O W_ExtractedCol,Awave
	Amin=WaveMin(Awave)
	Amax=WaveMax(Awave)
	ImageTransform/G=1 getCol dataWave
	Duplicate/O W_ExtractedCol,Bwave
	Bmin=WaveMin(Bwave)
	Bmax=WaveMax(Bwave)
	WM_catNotebookPair(notebookName,"Amin",Amin)
	WM_catNotebookPair(notebookName,"Amax",Amax)
	WM_catNotebookPair(notebookName,"Bmin",Bmin)
	WM_catNotebookPair(notebookName,"Bmax",Bmax)

	// identify the order of the rows and store it in an index wave: rowOrder
	Make/O/N=4/b/u  rowOrder=0
	Variable i,j,index,replicates,ncols=DimSize(dataWave,1)
	replicates=ncols-2
	
	for(i=0;i<4;i+=1)
		if(Awave[i]==Amin)
			if(BWave[i]==Bmin)
				rowOrder[i]=0
			else
				rowOrder[i]=2
			endif
		else
			if(Bwave[i]==Bmin)
				rowOrder[i]=1
			else
				rowOrder[i]=3
			endif
		endif
	endfor
	
	Make/O/N=4 sumRowsWave=0
	for(i=0;i<4;i+=1)
		index=rowOrder[i]
		for(j=2;j<ncols;j+=1)
			sumRowsWave[i]+=dataWave[index][j]
		endfor
	endfor
	
	Make/O/N=3 effectsWave=0
	SetDimLabel 0,0,Effect_A,effectsWave
	SetDimLabel 0,1,Effect_B,effectsWave
	SetDimLabel 0,2,Effect_AB,effectsWave
	
	// See eqs (3.1)-(3.3)
	effectsWave[0]=(sumRowsWave[3]+sumRowsWave[1]-sumRowsWave[2]-sumRowsWave[0])/(2*replicates)
	effectsWave[1]=(sumRowsWave[3]+sumRowsWave[2]-sumRowsWave[1]-sumRowsWave[0])/(2*replicates)
	effectsWave[2]=(sumRowsWave[3]+sumRowsWave[0]-sumRowsWave[1]-sumRowsWave[2])/(2*replicates)
	WM_catNotebookPlain(notebookName,"\r")
	WM_catNotebookPair(notebookName,"Effect A",effectsWave[0])
	WM_catNotebookPair(notebookName,"Effect B",effectsWave[1])
	WM_catNotebookPair(notebookName,"Effect AB",effectsWave[2])
	WM_catNotebookPlain(notebookName,"\r\r")

	// Calculate the various SS quantities:
	Make/O/N=5 SSWave=0
	SetDimLabel 0,0,SS_A,SSWave
	SetDimLabel 0,1,SS_B,SSWave
	SetDimLabel 0,2,SS_AB,SSWave
	SetDimLabel 0,3,SS_E,SSWave
	SetDimLabel 0,4,SS_T,SSWave
	// The following is less efficient but is meant to show the relationship between teh effects and the SS quantities.
	SSWave[0]=((2*replicates)*effectsWave[0])^2/(4*replicates)
	SSWave[1]=((2*replicates)*effectsWave[1])^2/(4*replicates)
	SSWave[2]=((2*replicates)*effectsWave[2])^2/(4*replicates)
	
	// calculate SST
	Variable element,theSum=0,theSumSqr=0
	for(i=0;i<4;i+=1)
		index=rowOrder[i]
		for(j=2;j<ncols;j+=1)
			element=dataWave[index][j]
			theSum+=element
			theSumSqr+=element^2
		endfor
	endfor
	SSWave[4]=theSumSqr-theSum^2/(4*replicates)
	
	// SSE=SST-SSA-SSB-SSAB
	SSWave[3]=SSWave[4]-SSWave[0]-SSWave[1]-SSWave[2]
	
	// Prepare the ANOVA table:
	Make/O/T/N=5 varSourceTitle={"A","B","AB","Error","Total"}
	Make/O/N=5 dfWave={1,1,1,4*(replicates-1),(4*replicates-1)}
	Make/O/N=4 msWave=SSWave[p]/dfWave[p]
	Make/O/N=3 FWave=msWave[p]/msWave[3]
	Make/O/N=3 PValueWave=1-StatsFCDF(FWave[p],1,dfWave[3])			// using error df.
	String tableName=UniqueName("twoSquareTable",7,0)
	Edit/K=1/W=(16,44,583,264)/N=$tableName varSourceTitle,SSWave,dfWave,msWave,FWave,PValueWave
	ModifyTable format(Point)=1,width(varSourceTitle)=56,width(dfWave)=58
	WM_catNotebookBold(notebookName,"ANOVA Table:")
	Notebook $notebookName ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	WM_catNotebookPlain(notebookName,"\r")
	
	// Compute the regression model:
	Duplicate/O/R=[][2, ]  dataWave,localData
	MatrixTranspose localData
	Redimension/N=(4*replicates) localData			// converted into a single column.
	Make/O/N=(4*replicates,3)	xWave=1,scatterWave
	index=0
	for(i=0;i<replicates;i+=1)
		xWave[index+i][1]=-1
		xWave[index+i][2]=-1
		scatterWave[index+i][0]=Amin
		scatterWave[index+i][1]=Bmin
	endfor
	index+=replicates
	for(i=0;i<replicates;i+=1)
		xWave[index+i][1]=1
		xWave[index+i][2]=-1
		scatterWave[index+i][0]=Amax
		scatterWave[index+i][1]=Bmin
	endfor
	index+=replicates
	for(i=0;i<replicates;i+=1)
		xWave[index+i][1]=-1
		xWave[index+i][2]=1
		scatterWave[index+i][0]=Amin
		scatterWave[index+i][1]=Bmax
	endfor
	index+=replicates
	for(i=0;i<replicates;i+=1)
		xWave[index+i][1]=1
		xWave[index+i][2]=1
		scatterWave[index+i][0]=Amax
		scatterWave[index+i][1]=Bmax
	endfor
	
	scatterWave[][2]=localData[p]
	
	MatrixLLS xWave,localData
	Wave M_B
	Duplicate/O/R=[0,2] M_B, regressionCoefficients
	WM_catNotebookBold(notebookName,"Regression Coefficients:")
	WM_catNotebookPlain(notebookName,"y=b0+b1*factorA+b2*factorB")
	WM_catNotebookPair(notebookName,"b0",regressionCoefficients[0])
	WM_catNotebookPair(notebookName,"b1",regressionCoefficients[1])
	WM_catNotebookPair(notebookName,"b2",regressionCoefficients[2])
	
	// Compute the residuals:
	MatrixOP/O residuals=localData-(xWave x regressionCoefficients)
	
	// Normal probability plot for the residuals:
	WM_catNotebookBold(notebookName,"\rProbability Plot for the Residuals:")
	String nameOfWindow=UniqueName("ProbabilityGraph",6,0)
	statsProbPlot(residuals)
	DoWindow/C $nameOfWindow
	ModifyGraph mode(tmpWave)=3,marker(tmpWave)=19
	Notebook $notebookName picture={$nameOfWindow,-5,1}
	DoWindow/K $nameOfWindow

	// Create a surface plot for the model:
	WM_catNotebookBold(notebookName,"\rResponse Surface:")
	nameOfWindow=UniqueName("responseSurfaceImage",6,0)
	Make/O/N=(50,50) responseSurface
	SetScale/I x (-1),(1),"", responseSurface			// set the scaling for the calculation
	SetScale/I y (-1),(1),"", responseSurface
	responseSurface=regressionCoefficients[0]+regressionCoefficients[1]*x+regressionCoefficients[2]*y
	SetScale/I x (Amin),(Amax),"", responseSurface	// reset the scaling for the graph
	SetScale/I y (Bmin),(Bmax),"", responseSurface
	
	Display /W=(147,44,611,400)/K=1 
	AppendMatrixContour/T responseSurface
	DoWindow/C $nameOfWindow
	ModifyContour responseSurface rgbLines=(65535,0,0), labels=0
	AppendImage/T responseSurface
	ModifyImage responseSurface ctab= {*,*,Rainbow,0}
	ModifyGraph margin(left)=25,margin(bottom)=14,margin(top)=25,margin(right)=14
	ModifyGraph mirror=2
	ModifyGraph nticks=3
	ModifyGraph minor=1
	ModifyGraph fSize=9
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	Label left "Factor A"
	Label top "Factor B"
	SetAxis/A/R left
	doUpdate														// Without this there is no image -- just the axes.
	Notebook $notebookName picture={$nameOfWindow,-5,1}
	DoWindow/K $nameOfWindow
	
	
	WM_catNotebookBold(notebookName,"\rResponse Surface and Original Data:")
	Execute "NewGizmo/K=1/N=GResponseSurf"
	Execute "AppendToGizmo defaultSurface=responseSurface"
	Execute "AppendToGizmo defaultScatter=scatterWave"
	Execute "ModifyGizmo ModifyObject=scatter0 property={ size,0.25}"
	Execute "ModifyGizmo showAxisCue=1"
	Execute "ExportGizmo Clip"

	LoadPict/Q "Clipboard"
	if(V_flag)
		DoWindow/K	GResponseSurf		
		String pictName=StringByKey("NAME", S_info)
		if(strlen(pictName)>0)
			notebook $notebookName, picture={$pictName,-5,1}
		endif
		KillPICTs/Z $pictName
	endif
	
	// convert all images to PNG at 2x resolution
//	Notebook $notebookName selection={startOfFile,endOfFile} 
//	Notebook $notebookName convertToPNG=2

	
	KillWaves/Z W_ExtractedCol,localData ,xWave,M_A,M_B
	SetDataFolder oldDF
	DoWindow/F $notebookName
End

//========================================================================================
