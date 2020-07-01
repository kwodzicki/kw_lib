FUNCTION KW_IDL_IDLBridge::Init, _EXTRA = _extra
;+
; Function to initialize the class
; 
; Inputs:
;   None.
; Keywords:
;   Any keyword accepted by IDL_IDLBridge. Note that a default
;   file path for OUTPUT keyword will be added if none supplied
; Returns:
;   A KW_IDL_IDLBridge instance
;-  
  COMPILE_OPT IDL2
  extra = DICTIONARY( _extra )																								; Convert _extra to local dictionary
  IF extra.HasKey('OUTPUT') EQ 0 THEN BEGIN																		; If extra dictionary does NOT have an OUTPUT key
    output = 'KW_IDL_IDLBridge_' + RANDOM_CHARS(10) + '.log'									; Set log file file
    output = FILEPATH(output, ROOT_DIR=GETENV('HOME'), SUBDIRECTORY='logs')		; Set log file path
    IF FILE_TEST( FILE_DIRNAME(output), /DIR ) EQ 0 THEN $										; If log file directory does NOT exist
      FILE_MKDIR, FILE_DIRNAME(output)																				; Create it
    extra['OUTPUT'] = output																									; Set output key in the local extra dictionary
    _extra = extra.ToStruct(/No_Copy)																					; Convert local extra dictionary to struct and overwrite _extra
  ENDIF
  void = self->IDL_Object::Init()																							; Initialize superclass object
  void = self->IDL_IDLBridge::Init( _EXTRA = _extra )													; Initialize superclass bridge
  startup = GET_STARTUP_TEXT()																								; Get text from startup file
  FOR i = 0, startup.LENGTH-1 DO self->IDL_IDLBridge::Execute, startup[i]			; Iterate over text from startup file and exectue each command in IDLBridge session
  RETURN, 1																																		; Return True, required
END

PRO KW_IDL_IDLBridge::GetProperty, STARTTIME = startTime, ENDTIME = endTime
;+
; Method to get the startTime and endTime properties for timing execution
;
; Inputs:
;   None.
; Keywords:
;   STARTTIME : Set to named variable that will contain execution start time
;                 for latest call to Execute method.
;   ENDTIME   : Set to named variable that will contain execution end time
;                 for latest call to Execute method.
; Returns:
;   None.
;-
  COMPILE_OPT IDL2
  IF ISA(self) THEN BEGIN																											; If class is initialized
    IF ARG_PRESENT(startTime) THEN startTime = self.startTime									; If startTime exists, get startTime
    IF ARG_PRESENT(endTime)   THEN endTime   = self.endTime										; If endTime exists, get endTime
  ENDIF
END

PRO KW_IDL_IDLBridge::SetProperty, STARTTIME = startTime, ENDTIME = endTime
;+
; Method to set the startTime and endTime properties for timing execution
;
; Inputs:
;   None.
; Keywords:
;   STARTTIME : Set to time (in seconds) of latest call to Execute method.
;   ENDTIME   : Set to time (in seconds) of end time of latest call to Execute
; Returns:
;   None.
;-
  COMPILE_OPT IDL2
  IF ISA(startTime) THEN self.startTime = startTime
  IF ISA(endTime)   THEN self.endTime   = endTime
END


PRO KW_IDL_IDLBridge::OnCallback, Status, Error
;+
; Overload the OnCallback method to add getting system time
;
; Inputs:
;   Status :
;   Error  :
; Keywords:
;   None.
; Returns:
;   None.
;-
  COMPILE_OPT IDL2
  self.endTime = SYSTIME(/SECONDS)																						; Set endTime attribute to current system time
  self->IDL_IDLBridge::OnCallback, Status, Error															; Call OnCallback method from superclass
END

PRO KW_IDL_IDLBridge::Execute, IDLStmt, NOWAIT = nowait
;+
; Overload the Execute method to add functionality
;
; Inputs:
;   IDLStmt : String containing the IDL statment to execute
; Keywords:
;   NOWAIT  : Set to have work doen asynchronously
; Returns:
;   None.
;-
  COMPILE_OPT IDL2
  self.startTime = SYSTIME(/SECONDS)																					; Set startTime attribute to current system time
  self->IDL_IDLBridge::SetVar, 'IDLStmt', IDLStmt															; Set IDLStmt inside the bridge
  self->IDL_IDLBridge::Execute, "PRINT, 'Running command: ', IDLStmt"					; Print the statment that will be run so appears in logs
  self->IDL_IDLBridge::Execute, IDLStmt, NOWAIT = nowait											; Execute the statement by calling on superclass
  IF ~KEYWORD_SET(nowait) THEN self.endTime = SYSTIME(/SECONDS)								; If nowait, then set endTime attribute as process is finished
END

PRO KW_IDL_IDLBridge::Cleanup
;+
; Overload the Cleanup method to add functionality
;
; Inputs:
;   None.
; Keywords:
;   None.
; Returns:
;   None.
;-
  COMPILE_OPT IDL2
  self->IDL_IDLBridge::SetVar, "runtime", self.Runtime()											; Set runtime of last call to execute inside the bridge
  self->IDL_IDLBridge::Execute, "PRINT, 'Run time: ', runtime, ' seconds'"		; Print runtime from inside the bridge so flushed to logs
  self->IDL_IDLBridge::Cleanup																								; Call cleanup method of IDL_IDLBridge superclass
  self->IDL_Object::Cleanup																										; Call cleanup method of IDL_Object superclass
END

FUNCTION KW_IDL_IDLBridge::Runtime
;+
; Function to return execution time of last call to Execute method
;-
  COMPILE_OPT IDL2
  RETURN, self.endTime - self.startTime																				; Return difference between endTime and startTime
END

PRO KW_IDL_IDLBridge__define
;+
; Set up Class structure
;-
  COMPILE_OPT IDL2
  void = {KW_IDL_IDLBridge, $
    INHERITS IDL_Object, $
    INHERITS IDL_IDLBridge, $
    startTime : 0.0D, $
    endTime   : 0.0D}
END
