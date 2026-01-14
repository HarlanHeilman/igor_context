# Marker Size as f(z)

Chapter II-13 — Graphs
II-299
Make/N=5 zWave = {1,2,3,4,5}
ModifyGraph zColor(yWave)={zWave,*,*,YellowHot}
The commands generate this graph:
If instead you create a three column wave and edit it to enter RGB values:
Make/N=(5,3) directColorWave
You can use this wave to directly control the marker colors:
ModifyGraph zColor(yWave)={directColorWave,*,*,directRGB}
Marker Size as f(z)
“Marker size as f(z)” works just like “Color as f(z)” in Color Table mode except the Z values map into the 
range of marker sizes that you define using the min and max marker settings.
This example presents a third value as a function of marker size:
Make/N=100 xData,yData,zData
xData=enoise(2); yData=enoise(2); zData=exp(-(xData^2+yData^2))
Display yData vs xData; ModifyGraph mode=3,marker=8
ModifyGraph zmrkSize(yData)={zData,*,*,1,10}
3.0
2.5
2.0
1.5
1.0
4
3
2
1
0
Row
directColorWavdirectColorWavdirectColorWav
0
1
2
0
0
0
0
1
65535
0
0
2
0
65535
0
3
0
0
65535
4
65535
0
26214
Black
Red
Green
Blue
Hot pink
3.0
2.5
2.0
1.5
1.0
4
3
2
1
0
-2
-1
0
1
-2
-1
0
1
2
