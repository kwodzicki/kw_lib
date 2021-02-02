FUNCTION KW_PROCESS::Init, func, $
     arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
    arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, $
    arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, $
    arg31, arg32, arg33, arg34, arg35, arg36, arg37, arg38, arg39, arg40, $
    arg41, arg42, arg43, arg44, arg45, arg46, arg47, arg48, arg49, arg50, $
    IS_FUNCTION = is_function, $
    _EXTRA = kwargs

  COMPILE_OPT IDL2

  void = self->KW_Object::Init()
  IF N_PARAMS() LT 1 THEN $
    MESSAGE, 'Must at least input function/procedue to run!!!', /CONTINUE 

  args = LIST()
  FOR i = 1, N_PARAMS()-1 DO $                                                ; Iterate from 1 to 1 less total number of arguments; there is one argument for function name
    args.ADD, SCOPE_VARFETCH('arg'+STRTRIM(i,2))

  self->SetProperty, $
    FUNC        = func, $
    ARGS        = args, $
    KWARGS      = kwargs, $
    IS_FUNCTION = KEYWORD_SET(is_function), $
    IS_ALIVE    = -1

  RETURN, 1B
END

FUNCTION KW_Process::Get_Result, ARGS = args, KWARGS = kwargs
  COMPILE_OPT IDL2, HIDDEN
  self.GetProperty, BRIDGE=bridge, ARGNAMES=argnames, KWARGNAMES=kwargnames
  IF N_ELEMENTS(argnames) GT 0 THEN BEGIN
    args   = LIST()
    FOR i = 0, argnames.LENGTH-1 DO $
      args.ADD, bridge.GetVar( argnames[i] )
  ENDIF ELSE $
    args = -1

  IF N_ELEMENTS(kwargnames) GT 0 THEN BEGIN
    kwargs = {}
    FOR i = 0, kwargnames.LENGTH-1 DO $
      kwargs = CREATE_STRUCT(kwargs, kwargnames[i], $
                 bridge.GetVar( '__kw_process_kwarg_'+kwargnames[i] ) )
  ENDIF ELSE $
    kwargs = -1

  IF KEYWORD_SET(self.__dict__['IS_FUNCTION']) THEN $                         ; If is a function
    RETURN, bridge.GetVar( '__kw_process_result' )                            ; Get result and return it
 
  RETURN, !NULL                                                               ; If made here, then was procedure so just return

END

PRO KW_PROCESS::Start, bridge
;+
; Name:
;   START
; Purpose:
;   Procedure to actually start the process. Calling the method will
;   initialize an IDL bridge instance (if one not provided), copy
;   required arguments and keyword arguments data to the new process, and
;   run the requested function/procedure.
; Inputs:
;   bridge (KW_IDL_IDLBridge) : Optional, an existing bridge to run the
;     process on; Intended to be used with the KW_POOL class.
;     IF YOU DON'T KNOW WHAT THIS DOES, DON'T PLAY WITH IT!!!
; Keywords:
;   None.
; Outputs:
;   bridge  : on end will contain reference to KW_IDL_IDLBridge object
;-
  COMPILE_OPT IDL2
  self.SetProperty, IS_ALIVE = 1
  IF N_ELEMENTS(bridge) EQ 0 THEN bridge = KW_IDL_IDLBridge()
  cmd    = self.__dict__['FUNC']
  IF KEYWORD_SET(self.__dict__['IS_FUNCTION']) THEN $
    cmd = '__kw_process_result = ' + cmd + '(' $
  ELSE $ 
    cmd += ','

  allArgs = []
  vNames  = []
  IF self.__dict__.HasKey('ARGS') THEN BEGIN
    FOR i = 0, N_ELEMENTS(self.__dict__['ARGS'])-1 DO BEGIN
      vName  = '__kw_process_arg_' + STRTRIM(i, 2)
      vNames = [vNames, vName]
      bridge.SetVar, vName, self.__dict__['ARGS',i] 
    ENDFOR
    self.SetProperty, ARGNAMES = vNames
    IF N_ELEMENTS(vNames) GT 0 THEN $
      allArgs = [allArgs, vNames]
  ENDIF

  IF self.__dict__.HasKey('KWARGS') THEN $
    IF N_TAGS( self.__dict__['KWARGS'] ) GT 0 THEN BEGIN
      tags = TAG_NAMES(self.__dict__['KWARGS'])
      vNames = []
      tmp    = []
      FOR i = 0, tags.LENGTH-1 DO BEGIN                                       ; Iterate over all keywords 
        vName  = '__kw_process_kwarg_' + tags[i]                              ; Define variable name of inside bridge; don't want clashes
        vNames = [vNames, tags[i]]                                            ; Add keyword variable name to vNames array
        tmp = [ tmp, tags[i] + '=' + vName ]                                  ; Build keyword call for command
        bridge.SetVar, vName, ( self.__dict__['KWARGS'] ).(i)                 ; Set variable in bridge
      ENDFOR 
      self.SetProperty, KWARGNAMES = vNames                                   ; Add list of variable names to class __dict__ under kwargnames
      IF N_ELEMENTS(tmp) GT 0 THEN $
        allArgs = [allArgs, tmp]
    ENDIF
  IF N_ELEMENTS(allArgs) GT 0 THEN $
    cmd += STRJOIN(allArgs, ',')

  IF KEYWORD_SET(self.__dict__['IS_FUNCTION']) THEN cmd += ')'
  bridge.Execute, cmd, /NoWait

  self.SetProperty, BRIDGE = bridge
