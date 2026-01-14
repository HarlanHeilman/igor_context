# Data Acquisition

Chapter IV-10 — Advanced Topics
IV-312
You can adjust the time by setting the WMTooltipHookStruct duration_ms field. When your function is 
called, that field is set to -1, which selects the default duration. To get an effectively permanent tooltip, set 
duration_ms to a large number in units of milliseconds. For example, setting duration_ms to 600000 causes 
the tooltip to be displayed for ten minutes.
Regardless of the duration, Igor hides the tooltip if you click the mouse or move it out of the tracking rect-
angle.
Data Acquisition
Igor Pro provides a number of facilities to allow working with live data:
•
Live mode traces in graphs
•
FIFOs and Charts
•
Background task
•
External operations and external functions
•
Controls and control panels
•
User-defined functions
Live mode traces in graphs are useful when you acquiring complete waveforms in a single short operation 
and you want to update a graph many times per second to create an oscilloscope type display. See Live 
Graphs and Oscilloscope Displays on page II-347 for details.
FIFOs and Charts are used when you have a continuous stream of data that you want to capture and, per-
haps, monitor. See FIFOs and Charts on page IV-313 details.
You can set up a background task that periodically performs data acquisition while allowing you to con-
tinue to work with Igor in the foreground. The background operations are not done using interrupts and 
therefore are easily disrupted by foreground operations. Background tasks are useful only for relatively 
infrequent tasks that can be quickly accomplished and do not cause a cascade of graph updates or other 
things that take a long time. See Background Tasks on page IV-319 for details.
You can create an instrument-like front panel for your data acquisition setup using user-defined controls in 
a panel window. Refer to Chapter III-14, Controls and Control Panels, for details. There are many example 
experiments that can be found in the Examples folder.
Igor Pro comes with an XOP named VDT2 for communicating with instruments via serial port (RS232), 
another XOP named NIGPIB2 for communicating via General Purpose Interface Bus (GPIB), and another 
XOP named VISA for communicating with VISA-compatible instruments. See the Igor Pro Folder:More 
Extensions:Data Acquisition folder.
Sound I/O can be done using the built-in SoundInRecord and PlaySound operations.
The NewCamera, GetCamera and ModifyCamera operations support frame grabbing.
WaveMetrics produces the NIDAQ Tools software package for doing data acquisition using National 
Instruments cards. NIDAQ Tools is built on top of Igor using all of the techniques mentioned in this section. 
Information about NIDAQ Tools is available via the WaveMetrics Web site <http://www.wavemet-
rics.com/Products/NIDAQTools/nidaqtools.htm>.
Third parties have created data acquisition packages that use other hardware. Information about these is 
also available at <http://www.wavemetrics.com/Products/thirdparty/thirdparty.htm>.
If an XOP package is not available for your hardware you can write your own. For this, you will need to pur-
chase the XOP Toolkit product from WaveMetrics. See Creating Igor Extensions on page IV-208 for details.
