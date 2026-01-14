# Notebook (Accessing Contents)

Notebook (Accessing Contents)
V-710
See Also
Chapter III-1, Notebooks. The NewNotebook, NotebookAction, and OpenNotebook operations; the 
SpecialCharacterInfo and SpecialCharacterList functions.
Notebook
(Accessing Contents)
Accessing Notebook Contents
See the Notebook In Panel example experiment for examples using getData and setData.
The specialUpdate keyword can update pictures of graphs, tables, and page layouts 
that were created from windows in the current experiment.
getData=mode
Causes Igor to return the contents of the notebook in the S_value variable. The 
contents are binary data in a private Igor format encoded as text. The only use for this 
keyword is to transfer data from one notebook to another by calling getData followed 
by setData.
Causes Igor to return the contents of the notebook in the S_value variable. The 
contents are binary data in a private Igor format encoded as text. The only use for 
this keyword is to transfer data from one notebook to another by calling getData 
followed by setData.
mode=1:
Stores in S_value plain text or formatted text data, depending on the 
type of the notebook, from the entire notebook.
mode=2:
Stores in S_value plain text data, regardless of the type of the 
notebook, from the entire notebook.
mode=3:
Stores in S_value plain text or formatted text data, depending on the 
type of the notebook, from the notebook selection only.
mode=4:
Stores in S_value plain text data, regardless of the type of the 
notebook, from the notebook selection only.
