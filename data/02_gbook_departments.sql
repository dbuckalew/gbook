CREATE TABLE departments (
    dept_code		 char(3),
    dept_name		 text NOT NULL,
    PRIMARY KEY (dept_code)
);

CREATE TABLE department_audit (
    op 	     		 char(1) NOT NULL,
    stamp		 timestamp NOT NULL,
    userid		 text NOT NULL,
    dept_code		 char(3),
    dept_name		 text NOT NULL
);

CREATE OR REPLACE FUNCTION process_department_audit() RETURNS TRIGGER AS $dpt_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO department_audit SELECT 'D', now(), user, OLD.*;
	RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN 
    	INSERT INTO department_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
    	INSERT INTO department_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$dpt_audit$ LANGUAGE plpgsql;

CREATE TRIGGER dpt_audit
AFTER INSERT OR UPDATE OR DELETE ON departments
    FOR EACH ROW EXECUTE PROCEDURE process_department_audit();
