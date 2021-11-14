/*
    System.......:
    Program......: error_class.prg
    Description..: Error methods class
    Author.......: Sergio Lima
    Updated at...: Nov, 2021
*/

#include "hbclass.ch"
#include "custom_commands_v1.1.0.ch"

CREATE CLASS Error
    EXPORTED:
        METHOD  New() CONSTRUCTOR
        METHOD  Destroy()
        METHOD  getErrorDescription( cParamSql, nParamSqlErrorCode )
        METHOD  getOnErrorMessage( oObject, xParam, cCol )

    HIDDEN:
        METHOD  getOnErrorVariableMessage( oObject, xParam, cCol )
        METHOD  getOnErrorMethodMessage( cCol )

    ERROR HANDLER OnError( xParam )
ENDCLASS

METHOD New() CLASS Error
RETURN Self

METHOD Destroy() CLASS Error
    Self := NIL
RETURN Self

METHOD getErrorDescription( cParamSql, nParamSqlErrorCode ) CLASS Error
    LOCAL cErrorDescription := "", i := 0
    LOCAL cSql := hb_defaultValue(cParamSql, "")
    LOCAL cSqlErrorCode := lTrim(hb_ValToStr(hb_defaultValue(nParamSqlErrorCode, 0)))

    cErrorDescription :=  "SqlErrorCode:" + cSqlErrorCode + "; Sql:" + cSql
    while ( !Empty(ProcName(++i)) )
        cErrorDescription += "; Called from: " + Trim(ProcName(i)) + "(" + ;
            ALLTRIM(STR(ProcLine(i))) + ") - "+ ;
            SubStr(ProcFile(i),RAT("/",ProcFile(i))+1)
    end
RETURN cErrorDescription

METHOD getOnErrorMessage( oObject, xParam, cCol ) CLASS Error
    LOCAL lIsVariable := Left( cCol, 1 ) == "_" // underscore means that it's a variable
    LOCAL xResult := "" //, cErrorMsg :=  "*** Error => "

    xResult := ::getOnErrorVariableMessage( oObject, xParam, cCol ) IF lIsVariable
    xResult := ::getOnErrorMethodMessage( cCol ) UNLESS lIsVariable
RETURN xResult

METHOD getOnErrorVariableMessage( oObject, xParam, cCol ) CLASS Error
    LOCAL xResult := ""
    LOCAL cColName := Right( cCol, Len( cCol ) - 1 )
    LOCAL lObjHasData := __objHasData( oObject, cCol )

    __objAddData( oObject, cColName ) UNLESS lObjHasData
    xResult := __ObjSendMsg( oObject, cColName ) IF xParam == NIL
    xResult := __ObjSendMsg( oObject, "_" + cColName, xParam ) UNLESS NIL
RETURN xResult

METHOD getOnErrorMethodMessage( cCol ) CLASS Error
    LOCAL xResult := "Method not created "
RETURN xResult + cCol

METHOD ONERROR( xParam ) CLASS Error
    LOCAL cCol := __GetMessage(), xResult

    IF Left( cCol, 1 ) == "_" // underscore means it's a variable
       cCol = Right( cCol, Len( cCol ) - 1 )
       IF ! __objHasData( Self, cCol )
          __objAddData( Self, cCol )
       ENDIF
       IF xParam == NIL
          xResult = __ObjSendMsg( Self, cCol )
       ELSE
          xResult = __ObjSendMsg( Self, "_" + cCol, xParam )
       ENDIF
    ELSE
       xResult := "Method not created " + cCol
    ENDIF
    ? "*** Error => ", xResult
RETURN xResult