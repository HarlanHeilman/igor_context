# Loading Multiple Waves Using the File Name

Chapter II-9 — Importing and Exporting Data
II-143
namePrefix and nameSuffix can be empty (""), literal text like "Run1_", the special pattern ":filename:" or a 
combination of literal text and the special pattern like ":filename:_". LoadWave replaces the special pattern 
":filename:" with the name of the file being loaded minus the file name extension. If both namePrefix and 
nameSuffix are empty, LoadWave acts as if the /NAME flag were omitted.
<normal name> refers to the wave name that would be used if /NAME were omitted.
The rest of this section discusses the nameOptions bitwise parameter (see Setting Bit Parameters on page 
IV-12) which provides flexibility in naming across various scenarios. In the abstract, nameOptions may be 
confusing; examples shown in subsequent sections should clarify its meaning and use. 
If bit 0 of nameOptions is set, LoadWave includes <normal name>. If cleared, it omits <normal name>.
Bits 1, 2, and 3 control the use of suffix numbers. A suffix number is a number like 0, 1, 2, and so on, used 
to make the wave names unique. When loading a single wave, LoadWave includes <suffix number> if bit 1 
of nameOptions is set unless it is suppressed by bit 3 as explained below. When loading multiple waves, 
LoadWave includes <suffix number> if bit 2 of nameOptions is set unless it is suppressed by bit 3 as 
explained below. Often you want to include suffix numbers when loading multiple waves, because the 
numbers are necessary to distinguish the names of the waves you are loading, but you want to exclude the 
suffix number when loading a single wave. For that case you would leave bit 1 cleared and set bits 2 and 3.
Bit 3 of nameOptions overrides bits 1 and 2 to prevent prevent appending suffix numbers if they are not 
needed to prevent name conflicts. When loading a single wave, bit 3 overrides bit 1 to prevent appending 
a suffix number if there is no name conflict. When loading multiple waves, bit 3 overrides bit 2 to prevent 
appending a suffix numbers if there are no name conflicts.
If bit 4 of nameOptions is set, LoadWave chooses the suffix number, if enabled, to avoid conflicts with exist-
ing waves and other objects. If it is cleared, the suffix number, if enabled, starts from 0 and increments for 
each wave being loaded.
If bit 5 of nameOptions is cleared, LoadWave cleans up the wave name to make it a standard name. Other-
wise it allows liberal names. We recommend standard names because programming with liberal names is 
tricky. See Object Names on page III-501 for details.
Loading a Single Wave Using the File Name
In this section, we assume that we are loading a file named "Data.txt" and that we are loading a single wave 
from the file.
// nameOptions=0 means omit the normal name
/NAME={":filename:","",0}
LoadWave creates a wave named Data if it does not already exist. If it exists and you include the /O (over-
write) flag, Data is overwritten. If it exists and you omit /O, LoadWave displays a dialog in which you can 
enter a unique name.
// nameOptions=26 means include a unique suffix number
// but only if there is a name conflict
/NAME={":filename:","",26}
// 26 = 2 | 8 | 16 (bits 1, 3, and 4 set)
LoadWave creates a wave named Data if it does not already exist. If it exists LoadWave creates a wave 
named Data0, or Data1, or ... where the suffix number is chosen so that the resulting wave name is unique.
Loading Multiple Waves Using the File Name
In this section, we assume that we are loading a file named "Data.txt" and that we are loading three waves 
from the file.
// nameOptions=0 means omit the normal name
/NAME={":filename:","",0}
