# Image Appearance Preferences

Chapter II-16 — Image Plots
II-403
Image Instance Names
Igor identifies an image plot by the name of the wave providing Z values (the wave selected in the Z Wave 
list of the Image Plot dialogs). This “image instance name” is used in commands that modify the image plot.
In this example the image instance name is “zw”:
Display; AppendImage zw
// new image plot
ModifyImage zw ctab={*,*,BlueHot}
// change color table
In the unusual case that a graph contains two image plots of the same data, to show different subranges of the 
data side-by-side,for example, an instance number must be appended to the name to modify the second plot:
Display; AppendImage zw; AppendImage/R/T zw
// two image plots
ModifyImage zw ctab={*,*,RedWhiteBlue} 
// change first plot
ModifyImage zw#1 ctab={*,*,BlueHot} 
// change second plot
The Modify Image Appearance dialog generates the correct image instance name automatically. Image 
instance names work much the same way wave instance names for traces in a graph do. See Instance Nota-
tion on page IV-20.
The ImageNameList function (see page V-397) returns a string list of image instance names. Each name cor-
responds to one image plot in the graph. The ImageInfo function (see page V-380) returns information 
about a particular named image plot.
ImageNameList returns strings, but ModifyImage uses names. The $ operator turns a string into a name. 
For example:
Function SetFirstImageToRainbow(graphName)
String graphName
String imageInstNames = ImageNameList(graphName, ";")
String firstImageName = StringFromList(0,imageInstNames) // Name in a string
if (strlen(firstImageName) > 0)
// $ converts string to name
ModifyImage/W=$graphName $firstImageName ctab={,,Rainbow}
endif
End
Image Preferences
You can change the default appearance of image plots by capturing preferences from a prototype graph 
containing image plots. Create a graph containing an image plot with the settings you use most often. Then 
choose Capture Graph Prefs from the Graph menu. Select the Image Plots category, and click Capture Prefs.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. Preferences are discussed in more detail in Chapter III-18, Preferences.
The Image Plots category includes both Image Appearance settings and axis settings.
Image Appearance Preferences
The captured Image Appearance settings are automatically applied to an image plot when it is first created, 
provided preferences are turned on. They are also used to preset the Modify Image Appearance dialog 
when it is invoked as a subdialog of the New Image Plot dialog.
If you capture the Image Plot preferences from a graph with more than one image plot, the first image plot 
appended to a graph gets the settings from the image first appended to the prototype graph. The second 
image plot appended to a graph gets the settings from the second image plot appended to the prototype 
graph, etc. This is similar to the way XY plot wave styles work.
