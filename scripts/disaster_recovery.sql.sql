-- 1. TAM YEDEK (FULL BACKUP) ALMA
-- Veritabanýnýn tam bir kopyasýný belirtilen diske alýr.
-- WITH INIT: Ayný isimde eski bir yedek dosyasý varsa üzerine yazar.
-- STATS=5: Ýþlemin her %5'lik dilimde ilerlemesini konsolda gösterir.
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH INIT, STATS=5;
GO

-- 2. ÝÞ YÜKÜNÜ SÝMÜLE ETME (VERÝ DEÐÝÞÝKLÝÐÝ)
-- Bir felaket anýndaki veri deðiþikliklerini simüle etmek için
-- AdventureWorks2022 veritabanýndaki ürünlerin fiyatlarýný günceller.
USE AdventureWorks2022;
GO

SELECT * FROM Production.Product; -- Güncelleme öncesi veriyi kontrol et.

UPDATE Production.Product
SET ListPrice = 25
WHERE ProductID BETWEEN 500 AND 999; -- Belirli ürün aralýðýnda fiyatý 25 yap.
GO

-- 3. KURTARMA MODELÝNÝ "FULL" OLARAK AYARLAMA
-- Transaction Log (Ýþlem Günlüðü) yedeklerinin alýnabilmesi için
-- veritabanýnýn kurtarma modelinin "FULL" olmasý gerekir.
-- Bu ayar, noktasal kurtarma (point-in-time recovery) yapabilmemizi saðlar.
USE master;
GO
ALTER DATABASE AdventureWorks2022 SET RECOVERY FULL;
GO

-- 4. TRANSACTION LOG YEDEÐÝ ALMA
-- Son full yedekten sonra yapýlan TÜM iþlemleri (yukarýdaki UPDATE dahil)
-- kaydederek, veritabanýný tam o anki durumuna kurtarabilmemizi saðlayacak
-- log yedeðini alýyoruz.
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH STATS=5;
GO

-- 5. FELAKET SÝMÜLASYONU: VERÝTABANINI SÝLME
-- Gerçek bir felaket senaryosu simüle ediliyor (sunucu çökmesi, disk hatasý vb.).
-- WITH ROLLBACK IMMEDIATE: Veritabanýna baðlý tüm kullanýcýlarý anýnda keser
-- ve bekleyen iþlemleri geri alýr (rollback). Bu, veritabanýný düþürmek için gereklidir.
USE master;
ALTER DATABASE AdventureWorks2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE AdventureWorks2022;
GO

-- 6. KURTARMA ÝÞLEMÝ (RESTORE PROCESS)

-- A) FULL YEDEÐÝ GERÝ YÜKLEME
-- WITH NORECOVERY: Geri yükleme iþlemine devam edeceðimizi belirtir.
-- Veritabaný "restoring" durumuna geçer ve kullanýma hazýr hale gelmez.
-- WITH REPLACE: Ayný isimde fiziksel dosyalar varsa üzerine yazmak için izin verir.
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH NORECOVERY, REPLACE;
GO

-- B) TRANSACTION LOG YEDEÐÝNÝ GERÝ YÜKLEME
-- WITH RECOVERY: Kurtarma iþlemini tamamlar ve veritabanýný kullanýma açar.
-- Bu komut, veritabanýný en son log yedeðinin alýndýðý ana (UPDATE iþleminin olduðu an) getirir.
RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH RECOVERY;
GO

-- 7. DOÐRULAMA
-- Kurtarma iþleminin baþarýlý olduðunu ve güncellenmiþ verilerin
-- (ProductID 500-999 arasý ListPrice=25) kaydedildiðini doðrulamak için basit bir sorgu.
USE AdventureWorks2022;
SELECT ProductID, ListPrice
FROM Production.Product
WHERE ProductID BETWEEN 500 AND 999;
GO