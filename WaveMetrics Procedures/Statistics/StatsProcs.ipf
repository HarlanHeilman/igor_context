#pragma rtGlobals=1		// Use modern global access method.

// 08MAR05
// This file contains an assortment of user functions that may be handy in various statistical calculations.
// [REF: Jerold H. Zar  Biostatistical Analysis 4th ed. ISBN 0-13-081542-X]

//========================================================================
// The following is just an extension of the built-in StudentT function which returns the T values
// for a given probability (area) and degree of freedom  in the case of a one-tailed distribution.
Function WM_OneTailStudentT(probability,degreesOfFreedom)
	Variable probability,degreesOfFreedom
	
	if(probability>=0.5)
		return StudentT(2*(probability-.5),degreesOfFreedom)
	else
		return -StudentT((1-2*probability),degreesOfFreedom)
	endif
End

//========================================================================
// The following is an extension of the built-in StudentA function which returns the area (probability)
// given the t-value and the degrees of freedom assuming a one-tailed distribution.
Function WM_OneTailStudentA(tValue,degreesOfFreedom)
	Variable tValue,degreesOfFreedom

	if(tValue==0)
		return 0.5
	elseif(tValue<0)
		return .5*(1-studentA(-tValue,degreesOfFreedom))
	else
		return 0.5*(1+studentA(tValue,degreesOfFreedom))
	endif
End

//========================================================================
// computes the harmonic average of the input wave.  NaNs and INFs are not counted.
// The harmonic average is defined as xbar=N/sum(1/w[i]) where w[i] are the values 
// in the input wave and N is the total number of finite w[i]'s.
Function WM_GetHarmonicMean(inWave)
	Wave inWave

	WaveTransform inverse inWave
	// Depending on the dimensionality of the input we have different named results.
	if(DimSize(inWave,1)>0)
		Wave out=M_Inverse
	else
		Wave out=W_Inverse
	endif
	
	Variable theSum=sum(out)
	
	// if there are no NaNs or infs
	if(numType(theSum)==0)
		KillWaves/Z out
		return numpnts(inWave)/theSum
	endif
	
	WaveStats/Q/M=1 out		//to get V_npnts that does not include NaNs/Infs
	out=SelectNumber(numtype(out[p])==2,out[p],0)	
	Variable hm=V_npnts/sum(out)
	KillWaves/Z out
	return hm
End

//========================================================================
// computes a geometric average.  Zeros and negative points in the input wave are ignored.
// The Geometric average is defined as the Nth root of the product of the N data points. 
Function WM_GetGeometricAverage(inWave)
	Wave inWave
	
	Duplicate/O inWave WM_tmp
	WM_tmp=log(inWave)				// this could create lots of NaNs/INFs
	WaveStats/Q WM_tmp
	WM_tmp=SelectNumber(numtype(WM_tmp[p])==2,WM_tmp[p],0)	
	Variable geoAverage=10^(Sum(WM_tmp)/V_npnts)
	KillWaves/Z WM_tmp
	return geoAverage
End

//========================================================================
// Use the following function to estimate the required sample size given sample variance,
// confidenceHW is the half-width of the required confidence interval,
// alpha is the significance [critical value (typically 0.05)].
// largeSize is an integer that is larger than the expected sample size.  It is used 
// for bracketing the search for the ideal value.
// This function will return NaN if it is unable to find a solution to the problem
// between n=2 and n=largeSize.
// [REF: Jerold H. Zar P. 105-106]
// See a variation below for the case that the power (1-beta) is given.
Function WM_EstimateReqSampleSize(sampleVar,confidenceHW,alpha,largeSize)
	Variable sampleVar,confidenceHW,alpha,largeSize
	
	Make/O/N=2 wm_ww={sampleVar/confidenceHW^2,(1-alpha)}
	FindRoots/Q/B=0/L=2/H=(largeSize)  WM_SSEstimatorFunc,wm_ww
	KillWaves/Z wm_ww
	return  V_Root
End

Function WM_SSEstimatorFunc(w,x)
	Wave w
	Variable x

	x=trunc(x)
	return  x-w[0]*(studentT(w[1],x-1))^2
