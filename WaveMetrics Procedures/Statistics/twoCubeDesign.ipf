#pragma rtGlobals=1		// Use modern global access method.

#include <StatsPlots>

//========================================================================================
// AG23MAR07
// dataWave is a 2D matrix which has 8 rows and (n+3) columns where n is the number of replicates.
// The first three columns contain the levels of the three factors which represent each row.  You should use
// real levels -- these are converted internally into low/high normalized formats.  If you do not have 
// numrical values enter -1 for low and +1 for high.  The first column data is
// regarded as factor A, the second column as factor B and the third as factor C.
// Equations are taken from R.H. Myers and D.C. Montgomery "Response Surface Methodology"
// ISBN 0-471-58100-3.

//========================================================================================

Function twoLevelCubeDesign(dataWave)
	Wave dataWave
	
	if(DimSize(dataWave,0)!=8)
		doAlert 0,"Improper input wave.  Check the documentation for required format."
	endif
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S twoLevelCubeDesign
	
	String/G notebookName=UniqueName("twoLeveCube",10,0)
	NewNotebook /F=1/K=0/N=$notebookName  as "2^3 Design"
	DoWindow/B $notebookName
	String str="Analysis of 2^3 Design for the wave: "+NameOfWave(dataWave)+"\r"
	WM_catNotebookBold(notebookName,str)
	str=date()+"; "+time()+"\r"
	WM_catNotebookPlain(notebookName,str)
	
	// first convert the matrix into "standard" form by creating an index wave
	Variable Amin,Amax,Bmin,Bmax,Cmin,Cmax
	ImageTransform/G=0 getCol dataWave
	Duplicate/O W_ExtractedCol,Awave
	Amin=WaveMin(Awave)
	Amax=WaveMax(Awave)
	
	ImageTransform/G=1 getCol dataWave
	Duplicate/O W_ExtractedCol,Bwave
	Bmin=WaveMin(Bwave)
	Bmax=WaveMax(Bwave)
	
	ImageTransform/G=2 getCol dataWave
	Duplicate/O W_ExtractedCol,Cwave
	Cmin=WaveMin(Cwave)
	Cmax=WaveMax(Cwave)
	
	Make/O/N=8/b/u  rowOrder=0
	Variable i,j,index,replicates,ncols=DimSize(dataWave,1)
	replicates=ncols-3
	
	for(i=0;i<8;i+=1)
		if(Awave[i]==Amin)
			if(BWave[i]==Bmin)
				if(CWave[i]==Cmin)
					rowOrder[i]=0
				else
					rowOrder[i]=4
				endif
			else
				if(CWave[i]==Cmin)
					rowOrder[i]=2
				else
					rowOrder[i]=6
				endif
			endif
		else
			if(Bwave[i]==Bmin)
				if(CWave[i]==Cmin)
					rowOrder[i]=1
				else
					rowOrder[i]=5
				endif
			else
				if(CWave[i]==Cmin)
					rowOrder[i]=3
				else
					rowOrder[i]=7
				endif
			endif
		endif
	endfor
	
	Make/O/N=8 sumRowsWave=0
	for(i=0;i<8;i+=1)
		index=rowOrder[i]
		for(j=3;j<ncols;j+=1)
			sumRowsWave[i]+=dataWave[index][j]
		endfor
	endfor
	
	Make/O/N=7 effectsWave=0
	SetDimLabel 0,0,Effect_A,effectsWave
	SetDimLabel 0,1,Effect_B,effectsWave
	SetDimLabel 0,2,Effect_C,effectsWave
	SetDimLabel 0,3,Effect_AB,effectsWave
	SetDimLabel 0,4,Effect_AC,effectsWave
	SetDimLabel 0,5,Effect_BC,effectsWave
	SetDimLabel 0,6,Effect_ABC,effectsWave
	
	// A
	effectsWave[0]=(sumRowsWave[1]-sumRowsWave[0]+sumRowsWave[3]-sumRowsWave[2]+sumRowsWave[5]-sumRowsWave[4]+sumRowsWave[7]-sumRowsWave[6])/(4*replicates)
	// B
	effectsWave[1]=(sumRowsWave[2]+sumRowsWave[3]+sumRowsWave[6]+sumRowsWave[7]-sumRowsWave[0]-sumRowsWave[1]-sumRowsWave[4]-sumRowsWave[5])/(4*replicates)
	// C
	effectsWave[2]=(sumRowsWave[4]+sumRowsWave[5]+sumRowsWave[6]+sumRowsWave[7]-sumRowsWave[0]-sumRowsWave[1]-sumRowsWave[2]-sumRowsWave[3])/(4*replicates)
	// AB
	effectsWave[3]=(sumRowsWave[3]-sumRowsWave[1]-sumRowsWave[2]+sumRowsWave[0]+sumRowsWave[7]-sumRowsWave[6]-sumRowsWave[5]+sumRowsWave[4])/(4*replicates)
	// AC
	effectsWave[4]=(sumRowsWave[0]-sumRowsWave[1]+sumRowsWave[2]-sumRowsWave[3]-sumRowsWave[4]+sumRowsWave[5]-sumRowsWave[6]+sumRowsWave[7])/(4*replicates)
	// BC
	effectsWave[5]=(sumRowsWave[0]+sumRowsWave[1]-sumRowsWave[2]-sumRowsWave[3]-sumRowsWave[4]-sumRowsWave[5]+sumRowsWave[6]+sumRowsWave[7])/(4*replicates)
	// ABC
	effectsWave[6]=(sumRowsWave[7]-sumRowsWave[6]-sumRowsWave[5]+sumRowsWave[4]-sumRowsWave[3]+sumRowsWave[2]+sumRowsWave[1]-sumRowsWave[0])/(4*replicates)
	
	WM_catNotebookPlain(notebookName,"\r")
	WM_catNotebookPair(notebookName,"Effect A",effectsWave[0])
	WM_catNotebookPair(notebookName,"Effect B",effectsWave[1])
	WM_catNotebookPair(notebookName,"Effect C",effectsWave[2])
	WM_catNotebookPair(notebookName,"Effect AB",effectsWave[3])
	WM_catNotebookPair(notebookName,"Effect AC",effectsWave[4])
	WM_catNotebookPair(notebookName,"Effect BC",effectsWave[5])
	WM_catNotebookPair(notebookName,"Effect ABC",effectsWave[6])
	WM_catNotebookPlain(notebookName,"\r\r")
	
	Make/O/N=9 SSWave=0
	for(i=0;i<7;i+=1)
		SSWave[i]=((4*replicates)*effectsWave[i])^2/(8*replicates)
	endfor
	
	// calculate SST
	Variable element,theSum=0,theSumSqr=0
	for(i=0;i<8;i+=1)
		index=rowOrder[i]
		for(j=3;j<ncols;j+=1)
			element=dataWave[index][j]
			theSum+=element
			theSumSqr+=element^2
		endfor
	endfor
	SSWave[8]=theSumSqr-theSum^2/(8*replicates)
	
	// calculate SSE
	SSWave[7]=SSWave[8]-SSWave[0]-SSWave[1]-SSWave[2]-SSWave[3]-SSWave[4]-SSWave[5]-SSWave[6]
	
	// Prepare the ANOVA table:
	Make/O/T/N=9 varSourceTitle={"A","B","C","AB","AC","BC","ABC","Error","Total"}
	Make/O/N=9 dfWave={1,1,1,1,1,1,1,(8*replicates-8),(8*replicates-1)}
	Make/O/N=8 msWave=SSWave[p]/dfWave[p]
	Make/O/N=7 FWave=msWave[p]/msWave[7]
	Make/O/N=7 PValueWave=1-StatsFCDF(FWave[p],1,dfWave[7])			// using error df.
	String tableName=UniqueName("twoCubeTable",7,0)
	Edit/K=1/W=(16,44,583,264)/N=$tableName varSourceTitle,SSWave,dfWave,msWave,FWave,PValueWave
	ModifyTable format(Point)=1,width(varSourceTitle)=56,width(dfWave)=58
	WM_catNotebookBold(notebookName,"ANOVA Table:")
	Notebook $notebookName ruler=Normal, picture={$tableName, -5, 1}
	DoWindow/K $tableName
	WM_catNotebookPlain(notebookName,"\r")

	// significance of effects:
	Variable se=sqrt(msWave[7]/(replicates*2))
	WM_catNotebookPair(notebookName,"Standard Error of each effect se",se)
	
	WM_catNotebookPlain(notebookName,"(95% confidence intervals are effects for which the inverval of their value +- se does not include 0)")
	for(i=0;i<7;i+=1)
		if(effectsWave[i]+se>0 && effectsWave[i]-se<0)
		else
			str="Significat effect "+varSourceTitle[i]
			WM_catNotebookPlain(notebookName,str)
		endif
	endfor
	KillWaves/Z Awave,Bwave,Cwave,rowOrder
	SetDataFolder oldDF
	DoWindow/F $notebookName
End