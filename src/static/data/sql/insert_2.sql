create or replace PROCEDURE insert_2 (
    v_system_id        IN pkg_subtype.system_id,
    v_reporting_date   IN pkg_subtype.general_date
) AS
BEGIN
	INSERT /*+ APPEND enable_parallel_dml */ INTO facility (
	facility_key,
	higher_level_facility_key,
	highest_level_facility_key,
	time_key,
	system_id,
	--customer_key,
	customer_id,
	higher_level_facility_id,
	facility_id,
	limit_amt_local,
	orig_limit_amt_local,
	start_date,
	orig_start_date,
	end_date,
	orig_end_date,
	purpose,
	sales_channel,
	risk_rating_orig,
	risk_rating_application,
	entity_code,
	authorisation,
	number_,
	dummy_indicator,
	pd_orig,
	lgd_orig,
	ead_local,
	book_office,
	origination,
	loan_status,
	local_product_type_code, --CR311
	local_initiating_office_code, --book_unit
	delivered_lgd,
	committed_indicator, --US-538: ALM# 54499: AQR Improvement item: Commitment indicator for Consumer (https://confluence.europe.intranet/x/Up-6Aw)
	base_entity,		-- New fields for IFRS9 starts here
	probability_of_default_at_orig,
	probability_of_default_orig_date,
	bank_credit_risk_rating_at_orig,
	default_reason,
	contractual_maturity,
	revolving,
	advised,
	fb_measure_type,  -- Changed it from forbearance_measure to existing field
	fb_status,		  -- Changed it from forbearance_status to existing field
	forbearance_start_date,
	forbearance_probation_start_date,
	limit_lifecycle_status_date,
	offer_issuance_date,
	documentation_completion_date,
	offer_acceptance_date,
	bridge_loan,
	credit_fraud,
	notice_period,
	derecognition_date,
	derecognition_reason,
	purch_or_orig_credit_impaired,
	problem_loan_department,
	pd_arrears_submodel_used,		-- New fields for IFRS9 ends here
	forbearance_measure_2, -- start STRY0501319  --oramig first catchup
	forbearance_measure_3,
	forbearance_measure_4,
	forbearance_measure_5,
	recourse_indicator, -- end STRY0501319
	--DG:30-10-2019:moved population of keys here from the merge statements below.
	df_days_pst_du,              -- START STRY0888227
	df_days_pst_du_value,
	df_days_pst_du_unit,
	abs_breach_str_date,
	abs_breach_pst_du_amt_local,
	abs_breach_end_date,
	rel_breach_str_date,
	rel_breach_pst_du_amt_local,
	rel_breach_out_amt_local,
	rel_breach_end_date,         -- END STRY0888227
	npv_old_local,               -- START STRY1145863
	npv_new_local,
	npv_loss,
	npv_impact_calc_date,
	orig_facility_id,
	orig_higher_level_fac_id,
	orig_system_id,
	new_facility_id,
	new_higher_level_fac_id,
	new_system_id ,               -- END STRY1145863
	forbearance_measure_2_key,
	forbearance_measure_3_key,
	forbearance_measure_4_key,
	forbearance_measure_5_key,
	recourse_indicator_key,
	book_office_key,
	init_office_key, -- For now set to book_office because initiating office is not in startpack file
	risk_rating_application_key,
	orig_ccy_limit_key,
	lim_amt_ccy_key,
	facility_type_key,
	customer_key,
	loan_status_key,
	sales_channel_key,
	entity_key,
	base_entity_key,
	contractual_maturity_key,
	revolving_key,
	advised_key,
	bridge_loan_key,
	credit_fraud_key,
	derecognition_reason_key,
	purch_or_orig_credit_impaired_key,
	problem_loan_department_key,
	pd_arrears_submodel_used_key,
	notice_period_unit,
	notice_period_value,
	abs_breach_pst_du_amt_ccy_key,
	rel_breach_pst_du_amt_ccy_key,
	rel_breach_out_amt_ccy_key,
	npv_old_ccy_key,
	npv_new_ccy_key,
	debt_collection_key,
	in_forbearance_key
	)
	SELECT /*+ PARALLEL +*/
	  ROWNUM + v_max_facility_key,
	  ROWNUM + v_max_facility_key,
	  ROWNUM + v_max_facility_key,
	  v_time_key,
	  v_system_id,
	  --NULL,--customer_key,
	  rl.customer_id,
	  higher_level_facility_id,
	  facility_id,
	  limit_amt,              --limit_amt_local
	  orig_princ_amt,         -- orig_limit_amt_local
	  limit_start_date,
	  orig_start_date,
	  limit_end_date,
	  orig_end_date,
	  facility_purpose,
	  sales_channel,
	  credit_risk_rating,
	  credit_aplic_rating,
	  rl.entity_code,
	  authorisation,
	  1,
	  rl.dummy_indicator,
	  pd_orig,
	  lgd_orig,
	  ead,
	  book_unit,
	  'E', -- origination will be dereleased but fopr Now Vortex-I needs this column 20060411
	  status_code,
	  local_product_type_code,
	  book_unit,
	  delivered_lgd,
	  rl.committed_indicator, --US-538: ALM# 54499: AQR Improvement item: Commitment indicator for Consumer (https://confluence.europe.intranet/x/Up-6Aw)
	  base_entity,		-- New fields for IFRS9 starts here
	  probability_of_default_at_orig,
	  probability_of_default_orig_date,
	  bank_credit_risk_rating_at_orig,
	  default_reason,
	  rl.contractual_maturity,
	  rl.revolving,
	  rl.advised,
	  --forbearance_measure,
	  case when status_code IN ('FB_MCP','FB_MIP') and (forbearance_status IS NULL or forbearance_measure IS NULL) then 'LOAN_MOD'
	       when status_code IN ('FB_RCP','FB_RIP') and (forbearance_status IS NULL or forbearance_measure IS NULL) then 'REFNC'
	       else forbearance_measure
	  end as fb_measure_type,
	  --forbearance_status,
	  case when status_code IN ('FB_MCP','FB_RCP') and (forbearance_status IS NULL or forbearance_measure IS NULL) then 'CHD_FRBC'
	       when status_code IN ('FB_MIP','FB_RIP') and (forbearance_status IS NULL or forbearance_measure IS NULL) then 'INL_FRBC'
	       else forbearance_status
	  end as loan_status,
	  forbearance_start_date,
	  forbearance_probation_start_date,
	  limit_lifecycle_status_date,
	  offer_issuance_date,
	  documentation_completion_date,
	  offer_acceptance_date,
	  bridge_loan,
	  credit_fraud,
	  rl.notice_period,
	  derecognition_date,
	  derecognition_reason,
	  purch_or_orig_credit_impaired,
	  problem_loan_department,
	  pd_arrears_submodel_used,		-- New fields for IFRS9 ends here
	  forbearance_measure_2,          -- start STRY0501319
	  forbearance_measure_3,
	  forbearance_measure_4,
	  forbearance_measure_5,
	  recourse_indicator,             -- end STRY0501319
	  --DG:30-10-2019:moved population of keys here from the merge statements below.
	    df_days_pst_du,                                     --df_days_pst_du               -- START STRY0888227
	  --cast(substr(substr(rtrim(df_days_pst_du), length(rtrim(df_days_pst_du)) - 1),-( length(rtrim(df_days_pst_du)) - 2)) as number),    --df_days_pst_du_value    --ORAMIGCATCHUP3
	  cast(  substr(substr(rtrim(df_days_pst_du), 2,length(rtrim(df_days_pst_du)) )  ,1,( length(rtrim(df_days_pst_du)) - 2))   as number),--RB
	  substr(reverse(rtrim(df_days_pst_du) ),1,1 ), --df_days_pst_du_unit  --ORAMIGCATCHUP3
	  abs_breach_str_date,                                --abs_breach_str_date
	  abs_breach_pst_du_amt,                              --abs_breach_pst_du_amt_local
	  abs_breach_end_date,                                --abs_breach_end_date
	  rel_breach_str_date,                                --rel_breach_str_date
	  rel_breach_pst_du_amt,                              --rel_breach_pst_du_amt_local
	  rel_breach_out_amt,                                 --rel_breach_out_amt_local
	  rel_breach_end_date,                                --rel_breach_end_date            -- END STRY0888227
	  npv_old,                                            --npv_old_local                  -- START STRY1145863
	  npv_new,                                            --npv_new_local
	  npv_loss,                                           --npv_loss
	  npv_impact_calc_date,                               --npv_impact_calc_date
	  orig_facility_id,                                   --orig_facility_id
	  orig_higher_level_fac_id,                           --orig_higher_level_fac_id
	  orig_system_id,                                     --orig_system_id
	  new_facility_id,                                    --new_facility_id
	  new_higher_level_fac_id,                            --new_higher_level_fac_id
	  new_system_id                              ,         --new_system_id                  -- END STRY1145863
	  frbc2.frbc_msr_key as forbearance_measure_2_key,
	  frbc3.frbc_msr_key as forbearance_measure_3_key,
	  frbc4.frbc_msr_key as forbearance_measure_4_key,
	  frbc5.frbc_msr_key as forbearance_measure_5_key,
	  res.recourse_key as recourse_indicator_key,
	  coff.office_key as book_office_key,
	  coff.office_key as init_office_key, -- For now set to book_office because initiating office is not in startpack file
	  rr.risk_rating_key as risk_rating_application_key,
	  org_cur.currency_key as orig_ccy_limit_key,
	  lmt_cur.currency_key as lim_amt_ccy_key,
	  ft.facility_type_key as facility_type_key,
	  cus.customer_key,
	  cs.loan_status_key,
	  slsc.sales_channel_key,
	  enty.entity_key,
	  obe.office_base_entity_key,
	  cmi.ctrl_mat_ind_key,
	  crvli.rvl_ind_key,
	  advi.adv_ind_key,
	  brdgi.brdg_loan_ind_key,
	  crfrd.cr_frd_key,
	  drgn.drgn_rsn_key,
	  poci.poci_tp_key,
	  pld.prblm_loan_dept_key,
	  psu.pdars_smdl_usd_key,
	  substr(reverse(rtrim(rl.notice_period)),1,1) as notice_period_unit,
	  REGEXP_SUBSTR(rtrim(rl.notice_period),'[0-9]+') as notice_period_value,
	  abpda.currency_key abs_breach_pst_du_amt_ccy_key,
	  rbpda.currency_key rel_breach_pst_du_amt_ccy_key,
	  rbomt.currency_key rel_breach_out_amt_ccy_key,
	  npvoc.currency_key npv_old_ccy_key,
	  npvnc.currency_key npv_new_ccy_key,
	  dcli.general_indicator_key debt_collection_key,
	  case when v_indicator_value = 'Y' then infrbi.general_indicator_key
	      else null
	  end in_forbearance_key
	FROM
	  raw_limit rl
	  left outer join current_frbc_msr frbc2 on  rl.forbearance_measure_2 = frbc2.code
	  left outer join current_frbc_msr frbc3 on  rl.forbearance_measure_3 = frbc3.code
	  left outer join current_frbc_msr frbc4 on  rl.forbearance_measure_4 = frbc4.code
	  left outer join current_frbc_msr frbc5 on  rl.forbearance_measure_5 = frbc5.code
	  left outer join recourse res on rl.recourse_indicator = res.code
	  and res.record_valid_from <= v_reporting_date
	  AND  NVL(res.record_valid_until,utilities.record_default_date) > v_reporting_date
	  left outer join current_office coff on rl.book_unit = coff.code
	  left outer join current_risk_rating rr on rl.credit_aplic_rating = rr.code
	  left outer join current_currency org_cur on rl.orig_ccy_limit = org_cur.code
	  left outer join current_currency lmt_cur on rl.limit_amt_ccy = lmt_cur.code
	  left outer join current_facility_type ft on rl.facility_type = ft.code
	  left outer join customer cus on cus.customer_id = rl.customer_id
	  and cus.time_key = v_time_key
	  AND cus.system_id = v_system_id
	  left outer join current_loan_status cs on rl.status_code = cs.code
	  left outer join current_sales_channel slsc on rl.sales_channel = slsc.code
	  left outer join current_entity enty on rl.entity_code = enty.code
	  left outer join current_office_base_entity obe on rl.base_entity = obe.code
	  left outer join current_ctrl_mat_ind cmi on rl.contractual_maturity = cmi.code
	  left outer join current_rvl_ind crvli on rl.revolving = crvli.code
	  left outer join current_adv_ind advi on rl.advised = advi.code
	  left outer join current_brdg_loan_ind brdgi on rl.bridge_loan = brdgi.code
	  left outer join current_cr_frd crfrd on rl.credit_fraud = crfrd.code
	  left outer join current_drgn_rsn drgn on rl.derecognition_reason = drgn.code
	  left outer join current_poci_tp poci on rl.purch_or_orig_credit_impaired = poci.code
	  left outer join current_prblm_loan_dept pld on rl.problem_loan_department = pld.code
	  left outer join current_pdars_smdl_usd psu on rl.pd_arrears_submodel_used = psu.code
	  left outer join current_currency abpda on rl.abs_breach_pst_du_amt_ccy = abpda.code
	  left outer join current_currency rbpda on rl.rel_breach_pst_du_amt_ccy = rbpda.code
	  left outer join current_currency rbomt on rl.rel_breach_out_amt_ccy = rbomt.code
	  left outer join current_currency npvoc on rl.npv_old_ccy = npvoc.code
	  left outer join current_currency npvnc on rl.npv_new_ccy = npvnc.code
	  left outer join general_indicator dcli on rl.debt_collection = dcli.code
	  left outer join general_indicator infrbi on rl.in_forbearance = infrbi.code
	  ;
END;