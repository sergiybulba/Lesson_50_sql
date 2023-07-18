
--==========================================================================================
--1. �������� ��������� ���������, ��� ������ ������� ������ ���� �� ����� � ���� � �� ����� � ������

alter procedure Task_One as 
begin

select [Group].name as Unit_name, count(S_Cards.id_book) as Count_book
from [Group] inner join Student on [Group].id = Student.id_group
			 inner join S_Cards on Student.id = S_Cards.id_student
group by [Group].name
union all
select Department.name, count(T_Cards.id_book) 
from Department inner join Teacher on Department.id = Teacher.id_department
			 inner join T_Cards on Teacher.id = T_Cards.id_teacher
group by Department.name

end;

--exec Task_One;

--==========================================================================================
--2. �������� ��������� ���������, ��� ������ ������ ����, � ��� ������� ������ �������.
--   ������: ��'� ������, ������� ������, ��������, ��������. ��� ���� ������ ������� ���� 
--   ������������ �� ������ ����, ��������� � 5-�� ��������, � ��������, ��������� � 6-�� �������� (sp_executesql)

alter procedure Task_Two 
	@author_lname nvarchar(50) = '', @author_fname nvarchar(50) = '',
	@theme_ nvarchar(50) = '', @category_ nvarchar(50) = '',
	@column int = 1, @sort nvarchar(10) = 'asc' as
begin
	if @column < 1 or @column > 5				-- �������� ������ ��������� ��� ����������
	begin
		print 'Column number is wrong! Try again.';
		return
	end

	if @sort != 'asc' and @sort != 'desc'				-- �������� ����������� ����� �������� ���������� 
	begin
		print 'Wrong sort direction! Try again.';
		return
	end

declare @query nvarchar(500) = N'		
select Book.name as Book_title, Author.last_name as Author_surname, Author.first_name as Author_name,
	   Theme.name as Book_theme, Category.name as Book_category
from Book inner join Author on Author.id = Book.id_author
		  inner join Theme on Theme.id = Book.id_theme
		  inner join Category on Category.id = Book.id_category
where Author.last_name like ''%' + @author_lname + '%'' and Author.first_name like ''%' + @author_fname + '%'' and
	  Theme.name like ''%' + @theme_ + '%'' and Category.name like ''%' + @category_ + '%''
order by ' + cast(@column as nvarchar(5)) + ' ' + @sort ;

--print @query;
exec sp_executesql @query;
end;


-- exec Task_Two @author_fname = '�����';
-- exec Task_Two @author_lname = '���';
-- exec Task_Two @theme_ = '������';
-- exec Task_Two @category_ = 'basic';
-- exec Task_Two @column = 5;
-- exec Task_Two @sort = 'asc';
-- exec Task_Two '���', '���', '��', 'sic';


/*select Book.name as Book_title, Author.last_name as Author_surname, Author.first_name as Author_name,  -- ��� ������ ������� � ��������
	   Theme.name as Book_theme, Category.name as Book_category
from Book inner join Author on Author.id = Book.id_author
		  inner join Theme on Theme.id = Book.id_theme
		  inner join Category on Category.id = Book.id_category
where Author.last_name = '�������������' and Author.first_name = '�������' and
	  Theme.name = '����������������' and Category.name = 'Delphi' 
order by 1 asc;*/

--==========================================================================================
-- 3. �������� ��������� ���������, ��� ������ ������ ����������, � ������� ������� ������ � ��� ����

alter procedure Task_Three as 
begin
select LibrarianTable.Librarian_name, sum(LibrarianTable.Count_books) as Books
from (	select Librarian.last_name + ' ' + Librarian.first_name as Librarian_name,
			   count(S_Cards.id_book) as Count_books
		from Librarian inner join S_Cards on Librarian.id = S_Cards.id_librarian
		group by Librarian.last_name, Librarian.first_name	
		union all
		select Librarian.last_name + ' ' + Librarian.first_name as Librarian_name,
			   count(T_Cards.id_book) as Count_books
		from Librarian inner join T_Cards on Librarian.id = T_Cards.id_librarian
		group by Librarian.last_name, Librarian.first_name) as LibrarianTable
group by LibrarianTable.Librarian_name

end;

--exec Task_Three;

--==========================================================================================
-- 4. �������� ��������� ���������, ��� ������ ��'� �� ������� ��������, ���� ���� �������� ������� ����

alter procedure Task_Four as 
begin

select TempTable.Student_name 
from(	select Student.id, Student.last_name + ' ' + Student.first_name as Student_name,
			   count(S_Cards.id_book) as Count_books
		from Student inner join S_Cards on Student.id = S_Cards.id_student
		group by Student.id, Student.last_name, Student.first_name) as TempTable
where TempTable.Count_books = (select max(TempTable2.Count_books)  
							   from (select Student.id, Student.last_name + ' ' + Student.first_name as Student_name,
									 count(S_Cards.id_book) as Count_books
									 from Student inner join S_Cards on Student.id = S_Cards.id_student
									 group by Student.id, Student.last_name, Student.first_name) as TempTable2) 
end;

--exec Task_Four;

--  ���� �� ������ ������ where?

-- where TempTable.Count_books = (select max(TempTable.Count_books) from TempTable) ;

--==========================================================================================
-- 5. �������� ��������� ���������, ��� ������� �������� ������� ������ � �������� ���� � ����������� � ����������

alter procedure Task_Five as
begin

select sum(LibrarianTable.Count_books) as Books
from (select count (*) as Count_books
	  from S_Cards 
	  union all
	  select count (*) as Count_books
	  from T_Cards) as LibrarianTable
end;

--declare @Count_books int;

--exec @Count_books = Task_Five;
--print @Count_books;

--==========================================================================================

 