End
//========================================================================
// The following example is similar to the one above except that here we also provide the power (via
// beta).
// [REF: Jerold H. Zar P. 107  example 7.7]
Function WM_EstimateReqSampleSize2(sampleVar,confidenceHW,alpha,beta,largeSize)
	Variable sampleVar,confidenceHW,alpha,largeSize,beta
	
	Make/O/N=3 wm_ww={sampleVar/confidenceHW^2,(1-alpha),(1-beta)}
	FindRoots/Q/B=0/L=2/H=(largeSize)  WM_SSEstimatorFunc2,wm_ww
	KillWaves/Z wm_ww
	return  V_Root
End

Function WM_SSEstimatorFunc2(w,x)
	Wave w
	Variable x

	x=trunc(x)
	return  x-w[0]*(studentT(w[1],x-1)+WM_OneTailStudentT(w[2],x-1))^2
End
//========================================================================
// The following function computes the minimum detectable difference for a single sample, given
// the sample size, sample variance, the significance (alpha) and power (1-beta).
// The units of the result are the square root of the units of sampleVar.
// [Ref Jerold H. Zar P. 107 example 7.8]
Function WM_EstimateMinDetectableDiff(sampleVar,dataSize,alpha,beta)
	Variable sampleVar,dataSize,alpha,beta
	
	Variable df=dataSize-1
	return sqrt(sampleVar/dataSize)*(studentT(1-alpha,df)+WM_OneTailStudentT(1-beta,df))
End
//========================================================================
// Given the mean and the variance of a sample, the following function computes the CI (Confidence Interval)
// range and returns the half CI.  Note that it takes the alpha parameter so that if you want 95% confidence
// interval you need to use alpha=0.05.
// [Ref Jerold H. Zar P. 99]
Function WM_MeanConfidenceInterval(sampleMean,sampleVariance,degreesOfFreedom,alpha)
	Variable sampleMean,sampleVariance,degreesOfFreedom,alpha
	
	Variable halfConfidenceInterval=sqrt(sampleVariance)*StudentT((1-alpha),degreesOfFreedom)
	Printf "[%g,%g]\r",sampleMean-halfConfidenceInterval,sampleMean+halfConfidenceInterval
	return halfConfidenceInterval
End
//========================================================================
// Given the sampleVariance and the degrees of freedom, the following function computes the CI (confidence
// interval) for the population's standard deviation using the two-tailed Chi-squared.
// [Ref Jerold H. Zar P. 111]
Function WM_VarianceConfidenceInterval(sampleVariance,degreesOfFreedom,alpha)
	Variable sampleVariance,degreesOfFreedom,alpha
	
	alpha/=2
	sampleVariance*=degreesOfFreedom
	Variable ChiSquaredLow=statsInvChiCdf(1-alpha,degreesOfFreedom)
	Variable ChiSquaredHigh=statsInvChiCdf(alpha,degreesOfFreedom)
	Printf "[%g,%g]\r",sqrt(sampleVariance/ChiSquaredHigh),sqrt(sampleVariance/ChiSquaredLow)
End
//========================================================================
// The following computes the confidence limits for two populations means assuming that their variances
// are the same.  If the variances are not the same use WM_2MeanConfidenceIntervals2()
// The pooledVariance can be computed by WM_GetPooledVariance().
// Eq. (8.13) from [Ref Jerold H. Zar P. 130]
Function WM_2MeanConfidenceIntervals(mean1,numPts1,mean2,numPts2,pooledVariance,alpha)
	Variable mean1,numPts1,mean2,numPts2,pooledVariance,alpha

	Variable n=numPts1+numPts2-2
	Variable tValue=StudentT(1-alpha,n)
	Variable dx1=tValue*sqrt(pooledVariance/numPts1)
	Variable dx2=tValue*sqrt(pooledVariance/numPts2)
	Printf "Confidence limits are: [%g,%g] and [%g,%g] at %g%\r",mean1-dx1,mean1+dx1,mean2-dx2,mean2+dx2,(1-alpha)*100
