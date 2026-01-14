#pragma rtGlobals=1		// Use modern global access method.

#include <StatsPlots>

// AG 14MAR07
// Equations are taken from R.H. Myers and D.C. Montgomery "Response Surface Methodology"
// ISBN 0-471-58100-3.

constant alpha=0.05

//========================================================================================
// First order linear regression analysis.
// ymat is the dependent 1D wave.
// xmat contains the independent variables.  Must have the same number of rows as ymat.  The number of columns
// in xmat is equal to the number of regression coefficients sought.  The first column of xmat corresponds to the constant term
// and should be set to 1.
// All the results are directed to a uniquely named formatted notebook.  All the relevant waves and variables are stored in 
// root:Packages:MLRFirstOrder.  Note that the data in this folder is overwritten each time you run MLRFirstOrder().
//========================================================================================
Function MLRFirstOrder(ymat,xmat)
	Wave ymat,xmat
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S MLRFirstOrder
	
	Variable dimP=DimSize(xmat,1)
	Variable dimN=DimSize(ymat,0)
	
	if(dimN!=DimSize(xmat,0))
		doAlert 0,"Matrix size mismatch"
		return 0
	endif
	
	String/G notebookName=UniqueName("firstOrderMLR",10,0)
	NewNotebook /F=1/K=0/N=$notebookName  as "First Order MLR"
	String str="First Order Multi-Linear Regression Analysis for the waves: "+NameOfWave(ymat)+" and " +NameOfWave(xmat)
	WM_catNotebookBold(notebookName,str)
	WM_catNotebookBold(notebookName,"\r")

	matrixLLS xmat,ymat
	Wave M_B
	Duplicate/O M_B,betaWave
	Redimension/N=(dimP) betaWave							// LLS can give more values than necessary.
	
	WM_catNotebookBold(notebookName,"Regression Coefficients:")
	Variable i
	for(i=0;i<dimP;i+=1)
		str="beta"+num2str(i)
		WM_catNotebookPair(notebookName,str,betaWave[i])
	endfor
	
	Variable SSE
	MatrixOP/O BXY=((betaWave^t) x (xmat^t) x ymat)
	MatrixOP/O aa=((ymat^t) x ymat) - BXY
	SSE=aa[0]
	Variable estimatedSigma2=SSE/(dimN-dimP)				// p.27
	
	WM_catNotebookPair(notebookName,"\rEstimated Sigma^2",estimatedSigma2)
	WM_catNotebookPair(notebookName,"Estimated Sigma",sqrt(estimatedSigma2))

	MatrixOP/O aa=BXY - powr(sum(ymat),2)/dimN			// p. 29
	Variable SSR=aa[0]
	Variable Syy=SSE+SSR
	Variable determinationR2=SSR/Syy
	Variable determinationR2Adj=1-((dimN-1)/(dimN-dimP))*(1-determinationR2)		// (2.26)
	
	WM_catNotebookPair(notebookName,"R^2",determinationR2)
	WM_catNotebookPair(notebookName,"R^2 (Adjusted)",determinationR2Adj)
	
	WM_catNotebookBold(notebookName,"\rTesting the significance of the regression:")
	WM_catNotebookPlain(notebookName,"(F>F_Critical to reject H0 that all betas are zero)")
	
	// Test H0: all betas =0
	// H1: at least one beta is non zero
	Variable degreeF=dimP-1			// k in the notation of the book
	Variable MSR=SSR/degreeF
	Variable MSE=SSE/(dimN-degreeF-1)
	Variable F0=MSR/MSE																	// (2.21)
	Variable CriticalF=statsInvFCDF(1-alpha,degreeF,dimN-degreeF-1)

	WM_catNotebookPair(notebookName,"SSR",SSR)
	WM_catNotebookPair(notebookName,"SSE",SSE)
	WM_catNotebookPair(notebookName,"Syy",Syy)
	WM_catNotebookPair(notebookName,"F",F0)
	WM_catNotebookPair(notebookName,"F_Critical",CriticalF)
	WM_catNotebookPair(notebookName,"P_Value",1-StatsFCDF(F0,degreeF,dimN-dimP))
		
	// Testing the individual significance of each beta:
	WM_catNotebookBold(notebookName,"\rTesting the individual significance of the regression coefficients")
	WM_catNotebookPlain(notebookName,"Abs(t)>t_Critical implies significant contribution to the model")

	MatrixOP/O CC=Inv((xmat^t) x xmat)
	Variable tStatistic,tCritical
	tCritical=StatsInvStudentCDF(1-alpha/2,dimN-degreeF-1)
	WM_catNotebookPair(notebookName,"Critical t-value",tCritical)
	for(i=0;i<dimP;i+=1)
		tStatistic=betaWave[i]/sqrt(estimatedSigma2*CC[i][i])
		str="beta"+num2str(i)+" ---  t"
		WM_catNotebookPair(notebookName,str,tStatistic)
	endfor
	
	// Confidence intervals for the coefficients: Section 2.5
	WM_catNotebookBold(notebookName,"\rConfidence intervals for regression coefficients:")
	Variable dt=StatsInvStudentCDF(1-alpha/2,dimN-dimP),delta
	for(i=0;i<dimP;i+=1)
		delta=dt*sqrt(estimatedSigma2*CC[i][i])
		sprintf str, "(%d) [%g  ,  %g]",i,betaWave[i]-delta,betaWave[i]+delta
		WM_catNotebookPlain(notebookName,str)
	endfor
	
	WM_catNotebookPlain(notebookName,"\r")
	WM_catNotebookBold(notebookName,"Representations of the residuals")
	// Calculate various forms of residuals:
	MatrixOP/O fittedValues=xmat x betaWave
	MatrixOP/O rawResiduals=ymat-fittedValues

	String graphName=UniqueName("Graph", 6, 0)
	Display /W=(35,44,585,369)/K=1  rawResiduals
	DoWindow/C $graphName
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph lblMargin(left)=8,lblMargin(bottom)=5
	ModifyGraph axOffset(bottom)=0.333333
	ModifyGraph lblLatPos(bottom)=1
	Label left "Raw Residual Value"
	Label bottom "Point Number"
	TextBox/C/N=text0/F=0/A=MC/X=-40.00/Y=46.44 "Raw Residuals"
	Notebook $notebookName, picture={$graphName,-5,1}
	DoWindow/K $graphName
	
	Variable sigma=sqrt(estimatedSigma2)
	MatrixOP/O standardizedResiduals=rawResiduals/sigma
	
	WM_catNotebookPlain(notebookName,"\r")
	Display /W=(35,44,585,369)/K=1  standardizedResiduals
	ModifyGraph margin(top)=25
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph lblMargin(left)=8,lblMargin(bottom)=5
	ModifyGraph axOffset(bottom)=0.333333
	ModifyGraph lblLatPos(bottom)=1
	Label left "StandardizedResiduals Residual Value"
	Label bottom "Point Number"
	TextBox/C/N=text0/F=0/A=MC/X=-29.36/Y=54.90 "StandardizedResiduals Residuals"
	Notebook $notebookName, picture={$graphName,-5,1}
	DoWindow/K $graphName
	
	// compute the hat matrix:
	MatrixOP/O hatMatrix=xmat x CC x (xmat^t)
	Make/O/N=(dimN) hatDiagonal=hatMatrix[p][p]
	Duplicate/O rawResiduals,studentizedResiduals,PRESSResiduals,ti_residuals,Si2,influenceDi
	studentizedResiduals=rawResiduals/sqrt(estimatedSigma2*(1-hatDiagonal[p]))
	// compute the PRESS residuals:  based on eq. (2.52)
	PRESSResiduals=rawResiduals/(1-hatDiagonal[p])
	MatrixOP/O pressStatw=sum(PRESSResiduals*PRESSResiduals)
	
	
	WM_catNotebookPair(notebookName,"PRESS Statistic",pressStatw[0])

	Variable R2Prediction=1-pressStatw[0]/Syy		// eq. (2.54)
	WM_catNotebookPair(notebookName,"R^2 Prediction",R2Prediction)
	
	Si2=((dimN-dimP)*MSE-rawResiduals[p]*PRESSResiduals[p])/(dimN-dimP-1)
	ti_residuals=rawResiduals/sqrt(Si2[p]*(1-hatDiagonal[p]))
	// Leverage Point comparison with hatDiagonal Sec. 2.7.3
	Variable leverageThreshold=2*dimP/dimN
	WM_catNotebookPair(notebookName,"Leverage Point threshold",leverageThreshold)
	WM_catNotebookPlain(notebookName,"(compare values in hatDiagonal to this value)")
	
	// Calculating influence of points based on eq. (2.59)
	// Values in this wave should be compared with 1.  Anything larger than 1 is bad.
	influenceDi=studentizedResiduals[p]^2*hatDiagonal[p]/(dimP*(1-hatDiagonal[p]))
	// Edit ymat,fittedValues,rawResiduals,hatDiagonal,studentizedResiduals,ti_residuals,influenceDi
	addTable(notebookName,ymat,fittedValues,rawResiduals,hatDiagonal,studentizedResiduals,ti_residuals,influenceDi)
	
	KillWaves/Z aa,cc,BXY,M_A,pressStatw,Si2,hatMatrix,M_B
	SetDataFolder oldDF
	DoWindow/F $notebookName
