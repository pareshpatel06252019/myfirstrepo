CREATE PROCEDURE [dbo].[Procedure1]
	@param1 int = 0,
	@param2 int
AS
BEGIN
PRINT 'A'

/*
---------
---------_CodeGenerator_NotInUsed

/****** Object:  StoredProcedure [dbo].[_CodeGenerator_NotInUsed]    Script Date: 6/27/2022 11:08:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[_CodeGenerator_NotInUsed]
	@TableName NVARCHAR(MAX),
	@TableShortName NVARCHAR(MAX) = NULL,
	@PKFieldName NVARCHAR(MAX),
	@AlreadyExistFields NVARCHAR(MAX) = NULL,
	@IsTransactionApply bit = false,
	@ClsTableName NVARCHAR(MAX) = NULL,
	@AddLOVs NVARCHAR(MAX) = NULL, --Singular table name
	@ListLOVs NVARCHAR(MAX) = NULL, --Singular table name
	@MainColumns NVARCHAR(MAX) = NULL,
	@ParameterColumns NVARCHAR(MAX) = NULL,
	@Namespace NVARCHAR(MAX) = NULL,
	@DevelopmentBy	VARCHAR(50) = 'Auto generated',
	@DevelopmentDateTime DATETIME2 = NULL
AS
/***********************************************************************************************
	 NAME     :  _CodeGenerator
	 PURPOSE  :  This SP useful for generate Classes like BLL, Entity, WebAPI, Page HTML, Angular code like controller, service, model 
				 store procedure like Insert, Update, Delete and Select.
	 REVISIONS:
		Ver			Date			Author					Description
	 ---------   ----------		---------------		 -----------------------------
		1.0      7/3/2016		Rekansh Patel			1. Initial Version.
				 10/27/2017		DHANASHRI K.			1. Change datatype DateTime,Date to DateTime2,SYSUTCDATETIME()

 EXAMPLE:
	EXEC [dbo].[_CodeGenerator]
	@TableName = 'Users', --Actual database table name
	@TableShortName = 'U', --Table short name, if table name is UserRole then short name is UR
	@PKFieldName = 'Id', --Table primary key field name
	@AlreadyExistFields = 'UserName ShortName LongName', --Already exists check field list by space seperated while insert or update
	@IsTransactionApply = 0,
	@ClsTableName = 'User', --Class name except word cls and BLL, EAL, Controller means if you enter User then BLL > clsUserBLL, EAL > clsUserEAL, model > UserModel etc...
	@AddLOVs = 'Organization UserRole Facility', --Singular table name list by space sperated for page add/edit mode
	@ListLOVs = 'Organization', --Singular table name list by space sperated for page list mode
	@MainColumns = 'Id UserName ShortName LongName', --Main fields list by space seperated for LOV
	@ParameterColumns = 'OrgId Id', --Field list by space seperated for create where part and parameter class
	@Namespace = 'Admin.Account', --Class namespace for generete namespace and routes
	@DevelopmentBy	= 'Rekansh Patel' --Developer name

*******************************************************************************************************/
BEGIN
	IF(@ClsTableName IS NULL)
		SET @ClsTableName = REPLACE(@TableName, 'tbl', '')
	
	IF(@TableShortName IS NULL)
		SET @TableShortName = SUBSTRING(@TableName, 1, 1)
	
	DECLARE @MainColumnsTable table(
		FieldName NVARCHAR(MAX)
	)
	INSERT INTO @MainColumnsTable(FieldName)
	SELECT t.value
	FROM dbo.fnSplit(@MainColumns, ' ') t
	
	DECLARE @ParameterColumnsTable table(
		FieldName NVARCHAR(MAX)
	)
	INSERT INTO @ParameterColumnsTable(FieldName)
	SELECT t.value
	FROM dbo.fnSplit(@ParameterColumns, ' ') t
	
	DECLARE @Route NVARCHAR(MAX)
	DECLARE @AddLOVsCount int
	DECLARE @ListLOVsCount int
	SELECT @AddLOVsCount = count(1) FROM dbo.fnSplit(@AddLOVs, ' ') t
	SELECT @ListLOVsCount = count(1) FROM dbo.fnSplit(@ListLOVs, ' ') t

	DECLARE @BLL_String NVARCHAR(MAX)
	DECLARE @EAL_String NVARCHAR(MAX)
	DECLARE @PKFieldDataType NVARCHAR(MAX)
	DECLARE @PKNetFieldDataType NVARCHAR(MAX)
	DECLARE @PKNetConvert NVARCHAR(MAX)

	DECLARE @PublicProperty NVARCHAR(MAX)
	DECLARE @SetDefaulValue NVARCHAR(MAX)
	DECLARE @PublicMainProperty NVARCHAR(MAX)
	DECLARE @SetMainDefaulValue NVARCHAR(MAX)
	DECLARE @SpSelectMainFields NVARCHAR(MAX)
	DECLARE @PublicParameterProperty NVARCHAR(MAX)
	DECLARE @SetParameterDefaulValue NVARCHAR(MAX)
	
	DECLARE @ColumnName NVARCHAR(MAX)
	DECLARE @DataType NVARCHAR(MAX)
	DECLARE @IsNullable bit
	DECLARE @DataSize NVARCHAR(MAX)
	DECLARE @NetDataType NVARCHAR(MAX)
	DECLARE @NetConvert NVARCHAR(MAX)
	DECLARE @NetDefaultValue NVARCHAR(MAX)

	DECLARE @InsertAddParameter NVARCHAR(MAX)
	DECLARE @UpdateAddParameter NVARCHAR(MAX)
	DECLARE @SelectAddParameter NVARCHAR(MAX)
	DECLARE @SpSelectForParameter NVARCHAR(MAX)
	DECLARE @SpSelectForParameterPass NVARCHAR(MAX)
	DECLARE @SpSelectForParameterWhere NVARCHAR(MAX)
	DECLARE @BLLParameter NVARCHAR(MAX)

	DECLARE @SpInsertString NVARCHAR(MAX)
	DECLARE @AlreadyExistInsertSting NVARCHAR(MAX)
	DECLARE @SpInsertParameter NVARCHAR(MAX)
	DECLARE @SpInsertField NVARCHAR(MAX)
	DECLARE @SpInsertValue NVARCHAR(MAX)

	DECLARE @SpUpdateString NVARCHAR(MAX)
	DECLARE @AlreadyExistUpdateSting NVARCHAR(MAX)
	DECLARE @SpUpdateParameter NVARCHAR(MAX)
	DECLARE @SpUpdateSet NVARCHAR(MAX)

	DECLARE @SpDeleteString NVARCHAR(MAX)

	DECLARE @SpSelectString NVARCHAR(MAX)
	DECLARE @SpSelectForAddString NVARCHAR(MAX)
	DECLARE @SpSelectForEditString NVARCHAR(MAX)
	DECLARE @SpSelectForGridString NVARCHAR(MAX)
	DECLARE @SpSelectForExportString NVARCHAR(MAX)
	DECLARE @SpSelectForListString NVARCHAR(MAX)
	DECLARE @SpSelectForLOVString NVARCHAR(MAX)
	DECLARE @SpSelectForRecordString NVARCHAR(MAX)

	DECLARE @SpSelectParameter NVARCHAR(MAX)
	DECLARE @SpSelectParameterPass NVARCHAR(MAX)
	DECLARE @SpSelectField NVARCHAR(MAX)
	DECLARE @SpSelectWhere NVARCHAR(MAX)
	
	DECLARE @MapDataColumns NVARCHAR(MAX)
	
	DECLARE @AngularModelString NVARCHAR(MAX)
	DECLARE @ModelDefination NVARCHAR(MAX)
	DECLARE @ModelMainDefination NVARCHAR(MAX)
	DECLARE @ModelParameter NVARCHAR(MAX)
	DECLARE @SetDefaulValueJava NVARCHAR(MAX)
	
	DECLARE @WebAPIControllerString NVARCHAR(MAX)

	DECLARE @AngularServiceString NVARCHAR(MAX)
	DECLARE @AngularRouteString NVARCHAR(MAX)
	DECLARE @AngularAddEditControllerString NVARCHAR(MAX)
	DECLARE @AngularListControllerString NVARCHAR(MAX)
	
	DECLARE @HtmlControlType NVARCHAR(MAX)
	DECLARE @HtmlInputModeFields NVARCHAR(MAX)
	DECLARE @HtmlSearchModeFields NVARCHAR(MAX)
	DECLARE @HtmlGridFieldsHeader NVARCHAR(MAX)
	DECLARE @HtmlGridFieldsDetail NVARCHAR(MAX)
	DECLARE @AddEditHtmlString NVARCHAR(MAX)
	DECLARE @ListHtmlString NVARCHAR(MAX)

	SELECT @Route = REPLACE(@Namespace, '.','/')
	SET @PublicProperty = ''
	SET @SetDefaulValue = ''
	SET @PublicMainProperty = ''
	SET @SetMainDefaulValue = ''
	SET @SpSelectMainFields = ''
	SET @PublicParameterProperty = ''
	SET @SetParameterDefaulValue = ''

	SET @InsertAddParameter = ''
	SET @UpdateAddParameter = ''
	SET @SelectAddParameter = ''
	SET @BLLParameter = ''
	SET @SpSelectForParameter = ''
	SET @SpSelectForParameterPass = ''
	SET @SpSelectForParameterWhere = ''

	SET @AlreadyExistInsertSting = ''
	SET @SpInsertParameter = ''
	SET @SpInsertField = ''
	SET @SpInsertValue = ''

	SET @AlreadyExistUpdateSting = ''
	SET @SpUpdateParameter = ''
	SET @SpUpdateSet = ''

	SET @SpSelectParameter = ''
	SET @SpSelectParameterPass = ''
	SET @SpSelectField = ''
	SET @SpSelectWhere = ''

	SET @MapDataColumns = ''

	SET @AngularModelString = ''
	SET @ModelDefination = ''
	SET @ModelMainDefination = ''
	SET @ModelParameter = ''
	SET @SetDefaulValueJava = ''
	
	SET @WebAPIControllerString = ''

	SET @AngularServiceString = ''
	SET @AngularRouteString = ''
	SET @AngularAddEditControllerString = ''
	SET @AngularListControllerString = ''
	
	SET @HtmlControlType = ''
	SET @HtmlInputModeFields = ''
	SET @HtmlSearchModeFields = ''
	SET @HtmlGridFieldsHeader = ''
	SET @HtmlGridFieldsDetail = ''
	SET @AddEditHtmlString = ''
	SET @ListHtmlString = ''

	IF(@AlreadyExistFields IS NOT NULL)
	BEGIN
		SELECT @AlreadyExistInsertSting = CASE @AlreadyExistInsertSting WHEN '' THEN 'SELECT [' + @PKFieldName + '] FROM [' + @TableName + '] WHERE [' + t.value + '] = @' + t.value 
			ELSE @AlreadyExistInsertSting + ' AND [' + t.value + '] = @' + t.value END
		FROM dbo.fnSplit(@AlreadyExistFields, ' ') t

		SET @AlreadyExistUpdateSting = @AlreadyExistInsertSting + ' AND [' + @PKFieldName + '] != @' + @PKFieldName 
	END

	DECLARE @CurColumn CURSOR
	SET @CurColumn = CURSOR FOR 
		SELECT c.name ColumnName, t.name DataType, c.IsNullable,
			CASE t.name WHEN 'nvarchar' THEN '(' + CONVERT(VARCHAR, c.length/2) + ')'
				WHEN 'char' THEN '(' + CONVERT(VARCHAR, c.length) + ')'
				WHEN 'varchar' THEN '(' + CONVERT(VARCHAR, c.length) + ')'
				WHEN 'numeric' THEN '(' + CONVERT(VARCHAR, c.xprec) + ',' + CONVERT(VARCHAR, c.xscale) + ')'
				WHEN 'decimal' THEN '(' + CONVERT(VARCHAR, c.xprec) + ',' + CONVERT(VARCHAR, c.xscale) + ')'
				ELSE '' END DataSize
		FROM sysobjects o
			INNER JOIN syscolumns c ON o.id = c.id
			INNER JOIN systypes t ON c.xtype = t.xtype
		WHERE o.name = @TableName AND t.name != 'sysname'
		ORDER BY colid

	OPEN @CurColumn; 

	FETCH NEXT FROM @CurColumn INTO @ColumnName, @DataType, @IsNullable, @DataSize
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @NetDataType = CASE @DataType
			WHEN 'tinyint' THEN 'int'
			WHEN 'smallint' THEN 'int'
			WHEN 'int' THEN 'int'
			WHEN 'bigint' THEN 'long'
			WHEN 'bit' THEN 'bool'
			WHEN 'nvarchar' THEN 'string'
			WHEN 'datetime2' THEN 'DateTime2'
			WHEN 'float' THEN 'double'
			WHEN 'numeric' THEN 'decimal'
			WHEN 'decimal' THEN 'decimal'
			WHEN 'char' THEN 'string'
			WHEN 'xml' THEN 'string'
			else 'string' end

		SELECT @NetConvert = CASE @DataType
			WHEN 'tinyint' THEN 'ToInt'
			WHEN 'smallint' THEN 'ToInt'
			WHEN 'int' THEN 'ToInt'
			WHEN 'bigint' THEN 'ToLong'
			WHEN 'bit' THEN 'ToBoolean'
			WHEN 'nvarchar' THEN 'ToString'
			WHEN 'datetime2' THEN 'ToDateTime'
			WHEN 'float' THEN 'ToDouble'
			WHEN 'numeric' THEN 'ToDecimal'
			WHEN 'decimal' THEN 'ToDecimal'
			WHEN 'char' THEN 'ToString'
			WHEN 'xml' THEN 'ToString'
			else 'ToString' end

		SELECT @NetDefaultValue = CASE @DataType
			WHEN 'tinyint' THEN '0'
			WHEN 'smallint' THEN '0'
			WHEN 'int' THEN '0'
			WHEN 'bigint' THEN '0'
			WHEN 'bit' THEN 'false'
			WHEN 'nvarchar' THEN 'string.Empty'
			WHEN 'datetime' THEN 'DateTime.MinValue'
			WHEN 'float' THEN '0'
			WHEN 'numeric' THEN '0'
			WHEN 'decimal' THEN '0'
			WHEN 'char' THEN 'string.Empty'
			WHEN 'xml' THEN 'string.Empty'
			else 'string.Empty' end

		SELECT @SetDefaulValueJava = CASE @DataType
			WHEN 'tinyint' THEN '0'
			WHEN 'smallint' THEN '0'
			WHEN 'int' THEN '0'
			WHEN 'bigint' THEN '0'
			WHEN 'bit' THEN 'false'
			WHEN 'nvarchar' THEN ''''''
			WHEN 'datetime' THEN 'new Date(0)'
			WHEN 'float' THEN '0'
			WHEN 'numeric' THEN '0'
			WHEN 'decimal' THEN '0'
			WHEN 'char' THEN ''''''
			WHEN 'xml' THEN ''''''
			else '''''' end
			
		SELECT @HtmlControlType = CASE @DataType
			WHEN 'tinyint' THEN 'number'
			WHEN 'smallint' THEN 'number'
			WHEN 'int' THEN 'number'
			WHEN 'bigint' THEN 'number'
			WHEN 'bit' THEN 'checkbox'
			WHEN 'nvarchar' THEN 'text'
			WHEN 'date' THEN 'date'
			WHEN 'datetime2' THEN 'datetime2'
			WHEN 'float' THEN 'number'
			WHEN 'numeric' THEN 'number'
			WHEN 'decimal' THEN 'number'
			WHEN 'char' THEN 'text'
			WHEN 'xml' THEN 'text'
			else 'text' end

		IF(@PKFieldName = @ColumnName)
		BEGIN
			SET @PKFieldDataType = @DataType
			SET @PKNetFieldDataType = @NetDataType
			SET @PKNetConvert = @NetConvert
		END

		IF EXISTS(SELECT * FROM @MainColumnsTable WHERE FieldName = @ColumnName)
		BEGIN
			SET @PublicMainProperty = @PublicMainProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetMainDefaulValue = @SetMainDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 
			SET @SpSelectMainFields = CASE @SpSelectMainFields WHEN '' THEN  @TableShortName + '.[' + @ColumnName + ']' else @SpSelectMainFields + ', ' + @TableShortName + '.[' + @ColumnName + ']' END
			SET @ModelMainDefination = CASE @ModelMainDefination WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelMainDefination + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)
		END
		ELSE
		BEGIN
			SET @PublicProperty = @PublicProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetDefaulValue = @SetDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 
		END

		IF EXISTS(SELECT * FROM @ParameterColumnsTable WHERE FieldName = @ColumnName)
		BEGIN
			SET @PublicParameterProperty = @PublicParameterProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetParameterDefaulValue = @SetParameterDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 

			SET @BLLParameter = @BLLParameter + 'if(obj' + @ClsTableName + 'ParameterEAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'ParameterEAL.' + @ColumnName + ');' + CHAR(13)
			
			SET @SpSelectForParameter = CASE @SpSelectForParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END ELSE @SpSelectForParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END END
			SET @SpSelectForParameterPass = CASE @SpSelectForParameterPass WHEN ' ' THEN '@' + @ColumnName ELSE @SpSelectForParameterPass + ', @' + @ColumnName END
			SET @SpSelectForParameterWhere = CASE @SpSelectForParameterWhere WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' + ' = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' ELSE @SpSelectForParameterWhere + CHAR(13) + ' AND ' + @TableShortName + '.[' + @ColumnName + '] = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' END

			SET @ModelParameter = CASE @ModelParameter WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelParameter + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)
		END

		if(@PKFieldName != @ColumnName)
		begin
			SET @InsertAddParameter = @InsertAddParameter + CASE @IsNullable WHEN 1 THEN 'if(obj' + @ClsTableName + 'EAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) ELSE '' END + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'EAL.' + @ColumnName + ');' + CHAR(13)
			SET @SpInsertParameter = CASE @SpInsertParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + case @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END ELSE @SpInsertParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END END
			SET @SpInsertField = CASE @SpInsertField WHEN '' THEN '[' + @ColumnName + ']' ELSE @SpInsertField + ', [' + @ColumnName + ']' END + CHAR(13) 
			SET @SpInsertValue = CASE @SpInsertValue WHEN '' THEN '@' + @ColumnName ELSE @SpInsertValue + ', ' + '@' + @ColumnName END + CHAR(13) 
			SET @SpUpdateSet = CASE @SpUpdateSet WHEN '' THEN '[' + @ColumnName + '] = @' + @ColumnName else @SpUpdateSet + ', ' + CHAR(13) + '[' + @ColumnName + '] = @' + @ColumnName END
		end

		SET @SelectAddParameter = @SelectAddParameter + 'if(obj' + @ClsTableName + 'EAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'EAL.' + @ColumnName + ');' + CHAR(13)
		SET @SpSelectParameter = CASE @SpSelectParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + ' = NULL' ELSE @SpSelectParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + ' = NULL' END
		SET @SpSelectParameterPass = CASE @SpSelectParameterPass WHEN '' THEN '@' + @ColumnName ELSE @SpSelectParameterPass + ', @' + @ColumnName END
		SET @SpSelectField = CASE @SpSelectField WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' ELSE @SpSelectField + ', ' + @TableShortName + '.[' + @ColumnName + ']' END
		SET @SpSelectWhere = CASE @SpSelectWhere WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' + ' = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' else @SpSelectWhere + CHAR(13) + ' AND ' + @TableShortName + '.[' + @ColumnName + '] = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' END

		SET @MapDataColumns = @MapDataColumns + 'case "' + @ColumnName + '":' + CHAR(13) + 'obj'+ @ClsTableName + 'EAL.' + @ColumnName + ' = MyConvert.' + @NetConvert + '(reader["' + @ColumnName + '"]);' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @ModelDefination = CASE @ModelDefination WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelDefination + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)

		SET @HtmlSearchModeFields = @HtmlSearchModeFields + N'
							<div class="form-group">
								<label for="inputSearch' + @ColumnName + '" class="col-sm-2 control-label">' + dbo.fnUserFriendlyName(@ColumnName) + '</label>
								<div class="col-sm-10">
									<input type="number" class="form-control" name="inputSearch' + @ColumnName + '" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.' + @ColumnName + '" placeholder="' + dbo.fnUserFriendlyName(@ColumnName) + '" />
								</div>
							</div>
		'
		SET @HtmlInputModeFields = @HtmlInputModeFields + N'
							<div class="form-group {{(' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$submitted && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) || (' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$touched && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) ? ''has-error'' : ''''}}">
								<label for="input' + @ColumnName + '" class="col-sm-2 control-label">' + dbo.fnUserFriendlyName(@ColumnName) + '</label>
								<div class="col-sm-10">
									<input type="' + @HtmlControlType + '" class="form-control" name="input' + @ColumnName + '" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + '.' + @ColumnName + '" placeholder="' + dbo.fnUserFriendlyName(@ColumnName) + '" ng-required="true" />
									<div class="tooltip bottom fade in" ng-if="(' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$submitted && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) || (' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$touched && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid)">
										<div class="tooltip-arrow"></div>
										<div class="tooltip-inner ng-binding" ng-if="' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$error.required">' + dbo.fnUserFriendlyName(@ColumnName) + ' is required.</div>
									</div>
								</div>
							</div>			
		'
		
		SET @HtmlGridFieldsHeader = @HtmlGridFieldsHeader + '<th ng-sort class="link" scope-sort-expression="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression" scope-sort-direction="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection" display-name="' + dbo.fnUserFriendlyName(@ColumnName) + '" sort-expression="' + @ColumnName + '" ng-click="sortRecord(''' + @ColumnName + ''');"></th>' + CHAR(13)
		SET @HtmlGridFieldsDetail = @HtmlGridFieldsDetail + '<td>{{'+ dbo.fnJavaScriptName(@ClsTableName) + 'List.' + @ColumnName + '}}</td>' + CHAR(13)

		FETCH NEXT FROM @CurColumn INTO @ColumnName, @DataType, @IsNullable, @DataSize
	END;
	CLOSE @CurColumn;
	DEALLOCATE @CurColumn;
	
	DECLARE @Lov NVARCHAR(MAX)
	DECLARE @AddLovsEAL NVARCHAR(MAX)
	DECLARE @AddLovsModel NVARCHAR(MAX)
	DECLARE @AddEditLovDepRoute NVARCHAR(MAX)
	DECLARE @AddLovSetAngular NVARCHAR(MAX)
	DECLARE @EditLovSetAngular NVARCHAR(MAX)
	DECLARE @AddEditLovDeclareAngular NVARCHAR(MAX)

	DECLARE @ListLovsEAL NVARCHAR(MAX)
	DECLARE @ListLovsModel NVARCHAR(MAX)
	DECLARE @ListLovDepRoute NVARCHAR(MAX)
	DECLARE @ListLovSetAngular NVARCHAR(MAX)
	DECLARE @ListLovDeclareAngular NVARCHAR(MAX)

	DECLARE @MapAddEAL NVARCHAR(MAX)
	DECLARE @MapEditEAL NVARCHAR(MAX)
	DECLARE @MapListEAL NVARCHAR(MAX)
	declare @AddEditResultSet int
	declare @ListResultSet int

	DECLARE @AddLovsSPCall NVARCHAR(MAX)
	DECLARE @ListLovsSPCall NVARCHAR(MAX)

	SET @AddLovsEAL = ''
	SET @AddLovsModel = ''
	SET @AddEditLovDepRoute = ''
	SET @AddLovSetAngular = ''
	SET @EditLovSetAngular = ''
	SET @AddEditLovDeclareAngular = ''
	SET @ListLovsEAL = ''
	SET @ListLovsModel = ''
	SET @ListLovDepRoute = ''
	SET @ListLovSetAngular = ''
	SET @ListLovDeclareAngular = ''

	SET @MapAddEAL = ''
	SET @MapEditEAL = ''
	SET @MapListEAL = ''
	SET @AddEditResultSet = 0
	SET @ListResultSet = 0

	SET @AddLovsSPCall = ''
	SET @ListLovsSPCall = ''

	DECLARE @CurAddLovs CURSOR
	SET @CurAddLovs = CURSOR FOR 
		SELECT t.value
		FROM dbo.fnSplit(@AddLOVs, ' ') t

	OPEN @CurAddLovs; 

	FETCH NEXT FROM @CurAddLovs INTO @Lov
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @AddLovsEAL = @AddLovsEAL + 'public List<cls' + @Lov + 'MainEAL> ' + @Lov + 's = new List<cls' + @Lov + 'MainEAL>();' + CHAR(13)
		
		SET @MapAddEAL = @MapAddEAL + 'case ' + CONVERT(VARCHAR, @AddEditResultSet) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'AddEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)

		SET @MapEditEAL = @MapEditEAL + 'case ' + CONVERT(VARCHAR, @AddEditResultSet + 1) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'EditEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @AddLovsSPCall = @AddLovsSPCall + 'EXEC ' + @Lov + '_SelectForLOV ' + @SpSelectForParameterPass + CHAR(13)

		SET @AddLovsModel = @AddLovsModel + 'this.' + @Lov + 's = [];' + CHAR(13)

		SET @AddEditLovDepRoute = @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @Lov + '/' + @Lov + '.Service.js?v='' + version,' + CHAR(13)

		SET @AddLovSetAngular = @AddLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel.' + @Lov + 's;' + CHAR(13)
		SET @EditLovSetAngular = @EditLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel.' + @Lov + 's;' + CHAR(13)
		SET @AddEditLovDeclareAngular = @AddEditLovDeclareAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData = {' + CHAR(13) + 'data: []' + CHAR(13) + '};' + CHAR(13)

		SET @AddEditResultSet = @AddEditResultSet + 1
		FETCH NEXT FROM @CurAddLovs INTO @Lov
	END;
	CLOSE @CurAddLovs;
	DEALLOCATE @CurAddLovs;
	
	DECLARE @CurListLovs CURSOR
	SET @CurListLovs = CURSOR FOR 
		SELECT t.value
		FROM dbo.fnSplit(@ListLOVs, ' ') t

	OPEN @CurListLovs; 

	FETCH NEXT FROM @CurListLovs INTO @Lov
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ListLovsEAL = @ListLovsEAL + 'public List<cls' + @Lov + 'MainEAL> ' + @Lov + 's = new List<cls' + @Lov + 'MainEAL>();' + CHAR(13)
		
		SET @MapListEAL = @MapListEAL + 'case ' + CONVERT(VARCHAR, @ListResultSet) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'ListEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @ListLovsSPCall = @ListLovsSPCall + 'EXEC ' + @Lov + '_SelectForLOV ' + @SpSelectForParameterPass + CHAR(13)

		SET @ListLovsModel = @ListLovsModel + 'this.' + @Lov + 's = [];' + CHAR(13)

		SET @ListLovDepRoute = @ListLovDepRoute + '''Areas/' + @Route + '/' + @Lov + '/' + @Lov + '.Service.js?v='' + version,' + CHAR(13)

		SET @ListLovSetAngular = @ListLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.' + @Lov + 's;' + CHAR(13)
		SET @ListLovDeclareAngular = @ListLovDeclareAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData = {' + CHAR(13) + 'data: []' + CHAR(13) + '};' + CHAR(13)

		SET @ListResultSet = @ListResultSet + 1
		FETCH NEXT FROM @CurListLovs INTO @Lov
	END;
	CLOSE @CurListLovs;
	DEALLOCATE @CurListLovs;

	SET @UpdateAddParameter = 'objCommonDAL.AddParameter("' + @PKFieldName + '", obj' + @ClsTableName + 'EAL.' + @PKFieldName + ');' + CHAR(13) + @InsertAddParameter 
	SET @SpUpdateParameter = '@' + @PKFieldName + ' ' + @PKFieldDataType + ',' + CHAR(13) + @SpInsertParameter 

	IF(@DevelopmentDateTime IS NULL)
		SET @DevelopmentDateTime = SYSUTCDATETIME();

	SET @EAL_String = N'
	/// <summary>
	/// This class having main entities of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'MainEAL
{
	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'MainEAL()
	{
		SetDefaulValue();
	}
	#endregion

	#region Public Properties
	' + @PublicMainProperty + '
	#endregion

	#region Private Methods
	/// <summary>
	/// This function is set properties default value based on its data type in table.
	/// </summary>
	private void SetDefaulValue()
	{
		' + @SetMainDefaulValue + '
	}
	#endregion
}

	/// <summary>
	/// This class having entities of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'EAL : cls'+ @ClsTableName + 'MainEAL
{
	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'EAL()
	{
		SetDefaulValue();
	}
	#endregion

	#region Public Properties
	' + @PublicProperty + '
	#endregion

	#region Private Methods
	/// <summary>
	/// This function is set properties default value based on its data type in table.
	/// </summary>
	private void SetDefaulValue()
	{
		' + @SetDefaulValue + '
	}
	#endregion
}

    public class cls'+ @ClsTableName + 'AddEAL
    {
        ' + @AddLovsEAL + '
    }

    public class cls'+ @ClsTableName + 'EditEAL : cls'+ @ClsTableName + 'AddEAL
    {
        public cls'+ @ClsTableName + 'EAL '+ @ClsTableName + ' = new cls'+ @ClsTableName + 'EAL();
    }

    public class cls'+ @ClsTableName + 'GridEAL
    {
        public List<cls'+ @ClsTableName + 'EAL> '+ @ClsTableName + 's = new List<cls'+ @ClsTableName + 'EAL>();
        public int TotalRecords { get; set; }
    }

    public class cls'+ @ClsTableName + 'ListEAL : cls'+ @ClsTableName + 'GridEAL
    {
        ' + @ListLovsEAL + '
    }

    public class cls'+ @ClsTableName + 'ParameterEAL : clsPagingSortingEAL
    {
        #region Constructor
        /// <summary>
        /// This construction is set properties default value based on its data type in table.
        /// </summary>
        public cls'+ @ClsTableName + 'ParameterEAL()
        {
            SetDefaulValue();
        }
        #endregion

		#region Public Properties
		' + @PublicParameterProperty + '
		#endregion

		#region Private Methods
		/// <summary>
		/// This function is set properties default value based on its data type in table.
		/// </summary>
		private void SetDefaulValue()
		{
			' + @SetParameterDefaulValue + '
		}
		#endregion
    }
		'

	SET @BLL_String = N'/// <summary>
	/// This class having crud operation function of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'BLL : clsAbstractCommonBLL<cls'+ @ClsTableName + 'EAL, cls'+ @ClsTableName + 'MainEAL, cls'+ @ClsTableName + 'AddEAL, cls'+ @ClsTableName + 'EditEAL, cls'+ @ClsTableName + 'GridEAL, cls'+ @ClsTableName + 'ListEAL, cls'+ @ClsTableName + 'ParameterEAL, ' + @PKNetFieldDataType + '>
{
        ISql objCommonDAL;

	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'BLL()
	{
            objCommonDAL = CreateSqlInstance();
	}
	#endregion

        #region Public Override Methods
    /// <summary>
    /// This function return map reader table field to EAL of ' + @TableName + '.
    /// </summary>
    /// <returns>EAL</returns>
        public override cls'+ @ClsTableName + 'EAL MapData(IDataReader reader)
        {
            cls'+ @ClsTableName + 'EAL obj'+ @ClsTableName + 'EAL = new cls'+ @ClsTableName + 'EAL();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                switch (reader.GetName(i))
                {
                    ' + @MapDataColumns + '
				}
            }
            return obj'+ @ClsTableName + 'EAL;
        }

        /// <summary>
        /// This function return all columns values for perticular ' + @TableName + ' record
        /// </summary>
        /// <param name="' + @PKFieldName + '">Perticular Record</param>
        /// <returns>EAL</returns>
        public override cls'+ @ClsTableName + 'EAL SelectForRecord(' + @PKNetFieldDataType + ' ' + @PKFieldName + ')
        {
            objCommonDAL.AddParameter("' + @PKFieldName + '", ' + @PKFieldName + ');
            List<cls'+ @ClsTableName + 'EAL> '+ @ClsTableName + 's = objCommonDAL.ExecuteList<cls'+ @ClsTableName + 'EAL>("' + @TableName + '_SelectForRecord", CommandType.StoredProcedure);
            if ('+ @ClsTableName + 's.Count > 0)
                return '+ @ClsTableName + 's[0];
            else
                return new cls'+ @ClsTableName + 'EAL();
        }

        /// <summary>
        /// This function returns main informations for bind ' + @ClsTableName + ' LOV
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'EAL">Filter criteria by EAL</param>
        /// <returns>Main EALs</returns>
		public override List<cls' + @ClsTableName + 'MainEAL> SelectForLOV(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @SelectAddParameter + '
			return objCommonDAL.ExecuteList<cls' + @ClsTableName + 'MainEAL>("' + @TableName + '_SelectForLOV", CommandType.StoredProcedure);
		}

        /// <summary>
        /// This function return all LOVs data for ' + @ClsTableName + ' page add mode
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Parameter</param>
        /// <returns>Add modes all LOVs data</returns>
        public override cls' + @ClsTableName + 'AddEAL SelectForAdd(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'AddEAL obj' + @ClsTableName + 'AddEAL = new cls' + @ClsTableName + 'AddEAL();
            ' + @BLLParameter + '
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'AddEAL>("' + @TableName + '_SelectForAdd", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @AddLOVsCount) + ', ref obj' + @ClsTableName + 'AddEAL, MapAddEAL);
            return obj' + @ClsTableName + 'AddEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' page add mode LOVs
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="obj' + @ClsTableName + 'AddEAL">Add mode EAL for fill data</param>
        /// <param name="reader">Database reader</param>
        public override void MapAddEAL(int resultSet, ref cls' + @ClsTableName + 'AddEAL obj' + @ClsTableName + 'AddEAL, IDataReader reader)
        {
            switch(resultSet)
            {
                ' + @MapAddEAL  + '
            }		
        }

        /// <summary>
        /// This function return all LOVs data and edit record information for ' + @ClsTableName + ' page edit mode
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Parameter</param>
        /// <returns>Edit modes all LOVs data and edit record information</returns>
        public override cls' + @ClsTableName + 'EditEAL SelectForEdit(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'EditEAL obj' + @ClsTableName + 'EditEAL = new cls' + @ClsTableName + 'EditEAL();
            ' + @BLLParameter + '
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'EditEAL>("' + @TableName + '_SelectForEdit", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @AddLOVsCount + 1) + ', ref obj' + @ClsTableName + 'EditEAL, MapEditEAL);
            return obj' + @ClsTableName + 'EditEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' page edit mode LOVs and edit record information
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'EditEAL">Edit mode EAL for fill data and edit record information</param>
        /// <param name="reader">Database reader</param>
        public override void MapEditEAL(int resultSet, ref cls' + @ClsTableName + 'EditEAL obj' + @ClsTableName + 'EditEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                case 0:
                    obj' + @ClsTableName + 'EditEAL.' + @ClsTableName + ' = objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader);
                    break;
                ' + @MapEditEAL  + '
            }
        }

        /// <summary>
        /// This function returns ' + @ClsTableName + ' list page grid data.
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Filter paramters</param>
        /// <returns>' + @ClsTableName + ' grid data</returns>
        public override cls' + @ClsTableName + 'GridEAL SelectForGrid(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'GridEAL obj' + @ClsTableName + 'GridEAL = new cls' + @ClsTableName + 'GridEAL();
            ' + @BLLParameter + '
            objCommonDAL.AddParameter("SortExpression", obj' + @ClsTableName + 'ParameterEAL.SortExpression);
            objCommonDAL.AddParameter("SortDirection", obj' + @ClsTableName + 'ParameterEAL.SortDirection);
            objCommonDAL.AddParameter("PageIndex", obj' + @ClsTableName + 'ParameterEAL.PageIndex);
            objCommonDAL.AddParameter("PageSize", obj' + @ClsTableName + 'ParameterEAL.PageSize);
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'GridEAL>("' + @TableName + '_SelectForGrid", CommandType.StoredProcedure, 2, ref obj' + @ClsTableName + 'GridEAL, MapGridEAL);
            return obj' + @ClsTableName + 'GridEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' grid data
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'GridEAL">' + @ClsTableName + ' grid data</param>
        /// <param name="reader">Database reader</param>
        public override void MapGridEAL(int resultSet, ref cls' + @ClsTableName + 'GridEAL obj' + @ClsTableName + 'GridEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                case 0:
                    obj' + @ClsTableName + 'GridEAL.' + @ClsTableName + 's.Add(objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader));
                    break;
                case 1:
                    obj' + @ClsTableName + 'GridEAL.TotalRecords = MyConvert.ToInt(reader["TotalRecords"]);
                    break;
            }
        }

        /// <summary>
        /// This function returns ' + @ClsTableName + ' list page grid data and LOV data
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Filter paramters</param>
        /// <returns>' + @ClsTableName + ' grid data and LOV data</returns>
        public override cls' + @ClsTableName + 'ListEAL SelectForList(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'ListEAL obj' + @ClsTableName + 'ListEAL = new cls' + @ClsTableName + 'ListEAL();
            ' + @BLLParameter + '
            objCommonDAL.AddParameter("SortExpression", obj' + @ClsTableName + 'ParameterEAL.SortExpression);
            objCommonDAL.AddParameter("SortDirection", obj' + @ClsTableName + 'ParameterEAL.SortDirection);
            objCommonDAL.AddParameter("PageIndex", obj' + @ClsTableName + 'ParameterEAL.PageIndex);
            objCommonDAL.AddParameter("PageSize", obj' + @ClsTableName + 'ParameterEAL.PageSize);
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'ListEAL>("' + @TableName + '_SelectForList", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @ListLOVsCount + 2) + ', ref obj' + @ClsTableName + 'ListEAL, MapListEAL);
            return obj' + @ClsTableName + 'ListEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' list page grid data and LOV data
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'ListEAL">' + @ClsTableName + ' list page grid data and LOV data</param>
        /// <param name="reader">Database reader</param>
        public override void MapListEAL(int resultSet, ref cls' + @ClsTableName + 'ListEAL obj' + @ClsTableName + 'ListEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                ' + @MapListEAL + '
                case ' + CONVERT(VARCHAR, @ListLOVsCount) + ':
                    obj' + @ClsTableName + 'ListEAL.' + @ClsTableName + 's.Add(objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader));
                    break;
                case ' + CONVERT(VARCHAR, @ListLOVsCount + 1) + ':
                    obj' + @ClsTableName + 'ListEAL.TotalRecords = MyConvert.ToInt(reader["TotalRecords"]);
                    break;
            }
        }

		/// <summary>
		/// This function insert record in ' + @TableName + ' table.
		/// </summary>
		/// <returns>Identity / AlreadyExist = 0</returns>
		public override ' + @PKNetFieldDataType + ' Insert(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @InsertAddParameter + 'return MyConvert.' + @PKNetConvert + '(objCommonDAL.ExecuteScalar("' + @TableName + '_Insert", CommandType.StoredProcedure));
		}

		/// <summary>
		/// This function update record in ' + @TableName + ' table.
		/// </summary>
		/// <returns>PrimaryKey Field Value / AlreadyExist = 0</returns>
		public override ' + @PKNetFieldDataType + ' Update(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @UpdateAddParameter + 'return MyConvert.' + @PKNetConvert + '(objCommonDAL.ExecuteScalar("' + @TableName + '_Update", CommandType.StoredProcedure));
		}

		/// <summary>
		/// This function delete record from ' + @TableName + ' table.
		/// </summary>
		public override void Delete(' + @PKNetFieldDataType + ' ' + @PKFieldName + ', long UserId)
		{
			objCommonDAL.AddParameter("' + @PKFieldName + '", ' + @PKFieldName + ');
            objCommonDAL.AddParameter("UserId", UserId);
            objCommonDAL.AddParameter("LastUpdateDate", DateTime.UtcNow);
			objCommonDAL.ExecuteNonQuery("' + @TableName + '_Delete", CommandType.StoredProcedure);
		}
		#endregion
}
			'

	SET @WebAPIControllerString = N'    [RoutePrefix("' + LOWER(@Route + '/' + @ClsTableName) +'")]
    public class ' + @ClsTableName + 'Controller : ApiController, IPageController<cls' + @ClsTableName + 'EAL, cls' + @ClsTableName + 'ParameterEAL, ' + @PKNetFieldDataType + '>
    {
        #region Interface public methods
        [HttpGet]
        [Route("getRecord/{' + @PKFieldName + ':' + @PKNetFieldDataType +'}", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.record")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForRecord(' + @PKNetFieldDataType +' ' + @PKFieldName + ')
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForRecord(' + @PKFieldName + '));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getLovValue", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.lovValue")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.IgnoreAccessValidation)]
        [CustomCompression]
        public Response GetForLOV(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForLOV(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getAddMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.addMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Insert)]
        [CustomCompression]
        public Response GetForAdd(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForAdd(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getEditMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.editMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Update)]
        [CustomCompression]
        public Response GetForEdit(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForEdit(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getGridData", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.gridData")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForGrid(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForGrid(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getListMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.listMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForList(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForList(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("insert", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.insert")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Insert)]
        [CustomCompression]
        public Response Insert(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.Insert(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("update", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.update")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Update)]
        [CustomCompression]
        public Response Update(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.Update(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("delete/{' + @PKFieldName + ':' + @PKNetFieldDataType +'}/{UserId:long}", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.delete")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Delete)]
        [CustomCompression]
        public Response Delete(' + @PKNetFieldDataType +' ' + @PKFieldName + ', long UserId)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                obj' + @ClsTableName + 'BLL.Delete(' + @PKFieldName + ', UserId);
                objResponse = new Response();
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }
        #endregion
	}
'

	SET @SpInsertString = N'	
ALTER PROCEDURE [dbo].[' + @TableName + '_Insert]
(
	' + @SpInsertParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Insert
	 PURPOSE  :  This SP insert record in table '+ @TableName + '.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Insert
	BEGIN TRY ' ELSE '' END + '
		DECLARE @' + @PKFieldName + ' ' + @PKFieldDataType + '
		IF NOT EXISTS(' + @AlreadyExistInsertSting + ')
		BEGIN
			INSERT INTO [' + @TableName + '] (' + @SpInsertField + ') 
			VALUES (' + @SpInsertValue + ')
			SET @' + @PKFieldName + ' = SCOPE_IDENTITY();
		END
		ELSE
			SET @' + @PKFieldName + ' = 0;
	
		SELECT @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Insert
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Insert
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'
	
	SET @SpUpdateString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Update]
(
	' + @SpUpdateParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Update
	 PURPOSE  :  This SP update record in table '+ @TableName + '.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Update
	BEGIN TRY ' ELSE '' END + '
		IF NOT EXISTS(' + @AlreadyExistUpdateSting + ')
		BEGIN
			UPDATE [' + @TableName + '] 
			SET ' + @SpUpdateSet + '
			WHERE [' + @PKFieldName + '] = @' + @PKFieldName + ';
		END
		ELSE
			SET @' + @PKFieldName + ' = 0;
	
		SELECT @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Update
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Update
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'
	
	SET @SpDeleteString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Delete]
(
	@' + @PKFieldName + ' ' + @PKFieldDataType + ',
	@UserId Int,
	@LastUpdateDate DateTime2
)
 AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Delete
	 PURPOSE  :  This SP delete record from table '+ @TableName + '
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Delete
	BEGIN TRY ' ELSE '' END + '
		UPDATE [' + @TableName + '] 
		SET 
			[IsDeleted] = 1, 
			[LastUpdatedBy] = @UserId,
			[LastUpdateDate] = @LastUpdateDate
		WHERE [' + @PKFieldName + '] = @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Delete
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Delete
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'

	SET @SpSelectString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Select]
(
	' + @SpSelectParameter + ' 
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Select
	 PURPOSE  :  This SP select records from table '+ @TableName + '
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectField + ' 
	FROM [' + @TableName + '] ' + @TableShortName + '
	WHERE ' + @SpSelectWhere + ' 
END	'

	SET @SpSelectForAddString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForAdd]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForAdd
	 PURPOSE  :  This SP use for fill all LOV in '+ @TableName + ' page for add mode
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	' + @AddLovsSPCall + '
END		'

	SET @SpSelectForEditString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForEdit]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForEdit
	 PURPOSE  :  This SP use for fill all LOV in '+ @TableName + ' page for edit mode
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	EXEC '+ @TableName + '_SelectForRecord @' + @PKFieldName + '

	EXEC '+ @TableName + '_SelectForAdd ' + @SpSelectForParameterPass + '
END	 '

	SET @SpSelectForGridString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForGrid]
(
	' + @SpSelectForParameter + ', 
	@SortExpression varchar(50),
	@SortDirection varchar(5),
	@PageIndex int,
	@PageSize int
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForGrid
	 PURPOSE  :  This SP select records from table '+ @TableName + ' for bind ' + @TableName + ' page grid.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	DECLARE @SqlQuery NVARCHAR(MAX)

	SET @SqlQuery = N''
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '
	ORDER BY '' + @SortExpression + '' '' + @SortDirection + ''
	OFFSET ((@PageIndex - 1) * @PageSize) ROWS
	FETCH NEXT @PageSize ROWS ONLY
	''

	EXEC sp_executesql @SqlQuery, N''' + @SpSelectForParameter + ', @PageIndex int, @PageSize int'', ' + @SpSelectForParameterPass + ', @PageIndex, @PageSize
	
	SELECT COUNT(1) AS TotalRecords
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '

END		
	'
	
	SET @SpSelectForExportString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForExport]
(
	' + @SpSelectForParameter + ', 
	@SortExpression varchar(50),
	@SortDirection varchar(5)
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForExport
	 PURPOSE  :  This SP select records from table ' + @TableName + ' for export ' + @TableName + ' page grid data in report.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	DECLARE @SqlQuery NVARCHAR(MAX)

	SET @SqlQuery = N''
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '
	ORDER BY '' + @SortExpression + '' '' + @SortDirection 

	EXEC sp_executesql @SqlQuery, N''' + @SpSelectForParameter + ''', ' + @SpSelectForParameterPass + '
END		
	'

	SET @SpSelectForListString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForList]
(
	' + @SpSelectForParameter + ',
	@SortExpression varchar(50),
	@SortDirection varchar(5),
	@PageIndex int,
	@PageSize int
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForList
	 PURPOSE  :  This SP use for fill all LOV and list grid in '+ @TableName + ' list page
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	' + @ListLovsSPCall + '

	EXEC '+ @TableName + '_SelectForGrid ' + @SpSelectForParameterPass + ', @SortExpression, @SortDirection, @PageIndex, @PageSize
END	
	'

	SET @SpSelectForLOVString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForLOV]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForLOV
	 PURPOSE  :  This SP select records from table '+ @TableName + ' for fill LOV
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectMainFields + '
	FROM [' + @TableName + '] ' + @TableShortName + '
	WHERE ' + @SpSelectForParameterWhere + '
END		
	'

	SET @SpSelectForRecordString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForRecord]
(
	@' + @PKFieldName + ' ' + @PKFieldDataType + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForRecord
	 PURPOSE  :  This SP select perticular record from table '+ @TableName + ' for open page in edit / view mode.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE ' + @TableShortName + '.[' + @PKFieldName + '] = @' + @PKFieldName + ';
END	
	'

	SET @AngularModelString = N'function ' + @ClsTableName + 'MainModel() {
'+ @ModelMainDefination +' }

function ' + @ClsTableName + 'Model() {
'+ @ModelDefination +' }

function ' + @ClsTableName + 'AddModel() {
    ' + @AddLovsModel + '
}

function ' + @ClsTableName + 'EditModel() {
    this.' + @ClsTableName + ' = new ' + @ClsTableName + 'Model();
    ' + @AddLovsModel + '
}

function ' + @ClsTableName + 'GridModel() {
    this.TotalRecords = 0;
    this.' + @ClsTableName + 's = [];
}

function ' + @ClsTableName + 'ListModel() {
    this.TotalRecords = 0;
    this.' + @ClsTableName + 's = [];
    ' + @ListLovsModel + '
}

function ' + @ClsTableName + 'ParameterModel() {
    ' + @ModelParameter + ' 

    this.SortExpression = '''';
    this.SortDirection = '''';
    this.PageIndex = 1;
    this.PageSize = 10;
    this.TotalRecords = 100;
}
'

	SET @AngularServiceString = N'angular.module(''emsApp'').service(''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', [''baseService'', function (baseService) {
    //#region main service
    this.getRecord = function (' + dbo.fnJavaScriptName(@PKFieldName) + ') {
        return baseService.httpGet(''' + LOWER(@Route + '/' + @ClsTableName) + '/getRecord/'' + ' + dbo.fnJavaScriptName(@PKFieldName) + ');
    }

    this.getLovValue = function (obj' + @ClsTableName + 'EAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getLovValue'', obj' + @ClsTableName + 'EAL);
    }

    this.getAddMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getAddMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getEditMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getEditMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getGridData = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getGridData'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getListMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getListMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.save = function (obj' + @ClsTableName + 'EAL) {
        if (obj' + @ClsTableName + 'EAL.' + @PKFieldName + ' > 0)
            return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/update'', obj' + @ClsTableName + 'EAL);
        else
            return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/insert'', obj' + @ClsTableName + 'EAL);
    }

    this.delete = function (' + dbo.fnJavaScriptName(@PKFieldName) + ', userId) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/delete/'' + ' + dbo.fnJavaScriptName(@PKFieldName) + ' + ''/'' + userId);
    }
    //#endregion
}]);'

	SET @AngularRouteString = N'angular.module(''emsApp'').config([''$stateProvider'', ''$urlRouterProvider'', ''$ocLazyLoadProvider'', function ($stateProvider, $urlRouterProvider, $ocLazyLoadProvider) {
    $stateProvider
          .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.list'', {
              url: ''/list'',
              views: {
                  '''': {
                      templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'List.html?v='' + version,
                      controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'ListController'',
                      resolve: {
                          deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                              return $ocLazyLoad.load(
                                {
                                    files: [
                                    ' + @ListLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'List.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                    ]
                                }
                              );
                          }]
                      }
                  }
              }
          })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'', {
            url: ''/add'',
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'', {
            url: ''/edit/:id'',
            params: { ''id'': null },
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'', {
            url: ''/copy/:id'',
            params: { ''id'': null },
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
}]);
'
	
	SET @AngularAddEditControllerString = N'/// <reference path="../../../../Scripts/_references.js" />
angular.module(''emsApp'').controller(''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'', [''$scope'', ''$rootScope'', ''$state'', ''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', ''Session'', function ($scope, $rootScope, $state, ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service, Session) {
    //#region submit or cancel record
    $scope.submitRecord = function () {
        if ($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$invalid) {
            myToastr.warning(''Invalid input'');
            return;
        }
        if ($scope.accessModel.CanInsert || $scope.accessModel.CanUpdate || $scope.accessModel.CanCopy) {
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.save($scope.' + dbo.fnJavaScriptName(@ClsTableName) + ').then(function (response) {
                if (response == 0) {
                    myToastr.info("' + dbo.fnUserFriendlyName(@ClsTableName) + ' already exist.");
                    return;
                }
                else {
                    myToastr.success("' + dbo.fnUserFriendlyName(@ClsTableName) + ' submit successfully.");
                }
                $scope.cancelRecord();
            });
        }
    };

    $scope.cancelRecord = function () {
        $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.list'');
    };
    //#endregion

    //#region LOV
    //#endregion

    //#region set page UI
    $scope.setPageAddEditMode = function () {
        if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'')
            $scope.setPageAddMode();
        else if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'')
            $scope.setPageEditMode(''Edit'');
        else if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'')
            $scope.setPageEditMode(''Copy'');
    }

    $scope.setPageAddMode = function () {
        $scope.mode = ''Add'';

        var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel = new ' + @ClsTableName + 'ParameterModel();
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.OrgId = $rootScope.user.OrgId;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.UserId = $rootScope.user.Id;

        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getAddMode(' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel = new ' + @ClsTableName + 'AddModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel = response;

            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + ' = new ' + @ClsTableName + 'Model();
            ' + @AddLovSetAngular + '
        });
    }

    $scope.setPageEditMode = function (mode) {
        $scope.mode = mode;

        var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel = new ' + @ClsTableName + 'ParameterModel();
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.OrgId = $rootScope.user.OrgId;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.UserId = $rootScope.user.Id;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.' + @PKFieldName + ' = $state.params.id;

        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getEditMode(' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel = new ' + @ClsTableName + 'EditModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel = response;

            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + ' = ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel.' + @ClsTableName + ';
            ' + @EditLovSetAngular + '

            if (mode == ''Copy'')
                $scope.' + dbo.fnJavaScriptName(@ClsTableName) + '.' + @PKFieldName + ' = 0;
        });
    }

    $scope.setLOVConfiguration = function () {
        ' + @AddEditLovDeclareAngular + '
    }

    $scope.initializePage = function () {
        $scope.accessModel = Session.getAccess();

        $scope.setLOVConfiguration();

        $scope.setPageAddEditMode();
    }
    $scope.initializePage();
    //#endregion
}]);
'

	SET @AngularListControllerString = N'/// <reference path="../../../../Scripts/_references.js" />
angular.module(''emsApp'').controller(''' + dbo.fnJavaScriptName(@ClsTableName) + 'ListController'', [''$scope'', ''$rootScope'', ''$state'', ''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', ''Session'', function ($scope, $rootScope, $state, ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service, Session) {
    //#region operation
    $scope.addNewRecord = function () {
        if ($scope.accessModel.CanInsert) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'');
        }
    };

    $scope.editRecord = function (id) {
        if ($scope.accessModel.CanUpdate) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'', { ''id'': id });
        }
    };

    $scope.deleteRecord = function (id) {
        if ($scope.accessModel.CanDelete) {
            if (confirm("Do you want to delete reecord?")) {
                ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.delete(id, $rootScope.user.Id).then(function (response) {
                    myToastr.success("' + dbo.fnUserFriendlyName(@ClsTableName) + ' delete successfully.");
                    $scope.searchRecord();
                });
            }
        }
    };

    $scope.copyRecord = function (id) {
        if ($scope.accessModel.CanCopy) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'', { ''id'': id });
        }
    }
    //#endregion

    //#region search
    $scope.searchRecord = function () {
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getGridData($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel = new ' + @ClsTableName + 'GridModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel = response;
            $scope.' + @ClsTableName + 's = ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel.' + @ClsTableName + 's;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords = ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel.TotalRecords;
        });
    }

    $scope.searchCancel = function () {
        $scope.setDefaultValue();

		$scope.searchRecord();
    };

    $scope.sortRecord = function (sortExpression) {
        if (sortExpression == $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression) {
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection == ''asc'' ? $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''desc'' : $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''asc'';
        }
        else {
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression = sortExpression;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''asc'';
        }
        $scope.searchRecord();
    };
    $scope.pageChanged = function () {
        $scope.searchRecord();
    };
    //#endregion

    //#region UI
    $scope.setPageListMode = function () {
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getListMode($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel = new ' + @ClsTableName + 'ListModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel = response;
            ' + @ListLovSetAngular + '
            $scope.' + @ClsTableName + 's = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.' + @ClsTableName + 's;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.TotalRecords;
        });
    }

    $scope.showHideSearchCriteria = function () {
        if ($scope.showSearchCriteria) {
            $scope.showSearchCriteria = false;
            $scope.showSearchCriteriaImage = ''chevron-down'';
        }
        else {
            $scope.showSearchCriteria = true;
            $scope.showSearchCriteriaImage = ''chevron-up'';
        }
    }

    $scope.setLOVConfiguration = function () {
        ' + @ListLovDeclareAngular + '
    }

    $scope.setDefaultValue = function () {
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search = new ' + @ClsTableName + 'ParameterModel();

        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression = ''LastUpdateDate'';
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''desc'';
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageIndex = 1;
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize = ''10'';
    }

    $scope.initializePage = function () {
        $scope.accessModel = Session.getAccess();

        $scope.setLOVConfiguration();

        $scope.showSearchCriteria = false;

        $scope.setDefaultValue();

        $scope.setPageListMode();

        $scope.showHideSearchCriteria();
    }
    $scope.initializePage();
    //#endregion
}]);
'

	SET @AddEditHtmlString = N'
    <section class="content">
        <form class="form-horizontal" name="' + dbo.fnJavaScriptName(@ClsTableName) + 'Form" novalidate>
            <div class="row">
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' {{mode}}</h3>
                        </div>
                        <div class="box-body">
