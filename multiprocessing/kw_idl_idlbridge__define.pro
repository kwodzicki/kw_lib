; This is a subclass for the IDL_IDLBridge class that
; enables passing structures, lists, dictionaries, and hashes
; to and IDLBridge session.

FUNCTION BUILD_COMMAND, var, tag, valVar, tName
;+
; Name:
;   BUILD_COMMAND
; Purpose:
;   Function to build commands to be run in IDLBridge session to 
;   add data to 'unpassable' data types
; Inputs:
;   var    (STRING) : The variable data are to be added to
;   tag    (STRING) : Tag under which data are to be added
;   valVar (STRING) : Name of temporary variable that data are stored under
;                       in the Bridge session
;   tName  (STRING) : Type name of the main variable (i.e., var) data are being
;                       added to
; Keywords:
;   None.
; Returns:
;   string : command to be run under ::Execute
;-
  COMPILE_OPT IDL2, HIDDEN
  IF tName EQ 'STRUCT' THEN BEGIN                                             ; If structure
    cmd  = var + ' = CREATE_STRUCT(' + var + ','                              ; Build up a CREATE_STRUCT() call
    cmd += '"' + tag + '", ' + valVar
    cmd += ')'
  ENDIF ELSE IF tName EQ 'DICTIONARY' OR tName EQ 'HASH' OR tName EQ 'ORDEREDHASH' THEN BEGIN ; If any type of has
    cmd = var + '["' + tag + '"] = ' + valVar                                 ; Place tag in quotes
  ENDIF ELSE IF tName EQ 'LIST' THEN BEGIN                                    ; If list
    cmd = var + '.ADD, ' + valVar                                             ; Use the .ADD method
  ENDIF ELSE $
    MESSAGE, 'Unsupported type: ' + tName                                     ; Else, error

  RETURN, cmd                                                                 ; Return command
END

FUNCTION BUILD_OBJ_INDEX, base, tagIn
;+
; Name:
;   BUILD_OBJ_INDEX
; Purpose:
;   Function to build index into objects given a starting index thing:
;      e.g. have tmp['yes'] and want to get 'no' tag
; Inputs:
;   base (STRING)      : The base variable and index
;   tagIN (STRING,INT) : Index to go deeper
; Keywords:
;   None.
; Returns:
;   string : Updated index
;-
  COMPILE_OPT IDL2, HIDDEN
  tag = (tagIn.TypeCode EQ 7) ? '"' + tagIn + '"' : STRTRIM(tagIn,2)          ; If tagIn is string, wrap in quotes, else convert to string and strip leading/trailing space

  IF STRMID(base, 0, /REVERSE) EQ ']' THEN $                                  ; If last character of base is ]
    new = STRMID(base, 0, STRLEN(base)-1) + ',' + tag + ']' $                 ; Remove last character, append new index, add ]
  ELSE $                                                                      ; Else
    new = base + '[' + tag + ']'                                              ; Add full index
  ;PRINT, 'Updated tag: ' + new                                                ; Verbose info
  RETURN, new                                                                 ; Return new
END


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

PRO KW_IDL_IDLBridge::DelVar, name
;+
; Name:
;   DelVar
; Purpose:
;   Procedure to delete variable in the IDLBridge session
; Inputs:
;   name (STRING) : Name of variable to delete in bridge session
; Keywords:
;   None.
; Outputs:
;   None.
;-
  COMPILE_OPT IDL2, HIDDEN
  self->IDL_IDLBridge::Execute, 'DELVAR, ' + name
END

FUNCTION KW_IDL_IDLBridge::TYPENAME, name
;+
; Name:
;   TYPENAME
; Purpose:
;   Function to get typename of variable in the IDLBridge session
; Inputs:
;   name (STRING) : Name of variable to delete in bridge session
; Keywords:
;   None.
; Outputs:
;   string : typename of the variable
;-
  COMPILE_OPT IDL2, HIDDEN

  varName = '__kw_idl_idlbridge_typename'                                     ; Name for typename variable in session; very obscure so not overwrite
  self->IDL_IDLBridge::Execute, varName + ' = TYPENAME(' + name + ')'         ; Run command to get typename of variable in bridge
  RETURN, self->KW_IDL_IDLBridge::GetVar(varName)                             ; Get typename from bridge and return
END

FUNCTION KW_IDL_IDLBridge::N_ELEMENTS, name
;+
; Name:
;   N_ELEMENTS
; Purpose:
;   Function to get number of elements of variable in the IDLBridge session
; Inputs:
;   name (STRING) : Name of variable to delete in bridge session
; Keywords:
;   None.
; Outputs:
;   int : number of elements in variable
;-
  COMPILE_OPT IDL2, HIDDEN

  varName = '__kw_idl_idlbridge_N_ELEMENTS'                                   ; Obscure variable name so no clash
  self->IDL_IDLBridge::Execute, varName + ' = N_ELEMENTS(' + name + ')'       ; Get n_elements in bridge
  RETURN, self->KW_IDL_IDLBridge::GetVar(varName)                             ; Get n from bridge and return
