#pragma rtGlobals=1		// Use modern global access method.

// 29DEC00 (AG)
// This procedure file contains the function frac() which finds two integers such that their ratio
// represents the input value v to within the specified error.
// The wrapper function rationalApprox() can be used if you just want to print out the results
// in the history window.
// for comments, send Email to: ag@wavemetrics.com

Function rationalApprox(v, error)
	Variable v,error

	Variable nn,dd
	error=frac(v,nn,dd, error)
	print "(",nn,"/",dd,") error=",error
End

Function frac(v,nn,dd, error)
	Variable v,&nn,&dd,&error

	Variable D, N, t
	Variable epsilon, r, m
	Variable first=1

	if(v < 3.0e-10 || v > 4.0e+10 || error < 0.0)
		return(-1.0)
	endif
		
	dd=1
	D=1
	nn=round(v)
	N=nn+1
	
	do
		if(!first)
			if(r <=1.0)
				r=1.0/r
			endif
				
			N +=nn*round(r)
			D +=dd*round(r)
			nn +=N
			dd +=D
		endif
		first=0	

		if(v*dd !=nn)
			r=(N - v*D)/(v*dd - nn)
			if(r <=1.0)
				t=N
				N=nn
				nn=t
				t=D
				D=dd
				dd=t
			endif
		endif
		
		epsilon=abs(1.0 - nn/(v*dd))
		if(epsilon > error)
			m=1.0
			do 
				m *=10.0
			while(m*epsilon < 1.0)
			epsilon=1.0/m *(round(0.5+m*epsilon))
		endif

		if(epsilon <=error)
			return epsilon
		endif
		if(r !=0.0)
			continue
		endif
		break
	while(1)

	return epsilon
End
