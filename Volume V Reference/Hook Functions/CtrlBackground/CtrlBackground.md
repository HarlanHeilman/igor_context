# CtrlBackground

CTabList
V-118
Cursor A ywave,0
Print CsrXWaveRef(A)[50]
// prints value of xwave at point #50
See Also
Programming With Cursors on page II-321.
Wave Reference Functions on page IV-197.
CTabList 
CTabList()
The CTabList function returns a semicolon-separated list of the names of built-in color tables. It is useful for 
creating pop-up menus in control panels.
Color tables available through Igor Pro 4:
Additional color tables added for Igor Pro 5:
Additional color tables added for Igor Pro 6:
Additional color tables added for Igor Pro 6.2:
Additional color tables added for Igor Pro 9:
See Also
Image Color Tables on page II-392, Color Table Waves on page II-399, ColorTab2Wave
CtrlBackground 
CtrlBackground [key [= value]]…
The CtrlBackground operation controls the unnamed background task.
CtrlBackground works only with the unnamed background task. New code should used named background 
tasks instead. See Background Tasks on page IV-319 for details.
Parameters
Grays
Rainbow
YellowHot
BlueHot
BlueRedGreen
RedWhiteBlue
PlanetEarth
Terrain
Grays256
Rainbow256
YellowHot256
BlueHot256
BlueRedGreen256
RedWhiteBlue256
PlanetEarth256
Terrain256
Grays16
Rainbow16
Red
Green
Blue
Cyan
Magenta
Yellow
Copper
Gold
CyanMagenta
RedWhiteGreen
BlueBlackRed
Geo
Geo32
LandAndSea
LandAndSea8
Relief
Relief19
PastelsMap
PastelsMap20
Bathymetry9
BlackBody
Spectrum
SpectrumBlack
Cycles
Fiddle
Pastels
RainbowCycle
Rainbow4Cycles
GreenMagenta16
dBZ14
dBZ21
Web216
BlueGreenOrange
BrownViolet
ColdWarm
Mocha
VioletOrangeYellow
SeaLandAndFire
Mud
Classification
Turbo
dialogsOK=1 or 0
If 1, your task will be allowed to run while an Igor dialog is present. This can 
potentially cause crashes unless your task is well-behaved.
noBurst=1 or 0
Normally (or noBurst=0), your task will be called at maximum rate if a delay causes 
normal run times to be missed. Using noBurst=1, will suppress this burst catch up 
mode.
