BEGIN TRY
	BEGIN TRAN -- comment this line to produce error.
		SELECT 1
	COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
	SELECT  
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_MESSAGE() AS ErrorMessage
END CATCH;