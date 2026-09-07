           --Phase 1: Blocks & Variables
--1&2

DO $$
 declare
   v_members_email members.email%type;
   v_member_id members.member_id%type;
   v_plain int;
 begin
    select email into v_members_email 
    from members where member_id=(
       select  min (member_id) from members);
   raise notice 'Email : %',v_members_email;

     select count(*) into v_plain from booking
      where member_id=v_member_id;
        raise notice 'Total booking :%',v_plain;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     RAISE NOTICE 'No members found.';
  end ;
  $$ ;
--------------------------------------------
--3
--A SQL SELECT is only used to retrieve data. A PL/pgSQL block lets us store values in variables
--execute multiple statements, handle exceptions, and reuse procedural logic instead of writing separate SQL queries each time.
-----------------------------------------------------------

            --Phase 2: Control Flow & Loops
--4
do $$
   declare v_member_status members.member_status% type;
 begin
    if
      v_member_status = 'active' then 
      raise notice 'Member status is active : %' , v_member_status;
  elsif
     v_member_status = 'inactive' then
      raise notice 'Member status is inactive : %' , v_member_status;
	else
	   raise notice 'Member status is not defined';
  end if;
end;
$$;
--------------------------------------------------
--5
do $$
  declare r record;
    begin
      for r in 
         select c.category_name,cl.class_name 
         from categories c inner join class cl
          on c.category_id=cl.category_id where c.category_id=2
      loop
        raise notice '%', r;
      end loop;
  end;
$$;
---------------------------------------------
--6
do $$
declare
    session_cursor cursor for
        select session_id
        from session
        where trainer_id = 3;

    v_session_id session.session_id%type;
    counter int := 0;

  begin
    open session_cursor;

    fetch session_cursor into v_session_id;

   while found loop
        counter := counter + 1;

        fetch session_cursor into v_session_id;
    end loop;

    close session_cursor;

    raise notice 'Total sessions: %', counter;
end;
$$;
------------------------------------------------------
                  --Phase 3: Functions

--7
create or replace function get_member_full_name (p_member_id int)
  returns text as $$
    begin 
      return(
      select name from members 
      where member_id= p_member_id
       );
   end;
$$ language plpgsql;

select get_member_full_name(1);
---------------------------------------
--8
create or replace function get_average_rating_by_trainer(p_trainer_id int)
  returns numeric as $$
    begin
      return(
      select avg(b.rating) from booking b
      join session s on b.session_id = s.session_id
      where s.trainer_id = p_trainer_id
      );
   end;
$$ language plpgsql;

select get_average_rating_by_trainer(4);
-----------------------------------------------
--9
create or replace function calculate_loyalty_points(p_member_id int)
 returns int as $$
  begin
    return(
    select count(*)
    from booking where member_id=p_member_id and rating =5
     );
  end;
$$ language plpgsql;

select calculate_loyalty_points(2)
---------------------------------------------------------------
                     --Phase 4: Procedures
					 
--10
create or replace procedure add_new_booking(p_member_id INT, p_session_id INT)
language plpgsql  as $$
begin
insert into booking(session_id,member_id,booking_date)
values(p_session_id,p_member_id,now());

raise notice 'session id:%,member id:%',p_session_id,p_member_id;
end;
$$;

call add_new_booking(22,1);
---------------------------------
--11
create or replace procedure update_member_status(p_member_id INT, p_new_status VARCHAR)
language plpgsql as $$
begin
update members set  member_status=p_new_status
where member_id=p_member_id;

raise notice 'member id :%,status:%', p_member_id,p_new_status;
end;
$$;

call update_member_status(1,'inactive');
-----------------------------------------------------------------------
             --Phase 5: Error Handling & RECORD Variables

--12
do $$
  declare rec record;
  begin 
     for rec in
     select session_date,room, trainer_id 
	 from session where class_id=1
  loop
     raise notice 'Date: %, Room: %, Trainer ID: %',
      rec.session_date, rec.room, rec.trainer_id;
  end loop;
 end;
$$;
------------------------------------------------
--13
create or replace procedure add_new_booking(p_member_id INT, p_session_id INT)
  language plpgsql  as $$
 begin
    insert into booking(session_id,member_id,booking_date)
    values(p_session_id,p_member_id,now());
    raise notice 'session id:%,member id:%',p_session_id,p_member_id;
	
  exception 
    when unique_violation THEN
         RAISE NOTICE 'Member % has already booked session %.',p_member_id,p_session_id;
    when foreign_key_violation THEN
         RAISE NOTICE 'Invalid member ID or session ID';
    when OTHERS THEN
         RAISE NOTICE 'Unexpected error: %', SQLERRM;
  end;
$$;

call add_new_booking(999,1);
----------------------------------------------------------------
             --Phase 6: Practical Applications of PL/pgSQL

--14
create or replace function get_member_by_email(v_email text)
   returns members as $$
 declare  rec members%ROWTYPE;
  begin 
    select * into rec from members where email=v_email;
    IF NOT FOUND THEN
    RAISE NOTICE 'Member not found.';
	return null;
    END IF;
 return rec;
  end;
$$ language plpgsql;

