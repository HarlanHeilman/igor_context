// Complex Math Functions 1.01
// Some functions have been removed to avoid conflict with new built-in names July, 1996
// All these functions have built-in equivalents;  in most cases you simply use the same function
//   name but with a complex arguement.  Consequently, built-in complex cos, for instance, is
//   simply called "cos" and the name does not conflict with the function here called "ccos".
//
// This file is provided for compatibility with old procedures.  It is recommended that you use
//   the built-in functions in any new procedures.

// Function/D cabs(z) now built in.

Function/C/D csqrt( z)
	Variable/C/D z
	
	Variable/C/D r
	Variable/D mag, t,tt

	mag = cabs(z)
	if( mag  == 0 )
		r = 0
	else
		if(real(z) > 0)
			t = sqrt(0.5 * (mag + real(z)) )
			r= cmplx(t,0.5 * imag(z) / t)
		else
			t = sqrt(0.5 * (mag - real(z)) )
			if(imag(z) < 0)
				t = -t
			endif
			r= cmplx(0.5 * imag(z) / t,t)
		endif
	endif
	return r
End

Function/C/D cexp(z)
	Variable/C/D z
	
	Variable/D expx = exp(real(z));
	Return cmplx( expx * cos(imag(z)), expx * sin(imag(z)))
end

Function/C/D cln(z)
	Variable/C/D z
	
	Return cmplx( ln(cabs(z)), atan2(imag(z),real(z)))
end

Function/C/D csin(z)
	Variable/C/D z
	
	Return cmplx(sin(real(z)) * cosh(imag(z)), cos(real(z)) * sinh(imag(z)))
end

Function/C/D ccos(z)
	Variable/C/D z
	
	Return cmplx(cos(real(z)) * cosh(imag(z)), -sin(real(z)) * sinh(imag(z)))
end



//Function/D/C cpowi(a, n) now built in 