' + @HtmlInputModeFields + '
                        </div>
                        <div class="box-footer">
                            <button type="button" ng-click="cancelRecord();" class="btn btn-default">Cancel</button>
                            <button type="submit" ng-click="submitRecord();" class="btn btn-info pull-right" ng-disabled="!(accessModel.CanInsert || accessModel.CanUpdate || accessModel.CanCopy)" title="{{(accessModel.CanInsert || accessModel.CanUpdate  || accessModel.CanCopy) ? ''Click here to submit record.'' : ''You have not not add or edit or copy rights.''}}">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
'

	SET @ListHtmlString = N'
    <section class="content">
        <form class="form-horizontal" name="' + dbo.fnJavaScriptName(@ClsTableName) + 'SearchForm" novalidate>
            <div class="row">
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' Search Criteria</h3>
                            <div class="box-tools">
                                <div class="input-group input-group-sm" style="width: 40px;">
                                    <div class="input-group-btn">
                                        <button type="button" ng-click="showHideSearchCriteria();" class="btn btn-default"><i class="{{''fa fa-'' + showSearchCriteriaImage}}"></i></button>
                                        <button type="button" ng-click="addNewRecord();" class="btn btn-default" ng-disabled="!accessModel.CanInsert" title="{{accessModel.CanInsert ? ''Click here to add new record.'' : ''You have not add rights.''}}"><i class="fa fa-plus"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="box-body">
                            ' + @HtmlSearchModeFields + '
                        </div>
                        <div class="box-footer" ng-show="showSearchCriteria">
                            <button type="submit" ng-click="searchCancel();" class="btn btn-default">Reset</button>
                            <button type="submit" ng-click="searchRecord();" class="btn btn-info pull-right">Submit</button>
                        </div>
                    </div>
                </div>
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' List</h3>
                       </div>
                        <div class="box-body table-responsive">
                            <table class="table table-bordered">
                                <tbody>
                                    <tr>
                                        ' + @HtmlGridFieldsHeader + '
                                        <th style="width:50px;text-align:center">Edit</th>
                                        <th style="width:50px;text-align:center">Delete</th>
										<th style="width:50px;text-align:center">Copy</th>
                                    </tr>
                                    <tr ng-repeat="' + dbo.fnJavaScriptName(@ClsTableName) + 'List in ' + @ClsTableName + 's">
                                        ' + @HtmlGridFieldsDetail + '
                                        <td style="width:50px;text-align:center">
                                            <button type="button" class="btn btn-default" ng-click="editRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanUpdate" title="{{accessModel.CanUpdate ? ''Click here to edit this record.'' : ''You have not edit rights.''}}"><i class="fa fa-pencil"></i></button>
                                        </td>
                                        <td style="width:50px;text-align:center">
                                            <button type="button" class="btn btn-default" ng-click="deleteRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanDelete" title="{{accessModel.CanDelete ? ''Click here to delete this record.'' : ''You have not delete rights.''}}"><i class="fa fa-remove"></i></button>
                                        </td>
										<td style="width:50px;text-align:center">
											<button type="button" class="btn btn-default" ng-click="copyRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanCopy" title="{{accessModel.CanCopy ? ''Click here to copy this record.'' : ''You have not copy rights.''}}"><i class="fa fa-files-o"></i></button>
										</td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="box-tools">
                                <SELECT ng-change="pageChanged();" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize">
                                    <option value="10">10</option>
                                    <option value="20">20</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                    <option value="150">150</option>
                                    <option value="200">200</option>
                                </select>
                                <ul uib-pagination items-per-page="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize" ng-change="pageChanged();" total-items="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageIndex" max-size="3" class="pagination-sm no-margin pull-right" boundary-link-numbers="true"></ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
	'

	SELECT @SpInsertString AS [Insert SP]
	SELECT @SpUpdateString AS [Update SP]
	SELECT @SpDeleteString AS [Delete SP]
	SELECT @SpSelectString AS [Select SP]
	SELECT @SpSelectForAddString AS [Select For Add SP]
	SELECT @SpSelectForEditString AS [Select For Edit SP]
	SELECT @SpSelectForGridString AS [Select For Grid SP]
	SELECT @SpSelectForListString AS [Select For List SP]
	SELECT @SpSelectForLOVString AS [Select For LOV SP]
	SELECT @SpSelectForRecordString AS [Select For Record SP]
	SELECT @SpSelectForExportString AS [Select For Export SP]
	
	SELECT @EAL_String AS EAL
	SELECT @BLL_String AS BLL
	SELECT @BLL_String AS BLL for xml RAW
	SELECT @WebAPIControllerString AS [Web API Controller]

	SELECT @AngularModelString AS [Angular Model]
	SELECT @AngularServiceString AS [Angular Service]
	SELECT @AngularRouteString AS [Angular Route]
	SELECT @AngularAddEditControllerString AS [Angular Add-Edit Controller]
	SELECT @AngularListControllerString AS [Angular List Controller]
	SELECT @AddEditHtmlString AS [Add Edit HTML]
	SELECT @AddEditHtmlString AS AddEditHtmlString for xml RAW
	SELECT @ListHtmlString AS [List HTML]
	SELECT @ListHtmlString AS ListHtmlString for xml RAW

