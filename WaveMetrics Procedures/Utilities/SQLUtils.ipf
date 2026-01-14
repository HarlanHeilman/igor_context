#pragma rtGlobals=1		// Use modern global access method.

#include <SQLConstants>

//===========================================================================================
// The following function can be used for error diagnosis:
Function PrintSQLDiagnostics(handleType,handleRefNum,recordNum) 
	Variable handleType,handleRefNum,recordNum
	
	String SQLState,messageText
	Variable nativeError,result
	
	result=SQLGetDiagRec(handleRefNum,handleType,recordNum,SQLState,nativeError,messageText,512)
	if(result==0)
		printf "SQLState=%s\t NativeError=%g\t Error=%s\r",SQLState,nativeError,messageText
	else
		Switch(result)
			case SQL_SUCCESS_WITH_INFO:
				print "SQL_SUCCESS_WITH_INFO"
			break
			case  SQL_STILL_EXECUTING:
				print "SQL_STILL_EXECUTING"
			break
			case  SQL_ERROR:
				print "SQL_ERROR"
			break
			case  SQL_INVALID_HANDLE:
				print "SQL_INVALID_HANDLE"
			break
			case  SQL_NEED_DATA:
				print "SQL_NEED_DATA"
			break
			case  SQL_NO_DATA:
				print "SQL_NO_DATA"
			break
		endswitch
	endif
End

//===========================================================================================
//	SQLToWaveType(SQLDataType)
//	For a given SQL data type code, returns an Igor type code suitable for use with Make/Y=(<type>).
Function SQLToWaveType(SQLDataType)
	Variable SQLDataType
	
	switch(SQLDataType)
		case SQL_UNKNOWN_TYPE:
			return NaN						// Unknown type
			break
		
		case  SQL_CHAR:
			return 0							// Text
			break
		
		case SQL_NUMERIC:
		case SQL_FLOAT:
		case SQL_REAL:
		case SQL_DECIMAL:
			return 0x02						// Single-precision floating point
			break
		
		case SQL_INTEGER:
		case SQL_BIGINT:
			return 0x20						// Signed 32-bit integer
			break
		
		case SQL_SMALLINT:
			return 0x40						// Signed 16-bit integer
			break
		
		case SQL_DOUBLE:
			return 0x04						// Double-precision floating point
			break
			
		case SQL_DATETIME:
		case SQL_VARCHAR:
		case SQL_TYPE_DATE:
		case SQL_TYPE_TIME:
		case SQL_TYPE_TIMESTAMP:
			return 0							// Text
			break
	endswitch
End

//===========================================================================================
Function/S SQLToWaveTypeStr(SQLDataType)
	Variable SQLDataType
	
	switch(SQLDataType)
		case SQL_UNKNOWN_TYPE:
			return ""
		break
		case  SQL_CHAR:
			return "/T "
		break
		
		case SQL_NUMERIC:
		case SQL_FLOAT:
		case SQL_REAL:
		case SQL_DECIMAL:
			return "/S "
		break
		
		case SQL_INTEGER:
		case SQL_BIGINT:
			return "/i "
		break
		
		case SQL_SMALLINT:
			return "/W "
		break
		
		case SQL_DOUBLE:
			return "/D "
		break
			
		case SQL_DATETIME:
		case SQL_VARCHAR:
		case SQL_TYPE_DATE:
		case SQL_TYPE_TIME:
		case SQL_TYPE_TIMESTAMP:
			return "/T "
		break
	endswitch
End

