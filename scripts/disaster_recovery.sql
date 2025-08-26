-- 1. TAM YEDEK (FULL BACKUP) ALMA
-- Veritabanının tam bir kopyasını belirtilen diske alır.
-- WITH INIT: Aynı isimde eski bir yedek dosyası varsa üzerine yazar.
-- STATS=5: İşlemin her %5'lik dilimde ilerlemesini konsolda gösterir.
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH INIT, STATS=5;
GO

-- 2. İŞ YÜKÜNÜ SİMÜLE ETME (VERİ DEĞİŞİKLİĞİ)
-- Bir felaket anındaki veri değişikliklerini simüle etmek için
-- AdventureWorks2022 veritabanındaki ürünlerin fiyatlarını günceller.
USE AdventureWorks2022;
GO

SELECT * FROM Production.Product; -- Güncelleme öncesi veriyi kontrol et.

UPDATE Production.Product
SET ListPrice = 25
WHERE ProductID BETWEEN 500 AND 999; -- Belirli ürün aralığında fiyatı 25 yap.
GO

-- 3. KURTARMA MODELİNİ "FULL" OLARAK AYARLAMA
-- Transaction Log (İşlem Günlüğü) yedeklerinin alınabilmesi için
-- veritabanının kurtarma modelinin "FULL" olması gerekir.
-- Bu ayar, noktasal kurtarma (point-in-time recovery) yapabilmemizi sağlar.
USE master;
GO
ALTER DATABASE AdventureWorks2022 SET RECOVERY FULL;
GO

-- 4. TRANSACTION LOG YEDEĞİ ALMA
-- Son full yedekten sonra yapılan TÜM işlemleri (yukarıdaki UPDATE dahil)
-- kaydederek, veritabanını tam o anki durumuna kurtarabilmemizi sağlayacak
-- log yedeğini alıyoruz.
BACKUP LOG AdventureWorks2022
TO DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH STATS=5;
GO

-- 5. FELAKET SİMÜLASYONU: VERİTABANINI SİLME
-- Gerçek bir felaket senaryosu simüle ediliyor (sunucu çökmesi, disk hatası vb.).
-- WITH ROLLBACK IMMEDIATE: Veritabanına bağlı tüm kullanıcıları anında keser
-- ve bekleyen işlemleri geri alır (rollback). Bu, veritabanını düşürmek için gereklidir.
USE master;
ALTER DATABASE AdventureWorks2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE AdventureWorks2022;
GO

-- 6. KURTARMA İŞLEMİ (RESTORE PROCESS)

-- A) FULL YEDEĞİ GERİ YÜKLEME
-- WITH NORECOVERY: Geri yükleme işlemine devam edeceğimizi belirtir.
-- Veritabanı "restoring" durumuna geçer ve kullanıma hazır hale gelmez.
-- WITH REPLACE: Aynı isimde fiziksel dosyalar varsa üzerine yazmak için izin verir.
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_full.bak'
WITH NORECOVERY, REPLACE;
GO

-- B) TRANSACTION LOG YEDEĞİNİ GERİ YÜKLEME
-- WITH RECOVERY: Kurtarma işlemini tamamlar ve veritabanını kullanıma açar.
-- Bu komut, veritabanını en son log yedeğinin alındığı ana (UPDATE işleminin olduğu an) getirir.
RESTORE LOG AdventureWorks2022
FROM DISK = 'C:\Users\alike\OneDrive\Desktop\BACKUP\AdventureWorks2022_trnlog.trn'
WITH RECOVERY;
GO

-- 7. DOĞRULAMA
-- Kurtarma işleminin başarılı olduğunu ve güncellenmiş verilerin
-- (ProductID 500-999 arası ListPrice=25) kaydedildiğini doğrulamak için basit bir sorgu.
USE AdventureWorks2022;
SELECT ProductID, ListPrice
FROM Production.Product
WHERE ProductID BETWEEN 500 AND 999;
GO
