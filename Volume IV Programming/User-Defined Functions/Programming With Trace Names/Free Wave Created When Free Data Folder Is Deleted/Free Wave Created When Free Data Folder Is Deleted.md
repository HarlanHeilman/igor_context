# Free Wave Created When Free Data Folder Is Deleted

Chapter IV-3 — User-Defined Functions
IV-91
Free Waves
Free waves are waves that are not part of any data folder hierarchy. They are used mainly for temporary 
storage in a user function. They are somewhat faster to create than global waves, and when used as tempo-
rary storage in a user function, they are automatically killed the end of the function.
Free waves are recommended for advanced programmers only.
A wave that is stored in no data folder is called a “free” wave to distinguish it from a “global” wave which 
is stored in the root data folder or its descendants and from a “local” wave which is stored in a free data 
folder or its descendants.
Note:
Free waves are saved only in packed experiment files. They are not saved in unpacked 
experiments and are not saved by the SaveData operation or the Data Browser's Save Copy 
button. In general, they are intended for temporary computation purposes only. The only way to 
save a free wave in an experiment file is by storing a wave reference in a wave reference wave.
You most commonly create free waves using the NewFreeWave function, or the Make/FREE and Dupli-
cate/FREE operations. There are some other operations that can optionally make their output waves free 
waves. By default free waves are given the name '_free_' but NewFreeWave and Make/FREE allow you to 
specify other names - see Free Wave Names (see page IV-95) for details.
Here is an example:
Function ReverseWave(w)
Wave w
Variable lastPoint = numpnts(w) - 1
if (lastPoint > 0)
// This creates a free wave named _free_ and an automatic
// wave reference named wTemp which refers to the free wave
Duplicate /FREE w, wTemp
w = wTemp[lastPoint-p]
endif
End
In this example, wTemp is a free wave. As such, it is not contained in any data folder and therefore can not 
conflict with any other wave.
As explained below under Free Wave Lifetime on page IV-92, a free wave is automatically killed when 
there are no more references to it. In this example that happens when the function ends and the local wave 
reference variable wTemp goes out of scope.
You can access a free wave only using the wave reference returned by NewFreeWave, Make/FREE or Dupli-
cate/FREE.
Free waves can not be used in situations where global persistence is required such as in graphs, tables and 
controls. In other words, you should use free waves for computation purposes only.
For a discussion of multithreaded assignment statements, see Automatic Parallel Processing with Multi-
Thread on page IV-323. For an example using free waves, see Wave Reference MultiThread Example on 
page IV-327.
Free Wave Created When Free Data Folder Is Deleted
A wave stored in a free data folder or one of its descendants is called a local wave. This is in contrast to free 
waves which are stored in no data folder and to global waves which are stored in the main data folder hier-
archy (in the root data folder or one of its descendants).
Local waves, like free waves, can not be used in situations where global persistence is required such as in 
graphs, tables and controls.
