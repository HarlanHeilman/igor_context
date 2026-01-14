#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.01		// JW 050504 fixed a bug


// _________________________________________________________
// 	Use the following to print the 3 roots of a cubic equation of the form
// 	x^3+a*x^2+b*x+c=0
// _________________________________________________________

Function solveCubic(a,b,c)
	Variable a,b,c
	
	Variable qq,pp
	pp=b-(a^2)/3
	qq=c+2*(a/3)^3-a*b/3
	
	Variable Qa=(pp/3)^3+(qq/2)^2
	Variable y1,y2,y3
	
	a/=3
	if(Qa>=0)		// calc using Cardan's solution
		Variable sQ=sqrt(Qa)
		Variable AA=cubeRoot(sQ-qq/2) 
		Variable BB=cubeRoot(-sQ-qq/2) 
		y1=AA+BB-a
		y2=-(AA+BB)/2-a
		y3=sqrt(3)*(AA-BB)/2		// JW 050504 removed erroneous "-a" from end of assignment
		printf "y1=%g, y2,3=(%g +-i%g)\r",y1,y2,y3
		return 0
		
	else				// using trigonometric solution
		pp/=3
		Variable cosA=-qq/(2*sqrt(-pp^3))
		Variable alpha=acos(cosA)/3
		if(alpha==0)
			alpha=2*pi/3
		endif
		y1=2*sqrt(-pp)*cos(alpha)-a
		y2=-2*sqrt(-pp)*cos(alpha+pi/3)-a
		y3=-2*sqrt(-pp)*cos(alpha-pi/3)-a
		
		printf "x1=%g, x2=%g, x3=%g\r",y1,y2,y3
	endif
End


Function cubeRoot(inVal)
	Variable inVal
	
	if(inVal<0)
		return -(-inVal)^0.33333333333333333
	else
		return  (inVal)^0.33333333333333333
	endif
End

// _________________________________________________________
// 	Use the following to print the 4 roots of a Quartic equation of the form
// 	x^4+a*x^3+b*x^2+c*x+d=0
// _________________________________________________________
Function solveQuartic(a,b,c,d)
	Variable a,b,c,d
	
	// first the resolvent cubic:
	Variable AA=-b
	Variable BB=a*c-4*d
	Variable CC=-a*a*d+4*b*d-c*c
	Variable y1=getOneCubicRoot(aa,bb,cc)
	Variable RR=sqrt(a*a/4-b+y1)	
	Variable/C DD,EE,x1,x2,x3,x4
	if(RR==0)
		DD=sqrt(cmplx(3*a*a/4-2*b+2*sqrt(y1*y1-4*d),0))
		EE=sqrt(cmplx(3*a*a/4-2*b-2*sqrt(y1*y1-4*d),0))
	else
		DD=sqrt(cmplx(3*a*a/4-RR*RR-2*b+(4*a*b-8*c-a^3)/(4*RR),0))
		EE=sqrt(cmplx(3*a*a/4-RR*RR-2*b-(4*a*b-8*c-a^3)/(4*RR),0))
	endif
	
	a/=4
	RR/=2
	DD/=2
	EE/=2
	x1=-a+RR+DD
	x2=-a+RR-DD
	x3=-a-RR+EE
	x4=-a-RR-EE
	print x1,x2,x3,x4
End



Function getOneCubicRoot(a,b,c)
	Variable a,b,c
	
	Variable qq,pp
	pp=b-(a^2)/3
	qq=c+2*(a/3)^3-a*b/3
	
	Variable Qa=(pp/3)^3+(qq/2)^2
	Variable y1,y2,y3
	
	a/=3
	if(Qa>=0)		// calc using Cardan's solution
		Variable sQ=sqrt(Qa)
		Variable AA=cubeRoot(sQ-qq/2) 
		Variable BB=cubeRoot(-sQ-qq/2) 
		y1=AA+BB-a
		return y1
		
	else				// using trigonometric solution
		pp/=3
		Variable cosA=-qq/(2*sqrt(-pp^3))
		Variable alpha=acos(cosA)/3
		if(alpha==0)
			alpha=2*pi/3
		endif
		y1=2*sqrt(-pp)*cos(alpha)-a
		return y1
	endif
End