END





--===============================================================================================================
--===============================================================================================================
--deadlock xml
<deadlock>
 <victim-list>
  <victimProcess id="process26f51d6bc28" />
 </victim-list>
 <process-list>
  <process id="process26f51d6bc28" taskpriority="0" logused="136" waitresource="KEY: 5:72057771452923904 (6d001b99dcfd)" waittime="2896" ownerId="41006483442" transactionname="INSERT EXEC" lasttranstarted="2022-07-07T20:35:15.933" XDES="0x266c09b8040" lockMode="U" schedulerid="26" kpid="4600" status="suspended" spid="55" sbid="0" ecid="0" priority="0" trancount="2" lastbatchstarted="2022-07-07T20:35:05.497" lastbatchcompleted="2022-07-07T20:35:05.497" lastattention="1900-01-01T00:00:00.497" clientapp="SQLAgent - TSQL JobStep (Job 0x4F186D2D32C1FB47BE18F56B10DA4D12 : Step 4)" hostname="TREX-DBS-01X" hostpid="14784" loginname="TREX\sqladmin" isolationlevel="read committed (2)" xactid="41006483442" currentdb="5" currentdbname="TREX" lockTimeout="4294967295" clientoption1="671088672" clientoption2="128056">
   <executionStack>
    <frame procname="adhoc" line="1" stmtstart="62" stmtend="586" sqlhandle="0x020000000b6d7c369ee2f0e5e6f687561b2188e0a13978170000000000000000000000000000000000000000">
unknown    </frame>
    <frame procname="mssqlsystemresource.sys.sp_executesql" line="1" stmtstart="-1" sqlhandle="0x0400ff7f427f99d9010000000000000000000000000000000000000000000000000000000000000000000000">
sp_executesql    </frame>
    <frame procname="TREX.scheduler.SchedularEvent_FindOverlapSchedule" line="68" stmtstart="6232" stmtend="6394" sqlhandle="0x0300050085c55a44dffe3a007dae000001000000000000000000000000000000000000000000000000000000">
EXEC sp_executesql @SQLQuery ,N'@CurrentDateUTC datetime2 OUT',@CurrentDateUTC OU    </frame>
    <frame procname="TREX.scheduler.Schedular_UpdateIncidentDirectionLineString" line="134" stmtstart="25730" stmtend="26334" sqlhandle="0x03000500bee94e4555353d0014ae000001000000000000000000000000000000000000000000000000000000">
INSERT INTO #OverLapSchedulers (SchedularId,LinkIds,LaneStatus ,TotalLanes  , LaneDescription)
		EXEC [scheduler].[SchedularEvent_FindOverlapSchedule] 
			@EventId = @EventId
			,@EventGroupId = @EventGroupId
			,@Incidenteventid = @Incidenteventid
			,@TriggeringScheduleId = @TriggeringScheduleI    </frame>
    <frame procname="adhoc" line="1" stmtend="126" sqlhandle="0x01000500c9500719802e234b6802000000000000000000000000000000000000000000000000000000000000">
EXEC [scheduler].[Schedular_UpdateIncidentDirectionLineString]    </frame>
   </executionStack>
   <inputbuf>
EXEC [scheduler].[Schedular_UpdateIncidentDirectionLineString] 3   </inputbuf>
  </process>
  <process id="process269787aa8c8" taskpriority="0" logused="200" waitresource="KEY: 5:72057771452923904 (7dd286b216fa)" waittime="2896" ownerId="41006483426" transactionname="INSERT EXEC" lasttranstarted="2022-07-07T20:35:15.930" XDES="0x264e7354040" lockMode="S" schedulerid="27" kpid="13988" status="suspended" spid="101" sbid="0" ecid="0" priority="0" trancount="1" lastbatchstarted="2022-07-07T20:35:15.883" lastbatchcompleted="2022-07-07T20:35:15.883" lastattention="1900-01-01T00:00:00.883" clientapp="SQLAgent - TSQL JobStep (Job 0x584445A570C3704DAED66977B46AFAB2 : Step 4)" hostname="TREX-DBS-01X" hostpid="14784" loginname="TREX\sqladmin" isolationlevel="read committed (2)" xactid="41006483426" currentdb="5" currentdbname="TREX" lockTimeout="4294967295" clientoption1="671088672" clientoption2="128056">
   <executionStack>
    <frame procname="TREX.scheduler.SchedularEvent_FindOverlapSchedule" line="172" stmtstart="12398" stmtend="12658" sqlhandle="0x0300050085c55a44dffe3a007dae000001000000000000000000000000000000000000000000000000000000">
IF NOT EXISTS(SELECT 1 FROM BothDirection_OverlapSchedules WHERE Eventid = @EventId and SchedularId = @SchedularId and  isActive=1    </frame>
    <frame procname="TREX.scheduler.Schedular_UpdateIncidentDirectionLineString" line="134" stmtstart="25730" stmtend="26334" sqlhandle="0x03000500bee94e4555353d0014ae000001000000000000000000000000000000000000000000000000000000">
INSERT INTO #OverLapSchedulers (SchedularId,LinkIds,LaneStatus ,TotalLanes  , LaneDescription)
		EXEC [scheduler].[SchedularEvent_FindOverlapSchedule] 
			@EventId = @EventId
			,@EventGroupId = @EventGroupId
			,@Incidenteventid = @Incidenteventid
			,@TriggeringScheduleId = @TriggeringScheduleI    </frame>
    <frame procname="adhoc" line="1" stmtend="126" sqlhandle="0x01000500fbf90c3b40a112406402000000000000000000000000000000000000000000000000000000000000">
EXEC [scheduler].[Schedular_UpdateIncidentDirectionLineString]    </frame>
   </executionStack>
   <inputbuf>
EXEC [scheduler].[Schedular_UpdateIncidentDirectionLineString] 4   </inputbuf>
  </process>
 </process-list>
 <resource-list>
  <keylock hobtid="72057771452923904" dbid="5" objectname="TREX.dbo.BothDirection_OverlapSchedules" indexname="PK_BothDirection_OverlapSchedules" id="lock26bba8dc200" mode="X" associatedObjectId="72057771452923904">
   <owner-list>
    <owner id="process269787aa8c8" mode="X" />
   </owner-list>
   <waiter-list>
    <waiter id="process26f51d6bc28" mode="U" requestType="wait" />
   </waiter-list>
  </keylock>
  <keylock hobtid="72057771452923904" dbid="5" objectname="TREX.dbo.BothDirection_OverlapSchedules" indexname="PK_BothDirection_OverlapSchedules" id="lock26baf2e4100" mode="X" associatedObjectId="72057771452923904">
   <owner-list>
    <owner id="process26f51d6bc28" mode="X" />
   </owner-list>
   <waiter-list>
    <waiter id="process269787aa8c8" mode="S" requestType="wait" />
   </waiter-list>
  </keylock>
 </resource-list>
</deadlock>

---query_to_findout_deadlock_resources

select
b.name, c.name,c.type_desc, * from 
sys.partitions a
inner join sys.objects b on a.object_id=b.object_id
inner join sys.indexes c on a.object_id=c.object_id and
	a.index_id=c.index_id
	where partition_id in  ('72057771452923904')


select 
sys.fn_PhysLocFormatter(%%physloc%%) as PageResource,
%%lockres%% as LockResources, *
From
BothDirection_OverlapSchedules
where %%lockres%% in ('(6d001b99dcfd)','(7dd286b216fa)')

select * from sys.dm_exec_sql_text(0x020000006ce2651c99d8c2c6d7e539e7a112c7d650139c010000000000000000000000000000000000000000); 




--===============================================================================================================
--===============================================================================================================
--get_listof_Job_step_command_detail
USE MSDB
GO

SELECT 
  sj.name JobName
, sj.enabled
, sj.start_step_id
, sjs.step_id
, sjs.step_name
, sjs.subsystem
, sjs.command
, CASE on_success_action
    WHEN 1 THEN 'Quit with success'
    WHEN 2 THEN 'Quit with failure'
    WHEN 3 THEN 'Go to next step'
    WHEN 4 THEN 'Go to step ' + CAST(on_success_step_id AS VARCHAR(3))
  END On_Success
, CASE on_fail_action
    WHEN 1 THEN 'Quit with success'
    WHEN 2 THEN 'Quit with failure'
    WHEN 3 THEN 'Go to next step'
    WHEN 4 THEN 'Go to step ' + CAST(on_fail_step_id AS VARCHAR(3))
  END On_Failure
FROM dbo.sysjobs sj
  INNER JOIN dbo.sysjobsteps sjs ON sj.job_id = sjs.job_id

--===============================================================================================================
--===============================================================================================================
--Query_to_check_backup_restore_process_percentage

SELECT 
   session_id as SPID, command, a.text AS Query, start_time, percent_complete,
   dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time
FROM sys.dm_exec_requests r 
   CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a 
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE') 

--===============================================================================================================
--===============================================================================================================
--shrink_pros_cons

 Before deciding to shrink a database, it is important to be aware of all limitations and restrictions of the database shrinking process, as well as a possible negative impact on the database and SQL Server performance.

Limitations:

    It is not possible to perform SQL Server database shrinking while a database backup process is running, and vice-versa.
    A database cannot be shrunk indefinitely. When the database was initially created, the minimum size of a database has been specified and shrinking a database can not make it smaller than this value. Even a completely empty database cannot be shrunk below 1GB if the initial minimum size has been set to 1GB

Cons:

    Shrinking a SQL Server database completely ignores logical index fragmenting, and results in massive fragmentation of all indexes. This can have a negative impact on query performance since it will take longer to ‘locate’ fragmented indexes. Performing an immediate index rebuild may solve this issue, but not completely, since it will partially negate the shrinking process and create some ‘unused’ space again to properly defragment indexes, which, to some extent, negates the results of database shrink
    Shrunken files will inevitably grow again as most production databases have at least ‘some’ activity. This means that the database file will be increasing in size, and this process takes times and utilizes not-so negligible amount of resources, which can produce performance impacts on performance-intensive environments
    Performing shrinking of multiple databases on multiple occasions may result in disk fragmentation (file system fragmentation) which can cause performance issues
    The process of page allocation will be written as an activity in the transaction log file, which can result in massive transaction log file growth, especially on databases in the full recovery model
    Subsequent shrinking and transaction log files growth will slow down database startup, restore and replication time


--===============================================================================================================
--===============================================================================================================
--SP_WHO2 FOR SPECIFIC DATABASE

CREATE TABLE #sp_who2 (SPID INT,Status VARCHAR(255),
      Login  VARCHAR(255),HostName  VARCHAR(255),
      BlkBy  VARCHAR(255),DBName  VARCHAR(255),
      Command VARCHAR(255),CPUTime INT,
      DiskIO INT,LastBatch VARCHAR(255),
      ProgramName VARCHAR(255),SPID2 INT,
      REQUESTID INT)
INSERT INTO #sp_who2 EXEC sp_who2
SELECT      *
FROM        #sp_who2
-- Add any filtering of the results here :
WHERE       DBName ='TiMedOD_2021'
-- Add any sorting of the results here :
ORDER BY    DBName ASC
 
DROP TABLE #sp_who2


DBCC LOGINFO

DBCC SQLPERF (LOGSPACE);

SELECT name FROM sys.master_files WHERE type_desc = 'LOG'



--===============================================================================================================
--===============================================================================================================
--1.Find  Query Cache plan 20% of Avg CPU above last execution
SELECT 

	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.last_elapsed_time,
	dm_exec_query_stats.last_execution_time,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes,
	dm_exec_query_stats.plan_handle
	
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE databases.name = 'TREX'
AND dm_exec_query_stats.last_elapsed_time > 
(CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS bigINT) + (cast(CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS bigINT) * 20/100 as bigint)))
and last_execution_time> dateadd(HH,-1,getdate())




--===============================================================================================================
--===============================================================================================================

-- To flush Plan handle for given stored procedure : 

DECLARE @NameOfProcedure VARCHAR(255) = 'Stored procedure name'

DECLARE @planHandle VARBINARY(64) = (SELECT top 1 plan_handle
   FROM   sys.dm_exec_cached_plans AS cp
          CROSS APPLY sys.dm_exec_sql_text(plan_handle)
   WHERE  cp.cacheobjtype = N'Compiled Plan'
          AND cp.objtype = N'Proc'
          AND cp.usecounts = 1
         AND TEXT LIKE '%' + @NameOfProcedure + '%')
IF @planHandle IS NOT NULL
 BEGIN    
      PRINT 'Procedure with name like ' + @NameOfProcedure + ' plan handle found with value as given below:'
      PRINT @planHandle  
	  
      DBCC FREEPROCCACHE (@planHandle)
  
  PRINT 'Execution plan cleared for the procedure'
  END
ELSE
  BEGIN
      PRINT 'No Plan was found for the selected procedure '+ @NameOfProcedure
  END

--===============================================================================================================
--===============================================================================================================
--3.findplanfromsqltext

 SELECT 
 --top 10
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.last_elapsed_time,
	dm_exec_query_stats.last_execution_time,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE dm_exec_sql_text.text LIKE '%HighwayEvents_Insert_Wizard%';


--===============================================================================================================
--===============================================================================================================
--Below is another query to find out bad or worst performing SQLs_Stored Procedures having distribution of CPU Usage or based on Reads 


use main
go 

set transaction isolation level read uncommitted
set nocount on
declare @Top int,
		@MinServerOnlineHours int,
		@DatabaseName nvarchar(128) = 'main'
select @Top = 200

;with ByCPU as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,
						total_logical_reads/execution_count AverageReads,
						max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)
								where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_worker_time desc)
	, ByReads as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,total_logical_reads/execution_count AverageReads,max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_logical_reads desc)
	, AllQueries as
		(select * from ByCPU
		 union
		 select * from ByReads
		 )
		select top(@Top) datediff(second, a.last_execution_time, getdate()) LastExecutionSecondsAgo,
				cast(TotalReads*100./sum(TotalReads) over() as decimal(10, 2)) [%OfAllIO],
				cast(TotalCPU*100./sum(TotalCPU) over() as decimal(10, 2)) [%OfAllCPU],
				DatabaseName,
				object_name(isnull(ps.object_id, ts.object_id), 
				isnull(ps.database_id, ts.database_id)) ObjectName,
				substring(text, (statement_start_offset/2)+1,
				((case statement_end_offset
						when -1 then datalength(text)
						when 0 then datalength(text)
						else statement_end_offset
					end - statement_start_offset)/2) + 1) [Statement], 
			    --cast(p.query_plan as xml) QueryPlan,
				TotalExecutions, 
				TotalReads, 
				TotalCPU, 
				TotalDurationSec,
				a.min_logical_reads,
				AverageReads, 
				a.max_logical_reads,
				AverageCPU, 
				AverageDurationMS, 
				creation_time,
				a.last_execution_time,
				a.plan_handle
from AllQueries a
		cross apply sys.dm_exec_sql_text(sql_handle) t
		cross apply sys.dm_exec_text_query_plan(plan_handle, statement_start_offset, statement_end_offset) p
		left join sys.dm_exec_procedure_stats ps on a.plan_handle = ps.plan_handle
		left join sys.dm_exec_trigger_stats ts on a.plan_handle = ts.plan_handle
order by [%OfAllIO] desc, 
		 [%OfAllCPU] desc
go


--===============================================================================================================
--===============================================================================================================

--DBCCFreeProCache_PLAN


 SELECT 'DBCC FREEPROCCACHE (0x' + convert(varchar(max),plan_handle, 2) + ')' FROM sys.dm_exec_cached_plans CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE text LIKE N'%SELECT TOP 100 wd.Hours, wd.WageAmount, wd.ItemID, wd.EmployeeWageItemID%';


select plan_handle, creation_time, last_execution_time, execution_count, qt.text FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text (qs.[sql_handle]) AS qt

DBCC FREEPROCCACHE (plan_handle_id_goes_here)

replace the string between %% with the query interested

