DECLARE @dt DATE
SET @dt = N'20200929 23:59:59'

EXECUTE master.dbo.xp_delete_file
	1,                                -- FileTypeSelected (0 = FileBackup, 1 = FileReport)
	N'D:\BackUp\',                    -- Folder path (trailing slash).
	'trn',                            -- File extension which needs to be deleted (no dot).
	@dt,                              -- All files prior specified date will be deleted.
	0                                 -- Subfolder flag (1 = include files in first subfolder level, 0 = not)

EXECUTE master.dbo.xp_delete_file 1, N'D:\BackUp\', 'txt', @dt, 0
EXECUTE master.dbo.xp_delete_file 1, N'D:\BackUp\', 'bak', @dt, 0