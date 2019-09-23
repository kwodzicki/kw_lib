FUNCTION FILTER_STRUCTURE, in_struct, indices
;+
; Name:
;   FILTER_STRUCTURE
; Purpose:
;   A function to filter every tag in a structure by indices input by user.
;   Will only filter tags that are 1-D; scalars and multi-dimensional arrays
;   are unaffected.
; Inputs:
;   in_struct : Structure to filter.
;   indices   : Indices to filter every tag in the structure by.
; Outputs:
;   A filtered structure.
; Keywords:
;   None.
; Author and History:
;   Kyle R. Wodzicki     Created 21 July 2016
;   
;    Modified:
;      27 Oct. 2016 by Kyle R. Wodzicki
;        Changed to filter only those tags that are one dimensional. All other
;        tags will be unchanged
;-
	COMPILE_OPT IDL2
	IF (N_PARAMS() NE 2) THEN MESSAGE, 'Incorrect number of inputs!'              ; Check the number of inputs
	tags = TAG_NAMES(in_struct)                                                   ; Get names of tags in the structure
	out_struct = {}                                                               ; Initialize empty structure for output
	FOR i = 0, N_TAGS(in_struct)-1 DO $                                           ; Iterate over all tags in input structure
		IF SIZE(in_struct.(i), /N_DIMENSIONS) EQ 1 THEN $
		  out_struct = CREATE_STRUCT(out_struct, tags[i], in_struct.(i)[indices]) $ ; Filter each tag of input structure IF only 1-D and append to output structure 
		ELSE $
		  out_struct = CREATE_STRUCT(out_struct, tags[i], in_struct.(i))            ; ELSE, just append the data
	RETURN, out_struct                                                            ; Return filtered structure
END