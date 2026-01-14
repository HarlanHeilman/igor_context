# Chart Recorder Overview

Chapter IV-10 — Advanced Topics
IV-313
FIFOs and Charts
This section will be of interest principally to programmers writing data acquisition packages.
Most people who use FIFOs and chart recorder controls will do so via packages provided by expert Igor 
programmers. For information on using, as opposed to programming, chart controls, see Using Chart 
Recorder Controls on page IV-317.
FIFO Overview
A FIFO is an invisible data objects that can act as a First-In-First-Out buffer between a data source and a 
disk file. Data is placed in a FIFO either via the AddFIFOData operation or via an XOP package designed 
to interface to a particular piece of hardware. Chart recorder controls provide a graphical view of a portion 
of the data in a FIFO. When data acquisition is complete a FIFO can operate as a bidirectional buffer to a 
disk file. This allows the user to review the contents of a file by scrolling the chart “paper” back and forth. 
FIFOs can be used without a chart but charts have no use without a FIFO to monitor.
A FIFO can have an arbitrary number of channels each with its own number type, scaling, and units. All 
channels of a given FIFO share a common “timebase”.
Chart Recorder Overview
Chart recorder controls can be used to emulate a mechanical chart recorder that writes on paper with 
moving pens as the paper scrolls by under the pens. Charts can be used to monitor data acquisition pro-
cesses or to examine a long data record. Although programming a chart is quite involved, using a chart is 
very easy.
Here is a typical chart recorder control:
The First-In-First-Out (FIFO) buffer is an invisible Igor component that buffers the data coming from data 
acquisition hardware and software and also writes the data to a file. The data that is streaming through the 
FIFO can be observed using a chart recorder control. When data acquisition is finished the process can be 
reversed with data coming back out of the file and into the FIFO where it can be reviewed using the chart. 
The FIFO file is optional but if missing then all data pushed out the end of the FIFO is lost.
Data 
Acquisition
FIFO buffer
FIFO 
Data 
File

Chapter IV-10 — Advanced Topics
IV-314
Chart recorder controls can take on quite a number of forms from the simple to the sophisticated:
A given chart recorder control can monitor an arbitrary selection of channels from a single FIFO. Each trace 
can have its own display gain, color and line style and can either have its own area on the “paper” or can 
share an area with one or more other traces. There can be multiple chart recorder controls active an one time 
in one or more panel or graph windows.
Chart recorders can display an image strip when hooked up to a FIFO channel defined using the optional 
vectPnts parameter to NewFIFOChan. An example experiment, Image Strip FIFO Demo, is provided to 
illustrate how to use this feature.
Chart recorders can operate in two modes — live and review. When a chart is in live mode and data acqui-
sition is in progress, the chart "paper" scrolls by from right to left under the influence of the acquisition pro-
cess. When in review mode, you are in control of the chart. When you position the mouse over the chart 
area you will see that the cursor turns into a hand. You can move the chart paper right or left by dragging 
with the hand. If you give the paper a push it will continue scrolling until it hits the end.
You can place the chart in review mode even as data acquisition is in progress by clicking in the paper with 
the hand cursor. To go back to live mode, give the paper a hard push to the left. When the paper hits the 
end then the chart will go to into live mode. You can also go back to live mode by clicking anywhere in the 
margins of the chart.
Depending on the exact details of the data acquisition hardware and software you may run the risk of cor-
rupting the data if you use review mode while acquisition is in progress. The person that created the hard-
ware and software system you are using should have provided guidelines for the use of review mode 
during acquisition. In general, if the acquisition process is paced by hardware then it should be OK to use 
review mode.
In the chart recorder graphics above, you may have noticed the line directly under the scrolling paper area. 
This line represents the current extent of data while the gray bar represents the data that is being shown in 
the chart. The right edge of the gray bar represents the right edge of the section of data being shown in the 
chart window. The above example is shown in live mode. Here are two examples shown in review mode:
While data acquisition is in progress, the horizontal line represents the extent of the data in the FIFO's 
memory. After acquisition is over then the line includes all of the data in the FIFO's output file, if any.
If you are in review mode while data acquisition is taking place, you will notice that the gray bar indicates 
the view area is moving even though the paper appears to be motionless. This is because the FIFO is moving 
Review of live data
Use hand to move or ﬂing “paper”
Click to position right edge of “paper”
End caps indicate ﬁle review
Review of data from a ﬁle
