# ICILS-KÄYNNISTIN

CILS-KOE.bat tiedosto läppäreiden työpöydälle.

	- Tarkistaa onko Chrome asennettu 32- vai 64-bittisten ohjelmien kansioon.
	
	- Sammuttaa mahdollisesti jo käynnissä olevaN Chrome-selaimen.
	
	- Tallentaa näytön skaalauksen väliaikaistiedostoon. Jos tiedosto on jo olemassa eikä ole yli päivää vanha, aikaisempaa tiedostoa ei ylikirjotieta. Skaalaus muutetaan arvoon 125 % ja lopussa palautetaan takaisin alkuperäiseen arvoon.
 
	- Samoin tehdään viransäästöasetukselle verkkovirralle. Poistetaan virransäästö käytössä ja lopussa palautetaan alkuperäinen arvo.
	
	- Avataan ICILS-sivusto selaimeen kokoruututilaan.


Näytön skaalauksen muuttamiseen käytetään SetDPI.exe-ohjelmaa https://github.com/imniko/SetDPI
