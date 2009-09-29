CREATE TABLE student_data (
  stu_id			  int PRIMARY KEY,
  stu_lname			  text NOT NULL,
  stu_fname			  text NOT NULL,
  stu_mname			  text,
  stu_called			  text,
  stu_uname			  text,
  CHECK (stu_id > 99999 AND stu_id < 1000000)
);

CREATE TABLE student_audit ( 
  op         		     char(1) NOT NULL,
  stamp			     timestamp NOT NULL,
  userid		     text NOT NULL,
  stu_id		     int,
  stu_lname		     text NOT NULL,
  stu_fname		     text NOT NULL,
  stu_mname		     text,
  stu_called		     text,
  stu_uname		     text
);

CREATE OR REPLACE FUNCTION process_student_audit() RETURNS TRIGGER AS $stu_audit$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO student_audit SELECT 'D', now(), user, OLD.*;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO student_audit SELECT 'U', now(), user, NEW.*;
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO student_audit SELECT 'I', now(), user, NEW.*;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$stu_audit$ LANGUAGE plpgsql;

CREATE TRIGGER stu_audit
AFTER INSERT OR DELETE OR UPDATE ON student_data
  FOR EACH ROW EXECUTE PROCEDURE process_student_audit();

CREATE INDEX students_by_name ON student_data (stu_lname, stu_fname);

CREATE TABLE alt_student_email (
  stu_id			int REFERENCES student_data(stu_id),
  stu_email			text,
  PRIMARY KEY			(stu_id, stu_email)
);

CREATE OR REPLACE FUNCTION add_student (
    id integer,
    lname text,
    fname text,
    mname text,
    uname text,
    scalled text,
    emails text[]
) RETURNS VOID AS $$
BEGIN
    INSERT INTO student_data VALUES (id, lname, fname, mname, uname, scalled);
    FOR i in array_lower(emails) .. array_upper(emails) LOOP
    	INSERT INTO alt_student_email VALUES (id, emails[i]); 
    END LOOP;
END;
$$ LANGUAGE plpgsql;
