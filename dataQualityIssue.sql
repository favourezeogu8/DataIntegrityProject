USE PBM_AD;
GO
IF OBJECT_ID(&#39;maintenance.DataQualityIssueLogs&#39;) IS NULL
BEGIN
CREATE TABLE maintenance.DataQualityIssueLogs (
    IssueID INT IDENTITY (1,1) PRIMARY key,
    DataIssueIdentifer VARCHAR(30),
    IssueLog VARCHAR(30),
    IssueDiscription VARCHAR(30),
    DateDetected DATETIME DEFAULT GETDATE()

);
END;

GO
SELECT * FROM maintenance.DataQualityIssueLogs ORDER By DateDetected ;