CREATE TABLE section_data (
    sec_id   		  serial,
    term_id		  int NOT NULL,
    sec_call		  int NOT NULL,
    sec_dept		  char(3) NOT NULL,
    sec_course		  int NOT NULL,
    sec_name		  text NOT NULL,
    sec_days		  int NOT NULL,
    sec_begin		  time,
    sec_end		  time,
    PRIMARY KEY (sec_id),
    FOREIGN KEY (term_id) REFERENCES term_data (term_id) ON DELETE RESTRICT,
    FOREIGN KEY (sec_dept) REFERENCES departments (dept_code) ON DELETE RESTRICT,
    CHECK (sec_call > 0 AND sec_call < 100000),
    CHECK (sec_course > 0 AND sec_course < 300)
);

CREATE TABLE section_audit (
    op 	     		 char(1) NOT NULL,
    stamp		 timestamp NOT NULL,
    userid		 text NOT NULL,
    sec_id		 int,
    term_id		 int NOT NULL,
    sec_call		 int NOT NULL,
    sec_dept		 char(3) NOT NULL,
    sec_course		 int NOT NULL,
    sec_name		 text NOT NULL,
    sec_days		 int NOT NULL,
    sec_begin		 time,
    sec_end		 time
);

CREATE OR REPLACE FUNCTION process_section_audit() RETURNS TRIGGER AS $sec_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO section_audit SELECT 'D', now(), user, OLD.*;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO section_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO section_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$sec_audit$ LANGUAGE plpgsql;

CREATE TRIGGER sec_audit
AFTER INSERT OR UPDATE OR DELETE ON section_data
    FOR EACH ROW EXECUTE PROCEDURE process_section_audit();