END

FUNCTION KW_Process::Status, ERROR = error
  self.getProperty, BRIDGE = bridge
  IF N_ELEMENTS(bridge) NE 0 THEN $
    RETURN, bridge.STATUS(ERROR = error)
  RETURN, -1
END

FUNCTION KW_Process::Is_Alive, ERROR = error
  COMPILE_OPT IDL2, HIDDEN
  self.GetProperty, IS_ALIVE= state
  IF state EQ -1 THEN BEGIN
    MESSAGE, 'Process not started yet!'
    RETURN, 0B
  ENDIF ELSE IF state EQ 1 THEN BEGIN
    self.GetProperty, BRIDGE = bridge
    state = bridge.Status(ERROR = error)
    IF state GT 1 THEN BEGIN
      self.SetProperty, IS_ALIVE = 0
      IF error NE '' THEN MESSAGE, error, /CONTINUE
      RETURN, 0B
    ENDIF ELSE $
      RETURN, 1B
  ENDIF
  RETURN, 0B
END

FUNCTION KW_Process::Join, timeout, ARGS = args, KWARGS = kwargs
  COMPILE_OPT IDL2
  self.GetProperty, BRIDGE = bridge
  IF ~ISA(bridge, 'KW_IDL_IDLBridge') THEN BEGIN
    MESSAGE, 'Already joined process, cannot join again!!!', /CONTINUE
    RETURN, -1
  ENDIF

  maxTimeout = 2ULL^64-1ULL 
  IF N_ELEMENTS(timeout) EQ 0 THEN $
    counter = maxTimeout $
  ELSE IF timeout GT maxTimeout THEN $
    counter = maxTimeout $
  ELSE $
    counter = ULONG64(timeout)

  WHILE (counter NE 0) AND self.Is_Alive() DO BEGIN
    WAIT, 1
    counter -= 1
  ENDWHILE
  IF counter EQ 0 THEN BEGIN
    MESSAGE, 'Timedout before completion!', /CONTINUE
    RETURN, 0B
  ENDIF ELSE BEGIN
    res = self.Get_Result(ARGS = args, KWARGS = kwargs)
    OBJ_DESTROY, bridge
    RETURN, res
  ENDELSE
END

PRO KW_Process::Close
  COMPILE_OPT IDL2
  IF self.Is_Alive() THEN BEGIN
    MESSAGE, 'Process still running!', /CONTINUE
    RETURN
  ENDIF

  self.getProperty, BRIDGE = bridge
  IF TYPENAME(bridge) EQ 'KW_IDL_IDLBridge' THEN OBJ_DESTROY, bridge
END

PRO KW_Process::Cleanup
  COMPILE_OPT IDL2, HIDDEN
  self.getProperty, BRIDGE = bridge
  IF TYPENAME(bridge) EQ 'KW_IDL_IDLBridge' THEN OBJ_DESTROY, bridge
  self->IDL_Object::cleanup
END
 
PRO KW_PROCESS__define
  COMPILE_OPT IDL2
  void = {KW_PROCESS, $
    INHERITS KW_Object}
END
