// PEAK FUNCTIONS

// LH040618: this is obsolete (it is built-in)
// Gaussian, amplitude= k1, center= k2, width (fwhm) = 2*sqrt(ln(2))*k3, area =  k1*k3*sqrt(Pi)
//Function/D gauss(k1,k2,k3)
//	Variable/D k1,k2,k3
//	return k1*exp(-((x-k2)/k3)^2)
//End

// Lorentzian, amplitude= k1/k3, center= k2, width (fwhm) = 2*sqrt(k3), area =   Pi*k1/sqrt(k3)
Function lor(x,k1,k2,k3)
	Variable x,k1,k2,k3
	return k1/((x-k2)^2+k3)
End

// This function is also available in the MultipeakFit XOP, using a better approximation. It also runs faster
// because it is implemented in C code. To use it, select Help->Show Igor Pro Folder. In the resulting Explorer
// or Finder window, find the More Extensions:Curve Fitting folder. Then make an alias or shortcut to the 
// MultiPeakFit.xop file. Put the shortcut or alias file into the Igor Extensions folder and re-start Igor. Since
// the XOP defines a function with the same name as this one, you can't use both.

// Note that the constants are single-precision; your waves must also be single-precision. 
// Voigt profile, center = 0, amplitude = voigt(0,y),
// 	width (fwhm) = (y+sqrt(y*y+4*ln(2))) [+/- 1%], area = sqrt(Pi)
Function Voigt(X,Y)
	variable X,Y

	variable/C W,U,T= cmplx(Y,-X)
	variable S =abs(X)+Y

	if( S >= 15 )								//        Region I
		W= T*0.5641896/(0.5+T*T)
	else
		if( S >= 5.5 ) 							//        Region II
			U= T*T
			W= T*(1.410474+U*0.5641896)/(0.75+U*(3+U))
		else
			if( Y >= (0.195*ABS(X)-0.176) ) 	//        Region III
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


// Doniac-Sunjic lineshape for photoelectron spectroscopy.
//  This version builds XPS core lineshapes in K.E. mode.
// (See Physical Review Letters 61, 357 (1988) for source and authors of this version.)
// "Dr. K.-M. Schindler" <schindler@fhi-berlin.mpg.d400.de>
Function DoniacSunjic(Ee, Alpha, Gamma, EF)
        Variable Ee, Alpha, Gamma, EF

        Variable Eps, OneAlp, Tmp
        Eps = Ee - EF
        OneAlp = 1. - Alpha
        Tmp = (Eps * Eps + Gamma * Gamma) ^ (-.5 * OneAlp)
        Tmp = Tmp *  cos(Pi/2 * Alpha + OneAlp * atan2(Eps,Gamma))
        return Tmp / sin(Pi * OneAlp)
End

