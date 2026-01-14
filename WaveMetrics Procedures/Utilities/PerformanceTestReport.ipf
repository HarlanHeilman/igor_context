#pragma rtGlobals=2		// Need new syntax


// PerformanceTestReport.ipf
// LH131121, Version 1.02
//		Added scan for IP7 internal debug macros
//		Zap misleading group start values
//		Add total test values
// LH040607, Version 1.01
//		Removed bogus /T flags (failed to compile with new tighter text wave checking.)
//	LH020105, Version 1.0
//
// The ProcessTest function can be used to compile and display test results after
// exercising user-function code that you have modified by inserting calls to
// MarkPerfTestTime with comments that describe the location in the test.
// After ruuning the test between calls to "SetIgorOption DebugTimer,Start"
// and "SetIgorOption DebugTimer,Stop", timing info is stored in a pair of
// waves. The ProcessTest function takes these waves as one input and
// a notebook that you must prepare as the other input. The notebook must
// contain copies of all the MarkPerfTestTime lines that you insered in the code.
//
// An example experiment, PerformanceTesting.pxp, contains full instructions.
//
// Note to WaveMetrics internal progrmmers:
// ProcessTest can also be used to process test results for igor source code.
// To do a performance test, in the igor source code, insert calls similar to this:
//	GSTOWDEBUGTIME(206);		// PlotGraf DrawAllContours
// Extract lines from the source code using a shell command in the source directory like this:
// find . -name "*.cpp" | xargs grep "STOWDEBUGTIME"
// and then copy and paste the lines into a notebook
// Turn on the internal STOWDEBUGTIME calls using SetIgorOption DebugTimer,DoBuiltin=1
// Then run your test between calls to SetIgorOption DebugTimer,Start
// and SetIgorOption DebugTimer,Stop

Function ProcessTest(testName,nb)
	String testName
	String nb					// name of notebook containing test code sniipits

	WAVE W_DebugTimerIDs
	WAVE W_DebugTimerVals
	
	if( !WaveExists(W_DebugTimerIDs) )
		Abort "Couldn't find test results"
	endif
	if( WinType(nb) != 5 )
		Abort "Specified notebook does not exist"
	endif
	
	String dfSav= GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S PerfTest
	NewDataFolder/O/S $testName
	
	Variable maxIDsPossible= 1000		// ASSUME: never more than this number of unique IDs
	
	Make/O/D/N=(maxIDsPossible) wIndexVals
	Make/O/T/N=(maxIDsPossible) wDescriptions

	// The following are used to create a table of results
	Make/O/D/N=(maxIDsPossible) IDNum
	Make/O/T/N=(maxIDsPossible) description
	Make/O/N=(maxIDsPossible) groupPct,totalPct,avgTime,totalCalls,totalTime		// destination for group and total percentage for each ID. Used in tabel.
	
	Variable totTestTime= W_DebugTimerVals[inf]-W_DebugTimerVals[0]
	
	Variable nIDs= ExtractTestIDStrs(nb,wIndexVals,wDescriptions)	//	Parse notebook to extract descriptive strings for each ID number
	if( nIDs==0 )
		SetDataFolder dfSav
		Abort "Notebook did not contain descriptive strings"
	endif 	

	//
	//	Now find all ID number groups assuming each group is a multiple of 100
	//
	Duplicate/O W_DebugTimerIDs,wDBGroups
	wDBGroups= floor(wDBGroups/100)
	Sort wDBGroups,wDBGroups
	Variable n= numpnts(wDBGroups)
	Variable i,j
	Variable prev= wDBGroups[0]
	for(i=1,j=1;i<n;i+=1)
		if( prev != wDBGroups[i] )
			prev= wDBGroups[i]
			wDBGroups[j]= prev
			j+=1
		endif
	endfor
	Variable nGroups= j
	Redimension/N=(nGroups) wDBGroups
	
	//
	//	Now for each group, create a data folder of IDs, Times and descriptions for
	//	members of the group. Then compile and print statistics for each item
	//	within the group. Also stow data in waves to create a table.
	//
	Variable nTableEntries= 0
	
	Variable nvals= numpnts(W_DebugTimerVals),k
	for(j=0;j<nGroups;j+=1)
		Variable grp= wDBGroups[j]*100
		String grpName= "Group"+num2istr(grp)
		NewDataFolder/O/S $grpName
		
		String idName= "w"+num2istr(grp)+"ID"
		String tName= "w"+num2istr(grp)+"Time"
		String descName= "w"+num2istr(grp)+"Desc"
		Duplicate/O W_DebugTimerIDs,$idName
		Duplicate/O W_DebugTimerVals,$tName
		WAVE id= $idName, tm= $tName
		for(i=0,k=0;i<nvals;i+=1)
			if( W_DebugTimerIDs[i]>=grp && W_DebugTimerIDs[i]<(grp+100) )
				id[k]= W_DebugTimerIDs[i]
				tm[k]= W_DebugTimerVals[i]
				k+=1
			endif
		endfor
		Redimension/N=(k) id,tm
		Duplicate/O tm,tmTEMP
		tm[1,*]= tmTEMP[p]-tmTEMP[p-1]		// we need a simple forward difference op
		tm[0]=0
		KillWaves tmTEMP
		Make/O/T/N=(k) $descName= wDescriptions[BinarySearch(wIndexVals,id)]
		
		ReportStats(grpName,id,tm,wIndexVals,wDescriptions,totTestTime,IDNum,description,groupPct,totalPct,avgTime,totalCalls,totalTime,nTableEntries)
		
		SetDataFolder ::
	endfor

	description[nTableEntries]= "Test Total"
	IDNum[nTableEntries]= NaN
	groupPct[nTableEntries]= NaN
	totalPct[nTableEntries]= NaN
	avgTime[nTableEntries]= NaN
	totalCalls[nTableEntries]= numpnts(W_DebugTimerVals)
	totalTime[nTableEntries]= totTestTime
	
	nTableEntries += 1

	Redimension/N=(nTableEntries) IDNum, description,groupPct,totalPct,avgTime,totalCalls,totalTime
	
	DoWindow/F $testName
	if( !V_Flag )
		Edit/W=(67,47,740,646) description,IDNum,groupPct,totalPct,avgTime,totalCalls,totalTime
		DoWindow/C $testName
		Execute "ModifyTable size=9,width(Point)=0,alignment(description)=0,width(description)=252"
		Execute "ModifyTable width(IDNum)=48,format(groupPct)=3,digits(groupPct)=2,width(groupPct)=56"
		Execute "ModifyTable format(totalPct)=3,digits(totalPct)=2,width(totalPct)=52,format(avgTime)=4"
		Execute "ModifyTable digits(avgTime)=9,width(avgTime)=84,width(totalCalls)=52"
		Execute "ModifyTable format(totalTime)=4,digits(totalTime)=9,width(totalTime)=84"
	endif
		
	SetDataFolder dfSav	
