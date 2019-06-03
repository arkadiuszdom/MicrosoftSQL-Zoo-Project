use Zoo

select * from grafik
select * from ilosc_zmian
select * from magazyn;

CREATE TRIGGER wyzwalacz
    ON Zoo.dbo.ilosc_zmian
 AFTER update
AS
BEGIN
	PRINT 'Wykonano zmiany, dodano wpis do grafika i zaktualizowano ilosc zmian'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure wybor_magazyniera	
	@stanowisko as char(30), @zmiana as varchar(1), @identyfikator as varchar(4), @data as date
as
begin 
	declare @sprawdzenie as int = 0;
	declare @spr as int = 0;
	while @spr = 0
	begin
	set @spr = (select count(*) from(
	select pracownik_id from pracownicy where kierownik_id = (select kierownik_id from kierownicy where sektor = @stanowisko) and zmiana = @zmiana
	intersect 
	select pracownik_id from ilosc_zmian where ilosc = @sprawdzenie) as i) ; 
	if @spr = 0
		set @sprawdzenie = @sprawdzenie + 1
	end
	SELECT * INTO tmpFerdeen FROM (
		select pracownik_id from pracownicy where kierownik_id = (select kierownik_id from kierownicy where sektor = @stanowisko) and zmiana = @zmiana
		intersect 
		select pracownik_id from ilosc_zmian where ilosc = @sprawdzenie) as tmp
	declare @pracownik as int = (select top 1(pracownik_id) from tmpFerdeen)
	begin try
		if @pracownik = 0
		Print 'Nie ma pracownika ktory moze wykonac to zadanie';
		else 
		insert into Zoo..grafik values(@pracownik, (select obowiazek_id from obowiazek where identyfikator = @identyfikator), @data, @zmiana)
		declare @pomocnicza as int = (select ilosc from ilosc_zmian where pracownik_id = @pracownik) + 1;
		update ilosc_zmian set ilosc = @pomocnicza where pracownik_id = @pracownik;
	end try
	begin catch
		Print Error_Message()
	end catch
	drop table tmpFerdeen;
end
go

exec wybor_magazyniera 'Magazyn', 'p', 'lr', '04-04-2019';


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure kontrola_magazynu
	@kategoria as varchar(15), @id_produktu as int
as 
begin
	declare @roznica as int = (select ilosc_maksymalna from magazyn where produkt_id = @id_produktu) - (select ilosc from magazyn where produkt_id = @id_produktu);
	update magazyn set ilosc = ilosc_maksymalna where produkt_id = @id_produktu;
	update magazyn set ostatnie_uzupelnienie = @roznica where produkt_id = @id_produktu;
	exec wybor_magazyniera @kategoria, 'p', 'lr', '04-04-2019';
end 
go 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure karmienie
	@klatka as int
as 
begin 
	create table zwierzePomocnicza (pr_k int NOT NULL PRIMARY KEY IDENTITY(1,1),
		z_id int NOT NULL)
	insert into zwierzePomocnicza(z_id) select zwierze_id from zwierzeta where klatka_id = @klatka

	select * from zwierzePomocnicza
	declare @indeks as int = 1;
	while (@indeks <= (select max(pr_k) from zwierzePomocnicza))
		begin
	
		create table tabelaPomocnicza
		( 
		pk int NOT NULL PRIMARY KEY IDENTITY(1,1),
		p_id int NOT NULL,
		ilo int not null);

		declare @zmienna as int = (select z_id from zwierzePomocnicza where pr_k = @indeks);
		insert into tabelaPomocnicza(p_id, ilo) select * from Zoo..dobierz_produkty_dla_zwierzecia(@zmienna);

		declare @pomocnicza as int = 1;
		while (@pomocnicza <= (select max(pk) from tabelaPomocnicza))
		begin 
			declare @ilosc_magazyn as int = (select ilosc from magazyn where produkt_id = (select p_id from tabelaPomocnicza where pk = @pomocnicza))
			declare @roznica as int = @ilosc_magazyn - (select ilo from tabelaPomocnicza where pk = @pomocnicza)
			update magazyn set ilosc = @roznica where produkt_id = (select p_id from tabelaPomocnicza where pk = @pomocnicza)
			if((select ilosc from magazyn where produkt_id = (select p_id from tabelaPomocnicza where pk = @pomocnicza)) <= (select ilosc_minimalna from magazyn where produkt_id = (select p_id from tabelaPomocnicza where pk = @pomocnicza)))
			begin
			declare @id_pomocnicze as int = (select p_id from tabelaPomocnicza where pk = @pomocnicza)
			exec kontrola_magazynu 'Magazyn', @id_pomocnicze;
			end 
			set @pomocnicza = @pomocnicza + 1;
			end 
		select * from tabelaPomocnicza
		drop table tabelaPomocnicza
		set @indeks = @indeks + 1;
		end
		drop table zwierzePomocnicza
end 
go 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure wybor_pracownika	
	@stanowisko as char(30), @zmiana as varchar(1), @klatka as int, @identyfikator as varchar(4), @data as date
as
begin 
	declare @sprawdzenie as int = 0;
	declare @spr as int = 0;
	while @spr = 0
	begin
	set @spr = (select count(*) from(
	select pracownik_id from pracownicy where kierownik_id = (select kierownik_id from kierownicy where sektor = @stanowisko) and zmiana = @zmiana
	intersect 
	select pracownik_id from pracownicy_klatki where klatka_id = @klatka
	intersect 
	select pracownik_id from ilosc_zmian where ilosc = @sprawdzenie) as i) ; 
	Print @spr
	if @spr = 0
		set @sprawdzenie = @sprawdzenie + 1
	end
	SELECT * INTO tmpFerdeen FROM (
		select pracownik_id from pracownicy where kierownik_id = (select kierownik_id from kierownicy where sektor = @stanowisko) and zmiana = @zmiana
		intersect 
		select pracownik_id from pracownicy_klatki where klatka_id = @klatka
		intersect 
		select pracownik_id from ilosc_zmian where ilosc = @sprawdzenie) as tmp
	declare @pracownik as int = (select top 1(pracownik_id) from tmpFerdeen)
	if @pracownik = 0
	print 'Nie ma pracownika ktory moze wykonac to zadanie';
	else 
	insert into Zoo..grafik values(@pracownik, (select obowiazek_id from obowiazek where identyfikator = @identyfikator), @data, @zmiana)
	declare @pomocnicza as int = (select ilosc from ilosc_zmian where pracownik_id = @pracownik) + 1;
	update ilosc_zmian set ilosc = @pomocnicza where pracownik_id = @pracownik;
	drop table tmpFerdeen;
	if @stanowisko = 'Karmienie'
		exec karmienie @klatka;
end
go

exec wybor_pracownika 'Karmienie', 'p', 9, 'kr', '04-04-2019';

select * from grafik
select * from ilosc_zmian
select * from magazyn

select * from pracownicy
select * from kierownicy
select * from pracownicy_klatki;

create function kierownik_dzialu
(@zmienna as varchar(50)) returns varchar(50)
as
begin
declare @kierownik as varchar(50)
set @kierownik = (select imie + ' ' + nazwisko from kierownicy where sektor = @zmienna)

	return @kierownik;

end 
go

select Zoo.dbo.kierownik_dzialu('Karmienie') 

update magazyn set ilosc = 230 where produkt_id = 2

select * from magazyn

select * from grafik