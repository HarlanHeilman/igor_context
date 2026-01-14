# Saving Package Preferences

Chapter IV-10 — Advanced Topics
IV-251
String dfName = "Channel" + num2istr(channel)
// Channel0, Channel1, ... 
DFREF channelDFR = dfr:$dfName
if (DataFolderRefStatus(channelDFR) != 1)
// Data folder does not exist?
DFREF channelDFR = CreatePackageChannelData(channel)
// Create it
endif
return channelDFR
End
GetPackageChannelDFREF would be used like this:
Function/DF DemoPackageChannelDFREF(channel)
Variable channel
// 0 to 3
DFREF channelDFR = GetPackageChannelDFREF(channel)
// Read a package variables
NVAR gGain = channelDFR:gGain
NVAR gOffset = channelDFR:gOffset
Printf "Channel %d: Gain=%g, offset=%g\r", channel, gGain, gOffset
End
All functions that access a package channel data folder should do so through GetPackageChannelDFREF. 
The calling functions do not need to worry about whether the data folder has been created and initialized 
because GetPackageChannelDFREF does this for them.
Saving Package Preferences
If you are writing a sophisticated package of Igor procedures you may want to save preferences for your 
package. For example, if your package creates a control panel that can be opened in any experiment, you 
may want it to remember its position on screen between invocations. Or you may want to remember 
various settings in the panel from one invocation to the next.
Such “state” information can be stored either separately in each experiment or it can be stored just once for 
all experiments in preferences. These two approaches both have their place, depending on circumstances. 
But, if your package creates a control panel that is intended to be present at all times and used in any exper-
iment, then the preferences approach is usually the best fit.
If you choose the preferences approach, you will store your package preference file in a directory created for 
your package. Your package directory will be in the Packages directory, inside Igor’s own preferences directory.
The location of Igor’s Packages directory depends on the operating system and the particular user’s config-
uration. You can find where it is on a particular system by executing:
Print SpecialDirPath("Packages", 0, 0, 0)
Important:You must choose a very distinctive name for your package because that is the only thing that 
prevents some other package from overwriting yours. All package names starting with "WM" 
are reserved for WaveMetrics.
A package name is limited to 255 bytes and must be a legal name for a directory on disk.
If you use a name longer than 31 bytes, your package will require Igor Pro 8.00 or later.
There are two ways to store package preference data:
•
In a special-format binary file stored in your package directory
•
As Igor waves and variables in an Igor experiment file stored in your package directory
The special-format binary file approach is relatively simple to implement but is not suitable for storing very large 
amounts of data. In most cases it is not necessary to store very large amounts of data so this is the way to go.
