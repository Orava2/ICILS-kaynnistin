@echo off
SETLOCAL EnableDelayedExpansion

REM ICILS-KÄYNNISTIN
REM ICILS-KOE.bat tiedosto läppäreiden työpöydälle.
REM Bat-tiedosto:
REM		- Tarkistaa onko Chrome asennettu 32- vai 64-bittisten ohjelmien kansioon.
REM		- Sammuttaa mahdollisesti jo käynnissä olevaN Chrome-selaimen.
REM		- Tallentaa näytön skaalauksen väliaikaistiedostoon. Jos tiedosto on jo olemassa eikä ole yli päivää vanha,
REM		  aikaisempaa tiedostoa ei ylikirjotieta. Skaalaus muutetaan arvoon 125 % ja lopussa palautetaan takaisin alkuperäiseen arvoon.
REM 	- Samoin tehdään viransäästöasetukselle verkkovirralle. Poistetaan virransäästö käytössä ja lopussa palautetaan alkuperäinen arvo.
REM		- Avataan ICILS-sivusto selaimeen kokoruututilaan.
REM Näytön skaalauksen muuttamiseen käytetään SetDPI.exe-ohjelmaa https://github.com/imniko/SetDPI


REM -----------------------------------------------------------------------------------------------
REM Tarkistetaan kaksi Chromen asennussijaintia ja otetaan polku talteen.
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
	echo Chrome loytyi: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
	set "chromePath=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
) else (
	if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
		echo Chrome loytyi: "C:\Program Files\Google\Chrome\Application\chrome.exe"
		set "chromePath=C:\Program Files\Google\Chrome\Application\chrome.exe"
		echo x64
	) else (
		echo Chromea ei loytynyt!
		pause
	)
)

rem del "%temp%\originalACStandby.tmp"
rem del "%temp%\originalScale.tmp"

REM -----------------------------------------------------------------------------------------------
REM Sulje valmiina aukiolevat Chrome-selaimet
taskkill /F /IM "chrome.exe">nul 2>&1

REM -----------------------------------------------------------------------------------------------
REM Poistetaan tiedostoihin aikaisemmin tallennetut arvot, jos tiedosto on yli päivän vanha.
if exist "%temp%\originalScale.tmp" (
	echo Tiedosto %temp%\originalScale.tmp on jo olemassa ja se poistetaan, jos se on yli paivan vanha."
	forfiles /m "%temp%\originalScale.tmp" /c "cmd /c del @path " /d -1
) 

if exist "%temp%\originalACStandby.tmp" (
	echo Tiedosto %temp%\originalACStandby.tmp on jo olemassa ja ja se poistetaan, jos se on yli paivan vanha."
	forfiles /m "%temp%\originalACStandby.tmp" /c "cmd /c del @path " /d -1
)


REM Otetaan talteen näytön alkuperäinen skaalaus ja tallennetaan se tiedostoon.
for /f "tokens=3" %%a in ('SetDpi.exe get ^| findstr /I resolution') do (set "originalScale=%%a")

echo originalScale: "%originalScale%"

if exist "%temp%\originalScale.tmp" (
	set /p readTemp1=<"%temp%\originalScale.tmp"
	echo Tiedosto %temp%\originalScale.tmp on jo olemassa ja siihen on tallennettu arvo: "!readTemp1!"
) else (
	>"%temp%\originalScale.tmp" echo !originalScale!
)

REM Aseta Windowsin skaalaus arvoon 125 %
c:\windows\SetDpi.exe 125


REM -----------------------------------------------------------------------------------------------
REM Ota talteen alkuperäinen standby-timeout-ac
for /f "tokens=4" %%a in ('powercfg /GETACTIVESCHEME ^| findstr /I GUID') do (set "powerScheme=%%a")
echo powerScheme: "%powerScheme%"

for /f "tokens=6" %%a in ('powercfg /Q %powerScheme% 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da ^| findstr /I /C:"Current AC Power Setting Index"') do (set "currentACIndex=%%a")
echo Current AC Power Setting Index: "%currentACIndex%"
set /A currentACIndex=currentACIndex
echo In seconds: "%currentACIndex%"
set /A currentACIndex=currentACIndex/60
echo In minutes: "%currentACIndex%"

if exist "%temp%\originalACStandby.tmp" (
	set /p readTemp2=<"%temp%\originalACStandby.tmp"
	echo Tiedosto %temp%\originalACStandby.tmp on jo olemassa ja siihen on tallennettu arvo: "!readTemp2!"
) else (
	>"%temp%\originalACStandby.tmp" echo !currentACIndex!
)

REM Poista koneen virransäästä, kun virtalähde käytössä
powercfg /change standby-timeout-ac 0

REM -----------------------------------------------------------------------------------------------
REM Avaa koesivu
REM "%chromePath%" -incognito --start-maximized --no-default-browser-check --new-window hop.norssi.fi/icils
"%chromePath%" -incognito --start-maximized --start-fullscreen --no-default-browser-check --new-window <url>


REM -----------------------------------------------------------------------------------------------
REM Palauta käytöön virransäästöasetus 30 minuuttia.
set /p readACStandby=<"%temp%\originalACStandby.tmp"
REM Jos arvo ei ole positiivinen kokonaisluku, asetetaan arvo 150
IF 1%%readACStandby%% NEQ +1%%readACStandby%% (
	set %readACStandby%=30
)
echo powercfg /change standby-timeout-ac %readACStandby%
powercfg /change standby-timeout-ac %readACStandby%

REM Palauta alkupernainen skaalausasetus
set /p readScale=<"%temp%\originalScale.tmp"
REM Jos arvo ei ole positiivinen kokonaisluku, asetetaan arvo 150
IF 1%readScale% NEQ +1%readScale% (
	set readScale=150
)

echo c:\windows\SetDpi.exe %readScale%
c:\windows\SetDpi.exe %readScale%

echo Loppu




