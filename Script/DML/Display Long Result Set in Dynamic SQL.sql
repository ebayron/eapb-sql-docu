DECLARE @variable_with_long_text AS VARCHAR(MAX)
SET @variable_with_long_text = 'input long text here'
SELECT @variable_with_long_text AS [processing-instruction(x)] FOR XML PATH
-- If used without FOR XML PATH, it will only print 43679 characters.