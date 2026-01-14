# LayoutPageAction

LayoutMarquee
V-480
index = 0
do
sprintf indexStr, "%d", index
info = LayoutInfo(layoutName, indexStr)
if (strlen(info) == 0)
break
// No more objects
endif
selected = NumberByKey("SELECTED", info)
if (selected)
objectTypeStr = StringByKey("TYPE", info)
if (CmpStr(objectTypeStr,"Graph") == 0)// This is a graph?
graphNameStr = StringByKey("NAME", info)
ModifyGraph/W=$graphNameStr wbRGB=(red,green,blue)
ModifyGraph/W=$graphNameStr gbRGB=(red,green,blue)
endif
endif
index += 1
while(1)
End
See Also
The Layout operation. See Chapter II-18, Page Layouts.
LayoutMarquee 
LayoutMarquee
LayoutMarquee is a procedure subtype keyword that puts the name of the procedure in the layout Marquee 
menu. See Marquee Menu as Input Device on page IV-163 for details.
See Also
See Chapter II-18, Page Layouts.
LayoutPageAction
LayoutPageAction [/W=winName] [keyword = value [, keyword = value …]]
The LayoutPageAction operation adds, deletes, reorders, or adjusts the sizes of layout pages.
The LayoutPageAction operation was added in Igor Pro 7.00.
Parameters
appendPage
Appends a new page.
insertPage=page
Inserts a new page before page.
Page numbers start from 1. Pass 0 for page to insert before the first page.
page=page
Makes page the active page.
Page numbers start from 1.
deletePage=page
Deletes page. This action cannot be undone.
Page numbers start from 1.
reorderPages={anchorPage, page1, ...}
Reorders the pages so that page1 and any others appear before anchorPage, in the same 
order as their appearance in the command.
Page numbers start from 1.
size=(width, height)
Sets the global page dimensions for the layout to width and height, specified in units 
of points.
size(page)=(width, height)
