DECLARE
	@email VARCHAR(20) = 'ebayron@gmail.com',
	@newdomain VARCHAR(20) = 'newdomain.com.ph',
	@schematable VARCHAR(50) = 'dbo.tablename',
	@column VARCHAR(20) = 'emailaddress';

SELECT
	@email AS "Original E-Mail",
	SUBSTRING(@email, 0, CHARINDEX('@', @email)) AS "E-Mail ID",
	SUBSTRING(@email, CHARINDEX('@', @email)+1, LEN(@email)) AS "Domain",
	REPLACE(@email, SUBSTRING(@email, CHARINDEX('@', @email)+1, LEN(@email)), @newdomain) AS "New E-mail Address",
	'UPDATE ' + @schematable + ' SET ' + @column + ' = ''' + REPLACE(@email, SUBSTRING(@email, CHARINDEX('@', @email)+1, LEN(@email)), @newdomain) + ''' WHERE emailaddress = ' + @email + '' AS "UPDATE script";
GO

DECLARE
	@email VARCHAR(20) = 'ebayron',
	@domain VARCHAR(20) = '@gmail.com'

SELECT
	STUFF(@email, 2, LEN(@email)-2, '*********') + @domain AS "Masked E-Mail Address"