//===========================================================================================
// The following function reads an SQL result set corresponding to the referenced statement.
// Text and numerical columns are read into text and numeric waves.  There are no test for 
// null data.
Function ParseSQLResults(statementRefNum)
	Variable statementRefNum

	Variable result,columnCount,rowCount,i,j,numVal,indicator
	String dataStr
	
	result=SQLNumResultCols(statementRefNum,columnCount)
	if(result==0)
		Make/O/T/N=(columnCount) outWaveName=""
		Make/O/N=(columnCount) outWaveType=0
		String colName
		Variable dataType,columnSize,decDigits,isNullable
		// Figure out the structure and contents of the SQL result set. 
		for(i=0;i<columnCount;i+=1)
			result=SQLDescribeCol(statementRefNum,i+1,colName,256,dataType,columnSize,decDigits,isNullable)
			if(result)
				PrintSQLDiagnostics(SQL_HANDLE_STMT,statementRefNum,1) 
			else
				outWaveName[i]=UniqueName(CleanupName(colName, 0 ),1,0)
				outWaveType[i]=SQLToWaveType(dataType)
			endif
		endfor

		result=SQLRowCount(statementRefNum,rowCount)
		if(result==0)
			if(rowCount<=0)
				Print "Empty SQL result set."
				return 0
			endif
			
			String cmd
			for(i=0;i<columnCount;i+=1)
				dataType = outWaveType[i]
				if (numtype(dataType) == 0)				// Is this a known output type?
					Make /Y=(dataType) /N=(rowCount) $(outWaveName[i])
				endif
			endfor
			
			// load all rows:
			for(i=0;i<rowCount;i+=1)
				result=SQLFetch(statementRefNum)	
				if(result)
					PrintSQLDiagnostics(SQL_HANDLE_STMT,statementRefNum,1) 
				endif
				
				// read all columns corresponding to the current row:	
				for(j=0;j<columnCount;j+=1)	
					if (NumType(outWaveType[j]) != 0)		// Unknown output type?
						continue								// Skip it.
					endif
					if (outWaveType[j] == 0)					// Text output?
						result=SQLGetDataStr(statementRefNum,j+1,dataStr,512,indicator)
						if(result)
							break
						endif
						Wave/T wt=$outWaveName[j]
						wt[i]=dataStr
					else										// Numeric output.
						result=SQLGetDataNum(statementRefNum,j+1,numVal,indicator)
						if(result)
							break
						endif
						Wave wd=$outWaveName[j]
						wd[i]=numVal
					endif
				endfor
			endfor
				
			if(result==0)
				// Display the table:
				Edit/K=1
				for(i=0;i<columnCount;i+=1)
					AppendToTable $outWaveName[i]
				endfor
			else
				PrintSQLDiagnostics(SQL_HANDLE_STMT,statementRefNum,1)
			endif
		else
			PrintSQLDiagnostics(SQL_HANDLE_STMT,statementRefNum,1) 
		endif
	endif
	
	SQLCloseCursor(statementRefNum);
	
	KillWaves/Z outWaveName,outWaveType
	
	return result
End	

// FixSQLColumnsNames()
// In ODBC 2, the output column names from the SQLColumns call was different from ODBC 3.
// Unfortunately, it appears that the only available SQLite ODBC driver shows ODBC 2 behaviors.
// This routine is called just after calling SQLColumns to convert the ODBC 2 names into ODBC 3 names.
Function FixSQLColumnsNames(nameList)
	String nameList		// Semicolon-separated list of names of waves created by SQLColumns call.
	
	if (WhichListItem("TABLE_QUALIFIER",nameList) >= 0)	// In ODBC 2, the TABLE_CAT column was called "TABLE_QUALIFIER".
		Duplicate/O TABLE_QUALIFIER, TABLE_CAT
		KillWaves/Z TABLE_QUALIFIER
	endif

	if (WhichListItem("TABLE_OWNER",nameList) >= 0)		// In ODBC 2, the TABLE_SCHEM column was called "TABLE_OWNER".
		Duplicate/O TABLE_OWNER, TABLE_SCHEM
		KillWaves/Z TABLE_OWNER
	endif

	if (WhichListItem("PRECISION",nameList) >= 0)			// In ODBC 2, the COLUMN_SIZE column was called "PRECISION".
		Duplicate/O PRECISION, COLUMN_SIZE
		KillWaves/Z PRECISION
	endif

	if (WhichListItem("LENGTH",nameList) >= 0)				// In ODBC 2, the BUFFER_LENGTH column was called "LENGTH".
		Duplicate/O LENGTH, BUFFER_LENGTH
		KillWaves/Z LENGTH
	endif

	if (WhichListItem("SCALE",nameList) >= 0)				// In ODBC 2, the DECIMAL_DIGITS column was called "SCALE".
		Duplicate/O SCALE, DECIMAL_DIGITS
		KillWaves/Z SCALE
	endif
	
	if (WhichListItem("RADIX",nameList) >= 0)				// In ODBC 2, the NUM_PREC_RADIX column was called "RADIX".
		Duplicate/O RADIX, NUM_PREC_RADIX
		KillWaves/Z RADIX
	endif
End

