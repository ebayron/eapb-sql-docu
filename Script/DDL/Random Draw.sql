/* https://www.brentozar.com/archive/2009/01/running-a-contest-with-sql-server/ */

-- If you ever need to run a random drawing contest with a SQL Server database back end, here’s one way to do it:

-- 1. Create a table to hold each person’s name and email address.
--    We use EntryID as a primary key, not their name or email, because a person can enter more than once.
CREATE TABLE [dbo].[Entry](
    [EntryID] [INT] IDENTITY(1,1) NOT NULL,
    [FullName] [VARCHAR](50) NOT NULL,
    [EmailAddress] [VARCHAR](100) NOT NULL,
    [PrizeWon] [VARCHAR](50) NULL,
 CONSTRAINT [PK_Entry] PRIMARY KEY CLUSTERED ([EntryID] ASC))

-- 2. Insert a record each time somebody enters:
INSERT INTO [dbo].[Entry] ([FullName], [EmailAddress])
  VALUES ('Edgar Allan Bayron', 'ebayron@securitybank.com.ph')
  
-- 3. Draw a random winner by running this script for each prize:
DECLARE @WinningEntryID INT
SET @WinningEntryID = (
	SELECT TOP 1 [EntryID] 
	FROM [dbo].[Entry] 
	WHERE [PrizeWon] IS NULL -- makes sure we don’t draw an entry again after it’s already won.
	ORDER BY NEWID()) -- gives us a random record out of the table

	-- makes sure we don’t draw an entry again after it’s already won.
	UPDATE [dbo].[Entry]
	SET [PrizeWon] = 'Pound of Bacon'
	WHERE [EntryID] = @WinningEntryID

  