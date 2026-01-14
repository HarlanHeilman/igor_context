# “Fake” Axes

Chapter II-13 — Graphs
II-317
// Set its scaling so X values are dates
Variable t0, t1
t0 = Date2Secs(2000,1,1); t1 = Date2Secs(2001,1,1)
SetScale x t0, t1, "dat", temperature
// double-precision X scaling
// Enter the temperature data in the wave's Y values
t0 = Date2Secs(2000,1,1); t1 = Date2Secs(2000,3,31) 
// winter
temperature(t0, t1) = 32
// it's cold
t0 = Date2Secs(2000,4,1); t1 = Date2Secs(2000,6,30) 
// spring
temperature(t0, t1) = 65
// it's nice
t0 = Date2Secs(2000,7,1); t1 = Date2Secs(2000,9,31)
// summer
temperature(t0, t1) = 85
// it's hot
t0 = Date2Secs(2000,10,1); t1 = Date2Secs(2000,12,31) // fall
temperature(t0, t1) = 45
// cold again
// Smooth the data out
CurveFit sin temperature
temperature= K0+K1*sin(K2*x+K3)
// Graph the wave
Display temperature
SetAxis left, 0, 100;Label left "temp"
Label bottom "2000"
The SetScale operation sets the temperature wave so that its X values span the year 2000. In this example, 
the date/time information is in the X values of the wave. X values are always double precision. The wave 
itself is not declared double precision because we are storing temperature information, not date/time infor-
mation in the Y values.
Manual Ticks for Date/Time Axes
Just as with regular axes, there are times when Igor’s automatic choices of ticks for date/time axes simply 
are not what you want. For these cases, you can use computed manual ticks with date/time axes.
To use computed manual ticks, display the Modify Axis dialog by double-clicking the axis, or by choosing 
GraphModify Axis. Select the Auto/Man Ticks tab, and choose Computed Manual Ticks from the menu 
in that tab.
The first step is to click the Set to Auto Values button. Choose Date, Time, or Date&Time from the pop-up 
menu below the Canonic Tick setting. This will depend on the range of the data. Choose the units for the 
Tick Increment setting and enter an increment value.
“Fake” Axes
It is sometimes necessary to create an axis that is not related to the data in a simple way. One method uses free 
axes that are not associated with a wave (see NewFreeAxis). The Transform Axis package uses this technique to 
make a mirror axis reflecting a different view of the data. An example would be a mirror axis showing wave 
number to go with a main axis showing wavelength. For an example, choose FileExample Experi-
mentsGraphing TechniquesTransform Axis Demo.
100
80
60
40
20
0
temp
1/1/2000
3/1/2000
5/1/2000
7/1/2000
9/1/2000
11/1/2000
2000
