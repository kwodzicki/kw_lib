FUNCTION RECURSIVE_COPY, inHash
;+
; Name:
;   RECURSIVE_COPY
; Purpose:
;   IDL function to recursively copy a hash/dictionary
; Inputs:
;   inHash : Hash to recursively copy
; Keywords:
;   None.
; Returns:
;   Recursive copy of the input
;-
COMPILE_OPT IDL2

IF ISA(inHash, 'DICTIONARY') THEN $
  out = DICTIONARY() $																													; Dictionary to return at end
ELSE IF ISA(inHash, 'ORDEREDHASH') THEN $
  out = ORDEREDHASH() $
ELSE IF ISA(inHash, 'HASH') THEN $
  out = HASH() $
ELSE $
  MESSAGE, 'Must input dictionary, orderedhash, or hash!'

FOREACH value, inHash, key DO $																								; Iterate over all key/value pairs in input dictionary
  IF ISA(value, 'HASH') THEN $																								; If value from input dictionary in a hash
    out[key] = RECURSIVE_COPY( value ) $																			; Call the recusive_copy function on value and place result under key in out dictionary
  ELSE IF ISA(value, 'LIST') THEN $																						; If value from input is a list
    out[key] = value[*] $																											; Copy list to out directory
  ELSE $																																			; Else
    out[key] = value																													; Copy value to out dictionary

RETURN, out																																		; Return out dictionary

END
