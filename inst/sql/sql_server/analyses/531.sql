-- 531	Number of persons by death date (YYYYMMDD)

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
	(YEAR(d1.death_date)*100 + MONTH(d1.death_date))*100 + DAY(d1.death_date) as stratum_1,
    COUNT_BIG(distinct d1.PERSON_ID) as count_value
  FROM
  @cdmDatabaseSchema.death d1 INNER JOIN 
  @cdmDatabaseSchema.observation_period op ON d1.person_id = op.person_id
  -- only include events that occur during observation period
  WHERE d1.death_date <= op.observation_period_end_date 
    AND d1.death_date >= op.observation_period_start_date
  GROUP BY (YEAR(d1.death_date)*100 + MONTH(d1.death_date))*100 + DAY(d1.death_date)
)
SELECT
  531 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_531
FROM rawData;