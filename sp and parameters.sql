DECLARE @PRODUCT VARCHAR(3)=32
DECLARE @SQL NVARCHAR(MAX)


SELECT 'EXEC '+SP+' '
+ISNULL(CASE WHEN ([1]='@ProductCode' OR [1]='@sdfProduct') THEN [1]+'='+@PRODUCT ELSE [1]+'=NULL' END,'')
+ISNULL(CASE WHEN ([2]='@ProductCode' OR [2]='@sdfProduct') THEN ','+[2]+'='+@PRODUCT ELSE ','+[2]+'=NULL' END,'')
+ISNULL(CASE WHEN ([3]='@ProductCode' OR [3]='@sdfProduct') THEN ','+[3]+'='+@PRODUCT ELSE ','+[3]+'=NULL' END,'')
+ISNULL(CASE WHEN ([4]='@ProductCode' OR [4]='@sdfProduct') THEN ','+[4]+'='+@PRODUCT ELSE ','+[4]+'=NULL' END,'')
+ISNULL(CASE WHEN ([5]='@ProductCode' OR [5]='@sdfProduct') THEN ','+[5]+'='+@PRODUCT ELSE ','+[5]+'=NULL' END,'')
+ISNULL(CASE WHEN ([6]='@ProductCode' OR [6]='@sdfProduct') THEN ','+[6]+'='+@PRODUCT ELSE ','+[6]+'=NULL' END,'')
FROM 
(
SELECT PC.name SP,ISNULL(P.name,' ') AS NAME,RANK() OVER (PARTITION BY PC.NAME ORDER BY PC.name,P.name) AS SLNO FROM sys.procedures PC
INNER JOIN sys.parameters P ON P.object_id=PC.object_id
WHERE PC.name LIKE '%ENG%' AND PC.name LIKE '%GET%' AND  NOT (PC.name LIKE  '%UPLOAD%' OR PC.name LIKE  '%UPDATE%'  )
)T

PIVOT
(MAX(NAME) FOR SLNO IN([1],[2],[3],[4],[5],[6]))PVT;

--SELECT * FROM sys.PARAMETERS


--EXEC spGetEngAccountDtls	@LoginUser=17,	@QuotationNo=NULL,	@sdfProduct=32



DROP TABLE Proc$

WITH Procdetails(slno,ProcName,ParameterName,DataType,ObjID,ParaMID)
AS
(

SELECT ROW_NUMBER() OVER (PARTITION BY ProcName ORDER BY ProcName) AS SLNO,ProcName,ProcColName,Datatype,OBJECT_ID,parameter_id FROM
(
SELECT P.NAME AS ProcName,PM.name as ProcColName ,T.NAME+ ISNULL(CASE WHEN T.NAME='varchar' THEN '('+CAST(PM.max_length as VARCHAR(10))+')' 
										  WHEN T.NAME='NUMERIC' THEN '('+CAST(PM.precision as varchar(10))+','+CAST(PM.SCALE AS VARCHAR(10))+')' 
										  END,'') Datatype,p.object_id,pm.parameter_id
FROM SYS.procedures P
INNER JOIN SYS.parameters  PM ON P.object_id=PM.object_id
INNER JOIN SYS.types T ON PM.user_type_id=T.user_type_id
WHERE P.NAME NOT LIKE 'SP@_%' ESCAPE '@'
UNION ALL
SELECT NAME,'','','',0 FROM SYS.procedures  WHERE NAME NOT LIKE 'SP@_%' ESCAPE '@'
)t
)

SELECT ProcName ,ParameterName,DataType INTO Proc$ FROM Procdetails 
ORDER BY ProcName,ParaMID

SELECT * FROM SYS.procedures WHERE NAME NOT LIKE 'SP@_%' ESCAPE '@'

SELECT * FROM SYS.procedures WHERE NAME LIKE '%_%'

EXEC sp_procedure_params_rowset spUpdOthLiaQuickquoteDtls