DECLARE @Difference VARCHAR(15)
DECLARE @date DATETIME2(0) = ''; -- insert date here
	
SELECT @Difference =
	RIGHT('0' + ISNULL(CONVERT(VARCHAR(10), (DATEDIFF(SECOND, @date, GETDATE()) / 86400)), ''), 2) + ':' + 				   -- days
	RIGHT('0' + ISNULL(CONVERT(VARCHAR(10), ((DATEDIFF(SECOND, @date, GETDATE()) % 86400) / 3600)), ''), 2) + ':' +		   -- hours
	RIGHT('0' + ISNULL(CONVERT(VARCHAR(10), (((DATEDIFF(SECOND, @date, GETDATE()) % 86400) % 3600) / 60)), ''), 2) + ':'+  -- minutes 
	RIGHT('0' + ISNULL(CONVERT(VARCHAR(10), (((DATEDIFF(SECOND, @date,GETDATE()) % 86400) % 3600) % 60)), ''), 2)		   -- seconds

SELECT
	@date AS "Input Date",
	@Difference AS "Difference (dd:hh:mm:ss)" -- maximum is 99:23:59:59