use Zoo
--R.T.
--sprzedaz biletu
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'tworz_bilet')
	drop procedure tworz_bilet
go 
create procedure tworz_bilet 
	@kiedy DATE,
	@promocjaid int
as
DECLARE 
	@pawilony int, 
	@Cena int,
	@IdRezerwacji int,
	@IdBiletu int
begin
SELECT @IdRezerwacji = max(#id_rezerwacji) from Rezerwacja
SELECT @pawilony = pawilon_id FROM pawilony --to trzeba zrobic inaczej
SELECT @IdBiletu = max(#id_biletu)+1 from Bilety
SELECT @Cena = Liczba_pawilonow * 5 from PawilonyBilety 
INSERT INTO Bilety (#id_biletu, pawilon_id,termin, id_rezerwacji , obnizka, cena)
VALUES (@IdBiletu, @pawilony, @kiedy, @IdRezerwacji ,(SELECT #id_promocji FROM Promocja), (SELECT @Cena * procent_obnizki FROM Promocja))

end

if exists(select 1 from sys.objects where TYPE = 'P' and name = 'dodaj_opinie')
	drop procedure dodaj_opinie
go
create procedure dodaj_opinie
@ocenka as int,
@opinia as varchar(255)
as
begin

INSERT INTO Opinie(#id_biletu, pawilon_id, ocena, komentarz) 
VALUES ((SELECT #id_biletu FROM Bilety), (SELECT pawilon_id FROM pawilony), @ocenka, @opinia)

end

go

if exists(select 1 from sys.objects where TYPE = 'P' and name = 'rezerwacja')
	drop procedure rezerwacja
create procedure rezerwacja
Declare
@ileosob int,
@indeks int = 0

Begin
INSERT INTO Rezerwacja (ilosc_osob)
VALUE (@ileosob)
WHILE @indeks <= @ileosob
exec kup_bilet 2019-07-20
@indeks = @indeks +1
end

go
create
FUNCTION Srednia (@nrpawilonu int)

RETURN avg(ocena) FROM Opinie
WHERE @nrpawilonu  = SELECT pawilon_id FROM pawilony
