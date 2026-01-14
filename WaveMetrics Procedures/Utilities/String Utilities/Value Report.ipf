#pragma TextEncoding = "UTF-8"
// <Value Report>
//
//************
// Given a base value (bval) plus the estimated error (sigma), returns a string
//	containing the value rounded according to the error value.  Three parameters
//	control the style of the result: method,unitsStr & flags.
//
//	method is an integer that selects a basic style.  Currently supported methods
//	are:
//		method==0	:	b.bbb
//			prints just the base value rounded to the correct number of digits.
//		method==1	:	b.bbb±s.sss
//			prints both base and sigma values rounded.
//		method==2	:	b.bbb (s.sss)
//			same as method 1 except places sigma in parentheses
//		method==3	:	b.bbb<ss>
//			sigma is included as two (or one) digits that are understood to overlay
//			the last two (or one) digits of the base value.
//		method>=4	:	reserved for future expansion
//
//	Example:   23.45678 +/- 0.0987654 =>
//		method==0	:	 23.457
//		method==1	:	 23.457±0.099
//		method==2	:	 23.457 (0.099)
//		method==3	:	 23.457<99>
//
// If the unitsStr is non-null then SI prefixes are used if the value is not too large or
//	too small.  Units are appended to the output string in any case.
//
//  Set bit 0 of flags if you want superscript exponential notation AND if you will
//	 be using the output in an annotation.  Don't set it if you are printing to history
//	 or to a file.
// Set bit 1 of flags if you want 'E' style exponential notation.  Don't set both 0 & 1.
// Set bit 2 of flags if you want rounding and/or sigma reporting to only 1 digit rather than 2.
//
// REQUIRES: IGOR PRO V2.0
// MODIFICATIONS
//	5-22-90,LH: added test for zero sigma
//	11-11-93,LH: changed from 1.2 proc to 2.0 string function
//	
Function/S MakeValueReportString(bval,sigma,method,unitsStr,flags)
	variable/D bval,sigma
	variable method
	string unitsStr					// if not null, contains units (like V,s,W,m etc)
	variable flags
	string result= ""

	if( (method<0) %| (method>3) )
		return "PMakeValueReportString: unknown method"
	endif

	variable errordigits=2
	if( flags %& 4 )
		errordigits= 1
	endif
	
	if( sigma==0 )					// so something reasonable if zero sigma
		sprintf result,"%g%s",bval,unitsStr
		return result
	endif
	
	variable bpwr= floor(log(max(sigma,abs(bval)))), spwr= floor(log(sigma))
	
	if( cmpstr(unitsStr, "") != 0 )
		if( (bpwr >= 5) %| (bpwr <= -2) )					// need prefixes at all?
			variable  exponent= sign(bpwr)*ceil(abs(bpwr)/3)*3	// engineering units
			if( (exponent >= -18) %& (exponent<=12) )	// in range for SI prefixes?
				sigma *= 10^-exponent
				bval *= 10^-exponent
				bpwr= floor(log(max(sigma,abs(bval)))); spwr= floor(log(sigma))
				unitsStr[0]= "afpnµm kMGT"[exponent/3+6]	// insert prefix from list
			endif
		endif
	endif
	variable ndigs= bpwr-spwr + errordigits -1
	bval = round(bval*10^(ndigs-bpwr))*10^-ndigs
	if( method==3 )
		sigma = round(sigma*10^(errordigits -1 -spwr))
	else
		sigma = round(sigma*10^(ndigs-bpwr))*10^-ndigs
	endif
//printf "bval=%g, sigma=%g,bpwr=%d,spwr=%d,ndigs=%d\r",bval,sigma,bpwr,spwr,ndigs	
	if( (bpwr < 5) %& (bpwr >= -2) )						// try to avoid exponential mode
		bval *= 10^bpwr									// undo scaling on bval
		if( method!=3 )
			sigma *= 10^bpwr								// undo scaling on sigma
		endif
		if( bpwr >= ndigs )
			if( method==3 )
				sigma *= 10^(bpwr-ndigs)					// zero pad sigma
			endif
			ndigs= 0
		else
			ndigs -= bpwr
		endif
		if( method==0 )
			sprintf result,"%.*f%s",ndigs,bval,unitsStr
		endif
		if( method==1 )
			sprintf result,"%.*f±%.*f %s",ndigs,bval,ndigs,sigma,unitsStr
		endif
		if( method==2 )
			sprintf result,"%.*f (%.*f) %s",ndigs,bval,ndigs,sigma,unitsStr
		endif
		if( method==3 )
			sprintf result,"%.*f<%d>%s",ndigs,bval,sigma,unitsStr
		endif
	else									// exponential mode
		String spfstr= "x10^%d"		// default format for exponent
		if(flags %& 1)
			spfstr= "x10\S%d\M"		// superscript format for exponent;	BUG: should need double "\"
		endif
		if(flags %& 2)
			spfstr= "E%d"				// E format for exponent
		endif

		if( method==0 )
			sprintf  result,"%.*f"+spfstr+"%s",ndigs,bval,bpwr,unitsStr
		endif
		if( method==1 )
			sprintf  result,"%.*f"+spfstr+"±%.*f"+spfstr+" %s",ndigs,bval,bpwr,ndigs,sigma,bpwr,unitsStr
		endif
		if( method==2 )
			sprintf  result,"%.*f"+spfstr+" (%.*f"+spfstr+") %s",ndigs,bval,bpwr,ndigs,sigma,bpwr,unitsStr
		endif
		if( method==3 )
			sprintf  result,"%.*f<%d>"+spfstr+"%s",ndigs,bval,sigma,bpwr,unitsStr
		endif
	endif
//printf "bval=%s\r",result
	return result
end