// FixSQLGetTypeInfoNames()
// In ODBC 2, the output column names from the SQLColumns call was different from ODBC 3.
// Unfortunately, it appears that the only available SQLite ODBC driver shows ODBC 2 behaviors.
// This routine is called just after calling SQLGetTypeInfo to convert the ODBC 2 names into ODBC 3 names.
Function FixSQLGetTypeInfoNames(nameList)
	String nameList		// Semicolon-separated list of names of waves created by SQLColumns call.
	
	if (WhichListItem("PRECISION",nameList) >= 0)			// In ODBC 2, the COLUMN_SIZE column was called "PRECISION".
		Duplicate/O PRECISION, COLUMN_SIZE
		KillWaves/Z PRECISION
	endif

	if (WhichListItem("MONEY",nameList) >= 0)				// In ODBC 2, the FIXED_PREC_SCALE column was called "MONEY".
		Duplicate/O MONEY, FIXED_PREC_SCALE
		KillWaves/Z MONEY
	endif

	if (WhichListItem("AUTO_INCREMENT",nameList) >= 0)	// In ODBC 2, the AUTO_UNIQUE_VALUE column was called "AUTO_INCREMENT".
		Duplicate/O AUTO_INCREMENT, AUTO_UNIQUE_VALUE
		KillWaves/Z AUTO_INCREMENT
	endif
End

// ShowSQLTypeInfo()
// Creates a table of data type information returned from the server.
// The main use for this is to see the list of data types supported by the DBMS.
// This list is in the first column of the table created by this function.
// Example:
//		ShowSQLTypeInfo("DSN=IgorDemo1;")
Function ShowSQLTypeInfo(connectionStr)
	String connectionStr			// A connection string identifying the server, database, user ID, and password.
	
	Variable result = 0
	Variable rc
	
	Variable environmentRefNum=-1, connectionRefNum=-1, statementRefNum=-1
	
	try
		rc = SQLAllocHandle(SQL_HANDLE_ENV, 0, environmentRefNum)
		if (rc != SQL_SUCCESS)
			AbortOnValue 1, 1
		endif

		rc = SQLSetEnvAttrNum (environmentRefNum, SQL_ATTR_ODBC_VERSION, 3)
		if (rc != SQL_SUCCESS)
			AbortOnValue 1, 2
		endif

		rc = SQLAllocHandle(SQL_HANDLE_DBC, environmentRefNum, connectionRefNum)
		if (rc != SQL_SUCCESS)
			AbortOnValue 1, 3
		endif
		
		String outConnectionStr
		Variable outConnectionStrRequiredLength
		rc = SQLDriverConnect(connectionRefNum, connectionStr, outConnectionStr, outConnectionStrRequiredLength, SQL_DRIVER_COMPLETE)
		switch(rc)
			case SQL_SUCCESS:
			case SQL_SUCCESS_WITH_INFO:		// SQL Server returns this routinely.
				rc = SQLAllocHandle(SQL_HANDLE_STMT, environmentRefNum, statementRefNum)
				if (rc != SQL_SUCCESS)
					AbortOnValue 1, 4
				endif
				
				rc = SQLGetTypeInfo(statementRefNum, SQL_ALL_TYPES)	// Generates a result set.
				if (rc != SQL_SUCCESS)
					AbortOnValue 1, 5
				endif
				
				SQLHighLevelOp /CONN=(connectionRefNum) /STMT=(statementRefNum) /E=1 ""	// Empty statement - just fetch result set into waves.
				
				FixSQLGetTypeInfoNames(S_waveNames)	// ODBC version 2 drivers used different names from ODBC version 3 drivers. This covers for that difference.
				
				break
	
			// case SQL_SUCCESS_WITH_INFO:
			//	PrintSQLDiagnostics(SQL_HANDLE_DBC,connectionRefNum,1)
			//	Print outConnectionStr
			//	AbortOnValue 1, 6
			//	break
			
			case SQL_NO_DATA:
				// The driver is supposed to return SQL_NO_DATA if the user cancels.
				// However, the MyODBC 3.51.19 driver returns SQL_ERROR, not SQL_NO_DATA in this event.
				Print "User cancelled."
				AbortOnValue 1, 7
				break
			
			default:			// Error
				PrintSQLDiagnostics(SQL_HANDLE_DBC,connectionRefNum,1)
				AbortOnValue 1, 8
				break
		endswitch
	catch
		Print "ShowSQLTypeInfo aborted with code ",V_AbortCode
		result = V_AbortCode
	endtry
	
	if (statementRefNum >= 0)
		SQLFreeHandle(SQL_HANDLE_STMT, statementRefNum)
	endif
	
	if (connectionRefNum >= 0)
		SQLDisconnect(connectionRefNum)
		SQLFreeHandle(SQL_HANDLE_DBC, connectionRefNum)
	endif
	
	if (environmentRefNum >= 0)
		SQLFreeHandle(SQL_HANDLE_ENV, environmentRefNum)
	endif
	
	return result
End