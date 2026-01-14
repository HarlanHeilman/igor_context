#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma moduleName=CIE_Chromaticity
#pragma version=9.021			// shipped with Igor 9.02


// Version 9.02 - Initial Version
// Version 9.021, JP230406, Added Rec. 2020 (ITU-R BT.2020) white point and primaries
Menu "CIE"
	"New CIE Graph"
	"Change Primaries Triangle"
	"Change White Point"
	"Toggle Planckian Locus"
	"Change CIE Background Image"
	"-"
	"Add Mark to CIE Graph"
	"Remove Marks from CIE Graph"
	"-"
	"Spectra To CIE XY"
	"-"
	"Chromaticity Diagram Tutorial", /Q, BrowseURL/Z "https://www.youtube.com/watch?v=KDiTxWcD3ZE"
End

//#define DEBUGGING

Function NewCIEGraph()
	String oldDF = Set_CIE_DF()
	WM_Init_CIE_Package(0)
	WAVE pureXX = $CIE_DF_VAR("pureXX")
	WAVE pureYY = $CIE_DF_VAR("pureYY")
	Display/W=(172.5,38.75,621,529.25) pureYY vs pureXX
	String graphName = S_Name
	DoWindow/T $graphName, graphName+": CIE XY Graph"
	WAVE cieRGBBackgroundImage = $CIE_DF_VAR("cieRGBBackgroundImage")
	AppendImage cieRGBBackgroundImage
	ModifyGraph mode=0,lsize=2,rgb=(0,0,0),lineJoin={1,10}
	ModifyGraph mirror=0, minor=1
	SetAxis left 0,0.86
	SetAxis bottom -.06,0.75
	Label left "Y";DelayUpdate
	Label bottom "X"
	ModifyGraph width={Plan,1,bottom,left}
	SetWindow $graphName userdata(isCIEGraph)="Yes"
	CIE_Chromaticity#DrawHorseshoeTicks(graphName, 440, 650, 0.01, 0.005, 2)
	CIE_Chromaticity#fDrawPrimariesTriangle(graphName, "sRGB", 4)
	SetDataFolder oldDF
End

Function WM_Init_CIE_Package(Variable always)
	Variable didIt = 0
	WAVE/Z bkgImage = $CIE_DF_VAR("cieRGBBackgroundImage")
	if( always || (!WaveExists(bkgImage)) )
		Variable result = WM_Initialize_CIE()
		didIt = result == 0
	endif
	return didIt
End

Function WM_Initialize_CIE()
	
	// Obtain the CIE chromaticity color matching functions numerical values into waves xL, yL, zL, 1 nm/point from 390 to 830 nm
	//		http://cvrl.ioo.ucl.ac.uk/database/data/cienewxyz/lin2012xyz2e_1_7sf.htm
	// See also: http://cvrl.ioo.ucl.ac.uk/
	String path = FunctionPath("")	// Path to file containing this function.
	if (CmpStr(path[0],":") == 0)
		// This is the built-in procedure window or a packed procedure
		// file, not a standalone file. Or procedures are not compiled.
		DoAlert 0, GetRTStackInfo(1)+" is not in a standalone procedure file"
		return -1
	endif
	
	PleaseWait("Initializing CIE XY Graph Package...")
	
	String oldDF =  Set_CIE_DF()

	// Create path to the lookup table file.
	path = ParseFilePath(1, path, ":", 1, 0) + "ColorMatchingFunctions.csv"
	
	String columnInfoStr = ""
	columnInfoStr += "C=1,F=0,T=2,N=cLambda;"
	columnInfoStr += "C=1,F=0,T=4,N=xL;"		// mostly red response (longest wavelengths)
	columnInfoStr += "C=1,F=0,T=4,N=yL;"		// mostly green response (middle wavelengths)
	columnInfoStr += "C=1,F=0,T=4,N=zL;"		// mostly blue response (shortest wavelengths)

	LoadWave/J/D/K=1/V={"\t,"," $",0,1}/L={0,3,0,0,4}/B=ColumnInfoStr/O/A/Q path
	if( V_Flag != 4 )
		SetDataFolder oldDF
		DoAlert 0, "Could not load color matching functions file "+path
		return -1
	endif
	
	WAVE cLambda,xL,yL,zL
	Variable n = DimSize(cLambda,0)
	Variable cLambdaStart = cLambda[0]
	Variable dLambda= cLambda[1]-cLambdaStart // expected to be 1 nm/data point
	Variable cLambdaEnd = cLambda[n-1]

	//Set the wave scalings to account for cLambda:
	SetScale/P x cLambdaStart,dLambda,"", xL,yL,zL
	
	// Compute horseshoe CIE xy coordinates
	// There is an inflection point in normY vs normX
	// at lambda = 700 beyond which the x and y reverse direction.
	makeXYPairForPureSpectrum(cLambdaStart,700,n)
	
	// https://en.wikipedia.org/wiki/Planckian_locus
	makeXYPairForPlanckianLocus()

#ifdef DEBUGGING
 	// normalized x and y
	Duplicate/O xL, normX, normY
	normX = xL[p]/(xL[p]+yL[p]+zL[p])
	normY = yL[p]/(xL[p]+yL[p]+zL[p])
	Variable timerRefNum = StartMSTimer
#endif
	
	// Compute background RGB Image using default parameters
	Variable gammaCorr= 2.2
	Variable makeBrighter = 1
	WMMakeRGBbackgroundImage(0,0.001,0.72,0.,0.001,0.86,gammaCorr,makeBrighter)
	
