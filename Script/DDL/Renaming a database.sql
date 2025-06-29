-- Renaming a database
ALTER DATABASE project_x
MODIFY NAME = project_X

EXECUTE sp_renameDB 'project_X', 'project' -- old way of renaming a database