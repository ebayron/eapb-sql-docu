-- STEP 1: On Session 1, run below query.
BEGIN TRAN

UPDATE AdventureWorks2017.Production.Product
SET name = 'Adjustable Race (UPDATE)'
WHERE ProductID = 1;

-- STEP 2: On Session 2, run below query. It will return the updated row.
SELECT * FROM Production.Product WITH(NOLOCK) WHERE ProductID = 1

-- STEP 3: On Session 3, run below query. It will wait on Session 1 to finish transaction;
SELECT * FROM Production.Product WHERE ProductID = 1 -- Query 

-- STEP 4: On Session 1, roll back transaction.
ROLLBACK TRAN;

-- If transaction was committed, Session 3 will finish querying and display same result as Session 2.
-- If transaction was rolled back, Session 3 will finish querying but dislay the "not updated" data in which result is different than Session 2. 
