-- Unique column with multiple NULL values

CREATE UNIQUE NONCLUSTERED INDEX <index name>
ON <table name>(<column name>)
WHERE <column name> IS NOT NULL;