#ifdef DEBUGGING
	Variable elapsedMicroSeconds = StopMSTimer(timerRefNum)
	Print "WM_Initialize_CIE: ", elapsedMicroSeconds/1e6, "seconds"
#endif

	SetDataFolder oldDF

	PleaseWait("")

	return 0
End

Function/S PleaseWait(String message) // pass "" to kill the progress window

	String panelName="CIE_Please_Wait"
	
	DoWindow/F $panelName
	Variable new = V_Flag == 0 && strlen(message) > 0
	Variable kill = strlen(message) == 0
	if( new ) 
		NewPanel/K=1/N=$panelName/W=(420,271,720,471) as "Please Wait"
		DoIgorMenu "Control", "Retrieve Window"
	endif
	if( strlen(message) )
		TitleBox pleaseWait,win=$panelName,pos={46.00,87.00},size={199.00,16.00}
		TitleBox pleaseWait,win=$panelName,title=message,frame=0,anchor=MC
	endif
	if( kill )
		DoWindow/K $panelName
	endif
	
	return panelName
End


static Function/S WMMakeRGBbackgroundImage(xmin,dx,xmax,ymin,dy,ymax,gammaCorr,makeBrighter)
	Variable xmin,dx,xmax,ymin,dy,ymax,gammaCorr,makeBrighter
	
	Variable nx=ceil((xmax-xmin)/dx)
	Variable ny=ceil((ymax-ymin)/dy)
	
	Make/O/N=(nx,ny,3)/U/B cieRGBBackgroundImage
	SetScale/P x, xmin, dx, "", cieRGBBackgroundImage
	SetScale/P y, ymin, dy, "", cieRGBBackgroundImage
	
	// create a mask image for inside/outside of the horseshoe defined by pureYY vs pureXX
	DoWindow/K CIE_Make_Mask
	NewImage/N=CIE_Make_Mask cieRGBBackgroundImage
	String graphName= S_Name

	Wave pureXX,pureYY

	SetDrawLayer/W=$graphName/K ProgFront
	String prevLayer = S_name

	SetDrawEnv/W=$graphName push
	SetDrawEnv/W=$graphName xcoord= top,ycoord= left, save
	SetDrawEnv/W=$graphName lineThick=1, save
	SetDrawEnv/W=$graphName dash=0, fillpat=0, save // no dash, no fill
	DrawPoly/W=$graphName/ABS 0,0,1,1,pureXX,pureYY
	ImageGenerateROIMask cieRGBBackgroundImage
	SetDrawEnv/W=$graphName pop
	SetDrawLayer/W=$graphName $prevLayer

	WAVE wmask= M_ROIMask

	DoWindow/K $graphName

	cieRGBBackgroundImage[][][0] = RGBbackgroundImage(cieRGBBackgroundImage,wmask,p,q,gammaCorr,makeBrighter,255)
	
	KillWaves/Z wmask
End

// bkgImage[row][column][] is expected to be unsigned byte color wave (3 layers)
// wmask[p][q] is 1 where the background image color should be computed, is 0 for white
// returns the red (layer 0) value, but actually sets the other two layers (1=green, 2=blue)
Function RGBbackgroundImage(WAVE bkgImage,WAVE wmask, Variable row, Variable col, Variable gammaCorr, Variable makeBrighter, Variable colorMax)
	
	Variable red, green, blue
	
	if( wmask[row][col] == 1 ) // inside horseshoe
		Variable xi = DimOffset(bkgImage,0) + row * DimDelta(bkgImage,0)
		Variable yj = DimOffset(bkgImage,1) + col * DimDelta(bkgImage,1)
		
		[red, green, blue] = XYTosRGB(xi,yj,gammaCorr,makeBrighter)

		red *= colorMax
		green *= colorMax
		blue *= colorMax
	else
		red=colorMax; green=colorMax; blue=colorMax
	endif

	//bkgImage[row][col][0] = red we return it instead.
	bkgImage[row][col][1] = green
	bkgImage[row][col][2] = blue

	return red
End

// Converts from XYZ to linear sRGB using calculations from:
// C. A. Bouman: Digital Image Processing - January 12, 2022

static function [Variable RR, Variable GG, Variable BB] XYTosRGB(Variable inx, Variable iny, Variable gammaCorr,Variable makeBrighter)
	
	variable inz=1-inx-iny
	
	RR= 3.2410*inx-1.5374*iny-0.4986*inz
	if(RR<0.0)
		RR=0
	elseif(RR>1)
		RR=1
	endif
				
	GG=-0.9692*inx+1.8760*iny+0.0416*inz
	if(GG<0.0)
		GG=0
	elseif(GG>1)
		GG=1
	endif
				
	BB=0.0556*inx-0.2040*iny+1.0570*inz
	if(BB<0.0)
		bb=0
	elseif(BB>1)
		BB=1
	endif
	
	// nonlinear correction using γ = 2.2 if gammaCorr isn't disabled (=0 or =1)
	if( (gammaCorr != 1.0) && (gammaCorr > 0) )
		RR = gammafx(RR)
		GG = gammafx(GG)
		BB = gammafx(BB)
	endif

	if( makeBrighter )
		Variable scale = 1.0/max(RR,GG,BB)	// relies on not all components being zero
		RR *= scale
		GG *= scale
		BB *= scale
	endif
End

// γ = 2.2
static function gammafx(Variable linearComponent)

	Variable corrected
	if( linearComponent <= 0.0031308 )
		corrected = 12.92 * linearComponent
	else
		corrected = 1.055 * linearComponent ^ (1/2.4) - 0.055
	endif

	return corrected
