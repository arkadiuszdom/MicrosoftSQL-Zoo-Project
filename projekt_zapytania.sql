use Zoo
go

--rozmyte
SELECT klatka_id, liczba_zwierzat, dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','ogromna', liczba_zwierzat) as przynaleznosc
FROM klatki
where dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','ogromna', liczba_zwierzat) > 0

SELECT klatka_id, liczba_zwierzat, dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','du¿a', liczba_zwierzat) as przynaleznosc
FROM klatki
where dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','du¿a', liczba_zwierzat) > 0

SELECT klatka_id, liczba_zwierzat, dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','ma³a', liczba_zwierzat) as przynaleznosc
FROM klatki
where dbo.zapytanie_rozmyte('klatki', 'liczba_zwierzat','ma³a', liczba_zwierzat) > 0


--Biomy o "przeciêtnej" wilgotonoœci i "ciep³ej" temperaturze
SELECT nazwa, wilgotnosc, temperatura, dbo.minimum(dbo.zapytanie_rozmyte('biomy', 'wilgotnosc', 'przeciêtny', wilgotnosc), dbo.zapytanie_rozmyte('biomy', 'temperatura', 'ciep³y', temperatura)) as przynaleznosc
FROM biomy
WHERE dbo.minimum(dbo.zapytanie_rozmyte('biomy', 'wilgotnosc', 'przeciêtny', wilgotnosc), dbo.zapytanie_rozmyte('biomy', 'temperatura', 'ciep³y', temperatura))>0


--Klatki, w ktorych panuje o "wilgotna" wilgotonoœæ lub "niska" temperatura
SELECT klatka_id, wilgotnosc, temperatura, dbo.maksimum(dbo.zapytanie_rozmyte('biomy', 'wilgotnosc', 'wilgotny', wilgotnosc), dbo.zapytanie_rozmyte('biomy', 'temperatura', 'zimny', temperatura)) as przynaleznosc
FROM biomy, klatki, pawilony
WHERE klatki.pawilon_id = pawilony.pawilon_id and pawilony.biom_id = biomy.biom_id and dbo.maksimum(dbo.zapytanie_rozmyte('biomy', 'wilgotnosc', 'wilgotny', wilgotnosc), dbo.zapytanie_rozmyte('biomy', 'temperatura', 'zimny', temperatura))>0


--Zwierzêta, które nie mieszkaj¹ we w³aœciwym biomie
SELECT zwierze_id, imie, gatunki.nazwa, zwierzeta.klatka_id
FROM zwierzeta, gatunki, klatki, pawilony
WHERE gatunki.gatunek_id = zwierzeta.gatunek_id AND zwierzeta.klatka_id = klatki.klatka_id AND klatki.pawilon_id = pawilony.pawilon_id
		AND pawilony.biom_id <> gatunki.biom_id

--Pracownicy nie zajmuj¹cy siê ¿adn¹ klatk¹
SELECT *
FROM pracownicy
WHERE NOT EXISTS (select * from pracownicy_klatki where pracownicy_klatki.pracownik_id = pracownicy.pracownik_id)

--Pracownicy obs³uguj¹cy wszystkie klatki z lwami
SELECT *
FROM pracownicy
WHERE NOT EXISTS(
		SELECT *
		FROM klatki
		WHERE gatunek_id = 
				(SELECT gatunek_id
				FROM gatunki
				WHERE nazwa = 'Lew')
						AND NOT EXISTS	
							(SELECT *
							FROM pracownicy_klatki
							WHERE pracownik_id = pracownicy.pracownik_id and klatka_id = klatki.klatka_id))

--Liczba zwierz¹t, któr¹ opiekuje siê ka¿dy pracownik posortowana malej¹co
SELECT pracownik_id, COUNT(zwierze_id) as liczba_zwierzat 
FROM zwierzeta, pracownicy, klatki
WHERE zwierzeta.klatka_id = klatki.klatka_id AND klatki.klatka_id in (select klatka_id
																		from pracownicy_klatki
																		where pracownik_id = pracownicy.pracownik_id)
GROUP BY pracownik_id
ORDER BY liczba_zwierzat DESC

--Zwierzêta, które nie maj¹ imion
SELECT zwierze_id, nazwa as gatunek, klatka_id
FROM zwierzeta, gatunki
WHERE zwierzeta.gatunek_id =  gatunki.gatunek_id AND imie is null

--Gatunki zwierz¹t, które s¹ w wiêcej ni¿ jednym pawilonie
SELECT nazwa as gatunek
FROM gatunki
WHERE (SELECT COUNT(gatunek_id) from klatki where gatunek_id = gatunki.gatunek_id) > 1

--Ile zwierz¹t przyby³o do zoo w ka¿dym roku, pososrtowane po roku malej¹co
SELECT YEAR(data_przybycia) as rok,COUNT(zwierze_id) as liczba_zwierz¹t
FROM zwierzeta
GROUP BY YEAR(data_przybycia)
ORDER BY rok DESC


--Najstarsze zwierze
SELECT zwierze_id, imie, datediff(year, data_urodzenia, getdate()) as wiek
FROM zwierzeta
WHERE data_urodzenia is not null and data_urodzenia = (SELECT MIN(data_urodzenia)
														FROM zwierzeta
														WHERE data_urodzenia is not null)

--Zwierzêta, które s¹ starsze ni¿ wynosi œredni wiek dla ich gatunku
SELECT zwierze_id, nazwa as gatunek, datediff(year, data_urodzenia, getdate()) as wiek
FROM zwierzeta, gatunki
WHERE zwierzeta.gatunek_id = gatunki.gatunek_id and 
		data_urodzenia is not null and datediff(year, data_urodzenia, getdate()) > (SELECT AVG(datediff(year, data_urodzenia, getdate()))
													FROM zwierzeta
													WHERE gatunek_id = gatunki.gatunek_id and data_urodzenia is not null)


--Klatki z wolnymi miejscami i liczba miejsc w nich
SELECT klatka_id, pawilon_id, nazwa as gatunek, liczba_zwierzat - (SELECT COUNT(zwierze_id) 
												FROM zwierzeta 
												WHERE klatka_id = klatki.klatka_id) as liczba_miejsc
FROM klatki, gatunki 
WHERE klatki.gatunek_id = gatunki.gatunek_id and liczba_zwierzat > (SELECT COUNT(zwierze_id) 
												FROM zwierzeta 
												WHERE klatka_id = klatki.klatka_id)

--Klatki, w których wystêpuje zwierze przyby³e w tym roku
SELECT klatki.klatka_id, nazwa as gatunek
FROM klatki, gatunki,zwierzeta
WHERE klatki.gatunek_id = gatunki.gatunek_id AND klatki.klatka_id = zwierzeta.klatka_id and YEAR(data_przybycia) = YEAR(getdate())

--Zwierzêta przebywaj¹ce w zoo od dnia urodzenia
SELECT zwierze_id, imie, nazwa as gatunek
FROM zwierzeta, gatunki
WHERE zwierzeta.gatunek_id = gatunki.gatunek_id AND data_urodzenia is not null AND datediff(day, data_przybycia, data_urodzenia) = 0

--Liczba pawilonów odtwarzaj¹ca ka¿dy z biomów 
SELECT nazwa, count(pawilon_id) as liczba_pawilonow
FROM pawilony, biomy
WHERE pawilony.biom_id = biomy.biom_id 
GROUP BY nazwa

