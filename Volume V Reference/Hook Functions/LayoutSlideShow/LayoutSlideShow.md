# LayoutSlideShow

LayoutSlideShow
V-481
Flags
Details
Page numbers starts from 1. Use page=0 to refer to the active page.
The layout as a whole has a size and margins. These are called "global" dimensions and govern all pages by 
default. You can set the global dimensions using the size and margins keyword without specifying a 
particular page.
You can override the dimensions for a given page using size(page) and margins(page) to specify custom 
dimensions.
Use size(page)=(0,0) to revert the specified page to the global layout dimensions. This reverts both the page 
size and its margins.
See Also
Page Layouts on page II-475, NewLayout, ModifyLayout
LayoutSlideShow
LayoutSlideShow [/W=winName] [keyword = value [, keyword = value …]]
The LayoutSlideShow operation starts, stops, or modifies a slideshow that displays the pages of a page 
layout.
The LayoutSlideShow operation was added in Igor Pro 7.00.
Parameters
Sets the dimensions of page to width and height, specified in units of points.
Using this keyword with page set to -1 modifies the global page dimensions for the 
layout.
margins=(leftMargin, topMargin, rightMargin, bottomMargin)
Sets the global page margins for the layout to the specified values, expressed in units 
of points.
margins(page)=(leftMargin, topMargin, rightMargin, bottomMargin)
Sets the margins of specified page to these values, expressed in units of points.
Page numbers start from 1.
Passing -1 for page sets the global margins for the layout.
/W=winName
Modifies the named layout. When omitted, the actions affect the top layout.
autoMode=a
Controls whether the presentation will advance between slides automatically (a=1) or 
manually (a=0). Use the delay keyword to control the delay between automatic 
transitions. 
delay=d
d is the number of seconds to wait between slide transitions when running in auto 
mode.
otherScreenContents=o
page=p
Causes the slideshow to start from page p. p is a page number starting from 1. This 
keyword has no effect unless the start keyword is also present.
Controls what is displayed on any additional screens that may be connected.
o=0:
Other screens show the presentation.
o=1:
Other screens show a presenter's view with additional information. 
Use the presentersView keyword to control the contents of this view.
o=2:
Other screens show a presenter's view with additional information. 
Use the presentersView keyword to control the contents of this view.

LayoutSlideShow
V-482
Flags
Details
A layout slide show can be used to present an Igor experiment to others, or to run an information kiosk.
Any changes to the layout window during a slide show are automatically reflected in the slides. For 
example you could use a background task to update a graph so that the slides always show the latest data.
You can control a running slide show by right-clicking on the slideshow. Alternatively, use the arrow keys 
or a mouse click to advance to the next slide.
Press the space bar to toggle between automatic and manual advancing of the slides. Press escape to end 
the slideshow.
Example
Function DemoSlideshow()
// Press escape to end the slideshow
NewLayout
TextBox/C/N=text0/F=0/A=LB/X=33.57/Y=70.81 "\\Z961"
LayoutPageAction appendpage
TextBox/C/N=text0/F=0/A=LB/X=33.57/Y=70.81 "\\Z962"
LayoutPageAction appendpage
TextBox/C/N=text0/F=0/A=LB/X=33.57/Y=70.81 "\\Z963"
LayoutSlideShow autoMode=1,delay=1,page=1,wrapMode=1,start
End
See Also
Page Layouts on page II-475, NewLayout, LayoutPageAction
presentersView=p
Controls what is displayed on the screens that show the presenter's view.
Setting Bit Parameters on page IV-12 for details about bit settings.
scaleMode=s
screen=s
Specifies the screen to be used for the main presentation. Use s=1 to use the primary 
screen. Use IgorInfo to determine the number of available screens.
start
Starts the slideshow.
stop
Stops the slideshow. You can also stop it by pressing the escape key.
wrapMode=w
/W= winName
winName is the name of the desired layout window. If /W is omitted or if winName is 
$"", the top layout window is used.
p is a bitfield of flags:
Bit 0:
Show the next page.
Bit 1:
Show the current time.
Bit 2:
Show the elapsed time.
Specifies how the pages are scaled to fit the screen.
s=0:
No scaling. Pages are drawn at actual size even if they are much 
larger or smaller than the screen size.
s=1:
All pages are individually scaled to the screen size.
s=2:
All pages are scaled by the same factor so that the largest page fits on 
the screen. This preserves the relative sizes of the pages.
Controls what happens when the presentation reaches the last page in the 
slideshow.
w=0:
Advancing to the next page has no effect.
w=1:
Advancing to the next page causes the slideshow to wrap around to 
the first page.
w=2:
Advancing to the next page causes the slideshow to stop.
