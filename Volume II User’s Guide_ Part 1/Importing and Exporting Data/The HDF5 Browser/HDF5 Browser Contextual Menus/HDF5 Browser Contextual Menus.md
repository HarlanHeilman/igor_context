# HDF5 Browser Contextual Menus

Chapter II-10 — Igor HDF5 Guide
II-195
Displays a panel that allows you to select and save waves in the HDF5 file, provided the file was open for 
read/write.
Transpose 2D
If the Transpose 2D checkbox is checked, 2D datasets are transposed to compensate for the difference in 
how Igor and other programs treat rows and columns in an image plot. See HDF5 Images Versus Igor 
Images on page II-204 for details. This does not affect the loading of "formal" images (images formatted 
according to the HDF5 Image and Palette Specification).
Sort By Creation Order If Possible
If checked, and if the file supports listing by creation order, the HDF5 Browser displays and loads groups 
and datasets in creation order.
Most HDF5 files do not include creation-order information and so are listed and loaded in alphabetical 
order even if this checkbox is checked. However, HDF5 files written by Igor Pro 9 or later include creation-
order information and so can be listed and loaded in creation order.
Load Group
The Load Group button loads all of the datasets in the currently selected group into a new data folder inside 
current data folder.
The Load Group button calls the HDF5LoadGroup operation using the /IMAG flag. This means that, if the 
group contains a formal image (see HDF5 Images Versus Igor Images on page II-204), it is be loaded as a 
formal image.
The Hyperselection controls do not apply to the operation of the Load Group button.
Load Groups Recursively
If the Load Groups Recursively checkbox is checked, when the Load Group button is pressed any sub-
groups in the currently selected group are loaded as sub-datafolders.
Load Group Only Once
Because an HDF5 file is a "directed graph" rather than a strict hierarchy, a given group in an HDF5 file can 
appear in more than one location in the file's hierarchy.
If the Load Group Only Once checkbox is checked, the Load Group button loads a given group only the 
first time it is encountered. If it is unchecked, the Load Group button loads a given group each time it 
appears in the file's hierarchy resulting in duplicated data. If in doubt, leave Load Group Only Once 
checked.
Save Data Folder
Displays a panel that allows you to select a single data folder and save it in the HDF5 file, provided the file 
was open for read/write.
HDF5 Browser Contextual Menus
If you right-click a row in the Datasets, Dataset Attributes or Group Attributes lists, the browser displays a 
contextual menu that allows you to perform the following actions:
- Copy the selected dataset or attribute's value to the clipboard as text
- Load the selected dataset or attribute as a wave
- Load all datasets or attributes as a waves
These popup menus also appear if you click the triangle icons above the lists. They work the same as the 
HDF5 Browser contextual menus described above.
