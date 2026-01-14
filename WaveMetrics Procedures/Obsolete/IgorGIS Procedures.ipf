#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0	1
// 1.0 June 2015, initial release
// 1.01 March 2017, removed RemoveAllAnnotations function; use DeleteAnnotations/A operation or the Delete Annotations dialog instead.

// Module constants
constant WMVectTypeUnknown = 0
constant WMVectTypePoint = 1
constant WMVectTypeLineString = 2
constant WMVectTypePolygon = 3
constant WMVectTypeMultiPoint = 4
constant WMVectTypeMultiLineString = 5
constant WMVectTypeMultiPolygon = 6
constant WMVectTypeGeometryCollection = 7

// CopyAttributeToZColumn(attributeWave, xyzFeatureWave, featureIndices)
// Copies the contents of a numeric attribute wave to the Z column of an XYZ feature wave.
// The attribute value for a given feature is copied to each of the feature wave points for that feature.
// This function is useful, for example, for copying a Z value to be used to display an XY pair
// using Igor's "Size as f(z)" feature.
Function CopyAttributeToZColumn(attributeWave, xyzFeatureWave, featureIndices)
	Wave attributeWave				// A numerical wave with values for each feature in xyzFeatureWave, as located by featureIndices -
									// must be at least as long as featureIndices
	Wave xyzFeatureWave			// A 3 column XYZ wave with geometric locations for each fetaure shape
	Wave featureIndices				// Indices into xyzFeatureWave indicating where each feature begins.  
	
	Variable numFeatures = DimSize(featureIndices,0)		// Number of features in this data
	Variable i
	for (i=0; i<numFeatures; i+=1)
		Variable attributeValue = attributeWave[i]
		Variable startIndex = featureIndices[i]
		Variable endIndex
		if (i < numFeatures-1)
			endIndex = featureIndices[i+1]-1
		else
			endIndex = DimSize(xyzFeatureWave,0) - 1
		endif
		// Store the attribute value in the Z column but set Z to NaN where X is NaN.
		xyzFeatureWave[startIndex,endIndex][2] = numtype(xyzFeatureWave[p][0])==2 ? NaN : attributeValue
	endfor
End

// SetMarkerFOfZMode(graphName, xyzTraceName, markerNum, markerThickness, minMarkerSize, maxMarkerSize)
// Sets trace to marker mode with marker size controlled by column 2 (i.e. the third column) of an xyz wave.
Function SetMarkerFOfZMode(graphName, xyzTraceName, markerNum, markerThickness, minMarkerSize, maxMarkerSize, r, g, b)
	String graphName			
	String xyzTraceName		// Name of the trace corresponding to the XYZ data
	Variable markerNum			// Marker type, as described in ModifyGraph for Traces
	Variable markerThickness	
	Variable minMarkerSize		// The smallest value(s) in the z column of xyzTraceName will have this marker size
	Variable maxMarkerSize		// The largest value(s) in the z column of xyzTraceName will have this marker size
	Variable r, g, b				// RGB color for marker

	Wave xyzFeatureWave = TraceNameToWaveRef(graphName, xyzTraceName)

	// Set trace display mode to marker
	ModifyGraph/W=$graphName mode($xyzTraceName)=3, marker($xyzTraceName)=(markerNum)
	
   	ModifyGraph/W=$graphName mrkThick($xyzTraceName)=(markerThickness)
   	
   	ModifyGraph/W=$graphName rgb($xyzTraceName)=(r,g,b)
   	
   	// Turn marker size as f(z) on
	ModifyGraph/W=$graphName zmrkSize($xyzTraceName)={xyzFeatureWave[*][2],*,*,minMarkerSize,maxMarkerSize}
End

// Creates a tag for each feature and locates it at the feature's first point.
// Best used with point data
Function TagPointsUsingTextAttribute(graphName, xyzTraceName, featureIndices, featureLabels[, xOff, yOff, fsize, valueWave, minValue])
	String graphName
	String xyzTraceName		// Name of the trace corresponding to the XYZ data
	Wave featureIndices			// indices identifying each geometry/feature in xyzTraceName
	Wave /T featureLabels		// the labels to use
	Variable xOff, yOff			// optional arguments to the Tag /X and /Y flags 
	Variable fsize				// font size - defaults to 9
	Wave valueWave
	Variable minValue
	
	if (paramisdefault(xOff))
		xOff=0.3
	endif
	if (paramisdefault(yOff))
		yOff=0.3
	endif
	if (paramisdefault(fsize))
		fsize = 9
	endif

	String fsizeStr
	sprintf fsizeStr, "\\Z%02.2d", fsize

	// Tag each point with the feature label
	Variable numFeatures = DimSize(featureIndices, 0)
	Variable i
	for (i=0; i<numFeatures; i+=1)
		String featureLabel = featureLabels[i]
		String tagName = CleanupName(featureLabel, 0)
		Variable tagPoint = featureIndices[i]
		
		if (!paramIsDefault(valueWave) && !paramIsDefault(minValue) && valueWave[i] < minValue)
			continue
		endif
		
//		Tag /W=$graphName /C /N=$tagName /A=LT/B=1/C/I=1/F=0/L=0/X=0.3/Y=0.3 $xyzTraceName, tagPoint, "\\Z09"+featureLabel
		Tag /W=$graphName /C /N=$tagName /A=LT/B=1/C/I=1/F=0/L=0/X=(xOff)/Y=(yOff) $xyzTraceName, tagPoint, fsizeStr+featureLabel
	endfor
End

