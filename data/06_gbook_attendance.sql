CREATE TABLE att_codes (
    att_status	       char(1),
    att_status_name    text NOT NULL,
    PRIMARY KEY (att_status)
);

CREATE TABLE attendance_data (
    att_id   	      serial,
    att_date	      date NOT NULL,
    att_status	      char(1) NOT NULL,
    enr_id	      int NOT NULL,
    PRIMARY KEY (att_id),
    FOREIGN KEY (att_status) REFERENCES att_codes (att_status) ON DELETE RESTRICT,
    FOREIGN KEY (enr_id) REFERENCES enrollment_data (enr_id) ON DELETE CASCADE
);

CREATE TABLE attendance_audit (
    op 	              char(1),
    stamp	      timestamp NOT NULL,
    userid	      text NOT NULL,
    att_id	      int,
    att_date	      date NOT NULL,
    att_status	      char(1) NOT NULL,
    enr_id	      int NOT NULL
);

CREATE FUNCTION process_attendance_audit() RETURNS TRIGGER AS $att_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO attendance_audit SELECT 'D', now(), user, OLD.*;
	RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO attendance_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN 
        INSERT INTO attendance_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$att_audit$ LANGUAGE plpgsql;

CREATE TRIGGER att_audit
AFTER INSERT OR DELETE OR UPDATE ON attendance_data
    FOR EACH ROW EXECUTE PROCEDURE process_attendance_audit();