End

// See https://en.wikipedia.org/wiki/CIE_1931_color_space
static function [Variable RR, Variable GG, Variable BB] XY2RGB(Variable inx, Variable iny, Variable gammaCorr,Variable makeBrighter)
	
	variable inz=1-inx-iny
	
	RR=(2.36461385*inx-0.89654057*iny-0.46807328*inz)
	if(RR<0.0)
		RR=0
	elseif(RR>1)
		RR=1
	endif
				
	GG=(-0.51516621*inx+1.4264081*iny+0.0887581*inz)
	if(GG<0.0)
		GG=0
	elseif(GG>1)
		GG=1
	endif
				
	BB=(0.0052037*inx-0.01440816*iny+1.00920446*inz)
	if(BB<0.0)
		bb=0
	elseif(BB>1)
		BB=1
	endif
	if( (gammaCorr != 1.0) && (gammaCorr > 0) )
		Variable pwr = 1/gammaCorr
		RR = RR^pwr
		GG = GG^pwr
		BB = BB^pwr
	endif

	if( makeBrighter )
		Variable scale = 1.0/max(RR,GG,BB)	// relies on not all components being zero
		RR *= scale
		GG *= scale
		BB *= scale
	endif
End

static Function DrawHorseshoeTicks(String graphName, Variable minLambda, Variable maxLambda, Variable tickLen, Variable lblOffset, Variable lineThick)

	WAVE pureXX= $CIE_DF_VAR("pureXX")
	WAVE pureYY= $CIE_DF_VAR("pureYY")
	WAVE pureLambda= $CIE_DF_VAR("pureLambda")	
	
	WaveStats/Q/M=1 pureLambda
	if( minLambda < V_min )
		minLambda = V_min
	endif
	if( maxLambda > V_Max )
		maxLambda = V_Max
	endif
	
	Variable minorTickInc = 5
	Variable majorTickInc = minorTickInc * 4	// 20, major tick Inc must be a multiple of minorTickInc

	Variable canonicalTick = floor(minLambda/majorTickInc)*majorTickInc // <= than minLambda
	Variable nextMajorTick = canonicalTick + majorTickInc
	

	SetDrawLayer/W=$graphName/K ProgAxes
	String prevLayer = S_name
	SetDrawEnv/W=$graphName push
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left, save
	SetDrawEnv/W=$graphName textyjust=0, textxjust=0, save
	SetDrawEnv/W=$graphName lineThick=lineThick, save
	SetDrawEnv/W=$graphName fStyle=1, save // bold

	Variable lambda = floor(minLambda/minorTickInc)*minorTickInc
	for(; lambda <= maxLambda; lambda += minorTickInc)
	
		// find next tick, whether minor or major
		// using <= skips the first lambda value, because the tangent uses the previous and next
		for( ;lambda <= minLambda; lambda += minorTickInc )
			;
		endfor
		if( lambda >= maxLambda )
			break
		endif
			
		Variable norX,norY
		compNorXYForLambda2(lambda,norX,norY)
		
		Variable isMajor = mod(lambda,majorTickInc) == 0
		Variable tl = ticklen
		if( isMajor )
			tl = ticklen * 3 / 2
		endif
		Variable tx, ty, lx, ly, anchor
		DrawHorseshoeTick(graphName,lambda,norX,norY,lineThick,tl,lblOffset,"Outside",tx,ty,lx,ly)

		if( isMajor )
			if( lambda < 520 )
				SetDrawEnv/W=$graphName textxjust= 2, textyjust=1
			endif
			DrawText/W=$graphName lx, ly, num2str(lambda)
		endif
	endfor
	SetDrawEnv/W=$graphName pop
	SetDrawLayer/W=$graphName/K $prevLayer
End
		
// On output, tx, ty is location of the far (unlabeled) end of the tickmark.
// and lx, ly is the (possibly offset) location of the near (labeled) end of the tickmark; the label anchor goes here.
// returns visible
//static Function DrawHorseshoeTick(graphName,radius,angle,x0Drawn,y0Drawn,lineThick,ticklen,lblOffset,tickOrient,tickWhere,tx,ty,lx,ly,xmin,xmax,ymin,ymax)
static Function DrawHorseshoeTick(graphName,lambda,x0Drawn,y0Drawn,lineThick,ticklen,lblOffset,tickWhere,tx,ty,lx,ly)
	String graphName
	Variable lambda				// position of tick mark in lambda coordinates
	Variable x0Drawn,y0Drawn	// position of tick mark in x, y coordinates
	Variable lineThick			// points; if zero, don't actually draw it, just compute the tick label position
	Variable ticklen				// in drawn coordinates
	String tickWhere			// "Crossing", "Inside", or "Outside"
	Variable lblOffset			//  in drawn coordinates, included in lx, ly output.
//	Variable tickOrient			// add this to angle to set the tickmark orientation, 0 or Pi for parallel, +/-Pi/2 for perpendicular
	Variable &tx, &ty			// OUTPUT: location of the unlabelled end of the tickmark.
	Variable &lx, &ly			// OUTPUT: the (possibly offset) location of the labelled end of the tickmark; the label anchor goes here.
