@echo off

rem Finds the Ruby embedded with Vagrant and executes setup.rb

where /q vagrant.exe

if errorlevel 1 (
    echo "Vagrant doesn't seem to be installed. Please download and install it"
    echo "from http://www.vagrantup.com/downloads.html and re-run setup.bat."
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%F in ('where vagrant.exe') do set vagrant=%%F

"%vagrant%\..\..\embedded\bin\ruby.exe" "%~dp0\support\setup.rb" "%0" %*
