#pragma rtGlobals=1		// Use modern global access method.

// 03APR07 AG changed the panel to /K=1
// 25MAY05 AG
// Self contained procedures to compute various aspects of power in one-way fixed effects model ANOVA.

#pragma ModuleName= ANOVA1PowerCalc				// un-necessarily ugly
//========================================================================
Function WM_SetupANOVAPowerPanel()

	String curDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S ANOVA1PowerF
	Variable/G 	n1=3,n2=16,alpha=0.05,delta=5,power=0.5,groupSize,minDetectableDiff
	Variable/G 	numGroups,sigmaSquared,powerResult,n2Result,groupSizeResult
	Variable/G	n2Result2,deltaResult,minDetResult
	NewPanel/K=1 /W=(2,44,681,544) as "ANOVA Power Calculations"
	ModifyPanel fixedSize=1
	SetVariable pwN1SetVar,pos={21,51},size={76,15},title="N1"
	SetVariable pwN1SetVar,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:n1,bodyWidth= 60
	SetVariable pwAlphaSetVar,pos={9,29},size={89,15},title="Alpha"
	SetVariable pwAlphaSetVar,limits={0,1,0.01},value= root:Packages:ANOVA1PowerF:alpha,bodyWidth= 60
	SetVariable pwDeltaSetVar,pos={141,164},size={87,15},title="Delta"
	SetVariable pwDeltaSetVar,limits={0,inf,0.01},value= root:Packages:ANOVA1PowerF:delta,bodyWidth= 60
	Button calcN2Button,pos={270,161},size={100,20},proc=ANOVA1PowerCalc#calcN2ButtonProc,title="Calc. N2"
	SetVariable pwN2SetVar,pos={149,230},size={76,15},title="N2"
	SetVariable pwN2SetVar,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:n2,bodyWidth= 60
	SetVariable pwPower,pos={32,164},size={93,15},title="Power"
	SetVariable pwPower,limits={0,1,0.01},value= root:Packages:ANOVA1PowerF:power,bodyWidth= 60
	SetVariable pwDeltaSetVar1,pos={32,231},size={87,15},title="Delta"
	SetVariable pwDeltaSetVar1,limits={0,inf,0.01},value= root:Packages:ANOVA1PowerF:delta,bodyWidth= 60
	Button calcPowerButton,pos={270,228},size={100,20},proc=ANOVA1PowerCalc#calcPowerButtonProc,title="Calc. Power"
	GroupBox group0,pos={21,138},size={630,57},title="Calculating Group Size"
	GroupBox group1,pos={21,207},size={630,57},title="Calculating Power"
	ValDisplay powerValDis,pos={388,231},size={128,14},title="Power Result:"
	ValDisplay powerValDis,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay powerValDis,value= #"root:Packages:ANOVA1PowerF:powerResult"
	ValDisplay powerValDis1,pos={388,162},size={111,14},title="N2 Result:"
	ValDisplay powerValDis1,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay powerValDis1,value= #"root:Packages:ANOVA1PowerF:n2Result"
	ValDisplay valdisp0,pos={519,162},size={116,14},title="Group Size:"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay valdisp0,value= #"root:Packages:ANOVA1PowerF:groupSizeResult"
	GroupBox group2,pos={21,75},size={630,57},title="Calculating N2"
	SetVariable gssetvar,pos={32,101},size={112,15},title="Group Size"
	SetVariable gssetvar,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:groupSize,bodyWidth= 60
	ValDisplay n2Result2VD,pos={388,101},size={107,14},title="N2 Result"
	ValDisplay n2Result2VD,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay n2Result2VD,value= #"root:Packages:ANOVA1PowerF:n2Result2"
	Button calcN2Butto1,pos={270,100},size={100,20},proc=ANOVA1PowerCalc#calcN2ButtonProc2,title="Calc. N2"
	GroupBox group3,pos={22,278},size={629,76},title="Calculating Delta"
	SetVariable gssetvar1,pos={32,305},size={112,15},title="Group Size"
	SetVariable gssetvar1,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:groupSize,bodyWidth= 60
	SetVariable ssSetVar,pos={157,305},size={79,15},title="s^2"
	SetVariable ssSetVar,limits={0,inf,0.1},value= root:Packages:ANOVA1PowerF:sigmaSquared,bodyWidth= 60
	Button calcDeltaButton,pos={270,302},size={100,20},proc=ANOVA1PowerCalc#calcDeltaButtonProc,title="Calc. Delta"
	ValDisplay valdisp1,pos={388,302},size={122,14},title="Delta Result:"
	ValDisplay valdisp1,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay valdisp1,value= #"root:Packages:ANOVA1PowerF:deltaResult"
	SetVariable minDetSetVar,pos={33,331},size={152,15},title="Min. det. difference"
	SetVariable minDetSetVar,limits={0,inf,1},value= root:Packages:ANOVA1PowerF:minDetectableDiff,bodyWidth= 60
	GroupBox group4,pos={22,365},size={629,100},title="Calculating Min. Det. Difference"
	SetVariable pwPower1,pos={148,399},size={93,15},title="Power"
	SetVariable pwPower1,limits={0,1,0.01},value= root:Packages:ANOVA1PowerF:power,bodyWidth= 60
	SetVariable gssetvar2,pos={34,435},size={112,15},title="Group Size"
	SetVariable gssetvar2,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:groupSize,bodyWidth= 60
	SetVariable ssSetVar1,pos={163,435},size={79,15},title="s^2"
	SetVariable ssSetVar1,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:sigmaSquared,bodyWidth= 60
	SetVariable pwN2SetVa1,pos={34,399},size={76,15},title="N2"
	SetVariable pwN2SetVa1,limits={1,inf,1},value= root:Packages:ANOVA1PowerF:n2,bodyWidth= 60
	Button calcMinDetSizeButton,pos={270,408},size={100,20},proc=ANOVA1PowerCalc#calcminDetButtonProc,title="Calc. Min. Det."
	ValDisplay valdisp2,pos={393,410},size={135,14},title="Min. Det. Result"
	ValDisplay valdisp2,limits={0,0,0},barmisc={0,1000},bodyWidth= 60
	ValDisplay valdisp2,value= #"root:Packages:ANOVA1PowerF:minDetResult"
	Button pwHelpButton,pos={571,36},size={50,20},proc=ANOVA1PowerCalc#pwHelpButtonProc,title="Help"
	
	SetDataFolder curDF
