#pragma rtGlobals=1		// Use modern global access method.

// Straighten Tags -- makes the top graph's tag attachment lines vertical,
// horizontal, or at 45 degree intervals,  whichever most closely resembles the
// current attachment line.
//
// Requires Igor 3.13
// Based on a routine by Kevin R. Boyce
//
Menu "Graph"
	"-"
	"Straighten Tags..."
End

Proc StraightenTags()

	Silent 1;PauseUpdate	// StraightenTags
	String list = AnnotationList("")
	Variable numBoxes = ItemsInList( list )
	if( numBoxes )
		String thisBox, info, type, flags, xs, ys
		Variable xoff, yoff, newAngle
		GetWindow kwTopWin psize
		Variable gheight= V_bottom - V_top  // points
		Variable gwidth= V_right - V_left
		Variable/C magAngle
		do
			numBoxes -= 1
			thisBox = StringFromList( numBoxes, list )
			info = AnnotationInfo( "", thisBox )
			type = StringByKey( "TYPE", info )
			if( CmpStr( type, "Tag" ) == 0 )
				flags = StringByKey( "FLAGS", info )
				xs = StringByKey( "X", flags, "=", "/" )
				ys = StringByKey( "Y", flags, "=", "/" )
				xoff = Str2Num( xs )
				yoff = Str2Num( ys )
				magAngle= r2polar(cmplx(xoff * gwidth,yoff * gheight))
				// one of 8 principal angles, every 45 degrees.
				// change 45 to 15 to make 24 principal angles
				newAngle= 45 * round(imag(magAngle)/Pi*180 /45)
				newAngle *= pi / 180
				xoff=cos(newAngle)*real(magAngle)/gwidth
				yoff=sin(newAngle)*real(magAngle)/gheight
				Tag/C/N=$thisBox/X=(xoff)/Y=(yoff)
			endif
		while( numBoxes > 0 )
	endif
End
