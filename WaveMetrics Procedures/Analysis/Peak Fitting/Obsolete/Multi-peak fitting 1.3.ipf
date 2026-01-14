//	Multi-peak fitting
//		Version 1.30
//
//	Changes since 1.21
//		Added AutoFind and Manual peak place and edit
//
//	Changes since 1.20
//		Added estimated error printout to PrintPeakParams.
//
//	Changes since 1.10
//		Fixed problem when x axis reversed
//		Control panel permits unlimited peaks.
//		Fixed bug involving parameters not updating after Lorentzian fit
//		Made Igor Pro 3.0 savvy (Data Folder and liberal name aware)
//		Used Data Folders to allow easy fitting to several subranges of data with revisiting
//	Changes since 1.00
//		Added display of individual fitted peaks
//		Added RunMeAfterManualFit() macro which updates the panel and graph
//
//	Note: if you don't have (or can't use) the XFUNCs contained in the
//	GaussFit, LorentzianFit and VoigtFit XOP modules, use the following #include line
//	in your Procedure window to obtain access to the user defined versions of the fitting funcitions.
//	Then uncheck the "Use XFUNCs" checkbox in the panel.
//	#include <Peak Functions>
//
//	Note: Instructions are in the "Multi-peak Fit" experiment in the Examples:Curve Fitting
//	folder. That experiment also contains sample data and a guided tour.
//
//	You can make some sample data like so:
//		Make/N=500 data;SetScale x,300e-9,500e-9,"m" data
//		data= exp(-((x-380e-9)/20e-9)^2) + 0.5*exp(-((x-430e-9)/30e-9)^2) + gnoise(0.02)
//
//	The package creates its results, waves and variables, in a new data folder it creates in
//	the DF containing your data (which needs to be the current DF (CDF)). The folder name
//	is WMPeakFits. Within that DF are individual data folders for each sub-range of data you
//	create. When it is the currently active set, the data folder is named Current
//	When you want to freeze the results of a run, you can rename this DF to anything ohter than Current.
//	That is done for you by the RenameGroup macro.
//
// The master wave (called mw here but is really named masterCoef) has the following structure:
//	mw[0] & mw[1] contain the center and width of the x range for use in basline calcs
//	mw[2-5] contain the coefficeints of a cubic poly using x values scaled with mw[0-1]
//	mw[6]= amp of first peak
//	mw[7]= position of first peak
//	mw[8]= width of first peak
//	mw[9]= shape factor for voigt for first peak
//	mw[10-13]= coefs for 2nd peak
//	etc.

#pragma rtGlobals= 1

#include <Manual Peak Adjust>
#include <Peak AutoFind>



Function WMCreateFitGlobals()
	String dfSav= GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMmpFitting
	
	Variable/G 	gChiSquare
	Variable/G gSaveSet

	Variable/G gDoBaseline,g1Width,g1Shape,gCurPeak,gNumPeaks,gFitType
	Variable/G gPeakAmp,gPeakPos,gPeakWidth,gVoigtShape,gUseXFUNCs
	Variable/G gPeakWidthFactor
	String/G gYDataName,gFitDataName,gXDataName,gResidsName
	String/G gCurDataFolder		// the DF containing the current data set

	Variable/G gFirstCoef=6,gNumCoef=4		// to allow some routines to be generic


	// AUTOFIND
	Variable/G gDoAutoPeakFind= 1
	Variable/G gMinPeakFraction= 0.01		// peaks smaller than this times the first (biggest) peak are rejected
	Variable/G gMinPeakNoiseFactor= 0		// 2^gMinPeakNoiseFactor times a noise factor sets a threshold for peak rejection
	Variable/G gNoiseEstFromAutoFind,gSmoothEstFromAutoFind
	Variable/G gCurPeakUpdateDummy
	SetFormula gCurPeakUpdateDummy,"UpdateCurPeakTag(gCurPeak)"

	SetDataFolder dfSav
end

Macro CreateFitSetupPanel()
	DoWindow/F FitSetupPanel
	if(!V_Flag )
		WMCreateFitGlobals()
		MakeFitSetupPanel()
	endif
end

Macro UseCursors()
	if( exists(":WMPeakFits:Current:masterCoef")==0 )
		DoAlert 0,"First, use the Set button in the FitSetupPanel"
		return
	endif

	DoWindow/F $WinName(0, 1)
	root:Packages:WMmpFitting:gCurPeak=1
	ControlBar 35
	Button gb0,pos={30,6},size={80,20},proc=ProcNextPeak,title="Next Peak"
	Button gb1,pos={118,6},size={50,20},proc=BProcFromCsrs,title="Set"
	Button gb2,pos={256,8},size={50,20},proc=BProcDone,title="Done"
	UpdateCurSettings()
	SetCursorsForCurPeak()
end

Macro ZapFitAndResiduals()
	Silent 1; PauseUpdate

	if( (exists("root:Packages:WMmpFitting:gFitDataName")==0) * (exists("root:Packages:WMmpFitting:gResidsName")==0) )
		return
	endif
	$root:Packages:WMmpFitting:gFitDataName= NaN
	$root:Packages:WMmpFitting:gResidsName= NaN
end

Macro RenameGroup(gname)
	String gname= StrVarOrDefault(":WMPeakFits:Current:prefix","GroupA")
	Prompt gname,"name for this group of result waves:"
	
	Silent 1; PauseUpdate
	
	if( !DataFolderExists(":WMPeakFits:Current") )
		DoAlert 0,"First, generate some results."
		return
	endif
	if( DataFolderExists(":WMPeakFits:"+gname) )
		DoAlert 0,"Sorry, that name is already taken."
		return
	endif
	String/G :WMPeakFits:Current:prefix= gname
	RenameDataFolder :WMPeakFits:Current,$gname
end

Function/S WMPF_DataFolderList(theDF)
	String theDF
	
	String dfSav= GetDataFolder(1)
	if( strlen(theDF)!=0 )
		SetDataFolder theDF
	endif
	Variable i=0
	String s="",dfname
	do
		dfName= GetIndexedObjName("", 4, i)
		if( strlen(dfName)==0 )
			break
		endif
		s+=dfname+";"
		i+=1
	while(1)
	SetDataFolder dfSav
	return s
end



// Find topmost graph containing given wave
//	returns zero length string if not found
//
Function/S FindGraphWithWave(w)
	wave w
	
	string win=""
	variable i=0
	
	do
		win=WinName(i, 1)				// name of ith graph window
		if( strlen(win) == 0 )
			break;							// no more graph wndows
		endif
		CheckDisplayed/W=$win  w
		if(V_Flag)
			break
		endif
		i += 1
	while(1)
	return win
end

Function ReturnToOldDataSet(gname)
	String gname	// contains desired group name. May be Current or a renamed set (or bogus)
	
	if( !exists(":WMPeakFits:yDataName") )
		DoAlert 0,"Fit info not found. Did you choose the wrong data folder?"
		return 1
	endif
	
	SVAR gCurDataFolder= root:Packages:WMmpFitting:gCurDataFolder
	gCurDataFolder= GetDataFolder(1)

	SVAR yDataName= :WMPeakFits:yDataName	// when we first did a set, we squirreled away the name of the data here (I hope the term squirreled does not offend any rodent-americans)
	SVAR xDataName= :WMPeakFits:xDataName

	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	SVAR gFitDataName= root:Packages:WMmpFitting:gFitDataName
	SVAR gResidsName= root:Packages:WMmpFitting:gResidsName
	
	gYDataName= yDataName
	gXDataName= xDataName
	gFitDataName= "fit_"+gYDataName
	gResidsName= "res_"+gYDataName
	
	String grfname= FindGraphWithWave($gFitDataName)
	if( strlen(grfname) != 0 )
		DoWindow/F $grfname
	endif
	DoWindow/F FitSetupPanel

	PopupMenu popupYData,win=FitSetupPanel,mode=1,popvalue=yDataName	// mode value has to be non-zero but we don't know the actual number
	PopupMenu popupXData,win=FitSetupPanel,mode=2,popvalue=xDataName

	if( CmpStr(gname,"Current") == 0 )
		UpdateCurSettings();CalculateData()
	endif
	return 0
end

Macro RevisitGroup(gname)
	String gname= "GroupA"
	Prompt gname,"Data Folder containing group of result waves:",popup WMPF_DataFolderList("WMPeakFits")
	
	Silent 1; PauseUpdate

	if( CmpStr(GetDataFolder(1),root:Packages:WMmpFitting:gCurDataFolder) != 0 )	// returning from a different data set?
		if( ReturnToOldDataSet(gname) )
			return						// error
		endif
	endif

	if( CmpStr(gname,"Current") == 0 )
		ResetAxisRange()
		return
	endif
	
	if( DataFolderExists(":WMPeakFits:Current") )		//Switching to a different setup but haven't saved the old one yet. Try to do it automatically.
		String s
		if( exists(":WMPeakFits:Current:prefix") )		// look for possible old name
			s= :WMPeakFits:Current:prefix
		else
			s= "oldCurrent"
		endif
		if( DataFolderExists("WMPeakFits:"+s) )
			DoAlert 0,"Can't rename Current due to conflict. You'll need to do it yourself."
			return
		endif
		RenameDataFolder :WMPeakFits:Current,$s
	endif
			
	RenameDataFolder $":WMPeakFits:"+gname,Current
	UpdateCurSettings();CalculateData();ResetAxisRange()
	UpdateCurPeakTag(NumVarOrDefault("root:Packages:WMmpFitting:gCurPeak",0))
end

