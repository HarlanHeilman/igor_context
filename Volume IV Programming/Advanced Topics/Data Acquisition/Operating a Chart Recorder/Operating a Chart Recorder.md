# Operating a Chart Recorder

Chapter IV-10 — Advanced Topics
IV-317
Another way to use a FIFO and chart control to review a raw binary file is to use the rdfile keyword with 
the CtrlFIFO command.
FIFO and Chart Demos
Igor Pro Folder:Examples:Feature Demos:FIFO Chart Demo FM.pxp
Igor Pro Folder:Examples:Feature Demos:FIFO Chart Overhead.pxp
Igor Pro Folder:Examples:Feature Demos:Wave Review Chart Demo.pxp
Igor Pro Folder:Examples:Imaging:Image Strip FIFO Demo.pxp
Using Chart Recorder Controls
The information provided here pertains to using rather than programming a chart recorder control. For 
information on programming chart controls, see FIFOs and Charts on page IV-313.
An Igor chart recorder control works in conjunction with a FIFO to display data as it is acquired or to review 
data that has previously been acquired.
Chart Reorder Control Basics
An Igor chart recorder control is neither an analytical tool nor a presentation quality graphic. It is meant 
only for real time monitoring of incoming data or to review data from a FIFO file. When you want an ana-
lytical or presentation quality graph you must transfer the data to a wave and then use a conventional Igor 
graph.
An Igor chart recorder control emulates a mechanical chart recorder that writes on paper with moving pens 
as the paper scrolls by under the pens. It differs from a real chart recorder in that the paper of the latter 
moves at a constant velocity whereas the “paper” of an Igor chart moves only when data becomes available 
in the FIFO it is monitoring. If data is placed in the FIFO at a constant rate then the “paper” will scroll by at 
a constant rate. However, since there can be no guarantee that the data is coming in at a constant rate, we 
refer to the horizontal axis not in terms of time but rather in terms of data sample number.
A given chart recorder control can monitor an arbitrary selection of channels from a single FIFO. Each chart 
trace can have its own display gain, color and line style and can either have its own area on the “paper” or 
can share an area with one or more other traces. There can be multiple charts active an one time in one or 
more control panel or graph windows.
Operating a Chart Recorder
Here is a typical chart recorder while taking data:
And here is the same chart recorder while reviewing data even though data acquisition is still taking place:

Chapter IV-10 — Advanced Topics
IV-318
And here we are while reviewing data from the file after data acquisition is complete:
Notice the positioning strip just under the chart and above the status line. It consists of a horizontal line and 
a horizontal, gray bar. The line, called the positioning line, represents the extent of available data. The bar, 
called the positioning bar, represents the currently displayed region of this data.
While data acquisition is in progress, the available data is the data in the FIFO's memory. After the acqui-
sition is over then the available data includes all of the data in the FIFO's output file, if any. The vertical bars 
at the ends of the positioning line indicate we are reviewing from a file.
You can instantly jump to any portion of the data by clicking on the positioning line. The spot that you click 
on indicates the part of the available data that you want to view. After clicking you can drag the "paper" 
region around.
The chart recorder will be in one of two modes: live mode or review mode. While data acquisition is under 
way, the chart recorder will display incoming data if it is in live mode. If it is in review mode, you can 
review previously acquired data.
Clicking on the positioning line or in the positioning bar puts the chart recorder into review mode even if 
data acquisition is taking place. To exit review mode and go into live mode, simply click anywhere in the 
chart recorder outside of the "paper" and the positioning strip. Of course, if you are not acquiring data you 
can not go into live mode.
Another way to go into review mode and navigate is to grab the "paper" with the mouse and fling it to the 
left or right. It will keep going until it hits the end of available data. The speed at which the "paper" moves 
depends on how hard you fling it.
If you are in review mode while data acquisition is taking place, you will notice that the positioning bar 
indicates the view area is moving even though the "paper" appears to be motionless. This is because the 
FIFO is moving out from under the chart. Eventually it will reach a position where the chart display can not 
be valid since the data it wants to display has been flushed off the end of the FIFO. When this happens the 
paper will go blank. Because it is very time consuming for Igor to try to keep the chart updated in this sit-
uation, your data acquisition rate may suffer. To get an idea of what kind of data rates can be sustained 
using an Igor background task, spend some time experimenting with the "FIFO/Chart Overhead" example 
experiment.