//	Variable xmin,xmax,ymin,ymax	// plot extent in drawn coordinates

	Variable halfTick=ticklen/2
	
	// compute the tangent angle
	Variable lambdaMinus = lambda - 1
	Variable norXMinus,norYMinus
	compNorXYForLambda2(lambdaMinus,norXMinus,norYMinus)

	Variable lambdaPlus = lambda + 1
	Variable norXPlus,norYPlus
	compNorXYForLambda2(lambdaPlus,norXPlus,norYPlus)
	
	Variable tangentAngle = atan2(norYPlus-norYMinus, norXPlus-norXMinus)
	Variable angle = mod(tangentAngle+pi/2,2*pi)	// rotate 90 degrees (CCW is positive angles)
	
	Variable cosAngle= cos(angle)
	Variable sinAngle= sin(angle)
	tx= x0Drawn
	ty= y0Drawn 		// position of tick on horseshoe

	cosAngle= cos(angle)
	sinAngle= sin(angle)
	
	// far end (unlabelled) crossing tick mark calculations
	strswitch(tickWhere)
		case "Outside":
			break
		default:		// "Crossing" or error
			tx -= cosAngle * halfTick
			ty -= sinAngle * halfTick
			break;
		case "Inside":
			tx -= cosAngle * ticklen
			ty -= sinAngle * ticklen
			break
	endswitch
	// Given far end, calculate near (labelled) end
	lx= tx+cosAngle * ticklen
	ly= ty+sinAngle * ticklen
	// Draw the tick mark (if lineThick != 0)
	DrawLine/W=$graphName tx,ty,lx,ly
	// Apply label standoff
	lx += cosAngle * lblOffset
	ly += sinAngle * lblOffset
	return 0
End

Function/S CIEPrimariesName(String graphName)

	String primariesName= StrVarOrDefault(CIE_DF_VAR("primariesName"), "sRGB")
	if( strlen(graphName) )
		String ud = GetUserData(graphName, "", "primariesName")
		if( strlen(ud) )
			primariesName = ud
		endif
	endif
	return primariesName
End
	
Proc ChangePrimariesTriangle(primariesName, circleSizeInPoints)
	String primariesName= CIEPrimariesName(TopCIEGraph())
	Variable circleSizeInPoints = NumVarOrDefault(CIE_DF_VAR("trianglesCircleSize"),4)
	Prompt primariesName, "Primary Colors", popup, "do not show;sRGB;Rec. 2020;NTSC;PAL;"
	Prompt circleSizeInPoints, "Size of circle at Primaries, 0 for none"

	String graphName= TopCIEGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a CIE Graph"
		return -1
	endif
	DoWindow/F $graphName
	CIE_Chromaticity#fDrawPrimariesTriangle(graphName, primariesName, circleSizeInPoints)
	String/G $CIE_DF_VAR("primariesName") = primariesName
	Variable/G $CIE_DF_VAR("trianglesCircleSize") = circleSizeInPoints
End

static Function fDrawPrimariesTriangle(String graphName, String primariesName, Variable circleSizeInPoints)
	SetDrawLayer/W=$graphName/K UserAxes // so we can draw a different primaries triangle
	String prevLayer = S_name

	Variable xr,yr // red normalized CIE XY coordinates
	Variable xg,yg // green
	Variable xb,yb // blue
	strswitch( primariesName )
		case "none":
		case "do not show":
			SetDrawLayer/W=$graphName $prevLayer
			return 0	// EARLY EXIT when clearing the triangle
			break
		default:
		case "sRGB": // ITU-R BT.709
			xr= 0.64; yr= 0.33
			xg= 0.30; yg= 0.60
			xb= 0.15; yb= 0.06
			break
		case "Rec. 2020": // ITU-R BT.2020
			xr= 0.708; yr= 0.292
			xg= 0.17; yg= 0.797
			xb= 0.131; yb= 0.046
			break
		case "PAL":
			xr= 0.64; yr= 0.33
			xg= 0.29; yg= 0.60
			xb= 0.15; yb= 0.06
			break
		case "NTSC":
			xr= 0.67; yr= 0.33
			xg= 0.21; yg= 0.71
			xb= 0.14; yb= 0.08
			break
	endswitch

	SetDrawEnv/W=$graphName push
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left, save
	SetDrawEnv/W=$graphName lineThick=1, save
	SetDrawEnv/W=$graphName dash=0, fillpat=0, save // no dash, no fill
	DrawPoly/W=$graphName/ABS 0,0,1,1,{xr,yr,xg,yg,xb,yb,xr,yr}
	
	if( circleSizeInPoints > 0 )
		DrawArc/W=$graphName xr,yr,circleSizeInPoints,0,0 // full circle
		DrawArc/W=$graphName xg,yg,circleSizeInPoints,0,0 // full circle
		DrawArc/W=$graphName xb,yb,circleSizeInPoints,0,0 // full circle
	endif
	
	SetDrawEnv/W=$graphName pop
	SetDrawLayer/W=$graphName $prevLayer
	
	SetWindow $graphName userdata(primariesName) = primariesName
	return 1
End		


Proc AddMarkToCIEGraph(cieX, cieY, markerSize, clearOtherMarkersPop)
	Variable cieX = 0.3333	// equal energy point (white)
	Variable cieY = 0.3333
	Variable markerSize = 0.03
	Variable clearOtherMarkersPop= 2 // no
	Prompt cieX, "Normalized CIE X"
	Prompt cieY, "Normalized CIE Y"
	Prompt clearOtherMarkersPop, "Clear other markers?", popup, "Yes;No;"

	String graphName= TopCIEGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a CIE Graph"
		return -1
	endif
	Variable doClear = clearOtherMarkersPop == 1 // 0 for No, 1 for Yes
	DoWindow/F $graphName
	CIE_Chromaticity#fAddCIEMarker(graphName, cieX, cieY, markerSize,doClear)
