#include <Keyword-Value>	// For StrByKey

// Have you ever wanted to adjust a contour level that Igor
// computed automatically? Ya can't do it!
// You can, however, run this macro which moves all the current
// automatic, manual, or from-wave levels into the More Levels
// Dialog where you CAN adjust a contour level by retyping it.

Macro MoveAllLevelsIntoMoreLevels(contourName)
	String contourName
	Prompt contourName,"Contour plot:",popup,ContourNameList("",";")	// plots in top graph

	String levels= StrByKey("LEVELS", ContourInfo("",contourName,0))	// levels as string list
	String cmd="ModifyContour "+contourName+" "
	cmd+= "autoLevels = {*,*,0}, moreLevels=0,moreLevels={"+levels+"}"
	Print "All contour levels for "+contourName+" converted to a list of levels in the More Levels dialog."
	Execute cmd
End
