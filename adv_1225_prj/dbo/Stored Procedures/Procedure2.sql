CREATE PROCEDURE [dbo].[Procedure2]
	@param1 int = 0,
	@param2 int
AS
	
begin

/*=========================================================================
--Running Queries
1Tr@n$c0m2
1Tr@n$c0m3
----------------------------------------------------------------------------------------------------------------------------------------
USE master
GO
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT
distinct
er.session_Id AS [Spid],
SUBSTRING (qt.text, (er.statement_start_offset/2) + 1,
((CASE WHEN er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
ELSE er.statement_end_offset
END - er.statement_start_offset)/2) + 1) AS [Individual Query]
FROM sys.dm_exec_requests er
INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
WHERE session_Id > 50
AND session_Id NOT IN (@@SPID)
ORDER BY 1
----------------------------------------------------------------------------------------------------------------------------------------
Shrink each database files for specific database
-------------------------------------------------
https://dba.stackexchange.com/questions/174039/database-shrink
-------------------------------------------------

--QUERY TO GET TEMP TABLE STRUCTURE-----------------------------------------------------------------------------------------------------

EXEC TEMPDB..SP_HELP #MonthlyReport_SelectForGridFinal

SELECT char(9) + '[' + c.column_name + '] ' + c.data_type 
   + CASE 
        WHEN c.data_type IN ('decimal')
            THEN isnull('(' + convert(varchar, c.numeric_precision) + ', ' + convert(varchar, c.numeric_scale) + ')', '') 
        WHEN c.data_type IN ('varchar', 'nvarchar', 'char', 'nchar')
            THEN isnull('(' 
                + CASE WHEN c.character_maximum_length = -1
                    THEN 'max'
                    ELSE convert(varchar, c.character_maximum_length) 
                  END + ')', '')
        ELSE '' END
   + CASE WHEN c.IS_NULLABLE = 'YES' THEN ' NULL' ELSE '' END
   + ','
FROM tempdb.INFORMATION_SCHEMA.COLUMNS c 
WHERE TABLE_NAME LIKE '#MonthlyReport_SelectForGridFinal%' 
ORDER BY c.ordinal_position

---------------------------------------------------------------------------------------------------------------------------------------- 
 
--select * from sys.databases
select       'USE [' + d.name + N']' + CHAR(13) + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE d.database_id = 9;

----------------------------------------------------------------------------------------------------------------------------------------

SELECT r.session_id AS [Session_Id]
    ,r.command AS [command]
    ,CONVERT(NUMERIC(6, 2), r.percent_complete) AS [% Complete]
    ,GETDATE() AS [Current Time]
    ,CONVERT(VARCHAR(20), DATEADD(ms, r.estimated_completion_time, GetDate()), 20) AS [Estimated Completion Time]
    ,CONVERT(NUMERIC(32, 2), r.total_elapsed_time / 1000.0 / 60.0) AS [Elapsed Min]
    ,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 / 60.0) AS [Estimated Min]
    ,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 / 60.0 / 60.0) AS [Estimated Hours]
    ,CONVERT(VARCHAR(1000), (
            SELECT SUBSTRING(TEXT, r.statement_start_offset / 2, CASE
                        WHEN r.statement_end_offset = - 1
                            THEN 1000
                        ELSE (r.statement_end_offset - r.statement_start_offset) / 2
                        END) 'Statement text'
            FROM sys.dm_exec_sql_text(sql_handle)
            ))
FROM sys.dm_exec_requests r
WHERE command like 'RESTORE%'
or  command like 'BACKUP%'
-------------------
--- Query to find job based on procedure

SELECT  sj.name         AS job_name
        ,sjs.step_id
        ,sjs.step_name
        ,sjs.command 
FROM msdb.dbo.sysjobs           AS sj
JOIN msdb.dbo.sysjobsteps       AS sjs
ON   sj.job_id = sjs.job_id
WHERE command like '%RoadwayClosureLog_MailSend%'
AND  sjs.subsystem = 'TSQL'
ORDER BY sj.name ,sjs.step_id
-------------------
https://www.sqlshack.com/author/daniel-calbimonte/
----------------------------------------------------------------------------------------------------------------------------------------------
-- Transaction tables

SELECT T.name TableName,i.Rows NumberOfRows,i2.Rows PRDNumberOfRows,(i2.Rows -i.Rows )
FROM [TREX-DR].trex.sys.tables T WITH (NOLOCK)
JOIN [TREX-DR].trex.sys.sysindexes I WITH (NOLOCK) ON T.OBJECT_ID = I.ID
JOIN trex.sys.tables T2 WITH (NOLOCK) ON T.NAME = T2.NAME
JOIN trex.sys.sysindexes I2 WITH (NOLOCK) ON T2.OBJECT_ID = I2.ID
WHERE I.indid IN (0,1)
AND I2.indid IN (0,1)
and t.name in (
select referenced_entity_name from sys.sql_expression_dependencies as d where referencing_id = OBJECT_ID ('SyncTrexTransactionTables')
and exists (select 1 from sys.objects where name = d.referenced_entity_name))
AND i.Rows <> i2.Rows
ORDER BY i.Rows DESC,T.name

-- Master tables

SELECT T.name TableName,i.Rows NumberOfRows,i2.Rows PRDNumberOfRows,(i2.Rows -i.Rows )
FROM [TREX-DR].trex.sys.tables T WITH (NOLOCK)
JOIN [TREX-DR].trex.sys.sysindexes I WITH (NOLOCK) ON T.OBJECT_ID = I.ID
JOIN trex.sys.tables T2 WITH (NOLOCK) ON T.NAME = T2.NAME
JOIN trex.sys.sysindexes I2 WITH (NOLOCK) ON T2.OBJECT_ID = I2.ID
WHERE I.indid IN (0,1)
AND I2.indid IN (0,1)
and t.name in (
select referenced_entity_name from sys.sql_expression_dependencies as d where referencing_id = OBJECT_ID ('SyncTrexTables')
and exists (select 1 from sys.objects where name = d.referenced_entity_name))
AND i.Rows <> i2.Rows
ORDER BY i.Rows DESC,T.name


----------------------------------------------------------------------------------------------------------------------------------------------
511NJ - PRD 
-- Query need to execute at PRD

SELECT T.name TableName,i.Rows NumberOfRows,i2.Rows PRDNumberOfRows,(i2.Rows -i.Rows )
FROM [511NJ_Azure_DR].[511NJ].sys.tables T WITH (NOLOCK)
JOIN [511NJ_Azure_DR].[511NJ].sys.sysindexes I WITH (NOLOCK) ON T.OBJECT_ID = I.ID
JOIN [511NJ].sys.tables T2 WITH (NOLOCK) ON T.NAME = T2.NAME
JOIN [511NJ].sys.sysindexes I2 WITH (NOLOCK) ON T2.OBJECT_ID = I2.ID
WHERE I.indid IN (0,1)
AND I2.indid IN (0,1)
and t.name in (
select referenced_entity_name from sys.sql_expression_dependencies as d where referencing_id IN 
(select OBJECT_ID  from sys.procedures where name like 'Sync%' )
and exists (select 1 from sys.objects where name = d.referenced_entity_name))
AND i.Rows <> i2.Rows
ORDER BY i.Rows DESC,T.name

---------------------------------------------------------------------------------------------------------------------------------------------
--SYNC FROM PRD TO DR

DECLARE @p_LinkServerName varchar(50)= '192.168.212.107,14333', @SQL Varchar(max)

TRUNCATE TABLE [TREX_TraceLog].[Bottleneck_Log];
SET IDENTITY_INSERT [TREX_TraceLog].[Bottleneck_Log] ON  
Set @SQL='Insert Into [TREX_TraceLog].[Bottleneck_Log]([Id],[BottleneckID],[BottleneckdescID],[FilterId],[FacilityName],[ToFacilityName],[CreatingOrgId],[ReportingOrgId],[IsCreated],[FileId],[HighwayEventId],[StatusFlag],[BottleneckLastUpdatedDate],[TREXUpdatedAtDateTime],[TimeStamp],[TREXOrgId])
Select [Id],[BottleneckID],[BottleneckdescID],[FilterId],[FacilityName],[ToFacilityName],[CreatingOrgId],[ReportingOrgId],[IsCreated],[FileId],[HighwayEventId],[StatusFlag],[BottleneckLastUpdatedDate],[TREXUpdatedAtDateTime],[TimeStamp],[TREXOrgId]
from Openquery(['+@p_LinkServerName+'],''Select * from [Trex].[TREX_TraceLog].[Bottleneck_Log] (READPAST)   '')'
-- Print @SQL
Exec(@SQL)
SET IDENTITY_INSERT [TREX_TraceLog].[Bottleneck_Log] OFF
-------------------
---MS Project
172.30.24.226
isg
Welcome02

------------------------------------------------------------------
SET NOCOUNT ON

@Debug parameter
Continuously add a @Debug parameter to your stored procedure. This can be of BIT information sort. At the point when a 1 is passed for this parameter, print all the moderate results, variable substance using SELECT or PRINT articulations and when 0 is passed, don't print anything. This aides in fast investigation of stored procedure systems, as you don't need to include and expel these PRINT/SELECT articulations prior and then after investigating issues.

Output parameter
If any stored procedure returns a single row data, consider returning the data using OUTPUT parameters in the place of a SELECT query and Output parameter is faster than the data returned by SELECT query.

Avoid using TEXT or NTEXT datatypes in SQL for storing the large textual data

Try to avoid use of Non-correlated Scalar Sub Query

Avoid multiple Joins in a single SQL Query

https://blog.sqlauthority.com/2007/06/04/sql-server-database-coding-standards-and-guidelines-part-1/

--------------------------------------------------------------------


SELECT 'EXEC msdb.dbo.sp_update_job @job_name = ''' + name + N''', @enabled = 0;'
FROM msdb.dbo.sysjobs
where enabled=1
order by name


-------------------------------------------------------------------
http://www.silota.com/docs/recipes/sql-difference-beginning.html


=========================================================================*/