end

Function ReportStats(groupName,wid,wtimer,wIndexVals,wDescriptions,totTestTime,IDNum,description,groupPct,totalPct,avgTime,totalCalls,totalTime,nTableEntries)
	String groupName
	WAVE wid,wtimer			// id and timer values for this group
	WAVE wIndexVals			// array of all possible ID values
	WAVE/T wDescriptions		// and corresponding text description
	Variable totTestTime
	WAVE IDNum				// output for table
	WAVE/T description			// output for table
	WAVE groupPct,totalPct		// output for table
	WAVE avgTime,totalCalls,totalTime	// output for table
	Variable &nTableEntries	// number of table entries so far
	
	
	Variable i,j,n= numpnts(wid)

	//
	//	Find all unique ID numbers within this group sorted in increasing value
	//
	Duplicate/O wid,uniqueIDs
	Sort uniqueIDs,uniqueIDs
	Variable prev= uniqueIDs[0]
	for(i=1,j=1;i<n;i+=1)
		if( prev != uniqueIDs[i] )
			prev= uniqueIDs[i]
			uniqueIDs[j]= prev
			j+=1
		endif
	endfor
	Variable nGroups= j
	Redimension/N=(nGroups) uniqueIDs
	
//	Print groupName
	description[nTableEntries]= groupName
	IDNum[nTableEntries]= NaN
	groupPct[nTableEntries]= NaN
	totalPct[nTableEntries]= NaN
	avgTime[nTableEntries]= NaN
	totalCalls[nTableEntries]= NaN
	totalTime[nTableEntries]= NaN
	
	nTableEntries += 1
	
	//
	//	For each ID, create a wave of times and along the way, find the total time for the group
	//	The very first item is not counted because its time is not within the group but rather
	//	measures the time between group runs.
	//
	
	Variable totGroupTime= 0
	Variable testID
	String wname

	Variable k
	for(k=0;k<nGroups;k+=1)
		testID= uniqueIDs[k]

		wname= "w"+num2istr(testID)
	
		Make/O/N=(n) $wname
		WAVE wout= $wname
		for(i=0,j=0;i<n;i+=1)
			if( wid[i]==testID )
				wout[j]= wtimer[i]
				j+=1
			endif
		endfor
		Redimension/N=(j) wout
		
		if( k!=0 )
			totGroupTime += sum(wout,-inf,inf)
		endif
	endfor

	//
	//	Finally, create statitics for each ID. The very first item is not of much
	//	use and the numbers will appear bogus. See previous comment group.
	//
	for(k=0;k<nGroups;k+=1)
		testID= uniqueIDs[k]
		String testDesc= wDescriptions[BinarySearch(wIndexVals,testID)]

		wname= "w"+num2istr(testID)
	
		WAVE wout= $wname
		
		Variable grpPct= sum(wout,-inf,inf)*100/totGroupTime
		Variable totPct= sum(wout,-inf,inf)*100/totTestTime
		
		if( k==0 )
			grpPct= NaN
			totPct= NaN
		endif

		description[nTableEntries]= testDesc
		IDNum[nTableEntries]= testID
		groupPct[nTableEntries]= grpPct
		totalPct[nTableEntries]= totPct
		totalCalls[nTableEntries]= numpnts(wout)
		if( k==0 )
			totalTime[nTableEntries]= NaN
			avgTime[nTableEntries]= NaN
		else
			totalTime[nTableEntries]= sum(wout,-inf,inf)
			avgTime[nTableEntries]= totalTime[nTableEntries]/totalCalls[nTableEntries]
		endif
		
		nTableEntries += 1
	endfor
