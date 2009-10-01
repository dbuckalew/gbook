CREATE TABLE terms (
    term_code		char(2),
    term_name		text,
    PRIMARY KEY (term_code)
);

CREATE TABLE term_data (
    term_id  	        serial,
    term_code		char(2) NOT NULL,
    term_year		integer,
    term_begin		date NOT NULL,
    term_end		date NOT NULL,
    PRIMARY KEY (term_id),
    UNIQUE (term_begin, term_end),
    FOREIGN KEY (term_code) REFERENCES terms (term_code)
);

CREATE TABLE term_data_audit (
    op 	     		char(1) NOT NULL,
    stamp		timestamp NOT NULL,
    userid		text NOT NULL,
    term_id		int,
    term_code		char(2) NOT NULL,
    term_year		int,
    term_begin		date NOT NULL,
    term_end		date NOT NULL
);

CREATE OR REPLACE FUNCTION process_term_data_audit() RETURNS TRIGGER AS $term_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
       INSERT INTO term_data_audit SELECT 'D', now(), user, OLD.*;
       RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
       INSERT INTO term_data_audit SELECT 'U', now(), user, NEW.*;
       RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
       INSERT INTO term_data_audit SELECT 'I', now(), user, NEW.*;
       RETURN NEW;
   END IF;
   RETURN NULL; 
END;
$term_audit$ LANGUAGE plpgsql;

CREATE TRIGGER term_audit
AFTER INSERT OR UPDATE OR DELETE ON term_data
    FOR EACH ROW EXECUTE PROCEDURE process_term_data_audit();