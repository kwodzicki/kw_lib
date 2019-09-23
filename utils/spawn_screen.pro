PRO SPAWN_SCREEN, cmdin, name, PUSH = push, PPID = ppid, PID = pid
;+
; Name:
;   SPAWN_SCREEN
; Purpose:
;   An IDL procedure to generate a screen session and push a command to it.
; Inputs:
;   cmdin : The command to push to the screen.
;   name  : Name to use for the screen. If name is already taken, random used.
; Outputs:
;   None.
; Keywords:
;   PUSH : Set this keyword if you just want to push the command to
;          'name' and NOT generate a new screen.     
; Author and History:
;   Kyle R. Wodzicki     Created 06 May 2017
;-
COMPILE_OPT IDL2

IF KEYWORD_SET(push) THEN $
	SPAWN, 'screen -S '+name+' -p 0 -X stuff "'+cmdin+'$(printf \\r)"', r, e $
ELSE BEGIN
	;=== Get and parse list of screens
	SPAWN, ['screen', '-ls'], result, /NoShell
	id = WHERE(STRMATCH(result, '*.'+name+'*', /FOLD_CASE), CNT)
	IF CNT NE 0 THEN name += '_' + STRTRIM(ROUND((RANDOMU(seed, 1))[0]*10^3),2)		; Append random number to screen name
	SPAWN, 'screen -dmS ' + name + ' bash -c "' + cmdin + '"', r, e, PID = pid
	SPAWN, ['screen', '-ls'], result, /NoShell																		; Get a list of the screen sessions
	id = WHERE(STRMATCH(result, '*.'+name+'*', /FOLD_CASE), CNT)									; Find the screen of interest
	IF CNT EQ 1 THEN $
		ppid = STRTRIM( (STRSPLIT(result[id],'.',/EXTRACT))[0], 2 ) $
	ELSE $
		MESSAGE, 'Error getting PPID...this is not good!', /CONTINUE
ENDELSE

IF N_ELEMENTS(e) GT 1 THEN MESSAGE, 'There was an error spawning screen: '+name

END