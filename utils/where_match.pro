PRO WHERE_MATCH, array_1, array_2, index_1, index_2, N_E=n_e

;+
; Name:
;		WHERE_MATCH
; Purpose:
;		A procedure to return the indices where to to large arrays match.
; Inputs:
;		array_1		: First array of data
;		array_2		: Second array of data
;		index_1		: Indices for first array
;		index_2		: Indices for second array
; Outputs:
;		None.
; Keywords:
;		N_E        : Set to find where NOT equal.
; Author and History:
;		Kyle R. Wodzicki		Created 22 Sep 2014
;
;    MODIFIED 03 Oct. 2014
;      Added NE keyword.
;-

COMPILE_OPT IDL2

index_1 = [] & index_2 = []

FOR i = 0, N_ELEMENTS(array_1)-1 DO BEGIN
  IF ~KEYWORD_SET(n_e) THEN id=WHERE(array_1[i] EQ array_2, COUNT) $
                       ELSE id=WHERE(array_2[i] NE array_1, COUNT)
	IF (COUNT NE 0) THEN BEGIN
		index_1 = [index_1, i]
		index_2 = [index_2, id]
	ENDIF
ENDFOR

END