End


//========================================================================================
// Follows the discussion in section 2.4 P. 32 on.
// testedComponentsWave is a 1D wave which has the same number of rows as the 
// number of columns in xmat (i.e., a row for each regression coefficient) with 0 entries
// corresponding to elements that are eliminated from the model and any non-zero entries
// designate elements that contribute to the model.
//========================================================================================
Function MLRPartialSignificance(ymat,xmat,testedComponentsWave)
	Wave ymat,xmat,testedComponentsWave
	
	// Test dimensions:
	Variable dimP=DimSize(xmat,1)
	Variable dimN=DimSize(ymat,0)
	
	if(dimN!=DimSize(xmat,0) || dimSize(testedComponentsWave,0)!=dimP)
		doAlert 0,"Matrix size mismatch"
		return 0
	endif
	
	// Repeat the solution as above to get SSR 
	matrixLLS xmat,ymat
	Wave M_B
	Redimension/N=(dimP) M_B
	MatrixOP/O BXY=((M_B^t) x (xmat^t) x ymat)
	MatrixOP/O aa=BXY - powr(sum(ymat),2)/dimN			// p. 29
	Variable SSR=aa[0]
	MatrixOP/O aa=((ymat^t) x ymat) - BXY
	Variable SSE=aa[0]
	
	// Create Alternative matrix X2
	Variable numTested=0
	Variable i
	for(i=0;i<dimP;i+=1)
		if(testedComponentsWave[i]!=0)
			numTested+=1
		endif
	endfor
	
	Make/O/N=(dimN,numTested) x2mat
	for(i=0;i<dimP;i+=1)
		if(testedComponentsWave[i]!=0)
			x2mat[][i]=xmat[p][i]
		endif
	endfor
	
	// Solve for the beta2 vector:				// (2.32)
	MatrixLLS x2mat, ymat
	Wave M_B
	Redimension/N=(numTested) M_B
	MatrixOP/O BXY=((M_B^t) x (x2mat^t) x ymat)
	MatrixOP/O aa=BXY - powr(sum(ymat),2)/dimN			// p. 29
	Variable SSRb2=aa[0]										
	Variable SSRb1b2=SSR-SSRb2
	
	Variable degreeF=dimP-1			// k in the notation of the book
	Variable MSE=SSE/(dimN-degreeF-1)
	Variable F=(SSRb1b2/(numTested-1))/MSE
	Print "SSR=",SSR,"SSRb2=",SSRb2,"MSE=",MSE
	Print "F=",F,"Critical=",statsInvFCDF(1-alpha,numTested-1,dimN-dimP)
	KillWaves/Z aa,BXY,M_A
