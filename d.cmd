java -jar ./KickAss.jar || goto :error
cd bin
..\C64Debugger -vicesymbols array_test.vs -prg array_test.prg
cd ..
@exit

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
