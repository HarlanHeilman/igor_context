#pragma rtGlobals=1		// Use modern global access method.
#pragma version=3.01
#include <TranslateChars>
// <WMDataBase Procs>
// v3.01 modified for Windows and avoidance of multi-dimensional index functions.
// v1.01 modified by Phil Parilla for rtGlobal=1 and data folder-awareness
// implements linear database with multiple semi-colon separated categories, and one "current" bag
// Each bag contains a list of comma-separated "items"
//
// An item may be a key=value pair.
// The key is expected to be a single word, just like any other Igor name (it is often the name of a global variable, but it need not be).
// The value may be a string with spaces.
// The value string may contain the , ; = chars by use of the TranslateChars() function to
// replace
//		;	with	¨	decimal 168
//		,	with	©	decimal 169
//		=	with	ª	decimal 170
//		:	with	Ù	decimal 217
// Thus the strings may not originally contain the ¨  ©  ª or Ù characters or they will be unTranslateChars-ed improperly.

// You should not refer to these globals from another procedure window, or you will
// have compilation trouble. Use the GetDataXXX() string functions, below

Proc WMDataBaseGlobalsInit()  //This initializes the package.  RUN THIS FIRST!

	Silent 1
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WMDataBase
	String/g u_dataBase,u_dbCurrBag,u_dbBadStringChars,u_dbReplaceBadChars,u_dbCurrContents,u_str
	SetDataFolder root:
End

Function DefaultWMDataBaseGlobals(explanation)
	String explanation
	
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase	//	"bag0:,<paramWave>,<other items for bag0>,;bag1:...."
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag	// "bag" and ",item1,item2,;" for current bag, or ""
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	SVAR u_dbBadStringChars=root:Packages:WMDataBase:u_dbBadStringChars
	SVAR u_dbReplaceBadChars=root:Packages:WMDataBase:u_dbReplaceBadChars
	
	u_dbBadStringChars=",;=:"			// these can't be in a string value (or in a bag, or item, or key, either)
	u_dbReplaceBadChars="©¨ªÙ"		// use these instead.

	String prompt="Forget everything in u_dataBase? "+explanation
	DoAlert 1,prompt
	if( V_Flag==1 )
		u_dataBase= ""
		u_dbCurrBag= ""
		u_dbCurrContents= ""
	endif
End

// Use these Get and Set routines instead of referring to the global strings
// from another procedure window. These routines were added in v 1.01.
Function/S GetDataBase()
	
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	return u_dataBase
End
Function SetDataBase(str)
	String str
	
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	u_dataBase = str
End

Function/S GetDataBag()
	
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	return u_dbCurrBag
End
Function SetDataBag(str)
	String str
	
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	u_dbCurrBag = str
End

Function/S GetDataContents()
	
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	return u_dbCurrContents
End
Function SetDataContents(str)
	String str
	
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	u_dbCurrContents = str
End

Proc ExamineDataBase(bagName,contents)
	String bagName=root:Packages:WMDataBase:u_dbCurrBag
	String contents
	Prompt bagName,"set new bag:",popup,DataBaseListCategories()
	Prompt contents,"contents of "+root:Packages:WMDataBase:u_dbCurrBag+" bag:",popup,TranslateChars(root:Packages:WMDataBase:u_dbCurrContents,",",";")

	DataBaseCurrentBag(bagName)
End

// puts the current bag and contents back into into the database,
// and extracts the newBagName as the current bag and contents
// returns length of new bag's contents, 0 if error in creating new bag
// Call with newBagName="" to flush current bag and contents back into the database.
Function DataBaseCurrentBag(newBagName)
	String newBagName
	
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	Variable offset
	if( CmpStr(newBagName,u_dbCurrBag)!=0 )
		if( DataBaseNameIsValid(u_dbCurrBag) )	// put current bag back into database
			offset= DataBaseRestoreBag(u_dbCurrBag,u_dbCurrContents)
		endif
		u_dbCurrBag=""
		u_dbCurrContents=""
		if( (DataBaseNameIsValid(newBagName)) %& (DataBaseAddBag(newBagName) > -1) )
			u_dbCurrContents= DataBaseExtractBag(newBagName)
			if( strlen(u_dbCurrContents) > 0 )
				u_dbCurrBag= newBagName
			endif
		endif
	endif
	return strlen(u_dbCurrContents)
End

// Returns truth that there was a current bag to kill
Function DataBaseKillCurrentBag()

	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	Variable killed
	killed= strlen(u_dbCurrBag)>0
	u_dbCurrBag=""
	u_dbCurrContents=""
	return killed
End

// Returns truth there was a bag and (optionally) a key within that bag
// As a side effect, the current bag becomes bagName if it is in the database
Function DataBaseBagAndKeyExist(bagName,key)
	String bagName,key
	
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	Variable exist=0,offset
	if( DataBaseNameIsValid(bagName) )
		if( (CmpStr(bagName,u_dbCurrBag) == 0) %| (DataBaseFindBag(bagName) != -1) )	//  if current bag or bag found in database
			exist=1	// unless key not found
			if( DataBaseNameIsValid(key) )	// check key, too?
				DataBaseCurrentBag	(bagName)			// SIDE EFFECT: sets current bag
				if( strsearch(u_dbCurrContents,","+key+"=",0) == -1 )
					exist= 0	// no key
				endif
			endif
		endif
	endif
	return exist