select get_member_by_email('hala.saeed@gmail.com');
------------------------------------------------------
--15
create or replace function is_valid_rating (v_rating int)
 returns BOOLEAN as $$
  begin
    if v_rating between 1 and 5 then 
      return true;
   else
      return false;
   end if;
end;
$$ language plpgsql;

select is_valid_rating(7);
-----------------------------------------------
--16
create or replace procedure apply_loyalty_bonus()
language plpgsql as $$
  declare rec record;
 begin
  for rec in 
    select m.member_id from members m join booking b
    on m.member_id = b.member_id
    group by m.member_id having count(*)>3
  loop
      if rec.loyalty_points < 5 then
      update members set loyalty_points = loyalty_points + 1
      where member_id = rec.member_id;
      end if;
    raise notice 'Loyalty processed for Member ID %', rec.member_id;
   end loop;
 end;
$$;

call apply_loyalty_bonus();
--------------------------------------------------
--17
create or replace function get_available_seats (v_session_id int)
  returns int as $$ 
  declare 
    room_capecity constant int :=15;
    booked_seats int ; 
  begin
   select count(*) into booked_seats from booking
    where session_id= v_session_id;
    return room_capecity - booked_seats;
  end;
$$ language plpgsql;

SELECT get_available_seats(22);
------------------------------------------------------------------------

                 --Part B — Advanced PL/pgSQL
--Phase 7: Named Exception Handling

--18
create or replace procedure add_new_trainer (p_email text)
  language plpgsql as $$
  begin
    insert into trainers (trainer_name,email) values ('test',p_email);
    raise notice 'Trainer added successfully';
 exception
   when unique_violation then
   raise notice 'This email is already exists : %', p_email;
 end;
$$;

call add_new_trainer('aya.karaf@fitzone.com');
-------------------------------------------------------------
--19
create or replace procedure insert_booking (p_session_id int)
  language plpgsql as $$
  begin
    insert into booking (session_id) values (p_session_id);
    raise notice 'session added successfully';
 exception
   when foreign_key_violation then
   raise notice 'This session does not exist: %', p_session_id;
 end;
$$;

call insert_booking(999);
----------------------------------------------------------------------
                  --Phase 8: Additional PL/pgSQL Practice
--20
do $$
declare 
total_number int;
begin
select count (*) into total_number from members ;
raise notice 'The total number of members :%', total_number;
end;
$$;
-----------------------------------------------------------------------
                --Phase 9: Triggers — Validation & Business Rules
--21
 --A
create or replace function validation_trigger()
returns trigger as $$
begin
if
NEW.rating < 1 or NEW.rating > 5 then
RAISE EXCEPTION
'rating (%) should be between 1 and 5 .', NEW.rating ;
end if;
return NEW;
end;
$$ language plpgsql;

create trigger validation_trigger
before insert on booking 
for each row execute function validation_trigger();

INSERT INTO booking (booking_date, rating)
VALUES ('2026-08-03', 7);
---------------------------------
 --B
create or replace function business_rule_trigger()
returns trigger as $$
begin
if OLD.rating is not null
   and NEW.rating <> OLD.rating then
    raise exception 'You cannot update the rating twice.';
end if;

return NEW;
end;
$$ language plpgsql;

create trigger business_rule_trigger
before update on booking 
for each row execute function business_rule_trigger();

update booking set rating = 2 where booking_id = 22;
----------------------------------------------------------------
                --Phase 10: Audit Logging

create table booking_audit_log (
    audit_id serial primary key,
    operation_type varchar,
    operation_time TIMESTAMP DEFAULT now(),
    booking_id int,
    old_rating int,
    new_rating int, 
    old_comment varchar,
    new_comment varchar
 );

create or replace function audit_booking()
  returns trigger as $$ 
   begin
    if TG_OP = 'INSERT' then 
          insert into booking_audit_log
	     (new_rating, new_comment, operation_type,booking_id)
         values (NEW.rating, NEW.comment,'INSERT',NEW.booking_id);
    elsif TG_OP= 'UPDATE' then 
           insert into booking_audit_log(new_rating,old_rating, new_comment,
		   old_comment, operation_type,booking_id)
         values (NEW.rating,OLD.rating, NEW.comment,OLD.comment,'UPDATE',NEW.booking_id);
    elsif TG_OP= 'DELETE' then 
          return OLD;
     else
         return NEW;
   end if;
 end;
$$ language plpgsql;

create trigger booking_audit_log
after insert or update or delete on booking
for each row execute function audit_booking();

insert into booking
( member_id, session_id, rating, comment)
values
( 2, 24, 5, 'Great session');

update booking
set rating = 5, comment = 'Good session'
where booking_id =28;

delete from booking
where booking_id = 23;

select * from booking_audit_log;
--------------------------------------------------------------

              --Phase 11: Business Rules in the Database

--23
create or replace function update_booking_table()
  returns trigger as $$
   begin
     if OLD.rating is null and NEW.rating is not null then
        update members
        set loyalty_points = loyalty_points + 1
        where member_id = NEW.member_id
        and loyalty_points < 5;

    end if;
   return NEW;
 end;
$$ language plpgsql;

create trigger update_booking_table
after update on booking
for each row execute function update_booking_table();

UPDATE booking
SET rating = 1
WHERE member_id = 1;







































  