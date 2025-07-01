DECLARE
	@FirstName VARCHAR(10), -- use VARCHAR(n) or VARCHAR(MAX)
	@COUNT INT = 0,
	@StartTime DATETIME = GETDATE()

WHILE (@COUNT < 1000000)
	BEGIN
		SELECT
			@FirstName = 'BASAVARAJ',
			@COUNT = @COUNT + 1
	END

PRINT 'Time Taken in ms: ' + CAST(DATEDIFF(ms,@StartTime,GETDATE()) AS VARCHAR(20))
GO 6

/*
-- VARCHAR(MAX)
Beginning execution loop
Time Taken in ms: 823
Time Taken in ms: 753
Time Taken in ms: 766
Time Taken in ms: 763
Time Taken in ms: 790
Time Taken in ms: 770
Batch execution completed 6 times.

-- VARCHAR(1000)
Beginning execution loop
Time Taken in ms: 396
Time Taken in ms: 356
Time Taken in ms: 356
Time Taken in ms: 343
Time Taken in ms: 344
Time Taken in ms: 340
Batch execution completed 6 times.

--VARCHAR(10)
Beginning execution loop
Time Taken in ms: 350
Time Taken in ms: 327
Time Taken in ms: 320
Time Taken in ms: 333
Time Taken in ms: 333
Time Taken in ms: 330
Batch execution completed 6 times.
*/