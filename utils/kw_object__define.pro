;+
; Used to make objects act more like python classes
;
; Adpated from:
;   https://www.harrisgeospatial.com/Learn/Blogs/Blog-Details/ArtMID/10198/ArticleID/16800/A-technique-for-flexible-GetSetProperty-methods-in-IDL-8
;-

FUNCTION KW_Object::INIT
  ; Initialize class 
  COMPILE_OPT IDL2

  self.__dict__ = HASH()																											; Initialize hash in the __dict__ key
  RETURN, OBJ_VALID(self.__dict__)																						; Return 1 if object valid
END

PRO KW_Object::SetProperty, _EXTRA=extra
  ; Procedure to set properties in the class
  COMPILE_OPT IDL2

  IF N_ELEMENTS(extra) EQ 0 THEN RETURN																				; If no keys in extra structure, return
  FOREACH val, DICTIONARY(extra), key DO self.__dict__[key] = val							; Convert extra structure to dictionary, iterate over key/value pairs, add value to __dict__ under the key
END

PRO KW_Object::GetProperty, _REF_EXTRA=extra
  ; Procedure to get properties from the class
  COMPILE_OPT IDL2

  IF N_ELEMENTS(extra) EQ 0 THEN RETURN																				; If no keys in extra list, return
  FOR i = 0, N_ELEMENTS(extra)-1 DO $																					; Iterate over keys in extra list
    IF self.__dict__.HasKey( extra[i] ) THEN $																; If the key at extra[i] exists in the __dict__ hash
       ( SCOPE_VARFETCH(extra[i], /REF_EXTRA) ) = self.__dict__[ extra[i] ]		; Generate reference to variable using SCOPE_VARFETCH and store value from __dict__[ key ] in new variable
END

PRO KW_Object__DEFINE
  COMPILE_OPT IDL2
  void_ = {KW_Object, $
    __dict__ : obj_new(), $																										; Object reference under key __dict__; like how python stores class attributes
    INHERITS IDL_Object}																											; Class inherites IDL_Object
END
