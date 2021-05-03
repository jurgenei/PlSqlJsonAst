create or replace PROCEDURE merge_2 (
    v_system_id        IN pkg_subtype.system_id,
    v_reporting_date   IN pkg_subtype.general_date
) AS
BEGIN
	--sj:2019-08-02 --reframe merge
	MERGE   /*+ enable_parallel_dml */ 
	INTO (
	  select  /*+ parallel no_index(facility)*/ customer_key,start_date,cust_age_at_start 
	  from  facility where system_id = v_system_id
	  AND   time_key = v_time_key
	) f USING (
	   SELECT /*+ PARALLEL +*/ DISTINCT
	    cu.birth,
	    cu.customer_key
	   FROM customer cu
	   WHERE cu.time_key = v_time_key
	   and cu.system_id = v_system_id
	)
	cu ON (   cu.customer_key = f.customer_key )
	WHEN MATCHED THEN 
	UPDATE 
	SET f.cust_age_at_start = case when f.start_date > cu.birth
	                          then EXTRACT(YEAR FROM f.start_date) -  EXTRACT(YEAR FROM cu.birth)
	                          when f.start_date < cu.birth
	                          then EXTRACT(YEAR FROM v_reporting_date) - EXTRACT(YEAR FROM cu.birth)
	                          when f.start_date = cu.birth
	                          then 0
	                          else f.cust_age_at_start
	                     			end; 
END;
                                                        