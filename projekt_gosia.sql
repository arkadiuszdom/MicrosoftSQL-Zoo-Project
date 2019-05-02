use Zoo

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
end
go

drop procedure wybor_pracownika

exec wybor_pracownika 'Karmienie', 'w', 2, 'kr', '02-04-2015';