End
//========================================================================

Function WM_2MeanConfidenceIntervals2()

End

//========================================================================
// Compute the pooled variance for two populations.
Function WM_GetPooledVariance(wave1,wave2)
	Wave wave1,wave2
	
	Variable n1,s1,n2,s2,spSquared
	WaveStats/Q wave1
	n1=V_npnts
	s1=V_sdev
	WaveStats/Q wave2
	n2=V_npnts
	s2=V_sdev
	spSquared=((n1-1)*s1^2+(n2-1)*s2^2)/(n1+n2-2)
	return spSquared
End
//========================================================================
// Compute the pooled mean (assuming that the two distributions come from populations having the same 
// mean value.

Function WM_GetPooledMean(mean1,numPts1,mean2,numPts2)
	Variable mean1,numPts1,mean2,numPts2
	
	return (numPts1*mean1+numPts2*mean2)/(numPts1+numPts2)
End
//========================================================================

// Eq. (8.16) from [Ref Jerold H. Zar P. 130]
Function WM_CIforPooledMean(mean1,numPts1,mean2,numPts2,pooledVariance,alpha)
	Variable mean1,numPts1,mean2,numPts2,pooledVariance,alpha
	
	Variable pooledMean=WM_GetPooledMean(mean1,numPts1,mean2,numPts2)
	Variable n=numPts1+numPts2-2
	Variable tValue=StudentT(1-alpha,n)
	Variable dx=tValue*sqrt(pooledVariance/(numPts1+numPts2))
	Printf "C.I. for pooled mean: [%g,%g] at %g% confidence\r",pooledMean-dx,pooledMean+dx,100*(1-alpha)
End

//========================================================================
// Get the size of two equal size samples that are required in order to estimate a difference in the means
// of two populations.
// largeSize is an integer that is larger than the expected sample size.  It is used 
// for bracketing the search for the ideal value.
// Eq. (8.20) from [Ref Jerold H. Zar P. 131]

Function WM_EstimateSampleSizeForDif(pooledVariance,alpha,diff,largeSize)
	Variable pooledVariance,alpha,diff,largeSize
	
	Make/O/N=2 wm_ww={2*pooledVariance/(diff^2),(1-alpha)}
	FindRoots/Q/B=0/L=2/H=(largeSize)  WM_SSEstimatorFunc3,wm_ww
	KillWaves/Z wm_ww
	return  V_Root
End

Function WM_SSEstimatorFunc3(w,x)
	Wave w
	Variable x

	x=trunc(x)
	return  x-w[0]*(studentT(w[1],2*(x-1)))^2
End
//========================================================================
Function WM_BernoulliCdf(xx,a,b)
	Variable xx,a,b

	Variable i
	if( xx < 0 )
		return 0
	elseif ( a <= xx )
		return 1
	elseif( b == 0.0 )
		return 1
	elseif ( b == 1.0 )
		return 0
	else
		Variable out=0
		for (i = 0; i <= xx; i+=1 )
			out+=binomial ( a, i)*b^i* ( 1.0 - b )^( a - i )
		endfor
		return out
	endif
End
//========================================================================
// Use StatsBinomialPDF
Function WM_BinomialPdf(xx,numTrials,pSuccessInOneTrial)
	Variable xx,numTrials,pSuccessInOneTrial

	if ( numTrials < 1  || xx<0 || numTrials <xx )
		return 0
	elseif (pSuccessInOneTrial==0.0)
		if (xx == 0)
			return 1
		else
			return 0
		endif
	elseif (pSuccessInOneTrial == 1.0)
		if (xx== numTrials )
			return 1
		else
			return 0
		endif
	else
		return  binomial(numTrials,xx)*pSuccessInOneTrial^xx*(1.0 - pSuccessInOneTrial)^ (numTrials - xx)
	endif
End
//========================================================================
// create a numeric wave containing the rank of each member of inTextWave.  Input is expected as 1-D text
// wave containing the letter grades: A,B,C,D,E,F with the possible modification of + or - for each letter grade.
// The modifiers must appear immediately after the letter.
// When there are ties, the average rank is selected.  The output is in W_rankedData.
// Both lower and upper case ascii characters can be used for the letter grades.  The grades are ranked from Higher
// to lower values.
// use WM_RankLetterGradesWithTies(inTextWave,wantReorder=1) if you want to create a text wave containing the ordered
// grades.

