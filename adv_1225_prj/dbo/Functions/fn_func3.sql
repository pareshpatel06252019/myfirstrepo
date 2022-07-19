
create function fn_func3(@id int)
returns @t table(id int, name varchar(255))
as
begin
	insert into @t (id, name)
		select customerid, firstname from [SalesLT].[Customer] c where CustomerID=@id

	insert into @t(id,name)
		select ProductID, Name from [SalesLT].[Product] where ProductID=@id

	return;
end
