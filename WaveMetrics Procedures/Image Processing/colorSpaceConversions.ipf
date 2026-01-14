#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.1		// shipped with Igor 6.1

// 23MAR04 AG
// The following are a bunch of color-space conversion routines.  The parameters and the conversion formulae are taken
// from:
// colorspace-faq -- FREQUENTLY ASKED QUESTIONS ABOUT GAMMA AND COLOR by Charles A. Poynton.

// 21JUL04 AG
// Added HSV2RGB

// 17SEP04	changed roundup to work with the constant below.  Set the constant to zero if you are not going to
// truncate the results into integers.

// 17FEB09 JP, Version 6.1
// Added RGB16toCMYK

constant kRoundUp=0.5

//_________________________________________________________________________
// The following is designed to be used either from the command line or from a function.  When used from 
// the command line just pass in the input parameters and the function prints the resulting transformation
// in the history.  When used from a function, use pass-by-reference for the optional three output parameters.

Function RGB2Lab(R, G, BB,[L, a, b])
	Variable R, G, BB
	Variable &L, &a, &b
   
	Variable X, Y, Z, fX, fY, fZ
	Variable localL,localA,localB

	X = 0.412453*R + 0.357580*G + 0.180423*BB
	Y = 0.212671*R + 0.715160*G + 0.072169*BB
	Z = 0.019334*R + 0.119193*G + 0.950227*BB

	X /= (255 * 0.950456)
	Y /=  255
	Z /= (255 * 1.088754)

	if (Y > 0.008856)
		fY = Y^(1.0/3.0)
		localL = (116.0*fY - 16.0 + kRoundUp)
	else
		fY = 7.787*Y + 16.0/116.0
		localL = (903.3*Y + kRoundUp)
	endif

	if (X > 0.008856)
		fX = X^(1.0/3.0)
	else
		fX = 7.787*X + 16.0/116.0
	endif
	
	if (Z > 0.008856)
		fZ = Z^(1.0/3.0)
	else
		fZ = 7.787*Z + 16.0/116.0
	endif
	
	localA = (500.0*(fX - fY) + kRoundUp)
	localB = (200.0*(fY - fZ) + kRoundUp)
	if(ParamIsDefault(L) || ParamIsDefault(a) || ParamIsDefault(b))
		printf "RGB=(%g,%g,%g) ==> Lab(%g,%g,%g)\r",R,G,BB,localL,localA,localB
	else
		L=localL
		a=localA
		b=localB
	endif
End

//_________________________________________________________________________
// The following is designed to be used either from the command line or from a function.  When used from 
// the command line just pass in the input parameters and the function prints the resulting transformation
// in the history.  When used from a function, use pass-by-reference for the optional three output parameters.

Function Lab2RGB(L, a,b,[R, G, rgbB])
	Variable L, a,b
	Variable &R,&G,&rgbB

	Variable  X, Y, Z, fX, fY, fZ
	Variable RR, GG, BB
	Variable localR,localG,localB

	fY = ((L + 16.0) / 116.0)^ 3.0
	if (fY < 0.008856)
		fY = L / 903.3
	endif
    
	Y = fY

	if (fY > 0.008856)
		fY = fY^(1.0/3.0)
	else
		fY = 7.787 * fY + 16.0/116.0
	endif
	
	fX = a / 500.0 + fY
	if (fX > 0.206893)
		X = fX^3.0
	else
		X = (fX - 16.0/116.0) / 7.787
	endif
	
	fZ = fY - b /200.0
	if (fZ > 0.206893)
		Z = fZ^3.0
	else
		Z = (fZ - 16.0/116.0) / 7.787
	endif
	
	X *= (0.950456 * 255)
	Y *=  255
	Z *= (1.088754 * 255)

	RR =(3.240479*X - 1.537150*Y - 0.498535*Z + kRoundUp)
	GG = (-0.969256*X + 1.875992*Y + 0.041556*Z + kRoundUp)
	BB =  (0.055648*X - 0.204043*Y + 1.057311*Z + kRoundUp)

	localR = (RR < 0 ? 0 : RR > 255 ? 255 : RR)
	localG = (GG < 0 ? 0 : GG > 255 ? 255 : GG)
	localB = (BB < 0 ? 0 : BB > 255 ? 255 : BB)

	if(ParamIsDefault(R) || ParamIsDefault(G) || ParamIsDefault(rgbB))
		printf "Lab=(%g,%g,%g) ==> RGB(%g,%g,%g)\r",L,a,b,localR,localG,localB
	else
		R=localR
		G=localG
		rgbB=localB
	endif
