#pragma rtGlobals=1		// Use modern global access method.

//  The following procedure calculates the isophote curvature for each pixel.
//  At each point we calculate the first and second derivatives in the \textit{x} and \textit{y} 
//  coordinate system and translate them to the gauge coordinate system.
// The derivates are calculated using central difference approximations
// with a unit spatial step size.  Original JAVA version of this algorithm by Duane Schwarzwald appeared on usenet August 2000.
// The result of the procedure is the wave M_calcCurvature that has the same dimensions and data type as the source image.

Function calcCurvature(srcWave)
	Wave srcWave
	
	Variable rows=DimSize(srcWave,0)
	Variable cols=DimSize(srcWave,1)
	Variable Iso,Ix,Iy,Ixx,Ixy,Iyy;
		
	Duplicate/O srcWave, M_calcCurvature
	
	Variable aIx,aIy,xx,yy;
	Variable ac,an,ane, ae,ase,as,asw,aw,anw
	
	for(xx = 0; xx < rows; xx+=1)
		 for( yy = 0; yy < cols; yy+=1)
			ac  = srcWave[xx][yy]
			an  = srcWave[xx][yy-1]
			ane = srcWave[xx+1][yy-1]
			ae  = srcWave[xx+1][yy]
			ase = srcWave[xx+1][yy+1]
			as  = srcWave[xx][yy+1]
			asw = srcWave[xx-1][yy+1]
			aw  = srcWave[xx-1][yy]
			anw = srcWave[xx-1][yy-1]
			
			Ix = (-aw +ae)/2	 
			Iy = (-an + as)/2;
			Ixx = aw + (-2 * ac) +ae;
			 Iyy = an + (-2 * ac) + as;
			Ixy = (anw + -ane + -asw + ase)/4;
			
			M_calcCurvature[xx][yy]=  (((Iy*Iy))*Ixx -2*Ix*Ixy*Iy + Iyy*((Ix*Ix))) / (1+(Ix*Ix)+(Iy*Iy))
		endfor
	endfor
End