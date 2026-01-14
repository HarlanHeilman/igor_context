# ImageInfo

ImageInfo
V-380
Details
The ImageHistogram operation works on images, but it handles both 2D and 3D waves of any data type. 
Unless you use one of the special features of this operation (e.g., ROI or /P or /I) you could alternatively use 
the Histogram operation, which computes the histogram for the full wave and includes additional options 
for controlling the number of bins.
If the data type of imageMatrix is single byte, the histogram will have 256 bins from 0 to 255. Otherwise, the 
256 bins will be distributed between the minimum and maximum values encountered in the data. Use the 
/I flag to increase the number of bins to 65536, which may be useful for unsigned short (/W/U) data.
See Also
ImageHistModification, ImageGenerateROIMask, JointHistogram, Histograms on page III-372
ImageInfo 
ImageInfo(graphNameStr, imageWaveNameStr, instanceNumber)
The ImageInfo function returns a string containing a semicolon-separated list of information about the 
specified image in the named graph window or subwindow.
Parameters
graphNameStr can be "" to refer to the top graph.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
imageWaveNameStr contains either the name of a wave displayed as an image in the named graph, or an 
image instance name (wave name with “#n” appended to distinguish the nth image of the wave in the 
graph). You might get an image instance name from the ImageNameList function.
If imageWaveNameStr contains a wave name, instanceNumber identifies which instance you want information 
about. instanceNumber is usually 0 because there is normally only one instance of a wave displayed as an 
image in a graph. Set instanceNumber to 1 for information about the second image of the wave, etc. If 
imageWaveNameStr is "", then information is returned on the instanceNumberth image in the graph.
If imageWaveNameStr contains an instance name, and instanceNumber is zero, the instance is taken from 
imageWaveNameStr. If instanceNumber is greater than zero, the wave name is extracted from 
imageWaveNameStr, and information is returned concerning the instanceNumberth instance of the wave.
/R=roiWave
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/b/u) that has the same number of rows and columns as imageMatrix. The ROI 
itself is defined by the entries o pixels in the roiWave with value of 0. Pixels outside the 
ROI may have any nonzero value. The ROI does not have to be contiguous. When 
imageMatrix is a 3D wave, roiWave can be either a 2D wave (matching the number of 
rows and columns in imageMatrix) or it can be a 3D wave that must have the same 
number of rows, columns and layers as imageMatrix. When using a 2D roiWave with a 
3D imageMatrix the ROI is understood to be defined by roiWave for each layer in the 
3D wave.
See ImageGenerateROIMask for more information on creating 2D ROI waves.
/S
Computes the histogram for a whole 3D wave possibly subject to 2D or 3D ROI 
masking. The /S and /P flags are mutually exclusive.

ImageInfo
V-381
Details
The string contains several groups of information. Each group is prefaced by a keyword and colon, and 
terminated with the semicolon for ease of use with StringByKey. The keywords are as follows: 
The format of the RECREATION information is designed so that you can extract a keyword command from 
the keyword and colon up to the “;”, prepend “ModifyImage ”, replace the “x” with the name of a image 
plot (“data#1” for instance) and then Execute the resultant string as a command.
Example 1
This example gets the image information for the second image plot of the wave "jack" (which has an instance 
number of 1) and applies its ModifyImage settings to the first image plot.
#include <Graph Utility Procs>, version>=6.1
// For WMGetRECREATIONFromInfo
// Make two image plots of the same data on different left and right axes
Make/O/N=(20,20) jack=sin(x/5)+cos(y/4)
Display;AppendImage jack
// bottom and left axes
AppendImage/R jack
// bottom and right axes
// Put image plot jack#0 above jack#1
ModifyGraph axisEnab(left)={0.5,1},axisEnab(right)={0,0.5}
// Set jack#1 to use the Rainbow color table instead of the default Grays
ModifyImage jack#1 ctab={*,*,Rainbow,0}
Keyword
Information Following Keyword
AXISFLAGS
Flags used to specify the axes. Usually blank because /L and /B (left and bottom axes) 
are the defaults.
COLORMODE
RECREATION
Semicolon-separated list of keyword=modifyParameters commands for the 
ModifyImage command.
XAXIS
X axis name.
XWAVE
X wave name if any, else blank.
XWAVEDF
The full path to the data folder containing the X wave or blank if there is no X wave.
YAXIS
Y axis name.
YWAVE
Y wave name if any, else blank.
YWAVEDF
The full path to the data folder containing the Y wave or blank if there is no Y wave.
ZWAVE
Name of wave containing Z data used to calculate the image plot.
ZWAVEDF
The full path to the data folder containing the Z data wave.
A number indicating how the image colors are derived:
1:
Color table (see Image Color Tables on page II-392).
2:
Scaled color index wave (see Indexed Color Details on page II-400).
3:
Point-scaled color index (See Example: Point-Scaled Color Index Wave 
on page II-401).
4:
Direct color (see Direct Color Details on page II-401).
5:
Explicit Mode (see ModifyImage explicit keyword).
6:
Color table wave (see Color Table Waves on page II-399).
