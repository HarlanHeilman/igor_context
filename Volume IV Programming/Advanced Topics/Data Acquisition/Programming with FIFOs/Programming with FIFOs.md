# Programming with FIFOs

Chapter IV-10 — Advanced Topics
IV-315
out from under the chart. Eventually it will reach a position where the chart display can not be valid since 
the data it wants to display has been flushed off the end of the FIFO. When this happens the view area will 
go blank. Because it is very time-consuming for Igor to try to keep the chart updated in this situation your 
data acquisition rate may suffer. 
Chart recorder controls sometimes try to auto-configure themselves to match their FIFO. Generally this 
action is exactly what you want and is unobtrusive. Here are the rules that charts use:
When the FIFO becomes invalid or if it ceases to exist then the chart marks itself as being in auto-configure 
mode. If the FIFO then becomes valid the chart will read the FIFO information and configure itself to 
monitor all channels. It tries to set the ppStrip parameter to a value appropriate for the deltaT value of the 
FIFO. It does so by assuming a desirable update rate of around 10 strips per second. Thus, for example, if 
deltaT was 1 millisecond then ppStrip would be set to 100. The moral is: deltaT had better be valid or weird 
values of ppStrip may be created.
Any chart recorder channel configuration commands executed after the FIFO becomes invalid but before 
the FIFO becomes valid again will prevent auto-configuration from taking place.
Programming with FIFOs
You can create a FIFO by using the NewFIFO operation. When you are done using a FIFO you use the Kill-
FIFO operation. A freshly created FIFO is not useful until either channels are created with the NewFIFO-
Chan operation or until the FIFO is attached to a disk file for review using a variant of the CtrlFIFO 
operation.
You can obtain information about a FIFO using the FIFOStatus operation and you can extract data from a 
FIFO using the FIFO2Wave operation. Once a FIFO is set up and ready to accept data, you can insert data 
using the AddFIFOData operation. Alternately, you can insert data using an XOP package.
Once data is stored in a file you can review the data using a FIFO or extract data using user-defined func-
tions. See the example experiment, “FIFO File Parse”, for sample utility routines.
Here are the operations and functions used in FIFO programming:
As with background tasks, FIFOs are considered transient objects — they are not saved and restored as part 
of an experiment.
A FIFO does not need to be attached to a file to be useful. Note, however, that the oldest data is lost when 
a FIFO overflows.
A FIFO set up to acquire data does not become valid until the start command is issued. Chart controls will 
report invalid FIFOs on their status line. FIFO2Wave will give an error if it is invoked on an invalid FIFO. A 
stopped FIFO remains valid until the first command is issued that could potentially change the FIFO’s setup.
Data in a running FIFO is written to disk when Igor notices that the FIFO is half full or when the AddFIFOData 
command is issued and the FIFO is full. The amount of time it takes to write data to disk can be quite consid-
erable and at the same time unpredictable. If the computer disk cache size is large then writes to disk will be 
less frequent but when they do occur they will take a long time. This will matter to you most if you are 
attempting to take data rapidly using software, perhaps using an Igor background task.
If you are taking data via interrupt transfer to an intermediate buffer of adequate size or if your hardware has 
an adequate internal buffer then the disk write latency may not be a concern. If dead time due to disk writes 
is a concern then you may want to decrease the size of the disk cache and you may want to run with a rela-
NewFIFO
KillFIFO
NewFIFOChan
CtrlFIFO
FIFO2Wave
AddFIFOData
AddFIFOVectData
FIFOStatus
