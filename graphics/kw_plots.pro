PRO KW_PLOTS, x, y, z, OUTLINE=outline, _EXTRA=_extra
COMPILE_OPT IDL2

IF N_ELEMENTS(outline) EQ 1 THEN BEGIN
  extra = DICTIONARY(_extra)
  extra['color'] = outline
  IF extra.HasKey('thick') THEN thick = extra['thick'] ELSE thick = 1
  extra['thick'] = thick + 3
  CASE N_PARAMS() OF
    1 : PLOTS, x,       _EXTRA = extra.ToStruct() 
    2 : PLOTS, x, y,    _EXTRA = extra.ToStruct() 
    3 : PLOTS, x, y, z, _EXTRA = extra.ToStruct() 
  ENDCASE
ENDIF

CASE N_PARAMS() OF
  1 : PLOTS, x,       _EXTRA = _extra 
  2 : PLOTS, x, y,    _EXTRA = _extra 
  3 : PLOTS, x, y, z, _EXTRA = _extra 
ENDCASE

END
