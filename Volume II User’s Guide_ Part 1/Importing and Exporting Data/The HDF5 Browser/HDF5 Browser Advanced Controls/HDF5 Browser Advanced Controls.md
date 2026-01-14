# HDF5 Browser Advanced Controls

Chapter II-10 — Igor HDF5 Guide
II-196
When the Datasets list is active, choosing Load Selected Dataset as Wave does the same thing as clicking 
the Load Dataset button.
When copying data to the clipboard, the data is copied as text and consequently may not represent the full 
precision of the underlying dataset or attribute. Not all datatypes are supported. If the browser supports 
the datatype that you right clicked, the contextual menu shows "Copy to Clipboard as Text". If the datatype 
is not supported, it shows "Can't Copy This Data Type".
When loading as waves, any pre-existing waves with the same names are overridden.
When loading waves from datasets, the table and graph options in the Load Dataset Options section of the 
browser apply. If you check Apply to Attributes also, the options apply when loading waves from attri-
butes.
HDF5 Browser Advanced Controls
Here is a description of the advanced controls in the HDF5 browser. These are for use by people familiar 
with the HDF5 file format.
Show Dump
If you click the Show Dump button, the browser displays a notebook in which you can see additional details 
about subsequent groups, datasets or attributes that you select. The dump window is updated each time 
you select a group, dataset or attribute from any of the lists.
Show Data In Dump
When unchecked, the dump shows header information but not the actual data of a dataset. When checked 
it shows data as well as header information for a dataset.
WARNING: If you check the Show Data In Dump checkbox and choose to dump a very large dataset, the 
dump could take a very long time. If the dump seems to be taking forever, clicking the Abort button in the 
Igor status bar.
Even if the Show Data In Dump checkbox is checked, the dump for a group consist of the header informa-
tion only and omits the actual data for datasets and attributes.
Show Attributes In Dump
The Show Attributes In Dump checkbox lets you determine whether attributes are dumped when you select 
a group or dataset. When checked, information about any attributes associated with the dataset is included 
in the dump. This checkbox does not affect what is dumped when you select an item in the group or dataset 
attribute lists.
Show Properties In Dump
The Show Properties In Dump checkbox lets you see properties such as storage layout and filters (compres-
sion). This information is usually of little interest but is useful when investigating the effects of compres-
sion.
Use Hyperselection
If you check the Use Hyperselection checkbox and enter a path to a "hyperslab wave", the HDF5 Browser 
uses the hyperselection in the wave to load a subset of subsequent datasets or attributes that you click. This 
is a feature for advanced users who understand HDF5 hyperselections and have read the HDF5 Dataset 
Subsets discussion below.
The hyperselection is used when you click the Load Dataset button but not when you click the Load Group 
button.
