create function fn_func1(@id int)
returns int
as
begin
	declare @res int
	set @res = @id * 5
	return @res;
end