// Find an approximate center point of a given feature geometry.  The intended purpose is for finding a decent place to put a label.
// The geometry is identified by startIndex and endIndex.  StartIndex is included, endIndex is not.
// Type is one of the module constants that appear at the top of this file, e.g. WMVectTypePoint, WMVectTypeLineString, or WMVectTypePolygon
// xLoc and yLoc are for the return values
// The algorithm for finding the polygon center expects the first and last point to be the same - i.e. the polygon must be explicitly closed.
Function getSpatialObjectMidPt(xyPts, startIndex, endIndex, type, xLoc, yLoc) 
	Wave xyPts							
	Variable startIndex, endIndex			// includes startIndex, does not include endIndex
	Variable type
	Variable & xLoc
	Variable & yLoc
	
	xLoc = NaN
	yLoc = NaN
	
	Variable i, m
	
	switch (type)
		case WMVectTypePoint:			//simple
			xLoc = xyPts[startIndex][0]
			yLoc = xyPts[startIndex][1]
			break			
		case WMVectTypeMultiPoint:	// average of all the points
			m=0
			xLoc = 0
			yLoc = 0
			for (i=startIndex; i<endIndex; i+=1)
				if (numtype(xyPts[i][0])==2 || numtype(xyPts[i][1])==2)
					continue
				endif
				xLoc += xyPts[i][0] 
				yLoc += xyPts[i][1]
				m+=1
			endfor
			
			if (m)
				xLoc /= m
				yLoc /= m
			else
				xLoc = NaN
				yLoc = NaN
			endif
			
			break
		case WMVectTypeLineString:	//Middle distance, in order, ignoring NaNs
		case WMVectTypeMultiLineString:
			// Get the total distance
			Make /O/FREE/N=(endIndex-startIndex-1) segmentLens
			i=startIndex

		 	segmentLens = sqrt((xyPts[i+p][0]-xyPts[i+p+1][0])^2 + (xyPts[i+p][1]-xyPts[i+p+1][1])^2)
			MatrixOp /O segmentLens = ReplaceNaNs(segmentLens, 0)

			Duplicate /O/FREE segmentLens, totalLens
			totalLens = sum(segmentLens, 0, p)

			FindLevel /Q/P totalLens, totalLens[dimsize(totalLens, 0)-1]/2

			if (V_flag)
				xLoc = NaN
				yLoc = NaN
			else
				xLoc = xyPts[startIndex+V_LevelX][0]
				yLoc = xyPts[startIndex+V_LevelX][1]		
			endif
			
			break
		case WMVectTypePolygon:
		case WMVectTypeMultiPolygon:
		case WMVectTypeGeometryCollection:		//Treat a GeometryCollection as a MultiPolygon for now.  Would need info on what each individual geometry is
			Variable totalArea = 0
			Variable currX, currY, currArea

			xLoc = 0
			yLoc = 0
			
			i=startIndex
			do 						
				m=WMFindNaNValue2Dxy(xyPts, i)
				if (m<0 || m>endIndex)
					m=endIndex
				endif	
				if (m-i-1 <= 0)	// one point polygon?
					m+=1
					i+=1
					continue
				endif
				
				// See:		http://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon							
				Make /O/FREE/N=(m-i-1) tmpPts0, tmpPts1, tmpPts2
				tmpPts0 = xyPts[i+p][0]*xyPts[i+p+1][1] - xyPts[i+p+1][0]*xyPts[i+p][1]
				tmpPts1 = (xyPts[i+p][0]+xyPts[i+p+1][0]) * tmpPts0[p]
				tmpPts2 = (xyPts[i+p][1]+xyPts[i+p+1][1]) * tmpPts0[p]
				
				// If the polygon does not have identical start and end points it could be an error in the file or read.  It can also happen when 
				// a polygon is cut off when only a portion of the GIS file is read.  This algorithm expects polygons to be represented
				// by common first and last points.  If it does not we put the points in in a temporary wave.  
				// This process may also allow users to find an approximate  "center" for a linestring that curves back on itself 
				// polygon-like, but only if it doesn't cross itself.
				if (xyPts[i][0]!=xyPts[m-1][0] || xyPts[i][1]!=xyPts[m-1][1])
					Redimension /N=(m-i) tmpPts0, tmpPts1, tmpPts2
					tmpPts0[m-i-1] = xyPts[m-1][0]*xyPts[i][1] - xyPts[i][0]*xyPts[m-1][1]
					tmpPts1[m-i-1] = (xyPts[m-1][0]+xyPts[i][0]) * tmpPts0[m-i-1]
					tmpPts2[m-i-1] = (xyPts[m-1][1]+xyPts[i][1]) * tmpPts0[m-i-1]					
				endif
									
				currArea = 0.5*sum(tmpPts0)
				if (currArea) 				
					currX = 1/(6*currArea)*sum(tmpPts1)
					currY = 1/(6*currArea)*sum(tmpPts2)

					currArea = abs(currArea)

					xLoc = (xLoc*totalArea + currX*currArea)/(totalArea+currArea)	
					yLoc = (yLoc*totalArea + currY*currArea)/(totalArea+currArea)	
			
					totalArea += currArea
				endif
				i = m+1
			while (i<endIndex)
						
			break
		default:
			break
	endswitch
End

