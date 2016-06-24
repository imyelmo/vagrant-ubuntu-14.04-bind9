@echo off
rem build or rebuild virtualbox

rem set version
set /p version=<version

rem get latest tag
for /f "delims=" %%A in ('git describe') do set "latesttag=%%A"


rem check tag
if "%version%" == "%latesttag%" goto tagexists

rem stop and create virtualbox
vagrant halt
if errorlevel 1 goto error

rem commit changes
git add --all
if errorlevel 1 goto error
git commit -m "vagrant-ubuntu-14.04-dns %version%"
git push
if errorlevel 1 goto error
git tag -a %version% -m "vagrant-ubuntu-14.04-dns %version%"
if errorlevel 1 goto error
git push --tags
if errorlevel 1 goto error

rem export virtualbox vm
del *.ova
del *.box
vboxmanage export vagrant-ubuntu-14.04-dns -o vagrant-ubuntu-14.04-dns-%version%.ova
if errorlevel 1 goto error

rem create & push vagrant box
:retry
packer build -force -var 'version=%version%' -var 'token=%ATLAS_TOKEN%' packer-vagrant-ubuntu-14.04-dns.json
if errorlevel 1 goto retry

rem cleanup
del *.ova
del *.box
rmdir packer_cache /s /q

echo "vagrant build successful"
goto end

:error
echo "vagrant build not successful"
goto end

:success
echo "vagrant build successful"
goto end

:tagexists
echo "version %version%" already exists"
goto end

:end
