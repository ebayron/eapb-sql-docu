CREATE TABLE Parent (id INT IDENTITY);
CREATE TABLE Child (id INT IDENTITY(100, 1));
GO

CREATE TRIGGER Parentins ON Parent FOR INSERT
AS 
	BEGIN
		INSERT Child DEFAULT VALUES
	END;
GO

SELECT id FROM Parent; -- id is empty.
SELECT id FROM Child; -- id is empty.
GO

/* DO the following in Session 1 */
INSERT Parent DEFAULT VALUES:
SELECT @@IDENTITY;		 		-- Returns value 100 (Trigger).
SELECT SCOPE_IDENTITY(); 		-- Returns the value 1 (INSERT statement).
SELECT IDENT_CURRENT('Child');  -- Returns value 100 (Trigger).
SELECT IDENT_CURRENT('Parent'); -- Returns the value 1 (INSERT statement).

/* DO the following in Session 2 */
SELECT @@IDENTITY;				-- Returns NULL as there has been no INSERT action in this session.
SELECT SCOPE_IDENTITY(); 		-- Returns NULL as there has been no INSERT action in this session.
SELECT IDENT_CURRENT('Child');  -- Returns value 100 (Trigger).
SELECT IDENT_CURRENT('Parent'); -- Returns the value 1 (INSERT statement).