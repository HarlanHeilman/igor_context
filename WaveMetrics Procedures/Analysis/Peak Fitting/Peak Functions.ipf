#pragma rtGlobals= 3
//
//	Release 031110 - contains new asymmetric functions ExpGauss and ExpConvExp.
//
// The functions in this file are user defined fitting functions mainly for use
// with the multipeak fitting package. You can also use them with your own
// custom fitting procedures.
//
// Note that much faster XFUNC versions of most of these user-defined functions
// are provided by the MulitPeakFit.xop module. 
//
// The names of the functions provided here are the same as the corresponding
// XFUNCs except these have a prefix of "f".
//
// Each basic fit type comes in several variants distinguished by a suffex appended
// to the base name.
//  A suffex of BL implies that a cubic polynomial baseline is
// supported using the first 6 entries in the coefficient wave. 
// The baseline is defined as:
// w[2]+ w[3]*xprime + w[4]*xprime^2 + w[5]*xprime^3
// where xprime= (x-w[0])/w[1]. 
// w[0] and w[1] are not free parameters and must not be used in the fit.
// Therefore a hold string will be necessary. These values are needed to ensure
// numeric stability. w[0] should be roughly the center of the x range and w[1]
// should be roughly the range of the x values. The goal is to have xprime vary
// somewhere in the region of -1 to 1 within an order of magnitude or two. 
//
// A suffex of the form 1width or 1shape implies that one value is shared among
// all the peaks. The value is stored in the coefficient wave after the baseline (or
// dc offset) values and each peak group will then have one fewer coefficient.


//****************************************************************
//************************* Gaussian ********************************
//****************************************************************

// A fitting function for multiple Gaussian peaks. The number of peaks is set by
// the length of the coefficient wave w. If w contains 4 points then one peak will
// be generated as follows: 
// Returns w[0]+w[1]*exp(-(((x-w[2])/w[3])^2)
// Parameter w[0] sets the DC offset, w[1] sets the amplitude, w[3] sets the
// location of the peak and, w[3]  affects the width. To fit two peaks, just
// append three new values to the coefficient wave that correspond to w[1-3]. 

Function fGaussFit(w,x)
	Wave w; Variable x
	
	Variable r= w[0]
	variable npts= numpnts(w),i=1
	do
		if( i>=npts )
			break
		endif
		r += w[i]*exp(-((x-w[i+1])/w[i+2])^2)
		i+=3
	while(1)
	return r
End

Function fGaussFitBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=6
	do
		if( i>=npts )
			break
		endif
		r += w[i]*exp(-((x-w[i+1])/w[i+2])^2)
		i+=3
	while(1)
	return r
End

Function fGaussFit1Width(w,x)
	Wave w; Variable x
	
	Variable r= w[0],width= w[1]
	variable npts= numpnts(w),i=2
	do
		if( i>=npts )
			break
		endif
		r += w[i]*exp(-((x-w[i+1])/width)^2)
		i+=2
	while(1)
	return r
End

Function fGaussFit1WidthBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],width= w[6]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=7
	do
		if( i>=npts )
			break
		endif
		r += w[i]*exp(-((x-w[i+1])/width)^2)
		i+=2
	while(1)
	return r
End

//****************************************************************
//************************ Lorentzian ********************************
//****************************************************************

// A fitting function for multiple Lorentzian peaks. The number of peaks is set by
// the length of the coefficient wave w. If w contains 4 points then one peak will
// be generated as follows: 
// Returns w[0]+w[1]/( (x-w[2])^2 + w[3] )
// Parameter w[0] sets the DC offset, w[1] sets the amplitude, w[2] sets the
// location of the peak and, w[3]  affects the width (and affects the amplidude).
Function fLorentzianFit(w,x)
	Wave w; Variable x
	
	Variable r= w[0]
	variable npts= numpnts(w),i=1
	do
		if( i>=npts )
			break
		endif
		r += w[i]/((x-w[i+1])^2+w[i+2])
		i+=3
	while(1)
	return r
End

Function fLorentzianFitBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=6
	do
		if( i>=npts )
			break
		endif
		r += w[i]/((x-w[i+1])^2+w[i+2])
		i+=3
	while(1)
	return r
End


Function fLorentzianFit1Width(w,x)
	Wave w; Variable x
	
	Variable r= w[0],width= w[1]
	variable npts= numpnts(w),i=2
	do
		if( i>=npts )
			break
		endif
		r += w[i]/((x-w[i+1])^2+width)
		i+=2
	while(1)
	return r
End

Function fLorentzianFit1WidthBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],width= w[6]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=7
	do
		if( i>=npts )
			break
		endif
		r += w[i]/((x-w[i+1])^2+width)
		i+=2
	while(1)
	return r
End

