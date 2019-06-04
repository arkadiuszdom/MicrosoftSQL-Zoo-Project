use Zoo


--zmieniona tabela indywidualne... 
create table badania (
	lekarz_id int,
	zwierze_id int not null, 
	data_badania date);

insert into badania(zwierze_id) select zwierze_id from zwierzeta

insert into lekarze values (1, 'a', 'a', 0), (2, 'b', 'b', 0), (3, 'c', 'c', 0), (4, 'd', 'd', 0)

create table lek_plan (id_leku int, id_planu int, 
foreign key(id_leku) references leki(lek_id),
foreign key(id_planu) references plany_zywieniowe(plan_zywieniowy_id))

insert into leki values (6, 'a'), (7, 'b'), (8, 'c') --to zmienic na 6, 7, 8
insert into lek_plan values (7,1), (6,2)
insert into magazyn values  (6, 'Lek1', 'L', 100, 10, 200, 3, null), (7, 'Lek2', 'L', 100, 10, 200, 3, null)

insert into lekarz_zwierze(zwierze_id, lekarz_id)
values (1,1),
	   (2,2), 
	   (3,1),
	   (4,3),
	   (5,2),
	   (6,2),
	   (7,2),
	   (8,3),
	   (9,2),
	   (10,3),
	   (11,3),
	   (12,3), 
	   (13,3),
	   (19,4),
	   (20,4),
	   (21,4),
	   (22,4), 
	   (23,4),
	   (24,3),
	   (25,2),
	   (27,3),
	   (28,1),
	   (29,1),
	   (30,1),
	   (41,1),
	   (42,1), 
	   (43,1),
	   (44,1),
	   (45,1),
	   (46,1),
	   (47,1),
	   (48,2),
	   (49,2),
	   (50,4),
	   (51,3),
	   (52,1),
	   (53,2),
	   (54,3)

create trigger dodajZwierzeDoKartoteki
on zwierzeta
after insert
as
begin 
	insert into lekarz_zwierze(zwierze_id) select max(zwierze_id) from zwierzeta
end

create trigger dodajLekarzaDoZwierzecia 
on lekarz_zwierze
after insert 
as
begin
	update lekarz_zwierze set lekarz_id = (select top 1 lekarz_id from lekarze where ilosc_zmian = (select min(ilosc_zmian) from lekarze)) where zwierze_id = (select max(zwierze_id) from lekarz_zwierze)
end 
go

select * from zwierzeta
select * from lekarz_zwierze
--sprawdzenie czy dziala
insert into zwierzeta(zwierze_id, gatunek_id, imie, data_przybycia, klatka_id) values (67,1,'Leo', '2019-02-02', 2)

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure kontrola_lekarska
as
begin 
	declare @i as int = 1;
	declare @data as int = DATEPART(weekday, GETDATE());
	print @data;
	if (@data = 6) 
		declare @ilosc as int = 0;
		declare @lekarz_id as int = 0;
		while @i <= (select max(zwierze_id) from badania)
		begin 
			set @lekarz_id = (select lekarz_id from lekarz_zwierze where zwierze_id = @i)
			update badania set lekarz_id = @lekarz_id, data_badania = GETDATE() where zwierze_id = @i;
			set @ilosc = (select ilosc_zmian from lekarze where lekarz_id = @lekarz_id) + 1;
			update lekarze set ilosc_zmian = @ilosc where lekarz_id = @lekarz_id;
			set @i = @i +1;
		end 
end 

select * from badania 
select * from lekarze
select * from lekarz_zwierze

exec kontrola_lekarska

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure badanie 
(@id_zwierzecia as int, @data as date)
as 
begin 
	declare @ilosc as int = 0;
	declare @lekarz_id as int = (select lekarz_id from lekarz_zwierze where zwierze_id = @id_zwierzecia);
	set @ilosc = (select ilosc_zmian from lekarze where lekarz_id = @lekarz_id) + 1;
	update lekarze set ilosc_zmian = @ilosc where lekarz_id = @lekarz_id;
	update badania set data_badania = @data where zwierze_id = @id_zwierzecia;
end 

select * from badania 
select * from lekarze

exec badanie 9, '2019-04-04'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure usuwanie_starych_planow
as 
begin 
	delete from indywidualne_plany_zywieniowe where data_koniec < GETDATE()
end 


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure leki_i_karma 
(@id_zwierzecia as int, @id_leku as int, @od as date, @do as date, @dawka as int) 
as
begin 
	if exists (select * from zwierzeta where zwierze_id = @id_zwierzecia)
	begin
	declare @plan as int = (select id_planu from lek_plan where id_leku = @id_leku);
	insert into indywidualne_plany_zywieniowe(plan_zywieniowy_id, zwierze_id, data_poczatek, data_koniec) values (@plan, @id_zwierzecia, @od, @do);
	print @plan
	declare @klatka as int = 0;
	set @klatka = (select klatka_id from zwierzeta where zwierze_id = @id_zwierzecia);
	declare @ilosc_dni as int = (select datediff(day, @od, @do) as datediff);
	declare @ilosc_zuzyta as int = @ilosc_dni * @dawka; 
	update magazyn set ilosc = ilosc - @ilosc_zuzyta where produkt_id = @id_leku;
	exec wybor_pracownika 'Leki', 'p', @klatka, 'lr', '04-04-2019';
	if (select ilosc_minimalna from magazyn where produkt_id = @id_leku) > (select ilosc from magazyn where produkt_id = @id_leku)
	exec kontrola_magazynu 'Leki', @id_leku;
	exec usuwanie_starych_planow
	end
	else 
	begin 
	RAISERROR('Nie ma takiego zwierzecia w bazie', 16, 1); 
	end
end 

select * from zwierze_lek
--te tabele chyba trzeba usunac 
select * from lek_plan
select id_planu from lek_plan
select * from indywidualne_plany_zywieniowe

drop procedure leki_i_karma
select * from zwierzeta where zwierze_id = 9
select * from magazyn
select * from lek_plan
select * from indywidualne_plany_zywieniowe


exec leki_i_karma 9, 7, '2020-04-06', '2020-04-09', 5
select datediff(day, '2019-04-06', '2019-04-09') as datediff