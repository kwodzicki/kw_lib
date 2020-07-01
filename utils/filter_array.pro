FUNCTION FILTER_ARRAY, array, indices, dimension
;+
; Name:
;   FILTER_ARRAY
; Purpose:
;   IDL function to filter data using indices across given dimension
; Inputs:
;   array     : Array of data to filter
;   indices   : Indices to use for filter
;   dimension : (Optional) Set the dimension to filter over; defaults to first
; Keywords:
;   None
; Returns:
;   Filtered array
;-

COMPILE_OPT IDL2

IF N_ELEMENTS(dimension) EQ 0 THEN dimension = 1

CASE dimension OF
  1    : RETURN, REFORM(array[indices,      *,      *,      *,      *,      *,      *,      *]) 
  2    : RETURN, REFORM(array[      *,indices,      *,      *,      *,      *,      *,      *])
  3    : RETURN, REFORM(array[      *,      *,indices,      *,      *,      *,      *,      *])
  4    : RETURN, REFORM(array[      *,      *,      *,indices,      *,      *,      *,      *])
  5    : RETURN, REFORM(array[      *,      *,      *,      *,indices,      *,      *,      *])
  6    : RETURN, REFORM(array[      *,      *,      *,      *,      *,indices,      *,      *])
  7    : RETURN, REFORM(array[      *,      *,      *,      *,      *,      *,indices,      *])
  8    : RETURN, REFORM(array[      *,      *,      *,      *,      *,      *,      *,indices])
  ELSE : MESSAGE, 'Value for dimension must be 1-8'
ENDCASE

END
