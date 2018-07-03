;WITH DD (ID,RN,TBL,COL,DT,KEYY,NN)
AS
(
SELECT ID,
ROW_NUMBER() OVER (ORDER BY T.[Table]) AS RN,
T.[Table],T.[Column],T.[Data Type],T.[key],T.IsNullable 	
FROM
(
SELECT 
	T.object_id  AS ID,
	T.name as [Table],
	C.column_id   AS CID,
	c.name AS [Column], 
	CASE WHEN I.DATA_TYPE LIKE '%VARCHAR%' THEN I.DATA_TYPE +'('+CAST(I.CHARACTER_MAXIMUM_LENGTH AS varchar) +')' 
		 WHEN I.DATA_TYPE LIKE '%NUMERIC' THEN I.DATA_TYPE +'('+CAST(I.NUMERIC_PRECISION AS varchar) +','+CAST(I.NUMERIC_SCALE AS varchar)+')' 
		 ELSE I.DATA_TYPE END as [Data Type], 
	CASE WHEN SUBSTRING(CONSTRAINT_NAME,1,2)='PK' THEN 'PK' ELSE '' END +''+
	CASE WHEN FKT.NAME IS NOT NULL THEN 'FK_'+FKT.name ELSE '' END
	+' '+ CASE WHEN DF.definition IS NOT NULL THEN 'Default '+ DF.definition ELSE '' END as [key],
	I.IS_NULLABLE as [IsNullable]

FROM sys.tables AS T
	INNER JOIN sys.columns C ON T.object_id=C.object_id 
	LEFT JOIN INFORMATION_SCHEMA.COLUMNS  I ON I.TABLE_NAME=T.name AND I.COLUMN_NAME=C.NAME
	LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE  CU ON CU.TABLE_NAME=T.name AND CU.COLUMN_NAME=C.NAME
	--INNER JOIN sys.objects OB ON OB.object_id=t.object_id
	LEFT JOIN sys.foreign_key_columns FK on FK.parent_object_id =c.object_id and C.column_id=FK.parent_column_id
	LEFT JOIN sys.foreign_keys Fky ON Fky.object_id=FK.constraint_object_id 
	LEFT JOIN sys.tables FKT ON FKT.object_id=Fky.referenced_object_id 
	LEFT JOIN sys.default_constraints DF ON DF.parent_object_id=C.object_id AND C.column_id=DF.parent_column_id
UNION ALL
SELECT 
	T.object_id  AS ID,	T.name as [Table],	0   AS CID,	'' AS [Column], 	'' as [Data Type], 	'' as [key],	'' AS [IsNullable]
FROM sys.tables AS T
) AS T	
WHERE T.[Table] LIKE 'sdfclient%'
GROUP BY T.ID,T.[Table],T.CID,T.[Column],T.[Data Type],T.[key],T.IsNullable 
)


SELECT CASE WHEN T1.TBL=T2.TBL THEN '' ELSE T1.TBL END TBL,T1.COL,T1.DT,T1.KEYY,T1.NN FROM DD T1
LEFT JOIN DD T2 ON T2.RN=T1.RN -1
ORDER BY T1.ID,T1.RN