end

Function ExtractTestIDStrs(nb,wIndexVals,wDescriptions)	//	Parse notebook to extract descriptive strings for each ID number
	String nb		// notebook containing code extracts
	WAVE wIndexVals			// destination of ID values
	WAVE/T wDescriptions		// and corresponding descriptions
	//
	Variable i=0,j=0
	Variable isQt= CmpStr(IgorInfo(6)[0,1],"Qt") == 0
	for(j=0;j<4;j+=1)
		Notebook $nb,selection={startOfFile, startOfFile}
		do
			if( j==0 )
				Notebook $nb,findText={"MarkPerfTestTime", 1 }				// user level code
			elseif( j==1 )
				Notebook $nb,findText={"GSTOWDEBUGTIME(", 1 }				// igor source code as used by WaveMetrics' programmers
			elseif( j==2 )
				if( CmpStr(IgorInfo(2)[0,8],"Macintosh") == 0 )
					Notebook $nb,findText={"MSTOWDEBUGTIME(", 1 }			// Mac specific igor source code as used by WaveMetrics' programmers
				else
					Notebook $nb,findText={"WSTOWDEBUGTIME(", 1 }			// Win specific igor source code as used by WaveMetrics' programmers
				endif
			else // j==3
				if( isQt )
					Notebook $nb,findText={"PSTOWDEBUGTIME(", 1 }			// Qt specific igor source code as used by WaveMetrics' programmers
				else
					Notebook $nb,findText={"NPSTOWDEBUGTIME(", 1 }			// nonQt specific igor source code as used by WaveMetrics' programmers
				endif
			endif
			if( V_Flag==0 )
				break
			endif
			GetSelection notebook,$nb,1
			Notebook $nb,selection={(V_endParagraph,V_endPos), endOfChars}
			
			GetSelection notebook,$nb,2
			String s= S_Selection
			
			wIndexVals[i]= str2num(s)
			Variable cmtpos= strsearch(s,"// ",0)
			wDescriptions[i]= s[cmtpos+3,inf]
			i+=1
		while(1)
	endfor
	Variable nIDs= i
	Redimension/N=(nIDs) wIndexVals,wDescriptions
	Sort wIndexVals,wIndexVals,wDescriptions
	return nIDs
end


// *************

Function ShowRawResults(testName)
	String testName

	WAVE W_DebugTimerIDs
	WAVE W_DebugTimerVals
	
	if( !WaveExists(W_DebugTimerIDs) || !WaveExists(root:Packages:PerfTest:$(testName):wDescriptions))
		Abort "Couldn't find test results"
	endif
	
	String dfSav= GetDataFolder(1)
	
	SetDataFolder root:Packages:PerfTest:$testName
	WAVE wIndexVals
	WAVE/T wDescriptions
	SetDataFolder dfSav
	
	Make/O/T/N=(numpnts(W_DebugTimerIDs)) wDebugDescription= wDescriptions[BinarySearch(wIndexVals,W_DebugTimerIDs)]
	Edit/W=(5,42,525,595) W_DebugTimerIDs,W_DebugTimerVals,wDebugDescription
	Execute "ModifyTable format(W_DebugTimerVals)=4,digits(W_DebugTimerVals)=9,width(W_DebugTimerVals)=106,width(wDebugDescription)=216"
end