Function WM_RankLetterGradesWithTies(inTextWave [,wantReorder])
	Wave/T inTextWave
	Variable wantReorder
	
	if( ParamIsDefault(wantReorder))
		wantReorder=0
	endif
	
	Variable numPoints=DimSize(inTextWave,0)
	if(numPoints<=0)
		doAlert 0, "Empty input text wave."
		return 0
	endif
	
	Make/O/N=(numPoints) W_tmpValues
	if(wantReorder)
		Duplicate/T/O inTextWave,T_orderedGrades
	endif
	
	// Make/O/T/N=(numPoints) T_gradeRanks 
	Variable  i,letterValue,modifierValue
	String grade
	
	// convert the letter grades into numbers using the + or - to shift by 0.25 either way.
	for(i=0;i<numPoints;i+=1)
		grade=inTextWave[i]
		letterValue=char2num(grade[0])
		if(letterValue<=70)
			letterValue=71-letterValue
		else
			letterValue=103-letterValue
		endif
		
		// here we handle the + or -
		modifierValue=char2num(grade[1])
		if(numType(modifierValue)!=2)
			if(modifierValue==45)
				letterValue-=0.25
			elseif(modifierValue==43)
				letterValue+=0.25
			else
				String alertStr="Bad grade modifier encounered in point "+num2str(i)
				doAlert 0, alertStr
				return 0
			endif
		endif
		W_tmpValues[i]=letterValue
	endfor

	WM_RankForTies(W_tmpValues,1,1)			// 1 for reverse order
	
	if(wantReorder)
		Duplicate/O W_tmpValues,W_tmpValues2
		W_tmpValues2=p
		Sort/R W_tmpValues,W_tmpValues2
		Wave/Z W_rankedData
		if(WaveExists(W_rankedData))
			T_orderedGrades=inTextWave[W_tmpValues2[p]]
		endif
		KillWaves/z W_tmpValues2
	endif
	
	KillWaves/Z W_tmpValues
End
//========================================================================
// The rank wave can be base 0 (i.e., the first or last rank is zero) or base 1.
// The rank assigned to tied values is the mean of the ranks that would have been used
// if they were not tied (see Zar 9.5).
// Creates the output wave W_rankedData.

Function WM_RankForTies(inDataWave,base,reverseOrder)
	Wave inDataWave
	Variable base,reverseOrder

	if(base!=0 && base !=1)
		doAlert 0,"Bad base value."
		return 0
	endif
	
	String name
	name=UniqueName("W_tmpValues", 1, 0)
	Duplicate/O inDataWave,$name,W_rankedData
	Wave w=$name
	W_rankedData=p+base
	if(reverseOrder)
		Sort/R w,w,W_rankedData
	else
		Sort w,w,W_rankedData
	endif
	
	Variable numPoints=DimSize(inDataWave,0)
	Variable i,j,k,count,testValue,newRank
	i=0
	do
		testValue=w[i]
		count=0
		j=i
		do
			j+=1
			count+=1
			if(j>=numPoints)
				break
			endif
		while(testValue==w[j])
		
		if(count>1)
			newRank=i+(count+base)/2
			for(k=i;k<j;k+=1)
				W_rankedData[k]=newRank
			endfor
		else
			W_rankedData[i]=i+1
		endif
		
		if(count<=0)
			break
		endif
		i+=count
	while(i<numPoints)
	
	KillWaves/Z w