End

Proc RemoveMarksFromCIEGraph()

	String graphName= TopCIEGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a CIE Graph"
		return -1
	endif
	DoWindow/F $graphName 
	SetDrawLayer/W=$graphName/K ProgFront
	String prevLayer = S_name
	SetDrawLayer/W=$graphName $prevLayer
End

static Function fAddCIEMarker(graphName, cieX, cieY, size, doClear)
	String graphName
	Variable cieX, cieY
	Variable size // width and height in CIE XY coordinates
	Variable doClear // 0 no, 1, yes
	
	if( doClear )
		SetDrawLayer/W=$graphName/K ProgFront
	else
		SetDrawLayer/W=$graphName ProgFront
	endif
	String prevLayer = S_name
	SetDrawEnv/W=$graphName push
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left, save
	SetDrawEnv/W=$graphName lineThick=2, save
	SetDrawEnv/W=$graphName dash=3, save

	Variable x1= cieX - size/2, x2 = cieX + size/2
	Variable y1 = cieY - size/2, y2 = cieY + size/2
	DrawLine/W=$graphName x1, cieY, x2, cieY
	DrawLine/W=$graphName cieX, y1, cieX, y2
	
	SetDrawEnv/W=$graphName pop
	SetDrawLayer/W=$graphName $prevLayer
	return 0
End

// The xy chromaticity coordinates for D65,
// based on the relative spectral radiant power distribution for D65
// and the CIE 1931 color-matching functions, are x=0.3127 and y=0.3290.
//
// These xy coordinates are on the CIE daylight locus in the CIE 1931 xy chromaticity space.

Proc ChangeWhitePoint(whitePointName, circleSizeInPoints)
	String whitePointName= "D65"
	Variable circleSizeInPoints = 4

	Prompt whitePointName, "White Point", popup, "do not show;D50;D55;D65;E;Rec. 2020;1666.7 K;9300 K;∞;"
	Prompt circleSizeInPoints, "Size of circle at White Point, 0 for none"

	String graphName= TopCIEGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a CIE Graph"
		return -1
	endif
	DoWindow/F $graphName 
	CIE_Chromaticity#fDrawWhitePoint(graphName, whitePointName, circleSizeInPoints)
End

static Function fDrawWhitePoint(String graphName, String whitePointName, Variable circleSizeInPoints)

	SetDrawLayer/W=$graphName/K Overlay
	String prevLayer = S_name

	Variable cieX,cieY
	strswitch( whitePointName )
		case "none":
		case "do not show":
			SetDrawLayer/W=$graphName $prevLayer
			return 0	// EARLY EXIT when clearing the triangle
			break
		case "D50":	// 5000°K
			cieX= 0.3457
			cieY= 0.3587
			break
		case "D55":	// 5500°K
			cieX= 0.3325
			cieY= 0.3476
			break
		case "D65":	// 6504°K
			cieX= 0.3127
			cieY= 0.3290
			break
		default:
		case "E": // equal energy
			cieX= 0.333333
			cieY= cieX
			break
		case "Rec. 2020": // ITU-R BT.2020
			cieX= 0.3127
			cieY= 0.329
			break
		case "1666.7 K":	//  (6000 mirek)
			cieX= 0.37683
			cieY= 0.38050
			break
		case "9300 K":	// Asian studio white
			cieX= 0.2830
			cieY= 0.2980
			break
		case "∞":	// (0 mirek)
			cieX= 0.23704
			cieY= 0.236741
			break
	endswitch

	SetDrawEnv/W=$graphName push
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left, save
	SetDrawEnv/W=$graphName lineThick=1, save
	SetDrawEnv/W=$graphName dash=0, fillpat=0, save // no dash, no fill
	
	DrawArc/W=$graphName cieX,cieY,circleSizeInPoints,0,0 // full circle

// TO DO: Set the label anchor to the right corner to look good, or use and image tag
//	SetDrawEnv/W=$graphName textyjust= 2, textxjust=0
//	DrawText/W=$graphName cieX, cieY, whitePointName
	
	SetDrawEnv/W=$graphName pop
	SetDrawLayer/W=$graphName $prevLayer
	return 1
End

Function/S TopCIEGraph()

	String list = CIEGraphList()
	String graphName= StringFromList(0,list)
	return graphName
End

Function/S CIEGraphList()

	String list=""
	Variable i=0
	do
		String graphName = WinName(i,1,1) // visible graphs
		if( strlen(graphName) == 0 )
			break
		endif
		if( IsCIEGraph(graphName) )
			list += graphName+";"
		endif
		i += 1
	while(1)
	return list
End

Function IsCIEGraph(String graphName)

	Variable isCIEGraph = 0
	if( strlen(graphName) )
		DoWindow $graphName
		if( V_Flag )
			String data = GetUserData(graphName, "", "isCIEGraph")
			isCIEGraph = CmpStr(data,"Yes") == 0
		endif
	endif
	return isCIEGraph
End


static Function/S CIE_DF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:CIE_DF
	return "root:Packages:CIE_DF"
End

Function/S CIE_DF_VAR(String varName)
	String path= CIE_DF() // no trailing :
	return path + ":" + varName
End

// returns old DF
Function/S Set_CIE_DF()
	String oldDF = GetDataFolder(1)
	SetDataFolder CIE_DF()
	return oldDF
End


