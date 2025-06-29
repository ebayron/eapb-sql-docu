-- ADD COLUMN
ALTER TABLE [tablename] ADD [columnname] [datatype] NOT NULL

-- DROP COLUMN
ALTER TABLE [tablename] DROP COLUMN [columnname]

-- CHANGE NOT NULL /  NULL
ALTER TABLE [tablename] ALTER COLUMN [columnname] [datatype] NOT NULL

-- ADD CONSTRAINT
ALTER TABLE [tablename] ADD CONSTRAINT [constraintname] UNIQUE ([columnname(s)])
ALTER TABLE [tablename] ADD CONSTRAINT [constraintname] PRIMARY KEY ([columnname])

-- DROP CONSTRAINT
ALTER TABLE [tablename] DROP CONSTRAINT [constraintname]