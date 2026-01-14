# NewFreeAxis

NewFreeAxis
V-679
Flags
The flags define the type of data to be stored in the FIFO channel:
Wave Data Types
As a replacement for the above number type flags you can use /Y=numType to set the number type as an 
integer code. See the WaveType function for code values. Do not use /Y in combination with other type flags.
Details
You can not invoke NewFIFOChan while the named FIFO is running.
If you provide a value for vectPnts, you will create a channel capable of holding a vector of data rather than 
just a single data value. When such a channel is used in a Chart, it is displayed as an image using one of the 
built-in color tables.
Igor scales values in the FIFO channel before displaying them in a chart or transferring them to a wave as follows:
scaled_value = (FIFO_value - offset) * gain
Igor uses the plusFS and minusFS parameters (plus and minus full scale) to set the default display scaling 
for charts.
The unitsStr parameter is limited to a maximum of three bytes.
When you transfer a channel’s data to a wave, using the FIFO2Wave operation, Igor stores the plusFS and 
minusFS values and the unitsStr in the wave’s Y scaling.
See Also
FIFOs are used for data acquisition. See FIFOs and Charts on page IV-313 and the NewFIFO and 
FIFO2Wave operations for more information.
The Chart operation for displaying FIFO data.
NewFreeAxis 
NewFreeAxis[flags] axisName
The NewFreeAxis operation creates a new free axis that has no controlling wave.
Parameters
axisName is the name for the new free axis.
/B
8-bit signed integer. Unsigned if /U is present.
/C
Complex.
/D
Double precision IEEE floating point.
/I
32-bit signed integer. Unsigned if /U is present.
/S
Single precision IEEE floating point (default).
/U
Unsigned integer data.
/W
16-bit signed integer. Unsigned if /U is present.
/Y=type
Specifies wave data type. See details below.