Macro RunMeAfterManualFit()
	if( exists(":WMPeakFits:Current:masterCoef")==0 )
		DoAlert 0,"First, use the Set button in the FitSetupPanel"
		return
	endif
	if( exists(":WMPeakFits:Current:coef")==0 )
		DoAlert 0,"First, copy the coef wave to the Current data folder"
		return
	endif

	UpdateMasterCoef();UpdateCurSettings();CalculateData()
end

Macro PrintPeakParams()
		fPrintPeakParams()
end

// This function operates on the actual fit coefficients and not on the munged
// versions stored in masterCoef. This is to make it easier to use the covariance
// matrix to calculate sigmas. To see how the coef wave is layed out, see the
// GaussFit Help, LorentzianFit Help and VoigtFit Help files found in
// the :More Extensions:Curve Fitting: folder.
//
Function fPrintPeakParams()
	
	String func= ""
	NVAR fitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gDoBaseline= root:Packages:WMmpFitting:gDoBaseline
	Wave fc= :WMPeakFits:Current:coef
	Wave fcov= :WMPeakFits:Current:M_Covar

	Variable first,nc	// first=first non-baseline coef, nc= number of coefs per peak
	Variable posIndex,ampIndex,widthIndex,shapeIndex	// width and shape indicies may be constant if g1Width or g1Shape are true

	if( gDoBaseline )
		first= 6
	else
		first=1
	endif

	if( fitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
		func= "Gaussian"
		nc= 3-g1Width
		widthIndex= first		// will be used only if g1Width
		first += g1Width
	endif
	if( fitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
		func= "Lorentzian"
		nc= 3-g1Width
		widthIndex= first		// will be used only if g1Width
		first += g1Width
	endif
	if( fitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		func= "Voigt"
		nc= 4-g1Width-g1Shape
		shapeIndex= first
		first +=g1Shape
		widthIndex= first		// will be used only if g1Width
		first += g1Width
	endif
	printf "For %s peaks:\r",func

	Variable i=0,pos,posSigma,width,widthSigma,amp,ampSigma,shape,shapeSigma
	Variable area,areaSigma,wg,wgSigma,wl,wlSigma
	do
		ampIndex= first+nc*i		// amp index is same for all fit types

		if( fitType==0 )	// Gaussian = k1*exp(-((x-k2)/k3)^2)
			posIndex= ampIndex+1			// K2
			if( g1Width==0 )
				widthIndex= posIndex+1	// K3
			endif

			amp= fc[ampIndex]
			ampSigma=  sqrt(fcov[ampIndex][ampIndex])		// amp is easy for gaussian
			width= fc[widthIndex]
			widthSigma=  sqrt(fcov[widthIndex][widthIndex])	// even width is easy for gaussian
			area= amp*width*sqrt(Pi)
			areaSigma= area*sqrt( (ampSigma/amp)^2 + (widthSigma/width)^2 +2*fcov[ampIndex][widthIndex]/(amp*width) )
			width *= 2*sqrt(ln(2))
			widthSigma *= 2*sqrt(ln(2))
		endif
		if( fitType==1 )	// Lorentzian = k1*/( (x-k2)^2 + k3 )
			posIndex= ampIndex+1			// K2
			if( g1Width==0 )
				widthIndex= posIndex+1	// K3
			endif

			amp= fc[ampIndex]
			ampSigma=  sqrt(fcov[ampIndex][ampIndex])
			width= fc[widthIndex]
			widthSigma=  sqrt(fcov[widthIndex][widthIndex])

			area= Pi*amp/sqrt(width)
			areaSigma= (Pi/width)*sqrt(width*ampSigma^2 + (widthSigma*amp)^2/(4*width) -amp*fcov[ampIndex][widthIndex])

			widthSigma= widthSigma/sqrt(width)
			width= 2*sqrt(width)
		endif
		if( fitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
			if( g1Width==0 )
				widthIndex= ampIndex+1	// K1
				posIndex= ampIndex+2		// K2
			else
				posIndex= ampIndex+1		// K2
			endif
			if( g1Shape==0 )
				shapeIndex= posIndex+1	// K3
			endif

			amp= fc[ampIndex]
			ampSigma=  sqrt(fcov[ampIndex][ampIndex])
			width= fc[widthIndex]		// This is the width affecting paramer but not a real width
			widthSigma=  sqrt(fcov[widthIndex][widthIndex])
			shape= fc[shapeIndex]
			shapeSigma=  sqrt(fcov[shapeIndex][shapeIndex])

			area= amp*sqrt(pi)/width
			areaSigma= area*sqrt( (ampSigma/amp)^2 + (widthSigma/width)^2 - 2*fcov[ampIndex][widthIndex]/(amp*width) )

			wg= sqrt(ln(2))/width						// gaussian width
			wgSigma= (wg/width)*widthSigma			// gaussian width sigma

			wl= shape/width 							// lorentzian width
			wlSigma= wl*sqrt( (shapeSigma/shape)^2 + (widthSigma/width)^2 - 2*fcov[shapeIndex][widthIndex]/(shape*width) )	// lorentzian width sigma

			// This is an approximation so we do not calculate an error.
			width= wl/2 + sqrt( wl^2/4 + wg^2)		// voigt width
			widthSigma= NaN

			width *=2	// the above were half width at half max and we report fwhm
			wg *= 2
			wgSigma *= 2
			wl *= 2
			wlSigma *= 2
		endif

		pos= fc[posIndex]							// position of peak
		posSigma= sqrt(fcov[posIndex][posIndex])	// position err is easy

		printf "Peak#%d: position= %g+/-%g, area= %g+/-%g, width (fwhm)= %g+/-%g\r",i+1,pos,posSigma,area,areaSigma,width,widthSigma
		if( fitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
			printf "\t Gaussian width= %g+/-%g, Lorentzian width= %g+/-%g, shape= %g+/-%g\r",wg,wgSigma,wl,wlSigma,shape,shapeSigma
		endif
		i += 1
	while(i<gNumPeaks)
end



Macro RemovePeakPackage()
	if( strlen(WinList("FitSetupPanel",";","")) != 0 )
		DoWindow/K FitSetupPanel
	endif
	KillDataFolder root:Packages:WMmpFitting
	DoAlert 0,"Now remove the #include from your Procedure window and recompile"
end


Function CheckPeakPackage()
	if( exists(":WMPeakFits:Current:masterCoef")==1 )
		return 0
	endif
	DoAlert 0,"Click the Setup button first"
	return 1
end


Function SetCursorsForCurPeak()
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName

	Variable apnum,bpnum,axval,bxval,i=6+4*(gCurPeak-1)
	Wave w= $":WMPeakFits:Current:mastercoef"
	axval= w[i+1]
	bxval= axval+w[i+2]
	if(  cmpstr(gXDataName,"_calculated_") == 0 )
		apnum= x2pnt($gYDataName, axval)
		bpnum= x2pnt($gYDataName, bxval)
	else
		apnum= BinarySearch($gXDataName,axval)
		bpnum= BinarySearch($gXDataName,bxval)
	endif
	Cursor/P A,$gYDataName,apnum
	Cursor/P B,$gYDataName,bpnum
end


Function BProcFromCsrs(ctrlName) : ButtonControl
	String ctrlName

	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	wave w= $":WMPeakFits:Current:masterCoef"
	Variable i= 6+4*(gCurPeak-1)
	w[i]= vcsr(A)
	w[i+1]= hcsr(A)
	w[i+2]= abs(hcsr(A)-hcsr(B))
	CalculateData()
	UpdateCurSettings()
End


Function CalcAmpFromMC(pknum,master)
	Variable pknum
	Wave master

	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	
	Variable j= 6+4*pknum			// index to first peak's coefs (amp)

	if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
		return master[j]
	endif

	if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
		if( g1Width  )
			return master[j]*master[8]^2
		else
			return  master[j]*master[j+2]^2
		endif
	endif

	if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		Variable shape= master[9]
		if( g1Shape  == 0 )
			shape= master[j+3]
		endif
		return master[j]*(1+ shape)
	endif
	return NaN
end


Function CalcWidthFromMC(pknum,master)
	Variable pknum
	Wave master
	
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR g1Width= root:Packages:WMmpFitting:g1Width

	Variable j= 6+4*pknum			// index to first peak's coefs (amp)

	if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
		if( g1Width  )
			return master[8]
		else
			return master[j+2]
		endif
	endif

	if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
		if( g1Width  )
			return master[8]^2
		else
			return  master[j+2]^2
		endif
	endif

	if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		Variable shape= master[9]
		if( g1Shape  == 0 )
			shape= master[j+3]
		endif
		if( g1Width  )
			return (1+ shape)/master[8]
		else
			return   (1+ shape)/master[j+2]
		endif
	endif
	return NaN
end


Function CalcShapeFromMC(pknum,master)
	Variable pknum
	Wave master

	Variable j= 6+4*pknum			// index to first peak's coefs (amp)

	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape

	if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		Variable shape= master[9]
		if( g1Shape  == 0 )
			shape= master[j+3]
		endif
		return shape
	endif
	return 1
end



Function CalculateCoef()
	Wave master= $":WMPeakFits:Current:masterCoef"
	Wave masterHold= $":WMPeakFits:Current:masterCoefHold"
	
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR gDoBaseline= root:Packages:WMmpFitting:gDoBaseline

	Variable i,nc,j, npks= (numpnts(master)-6)/4

	if( (gFitType==0) %| (gFitType==1) )	// Gaussian or Lorentzian
		nc= 1+gDoBaseline*5+g1Width+npks*(3-g1Width)
	else // must be Voigt for now
		nc= 1+gDoBaseline*5+g1Width+g1Shape+npks*(4-g1Width-g1Shape)
	endif
	Duplicate/O master,$":WMPeakFits:Current:coef"
	Duplicate/O masterHold,$":WMPeakFits:Current:coefHold"
	Wave slave= $":WMPeakFits:Current:coef"
	Wave slaveHold= $":WMPeakFits:Current:coefHold"
	Redimension/N=(nc) slave,slaveHold
	if( gDoBaseline )
		slave[0,5]= master[P]				// copy baseline
		slaveHold[0,5]= masterHold[P]	
		i= 6
	else
		slave[0]= master[2]		// copy only offset
		slaveHold[0]= masterHold[2]	
		i=1
	endif
	do
		if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
			if( g1Width )
				slave[i]= master[8]
				slaveHold[i]= masterHold[8]	
				i+=1
			endif
			j= 6
			do
				slave[i]= master[j]
				slaveHold[i]= masterHold[j]	
				i+=1
				slave[i]= master[j+1]
				slaveHold[i]= masterHold[j+1]	
				i+=1
				if( g1Width == 0 )
					slave[i]= master[j+2]
					slaveHold[i]= masterHold[j+2]
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
		if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
			if( g1Width )
				slave[i]= master[8]^2
				slaveHold[i]= masterHold[8]
				i+=1
			endif
			j= 6
			do
				if( g1Width  )
					slave[i]= master[j]*master[8]^2
				else
					slave[i]= master[j]*master[j+2]^2
				endif
				slaveHold[i]= masterHold[j]
				i+=1
				slave[i]= master[j+1]
				slaveHold[i]= masterHold[j+1]
				i+=1
				if( g1Width == 0 )
					slave[i]= master[j+2]^2
					slaveHold[i]= masterHold[j+2]
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
		if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
			variable shape,width
			if(  g1Shape )
				slave[i]= master[9]		// 1 Shape or 1 Shape and 1 Width
				slaveHold[i]= masterHold[9]
				shape= master[9]
				i+=1
			endif
			if( g1Width )
				slave[i]= (1+ master[9])/master[8]
				slaveHold[i]= masterHold[8]
				width= master[8]
				i+=1
			endif
			j= 6
			do
				if( g1Shape  == 0 )
					shape= master[j+3]
				endif
				if( g1Width == 0 )
					width= master[j+2]
				endif
				slave[i]= master[j]*(1+ shape)
				slaveHold[i]= masterHold[j]
				i+=1
				if( g1Width == 0 )
					slave[i]=(1+ shape)/width
					slaveHold[i]= masterHold[j+2]
					i+=1
				endif
				slave[i]= master[j+1]
				slaveHold[i]= masterHold[j+1]
				i+=1
				if(  g1Shape == 0 )
					slave[i]= master[j+3]
					slaveHold[i]= masterHold[j+3]
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
	while(0)
end

Function UpdateMasterCoef()
	Wave master= $":WMPeakFits:Current:masterCoef"
	Wave slave= $":WMPeakFits:Current:coef"
	
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR gDoBaseline= root:Packages:WMmpFitting:gDoBaseline

	Variable i,nc,j, npks= (numpnts(master)-6)/4

	if( (gFitType==0) %| (gFitType==1) )	// Gaussian or Lorentzian
		nc= 1+gDoBaseline*5+g1Width+npks*(3-g1Width)
	else // must be Voigt for now
		nc= 1+gDoBaseline*5+g1Width+g1Shape+npks*(4-g1Width-g1Shape)
	endif
	if( gDoBaseline )
		master[0,5]= slave[P]		// copy baseline
		i= 6
	else
		master[2]= slave[0]		// copy only offset
		i=1
	endif
	do
		if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
			if( g1Width )
				master[8]= slave[i]
				i+=1
			endif
			j= 6
			do
				master[j]= slave[i]
				i+=1
				master[j+1]= slave[i]
				i+=1
				if( g1Width == 0 )
					master[j+2]= slave[i]
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
		if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
			if( g1Width )
				master[8]= sqrt(slave[i])
				i+=1
			endif
			j= 6
			do
				if( g1Width  )
					master[j]=slave[i]/(master[8]^2)
				else
					master[j]=slave[i]/slave[i+2]
				endif
				i+=1
				master[j+1]= slave[i]
				i+=1
				if( g1Width == 0 )
					master[j+2]= sqrt(slave[i])
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
		if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
			variable shape,width
			if(  g1Shape )
				master[9]= slave[i]		// 1 Shape or 1 Shape and 1 Width
				shape= master[9]
				i+=1
			endif
			if( g1Width )
				master[8]=(1+ shape)/ slave[i]
				width=  slave[i]
				i+=1
			endif
			j= 6
			do
				if( g1Width == 0 )
					width= slave[i+1]
					if( g1Shape  == 0 )
						shape= slave[i+3]
					endif
				endif
				master[j]= slave[i]/(1+ shape)
				i+=1
				if( g1Width == 0 )
					master[j+2]= (1+ shape)/slave[i]
					i+=1
				endif
				master[j+1]= slave[i]
				i+=1
				if(  g1Shape == 0 )
					master[j+3]= slave[i]
					i+=1
				endif
				j += 4						// each peak has 4 parameters (not all used)
			while(i<nc)
			break
		endif
	while(0)
end
	

Function CalculateData()
	 CalculateCoef()
	 
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR gDoBaseline= root:Packages:WMmpFitting:gDoBaseline
	NVAR gUseXFUNCs= root:Packages:WMmpFitting:gUseXFUNCs

	 String func=""

	if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
		if( gDoBaseline )
			if( g1Width )
				func= "GaussFit1WidthBL"
			else
				func= "GaussFitBL"
			endif
		else
			if( g1Width )
				func= "GaussFit1Width"
			else
				func= "GaussFit"
			endif
		endif
	endif
	if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
		if( gDoBaseline )
			if( g1Width )
				func= "LorentzianFit1WidthBL"
			else
				func= "LorentzianFitBL"
			endif
		else
			if( g1Width )
				func= "LorentzianFit1Width"
			else
				func= "LorentzianFit"
			endif
		endif
	endif
	if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		if( gDoBaseline )
			if( g1Width )	// implies 1 Shape also
				func= "VoigtFit1Shape1WidthBL"
			else
				if( g1Shape )
					func= "VoigtFit1ShapeBL"
				else
					func= "VoigtFitBL"
				endif
			endif
		else
			if( g1Width )	// implies 1 Shape also
				func= "VoigtFit1Shape1Width"
			else
				if( g1Shape )
					func= "VoigtFit1Shape"
				else
					func= "VoigtFit"
				endif
			endif
		endif
	endif
	if( gUseXFUNCs == 0 )
		func= "f"+func
	endif

	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gResidsName= root:Packages:WMmpFitting:gResidsName
	SVAR gFitDataName= root:Packages:WMmpFitting:gFitDataName
	NVAR gChiSquare= root:Packages:WMmpFitting:gChiSquare
	
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd

	String dfSav= GetDataFolder(1)
	SetDataFolder :WMPeakFits:Current
	
	Wave dy= :::$gYDataName
	Wave fw= :::$gFitDataName
	Wave rw= :::$gResidsName

	String xn= "x"
	if(  cmpstr(gXDataName,"_calculated_") != 0 )
		xn= PossiblyQuoteName(gXDataName)
	endif
	String cmd
	sprintf cmd,"%s[%g,%g]=%s(:WMPeakFits:Current:coef,%s)", ":::"+PossiblyQuoteName(gFitDataName),gRangeBegin,gRangeEnd,func,xn
//print cmd
	Execute cmd		// fitwave[begin,end]= func(coef,xsrc)

	SetDataFolder dfSav

	rw[gRangeBegin,gRangeEnd]= dy-fw

	gChiSquare= CalcChiSqr(rw)
	UpdateIndividualPeaks()
end

Function/S FindTraceUsingWave(w)
	Wave w
	
	Variable i=0
	do
		String tracename= PossiblyQuoteName(NameOfWave(w))+"#"+num2istr(i)
		WAVE/Z wt= TraceNameToWaveRef("", tracename)
		if( WaveExists(wt) == 0 )
			break
		endif
		if( CmpStr(GetWavesDataFolder(w, 4),GetWavesDataFolder(wt, 4)) == 0 )
			return tracename
		endif
		i+=1
	while(1)		// will exit above if trace found
	return ""
end
	



Function TrimExcessPeaks()
	String bname= "Peak",fname,tname				// basename for individual peak waves, full name, trace name
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	Variable i= gNumPeaks
	do
		tname= bname+num2istr(i+1)			// count from 1 rather than zero
		Wave/Z w=$":WMPeakFits:Current:"+tname
		if( WaveExists(w)==0 )
			break								// quit when we run out of waves of this name series
		endif
		tname= FindTraceUsingWave(w)
		if( strlen(tname) != 0 )
			RemoveFromGraph $tname
		endif
		KillWaves w
		i += 1
	while(1)
end


Function UpdateIndividualPeaks()
	NVAR gPeakWidthFactor= root:Packages:WMmpFitting:gPeakWidthFactor
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR gUseXFUNCs= root:Packages:WMmpFitting:gUseXFUNCs
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName

	NVAR gXMin= :WMPeakFits:Current:gXMin
	NVAR gXMax= :WMPeakFits:Current:gXMax
	
	if( gPeakWidthFactor < 0 )			// flag not to do peaks at all
		return 0
	endif

	if( gPeakWidthFactor == 0 )
		gPeakWidthFactor= 3
	endif

	String dfSav= GetDataFolder(1)
	SetDataFolder :WMPeakFits:Current

	wave c= coef
	wave mc= masterCoef

	String bname= "Peak",fname				// basename for individual peak waves
	String func

	Variable i=0,xmin,xmax,pos,width,amp,shape
	do
		fname= bname+num2istr(i+1)		// peak numbers start with 1
		Make/O/N=100 $fname
		Wave w= $fname
		
		pos= mc[6+4*i+1]				// position of peak
		if( g1Width )
			width= mc[8]				// width of first peak
		else
			width= mc[8+4*i]			// width of this peak
		endif
		
		// Bracket peak position but don't go all the way to the ends to avoid unnecessary long runs of zero
		Variable lXMax= gXMax, lXMin= gXMin
		if( lXMax < lXMin )							// in case axis is reversed
			lXMax= gXMin
			lXMin= gXMax
		endif
		width= abs(width)
		xmax= min(lXMax,pos+gPeakWidthFactor*width)
		xmin= max(lXMin,pos-gPeakWidthFactor*width)
		

		SetScale x,xmin,xmax,"",w
		Duplicate/O c,tempcoef
		
		amp= CalcAmpFromMC(i,mc)
		width= CalcWidthFromMC(i,mc)
		shape= CalcShapeFromMC(i,mc)
		// don't need position since that is never common nor in need of munging

		if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
			func= "GaussFit"
			tempcoef= {0,amp,pos,width}
		endif
		if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
			func= "LorentzianFit"
			tempcoef= {0,amp,pos,width}
		endif
		if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
			func= "VoigtFit"
			tempcoef= {0,amp,width,pos,shape}
		endif
		if( gUseXFUNCs == 0 )
			func= "f"+func
		endif
		Execute fname+"= "+func+"(tempcoef,x)"
		CheckDisplayed/W=$WinName(0, 1) :::$gYDataName
		if( V_Flag == 1 )
			CheckDisplayed/W=$WinName(0, 1) w
			if( V_Flag != 1 )
				AppendToGraph w
			endif
		endif
		i += 1
	while(i<gNumPeaks)
	KillWaves tempcoef
	SetDataFolder dfSav
	
	TrimExcessPeaks()		// from previous runs
end



Function SetAPeak()

	if( CheckPeakPackage() )
		return 0
	endif

	wave w= $":WMPeakFits:Current:masterCoef"
	wave hw= $":WMPeakFits:Current:masterCoefHold"
	
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	NVAR gPeakAmp= root:Packages:WMmpFitting:gPeakAmp
	NVAR gPeakPos= root:Packages:WMmpFitting:gPeakPos
	NVAR gPeakWidth= root:Packages:WMmpFitting:gPeakWidth
	NVAR gVoigtShape= root:Packages:WMmpFitting:gVoigtShape	
	
	variable i=6+4*(gCurPeak-1)
	w[i]={gPeakAmp,gPeakPos,gPeakWidth,gVoigtShape}
	ControlInfo/W=FitSetupPanel checkAmp; hw[i]= V_value
	ControlInfo/W=FitSetupPanel  checkPos; hw[i+1]= V_value
	ControlInfo/W=FitSetupPanel  checkWid; hw[i+2]= V_value
	ControlInfo/W=FitSetupPanel  checkVS; hw[i+3]= V_value
	CalculateData()
End

Function UpdateCurSettings()
	wave w= $":WMPeakFits:Current:masterCoef"
	wave hw= $":WMPeakFits:Current:masterCoefHold"

	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	NVAR gPeakPos= root:Packages:WMmpFitting:gPeakPos
	NVAR gPeakWidth= root:Packages:WMmpFitting:gPeakWidth
	NVAR gVoigtShape= root:Packages:WMmpFitting:gVoigtShape
	NVAR gPeakAmp= root:Packages:WMmpFitting:gPeakAmp
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	
	gNumPeaks= (numpnts(w)-6)/4
	if( gCurPeak > gNumPeaks )
		gCurPeak= 1
	endif
	SetVariable SetPkNum limits={1,gNumPeaks,1},win=FitSetupPanel

	Variable i= 6+4*(gCurPeak-1)
	gPeakAmp=w[i];gPeakPos= w[i+1]; gPeakWidth= w[i+2] ; gVoigtShape= w[i+3]
	CheckBox checkAmp value=hw[i],win=FitSetupPanel
	CheckBox checkPos value=hw[i+1],win=FitSetupPanel
	CheckBox checkWid value=hw[i+2],win=FitSetupPanel
	CheckBox checkVS value=hw[i+3],win=FitSetupPanel
End

Function SetVarProcNPeaks(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak

	SetVariable SetPkNum limits={1,gNumPeaks,1}
	
	if( exists(":WMPeakFits:Current:masterCoef") == 0 )
		return 0
	endif
	
	DoSetDataRange()

	wave w= $":WMPeakFits:Current:masterCoef"
	Variable oldNpeaks= (numpnts(w)-6)/4,i
	Redimension/N=(6+4*gNumPeaks) w,$":WMPeakFits:Current:masterCoefHold"
	if( oldNpeaks < gNumPeaks )
		do
			i= 6+4*(oldNpeaks)
			w[i]= w[i-4]*0.9					// new peak amp smaller than last
			w[i+1]= w[i-3]+2*w[i-2]		// new pos one peak width from last
			w[i+2]= w[i-2]					// make sure width parameter is not zero (else get nan from gauss)
			w[i+3]= 1							// always a reasonable guess for voigt
			oldNpeaks+=1
		while(oldNpeaks<gNumPeaks)
	else
		if( gCurPeak > gNumPeaks )
			gCurPeak= gNumPeaks
			UpdateCurSettings()
		endif
	endif
	CalculateData()
End

// Speical purpose to gen hold string from the hold wave
Function/S GenHoldStrForFitProc(w)
	Wave w

	variable ntot= numpnts(w)
	
	String s=""
	Variable i=0
	do
		if( w[i] == 0 )
			s += "0"
		else
			s += "1"
		endif
		i+=1
	while(i<ntot)
	return s
end

Function fitProc(ctrlName) : ButtonControl
	String ctrlName

	if( CheckPeakPackage() )
		return 0
	endif

	 String func= ""

	 CalculateCoef()

	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	NVAR gUseXFUNCs= root:Packages:WMmpFitting:gUseXFUNCs
	NVAR gDoBaseline= root:Packages:WMmpFitting:gDoBaseline
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	SVAR gFitDataName= root:Packages:WMmpFitting:gFitDataName
	SVAR gResidsName= root:Packages:WMmpFitting:gResidsName
	NVAR gChiSquare= root:Packages:WMmpFitting:gChiSquare

	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd

	if( gFitType==0 )	// Gaussian = k0*exp(-((x-k1)/k2)^2)
		if( g1Width )
			func= "GaussFit1Width"
		else
			func= "GaussFit"
		endif
	endif
	if( gFitType==1 )	// Lorentzian = k0*/( (x-k1)^2 + k2 )
		if( g1Width )
			func= "LorentzianFit1Width"
		else
			func= "LorentzianFit"
		endif
	endif
	if( gFitType==2 )	// VoigtFit = k0*Voigt(k1*(x-k2),k3)
		if( g1Width )	// implies 1 Shape also
			func= "VoigtFit1Shape1Width"
		else
			if( g1Shape )
				func= "VoigtFit1Shape"
			else
				func= "VoigtFit"
			endif
		endif
	endif
	if( gUseXFUNCs == 0 )
		func= "f"+func
	endif
	
	String dfSav= GetDataFolder(1)
	SetDataFolder :WMPeakFits:Current
	
	Wave cw= coef
	Wave dy= :::$gYDataName
	Wave dx= :::$gXDataName		// may be NULL
	Wave fw= :::$gFitDataName
	Wave rw= :::$gResidsName
	
	String holdStrName= gYDataName+"_HoldStr"
	String/G $holdStrName= GenHoldStrForFitProc($"coefHold")	// we use a variable rather than creating literal string in command so unlimited peaks will not create too long a command

	String s= func
	if( gDoBaseline )
		s += "BL"
	endif
	s += " " + GetWavesDataFolder(cw,4)+" "+GetWavesDataFolder(dy,4)+"["+num2str(gRangeBegin)+","+num2str(gRangeEnd)+"]"
	if( cmpstr(gXDataName,"_calculated_") != 0 )
		s += " /X= "+GetWavesDataFolder(dx,4)
	endif
	s += " /D="+GetWavesDataFolder(fw,4)
	s=  "FuncFit/M=2"+"/H="+PossiblyQuoteName(holdStrName)+" "+s

	print s
	Execute s

	SetDataFolder dfSav
	
	rw[gRangeBegin,gRangeEnd]= dy-fw

	gChiSquare= CalcChiSqr(rw)
	UpdateMasterCoef();UpdateCurSettings()
	UpdateIndividualPeaks()
End

// given a residuals wave, calculate chi squared
Function CalcChiSqr(residsw)
	Wave residsw

	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd
	
	// I'd like to check here if the residsw is null or not but can't figure
	// out how.
	Variable chisq=0,i=gRangeBegin,npts= gRangeEnd+1
	do
		chisq += residsw[i]^2
		i+=1
	while(i<npts)
	return chisq
end

Function foo()
	SVAR gResidsName= root:Packages:WMmpFitting:gResidsName
	NVAR gChiSquare= root:Packages:WMmpFitting:gChiSquare
	gChiSquare= CalcChiSqr($gResidsName)
	print gChiSquare
end


Function SetPeakNumProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if( CheckPeakPackage() )
		return 0
	endif

	UpdateCurSettings()
End

Proc PopProcFunc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if( CheckPeakPackage() )
		return
	endif

	root:Packages:WMmpFitting:gFitType= popNum-1
	ValidateShapeForVoigt()
	CalculateData()
End


Proc CheckProcUseXFUNCs(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	root:Packages:WMmpFitting:gUseXFUNCs= checked
End

Proc CheckProc1Width(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	root:Packages:WMmpFitting:g1Width= checked
	ValidateShapeForVoigt()
End

Function ValidateShapeForVoigt()
	NVAR gFitType= root:Packages:WMmpFitting:gFitType
	NVAR g1Width= root:Packages:WMmpFitting:g1Width
	NVAR g1Shape= root:Packages:WMmpFitting:g1Shape
	if( gFitType==2 )	// VoigtFit
		if( (g1Width!=0) %& (g1Shape==0) )	// illegal combo?
			CheckBox checkCS,value=1
			g1Shape= 1
		endif
	endif
end


Proc CheckProc1Shape(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	root:Packages:WMmpFitting:g1Shape= checked
	ValidateShapeForVoigt()
End

Proc CheckProcDoBaseline(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	root:Packages:WMmpFitting:gDoBaseline= checked
End

Proc CheckProcHold(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SetAPeak()
End

Function ButtonProcAmpFromCsrA(ctrlName) : ButtonControl
	String ctrlName

	if( CheckPeakPackage() )
		return 0
	endif

	wave w= $":WMPeakFits:Current:masterCoef"
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	Variable i= 6+4*(gCurPeak-1)
	do
		if( cmpstr(ctrlName,"b0") == 0 )
			w[i]= vcsr(A)
			break
		endif
		if( cmpstr(ctrlName,"b1") == 0 )
			w[i+1]= hcsr(A)
			break
		endif
		if( cmpstr(ctrlName,"b2") == 0 )
			w[i+2]= abs(hcsr(A)-hcsr(B))
			break
		endif
	while(0)
	CalculateData()
	UpdateCurSettings()
End

Proc ButtonProcNewGraph(ctrlName) : ButtonControl
	String ctrlName

	if( CheckPeakPackage() )
		return
	endif

	MakeGraph()
End

Function ResetAxisRange()
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd
	NVAR gRangeReversed= :WMPeakFits:Current:gRangeReversed
	
	Variable p0= gRangeBegin, p1= gRangeEnd
	if( gRangeReversed )
		p0= gRangeEnd
		p1= gRangeBegin
	endif

	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName

	Variable vmin,vmax

	if( cmpstr(gXDataName,"_calculated_") == 0 )
		vmin= pnt2x($gYDataName,p0)
		vmax= pnt2x($gYDataName,p1)
	else
		Wave w= $gXDataName
		vmin=w[p0]
		vmax=w[p1]
	endif

	if( strlen(WinName(0, 1)) != 0 )
		CheckDisplayed/W=$WinName(0, 1) $gYDataName
		if( V_Flag )
			SetAxis bottom,vmin,vmax
		endif
	endif
	printf "Range reset from saved data: points= [%d,%d] ( equivalent to x= (%g,%g) )\r",gRangeBegin,gRangeEnd,vmin,vmax
end


Function DoSetDataRange()
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd
	NVAR gRangeReversed= :WMPeakFits:Current:gRangeReversed

	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName

	gRangeBegin= 0; gRangeEnd= numpnts($gYDataName)-1;
	
	Variable te= gRangeEnd
	Variable V_Flag= 0

	if( strlen(WinName(0, 1)) != 0 )
		CheckDisplayed/W=$WinName(0, 1) $gYDataName
	endif
	Variable isGraphed= V_Flag
	if( isGraphed )
		GetAxis /Q bottom
		if( cmpstr(gXDataName,"_calculated_") == 0 )
			gRangeBegin= x2pnt($gYDataName,V_min)
			gRangeEnd= x2pnt($gYDataName,V_max)
		else
			gRangeBegin=BinarySearch($gXDataName,V_min)
			gRangeEnd=BinarySearch($gXDataName,V_max)
			if( gRangeEnd == -2 )
				gRangeEnd= te
			endif
		endif
		if( gRangeBegin<0 )
			gRangeBegin= 0;
		endif
		if( gRangeEnd>te )
			gRangeEnd= te
		endif
		printf "Range set from graph: points= [%d,%d] ( equivalent to x= (%g,%g) )\r",gRangeBegin,gRangeEnd,V_min,V_max
	else
		printf "Range set to full extent of data (not graphed yet)\r"
	endif
	gRangeReversed= gRangeBegin>gRangeEnd
	if( gRangeReversed )
		variable tmp= gRangeBegin
		gRangeBegin= gRangeEnd
		gRangeEnd= tmp
	endif
	return isGraphed
End


Function ButtonProcSet(ctrlName) : ButtonControl
	String ctrlName
	
	NewDataFolder/O WMPeakFits				// contains material about one data set (names of data, sub-range DFs)
	NewDataFolder/O :WMPeakFits:Current		// contains material specific to a sub-range of one data set (peaks, coefs etc)
	
	SVAR gCurDataFolder= root:Packages:WMmpFitting:gCurDataFolder
	SVAR gFitDataName= root:Packages:WMmpFitting:gFitDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gResidsName= root:Packages:WMmpFitting:gResidsName
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak

	Variable/G :WMPeakFits:Current:gRangeBegin,:WMPeakFits:Current:gRangeEnd,:WMPeakFits:Current:gRangeReversed
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd

	Variable/G :WMPeakFits:Current:gXMin,:WMPeakFits:Current:gXMax
	NVAR gXMin= :WMPeakFits:Current:gXMin
	NVAR gXMax= :WMPeakFits:Current:gXMax

	String/G :WMPeakFits:yDataName,:WMPeakFits:xDataName
	SVAR yDataName= :WMPeakFits:yDataName
	SVAR xDataName= :WMPeakFits:xDataName

	ControlInfo popupYData
	gYDataName= S_value
	ControlInfo popupXData
	gXDataName=  S_value
	
	if( (strlen(gYDataName) *strlen(gXDataName)) == 0 )
		DoAlert 0,"Choose X and Y data first"
		return 0
	endif

	gCurDataFolder= GetDataFolder(1)

	yDataName= gYDataName	// for revisit feature when we have been working on a different data set
	xDataName= gXDataName
	
	Variable reset	// used to check if we are resetting using the same data or if we are starting fresh
	
	reset= CmpStr(gFitDataName, "fit_"+gYDataName)==0
	reset *= CmpStr(gResidsName, "res_"+gYDataName)==0
	if( reset )
		reset *= numpnts($gYDataName)==numpnts($gResidsName)
	endif
	
	if( reset == 0 )
		gFitDataName= "fit_"+gYDataName
		gResidsName= "res_"+gYDataName
		Duplicate/O $gYDataName,$gFitDataName,$gResidsName
		Wave w= $gResidsName
		w= NaN
		Wave w= $gFitDataName
		w= NaN
		
		printf "Set Y data= %s, X data= %s, fit wave= %s, residuals= %s\r",gYDataName,gXDataName,gFitDataName,gResidsName
	else
		print "Reset using same data"
	endif
	
	Variable isGraphed= DoSetDataRange()

	// AUTOFIND
	Variable isAuto= isGraphed %& NumVarOrDefault("root:Packages:WMmpFitting:gDoAutoPeakFind",0);
	
	if( isAuto )
		DoMP_EstPeakNoiseAndSmfact()
		gNumPeaks= DoMP_AutoFindPeaks()
		if( gNumPeaks==0 )
			isAuto= 0
		else
			gCurPeak= 1
			SetVariable SetPkNum limits={1,gNumPeaks,1}
		endif
	endif
	
	if( gNumPeaks == 0 )			// user hasn't set this yet
		gCurPeak= 1
		gNumPeaks= 2				// arbitrary first
		SetVariable SetPkNum limits={1,gNumPeaks,1}
	endif
	
	Duplicate/O $gYDataName,$":WMPeakFits:Current:masterCoef"	// force same number type
	Make/O/B $":WMPeakFits:Current:masterCoefHold"={1,1}
	Redimension/N=(6+4*gNumPeaks) $":WMPeakFits:Current:masterCoef",$":WMPeakFits:Current:masterCoefHold"

	wave cw= $":WMPeakFits:Current:masterCoef"
	Variable xmin,xmax
	if( cmpstr(gXDataName,"_calculated_") == 0 )
		xmin= pnt2x($gYDataName,gRangeBegin)
		xmax= pnt2x($gYDataName,gRangeEnd)
	else
		WaveStats/Q/R=[gRangeBegin,gRangeEnd] $gXDataName
		xmin=V_min
		xmax=V_max
	endif
	gXMin= xmin
	gXMax= xmax

	WaveStats/Q/R=[gRangeBegin,gRangeEnd] $gYDataName
	cw[0]= (xmin+xmax)/2
	cw[1]= xmax-xmin
	if( abs(V_min) < 0.01*abs(V_max) )		// protect against near zero baseline (singlar matrix)
		cw[2]= 0.01*V_max				// estimate of offset
	else
		cw[2]= V_min				// estimate of offset
	endif
	cw[3]= (V_max-V_min)*0.01	// fairly arbitrary estimate for ...
	cw[4]= cw[3]				// coeff of x
	cw[5]= cw[3]				// coeff of x^2
	cw[6]= cw[3]				// coeff of x^3
	

	// AUTOFIND
	if( isAuto )
		DoMPSetCoefsFromAutoFind(6,4,cw)
	else
		Variable i,cp=1,delta= (xmax-xmin)/(gNumPeaks+1)
		do
			 i=6+4*(cp-1)
			cw[i]= {V_max-V_min,xmin+cp*delta,delta/10,1}
			cp += 1
		while( cp<=gNumPeaks)
	
	endif

	UpdateCurSettings()
	CalculateData()
End

Proc MakeGraph()
	PauseUpdate; Silent 1		// building window...

	String gXDataName= root:Packages:WMmpFitting:gXDataName
	String gYDataName= root:Packages:WMmpFitting:gYDataName
	String gFitDataName= root:Packages:WMmpFitting:gFitDataName
	String gResidsName= root:Packages:WMmpFitting:gResidsName
	
	Variable isYN= cmpstr(gXDataName,"_calculated_") == 0

	if( isYN )
		Display /W=(5,42,410,401) $gYDataName,$gFitDataName
		Append/L=lr $gResidsName
	else
		Display /W=(5,42,410,401) $gYDataName,$gFitDataName vs $gXDataName
		Append/L=lr $gResidsName vs $gXDataName
	endif
	ModifyGraph margin(left)=73,wbRGB=(49151,65535,49151),gbRGB=(49151,60031,65535)
	ModifyGraph mode($gYDataName)=3,mode($gResidsName)=2
	ModifyGraph marker($gYDataName)=8,marker($gResidsName)=19
	ModifyGraph lSize($gFitDataName)=2,lSize($gResidsName)=2
	ModifyGraph rgb($gFitDataName)=(0,0,65535)
	ModifyGraph msize($gYDataName)=2,msize($gResidsName)=2
	ModifyGraph mirror(left)=1,mirror(lr)=1
	ModifyGraph nticks(left)=4,nticks(lr)=2
	ModifyGraph minor=1
	ModifyGraph lowTrip(lr)=0.001
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	ModifyGraph lblPos(left)=68,lblPos(lr)=68
	ModifyGraph freePos(lr)=0
	ModifyGraph axisEnab(left)={0,0.75}
	ModifyGraph axisEnab(lr)={0.8,1}
	Label left "Amplitude"
	Label bottom "Wavelength, \\U"
	Label lr "Residuals"
	SetAxis/A/N=1 left
	SetAxis/A bottom
	SetAxis/A/N=1/E=2 lr
EndMacro


Proc SetVarProcCoef(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SetAPeak()
End

Proc ProcNextPeak(ctrlName) : ButtonControl
	String ctrlName

	root:Packages:WMmpFitting:gCurPeak= mod(root:Packages:WMmpFitting:gCurPeak,root:Packages:WMmpFitting:gNumPeaks)+1
	UpdateCurSettings()
	SetCursorsForCurPeak()
End

Proc BProcDone(ctrlName) : ButtonControl
	String ctrlName

	KillControl gb0
	KillControl gb1
	KillControl gb2
	ControlBar 0
End

Proc BProcSaveSet(ctrlName) : ButtonControl
	String ctrlName

	if( CheckPeakPackage() )
		return
	endif

	Duplicate/O $":WMPeakFits:Current:masterCoef" $(":WMPeakFits:Current:CoefSet"+num2istr(root:Packages:WMmpFitting:gSaveSet))
	Duplicate/O $":WMPeakFits:Current:masterCoefHold" $(":WMPeakFits:Current:CoefHoldSet"+num2istr(root:Packages:WMmpFitting:gSaveSet))
End

Proc PProcRecall(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if( CheckPeakPackage() )
		return
	endif
	
	Duplicate/O $":WMPeakFits:Current:"+popStr $":WMPeakFits:Current:masterCoef" 
	root:Packages:WMmpFitting:gSaveSet= str2num(popStr[strlen("CoefSet"),100])
	Duplicate/O $(":WMPeakFits:Current:CoefHoldSet"+num2istr(root:Packages:WMmpFitting:gSaveSet)), $":WMPeakFits:Current:masterCoefHold" 
	
	Variable npks= (numpnts($":WMPeakFits:Current:masterCoef")-6)/4	
	root:Packages:WMmpFitting:gNumPeaks= npks	// NOTE: done in two steps because previous rhs would have been evaluted in context of DF= root:Packages: etc
	UpdateCurSettings()
	CalculateData()
	SetVariable SetPkNum limits={1,root:Packages:WMmpFitting:gNumPeaks,1}
End

Function/S ListCoefSetWaves()
	if( !DataFolderExists(":WMPeakFits:Current") )
		return ""
	endif
	SetDataFolder :WMPeakFits:Current
	String s= WaveList("CoefSet*",";","")
	SetDataFolder :::
	return s
end

Proc MakeFitSetupPanel()
	PauseUpdate; Silent 1		// building window...
	String dfSav= GetDataFolder(1)
	
	SetDataFolder root:Packages:WMmpFitting

	NewPanel/K=1 /W=(302,39,529,445)
	DoWindow/C FitSetupPanel
	SetDrawLayer UserBack
	SetDrawEnv rounding= 20,fillpat=0,save
	DrawRRect 9,15,217,84
	SetDrawEnv fstyle= 1,textrgb= (0,0,65535)
	DrawText 15,106,"Initial Values"
	DrawRRect 9,106,217,249
	DrawLine 8,130,214,130
	SetDrawEnv fsize= 10,textxjust= 2,textyjust= 1
	DrawText 69,119,"For Peak #"
	SetDrawEnv fname= "Geneva",fsize= 9,textxjust= 2,textyjust= 1
	DrawText 70,144,"Amplitude:"
	SetDrawEnv fname= "Geneva",fsize= 9,textxjust= 2,textyjust= 1
	DrawText 70,163,"Position:"
	SetDrawEnv fname= "Geneva",fsize= 9,textxjust= 2,textyjust= 1
	DrawText 70,184,"Width:"
	SetDrawEnv fname= "Geneva",fsize= 9,textxjust= 2,textyjust= 1
	DrawText 70,203,"Voigt Shape:"
	DrawRRect 7,277,218,373
	DrawLine 178,106,178,219
	SetDrawEnv fsize= 9,textxjust= 1,textyjust= 1
	DrawText 193,114,"From"
	SetDrawEnv fsize= 9,textxjust= 1,textyjust= 1
	DrawText 196,123,"cursor"
	SetDrawEnv fsize= 10,textxjust= 2,textyjust= 1
	DrawText 122,118,"of"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65535),textxjust= 1
	DrawText 31,16,"Data"
	DrawLine 9,219,215,219
	SetDrawEnv fstyle= 1,textrgb= (0,0,65535)
	DrawText 17,275,"Fitting Function"
	SetDrawEnv fname= "Geneva",fsize= 9,textrot= 90
	DrawText 163,127,"Hold"
	SetVariable setvar0,pos={125,111},size={27,15},proc=SetVarProcNPeaks,title=" "
	SetVariable setvar0,limits={1,1000,0},value=gNumPeaks
	SetVariable SetPkNum,pos={73,111},size={37,15},proc=SetPeakNumProc,title=" "
	SetVariable SetPkNum,limits={1,4,1},value=gCurPeak
	SetVariable setvar2,pos={73,137},size={87,13},proc=SetVarProcCoef,title=" "
	SetVariable setvar2,fSize=10,limits={-INF,INF,0},value=gPeakAmp
	SetVariable setvar3,pos={73,156},size={87,13},proc=SetVarProcCoef,title=" "
	SetVariable setvar3,fSize=10,format="%g",limits={-INF,INF,0},value=gPeakPos
	SetVariable setvar4,pos={73,177},size={87,13},proc=SetVarProcCoef,title=" "
	SetVariable setvar4,fSize=10,format="%g",limits={-INF,INF,0},value=gPeakWidth
	Button DoFitButton,pos={51,377},size={114,25},proc=fitProc,title="Do Fit"
	SetVariable setvar5,pos={73,197},size={87,13},proc=SetVarProcCoef,title=" "
	SetVariable setvar5,fSize=10,limits={0,INF,0},value=gVoigtShape
	PopupMenu popupFunc,pos={21,283},size={149,19},proc=PopProcFunc,title="Function:"
	PopupMenu popupFunc,mode=1,value= #"\"Gaussian;Lorentzian;Voigt\""
	CheckBox checkBL,pos={22,306},size={80,20},proc=CheckProcDoBaseline,title="Baseline",value=0
	CheckBox checkCW,pos={124,306},size={80,20},proc=CheckProc1Width,title="1 width",value=0
	CheckBox checkCS,pos={124,328},size={80,20},proc=CheckProc1Shape,title="1 shape",value=0
	CheckBox checkUseX,pos={22,328},size={95,20},proc=CheckProcUseXFUNCs,title="use XFUNCs",value=0
	PopupMenu popupYData,pos={17,18},size={77,19},title="Y: "
	PopupMenu popupYData,mode=1,value= #"WaveList(\"*\",\";\",\"\")"
	PopupMenu popupXData,pos={17,40},size={85,19},title="X: "
	PopupMenu popupXData,mode=3,value= #"\"_calculated_;\"+WaveList(\"*\",\";\",\"\")"
	Button b0,pos={185,136},size={18,14},proc=ButtonProcAmpFromCsrA,title="A"
	Button b1,pos={185,155},size={18,14},proc=ButtonProcAmpFromCsrA,title="A"
	Button b2,pos={181,175},size={28,14},proc=ButtonProcAmpFromCsrA,title="A-B"
	Button button0,pos={83,62},size={50,17},proc=ButtonProcNewGraph,title="Graph"
	Button button1,pos={22,62},size={50,17},proc=ButtonProcSet,title="Set"
	Button bSave,pos={16,223},size={50,20},proc=BProcSaveSet,title="Save"
	SetVariable setvar1,pos={70,224},size={65,15},title="Set",format="%d"
	SetVariable setvar1,limits={0,10,1},value=gSaveSet
	PopupMenu popRecall,pos={144,223},size={64,19},proc=PProcRecall,title="Recall"
	PopupMenu popRecall,mode=0,value= #"ListCoefSetWaves()"
	ValDisplay valdisp0,pos={48,352},size={152,15},title="Chi Square"
	ValDisplay valdisp0,limits={0,0,0},barmisc={0,1000},value= #"root:Packages:WMmpFitting:gChiSquare"
	CheckBox checkAmp,pos={161,133},size={16,20},proc=CheckProcHold,title="",value=0
	CheckBox checkPos,pos={161,152},size={16,20},proc=CheckProcHold,title="",value=0
	CheckBox checkWid,pos={161,173},size={16,20},proc=CheckProcHold,title="",value=0
	CheckBox checkVS,pos={161,193},size={16,20},proc=CheckProcHold,title="",value=0
// AUTOFIND
	Button buttonAuto,pos={105,87},size={50,17},proc=ShowAutoBP,title="Auto..."
// MANPEAKS
	Button buttonMan size={50,17},proc=ShowManBP,title="Man..."
	SetDataFolder dfSav
EndMacro


// *********************************************************************
// AUTOFIND

Function ShowAutoFindPanel()
	DoWindow/F AutoFindPanel
	if( V_Flag )
		return 0
	endif
	NewPanel/K=1 /W=(635,345,836,564)
	DoWindow/C AutoFindPanel
	AutoPositionWindow
	SetDrawLayer UserBack
	SetDrawEnv xcoord= rel,ycoord= abs
	DrawLine 0,56,1,56
	SetDrawEnv xcoord= rel,ycoord= abs
	DrawLine 0,127,1,127
	SetVariable svNoise,pos={56,86},size={112,15},title="Noise est:",format="%.2g"
	SetVariable svNoise,limits={-Inf,Inf,0},value= root:Packages:WMmpFitting:gNoiseEstFromAutoFind
	SetVariable smFact,pos={58,106},size={109,15},title="Smoothing"
	SetVariable smFact,limits={-Inf,Inf,0},value= root:Packages:WMmpFitting:gSmoothEstFromAutoFind
	Button AutoEst,pos={23,61},size={126,20},proc=AutoFindPeakBP,title="Estimate Params"
	Button AutoFind,pos={25,180},size={126,20},proc=AutoFindPeakBP,title="Find Peaks"
	CheckBox CheckAuto,pos={28,22},size={160,20},proc=DoAutoCheck,title="Do Autofind on Set",value=1
	SetVariable NoiseAmpFactor,pos={18,135},size={170,15},title="Noise Amp Factor"
	SetVariable NoiseAmpFactor,format="%d"
	SetVariable NoiseAmpFactor,limits={-2,5,1},value= root:Packages:WMmpFitting:gMinPeakNoiseFactor
	SetVariable MinFract,pos={18,156},size={170,15},title="Minimum Fraction"
	SetVariable MinFract,limits={0,0.5,0.01},value= root:Packages:WMmpFitting:gMinPeakFraction
EndMacro


Function AutoFindPeakBP(ctrlName) : ButtonControl
	String ctrlName
	
	if( CmpStr(ctrlName,"AutoEst") == 0 )
		DoMP_EstPeakNoiseAndSmfact()
	endif
	if( CmpStr(ctrlName,"AutoFind") == 0 )
		DoMP_AutoFIndNoSet()
	endif
End

Function DoAutoCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable/G root:Packages:WMmpFitting:gDoAutoPeakFind = checked
End


Function ShowAutoBP(ctrlName) : ButtonControl
	String ctrlName

	ShowAutoFindPanel()
End


Function DoMP_EstPeakNoiseAndSmfact()
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd

	if( NumType(gRangeEnd-gRangeBegin)!=0 )
		DoAlert 0,"Click the Setup button first"
		return 0
	endif



	Variable/C ctmp= EstPeakNoiseAndSmfact($gYDataName,gRangeBegin,gRangeEnd)

	Variable/G root:Packages:WMmpFitting:gNoiseEstFromAutoFind= real(ctmp)
	Variable/G root:Packages:WMmpFitting:gSmoothEstFromAutoFind= imag(ctmp)
end

Function DoMP_AutoFindPeaks()
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	SVAR gXDataName= root:Packages:WMmpFitting:gXDataName
	NVAR gRangeBegin= :WMPeakFits:Current:gRangeBegin
	NVAR gRangeEnd= :WMPeakFits:Current:gRangeEnd
	NVAR gNoiseEstFromAutoFind= root:Packages:WMmpFitting:gNoiseEstFromAutoFind
	NVAR gSmoothEstFromAutoFind= root:Packages:WMmpFitting:gSmoothEstFromAutoFind
	NVAR gMinPeakFraction= root:Packages:WMmpFitting:gMinPeakFraction
	NVAR gMinPeakNoiseFactor= root:Packages:WMmpFitting:gMinPeakNoiseFactor
	

	if( NumType(gRangeEnd-gRangeBegin)!=0 )
		DoAlert 0,"Click the Setup button first"
		return 0
	endif


	Variable npks,noiseFactor= gNoiseEstFromAutoFind*3^gMinPeakNoiseFactor

	npks= AutoFindPeaks($gYDataName,gRangeBegin,gRangeEnd, noiseFactor, gSmoothEstFromAutoFind,Inf)
	Wave wpi= W_AutoPeakInfo			// may or may not exist
	if( npks>0 )
		AdjustAutoPeakInfoForX(wpi,$gYDataName,$gXDataName)
		npks= TrimAmpAutoPeakInfo(wpi,gMinPeakFraction)
	endif
	return npks
end

// AUTOFIND
Function DoMPSetCoefsFromAutoFind(firstCoef,numCoef,cw)
	Variable firstCoef,numCoef
	Wave cw
	
	if( numCoef!=4 )
		Abort "Rewrite DoMPSetCoefsFromAutoFind. Mismatch in number of coefs for each peak"
	endif

	Wave wpi= W_AutoPeakInfo	
	Variable npks= DimSize(wpi,0)
	if( npks==0 )
		return 0
	endif
	
	Make/O/N=(npks) wpiTmpIndex,wpiTmpPos=wpi[P][0]		//extract the column of positions
	MakeIndex 	wpiTmpPos,wpiTmpIndex

	Variable i,cp=0,cps
	do
		 i= firstCoef+numCoef*(cp)
		 cps= wpiTmpIndex[cp]				// access autofind data in ascending position order

		// MYCUSTOM - edit to translate results of autofind into initial guesses for peaks
		cw[i]= wpi[cps][2]
		cw[i+1]=wpi[cps][0]
		cw[i+2]= wpi[cps][1]
		cw[i+3]= 1
		cp += 1
	while( cp<npks)
	
	KillWaves wpiTmpPos,wpiTmpIndex
end	

Function DoMP_AutoFIndNoSet()
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak

	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef	

	wave/Z cw= $":WMPeakFits:Current:masterCoef"
	if( !WaveExists(cw) )
		DoAlert 0,"Click the Setup button first"
		return 0
	endif

	gNumPeaks= DoMP_AutoFindPeaks()
	gCurPeak= 1
	SetVariable SetPkNum win=FitSetupPanel, limits={1,gNumPeaks,1}
	Redimension/N=(gFirstCoef+gNumCoef*gNumPeaks) $":WMPeakFits:Current:masterCoef",$":WMPeakFits:Current:masterCoefHold"
	DoMPSetCoefsFromAutoFind(gFirstCoef,gNumCoef,cw)

	UpdateCurSettings()
	CalculateData()
End

Function UpdateCurPeakTag(gCurPeak)
	Variable gCurPeak

	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName

	String bname= "Peak",fname				// basename for individual peak waves
	fname= 	bname+num2istr(gCurPeak)	// peak numbers start with 1
	Wave/Z w=  :WMPeakFits:Current:$fname

	if( WaveExists(w) == 0 )
		return 0
	endif

	Variable cent= Pnt2X(w,NumPnts(w)/2-1)

	CheckDisplayed/W=$WinName(0, 1) $gYDataName
	fname= TraceNameForWave(WinName(0, 1),w)
	if( V_Flag == 1 )
		CheckDisplayed/W=$WinName(0, 1) w
		if( V_Flag == 1 )
			Tag/C/N=text0/F=0/S=3/B=1/A=MB/X=0.00/Y=8.64/P=10 $fname, cent, "\\JCcurrent\rpeak"
		endif
	endif
end


Function/S TraceNameForWave(graphName,w)
	String graphName
	Wave w
	
	Variable i=0
	do
		String tname= NameOfWave(w)+"#"+num2istr(i)
		WAVE/Z tw= TraceNameToWaveRef(graphName,tname )
		if( !WaveExists(tw) )
			return ""
		endif
		if( CmpStr(GetWavesDataFolder(w,1),GetWavesDataFolder(tw,1)) == 0 )
			break
		endif
		i+=1
	while(1)
	return tname
end
		

// *********************************************************************
// MANPEAKS


Function ShowManualPeaksPanel()
	DoWindow/F ManualPeaksPanel
	if( V_Flag )
		return 0
	endif
	NewPanel /K=1 /W=(257,78,459,221)
	DoWindow/C ManualPeaksPanel
	AutoPositionWindow
	Button KillCurrent,pos={15,7},size={169,20},proc=ManPeakBP,title="Delete Current Peak"
	Button InsertNew,pos={15,31},size={169,20},proc=ManPeakBP,title="Insert New Peak"
	Button EditOld,pos={15,55},size={169,20},proc=ManPeakBP,title="Edit Old Peak"
	Button undo,pos={77,116},size={50,20},proc=ManPeakBP,title="Undo"
	String dfSav= InitManualPeakPlacePackage()
	SetVariable Message,pos={5,83},size={192,15},title=" "
	SetVariable Message,limits={-Inf,Inf,1},value= gMessage
	SetWindow ManualPeaksPanel,hook=ManualPeaksPanelHookProc
	SetDataFolder dfSav
End

Function ManualPeaksPanelHookProc(infoStr)
	String infoStr
	
	if( StrSearch(infoStr,"EVENT:kill;",0) > 0 )
		EndManualPeakMode()
	endif
	return 0
end	

Function ShowManBP(ctrlName) : ButtonControl
	String ctrlName

	ShowManualPeaksPanel()
End


Function ManPeakBP(ctrlName) : ButtonControl
	String ctrlName
	
	if( CmpStr(ctrlName,"KillCurrent") == 0 )
		DoMP_KillCurrentPeak()
	endif
	if( CmpStr(ctrlName,"InsertNew") == 0 )
		KillControl KillCurrent
		KillControl InsertNew
		KillControl EditOld
		Button Finish,pos={9,31},size={160,20},proc=ManPeakBP,title="Finish Insert"
		SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
		StartManualPeakMode($gYDataName,"MB_PeakEditCallback",$"",$"")
	endif
	if( CmpStr(ctrlName,"EditOld") == 0 )
		KillControl KillCurrent
		KillControl InsertNew
		KillControl EditOld
		Button Finish,pos={8,55},size={160,20},proc=ManPeakBP,title="Finish Edit Old"
		DoMP_EditOldPeak()
	endif
	if( CmpStr(ctrlName,"Finish") == 0 )
		EndManualPeakMode()
		KillControl Finish
		Button KillCurrent,pos={8,7},size={160,20},proc=ManPeakBP,title="Delete Current Peak"
		Button InsertNew,pos={9,31},size={160,20},proc=ManPeakBP,title="Insert New Peak"
		Button EditOld,pos={8,55},size={160,20},proc=ManPeakBP,title="Edit Old Peak"
	endif
	if( CmpStr(ctrlName,"Undo") == 0 )
		EndManualPeakMode()
		KillControl Finish
		Button KillCurrent,pos={8,7},size={160,20},proc=ManPeakBP,title="Delete Current Peak"
		Button InsertNew,pos={9,31},size={160,20},proc=ManPeakBP,title="Insert New Peak"
		Button EditOld,pos={8,55},size={160,20},proc=ManPeakBP,title="Edit Old Peak"
		DoMP_UndoManMods()
	endif
End

Function DoMP_KillCurrentPeak()
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef
	
	Wave mc= $":WMPeakFits:Current:masterCoef"
	Wave mch= $":WMPeakFits:Current:masterCoefHold"

	// for undo
	Duplicate/O mc,$":WMPeakFits:Current:masterCoefManBak"
	Duplicate/O mch $":WMPeakFits:Current:CoefHoldSetManBak"

	DeletePoints gFirstCoef+(gCurPeak-1)*gNumCoef,gNumCoef,mc,mch
	gNumPeaks -= 1

	SetVariable SetPkNum win=FitSetupPanel, limits={1,gNumPeaks,1}

	UpdateCurSettings()
	CalculateData()

	// for undo
	Duplicate/O mc,$":WMPeakFits:Current:masterCoefManRecent"
	Duplicate/O mch $":WMPeakFits:Current:CoefHoldSetManRecent"
end


Function DoMP_EditOldPeak()
	SVAR gYDataName= root:Packages:WMmpFitting:gYDataName
	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef
	wave mc= $":WMPeakFits:Current:masterCoef"
	Make/O/T/N=(gNumPeaks) peaknames
	Make/O/N=(gNumPeaks,gNumCoef+1) peakcoefs=0
	Variable i=0
	Do
		peaknames[i]= "Peak"+num2istr(i+1)
		peakcoefs[i][1,3]= mc[gFirstCoef+i*gNumCoef+Q-1]
		i+=1
	while(i<gNumPeaks)
	StartManualPeakMode($gYDataName,"MB_PeakEditCallback",peaknames,peakcoefs)
	KillWaves peaknames,peakcoefs
end

Function MB_PeakEditCallback(pk,y0,a,x0,w)
	Variable pk,y0,a,x0,w
	
//	print y0,a,x0,w

	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef

	wave ww= $":WMPeakFits:Current:masterCoef"
	
	// for undo
	Duplicate/O ww,$":WMPeakFits:Current:masterCoefManBak"
	Duplicate/O $":WMPeakFits:Current:masterCoefHold" $":WMPeakFits:Current:CoefHoldSetManBak"

	if( pk==0 )
		gNumPeaks += 1
		SetVariable SetPkNum win=FitSetupPanel, limits={1,gNumPeaks,1}
		Redimension/N=(gFirstCoef+gNumCoef*gNumPeaks) ww,$":WMPeakFits:Current:masterCoefHold"
		pk= gNumPeaks
	endif
	
	// MYCUSTOM - edit to install correct parameters based on gaussian parameters
	if( gNumCoef!=4 )
		Abort "Rewrite MB_PeakEditCallback. Mismatch in number of coefs for each peak"
	endif
	ww[gFirstCoef+gNumCoef*(pk-1)]= {a,x0,w,1}

	NVAR gCurPeak= root:Packages:WMmpFitting:gCurPeak
	gCurPeak= MB_SortPeaks(pk)		// pk is presort peak number to become current peak in panel
	UpdateCurSettings()
	CalculateData()

	// for undo
	Duplicate/O ww,$":WMPeakFits:Current:masterCoefManRecent"
	Duplicate/O $":WMPeakFits:Current:masterCoefHold" $":WMPeakFits:Current:CoefHoldSetManRecent"
end

Function MB_SortPeaks(newCurPeak)
	Variable newCurPeak

	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef
	
	wave mc= $":WMPeakFits:Current:masterCoef"
	Wave mch= $":WMPeakFits:Current:masterCoefHold"

	NewDataFolder/O/S spTmp
	
	Duplicate/O mc,mcOld
	Duplicate/O mch,mchOld
	Make/O/D/N=(gNumPeaks) sortX,sortIndex
// MYCUSTOM - edit to ensure the following index refers to the position coef. 
	sortX= mc[gFirstCoef+P*gNumCoef+1]		// position is index 1 of a group (0 is amp, 2 is width)
	
	MakeIndex sortX,sortIndex
	Variable i=0,destp0,srcp0
	do
		destp0= gFirstCoef+i*gNumCoef
		srcp0= gFirstCoef+sortIndex[i]*gNumCoef
		mc[destp0,destp0+gNumCoef]= mcOld[srcp0+P-destp0]
		mch[destp0,destp0+gNumCoef]= mchOld[srcp0+P-destp0]
		i+=1
	while(i<gNumPeaks)
	
	MakeIndex sortIndex,sortIndex					// convert into inverse table
	Variable rval= sortIndex[newCurPeak-1]+1	// returns new standing of old position

	
	KillDataFolder :
//SetDataFolder ::

	return rval
end

Function DoMP_UndoManMods()

	// most recent 
	WAVE/Z mcLast= $":WMPeakFits:Current:masterCoefManRecent"
	WAVE/Z hcLast=  $":WMPeakFits:Current:CoefHoldSetManRecent"
	// current
	WAVE/Z mc= $":WMPeakFits:Current:masterCoef"
	WAVE/Z hc= $":WMPeakFits:Current:masterCoefHold"
	// backup
	WAVE/Z mcBak= $":WMPeakFits:Current:masterCoefManBak"
	WAVE/Z hcBak=  $":WMPeakFits:Current:CoefHoldSetManBak"
	if( !WaveExists(mcLast) %|  !WaveExists(mc)  %| !WaveExists(hcLast) %|  !WaveExists(hc)  %| !WaveExists(mcBak) %|  !WaveExists(hcBak))
		Abort "Nothing to undo"
	endif
	
	Variable np= numpnts(mc),npLast= numpnts(mcLast)
	Variable doIt= 1
	if( np==npLast )
		Variable i=0
		do
			if( mc[i]!=mcLast[i] )		// exact comparison ok because no calculations have been done
				doIt= 0
				break
			endif
			i+=1
		while( i<np)
	endif
	
	if( !doIt )
		DoAlert 1,"Coefs have been modified since last Manual adjustment. Do undo anyway?"
		if( V_FLag!=1 )
			return 0
		endif
	endif
	
	Duplicate/O mcBak,mc
	Duplicate/O hcBak,hc
	
	Duplicate/O mcLast,mcBak
	Duplicate/O hcLast,hcBak
	
	Duplicate/O mc,mcLast
	Duplicate/O hc,hcLast

	NVAR gNumPeaks= root:Packages:WMmpFitting:gNumPeaks
	NVAR gFirstCoef= root:Packages:WMmpFitting:gFirstCoef
	NVAR gNumCoef= root:Packages:WMmpFitting:gNumCoef

	gNumPeaks= (numpnts(mc)-gFirstCoef)/gNumCoef	
	UpdateCurSettings()
	CalculateData()
	SetVariable SetPkNum win=FitSetupPanel, limits={1,gNumPeaks,1}	// just in case gNumPeaks changed
end