/*=========================================================================
--PG Queries
SELECT pg_reload_conf()
---------Get Size of database
select pg_database_size('navteqnew');

select t1.datname AS db_name,  
       pg_size_pretty(pg_database_size(t1.datname)) as db_size
from pg_database t1
order by pg_database_size(t1.datname) desc;

--------- Get Function script
select pg_get_functiondef(oid)
from pg_proc
where proname = '';


---------find object in function in postgre

SELECT n.nspname AS schema_name
      ,p.proname AS function_name
      ,pg_get_function_arguments(p.oid) AS args
      ,pg_get_functiondef(p.oid) AS func_def
FROM   (SELECT oid, * FROM pg_proc p WHERE NOT p.proisagg) p
JOIN   pg_namespace n ON n.oid = p.pronamespace 
LEFT   JOIN pg_depend d ON d.objid = p.oid 
                       AND d.deptype = 'e'
WHERE  n.nspname !~~ 'pg_%'
and pg_get_functiondef(p.oid) ilike '%triplinkampping%'
AND    d.objid IS NULL
Order by p.proname

-------- find function based on table/object
select 
n.nspname as function_schema, p.proname as function_name, l.lanname as function_language, 
case when l.lanname = 'internal' then p.prosrc    else pg_get_functiondef(p.oid) end as definition, 
pg_get_function_arguments(p.oid) as function_arguments, t.typname as return_type 
from pg_proc p 
left join pg_namespace n on p.pronamespace = n.oid 
left join pg_language l on p.prolang = l.oid left 
join pg_type t on t.oid = p.prorettype 
where n.nspname not in ('pg_catalog', 'information_schema') 
and prosrc ilike '%streets_all_q12019%' 
order by function_schema, function_name;
----------

SELECT schema_name, 
    pg_size_pretty(sum(table_size)::bigint) as "disk space"
    
FROM (
     SELECT pg_catalog.pg_namespace.nspname as schema_name,
         pg_relation_size(pg_catalog.pg_class.oid) as table_size
     FROM   pg_catalog.pg_class
         JOIN pg_catalog.pg_namespace 
             ON relnamespace = pg_catalog.pg_namespace.oid
) t
GROUP BY schema_name
ORDER BY schema_name
--------
select schemaname as table_schema,
       relname as table_name,
       pg_size_pretty(pg_relation_size(relid)) as data_size
from pg_catalog.pg_statio_user_tables
order by pg_relation_size(relid) desc;
--------
SELECT 'linkcalculation.linkcalc_'||TO_CHAR(now(), 'YYYYMMDD')||'_'||a.partition_name 
FROM linkcalc_partition a WHERE TO_CHAR(now(),'hh24:mi:ss') 
BETWEEN a.fromdate and a.todate;
-------- 
SELECT datetime,count(1) FROM linkcalculation.linkcalc_20210930_0416_0429
group by datetime
LIMIT 10

-------- Generate crate table script
SELECT                                          
  'CREATE TABLE ' || relname || E'\n(\n' ||
  array_to_string(
    array_agg(
      '    ' || column_name || ' ' ||  type || ' '|| not_null
    )
    , E',\n'
  ) || E'\n);\n'
from
(
  SELECT 
    c.relname, a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) as type,
    case 
      when a.attnotnull
    then 'NOT NULL' 
    else 'NULL' 
    END as not_null 
  FROM pg_class c,
   pg_attribute a,
   pg_type t
   WHERE c.relname = 'vehiclemapdata'
   AND a.attnum > 0
   AND a.attrelid = c.oid
   AND a.atttypid = t.oid
 ORDER BY a.attnum
) as tabledefinition
group by relname;
   
-----------------------------------------------------------------------
-- LOCKING
SELECT 
        waiting.locktype           AS waiting_locktype,
        waiting.relation::regclass AS waiting_table,
        waiting_stm.query          AS waiting_query,
        waiting.mode               AS waiting_mode,
        waiting.pid                AS waiting_pid,
        other.locktype             AS other_locktype,
        other.relation::regclass   AS other_table,
        other_stm.query            AS other_query,
        other.mode                 AS other_mode,
        other.pid                  AS other_pid,
        other.granted              AS other_granted
    FROM
        pg_catalog.pg_locks AS waiting
    JOIN
        pg_catalog.pg_stat_activity AS waiting_stm
        ON (
            waiting_stm.pid = waiting.pid
        )
    JOIN
        pg_catalog.pg_locks AS other
        ON (
            (
                waiting."database" = other."database"
            AND waiting.relation  = other.relation
            )
            OR waiting.transactionid = other.transactionid
        )
    JOIN
        pg_catalog.pg_stat_activity AS other_stm
        ON (
            other_stm.pid = other.pid
        )
    WHERE
        NOT waiting.granted
    AND
        waiting.pid <> other.pid;
   
-----------------------------------------------------------------------
--get list of indexes

SELECT
'drop index waze_event.'||indexname||' ;'
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'waze_event'
	and 
	indexname ilike 'idx_wazeeventcon%'
	and
	tablename ilike 'wazeeventcon_p%'
ORDER BY
    tablename,
    indexname;
	
-----------------------------------------------------------------------   
select
    'CREATE INDEX '||i.relname||' ON timed_native.'||t.relname||' USING btree ('||a.attname||');'
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where
    t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 'segmentrealtime%'
    and t.relname BETWEEN 'segmentrealtime_pullid_000478501_000479000' AND 'segmentrealtime_pullid_000610501_000611000'
order by
    t.relname,
    i.relname;
	
------------------------

select t.relname,i.relname,
    'CREATE INDEX '||i.relname||' ON timed_native.'||t.relname||' USING btree ('||a.attname||');'
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where
    t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 'vehicle_movement%'
   -- and t.relname BETWEEN 'segmentrealtime_pullid_000478501_000479000' AND 'segmentrealtime_pullid_000610501_000611000'
   and t.relname not like '%per%'
   and t.relname not like '%batch%'
   and i.relname not like '%wmvd%'
order by
    t.relname,
    i.relname;
	
---------------


COPY trex.streets_all_q12019 TO 'D:\DBA\trex_streets_all_q12019_040220212.csv' DELIMITER ',' CSV HEADER;


truncate table trex.streets_all_q12019;
COPY analysis.link_bidir FROM 'D:\DBA\analysis_link_bidir.csv' DELIMITER ',' CSV HEADER;

select count(1) from trex.streets_all_q12019

-----------

select table_name from information_schema.tables where table_name like 'om_waze_speed%'  order by table_name
	
----------------------------
https://towardsdatascience.com/local-development-set-up-of-postgresql-with-docker-c022632f13ea
-----------------------------

SELECT rows FROM sysindexes

WHERE id = OBJECT_ID('table_name') AND indid<2

-------------------------------------------------------------------------------------------------------
-- disable all constraints
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- delete data in all tables
EXEC sp_MSForEachTable "DELETE FROM ?"

-- enable all constraints
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

--some of the tables have identity columns we may want to reseed them
EXEC sp_MSforeachtable "DBCC CHECKIDENT ( '?', RESEED, 0)"


======================================================
select * from public.getrawdatatablestatus();
======================================================

select * from pg_class 
where reltablespace in(select oid from pg_tablespace where spcname not in ('pg_default','pg_global')
and spcname like '%navteq%' 
)
and relname not like '%idx_%'
order by 1 desc limit 1

select * from pg_tablespace where oid=224900659
======================================================
======================================================

--all table recordcount

SELECT      SCHEMA_NAME(A.schema_id) + '.' +
        A.Name, SUM(B.rows) AS 'RowCount'
FROM        sys.objects A
INNER JOIN sys.partitions B ON A.object_id = B.object_id
WHERE       A.type = 'U'
GROUP BY    A.schema_id, A.Name
order by 2 desc

======================================================
-- check current execution in postgre
--check current exection

select query,* from pg_Stat_activity where query like '%graph_get_linkcalc_data_db_approach%'

http://xcmdfe.xcmdata.org/TripDataAnalysis_SSO/pages/tripdatagraphdb.jsp

======================================================

-- find table name
SELECT 'DROP TABLE navteq.'|| table_name || ';' fROM information_schema.tables 
WHERE table_schema = 'navteq'
and table_name like 'navteqcon_pullid_00052%'
order by 1


-- proc/function name list
SELECT  p.proname
FROM    pg_catalog.pg_namespace n
JOIN    pg_catalog.pg_proc p
ON      p.pronamespace = n.oid
WHERE   n.nspname = 'nj_vol_data'
order by 1
======================================================
-------- Last executed queries
======================================================
SELECT  d.plan_handle ,
        d.sql_handle ,
        e.text

FROM    sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
----------------------------------------------------------------------------------------
SELECT
    deqs.last_execution_time AS [Time], 
    dest.TEXT AS [Query]
 FROM 
    sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY 
    deqs.last_execution_time DESC
-------------------------------------------------------------------------
SELECT deqs.last_execution_time AS [Time], dest.text AS [Query], dest.*
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.dbid = DB_ID('msdb')
ORDER BY deqs.last_execution_time DESC


======================================================
query to get record count of all tables from database
======================================================

CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY table_name


--------------------------------------
-- DELETE DUPLICATE RECORDS FROM EVENTCITYMAPPING

with myCity
as
(
SELECT eventid, cityid, city_name, CountyID, county, StateID, state, ROW_NUMBER() OVER(PARTITION BY EVENTID ORDER BY EVENTID) MYID FROM 
eventcitymapping
) 
DELETE from myCity where myid<>1

------------------------------------------------------------
------------------------------------------------------------

SELECT table_name, dsql2('select count(*) from '||table_name) as rownum
FROM information_schema.tables
WHERE table_type='BASE TABLE'
    AND table_schema='livescreen'
ORDER BY 2 DESC;

CREATE OR REPLACE FUNCTION dsql2(i_text text)
  RETURNS int AS
$BODY$
Declare
  v_val int;
BEGIN
  execute i_text into v_val;
  return v_val;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

------------------------------------------------------------
------------------------------------------------------------

COPY (SELECT * FROM historicalanalysis_2013.tmclinkmapping ) 
TO 
'E:\\DBA\\NPMRDS_histAnalysis_Backup_CSV\\tmclinkmapping.CSV' with csv HEADER DELIMITER '~' ;


------------------------------------------------------------
------------------------------------------------------------

BULK INSERT TransmitArchive.dbo.groupmaster FROM 'D:\XMIT_BackupFrom204\groupmaster.CSV'  
WITH ( 
FIELDTERMINATOR = '~', 
ROWTERMINATOR = '\n', 
FIRSTROW = 2 
) 

------------------------------------------------------------
------------------------------------------------------------

select 'alter table '+ t.name + ' add hhmm varchar(10)' from sys.tables t  

select 'alter table '+ t.name + ' drop column hhmm ' from sys.columns c 	
	inner join sys.tables t on c.object_id = t.object_id
	where c.name='hhmm'

------------------------------------------------------------
------------------------------------------------------------

--------------convert to simple-------------------
declare @filenm varchar(max)
declare @logtext varchar(4000), @cmd varchar(4000)

set @logtext = '"select  TripMasterID, PullId, EstimatedDT, Delta, IsHistorical, IsBelowMinDT, EstimatedDTCongestionID, Smoothed, Reconstructed, Historical, Predicted, BluetoadPercent, XmitPercent, InrixPercent, NavteqPercent, ClosurePercent, BadDataPercent, BluetoadTT, XmitTT, InrixTT, NavteqTT from SPATELTripTravelData.dbo.DrivingTimeForTrip_2016Q1 "'
set @filenm = 'DrivingTimeForTrip_2016Q1.txt'
SET @cmd = 'bcp ' + @logtext + ' queryout  "D:\DBA\'+ @filenm +'" -U sa -P njsql@dmin5 -c'
EXEC master..XP_CMDSHELL @cmd 

------------------------------------------------------------
------------------------------------------------------------

declare @filenm varchar(max)
declare @qrystr nvarchar(4000)
declare @cmd varchar(4000)

SET @QryStr = 'TRUNCATE TABLE SPATELTripTravelData.dbo.'+ @tblnm 
exec sp_executeSQL @QryStr

set @filenm = @tblnm+'.txt'
set @cmd = 'BCP SPATELTripTravelData.dbo.'+ @tblnm +' IN D:\DBA\SYNCFILES\XMLSTORE\' + @filenm +' -T -c -E'
exec master..xp_cmdshell @cmd

------------------------------------------------------------
------------------------------------------------------------
Schema tables/functions/views/triggers script
=======================

    Right-click on your database (or schema).
    Choose "backup"
    Under "Format" choose "plain"
    Under "Dump Options #1" choose "Only schema"
    Under "Objects" choose the tables you want.

Then click "backup". The output should be a plain text file with the create table statements.


--------------------------
	
To rename a column:

sp_rename 'table_name.old_column_name', 'new_column_name' , 'COLUMN';

To rename a table:

sp_rename 'old_table_name','new_table _name';


=============================================


	declare @filenm varchar(max)
	declare @logtext varchar(4000), @cmd varchar(4000)
	DECLARE @output INT

	set @logtext = '"select id, calendar_date, year, month, quarter, dow, season from SPATELTripTravelData.dbo.calendar  "'
	set @filenm = 'calendar.txt'
	SET @cmd = 'bcp ' + @logtext + ' queryout  "D:\DBA\'+ @filenm +'" -U sa -P njsql@dmin5 -c'
	EXEC master..XP_CMDSHELL @cmd 

	
CREATE TABLE calendar(
	id SERIAL,
	calendar_date timestamp without time zone NOT NULL,
	year smallint NULL,
	month SMALLint NULL,
	quarter SMALLint NULL,
	dow SMALLint NULL,
	season character varying(50)
)

COPY public.calendar FROM 'D:\DBA\calendar.TXT';

------------------

copy(select * from deweb.publishtype where  publishtypeid>=84 order by 1) TO 'D:\DBA\publishtype.csv' (DELIMITER '|');
=============================
QUERY TO CREATE CSV IN SQLSERVER


select 
'EXEC master..XP_CMDSHELL ''' + 'bcp "select linkid, epochcode, ISNULL(day0avgtt, 0) day0avgtt,ISNULL(day0avgsrc, '''''''') day0avgsrc,ISNULL(day1avgtt, 0) day1avgtt,ISNULL(day1avgsrc, '''''''') day1avgsrc,ISNULL(day2avgtt, 0) day2avgtt,ISNULL(day2avgsrc, '''''''') day2avgsrc,ISNULL(day3avgtt, 0) day3avgtt,ISNULL(day3avgsrc, '''''''') day3avgsrc,ISNULL(day4avgtt, 0) day4avgtt,ISNULL(day4avgsrc, '''''''') day4avgsrc,ISNULL(day5avgtt, 0) day5avgtt,ISNULL(day5avgsrc, '''''''') day5avgsrc,ISNULL(day6avgtt, 0) day6avgtt,ISNULL(day6avgsrc, '''''''') day6avgsrc from spatellinkhistoricaldata_2016.dbo.'+ name +'" queryout "D:\DBA_BACKUP\'+name+'.txt " -U sa -P njsql@dmin5 -c'''
 from sys.tables where name like '%fusion%'
=============================

-------------- get record count for all schema -- postgre
SELECT 
  nspname AS schemaname,relname,reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
  nspname NOT IN ('pg_catalog', 'information_schema') AND
	-- nspname='nj' and
	relname in 
	('parkrec','travdest','restrnts','parking','transhubs','autosvc','eduinsts','shopping','business','commsvc','entertn','fininsts','hospital','hamlet','misccategories')
  and relkind='r' 
ORDER BY 1,2 DESC;



------------------------------------

insert into mydbschma.mytbl (id, code)values (1,'a'),(2,'b'),(3,'c') returning ckey as storedkey,code;

------------------------------------

do
$$
declare
v_cnt int;
begin
select count(1) into v_cnt from mydbschma.mytbl;
raise notice 'v_cnt -> % ', v_cnt;
end
$$

--------------------------------------
https://www.enterprisedb.com/postgres-tutorials/how-secure-job-scheduling-dbmsscheduler-edb-postgres-advanced-server

SELECT owner, program_name, enabled FROM dba_scheduler_programs;

SELECT owner, schedule_name FROM pgagent.dba_scheduler_schedules;

select * from pgagent.pga_jobstep

select * from information_schema.tables where table_schema='pgagent'

select * from "pgagent"."pga_jobsteplog" order by jslstart desc

https://www.postgresonline.com/article_pfriendly/19.html
-------------------------------------

generate_all_partition_automation
=========================================================================*/
/*=========================================================================
--SQL SERVER SECURE
 SOX
	-- Screen shots demand.
	-- SQL Login ( Instance Level )
		-- password rotation.
		-- Active / Disabed users.
		-- sa account disable.
		-- Differential - Application Users / DBA user
		-- Read Only - SELECT grant
	-- Domain group Login / Domain Users
		-- xp_ ? 
	-- Schema/Role/Login (Grants except DML) 
		-- Read Only - SELECT grant
		
	NC - Non Compliance. 
	 -- Next audit - cover any NC.
	 
 FFIEC 
	Data Audit -  Personal details.
	-- SSN
	-- BirthDate
	-- Gender 
	-- Health details.  - HIPPA
	
	-- Google -> Personal Data Security US / GDPR.
 
 CIS 
	-- Hardening of your SQL instance.
	-- CIS benchmark 
	
 
 ---------------------------------------------------
 Encryption  -- Optional.
	-- Database Encyption [ TDE ]
	-- Column level - Encryption.
	-- Backup Level - Encryption.
	-- Storage Encryption - HDD [SysAdmin ] 
 ---------------------------------------------------
 
 
 
 
 
cd\
cd  D:\MSSQL\ciscat-full-bundle\cis-cat-full
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_241
set benchmark=D:\MSSQL\ciscat-full-bundle\cis-cat-full\benchmarks\CIS_Microsoft_SQL_Server_2019_Benchmark_v1.2.0-xccdf.xml
set profile="Level 1 - Database Engine"
set REPORT_DIR=D:\MSSQL\ciscat-full-bundle
set server_name=localhost
set param1="xccdf_org.cisecurity_value_jdbc.url=jdbc:jtds:sqlserver://%server_name%:1433/master;user=sa;password=dbadba;useNTLMv2=true"
set REPORT_NAME=ciscat_report_%server_name%                   
CIS-CAT.bat -b %BENCHMARK% -p %PROFILE% -D %param1% -a -s -r %REPORT_DIR% -rn %REPORT_NAME% -html





D:\MSSQL\ciscat-full-bundle\cis-cat-full>set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_241

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set benchmark=D:\MSSQL\ciscat-full-bundle\cis-cat-full\benchmarks\CIS_Microsoft_SQL_Server_2019_Benchmark_v1.2.0-xccdf.xml

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set profile="Level 1 - Database Engine"

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set REPORT_DIR=D:\MSSQL\ciscat-full-bundle

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set server_name=localhost

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set param1="xccdf_org.cisecurity_value_jdbc.url=jdbc:jtds:sqlserver://%server_name%:1433/master;user=sa;password=xxx ;useNTLMv2=true"

D:\MSSQL\ciscat-full-bundle\cis-cat-full>set REPORT_NAME=ciscat_report_%server_name%



-- Error 
D:\MSSQL\ciscat-full-bundle\cis-cat-full>CIS-CAT.bat -b %BENCHMARK% -p %PROFILE% -D %param1% -a -s -r %REPORT_DIR% -rn %REPORT_NAME% -html
------------------------------------------------------------------------
 .d8888b.  8888888  .d8888b.          .d8888b.         d8888 88888888888
d88P  Y88b   888   d88P  Y88b        d88P  Y88b       d88888     888
888    888   888   Y88b.             888    888      d88P888     888
888          888     Y888b.          888            d88P 888     888
888          888        Y88b.  8888  888           d88P  888     888
888    888   888          888  8888  888    888   d88P   888     888
Y88b  d88P   888   Y88b  d88P        Y88b  d88P  d8888888888     888
 Y8888PY   8888888   Y8888PY           Y8888PY  d88P     888     888
------------------------------------------------------------------------
               This is CIS-CAT-Pro Assessor version 3.0.75
                    Built on: 07/27/2021 09:48 AM
------------------------------------------------------------------------
An unrecognized Command-Line option -html was entered. Use -h to list all available Command-Line options.
CIS-CAT will now exit -- Error Code: ERR-CLI-0001






D:\MSSQL\ciscat-full-bundle\cis-cat-full>CIS-CAT.bat -b %BENCHMARK% -p %PROFILE% -D %param1% -a -s -r %REPORT_DIR% -rn %REPORT_NAME% -csv
------------------------------------------------------------------------
 .d8888b.  8888888  .d8888b.          .d8888b.         d8888 88888888888
d88P  Y88b   888   d88P  Y88b        d88P  Y88b       d88888     888
888    888   888   Y88b.             888    888      d88P888     888
888          888     Y888b.          888            d88P 888     888
888          888        Y88b.  8888  888           d88P  888     888
888    888   888          888  8888  888    888   d88P   888     888
Y88b  d88P   888   Y88b  d88P        Y88b  d88P  d8888888888     888
 Y8888PY   8888888   Y8888PY           Y8888PY  d88P     888     888
------------------------------------------------------------------------
               This is CIS-CAT-Pro Assessor version 3.0.75
                    Built on: 07/27/2021 09:48 AM
------------------------------------------------------------------------
Loading Benchmark...
Validating Benchmark...

******************************************************

        Loading Checklist Components...                          <1 second Done
1/42    Ensure Latest SQL Server C...ity Updates are Installed   <1 second  N/C
2/42    Ensure Single-Function Member Servers are Used           <1 second  N/C
3/42    Ensure Unnecessary SQL Ser...ols are set to 'Disabled'   <1 second  N/C
4/42    Ensure SQL Server is confi...to use non-standard ports   <1 second Fail
5/42    Ensure 'Hide Instance' opt...tion SQL Server instances   <1 second Fail
6/42    Ensure the 'sa' Login Account is set to 'Disabled'       <1 second Fail
7/42    Ensure the 'sa' Login Account has been renamed           <1 second Fail
8/42    Ensure 'AUTO_CLOSE' is set...F' on contained databases   <1 second Pass
9/42    Ensure no an exists with the name 'sa'                <1 second Fail
10/42   Ensure 'clr strict securit...tion Option is set to '1'   <1 second Pass
11/42   Ensure 'Ad Hoc Distributed...tion Option is set to '0'   <1 second Pass
12/42   Ensure 'CLR Enabled' Serve...tion Option is set to '0'   <1 second Pass
13/42   Ensure 'Cross DB Ownership...tion Option is set to '0'   <1 second Pass
14/42   Ensure 'Database Mail XPs'...tion Option is set to '0'   <1 second Pass
15/42   Ensure 'Ole Automation Pro...tion Option is set to '0'   <1 second Pass
16/42   Ensure 'Remote Access' Ser...tion Option is set to '0'   <1 second Fail
17/42   Ensure 'Remote Admin Conne...tion Option is set to '0'   <1 second Pass
18/42   Ensure 'Scan For Startup P...tion Option is set to '0'   <1 second Pass
19/42   Ensure 'Trustworthy' Database Property is set to 'Off'   <1 second Pass
20/42   Ensure Windows local groups are not SQL Logins           <1 second Pass
21/42   Ensure the public role in ...cess to SQL Agent proxies   <1 second Pass
22/42   Ensure 'Server Authenticat...dows Authentication Mode'   <1 second Fail
23/42   Ensure CONNECT permissions...e master, msdb and tempdb   <1 second Pass
24/42   Ensure 'Orphaned Users' ar...From SQL Server Databases   <1 second Fail
25/42   Ensure SQL Authentication ...ed in contained databases   <1 second Pass
26/42   Ensure the SQL Server?s MS...t is Not an Administrator   <1 second  N/C
27/42   Ensure the SQL Server?s SQ...t is Not an Administrator   <1 second  N/C
28/42   Ensure the SQL Server?s Fu...t is Not an Administrator   <1 second  N/C
29/42   Ensure only the default pe...to the public server role   <1 second Pass
30/42   Ensure Windows BUILTIN groups are not SQL Logins         <1 second Pass
31/42   Ensure 'MUST_CHANGE' Optio... SQL Authenticated Logins   <1 second  N/C
32/42   Ensure 'CHECK_EXPIRATION' ... Within the Sysadmin Role   <1 second Fail
33/42   Ensure 'CHECK_POLICY' Opti... SQL Authenticated Logins   <1 second Pass
34/42   Ensure 'Maximum number of ...ter than or equal to '12'   <1 second Fail
35/42   Ensure 'Default Trace Enab...tion Option is set to '1'   <1 second Pass
36/42   Ensure 'Login Auditing' is set to 'failed logins'        <1 second Pass
37/42   Ensure 'SQL Server Audit' ...' and 'successful logins'   <1 second Fail
38/42   Ensure Database and Applic...n User Input is Sanitized   <1 second  N/C
39/42   Ensure 'CLR Assembly Permi...S' for All CLR Assemblies   <1 second Fail
40/42   Ensure 'Symmetric Key encr...r in non-system databases   <1 second Pass
41/42   Ensure Asymmetric Key Size...' in non-system databases   <1 second Pass
42/42   Ensure 'SQL Server Browser...' is configured correctly   <1 second  N/C
        Generating Reports...
HTML Report written to: D:\MSSQL\ciscat-full-bundle\ciscat_report_localhost.html

CSV Report written to: D:\MSSQL\ciscat-full-bundle\ciscat_report_localhost.csv
 03 seconds Done
Total Evaluation Time: 8 seconds
D:\MSSQL\ciscat-full-bundle\cis-cat-full>

/*=========================================================================
http://www.silota.com/docs/recipes/sql-top-n-aggregate-rest-other.html

SELECT
      [OrderDate],
	  dateadd(YEAR,		datediff(year,		0, orderdate), 0) 'YEAR_START_DATE',
	  dateadd(QUARTER,	datediff(QUARTER,	0, orderdate), 0) 'QUARTER_START_DATE',
	  dateadd(MONTH,	datediff(MONTH,		0, orderdate), 0) 'MONTH_START_DATE',
	  dateadd(WEEK,		datediff(WEEK,		0, orderdate), 0) 'WEEK_START_DATE',
	  dateadd(DAY,		datediff(DAY,		0, orderdate), 0) 'DAY_START_DATETIME',
	  dateadd(HOUR,		datediff(HOUR,		0, orderdate), 0),
	  date_trunc('month',orderdate),
  FROM [adv_1225].[SalesLT].[SalesOrderHeader]
ORDER BY 1

----------------------------------

select OrderDate, total,
FIRST_VALUE(total) over(partition by year(orderdate),month(orderdate) order by orderdate)
from
(
select OrderDate,sum(subtotal) total from 
[SalesLT].[SalesOrderHeader]
group by OrderDate
) sales
order by OrderDate

----------------------------------

select OrderDate, total,
sum(total) over(partition by year(orderdate),month(orderdate) order by orderdate)
from
(
select OrderDate,sum(subtotal) total from 
[SalesLT].[SalesOrderHeader]
group by OrderDate
) sales
order by OrderDate

-----------------------------------
;WITH TOP10_ONLY AS
 (
	SELECT TOP 10 orderdate,FIRST_SalesOrderID
	FROM
	(
		 select DISTINCT orderdate,FIRST_SalesOrderID
		 from
		 (
		 select  dateadd(MONTH,	datediff(MONTH,		0, orderdate), 0) orderdate,
		  FIRST_VALUE(SalesOrderID) OVER(PARTITION BY dateadd(MONTH,	datediff(MONTH,		0, orderdate), 0) ORDER BY SalesOrderID) AS FIRST_SalesOrderID 
		 FROM [adv_1225].[SalesLT].[SalesOrderHeader]
		 ) y
	 ) Z
	 ORDER BY orderdate
)
SELECT * FROM TOP10_ONLY
UNION ALL
select DISTINCT orderdate,FIRST_SalesOrderID
		 from
		 (
		 select  dateadd(MONTH,	datediff(MONTH,		0, orderdate), 0) orderdate,
		  FIRST_VALUE(SalesOrderID) OVER(PARTITION BY dateadd(MONTH,	datediff(MONTH,		0, orderdate), 0) ORDER BY SalesOrderID) AS FIRST_SalesOrderID 
		 FROM [adv_1225].[SalesLT].[SalesOrderHeader]
		 ) y
		WHERE NOT EXISTS (SELECT 1 FROM  TOP10_ONLY T WHERE T.orderdate=Y.orderdate AND T.FIRST_SalesOrderID=Y.FIRST_SalesOrderID)
		
=========================================================================*/

/*=========================================================================

=========================================================================*/


/*=========================================================================

=========================================================================*/


/*=========================================================================

=========================================================================*/


RETURN 0

end