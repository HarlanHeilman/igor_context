# NewFIFOChan

NewCamera
V-678
See Also
The NeuralNetworkRun operation.
NewCamera 
NewCamera [flags] [keywords]
The NewCamera operation creates a new camera window.
Documentation for the NewCamera operation is available in the Igor online help files only. In Igor, execute:
DisplayHelpTopic "NewCamera"
NewDataFolder 
NewDataFolder [/O/S] dataFolderSpec
The NewDataFolder operation creates a new data folder of the given name.
Parameters
dataFolderSpec can be just a data folder name, a partial path (relative to the current data folder) with name 
or a full path (starting from root) with name. If just a data folder name is used then the new data folder is 
created in the current data folder. If a full or partial path is used, all data folders except for the last in the 
path must already exist.
Flags
Examples
NewDataFolder foo
// Creates foo in the current data folder
NewDataFolder :bar:foo
// Creates foo in bar in current data folder
NewDataFolder root:foo
// Creates foo in the root data folder
See Also
Chapter II-8, Data Folders.
NewFIFO 
NewFIFO FIFOName
The NewFIFO operation creates a new FIFO.
Details
Useless until channel info is added with NewFIFOChan.
An error is generated if a FIFO of same name already exists. FIFOName needs to be unique only among 
FIFOs. You can not overwrite a FIFO.
See Also
FIFOs are used for data acquisition. See FIFOs and Charts on page IV-313 and the NewFIFOChan 
operation for more information.
NewFIFOChan 
NewFIFOChan [flags] FIFOName, channelName, offset, gain, minusFS, plusFS, 
unitsStr [, vectPnts]
The NewFIFOChan operation creates a new channel for the named FIFO.
Parameters
channelName must be unique for the specified FIFO.
The offset, gain, plusFS, minusFS and unitsStr parameters are used when the channel’s data is displayed in a 
chart or transferred to a wave. If given, vectPnts must be between 1 and 65535.
/O
No error if a data folder of the same name already exists.
/S
Sets the current data folder to dataFolderSpec after creating the data folder.
