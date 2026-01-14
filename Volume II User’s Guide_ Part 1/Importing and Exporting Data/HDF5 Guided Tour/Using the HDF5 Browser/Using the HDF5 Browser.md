# Using the HDF5 Browser

Chapter II-10 — Igor HDF5 Guide
II-184
In the following material you will see numbered steps that you should perform. Please perform them 
exactly as written so you stay in sync with the guided tour.
This tour in intended to help experienced Igor users learn how to access HDF5 files from Igor but also to 
entice non-Igor users to buy Igor. Therefore the tour is written assuming no knowledge of Igor.
HDF5 Overview
HDF5 is a very powerful but complex file format that is designed to be capable of storing almost any imag-
inable set of data and to encapsulate relationships between data sets.
An HDF5 file can contain within it a hierarchy similar to the hierarchy of directories and files on your hard 
disk. In HDF5, the hierarchy consists of "groups" and "datasets". There is a root group named "/". Each 
group can contain datasets and other groups.
An HDF5 dataset is a one-dimensional or multi-dimensional set of elements. Each element can be an 
"atomic" datatype (e.g., 16-bit signed integer or a 32-bit IEEE float) or a "composite" datatype such as a struc-
ture or an array. A "compound" datatype is a composite datatype similar to a C structure. Its members can 
be atomic datatypes or composite datatypes. For now, forget about composite datatypes - we will deal with 
atomic datatypes only.
Each dataset can have associated with it any number of "attributes". Attributes are like datasets but are 
attached to datasets, or to groups, rather than being part of the hierarchy.
Igor Pro HDF5 Support
The Igor Pro HDF5 package consists of built-in HDF5 support and a set of Igor procedures.
The Igor procedures, which are automatically loaded when Igor is launched, implement an HDF5 browser 
in Igor. The browser supports:
•
Previewing HDF5 file data
•
Loading HDF5 datasets and groups into Igor
•
Saving Igor waves and data folders in HDF5 files
In Igor Pro 9 and later, Igor can save Igor experiments as HDF5 packed experiment files and reload exper-
iments from them.
Using the HDF5 Browser
1.
Choose DataLoad WavesNew HDF5 Browser.
This displays an HDF5 browser control panel.
As you can see, the HDF5 Browser takes up a bit of screen space. You will need to arrange it and this 
help window so you can see both.
2.
Click the Open HDF5 File button and open the following file:
Igor Pro Folder\Examples\Feature Demos\HDF5 Samples\TOVSB1NF.h5
(If you're not sure where your Igor Pro Folder is, choose MiscPath Status, click on the Igor symbolic 
path, and note the path to the Igor Pro Folder.)
We got this sample from the NCSA web site.

