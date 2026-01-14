# Save Graph Copy

Chapter II-13 — Graphs
II-323
Printing Graphs
Before printing a graph you should set the page size and orientation using the Page Setup dialog. Choose 
Page Setup from the Files menu. Often graphs are wider than they are tall and look better when printed 
using the horizontal orientation.
When you invoke the Page Setup dialog you must make sure that the graph that you want to print is the 
top window. Igor stores one page setup in each experiment for all graphs and stores other page setups for 
other types of windows. You can set the default graph page setup for new experiments using the Capture 
Graph Preferences dialog.
To print a graph, choose FilePrint while the graph is the active window. You can also choose FilePrint 
Preview to display a preview.
Graphs by default print at the same size as the graph window unless they do not fit in which case they are 
scaled down at the same aspect ratio.
Prior to Igor Pro 7, the Print dialog supported scaling modes such as Fill Page and Same Aspect. These are 
no longer available in the Print dialog. You can use PrintSettings with the graphMode and graphSize key-
words prior to printing to achieve the same effects.
Printing Poster-Sized Graphs
Using the PrintGraphs operation, you can specify a size for a graph that is too big for a single sheet of paper. 
When you do this, Igor uses multiple sheets of paper to print the graph. Use this to make very large, poster-
sized printouts.
To make the multiple sheets into one big poster, you need to trim the edges of the sheets and tape them 
together. Igor prints tiny alignment marks on the edges so you can line the pages up. You should trim the 
unneeded borders so that the alignment marks are flush against the edge of the trimmed sheet. Then align 
the sheets so that the alignment marks butt up against each other. All of the alignment marks should still 
be visible. Then tape the sheets together.
Other Printing Methods
You can also print graphs by placing them in page layouts. See Chapter II-18, Page Layouts for details.
You can print graphs directly from macros using the PrintGraphs (see page V-773) operation.
Save Graph Copy
You can save the active graph as an Igor packed experiment file by choosing FileSave Graph Copy. The main 
uses for saving as a packed experiment are to save an archival copy of data or to prepare to merge data from 
multiple experiments (see Merging Experiments on page II-19). The resulting experiment file preserves the data 
folder hierarchy of the waves displayed in the graph starting from the “top” data folder, which is the data folder 
that encloses all waves displayed in the graph. The top data folder becomes the root data folder of the resulting 
experiment file. Only the graph, its waves, dashed line settings, and any pictures used in the graph are saved in 
the packed experiment file, not procedures, variables, strings or any other objects in the experiment.
Save Graph Copy does not work well with graphs containing controls. First, the controls may depend on 
waves, variables or FIFOs (for chart controls) that Save Graph Copy will not save. Second, controls typically 
rely on procedures which are not saved by Save Graph Copy.
Save Graph Copy does not know about dependencies. If a graph contains a wave, wave0, that is dependent 
on another wave, wave1 which is not in the graph, Save Graph Copy will save wave0 but not wave1. When 
the saved experiment is open, there will be a broken dependency.
The SaveGraphCopy operation on page V-821 provides options that are not available using the Save Graph 
Copy menu command.
