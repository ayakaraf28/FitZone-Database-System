--Phase1 part2

--Initially, all gym data was stored in one large unnormalized table combining members,
--sessions, classes, trainers, and ratings. This caused data duplication because the same
--information was repeated in multiple records. It also created update anomalies,
--as changing information required modifying many rows and could lead to inconsistent data.
--Deletion anomalies could occur because removing a record might accidentally remove important
--related information. Additionally, storing multiple ratings in one column violated the first 
--normal form because each field should contain a single value. Normalization solves these issues 
--by separating the data into related tables.
----------------------------------------------------------

--Phase2 create database(DDL)

CREATE TABLE members(
member_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
name VARCHAR(30) NOT NULL,
email VARCHAR(30) NOT NULL UNIQUE,
phone_number INT,country VARCHAR(20),
city VARCHAR(20),street VARCHAR(20),
join_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
member_status VARCHAR(20) CHECK (member_status IN ('active' ,'inactive'))DEFAULT 'active',
);

CREATE TABLE trainers(
trainer_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
trainer_name VARCHAR(30) NOT NULL,
email VARCHAR(30) NOT NULL UNIQUE,
phone_number INT,
specilization VARCHAR(50),
years_of_experience INT ,
mentor_id INT CONSTRAINT fk_trainer_mentor REFERENCES trainers(trainer_id));


CREATE TABLE categories(
category_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
category_name VARCHAR(20)
);

CREATE TABLE class(
class_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
class_name VARCHAR(20),
category_id INT REFERENCES categories(category_id)
);

CREATE TABLE session(
session_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
date TIMESTAMPTZ DEFAULT NOW(),
start_time DATE, end_time DATE,
room INT,
trainer_id INT REFERENCES trainers(trainer_id),
class_id INT REFERENCES class(class_id)
);
alter table session
alter column room type varchar(10);

CREATE TABLE booking(
booking_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
booking_date TIMESTAMPTZ DEFAULT NOW(),
rating INT CHECK (rating BETWEEN 1 AND 5),
comment VARCHAR(40),
session_id INT REFERENCES session(session_id),
member_id INT REFERENCES members(member_id)
);

--Phase2-1
ALTER TABLE members
ADD COLUMN loyalty_points INT DEFAULT 0;

--Phase2-2
ALTER TABLE members
ALTER COLUMN phone_number TYPE VARCHAR(20);

--Phase2-3
TRUNCATE TABLE booking
RESTART IDENTITY CASCADE;
---------------------------------------------------



--Phase 3 insert data 

INSERT INTO categories(category_name) VALUES ('Yoga'),('Cardio'),('Boxing'),('Zumba'),('Pilates');
----------------------------------------------------------
INSERT INTO trainers (trainer_name,email,phone_number,specilization,years_of_experience,mentor_id)
VALUES ('Aya Karaf', 'aya.karaf@fitzone.com', 790222222, 'Yoga', 1, 2),
('Omar Haddad', 'omar.haddad@fitzone.com', 790333333, 'Boxing', 5,null),
('Lina Saleh', 'lina.saleh@fitzone.com', 790444444, 'Zumba', 2, 2),
('Yousef Ali', 'yousef.ali@fitzone.com', 790555555, 'Cardio', 3, 1),
('Rana Hasan', 'rana.hasan@fitzone.com', 790666666, 'Pilates', 4,null),
('Bayan Awni', 'bayan.awni@fitzone.com', 790653776, 'Pilates', 6,null);
------------------------------------------------------------
INSERT INTO class (class_name, category_id)
VALUES
('Morning Yoga', 1),
('Power Yoga', 1),
('HIIT Cardio', 2),
('Cardio Blast', 2),
('Endurance Training', 2),
('Beginner Boxing', 3),
('Advanced Boxing', 3),
('Zumba Fitness', 4),
('Latin Zumba', 4),
('Dance Workout', 4);
------------------------------------------------------------
INSERT INTO session
(date, start_time, end_time, room, trainer_id, class_id)
VALUES

