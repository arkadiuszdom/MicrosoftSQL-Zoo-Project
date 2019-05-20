use zoo



if exists (select 1 from sys.objects where name = 'wybierz_plan_zywnosciowy')
	drop function wybierz_plan_zywnosciowy
go

create function wybierz_plan_zywnosciowy(@zwierze_id int) returns int as
BEGIN
	DECLARE @indywidualne_plany_liczba int, @plan_zywieniowy_id int;
	SELECT  @indywidualne_plany_liczba = COUNT(*) FROM indywidualne_plany_zywieniowe WHERE zwierze_id = @zwierze_id;
	
	IF 1 = @indywidualne_plany_liczba
	BEGIN
		SELECT @plan_zywieniowy_id = plan_zywieniowy_id FROM indywidualne_plany_zywieniowe WHERE zwierze_id = @zwierze_id;
	END
	
	ELSE 
	BEGIN
		SELECT @plan_zywieniowy_id = plany_zywieniowe.plan_zywieniowy_id FROM plany_zywieniowe, gatunki, zwierzeta, gatunki_plany_zywieniowe WHERE zwierze_id = @zwierze_id AND gatunki.gatunek_id=zwierzeta.gatunek_id AND gatunki.gatunek_id=gatunki_plany_zywieniowe.gatunek_id AND gatunki_plany_zywieniowe.plan_zywieniowy_id = plany_zywieniowe.plan_zywieniowy_id;		
	END

	RETURN @plan_zywieniowy_id;
END
go

if exists (select 1 from sys.objects where name = 'ustal_przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia')
	drop function ustal_przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia
go

create function ustal_przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia(@zwierze_id int) returns float as
BEGIN
	DECLARE @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia float;

	DECLARE @gatunek_id int, @wiek int;
	SET @wiek=0;
	SELECT @gatunek_id=gatunek_id, @wiek=datediff(year, data_urodzenia, getdate())  FROM zwierzeta WHERE data_urodzenia IS NOT NULL AND zwierze_id=@zwierze_id;

	IF @wiek = 0 
	BEGIN 
		RETURN 1.0;
	END
	
	DECLARE @wiek_dojrzalosci int;
	SELECT @wiek_dojrzalosci=wiek_dojrzalosci FROM gatunki WHERE gatunek_id=@gatunek_id;
	
	DECLARE @odleglosc_do_lewego_kranca int, @odleglosc_do_prawego_kranca int;
	SET @odleglosc_do_lewego_kranca=0;
	SET @odleglosc_do_prawego_kranca=0;
	SELECT @odleglosc_do_lewego_kranca = odleglosc_do_lewego_kranca, @odleglosc_do_prawego_kranca=odleglosc_do_prawego_kranca FROM wartosci_rozmyte_atrybutu_dojrzalosc_plciowa WHERE @gatunek_id=gatunek_id;
	
	DECLARE @stosunek float;
	SET @stosunek=round(@wiek/@wiek_dojrzalosci,2);
	IF @stosunek>1
	BEGIN
		SET @stosunek=round(1/@stosunek,2);
	END
	SET @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia=@stosunek;

	IF @wiek > @wiek_dojrzalosci AND @wiek < @wiek_dojrzalosci+@odleglosc_do_prawego_kranca
	BEGIN	
		SET @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia=ROUND(@wiek/(2*@wiek_dojrzalosci+@odleglosc_do_prawego_kranca),2);
	END

	ELSE IF @wiek < @wiek_dojrzalosci AND @wiek > @wiek_dojrzalosci-@odleglosc_do_lewego_kranca
	BEGIN
		SET @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia=ROUND(@wiek/(2*@wiek_dojrzalosci-@odleglosc_do_lewego_kranca),2);
	END
	
	
	IF @stosunek > @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia
	BEGIN
		SET @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia=@stosunek;
	END

	RETURN @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia;
END
go
DROP VIEW view_get_newid;
GO
CREATE VIEW view_get_newid
AS
SELECT NEWID() AS Value
GO

if exists (select 1 from sys.objects where name = 'dobierz_produkty_dla_zwierzecia')
	drop function dobierz_produkty_dla_zwierzecia