End
//_________________________________________________________________________
// To transform from CIE XYZ into Rec. 709 RGB (with its D65 white point), put
// an XYZ column vector to the right of this matrix, and multiply:
// Details can be found in SMPTE RP 177-1993 [11].

Function RGB2XYZ(r,g,b,[xx,yy,zz])
	Variable r,g,b
	Variable &xx,&yy,&zz
	
	Variable localX,localY,localZ
	localX=0.412453*r+0.35758*g+0.180423*b
	localY=0.212671*r+0.71516 *g+0.072169*b
	localZ= 0.019334*r+0.119193*g+0.950227*b

	if(ParamIsDefault(xx) || ParamIsDefault(yy) || ParamIsDefault(zz))
		printf "RGB=(%g,%g,%g) ==> XYZ(%g,%g,%g)\r",r,g,b,localX,localY,localZ
	else
		xx=localX
		yy=localY
		zz=localZ
	endif	
End
//_________________________________________________________________________
// To transform from CIE XYZ into Rec. 709 RGB (with its D65 white point), put
// an XYZ column vector to the right of this matrix, and multiply:
// Details can be found in SMPTE RP 177-1993 [11].

Function XYZ2RGB(xx,yy,zz,[r,g,b])
	Variable xx,yy,zz
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=3.240479*xx -1.53715*yy -0.498535*zz
	localG=-0.969256*xx+ 1.875991*yy+0.041556*zz
	localB=0.055648*xx-0.204043*yy+1.057311*zz
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "XYZ(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",xx,yy,zz,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End

//_________________________________________________________________________
// http://www.neuro.sfc.keio.ac.jp/~aly/polygon/info/color-space-faq.html

Function RGB2XYZccir(r,g,b,[xx,yy,zz])
	Variable r,g,b
	Variable &xx,&yy,&zz
	
	Variable localX,localY,localZ
	localX=0.607*r+0.174*g+0.200*b
	localY=0.299*r+0.587*g+0.114*b
	localZ=0.000*r+0.066*g+1.116*b

	if(ParamIsDefault(xx) || ParamIsDefault(yy) || ParamIsDefault(zz))
		printf "RGB=(%g,%g,%g) ==> XYZccir(%g,%g,%g)\r",r,g,b,localX,localY,localZ
	else
		xx=localX
		yy=localY
		zz=localZ
	endif	
End
//_________________________________________________________________________

Function XYZccir2RGB(xx,yy,zz,[r,g,b])
	Variable xx,yy,zz
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=1.910*xx-0.532*yy-0.288*zz
	localG=-0.985*xx+1.999*yy+-0.028*zz
	localB=0.058*xx-0.118*yy+0.898*zz
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "XYZccir(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",xx,yy,zz,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End
//_________________________________________________________________________
//  RGB -> CIE XYZitu (D65)

Function RGB2XYZitu(r,g,b,[xx,yy,zz])
	Variable r,g,b
	Variable &xx,&yy,&zz
	
	Variable localX,localY,localZ
	localX=0.430574*r+0.341550*g+0.178325*b
	localY=0.222015*r+0.706655*g+0.071330*b
	localZ=0.020183*r+0.129553*g+0.939180*b

	if(ParamIsDefault(xx) || ParamIsDefault(yy) || ParamIsDefault(zz))
		printf "RGB=(%g,%g,%g) ==> XYZitu(%g,%g,%g)\r",r,g,b,localX,localY,localZ
	else
		xx=localX
		yy=localY
		zz=localZ
	endif	
End
//_________________________________________________________________________

Function XYZitu2RGB(xx,yy,zz,[r,g,b])
	Variable xx,yy,zz
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=3.06322*xx-1.39333*yy-0.475801*zz
	localG=-0.969245*xx+1.87597*yy+0.0415552*zz
	localB=0.0678716*xx-0.228833*yy+1.06925*zz
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "XYZitu(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",xx,yy,zz,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End