('2026-08-01','09:00','10:00','Room A',1,1),
('2026-08-03','09:00','10:00','Room A',2,1),
('2026-08-01','11:00','12:00','Room B',2,2),
('2026-08-04','11:00','12:00','Room B',1,2),
('2026-08-02','08:00','09:00','Room C',5,3),
('2026-08-05','08:00','09:00','Room C',5,3),
('2026-08-02','17:00','18:00','Room C',5,4),
('2026-08-06','17:00','18:00','Room C',4,4),
('2026-08-03','18:00','19:00','Room D',4,5),
('2026-08-07','18:00','19:00','Room D',5,5),
('2026-08-01','14:00','15:00','Room E',3,6),
('2026-08-03','14:00','15:00','Room E',3,6),
('2026-08-02','15:00','16:00','Room E',3,7),
('2026-08-05','15:00','16:00','Room E',7,7),
('2026-08-01','19:00','20:00','Room F',4,8),
('2026-08-04','19:00','20:00','Room F',4,8),
('2026-08-02','19:00','20:00','Room F',7,9),
('2026-08-06','19:00','20:00','Room F',7,9),
('2026-08-03','20:00','21:00','Room G',4,10),
('2026-08-07','20:00','21:00','Room G',2,10);
-----------------------------------------------------------------------------------
INSERT INTO members
(name, email, phone_number, country, city, street, loyalty_points)
VALUES
('Mohammed Salem', 'mohammed.salem@gmail.com', 790111111, 'Jordan', 'Amman', 'Rainbow St', 120),
('Noor Alshami', 'noor.alshami@gmail.com', 790111112, 'Jordan', 'Zarqa', 'King Abdullah St', 80),
('Kareem Hamdan', 'kareem.hamdan@gmail.com', 790111113, 'Jordan', 'Irbid', 'University St', 150),
('Hala Saeed', 'hala.saeed@gmail.com', 790111114, 'Jordan', 'Salt', 'Main St', 60),
('Tareq Mahmoud', 'tareq.mahmoud@gmail.com', 790111115, 'Jordan', 'Madaba', 'Al Hussein St', 100),
('Ruba Khalaf', 'ruba.khalaf@gmail.com', 790111116, 'Jordan', 'Jerash', 'Roman St', 90),
('Zaid Qasim', 'zaid.qasim@gmail.com', 790111117, 'Jordan', 'Aqaba', 'Beach Road', 140),
('Maya Fares', 'maya.fares@gmail.com', 790111118, 'Jordan', 'Ajloun', 'Castle St', 70),
('Fadi Nabil', 'fadi.nabil@gmail.com', 790111119, 'Jordan', 'Karak', 'Al Quds St', 110),
('Reem Samer', 'reem.samer@gmail.com', 790111120, 'Jordan', 'Mafraq', 'Prince Hassan St', 50);
--------------------------------------------------------------------------------------------
INSERT INTO booking
(booking_date, rating, comment, session_id, member_id)
VALUES
('2026-08-01',5,'Excellent',21,1),
('2026-08-02',4,'Very Good',22,1),

('2026-08-01',5,'Amazing',23,2),
('2026-08-03',3,'Good',24,2),

('2026-08-02',5,'Loved it',25,3),
('2026-08-04',4,'Nice trainer',26,3),

('2026-08-02',2,'Average',27,4),
('2026-08-05',5,'Excellent',28,4),

('2026-08-03',4,'Good class',29,5),
('2026-08-06',5,'Perfect',30,5),

('2026-08-03',3,'Okay',31,6),
('2026-08-05',4,'Enjoyed it',32,6),

('2026-08-04',5,'Fantastic',33,7),
('2026-08-06',5,'Highly recommended',34,8),
('2026-08-07',4,'Great',35,9),

('2026-08-07',NULL,NULL,36,1),
('2026-08-08',NULL,NULL,37,2),
('2026-08-08',NULL,NULL,38,3),
('2026-08-09',NULL,NULL,39,4),
('2026-08-09',NULL,NULL,40,5);

---------------------------------------------------------------------------

--Phase 5 FUNDAMENRAL & DML

3) select name AS full_name, email from members ORDER BY join_date ASC;

4) select DISTINCT city from members;

5) select * from members WHERE member_status = 'active';

6) update trainerS SET years_of_experience=2 WHERE trainer_id=1 RETURNING *;

7) delete from booking WHERE booking_id=21 RETURNING *;
----------------------------------------------------------------------

--Phase 6 security & DCL

-- Create a read-only user:
create user readonly_role with password 'user123';
create role readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
grant readonly TO readonly_role;

-- Create an operations manager user
create user manager_useer with password 'manager123';
grant select,insert,update on all tables in schema public to manager_useer;

-- Revoke update permission from manager_user
revoke update on all tables in schema public from manager_useer;

--A database administrator (DBA) manages user access to the database by granting and revoking permissions when needed. For example, a new employee in the reporting department may be granted read-only access to view data without making changes. If the employee changes roles or leaves the company, the DBA revokes those permissions to protect the database from unauthorized access. This helps keep the data secure and ensures that users only have the permissions required for their jobs.

--------------------------------------------------------
select * from categories;

--Phase 7- JOINS 

8)SELECT 
    session.session_id,
    class.class_name,
    trainers.trainer_name
  FROM session INNER JOIN class
     ON session.class_id = class.class_id
  INNER JOIN trainers
    ON session.trainer_id = trainers.trainer_id;
   --------------------------------------------------
9) select members.name,COUNT( booking.booking_id) AS booking_count from members left JOIN booking
  ON booking.member_id=members.member_id GROUP BY members.name;
