PRO BRIDGE_COUNT_CHECK, bridges, ncpu, CLOSE=close, POLL=poll, VERBOSE=verbose
;+
; Name:
;   BRIDGE_COUNT_CHECK
; Pupose:
;   A procedure to block until an IDL bridge instance is finished processing
; Inputs:
;   bridges : List of IDL_IDLBridge instances
;   ncpu    : (Optional) Number of bridges to allow
; Keywords:
;   CLOSE   : Set to wait for all proceses to finish
;   POLL    : Set to floating point number specifying number of seconds
;               to wait in between polling of Bridges for completion
;   VERBOSE : Increase verbosity
; Outputs:
;   The bridges list will be updated
;-

COMPILE_OPT IDL2

IF KEYWORD_SET(close) EQ 1 THEN ncpu = 1																			; If close keyword set, then set ncpu to zero (0)
IF N_ELEMENTS(ncpu)   EQ 0 THEN ncpu = !CPU.HW_NCPU / 2 > 1										; Set default number of cpus; has no effect if close is set
IF N_ELEMENTS(poll)   EQ 0 THEN poll = 1.0																		; Set default polling interval to 1 second

nBridges = N_ELEMENTS(bridges)
WHILE nBridges GE ncpu DO BEGIN																								; While there are an equal or greater number of bridges than ncpu requested
  FOR i = 0, nBridges-1 DO BEGIN																		; Iterate over all bridges
    status = bridges[i].STATUS(ERROR = err)																		; Get status of the bridge
    IF KEYWORD_SET(verbose) THEN PRINT, 'Bridge : ', i, ' Status : ', status	; If verbose keyword set, print some verbose information
    IF status NE 1 THEN BEGIN																									; If status NE 1 then it is done or failed 
      IF status EQ 2 THEN PRINT, 'Completed!' ELSE PRINT, 'Error : ' + err
      bridge = bridges.Remove(i)																							; Remove the bridge instance from the list of bridges
      OBJ_DESTROY, bridge																											; Destroy the bridge object
      nBridges -= 1
      BREAK
    ENDIF
  ENDFOR
  IF nBridges GE ncpu THEN WAIT, poll
ENDWHILE

END
