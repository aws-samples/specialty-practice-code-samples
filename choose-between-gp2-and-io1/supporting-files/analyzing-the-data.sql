SELECT max(row_ts) FROM myschema.mytesttable;

SELECT day(row_ts), hour(row_ts), minute(row_ts), count(*)
  FROM myschema.mytesttable
GROUP BY day(row_ts), hour(row_ts) , minute(row_ts);


gp2 max timestamp 2018-04-19 03:20:32

io1 max timestamp 2018-04-19 02:58:27