End

// for instance "Graph0","zeroAngleWhere"
Function/D DataBaseGetBagVariable(bagName,variableKey)
	String bagName,variableKey
	
	Variable/D value=NaN
	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	if( (DataBaseCurrentBag(bagName) > 0) %& (GetKeyEqualValStr(u_dbCurrContents,variableKey)) )
		value= str2num(u_str)
	else
		Abort "Database error: couldn't find "+variableKey+" for bag "+bagName
	endif
	return value
End

// returns truth that variableValue was set
Function DataBaseSetBagVariable(bagName,variableKey,variableValue)
	String bagName,variableKey
	Variable/D variableValue

	String valueAsString
	Variable set=0
	if( DataBaseCurrentBag(bagName) > 0 )
		sprintf valueAsString,"%.15g",variableValue
		SetCurrKeyEqualValStr(variableKey,valueAsString)
		set=1
	endif
	return set
End

Function/S DataBaseGetBagString(bagName,stringKey)
	String bagName,stringKey

	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	String stringValue=""
	if( (DataBaseCurrentBag(bagName) > 0) %& (GetKeyEqualValStr(u_dbCurrContents,stringKey)) )
		stringValue=DataBaseDecodeString(u_str)
	else
		Abort "Database error: couldn't find "+stringKey+" for bag "+bagName
	endif
	return stringValue
End

// returns truth that stringValue was set
Function DataBaseSetBagString(bagName,stringKey,stringValue)
	String bagName,stringKey,stringValue

	Variable set=0
	if( DataBaseCurrentBag(bagName) > 0 )
		stringValue=DataBaseEncodeString(stringValue)
		SetCurrKeyEqualValStr(stringKey,stringValue)
		set=1
	endif
	return set
End

// u_dbCurrContents is assumed to contain comma-separated key=value pairs (the list might be terminated with ";", too).
// Returns offset to where key=value was inserted into u_dbCurrContents
Function SetCurrKeyEqualValStr(key,valueStr)
	String key,valueStr
	
	SVAR u_dbCurrContents=root:Packages:WMDataBase:u_dbCurrContents
	Variable en,offset,len
	key= "," + key + "="
	offset= strsearch(u_dbCurrContents,key,0)
	if( offset >= 0 ) // found key, locate value end (up to next ",")
		len= strlen(key)	// len includes , and =
		en= strsearch(u_dbCurrContents,",",offset+len)
		if( en == -1 )
			en= strsearch(u_dbCurrContents,";",offset+len)
			if(en == -1 )
				en= strlen(u_dbCurrContents)
				u_dbCurrContents+= ";"		// list should be terminated
			endif
		endif
		u_dbCurrContents[offset,en-1]= key+valueStr
	else
		if( CmpStr(u_dbCurrContents[0,0],",") != 0 )
			u_dbCurrContents[0]=","
		endif
		u_dbCurrContents[0]= key+valueStr
		offset=0
	endif
	return offset
End

// returns true if name doesn't contain any invalid chars from u_dbBadStringChars
Function DataBaseNameIsValid(name)
	String name
	
	Variable nameIsValid
	nameIsValid= (strlen(name) > 0) %& (CmpStr(name,DataBaseEncodeString(name))==0)
	return nameIsValid
End

Function/S DataBaseEncodeString(str)
	String str
	
	SVAR u_dbReplaceBadChars=root:Packages:WMDataBase:u_dbReplaceBadChars
	SVAR u_dbBadStringChars=root:Packages:WMDataBase:u_dbBadStringChars
	str= TranslateChars(str,u_dbReplaceBadChars,"")		// delete any database-compatible chars
	return	TranslateChars(str,u_dbBadStringChars,u_dbReplaceBadChars)
End

Function/S DataBaseDecodeString(str)
	String str
	
	SVAR u_dbReplaceBadChars=root:Packages:WMDataBase:u_dbReplaceBadChars
	SVAR u_dbBadStringChars=root:Packages:WMDataBase:u_dbBadStringChars
	return	TranslateChars(str,u_dbReplaceBadChars,u_dbBadStringChars)
End

//returns a semi-colon separated list of categories, suitable for a popup list
Function/S DataBaseListCategories()

	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_dbCurrBag=root:Packages:WMDataBase:u_dbCurrBag
	SVAR u_str=root:Packages:WMDataBase:u_str
	String list=u_dbCurrBag+";"
	Variable offset=0
	do		// u_dataBase format is: ";bagA:,item1,;bagB:,item1,item2,;"
		offset= DataBaseNextBag(offset)
		if( offset == -1 )
			break
		endif		
		list += u_str+";"
	while( 1 )
	return list
End

// NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE
//
// The private functions below are intended only to support the public functions above.
//
// NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE  NOTE