Function compNorXYForLambda2(lambda,norX,norY)
	variable lambda
	Variable &norX,&norY
	
	Variable xx,yy,zz
	Wave xl,yl,zl
	// here we basically integrate a delta function for lambda times the matching curve
	// by just returning the value of the color matching function waves at the delta's location
	xx=xl(lambda)				
	yy=yl(lambda)
	zz=zl(lambda)

	norX=xx/(xx+yy+zz)
	norY=yy/(xx+yy+zz)
End

// good range is [450,650] nm
static Function makeXYPairForPureSpectrum(lamMin,lamMax,numPoints)
	Variable lamMin,lamMax,numPoints
	
	Make/O/N=(numPoints+1) pureXX,pureYY,pureLambda			// +1 to connect ends
	Variable dl=(lamMax-lamMin)/(numPoints-1)
	SetScale/P x lamMin, dl, "", pureXX, pureYY
	pureLambda=lamMin+p*dl									// this is for labeling the horseshoe curve.
	pureLambda[numPoints]=lamMin
	
	Variable i,lambda,norX,norY

	for(i=0;i<numPoints;i+=1)
		lambda=lamMin+i*dl
		compNorXYForLambda2(lambda,norX,norY)		// suffix2 uses tabled waves xl,yl,zl
		pureXX[i]=norX
		pureYY[i]=norY
	endfor
	pureXX[i]=pureXX[0]
	pureYY[i]=pureYY[0]
End

Proc TogglePlanckianLocus()
	String graphName= TopCIEGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a CIE Graph"
		return -1
	endif
	Variable show = !HavePlanckianLocus(TopCIEGraph()) // preselect the state it is not currently in
	DoWindow/F $graphName
	CIE_Chromaticity#fShowHidePlanckianLocus(graphName, show)
End

Static Function fShowHidePlanckianLocus(String graphName, Variable show)

	if( !IsCIEGraph(graphName) )
		return -1
	endif
	
	WAVE/Z py = $CIE_DF_VAR("planckY")
	if( !WaveExists(py) )
		makeXYPairForPlanckianLocus()
		WAVE py = $CIE_DF_VAR("planckY")
	endif
	
	WAVE/Z pTrace = PlanckianTrace(graphName)
	if( show )
		if( !WaveExists(pTrace) )
			WAVE px = $CIE_DF_VAR("planckX")
			AppendToGraph/W=$graphName py vs px
			ModifyGraph/W=$graphName rgb(planckY)=(0,0,0)
		endif	
		DrawPlanckianTicks(graphName)
	else
		if( WaveExists(pTrace) )
			RemoveFromGraph/W=$graphName planckY // attached tags will vanish
		endif	
	endif

	return 0
End

static Function DrawPlanckianTicks(String graphName)

	WAVE/Z pTrace = PlanckianTrace(graphName)
	if( !WaveExists(pTrace) )
		return -2
	endif

	// create a succession of
	// Tag/C/N=text0 planckY, 1700,"\\{\"%d\", pnt2x(TagWaveRef(), TagVal(0))}"
	// for a few important values
	Variable so = 1
	String fs="\\Zr075"
	String cmd= fs+"\\{\"%d\", pnt2x(TagWaveRef(), TagVal(0))}"
	Tag/W=$graphName/C/N=text0/P=(so)/X=7.26/Y=7.50 planckY, 1700,cmd
	Tag/W=$graphName/C/N=text1/P=(so)/X=2.70/Y=-7.50 planckY, 2000,cmd
	Tag/W=$graphName/C/N=text2/P=(so)/X=-2.07/Y=-7.68 planckY, 2500,cmd
	Tag/W=$graphName/C/N=text3/P=(so)/X=-2.70/Y=7.85 planckY, 3000,cmd
	Tag/W=$graphName/C/N=text4/P=(so)/X=-5.19/Y=8.73 planckY, 4000,cmd
	Tag/W=$graphName/C/N=text5/P=(so)/X=-3.94/Y=8.20 planckY, 6000,cmd
	Tag/W=$graphName/C/N=text6/P=(so)/X=-5.19/Y=7.85 planckY, 10000,cmd
	Tag/W=$graphName/C/N=text7/P=(so)/X=-8.09/Y=5.41 planckY, 25000,cmd
	return 0
End




static Function/WAVE PlanckianTrace(String graphName)
	WAVE/Z py = TraceNameToWaveRef(graphName,"planckY")
	return py
End

Function HavePlanckianLocus(String graphName)

	if( !IsCIEGraph(graphName) )
		return 0
	endif
	WAVE/Z pTrace = PlanckianTrace(graphName)
	Variable haveLocus = WaveExists(pTrace)
	return haveLocus
End

// https://en.wikipedia.org/wiki/Planckian_locus
static Function makeXYPairForPlanckianLocus()
	Variable Tmin = 1700 // degrees Kelvin
	Variable Tmax = 25000
	Variable Tpoints = (Tmax-Tmin)/100+1
	
	String oldDF = Set_CIE_DF()
	Make/O/N=(Tpoints) planckX, planckY
	Variable dT=(Tmax-Tmin)/(Tpoints-1)
	SetScale/P x Tmin, dT, "°K", planckX, planckY
	planckX = PlanckianX(x)	// here x is the temperature in Kelvin
	planckY = PlanckianY(x)	// here x is the temperature in Kelvin
	SetDataFolder oldDF
End

