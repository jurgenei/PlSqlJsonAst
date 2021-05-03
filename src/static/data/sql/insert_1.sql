create or replace PROCEDURE insert_1 (
    v_system_id        IN pkg_subtype.system_id,
    v_reporting_date   IN pkg_subtype.general_date
) AS
BEGIN
    INSERT /*+ APPEND enable_parallel_dml */ INTO  customer (
        system_id,
        customer_key,
        time_key,
        customer_id,
        birth,
        industry_code,
        income_local,
        work_agree,
        lev_edu,
        dummy_indicator,
        segmentation_code,
         customer_postal_code,
         nationality_key,
         residence_key,
         marital_status_key,
         customer_type_code,
         customer_type_key,
         income_base_key,
         income_currency_key,
         segmentation_type_key,
         industry_type_key,
         work_agree_key,
         lev_edu_key
    )
        ( SELECT /*+ PARALLEL */
            v_system_id,
            ROWNUM + v_max_cus_key,
            v_time_key,
            customer_id,
            birth,
            ind_code,
            income,
            work_agree,
            lev_edu,
            dummy_indicator,
            segmentation_code,
            customer_postal_code,
            nk.country_key,
            rk.country_key,
            msk.marital_status_key,
            r.customer_type,
            ct.customer_type_key,
            ib.income_base_key,
            cu.currency_key,
            st.segmentation_type_key,
            it.industry_type_key,
            wa.work_agree_key,
            le.lev_edu_key
          FROM
            raw_customer r
            left join current_country nk on r.nationality = nk.code
            left join current_country rk on r.residence = rk.code
            left join current_marital_status  msk on r.marital_status = msk.code
            left join current_customer_type ct on r.customer_type = ct.code
            left join current_income_base ib on r.income_base = ib.code --fix added by RS
            left join current_currency cu on r.orig_income_ccy = cu.code
            left join current_segmentation_type st on r.segmentation_code = st.code
            left join current_industry_type it on r.ind_code = it.code
            left join current_work_agree wa on r.work_agree = wa.code
            left join current_lev_edu le on r.lev_edu = le.code
        );
END;