copy the output and run the DBCC FREEPROCCACHE


DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS

--===============================================================================================================
--===============================================================================================================

--Identifying Query Plans of particular SQL text


 SELECT 
 --top 10
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.last_elapsed_time,
	dm_exec_query_stats.last_execution_time,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE dm_exec_sql_text.text LIKE '%HighwayEvents_Insert_Wizard%';

--===============================================================================================================
--===============================================================================================================
--usp_CollectQueryPlans
create procedure [dbo].[usp_CollectQueryPlans]
as
;with PlanCache as
	(select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			total_worker_time, total_logical_reads, total_logical_writes, total_elapsed_time, total_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			row_number() over (partition by query_hash, query_plan_hash order by creation_time) rn
		from sys.dm_exec_query_stats q
		where query_hash <> 0x0000000000000000
	)
insert into QueryPlanHistory(CollectionDate, query_hash, query_plan_hash, [sql_handle], plan_handle, statement_start_offset, statement_end_offset, plan_generation_num,
							avg_worker_time, avg_logical_reads, avg_logical_writes, avg_duration, avg_rows, execution_count, creation_time, last_execution_time, query_plan)
select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			cast(total_worker_time*1./execution_count as decimal(20, 3)) avg_worker_time,
			cast(total_logical_reads*1./execution_count as decimal(20, 3)) avg_logical_reads,
			cast(total_logical_writes*1./execution_count as decimal(20, 3)) avg_logical_writes,
			cast(total_elapsed_time*1./execution_count as decimal(20, 3)) avg_duration,
			cast(total_rows*1./execution_count as decimal(20, 3)) avg_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			p.query_plan
from PlanCache q
	cross apply sys.dm_exec_text_query_plan(q.plan_handle, q.statement_start_offset, q.statement_end_offset) p
where rn = 1


--===============================================================================================================
--===============================================================================================================
/*
--flush_cache

Problem
Sometimes there are issues due to what SQL Server has stored in its cache. Here are some possible reasons which may create caching performance issues.

Ad-hoc Query workload issues due to cache bloat
Excessive use of dynamic T-SQL code
Server has insufficient memory or not properly assigned to SQL instances
Memory pressure generated due to heavy long running transactions
Server has frequent recompilation events
When issues such as these are found you may need to flush the plan cache or buffer cache. So in this tip we look at different ways to flush the SQL Server cache.

Solution
I will explain different commands that you can use to manage what is in the cache.

DBCC FREEPROCCACHE
This command allows you to clear the plan cache, a specific plan or a SQL Server resource pool.

Syntax
DBCC FREEPROCCACHE [ ( { plan_handle | sql_handle | pool_name } ) ] [ WITH NO_INFOMSGS ] 
plan handle uniquely identifies a query plan for a batch that has executed and whose plan resides in the plan cache.
sql_handle is the SQL handle of the batch to be cleared. sql_handle is varbinary(64).
pool_name is the name of a Resource Governor resource pool.
Examples
Flush the entire plan cache for a SQL Server instance.

DBCC FREEPROCCACHE
Flush the plan cached for an entire instance, but suppress the output messages.

DBCC FREEPROCCACHE WITH NO_INFOMSGS;
To flush a specific resource pool, we can use this command to see how much memory is being used for each resource pool.

SELECT name AS 'Pool Name', 
cache_memory_kb/1024.0 AS [cache_memory_MB], 
used_memory_kb/1024.0 AS [used_memory_MB] 
FROM sys.dm_resource_governor_resource_pools;
Then with the output above, we can specify the specific resource pool to flush as follows.

DBCC FREEPROCCACHE ('LimitedIOPool');
We can also flush a single query plan. To do this we need to first get the plan_handle from the plan cache as follows:

SELECT cp.plan_handle 
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid) LIKE '%TestProcedure%'
Then we can use the plan_handle as follows to flush that one query plan.

DBCC FREEPROCCACHE (0x040011004A2CC30E204881F30200000001000000000000000000000000000000000000000000000000000000);

DBCC FLUSHPROCINDB
This allows you to clear the plan cache for a specific database.

Syntax
DBCC FLUSHPROCINDB(DatabaseID)
Example
Flush the database plan cache for database MyDB.

Use MyDB; 
Declare @dbid int = db_ID() 
DBCC FLUSHPROCINDB (@dbId)
DBCC FREESYSTEMCACHE
Releases all unused cache entries from all caches. You can use this command to manually remove unused entries from all caches or from a specific Resource Governor pool.

Syntax
DBCC FREESYSTEMCACHE( 'ALL' [, pool_name ] ) [WITH { [ MARK_IN_USE_FOR_REMOVAL ] , [ NO_INFOMSGS ]]
Examples
The following example uses the MARK_IN_USE_FOR_REMOVAL clause to release entries from all current caches once the entries become unused.

DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL
Flush the ad hoc and prepared plan cache for the entire server instance.

DBCC FREESYSTEMCACHE ('SQL Plans')
Clear all table variables and temp tables cached.

DBCC FREESYSTEMCACHE ('Temporary Tables & Table Variables')
Clear for a specific user database.

DBCC FREESYSTEMCACHE ('userdatabase')
Remove the tempdb cache.

DBCC FREESYSTEMCACHE ('tempdb')
DBCC FREESESSIONCACHE
Flushes the distributed query connection cache used by distributed queries against an instance of SQL Server.

Syntax
DBCC FREESESSIONCACHE [ WITH NO_INFOMSGS ]
Example
DBCC FREESESSIONCACHE
DBCC FLUSHAUTHCACHE
DBCC FLUSHAUTHCACHE flushes the database authentication cache maintained information regarding login and firewall rules for the current user database.  This command cannot run in the master database, because the master database maintains the physical storage information regarding login and firewall rules.

Syntax
DBCC FLUSHAUTHCACHE [ ; ]
Using sp_recompile
For specific objects that are cached, we can pass a procedure name, trigger, table, view, function in the current database and it will be recompiled next time it is run.

Syntax
EXEC sp_recompile N'Object';
Example
EXEC sp_recompile N'myprocedure';
EXEC sp_recompile N'myprocedure';
EXEC sp_recompile N'mytable';
Using ALTER DATABASE
You can also clear the plan cache for the current database using ALTER DATABASE as shown below. This is new in SQL Server 2016.

Syntax
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
DBCC DROPCLEANBUFFERS
Use DBCC DROPCLEANBUFFERS to test queries with a cold buffer cache without shutting down and restarting the server.

Syntax
DBCC DROPCLEANBUFFERS [ WITH NO_INFOMSGS ] 
DBCC DROPCLEANBUFFERS ( COMPUTE | ALL ) [ WITH NO_INFOMSGS ]
WITH NO_INFOMSGS - Suppresses all informational messages. Informational messages are always suppressed on SQL Data Warehouse and Parallel Data Warehouse.
COMPUTE - Purge the query plan cache from each Compute node.
ALL - Purge the query plan cache from each Compute node and from the Control node. This is the default if you do not specify a value.
*/
--===============================================================================================================
--===============================================================================================================
/*
--wiki_QueryPlans.sql
-- Resources :
 
-- https://www.sqlshack.com/searching-the-sql-server-query-plan-cache/
https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cached-plans-transact-sql?view=sql-server-2017



---------------------------------------------------------------------------------- 
-- To find the number of single-used cached plans, run the following query:
-- Optimize for ad hoc workloads Server Configuration Option
/*
Setting the optimize for ad hoc workloads to 1 affects only new plans; plans that are already in the plan cache are unaffected. To affect already cached query plans immediately, the plan cache needs to be cleared using 
-- ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE,
*/ 
 
Sys.dm_exec_query_stats: Provides details about executions of the query, such as reads, writes, duration, etc…
Sys.dm_exec_sql_text: This function includes the text of the query executed. The plan handle is a uniquely identifying ID for a given execution plan.
sys.dm_exec_query_plan: Also a function of plan handle, this provides the XML query execution plan for a given query.
sys.databases: System view that provides quite a bit of info on each database on this instance.



----------------------------------------------------------------------------------------------------------
-- Top 25 Expensive Query Plans of main database.

SELECT TOP 1000
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE databases.name = 'main'
ORDER BY dm_exec_query_stats.total_elapsed_time DESC;
-- ORDER BY dm_exec_query_stats.max_logical_reads DESC;
-- ORDER BY dm_exec_query_stats.execution_count DESC ;  -- Most executing queries.






----------------------------------------------------------------------------------------------------------
-- Queries to find out for particular object refered.
-- Replace table or object name.

 
SELECT TOP 100
	 databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_plan.query_plan
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
WHERE dm_exec_sql_text.text LIKE '%SalesOrderHeader%';

  
 
----------------------------------------------------------------------------------------------------------
-- Identifying Query Plans of particular SQL text.
 
 
 SELECT
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE dm_exec_sql_text.text LIKE '<Replace Query Text here>';



----------------------------------------------------------------------------------------------------------
-- To flush Plan handle for given stored procedure : 

DECLARE @NameOfProcedure VARCHAR(255) = 'Stored procedure name'

DECLARE @planHandle VARBINARY(64) = (SELECT top 1 plan_handle
   FROM   sys.dm_exec_cached_plans AS cp
          CROSS APPLY sys.dm_exec_sql_text(plan_handle)
   WHERE  cp.cacheobjtype = N'Compiled Plan'
          AND cp.objtype = N'Proc'
          AND cp.usecounts = 1
         AND TEXT LIKE '%' + @NameOfProcedure + '%')
IF @planHandle IS NOT NULL
 BEGIN    
      PRINT 'Procedure with name like ' + @NameOfProcedure + ' plan handle found with value as given below:'
      PRINT @planHandle  
	  
      DBCC FREEPROCCACHE (@planHandle)
  
  PRINT 'Execution plan cleared for the procedure'
  END
ELSE
  BEGIN
      PRINT 'No Plan was found for the selected procedure '+ @NameOfProcedure
  END
----------------------------------------------------------------------------------------------------------

dm_exec_cached_plans




--- List plan handles of slow running query /// 
SELECT sql_handle, 
statement_start_offset, 
statement_end_offset, 
plan_handle, execution_count, 
total_logical_reads, 
total_physical_reads, 
total_elapsed_time, 
st.text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_elapsed_time DESC



 


-- Returning the batch text of cached entries that are reused


SELECT usecounts, cacheobjtype, objtype, text   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle)   
WHERE usecounts > 1   
ORDER BY usecounts DESC;  
GO


-- Returning query plans for all cached triggers

SELECT plan_handle, query_plan, objtype   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_query_plan(plan_handle)   
WHERE objtype ='Trigger';  
GO  

objtypes  ---

Proc: Stored procedure
Prepared: Prepared statement
Adhoc: Ad hoc query. Refers to Transact-SQL submitted as language events by using osql or sqlcmd instead of as remote procedure calls.
ReplProc: Replication-filter-procedure
Trigger: Trigger
View: View
Default: Default
UsrTab: User table
SysTab: System table
Check: CHECK constraint
Rule: Rule









SELECT
	objtype, 
	cacheobjtype, 
	AVG(usecounts) AS Avg_UseCount, 
	SUM(refcounts) AS AllRefObjects, 
	SUM(CAST(size_in_bytes AS bigint))/1024/1024 AS Size_MB
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Adhoc' AND usecounts = 1
GROUP BY objtype, cacheobjtype;



 


CAST(CAST(dm_exec_query_stats.execution_count AS DECIMAL) / CAST((CASE WHEN DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1 ELSE DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) END) AS DECIMAL) AS INT) AS executions_per_hour

------------------------------------------------------------------------------------ 
-- Returning the batch text of cached entries that are reused

SELECT usecounts, cacheobjtype, objtype, text   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_sql_text(plan_handle)   
WHERE usecounts > 1   
ORDER BY usecounts DESC;  
GO  


Returning query plans for all cached Procedure/triggers

------------------------------------------------------------------------------------ 
-- Returning the batch text of cached entries that are reused

SELECT plan_handle, query_plan, objtype   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_query_plan(plan_handle)   
WHERE objtype ='Proc';  
-- WHERE objtype ='Proc';  
GO  

------------------------------------------------------------------------------------ 
-- Returning the SET options with which the plan was compiled

ELECT plan_handle, pvt.set_options, pvt.sql_handle  
FROM (  
      SELECT plan_handle, epa.attribute, epa.value   
      FROM sys.dm_exec_cached_plans   
      OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) AS epa  
      WHERE cacheobjtype = 'Compiled Plan'  
      ) AS ecpa   
PIVOT (MAX(ecpa.value) FOR ecpa.attribute IN ("set_options", "sql_handle")) AS pvt;  
GO  

----------------------------------------------------------------------------------
-- Returning the memory breakdown of all cached compiled plans

SELECT plan_handle, ecp.memory_object_address AS CompiledPlan_MemoryObject,   
    omo.memory_object_address, type, page_size_in_bytes   
FROM sys.dm_exec_cached_plans AS ecp   
JOIN sys.dm_os_memory_objects AS omo   
    ON ecp.memory_object_address = omo.memory_object_address   
    OR ecp.memory_object_address = omo.parent_address  
WHERE cacheobjtype = 'Compiled Plan';  
GO




SELECT plan_handle, 
	   query_plan, 
	   objtype, 
	   dm_exec_cached_plans.*
FROM sys.dm_exec_cached_plans   
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle 
CROSS APPLY sys.dm_exec_query_plan(plan_handle)

WHERE objtype ='Proc';  
GO


SELECT 	cp.plan_handle, 
		sql_handle, 
		st.text, 
		objtype, 
		cp.*, 
		qs.*
FROM sys.dm_exec_cached_plans AS cp  
JOIN sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st


To see the plans for ad hoc queries cached in the plan cache:

SELECT qp.query_plan, 
       CP.usecounts, 
       cp.cacheobjtype, 
       cp.size_in_bytes, 
       cp.usecounts, 
       SQLText.text
FROM sys.dm_exec_cached_plans AS CP
CROSS APPLY sys.dm_exec_sql_text( plan_handle) AS SQLText
CROSS APPLY sys.dm_exec_query_plan( plan_handle) AS QP
WHERE objtype = 'Adhoc' 
and cp.cacheobjtype = 'Compiled Plan'

---------------------------- ---------------------------- 

Finding the TOP N queries



SELECT TOP 100 query_stats.query_hash AS "Query Hash",   
	SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",  
	MIN(query_stats.statement_text) AS "Statement Text"  
FROM   
	(SELECT QS.*,   
	SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,  
	((CASE statement_end_offset   
		WHEN -1 THEN DATALENGTH(ST.text)  
		ELSE QS.statement_end_offset END   
			- QS.statement_start_offset)/2) + 1) AS statement_text  
	 FROM sys.dm_exec_query_stats AS QS  
	 CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats  
GROUP BY query_stats.query_hash  
ORDER BY 2 DESC;  


Returning row count aggregates for a query


SELECT qs.execution_count,  
	SUBSTRING(qt.text,qs.statement_start_offset/2 +1,   
				 (CASE WHEN qs.statement_end_offset = -1   
					   THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2   
					   ELSE qs.statement_end_offset end -  
							qs.statement_start_offset  
				 )/2  
			 ) AS query_text,   
	 qt.dbid, dbname= DB_NAME (qt.dbid), qt.objectid,   
	 qs.total_rows, qs.last_rows, qs.min_rows, qs.max_rows  
FROM sys.dm_exec_query_stats AS qs   
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt   
WHERE qt.text like '%SELECT%'   
ORDER BY qs.execution_count DESC;






SELECT dest.TEXT AS [Query],
deqs.execution_count [Count],
deqs.last_execution_time AS [Time]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.last_execution_time DESC

select db_name(qp.dbid)as databasename,
sql_text.text as query
,st.last_execution_time
from sys.dm_exec_query_stats st
cross apply sys.dm_exec_sql_text(st.sql_handle)as sql_text
inner join sys.dm_exec_cached_plans cp
on cp.plan_handle=st.plan_handle
cross apply sys.dm_exec_query_plan(cp.plan_handle) as qp
where st.last_execution_time >=dateadd(month,-1,getdate())
order by st.last_execution_time desc;

SELECT 
sql_text.text, 
st.last_execution_time,
DB_NAME(qp.dbid) as databasename
FROM sys.dm_exec_query_stats st 
CROSS APPLY sys.dm_exec_sql_text(st.sql_handle) AS sql_text
INNER JOIN sys.dm_exec_cached_plans cp
ON cp.plan_handle = st.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) as qp
WHERE st.last_execution_time >= DATEADD(week, -1, getdate())
ORDER BY last_execution_time DESC;

SELECT
    txt.TEXT AS [SQL Statement],
    qs.EXECUTION_COUNT [No. Times Executed],
    qs.LAST_EXECUTION_TIME AS [Last Time Executed], 
    DB_NAME(txt.dbid) AS [Database]
FROM SYS.DM_EXEC_QUERY_STATS AS qs
    CROSS APPLY SYS.DM_EXEC_SQL_TEXT(qs.SQL_HANDLE) AS txt
ORDER BY qs.LAST_EXECUTION_TIME DESC




SELECT  CHAR(13) + CHAR(10)
        + CASE WHEN deqs.statement_start_offset = 0
                    AND deqs.statement_end_offset = -1
               THEN '-- see objectText column--'
               ELSE '-- query --' + CHAR(13) + CHAR(10)
                    + SUBSTRING(execText.text, deqs.statement_start_offset / 2,
                                ( ( CASE WHEN deqs.statement_end_offset = -1
                                         THEN DATALENGTH(execText.text)
                                         ELSE deqs.statement_end_offset
                                    END ) - deqs.statement_start_offset ) / 2)
          END AS queryText ,
        deqp.query_plan
FROM    sys.dm_exec_query_stats deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) deqp
WHERE   execText.text LIKE 'CREATE PROCEDURE ShowQueryText%'





SELECT  deqp.dbid ,
        deqp.objectid ,
        CAST(detqp.query_plan AS XML) AS singleStatementPlan ,
        deqp.query_plan AS batch_query_plan ,
        --this won't actually work in all cases because nominal plans aren't
        -- cached, so you won't see a plan for waitfor if you uncomment it
        ROW_NUMBER() OVER ( ORDER BY Statement_Start_offset )
                                                AS query_position ,
        CASE WHEN deqs.statement_start_offset = 0
                  AND deqs.statement_end_offset = -1
             THEN '-- see objectText column--'
             ELSE '-- query --' + CHAR(13) + CHAR(10)
                  + SUBSTRING(execText.text, deqs.statement_start_offset / 2,
                              ( ( CASE WHEN deqs.statement_end_offset = -1
                                       THEN DATALENGTH(execText.text)
                                       ELSE deqs.statement_end_offset
                                  END ) - deqs.statement_start_offset ) / 2)
        END AS queryText
FROM    sys.dm_exec_query_stats deqs
        CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle,
                                                deqs.statement_start_offset,
                                                deqs.statement_end_offset)
                                                                     AS detqp
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText
WHERE   deqp.objectid = OBJECT_ID('ShowQueryText', 'p') ;





SELECT TOP 3
        total_worker_time ,
        execution_count ,
        total_worker_time / execution_count AS [Avg CPU Time] ,
        CASE WHEN deqs.statement_start_offset = 0
                  AND deqs.statement_end_offset = -1
             THEN '-- see objectText column--'
             ELSE '-- query --' + CHAR(13) + CHAR(10)
                  + SUBSTRING(execText.text, deqs.statement_start_offset / 2,
                              ( ( CASE WHEN deqs.statement_end_offset = -1
                                       THEN DATALENGTH(execText.text)
                                       ELSE deqs.statement_end_offset
                                  END ) - deqs.statement_start_offset ) / 2)
        END AS queryText
FROM    sys.dm_exec_query_stats deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText
ORDER BY deqs.total_worker_time DESC ;





SELECT TOP 100
        SUM(total_logical_reads) AS total_logical_reads ,
        COUNT(*) AS num_queries , --number of individual queries in batch
        --not all usages need be equivalent, in the case of looping
        --or branching code
        MAX(execution_count) AS execution_count ,
        MAX(execText.text) AS queryText
FROM    sys.dm_exec_query_stats deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS execText
GROUP BY deqs.sql_handle
HAVING  AVG(total_logical_reads / execution_count) <> SUM(total_logical_reads)
        / SUM(execution_count)
ORDER BY 1 DESC 



-- Top Cached SPs By Total Logical Reads (SQL 2008 only).
-- Logical reads relate to memory pressure
SELECT TOP ( 25 )
        p.name AS [SP Name] ,
        deps.total_logical_reads AS [TotalLogicalReads] ,
        deps.total_logical_reads / deps.execution_count AS [AvgLogicalReads] ,
        deps.execution_count ,
        ISNULL(deps.execution_count / DATEDIFF(Second, deps.cached_time,
                                           GETDATE()), 0) AS [Calls/Second] ,
        deps.total_elapsed_time ,
        deps.total_elapsed_time / deps.execution_count AS [avg_elapsed_time] ,
        deps.cached_time
FROM    sys.procedures AS p
        INNER JOIN sys.dm_exec_procedure_stats
                       AS deps ON p.[object_id] = deps.[object_id]
WHERE   deps.database_id = DB_ID()
ORDER BY deps.total_logical_reads DESC ;







-- 


set transaction isolation level read uncommitted
set nocount on
declare @Top int,
		@MinServerOnlineHours int,
		@DatabaseName nvarchar(128) = 'main'
select @Top = 200

;with ByCPU as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,
						total_logical_reads/execution_count AverageReads,
						max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)
								where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_worker_time desc)
	, ByReads as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,total_logical_reads/execution_count AverageReads,max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_logical_reads desc)
	, AllQueries as
		(select * from ByCPU
		 union
		 select * from ByReads
		 )
		select top(@Top) datediff(second, a.last_execution_time, getdate()) LastExecutionSecondsAgo,
				cast(TotalReads*100./sum(TotalReads) over() as decimal(10, 2)) [%OfAllIO],
				cast(TotalCPU*100./sum(TotalCPU) over() as decimal(10, 2)) [%OfAllCPU],
				DatabaseName,
				object_name(isnull(ps.object_id, ts.object_id), 
				isnull(ps.database_id, ts.database_id)) ObjectName,
				substring(text, (statement_start_offset/2)+1,
				((case statement_end_offset
						when -1 then datalength(text)
						when 0 then datalength(text)
						else statement_end_offset
					end - statement_start_offset)/2) + 1) [Statement], 
			    --cast(p.query_plan as xml) QueryPlan,
				TotalExecutions, 
				TotalReads, 
				TotalCPU, 
				TotalDurationSec,
				a.min_logical_reads,
				AverageReads, 
				a.max_logical_reads,
				AverageCPU, 
				AverageDurationMS, 
				creation_time,
				a.last_execution_time,
				a.plan_handle
from AllQueries a
		cross apply sys.dm_exec_sql_text(sql_handle) t
		cross apply sys.dm_exec_text_query_plan(plan_handle, statement_start_offset, statement_end_offset) p
		left join sys.dm_exec_procedure_stats ps on a.plan_handle = ps.plan_handle
		left join sys.dm_exec_trigger_stats ts on a.plan_handle = ts.plan_handle
order by [%OfAllIO] desc, 
		 [%OfAllCPU] desc
GO



