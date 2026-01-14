# Wave Properties

Chapter II-5 — Waves
II-88
When you save a packed experiment as unpacked, home waves are stored in their default disk folder in the 
experiment folder.
When you save an unpacked experiment as packed, home waves are saved in the packed experiment file.
You can use the Data Browser to determine if a wave is shared. For shared waves, the Data Browser info 
pane shows the path and file name of the wave file on disk. For home waves this information is omitted.
You can convert a shared wave to a home wave by adopting it. See Adopting Files on page II-24 for details.
Wave Properties
Here is a complete list of the properties that Igor stores for each wave.
Property
Comment
Name
Used to reference the wave from commands and dialogs.
1 to 255 bytes. Standard names start with a letter. May contain letters, 
numbers or underscores.
Prior to Igor Pro 8.00, wave names were limited to 31 bytes. If you use long 
wave names, your wave files and experiments will require Igor Pro 8.00 or 
later.
Liberal names may contain almost any character but must be enclosed in 
single quotes. See Wave Names on page II-65.
The name is assigned when you create a wave. You can use the Rename 
operation (see page V-796) to change it.
Data type
A numeric, text or reference data type. See Wave Data Types on page II-66.
Set when you create a wave.
Use the Redimension operation (see page V-788) to change it.
Length
Number of data points in the wave. Also, size of each dimension for 
multidimensional waves.
Set when you create a wave.
Use the Redimension operation (see page V-788) to change it.
X scaling (x0 and dx)
Used to compute X values from point numbers. Also Y, Z and T scaling for 
multidimensional waves.
The X value for point p is computed as X = x0 + p*dx.
Set by SetScale operation (see page V-853).
X units
Used to auto-label axes. Also Y, Z and T units for multidimensional waves.
Set by SetScale operation (see page V-853).
Data units
Used to auto-label axes.
Set by SetScale operation (see page V-853).
Data full scale
For documentation purposes only. Not used.
Set by SetScale operation (see page V-853).
Note
Holds arbitrary text related to wave.
Set by Note operation (see page V-694) or via the Data Browser.
Readable via note function (see page V-694).
Dimension labels
Holds a label up to 255 bytes in length for each dimension index and for each 
dimension. See Dimension Labels on page II-93.
Prior to Igor Pro 8.00, dimension labels were limited to 31 bytes. If you use 
long dimension labels, your wave files and experiments will require Igor Pro 
8.00 or later.

Chapter II-5 — Waves
II-89
Dependency formula
Holds right-hand expression if wave is dependent.
Set when you execute a dependency assignment using := or the SetFormula 
operation (see page V-847).
Cleared when you do an assignment using plain =.
Creation date/time
Date & time when wave was created.
Modification date/time
Date & time when wave was last modified.
Lock
Wave lock state. A locked wave can not be modified.
Set by SetWaveLock operation (see page V-858).
Source folder
Identifies folder containing wave’s source file, if any.
File name
Name of wave’s source file, if any.
Text encodings
See Wave Text Encodings on page III-472.
Property
Comment

Chapter II-5 — Waves
II-90
