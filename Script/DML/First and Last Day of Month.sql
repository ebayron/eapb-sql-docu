DECLARE
	@WhatDate DATE,
	@LastDay DATE,
	@FirstDay DATE

SET @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
SET @LastDay = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) +1, 0))

SELECT
	@FirstDay AS [First Day],
	@LastDay AS [Last Day]