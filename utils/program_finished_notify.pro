PRO PROGRAM_FINISHED_NOTIFY, PROGRAM = program, SOUND = sound
;+
; Name:
;   PROGRAM_FINISHED_NOTIFY
; Purpose:
;   A procedure to run some apple scripts through the command line to
;   generate an OS X 'stock' sound and notification window. A call to this
;   procedure should be the last line of code before END.
; Inputs:
;   None.
; Outputs:
;   Generates and OS X notification window and plays a sound.
; Keywords:
;   PROGRAM  : Set to name of program this procedure is run from to have a 
;               more detailed notification window. Default is to simply say
;               "Program Finished".
;   SOUND    : Set to a number from 0 to n-1, where n is the number of sounds
;               in the /System/Library/Sounds folder on your machine. Default
;               is to use the Glass sound if present. IF NOT present, will use
;               first sound available.
; Author and History:
;   Kyle R. Wodzicki     Created 08 Aug. 2016
;-
COMPILE_OPT IDL2, HIDDEN
text = N_ELEMENTS(program) NE 0 ? +program+' Finished' : 'Program Finished'     ; Set up text to display in notification window
cmd = "osascript -e 'display notification "                                     ; Set beginning of command to run
cmd = cmd + '"' + text + '" with title "IDL"'                                   ; Append the text to display in the notification window to the command
IF FILE_TEST('/System/Library/Sounds', /DIR) THEN BEGIN                         ; IF sounds directory is found
  sounds = FILE_SEARCH('/System/Library/Sounds/*', COUNT=nSounds)               ; Get list of all sounds in the directory
  sounds = ((STRSPLIT(FILE_BASENAME(sounds), '.', /EXTRACT)).ToArray())[*,0]    ; Get only file names (not full paths) and remove the extension
  id = WHERE(STRMATCH(sounds, 'Glass', /FOLD_CASE),CNT)                         ; Find the 'Glass' sound
  noise = CNT EQ 1 ? sounds[id] : sounds[0]                                     ; If found, set noise to default of 'Glass', else use the first sound in list
  IF N_ELEMENTS(sound) GT 0 THEN $                                              ; If sound set by user
    IF sound LT nSounds THEN $                                                  ; Ensure sound number is less than number of sounds
      noise = sounds[sound]                                                     ; Use user sound
  cmd = cmd + ' sound name "' + noise + '"' + "'"                               ; Append the sound to the command
ENDIF ELSE $                                                                    ; If the sounds directory is NOT found
  cmd = cmd + "'"                                                               ; Finish the applescript command
SPAWN, cmd                                                                      ; Run the command
END