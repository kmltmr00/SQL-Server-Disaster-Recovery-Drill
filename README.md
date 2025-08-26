# SQL-Server-Disaster-Recovery-Drill
A hands-on simulation of a SQL Server disaster recovery scenario using Full and Transaction Log backups.

# SQL Server Disaster Recovery Drill

## 🚨 Overview
This project is a hands-on simulation of a critical disaster recovery scenario for a SQL Server database. The goal was to successfully restore the AdventureWorks2022 database after a simulated failure, using a combination of Full and Transaction Log backups.

## ⚡ Steps Performed
1.  **Preparation:** Set the database recovery model to `FULL`.
2.  **Full Backup:** Took a full backup of the database.
3.  **Simulate Workload:** Executed data modification operations (UPDATE).
4.  **Log Backup:** Took a transaction log backup to capture the changes.
5.  **Simulate Disaster:** Dropped the database to simulate a critical failure.
6.  **Restore Full Backup:** Restored the full backup with `NORECOVERY`.
7.  **Restore Log Backup:** Restored the log backup with `RECOVERY` to bring the database to its state just before the failure.
8.  **Verification:** Queried the database to verify data consistency and successful recovery.

## 🛠️ Technologies Used
- **Microsoft SQL Server**
- **SQL Server Management Studio (SSMS)**
- **AdventureWorks2022 Sample Database**

## 📁 Repository Structure
- `/scripts/disaster_recovery.sql` - Contains the complete T-SQL code for the drill.

## 💡 Key Learnings
- The importance of a well-defined backup strategy.
- The difference between `FULL` and `SIMPLE` recovery models.
- The process of restoring a database using `RESTORE DATABASE` and `RESTORE LOG`.
- Using `WITH NORECOVERY` and `WITH RECOVERY` options effectively.
