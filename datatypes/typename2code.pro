FUNCTION TYPENAME2CODE, typename

COMPILE_OPT IDL2

CASE STRUPCASE(typename) OF
  'UNDEFINED' : RETURN,  0B 
  'BYTE'      : RETURN,  1B 
  'INT'       : RETURN,  2B 
  'LONG'      : RETURN,  3B 
  'FLOAT'     : RETURN,  4B 
  'DOUBLE'    : RETURN,  5B 
  'COMPLEX'   : RETURN,  6B 
  'STRING'    : RETURN,  7B 
  'STRUCT'    : RETURN,  8B 
  'DCOMPLEX'  : RETURN,  9B 
  'POINTER'   : RETURN, 10B 
  'OBJREF'    : RETURN, 11B 
  'UINT'      : RETURN, 12B 
  'ULONG'     : RETURN, 13B 
  'LONG64'    : RETURN, 14B 
  'ULONG64'   : RETURN, 15B 
  ELSE        : RETURN, -1
ENDCASE
END