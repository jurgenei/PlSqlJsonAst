create or replace PROCEDURE update_1 (
    v_system_id        IN pkg_subtype.system_id,
    v_reporting_date   IN pkg_subtype.general_date
) AS
BEGIN
	UPDATE /*+ enable_parallel_dml no_index(facility)*/  facility
	SET
	    higher_level_facility_id = facility_id
	WHERE
	higher_level_facility_key = facility_key
	AND   higher_level_facility_id IS NULL
	AND   time_key = v_time_key
	AND   system_id = v_system_id;
END;