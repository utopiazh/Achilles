-- 2130	Number of device_exposure records by device_concept_id, device start month, and observation_period look back (days)
--      For each device_concept_id, year_month combination, stratum_4 represents the proportion of records with at least as many look back 
--      days as the current row.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with lookback as (
select de.device_concept_id,
       substring(replace(datefromparts(year(de.device_exposure_start_date),month(de.device_exposure_start_date),1),'-',''),1,6) as year_month,
       datediff(d,op.observation_period_start_date,de.device_exposure_start_date) as lookback_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op
  join @cdmDatabaseSchema.device_exposure de
    on de.person_id = op.person_id
 where op.observation_period_start_date <= de.device_exposure_start_date
 group by de.device_concept_id,
          substring(replace(datefromparts(year(de.device_exposure_start_date),month(de.device_exposure_start_date),1),'-',''),1,6),
          datediff(d,op.observation_period_start_date,de.device_exposure_start_date)
) 
select 2130 as analysis_id,
       cast(device_concept_id as varchar(255)) as stratum_1,
       cast(year_month        as varchar(255)) as stratum_2,
       cast(lookback_days     as varchar(255)) as stratum_3,
       cast(1.0*sum(count_value)over(partition by device_concept_id,year_month order by lookback_days desc)/
	            sum(count_value)over(partition by device_concept_id,year_month) as varchar(255)) as stratum_4,
       cast(null              as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2130
  from lookback; 
