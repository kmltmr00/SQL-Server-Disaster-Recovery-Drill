# SQL Server Olağanüstü Durum Kurtarma Tatbikatı

Bir SQL Server olağanüstü durum kurtarma senaryosunun **Tam (Full)** ve **İşlem Günlüğü (Transaction Log)** yedekleri kullanılarak birebir uygulamalı simülasyonu.

## 🚨 Proje Genel Bakış

Bu proje, bir SQL Server veritabanı için kritik bir olağanüstü durum kurtarma senaryosunun uygulamalı bir simülasyonudur. Amacım, benzetilmiş bir başarısızlık (felaket) durumundan sonra **AdventureWorks2022** veritabanını, birleştirilmiş bir Tam ve İşlem Günlüğü yedek stratejisi kullanarak başarılı bir şekilde kurtarmaktı.

## ⚡ Gerçekleştirilen Adımlar

1.  **Hazırlık:** Veritabanının kurtarma modelini `FULL` olarak ayarladım.
2.  **Tam Yedek (Full Backup):** Veritabanının tam bir yedeğini aldım.
3.  **İş Yükü Simülasyonu:** Veri değişiklik operasyonları (`UPDATE` sorgusu) çalıştırdım.
4.  **İşlem Günlüğü Yedeği (Log Backup):** Yapılan değişiklikleri yakalamak için bir transaction log yedeği aldım.
5.  **Felaket Senaryosu Simülasyonu:** Veritabanını düşürerek (DROP) kritik bir arızayı simüle ettim.
6.  **Tam Yedeği Geri Yükleme:** Tam yedeği `NORECOVERY` seçeneğiyle geri yükledim.
7.  **İşlem Günlüğü Yedeğini Geri Yükleme:** Log yedeğini `RECOVERY` seçeneğiyle geri yükleyerek, veritabanını felaketten hemen önceki durumuna getirdim.
8.  **Doğrulama:** Veri tutarlılığını ve başarılı kurtarmayı doğrulamak için veritabanını sorguladım.

## 🛠️ Kullanılan Teknolojiler

*   Microsoft SQL Server
*   SQL Server Management Studio (SSMS)
*   AdventureWorks2022 Örnek Veritabanı

## 📁 Depo (Repository) Yapısı

*   `/scripts/disaster_recovery.sql` - Tatbikatın tamamını içeren T-SQL kodlarını barındırır.

## 💡 Edinilen Önemli Bilgiler

*   İyi tanımlanmış bir yedekleme stratejisinin önemi.
*   `FULL` ve `SIMPLE` kurtarma modelleri arasındaki temel farklar.
*   `RESTORE DATABASE` ve `RESTORE LOG` kullanarak bir veritabanını kurtarma süreci.
*   `WITH NORECOVERY` ve `WITH RECOVERY` seçeneklerinin etkili bir şekilde kullanımı.

  ## 🚀 Kurulum ve Çalıştırma Talimatları

1.  **Gereksinimler:** Aşağıdakilerin makinenizde yüklü olduğundan emin olun:
    *   [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (herhangi bir sürüm)
    *   [SQL Server Management Studio (SSMS)](https://docs.microsoft.com/tr-tr/sql/ssms/download-sql-server-management-studio-ssms)
    *   [AdventureWorks2022 Örnek Veritabanı](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

2.  **Veritabanını Kurun:** İndirdiğiniz `AdventureWorks2022` veritabanını SQL Server'a geri yükleyin.

3.  **Script'leri Çalıştırın:** `scripts/` klasöründeki `disaster_recovery.sql` dosyasını SSMS'de açın ve adım adım çalıştırın.
    *   **ÖNEMLİ:** Script'teki yedek dosya yollarını (`C:\Users\alike\...`) kendi bilgisayarınızdaki bir klasör yoluna değiştirmeyi unutmayın!
