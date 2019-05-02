use Zoo

insert into wartosci_rozmyte
values('klatki', 'liczba_zwierzat', 'ma≥a', 0,0,3,6),
		('klatki', 'liczba_zwierzat', 'úrednia', 4,5,8,11),
		('klatki', 'liczba_zwierzat', 'duøa', 7,10,14,15),
		('klatki', 'liczba_zwierzat', 'ogromna', 14,18,1000,1000),
		('biomy', 'temperatura', 'zimny', -273,-273,-5,3),
		('biomy', 'temperatura', 'przciÍtny', -4,5,18,22),
		('biomy', 'temperatura', 'ciep≥y', 20,25,1000,1000),
		('biomy', 'wilgotnosc', 'suchy', 0,0,8,15),
		('biomy', 'wilgotnosc', 'przciÍtny', 14,18,30,37),
		('biomy', 'wilgotnosc', 'wilgotny', 30,50,100,100)


insert into biomy (biom_id, nazwa,temperatura, wilgotnosc)
values (1, 'Sawanna', 30, 25),
		(2, 'Las deszczowy',24,80),
		(3,'Step', 10, 10),
		(4, 'Arktyka', -20,13),
		(5, 'Tajga', 0, 43),
		(6, 'Depresja', -10, 75)

insert into pawilony (pawilon_id, biom_id)
values (1,1),
		(2,1),
		(3,2),
		(4,3),
		(5,4),
		(6,4),
		(7,5),
		(8,6)

insert into gatunki (gatunek_id, nazwa, wiek_dojrzalosci, biom_id)
values (1, 'Lew', 4, 1),
		(2, 'Antylopa gnu', 7, 1),
		(3, 'Zebra', 5, 1),
		(4, 'Øyrafa', 9, 1),
		(5, 'Krokodyl', 12, 2),
		(6, 'Goryl', 6, 2),
		(7, 'Koliber', 1, 2),
		(8, 'åwistak', 2, 3),
		(9, 'Wilk', 3, 3),
		(10, 'Lis', 5, 3),
		(11, 'Foka', 6, 4),
		(12, 'Niedüwiedü polarny', 10, 4),
		(13, 'Mors', 11, 4),
		(14, 'Niedüwiedü brunatny', 8,5),
		(15, 'Ryú', 6, 5),
		(16, 'Rosomak', 4, 5),
		(17, 'Zimorodek', 3, 6)



insert into klatki (klatka_id, pawilon_id, gatunek_id, liczba_zwierzat)
values (1, 1, 1, 2),
		(2, 1, 1, 5),
		(3, 1, 2, 8),
		(4, 1, 4, 7),
		(5, 2, 4, 10), 
		(6, 3, 5, 13),
		(7, 3, 6, 4),
		(8, 3, 5, 7),
		(9, 3, 1, 4), 
		(10, 4, 8, 16),
		(11, 4, 10, 6),
		(12, 4, 10,19),
		(13, 5, 11, 8),
		(14, 5, 15, 7),
		(15, 6, 13, 8), 
		(16, 6, 15, 9),
		(17, 6, 12, 15),
		(18, 7, 14, 5),
		(19, 7, 15, 2),
		(20, 7, 15, 6),
		(21, 7, 16, 2),
		(22, 8, 17, 10),
		(23, 3, 1, 5),
		(24, 8, 17, 14),
		(25, 8, 17, 12)

insert into zwierzeta(zwierze_id, gatunek_id, imie,data_urodzenia,data_przybycia, klatka_id)
values (1,1,'King','20080715', '20100626', 1),
	   (2,1,'KrÛl','20040715', '20091017',2), 
	   (3,1,'Simba','20120715', '20120715', 1),
	   (4,1,'Alex','19990715', '20020316', 9),
	   (5,1,'Mufasa','20020715', '20020715', 2),
	   (6,1,'Sarabi',null, '20071016', 2),
	   (7,1,'Skaza','20010802', '20040414', 2),
	   (8,1,null,null, '20101116',9),
	   (9,1,null,'20070717', '20101116', 9),
	   (10,2,null,'19970421', '20081018', 3),
	   (11,2,null,null, '20020616', 3),
	   (12,2,null,'20120218', '20120218', 3), 
	   (13,2,null,null, '20150330', 3),
	  /* (14,3,null,getdate(), 3), -- nie ma
	   (15,3,'Marty',getdate(), 3),
	   (16,3,null,getdate(), 3),
	   (17,3,null,getdate(), 3),
	   (18,3,null,getdate(), 3), --*/
	   (19,4,null,null, '20170203', 4),
	   (20,4,null,'20140415', '20151117', 4),
	   (21,5,null,'20071109', '20101116', 6),
	   (22,5,null,'20110704', '20110704', 6), 
	   (23,6,null,'20110802', '20121116', 7),
	   (24,6,null,null, '20101128', 7),
	   (25,6,null,'20010705', '20181116', 7),
	  -- (26,7,null,getdate(), 7), -- nie ma
	   (27,10,null,'20150714', '20160324',11),
	   (28,10,null,null, '20080816', 12),
	   (29,10,null,'20160717', '20160812', 12),
	   (30,11,null,'20030927', '20101116', 13),
	   (41,12,null,null, '20101201', 17),
	   (42,12,null,'20170123', '20170123', 17), 
	   (43,13,null,null, '20100119',15),
	   (44,14,null,'19990312', '20180102', 18),
	   (45,14,null,null, '20000813',18),
	   (46,15,'Mruczek','19951204', '20000812', 16),
	   (47,15,null,null, '20040610', 19),
	   (48,16,null,'20011106', '20011106', 21),
	   (49,16,null,'20030814', '20101017',21),
	   (50,17,null,'20030815', '20101017',25),
	   (51,17,null,'20030714', '20101017',25),
	   (52,17,null,'20030314', '20101017',25),
	   (53,17,null,'20030823', '20101017',22),
	   (54,17,null,'20031014', '20101017',22)

