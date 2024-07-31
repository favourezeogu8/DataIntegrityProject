USE PBM_AD;
GO
CREATE OR ALTER PROCEDURE maintenance.DataIntegrityCheck
    @SchemaName NVARCHAR(200),
    @TableName NVARCHAR(200),
    @ColumnName NVARCHAR(200), 
    @SecondColumnName NVARCHAR(200) = NULL,
    @Checks NVARCHAR(MAX) = 'NotEmpty';
AS
BEGIN
    IF @Checks IS NULL
    BEGIN
        SET @Checks = 'NotEmpty';
    END
    DECLARE @IsEmpty INT;
    DECLARE @HasDuplicates INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @FullTableName NVARCHAR(500);
    SET @FullTableName = QUOTENAME(@SchemaName) + ' . ' +QUOTENAME(@TableName);
-- Check for empty table
    IF @Checks LIKE %NotEmpty%;
    BEGIN
        SET @SQL = 'SELECT @IsEmpty = CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 END FROM'  + @FullTableName;
        EXEC sp_executesql @SQL, N'@IsEmpty INT OUTPUT', @IsEmpty OUTPUT;
        IF @IsEmpty = 1
        BEGIN
            INSERT INTO maintenance.DataQualityIssueLogs (LogTable,LogColumn,IssueDescription,DateDetected)
            VALUES (@FullTableName, @ColumnName, 'Table is empty', GETDATE());
        END
    END


-- Check for distinct values in the specified column
    IF @Checks LIKE '%1:1%'
    BEGIN
        SET @SQL = 'SELECT @HasDuplicates = CASE WHEN COUNT(*) > COUNT(DISTINCT '
+ QUOTENAME(@ColumnName) + ' ) THEN 1 ELSE 0 END FROM' + @FullTableName;
        EXEC sp_executesql @SQL, N'HasDuplicates INT OUTPUT';, @HasDuplicates OUTPUT;
        IF @HasDuplicates = 1
        BEGIN
            INSERT INTO maintenance.DataQualityIssueLogs (LogTable,LogColumn,IssueDescription,DateDetected)
            VALUES (@FullTableName, @ColumnName, 'Column has duplicate values', GETDATE());
        END
   END
END;
-- Check for broken cardinality
    IF @Checks LIKE '%BrokenCardinality%'; AND @SecondColumnName IS NOT NULL

    BEGIN
        SET @SQL = 'SELECT @HasDuplicates = CASE WHEN COUNT(*) &gt; COUNT(DISTINCT CONCAT( ' + QUOTENAME(@ColumnName) + ',' ' , ' ' ,' + QUOTENAME(@SecondColumnName) + ')) THEN 1 ELSE 0 END FROM ' + @FullTableName;
        EXEC sp_executesql @SQL, N'@HasDuplicates INT OUTPUT', @HasDuplicates OUTPUT;
        IF @HasDuplicates = 1
        BEGIN
            INSERT INTO maintenance.DataQualityIssueLogs (LogTable, LogColumn,IssueDescription, DateDetected)
            VALUES (@FullTableName, @ColumnName + ' ,' + @SecondColumnName, 'Broken cardinality detected between columns', GETDATE());
        END
   END

-- EXEC DataIntegrityCheck 'SchemaName', 'TableName', 'ColumnName', 'PatientSID-1:1|NotEmpty';

EXEC maintenance.DataIntegrityCheck 'App', 'HF_ReportBaseTable_empty','PatientSID', 'PatientSID-1:1|NotEmpty';
EXEC maintenance.DataIntegrityCheck 'APP', 'HF_ReportBaseTable', 'PatientSID',NULL, '1:1';
EXEC maintenance.DataIntegrityCheck 'App', 'HF_ReportBaseTable', 'PatientSID', 'AdjustedSID', 'BrokenCardinality';
EXEC maintenance.DataIntegrityCheck 'project', 'Hypertension_Basetable', 'EndoProviderSID', 'EndoProviderSID-1:1|NotEmpty';
EXEC maintenance.DataIntegrityCheck 'project', 'Hypertension_Basetable', 'EndoProviderSID', NULL, '1:1';



