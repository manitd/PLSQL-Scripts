DECLARE @SearchStr nvarchar(max)
SET @SearchStr = 'src'
 
    CREATE TABLE #Results (ColumnName nvarchar(max), ColumnValue nvarchar(max))
 DECLARE @StrResult VARCHAR(MAX)
    SET NOCOUNT ON
 
    DECLARE @TableName nvarchar(max), @ColumnName nvarchar(max), @SearchStr2 nvarchar(max)
    SET  @TableName = ''
    SET @SearchStr2 = QUOTENAME('%' + @SearchStr + '%','''')
 
    WHILE @TableName IS NOT NULL
     
    BEGIN
        SET @ColumnName = ''
        SET @TableName = 
        (
            SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
            FROM     INFORMATION_SCHEMA.TABLES
            WHERE         TABLE_TYPE = 'BASE TABLE'
                AND    QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
                AND    OBJECTPROPERTY(
                        OBJECT_ID(
                            QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
                             ), 'IsMSShipped'
                               ) = 0
        )
 
        WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
             
        BEGIN
            SET @ColumnName =
            (
                SELECT MIN(QUOTENAME(COLUMN_NAME))
                FROM     INFORMATION_SCHEMA.COLUMNS
                WHERE         TABLE_SCHEMA    = PARSENAME(@TableName, 2)
                    AND    TABLE_NAME    = PARSENAME(@TableName, 1) AND TABLE_NAME NOT LIKE '%$%'
                    AND    DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar', 'int', 'decimal')
                    AND    QUOTENAME(COLUMN_NAME) > @ColumnName
            )
     
            IF @ColumnName IS NOT NULL
             
            BEGIN
			Set @StrResult='SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) FROM ' + @TableName + ' (NOLOCK) ' +
                    ' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
					PRINT @StrResult
                INSERT INTO #Results
                EXEC(@StrResult)
                --(
                --    'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) FROM ' + @TableName + ' (NOLOCK) ' +
                --    ' WHERE ' + @ColumnName + ' LIKE ' + @SearchStr2
                --)
				
				
            END
			
        END 
		
    END
 
    --SELECT distinct ColumnName,ColumnValue FROM #Results where ColumnName like '%[sdfCommodity]%'
    -- SELECT distinct ColumnName FROM #Results
DROP TABLE #Results