insert into kierownicy (kierownik_id, imie, nazwisko, sektor)
values (1, 'Jan', 'Kowalski', 'Naprawy'), 
		(2, 'Anna', 'Nowak', 'Karmienie'), 
		(3, 'Michal', 'Wisniewski', 'Leki'), 
		(4, 'Adam', 'Michalski', 'Magazyn');

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dodaj_pracownika 
	@id as int, @imie as varchar(30), @nazwisko as varchar(30), @kierownik_id as int, @godzina_p as time, @godzina_k as time
	as
	begin 
	declare @zmiana as varchar(1)
	if @godzina_p = '7:00' 
		set @zmiana = 'p'
	else 
		if @godzina_p = '15:00'
			set @zmiana = 'w'
		else 
			Print 'nieodpowiednia godzina rozpoczecia pracy, prosze zmienic'
	if @zmiana = 'w' or @zmiana = 'p'
	insert into Zoo..pracownicy values(@id, @imie, @nazwisko, @kierownik_id, @godzina_p, @godzina_k, @zmiana)
	insert into Zoo..ilosc_zmian values(@id, 0)
	end 
go

exec dodaj_pracownika 11, 'A', 'A', 1, '7:00', '15:00';
exec dodaj_pracownika 12, 'B', 'B', 1, '7:00', '15:00';
exec dodaj_pracownika 13, 'C', 'C', 1, '15:00', '22:00';
exec dodaj_pracownika 21, 'D', 'D', 2, '7:00', '15:00';
exec dodaj_pracownika 22, 'E', 'E', 2, '15:00', '22:00';
exec dodaj_pracownika 31, 'A1', 'A1', 3, '7:00', '15:00';
exec dodaj_pracownika 32, 'B1', 'B1', 3, '7:00', '15:00';
exec dodaj_pracownika 33, 'C1', 'C1', 3, '7:00', '15:00';
exec dodaj_pracownika 34, 'D1', 'D1', 3, '15:00', '22:00';
exec dodaj_pracownika 41, 'D11', 'D1', 4, '7:00', '15:00';
exec dodaj_pracownika 42, 'D11', 'D1', 4, '7:00', '15:00';
exec dodaj_pracownika 43, 'D11', 'D1', 4, '7:00', '15:00';
exec dodaj_pracownika 44, 'D11', 'D1', 4, '15:00', '22:00';

insert into pracownicy_klatki(pracownik_id, klatka_id)
values (11,1),
		(21,1),
		(31,1),
		(12,2),
		(22,2),
		(32,2),  
		(13,3),
		(21,3),
		(33,3),
		(34,3),
		(11,4),
		(21,5),
		(22,6),
		(31,6),
		(12,9),
		(32,9),
		(13,10),
		(11,11),
		(21,11),
		(33,11),
		(34,12),
		(12,13),
		(13,13),  
		(22,14),
		(21,15),
		(33,16),
		(34,16),
		(21,16),
		(13,17),
		(12,18),
		(33,19),
		(31,20),
		(34,20),
		(21,21),
		(11,21)
		
insert into Zoo..obowiazek values('kr', '8:00', '11:00', '14:00', 'p', 3);
insert into Zoo..obowiazek values('kw', '17:00', '20:00', '22:00', 'w', 3);
insert into Zoo..obowiazek values('sr', '8:00', '11:00', '14:00', 'p', 2);
insert into Zoo..obowiazek values('sw', '17:00', '20:00', '22:00', 'w', 2);
insert into Zoo..obowiazek values('lr', '8:00', '11:00', '14:00', 'p', 1);
insert into Zoo..obowiazek values('lw', '17:00', '20:00', '22:00', 'w', 1);

insert into Zoo..magazyn (produkt_id, typ_produktu, data_waznosci, ilosc, ilosc_minimalna, ilosc_maksymalna, kierownik_id) 
values (1, 'K', '03-03-2020', 1200, 200, 2000, 2), 
	(2, 'K', '03-03-2020', 1200, 200, 2000, 2),
	(3, 'K',  '03-03-2020', 1200, 200, 2000, 2),
	(4, 'L',  '03-03-2020', 1200, 200, 2000, 3),
	(5, 'L', '03-03-2020', 1200, 200, 2000, 3);