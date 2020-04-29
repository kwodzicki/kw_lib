FUNCTION KW_IDL_IDLBridge
;+
; Name:
;   KW_IDL_IDLBridge
; Purpose:
;   A wrapper function for initializing an IDL_IDLBridge instanace
;   that will execute a user's IDL_STARTUP script automatically.
;   Note that the script will look for IDL_STARTUP file with a
;   '.bridge' extension first. If one found, that script is run.
;   Otherwise, will run file set by IDL_STARTUP.
; Inputs:
;   None.
; Keywords:
;   None.
; Returns:
;   An IDL_IDLBridge instance with user's IDL_STARTUP script executed
;-
bridge  = IDL_IDLBridge()

startup = GETENV('IDL_STARTUP')
IF startup NE '' THEN BEGIN
  startup_bridge = startup + '.bridge'
  IF FILE_TEST(startup_bridge) EQ 1 THEN startup = startup_bridge
  bridge.Execute, '@' + startup
ENDIF

RETURN, bridge

END
