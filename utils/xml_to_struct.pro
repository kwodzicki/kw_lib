FUNCTION XML_TO_STRUCT, filename
;+
; Name:
;   XML_TO_STRUCT
; Purpose:
;   A function to read in an XML file and create a structure
; Inputs:
;   filename : Full path to file to read in.
; Outputs:
;   Returns a structure.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 19 Sep. 2016
;-
COMPILE_OPT IDL2

line = ''
data = {}
OPENR, iid, filename, /GET_LUN, /MORE

WHILE NOT EOF(iid) DO BEGIN
	READF, iid, line
	IF STRMATCH(line, '*<?xml*', /FOLD_CASE) THEN CONTINUE
	IF STRMATCH(line, '*<kml*', /FOLD_CASE) THEN CONTINUE
	tag = (STRJOIN(STRSPLIT(line, '<>', /EXTRACT))[1]
	tmp = {}
	STOP
ENDWHILE

FREE_LUN, iid


END