// https://en.wikipedia.org/wiki/Planckian_locus#Approximation
static Function PlanckianX(Variable T)
	Variable xc=NaN
	
	Variable a = 1e9/(T*T*T)
	Variable b = 1e6/(T*T)
	Variable c = 1e3/T
	
	if( T >= 1667 && T <= 4000 )
		xc = -0.2661239*a - 0.2343589*b + 0.8776956*c + 0.17991
	elseif( T >= 4000 && T <= 25000 )
		xc = -3.0258469*a + 2.1070379*b + 0.2226347*c + 0.240390
	endif	
	
	return xc
End

static Function PlanckianY(Variable T)
	Variable yc=NaN
	
	Variable xc = PlanckianX(T)
	Variable a = xc*xc*xc
	Variable b = xc*xc
	Variable c = xc
	
	if( T >= 1667 && T <= 2222 )
		yc = -1.1063814*a - 1.34811020*b + 2.18555832*c - 0.20219683
	elseif( T >= 2222 && T <= 4000 )
		yc = -0.9549476*a -1.37418593*b + 2.09137015*c - 0.16748867
	elseif( T >= 4000 && T <= 25000 )
		yc = 3.0817580*a - 5.87338670*b + 3.75112997*c - 0.37001483
	endif	
	
	return yc
End

Proc ChangeCIEBackgroundImage(gammaCorr, brighter)
	Variable gammaCorr= 2.2
	Variable brighter = 1 // activate scale RGB to max of R,G,B
	Prompt gammaCorr, "RGB Gamma Correction"
	Prompt brighter, "Brighter Colors", popup, "Yes;No;"
	
	WM_Init_CIE_Package(0)

	Variable makeBrighter = brighter == 1
	PleaseWait("Rebuilding CIE Background Image...")
	String oldDF =  Set_CIE_DF()
	Variable timerRefNum = StartMSTimer
	CIE_Chromaticity#WMMakeRGBbackgroundImage(0,0.001,0.72,0.,0.001,0.86,gammaCorr,makeBrighter)
	Variable elapsedMicroSeconds = StopMSTimer(timerRefNum)
	String msg
	sprintf msg, "Background compute time = %.2f seconds", elapsedMicroSeconds/1e6
	Print msg
	SetDataFolder oldDF
	PleaseWait(msg)
	Sleep/C=2/S 2
	PleaseWait("")
End

/////// START of routines to compute the CIE XY value from a spectral measurement of intensity vs wavelength in nm ("lambda")
Proc SpectraToCIEXY(intensityWaveName, wavelengthWaveName, doWhat)
	String intensityWaveName = StrVarOrDefault(CIE_DF_VAR("spectraWaveName"),"intensity")
	String wavelengthWaveName= StrVarOrDefault(CIE_DF_VAR("wavelengthWaveName"),"_calculated_")
	Variable doWhat=NumVarOrDefault(CIE_DF_VAR("spectraDoWhat"),1)	// 1 = Display CIE XY in new CIE Graph

	Prompt intensityWaveName, "Intensity" , popup, WaveList("!*interp",";", "DIMS:1,TEXT:0,WAVE:0,DF:0") // only one-D waves in current DF
	Prompt wavelengthWaveName, "vs WaveLength", popup, "_calculated_;"+WaveList("*",";", "DIMS:1,TEXT:0,WAVE:0,DF:0") // only one-D waves in current DF
	Prompt doWhat, "Show CIE XY Result", popup, "in new CIE Graph;add to top CIE Graph;print to History;"
	
	// Save choices for next invocation
	String/G $CIE_DF_VAR("spectraWaveName") = intensityWaveName
	String/G $CIE_DF_VAR("wavelengthWaveName") = wavelengthWaveName
	Variable/G $CIE_DF_VAR("spectraDoWhat") = doWhat
	
	if( CmpStr(wavelengthWaveName,"_calculated_") == 0 )
		fSpectrumToCIE($intensityWaveName, $"", doWhat)
	else
		fSpectrumToCIE($intensityWaveName, $wavelengthWaveName, doWhat)
	endif
End

// doWhat: 1 = in new CIE Graph, 2 = add to top CIE Graph (if it exists), 3 (else) print to History
Function fSpectrumToCIE(WAVE wIntensity, WAVE/Z wLambda, Variable doWhat)

	Variable cieX, cieY, cieZ // normalized
	
	[cieX, cieY, cieZ] = SpectraToCIENormalizedXYZ(wIntensity, wLambda)
	
	switch( doWhat )
		case 1:	// in new CIE Graph
			NewCIEGraph()
			// fall through
		case 2:	// add to top CIE Graph, if any
			String topGraph = TopCIEGraph()
			if( strlen(topGraph) )
				DoWindow/F $topGraph
				Variable markerSize = 0.03
				Variable doClear = 0
				fAddCIEMarker(topGraph, cieX, cieY, markerSize, doClear)
			endif
			// always fall through
		default: // print to History
			String msg
			sprintf msg, "Normalized CIE XYZ = (%g,%g,%g)", cieX, cieY, cieZ
			Print msg
			
			// linear sRGB, non-normalized
			Variable red, green, blue, colorMax= 255
			Variable gammaCorr = 1 // linear sRGB
			Variable makeBrighter = 0 // don't normalize
			[red, green, blue] = XYTosRGB(cieX,cieY,gammaCorr,makeBrighter)
			red *= colorMax
			green *= colorMax
			blue *= colorMax
			sprintf msg, "Linear sRGB (255 max) = (%g,%g,%g)", red, green, blue
			Print msg
			
			// gamma-corrected sRGB, non-normalized
			gammaCorr = 2.2 // gamma = 2.2 sRGB
			makeBrighter = 0 // don't normalize
			[red, green, blue] = XYTosRGB(cieX,cieY,gammaCorr,makeBrighter)
			red *= colorMax
			green *= colorMax
			blue *= colorMax
			sprintf msg, "Gamma-corrected 2.2 sRGB (255 max) = (%g,%g,%g)", red, green, blue
			Print msg
			
			// gamma-corrected sRGB, normalized
			gammaCorr = 2.2 // gamma = 2.2 sRGB
			makeBrighter = 1 // normalize
			[red, green, blue] = XYTosRGB(cieX,cieY,gammaCorr,makeBrighter)
			red *= colorMax
			green *= colorMax
			blue *= colorMax
			sprintf msg, "Normalized gamma-corrected 2.2 sRGB (255 max) = (%g,%g,%g)", red, green, blue
			Print msg
			
			// See https://en.wikipedia.org/wiki/CIE_1931_color_space
			gammaCorr = 1 // linear CIE rgb
			makeBrighter = 0 // don't normalize
			[red, green, blue] = XY2RGB(cieX,cieY,gammaCorr,makeBrighter)
			red *= colorMax
			green *= colorMax
			blue *= colorMax
			sprintf msg, "Linear CIE 1931 RGB (255 max) = (%g,%g,%g)", red, green, blue
			Print msg

			break
	endswitch
