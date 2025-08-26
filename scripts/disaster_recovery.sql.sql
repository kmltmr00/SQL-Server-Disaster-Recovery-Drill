-- 1. TAM YEDEK (FULL BACKUP) ALMA
-- Veritaban�n�n tam bir kopyas�n� belirtilen diske al�r.
-- WITH INIT: Ayn� isimde eski bir yedek dosyas� varsa �zerine yazar.
-- STATS=5: ��lemin her %5'lik dilimde ilerlemesini konsolda g�sterir.
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH INIT, STATS=5;
GO

-- 2. �� Y�K�N� S�M�LE ETME (VER� DE����KL���)
-- Bir felaket an�ndaki veri de�i�ikliklerini sim�le etmek i�in
-- AdventureWorks2022 veritaban�ndaki �r�nlerin fiyatlar�n� g�nceller.
USE AdventureWorks2022;
GO

SELECT * FROM Production.Product; -- G�ncelleme �ncesi veriyi kontrol et.

UPDATE Production.Product
SET ListPrice = 25
WHERE ProductID BETWEEN 500 AND 999; -- Belirli �r�n aral���nda fiyat� 25 yap.
GO

-- 3. KURTARMA MODEL�N� "FULL" OLARAK AYARLAMA
-- Transaction Log (��lem G�nl���) yedeklerinin al�nabilmesi i�in
-- veritaban�n�n kurtarma modelinin "FULL" olmas� gerekir.
-- Bu ayar, noktasal kurtarma (point-in-time recovery) yapabilmemizi sa�lar.
USE master;
GO
ALTER DATABASE AdventureWorks2022 SET RECOVERY FULL;
GO

-- 4. TRANSACTION LOG YEDE�� ALMA
-- Son full yedekten sonra yap�lan T�M i�lemleri (yukar�daki UPDATE dahil)
-- kaydederek, veritaban�n� tam o anki durumuna kurtarabilmemizi sa�layacak
-- log yede�ini al�yoruz.
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH STATS=5;
GO

-- 5. FELAKET S�M�LASYONU: VER�TABANINI S�LME
-- Ger�ek bir felaket senaryosu sim�le ediliyor (sunucu ��kmesi, disk hatas� vb.).
-- WITH ROLLBACK IMMEDIATE: Veritaban�na ba�l� t�m kullan�c�lar� an�nda keser
-- ve bekleyen i�lemleri geri al�r (rollback). Bu, veritaban�n� d���rmek i�in gereklidir.
USE master;
ALTER DATABASE AdventureWorks2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE AdventureWorks2022;
GO

-- 6. KURTARMA ��LEM� (RESTORE PROCESS)

-- A) FULL YEDE�� GER� Y�KLEME
-- WITH NORECOVERY: Geri y�kleme i�lemine devam edece�imizi belirtir.
-- Veritaban� "restoring" durumuna ge�er ve kullan�ma haz�r hale gelmez.
-- WITH REPLACE: Ayn� isimde fiziksel dosyalar varsa �zerine yazmak i�in izin verir.
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH NORECOVERY, REPLACE;
GO

-- B) TRANSACTION LOG YEDE��N� GER� Y�KLEME
-- WITH RECOVERY: Kurtarma i�lemini tamamlar ve veritaban�n� kullan�ma a�ar.
-- Bu komut, veritaban�n� en son log yede�inin al�nd��� ana (UPDATE i�leminin oldu�u an) getirir.
RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH RECOVERY;
GO

-- 7. DO�RULAMA
-- Kurtarma i�leminin ba�ar�l� oldu�unu ve g�ncellenmi� verilerin
-- (ProductID 500-999 aras� ListPrice=25) kaydedildi�ini do�rulamak i�in basit bir sorgu.
USE AdventureWorks2022;
SELECT ProductID, ListPrice
FROM Production.Product
WHERE ProductID BETWEEN 500 AND 999;
GO