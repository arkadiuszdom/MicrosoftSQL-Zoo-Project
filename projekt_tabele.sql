
if exists(select 1 from master.dbo.sysdatabases where name = 'Zoo') drop database Zoo
GO
CREATE DATABASE Zoo
GO

CREATE TABLE Zoo..wartosci_rozmyte(
	tabela varchar(30) NOT NULL,
	atrybut varchar(30) NOT NULL,
	zmienna_lingwistyczna varchar(30) NOT NULL,
	a int NOT NULL,
	b int NOT NULL,
	c int NOT NULL,
	d int NOT NULL,
	PRIMARY KEY(tabela, atrybut, zmienna_lingwistyczna),
	CHECK (a<=b and b<=c and c<=d)
);
GO




CREATE TABLE Zoo..pracownicy (
    pracownik_id int NOT NULL ,
	imie varchar(30) NOT NULL,	
	nazwisko varchar(30) NOT NULL,
	stanowisko varchar(30) NOT NULL,
    PRIMARY KEY (pracownik_id)
);
GO

CREATE TABLE Zoo..biomy (
    biom_id int NOT NULL,
	nazwa varchar(30) NOT NULL,
	temperatura int NOT NULL,
	wilgotnosc int NOT NULL,
    PRIMARY KEY (biom_id)
);
GO

CREATE TABLE Zoo..pawilony (
    pawilon_id int NOT NULL,
	biom_id int NOT NULL,
    PRIMARY KEY (pawilon_id),
	foreign key(biom_id) references biomy(biom_id)
);
GO
CREATE TABLE Zoo..gatunki (
    gatunek_id int NOT NULL,
	nazwa varchar(30) NOT NULL,
	wiek_dojrzalosci int NOT NULL,
	biom_id int NOT NULL,
    PRIMARY KEY (gatunek_id),
	foreign key(biom_id) references biomy(biom_id)
);
GO

CREATE TABLE Zoo..klatki (
    klatka_id int NOT NULL,
	pawilon_id int NOT NULL, 
	gatunek_id int NOT NULL,
	liczba_zwierzat int NOT NULL,
    PRIMARY KEY (klatka_id),
	foreign key(pawilon_id) references pawilony(pawilon_id),		
	foreign key(gatunek_id) references gatunki(gatunek_id)
);
GO

CREATE TABLE Zoo..zwierzeta (
    zwierze_id int NOT NULL,
	gatunek_id int NOT NULL,
	imie varchar(30),
	data_urodzenia date,
	data_przybycia date NOT NULL,
	klatka_id int NOT NULL,
    PRIMARY KEY (zwierze_id),
	foreign key(gatunek_id) references gatunki(gatunek_id),
	foreign key(klatka_id) references klatki(klatka_id),	
    CHECK (data_urodzenia is null or data_urodzenia <= data_przybycia)
);

GO

CREATE TABLE Zoo..pracownicy_klatki(
	pracownik_id int NOT NULL,
	klatka_id int NOT NULL,
    PRIMARY KEY (pracownik_id, klatka_id),
	foreign key(pracownik_id) references pracownicy(pracownik_id),
	foreign key(klatka_id) references klatki(klatka_id)
);

GO

--Arek010419
CREATE TABLE Zoo..plany_zywieniowe (
    plan_zywieniowy_id int NOT NULL,
	nazwa varchar(30) NOT NULL,
    PRIMARY KEY (plan_zywieniowy_id),
);
GO
CREATE TABLE Zoo..gatunki_plany_zywieniowe (
    plan_zywieniowy_id int NOT NULL,
    gatunek_id int NOT NULL,
    PRIMARY KEY (plan_zywieniowy_id, gatunek_id),
	foreign key(gatunek_id) references gatunki(gatunek_id),
	foreign key(plan_zywieniowy_id) references plany_zywieniowe(plan_zywieniowy_id),
);
GO
CREATE TABLE Zoo..indywidualne_plany_zywieniowe (
    plan_zywieniowy_id int NOT NULL,
    zwierze_id int NOT NULL,
    PRIMARY KEY (plan_zywieniowy_id, zwierze_id),
	foreign key(zwierze_id) references zwierzeta(zwierze_id),
	foreign key(plan_zywieniowy_id) references plany_zywieniowe(plan_zywieniowy_id)
);
GO
CREATE TABLE Zoo..wartosci_odzywcze (
    wartosc_odzywcza_id int NOT NULL,
	nazwa varchar(30) NOT NULL,
    PRIMARY KEY (wartosc_odzywcza_id),
);
GO
CREATE TABLE Zoo..plany_zywieniowe_wartosci_odzywcze (
    plan_zywieniowy_id int NOT NULL,
    wartosc_odzywcza_id int NOT NULL,
	ilosc int NOT NULL,
    PRIMARY KEY (plan_zywieniowy_id, wartosc_odzywcza_id),
	foreign key(plan_zywieniowy_id) references plany_zywieniowe(plan_zywieniowy_id),
	foreign key(wartosc_odzywcza_id) references wartosci_odzywcze(wartosc_odzywcza_id)
);
GO
CREATE TABLE Zoo..produkty (
    produkt_id int NOT NULL,
	nazwa varchar(30) NOT NULL,
    PRIMARY KEY (produkt_id),
);
GO
CREATE TABLE Zoo..produkty_wartosci_odzywcze (
    produkt_id int NOT NULL,
    wartosc_odzywcza_id int NOT NULL,
	zawartosc_wartosci_odzywczej_na_sto_gram int NOT NULL,
    PRIMARY KEY (produkt_id, wartosc_odzywcza_id),
	foreign key(produkt_id) references produkty(produkt_id),
	foreign key(wartosc_odzywcza_id) references wartosci_odzywcze(wartosc_odzywcza_id)
);
GO
CREATE TABLE Zoo..magazyn (
    produkt_id int NOT NULL,
	data_waznosci datetime NOT NULL,
	ilosc int NOT NULL,
    PRIMARY KEY (produkt_id, data_waznosci),
	foreign key(produkt_id) references produkty(produkt_id),
);
GO

CREATE TABLE Zoo..lekarze (
	lekarz_id int NOT NULL ,
	imie varchar(30) NOT NULL,	
	nazwisko varchar(30) NOT NULL,
    PRIMARY KEY (lekarz_id)
);
GO

CREATE TABLE Zoo..lekarz_zwierze (
	lekarz_id int NOT NULL ,
	zwierze_id int NOT NULL ,
	lekarz_zwierze_id int NOT NULL ,
	PRIMARY KEY (lekarz_id, zwierze_id),
	foreign key (lekarz_id) references lekarze(lekarz_id) ,
	foreign key (zwierze_id) references zwierzeta(zwierze_id)
);
GO

CREATE TABLE Zoo..leki (
	lek_id int NOT NULL ,
	nazwa varchar(30) NOT NULL ,
	PRIMARY KEY (lek_id)
);

CREATE TABLE Zoo..zwierze_lek (
	lekarz_zwierze_id int NOT NULL ,
	lek_id int NOT NULL ,
	dawkowanie_leku varchar(30) NOT NULL ,
	porcjowanie_karmy float NOT NULL ,
	PRIMARY KEY (lek_id, lekarz_zwierze_id),
	foreign key (lekarz_zwierze_id) references lekarz_zwierze(lekarz_zwierze_id),
	foreign key (lek_id) references leki(lek_id)
);

--Arek010419