*/
--===============================================================================================================
--===============================================================================================================
/*
--wiki_removing_query_plan_from_PlanCache.sql
Ghanshyam Borasaniya 8:32 AM
https://wiki.intuit.com/pages/viewpage.action?pageId=506452136



 
Everything is going well, SQL server Instance is with low CPU utilization, high Page Life Expectancy, few fragmented indexes and updated statistics when suddenlysome query get a bad execution plan and the CPU usage rises to 100% and you noticed that there are multiple sessions of the same application running this same query, which until then had never presented problem, taking too long to return the result and are flooding the SQL Server.


This wiki steps presents a simple way to identify and remove bad execution plan from the SQL Server plan cache (and save you from an emergency).

First you need the content of sql_handle or plan_handle column of the query that is having trouble to remove the execution plan from the SQL Server plan cache.

Below are few queries to identify Worst Performing Queries and take decision to remove appropriate plan handle from Plan Cache.

-- 1 Below query will useful to find out worst performing queries 
	-- used top 1000 clause and execution count more then 1000 , removed - procedure%cdc%sp_batchinsert and CREATE TRIGGER%cdc%OracleGG
	-- Please verify where clause first.
 
 

set transaction isolation level read uncommitted
set nocount on
SELECT TOP 1000 
	GETDATE() AS 'Collection Date'
	, DB_NAME(qt.dbid) AS 'DB Name'
	, qs.execution_count AS 'Execution Count'
	, qs.total_worker_time AS 'Total CPU Time'
	, qs.total_worker_time / qs.execution_count AS 'Avg CPU Time (ms)'
	, qs.total_elapsed_time AS 'Total Duration'
	, query_hash
	, qs.plan_handle
	, qt.TEXT
	, SUBSTRING(qt.TEXT, qs.statement_start_offset / 2 + 1, (
			CASE 
				WHEN qs.statement_end_offset = - 1
					THEN LEN(CONVERT(NVARCHAR(max), qt.TEXT)) * 2
				ELSE qs.statement_end_offset
				END - qs.statement_start_offset
			) / 2) AS 'QueryText' 
	, qs.total_physical_reads AS 'Total Physical Reads'
	, qs.total_physical_reads / qs.execution_count AS 'Avg Physical Reads'
	, qs.total_logical_reads AS 'Total Logical Reads'
	, qs.total_logical_reads / qs.execution_count AS 'Avg Logical Reads'
	, qs.total_logical_writes AS 'Total Logical Writes'
	, qs.total_logical_writes / qs.execution_count AS 'Avg Logical Writes'
	, qs.total_elapsed_time / qs.execution_count AS 'Avg Duration (ms)' 
	, qp.query_plan AS 'Plan'
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE 1=1
     and ( 
		CONVERT(NVARCHAR(max), qt.TEXT) not like '%procedure%cdc%sp_batchinsert%'  
	    and CONVERT(NVARCHAR(max), qt.TEXT) not like '%CREATE TRIGGER%cdc%OracleGG%' 
	   ) 
	and qs.execution_count > 100
    and (DB_NAME(qt.dbid) = 'main')
	and (
		 qs.total_worker_time / qs.execution_count > 100
		OR qs.total_physical_reads / qs.execution_count > 1000
		OR qs.total_logical_reads / qs.execution_count > 1000
		OR qs.total_logical_writes / qs.execution_count > 1000
		OR qs.total_elapsed_time / qs.execution_count > 1000
	)
ORDER BY qs.total_worker_time DESC
	, qs.total_elapsed_time / qs.execution_count DESC
	, qs.total_worker_time / qs.execution_count DESC
	, qs.total_physical_reads / qs.execution_count DESC
	, qs.total_logical_reads / qs.execution_count DESC
	, qs.total_logical_writes / qs.execution_count DESC ;
	
	
-- 2 Below is another query to find out bad or worst performing SQLs/Stored Procedures having % distribution of CPU Usage or based on Reads 


use main
go 

set transaction isolation level read uncommitted
set nocount on
declare @Top int,
		@MinServerOnlineHours int,
		@DatabaseName nvarchar(128) = 'main'
select @Top = 200

;with ByCPU as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,
						total_logical_reads/execution_count AverageReads,
						max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)
								where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_worker_time desc)
	, ByReads as
		(select top(@Top) DatabaseName, [sql_handle], plan_handle, statement_start_offset, statement_end_offset,
						execution_count TotalExecutions, total_logical_reads TotalReads,
						total_worker_time TotalCPU, total_elapsed_time/1000000 TotalDurationSec,
						min_logical_reads,total_logical_reads/execution_count AverageReads,max_logical_reads,
						total_worker_time/execution_count AverageCPU,
						total_elapsed_time/1000/execution_count AverageDurationMS, last_execution_time, creation_time
			from sys.dm_exec_query_stats
				cross apply (select db_name(cast(value as int)) DatabaseName
								from sys.dm_exec_plan_attributes(plan_handle)where attribute = 'dbid') a
			where DatabaseName = @DatabaseName or @DatabaseName is null
			order by total_logical_reads desc)
	, AllQueries as
		(select * from ByCPU
		 union
		 select * from ByReads
		 )
		select top(@Top) datediff(second, a.last_execution_time, getdate()) LastExecutionSecondsAgo,
				cast(TotalReads*100./sum(TotalReads) over() as decimal(10, 2)) [%OfAllIO],
				cast(TotalCPU*100./sum(TotalCPU) over() as decimal(10, 2)) [%OfAllCPU],
				DatabaseName,
				object_name(isnull(ps.object_id, ts.object_id), 
				isnull(ps.database_id, ts.database_id)) ObjectName,
				substring(text, (statement_start_offset/2)+1,
				((case statement_end_offset
						when -1 then datalength(text)
						when 0 then datalength(text)
						else statement_end_offset
					end - statement_start_offset)/2) + 1) [Statement], 
			    --cast(p.query_plan as xml) QueryPlan,
				TotalExecutions, 
				TotalReads, 
				TotalCPU, 
				TotalDurationSec,
				a.min_logical_reads,
				AverageReads, 
				a.max_logical_reads,
				AverageCPU, 
				AverageDurationMS, 
				creation_time,
				a.last_execution_time,
				a.plan_handle
from AllQueries a
		cross apply sys.dm_exec_sql_text(sql_handle) t
		cross apply sys.dm_exec_text_query_plan(plan_handle, statement_start_offset, statement_end_offset) p
		left join sys.dm_exec_procedure_stats ps on a.plan_handle = ps.plan_handle
		left join sys.dm_exec_trigger_stats ts on a.plan_handle = ts.plan_handle
order by [%OfAllIO] desc, 
		 [%OfAllCPU] desc
go



-- 3 Below is again simplest query for finding out quick top 100 worst performing SQLs and its plan handle based on elapsed time.
	
	
SELECT TOP 100
    execution_count,
    total_elapsed_time / 1000 as totalDurationms,
    total_worker_time / 1000 as totalCPUms,
    total_logical_reads,
    total_physical_reads,
    qt.text,
    qs.sql_handle,
    qs.plan_handle
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY total_elapsed_time DESC
	



 
 
  
----------------------------------------------------------------------------------------------------------
-- Identifying Query Plans of particular SQL text.
 
 
SELECT
	databases.name,
	dm_exec_sql_text.text AS TSQL_Text,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases
ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans 
ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE dm_exec_sql_text.text LIKE '<Replace Query Text here>';



----------------------------------------------------------------------------------------------------------
-- To flush Plan handle for given stored procedure : 

DECLARE @NameOfProcedure VARCHAR(255) = 'Stored procedure name'

DECLARE @planHandle VARBINARY(64) = (SELECT top 1 plan_handle
   FROM   sys.dm_exec_cached_plans AS cp
          CROSS APPLY sys.dm_exec_sql_text(plan_handle)
   WHERE  cp.cacheobjtype = N'Compiled Plan'
          AND cp.objtype = N'Proc'
          AND cp.usecounts = 1
         AND TEXT LIKE '%' + @NameOfProcedure + '%')
IF @planHandle IS NOT NULL
 BEGIN    
      PRINT 'Procedure with name like ' + @NameOfProcedure + ' plan handle found with value as given below:'
      PRINT @planHandle  
	  
      DBCC FREEPROCCACHE (@planHandle)
  
  PRINT 'Execution plan cleared for the procedure'
  END
ELSE
  BEGIN
      PRINT 'No Plan was found for the selected procedure '+ @NameOfProcedure
  END
 
 
-- Removing Plan Handle from the Plan Cache
-- Remove the specific query plan from the cache using the plan handle from the above query 
--DBCC FREEPROCCACHE (<copy the plan_handle here>)

DBCC FREEPROCCACHE (0x050011007A2CC30E204991F30200000001000000000000000000000000000000000000000000000000000000);



 

USE AdventureWorks2014;
GO

-- Run a stored procedure or query
EXEC dbo.uspGetEmployeeManagers 9;

-- Find the plan handle for that query 

-- OPTION (RECOMPILE) keeps this query from going into the plan cache

SELECT cp.plan_handle, 
	 cp.objtype, 
	 cp.usecounts, 
	 DB_NAME(st.dbid) AS [DatabaseName] 
[text][/text]
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid) [text][/text] LIKE N'%uspGetEmployeeManagers%' OPTION (RECOMPILE);
 



use this code to help you:
 
-- List Plan Counts from DM_Exec_Cached_Plans

 
SELECT   plan_handle, 
		 objtype,  
		MAX(CASE  WHEN usecounts BETWEEN 10 AND 100 THEN '10 - 100' 
				   WHEN usecounts BETWEEN 101 AND 1000 THEN '101 - 1000'
				   WHEN usecounts BETWEEN 1001 AND 5000 THEN '1001 - 5000' 
				   WHEN usecounts BETWEEN 5001 AND 10000 THEN '5001 - 10000' 
				   ELSE CAST(usecounts AS VARCHAR(100)) END) AS 'Use Counts' , 
		COUNT(usecounts) AS 'Count Instance' 
FROM sys.dm_exec_cached_plans
GROUP BY objtype, 
		plan_handle,
		CASE WHEN usecounts BETWEEN 10 AND 100 THEN 50 
		WHEN usecounts BETWEEN 101 AND 1000 THEN 500 
		WHEN usecounts BETWEEN 1001 AND 5000 THEN 2500 
		WHEN usecounts BETWEEN 5001 AND 10000 THEN 7500 ELSE usecounts END 
ORDER BY CASE  WHEN usecounts BETWEEN 10 AND 100 THEN 50 
		WHEN usecounts BETWEEN 101 AND 1000 THEN 500 
		WHEN usecounts BETWEEN 1001 AND 5000 THEN 2500 
		WHEN usecounts BETWEEN 5001 AND 10000 THEN 7500 
		ELSE usecounts END 
	DESC;










 
SELECT  cp.plan_handle, 
	    cp.objtype, 
	    cp.usecounts, 
		
		
	 DB_NAME(st.dbid) AS [DatabaseName] 
[text][/text]
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid) [text][/text] LIKE N'%uspGetEmployeeManagers%' OPTION (RECOMPILE);





and this also:

 
– List Single & Double Query Plans-- List Single & Double Query Plans


SELECT deqp.dbid AS 'DB ID' ,
	deqp.objectid AS 'Object ID' , 
	CAST(detqp.query_plan AS XML) AS 'Single Statement Plan' , 
	deqp.query_plan AS 'Batch Query Plan' , 
	ROW_NUMBER() OVER ( ORDER BY Statement_Start_offset ) AS query_position , 
	CASE  WHEN deqs.statement_start_offset = 0 AND deqs.statement_end_offset = - 1
	THEN '-- see objectText column-' ELSE '- query --' + CHAR(13) + CHAR(10) + 
	SUBSTRING(execText.TEXT, deqs.statement_start_offset / 2, ( ( CASE  WHEN deqs.statement_end_offset = - 1 THEN DATALENGTH(execText.TEXT) ELSE deqs.statement_end_offset END ) - deqs.statement_start_offset ) / 2) END 
	AS queryText 
	FROM sys.dm_exec_query_stats deqs 
	CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle, deqs.statement_start_offset, deqs.statement_end_offset) AS detqp 
	CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp 
	CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText
	WHERE deqp.objectid = OBJECT_ID('PC_getAdminCoInfoByUser_New', 'p');
 
 
 
 
 
 SELECT 'DBCC FREEPROCCACHE (0x' + convert(varchar(max),plan_handle, 2) + ')' FROM sys.dm_exec_cached_plans CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE text LIKE N'%SELECT TOP 100 wd.Hours, wd.WageAmount, wd.ItemID, wd.EmployeeWageItemID%';


select plan_handle, creation_time, last_execution_time, execution_count, qt.text FROM sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text (qs.[sql_handle]) AS qt

DBCC FREEPROCCACHE (plan_handle_id_goes_here)

replace the string between %% with the query interested

copy the output and run the DBCC FREEPROCCACHE


DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS






Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create procedure [dbo].[usp_CollectQueryPlans]
as
;with PlanCache as
	(select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			total_worker_time, total_logical_reads, total_logical_writes, total_elapsed_time, total_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			row_number() over (partition by query_hash, query_plan_hash order by creation_time) rn
		from sys.dm_exec_query_stats q
		where query_hash <> 0x0000000000000000
	)
insert into QueryPlanHistory(CollectionDate, query_hash, query_plan_hash, [sql_handle], plan_handle, statement_start_offset, statement_end_offset, plan_generation_num,
							avg_worker_time, avg_logical_reads, avg_logical_writes, avg_duration, avg_rows, execution_count, creation_time, last_execution_time, query_plan)
select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			cast(total_worker_time*1./execution_count as decimal(20, 3)) avg_worker_time,
			cast(total_logical_reads*1./execution_count as decimal(20, 3)) avg_logical_reads,
			cast(total_logical_writes*1./execution_count as decimal(20, 3)) avg_logical_writes,
			cast(total_elapsed_time*1./execution_count as decimal(20, 3)) avg_duration,
			cast(total_rows*1./execution_count as decimal(20, 3)) avg_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			p.query_plan
from PlanCache q
	cross apply sys.dm_exec_text_query_plan(q.plan_handle, q.statement_start_offset, q.statement_end_offset) p
where rn = 1







;with PlanCache as
	(select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			total_worker_time, total_logical_reads, total_logical_writes, total_elapsed_time, total_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			row_number() over (partition by query_hash, query_plan_hash order by creation_time) rn
		from sys.dm_exec_query_stats q
		where query_hash <> 0x0000000000000000
	)
select sysdatetime() collection_date,
			query_hash, query_plan_hash,
			sql_handle, plan_handle,
			statement_start_offset, statement_end_offset, plan_generation_num,
			cast(total_worker_time*1./execution_count as decimal(20, 3)) avg_worker_time,
			cast(total_logical_reads*1./execution_count as decimal(20, 3)) avg_logical_reads,
			cast(total_logical_writes*1./execution_count as decimal(20, 3)) avg_logical_writes,
			cast(total_elapsed_time*1./execution_count as decimal(20, 3)) avg_duration,
			cast(total_rows*1./execution_count as decimal(20, 3)) avg_rows,
			execution_count,
			q.creation_time,
			q.last_execution_time,
			p.query_plan
from PlanCache q
	cross apply sys.dm_exec_text_query_plan(q.plan_handle, q.statement_start_offset, q.statement_end_offset) p
where rn = 1







*/
--===============================================================================================================
--===============================================================================================================
/*
_CodeGenerator


CREATE PROCEDURE [dbo].[_CodeGenerator]
	@TableName NVARCHAR(MAX),
	@TableShortName NVARCHAR(MAX) = NULL,
	@PKFieldName NVARCHAR(MAX),
	@AlreadyExistFields NVARCHAR(MAX) = NULL,
	@IsTransactionApply bit = false,
	@ClsTableName NVARCHAR(MAX) = NULL,
	@AddLOVs NVARCHAR(MAX) = NULL, --Singular table name
	@ListLOVs NVARCHAR(MAX) = NULL, --Singular table name
	@MainColumns NVARCHAR(MAX) = NULL,
	@ParameterColumns NVARCHAR(MAX) = NULL,
	@Namespace NVARCHAR(MAX) = NULL,
	@DevelopmentBy	VARCHAR(50) = 'Auto generated',
	@DevelopmentDateTime DATETIME2 = NULL
AS
/***********************************************************************************************
	 NAME     :  _CodeGenerator
	 PURPOSE  :  This SP useful for generate Classes like BLL, Entity, WebAPI, Page HTML, Angular code like controller, service, model 
				 store procedure like Insert, Update, Delete and Select.
	 REVISIONS:
		Ver			Date			Author					Description
	 ---------   ----------		---------------		 -----------------------------
		1.0      7/3/2016		Rekansh Patel			1. Initial Version.
				 10/27/2017		DHANASHRI K.			1. Change datatype DateTime,Date to DateTime2,SYSUTCDATETIME()

 EXAMPLE:
	EXEC [dbo].[_CodeGenerator]
	@TableName = 'Users', --Actual database table name
	@TableShortName = 'U', --Table short name, if table name is UserRole then short name is UR
	@PKFieldName = 'Id', --Table primary key field name
	@AlreadyExistFields = 'UserName ShortName LongName', --Already exists check field list by space seperated while insert or update
	@IsTransactionApply = 0,
	@ClsTableName = 'User', --Class name except word cls and BLL, EAL, Controller means if you enter User then BLL > clsUserBLL, EAL > clsUserEAL, model > UserModel etc...
	@AddLOVs = 'Organization UserRole Facility', --Singular table name list by space sperated for page add/edit mode
	@ListLOVs = 'Organization', --Singular table name list by space sperated for page list mode
	@MainColumns = 'Id UserName ShortName LongName', --Main fields list by space seperated for LOV
	@ParameterColumns = 'OrgId Id', --Field list by space seperated for create where part and parameter class
	@Namespace = 'Admin.Account', --Class namespace for generete namespace and routes
	@DevelopmentBy	= 'Rekansh Patel' --Developer name

*******************************************************************************************************/
BEGIN
	IF(@ClsTableName IS NULL)
		SET @ClsTableName = REPLACE(@TableName, 'tbl', '')
	
	IF(@TableShortName IS NULL)
		SET @TableShortName = SUBSTRING(@TableName, 1, 1)
	
	DECLARE @MainColumnsTable table(
		FieldName NVARCHAR(MAX)
	)
	INSERT INTO @MainColumnsTable(FieldName)
	SELECT t.value
	FROM dbo.fnSplit(@MainColumns, ' ') t
	
	DECLARE @ParameterColumnsTable table(
		FieldName NVARCHAR(MAX)
	)
	INSERT INTO @ParameterColumnsTable(FieldName)
	SELECT t.value
	FROM dbo.fnSplit(@ParameterColumns, ' ') t
	
	DECLARE @Route NVARCHAR(MAX)
	DECLARE @AddLOVsCount int
	DECLARE @ListLOVsCount int
	SELECT @AddLOVsCount = count(1) FROM dbo.fnSplit(@AddLOVs, ' ') t
	SELECT @ListLOVsCount = count(1) FROM dbo.fnSplit(@ListLOVs, ' ') t

	DECLARE @BLL_String NVARCHAR(MAX)
	DECLARE @EAL_String NVARCHAR(MAX)
	DECLARE @PKFieldDataType NVARCHAR(MAX)
	DECLARE @PKNetFieldDataType NVARCHAR(MAX)
	DECLARE @PKNetConvert NVARCHAR(MAX)

	DECLARE @PublicProperty NVARCHAR(MAX)
	DECLARE @SetDefaulValue NVARCHAR(MAX)
	DECLARE @PublicMainProperty NVARCHAR(MAX)
	DECLARE @SetMainDefaulValue NVARCHAR(MAX)
	DECLARE @SpSelectMainFields NVARCHAR(MAX)
	DECLARE @PublicParameterProperty NVARCHAR(MAX)
	DECLARE @SetParameterDefaulValue NVARCHAR(MAX)
	
	DECLARE @ColumnName NVARCHAR(MAX)
	DECLARE @DataType NVARCHAR(MAX)
	DECLARE @IsNullable bit
	DECLARE @DataSize NVARCHAR(MAX)
	DECLARE @NetDataType NVARCHAR(MAX)
	DECLARE @NetConvert NVARCHAR(MAX)
	DECLARE @NetDefaultValue NVARCHAR(MAX)

	DECLARE @InsertAddParameter NVARCHAR(MAX)
	DECLARE @UpdateAddParameter NVARCHAR(MAX)
	DECLARE @SelectAddParameter NVARCHAR(MAX)
	DECLARE @SpSelectForParameter NVARCHAR(MAX)
	DECLARE @SpSelectForParameterPass NVARCHAR(MAX)
	DECLARE @SpSelectForParameterWhere NVARCHAR(MAX)
	DECLARE @BLLParameter NVARCHAR(MAX)

	DECLARE @SpInsertString NVARCHAR(MAX)
	DECLARE @AlreadyExistInsertSting NVARCHAR(MAX)
	DECLARE @SpInsertParameter NVARCHAR(MAX)
	DECLARE @SpInsertField NVARCHAR(MAX)
	DECLARE @SpInsertValue NVARCHAR(MAX)

	DECLARE @SpUpdateString NVARCHAR(MAX)
	DECLARE @AlreadyExistUpdateSting NVARCHAR(MAX)
	DECLARE @SpUpdateParameter NVARCHAR(MAX)
	DECLARE @SpUpdateSet NVARCHAR(MAX)

	DECLARE @SpDeleteString NVARCHAR(MAX)

	DECLARE @SpSelectString NVARCHAR(MAX)
	DECLARE @SpSelectForAddString NVARCHAR(MAX)
	DECLARE @SpSelectForEditString NVARCHAR(MAX)
	DECLARE @SpSelectForGridString NVARCHAR(MAX)
	DECLARE @SpSelectForExportString NVARCHAR(MAX)
	DECLARE @SpSelectForListString NVARCHAR(MAX)
	DECLARE @SpSelectForLOVString NVARCHAR(MAX)
	DECLARE @SpSelectForRecordString NVARCHAR(MAX)

	DECLARE @SpSelectParameter NVARCHAR(MAX)
	DECLARE @SpSelectParameterPass NVARCHAR(MAX)
	DECLARE @SpSelectField NVARCHAR(MAX)
	DECLARE @SpSelectWhere NVARCHAR(MAX)
	
	DECLARE @MapDataColumns NVARCHAR(MAX)
	
	DECLARE @AngularModelString NVARCHAR(MAX)
	DECLARE @ModelDefination NVARCHAR(MAX)
	DECLARE @ModelMainDefination NVARCHAR(MAX)
	DECLARE @ModelParameter NVARCHAR(MAX)
	DECLARE @SetDefaulValueJava NVARCHAR(MAX)
	
	DECLARE @WebAPIControllerString NVARCHAR(MAX)

	DECLARE @AngularServiceString NVARCHAR(MAX)
	DECLARE @AngularRouteString NVARCHAR(MAX)
	DECLARE @AngularAddEditControllerString NVARCHAR(MAX)
	DECLARE @AngularListControllerString NVARCHAR(MAX)
	
	DECLARE @HtmlControlType NVARCHAR(MAX)
	DECLARE @HtmlInputModeFields NVARCHAR(MAX)
	DECLARE @HtmlSearchModeFields NVARCHAR(MAX)
	DECLARE @HtmlGridFieldsHeader NVARCHAR(MAX)
	DECLARE @HtmlGridFieldsDetail NVARCHAR(MAX)
	DECLARE @AddEditHtmlString NVARCHAR(MAX)
	DECLARE @ListHtmlString NVARCHAR(MAX)

	SELECT @Route = REPLACE(@Namespace, '.','/')
	SET @PublicProperty = ''
	SET @SetDefaulValue = ''
	SET @PublicMainProperty = ''
	SET @SetMainDefaulValue = ''
	SET @SpSelectMainFields = ''
	SET @PublicParameterProperty = ''
	SET @SetParameterDefaulValue = ''

	SET @InsertAddParameter = ''
	SET @UpdateAddParameter = ''
	SET @SelectAddParameter = ''
	SET @BLLParameter = ''
	SET @SpSelectForParameter = ''
	SET @SpSelectForParameterPass = ''
	SET @SpSelectForParameterWhere = ''

	SET @AlreadyExistInsertSting = ''
	SET @SpInsertParameter = ''
	SET @SpInsertField = ''
	SET @SpInsertValue = ''

	SET @AlreadyExistUpdateSting = ''
	SET @SpUpdateParameter = ''
	SET @SpUpdateSet = ''

	SET @SpSelectParameter = ''
	SET @SpSelectParameterPass = ''
	SET @SpSelectField = ''
	SET @SpSelectWhere = ''

	SET @MapDataColumns = ''

	SET @AngularModelString = ''
	SET @ModelDefination = ''
	SET @ModelMainDefination = ''
	SET @ModelParameter = ''
	SET @SetDefaulValueJava = ''
	
	SET @WebAPIControllerString = ''

	SET @AngularServiceString = ''
	SET @AngularRouteString = ''
	SET @AngularAddEditControllerString = ''
	SET @AngularListControllerString = ''
	
	SET @HtmlControlType = ''
	SET @HtmlInputModeFields = ''
	SET @HtmlSearchModeFields = ''
	SET @HtmlGridFieldsHeader = ''
	SET @HtmlGridFieldsDetail = ''
	SET @AddEditHtmlString = ''
	SET @ListHtmlString = ''

	IF(@AlreadyExistFields IS NOT NULL)
	BEGIN
		SELECT @AlreadyExistInsertSting = CASE @AlreadyExistInsertSting WHEN '' THEN 'SELECT [' + @PKFieldName + '] FROM [' + @TableName + '] WHERE [' + t.value + '] = @' + t.value 
			ELSE @AlreadyExistInsertSting + ' AND [' + t.value + '] = @' + t.value END
		FROM dbo.fnSplit(@AlreadyExistFields, ' ') t

		SET @AlreadyExistUpdateSting = @AlreadyExistInsertSting + ' AND [' + @PKFieldName + '] != @' + @PKFieldName 
	END

	DECLARE @CurColumn CURSOR
	SET @CurColumn = CURSOR FOR 
		SELECT c.name ColumnName, t.name DataType, c.IsNullable,
			CASE t.name WHEN 'nvarchar' THEN '(' + CONVERT(VARCHAR, c.length/2) + ')'
				WHEN 'char' THEN '(' + CONVERT(VARCHAR, c.length) + ')'
				WHEN 'varchar' THEN '(' + CONVERT(VARCHAR, c.length) + ')'
				WHEN 'numeric' THEN '(' + CONVERT(VARCHAR, c.xprec) + ',' + CONVERT(VARCHAR, c.xscale) + ')'
				WHEN 'decimal' THEN '(' + CONVERT(VARCHAR, c.xprec) + ',' + CONVERT(VARCHAR, c.xscale) + ')'
				ELSE '' END DataSize
		FROM sysobjects o
			INNER JOIN syscolumns c ON o.id = c.id
			INNER JOIN systypes t ON c.xtype = t.xtype
		WHERE o.name = @TableName AND t.name != 'sysname'
		ORDER BY colid

	OPEN @CurColumn; 

	FETCH NEXT FROM @CurColumn INTO @ColumnName, @DataType, @IsNullable, @DataSize
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @NetDataType = CASE @DataType
			WHEN 'tinyint' THEN 'int'
			WHEN 'smallint' THEN 'int'
			WHEN 'int' THEN 'int'
			WHEN 'bigint' THEN 'long'
			WHEN 'bit' THEN 'bool'
			WHEN 'nvarchar' THEN 'string'
			WHEN 'datetime2' THEN 'DateTime2'
			WHEN 'float' THEN 'double'
			WHEN 'numeric' THEN 'decimal'
			WHEN 'decimal' THEN 'decimal'
			WHEN 'char' THEN 'string'
			WHEN 'xml' THEN 'string'
			else 'string' end

		SELECT @NetConvert = CASE @DataType
			WHEN 'tinyint' THEN 'ToInt'
			WHEN 'smallint' THEN 'ToInt'
			WHEN 'int' THEN 'ToInt'
			WHEN 'bigint' THEN 'ToLong'
			WHEN 'bit' THEN 'ToBoolean'
			WHEN 'nvarchar' THEN 'ToString'
			WHEN 'datetime2' THEN 'ToDateTime'
			WHEN 'float' THEN 'ToDouble'
			WHEN 'numeric' THEN 'ToDecimal'
			WHEN 'decimal' THEN 'ToDecimal'
			WHEN 'char' THEN 'ToString'
			WHEN 'xml' THEN 'ToString'
			else 'ToString' end

		SELECT @NetDefaultValue = CASE @DataType
			WHEN 'tinyint' THEN '0'
			WHEN 'smallint' THEN '0'
			WHEN 'int' THEN '0'
			WHEN 'bigint' THEN '0'
			WHEN 'bit' THEN 'false'
			WHEN 'nvarchar' THEN 'string.Empty'
			WHEN 'datetime' THEN 'DateTime.MinValue'
			WHEN 'float' THEN '0'
			WHEN 'numeric' THEN '0'
			WHEN 'decimal' THEN '0'
			WHEN 'char' THEN 'string.Empty'
			WHEN 'xml' THEN 'string.Empty'
			else 'string.Empty' end

		SELECT @SetDefaulValueJava = CASE @DataType
			WHEN 'tinyint' THEN '0'
			WHEN 'smallint' THEN '0'
			WHEN 'int' THEN '0'
			WHEN 'bigint' THEN '0'
			WHEN 'bit' THEN 'false'
			WHEN 'nvarchar' THEN ''''''
			WHEN 'datetime' THEN 'new Date(0)'
			WHEN 'float' THEN '0'
			WHEN 'numeric' THEN '0'
			WHEN 'decimal' THEN '0'
			WHEN 'char' THEN ''''''
			WHEN 'xml' THEN ''''''
			else '''''' end
			
		SELECT @HtmlControlType = CASE @DataType
			WHEN 'tinyint' THEN 'number'
			WHEN 'smallint' THEN 'number'
			WHEN 'int' THEN 'number'
			WHEN 'bigint' THEN 'number'
			WHEN 'bit' THEN 'checkbox'
			WHEN 'nvarchar' THEN 'text'
			WHEN 'date' THEN 'date'
			WHEN 'datetime2' THEN 'datetime2'
			WHEN 'float' THEN 'number'
			WHEN 'numeric' THEN 'number'
			WHEN 'decimal' THEN 'number'
			WHEN 'char' THEN 'text'
			WHEN 'xml' THEN 'text'
			else 'text' end

		IF(@PKFieldName = @ColumnName)
		BEGIN
			SET @PKFieldDataType = @DataType
			SET @PKNetFieldDataType = @NetDataType
			SET @PKNetConvert = @NetConvert
		END

		IF EXISTS(SELECT * FROM @MainColumnsTable WHERE FieldName = @ColumnName)
		BEGIN
			SET @PublicMainProperty = @PublicMainProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetMainDefaulValue = @SetMainDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 
			SET @SpSelectMainFields = CASE @SpSelectMainFields WHEN '' THEN  @TableShortName + '.[' + @ColumnName + ']' else @SpSelectMainFields + ', ' + @TableShortName + '.[' + @ColumnName + ']' END
			SET @ModelMainDefination = CASE @ModelMainDefination WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelMainDefination + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)
		END
		ELSE
		BEGIN
			SET @PublicProperty = @PublicProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetDefaulValue = @SetDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 
		END

		IF EXISTS(SELECT * FROM @ParameterColumnsTable WHERE FieldName = @ColumnName)
		BEGIN
			SET @PublicParameterProperty = @PublicParameterProperty + '/// <summary>' + CHAR(13) + '/// Get & Set ' + dbo.fnUserFriendlyName(@ColumnName)  + CHAR(13) + '/// </summary>' + CHAR(13) + 'public ' + @NetDataType + ' ' + @ColumnName + ' { get; set; } ' + CHAR(13)  + CHAR(13) 
			SET @SetParameterDefaulValue = @SetParameterDefaulValue + @ColumnName + ' = ' + @NetDefaultValue + '; ' + CHAR(13) 

			SET @BLLParameter = @BLLParameter + 'if(obj' + @ClsTableName + 'ParameterEAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'ParameterEAL.' + @ColumnName + ');' + CHAR(13)
			
			SET @SpSelectForParameter = CASE @SpSelectForParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END ELSE @SpSelectForParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END END
			SET @SpSelectForParameterPass = CASE @SpSelectForParameterPass WHEN ' ' THEN '@' + @ColumnName ELSE @SpSelectForParameterPass + ', @' + @ColumnName END
			SET @SpSelectForParameterWhere = CASE @SpSelectForParameterWhere WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' + ' = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' ELSE @SpSelectForParameterWhere + CHAR(13) + ' AND ' + @TableShortName + '.[' + @ColumnName + '] = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' END

			SET @ModelParameter = CASE @ModelParameter WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelParameter + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)
		END

		if(@PKFieldName != @ColumnName)
		begin
			SET @InsertAddParameter = @InsertAddParameter + CASE @IsNullable WHEN 1 THEN 'if(obj' + @ClsTableName + 'EAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) ELSE '' END + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'EAL.' + @ColumnName + ');' + CHAR(13)
			SET @SpInsertParameter = CASE @SpInsertParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + case @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END ELSE @SpInsertParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + CASE @IsNullable WHEN 1 THEN ' = NULL' ELSE '' END END
			SET @SpInsertField = CASE @SpInsertField WHEN '' THEN '[' + @ColumnName + ']' ELSE @SpInsertField + ', [' + @ColumnName + ']' END + CHAR(13) 
			SET @SpInsertValue = CASE @SpInsertValue WHEN '' THEN '@' + @ColumnName ELSE @SpInsertValue + ', ' + '@' + @ColumnName END + CHAR(13) 
			SET @SpUpdateSet = CASE @SpUpdateSet WHEN '' THEN '[' + @ColumnName + '] = @' + @ColumnName else @SpUpdateSet + ', ' + CHAR(13) + '[' + @ColumnName + '] = @' + @ColumnName END
		end

		SET @SelectAddParameter = @SelectAddParameter + 'if(obj' + @ClsTableName + 'EAL.' + @ColumnName + ' != ' + @NetDefaultValue + ')' + CHAR(13) + 'objCommonDAL.AddParameter("' + @ColumnName + '", obj' + @ClsTableName + 'EAL.' + @ColumnName + ');' + CHAR(13)
		SET @SpSelectParameter = CASE @SpSelectParameter WHEN '' THEN '@' + @ColumnName + ' ' + @DataType + @DataSize + ' = NULL' ELSE @SpSelectParameter + ', ' + CHAR(13) + '@' + @ColumnName + ' ' + @DataType + @DataSize + ' = NULL' END
		SET @SpSelectParameterPass = CASE @SpSelectParameterPass WHEN '' THEN '@' + @ColumnName ELSE @SpSelectParameterPass + ', @' + @ColumnName END
		SET @SpSelectField = CASE @SpSelectField WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' ELSE @SpSelectField + ', ' + @TableShortName + '.[' + @ColumnName + ']' END
		SET @SpSelectWhere = CASE @SpSelectWhere WHEN '' THEN @TableShortName + '.[' + @ColumnName + ']' + ' = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' else @SpSelectWhere + CHAR(13) + ' AND ' + @TableShortName + '.[' + @ColumnName + '] = COALESCE(@' + @ColumnName + ', ' + @TableShortName + '.[' + @ColumnName + '])' END

		SET @MapDataColumns = @MapDataColumns + 'case "' + @ColumnName + '":' + CHAR(13) + 'obj'+ @ClsTableName + 'EAL.' + @ColumnName + ' = MyConvert.' + @NetConvert + '(reader["' + @ColumnName + '"]);' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @ModelDefination = CASE @ModelDefination WHEN '' THEN 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' ELSE @ModelDefination + 'this.' + @ColumnName + ' = ' + @SetDefaulValueJava + ';' END + CHAR(13)

		SET @HtmlSearchModeFields = @HtmlSearchModeFields + N'
							<div class="form-group">
								<label for="inputSearch' + @ColumnName + '" class="col-sm-2 control-label">' + dbo.fnUserFriendlyName(@ColumnName) + '</label>
								<div class="col-sm-10">
									<input type="number" class="form-control" name="inputSearch' + @ColumnName + '" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.' + @ColumnName + '" placeholder="' + dbo.fnUserFriendlyName(@ColumnName) + '" />
								</div>
							</div>
		'
		SET @HtmlInputModeFields = @HtmlInputModeFields + N'
							<div class="form-group {{(' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$submitted && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) || (' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$touched && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) ? ''has-error'' : ''''}}">
								<label for="input' + @ColumnName + '" class="col-sm-2 control-label">' + dbo.fnUserFriendlyName(@ColumnName) + '</label>
								<div class="col-sm-10">
									<input type="' + @HtmlControlType + '" class="form-control" name="input' + @ColumnName + '" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + '.' + @ColumnName + '" placeholder="' + dbo.fnUserFriendlyName(@ColumnName) + '" ng-required="true" />
									<div class="tooltip bottom fade in" ng-if="(' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$submitted && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid) || (' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$touched && ' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$invalid)">
										<div class="tooltip-arrow"></div>
										<div class="tooltip-inner ng-binding" ng-if="' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.input' + @ColumnName + '.$error.required">' + dbo.fnUserFriendlyName(@ColumnName) + ' is required.</div>
									</div>
								</div>
							</div>			
		'
		
		SET @HtmlGridFieldsHeader = @HtmlGridFieldsHeader + '<th ng-sort class="link" scope-sort-expression="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression" scope-sort-direction="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection" display-name="' + dbo.fnUserFriendlyName(@ColumnName) + '" sort-expression="' + @ColumnName + '" ng-click="sortRecord(''' + @ColumnName + ''');"></th>' + CHAR(13)
		SET @HtmlGridFieldsDetail = @HtmlGridFieldsDetail + '<td>{{'+ dbo.fnJavaScriptName(@ClsTableName) + 'List.' + @ColumnName + '}}</td>' + CHAR(13)

		FETCH NEXT FROM @CurColumn INTO @ColumnName, @DataType, @IsNullable, @DataSize
	END;
	CLOSE @CurColumn;
	DEALLOCATE @CurColumn;
	
	DECLARE @Lov NVARCHAR(MAX)
	DECLARE @AddLovsEAL NVARCHAR(MAX)
	DECLARE @AddLovsModel NVARCHAR(MAX)
	DECLARE @AddEditLovDepRoute NVARCHAR(MAX)
	DECLARE @AddLovSetAngular NVARCHAR(MAX)
	DECLARE @EditLovSetAngular NVARCHAR(MAX)
	DECLARE @AddEditLovDeclareAngular NVARCHAR(MAX)

	DECLARE @ListLovsEAL NVARCHAR(MAX)
	DECLARE @ListLovsModel NVARCHAR(MAX)
	DECLARE @ListLovDepRoute NVARCHAR(MAX)
	DECLARE @ListLovSetAngular NVARCHAR(MAX)
	DECLARE @ListLovDeclareAngular NVARCHAR(MAX)

	DECLARE @MapAddEAL NVARCHAR(MAX)
	DECLARE @MapEditEAL NVARCHAR(MAX)
	DECLARE @MapListEAL NVARCHAR(MAX)
	declare @AddEditResultSet int
	declare @ListResultSet int

	DECLARE @AddLovsSPCall NVARCHAR(MAX)
	DECLARE @ListLovsSPCall NVARCHAR(MAX)

	SET @AddLovsEAL = ''
	SET @AddLovsModel = ''
	SET @AddEditLovDepRoute = ''
	SET @AddLovSetAngular = ''
	SET @EditLovSetAngular = ''
	SET @AddEditLovDeclareAngular = ''
	SET @ListLovsEAL = ''
	SET @ListLovsModel = ''
	SET @ListLovDepRoute = ''
	SET @ListLovSetAngular = ''
	SET @ListLovDeclareAngular = ''

	SET @MapAddEAL = ''
	SET @MapEditEAL = ''
	SET @MapListEAL = ''
	SET @AddEditResultSet = 0
	SET @ListResultSet = 0

	SET @AddLovsSPCall = ''
	SET @ListLovsSPCall = ''

	DECLARE @CurAddLovs CURSOR
	SET @CurAddLovs = CURSOR FOR 
		SELECT t.value
		FROM dbo.fnSplit(@AddLOVs, ' ') t

	OPEN @CurAddLovs; 

	FETCH NEXT FROM @CurAddLovs INTO @Lov
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @AddLovsEAL = @AddLovsEAL + 'public List<cls' + @Lov + 'MainEAL> ' + @Lov + 's = new List<cls' + @Lov + 'MainEAL>();' + CHAR(13)
		
		SET @MapAddEAL = @MapAddEAL + 'case ' + CONVERT(VARCHAR, @AddEditResultSet) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'AddEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)

		SET @MapEditEAL = @MapEditEAL + 'case ' + CONVERT(VARCHAR, @AddEditResultSet + 1) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'EditEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @AddLovsSPCall = @AddLovsSPCall + 'EXEC ' + @Lov + '_SelectForLOV ' + @SpSelectForParameterPass + CHAR(13)

		SET @AddLovsModel = @AddLovsModel + 'this.' + @Lov + 's = [];' + CHAR(13)

		SET @AddEditLovDepRoute = @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @Lov + '/' + @Lov + '.Service.js?v='' + version,' + CHAR(13)

		SET @AddLovSetAngular = @AddLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel.' + @Lov + 's;' + CHAR(13)
		SET @EditLovSetAngular = @EditLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel.' + @Lov + 's;' + CHAR(13)
		SET @AddEditLovDeclareAngular = @AddEditLovDeclareAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData = {' + CHAR(13) + 'data: []' + CHAR(13) + '};' + CHAR(13)

		SET @AddEditResultSet = @AddEditResultSet + 1
		FETCH NEXT FROM @CurAddLovs INTO @Lov
	END;
	CLOSE @CurAddLovs;
	DEALLOCATE @CurAddLovs;
	
	DECLARE @CurListLovs CURSOR
	SET @CurListLovs = CURSOR FOR 
		SELECT t.value
		FROM dbo.fnSplit(@ListLOVs, ' ') t

	OPEN @CurListLovs; 

	FETCH NEXT FROM @CurListLovs INTO @Lov
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ListLovsEAL = @ListLovsEAL + 'public List<cls' + @Lov + 'MainEAL> ' + @Lov + 's = new List<cls' + @Lov + 'MainEAL>();' + CHAR(13)
		
		SET @MapListEAL = @MapListEAL + 'case ' + CONVERT(VARCHAR, @ListResultSet) + ':' + CHAR(13) + 'obj' + @ClsTableName + 'ListEAL.' + @Lov + 's.Add(objCommonDAL.MapDataDynamically<cls' + @Lov + 'MainEAL>(reader));' + CHAR(13) + 'break;' + CHAR(13)
		
		SET @ListLovsSPCall = @ListLovsSPCall + 'EXEC ' + @Lov + '_SelectForLOV ' + @SpSelectForParameterPass + CHAR(13)

		SET @ListLovsModel = @ListLovsModel + 'this.' + @Lov + 's = [];' + CHAR(13)

		SET @ListLovDepRoute = @ListLovDepRoute + '''Areas/' + @Route + '/' + @Lov + '/' + @Lov + '.Service.js?v='' + version,' + CHAR(13)

		SET @ListLovSetAngular = @ListLovSetAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData.data = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.' + @Lov + 's;' + CHAR(13)
		SET @ListLovDeclareAngular = @ListLovDeclareAngular + '$scope.' + dbo.fnJavaScriptName(@Lov) + 'ConfigData = {' + CHAR(13) + 'data: []' + CHAR(13) + '};' + CHAR(13)

		SET @ListResultSet = @ListResultSet + 1
		FETCH NEXT FROM @CurListLovs INTO @Lov
	END;
	CLOSE @CurListLovs;
	DEALLOCATE @CurListLovs;

	SET @UpdateAddParameter = 'objCommonDAL.AddParameter("' + @PKFieldName + '", obj' + @ClsTableName + 'EAL.' + @PKFieldName + ');' + CHAR(13) + @InsertAddParameter 
	SET @SpUpdateParameter = '@' + @PKFieldName + ' ' + @PKFieldDataType + ',' + CHAR(13) + @SpInsertParameter 

	IF(@DevelopmentDateTime IS NULL)
		SET @DevelopmentDateTime = SYSUTCDATETIME();

	SET @EAL_String = N'
	/// <summary>
	/// This class having main entities of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'MainEAL
{
	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'MainEAL()
	{
		SetDefaulValue();
	}
	#endregion

	#region Public Properties
	' + @PublicMainProperty + '
	#endregion

	#region Private Methods
	/// <summary>
	/// This function is set properties default value based on its data type in table.
	/// </summary>
	private void SetDefaulValue()
	{
		' + @SetMainDefaulValue + '
	}
	#endregion
}

	/// <summary>
	/// This class having entities of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'EAL : cls'+ @ClsTableName + 'MainEAL
{
	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'EAL()
	{
		SetDefaulValue();
	}
	#endregion

	#region Public Properties
	' + @PublicProperty + '
	#endregion

	#region Private Methods
	/// <summary>
	/// This function is set properties default value based on its data type in table.
	/// </summary>
	private void SetDefaulValue()
	{
		' + @SetDefaulValue + '
	}
	#endregion
}

    public class cls'+ @ClsTableName + 'AddEAL
    {
        ' + @AddLovsEAL + '
    }

    public class cls'+ @ClsTableName + 'EditEAL : cls'+ @ClsTableName + 'AddEAL
    {
        public cls'+ @ClsTableName + 'EAL '+ @ClsTableName + ' = new cls'+ @ClsTableName + 'EAL();
    }

    public class cls'+ @ClsTableName + 'GridEAL
    {
        public List<cls'+ @ClsTableName + 'EAL> '+ @ClsTableName + 's = new List<cls'+ @ClsTableName + 'EAL>();
        public int TotalRecords { get; set; }
    }

    public class cls'+ @ClsTableName + 'ListEAL : cls'+ @ClsTableName + 'GridEAL
    {
        ' + @ListLovsEAL + '
    }

    public class cls'+ @ClsTableName + 'ParameterEAL : clsPagingSortingEAL
    {
        #region Constructor
        /// <summary>
        /// This construction is set properties default value based on its data type in table.
        /// </summary>
        public cls'+ @ClsTableName + 'ParameterEAL()
        {
            SetDefaulValue();
        }
        #endregion

		#region Public Properties
		' + @PublicParameterProperty + '
		#endregion

		#region Private Methods
		/// <summary>
		/// This function is set properties default value based on its data type in table.
		/// </summary>
		private void SetDefaulValue()
		{
			' + @SetParameterDefaulValue + '
		}
		#endregion
    }
		'

	SET @BLL_String = N'/// <summary>
	/// This class having crud operation function of table '+ @TableName + '
	/// Created By :: '+ @DevelopmentBy + '
	/// Created On :: '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '
	/// </summary>
	public class cls'+ @ClsTableName + 'BLL : clsAbstractCommonBLL<cls'+ @ClsTableName + 'EAL, cls'+ @ClsTableName + 'MainEAL, cls'+ @ClsTableName + 'AddEAL, cls'+ @ClsTableName + 'EditEAL, cls'+ @ClsTableName + 'GridEAL, cls'+ @ClsTableName + 'ListEAL, cls'+ @ClsTableName + 'ParameterEAL, ' + @PKNetFieldDataType + '>
{
        ISql objCommonDAL;

