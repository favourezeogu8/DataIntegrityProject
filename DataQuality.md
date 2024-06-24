# Data Quality Test Procedure Documentation
## Overview
This document provides guidelines and instructions for using the `DataIntegrityCheck` SQL
stored procedure to perform data quality checks on database tables. The checks log any
identified issues into the `maintenance.DataQualityIssueLogs` table.
## Pre-requisites
```sql
IF OBJECT_ID(&#39;maintenance.DataQualityIssueLogs&#39;) IS NULL
BEGIN
    CREATE TABLE maintenance.DataQualityIssueLogs (
        IssueID INT IDENTITY(1,1) PRIMARY KEY,
        LogTable VARCHAR(200),
        LogColumn VARCHAR(200),
        IssueDescription VARCHAR(200),
        DateDetected DATETIME DEFAULT GETDATE()
    );
END;
```
Ensure the logging table is set up in your database by executing the following SQL script:
# Using the DataIntegrityCheck Procedure
## Syntax
DataIntegrityCheck @SchemaName, @TableName, @ColumnName, [@SecondColumnName], @Checks
## Parameters
•   @SchemaName NVARCHAR(200) - Schema name of the table.
•   @TableName NVARCHAR(200) - Name of the table to perform checks on.
•   @ColumnName NVARCHAR(200) - Primary column for data quality checks.
•   @SecondColumnName NVARCHAR(200) - Secondary column for specific checks (optional).
•   @Checks NVARCHAR(MAX) - Specifies the types of checks to be performed.
## Available Tests
•   NotEmpty - Ensures the table is not empty.
•   1:1 - Ensures all values in the specified column are unique.
•   BrokenCardinality - Checks for unique combinations of two columns.
## Example Usage

**Check if table is not empty and if column values are unique:**
```sql
EXEC DataIntegrityCheck &#39;APP&#39;, &#39;HF_ReportBaseTable_empty&#39;, &#39;PatientSID&#39;, NULL, &#39;PatientSID-
1:1|NotEmpty&#39;;
```
**Check for unique/Distint Column:**
```SQL
EXEC DataIntegrityCheck &#39;APP&#39;, &#39;HF_ReportBaseTable&#39;, &#39;PatientSID&#39;, NULL, &#39;1:1&#39;;
```
**Check for broken cardinality between two columns:**
sql
```SQL
EXEC DataIntegrityCheck &#39;App&#39;, &#39;HF_ReportBaseTable&#39;, &#39;PatientSID&#39;, &#39;VisitID&#39;,
&#39;BrokenCardinality&#39;;*
```
# Viewing Logs
## To view the issues logged by the data quality checks, execute:
```SQL
SELECT * FROM maintenance.DataQualityIssueLogs ORDER BY DateDetected;
Extending the Procedure
```
# Extending the Procedure
## To add new tests, incorporate additional logic into the DataIntegrityCheck procedure like
the example below:
```SQL
IF @Checks LIKE &#39;%NewTest%&#39;
BEGIN
   
    -- Insert new test logic here
END
```