------------------------------------------------
10) SELECT session.session_id, booking.booking_id
    FROM session LEFT JOIN booking
    ON booking.session_id = session.session_id;
  -------------------------------------
11) select categories.category_name, class.class_name
    from categories full join class on 
	categories.category_id=class.category_id;
   --------------------------------------------
12) select t.trainer_name AS trainer, m.trainer_name AS mentor
    from trainers t left join trainers m
	on m.trainer_id= t.mentor_id;
	

--Phase 7: Aggregation , Grouping & Subqueries

13) select members.name,COUNT( booking.booking_id) AS booking_count 
    from members inner JOIN booking
    ON booking.member_id=members.member_id GROUP BY members.name;
 
--------------------------
14) SELECT trainers.trainer_name,
    AVG(booking.rating) AS average_rating FROM booking
    JOIN session ON booking.session_id = session.session_id
    JOIN trainers ON session.trainer_id = trainers.trainer_id
    GROUP BY trainers.trainer_name;
-------------------------------
15) SELECT class.class_name,
    MIN(booking.rating) AS lowest_rating,
    MAX(booking.rating) AS highest_rating
  FROM booking JOIN session ON booking.session_id = session.session_id
JOIN class ON session.class_id = class.class_id
GROUP BY class.class_name;
-----------------------------
16) select city,sum(loyalty_points) from members group by city;
------------------------------
17) SELECT categories.category_name,
    COUNT(class.class_id) AS class_count
   FROM categories JOIN class ON class.category_id = categories.category_id
   GROUP BY categories.category_name HAVING COUNT(class.class_id) > 2;
---------------------------------
18) SELECT * FROM members WHERE member_id NOT IN (
    SELECT member_id FROM booking);
------------------------------------
19) SELECT t.trainer_name, AVG(b.rating) AS trainer_avg_rating
     FROM trainers t JOIN session s ON t.trainer_id = s.trainer_id
    JOIN booking b ON s.session_id = b.session_id
    GROUP BY t.trainer_name HAVING AVG(b.rating) > (
    SELECT AVG(rating) FROM booking);

-------------------------------------------------------

--Phase 8-Indexing

- create index index_member on members(email);

- CREATE INDEX booking_session_idx ON booking(session_id);

- drop index index_member;


select * from session;
select * from trainers;

alter table trainers
add constraint eq_email unique(email);

select t.trainer_name, avg(b.rating) from trainers t inner join session s 
on t.trainer_id=s.trainer_id join booking b on b.session_id=s.session_id group by t.trainer_name;

select count(*)
from booking where member_id=2 and rating =5;

SELECT * FROM session;

select m.member_id from members m join booking b
on m.member_id = b.member_id
group by m.member_id having count(*)<3;

ALTER TABLE session
RENAME COLUMN date TO session_date;

select c.category_name,cl.class_name from categories c inner join class cl
on c.category_id=cl.category_id where c.category_id=1; 

select b.booking_id, s.session_id from booking b inner join session s
on s.session_id = b.session_id join trainers t
on t.trainer_id= s.trainer_id 
;
----------------------------------------------
DO $$
DECLARE
session_cursor cursor for 
select t.trainer_name, count (s.session_id) from trainers t inner join session  s on
t.trainer_id= s.trainer_id group by t.trainer_name ;

counter INTEGER := 0;
    i INTEGER := 1;
BEGIN
    open session_cursor;
	fetch
	while
	counter<= session_cursor
	raise notice '%', session_cursor;
	i := i+1;
	exit when not found;
	end loop;
	
	close session_cursor;
END;
$$;


DO $$
DECLARE
    session_cursor CURSOR FOR
        SELECT session_id
        FROM session
        WHERE trainer_id = 1;   -- غيّر رقم المدرب

    v_session_id session.session_id%TYPE;
    counter INTEGER := 0;

BEGIN
    OPEN session_cursor;

    FETCH session_cursor INTO v_session_id;

    WHILE FOUND LOOP
        counter := counter + 1;

        FETCH session_cursor INTO v_session_id;
    END LOOP;

    CLOSE session_cursor;

    RAISE NOTICE 'Total sessions: %', counter;
END;
$$;




select email from members
    where member_id=(
      select  min (member_id) from members);

SELECT COUNT(*)
FROM booking
WHERE member_id = (
    SELECT MIN(member_id)
    FROM members
);
	  


DO $$
declare
v_members_email members.email%type;
v_plain_type int;
begin
select email into v_members_email from members
where member_id=1;


raise notice 'Email : %',v_members_email;
end ;
$$ ;


create or replace function get_member_name(p_id int)
returns text AS $$
begin
return(
select name from members where member_id=p_id
);
end;
$$ language plpgsql;

