// Filter out some features in a vector GIS data according to numeric feature data.  An example that would include 
// cities with more than 500,000 people:
//
// genAbridgedFeatureWaves(W_Geometries, W_GeometryIndices, W_POPULATION, W_AttributeNames, 500000, inf, "_500k")
//
// This will create W_Geometries_500k, W_GeometryIndices_500k, W_POPULATION_500k and a W_[field name]_500k wave for each
// field name specified in the W_AttributeNames text wave
Function genAbridgedFeatureWaves(Geometries, GeoIndices, criteria, fieldNames, minVal, maxVal, postfix[, noNans])
	Wave Geometries, GeoIndices, criteria	// e.g. W_Geometries, W_GeometryIndices, W_Population
	Wave /T fieldNames						// e.g. W_AttributeNames.  2 column with the second indicating if it is String, Double or Integer type
	Variable minVal, maxVal
	String postFix							// e.g. "_large"
	Variable noNans						// remove NaNs between features (but not within a feature).
	
	if (paramIsDefault(noNans))
		noNans = 0
	endif
	
	Variable i, j
	Variable nSrcFeatures = dimsize(GeoIndices,0)
	Variable nSrcAttributes = dimsize(fieldNames, 0)
	Variable nSrcPts = dimsize(Geometries, 0)
	
	Variable nFeatsQualified = 0
	
	DFREF targetDF = GetWavesDataFolderDFR(Geometries)
	
	Make /FREE/U/N=(nSrcFeatures) qualifiedFeatures
	
	for (i=0; i<nSrcFeatures; i+=1)
		if (criteria[i] >=minVal && criteria[i] <=maxVal)
			qualifiedFeatures[nFeatsQualified] = i
			nFeatsQualified += 1
		endif
	endfor

	String newName = NameOfWave(GeoIndices)+postfix
	Make /O/N=(nFeatsQualified) targetDF:$newName
	Wave newIndices = targetDF:$newName
	newName = NameOfWave(Geometries)+postfix
	Make /O/N=(dimsize(Geometries,0),3) targetDF:$newName
	Wave newGeometries = targetDF:$newName
	
	Variable currIndex = 0
	Variable currEndPt, nPtsAdded
	for (i=0; i<nFeatsQualified; i+=1)
		newIndices[i] = currIndex
		currEndPt = qualifiedFeatures[i] == nSrcFeatures ? nSrcPts : GeoIndices[qualifiedFeatures[i]+1]	// non-inclusive
		
		if (noNans && numtype(Geometries[currEndPt-1][0])==2)
			currEndPt -= 1
		endif
		nPtsAdded = currEndPt - GeoIndices[qualifiedFeatures[i]]
		
		newGeometries[currIndex, currIndex+nPtsAdded-1][] = Geometries[GeoIndices[qualifiedFeatures[i]]+p-currIndex][q]
		currIndex += nPtsAdded
	endfor
	Redimension /N=(currIndex, 3) newGeometries
	
	for (i = 0; i<nSrcAttributes; i+=1)		
		if (!CmpStr(fieldNames[i][1], "String"))
			Wave /T currWaveT = targetDF:$("W_"+fieldNames[i])		
			newName = NameOfWave(currWaveT)+postfix
			Make /T/O/N=(nFeatsQualified) targetDF:$newName
			Wave /T newAttributeWaveT = targetDF:$newName
				
			for (j=0; j<nFeatsQualified; j+=1)
				newAttributeWaveT[j] = currWaveT[qualifiedFeatures[j]]
			endfor	
		else 
			Wave currWave = targetDF:$("W_"+fieldNames[i])
			newName = NameOfWave(currWave)+postfix		

			if (!CmpStr(fieldNames[i][1],"Integer"))		
				Make /I/O/N=(nFeatsQualified) targetDF:$newName
			else // "Double"
				Make /D/O/N=(nFeatsQualified) targetDF:$newName	
			endif
				
			Wave newAttributeWave = targetDF:$newName
			for (j=0; j<nFeatsQualified; j+=1)
				newAttributeWave[j] = currWave[qualifiedFeatures[j]]
			endfor	
		endif
	endfor	
End

// Find NaN rows.  Assumes if the first column is NaN then all columns are, or can be treated as, NaN
// Returns -1 if no NaN is found after the startingIndex
Function WMFindNaNValue2Dxy(w, startingIndex)
	Wave w					// real (not complex) one-dimensional wave
	Variable startingIndex	// usually 0 or one more than the index of the previously found NaN
	
	Variable i, n= dimsize(w,0)
	for( i=startingIndex; i < n; i += 1 )
		if (numtype(w[i][0]) == 2 )	// found NaN
			return i					
		endif
	endfor
	return -1	// not found indicator
End

// Color vector feature geometries. This function just colors the vector. It does not fill the geometry
// graphName is the graph name as a string (e.g. "Graph0")
// XYZVals is the wave of geometry points in the same format as W_Geometries as loaded by GISLoadVectorData
// allIndices is the complete list of feature geometry indices into XYZVals, e.g. W_GeometryIndices
// allNames the complete list of names, and should have the same number of rows as, and be directly correlated to, W_GeometryIndices
// selectNames is a ";" separated list of names from allNames to be displayed in the selected color
// newWaveName is a name of the new wave to form the basis for the new trace.  
// RGBValues is a 3 point wave of rgb values (0-65535)
// colorStr is a string used by the getRGBFromColorName() function to get the RGB values.  See getRGBFromColorName for defined colors
// If both RBGValues and colorStr are defined RGBVals will be used.
Function createAndAddColoredBounds(graphName, XYZVals, allIndices, allNames, selectNames, newWaveName, [RGBVals, colorStr])
	String graphName					// graph name to append, string form
	Wave XYZVals, allIndices				// As loaded from the GIS vector file
	Wave /T allNames					// names directly correlating to allIndices - as loaded by GISLoadVectorData
	String selectNames					// ";" separated list of states to be given the current color
	String newWaveName				// Will create a wave by this name in the XYZVals directory - will overwrite existing name!
	Wave RGBVals						// a 3 point wave of 0-65535 based RGB color values
	String colorStr

	Variable red, green, blue
	if (ParamIsDefault(RGBVals))
		if (ParamIsDefault(colorStr))
			red = 0
			green = 0
			blue = 0
		else
			getRGBFromColorName(colorStr, red, green, blue)
		endif
	else
		red = RGBVals[0]
		green = RGBVals[1]
		blue = RGBVals[2]
	endif

	Variable nFeatures = DimSize(allIndices, 0)
	Variable nSelectFeatures = ItemsInList(selectNames)

	DFREF targetDF = GetWavesDataFolderDFR(XYZVals)

	// This is the new wave.  Allocate enough space for every state, redimension at the end
	Make /N=(DimSize(XYZVals, 0), 3)/O targetDF:$newWaveName
	Wave newWave = targetDF:$newWaveName

	Variable i, j
	Variable nNewRows=0
	Variable currIndex = 0
	Variable nPtsAdded, offset

	for (i=0; i<nSelectFeatures; i+=1)
		String currentState = StringFromList(i, selectNames)
		for (j=0; j<nFeatures; j+=1)		// Doing  a brute force search.  Sorted features and an O(logN) search would make this quicker.
			if (!CmpStr(currentState, allNames[j]))
				if (j==nFeatures-1)
					nPtsAdded = DimSize(XYZVals, 0)-allIndices[j][0]+1
				else
					nPtsAdded = allIndices[j+1][0]-allIndices[j][0] 
				endif

				offset = allIndices[j][0] - currIndex
				
				newWave[currIndex, currIndex + nPtsAdded-1][] = XYZVals[p+offset][q]
				//add a separating NaN
				newWave[currIndex + nPtsAdded][] = NaN
				
				currIndex += nPtsAdded
				break
			endif
		endfor
	endfor
	
	Redimension /N=(currIndex, 3) newWave
	AppendToGraph /C=(red, green, blue) newWave[][1] vs newWave[][0]
