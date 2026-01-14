# Marquee Menu as Input Device

Chapter IV-6 — Interacting with the User
IV-163
Cursors as Input Device
You can use the cursors on a trace in a graph to identify the data to be processed.
The examples shown above using PauseForUser are modal - the user adjusts the cursors in the middle of 
procedure execution and can do nothing else. This technique is non-modal — the user is expected to adjust 
the cursors before invoking the procedure.
This function does a straight-line curve fit through the data between cursor A (the round cursor) and cursor 
B (the square cursor). This example is written to handle both waveform and XY data.
Function FitLineBetweenCursors()
Variable isXY
// Make sure both cursors are on the same wave.
WAVE wA = CsrWaveRef(A)
WAVE wB = CsrWaveRef(B)
String dfA = GetWavesDataFolder(wA, 2)
String dfB = GetWavesDataFolder(wB, 2)
if (CmpStr(dfA, dfB) != 0)
Abort "Both cursors must be on the same wave."
return -1
endif
// Find the wave that the cursors are on.
WAVE yWave = CsrWaveRef(A)
// Decide if this is an XY pair.
WAVE xWave = CsrXWaveRef(A)
isXY = WaveExists(xWave)
if (isXY)
CurveFit line yWave(xcsr(A),xcsr(B)) /X=xWave /D
else
CurveFit line yWave(xcsr(A),xcsr(B)) /D
endif
End
This technique is demonstrated in the Fit Line Between Cursors example experiment in the “Exam-
ples:Curve Fitting” folder.
Advanced programmers can set things up so that a hook function is called whenever the user adjusts the 
position of a cursor. For details, see Cursors — Moving Cursor Calls Function on page IV-339.
Marquee Menu as Input Device
A marquee is the dashed-line rectangle that you get when you click and drag diagonally in a graph or page 
layout. It is used for expanding and shrinking the range of axes, for selecting a rectangular section of an 
image, and for specifying an area of a layout. You can use the marquee as an input device for your proce-
dures. This is a relatively advanced technique.
This menu definition adds a user-defined item to the graph marquee menu:
Menu "GraphMarquee"
"Print Marquee Coordinates", PrintMarqueeCoords()
End
To add an item to the layout marquee menu, use LayoutMarquee instead of GraphMarquee.