End

Function [Variable ncieX, Variable ncieY, Variable ncieZ] SpectraToCIENormalizedXYZ(WAVE wIntensity, WAVE/Z wLambda)

	WM_Init_CIE_Package(0)	// load the X,Y,Z response curves root:Packages:WM_CIE_DF:xL, yL, zL

	// Compute an interpolated intensity waveform at regular 1nm intervals in the current data folder
	WAVE xL = $CIE_DF_VAR("xL")
	Variable n = numpnts(xL)			// should be 441
	Variable lambdaMin = pnt2x(xL,0)		// in nanometers, should be 390
	Variable lambdaMax = pnt2x(xL,n-1)	// in nanometers, should be 830
	Variable lambdaInc = deltax(xL)		// better be 1 (as in, 1 nm/row)
	String intensityName = NameOfWave(wIntensity)
	if( WaveExists(wLambda) )
		// y vs x data
		// We *presume* the x data isn't completely linear and that it isn't in 1nm steps
		// (if it was, we'd just use wLambda to set the x scaling of wIntensity)
		// Interpolate the y spectra vs x wavelength to a waveform at 1nm intervals
		WaveStats/Q wLambda
		lambdaMin = V_Min
		lambdaMax = V_Max

		intensityName = NameOfWave(wIntensity)+"_interp"
		lambdaMin = ceil(lambdaMin) // enforce integer nm
		lambdaMax = floor(lambdaMax)
		n = 1 + (lambdaMax - lambdaMin)
		Make/O/N=(n) $intensityName/WAVE=winterpolated
		SetScale/P x lambdaMin,1,"",winterpolated
		winterpolated=interp(x,wLambda,wIntensity)
	else
		// already have a waveform; it may not be 1nm increment though
		n = numpnts(wIntensity)
		lambdaMin = pnt2x(wIntensity,0)		// in nanometers
		lambdaMax = pnt2x(wIntensity,n-1)	// in nanometers
		lambdaInc = deltax(wIntensity)
		if( lambdaInc != 1 )
			intensityName = NameOfWave(wIntensity)+"_interp"
			n = 1 + (lambdaMax - lambdaMin)
			Make/O/N=(n) $intensityName/WAVE=winterpolated
			SetScale/P x lambdaMin,1,"",winterpolated
			winterpolated= wIntensity(x)
		endif
	endif

	WAVE w=$intensityName // wIntensity or wIntensity_interp

	lambdaMin = max(lambdaMin, pnt2x(xL,0))
	lambdaMax = min(lambdaMax, pnt2x(xL,n-1))
	Variable options = 0 // trapezoidal integration
	Variable count = 0 // # of subintervals, adaptive Gaussian Quadrature integration

	Variable cieX=Integrate1D(xIntegral,lambdaMin,lambdaMax,options,count,w)
	Variable cieY=Integrate1D(yIntegral,lambdaMin,lambdaMax,options,count,w)
	Variable cieZ=Integrate1D(zIntegral,lambdaMin,lambdaMax,options,count,w)

#ifdef DEBUGGING
	// if we interpolate 5nm to 1nm, the integrals should be about 5 times greater
	Variable interpolationFactor = numpnts(w)/numpnts(wIntensity)
	cieX /= interpolationFactor
	cieY /= interpolationFactor
	cieZ /= interpolationFactor
#endif

	// compute normalized XYZ
	Variable total = cieX+cieY+cieZ
	ncieX=cieX/total
	ncieY=cieY/total
	ncieZ=cieZ/total

	return [ncieX, ncieY, ncieZ]
End

Function xIntegral(Wave wintensity, Variable x)
	
	WAVE xL = $CIE_DF_VAR("xL")
	return wintensity(x)*xL(x)
End

Function yIntegral(Wave wintensity, Variable x)

	WAVE yL = $CIE_DF_VAR("yL")
	return wintensity(x)*yL(x)
End


Function zIntegral(Wave wintensity, Variable x)

	WAVE zL = $CIE_DF_VAR("zL")
	return wintensity(x)*zL(x)
End

/////// End of routines to compute the CIE XY value from a spectral measurement of intensity vs wavelength in nm ("lambda")
