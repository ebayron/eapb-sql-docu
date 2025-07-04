CREATE TRIGGER [dbo].[tr_tbl1_Upd_Del] ON [dbo].[tbl1]
FOR UPDATE, DELETE
NOT FOR REPLICATION
AS

IF(SELECT COUNT(1) FROM deleted) > 0 
	BEGIN
		INSERT INTO [tbl1_Log] (
		[tbl1_ID],
		[coln],
		[Action_Type], 
		[Action_Done_By], 
		[Action_Done_On],
		[From_Host] 
		) 
		SELECT
		d.[tbl1_ID],
		d.[coln],
		CASE 	
			WHEN i.[tbl1_ID] IS NULL THEN 'D'
			ELSE 'U'
			END
		SUSER_SNAME(),
		GETDATE(),
		HOST_NAME()
		FROM deleted d
		LEFT OUTER JOIN inserted i ON d.[tbl1_ID] = i.[tbl1_ID]
	END