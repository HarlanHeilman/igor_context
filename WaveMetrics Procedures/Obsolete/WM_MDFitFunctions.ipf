#pragma rtGlobals=1		// Use modern global access method.

// This procedure file is obsolete as all these functions are now built in.
// The Plane, QuadraticSurface and CubicSurface functions are superseded by
// the Poly2D fit function with the order parameter set to 1, 2, or 3.
// The Gauss2D function is replaced by the builtin Gauss2D function.

// Using the built-in equivalents will result in faster fits and compliance with new
// convenience features like fit coefficients with mnemonic names.
// JW 6/12/00

// z = A + Bx + Cy
Function Plane_ff3(w, xx,yy)
	Wave w
	Variable xx,yy
	
	return w[0] + w[1]*xx + w[2]*yy
end

// z = A + Bx + Cy + Dx^2 + Exy + Fy^2
Function QuadraticSurface_ff6(w, xx,yy)
	Wave w
	Variable xx,yy
	
	return w[0] + xx*(w[1] + xx*w[3]) + yy*(w[2] + xx*w[4] + yy*w[5])
end

// z = A + Bx + Cy + Dx^2 + Exy + Fy^2 + Gx^3 + Hx^2y + Ixy^2 + Jy^3
Function CubicSurface_ff10(w, xx,yy)
	Wave w
	Variable xx,yy
	
	return w[0] + xx*(w[1] + yy*(w[4] + yy*w[8]) + xx*(w[3] + xx*w[6] + yy*w[7])) + yy*(w[2] + yy*(w[5] + yy*w[9]))
end


// 2-D Gaussian peak
//	z = A + B*exp{-P*[x'^2/C^2 + y'^2/D^2 - 2Ex'y'/CD]}
//		y' = y-y0		            y0 = y coordinate of peak
//		x' = x-x0		            x0 = x coordinate of peak
//		P = 1/(2(1-E^2))
//
//		A	w[0]	baseline offset
//		x0	w[1]	x coordinate of peak
//		y0  w[2]	y coordinate of peak
//		B	w[3]	amplitude
//		C	w[4]	X width
//		D	w[5]	Y width
//		E	w[6]	"obliquity" must be between -1 and 1
	
Function Gauss2D_ff7(w,xx,yy)
	Wave w
	Variable xx,yy
	
	Variable X_ =  xx-w[1]
	Variable Y_ = yy-w[2]
	Variable arg=-1/(2*(1-w[6]*w[6]))
	return w[0] + w[3]*exp(arg*(X_*X_/(w[4]*w[4]) + Y_*Y_/(w[5]*w[5]) - 2*w[6]*X_*Y_/(w[4]*w[5])))
end
