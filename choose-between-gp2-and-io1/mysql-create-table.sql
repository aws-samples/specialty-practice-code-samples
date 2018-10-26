-- create a schema if it doesn't already exist
CREATE SCHEMA IF NOT EXISTS myschema;
-- drop the table if it is already there (dropping the table first will provide for a clean run)
DROP TABLE myschema.mytesttable;
-- create a simple table
CREATE TABLE IF NOT EXISTS  myschema.mytesttable (
  id_pk             varchar(36)     not null,
  random_string     varchar(200)    not null,
  random_number     double          not null,
  reverse_string    varchar(200)    not null,
  row_ts            timestamp       not null,
 PRIMARY KEY (id_pk)
);
-- create a few indexes to better support a real I/O scenario
CREATE INDEX rs_secondary_idx ON myschema.mytesttable (random_string);
CREATE INDEX rn_secondary_idx ON myschema.mytesttable (random_number);
CREATE INDEX ts_secondary_idx ON myschema.mytesttable (row_ts);
CREATE INDEX ci_compound_idx ON myschema.mytesttable (reverse_string, id_pk);

-- Replace existing <mydbuser> with your own database user
GRANT SELECT, INSERT, UPDATE, DELETE on myschema.mytesttable TO <mydbuser>;

-- sample SQL for generating some random data
INSERT INTO myschema.mytesttable
(id_pk,
 random_string,
 random_number,
 reverse_string,
 row_ts
)
VALUES
(replace(uuid(),'-',''),
 concat(replace(uuid(),'-',''), replace(convert(rand(), char), '.', ''), replace(convert(rand(), char), '.', '')),
 rand(),
 reverse(concat(replace(uuid(),'-',''), replace(convert(rand(), char), '.', ''), replace(convert(rand(), char), '.', ''))),
 current_timestamp
);