End

//========================================================================
Static Function calcminDetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:ANOVA1PowerF
	NVAR n1,n2,alpha,power,sigmaSquared,groupSize,minDetResult
	Variable localDelta
	make/O/n=4 paramWave={n1,n1,alpha,power}

	FindRoots/b=0/Q /L=1/H=1000 deltaRootFunc,paramWave
	localDelta=V_root
	minDetResult=sqrt(localDelta*2*sigmaSquared/groupSize)
	
	KillWaves/z paramWave
	SetDataFolder curDF
End

//========================================================================
Function deltaRootFunc(w,x)
	Wave w
	Variable x
	
	NVAR counter=root:Packages:ANOVA1PowerF:counter
	counter+=1
	if(counter==50)
		beep
	endif

	return (ANOVA1PowerCalc#WM_GetANOVA1Power(w[0],w[1],x,w[2])-w[3])
End
//========================================================================
Function n2RootFunc(w,x)
	Wave w
	Variable x
	
	NVAR counter=root:Packages:ANOVA1PowerF:counter
	counter+=1
	if(counter==50)
		beep
	endif

	return (ANOVA1PowerCalc#WM_GetANOVA1Power(w[0],x,w[2],w[1])-w[3])
End
//========================================================================
Static Function calcN2ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:ANOVA1PowerF
	NVAR n1,alpha,delta,power,n2result,groupSizeResult
	make/O/n=4 paramWave={n1,alpha,delta,power}

	FindRoots/b=0/Q /L=1/H=1000 n2RootFunc,paramWave
	n2Result=ceil(V_root)
	groupSizeResult=(n2Result/(n1+1))+1
	KillWaves/z paramWave
	SetDataFolder curDF
End
//========================================================================
Static Function calcPowerButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:ANOVA1PowerF
	NVAR n1,n2,alpha,delta,powerResult
	powerResult=ANOVA1PowerCalc#WM_GetANOVA1Power(n1,n2,delta,alpha)
	SetDataFolder curDF
End
//========================================================================

Static Function calcN2ButtonProc2(ctrlName) : ButtonControl
	String ctrlName
	
	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:ANOVA1PowerF
	NVAR n1,n2Result2,groupSize
	n2Result2=((n1+1)*groupSize-1)-n1
	SetDataFolder curDF
End
//========================================================================

Static Function calcDeltaButtonProc(ctrlName) : ButtonControl
	String ctrlName
	String curDF=GetDataFolder(1)
	SetDataFolder root:Packages:ANOVA1PowerF
	NVAR 		groupSize,deltaResult,sigmaSquared,minDetectableDiff
	deltaResult=groupSize*minDetectableDiff*minDetectableDiff/(2*sigmaSquared)
	SetDataFolder curDF
End

//========================================================================

Static Function pwHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "ANOVA Power Calculations Panel"
End

//========================================================================
// Calculating Power in fixed effects one way ANOVA
// n1 is the number of degrees of freedom of the numerator or the Group's DF.  This is usually the number
// 		of groups-1.
// n2 is the number of degrees of freedom of the denominator or the Error DF.  This is usually equal to the 
//		total DF - groups DF.
// delta is the non-central parameter. Zar Eq. (10.32) gives NC Phi which satisfies:
// 		delta=(Phi^2)*k,
// 		where k is the number of groups.
// alpha is the std. significance.

Static Function WM_GetANOVA1Power(n1,n2,delta,alpha)
	Variable n1,n2,delta,alpha

	return 1-statsNCFCDF(statsInvFCDF((1-alpha),n1,n2),n1,n2,delta)
End
//========================================================================
