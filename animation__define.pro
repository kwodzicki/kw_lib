FUNCTION Animation::Init, outfile, _EXTRA=ex
  COMPILE_OPT IDL2
  ; Call our superclass Initialization method.
  void = self->IDL_Object::Init()
  self.outfile = outfile
  self.tmpfile = '/tmp/idl_video_data.tmp'
;  IF (ISA(ex)) THEN self->SetProperty, _EXTRA=ex
  print, self.tmpid, self.xsize
  RETURN, 1
END

PRO Animation::Cleanup
  COMPILE_OPT IDL2
  ; Call our superclass Cleanup method
  self->IDL_Object::Cleanup
END

FUNCTION Animation::TVRD
  COMPILE_OPT IDL2
  IF self.tmpid EQ 0 THEN BEGIN
    self.xsize = !D.X_VSIZE              ; Get x-size of video
    self.ysize = !D.Y_VSIZE              ; Get y-size of video
    OPENW, oid, self.tmpfile, /GET_LUN   ; Open the temporary output file
    PRINT, oid
    self.tmpid = oid                     ; Set the tmpid value
  ENDIF

  WRITEU, self.tmpid, TVRD(TRUE = 1)     ; Write the data from screen to the temporary file
  self.nframes += 1                      ; Increment the number of frames
END

PRO Animation::SAVE_TVRD
  COMPILE_OPT IDL2
  POINT_LUN, self.tmpid, 0       ; Move back to the beginning of the file
  data = BYTARR(3, self.xsize, self.ysize, self.nframes, /NoZero)
  READU, self.tmpid, data
  FREE_LUN, self.tmpid
  self.tmpid = 0L
;  FILE_DELETE, self.tmpfile
  HELP, data
  WRITE_VIDEO, self.outfile, data, VIDEO_FPS=self.fps
END

PRO Animation::SAVE_FILES
  COMPILE_OPT IDL2
END

FUNCTION Animation::SAVE, fps
  ; Static method.
  ; Note: Cannot use "self" within a static method
  COMPILE_OPT IDL2, static
  self.fps = fps
  IF self.tmpid NE -1 THEN $
    self->SAVE_TVRD $
  ELSE $
    self->SAVE_FILES

END

PRO Animation::GetProperty, OUTFILE = outfile, TMPFILE = tmpfile, TMPID = tmpid, XSIZE = xsize
;  CENTER=center, PI=pi, RADIUS=radius
  ; This method can be called either as a static or instance.
  COMPILE_OPT IDL2, static
  ; If "self" is defined, then this is an "instance".
  IF (ISA(self)) THEN BEGIN
    ; User asked for an "instance" property.
    IF (ARG_PRESENT(outfile)) THEN outfile = self.outfile
    IF (ARG_PRESENT(tmpfile)) THEN tmpfile = self.tmpfile
    IF (ARG_PRESENT(tmpid))   THEN tmpid   = self.tmpid
;    IF (ARG_PRESENT(radius)) THEN radius = self.radius
  ENDIF
END

PRO Animation::SetProperty, CENTER=center, RADIUS=radius
  COMPILE_OPT IDL2
  ; If user passed in a property, then set it.
  IF (ISA(center)) THEN self.center = center
  IF (ISA(radius)) THEN self.radius = radius
END

PRO Animation__define
  COMPILE_OPT IDL2
  void = {Animation, $
  INHERITS IDL_Object, $ ; superclass
  outfile : '', $ ; two-element array
  tmpfile : '', $
  tmpid   : 0L, $
  xsize   : 0S, $
  ysize   : 0S, $
  nframes : 0ULL, $
  fps     : 0S}  ; scalar value
END