Chapter II-10 — Igor HDF5 Guide
II-185
You should now see something like this:
The browser contains four lists.
The top/left list is the Groups list and shows the groups in the HDF5 file. Groups in an HDF5 file are 
analogous to directories in a hard disk hierarchy. In this case there are two groups, root (which is 
called "/" in HDF5 terminology) and HDF4_PALGROUP. HDF4_PALGROUP is a subgroup of root.
This file contains a number of objects with names that begin with HDF4 because it was created by con-
verting an HDF4 file to HDF5 format using a utility supplied by The HDF Group.
Below the Groups list is the Group Attributes list. In the picture above, the root group is selected so 
the Group Attributes list shows the attributes of the root group. An attribute is like a dataset but is 
attached to a group or dataset instead of being part of the HDF5 file hierarchy. Attributes are usually 
used to save small snippets of information related to a group or dataset.
The top/right list is the Datasets list. This lists the datasets in the selected group, root in this case. In 
the root group of this file we have three datasets all of which are images.
Below the Datasets list is the Dataset Attributes list. It shows the attributes of the selected dataset, Ras-
ter Image #0 in this case.
Three of the lists have columns that show information about the items in the list.
3.
Familiarize yourself with the information listed in the columns of the lists.
To see all the information you will need to either scroll the list and/or resize the entire HDF5 browser 
window to make it larger.
4.
In the Groups list, click the subgroup and notice that the information displayed in the other lists 
changes.
5.
In the Groups list, click the root group again.
Now we will see how to browse a dataset.
6.
Click the Show Graph, Show Table and Show Dump buttons and arrange the three resulting win-
dows so that they can all be seen at least partially.
These browser preview windows should typically be kept fairly small as they are intended just to pro-
vide a preview. It is usually convenient to position them to the right of the HDF5 browser.
The three windows are blank now. They display something only when you click on a dataset or attri-
bute.
7.
In the Datasets list, click the top dataset (Raster Image #0).

Chapter II-10 — Igor HDF5 Guide
II-186
The dataset is displayed in each of the three preview windows.
The dump window shows the contents of the HDF5 file in "Data Description Language" (DDL). This 
is useful for experts who want to see the format details of a particular group, dataset or attribute. The 
dump window will be of no interest in most everyday use.
If you check the Show Data in Dump checkbox and then click a very large dataset, it will take a very 
long time to dump the data into the dump window. Therefore you should avoid checking the Show 
Data in Dump checkbox.
The preview graph and table, not surprisingly, allow you to preview the dataset in graphical and tab-
ular form.
This dataset is a special case. It is an image formatted according to the HDF5 Image and Palette Spec-
ification which requires that the image have certain attributes that describe it. You can see these attri-
butes in the Dataset Attributes list. They are named CLASS, IMAGE_VERSION, IMAGE_SUBCLASS 
and PALETTE. The HDF5 Browser uses the information in these attributes to make a nice preview 
graph.
An HDF5 file can contain a 2D dataset without the dataset being formatted according to the HDF5 
Image and Palette Specification. In fact, most HDF5 files do not follow that specification. We use the 
term "formal image" to make clear that a particular dataset is formatted according to the HDF5 Image 
and Palette Specification and to distinguish it from other 2D datasets which may be considered to be 
images.
8.
In the Dataset Attributes list, click the CLASS attribute.
The value of the selected attribute is displayed in the preview windows.
Try clicking the other image attributes, IMAGE_VERSION, IMAGE_SUBCLASS and PALETTE.
So far we have just previewed data, we have not loaded it into Igor. (Actually, it was loaded into Igor 
and stored in the root:Packages:HDF5Browser data folder, but that is an HDF5 Browser implementa-
tion detail.)
Now we will load the data into Igor for real.
9.
Make sure that the Raster Image #0 dataset is selected, that the Table popup menu is set to Display 
In New Table and that the Graph popup menu is set to Display In New Graph. Then click the Load 
Dataset button.
The HDF5 Browser loads the dataset (and its associated palette, because this is a formal image with 
an associated palette dataset) into the current data folder in Igor and creates a new graph and a new 
table.
10.
Choose DataData Browser and note the two "waves" in the root data folder.
"Wave" is short for "waveform" and is our term for a dataset. This terminology stems from our roots 
in time series signal processing.
The two waves, 'Raster Image #0' and 'Raster Image #0Pal' were loaded when you clicked the Load 
Dataset button. The graph was set up to display 'Raster Image #0' using 'Raster Image #0Pal' as a pal-
ette wave.
11.
Back in the HDF5 Browser, with the root group still selected, click the Load Group button.
The HDF5 Browser created a new data folder named TOVSB1NF and loaded the contents of the HDF5 
root group into the new data folder which can be seen in the Data Browser. The name TOVSB1NF 
comes from the name of the HDF5 file whose root group we just loaded.
When you load a group, the HDF5 Browser does not display the loaded data in a graph or table. That 
is done only when you click Load Dataset and also depends on the Load Dataset Options controls.
12.
Click the Close HDF5 File button and then click the close box on the HDF5 Browser.
If you had closed the HDF5 browser without clicking the Close HDF5 File button, the browser would 
have closed the file anyway. It will also automatically close the file if you choose FileNew Experi-
ment or FileOpen Experiment or if you quit Igor.
