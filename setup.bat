@echo off

where /q vagrant.exe

if errorlevel 1 (
    echo "Vagrant doesn't seem to be installed. Please download and install it"
    echo "from http://www.vagrantup.com/downloads.html and re-run setup.bat."
    echo.
    pause
    exit /b 1
)

vagrant config --required

echo.
echo "You're all set! Simply run `vagrant up` to boot your new environment."
echo "(Or try `vagrant config --list` to see what else you can tweak.)"