//****************************************************************
//************************** Voigt **********************************
//****************************************************************

// Returns the Voigt profile (a convolution between a Gaussian and a Lorentzian).
// Y is the shape parameter. When Y is zero, the Voigt function is 100% Gaussian
// and transitions to 100% Lorentzian as Y approaches infinity. When Y is one the
// mix is 50/50. 
// 
// The algorithm used is described in TN026. Its relative accuracy is better than
// 0.0001 and most of the time is much better. 

Function fVoigt(X,Y)
	variable X,Y
	
	Y= abs(Y)
	X= abs(X)

	variable/C W,U,T= cmplx(Y,-X)
	variable S= X+Y

	if( S >= 15 )								//        Region I
		W= T*0.5641896/(0.5+T*T)
	else
		if( S >= 5.5 ) 							//        Region II
			U= T*T
			W= T*(1.410474+U*0.5641896)/(0.75+U*(3+U))
		else
			if( Y >= (0.195*X-0.176) ) 	//        Region III
				W= (16.4955+T*(20.20933+T*(11.96482+T*(3.778987+T*0.5642236))))
				W /= (16.4955+T*(38.82363+T*(39.27121+T*(21.69274+T*(6.699398+T)))))
			else									//        Region IV
				U= T*T
				W= T*(36183.31-U*(3321.9905-U*(1540.787-U*(219.0313-U*(35.76683-U*(1.320522-U*0.56419))))))
				W /= (32066.6-U*(24322.84-U*(9022.228-U*(2186.181-U*(364.2191-U*(61.57037-U*(1.841439-U)))))))
				W= cmplx(exp(real(U))*cos(imag(U)),0)-W
			endif
		endif
	endif
	return real(W)
end

// A fitting function utilizing the Voigt profile (a convolution between a
// Gaussian and a Lorentzian). Can handle a number of peaks depending on the
// number of points in the coefficient wave w. If w contains 5 points then one
// peak will be generated as follows: 
// w[0]+w[1]*Voigt(w[2]*(x-w[3]),w[4])
// Parameter w[0] sets the DC offset, w[1] sets the amplitude, w[2]  affects the
// width, w[3] sets the location of the peak and w[4] adjusts the shape (but also
// affects the amplitude). 
// After the fit, you can use the returned coefficients to calculate the area (a)
// along with the half width at half max for the Gaussian (wg), Lorentzian (wl)
// and the Voigt (wv). Assuming the coefficient wave is named coef: 
// 	a= coef[1]*sqrt(pi)/coef[2]
// 	wg= sqrt(ln(2))/coef[2]
// 	wl= coef[4]/coef[2] 
// 	wv= wl/2 + sqrt( wl^2/4 + wg^2)
// See Tech Note TN026 for more information about the Voigt.

Function fVoigtFit(w,x)
	Wave w; Variable x
	
	Variable r= w[0]
	variable npts= numpnts(w),i=1
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(w[i+1]*(x-w[i+2]),w[i+3])
		i+=4
	while(1)
	return r
End

Function fVoigtFitBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=6
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(w[i+1]*(x-w[i+2]),w[i+3])
		i+=4
	while(1)
	return r
End


Function fVoigtFit1Shape(w,x)
	Wave w; Variable x
	
	Variable r= w[0],shape= w[1]
	variable npts= numpnts(w),i=2
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(w[i+1]*(x-w[i+2]),shape)
		i+=3
	while(1)
	return r
End

Function fVoigtFit1ShapeBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],shape= w[6]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=7
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(w[i+1]*(x-w[i+2]),shape)
		i+=3
	while(1)
	return r
End


Function fVoigtFit1Shape1Width(w,x)
	Wave w; Variable x
	
	Variable r= w[0],shape= w[1],width= w[2]
	variable npts= numpnts(w),i=3
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(width*(x-w[i+1]),shape)
		i+=2
	while(1)
	return r
End

Function fVoigtFit1Shape1WidthBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],shape= w[6],width= w[7]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=8
	do
		if( i>=npts )
			break
		endif
		r += w[i]*fVoigt(width*(x-w[i+1]),shape)
		i+=2
	while(1)
	return r
End



//****************************************************************
//****************** Exponentially modified Gaussian ***********************
//****************************************************************


// cumulative gaussian prob dist with unit sigma
Static Function ncdf(t)
	Variable t
	
	Variable r= GammP(0.5,0.5*t^2)
	if( t<0 )
		return (1-r)/2
	else
		return (1+r)/2
	endif
end

// Convolution of exponential and Gaussian probability distribution functions
// r is the exponential decay constant and s is the Gaussian sigma
Function fExpGauss(t,r,s)
	Variable t,r,s
	
	return r*exp( -r*t + s^2*r^2/2 )*ncdf( t/s - s*r )