//_________________________________________________________________________
//  RGB -> YUV
// http://www.neuro.sfc.keio.ac.jp/~aly/polygon/info/color-space-faq.html

Function RGB2YUV(r,g,b,[yy,uu,vv])
	Variable r,g,b
	Variable &yy,&uu,&vv
	
	Variable localY,localU,localV
	localY=0.299*r+0.587*g+0.114*b
	localU=-0.147*r-0.289*g+0.436*b
	localV=0.615*r-0.515*g-0.100*b

	if(ParamIsDefault(yy) || ParamIsDefault(uu) || ParamIsDefault(vv))
		printf "RGB=(%g,%g,%g) ==> YUV(%g,%g,%g)\r",r,g,b,localY,localU,localV
	else
		yy=localY
		uu=localU
		vv=localV
	endif	
End
//_________________________________________________________________________

Function YUV2RGB(yy,uu,vv,[r,g,b])
	Variable yy,uu,vv
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=yy+1.140*vv
	localG=yy-0.396*uu-0.581*vv
	localB=yy+2.029*uu+0.000*vv
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "YUV(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",yy,uu,vv,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End

//_________________________________________________________________________

Function RGB2YIQ(r,g,b,[yy,ii,qq])
	Variable r,g,b
	Variable &yy,&ii,&qq
	
	Variable localY,locali,localq
	localY=0.299*r+0.587*g+0.114*b
	locali=0.596*r-0.274*g+0.322*b
	localq=0.212*r-0.523*g-0.311*b

	if(ParamIsDefault(yy) || ParamIsDefault(ii) || ParamIsDefault(qq))
		printf "RGB=(%g,%g,%g) ==> YIQ(%g,%g,%g)\r",r,g,b,localY,locali,localq
	else
		yy=localY
		ii=locali
		qq=localq
	endif	
End
//_________________________________________________________________________

Function YIQ2RGB(yy,ii,qq,[r,g,b])
	Variable yy,ii,qq
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=yy+0.956*ii+0.621*qq
	localG=yy-0.272*ii-0.647*qq
	localB=yy-1.105*ii+1.702*qq
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "YIQ(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",yy,ii,qq,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End

//_________________________________________________________________________

Function YUV2YIQ(yin,uin,vin,[yy,ii,qq])
	Variable yin,uin,vin
	Variable &yy,&ii,&qq
	
	Variable localY,locali,localq
	localY=yin
	locali=-0.2676*uin+0.7361*vin  
	localq=0.3869*uin+0.4596*vin

	if(ParamIsDefault(yy) || ParamIsDefault(ii) || ParamIsDefault(qq))
		printf "YUV=(%g,%g,%g) ==> YIQ(%g,%g,%g)\r",yin,uin,vin,localY,locali,localq
	else
		yy=localY
		ii=locali
		qq=localq
	endif	
End
//_________________________________________________________________________

Function YIQ2YUV(yy,ii,qq,[yout,uout,vout])
	Variable yy,ii,qq
	Variable &yout,&uout,&vout
	
	Variable localY,localU,localV
	
	localY=yy 
	localU=-1.1270*ii+1.8050*qq
	localV=0.9489*ii+0.6561*qq
	
	if(ParamIsDefault(yout) || ParamIsDefault(uout) || ParamIsDefault(vout))
		printf "YIQ(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",yy,ii,qq,localY,localU,localV
	else
		yout=localY
		uout=localU
		vout=localV
	endif	
End

//_________________________________________________________________________
Function RGB2YCbCr(r,g,b,[yy,cb,cr])
	Variable r,g,b
	Variable &yy,&cb,&cr
	
	Variable localY,localCb,localCr
	localY=0.2989*r+0.5866*g+0.1145*b
	localCb=-0.1687*r-0.3312*g+0.5000*b
	localCr=0.5000*r-0.4183*g-0.0816*b

	if(ParamIsDefault(yy) || ParamIsDefault(cb) || ParamIsDefault(cr))
		printf "RGB=(%g,%g,%g) ==> YCbCr(%g,%g,%g)\r",r,g,b,localY,localCb,localCr
	else
		yy=localY
		cb=localCb
		cr=localCr
	endif	
