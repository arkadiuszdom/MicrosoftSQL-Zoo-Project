use Zoo
--R.T.
--Procedura tworzaca nowe tabele
go
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'tworz_bilet')
	drop procedure Pomocnicze_tabele
go
CREATE PROCEDURE Pomocnicze_tabele
	@ktore_pawilony NVARCHAR(128),
	@IdBiletu INT
as
begin
INSERT INTO Zoo..PawilonyBilety (#id_biletu,pawilon_id)
SELECT @IdBiletu, SPL.value FROM string_split(@ktore_pawilony,',') as SPL
end

go

--Funkcja wyliczajaca Cene
if exists(select 1 from sys.objects where TYPE = 'FN' and name = 'WyliczCene')
	DROP FUNCTION dbo.WyliczCene
Go
CREATE FUNCTION WyliczCene ( @ZNIZKA FLOAT,@Pawilony INT)
RETURNS FLOAT
AS
BEGIN
Declare
@Cena Float = 0
SELECT @Cena = 5 * @Pawilony
SELECT @ZNIZKA *= 0.01
SELECT @Cena *= (1-@ZNIZKA)
RETURN @Cena
END

--sprzedaz biletu
go
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'tworz_bilet')
	drop procedure tworz_bilet
go 
create procedure tworz_bilet 
	@kiedy DATE,
	@promocjaid int,
	@ktore_pawilony NVARCHAR(128),
	@IdRezerwacji int
as
DECLARE 
	@Cena Float = 20,
	@IdBiletu int,
	@Procent int,
	@Ilosc int
