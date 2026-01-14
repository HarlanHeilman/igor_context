#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.38		// Shipped with Igor 6.38

// LH950924: Modernized to Igor Pro 3.0 level
// JP960329: Works with XY traces (Display ywave vs xwave) and non-XY traces (Display ywave)
// JP100628: Removed obsolete include file <AreaXY>
// JP160210: Added Menu definition

Menu "Macros"
	"Put Cursors On Wave", /Q, PutCursorsOnWave()
	"Area XY Between Cursors", /Q, AreaXYBetweenCursors()
	"Area XY Between Cursors Less Base", /Q, AreaXYBetweenCursorsLessBase()
	"Hide Cursors", /Q, HideCursors()
End

Proc PutCursorsOnWave(w)
	String w
	Prompt w,"wave to put cursors on",popup,TraceNameList("",";",1)
	ShowInfo;Cursor/P A,$w,0;Cursor/P B,$w,numpnts(TraceNameToWaveRef("",w))-1
End

Function fAreaXYBetweenCursors()
	String wvaName,wvbName,wvxName
	WAVE wva=CsrWaveRef(A)
	WAVE wvb=CsrWaveRef(B)
	wvaName= GetWavesDataFolder(wva,4)
	wvbName= GetWavesDataFolder(wvb,4)
	if( CmpStr(wvaName,wvbName) != 0 )
		Abort "Cursors must be on the same wave (Cursor A is on wave \""+wvaName+"\"; Cursor B isn't)."
		return NaN
	endif
	Variable p1=pcsr(A)
	Variable p2=pcsr(B)
	if( p1 > p2 )
		p1=p2
		p2=pcsr(A)
	endif
	// extract the subrange between the cursors
	Duplicate/O/R=[p1,p2] wva, s_ywave
	WAVE/Z wvx= CsrXWaveRef(A)			// could be non-existant
	if( WaveExists(wvx) )
		Duplicate/O/R=[p1,p2] wvx,s_xwave
		if( IsMonotonicIncrP1P2(s_xwave,0,p2-p1) == 0 )
			Abort "X values between cursors aren't monotonically increasing or decreasing."
			return NaN
		endif
	endif
	Variable x1=hcsr(A)
	Variable x2=hcsr(B)
	if( x1 > x2 )
		x1= x2
		x2=hcsr(A)
	endif
	Variable a
	if( WaveExists(wvx) )
		a= AreaXY(s_xwave,s_ywave,x1,x2)
		Killwaves/Z s_xwave
	else
		a= area(s_ywave,x1,x2)
	endif
	Killwaves/Z s_ywave
	return A
end

Proc AreaXYBetweenCursors()
	PauseUpdate;Silent 1

	Variable/G V_areaXY= fAreaXYBetweenCursors()
	Print "area between x= ",hcsr(A)," and ",hcsr(B)," = ",V_areaXY
End

// This removes the area of the baseline that stretches between the two cursors
Proc AreaXYBetweenCursorsLessBase()
	PauseUpdate;Silent 1
	Variable/G V_areaXY= fAreaXYBetweenCursors()
	Variable x1=hcsr(A)
	Variable x2=hcsr(B)
	if( x1 > x2 )
		x1= x2
		x2=hcsr(A)
	endif
	V_AreaXY -=  (vcsr(A)+vcsr(B))/2*(x2-x1) 	// remove trapezoidal baseline (straight line between cursors)
	Print "adjusted area between x= ",x1," and ",x2," = ",V_areaXY
End

Proc HideCursors()
	HideInfo;Cursor/K A;Cursor/K B
End

// IsMonotonicIncrP1P2() returns true if the wave has delta(wave(x))/delta(x) > 0 for all points from p1 to p2.
// p1 must be < p2; these are point numbers, not x values
Function IsMonotonicIncrP1P2(wv,p1,p2)
	Wave wv
	Variable p1,p2
	
	Variable diff,i=p1
	Variable last=p2
	Variable incr=(wv[p1+1]-wv[p1])>0
	do
		if(incr)
			diff=wv[i+1]-wv[i]
		else
			diff=wv[i]-wv[i+1]
		endif
		if (diff<=0)
			return 0	// not monotonically increasing. (we DO NOT allow wv[i+1] == wv[i]).
		endif
		i += 1
	while (i < last)
	return 1			// success
End