End
//_________________________________________________________________________

Function YCbCr2RGB(yy,cb,cr,[r,g,b])
	Variable yy,cb,cr
	Variable &r,&g,&b
	
	Variable localR,localG,localB
	
	localR=yy+1.4022*Cr
	localG=yy-0.3456*Cb-0.7145*Cr
	localB=yy+1.7710*Cb
	
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "YCbCr(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",yy,cb,cr,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End

//_________________________________________________________________________
//HSL values = [0,1] RGB [0,255]
Function HSL2RGB(H,S,L,[r,g,b])
	Variable H,S,L
	Variable &r,&g,&b
	
	Variable localR,localG,localB,V1,V2
	
	if(S==0)
		localR=L*255
		localG=L*255
		localB=L*255
	else
		if (L< 0.5)
			V1 = L*(1+S)
		else 
			V2 = (L+ S)-(S* L)
		endif
	endif
	V1= 2* L-V2
	localR= 255 * Hue_2_RGB( V1, V2, H+0.33333)
	localG= 255 * Hue_2_RGB( V1, V2, H)
	localB= 255 * Hue_2_RGB( V1, V2, H-0.33333)
	if(ParamIsDefault(r) || ParamIsDefault(g) || ParamIsDefault(b))
		printf "HSL(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",H,S,L,localR,localG,localB
	else
		r=localR
		g=localG
		b=localB
	endif	
End


Function Hue_2_RGB( v1, v2, H)
	Variable v1, v2, H
	if (H < 0 ) 
		H += 1
	endif
	if (H > 1 ) 
		H -= 1
	endif
 	
	if ( ( 6 * H ) < 1 )
		return ( v1 + ( v2 - v1 ) * 6 * H )
	endif
 	
	if ((2 * H ) < 1 )
		return ( v2 )
	endif
 	
	if ( ( 3 * H ) < 2 )
		return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - H ) * 6 )
	endif
	return ( v1 )
End

//_________________________________________________________________________
//HSV values = [0,1] RGB [0,255]

Function HSV2RGB(H,S,V,[outr,outg,outb])
	Variable H,S,V
	Variable &outr,&outg,&outb
	
	Variable var_i,var_1,var_2,var_3,var_h,var_r,var_g,var_b
	
	if (S==0)  
		var_r = V  
		var_g = V
		var_b = V
	else
		var_h = H * 6
		var_i = floor(var_h)
		var_1 = V * (1-S)
		var_2 = V* (1-S* (var_h-var_i))
		var_3 = V* (1-S* (1-(var_h-var_i)))

		if( var_i == 0)
			var_r = V 
			var_g = var_3 
			var_b = var_1 
 		 
		elseif (var_i == 1) 
			var_r = var_2 
			var_g =V
			var_b = var_1
 		 
		elseif (var_i == 2)
			var_r = var_1
			var_g = V 
			var_b = var_3 
   
		elseif (var_i == 3) 
			var_r =var_1 
			var_g =var_2 
			var_b =V 
 
		elseif (var_i == 4) 
			var_r = var_3
			var_g = var_1 
			var_b =V 
 
		else 
			var_r = V 
			var_g = var_1 
			var_b = var_2
		endif
	endif
	
	if(ParamIsDefault(outr) || ParamIsDefault(outg) || ParamIsDefault(outb))
		printf "HSV(%g,%g,%g) ==> RGB=(%g,%g,%g)\r",H,S,V,var_r,var_g,var_b 
	else
		outr = var_r
		outg = var_g
		outb = var_b
	endif

End


//_________________________________________________________________________
// The following function uses HSV2RGB() to create distinct consecutive colors.  The color difference
// between every other color depend on the total number of colors selected but in each case, the 
// algorithm attempts to make sure that consecutive colors are as different as possible.  This 
// function is fairly basic.
// Use options=0 for Gizmo colors and options=1 for genera IGOR colors.