	#region Constructor
	/// <summary>
	/// This construction is set properties default value based on its data type in table.
	/// </summary>
	public cls'+ @ClsTableName + 'BLL()
	{
            objCommonDAL = CreateSqlInstance();
	}
	#endregion

        #region Public Override Methods
    /// <summary>
    /// This function return map reader table field to EAL of ' + @TableName + '.
    /// </summary>
    /// <returns>EAL</returns>
        public override cls'+ @ClsTableName + 'EAL MapData(IDataReader reader)
        {
            cls'+ @ClsTableName + 'EAL obj'+ @ClsTableName + 'EAL = new cls'+ @ClsTableName + 'EAL();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                switch (reader.GetName(i))
                {
                    ' + @MapDataColumns + '
				}
            }
            return obj'+ @ClsTableName + 'EAL;
        }

        /// <summary>
        /// This function return all columns values for perticular ' + @TableName + ' record
        /// </summary>
        /// <param name="' + @PKFieldName + '">Perticular Record</param>
        /// <returns>EAL</returns>
        public override cls'+ @ClsTableName + 'EAL SelectForRecord(' + @PKNetFieldDataType + ' ' + @PKFieldName + ')
        {
            objCommonDAL.AddParameter("' + @PKFieldName + '", ' + @PKFieldName + ');
            List<cls'+ @ClsTableName + 'EAL> '+ @ClsTableName + 's = objCommonDAL.ExecuteList<cls'+ @ClsTableName + 'EAL>("' + @TableName + '_SelectForRecord", CommandType.StoredProcedure);
            if ('+ @ClsTableName + 's.Count > 0)
                return '+ @ClsTableName + 's[0];
            else
                return new cls'+ @ClsTableName + 'EAL();
        }

        /// <summary>
        /// This function returns main informations for bind ' + @ClsTableName + ' LOV
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'EAL">Filter criteria by EAL</param>
        /// <returns>Main EALs</returns>
		public override List<cls' + @ClsTableName + 'MainEAL> SelectForLOV(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @SelectAddParameter + '
			return objCommonDAL.ExecuteList<cls' + @ClsTableName + 'MainEAL>("' + @TableName + '_SelectForLOV", CommandType.StoredProcedure);
		}

        /// <summary>
        /// This function return all LOVs data for ' + @ClsTableName + ' page add mode
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Parameter</param>
        /// <returns>Add modes all LOVs data</returns>
        public override cls' + @ClsTableName + 'AddEAL SelectForAdd(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'AddEAL obj' + @ClsTableName + 'AddEAL = new cls' + @ClsTableName + 'AddEAL();
            ' + @BLLParameter + '
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'AddEAL>("' + @TableName + '_SelectForAdd", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @AddLOVsCount) + ', ref obj' + @ClsTableName + 'AddEAL, MapAddEAL);
            return obj' + @ClsTableName + 'AddEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' page add mode LOVs
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="obj' + @ClsTableName + 'AddEAL">Add mode EAL for fill data</param>
        /// <param name="reader">Database reader</param>
        public override void MapAddEAL(int resultSet, ref cls' + @ClsTableName + 'AddEAL obj' + @ClsTableName + 'AddEAL, IDataReader reader)
        {
            switch(resultSet)
            {
                ' + @MapAddEAL  + '
            }		
        }

        /// <summary>
        /// This function return all LOVs data and edit record information for ' + @ClsTableName + ' page edit mode
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Parameter</param>
        /// <returns>Edit modes all LOVs data and edit record information</returns>
        public override cls' + @ClsTableName + 'EditEAL SelectForEdit(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'EditEAL obj' + @ClsTableName + 'EditEAL = new cls' + @ClsTableName + 'EditEAL();
            ' + @BLLParameter + '
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'EditEAL>("' + @TableName + '_SelectForEdit", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @AddLOVsCount + 1) + ', ref obj' + @ClsTableName + 'EditEAL, MapEditEAL);
            return obj' + @ClsTableName + 'EditEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' page edit mode LOVs and edit record information
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'EditEAL">Edit mode EAL for fill data and edit record information</param>
        /// <param name="reader">Database reader</param>
        public override void MapEditEAL(int resultSet, ref cls' + @ClsTableName + 'EditEAL obj' + @ClsTableName + 'EditEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                case 0:
                    obj' + @ClsTableName + 'EditEAL.' + @ClsTableName + ' = objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader);
                    break;
                ' + @MapEditEAL  + '
            }
        }

        /// <summary>
        /// This function returns ' + @ClsTableName + ' list page grid data.
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Filter paramters</param>
        /// <returns>' + @ClsTableName + ' grid data</returns>
        public override cls' + @ClsTableName + 'GridEAL SelectForGrid(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'GridEAL obj' + @ClsTableName + 'GridEAL = new cls' + @ClsTableName + 'GridEAL();
            ' + @BLLParameter + '
            objCommonDAL.AddParameter("SortExpression", obj' + @ClsTableName + 'ParameterEAL.SortExpression);
            objCommonDAL.AddParameter("SortDirection", obj' + @ClsTableName + 'ParameterEAL.SortDirection);
            objCommonDAL.AddParameter("PageIndex", obj' + @ClsTableName + 'ParameterEAL.PageIndex);
            objCommonDAL.AddParameter("PageSize", obj' + @ClsTableName + 'ParameterEAL.PageSize);
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'GridEAL>("' + @TableName + '_SelectForGrid", CommandType.StoredProcedure, 2, ref obj' + @ClsTableName + 'GridEAL, MapGridEAL);
            return obj' + @ClsTableName + 'GridEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' grid data
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'GridEAL">' + @ClsTableName + ' grid data</param>
        /// <param name="reader">Database reader</param>
        public override void MapGridEAL(int resultSet, ref cls' + @ClsTableName + 'GridEAL obj' + @ClsTableName + 'GridEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                case 0:
                    obj' + @ClsTableName + 'GridEAL.' + @ClsTableName + 's.Add(objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader));
                    break;
                case 1:
                    obj' + @ClsTableName + 'GridEAL.TotalRecords = MyConvert.ToInt(reader["TotalRecords"]);
                    break;
            }
        }

        /// <summary>
        /// This function returns ' + @ClsTableName + ' list page grid data and LOV data
        /// </summary>
        /// <param name="obj' + @ClsTableName + 'ParameterEAL">Filter paramters</param>
        /// <returns>' + @ClsTableName + ' grid data and LOV data</returns>
        public override cls' + @ClsTableName + 'ListEAL SelectForList(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            cls' + @ClsTableName + 'ListEAL obj' + @ClsTableName + 'ListEAL = new cls' + @ClsTableName + 'ListEAL();
            ' + @BLLParameter + '
            objCommonDAL.AddParameter("SortExpression", obj' + @ClsTableName + 'ParameterEAL.SortExpression);
            objCommonDAL.AddParameter("SortDirection", obj' + @ClsTableName + 'ParameterEAL.SortDirection);
            objCommonDAL.AddParameter("PageIndex", obj' + @ClsTableName + 'ParameterEAL.PageIndex);
            objCommonDAL.AddParameter("PageSize", obj' + @ClsTableName + 'ParameterEAL.PageSize);
            objCommonDAL.ExecuteEnumerableMultiple<cls' + @ClsTableName + 'ListEAL>("' + @TableName + '_SelectForList", CommandType.StoredProcedure, ' + CONVERT(VARCHAR, @ListLOVsCount + 2) + ', ref obj' + @ClsTableName + 'ListEAL, MapListEAL);
            return obj' + @ClsTableName + 'ListEAL;
        }

        /// <summary>
        /// This function map data for ' + @ClsTableName + ' list page grid data and LOV data
        /// </summary>
        /// <param name="resultSet">Result Set No</param>
        /// <param name="cls' + @ClsTableName + 'ListEAL">' + @ClsTableName + ' list page grid data and LOV data</param>
        /// <param name="reader">Database reader</param>
        public override void MapListEAL(int resultSet, ref cls' + @ClsTableName + 'ListEAL obj' + @ClsTableName + 'ListEAL, IDataReader reader)
        {
            switch (resultSet)
            {
                ' + @MapListEAL + '
                case ' + CONVERT(VARCHAR, @ListLOVsCount) + ':
                    obj' + @ClsTableName + 'ListEAL.' + @ClsTableName + 's.Add(objCommonDAL.MapDataDynamically<cls' + @ClsTableName + 'EAL>(reader));
                    break;
                case ' + CONVERT(VARCHAR, @ListLOVsCount + 1) + ':
                    obj' + @ClsTableName + 'ListEAL.TotalRecords = MyConvert.ToInt(reader["TotalRecords"]);
                    break;
            }
        }

		/// <summary>
		/// This function insert record in ' + @TableName + ' table.
		/// </summary>
		/// <returns>Identity / AlreadyExist = 0</returns>
		public override ' + @PKNetFieldDataType + ' Insert(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @InsertAddParameter + 'return MyConvert.' + @PKNetConvert + '(objCommonDAL.ExecuteScalar("' + @TableName + '_Insert", CommandType.StoredProcedure));
		}

		/// <summary>
		/// This function update record in ' + @TableName + ' table.
		/// </summary>
		/// <returns>PrimaryKey Field Value / AlreadyExist = 0</returns>
		public override ' + @PKNetFieldDataType + ' Update(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
		{
			' + @UpdateAddParameter + 'return MyConvert.' + @PKNetConvert + '(objCommonDAL.ExecuteScalar("' + @TableName + '_Update", CommandType.StoredProcedure));
		}

		/// <summary>
		/// This function delete record from ' + @TableName + ' table.
		/// </summary>
		public override void Delete(' + @PKNetFieldDataType + ' ' + @PKFieldName + ', long UserId)
		{
			objCommonDAL.AddParameter("' + @PKFieldName + '", ' + @PKFieldName + ');
            objCommonDAL.AddParameter("UserId", UserId);
            objCommonDAL.AddParameter("LastUpdateDate", DateTime.UtcNow);
			objCommonDAL.ExecuteNonQuery("' + @TableName + '_Delete", CommandType.StoredProcedure);
		}
		#endregion
}
			'

	SET @WebAPIControllerString = N'    [RoutePrefix("' + LOWER(@Route + '/' + @ClsTableName) +'")]
    public class ' + @ClsTableName + 'Controller : ApiController, IPageController<cls' + @ClsTableName + 'EAL, cls' + @ClsTableName + 'ParameterEAL, ' + @PKNetFieldDataType + '>
    {
        #region Interface public methods
        [HttpGet]
        [Route("getRecord/{' + @PKFieldName + ':' + @PKNetFieldDataType +'}", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.record")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForRecord(' + @PKNetFieldDataType +' ' + @PKFieldName + ')
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForRecord(' + @PKFieldName + '));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getLovValue", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.lovValue")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.IgnoreAccessValidation)]
        [CustomCompression]
        public Response GetForLOV(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForLOV(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getAddMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.addMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Insert)]
        [CustomCompression]
        public Response GetForAdd(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForAdd(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getEditMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.editMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Update)]
        [CustomCompression]
        public Response GetForEdit(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForEdit(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getGridData", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.gridData")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForGrid(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForGrid(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("getListMode", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.listMode")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.View)]
        [CustomCompression]
        public Response GetForList(cls' + @ClsTableName + 'ParameterEAL obj' + @ClsTableName + 'ParameterEAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.SelectForList(obj' + @ClsTableName + 'ParameterEAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("insert", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.insert")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Insert)]
        [CustomCompression]
        public Response Insert(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.Insert(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("update", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.update")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Update)]
        [CustomCompression]
        public Response Update(cls' + @ClsTableName + 'EAL obj' + @ClsTableName + 'EAL)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                objResponse = new Response(obj' + @ClsTableName + 'BLL.Update(obj' + @ClsTableName + 'EAL));
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }

        [HttpPost]
        [Route("delete/{' + @PKFieldName + ':' + @PKNetFieldDataType +'}/{UserId:long}", Name = "' + LOWER(@Namespace + '.' + @ClsTableName) +'.delete")]
        [AuthorizeAPI(PageName = "' + @ClsTableName + '", PageAccess = AuthorizeAPIAttribute.PageAccessValues.Delete)]
        [CustomCompression]
        public Response Delete(' + @PKNetFieldDataType +' ' + @PKFieldName + ', long UserId)
        {
            Response objResponse;
            try
            {
                cls' + @ClsTableName + 'BLL obj' + @ClsTableName + 'BLL = new cls' + @ClsTableName + 'BLL();
                obj' + @ClsTableName + 'BLL.Delete(' + @PKFieldName + ', UserId);
                objResponse = new Response();
            }
            catch (Exception ex)
            {
                objResponse = new Response(ex.WriteLogFile(), ex);
            }
            return objResponse;
        }
        #endregion
	}
'

	SET @SpInsertString = N'	
ALTER PROCEDURE [dbo].[' + @TableName + '_Insert]
(
	' + @SpInsertParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Insert
	 PURPOSE  :  This SP insert record in table '+ @TableName + '.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Insert
	BEGIN TRY ' ELSE '' END + '
		DECLARE @' + @PKFieldName + ' ' + @PKFieldDataType + '
		IF NOT EXISTS(' + @AlreadyExistInsertSting + ')
		BEGIN
			INSERT INTO [' + @TableName + '] (' + @SpInsertField + ') 
			VALUES (' + @SpInsertValue + ')
			SET @' + @PKFieldName + ' = SCOPE_IDENTITY();
		END
		ELSE
			SET @' + @PKFieldName + ' = 0;
	
		SELECT @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Insert
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Insert
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'
	
	SET @SpUpdateString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Update]
(
	' + @SpUpdateParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Update
	 PURPOSE  :  This SP update record in table '+ @TableName + '.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Update
	BEGIN TRY ' ELSE '' END + '
		IF NOT EXISTS(' + @AlreadyExistUpdateSting + ')
		BEGIN
			UPDATE [' + @TableName + '] 
			SET ' + @SpUpdateSet + '
			WHERE [' + @PKFieldName + '] = @' + @PKFieldName + ';
		END
		ELSE
			SET @' + @PKFieldName + ' = 0;
	
		SELECT @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Update
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Update
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'
	
	SET @SpDeleteString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Delete]
(
	@' + @PKFieldName + ' ' + @PKFieldDataType + ',
	@UserId Int,
	@LastUpdateDate DateTime2
)
 AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Delete
	 PURPOSE  :  This SP delete record from table '+ @TableName + '
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN' + CASE @IsTransactionApply WHEN 1 THEN '
	BEGIN TRANSACTION ' + @TableName + 'Delete
	BEGIN TRY ' ELSE '' END + '
		UPDATE [' + @TableName + '] 
		SET 
			[IsDeleted] = 1, 
			[LastUpdatedBy] = @UserId,
			[LastUpdateDate] = @LastUpdateDate
		WHERE [' + @PKFieldName + '] = @' + @PKFieldName + ';'  + CASE @IsTransactionApply WHEN 1 THEN '
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION ' + @TableName + 'Delete
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION ' + @TableName + 'Delete
		
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorNumber INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorNumber = ERROR_NUMBER()
		RAISERROR  (@ErrorMessage,@ErrorSeverity,@ErrorState,@ErrorNumber)
	END CATCH' ELSE '' END + '
END	'

	SET @SpSelectString = N'
ALTER PROCEDURE [dbo].[' + @TableName + '_Select]
(
	' + @SpSelectParameter + ' 
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_Select
	 PURPOSE  :  This SP select records from table '+ @TableName + '
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectField + ' 
	FROM [' + @TableName + '] ' + @TableShortName + '
	WHERE ' + @SpSelectWhere + ' 
END	'

	SET @SpSelectForAddString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForAdd]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForAdd
	 PURPOSE  :  This SP use for fill all LOV in '+ @TableName + ' page for add mode
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	' + @AddLovsSPCall + '
END		'

	SET @SpSelectForEditString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForEdit]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForEdit
	 PURPOSE  :  This SP use for fill all LOV in '+ @TableName + ' page for edit mode
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	EXEC '+ @TableName + '_SelectForRecord @' + @PKFieldName + '

	EXEC '+ @TableName + '_SelectForAdd ' + @SpSelectForParameterPass + '
END	 '

	SET @SpSelectForGridString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForGrid]
(
	' + @SpSelectForParameter + ', 
	@SortExpression varchar(50),
	@SortDirection varchar(5),
	@PageIndex int,
	@PageSize int
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForGrid
	 PURPOSE  :  This SP select records from table '+ @TableName + ' for bind ' + @TableName + ' page grid.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	DECLARE @SqlQuery NVARCHAR(MAX)

	SET @SqlQuery = N''
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '
	ORDER BY '' + @SortExpression + '' '' + @SortDirection + ''
	OFFSET ((@PageIndex - 1) * @PageSize) ROWS
	FETCH NEXT @PageSize ROWS ONLY
	''

	EXEC sp_executesql @SqlQuery, N''' + @SpSelectForParameter + ', @PageIndex int, @PageSize int'', ' + @SpSelectForParameterPass + ', @PageIndex, @PageSize
	
	SELECT COUNT(1) AS TotalRecords
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '

END		
	'
	
	SET @SpSelectForExportString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForExport]
(
	' + @SpSelectForParameter + ', 
	@SortExpression varchar(50),
	@SortDirection varchar(5)
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForExport
	 PURPOSE  :  This SP select records from table ' + @TableName + ' for export ' + @TableName + ' page grid data in report.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	DECLARE @SqlQuery NVARCHAR(MAX)

	SET @SqlQuery = N''
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE  ' + @SpSelectForParameterWhere + '
	ORDER BY '' + @SortExpression + '' '' + @SortDirection 

	EXEC sp_executesql @SqlQuery, N''' + @SpSelectForParameter + ''', ' + @SpSelectForParameterPass + '
END		
	'

	SET @SpSelectForListString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForList]
(
	' + @SpSelectForParameter + ',
	@SortExpression varchar(50),
	@SortDirection varchar(5),
	@PageIndex int,
	@PageSize int
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForList
	 PURPOSE  :  This SP use for fill all LOV and list grid in '+ @TableName + ' list page
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	' + @ListLovsSPCall + '

	EXEC '+ @TableName + '_SelectForGrid ' + @SpSelectForParameterPass + ', @SortExpression, @SortDirection, @PageIndex, @PageSize
END	
	'

	SET @SpSelectForLOVString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForLOV]
(
	' + @SpSelectForParameter + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForLOV
	 PURPOSE  :  This SP select records from table '+ @TableName + ' for fill LOV
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectMainFields + '
	FROM [' + @TableName + '] ' + @TableShortName + '
	WHERE ' + @SpSelectForParameterWhere + '
END		
	'

	SET @SpSelectForRecordString = N'
ALTER PROCEDURE [dbo].['+ @TableName + '_SelectForRecord]
(
	@' + @PKFieldName + ' ' + @PKFieldDataType + '
)
AS
/***********************************************************************************************
	 NAME     :  ' + @TableName + '_SelectForRecord
	 PURPOSE  :  This SP select perticular record from table '+ @TableName + ' for open page in edit / view mode.
	 REVISIONS:
	 Ver        Date				        Author              Description
	 ---------  ----------					---------------		-------------------------------
	 1.0        '+ CONVERT(VARCHAR(10), @DevelopmentDateTime, 101) + '					'+ @DevelopmentBy + '             1. Initial Version.	 
************************************************************************************************/
BEGIN
	SELECT ' + @SpSelectField + '
	FROM ['+ @TableName + '] ' + @TableShortName + '
	WHERE ' + @TableShortName + '.[' + @PKFieldName + '] = @' + @PKFieldName + ';
END	
	'

	SET @AngularModelString = N'function ' + @ClsTableName + 'MainModel() {
'+ @ModelMainDefination +' }

function ' + @ClsTableName + 'Model() {
'+ @ModelDefination +' }

function ' + @ClsTableName + 'AddModel() {
    ' + @AddLovsModel + '
}

function ' + @ClsTableName + 'EditModel() {
    this.' + @ClsTableName + ' = new ' + @ClsTableName + 'Model();
    ' + @AddLovsModel + '
}

function ' + @ClsTableName + 'GridModel() {
    this.TotalRecords = 0;
    this.' + @ClsTableName + 's = [];
}

function ' + @ClsTableName + 'ListModel() {
    this.TotalRecords = 0;
    this.' + @ClsTableName + 's = [];
    ' + @ListLovsModel + '
}

function ' + @ClsTableName + 'ParameterModel() {
    ' + @ModelParameter + ' 

    this.SortExpression = '''';
    this.SortDirection = '''';
    this.PageIndex = 1;
    this.PageSize = 10;
    this.TotalRecords = 100;
}
'

	SET @AngularServiceString = N'angular.module(''emsApp'').service(''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', [''baseService'', function (baseService) {
    //#region main service
    this.getRecord = function (' + dbo.fnJavaScriptName(@PKFieldName) + ') {
        return baseService.httpGet(''' + LOWER(@Route + '/' + @ClsTableName) + '/getRecord/'' + ' + dbo.fnJavaScriptName(@PKFieldName) + ');
    }

    this.getLovValue = function (obj' + @ClsTableName + 'EAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getLovValue'', obj' + @ClsTableName + 'EAL);
    }

    this.getAddMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getAddMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getEditMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getEditMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getGridData = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getGridData'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.getListMode = function (obj' + @ClsTableName + 'ParameterEAL) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/getListMode'', obj' + @ClsTableName + 'ParameterEAL);
    }

    this.save = function (obj' + @ClsTableName + 'EAL) {
        if (obj' + @ClsTableName + 'EAL.' + @PKFieldName + ' > 0)
            return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/update'', obj' + @ClsTableName + 'EAL);
        else
            return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/insert'', obj' + @ClsTableName + 'EAL);
    }

    this.delete = function (' + dbo.fnJavaScriptName(@PKFieldName) + ', userId) {
        return baseService.httpPost(''' + LOWER(@Route + '/' + @ClsTableName) + '/delete/'' + ' + dbo.fnJavaScriptName(@PKFieldName) + ' + ''/'' + userId);
    }
    //#endregion
}]);'

	SET @AngularRouteString = N'angular.module(''emsApp'').config([''$stateProvider'', ''$urlRouterProvider'', ''$ocLazyLoadProvider'', function ($stateProvider, $urlRouterProvider, $ocLazyLoadProvider) {
    $stateProvider
          .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.list'', {
              url: ''/list'',
              views: {
                  '''': {
                      templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'List.html?v='' + version,
                      controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'ListController'',
                      resolve: {
                          deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                              return $ocLazyLoad.load(
                                {
                                    files: [
                                    ' + @ListLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'List.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                    ]
                                }
                              );
                          }]
                      }
                  }
              }
          })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'', {
            url: ''/add'',
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'', {
            url: ''/edit/:id'',
            params: { ''id'': null },
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
        .state(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'', {
            url: ''/copy/:id'',
            params: { ''id'': null },
            views: {
                '''': {
                    templateUrl: ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.html?v='' + version,
                    controller: ''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'',
                    resolve: {
                        deps: [''$ocLazyLoad'', function ($ocLazyLoad) {
                            return $ocLazyLoad.load({
                                files: [
                                    ' + @AddEditLovDepRoute + '''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Model.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + 'AddEdit.Controller.js?v='' + version,
                                    ''Areas/' + @Route + '/' + @ClsTableName + '/' + @ClsTableName + '.Service.js?v='' + version
                                ]
                            });
                        }]
                    }
                }
            }
        })
}]);
'
	
	SET @AngularAddEditControllerString = N'/// <reference path="../../../../Scripts/_references.js" />
