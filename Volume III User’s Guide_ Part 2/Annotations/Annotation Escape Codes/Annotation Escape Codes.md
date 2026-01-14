# Annotation Escape Codes

Chapter III-2 — Annotations
III-53
Changing Annotation Names
Each annotation has a name which is unique within the window it is in. You supply this name to the TextBox, 
Tag, Legend, ColorScale, and AnnotationInfo routines to identify the annotation you want to change.
You can rename an annotation by using the /C/N=oldName/R=newName syntax with the operations. For exam-
ple:
TextBox/C/N=oldTextBoxName/R=newTextBoxName
Changing Annotation Types
To change the type of an annotation, apply the corresponding operation to the named annotation. For 
example, to change a tag or legend into a textbox, use:
TextBox/C/N=annotationName
Changing Annotation Text
To change the text of an existing annotation, identify the annotation using /N=annotationName, and supply 
the new text. For example, to supply new text for the textbox named text0, use:
TextBox/C/N=text0 "This is the new text"
To append text to an annotation, use the AppendText operation:
AppendText/N=text0 "and this text appears on a new line"
You can append text without creating a new line using the /NOCR flag.
Generating Text Programmatically
You can write an Igor procedure to create or update an annotation using text generated from the results of 
an analysis or calculation. For example, here is a function that creates or updates a textbox in the top graph 
or layout window. The textbox is named FitResults.
Function CreateOrUpdateFitResults(slope, intercept)
Variable slope, intercept
String fitText
sprintf fitText, "Fit results: Slope=%g, Intercept=%g", slope, intercept
TextBox/C/N=FitResults fitText
End
You would call this function, possibly from another function, after executing a CurveFit command that per-
formed a fit to a line, passing coefficients returned by the CurveFit operation.
Deleting Annotations
To programmatically delete an annotation, use:
TextBox/K/N=text0
Annotation Escape Codes
Annotation escape codes provide formatting control and other features in annotations, including textboxes, 
tags, legends, and color scales. They can also be used in axis labels, control titles, SetVariable values using 
the styledText keyword, ListBox control contents, and with the DrawUserShape operation.
Using these escape codes you can control the font, size, style and color of text, create superscripts and sub-
scripts, create dynamically-updated text, insert legend symbols, and apply other effects.
