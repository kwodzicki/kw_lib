FUNCTION JOIN_PNG_SAVE_FILE_CHECK, save_names, num_saveNames_need

;+
; Name:
;    JOIN_PNG_SAVE_FILE_CHECK
; Purpose:
;    A function to check if the number of save paths for the 
;    JOIN_PNG procedure matches the number of files to be written.
;    If they do NOT match, the user is asked what to do and can
;    either 0) use the first file in then save_names array
;    and append numbers to that OR 1) enter an new array containing
;    the correct number of save paths.
; Calling Sequence:
;    result = JOIN_PNG_SAVE_FILE_CHECK(num_save_names, tot_save_names)
; Inputs:
;    num_save_names     : The number of elements in the 'save_names'
;                         input into JOIN_PNG. If it is only one (1)
;                         element, then the png extension (if exists)
;                         is removed and a count is append during
;                         conversion in the JOIN_PNG procedure. If
;                         there is more than one (1) element in input
;                         some checking is done.
;    num_saveNames_need : Total number of files to write. 
; Outputs:
;    An array or single file name is returned.
; Keywords:
;    None.
; Author and History:
;    Kyle R. Wodzicki    Created 21 Aug. 2014.
;
;     MODIFIED 14 Oct. 2014
;       Added check against first dimension of save names for WHILE
;-

COMPILE_OPT IDL2                                                      ;Set compile options

dims = SIZE(save_names,/DIMENSIONS)                                   ;Get dimensions of save names
PRINT, DIMS
PRINT, num_saveNames_need
IF (N_ELEMENTS(save_names) NE 1) THEN BEGIN                           ;If more than one file name
  WHILE (dims[0] NE num_saveNames_need) DO BEGIN                      ;While not enough to name all files
    SPAWN, 'clear'                                                    ;Clear page for output
    PRINT, 'Number of save file names entered does NOT match'         ;Print some error messages
    PRINT, 'the number of files that must be written.'
    PRINT, 'Found '+STRING(N_ELEMENTS(save_names))+' Save Names.'
    PRINT, 'Found '+STRING(num_saveNames_need)+' Files to write.'
    PRINT, ''
    PRINT, 'Would you like to:'
    PRINT, '  0) Use the first save name and append numbers,'
    PRINT, '  1) Enter a new array with the correct number of paths'
    READ, answer
    CASE answer OF
      0    : BEGIN
               save_names=STRSPLIT(save_names[0],'.',/EXTRACT)        ;Remove PNG extension if exist
               save_names=save_names[0]                               ;Don't take png
             END
      1    : BEGIN
               READ, save_names                                       ;Read in new string
               ext = N_ELEMENTS(STRSPLIT(save_names[0],'.',/EXTRACT)) ;If = 2, then extension exists
               IF (ext EQ 1) THEN save_names=save_names+'.png'        ;If no extension , add .png
             END
      ELSE : BEGIN
               PRINT, 'Entry must be zero (0) OR one (1). . .'
               PRINT, 'Will restart prompt'
               WAIT, 1
             END
    ENDCASE
    IF (answer EQ 0) THEN BREAK                                       ;If enter zero (0), break while
  ENDWHILE
ENDIF ELSE BEGIN                                                      ;If only one element
 save_names=STRSPLIT(save_names[0],'.',/EXTRACT)                      ;Remove PNG extension if exist
 save_names=save_names[0]                                             ;Don't take png
ENDELSE
IF ~FILE_TEST(FILE_DIRNAME(save_names[0]),/DIR) THEN $                ;Create save Dir if NOT exist
  FILE_MKDIR, FILE_DIRNAME(save_names[0])
RETURN, save_names                                                    ;Return the save names
END

PRO JOIN_PNG, file_patterns, save_names, $
              VERTICAL = vertical, $
              VERBOSE  = verbose, $
              DELETE   = delete, $
            	FILES    = files

;+
; Name:
;    JOIN_PNG
; Purpose:
;    A procedure to join multiple PNG files together.
;    NOTE that this procedure assumes that all files in all
;    directories are in same order.
; Calling Sequence:
;    JOIN_PNG, ['Ex. 1', 'Ex. 2'], 'test_join'
; Inputs:
;    file_patterns  : Assuming all files are in the same location,
;                     this is an array containing a pattern to search
;                     for to find multiple different files for 
;                     joining. MUST ALSO INCLUDE FILE PATH!
;    save_names      : The full path to save the appended PNG as.
;                     The suffix '.png' is not needed. If this
;                     is a single string, then the number 0 to 
;                     however many files are being created-1 will
;                     be appended. If this contains all the
;                     file names that are to be used
;                     each will be used
; Outputs:
;    A PNG file is created that is a combination of many png files.
; Keywords:
;    VERTICAL    : The default is to append images to the right
;                   of the last image add. Thus the first image in 
;                   the 'file_patterns' array will be on the left
;                   of the image and the last image on the right.
;                   Setting this keyword stacks them vertically with 
;                   the first image on top, last on bottom.
;    VERBOSE      : Increase verbosity.
;    DELETE       : Delete the files that were used to create the
;                   join file.
; Author and History:
;    Kyle R. Wodzicki    Created 21 Aug. 2014
;
;     MODIFIED 14 Oct. 2014
;       Added the keyword FILES. IF this is set, it assumes that
;       files down columns are to be joined
;-

