use Zoo

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
	if @pracownik = 0
	print 'Nie ma pracownika ktory moze wykonac to zadanie';
	else 
	insert into Zoo..grafik values(@pracownik, (select obowiazek_id from obowiazek where identyfikator = @identyfikator), @data, @zmiana)
	declare @pomocnicza as int = (select ilosc from ilosc_zmian where pracownik_id = @pracownik) + 1;
	update ilosc_zmian set ilosc = @pomocnicza where pracownik_id = @pracownik;
	drop table tmpFerdeen;
end
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure kontrola_magazynu
--procedura zlecajaca uzupelnienie magazynu konkretnej osobie, wyliczenie ilosci, dodanie rekordu 'ostatnie uzupelnienie'
	@kategoria as varchar(15), @id_produktu as int
as 
begin
	declare @roznica as int = (select ilosc_maksymalna from magazyn where produkt_id = @id_produktu) - (select ilosc from magazyn where produkt_id = @id_produktu);
	update magazyn set ilosc = ilosc_maksymalna where produkt_id = @id_produktu;
	update magazyn set ostatnie_uzupelnienie = @roznica where produkt_id = @id_produktu;
	exec wybor_magazyniera @kategoria, 'p', 'lr', '04-04-2019';
end 
go 

exec kontrola_magazynu 'Magazyn', 3; 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure karmienie
--procedura wyliczajaca ilosc karmy na klatke (potem z uwzglednieniem planow zywieniowych), sprawdzenie czy sie zgadza stan magazynu
--wydanie polecenia uzupelnienia magazynu 
	@klatka as int, @id_produktu as int 
as 
begin 
	declare @ile_zwierzat as int = (select count(zwierze_id) from zwierzeta where klatka_id = @klatka);
	declare @ilosc_magazyn as int = 50 * @ile_zwierzat * 3;
	declare @pomocnicza as int = (select ilosc from magazyn where produkt_id = @id_produktu);
	update magazyn set ilosc = @pomocnicza - @ilosc_magazyn where produkt_id = @id_produktu;
	if(select ilosc from magazyn where produkt_id = @id_produktu) <= (select ilosc_minimalna from magazyn where produkt_id = @id_produktu)
		exec kontrola_magazynu 'Magazyn', @id_produktu;
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
	if @stanowisko = 'Karmienie' or @stanowisko = 'Leki' 
		exec karmienie @klatka, 1;
end
go

exec wybor_pracownika 'Karmienie', 'w', 2, 'kr', '02-04-2019';

select * from zwierzeta
select * from magazyn