begin
	if (@kiedy < CONVERT(date, GETDATE()))
	RAISERROR('Nie mozna rezerwować w przeszlości', 17, 1);
	else
	SELECT @Procent = procent_obnizki From Zoo..Promocja where Zoo..Promocja.#id_promocji = @promocjaid 
	SELECT @IdBiletu =  MAX(#id_biletu)+1 from Zoo..Bilety
	SELECT @Ilosc = (len(@ktore_pawilony) - len(replace(@ktore_pawilony, ',', '')))+1
	SELECT @Cena = dbo.WyliczCene(@Procent, @Ilosc)
	INSERT INTO Zoo..Bilety (#id_biletu, #id_pawilonow ,termin, id_rezerwacji , obnizka, #id_obnizki , cena)
			VALUES (@IdBiletu,  @ktore_pawilony ,@kiedy, @IdRezerwacji , @Procent, @promocjaid , @Cena )
	exec Pomocnicze_tabele @ktore_pawilony,@IdBiletu


end

--Triger na Date
if exists(select 1 from sys.objects where TYPE = 'TR' and name = 'ZmianaZnizkiNaWtorek')
	DROP TRIGGER ZmianaZnizkiNaWtorek
go
CREATE TRIGGER ZmianaZnizkiNaWtorek
	ON Zoo..Bilety
	AFTER INSERT
	AS
	DECLARE
	@DzienTygodnia date,
	@Ilosc int,
	@Pawilony NVARCHAR(max),
	@NowaCena Float
	BEGIN
	SELECT @DzienTygodnia = termin from inserted 
	SELECT @Pawilony = #id_pawilonow from inserted where #id_biletu = (SELECT #id_biletu from inserted)
	SELECT @Ilosc= (len(@Pawilony) - len(replace(@Pawilony, ',', '')))+1
	SELECT @NowaCena = dbo.WyliczCene(80,@Ilosc)
	UPDATE Bilety
		SET obnizka=80, #id_obnizki=7 , cena = @NowaCena
		WHERE DATEPART(dw , @DzienTygodnia)=3 and #id_biletu = (SELECT #id_biletu from inserted)

	END


--Rezerwacja dla grupy osob
go
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'rezerwacja')
	drop procedure rezerwacje
go
create procedure rezerwacje
@dzien date,
@pawilony_ktore NVARCHAR(128),
--@indeks int = 0,
@znizka1 int,
@znizka2 int,
@znizka3 int,
@znizka4 int,
@znizka5 int,
@znizka6 int,
@znizka7 int
as
DECLARE
@id_rezerwacji int,
@ile_osob int

begin
SELECT @id_rezerwacji =  MAX(#id_rezerwacji)+1 from Zoo..Rezerwacja
SELECT @ile_osob = @znizka1+@znizka2+@znizka3+@znizka4+@znizka5+@znizka6+@znizka7
begin
INSERT INTO Zoo..Rezerwacja (#id_rezerwacji,Ilosc_osob)
VALUES (@id_rezerwacji,@ile_osob)
end
Begin
while @znizka1 > 0
begin
EXEC tworz_bilet @dzien, 1, @pawilony_ktore, @id_rezerwacji
set @znizka1 = @znizka1 -1
end
while @znizka2 > 0
begin
EXEC tworz_bilet @dzien, 2, @pawilony_ktore, @id_rezerwacji
set @znizka2 = @znizka2 - 1
end
while @znizka3 > 0
begin
EXEC tworz_bilet @dzien, 3, @pawilony_ktore, @id_rezerwacji
set @znizka3 = @znizka3 - 1
end
while @znizka4 > 0
begin
EXEC tworz_bilet @dzien, 4, @pawilony_ktore, @id_rezerwacji
set @znizka4 = @znizka4 - 1
end
while @znizka5 > 0
begin
EXEC tworz_bilet @dzien, 5, @pawilony_ktore, @id_rezerwacji
set @znizka5 = @znizka5 - 1
end
while @znizka6 > 0
begin
EXEC tworz_bilet @dzien, 6, @pawilony_ktore, @id_rezerwacji
set @znizka6 = @znizka6 - 1
end
while @znizka7 > 0
begin
EXEC tworz_bilet @dzien, 7, @pawilony_ktore, @id_rezerwacji
set @znizka7 = @znizka7 - 1
end
end
end


go
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'rezerwacja')
	drop procedure Opinia
go
create procedure Opinia
@id_bilet int,
@pawilon_id int,
@komentarz nvarchar(510),
@ocenka int
as
DECLARE
@id_opini int
SELECT @id_opini =  MAX(@id_opini)+1 from Zoo..Opinie
begin
INSERT INTO Zoo..Opinie (#id_opini,#id_biletu,pawilon_id ,komentarz)
VALUES ( @id_opini ,@id_bilet,@pawilon_id , @komentarz )
end

--TESTY
	exec Pomocnicze_tabele '1,2,3','1'
	select * from Zoo..PawilonyBilety 
	EXEC tworz_bilet '2020-09-09', 3, '1,2,3', 1
	select * from Zoo..Bilety
	Select * from Zoo..PawilonyBilety
	Select * from Zoo..Promocja
	EXEC tworz_bilet '2019-06-07', 1, '1,2,3,4,5,6', 1
	select * from Zoo..Bilety
--jakas tam srednia
go
create
FUNCTION Srednia (@nrpawilonu int)
RETURN avg(ocena) FROM Opinie
WHERE @nrpawilonu  = SELECT pawilon_id FROM pawilony

-- tu jest zlo LEPIEJ NIE RUSZAC
INSERT INTO Zoo..PawilonyBilety (#id_biletu,pawilon_id)
VALUES ( '1' ,(SELECT * FROM dbo.Split(@DelimitedString, ',')))


CREATE TYPE TableType AS TABLE
(LocationName VARCHAR(50))
GO
DECLARE @myTable TableType
DECLARE @DelimitedString NVARCHAR(128)
SET @DelimitedString = '1,2,3,4'
INSERT INTO @myTable(LocationName) VALUES((SELECT * FROM dbo.Split(@DelimitedString, ',')))
SELECT * FROM @myTable

CREATE FUNCTION Example( @TableName TableType READONLY)
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE @name VARCHAR(50)
SELECT TOP 1 @name = LocationName FROM @TableName
RETURN @name
END 

-- pierwsza turdna wersja
drop function [dbo].[Split]
CREATE FUNCTION [dbo].[Split]
(
    @String NVARCHAR(4000),
    @Delimiter NCHAR(1),
	@Ticker_id int
)
RETURNS TABLE
AS
RETURN
(
    WITH Split(stpos,endpos)
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'Id_biletu' = @Ticker_id,
        'Nr_pawilonu' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
)
GO