Function WM_GetDistinctColor(index,totalColors,outR,outG,outB,options)
	Variable index,totalColors,options
	Variable &outR,&outG,&outB
	
	// some obvious fixed colors
	if(totalColors<8)
		switch(index)
			case 0:
				outR=1;outG=0;outB=0
			break
			
			case 1:
				outR=0;outG=1;outB=0
			break
			
			case 2:
				outR=0;outG=0;outB=1
			break
			
			case 3:
				outR=1;outG=1;outB=0
			break
			
			case 4:
				outR=0;outG=1;outB=1
			break
			
			case 5:
				outR=1;outG=0;outB=1
			break
			
			case 6:
				outR=0;outG=0;outB=0
			break
		endswitch
	
	else		// more than the fixed number of colors:
		Variable inIndex=index
		// make two consecutive colors originate from the opposite sides of the hue circle diameter.
		if(mod(index,2)==0)
			index+=totalColors/2
			index=mod(index,totalColors)
		endif

		Variable H=index/totalColors
		Variable V=1,S=1
	
			switch(mod(inIndex,3))
				case 0:
					V=1
				break
				
				case 1:
					V=0.5
				break
				
				case 2:
					V=0.75
				break
			endswitch
	
			switch(mod(inIndex,4))
				case 0:
					S=0.75
				break
				
				case 1:
					S=1
				break
				
				case 2:
					S=.25
				break
				
				case 3:
					S=0.5
				break
			endswitch
	
		HSV2RGB(H,S,V,outR=outR,outg=outG,outb=outB)
	endif
	if(options==1)
		outR*=65535
		outG*=65535
		outB*=65535
	endif
End


//_________________________________________________________________________
// 090215: Can now specify custom rgb to cmyk for eps and igor pdf export.
//	To do so, create a 7 column float or double wave named M_IgorRGBtoCMYK  
//	(in the root data folder) where the first 3 columns are igor rgb values and the last 4 are the  
//	desired cmyk values on a scale of 0 to 1.
//	Not used for images within eps or pdf and not used for tiff export currently.
//	For example, given:
//	
//	Make/O jack=sin(x/8);Display jack
//	ModifyGraph rgb=(65535,0,0)	// force red
//	
//	Make/N=(2,7)/O M_IgorRGBtoCMYK
//	M_IgorRGBtoCMYK[0]={{65535},{0},{0},{1},{0},{0},{0}}	// red=>cyan
//	M_IgorRGBtoCMYK[1]={{0},{0},{0},{0},{1},{0},{0}}	// black=>magenta
//	
//	SavePICT/C=2/EF=1/E=-8	// export as cmyk igor pdf
//

Function RGB16toCMYK(red,green,blue,cyan,magenta,yellow,black)	
	Variable red, green, blue							// 0-65535 inputs
	Variable &cyan, &magenta, &yellow, &black	// 0-1 outputs
	
	cyan= 65535 - red
	magenta= 65535 - green
	yellow= 65535 - blue

	black = min(cyan,min(magenta,yellow))
	
	cyan= (cyan-black)/65535
	magenta= (magenta-black)/65535
	yellow= (yellow-black)/65535
	black= black/65535
End


// This mathematically looks like a good inverse to RGB16toCMYK()
//
// from http://voisen.org/archives/2003/01/29/cmyk-to-rgb-in-actionscript/
//
//     Color.prototype.2rgb = function( c, m, y, k )
//     {
//         // Convert percentages to 0-255 range
//         c = (0xFF * c) / 100;
//         m = (0xFF * m) / 100;
//         y = (0xFF * y) / 100;
//         k = (0xFF * k) / 100;
//     
//         r = this.dec2hex( Math.round( ((0xFF - c) * (0xFF - k)) / 0xFF ) );
//         g = this.dec2hex( Math.round( (0xFF - m) * (0xFF - k) / 0xFF ) );
//         b = this.dec2hex( Math.round( (0xFF - y) * (0xFF - k) / 0xFF ) ); 
//         return "0x"+r+g+b;
//     }
   
Function CMYKtoRGB16(cyan,magenta,yellow,black,red,green,blue)
	Variable cyan, magenta, yellow, black	// 0-1 inputs
	Variable &red, &green, &blue				// 0-65535 outputs

	red= round((1-cyan) * (1-black) * 65535)
	green= round((1-magenta) * (1-black) * 65535)
	blue= round((1-yellow) * (1-black) * 65535)
End
