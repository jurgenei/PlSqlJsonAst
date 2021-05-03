create or replace PROCEDURE merge_1 (
    v_system_id        IN pkg_subtype.system_id,
    v_reporting_date   IN pkg_subtype.general_date
) AS
BEGIN
	MERGE /*+ enable_parallel_dml */
	INTO (
	select /*+ no_index(facility) +*/  customer_id,facility_id,higher_level_facility_id,facility_purpose_key 
	from facility where time_key = v_time_key and system_id = v_system_id
	) f 
	USING
	(
	    SELECT  /*+ PARALLEL +*/
	    facility_purpose_key,
	    customer_id,
	    higher_level_facility_id,
	    facility_id
	    FROM
	    tt__purpose
	)
	fp ON (fp.customer_id = f.customer_id
	    AND   fp.facility_id = f.facility_id
	    AND   fp.higher_level_facility_id = f.higher_level_facility_id)
	WHEN MATCHED THEN UPDATE SET f.facility_purpose_key = fp.facility_purpose_key;
END;
