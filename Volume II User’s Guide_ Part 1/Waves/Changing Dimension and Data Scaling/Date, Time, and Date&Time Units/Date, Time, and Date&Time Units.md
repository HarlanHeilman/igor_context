# Date, Time, and Date&Time Units

Chapter II-5 — Waves
II-69
Igor uses the dimension and data Units to automatically label axes in graphs. Igor can handle units consisting 
of 49 bytes or less. Typically, units should be short, standard abbreviations such as “m”, “s”, or “g”. If your 
data has more complex units, you can enter the complex units or you may prefer to leave the units blank.
Advanced Dimension and Data Scaling
If you click More Options, Igor displays some additional items in the dialog. They give you two additional 
ways to specify X scaling and allow you to set the wave’s “data full scale” values. These options are usually 
not needed but for completeness are described in this section.
In spite of the fact that there is only one way of calculating X values, there are three ways you can specify 
the x0 and dx values. The SetScale Mode pop-up menu changes the meaning of the scaling entries above. 
The simplest way is to simply specify x0 and dx directly. This is the Start and Delta mode in the dialog and 
is the only way of setting the scaling unless you click the More Options button. As an example, if you have 
data that was acquired by a digitizer that was set to sample at 1 MHz starting 150 µs after t=0, you would 
enter 150E-6 for Start and 1E-6 for Delta.
The other two ways of specifying X scaling are to set the starting and ending X values are and to calculate 
dx from the number of points. In the Start and End mode you specify the X value of the last data point. 
Using the Start and Right mode you specify the X at the end of the last interval. For example, assuming our 
digitizer (above) created a 100 point wave, we would enter 150E-6 as Start for either mode. If we selected 
the Start and End mode we would enter 249E-6 for End (150E-6 + 99*1E-6). If we selected Start and Right 
we would enter 250E-6 for Right.
The min and max entries allow you to set a property of a wave called its “data full scale”. This property 
doesn’t serve a critical purpose. Igor does not use it for any computation or graphing purposes. It is merely 
a way for you to document the conditions under which the wave data was acquired. For example, if your 
data comes from a digital oscilloscope and was acquired on the ±10v range, you could enter -10 for min and 
+10 for max. When you make waves, both of these will initially be set to zero. If your data has a meaningful 
data full scale, you can set them appropriately. Otherwise, leave them zero.
The data units, on the other hand are used for graphing purposes, just like the dimension units.
Date, Time, and Date&Time Units
The units “dat” are special, specifying that the scaled dimension indices or data values of a wave contain 
date, time, or date&time information.
If you have waveform data then set the X units of your waveform to "dat".
If you have XY data then set the data units of your X wave to "dat". In this case your X wave must be double-
precision floating point in order to have enough precision to represent dates accurately.
For example, if you have a waveform that contains some quantity measured once per day, you would set 
the X units for the wave to “dat”, set the starting X value to the date on which the first measurement was 
done, and set the Delta X value to one day. Choosing Date from the Units Type pop-up menu sets the X 
units to “dat”. You can enter the starting value as a date rather than as a number of seconds since 1/1/1904, 
which is how Igor represents dates internally. When Igor graphs the waveform, it will notice that the X units 
are “dat” and will display dates on the X axis.
If instead of a waveform, you have an XY pair, you would set the data units of the X wave to “dat”, by 
choosing Date from the Units Type pop-up menu in the Set Data Properties section of the dialog. When you 
graph the XY pair, Igor will notice that the X wave contains dates and will display dates on the X axis.
The Units Type pop-up menus do not correspond directly to any property of a wave. That is, a wave doesn’t 
have a units type property. Instead, these menus merely identify what kind of values you are dealing with 
so that the dialog can display the values in the appropriate format.
For further discussion of how Igor represents dates, see Date/Time Waves on page II-85.
For information on dates and times in tables, see Date/Time Formats on page II-256.
