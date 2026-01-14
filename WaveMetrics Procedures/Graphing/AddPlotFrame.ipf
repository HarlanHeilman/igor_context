// This macro draws a rectangle around the plot area of a graph. It is
// provided when you are using stacked or staggered axes and also want
// a frame.
//
Macro AddPlotFrame()
	SetDrawLayer UserBack
	SetDrawEnv xcoord= prel,ycoord= prel,fillpat= 0
	DrawPoly 0,0,1,1,{0,0,0,1,1,1,1,0,0,0}
	SetDrawLayer UserFront
End
