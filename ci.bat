@echo off
rem ci.bat - configure, build, unit-test and package "hello" on Windows.
rem Used both locally and by GitHub Actions (.github/workflows/ci.yml).
rem Deletes nothing except the generated build\ directory (mvn clean).
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

echo.
echo ==^> 1/5 Environment
where java >nul 2>&1 || (echo ERROR: java not found ^(JDK 17+ required^) & exit /b 1)
where mvn  >nul 2>&1 || (echo ERROR: mvn not found ^(Maven 3.9+ required^) & exit /b 1)
java -version
call mvn -v
if errorlevel 1 (echo ERROR: mvn -v failed & exit /b 1)

echo.
echo ==^> 2/5 Configure, compile, unit tests, package (mvn clean verify)
call mvn -B -ntp %MVN_ARGS% clean verify
if errorlevel 1 (echo ERROR: maven build or tests failed & exit /b 1)

echo.
echo ==^> 3/5 Test results
set "REPORT=build\surefire-reports\TEST-ua.lpnu.ki405.hello.CalculatorTest.xml"
if not exist "%REPORT%" (echo ERROR: test report not found: %REPORT% & exit /b 1)
findstr /C:"BasicAddition" "%REPORT%" >nul || (echo ERROR: test BasicAddition did not run & exit /b 1)
echo BasicAddition: found in %REPORT%

echo.
echo ==^> 4/5 Executables -^> build\dist
if not exist build\dist mkdir build\dist
copy /Y build\hello.jar build\dist\hello.jar >nul || (echo ERROR: build\hello.jar not found & exit /b 1)
> build\dist\hello.bat echo @echo off
>> build\dist\hello.bat echo java -jar "%%~dp0hello.jar" %%*

echo.
echo ==^> 5/5 Smoke test
set "OUT="
for /f "usebackq delims=" %%L in (`build\dist\hello.bat`) do set "OUT=%%L"
if not "%OUT%"=="Hello, World!" (echo ERROR: unexpected output: "%OUT%" & exit /b 1)
echo hello says: %OUT%
echo CI RESULT: PASS
exit /b 0
