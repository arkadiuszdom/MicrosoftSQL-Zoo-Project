
if exists(select 1 from master.dbo.sysdatabases where name = 'Zoo') drop database Zoo
GO
CREATE DATABASE Zoo
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

CREATE TABLE Zoo..pracownicy_klatki(
	pracownik_id int NOT NULL,
	klatka_id int NOT NULL,
    PRIMARY KEY (pracownik_id, klatka_id),
	foreign key(pracownik_id) references pracownicy(pracownik_id),
	foreign key(klatka_id) references klatki(klatka_id)
);


go