End


//========================================================================================
// Section 2.6 Prediction of a new response.
// Note that this function does not test if xVector falls inside the convex domain defined by xmat.
//========================================================================================
Function MLRPrediction(ymat,xmat,xVector)
	Wave ymat,xmat,xVector
	
	// Test dimensions:
	Variable dimP=DimSize(xmat,1)
	Variable dimN=DimSize(ymat,0)
	
	if(dimN!=DimSize(xmat,0) || dimSize(xVector,0)!=dimP)
		doAlert 0,"Matrix size mismatch"
		return 0
	endif
	
	// basic solution for regression coefficients:
	matrixLLS xmat,ymat
	Wave M_B
	Redimension/N=(dimP) M_B
	
	// predicted model values:
	MatrixOP/O W_PredictedModel=(xVector^t) x M_B
	
	// uncertainty in predicted values +-delta
	MatrixOP/O BXY=((M_B^t) x (xmat^t) x ymat)
	MatrixOP/O aa=((ymat^t) x ymat) - BXY
	Variable SSE=aa[0]
	Variable estimatedSigma2=SSE/(dimN-dimP)				
	Variable tStat=StatsInvStudentCDF(1-alpha/2,dimN-dimP)
	MatrixOP/O aa=(xVector^t) x Inv((xmat^t) x xmat) x xVector
	Variable delta=tStat*sqrt(estimatedSigma2*(1+aa[0]))
	Printf "Prediction uncertainty +- %g\r",delta
	KillWaves/Z aa,M_A,M_B
End


//========================================================================================
// Special utility function to format the table at the bottom of the notebook report.
static function addTable(nb,ymat,fittedValues,rawResiduals,hatDiagonal,studentizedResiduals,ti_residuals,influenceDi)
	String nb
	Wave ymat,fittedValues,rawResiduals,hatDiagonal,studentizedResiduals,ti_residuals,influenceDi
	
	Notebook $nb defaultTab=36, statusWidth=252, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb newRuler=Table, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Table; Notebook $nb  margins={0,0,546}, tabs={71,144,216,288,360,433,504}
	Notebook $nb text="ymat\tfittedValues\traw\tHat\tStudentized\tti\tInfluenceDi\r"
	Notebook $nb text="\t\tResiduals\tDiagonal\tResiduals\r"
	Variable i,dim=DimSize(ymat,0)
	String str
	for(i=0;i<dim;i+=1)
		sprintf str,"%.4g\t%.4g\t%.4g\t%.4g\t%.4g\t%.4g\t%.4g\r",ymat[i],fittedValues[i],rawResiduals[i],hatDiagonal[i],studentizedResiduals[i],ti_residuals[i],influenceDi[i]
		Notebook $nb text=str
	endfor
End
//========================================================================================