END

FUNCTION KW_IDL_IDLBridge::TAG_NAMES, name
;+
; Name:
;   TAG_NAMES
; Purpose:
;   Function to get tag names of variable in the IDLBridge session
; Inputs:
;   name (STRING) : Name of variable to delete in bridge session
; Keywords:
;   None.
; Outputs:
;   string : tag names of the variable
;-
  COMPILE_OPT IDL2, HIDDEN

  varName = '__kw_idl_idlbridge_tag_names'                                    ; Name for typename variable in session; very obscure so not overwrite
  self->IDL_IDLBridge::Execute, varName + ' = TAG_NAMES(' + name + ')'        ; Run command to get typename of variable in bridge
  RETURN, self->KW_IDL_IDLBridge::GetVar(varName)                             ; Get typename from bridge and return
END

FUNCTION KW_IDL_IDLBridge::KEYS, name
;+
; Name:
;   KEYS 
; Purpose:
;   Function to get keys of variable in the IDLBridge session
; Inputs:
;   name (STRING) : Name of variable to delete in bridge session
; Keywords:
;   None.
; Outputs:
;   string : tag names of the variable
;-
  COMPILE_OPT IDL2, HIDDEN

  varName = '__kw_idl_idlbridge_tag_names'                                    ; Name for typename variable in session; very obscure so not overwrite
  self->IDL_IDLBridge::Execute, varName + ' = ' + name + '.KEYS()'            ; Run command to get typename of variable in bridge
  RETURN, self->KW_IDL_IDLBridge::GetVar(varName)                             ; Get typename from bridge and return
END

PRO KW_IDL_IDLBridge::SetVar, name, value
;+
; Name:
;   SetVar
; Purpose:
;   Procedure that wraps standard SetVar, adding the ability to copy
;   structures, lists, and various hash types to bridge session
; Inputs:
;   name  (STRING) : name of the variable to use in bridge session
;   value (any)    : value to store under name in bridge
; Keywords:
;   None.
; Outputs:
;   NOne.
;-
  COMPILE_OPT IDL2, HIDDEN
  IF value.TypeCode EQ 8 OR value.TypeCode EQ 11 THEN BEGIN                     ; If structure or object
    sName = '__' + name                                                         ; Set temporary name for structure; don't want to break things in the other session
    tName = TYPENAME(value)                                                     ; Get type name of values
    ;PRINT, 'Input Info:', tName, name, value, FORMAT="(4(A, 1X))"
    IF ISA(value, 'STRUCT') THEN BEGIN                                          ; If is struct
      tName = 'STRUCT'                                                          ; Update typename
      self->IDL_IDLBridge::EXECUTE, sName +'={}'                                ; Initialize temporary structure
      tags = TAG_NAMES(value)                                                   ; Get all tag names for value
    ENDIF ELSE IF ISA(value, 'DICTIONARY') THEN BEGIN                           ; If dict
      self->IDL_IDLBridge::EXECUTE, sName +'=DICTIONARY()'                      ; Initialize temporary dictionary in bridge
      tags = value.Keys()                                                       ; Get all tag names for value
    ENDIF ELSE IF ISA(value, 'HASH') THEN BEGIN
      self->IDL_IDLBridge::EXECUTE, sName +'=HASH()'                            ; Initialize temporary hash
      tags = value.Keys()                                                       ; Get all tag names for value
    ENDIF ELSE IF ISA(value, 'ORDEREDHASH') THEN BEGIN
      self->IDL_IDLBridge::EXECUTE, sName +'=ORDEREDHASH()'                     ; Initialize temporary orderedhash
      tags = value.Keys()                                                       ; Get all tag names for value
    ENDIF ELSE IF ISA(value, 'LIST') THEN BEGIN
      self->IDL_IDLBridge::EXECUTE, sName +'=LIST()'                            ; Initialize temporary list
      tags = BYTARR(value.LENGTH, /NoZero)                                      ; Build random list to act as tags
    ENDIF ELSE $                                                                ; Else error
      MESSAGE, 'Unsupported type: ' + tName
    FOR i = 0, tags.LENGTH-1 DO BEGIN                                           ; Iterate over all tags
      IF tags.TypeCode EQ 1 THEN BEGIN                                          ; If tags are bytes
        tmpVar = STRING(tags[i],FORMAT="('__',I03)")                            ; Build temporary variable name
        self->KW_IDL_IDLBridge::SetVar, tmpVar, value[i]                        ; Copy data to bridge
      ENDIF ELSE BEGIN                                                          ; Else
        tmpVar = '__' + tags[i]                                                 ; Build temporary variable name
        IF tName EQ 'STRUCT' THEN $                                             ; If structure
          self->KW_IDL_IDLBridge::SetVar, tmpVar, value.(i) $                   ; Copy data to bridge
        ELSE $                                                                  ; Else
          self->KW_IDL_IDLBridge::SetVar, tmpVar, value[tags[i]]                ; Copy data to bridge
      ENDELSE
      cmd = BUILD_COMMAND(sName, tags[i], tmpVar, tName)                        ; Generate command for adding newly copied variable to structure
      ;PRINT, 'Command: ' + cmd
      self->IDL_IDLBridge::Execute, cmd                                         ; Run the command to add temporary data to the object
      self->KW_IDL_IDLBridge::DelVar, tmpVar                                    ; Delete the copied data as is now in object; don't need 2 copies
    ENDFOR
    ;PRINT, 'Moving: ' + sName + ' --> ' + name
    self->IDL_IDLBridge::EXECUTE, name  + '=' + sName                           ; Clone data into actual variable name
    self->KW_IDL_IDLBridge::DelVar, sName                                       ; Delete the temporary data as don't need 2 copies
  ENDIF ELSE IF ~ISA(value, /NULL) THEN BEGIN                                   ; For anything but !NULL values
    ;PRINT, 'Setting: ' + name, value 
    self->IDL_IDLBridge::SetVar, name, value                                    ; Set variable using base method
  ENDIF
