# LoadPackagePreferences

LoadPackagePreferences
V-505
// Load root:DataFolder0B and all objects in it using /GREP
LoadData/P=Data/Q/R/L=7/GREP={"(?i)^root:DataFolder0B:$",3,8,0} "Packed.pxp"
// Load all objects whose path contains "DataFolder" and whose name ends with "1"
LoadData/P=Data/Q/R/L=7/GREP={"(?i)DataFolder",2,7,0}/GREP={"(?i).*1$",1,7,0} "Packed.pxp"
// Load all objects in root:DataFolder0B and whose name ends with "0"
LoadData/P=Data/Q/R/L=7/GREP={"(?i)root:DataFolder0B:.*0$",3,7,0} "Packed.pxp"
See Also
SaveData, Importing Data on page II-126, The Data Browser on page II-114, Regular Expressions on page 
IV-176. 
LoadPackagePreferences 
LoadPackagePreferences [/MIS=mismatch /P=pathName] packageName, prefsFileName, 
recordID, prefsStruct
The LoadPackagePreferences operation loads preference data previously stored on disk by the 
SavePackagePreferences operation. The data is loaded into the specified structure.
The structure can use fields of type char, uchar, int16, uint16, int32, uint32, int64, uint64, float and double 
as well as fixed-size arrays of these types and substructures with fields of these types.
If the /P flag is present then the location on disk of the preference file is determined by pathName and 
prefsFileName. However in the usual case the /P flag will be omitted and the preference file is located in a file 
named prefsFileName in a directory named packageName in the Packages directory in Igor’s preferences directory.
See Saving Package Preferences on page IV-251 for background information and examples.
Parameters
packageName is the name of your package of Igor procedures. It is limited to 255 bytes and must be a legal 
name for a directory on disk. This name must be very distinctive as this is the only thing preventing 
collisions between your package and someone else’s package. If you use a name longer than 31 bytes, your 
package will require Igor Pro 8.00 or later.
prefsFileName is the name of a preference file to be loaded by LoadPackagePreferences. It should include an 
extension, typically ".bin".
prefsStruct is the structure into which data from disk, if it exists, will be loaded.
recordID is a unique positive integer that you assign to each record that you store in the preferences file. If 
you store more than one structure in the file, you would use distinct recordIDs to identify which structure 
you want to load. In the simple case you will store just one structure in the preference file and you can use 
0 (or any positive integer of your choice) as the recordID.
Flags
Note:
The package preferences structure must not use fields of type Variable, String, WAVE, 
NVAR, SVAR or FUNCREF because these fields refer to data that may not exist when 
LoadPackagePreferences is called.
Note:
You must choose a very distinctive name for packageName as this is the only thing 
preventing collisions between your package and someone else’s package. If you use a 
name longer than 31 bytes, your package will require Igor Pro 8.00 or later.
/MIS=mismatch
Controls what happens if the number of bytes in the file does not match the size of 
the structure:
0:
Returns an error. Default behavior if /MIS is omitted.
1:
Returns the smaller of the size of the structure and the number of 
bytes in the file. Does not return an error. Use this if you want to 
read and update old versions of a preferences structure.