end

// A fitting function utilizing the ExpGauss profile (a convolution between a Gaussian
// and an exponential decay). Can handle a number of peaks depending on the number of
// points in the coefficient wave w. If w contains 5 points then one peak will be generated as follows:
// w[0]+w[1]/w[4]*ExpGauss(x-w[2],w[4],w[3])
// Parameter w[0] sets the DC offset, w[1] affects the amplitude,  w[2] sets the location of
// the peak, w[3] is the Gaussian width and w[4] is the exponential decay constant.
//  The reason we multiply the fExpGauss by (w[1]/w[3]) rather than
//  just w[1] is that the provided functions are based on probability distributions and
//  are normalized to unit area and not to unit height. 
Function fExpGaussFit(w,x)
	Wave w; Variable x
	
	Variable r= w[0]
	variable npts= numpnts(w),i=1
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/w[i+3])*fExpGauss(x-w[i+1],w[i+3],w[i+2])
		i+=4
	while(1)
	return r
End

// Version with baseline. See description at the top of this file.
Function fExpGaussFitBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=6
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/w[i+3])*fExpGauss(x-w[i+1],w[i+3],w[i+2])
		i+=4
	while(1)
	return r
End

// Just like ExpGaussFit except all peaks share a common exponential decay parameter in w[1].
// Each peak then uses only 3 parameters rather than 4 and the first group starts with w[2].
Function fExpGaussFit1Shape(w,x)
	Wave w; Variable x
	
	Variable r= w[0],shape= w[1]
	variable npts= numpnts(w),i=2
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/shape)*fExpGauss(x-w[i+1],shape,w[i+2])
		i+=3
	while(1)
	return r
End

Function fExpGaussFit1ShapeBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],shape= w[6]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=7
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/shape)*fExpGauss(x-w[i+1],shape,w[i+2])
		i+=3
	while(1)
	return r
End

//****************************************************************
//****************** Exponentially modified Exponential *********************
//****************************************************************


// Convolution of two exponentials. The k1 and k2 decay constants are equivalent
// (i.e., may be swapped) but one may think of k1 controlling the rise while
// k2 controls the fall. This requires k1 to be greater than k2.  A larger value gives a faster decay.
Function fExpConvExp(t,k1,k2)
	Variable t,k1,k2
	
	if( t<0 )
		return 0
	endif
	if( k1==k2 )
		return t*k2^2*exp(-k2*t)
	endif
	return  (exp(-k1*t) -  exp(-k2*t))*k1*k2/(k2-k1)
end

// A fitting function utilizing the ExpConvExp profile (a convolution between two exponential decays). 
// Can handle a number of peaks depending on the number of points in the coefficient wave w. If w
//  contains 5 points then one peak will be generated as follows:
// w[0]+w[1]/w[4]*ExpConvExp(x-w[2],w[4],w[3])
// Parameter w[0] sets the DC offset, w[1] affects the amplitude,  w[2] sets the location of the peak,
// w[3] is exponential decan constant k1 and w[4] is exponential decay constant k2.
Function fExpConvExpFit(w,x)
	Wave w; Variable x
	
	Variable r= w[0]
	variable npts= numpnts(w),i=1
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/w[i+3])*fExpConvExp(x-w[i+1],w[i+2],w[i+3])
		i+=4
	while(1)
	return r
End

// Version with baseline. See description at the top of this file.
Function fExpConvExpFitBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=6
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/w[i+3])*fExpConvExp(x-w[i+1],w[i+2],w[i+3])
		i+=4
	while(1)
	return r
End

// Just like ExpConvExpFit except all peaks share a common exponential decay parameter
// k2 in w[1]. Each peak then uses only 3 parameters rather than 4 and the first group starts with w[2].
Function fExpConvExpFit1Shape(w,x)
	Wave w; Variable x
	
	Variable r= w[0],shape= w[1]
	variable npts= numpnts(w),i=2
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/shape)*fExpConvExp(x-w[i+1],w[i+2],shape)
		i+=3
	while(1)
	return r
End

// Just like ExpConvExpFit1Shape but with provision for a baseline defined using the first 
// 6 coefficients as explained above. The common decay parameter is in w[6]. Each peak then
// uses 3 parameters and the first group starts with w[7].
Function fExpConvExpFit1ShapeBL(w,x)
	Wave w; Variable x
	
	Variable xprime= (x-w[0])/w[1],shape= w[6]
	Variable r= w[2]+w[3]*xprime+w[4]*xprime^2+w[5]*xprime^3
	variable npts= numpnts(w),i=7
	do
		if( i>=npts )
			break
		endif
		r += (w[i]/shape)*fExpConvExp(x-w[i+1],w[i+2],shape)
		i+=3
	while(1)
	return r
End
