/*
There are 2 ways to avoid large transaction log file when deleting large number of records.

1. Change recovery model of database to SIMPLE.
2. Insert records which will not be deleted into a temporary table (not #table) then issue a TRUNCATE statement on the original table then rename the temporary table to the original table.

If above scnearios are not applicable, use below script.

*/

SET ROWCOUNT 500 -- value of your choice
delete_more:
     -- your delete statement here
IF @@ROWCOUNT > 0 GOTO delete_more
SET ROWCOUNT 0