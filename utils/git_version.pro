FUNCTION GIT_VERSION, pathIn

path = FILE_TEST(pathIn) ? FILE_DIRNAME(pathIn) : pathIn
cmd = "cd " + path + "; git branch | grep \* | cut -d ' ' -f2"

SPAWN, cmd, res, err
IF (err EQ '') THEN $
  RETURN, res $
ELSE $
  MESSAGE, err
END
