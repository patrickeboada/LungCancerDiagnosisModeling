CREATE TABLE lungcohort AS (SELECT a.subject_id, a.hadm_id, MIN(a.admittime), m.patient_age, m.gender, m.ethnicity, m.insurance, m.hadm_id_los, le.charttime, le.valuenum, le.flag, dli.label, dli.loinc_code
		, CASE
			WHEN m.proc_icd9_long_list LIKE '%chemotherapeutic%' THEN '1'
			ELSE '0'
			END AS has_chemo
		, CASE
			WHEN m.proc_icd9_long_list LIKE '%radiotherapeutic%' THEN '1'
			ELSE '0'
			END AS has_radio
		, CASE
			WHEN m.icd9_list LIKE '%1620%' 
			OR m.icd9_list LIKE '%1622%' 
			OR m.icd9_list LIKE '%1623%'
			OR m.icd9_list LIKE '%1624%'
			OR m.icd9_list LIKE '%1625%'
			OR m.icd9_list LIKE '%1628%'
			OR m.icd9_list LIKE '%1629%'
			OR m.icd9_list LIKE '%1970%'
			OR m.icd9_list LIKE '%2312%'
			OR m.icd9_list LIKE '%2357%'
			OR m.icd9_list LIKE '%2391%'
			THEN '1' 
			ELSE '0'
			END AS has_cancer
		, m.hospital_expire_flag
FROM mimiciii.admissions a
	INNER JOIN mimiciii.diagnoses_icd d
		ON a.HADM_ID = d.HADM_ID
	INNER JOIN mimiciii.d_icd_diagnoses di
		ON d.ICD9_CODE = di.ICD9_CODE
	INNER JOIN mimiciii.labevents le 
		ON a.HADM_ID = le.HADM_ID
	INNER JOIN mimiciii.d_labitems dli 
		ON le.itemid = dli.itemid
	LEFT JOIN master_table m
		ON a.hadm_id = m.hadm_id
WHERE d.ICD9_CODE IN('1620', '1622', '1623', '1624', '1625', '1628', '1629', '1970',  '2312', '2357', '2391')
AND d.ICD9_CODE NOT IN('25541, 2459, 042')
AND dli.label  IN('Bicarbonate', 'Red Blood Cells', 'White Blood Cells', 'Platelet Count', 'Oxygen Saturation','pH')

GROUP BY a.subject_id, a.hadm_id, m.patient_age, m.gender, m.ethnicity, m.insurance
	, m.hadm_id_los, m.proc_icd9_long_list, m.icd9_list, m.hospital_expire_flag,le.charttime, le.valuenum, le.flag, dli.label, dli.loinc_code)



--COPY lungcohort TO '/Users/patrickboada/Desktop/lungcohortdb.csv' DELIMITER ',' CSV HEADER;


\copy lungcohort to '/Users/patrickboada/Desktop/lungcohortdb.csv' with csv;