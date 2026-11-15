CREATE DATABASE Front
GO

USE master;
GO

RESTORE DATABASE Front
FROM DISK = '/backup/rest.bak'
WITH REPLACE,
MOVE 'pos' TO '/var/opt/mssql/data/rest.mdf', 
MOVE 'pos_log' TO '/var/opt/mssql/data/rest_log.ldf'; 
GO

SELECT 
    DB_NAME(database_id) AS DatabaseName,
    type_desc AS FileType,
    physical_name AS PhysicalPath
FROM sys.master_files
WHERE DB_NAME(database_id) = 'Front';
GO
