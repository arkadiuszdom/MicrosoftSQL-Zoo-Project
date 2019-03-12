use Zoo



if exists (select 1 from sys.objects where name = 'zapytanie_rozmyte')
	drop function zapytanie_rozmyte
go
create function zapytanie_rozmyte(@tabela varchar(30), @atrybut varchar(30), @zmienna_lingwistyczna varchar(30), @wartosc int)
	returns float
as
begin
	declare @a float, @b float, @c float, @d float
	select @a = a,@b = b,@c = c,@d =d
	from Zoo..wartosci_rozmyte
	where tabela = @tabela and atrybut = @atrybut and zmienna_lingwistyczna = @zmienna_lingwistyczna
	if @wartosc <= @a or @wartosc >= @d
		return 0
	if @wartosc >= @b and @wartosc <= @c
		return 1
	if @wartosc > @a and @wartosc < @b
		return ROUND((@wartosc/(@a + @b)),2)

	return ROUND((@wartosc/(@c + @d)),2)

end
go

if exists (select 1 from sys.objects where name = 'minimum')
	drop function minimum
go
create function minimum(@a float, @b float)
	returns float
as
begin
	if @a<@b
		begin
			return @a
		end
	return @b
end

go

if exists (select 1 from sys.objects where name = 'maksimum')
	drop function maksimum
go
create function maksimum(@a float, @b float)
	returns float
as
begin
	if @a>@b
		begin
			return @a
		end
	return @b
end
go
if exists (select 1 from sys.objects where name='dod_zwierze_trig') 
	drop TRIGGER dod_zwierze_trig 
GO
CREATE TRIGGER dod_zwierze_trig
	ON zwierzeta   
  INSTEAD OF INSERT 
  as
	begin
		declare @klatka_id int
		select @klatka_id = klatka_id from  inserted
		if (SELECT COUNT(klatka_id) from zwierzeta where klatka_id = @klatka_id) < (SELECT liczba_zwierzat from klatki where klatka_id = @klatka_id)
			INSERT INTO zwierzeta SELECT * from inserted
		else
			print('B£¥D! W tej klatce nie ma ju¿ miejsca')			
  END;
go

if exists (select 1 from sys.objects where name='usun_klatke_trig') 
	drop TRIGGER usun_klatke_trig 
GO
CREATE TRIGGER usun_klatke_trig
	ON klatki   
  INSTEAD OF delete 
  as
	begin
		declare @klatka_id int
		select @klatka_id = klatka_id from deleted
		if NOT EXISTS(SELECT zwierze_id from zwierzeta where klatka_id = @klatka_id)
			DELETE FROM klatki where klatka_id = (select klatka_id from deleted)
		else
			print('B£¥D! Nie mo¿na usun¹æ klatki, poniewa¿ s¹ w niej zwierzêta')			
  END;
go

if exists (select 1 from sys.objects where name='aktualizuj_imie_trig') 
	drop TRIGGER aktualizuj_imie_trig 
GO
CREATE TRIGGER aktualizuj_imie_trig
	ON zwierzeta
  AFTER UPDATE  
  as
	begin
	if exists (select * from deleted where imie is null)
		update zwierzeta
		set data_urodzenia = DATEADD(YEAR, -1 * (1+DATEDIFF(YEAR, data_przybycia, getdate())), getdate())
		where data_urodzenia is null and zwierze_id in (select zwierze_id from deleted)
  END
go


if exists(select 1 from sys.objects where TYPE = 'P' and name = 'przenies_zwierzeta')
	drop procedure przenies_zwierzeta
go
create procedure przenies_zwierzeta @klatka_z int, @klatka_do int
as
declare 
		@l_zwierzat int,
		@wolne_miejsce int	
begin
	set @l_zwierzat = (select count(zwierze_id)
	from zwierzeta
	where klatka_id = @klatka_z)
	set @wolne_miejsce = (select liczba_zwierzat
						  from klatki
						  where klatka_id = @klatka_do) -
						  (select count(zwierze_id)
						  from zwierzeta
						  where klatka_id = @klatka_do)
	if @l_zwierzat > @wolne_miejsce
		print('B£¥D! W klatce, do której prznosisz zwierzêta nie ma wystarczajaco wolnego miejsca.')
	else if (SELECT gatunek_id 
		from klatki 
		where klatka_id = @klatka_z) <>
		(SELECT gatunek_id 
		from klatki 
		where klatka_id = @klatka_do)
	print('B£¥D! W klatce, z której przenosisz s¹ trzymane zwierzêta innego gatunku ni¿ w klatce docelowej')
	else
	update zwierzeta
	set klatka_id = @klatka_do
	where klatka_id = @klatka_z

end
go

if exists (select 1 from sys.objects where name = 'wyszukaj_imie')
	drop function wyszukaj_imie
go
create function wyszukaj_imie(@fraza varchar(30))
	returns table
as
	return (select imie, nazwa as gatunek
			from zwierzeta, gatunki
			where zwierzeta.gatunek_id = gatunki.gatunek_id
				and imie is not null 
				and imie like @fraza + '%')
go



if exists(select 1 from sys.objects where TYPE = 'P' and name = 'usun_obowiazki_pracownika')
	drop procedure usun_obowiazki_pracownika
go
create procedure usun_obowiazki_pracownika @max_liczba_klatek int=5
as	
begin
declare @liczba_klatek int,
	@id_pracownik int
DECLARE
	cur cursor for select pracownik_id, count(klatka_id) as liczba_klatek from pracownicy_klatki group by pracownik_id 

	OPEN cur;
	FETCH NEXT FROM cur INTO @id_pracownik, @liczba_klatek;
	WHILE @@FETCH_STATUS=0
	BEGIN
		if(@liczba_klatek>@max_liczba_klatek)
		begin
			delete pracownicy_klatki 
			where klatka_id in (select top (@liczba_klatek-@max_liczba_klatek) klatka_id from pracownicy_klatki where @id_pracownik=pracownik_id ) and pracownik_id=@id_pracownik
		end
		FETCH NEXT FROM cur INTO @id_pracownik, @liczba_klatek;
	END	
	CLOSE cur
	DEALLOCATE cur
						
end

go 

if exists(select 1 from sys.objects where TYPE = 'P' and name = 'dodaj_pawilon')
	drop procedure dodaj_pawilon
go
create procedure dodaj_pawilon @nazwa_biomu varchar(30), @kod_bledu int output
as	
declare @pawilon_id int,
		@biom_id int
begin
	if(not exists (select * from biomy where nazwa=@nazwa_biomu))
		begin 
		set @kod_bledu = 1
		return
		end
	select @pawilon_id=max(pawilon_id)+1 from pawilony
	select @biom_id=biom_id from biomy where nazwa = @nazwa_biomu
	insert into pawilony (pawilon_id, biom_id) values (@pawilon_id, @biom_id)
	set @kod_bledu = 0
						
end

go