End

// Provide a string naming a color, and get 65535-based rgb color values
Static Function getRGBFromColorName(colorStr, red, green, blue)
	String colorStr
	Variable &red, &green, &blue
	
	strswitch (colorStr)
		case "red":
			red = 65535
			green = 0
			blue = 0
			break
		case "green":
			red = 0
			green = 32768
			blue = 0
			break
		case "blue":
			red = 0
			green = 0
			blue = 65535
			break
		case "lime":
			red = 20000
			green = 65535
			blue = 20000
			break
		case "yellow":
			red = 65535
			green = 65535
			blue = 0
			break
		case "cyan":
			red = 0
			green = 65535
			blue = 65535
			break
		case "magenta":
			red = 65535
			green = 0
			blue = 65535
			break
		case "gray":
			red = 32768
			green = 32768
			blue = 32768
			break
		case "maroon":
			red = 32768
			green = 0
			blue = 0
			break
		case "olive":
			red = 32768
			green = 32768
			blue = 0
			break
		case "purple":
			red = 32768
			green = 0
			blue = 32768
			break
		case "orange":
			red = 65535
			green = 32768
			blue = 0
			break
		case "light blue":
			red = 34695
			green = 53780
			blue = 65535
			break	
		case "pink":
			red = 65535
			green = 5140
			blue = 37780
			break
		case "brown":
			red = 35723
			green = 17733
			blue = 4883
			break
		case "white":
			red = 65535
			green = 65535
			blue = 65535
			break
		case "black":
		default:
			red = 0
			green = 0
			blue = 0
			break
	endswitch
End

// Creates a rasterized version of a vector file, and a color table to go with it.
// Result matrices M_RasterizedVector and M_GISColorTable are placed in the current directory
//
// GISFileHandle is a handle to an open GIS file, as created by GISRegesterFile
// featureToValueWave is a wave of values to assign to each feature geometry. 
//		It should have a 1-1 correlation with, and the same number of points as, W_GeometryIndices
// layer selects the layer number.  It defaults to 0
// resolution is the pixel size relative to the span of the data in its spatial reference system. Default is a simple, possibly simplistic, algorithm
// colorTableOffset is the lowest value in the color table (i.e. the X offset).  Defaults to the minimum value in the featureToValueWave
// colorTableDX is the distance between color table values (i.e. the X scaling).  Defaults to 1
// colorTableName is an alternate name for the color table output wave.  Defaults to M_GISColorTable
Function GenIndexedImageFromVectorFile(GISFileHandle, featureToValueWave, [layer, resolution, colorTableOffset, colorTableDX, colorTableName, LimitsRect])
	Variable GISFileHandle
	Wave featureToValueWave
	Variable layer
	Variable resolution
	Variable colorTableOffset
	Variable colorTableDX
	String colorTableName
	Wave LimitsRect
	
	if (ParamIsDefault(layer))
		layer=0
	endif	
	
	GISGetVectorLayerInfo /L=(layer) /R/D GISFileHandle

	if (V_Flag)
		DoAlert /T="GenIndexedImageFromVectorFile Error", 0, "The handle, "+num2str(GISFileHandle)+" is not associated with a registered vector file"
		return -1
	endif

	if (ParamIsDefault(resolution))
		Variable guessX = 10^(ceil(log(V_MaxX-V_MinX))-3)
		Variable guessY = 10^(ceil(log(V_MaxY-V_MinY))-3)		
		
		resolution = min(guessX, guessY)
	endif	
	
	Variable minX, minY, maxX, maxY
	if (ParamIsDefault(LimitsRect))
		minX = V_MinX
		minY = V_MinY
		maxX = V_MaxX	
		maxY = V_MaxY
	else
		minX = LimitsRect[0]
		minY = LimitsRect[1]
		maxX = LimitsRect[2]
		maxY = LimitsRect[3]
	endif
	
	GISRasterizeVectorData /O/L=(layer)/R=(minX, minY, maxX, maxY) /W=featureToValueWave /X=(resolution) GISFileHandle, ""
	
	if (ParamIsDefault(colorTableOffset))
		colorTableOffset = wavemin(featureToValueWave)
	endif
	if (ParamIsDefault(colorTableDX))
		colorTableDX = 1				// Keep it simple
	endif
	
	Variable nPts = ceil((wavemax(featureToValueWave)-colorTableOffset+1)/colorTableDX)
	Make /O/N=(nPts, 3) M_GISColorTable
	SetScale /P x, colorTableOffset, colorTableDX, M_GISColorTable
	
	String ctName = "Rainbow"
	if (!ParamIsDefault(colorTableName))
		ctName = colorTableName
	endif
	ColorTab2Wave $ctName
	Wave M_colors
	Variable nColors = dimSize(M_colors, 0)
	
	Variable i
	for (i=0; i<nPts; i+=1)
		M_GISColorTable[i][0] = M_colors[floor(i/nPts*nColors)][0]
		M_GISColorTable[i][1] = M_colors[floor(i/nPts*nColors)][1]
		M_GISColorTable[i][2] = M_colors[floor(i/nPts*nColors)][2]				
	endfor
End

