java -jar ./KickAss.jar zp_test.asm || goto :error
cd bin
..\C64Debugger -vicesymbols zp_test.vs -breakpoints breakpoints.txt -prg zp_test.prg
cd ..
@exit

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
