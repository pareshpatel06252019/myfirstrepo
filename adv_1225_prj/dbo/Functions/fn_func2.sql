;create function fn_func2(@id int)
returns table
as
	return
	select customerid, firstname from 
	[SalesLT].[Customer]
	where 
	customerid = @id
