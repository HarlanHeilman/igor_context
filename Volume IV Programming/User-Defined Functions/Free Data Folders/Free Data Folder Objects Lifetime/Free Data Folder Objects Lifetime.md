# Free Data Folder Objects Lifetime

Chapter IV-3 — User-Defined Functions
IV-98
. . .
End
// The free data folder is deleted because dfr no longer exists.
The fourth case, where a data folder reference is stored in a data folder reference wave, is discussed under 
Data Folder Reference Waves on page IV-82.
In the next example, the free data folder is referenced by Igor's internal current data folder reference vari-
able because it is the current data folder. When the current data folder is changed, there are no more refer-
ences to the free data folder and it is automatically deleted:
Function Test4()
SetDataFolder NewFreeDataFolder()
// Create new free data folder. 
// The free data folder persists because it is the current data folder
// and therefore is referenced by Igor's internal
// current data folder reference variable.
. . .
// Change Igor's internal current data folder reference
SetDataFolder root:
// The free data folder is deleted since there are no references to it.
End
Free Data Folder Objects Lifetime
Next we consider what happens to objects in a free data folder when the free data folder is deleted. In this 
event, numeric and string variables in the free data folder are unconditionally automatically deleted. A 
wave is automatically deleted if there are no wave references to it. If there is a wave reference to it, the wave 
survives and becomes a free wave. Free waves are waves that exists outside of any data folder as explained 
under Free Waves on page IV-91. 
For example:
Function Test()
SetDataFolder NewFreeDataFolder()
// Create new free data folder. 
// The free data folder exists because it is the current data folder.
Make jack
// Make a wave and an automatic wave reference
. . .
SetDataFolder root:
// The free data folder is deleted since there are no references to it.
// Because there is a reference to the wave jack, it persists
// and becomes a free wave.
. . .
End
// The wave reference to jack ceases to exist so jack is deleted
When this function ends, the reference to the wave jack ceases to exist, there are no references to jack, and 
it is automatically deleted.
Next we look at a slight variation. In the following example, Make does not create an automatic wave ref-
erence because of the use of $, and we do not create an explicit wave reference:
Function Test()
SetDataFolder NewFreeDataFolder()
// Create new free data folder. 
// The free data folder exists because it is the current data folder.
Make $"jack"
// Make a wave but no wave reference
// jack persists because the current data folder references it.