// Create feature geometry labels.  This will attempt to find the center of the geometry and place a tag there.
// The tags require a new trace.  A wave, named by TagsName and placed in the same directory as the GeoWave,
// is created to place the tag.  It is displayed with a width 0 line, making it effectively hidden while still showing the tag.
//
// GeoWave is a wave of feature geometries, e.g. W_Geometries as created by GISLoadVectorData
// GeoIndices is a wave of indices into the GeoWave of individual feature geometires, e.g. W_GeometryIndices
// TagVals is a text wave of labels
// graphName is the name of the graph to put the tags onto
// TagsName is the name of the tags location wave.  CleanUpName, non-liberal, is applied before the wave is create. 
//		It goes into the same data folder as the GeoWave.
Function genFeatureCenterPtTags(GeoWave, GeoIndices, TagVals, graphName, TagsName, [newLineTagVals, fsize, fcolorStr])
	Wave GeoWave
	Wave GeoIndices
	Wave /T TagVals
	String graphName
	String TagsName
	Wave /T newLineTagVals
	Variable fsize
	String fcolorStr
	
	Variable r, g, b
	if (paramisdefault(fcolorStr))
		r=0
		g=0
		b=0
	else
		getRGBFromColorName(fcolorStr, r, g, b)
	endif
	
	if (paramisdefault(fsize))
		fsize = 9
	endif

	String textFormatStr
	sprintf textFormatStr, "\\K(%d,%d,%d)\\Z%02.2d", r, g, b, fsize	

	DFREF geoDFR = GetWavesDataFolderDFR(GeoWave)

	Variable nFeatures = dimsize(GeoIndices, 0)

	String traceName = CleanupName(TagsName, 0)	
	Make /O/N=(nFeatures, 2) geoDFR:$traceName	
	Wave centerPts = geoDFR:$traceName
	
	Variable startIndex, endIndex, xLoc, yLoc
	Variable i
	for (i=0; i<nFeatures; i+=1)
		startIndex = GeoIndices[i][0]
		endIndex = i<nFeatures-1 ? GeoIndices[i+1][0] : DimSize(GeoWave, 0)
		
		getSpatialObjectMidPt(GeoWave, startIndex, endIndex, GeoIndices[i][1], xLoc, yLoc)
		
		centerPts[i][0] = xLoc
		centerPts[i][1] = yLoc
	endfor
	
	AppendToGraph /W=$graphName centerPts[][1]/TN=$traceName vs centerPts[][0]
	ModifyGraph /W=$graphName lSize($traceName)=0

	for (i=0; i<nFeatures; i+=1)
		String featureLabel = TagVals[i]
		String tagName = CleanupName(featureLabel, 0)
		Variable tagPoint = i

		if (!ParamIsDefault(newLineTagVals))
			featureLabel+="\r"+newLineTagVals[i]
		endif

		Tag /W=$graphName /C /N=$tagName /A=LT/B=1/C/I=1/F=0/L=0/X=-0.6/Y=0.6 $TagsName, tagPoint, textFormatStr+featureLabel
	endfor
End

// This only removes the feature in Igor.  It does not remove it from the GIS file.
// This function expects the waves to have the default names as loaded by GISLoadVectorData:
//  W_Geometries, W_GeometryIndices, W_AttributeNames, "W_"+[name in W_AttributeNames]
Function removeFeature(dfr, featureNum)
	DFREF dfr					// The layer data folder
	Variable featureNum

	Variable i

	Wave /T fieldNames = dfr:W_AttributeNames
	Variable nAttributes = dimsize(fieldNames, 0)

	Wave GeoIndices = dfr:W_GeometryIndices
	Wave Geometries = dfr:W_Geometries
	Variable nFeatures = dimsize(GeoIndices, 0)
	
	for (i = 0; i<nAttributes; i+=1)
		
		Wave /Z currWave = dfr:$("W_"+fieldNames[i])
		if (waveExists(currWave))			
			DeletePoints featureNum, 1, currWave
		endif		
	endfor
	
	Variable startIndex = GeoIndices[featureNum][0]
	Variable endIndex = featureNum<nFeatures-1 ? GeoIndices[featureNum+1][0]-1 : dimSize(Geometries,0)
	Variable nPtsRemoved = endIndex-startIndex+1
	
	DeletePoints startIndex, nPtsRemoved, Geometries

	for (i=featureNum+1; i<nFeatures; i+=1)
		GeoIndices[i][0] -= nPtsRemoved
	endfor
	DeletePoints featureNum, 1, GeoIndices	
End

// Remove numerous features all at once
//  As above, it expects the waves to have the default names as loaded by GISLoadVectorData:
//  W_Geometries, W_GeometryIndices, W_AttributeNames, "W_"+[name in W_AttributeNames]
Function removeFeatureList(dfr, featureList)
	DFREF dfr
	Wave featureList
	
	Duplicate /FREE featureList, localList
	
	Wave GeoIndices = dfr:W_GeometryIndices
	Wave Geometries = dfr:W_Geometries
	Variable nFeatures = dimsize(GeoIndices, 0)	
	Variable nFeatsToDelete = dimsize(featureList, 0)
	Variable i, j
	
	for (i=0; i<nFeatsToDelete; i+=1)
		Variable toDelete = featureList[i]
		removeFeature(dfr, toDelete)

		featureList = featureList[p] > toDelete ? featureList[p]-1 : featureList[p]
	endfor
End

// Move a vector feature, such as a state in a map of the United States
Function moveFeature(geoPts, geoIndices, featureNum, xShift, yShift)
	Wave geoPts
	Wave geoIndices
	Variable featureNum
	Variable xShift, yShift
	
	Variable i
	
	Variable startIndex = geoIndices[featureNum]
	Variable endIndex = featureNum >= dimsize(geoIndices, 0) ? dimsize(geoPts,0)-1 : geoIndices[featureNum+1]-1
	
	geoPts[startIndex, endIndex][0] += xShift
	geoPts[startIndex, endIndex][1] += yShift
End