End
//========================================================================
// See Zar 9.5 and example 9.3.  Input pairs in two numerical waves of equal length.
// There is no accounting here for either ties or zeros.
Function WM_WilcoxonPairedRanks(waveA,waveB)
	Wave waveA,waveB
	
	Variable numPoints=numpnts(waveA)
	if(numPoints!=numpnts(waveB))
		doAlert 0,"Input waves must have the same number of points"
		return 0
	endif
	
	MatrixOP/O  W_tmp_difference=waveA-waveB
	MatrixOP/O  W_tmp_abs=abs(W_tmp_difference)
	Duplicate/O  W_tmp_difference,W_tmp_index
	
	W_tmp_index=p
	Sort W_tmp_abs,W_tmp_index
	WM_RankForTies(W_tmp_abs,1,0)
	Wave/Z W_rankedData
	if(WaveExists(W_rankedData)==0)
		return 0
	endif
	
	 W_rankedData*=sign(W_tmp_difference[W_tmp_index[p]])
 	 Duplicate/O W_rankedData,W_MatchedRank
 	 Variable i
  	Variable positiveRanks=0,negativeRanks=0
	
 	 for(i=0;i<numPoints;i+=1)
 		 W_MatchedRank[W_tmp_index[i]]=W_rankedData[i]
 		 if(W_rankedData[i]>0)
 		 	positiveRanks+=W_rankedData[i]
 		 else
 		 	negativeRanks+=W_rankedData[i]
 		 endif
 	endfor
 	
 	Printf  "(T+)=%g\t (T-)=%g\r",positiveRanks,negativeRanks
 		
	
	KillWaves/Z W_tmp_difference,W_tmp_index,W_tmp_abs
End

//========================================================================
// See Zar example 9.4 and example 9.7.
// The input wave should be square of minimum dimensions (2,2).
Function McNeamarTest(inWave,alpha)
	Wave inWave
	Variable alpha
	
	Variable rows=DimSize(inWave,0)
	Variable cols=DimSize(inWave,1)
	if(rows!=cols || rows<1)
		doAlert 0,"Input matrix must be square and greater than 2."
		return 0
	endif
	
	Variable i,j,theSum=0,diff
	if(rows>2)
		for(i=0;i<rows;i+=1)
			for(j=i+1;j<rows;j+=1)
				diff=inWave[i][j]-inWave[j][i]
				theSum+=diff*diff/(inWave[i][j]+inWave[j][i])
			endfor
		endfor
	else
		theSum=(abs(inWave[0][1]-inWave[1][0])-1)^2/(inWave[0][1]+inWave[1][0])
	endif
	
	Variable df=rows*(rows-1)/2
	Variable criticalValue=statsInvChiCDF(1-alpha,df)

	Printf "ChiSquared=%g\t df=%d\t Critical Value=%g\r",theSum,df,criticalValue
	if(criticalValue>theSum)
		Print "Accept H0"
	else
		Print "Reject H0"
	endif
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

Function WM_GetANOVA1Power(n1,n2,delta,alpha)
	Variable n1,n2,delta,alpha

	return 1-statsNCFCDF(statsInvFCDF((1-alpha),n1,n2),n1,n2,delta)
End

//========================================================================
// Comparing two correlation coefficients.  Based on Zar chapter 19.  The inputs are the two correlation
// coefficients, their respective number of samples and the significance alpha (usually 0.05 or so).

Function WM_CompareCorrelations(r1,n1,r2,n2,alpha)
	Variable r1,n1,r2,n2,alpha

	Variable z1,z2								// Fisher-transformed values
	Variable sigma,zd							
	Variable zc									// critical value
	
	z1=0.5*ln((1+r1)/(1-r1))
	z2=0.5*ln((1+r2)/(1-r2))
	
	sigma=sqrt((1/(n1-3))+(1/(n2-3)))
	zd=(z1-z2)/sigma
	zc=StatsInvNormalCDF(1-alpha/2,0,1)
	Printf "Z=%g\t Critical=%g\r",zd,zc
	
	// Compute the common correlation coefficients and its transform
	Variable zcommon=((n1-3)*z1+(n2-3)*z2)/((n1-3)+(n2-3))
	Variable rcommon=tanh(zcommon)
	Printf "Common r=%g\t Common z=%g\r",rcommon,zcommon
	
	// note the factor of 2 in the following!
	Variable Pvalue=2*(1-StatsNormalCDF(abs(zd),0,1))
	Printf "P=%g\r",Pvalue
	
	// calculating the power of this test:
	Variable zb=abs(z1-z2)/sigma-zc
	Variable thePower=StatsNormalCDF(zb,0,1)
	Printf "Test Power=%g\r",thePower
