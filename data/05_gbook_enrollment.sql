CREATE TABLE enr_codes (
    enr_code 	       char(1),
    enr_code_name      text NOT NULL,
    PRIMARY KEY (enr_code)
);

CREATE TABLE enrollment_data (
    enr_id   	       serial,
    sec_id	       int NOT NULL,
    stu_id	       int NOT NULL,
    enr_code	       char(1) NOT NULL,
    PRIMARY KEY (enr_id),
    FOREIGN KEY (sec_id) REFERENCES section_data (sec_id),
    FOREIGN KEY (stu_id) REFERENCES student_data (stu_id),
    FOREIGN KEY (enr_code) REFERENCES enr_codes (enr_code)
);

CREATE TABLE enrollment_audit (
    op 	     	       char(1),
    stamp	       timestamp NOT NULL,
    userid	       text NOT NULL,
    enr_id	       int,
    sec_id	       int NOT NULL,
    stu_id	       int NOT NULL,
    enr_code	       char(1) NOT NULL
);

CREATE FUNCTION process_enrollment_audit() RETURNS TRIGGER AS $enr_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN 
        INSERT INTO enrollment_audit SELECT 'D', now(), user, OLD.*;
	RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO enrollment_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN 
        INSERT INTO enrollment_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$enr_audit$ LANGUAGE plpgsql;

CREATE TRIGGER enr_audit
AFTER INSERT OR DELETE OR UPDATE ON enrollment_data
    FOR EACH ROW EXECUTE PROCEDURE process_enrollment_audit();