// Shrink a vector feature.  Note that the feature is shrunk towards a single point.  It does not necessarily maintain 
// angles and relative distances between points.  It is intended for circumstances where a feature needs
// to be moved to clarify or simplify data presentation, but only the general shape needs to be maintained.  
// An example is shrinking or growing, then moving Alaska and Hawaii to just off America's west coast to display 
// state-by-state data (e.g. election maps).
Function resizeFeature(geoPts, geoIndices, featureNum, scaleX, scaleY, shrinkToPt)
	Wave geoPts
	Wave geoIndices
	Variable featureNum
	Variable scaleX, scaleY
	Wave shrinkToPt

	Variable i
	
	Variable startIndex = geoIndices[featureNum]
	Variable endIndex = featureNum >= dimsize(geoIndices, 0) ? dimsize(geoPts,0)-1 : geoIndices[featureNum+1]-1

	geoPts[startIndex, endIndex][0] = (geoPts[p][0] - shrinkToPt[0])*scaleX + shrinkToPt[0]
	geoPts[startIndex, endIndex][1] = (geoPts[p][1] - shrinkToPt[1])*scaleY + shrinkToPt[1]
End

///////////////// Make WKT pretty ////////////////
// Call this function
Function /S prettyWKTSRef(uglyWKT[, checkBrackets]) 
	String uglyWKT
	Variable checkBrackets
	
	if (ParamIsDefault(checkBrackets))
		checkBrackets = 0
	endif
	
	Variable nChars = strlen(uglyWKT)

	// this is a state machine, basically
	String prettyWKT = doPrettyWKTSRef(uglyWKT, checkBrackets)
		
	return prettyWKT
End

constant LBracketChar = 91
constant ZeroChar = 48
constant NineChar = 57
constant ColonChar = 58
constant PeriodChar = 46
constant RBracketChar = 93
constant LittleaChar = 97
constant LittlezChar = 122
constant BigAChar = 65
constant BigZChar = 90
constant QuoteChar = 34
constant CommaChar = 44
constant CarriageReturnChar = 13
constant LineFeedChar = 10
constant UnderscoreChar = 95
constant TabChar = 9
constant SingleQuoteChar = 39
constant LSquigglyBracketChar = 123
constant RSquigglyBracketChar = 125

constant itsALetter = 1
constant itsANumber = 2
constant itsALBracket = 3
constant itsARBracket = 4
constant itsAComma = 5
constant itsAQuote = 6

// Don't call this one directly
// State machine function for prettyWKTSRef
Function /S doPrettyWKTSRef(uglyWKT, checkBrackets)
	String uglyWKT
	Variable checkBrackets
	
	Variable currIndx=0
	Variable currDepth=0
	Variable nChars=strlen(uglyWKT)
	Variable lastState=itsALetter
	
	String prettyWKT=""	
	
	Variable i, currCharVal
	for (i=0; i<nChars; i+=1)
		currCharVal = char2num(uglyWKT[i])
	
		if (currCharVal == CarriageReturnChar || currCharVal == 	LineFeedChar || currCharVal == TabChar)						// skip \r, \n and \t
			continue	//doPrettyWKTSRef(uglyWKT, currIndx+1, currDepth, nChars, lastState)						
		elseif ((currCharVal >= ZeroChar && currCharVal <= NineChar) || currCharVal==PeriodChar)								// a number or decimal
			prettyWKT += uglyWKT[i]	
			lastState = itsANumber 
		elseif (currCharVal == QuoteChar)																						// a quote
			prettyWKT += uglyWKT[i]	
			lastState = itsAQuote
		elseif (currCharVal == LBracketChar)																					// a L Bracket
			prettyWKT += uglyWKT[i]	
			lastState = itsALBracket
			currDepth += 1
		elseif (currCharVal == RBracketChar)																					// a R Bracket
			prettyWKT += uglyWKT[i]	
			lastState = itsARBracket
			currDepth -= 1
		elseif (currCharVal == CommaChar)																						// a Comma
			prettyWKT += uglyWKT[i]	
			lastState = itsAComma
		else	
			if (lastState==itsAcomma)
				// read ahead and determine if the current name has children.  If so, \r, if not, finish the line
				Variable j
				for (j=i; j<nChars; j+=1)
					if (!isAlphaNumOrWhite(uglyWKT[j]))
						break
					endif
				endfor
				Variable asNum = char2num(uglyWKT[j])
				
				if (asNum==LBracketChar)
					prettyWKT += "\r"
					for (j=0; j<currDepth; j+=1)
						prettyWKT += "\t"
					endfor
				endif
			endif
		
			prettyWKT += uglyWKT[i]
			lastState = itsALetter
		endif
	endfor
	
	if (currDepth != 0 && checkBrackets)	
		DoAlert /T="WKT Mismatched Brackets" 0, "A bracket mismatch was detected while prettying up a Well Known Text spatial reference"
	endif

	return prettyWKT
End

Function isAlphaNumOrWhite(aChar)
	String aChar
	
	return GrepString(aChar, "\\s|\\d|\\w|_")
End

///////////////////////////////////////////////////////////////////////////
///////////////// 2004 GISLoadWave Utility Procedures /////////////////////
///////////////////////////////////////////////////////////////////////////

//These procedures are left over from Igor's old GIS utilities.  There is one file loader - LoadGSHHS_7 -
//and one utility - fillLake().  IgorGIS help includes the original instructions for fillLake() in the 
//"Previos Igor GIS Utilities" section.