END

FUNCTION KW_IDL_IDLBridge::GetVar, name 
;+
; Name:
;   GetVar
; Purpose:
;   Procedure that wraps standard GetVar, adding the ability to copy
;   structures, lists, and various hash types from bridge session
; Inputs:
;   name  (STRING) : name of the variable to use in bridge session
; Keywords:
;   None.
; Outputs:
;   NOne.
;-
  COMPILE_OPT IDL2, HIDDEN

  CATCH, Error_Status                                                         ; Catch any errors; go back to here if there is an error

  IF Error_Status NE 0 THEN BEGIN                                             ; If any error
    IF STRMATCH(!ERROR_STATE.MSG, '*IDL_TYP_STRUCT*') THEN BEGIN              ; If error is because structure
      tags = self->KW_IDL_IDLBridge::TAG_NAMES(name)                          ; Get tag names for variable within the session
      data = {}                                                               ; Initialize dictionary to copy data to
      FOR i = 0, tags.LENGTH-1 DO $                                           ; Iterate over all tags
        data = CREATE_STRUCT(data, tags[i], $                                 ; Get data under tag and add to local structure
          self->KW_IDL_IDLBridge::GetVar( name + '.' + tags[i] ) )
    ENDIF ELSE IF STRMATCH(!ERROR_STATE.MSG, '*IDL_TYP_OBJREF*') THEN BEGIN   ; If the error is because tried to copy object
      tName = self->KW_IDL_IDLBridge::TYPENAME( name )                        ; Get type name of object
      ;PRINT, 'Trying to copy object: ' + name + ', TYPE: ' + tName
      IF tName EQ 'LIST' THEN BEGIN                                           ; If copying list
        data = LIST()                                                         ; Initialize local list
        nn = self->KW_IDL_IDLBridge::N_ELEMENTS(name)                         ; Get number of elements in list
        ;PRINT, 'N_ELEMENTS: ', nn
        FOR i = 0, nn-1 DO $                                                  ; Iterate over all elements
          data.ADD, self->KW_IDL_IDLBridge::GetVar( BUILD_OBJ_INDEX(name, i) ); Read in data under give index and add to local list
      ENDIF ELSE BEGIN                                                        ; Else, assume dictionary
        CASE tName OF                                                         ; Check the type name against some cases
          'DICTIONARY'  : data = DICTIONARY()
          'HASH'        : data = HASH()
          'ORDEREDHASH' : data = ORDEREDHASH()
          ELSE          : MESSAGE, 'Unsupported type: ' + tName
        ENDCASE
        keys = self->KW_IDL_IDLBridge::KEYS(name)                             ; Get keys for object
        FOR i = 0, keys.LENGTH-1 DO $                                         ; Iterate over keys
          data[keys[i]] = $                                                   ; Get key and add to object
            self->KW_IDL_IDLBridge::GetVar( BUILD_OBJ_INDEX(name, keys[i]) )
      ENDELSE
    ENDIF ELSE BEGIN                                                          ; Else, there was some other issue
      data = !NULL
      MESSAGE, !ERROR_STATE.MSG, /CONTINUE
    ENDELSE
    CATCH, /CANCEL                                                            ; Cancel error
    RETURN, data                                                              ; Return data
  ENDIF

  ; Note that this part runs first; above runs on error
  ;PRINT, 'Getting var using default method: ' + name
  RETURN, self->IDL_IDLBridge::GetVar(name)
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
  COMPILE_OPT IDL2, HIDDEN
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
