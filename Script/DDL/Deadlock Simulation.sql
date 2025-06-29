-- 1. Create two global temp tables with sample data.
CREATE TABLE ##Employees (
    EmpId INT IDENTITY,
    EmpName VARCHAR(16),
    Phone VARCHAR(16)
)
GO

INSERT INTO ##Employees (EmpName, Phone)
VALUES ('Martha', '800-555-1212'), ('Jimmy', '619-555-8080')
GO

CREATE TABLE ##Suppliers(
    SupplierId INT IDENTITY,
    SupplierName VARCHAR(64),
    Fax VARCHAR(16)
)
GO

INSERT INTO ##Suppliers (SupplierName, Fax)
VALUES ('Acme', '877-555-6060'), ('Rockwell', '800-257-1234')
GO


-- 2. Open two empty query windows in SSMS. Place the code for session 1 in one query window and the code for session 2 in the other query window. Then execute each of the two sessions step by step, going back and forth between the two query windows as required. Note that each transaction has a lock on a resource that the other transaction is also requesting a lock on.

Session 1             | Session 2
================================================
BEGIN TRAN;           | BEGIN TRAN;
================================================
UPDATE ##Employees
SET EmpName = 'Mary'
WHERE EmpId = 1
================================================
                      | UPDATE ##Suppliers
                      | SET Fax = N'555-1212'
                      | WHERE SupplierId = 1
================================================
UPDATE ##Suppliers
SET Fax = N'555-1212'
WHERE SupplierId = 1
================================================
<blocked>             | UPDATE ##Employees
                      | SET Phone = N'555-9999'
                      | WHERE EmpId = 1
================================================
                      | <blocked>
================================================