// returns offset for next search, startOffset should initially be 0
// the bag is in the global string u_str
Function DataBaseNextBag(startOffset)
	Variable startOffset
	
	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	u_str=""
	Variable en
	// u_dataBase format is: ";bagA:,item1,;bagB:,item1,item2,;"
	startOffset= strsearch(u_dataBase,";",startOffset)	// start of bag
	if( startOffset != -1 )	//  found
		en= strsearch(u_dataBase,":",startOffset)	// end of bag
		if( en != -1 )	//  found
			u_str= u_dataBase[startOffset+1,en-1]
		endif
		startOffset= en
	endif
	return startOffset
End

// Locates a bag with given name as "<bagName>:".
// If bagName found, returns char position into global u_dataBase just after ":", or -1.
// that is the char position where the first variableKey or stringKey starts.
//
// u_dataBase format is: ";bagA:,item1,;bagB:,item1,item2,;"
// where item is usually "key=value", though it need not be.
Function DataBaseFindBag(bagName)
	String bagName

	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	Variable offset= -1,nameLen
	nameLen= strlen(bagName) 	// doesn't include leading ";", or trailing ":,"
	if( DataBaseNameIsValid(bagName) )
		bagName= ";" + bagName + ":,"
		offset= strsearch(u_dataBase,bagName,0)
		if( offset != -1 )	//  found
			// adjust offset to point at the "," after the bag's trailing ":"
			offset += nameLen + 2	// which is  a good place to search for ",item,"
		endif
	endif
	return offset
End

// Creates or locates a bag with given name as "<bagName>:".
// If bagName found or added successfully, returns char position into global u_dataBase just after ":", or -1.
// that is the char position where the first variableKey or stringKey starts.
//
// u_dataBase format is: ";bagA:,item1,;bagB:,item1,item2,;"
// where item is usually "key=value", though it need not be.
Function DataBaseAddBag(bagName)
	String bagName

	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	Variable offset= -1,nameLen
	nameLen= strlen(bagName) 	// doesn't include leading ";", or trailing ":,"
	if( DataBaseNameIsValid(bagName) )
		if( strlen(u_dataBase) < 5 )	// shortest valid list is ";a:,;"
			u_dataBase= ";"	// so that bag list always ends with ";"
		endif
		offset= DataBaseFindBag(bagName)
		if( offset == -1 )	// not found, insert it at front (where most recently added categories will be found quickest)
			u_dataBase[0]=  ";" + bagName + ":,"	// on first call, will be ";bagName:,;"
			offset=  nameLen + 2	// adjust offset to point at the leading "," after the bag's trailing ":", which is a good place to search for ",key="
		endif
	endif
	return offset
End

// returns entire bag contents ",item1,item2,;", and removes it from database.
// the bag name and following colon are NOT returned.
// returns "" if bag not found.
Function/S DataBaseExtractBag(bagName)
	String bagName
	
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	Variable offset,nextBag
	String bagContents=""
	offset= DataBaseFindBag(bagName)
	if( offset != -1 )	// found bag, extract it
		nextBag= strsearch(u_dataBase,";",offset)	// points at ";" after bagName
		if( nextBag == -1 )
			nextBag=strlen(u_dataBase)-1
		endif
		bagContents=u_dataBase[offset,nextBag]	// doesn't include bag name and colon
		offset-=  strlen(bagName)+1					// points at first char of bagName
		u_dataBase[offset,nextBag]= ""					// remove bag and trailing ";" or till end	
	endif
	return bagContents
End

// returns offset where bag contents were restored, or -1 
Function DataBaseRestoreBag(bagName,bagContents)
	String bagName,bagContents
	
	SVAR u_dataBase=root:Packages:WMDataBase:u_dataBase
	Variable offset,nextBag,lastCharOffset
	offset= DataBaseAddBag(bagName)
	if( offset != -1 )	// found bag, offset points at content start (usually leading ",")
		nextBag= strsearch(u_dataBase,";",offset)	// points at ";" after bagName
		if( nextBag == -1 )
			nextBag=strlen(u_dataBase)-1
		endif
		lastCharOffset=strlen(bagContents)-1
		if( CmpStr(bagContents[lastCharOffset,lastCharOffset],";") != 0 )
			bagContents+=";"								// terminate content properly
		endif
		u_dataBase[offset,nextBag]= bagContents		// replace contents	
	endif
	return offset
End

// str is assumed to contain comma-separated key=value pairs (the list might be terminated with ";", too).
// Return value is truth that the key was found
// Returns the string value string given the corresponding key in u_str
Function GetKeyEqualValStr(str,key)
	String str,key
	
	SVAR u_str=root:Packages:WMDataBase:u_str
	u_str=""
	Variable st,en,found=0
	if( CmpStr(str[0,0],",") != 0 )
		str[0]=","
	endif
	st= strsearch(str,","+key+"=",0)
	if( st >= 0 ) // found key, get value (up to next "," or ";")
		found= 1
		st += strlen(key)+2	// points at first char after "="
		en= strsearch(str,",",st)
		if( en== -1 )			// no terminating , try ;
			en= strsearch(str,";",st)
			if( en== -1 )
				en= strlen(str)	// to allow absence of terminating ;
			endif
		endif
		u_str= str[st,en-1]
	endif
	return found
End


