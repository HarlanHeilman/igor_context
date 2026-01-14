# Concatenate

ColorTab2Wave
V-82
Image Plot ColorScale Examples
Make/O/N=(20,20) img=p*q; NewImage img
// Make and display an image
ColorScale
// Create default color scale
// First annotation is text0
ColorScale/C/N=text0 nticks=3,minor=1,"Altitude"
ModifyImage img ctab= {*,*,Relief19,0}
// 19-color color table
ColorScale/C/N=text0 axisRange={100,300}
// Detail for 100-300 range
ColorScale/C/N=text0 colorBoxesFrame=1
// Frame the color boxes
ColorScale/C/N=text0 frameRGB=(65535,0,0)
// Red frame
Gizmo Plot ColorScale Example
See the online reference help for ColorScale.
See Also
For all other flags see the TextBox and AppendText operations.
Color Scales on page III-47, AnnotationInfo, AnnotationList
Demo
Choose FileExample ExperimentsFeature Demos 2ColorScale Demo
ColorTab2Wave 
ColorTab2Wave colorTableName
The ColorTab2Wave operation extracts colors from the built-in color table and places them in an Nx3 matrix of 
red, green, and blue columns named M_colors. Values are unsigned 16-bit integers and range from 0 to 65535.
N will typically be 100 but may be as little as 9 and as large as 476. Use
Variable N= DimSize(M_colors,0)
to determine the actual number of colors.
The wave M_colors is created in the current data folder. Red is in column 0, green is in column 1, and blue 
in column 2.
Parameters
colorTableName can be any of those returned by CTabList, such as Grays or Rainbow.
colorTableName can also be Igor or IgorRecent, to return either the 128 standard or 0-32 user-selected 
colors from Igor's color menu.
Details
See Image Color Tables on page II-392.
Complex
Complex localName
Declares a local complex 64-bit double-precision variable in a user-defined function or structure.
Complex is another name for Variable/C. It is available in Igor Pro 7.00 and later.
Concatenate 
Concatenate [type flags][flags] waveListStr, destWave
Concatenate [type flags][flags] {wave1, wave2, wave3,…}, destWave
Concatenate [type flags][flags] {waveWave}, destWave
The Concatenate operation combines data from the source waves into destWave, which is created if it does not 
already exist. If destWave does exists and overwrite is not specified, the source waves' data is concatenated 
with the existing data in the destination wave.
By default the concatenation increases the dimensionality of the destination wave if possible. For example, if 
you concatenate two 1D waves of the same length you get a 2D wave with two columns. The destination wave 
is said to be "promoted" to a higher dimensionality.
If you use the /NP (no promotion) flag, the dimensionality of the destination wave is not changed. For 
example, if you concatenate two 1D waves of the same length using /NP you get a 1D wave whose length is 
the sum of the lengths of the source waves.

Concatenate
V-83
If the source waves are of different lengths, no promotion is done whether /NP is used or not.
Parameters
waveListStr is a string expression containing a list of input wave names separated by semicolons with a 
semicolon at the end. There is no limit to the number of wave names in waveListStr.
The {wave1, wave2, ...} syntax is limited to 100 waves.
In the {waveWave} syntax, waveWave is a single WAVE reference wave containing references to the input 
waves. This syntax was added in Igor Pro 8.00.
Flags
Type Flags (used only in functions)
Concatenate also can use various type flags in user functions to specify the type of destination wave 
reference variables. These type flags do not need to be used except when needed to match another wave 
reference variable of the same name or to identify what kind of expression to compile for a wave 
assignment. See WAVE Reference Types on page IV-73 and WAVE Reference Type Flags on page IV-74 
for a complete list of type flags and further details.
Details
If destWave does not already exist or, if the /O flag is used, destWave is created by duplication of the first 
source wave. Waves are concatenated in order through the list of source waves. If destWave exists and the 
/O flag is not used, then the concatenation starts with destWave.
destWave cannot be used in the source wave list.
Source waves must be either all numeric or all text.
If promotion is allowed, the number of low-order dimensions that all waves share in common determines 
the dimensionality of destWave so that the dimensionality of destWave will then be one greater. The default 
behaviors will vary according to the source wave sizes. Concatenating 1D waves that are all the same length 
will produce a 2D wave, whereas concatenating 1D waves of differing lengths will produce a 1D wave. 
Similarly, concatenating 2D waves of the same size will produce a 3D wave; but if the 2D source waves have 
differing numbers of columns then destWave will be a 2D wave, or if the 2D waves have differing numbers 
of rows then destWave will be a 1D wave. Concatenating 1D and 2D waves that have the same number of 
rows will produce a 2D wave, but when the number of rows differs, destWave will be a 1D wave. See the 
examples.
Use the /NP flag to suppress dimension promotion and keep the dimensionality of destWave the same as the 
input waves.
Warning
Under some circumstances, such as in loops in user-defined functions, Concatenate may exhibit unexpected 
behavior.
When you have a statement like this in a user-defined function:
Concatenate/O ..., DestWaveName
/DL
Sets dimension labels. For promotion, it uses source wave names as new dimension 
labels otherwise it uses existing labels.
/FREE
Creates destWave as a free wave (see Free Waves on page IV-91). The /FREE flag was 
added in Igor Pro 8.00.
/KILL
Kills source waves.
/NP
Prevents promotion to higher dimension.
/NP=dim
Prevents promotion and appends data along the specified dimension (0= rows, 1= 
columns, 2=layers, 3=chunks). All dimensions other than the one specified by dim 
must be the same in all waves.
/O
Overwrites destWave.
