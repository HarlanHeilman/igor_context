# Miscellaneous Settings

Chapter III-17 — Miscellany
III-500
SetDrawEnv
If you specify a gradient it overrides the fill for drawing elements.
If you omit the color0 parameter or specify (0,0,0,0) then the current pattern background color is used.
If you omit the color1 parameter or specify (0,0,0,0) then the current foreground color is used.
All gradientExtra keywords must be on the same line as the gradient keyword itself.
ModifyLayout
You can specify gradients for individual pages by combining the gradient and gradientExtra keywords with 
the /PAGE=pageNum flag.
Page numbers start from 1. Use /PAGE=0 to use the currently active page.
/PAGE=-1 causes the operation to modify the layout global gradient which applies to any pages in the targeted 
page layout for which no explicit gradient has been set.
ModifyGraph (traces)
If you specify a gradient it overrides the fill for traces.
The gradient and gradientExtra keywords apply to all traces unless you specify a trace name like this:
gradient(<trace name>) = {...}
gradientExtra(<trace name>) = {...}
If you omit the color0 parameter or specify (0,0,0,0) then the current pattern background color is used.
If you omit the color1 parameter or specify (0,0,0,0) then the plusRGB color is used.
When the type parameter specifies a window rect, the plus and neg areas are used automatically and the color1 
is away from the zero level.
ModifyGraph (colors)
The wbGradient and wbGradientExtra keywords control the window background gradient, if any.
The gbGradient and gbGradientExtra keywords control the graph plot area background gradient, if any.
The "Demo Experiment #1" and "Demo Experiment #2" example experiments demonstrate these gradients. 
You can turn the on and off using the Macros menu.
Miscellaneous Settings
You can customize many aspects of how Igor works using the Miscellaneous Settings dialog. Choose 
MiscMiscellaneous Settings to display the dialog.
Most of the settings are self-explanatory. Many have tooltips that describe what they do.
