
//******** several window functions...
//	each returns the average sum square value
//	this is needed for psd normalization 
//	Note: These functions do not need to be double precision unless you have
//		very unusual data that exceeds the dynamic range of single precision.
//		If that is the case (data > 10^35 or data < 10^-35) you will have to
//		generate your own versions that are double precision.
//********


Function ParzenOrWelch(w,isWelch)
	wave w
	variable isWelch
	
	variable N=numpnts(w),tmp

	variable sumsqr=0,jj=0
	do
		tmp= (jj-0.5*(N-1))/(0.5*(N+1))
		if(isWelch)
			tmp= 1 - tmp^2
		else
			tmp= 1-abs(tmp)
		endif
		sumsqr += tmp^2
		w[jj] *= tmp
		jj+=1
	while(jj<N)
	return sumsqr/N
end

Function Parzen(w)
	wave w

	return ParzenOrWelch(w,0)
End

Function Welch(w)
	wave w

	return ParzenOrWelch(w,1)
End

Function Kaiser(w,beta)	// see D.F. Elliott, Handbook of Digital SIgnal Processing, Academic Press, P 68
	wave w
	variable beta
	
	variable N=numpnts(w),tmp
	variable IBeta= BessI(0,beta), NM1= (N-1)/2

	variable sumsqr=0,jj=0
	do
		tmp= BessI(0,beta*sqrt(1 - ( (jj-NM1)/NM1 )^2))/IBeta
		sumsqr += tmp^2
		w[jj] *= tmp
		jj+=1
	while(jj<N)
	return sumsqr/N
end


Function Hamming(w)
	wave w
	
	variable N=numpnts(w),tmp
	variable omega= 2*Pi/N,mid= (N-1)/2

	variable sumsqr=0,i=0
	do
		tmp= 0.54 + 0.46*cos(omega*(i-mid))
		sumsqr += tmp^2
		w[i] *= tmp
		i+=1
	while(i<N)
	return sumsqr/N
end

Function BlackmanHarris3(w)
	wave w
	
	variable N=numpnts(w),tmp
	variable omega= 2*Pi/N,mid= (N-1)/2

	variable sumsqr=0,i=0
	do
		tmp= 0.42323 + 0.49755*cos(omega*(i-mid)) +  0.07922*cos(omega*2*(i-mid))
		sumsqr += tmp^2
		w[i] *= tmp
		i+=1
	while(i<N)
	return sumsqr/N
end

Function KaiserBessel(w)
	wave w
	
	variable N=numpnts(w),tmp
	variable omega= 2*Pi/N,mid= (N-1)/2

	variable sumsqr=0,i=0
	do
		tmp= 0.40243 + 0.49804*cos(omega*(i-mid)) 
		tmp += 0.09831*cos(omega*2*(i-mid)) +  0.00122*cos(omega*3*(i-mid))
		sumsqr += tmp^2
		w[i] *= tmp
		i+=1
	while(i<N)
	return sumsqr/N
end