End

//========================================================================
// Inverse prediction for linear regression.  See Zar 17.5.  The input consists of Y value and
// the wave W_StatsLinearRegression that results from the analysis of the data using StatsLinearRegression operation.
// Use isUpper=1 to get the high side of the confidence interval and isUpper=0 for the low side.  Note that the value
// of alpha is already coded into W_StatsLinearRegression.
// This function is written in unoptimized format in order to make it more readable.  If you 
// need to improve its pefromance you can hard-wire the wave elements replacing label based
// access.
Function WM_RegressionInversePrediction(inY,W_StatsLinearRegression,isUpper)
	Variable inY,isUpper
	Wave W_StatsLinearRegression
	
	Variable b=W_StatsLinearRegression[0][%b]
	Variable lct=W_StatsLinearRegression[0][%tc]
	Variable Sb=W_StatsLinearRegression[0][%Sb]
	Variable capK=b^2-(lct*Sb)^2
	Variable ybar=W_StatsLinearRegression[0][%yBar]
	Variable xBar=W_StatsLinearRegression[0][%xBar]
	Variable Syx=W_StatsLinearRegression[0][%Syx]
	Variable N=W_StatsLinearRegression[0][%N]
	Variable sx2=W_StatsLinearRegression[0][%sumx2]
	
	if(isUpper==0)
		isUpper=-1
	endif
	
	return xBar+b*(inY-yBar)/capK +isUpper*(lct/capK)*Syx*sqrt((inY-yBar)^2/sx2+capK*(1+1/N))
End

//========================================================================
// Test the difference between two points which lie on two lines (which are assumed to intersect).
// Given the results of StatsLinearRegression for the two regressions, the input inX is used to compute
// the two Y values which are then tested using a t-statistic.  The result of the function is 1 if the two Y 
// values are the same for the two regressions or 0 if they are different
//  See Zar Ex. (18.3).
// Note -- Zar warns not to use this method unless the variances of the two Y's are the same.

Function WM_MCPointOnRegressionLines(inX,alpha,W_StatsLinearRegression,W_LinearRegressionMC)
	Variable inX,alpha
	Wave W_StatsLinearRegression,W_LinearRegressionMC
	
	Variable a0=W_StatsLinearRegression[0][%a]
	Variable a1=W_StatsLinearRegression[1][%a]
	Variable b0=W_StatsLinearRegression[0][%b]
	Variable b1=W_StatsLinearRegression[1][%b]
	Variable xBar0=W_StatsLinearRegression[0][%xBar]
	Variable xBar1=W_StatsLinearRegression[1][%xBar]
	Variable n0=W_StatsLinearRegression[0][%N]
	Variable n1=W_StatsLinearRegression[1][%N]
	Variable sumx20=W_StatsLinearRegression[0][%sumx2]
	Variable sumx21=W_StatsLinearRegression[1][%sumx2]

	Variable Syxp=W_LinearRegressionMC[%pooledRMS]
	
	// compute the two y values
	Variable Y0=a0+b0*inX
	Variable Y1=a1+b1*inX
	
	// standard error of the difference:
	Variable sdy=Syxp*sqrt((1/n0)+(1/n1)+(inX-xBar0)^2/sumx20+(inX-xBar1)^2/sumx21)
	Variable t_stat=abs(Y0-Y1)/sdy
	Variable nu=n0+n1-4
	Variable tc=StatsInvStudentCDF(1-alpha/2,nu)
	return tc>t_stat ? 1:0
End

//========================================================================
//  The following function creates a wave W_KMEstimator
// which contains the Kaplan-Meier estimator for the Survival function S(t).
// The inputs are waves of equal length.  rWave contains the number of survivors
// just prior to each event.  dWave correspond to the number of death in each event and the optional
// cWave contains the number censored as of the specified event.  If you do not have
// censored data pass $"" for cWave.  Alternatively, since the censored gets subtracted from the number
// of survivors you can simply incorporate the censored numbers into rWave.
// The function also computes the variance of the survival function as well as the estimated
// cumulative hazard function.
// If you want to display the results and you have an additional time wave, you can plot, for example,
// Display W_KMEstimator vs timeWave.

