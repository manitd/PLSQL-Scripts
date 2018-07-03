
/****** Object:  StoredProcedure [dbo].[spGenInsertQry]    Script Date: 03/07/2018 8:05:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Authore : neeraj prasad sharma (please dont remove this :))
Example (1) Exec [dbo].[INS]  'Dbo.test where 1=1'
        (2) Exec [dbo].[INS]  'Dbo.test where name =''neeraj''' * for string

here Dbo is schema and test is tablename and 1=1 is condition

*/

                                           
--DECLARE   @Query  Varchar(MAX)   ='DBO.TABLE1 WHERE 1=1'
--DECLARE @Conditioncol  VARCHAR(50)='COL1'                                                      
--DECLARE @Conditioncol2  VARCHAR(50)='COL2'
--DECLARE @Conditioncol3  VARCHAR(50)='COL3'

ALTER PROCEDURE [dbo].[spGenInsertQry]
(
@Query  Varchar(MAX),   
@Conditioncol  VARCHAR(50)=NULL,                                                     
@Conditioncol2  VARCHAR(50)=NULL,
@Conditioncol3  VARCHAR(50)=NULL,
@UpdateCondition VARCHAR(50) =NULL
)                          
AS
SET nocount ON                  
--SELECT @Query
DECLARE @AllCondition VARCHAR(MAX)
DECLARE @Conditioncols VARCHAR(MAX)
DECLARE @Conditioncols2 VARCHAR(MAX)
DECLARE @Conditioncols3 VARCHAR(MAX)
DECLARE @WithStrINdex as INT                            
DECLARE @WhereStrINdex as INT                            
DECLARE @INDExtouse as INT                            

DECLARE @SchemaAndTAble VArchar(270)                            
DECLARE @Schema_name  varchar(30)                            
DECLARE @Table_name  varchar(240)                            
DECLARE @Condition  Varchar(MAX)                             

SET @WithStrINdex=0                            

SELECT @WithStrINdex=CHARINDEX('With',@Query )                            
, @WhereStrINdex=CHARINDEX('WHERE', @Query)                            

IF(@WithStrINdex!=0)                            
SELECT @INDExtouse=@WithStrINdex                            
ELSE                            
SELECT @INDExtouse=@WhereStrINdex                            

SELECT @SchemaAndTAble=Left (@Query,@INDExtouse-1)                                                     
SELECT @SchemaAndTAble=Ltrim (Rtrim( @SchemaAndTAble))                            

SELECT @Schema_name= Left (@SchemaAndTAble, CharIndex('.',@SchemaAndTAble )-1)                            
,      @Table_name = SUBSTRING(  @SchemaAndTAble , CharIndex('.',@SchemaAndTAble )+1,LEN(@SchemaAndTAble) )                            

,      @CONDITION=SUBSTRING(@Query,@WhereStrINdex+6,LEN(@Query))--27+6                            


DECLARE @COLUMNS  table (Row_number SmallINT , Column_Name VArchar(Max) )                              
DECLARE @CONDITIONS as varchar(MAX)                              
DECLARE @UpdateCondtions as varchar(MAX)   
DECLARE @Total_Rows as SmallINT                              
DECLARE @Counter as SmallINT              

DECLARE @ComaCol as varchar(max)            
SELECT @ComaCol=''                   

SET @Counter=1                              
SET @CONDITIONS=''                              

INSERT INTO @COLUMNS                              
SELECT Row_number()Over (Order by ORDINAL_POSITION ) [Count], Column_Name 
FROM INformation_schema.columns 
WHERE Table_schema=@Schema_name AND table_name=@Table_name         


SELECT @Total_Rows= Count(1) 
FROM @COLUMNS                              

SELECT @Table_name= '['+@Table_name+']'                      

