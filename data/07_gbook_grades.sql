CREATE TABLE assignment_data (
    asn_id   		     serial,
    sec_id		     int NOT NULL,
    asn_parent		     int,
    asn_name		     text NOT NULL,
    asn_short_name	     text NOT NULL,
    asn_weight		     real NOT NULL,
    asn_max_score	     real,
    PRIMARY KEY (asn_id),
    FOREIGN KEY (sec_id) REFERENCES section_data (sec_id) ON DELETE CASCADE,
    FOREIGN KEY (asn_parent) REFERENCES assignment_data (asn_id) ON DELETE CASCADE
);

CREATE TABLE assignment_audit (
    op 	     		    char(1),
    stamp		    timestamp NOT NULL,
    userid		    text NOT NULL,
    asn_id		    int,
    sec_id		    int NOT NULL,
    asn_parent		    int,
    asn_name		    text NOT NULL,
    asn_short_name	    text NOT NULL,
    asn_weight		    real NOT NULL,
    asn_max_score	    real
);

CREATE OR REPLACE FUNCTION process_assignment_audit() RETURNS TRIGGER AS $asn_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO assignment_audit SELECT 'D', now(), user, OLD.*;
	RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO assignment_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO assignment_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$asn_audit$ LANGUAGE plpgsql;

CREATE TRIGGER ans_audit
AFTER INSERT OR DELETE OR UPDATE ON assignment_data
    FOR EACH ROW EXECUTE PROCEDURE process_assignment_audit();

CREATE TABLE grade_data (
    grd_id   		 serial,
    enr_id		 int NOT NULL,
    asn_id		 int NOT NULL,
    grd_earned		 real NOT NULL,
    PRIMARY KEY (grd_id),
    FOREIGN KEY (enr_id) REFERENCES enrollment_data (enr_id) ON DELETE CASCADE,
    FOREIGN KEY (asn_id) REFERENCES assignment_data (asn_id) ON DELETE CASCADE
);

CREATE TABLE grade_audit (
   op  	     		 char(1) NOT NULL,
   stamp		 timestamp NOT NULL,
   userid		 text NOT NULL,
   grd_id		 int,
   enr_id		 int NOT NULL,
   asn_id		 int NOT NULL,
   grd_earned		 real NOT NULL
);

CREATE OR REPLACE FUNCTION process_grade_audit() RETURNS TRIGGER AS $grd_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO grade_audit SELECT 'D', now(), user, OLD.*;
	RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO grade_audit SELECT 'U', now(), user, NEW.*;
	RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO grade_audit SELECT 'I', now(), user, NEW.*;
	RETURN NEW;
    END IF;
    RETURN NULL;
END;
$grd_audit$ LANGUAGE plpgsql;

CREATE TRIGGER grd_audit
AFTER INSERT OR UPDATE OR DELETE ON grade_data
    FOR EACH ROW EXECUTE PROCEDURE process_grade_audit();