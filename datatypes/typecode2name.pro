FUNCTION TYPECODE2NAME, typecode

COMPILE_OPT IDL2

CASE typecode OF
   0   : RETURN,  'UNDEFINED'
   1   : RETURN,  'BYTE'
   2   : RETURN,  'INT'
   3   : RETURN,  'LONG'
   4   : RETURN,  'FLOAT'
   5   : RETURN,  'DOUBLE'
   6   : RETURN,  'COMPLEX'
   7   : RETURN,  'STRING'
   8   : RETURN,  'STRUCT'
   9   : RETURN,  'DCOMPLEX'
  10   : RETURN,  'POINTER'
  11   : RETURN,  'OBJREF'
  12   : RETURN,  'UINT'
  13   : RETURN,  'ULONG'
  14   : RETURN,  'LONG64'
  15   : RETURN,  'ULONG64'
  ELSE : MESSAGE, 'Invalid type code'
ENDCASE
END