// Fills a flat area, such as a lake in a DEM. Requires that a cursor be positioned on the DEM
// with in the area that is to be filled. lakeFiller() does all of the work
Function fillLake( )	
	String WvCsrA=CsrWave(A)
	String WvCsrB=CsrWave(B)
	if( WinType(StringFromList(0,WinList("*",";","")))!=1 )		// Graph is target?
		Beep
		DoAlert 0,"Please display or bring graph to the front!"
		return 0
	endif
	if( strlen(WvCsrA)==0 && strlen(WvCsrB)==0 )				// Are any cursors on graph?
		Beep
		DoAlert 0,"Please position a cursor on the DEM!"
		return 0
	endif
	
	Variable fillDelta=2, fillVal=0
	String overWrite="Yes",csr
	Prompt overWrite, "Overwrite the current DEM?", popup, "Yes;No"
	Prompt	fillDelta, "Range (+/-) of elevation coverage:"
	Prompt	fillVal, "Value for elevation fill:"
	Prompt csr, "Which Cursor should I use?", popup, "A;B"
	
	if( strlen(WvCsrA)>0 && strlen(WvCsrB)>0 )			// Two cursors; use one
		DoPrompt "Fill a lake:", overWrite,csr,fillDelta,fillVal
	else
		DoPrompt "Fill a lake:", overWrite,fillDelta,fillVal
		if( strlen(WvCsrA)>0 )								// Only one cursor up, which one?
			csr="A"
		elseif( strlen(WvCsrB)>0 )
			csr="B"
		endif
	endif
	
	if( V_flag==0 )
		lakeFiller(fillDelta,fillVal, stringmatch(overWrite, "Yes"),csr)
	endif
End										// fillLake() ------------------


Function lakeFiller(fillDelta,fillVal,overWrite,csr)
	Variable fillVal					// new elevation for area
	Variable fillDelta				// +/- delta on elevation to fill; a negative value uses elevation as upper limit
	Variable overWrite				// option to overwrite source wave
	String csr						// name of cursor positioned in fill area
	
	String DEMwaveName,noteText
	Variable Lat, dLat, Lon, dLon, convert=0
	
	Wave/Z DEMwv=CsrWaveRef($csr)
	
	if( numtype(fillVal)==2 )							// NaN fill
		String wInfo=WaveInfo(demwv,0)
		if( NumberByKey("NUMTYPE", wInfo) >=8 )	// Ask to convert from INT to make area transparent
			Beep
			DoAlert 1, "Convert DEM to single precision?\rFill values will then become transparent.\rOtherwise fill is zero."
			if( V_flag==1 )
				if( overwrite )							// Redimension now when overwriting
					Redimension/S demwv
				else										// ... or at end for new wave
					convert=1
				endif
			endif
		endif
	endif
	
	// get position and elevation of cursor
	Variable latPos=dimoffset(DEMwv,1)+qcsr($csr)*dimdelta(DEMwv,1)
	Variable lonPos=dimoffset(DEMwv,0)+pcsr($csr)*dimdelta(DEMwv,0)
	Variable fillMin=zcsr($csr)-fillDelta
	Variable fillMax=zcsr($csr)+fillDelta
	
	if( fillDelta<0 )									// negative delta uses cursor elevation as upper limit
		fillMin=zcsr($csr)+fillDelta
		fillMax=zcsr($csr)
	endif
	
	noteText=note(DEMwv)							// get wave note to preserve it
	
	if( overWrite )									// do fill in place; overwrite
		ImageSeedFill/O seedx=lonPos,seedy=latPos,min=fillMin,max=fillMax,target=fillVal,srcwave=DEMwv
//		Note DEMwv,noteText
	else
		ImageSeedFill seedx=lonPos,seedy=latPos,min=fillMin,max=fillMax,target=fillVal,srcwave=DEMwv
	
		DEMwaveName=NameOfWave(DEMwv)+"_lakes"
		
		Variable i=0
		String baseName=DEMwaveName+"_"
		do												// overwrites lake DEM when not in use
			CheckDisplayed/A $DEMwaveName
			if( V_flag == 0 )							// wave not in use; exit loop
				break
			endif
			
			DEMwaveName=baseName+num2istr(i)		// create new name to test
			i+=1
		while(1)
		KillWaves/Z $DEMwaveName
		
		Rename	M_SeedFill, $DEMwaveName
		
		if( convert )									// Convert to SP and refill when not overwriting
			Redimension/S $DEMwaveName
			
			ImageSeedFill/O seedx=lonPos,seedy=latPos,min=0,max=0,target=fillVal,srcwave=$DEMwaveName
		endif
		Note $DEMwaveName,noteText		
	endif
End										// lakeFiller() ------------------


// The old GISLoadWave XOP has become obsolete and been deleted.  However some of the procedures, not
// relying on GISLoadWave operations, included in the package remain potentially useful.  LoadGSHHS_7 is one
// of those.

// Loads GSHHS coastline binary data files (*.b extension).
// Translated from gshhs.c	1.1  05/18/99 by Joe Urmos
// <http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html>
//
// GSHHS coastline data is now available as both shapefile and .b binary files.
// Shapefile versions are (as of 10/1/2015) slightly different, possibly inferior due to artifacts at the map
// edges. Thus this .b reader has been maintained.
Function LoadGSHHS_7(DEMName, pathStr)
	String	DEMName				// name for new DEM wave
	String	pathStr					// path with file name of DEM to import
	
	String	lonName=DEMname+"_Lon",latName=DEMname+"_Lat"
	Variable	refnum, refnum2
	String	filename, wname="testy"
	
	Variable	id,nPoly,flag,west,east,south,north,pArea,area_full,container,ancestor,pVersion
	Variable	greenwich,fSource,level,version,river,xx,yy
	
	Variable	lon,lat
