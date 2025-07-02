-- In this example, "Admin" is the database that will be restore. Change DB name as necessary.

-- 1. Make sure you're not on a user database
USE master

-- 2. Do not let users touch the database temporarily
ALTER DATABASE Admin
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

-- 3. Perform tail log backup (this will make database inaccessible to read)
-- change values as necessary
DECLARE @filename AS VARCHAR(40) = 'Admin' + '_' + LEFT(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR, GETDATE(), 21), '-', ''), ' ', '_'), ':', ''), 15);
DECLARE @path AS SYSNAME = 'D:\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\LOG\'+@filename+'.bak'
BACKUP LOG Admin TO DISK = @path WITH NORECOVERY

-- 4. Generate FULL, DIFF, and T-LOG restore scripts
-- Include this on the last t-log (WITH STOPAT = '2025-04-01 07:29:01') -- change date as necessary
-- If the mistake happened close to or during a scheduled log backup, never assume it's safe. Always use STOPAT when you're unsure, even on regular log backups, not just tail logs.

-- sample only
--RESTORE DATABASE admin FROM DISK = N'\\LAPTOP-IMGT9ROF\D$\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\FULL\LAPTOP-IMGT9ROF_Admin_FULL_20250401_072234.bak' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
--RESTORE DATABASE admin FROM DISK = N'\\LAPTOP-IMGT9ROF\D$\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\DIFF\LAPTOP-IMGT9ROF_Admin_DIFF_20250401_072242.bak' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
--RESTORE LOG admin FROM DISK = N'\\LAPTOP-IMGT9ROF\D$\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\LOG\LAPTOP-IMGT9ROF_Admin_LOG_20250401_072248.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
--RESTORE LOG admin FROM DISK = N'\\LAPTOP-IMGT9ROF\D$\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\LOG\LAPTOP-IMGT9ROF_Admin_LOG_20250401_072500.trn' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
--RESTORE LOG admin FROM DISK = N'\\LAPTOP-IMGT9ROF\D$\Virtual Box\SQL SERVER\S\LAPTOP-IMGT9ROF\Admin\LOG\LAPTOP-IMGT9ROF_Admin_LOG_20250401_073538.trn' WITH STOPAT = '2025-04-01 07:29:01', FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5

-- 5. Restore database
RESTORE DATABASE Admin WITH RECOVERY;

-- 6. Validate database

-- 7. Set to multi_user
ALTER DATABASE Admin
SET MULTI_USER;