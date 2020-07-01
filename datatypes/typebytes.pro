FUNCTION TYPEBYTES, type
COMPILE_OPT IDL2

typeCode = ISA(type, 'STRING') ? TYPENAME2CODE(type) : type

CASE typeCode OF
   1   : RETURN,  1B
   2   : RETURN,  2B
  12   : RETURN,  2B
   3   : RETURN,  4B
  13   : RETURN,  4B
   4   : RETURN,  4B
  14   : RETURN,  8B
   5   : RETURN,  8B
  15   : RETURN,  8B
   6   : RETURN,  8B
   9   : RETURN, 16B
  ELSE : RETURN, -1
ENDCASE
END