// See: http://en.wikipedia.org/wiki/Kaplan-Meier_estimator
Function WM_StatsKaplanMeier(rWave,dWave,cWave)
	Wave rWave,dWave,cWave
	
	Variable num=numpnts(rWave)
	Make/O/N=(num)W_KMEstimator=NAN,W_GreenwoodVar=NaN,W_cumulativeHazard=NaN
	if(num!=numpnts(dWave))
		doAlert 0,"Mismatch in input wave sizes."
		return 0
	endif
	
	NewDataFolder/O/S '_ _ _ WM_TEMP'			
	Duplicate rWave,r1Wave
	if(WaveExists(cWave))
		r1Wave=r1Wave-cWave
	endif
	
	// compute the Kaplan-Meier estimates
	Variable i,product=1
	for(i=0;i<num;i+=1)
		product*=(r1Wave[i]-dWave[i])/r1Wave[i]
		W_KMEstimator[i]=product
	endfor
	
	// compute the variance (Greenwood formula and the estimate of the cumulative hazard function)
	Variable theSum=0
	for(i=0;i<num;i+=1)
		theSum+=dWave[i]/(r1Wave[i]*(r1Wave[i]-dWave[i]))
		W_GreenwoodVar[i]=W_KMEstimator[i]^2*theSum
		W_cumulativeHazard[i]=-ln(W_KMEstimator[i])
	endfor
	
	KillDataFolder :		// cleanup
End

//========================================================================
// Calculating Cronbach alpha:
// The input wave is assumed to be two dimensional.  Columns correspond to "items", e.g., 
// individuals taking a test.  Rows correspond to scores on test questions.
// This procedure requires IP 6.02.
Function WM_CronbachAlpha(inWave)
	Wave inWave
	
	Variable n=DimSize(inWave,1)
	MatrixOP/O cc=varcols(sumcols(inWave^t)^t)
	MatrixOP/O bb=sum(varcols(inWave))
	Variable st=cc[0]
	Variable sv=bb[0]
	KillWaves/z cc,bb
	return (n/(n-1))*(1-sv/st)
End	
//========================================================================
// The following function computes Kendall's probability for inN in the range
// [2,19].  Depending on inN the function prints either the even or the odd
// S's and their associated probabilities.

Function WM_KendallSProbability(inN)
	Variable inN
	
	if(inN<2 || inN>20)
		doAlert 0, "inN is out of range"
		return NaN
	endif
	
	Variable maxS=inN*(inN-1)/2
	Variable isOdd=0
	if(maxS & 1)
		isOdd=1
		Print "Expect only odd values of S."
	else
		Print "Expect only even values of S."
	endif
	
	Make/O/N=(30,100) ww=0
	ww[0][0]=1
	ww[1][0]=1
	ww[1][1]=1
	
	Variable rrow,i
		
	for(rrow=2;rrow<inN;rrow+=1)
		MatrixOP/FREE theRow=row(ww,rrow-1)
		MatrixOP/FREE accum=theRow		 
		for(i=0;i<rrow;i+=1)
			Rotate 1,theRow
			accum+=theRow
		endfor
		ww[rrow][]=accum[q]
	endfor	// row

	// get the row corresponding to inN:
	MatrixOP/O freqRow=(row(ww,inN-1)^t)
	WaveStats/Q/M=1 freqRow
	Variable indexAtMax=V_maxLoc
	Variable minS=0
	if(isOdd)
		minS=1
	endif
	Variable theSum=sum(freqRow,0,indexAtMax)
	Variable total=factorial(inN)
	Variable sValue=minS
	for(i=0;i<=indexAtMax;i+=1)
		Printf "S=%g\t\tp=%g\r",sValue,theSum/total
		sValue+=2
		theSum-=freqRow[indexAtMax-i]
	endfor
End