angular.module(''emsApp'').controller(''' + dbo.fnJavaScriptName(@ClsTableName) + 'AddEditController'', [''$scope'', ''$rootScope'', ''$state'', ''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', ''Session'', function ($scope, $rootScope, $state, ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service, Session) {
    //#region submit or cancel record
    $scope.submitRecord = function () {
        if ($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Form.$invalid) {
            myToastr.warning(''Invalid input'');
            return;
        }
        if ($scope.accessModel.CanInsert || $scope.accessModel.CanUpdate || $scope.accessModel.CanCopy) {
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.save($scope.' + dbo.fnJavaScriptName(@ClsTableName) + ').then(function (response) {
                if (response == 0) {
                    myToastr.info("' + dbo.fnUserFriendlyName(@ClsTableName) + ' already exist.");
                    return;
                }
                else {
                    myToastr.success("' + dbo.fnUserFriendlyName(@ClsTableName) + ' submit successfully.");
                }
                $scope.cancelRecord();
            });
        }
    };

    $scope.cancelRecord = function () {
        $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.list'');
    };
    //#endregion

    //#region LOV
    //#endregion

    //#region set page UI
    $scope.setPageAddEditMode = function () {
        if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'')
            $scope.setPageAddMode();
        else if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'')
            $scope.setPageEditMode(''Edit'');
        else if ($state.current.name == ''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'')
            $scope.setPageEditMode(''Copy'');
    }

    $scope.setPageAddMode = function () {
        $scope.mode = ''Add'';

        var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel = new ' + @ClsTableName + 'ParameterModel();
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.OrgId = $rootScope.user.OrgId;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.UserId = $rootScope.user.Id;

        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getAddMode(' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel = new ' + @ClsTableName + 'AddModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'AddModel = response;

            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + ' = new ' + @ClsTableName + 'Model();
            ' + @AddLovSetAngular + '
        });
    }

    $scope.setPageEditMode = function (mode) {
        $scope.mode = mode;

        var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel = new ' + @ClsTableName + 'ParameterModel();
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.OrgId = $rootScope.user.OrgId;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.UserId = $rootScope.user.Id;
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel.' + @PKFieldName + ' = $state.params.id;

        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getEditMode(' + dbo.fnJavaScriptName(@ClsTableName) + 'ParameterModel).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel = new ' + @ClsTableName + 'EditModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel = response;

            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + ' = ' + dbo.fnJavaScriptName(@ClsTableName) + 'EditModel.' + @ClsTableName + ';
            ' + @EditLovSetAngular + '

            if (mode == ''Copy'')
                $scope.' + dbo.fnJavaScriptName(@ClsTableName) + '.' + @PKFieldName + ' = 0;
        });
    }

    $scope.setLOVConfiguration = function () {
        ' + @AddEditLovDeclareAngular + '
    }

    $scope.initializePage = function () {
        $scope.accessModel = Session.getAccess();

        $scope.setLOVConfiguration();

        $scope.setPageAddEditMode();
    }
    $scope.initializePage();
    //#endregion
}]);
'

	SET @AngularListControllerString = N'/// <reference path="../../../../Scripts/_references.js" />
angular.module(''emsApp'').controller(''' + dbo.fnJavaScriptName(@ClsTableName) + 'ListController'', [''$scope'', ''$rootScope'', ''$state'', ''' + dbo.fnJavaScriptName(@ClsTableName) + 'Service'', ''Session'', function ($scope, $rootScope, $state, ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service, Session) {
    //#region operation
    $scope.addNewRecord = function () {
        if ($scope.accessModel.CanInsert) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.add'');
        }
    };

    $scope.editRecord = function (id) {
        if ($scope.accessModel.CanUpdate) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.edit'', { ''id'': id });
        }
    };

    $scope.deleteRecord = function (id) {
        if ($scope.accessModel.CanDelete) {
            if (confirm("Do you want to delete reecord?")) {
                ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.delete(id, $rootScope.user.Id).then(function (response) {
                    myToastr.success("' + dbo.fnUserFriendlyName(@ClsTableName) + ' delete successfully.");
                    $scope.searchRecord();
                });
            }
        }
    };

    $scope.copyRecord = function (id) {
        if ($scope.accessModel.CanCopy) {
            $state.go(''' + LOWER(@Namespace + '.' + @ClsTableName) + '.copy'', { ''id'': id });
        }
    }
    //#endregion

    //#region search
    $scope.searchRecord = function () {
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getGridData($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel = new ' + @ClsTableName + 'GridModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel = response;
            $scope.' + @ClsTableName + 's = ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel.' + @ClsTableName + 's;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords = ' + dbo.fnJavaScriptName(@ClsTableName) + 'GridModel.TotalRecords;
        });
    }

    $scope.searchCancel = function () {
        $scope.setDefaultValue();

		$scope.searchRecord();
    };

    $scope.sortRecord = function (sortExpression) {
        if (sortExpression == $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression) {
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection == ''asc'' ? $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''desc'' : $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''asc'';
        }
        else {
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression = sortExpression;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''asc'';
        }
        $scope.searchRecord();
    };
    $scope.pageChanged = function () {
        $scope.searchRecord();
    };
    //#endregion

    //#region UI
    $scope.setPageListMode = function () {
        ' + dbo.fnJavaScriptName(@ClsTableName) + 'Service.getListMode($scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search).then(function (response) {
            var ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel = new ' + @ClsTableName + 'ListModel();
            ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel = response;
            ' + @ListLovSetAngular + '
            $scope.' + @ClsTableName + 's = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.' + @ClsTableName + 's;
            $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords = ' + dbo.fnJavaScriptName(@ClsTableName) + 'ListModel.TotalRecords;
        });
    }

    $scope.showHideSearchCriteria = function () {
        if ($scope.showSearchCriteria) {
            $scope.showSearchCriteria = false;
            $scope.showSearchCriteriaImage = ''chevron-down'';
        }
        else {
            $scope.showSearchCriteria = true;
            $scope.showSearchCriteriaImage = ''chevron-up'';
        }
    }

    $scope.setLOVConfiguration = function () {
        ' + @ListLovDeclareAngular + '
    }

    $scope.setDefaultValue = function () {
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search = new ' + @ClsTableName + 'ParameterModel();

        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortExpression = ''LastUpdateDate'';
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.SortDirection = ''desc'';
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageIndex = 1;
        $scope.' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize = ''10'';
    }

    $scope.initializePage = function () {
        $scope.accessModel = Session.getAccess();

        $scope.setLOVConfiguration();

        $scope.showSearchCriteria = false;

        $scope.setDefaultValue();

        $scope.setPageListMode();

        $scope.showHideSearchCriteria();
    }
    $scope.initializePage();
    //#endregion
}]);
'

	SET @AddEditHtmlString = N'
    <section class="content">
        <form class="form-horizontal" name="' + dbo.fnJavaScriptName(@ClsTableName) + 'Form" novalidate>
            <div class="row">
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' {{mode}}</h3>
                        </div>
                        <div class="box-body">
' + @HtmlInputModeFields + '
                        </div>
                        <div class="box-footer">
                            <button type="button" ng-click="cancelRecord();" class="btn btn-default">Cancel</button>
                            <button type="submit" ng-click="submitRecord();" class="btn btn-info pull-right" ng-disabled="!(accessModel.CanInsert || accessModel.CanUpdate || accessModel.CanCopy)" title="{{(accessModel.CanInsert || accessModel.CanUpdate  || accessModel.CanCopy) ? ''Click here to submit record.'' : ''You have not not add or edit or copy rights.''}}">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
'

	SET @ListHtmlString = N'
    <section class="content">
        <form class="form-horizontal" name="' + dbo.fnJavaScriptName(@ClsTableName) + 'SearchForm" novalidate>
            <div class="row">
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' Search Criteria</h3>
                            <div class="box-tools">
                                <div class="input-group input-group-sm" style="width: 40px;">
                                    <div class="input-group-btn">
                                        <button type="button" ng-click="showHideSearchCriteria();" class="btn btn-default"><i class="{{''fa fa-'' + showSearchCriteriaImage}}"></i></button>
                                        <button type="button" ng-click="addNewRecord();" class="btn btn-default" ng-disabled="!accessModel.CanInsert" title="{{accessModel.CanInsert ? ''Click here to add new record.'' : ''You have not add rights.''}}"><i class="fa fa-plus"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="box-body">
                            ' + @HtmlSearchModeFields + '
                        </div>
                        <div class="box-footer" ng-show="showSearchCriteria">
                            <button type="submit" ng-click="searchCancel();" class="btn btn-default">Reset</button>
                            <button type="submit" ng-click="searchRecord();" class="btn btn-info pull-right">Submit</button>
                        </div>
                    </div>
                </div>
                <div class="col-xs-12">
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title">' + dbo.fnUserFriendlyName(@ClsTableName) + ' List</h3>
                       </div>
                        <div class="box-body table-responsive">
                            <table class="table table-bordered">
                                <tbody>
                                    <tr>
                                        ' + @HtmlGridFieldsHeader + '
                                        <th style="width:50px;text-align:center">Edit</th>
                                        <th style="width:50px;text-align:center">Delete</th>
										<th style="width:50px;text-align:center">Copy</th>
                                    </tr>
                                    <tr ng-repeat="' + dbo.fnJavaScriptName(@ClsTableName) + 'List in ' + @ClsTableName + 's">
                                        ' + @HtmlGridFieldsDetail + '
                                        <td style="width:50px;text-align:center">
                                            <button type="button" class="btn btn-default" ng-click="editRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanUpdate" title="{{accessModel.CanUpdate ? ''Click here to edit this record.'' : ''You have not edit rights.''}}"><i class="fa fa-pencil"></i></button>
                                        </td>
                                        <td style="width:50px;text-align:center">
                                            <button type="button" class="btn btn-default" ng-click="deleteRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanDelete" title="{{accessModel.CanDelete ? ''Click here to delete this record.'' : ''You have not delete rights.''}}"><i class="fa fa-remove"></i></button>
                                        </td>
										<td style="width:50px;text-align:center">
											<button type="button" class="btn btn-default" ng-click="copyRecord(' + dbo.fnJavaScriptName(@ClsTableName) + 'List.Id);" ng-disabled="!accessModel.CanCopy" title="{{accessModel.CanCopy ? ''Click here to copy this record.'' : ''You have not copy rights.''}}"><i class="fa fa-files-o"></i></button>
										</td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="box-tools">
                                <SELECT ng-change="pageChanged();" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize">
                                    <option value="10">10</option>
                                    <option value="20">20</option>
                                    <option value="25">25</option>
                                    <option value="50">50</option>
                                    <option value="100">100</option>
                                    <option value="150">150</option>
                                    <option value="200">200</option>
                                </select>
                                <ul uib-pagination items-per-page="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageSize" ng-change="pageChanged();" total-items="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.TotalRecords" ng-model="' + dbo.fnJavaScriptName(@ClsTableName) + 'Search.PageIndex" max-size="3" class="pagination-sm no-margin pull-right" boundary-link-numbers="true"></ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
	'

	SELECT @SpInsertString AS [Insert SP]
	SELECT @SpUpdateString AS [Update SP]
	SELECT @SpDeleteString AS [Delete SP]
	SELECT @SpSelectString AS [Select SP]
	SELECT @SpSelectForAddString AS [Select For Add SP]
	SELECT @SpSelectForEditString AS [Select For Edit SP]
	SELECT @SpSelectForGridString AS [Select For Grid SP]
	SELECT @SpSelectForListString AS [Select For List SP]
	SELECT @SpSelectForLOVString AS [Select For LOV SP]
	SELECT @SpSelectForRecordString AS [Select For Record SP]
	SELECT @SpSelectForExportString AS [Select For Export SP]
	
	SELECT @EAL_String AS EAL
	SELECT @BLL_String AS BLL
	SELECT @BLL_String AS BLL for xml RAW
	SELECT @WebAPIControllerString AS [Web API Controller]

	SELECT @AngularModelString AS [Angular Model]
	SELECT @AngularServiceString AS [Angular Service]
	SELECT @AngularRouteString AS [Angular Route]
	SELECT @AngularAddEditControllerString AS [Angular Add-Edit Controller]
	SELECT @AngularListControllerString AS [Angular List Controller]
	SELECT @AddEditHtmlString AS [Add Edit HTML]
	SELECT @AddEditHtmlString AS AddEditHtmlString for xml RAW
	SELECT @ListHtmlString AS [List HTML]
	SELECT @ListHtmlString AS ListHtmlString for xml RAW

END



GO



*/
--===============================================================================================================
--===============================================================================================================
/*
--DBA_GenerateExecutionPlanLog.sql
USE [TREX]
GO

/****** Object:  StoredProcedure [dbo].[DBA_GenerateExecutionPlanLog]    Script Date: 7/22/2022 7:48:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DBA_GenerateExecutionPlanLog]
AS

begin


insert into DBA_ExecutionPlanLog ([TransactionTime], [TSQL_Text],CPUPercentage, [cpu_per_execution], [logical_reads_per_execution], 
[elapsed_time_per_execution], [last_elapsed_time], [last_execution_time], [creation_time], [execution_count], [total_cpu_time], [max_cpu_time], [total_elapsed_time], [max_elapsed_time], [total_logical_reads], [max_logical_reads], [total_physical_reads], [max_physical_reads], [query_plan], [cacheobjtype], [objtype], [size_in_bytes], [plan_handle], [flush_QueryCommand])
	SELECT 
	getdate(),
	dm_exec_sql_text.text AS TSQL_Text,
	(dm_exec_query_stats.last_elapsed_time/((CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL)))) CPUPercentage,
	CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as cpu_per_execution,
	CAST(CAST(dm_exec_query_stats.total_logical_reads AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as logical_reads_per_execution,
	CAST(CAST(dm_exec_query_stats.total_elapsed_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS INT) as elapsed_time_per_execution,
	dm_exec_query_stats.last_elapsed_time,

	dm_exec_query_stats.last_execution_time,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_worker_time AS total_cpu_time,
	dm_exec_query_stats.max_worker_time AS max_cpu_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.max_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.max_logical_reads,
	dm_exec_query_stats.total_physical_reads, 
	dm_exec_query_stats.max_physical_reads,
	dm_exec_query_plan.query_plan,
	dm_exec_cached_plans.cacheobjtype,
	dm_exec_cached_plans.objtype,
	dm_exec_cached_plans.size_in_bytes,
	dm_exec_query_stats.plan_handle,
	 'DBCC FREEPROCCACHE (0x' + convert(varchar(max),dm_exec_query_stats.plan_handle, 2) + ')' flush_QueryCommand
FROM sys.dm_exec_query_stats 
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases ON dm_exec_sql_text.dbid = databases.database_id
INNER JOIN sys.dm_exec_cached_plans ON dm_exec_cached_plans.plan_handle = dm_exec_query_stats.plan_handle
WHERE databases.name = 'TREX'
AND dm_exec_query_stats.last_elapsed_time > 
(CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS bigINT) + (cast(CAST(CAST(dm_exec_query_stats.total_worker_time AS DECIMAL)/CAST(dm_exec_query_stats.execution_count AS DECIMAL) AS bigINT) * 20/100 as bigint)))
and last_execution_time> dateadd(HH,-1,getdate())

end
GO



*/
--===============================================================================================================
--===============================================================================================================
/*
--DBA_SQLServer_BlockingSessions.sql

USE [TREX]
GO

/****** Object:  StoredProcedure [dbo].[DBA_SQLServer_BlockingSessions]    Script Date: 7/22/2022 7:48:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DBA_SQLServer_BlockingSessions]
AS 
BEGIN
SET NOCOUNT ON;
DECLARE @ERRORMSG varchar(max),
		@SNO INT,
		@Mins INT,
		@SQLVERSION VARCHAR(100)

-- declaration for email 
declare 
	@v_servername		varchar(200),
	@v_email_subject	varchar(255),
	@v_email_profile	varchar(100),
	@v_recipient_list	 varchar(255),
	@v_copyrecipient_list	varchar(255),
	@v_ip_address		varchar(100),
	@v_table_name		varchar(255),
	@v_rec_cnt  		bigint,
	@v_alert_tag		varchar(100)
	
declare @v_message			varchar(max),
	    @v_message_bkcl1	varchar(max),
	    @v_message_bkcl2	varchar(max),
		@v_message_bkcl3	varchar(max)

set @v_alert_tag = 'MSSQLBLOCKS'
set @v_servername = CONVERT(varchar(100), SERVERPROPERTY('Servername') )

-- select 
	-- @v_email_subject = 'MSSQL:'+ @v_servername+': '+email_subject,
	-- @v_email_profile = email_profile,
	-- @v_recipient_list = 	recipient_list,
	-- @v_copyrecipient_list = copyrecipient_list
-- from sqldba.dbo.sqldba_email_configuration where email_tag = @v_alert_tag

Select 
@v_email_subject = @v_servername +' - SQLServer_BlockingSessions', 
@v_email_profile = 'TREXSQLALERTS',
--@v_recipient_list= 'kkhatri@infosenseglobal.com;jajmeri@infosenseglobal.com;'
@v_recipient_list= 'sqldba@infosenseglobal.com; bsarvaiya@infosenseglobal.com'

 
/* Fetches the numeric part of SQL Version */
SELECT @SQLVERSION = RTRIM(LTRIM(SUBSTRING(@@VERSION,22,5))) 

	create table #BS(
		session_id				bigint,
		blocking_session_id		bigint,
		connect_time			datetime,
		status					varchar(20),
		host_name				varchar(50),
		program_name			varchar(200),
		client_interface_name	varchar(100),
		login_name				varchar(100),
		last_request_start_time datetime,
		original_login_name		varchar(100),
		command					varchar(100),
		sql_text				varchar(260),
		dbname					varchar(100),
		last_wait_type			varchar(100),
		client_net_address		varchar(100),
		DiffInSec				BIGINT
	)

	insert into #BS
	(
	session_id		,		
	blocking_session_id	,
	connect_time	,		
	status			,		
	host_name		,		
	program_name	,		
	client_interface_name	,
	login_name				,
	last_request_start_time ,
	original_login_name		,
	command,					
	sql_text			,	
	dbname				,	
	last_wait_type			,
	client_net_address	,
	DiffinSec
	)	

	SELECT  
		ec.session_id, 
		er.blocking_session_id,
		ec.connect_time,
		es.status,
		es.host_name,
		es.program_name,
		es.client_interface_name,
		es.login_name,
		er.start_time,
 		es.original_login_name,  
		er.command,  
		(SELECT substring(text,1,250) FROM sys.dm_exec_sql_text(er.sql_handle)) sql_text,  
		db_name(er.database_id) as dbname,   
		er.last_wait_type,
		ec.client_net_address ,
		DATEDIFF_BIG(second,er.start_time,getdate()) as DiffinSec
		from sys.dm_exec_connections  ec  
		inner join sys.dm_exec_sessions es on (ec.session_id =es.session_id)  
		inner join sys.dm_exec_requests er on (ec.connection_id =er.connection_id)  
	WHERE ( er.blocking_session_id !=0 or er.wait_type != 0x0000 )
	AND last_wait_type<>'BROKER_RECEIVE_WAITFOR'
					and er.command not in ('BACKUP DATABASE')
					and db_name(er.database_id)='TREX'
					and DATEDIFF_BIG(second,er.start_time,getdate())>30
	--UNION ALL 
	--SELECT   
	--	ec.session_id, 
	--	null blocking_session_id,
	--	ec.connect_time,
	--	es.status,
	--	es.host_name,
	--	es.program_name,
	--	es.client_interface_name,
	--	es.login_name,
	--	es.last_request_start_time,
 --		es.original_login_name,  
	--	null command,  
	--	(SELECT substring(text,1,250) FROM sys.dm_exec_sql_text(ec.most_recent_sql_handle)) sql_text,  
	--	NULL  dbname,   
	--	NULL last_wait_type ,
	--	ec.client_net_address ,
	--	DATEDIFF_BIG(second,last_request_start_time,getdate()) as DiffinSec
	--	from sys.dm_exec_connections  ec  
	--	inner join sys.dm_exec_sessions es on (ec.session_id =es.session_id)  
	--WHERE ec.session_id in (select BS.blocking_session_id from sys.dm_exec_requests BS where  blocking_session_id >0) 
	--			and DATEDIFF_BIG(second,last_request_start_time,getdate())>30;


	IF (SELECT COUNT(1) FROM #BS  ) > 0 
		BEGIN 
			SET @v_message_bkcl1 =

						N'<html> <style> body, table{ font-size:9pt; font-family:Calibri; } </style> <head> ' +
			N'<body>' +
			N'<tr> <br><br> '+ 'Blocking sessions found. Below are SQL server blocking session details..' + ' <br><br><br>' +
			N'<tr> <br><br> '+ 'Current Tyime..' + CAST(getdate() AS varchar(50)) + ' <br><br><br>' +
			N'<table border="0" width="100%" >' +
			N'<style> table, th, td {font:80%%; border: 1px solid black;padding: 5px;border-collapse: collapse;text-align:left}</style>' +
			N'<style> td {background-color: #f0f0f0}</style>' +
			N'<style> th {background-color: #e0e0a0}</style>' 

 
 
		 		SET @v_message_bkcl2 =
	 				N'<table border="1" cellpadding="0" cellspacing="0" width="100%">' +
					N'<tr bgcolor="#90D0F0">
					<th>Session ID</th>
					<th>Blocking Session ID</th>
					<th>Connect Time</th>
					<th>Status</th>
					<th>Host Name</th>
					<th>Program Name</th>
					<th>Client Interface Name</th>
					<th>Login Name</th>
					<th>Last Request Start Time</th>
					<th>Original Login name</th>
					<th>command</th>
					<th>SQL Text</th>
					<th>DB Name</th>
					<th>Last Wait Type</th>
					<th>Client Net Address</th>
					<th>Difference In Seconds</th>
					</tr>' 
					+
					CAST (( 
					SELECT 
					td =isnull(session_id,' '),'',
					td =isnull(blocking_session_id,' '),'',
					td =isnull(connect_time,' '),'',
					td =isnull(status,' '),'',
					td =isnull(host_name,' '),'',
					td =isnull(program_name,' '),'',
					td =isnull(client_interface_name,' '),'',
					td =isnull(login_name,' '),'',
					td =isnull(last_request_start_time,' '),'',
					td =isnull(original_login_name,' '),'',
					td =isnull(command,' '),'',
					td =isnull(sql_text,' '),'',
					td =isnull(dbname,' '),'',
					td =isnull(last_wait_type,' '),'',
					td =isnull(client_net_address,' '),'',
					td =isnull(DiffinSec,' '),''
					FROM #BS
					FOR XML PATH('tr'), TYPE
						) AS NVARCHAR(MAX) ) +
						N'</table> </br>' ;
 	
			set @v_message_bkcl3 = 
						N'</table> ' 

			set @v_message =  isnull(@v_message_bkcl1,' ') + isnull (@v_message_bkcl2,'') +   isnull(@v_message_bkcl3,' ')  + '</body></html>'

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name =  @v_email_profile,
				@recipients = @v_recipient_list,
				@copy_recipients = @v_copyrecipient_list,
				@body = @v_message,
				@subject = @v_email_subject,
				@body_format = 'HTML' ;

	   	 END 
		ELSE 
			BEGIN
				Print 'There is no blocking session';
		END; 
			
drop table #BS ;
END

  
GO



*/
--===============================================================================================================
--===============================================================================================================
/*
--DBA_TREXRendexing.sql

USE [TREX]
GO

/****** Object:  StoredProcedure [dbo].[DBA_TREXRendexing]    Script Date: 7/22/2022 7:49:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DBA_TREXRendexing]
as
BEGIN

 /******************************************************************************  
       NAME     :  [DBA_TREXRendexing]  
       PURPOSE  :   This script will rebuild indexes which are fragmented more than 30 %
       REVISIONS:  
       Ver        Date			Author						Description  
       ---------  ----------	---------------  ------------------------------------  
       1.0        09/25/2020	Jahid Ajmeri				1. Initial Version.  
  
    EXEC dbo.[DBA_TREXRendexing]  
     
    ******************************************************************************/  
 

DECLARE @Database NVARCHAR(255)   
DECLARE @Table NVARCHAR(255)  
DECLARE @indexname NVARCHAR(255)
DECLARE @cmd NVARCHAR(1000)  


insert into fragmentation_Log(indexname , tablename , fragmentation , transactiondate,fromJOb, partitionno )
SELECT ind.name,'[' + table_catalog + '].[' + table_schema + '].[' +  
		table_name + ']' as tableName , indexstats.avg_fragmentation_in_percent,
		getdate(),0, indexstats.partition_number 
		FROM TREX.sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
		INNER JOIN TREX.sys.indexes ind  
		INNER JOIN TREX.INFORMATION_SCHEMA.TABLES isc 
		ON  OBJECT_NAME(ind.OBJECT_ID) = isc.TABLE_NAME
		ON ind.object_id = indexstats.object_id 
		AND ind.index_id = indexstats.index_id 
		WHERE indexstats.avg_fragmentation_in_percent > 30 
		and ind.name is not null and isc.TABLE_TYPE = 'BASE TABLE'
		--ORDER BY indexstats.avg_fragmentation_in_percent DESC

DECLARE DatabaseCursor CURSOR READ_ONLY FOR  
SELECT name FROM master.sys.databases   
WHERE name  IN ('TREX')  -- databases name
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database  
WHILE @@FETCH_STATUS = 0  
BEGIN  

   SET @cmd = 'DECLARE TableCursor CURSOR READ_ONLY FOR SELECT ind.name,''['' + table_catalog + ''].['' + table_schema + ''].['' +  
		table_name + '']'' as tableName 
		FROM TREX.sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
		INNER JOIN TREX.sys.indexes ind  
		INNER JOIN TREX.INFORMATION_SCHEMA.TABLES isc 
		ON  OBJECT_NAME(ind.OBJECT_ID) = isc.TABLE_NAME
		ON ind.object_id = indexstats.object_id 
		AND ind.index_id = indexstats.index_id 
		WHERE indexstats.avg_fragmentation_in_percent > 30 
		and ind.name is not null and isc.TABLE_TYPE = ''BASE TABLE''
		ORDER BY indexstats.avg_fragmentation_in_percent DESC
'   

   -- create table cursor  
   
   EXEC (@cmd)  
   OPEN TableCursor   

   FETCH NEXT FROM TableCursor INTO @indexname, @Table   
   WHILE @@FETCH_STATUS = 0   
   BEGIN
      BEGIN TRY   
	  
         SET @cmd = 'ALTER INDEX ' + @indexname + ' ON ' + @Table + ' REBUILD;' 
         PRINT @cmd -- uncomment if you want to see commands
         EXEC (@cmd) 
      END TRY
      BEGIN CATCH
         PRINT '---'
         PRINT @cmd
         PRINT ERROR_MESSAGE() 
         PRINT '---'
      END CATCH

      FETCH NEXT FROM TableCursor INTO @indexname,@Table   
   END   

   CLOSE TableCursor   
   DEALLOCATE TableCursor  

   FETCH NEXT FROM DatabaseCursor INTO @Database  
END  
CLOSE DatabaseCursor   
DEALLOCATE DatabaseCursor



	insert into fragmentation_Log(indexname , tablename , fragmentation , transactiondate,fromJOb ,partitionno)
	SELECT ind.name,'[' + table_catalog + '].[' + table_schema + '].[' +  
			table_name + ']' as tableName , indexstats.avg_fragmentation_in_percent,
			getdate(),1, indexstats.partition_number
			FROM TREX.sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
			INNER JOIN TREX.sys.indexes ind  
			INNER JOIN TREX.INFORMATION_SCHEMA.TABLES isc 
			ON  OBJECT_NAME(ind.OBJECT_ID) = isc.TABLE_NAME
			ON ind.object_id = indexstats.object_id 
			AND ind.index_id = indexstats.index_id 
			WHERE indexstats.avg_fragmentation_in_percent > 30 
			and ind.name is not null and isc.TABLE_TYPE = 'BASE TABLE'
			--ORDER BY indexstats.avg_fragmentation_in_percent DESC

END
GO



*/
--===============================================================================================================
--===============================================================================================================
/*
--DBA_TREXUpdateStatistics.sql
USE [TREX]
GO

/****** Object:  StoredProcedure [dbo].[DBA_TREXUpdateStatistics]    Script Date: 7/22/2022 7:49:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DBA_TREXUpdateStatistics]
as
BEGIN

 /******************************************************************************  
       NAME     :  [DBA_TREXUpdateStatistics] 
       PURPOSE  :   This script will updating older statistics
       REVISIONS:  
       Ver        Date			Author						Description  
       ---------  ----------	---------------  ------------------------------------  
       1.0        09/25/2020	Jahid Ajmeri				1. Initial Version.  
  
    EXEC dbo.[DBA_TREXUpdateStatistics] 
     
    ******************************************************************************/  
 
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT
	ss.name AS SchemaName
	, st.name AS TableName
	, si.name AS IndexName
	, si.type_desc AS IndexType
	, STATS_DATE(si.object_id,si.index_id) AS StatsLastTaken
	, ssi.rowcnt
	, ssi.rowmodctr, DATEDIFF(day, STATS_DATE(si.object_id,si.index_id), GETDATE()) as datediff_Stat
	INTO #IndexUsage
	FROM sys.indexes si
	INNER JOIN sys.sysindexes ssi ON si.object_id = ssi.id
	AND si.name = ssi.name
	INNER JOIN sys.tables st ON st.[object_id] = si.[object_id]
	INNER JOIN sys.schemas ss ON ss.[schema_id] = st.[schema_id]
	WHERE st.is_ms_shipped = 0
	AND si.index_id != 0
	AND ssi.rowcnt > 10000
	AND (ssi.rowmodctr > 0 OR DATEDIFF(day, STATS_DATE(si.object_id,si.index_id), GETDATE()) >10)
	select * from #IndexUsage

	DECLARE @UpdateStatisticsSQL NVARCHAR(MAX)
	SET @UpdateStatisticsSQL = ''
	SELECT
	@UpdateStatisticsSQL = @UpdateStatisticsSQL
	+ CHAR(10) + 'UPDATE STATISTICS '
	+ QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName)
	+ ' ' + QUOTENAME(IndexName) + ' WITH SAMPLE '
	+ CASE
	WHEN rowcnt < 500000 THEN '100 PERCENT'
	WHEN rowcnt < 1000000 THEN '50 PERCENT'
	WHEN rowcnt < 5000000 THEN '25 PERCENT'
	WHEN rowcnt < 10000000 THEN '10 PERCENT'
	WHEN rowcnt < 50000000 THEN '2 PERCENT'
	WHEN rowcnt < 100000000 THEN '1 PERCENT'
	ELSE '3000000 ROWS '
	END
	+ '-- ' + CAST(rowcnt AS VARCHAR(22)) + ' rows'
	FROM #IndexUsage
	DECLARE @StartOffset INT
	DECLARE @Length INT
	SET @StartOffset = 0
	SET @Length = 4000
	WHILE (@StartOffset < LEN(@UpdateStatisticsSQL))
	BEGIN
	PRINT SUBSTRING(@UpdateStatisticsSQL, @StartOffset, @Length)
	SET @StartOffset = @StartOffset + @Length
	END
	PRINT SUBSTRING(@UpdateStatisticsSQL, @StartOffset, @Length)
	EXECUTE sp_executesql @UpdateStatisticsSQL
	DROP TABLE #IndexUsage 

END
GO




*/
--===============================================================================================================
--===============================================================================================================
/*Partition Creation

USE TREX
SELECT
'CREATE PARTITION FUNCTION ['+pf.name+']('+TYPE_NAME(system_type_id)+') AS RANGE LEFT FOR VALUES 
('+
--STRING_AGG(  'N'''+convert(varchar, prv.value, 21)+'''' ,',')WITHIN GROUP (ORDER BY pstats.partition_number)
STRING_AGG( convert(varchar, prv.value, 21) ,',')WITHIN GROUP (ORDER BY pstats.partition_number)
  +')
GO' AS Step1
,'CREATE PARTITION SCHEME ['+ps.name+'] AS PARTITION ['+pf.name+'] TO 
('+
STRING_AGG(  '['+convert(varchar, ds.name, 21)+']' ,',')WITHIN GROUP (ORDER BY pstats.partition_number)
 +')
GO' AS Step2
  FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN  sys.database_files as f  on ds.data_space_id = f.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id

LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
Where OBJECT_NAME(pstats.object_id)='Highwayevents'
group by pf.name ,ps.name,TYPE_NAME(system_type_id)




USE TREX
SELECT
'ALTER DATABASE '+DB_NAME(DB_ID())+' ADD FILEGROUP ['+ds.name+'];'  AS Step3
,
'ALTER DATABASE '+DB_NAME(DB_ID())+'
  ADD FILE
  (NAME = N'''+ds.name+''',
  FILENAME = N'''+f.physical_name+'''
  )
  TO FILEGROUP  ['+ds.name+']  
  ;'
  AS Step4
  FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN  sys.database_files as f  on ds.data_space_id = f.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id

LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
Where OBJECT_NAME(pstats.object_id)='Highwayevents'
and boundary_id is not null
ORDER BY pstats.partition_number


*/
--===============================================================================================================
--===============================================================================================================
/*
Query-to-list-recordcount-size-for-table-in-database.sql

USE [adv_1225] -- replace your dbname
GO
SELECT
s.Name AS SchemaName,
t.Name AS TableName,
p.rows AS RowCounts,
CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB,
CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB,
CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
GROUP BY t.Name, s.Name, p.Rows
ORDER BY s.Name, t.Name
GO

*/
--===============================================================================================================
--===============================================================================================================
/*
--Query-to-shrink-logfiles.sql


  USE adv_1225;  
GO  
-- Truncate the log by changing the database recovery model to SIMPLE.  
ALTER DATABASE adv_1225  SET RECOVERY SIMPLE;  
GO  
-- Shrink the truncated log file to 1 MB.  
DBCC SHRINKFILE (AdventureWorksLT2012_Log, 1);  
GO  
-- Reset the database recovery model.  
ALTER DATABASE adv_1225  SET RECOVERY FULL;  
GO 


USE adv_1225;  
GO  
SELECT file_id, name  
FROM sys.database_files;  
GO  
DBCC SHRINKFILE (1, TRUNCATEONLY); 

*/
--===============================================================================================================
--===============================================================================================================
/*
--TR_Auditing.sql


CREATE TRIGGER [TR_Auditing]
ON DATABASE
FOR alter_procedure, drop_procedure, alter_table, drop_table, alter_function, drop_function
AS
	SET NOCOUNT ON

	DECLARE @data XML
	SET @data = EVENTDATA()

	INSERT INTO dbo._ChangeLog(databasename, eventtype, objectname, objecttype, sqlcommand, loginname)
	VALUES(
			@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
			@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
			@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'), 
			@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
			@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
			@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
	)
GO

/*
*/

END