//	Variable	ww,ee,ss,nn,warea				// Unused -> See below.
	string	source
	variable	kk, max_east = 270000000
	
	Variable	wLen=10000, pp=0
	
	Open/R	refNum as pathStr
	
	Make/O/N=10000 $lonName, $latName
	Wave wLon = $lonName
	Wave wLat = $latName
	
	Do
		FBinRead/B=2/U/F=3 refnum, id				// Unique polygon id number, starting at 0
		if( pp==0 && id!=0 )
			Beep
			DoAlert 0, "This appears to be an incorrect file type!"
			return 0
		endif
		FBinRead/B=2/U/F=3 refnum, nPoly	// Number of points in this polygon
		FBinRead/B=2/U/F=3 refnum, flag			// 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
		
		if(pp==0)
			version = (flag/2^8) & 255				// Should be 7 for GSHHS release 7
			if(version<7)
				Print "WARNING:  This GSHHS file is outdated (older than release 2.0). Consider downloading a new version from http://www.soest.hawaii.edu/pwessel/gshhs/index.html"
			elseif(version>9)						// FD, 2012-07-02, 1.02: Support version 2.2
				Print "WARNING:  This GSHHS file is newer than the reading routine.  Beware of incompatibilities!"
			endif
		endif
		
		if (version==0)
			FBinRead/B=2/F=3 refnum, west			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, east			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, south			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, north			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, pArea			// Area of polygon in 1/10 km^2
			FBinRead/B=2/F=2 refnum, greenwich		// Greenwich is 1 if Greenwich is crossed, else 0
			FBinRead/B=2/F=2 refnum, fSource			// 0 = CIA WDBII, 1 = WVS	
			
			// If Version 1.3, then those last two are actually a 4-byte polynomial version, which is 3.  Check.   
			pVersion = greenwich*2^16 + fSource
			if(pVersion==3)
				FBinRead/B=2/F=2 refnum, greenwich	// Greenwich is 1 if Greenwich is crossed, else 0
				FBinRead/B=2/F=2 refnum, fSource		// 0 = CIA WDBII, 1 = WVS	
			endif

			level = flag
			
		elseif(version==4)								// GSHHS release 1.4 (version 4)
			FBinRead/B=2/F=3 refnum, west			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, east			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, south			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, north			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, pArea			// Area of polygon in 1/10 km^2

			level = flag & 255							// 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
			greenwich = (flag/2^16) & 255				// 1 if Greenwich is crossed
			fSource = (flag/2^24) & 1					// 0 = CIA WDBII, 1 = WVS
			
		else												// GSHHS release 2.0 (version 7) and later?
			FBinRead/B=2/F=3 refnum, west			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, east			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, south			// min/max extent in micro-degrees
			FBinRead/B=2/F=3 refnum, north			// min/max extent in micro-degrees
			FBinRead/B=2/U/F=3 refnum, pArea		// Area of polygon in 1/10 km^2
			FBinRead/B=2/U/F=3 refnum, area_full	// Area of polygon from full-resolution dataset in 1/10 km^2
			FBinRead/B=2/F=3 refnum, container		// Id of container polygon that encloses this polygon (-1 if none)
			FBinRead/B=2/U/F=3 refnum, ancestor	// Id of ancestor polygon in the full resolution set that was the source of this polygon (-1 if none)
	
			level = flag & 255							// 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
			greenwich = (flag/2^16) & 255				// 1 if Greenwich is crossed
			fSource = (flag/2^24) & 1					// 0 = CIA WDBII, 1 = WVS
			river = (flag/2^25) & 1 					// 0 = not set, 1 = river-lake and level = 2
		endif
				
		For(kk = 0; kk < nPoly; kk+=1)
			FBinRead/B=2/F=3 refnum, xx			// Data longitude
			FBinRead/B=2/F=3 refnum, yy			// Data latitude
			
			lon = (greenwich && xx > max_east) ? ((xx * 1.0e-6) - 360.0) : (xx * 1.0e-6)
			lat = yy * 1.0e-6
			
			wLon[pp]=lon
			wLat[pp]=lat
			pp+=1
			if(pp==wLen)
				wLen+=10000
				Redimension/N=(wLen)	wLon,wLat
			Endif
		EndFor
		
		max_east = 180000000				// Only Eurasiafrica needs 270 
		
		wLon[pp]=nan
		wLat[pp]=nan
		pp+=1			

		// FD, 2012-07-02, 1.02: We may need to expand wave.
		if (pp == wLen)
			wLen += 10000
			Redimension /N=(wLen) wLon, wLat
		endif
	
		FStatus refnum
		if (V_filePos == V_logEOF )
			break
		endif
	while(1)
	
	redimension/N=(pp-1)	wLon,wLat
	close	refNum
	
	RemoveZeroPad(wLon,wLat)
	
	return 1
End										// LoadGSHHS() ------------------

// Some GSHHS data sets are "padded" at the end by all zeros. This removes that 
// extra padding.
Function RemoveZeroPad(theXWave, theYWave)
	Wave theXWave
	Wave theYWave

	Variable p, numPoints, numNaNs
	Variable xval, yval
	
	For(numPoints=numpnts(theXWave)-1; numPoints >0; numPoints-=1)
		xval = theXWave[numPoints]
		yval = theYWave[numPoints]
		if ( xval!=0 || yval!=0 )		// stop if neither is zero
			break
		endif
		numNaNs+=1
	endfor	
	
	Redimension /N=(numPoints) theXWave, theYWave			// Truncate the wave
	
	return 1
End										// RemoveZeroPad() ------------------


///////////////////////////////////////////////////////////////////////////
////////////////////////// Examples and scratch ////////////////////////////
///////////////////////////////////////////////////////////////////////////

// This is an example of re-sizing and moving Alaska and Hawaii so they appear off California.
// This is common when displaying political or cultural data.  Note that the re-sizing algorithm is
// not rigorous.  In most cases it produces polygons that look like the source, but internal spatial
// relationships may not be maintained.
Function quickMoveStates()
	Wave xyPts = root:USAStateBounds:W_GeosUSAPoliticalMap
	Wave indices = root:USAStateBounds:W_GeometryIndices

	Variable xLoc, yLoc

	// Alaska is index 0, Hawaii is index 11

	//// Shrink and move Alaska ////
	getSpatialObjectMidPt(xyPts, indices[0][0], indices[1][0]-1, 6, xLoc, yLoc) 	// Find an approximate middle pt to shrink to
	Make /Free/N=2 centerPt = {xLoc, yLoc}
	resizeFeature(xyPts, indices, 0, .5, .6, centerPt)
	moveFeature(xyPts, indices, 0, 16, -25)

	//// Shrink and move Hawaii ////
	getSpatialObjectMidPt(xyPts, indices[11][0], indices[12][0]-1, 6, xLoc, yLoc)
	centerPt = {xLoc, yLoc}
	// Error in source file
	resizeFeature(xyPts, indices, 11, 1.4, 1.4, centerPt)			// Grow Hawaii a bit
	moveFeature(xyPts, indices, 11, 40, 8)
	
End
