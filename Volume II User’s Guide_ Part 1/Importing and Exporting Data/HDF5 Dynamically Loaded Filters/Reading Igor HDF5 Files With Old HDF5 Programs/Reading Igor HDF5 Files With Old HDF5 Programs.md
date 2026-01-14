# Reading Igor HDF5 Files With Old HDF5 Programs

Chapter II-10 — Igor HDF5 Guide
II-222
This issue does not affect Macintosh because both Igor7 or later and the HDF5 library use UTF-8 on Macin-
tosh.
Igor Compatibility With HDF5
This section discusses issues relating to various HDF5 library versions.
You don't need to know this information unless you are using very old software based on HDF5 library ver-
sions earlier than 1.8.0.
The following table lists various Igor and HDF5 versions:
HDF5 Compatibility Terminology
For the purposes of this discussion, the term "old HDF5 version" means a version of the HDF5 library earlier 
than 1.8.0. The term "old HDF5 program" means a program that uses an old HDF5 version. The term "old 
HDF5 file" means an HDF5 file written by an old HDF5 program.
Reading Igor HDF5 Files With Old HDF5 Programs
By default, Igor Pro 9 and later create HDF5 files that work with programs compiled with HDF5 library 
version 1.8.0 or later. HDF5 1.8.0 was released in February of 2008. For most uses, this default compatibility 
will work fine.
The rest of this section is of interest only if you need to read Igor HDF5 files using very old HDF5 programs 
which use HDF5 library versions earlier than 1.8.0.
As explained at https://support.hdfgroup.org/HDF5/faq/bkfwd-compat.html#162unable, software com-
piled with HDF5 1.6.2 (released on 2004-02-12) or before is incompatible with HDF5 files produced by 
HDF5 1.8.0 or later.
If you need to read files written by Igor Pro 9 and later using software that uses HDF5 1.6.3 (released on 
2004-09-22) through 1.6.10 (released on 2009-11-10), you need to tell Igor to use compatible HDF5 formats. 
You do this by executing this command:
SetIgorOption HDF5LibVerLowBound=0
When you do this, you lose these features:
•
The ability to save attributes larger than 65,535 bytes ("large attributes")
You will get an error in the unlikely event that you attempt to write a large attribute to a group or 
dataset.
This includes saving a wave with a very large wave note or with a very large number of dimension 
labels via HDF5SaveData or HDF5SaveGroup or by saving an HDF5 packed experiment file. It also 
includes adding a large attribute using HDF5SaveData/A.
•
The ability to sort groups and datasets by creation order 
This feature is provided by the HDF5 browser but is supported only for files in which it is enabled 
when the file is created.
•
The ability to write attributes so that they can be read in creation order
Igor Version
HDF5 Library Version
Igor Pro 6.03
1.6.3 (released on 2004-09-22)
Igor Pro 6.10 to 6.37
1.8.2 (released on 2008-11-10)
Igor Pro 7.00 to 7.08
1.8.15 (released on 2015-05-04)
Igor Pro 8.00 to 8.04
1.10.1 (released on 2017-04-27)
Igor Pro 9.00 to 9.0x
1.10.7 (released on 2020-09-15)