COMPILE_OPT IDL2                                                      ;Set compile options

SPAWN, 'which convert', sh_return, err                                ;Find location of convert
IF (sh_return EQ "") THEN $                                           ;If command not found, message
  MESSAGE, "ImageMagick 'convert' command NOT FOUND!"

files_2_join = [ ]                                                    ;Create empty array

;=====================================================================
;   CREATE A STRUCT WHERE A GIVEN ELEMENT ACROSS ALL TAGS ARE THE
;   FILE PATHS TO STRINGS THAT WILL BE JOINED
IF ~KEYWORD_SET(files) THEN BEGIN
	FOR i = 0, N_ELEMENTS(file_patterns)-1 DO BEGIN                       ;Iterate over all file patters
		file_str      = FILE_BASENAME(file_patterns[i])                     ;Get dir search pattern
		file_path     = FILE_DIRNAME(file_patterns[i])                      ;Get dir to search
		files         = FILE_SEARCH(file_path, file_str)                    ;Get all files matching 
		files_2_join  = [[files_2_join], [files]]                           ;Append current files to array
	ENDFOR
ENDIF ELSE files_2_join = files

dims = SIZE(files_2_join,/DIMENSIONS)                                 ;Get array dims for iterations

;=====================================================================
;    CHECK THAT NUM SAVE NAMES ENTERED MATCH NUMBER OF FILES TO WRITE.
;save_names = JOIN_PNG_SAVE_FILE_CHECK(save_names, files)

;=====================================================================
;   ITERATE OVER NUMBER OF FILES TO CREATE AND NUMBER OF FILES TO JOIN
;   TO CREATE THE CONVERT COMMAND
FOR i = 0, dims[0]-1 DO BEGIN                                         ;Iterate over num files to create
  IF ~KEYWORD_SET(vertical) THEN cmd = 'convert +append ' $           ;Start command for horizontal append
                            ELSE cmd = 'convert -append '             ;Start command for vertical append
  IF KEYWORD_SET(delete) THEN dlt_cmd= 'rm '                          ;Initialize bash rm command
	
  FOR j = 0, dims[1]-1 DO BEGIN                                       ;Iterate over num files to join
    cmd = cmd+files_2_join[i,j]+' '                                   ;Append file to cmd
    IF KEYWORD_SET(delete) THEN dlt_cmd=dlt_cmd+files_2_join[i,j]+' ' ;Append files to delete
  ENDFOR                                                              ;END j
  
  IF (N_ELEMENTS(save_names) EQ 1) THEN BEGIN
    cmd = cmd + save_names+'_'+STRTRIM(i,2)+'.png'                    ;Append out file to command
    IF KEYWORD_SET(verbose) THEN $                                    ;Store file name if verbose output
      prog_fName=FILE_BASENAME(save_names+'_'+STRTRIM(i,2)+'.png')
  ENDIF ELSE BEGIN
    cmd = cmd + save_names[i]                                         ;Use user entered save name
    IF KEYWORD_SET(verbose) THEN $                                    ;Store file name if verbose output
      prog_fName=FILE_BASENAME(save_names[i])
  ENDELSE

  SPAWN, cmd, sh_out, err                                             ;Spawn the shell command
  IF (err NE '') THEN MESSAGE,'PNG Join FAILED!',/CONTINUE            ;Message error from convert
  IF KEYWORD_SET(delete) THEN SPAWN, dlt_cmd, sh_out, err             ;Spawn the shell command to delete source files
  IF (err NE '') THEN MESSAGE,'Delete source files FAILED!',/CONTINUE ;Message error from delete
  
;=====================================================================
;   VERBOSE OUTPUT SECTION
  IF KEYWORD_SET(verbose) THEN BEGIN                                  ;If verbose
    IF (i+1 LT 100) THEN $
      IF (i+1 LT 10) THEN $
        str_i='  '+STRTRIM(i+1,2) $                                   ;Add two leading spaces if LT 10
      ELSE str_i=' '+STRTRIM(i+1,2) $                                 ;Add one leading space if GE 10 LT 100
    ELSE str_i=STRTRIM(i+1,2)                                         ;Add no leading space if GE 100
    
    prog = 'File '+str_i+' of '+STRTRIM(dims[0],2)+$                  ;Create progress string
            ' processed. File name = '+prog_fName
            
    IF (i NE dims[0]-1) THEN format='(A, A, $)' $                     ;Set formating
                        ELSE format='(A, A)'
                        
    PRINT, STRING(13B), prog, format=format                           ;Print progress, 13B is carriage return
  ENDIF 
  
ENDFOR                                                                ;END i
END
