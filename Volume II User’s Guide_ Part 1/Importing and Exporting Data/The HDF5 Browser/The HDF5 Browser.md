# The HDF5 Browser

Chapter II-10 — Igor HDF5 Guide
II-193
17.
Choose FileSave Experiment and save the current work environment in the HDF5 Tour.pxp 
experiment file.
This concludes the HDF5 Guided Tour.
Where To Go From Here
If you are new to Igor or have never done it you should definitely do the Guided Tour of Igor Pro on page 
I-11. If you are in a hurry, do just the first half of it.
You should also read the following chapters which explain the basics of Igor in more detail:
Getting Help on page II-1
Experiments, Files and Folders on page II-15
Windows on page II-43
Waves on page II-61
To get started with Igor programming you need to read these chapters:
Working with Commands on page IV-1
Programming Overview on page IV-23
User-Defined Functions on page IV-29
For HDF5-specific programming, you need to have at least a basic understanding of HDF5. See the links in 
the next section. Then you need to familiarize yourself with the HDF5-related operations and functions 
listed in HDF5 Operations and Functions on page II-197.
If you run into problems, send a sample HDF5 file along with a description of what you are trying to do to 
support@wavemetrics.com and we will try to get you started in the right direction.
Learning More About HDF5
In order to use HDF5 operations, you must have at least a basic understanding of HDF5. The HDF5 web 
site provides an abundance of material. To get started, visit this web page:
https://portal.hdfgroup.org/display/HDF5/Learning+HDF5
The HDF Group provides a Java-based program called HDFView. You may want to download and install 
HDFView so that you can easily browse HDF5 files as you read the introductory material. Or you may 
prefer to use the HDF5 browser provided by Igor.
The HDF5 Browser
Igor Pro includes an automatically-loaded procedure file, "HDF5 Browser.ipf", which implements an HDF5 
browser. The browser lets you interactively examine HDF5 files to get an idea of what is in them. It also lets 
you load HDF5 datasets and groups into Igor and save Igor waves and data folders in HDF5 files.
The browser currently does not support creating attributes. For that you must use the HDF5SaveData oper-
ation.
The HDF5 browser includes lists which display:
•
All groups in the file
•
All attributes of the selected group
•
All datasets in the selected group
•
All attributes of the selected dataset
In addition, the HDF5 browser optionally displays:
