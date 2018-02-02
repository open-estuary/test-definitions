set yarn.nodemanager.vmem-pmem-ratio=4;
set mapreduce.reduce.memory.mb=4096;
set mapred.child.java.opts=-Xmx3024m;
set mapreduce.map.memory.mb=4096;


drop table if exists u_data_new;
CREATE TABLE u_data_new (
  userid INT,
  movieid INT,
  rating INT,
  weekday INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

add FILE weekday_mapper.py;

INSERT OVERWRITE TABLE u_data_new
SELECT
  TRANSFORM (userid, movieid, rating, unixtime)
  USING 'python weekday_mapper.py'
  AS (userid, movieid, rating, weekday)
FROM u_data;