go
create function dobierz_produkty_dla_zwierzecia(@zwierze_id int) RETURNS @produkty_dla_zwierzecia TABLE (produkt_id int, ilosc int)
as
BEGIN
	declare @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia float; 
	set @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia = dbo.ustal_przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia(@zwierze_id); 

	declare @plan_zywieniowy_id int;
	set @plan_zywieniowy_id = dbo.wybierz_plan_zywnosciowy(@zwierze_id);  

	declare @potrzebne_wartosc_odzywcze table( wartosc_odzywcza_id int, ilosc int);
	INSERT INTO @potrzebne_wartosc_odzywcze SELECT wartosc_odzywcza_id, floor(ilosc * @przelicznik_ilosci_wartosci_odzywczej_uzalezniony_od_wieku_zwierzecia) FROM plany_zywieniowe_wartosci_odzywcze WHERE plan_zywieniowy_id=@plan_zywieniowy_id;


	declare @wartosci_odzywcze_z_magazynu table( wartosc_odzywcza_id int );
	declare @produkt_id_z_magazynu int, @ilosc_z_magazynu int;
	WHILE EXISTS (SELECT * FROM @potrzebne_wartosc_odzywcze WHERE ilosc>0)	
		BEGIN		
			SELECT @produkt_id_z_magazynu = produkt_id, @ilosc_z_magazynu=ilosc 
			FROM magazyn
			WHERE magazyn.produkt_id in (
				SELECT TOP 1 produkt_id
					FROM produkty_wartosci_odzywcze as potrzebne_produkty_wartosci_odzywcze
					WHERE wartosc_odzywcza_id in (select wartosc_odzywcza_id from @potrzebne_wartosc_odzywcze)
					GROUP BY produkt_id
					ORDER BY 
						COUNT(wartosc_odzywcza_id) - 
							ISNULL((SELECT COUNT(wartosc_odzywcza_id)
							FROM produkty_wartosci_odzywcze
							WHERE produkt_id = potrzebne_produkty_wartosci_odzywcze.produkt_id AND wartosc_odzywcza_id not in (select wartosc_odzywcza_id from @potrzebne_wartosc_odzywcze)
							GROUP BY produkt_id),0) 
						DESC, (SELECT Value FROM view_get_newid)		
			)

			INSERT INTO @wartosci_odzywcze_z_magazynu 
				SELECT wartosc_odzywcza_id
				FROM magazyn, produkty_wartosci_odzywcze 
				WHERE magazyn.produkt_id = @produkt_id_z_magazynu
					AND produkty_wartosci_odzywcze.produkt_id= @produkt_id_z_magazynu
		

			declare @najmniejsza_ilosc int;
			SELECT @najmniejsza_ilosc=ilosc 
			FROM @potrzebne_wartosc_odzywcze 
			WHERE ilosc = (SELECT MIN(ilosc) from @potrzebne_wartosc_odzywcze)
			

			declare @ilosc_do_zabrania int;
			IF @najmniejsza_ilosc > @ilosc_z_magazynu
			BEGIN
				SET @ilosc_do_zabrania= @najmniejsza_ilosc-@ilosc_z_magazynu;
			END
			ELSE 
			BEGIN
				SET @ilosc_do_zabrania= @najmniejsza_ilosc;
			END			

			INSERT INTO @produkty_dla_zwierzecia VALUES (@produkt_id_z_magazynu, @ilosc_do_zabrania);
		
			declare @wartosc_odzywcza_id_z_magazynu int;
			DECLARE wartosc_odzywcze_z_magazynu_kursor CURSOR FOR SELECT wartosc_odzywcza_id FROM @wartosci_odzywcze_z_magazynu;
			OPEN wartosc_odzywcze_z_magazynu_kursor;
			FETCH NEXT FROM wartosc_odzywcze_z_magazynu_kursor INTO @wartosc_odzywcza_id_z_magazynu;
			WHILE @@FETCH_STATUS = 0  
			BEGIN
				UPDATE @potrzebne_wartosc_odzywcze SET ilosc=ilosc-@ilosc_do_zabrania WHERE wartosc_odzywcza_id = @wartosc_odzywcza_id_z_magazynu;
				FETCH NEXT FROM wartosc_odzywcze_z_magazynu_kursor INTO @wartosc_odzywcza_id_z_magazynu;
			END
			
			DEALLOCATE wartosc_odzywcze_z_magazynu_kursor;
		
			DELETE FROM @wartosci_odzywcze_z_magazynu;
			DELETE FROM @potrzebne_wartosc_odzywcze WHERE ilosc = 0;
		END;
		RETURN;
end
go

select * from dobierz_produkty_dla_zwierzecia(3);
select * from dobierz_produkty_dla_zwierzecia(1);
select * from dobierz_produkty_dla_zwierzecia(2);
select * from dobierz_produkty_dla_zwierzecia(4);