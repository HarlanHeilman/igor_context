# Igor HDF5 Limitations

Chapter II-10 — Igor HDF5 Guide
II-206
dataset for a complex wave. HDF5LoadData and HDF5LoadGroup do this automatically if you use the 
appropriate /IGOR flag.
Handling of Igor Reference Waves
Igor Pro supports wave reference waves and data folder reference waves. Each element of a wave reference 
wave is a reference to another wave. Each element of a data folder reference wave is a reference to a data 
folder.
Igor correctly writes Igor reference waves when you save an experiment as HDF5 packed format, but the 
HDF5SaveData and HDF5SaveGroup do not support saving Igor reference waves.
The HDF5SaveData operation returns an error if you try to save a reference wave.
The behavior of the HDF5SaveGroup operation when it is asked to save a reference wave depends on the 
/CONT flag. By default (/CONT=1), it prints a note in the history saying it can not save the wave and then 
continues saving the rest of the objects in the data folder. If /CONT=0 is used, HDF5SaveGroup returns an 
error if asked to save a reference wave.
HDF5 Multitasking
You can call HDF5 operations and functions from an Igor preemptive thread.
The HDF5 library is limited to accessing one HDF5 file at a time. This precludes loading multiple HDF5 files 
concurrently in a given Igor instance but it does allow you to load an HDF5 file in a preemptive thread 
while you do something else in Igor's main thread. If you create multiple threads that attempt to access 
HDF5 files, one of your threads will gain access to the HDF5 library. Your other HDF5-accessing threads 
will wait until the first thread finishes at which time another thread will gain access to the HDF5 library.
For further information on multitasking and for examples, see the Demo Thread Safe HDF5 example exper-
iment.
Igor HDF5 Capabilities
Igor supports only a subset of all of the HDF5 capability.
Here is a partial list of HDF5 features that Igor does support:
•
Loading of all atomic datatypes.
•
Loading of strings.
•
Loading of array datatypes.
•
Loading of variable-length datasets where the base type is integer or float.
•
Loading of compound datasets (datasets consisting of C-like structures), including compound data-
sets containing members that are arrays.
•
Use of hyperslabs to load subsets of datasets.
•
Loading and saving object references.
•
Loading dataset region references.
Igor HDF5 Limitations
Here is a partial list of HDF5 features that Igor does not support:
•
Creating or appending to VLEN datasets (ragged arrays).
•
Loading of deeply-nested datatypes. See HDF5 Nested Datatypes below.
•
Saving dataset region references.
If Igor does not work with your HDF5 file, it could be due to a limitation in Igor. Send a sample file along 
with a description of what you are trying to do to support@wavemetrics.com and we will try to determine 
what the problem is.
