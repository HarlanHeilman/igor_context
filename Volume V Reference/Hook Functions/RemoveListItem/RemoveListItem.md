# RemoveListItem

RemoveLayoutObjects
V-795
Flags
Details
If the axes used by the given image are not in use after removing the image, they will also be removed.
An image name in a string can be used with the $ operator to specify imageInstance.
See Also
The AppendImage operation.
RemoveLayoutObjects 
RemoveLayoutObjects [/PAGE=page/W=winName/Z] objectSpec [, objectSpec]
The RemoveLayoutObjects operation removes the specified object or objects from the top page layout, or 
from the layout specified by the /W flag. It targets the active page or the page specified by the /PAGE flag.
Unlike the RemoveFromLayout operation, RemoveLayoutObjects can be used in user-defined functions. 
Therefore, RemoveLayoutObjects should be used in new programming.
Parameters
objectSpec is either an object name (e.g., Graph0) or an objectName with an instance (e.g., Graph0#1). An 
instance is needed only if the same object appears in the layout more than one time. Graph0 is equivalent 
to Graph0#0 and Graph0#1 refers to the second instance of Graph0 in the layout.
Flags
See Also
NewLayout, AppendLayoutObject, ModifyLayout, LayoutPageAction
RemoveListItem 
RemoveListItem(index, listStr [, listSepStr [, offset]])
The RemoveListItem function returns listStr after removing the item specified by the list index index.
RemoveListItem removes an item from a string containing a list of items separated by a separator, such as 
strings returned by functions like TraceNameList and AnnotationList.
Parameters
index is the zero-based index of the list item that you want to remove.
listStr contains a series of text items separated by listSepStr. The trailing separator is optional though 
recommended.
listSepStr is optional. If omitted it defaults to ";". Prior to Igor Pro 7.00, only the first byte of listSepStr was 
used. Now all bytes are used.
/ALL
Removes all image plots from the graph. Any image name parameters listed are 
ignored. /ALL was added in Igor Pro 9.00.
/W=winName
Removes an image from the named graph window or subwindow. When omitted, 
action will affect the active window or subwindow. Must be the first flag specified 
when used in a Proc or Macro or on the command line.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
/Z
Suppresses errors if specified image is not on the graph.
/PAGE=page
Removes the object from the specified page.
Page numbers start from 1. To target the active page, omit /PAGE or use page=0.
The /PAGE flag was added in Igor Pro 7.00.
/W=winName
winName is the name of the page layout window from which the object is to be 
removed. If /W is omitted or if winName is $"", the top page layout is used.
/Z
Does not report errors if the specified layout object does not exist.
