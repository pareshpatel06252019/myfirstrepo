create procedure psx
(@o int output)
as
begin
	begin try
		select 1/0;
	end try
	begin catch
		set @o=1
	end catch
end