SELECT @Schema_name='['+@Schema_name+']'                      

	While (@Counter<=@Total_Rows )                              
	begin                               
	--PRINT @Counter                              

	SELECT @ComaCol= @ComaCol+'['+Column_Name+'],'            
	FROM @COLUMNS                              
	WHERE [Row_number]=@Counter   
	                       
	SELECT @CONDITIONS=@CONDITIONS+ ' + Case When ['+Column_Name+'] is null then ''Null'' Else '''''''' +REPLACE(Convert(varchar(Max),['+Column_Name+']  ),'''''''','''''''''''') +'''''''' end+'+''','''                                                     --' + Case When ['+Column_Name+'] is null then ''Null'' Else '''''''' + Replace( Convert(varchar(Max),['+Column_Name+']  ) ,'''''''',''''  ) +'''''''' end+'+''','''                                                     
	FROM @COLUMNS                              
	WHERE [Row_number]=@Counter     
	
                   
	IF @UpdateCondition=(SELECT Column_Name from @COLUMNS WHERE [Row_number]=@Counter AND Column_Name=@UpdateCondition)
	BEGIN
	
		
		SET @UpdateCondtions=(SELECT Column_Name +' = '+''' + Case When ['+Column_Name+'] is null then ''Null'' Else '''''''' + REPLACE(Convert(varchar(Max),['+Column_Name+']  ),'''''''','''''''''''') +'''''''' end+'
		FROM @COLUMNS WHERE [Row_number]=@Counter AND Column_Name=@UpdateCondition)
	
	END
	SET @Counter=@Counter+1                              

	End                              
SELECT @Conditioncols = 'Case When ['+@Conditioncol+'] is null then ''Null'' Else '''''''' + Convert(varchar(Max),['+@Conditioncol+']  )  +'''''''' end+'                                                     --'Case When ['+@Conditioncol+'] is null then ''Null'' Else '''''''' + Replace( Convert(varchar(Max),['+@Conditioncol+']  ) ,'''''''',''''  ) +'''''''' end+'                                                     
SELECT @Conditioncols2 = 'Case When ['+@Conditioncol2+'] is null then ''Null'' Else '''''''' + Convert(varchar(Max),['+@Conditioncol2+']  )  +'''''''' end+'                                                     --'Case When ['+@Conditioncol+'] is null then ''Null'' Else '''''''' + Replace( Convert(varchar(Max),['+@Conditioncol+']  ) ,'''''''',''''  ) +'''''''' end+'                                                     
SELECT @Conditioncols3 = 'Case When ['+@Conditioncol3+'] is null then ''Null'' Else '''''''' + Convert(varchar(Max),['+@Conditioncol3+']  )  +'''''''' end+'                                                     --'Case When ['+@Conditioncol+'] is null then ''Null'' Else '''''''' + Replace( Convert(varchar(Max),['+@Conditioncol+']  ) ,'''''''',''''  ) +'''''''' end+'                                                     

--select @CONDITIONS
SELECT @CONDITIONS=Right(@CONDITIONS,LEN(@CONDITIONS)-2)                              

SELECT @CONDITIONS=LEFT(@CONDITIONS,LEN(@CONDITIONS)-4)              
SELECT @ComaCol= substring (@ComaCol,0,  len(@ComaCol) )                            
--SELECT @CONDITIONS
--SELECT @Conditioncols

IF @Conditioncols IS NOT NULL
SELECT @AllCondition ='''IF NOT EXISTS(SELECT 1 FROM '+@Schema_name+'.'+@Table_name+ ' WHERE '+ @Conditioncol+'=  ''+'+@Conditioncols
IF @Conditioncols2 IS NOT NULL
SELECT @AllCondition =@AllCondition+ ''' AND '+ @Conditioncol2+'=  ''+'+@Conditioncols2
IF @Conditioncols3 IS NOT NULL
SELECT @AllCondition =@AllCondition+ ''' AND '+ @Conditioncol3+'=  ''+'+@Conditioncols3

IF @Conditioncols IS NOT NULL
SELECT @AllCondition =@AllCondition+'+'' )' + CHAR(13) + 'BEGIN' + CHAR(13)

IF @Conditioncols IS NOT NULL
SELECT @AllCondition= @AllCondition+ ' INSERT INTO '+@Schema_name+'.'+@Table_name+ '('+@ComaCol+')' + CHAR(13)+' Values( '+'''' + '+'+@CONDITIONS  +'+'+ ''')  '                            
ELSE
SELECT @AllCondition= ''' INSERT INTO '+@Schema_name+'.'+@Table_name+ '('+@ComaCol+')' + CHAR(13)+' Values( '+'''' + '+'+@CONDITIONS   +'+'+ ''')  '                           

--PRINT @AllCondition
IF @Conditioncols IS NOT NULL
SELECT @AllCondition=@AllCondition+CHAR(13)+'  END  '

IF @UpdateCondtions IS NOT NULL
SELECT @AllCondition =@AllCondition +' ELSE UPDATE '+@Schema_name+'.'+@Table_name+ ' SET '+@UpdateCondtions+''' WHERE '+ @Conditioncol+'=  ''+'+@Conditioncols +''''
IF @Conditioncols IS NOT NULL
SELECT @AllCondition=@AllCondition+CHAR(13)+'PRINT '+'''+CAST(ROW_NUMBER() OVER(ORDER BY '+@Conditioncol+') AS VARCHAR(10))+'''+'''' 
ELSE
SELECT @AllCondition=@AllCondition+'''' 


SELECT @CONDITIONS= 'Select  '+@AllCondition +' FROM  ' +@Schema_name+'.'+@Table_name+' With(NOLOCK) ' + ' Where '+@Condition 

print(@CONDITIONS)                              
Exec(@CONDITIONS)  