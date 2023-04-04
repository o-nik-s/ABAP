
DATA: ls_runperiod        TYPE ckml_run_period_data,
      lt_split_aqzif TYPE STANDARD TABLE OF ztco_split_aqzif,
      lt_makz             TYPE STANDARD TABLE OF makz,
      ls_split_aqzif      TYPE ckml_s_bai_split_aqzif,
      " s_output_list       TYPE output_list_str,
      " t_output_list       TYPE STANDARD TABLE OF output_list_str.
      lv_common_mm        TYPE ztco_split_aqzif-meins,
      lv_menge            TYPE ztco_split_aqzif-menge,
      lv_denominator(16)  TYPE p DECIMALS 5,
      lv_numerator(16)    TYPE p DECIMALS 5.

    CLEAR lv_common_mm.

    CALL FUNCTION 'CKML_RUN_PERIOD_GET'
      EXPORTING
        i_run_id     = run_id
      IMPORTING
        es_runperiod = ls_runperiod.

    SELECT ckmlmv001~matnr AS kuppl
           ckmlmv001~losgr_pc AS menge
           ckmlmv001~meins_pc AS meins
           makz~ziffr AS ziffr
      INTO CORRESPONDING FIELDS OF TABLE lt_split_aqzif
      FROM ckmlmv001
      JOIN marc
        ON marc~matnr = ckmlmv001~matnr AND
           marc~werks = ckmlmv001~werks
      JOIN makz
        ON makz~kuppl = ckmlmv001~matnr AND
           makz~werks = ckmlmv001~werks
     WHERE ckmlmv001~main_process EQ procnr AND
           marc~fxpru = ' '.

    CHECK NOT lt_split_aqzif[] IS INITIAL.

LOOP AT lt_split_aqzif ASSIGNING FIELD-SYMBOL(<lt_split_aqzif>).

  IF lv_common_mm <> <lt_split_aqzif>-meins. " �������, ��� �������� �������� ������ ������
    IF <lt_split_aqzif>-kuppl = cf_kvmk-matnr.
    lv_common_mm = <lt_split_aqzif>-meins.
  ELSE.
   co-material - �� �������
   convert unit - ����������� � ��� ������� ��� � ���������
   ������� ������
    IF <lt_split_aqzif>-meins <> lv_common_mm.
      CALL FUNCTION 'CONVERSION_FACTOR_GET'
        EXPORTING
          no_type_check        = 'X'
          unit_in              = <lt_split_aqzif>-meins
          unit_out             = lv_common_mm
        IMPORTING
          denominator          = lv_denominator
          numerator            = lv_numerator
        EXCEPTIONS
          conversion_not_found = 01
          overflow             = 02
          type_invalid         = 03
          units_missing        = 04
          unit_in_not_found    = 05
          unit_out_not_found   = 06.
"    �����������
      CALL FUNCTION 'UNIT_CONVERSION_WITH_FACTOR'
        EXPORTING
          add_const        = '0'
          denominator      = lv_denominator
          numerator        = lv_numerator
          input            = <lt_split_aqzif>-menge
        IMPORTING
          output           = lv_menge
        EXCEPTIONS
          division_by_zero = 1
          overflow         = 2
          type_invalid     = 3
          OTHERS           = 4.
"    fill unit, ���� �� ��������
      IF sy-subrc IS INITIAL .
        <lt_split_aqzif>-meins = lv_common_mm.
        <lt_split_aqzif>-menge = lv_menge.
      ENDIF.
    ENDIF.
  ENDIF.

ENDLOOP.

es_split-csplit = 'BADI'.
LOOP AT lt_split_aqzif ASSIGNING <lt_split_aqzif>.
  <lt_split_aqzif>-kmeng = <lt_split_aqzif>-menge  <lt_split_aqzif>-ziffr.
  CLEAR ls_split_aqzif.
  ls_split_aqzif-kuppl = <lt_split_aqzif>-kuppl.
  ls_split_aqzif-aqzif = <lt_split_aqzif>-kmeng.
  INSERT ls_split_aqzif INTO TABLE et_split_aqzif.
ENDLOOP.



"  Version S4HANA, Release 16.10 or higher.
"  Sample Implementation:
"  Apportionment according to actual output quantities of run period.
TYPES:
  BEGIN OF output_list_str,
    matnr TYPE matnr,
    quant TYPE ml4h_quantity,
    meins TYPE ml4h_meins,
  END OF output_list_str,
  BEGIN OF meins_str,
    meins TYPE ml4h_meins,
  END OF meins_str.
DATA:
  s_output_list TYPE output_list_str,
  s_meins_list  TYPE meins_str,
  t_sel_result  TYPE STANDARD TABLE OF output_list_str,
  t_output_list TYPE STANDARD TABLE OF output_list_str,
  t_meins_list  TYPE STANDARD TABLE OF meins_str,
  lines         LIKE sy-index,
  d_posnr       TYPE co_posnr,
  d_maximum     TYPE f,
  d_help        TYPE f,
  d_factor      TYPE f,
  s_split_aqzif TYPE ckml_s_bai_split_aqzif,
  s_runperiod   TYPE ckml_run_period_data,
  s_mkal        TYPE mkal,
  s_makv        TYPE makv,
  s_makz        TYPE makz,
  t_makz        TYPE STANDARD TABLE OF makz,
  ls_strg        TYPE ml4h_s_strg,
  lt_process     TYPE ml4h0_srt_proc,
  ls_process     TYPE ml4h0_s_proc,
  lt_outputs     TYPE ml4h0_srt_outputs,
  s_outputs     TYPE ml4h0_s_outputs,
  csplt         TYPE csplit,
  msgv1         LIKE sy-msgv1,
  msgv2         LIKE sy-msgv1,
  message       TYPE symsgli.
* Check if an apportionment structure is maintained in
* material master. In this case don't use the BAdI
IF NOT verid IS INITIAL.
"  Read apportionment structure from version first.
  CALL FUNCTION 'CK31_PRODUCTION_VERSION_READ'
    EXPORTING
      matnr    = matnr_process
      werks    = werks_process
      verid    = verid
    IMPORTING
      mkal_exp = s_mkal
    EXCEPTIONS
      OTHERS   = 1.
  IF sy-subrc EQ 0.
    csplt = s_mkal-csplt.
  ENDIF.
ENDIF.
CLEAR s_makv.
REFRESH t_makz.
CALL FUNCTION 'MATERIAL_COSTS_SPLIT_READ'
  EXPORTING
    matnr                 = matnr_process
    werks                 = werks_process
    csplit                = csplt
    datum                 = datum
    refresh_buffer        = 'X'
  IMPORTING
    makv_exp              = s_makv
  TABLES
    tmakz                 = t_makz
  EXCEPTIONS
    costs_split_not_found = 01.
IF sy-subrc = 0 AND NOT t_makz IS INITIAL.
* Apportionment structure found. So don't use the BAdI.
  EXIT.
ENDIF.
* Get costing run information.
CALL FUNCTION 'CKML_RUN_PERIOD_GET'
  EXPORTING
    i_run_id     = run_id
  IMPORTING
    es_runperiod = s_runperiod.
ls_strg-run_id = run_id.
ls_strg-curtp_10 = '10'.
 Set RUNREF
IF s_runperiod-appl = ckru0_co_appl_act.
"  Actual Run: Set default Run Reference (ACT)
  ls_strg-runref = ml4h1_runref-act.
ELSEIF NOT s_runperiod-ref_run_id IS INITIAL.
"  AVR with Run Reference: Set Run Reference ID
  ls_strg-runref = s_runperiod-ref_run_id.
ELSE.
"  AVR without Run Reference: Set Run ID
  ls_strg-runref = s_runperiod-run_id.
ENDIF.
IF s_runperiod-appl = 'CUM' AND
    ( s_runperiod-from_gjahr <> s_runperiod-gjahr OR
    s_runperiod-from_poper <> s_runperiod-poper OR
    s_runperiod-xshifted IS NOT INITIAL ).
  ls_strg-xmultiperiod = 'X'.
ELSE.
  CLEAR ls_strg-xmultiperiod.
ENDIF.
"  Get list of output materials with actual quantities
ls_process-process = procnr.
INSERT ls_process INTO TABLE lt_process.
CALL FUNCTION 'FCML4H_READ_OUTPUTS'
  EXPORTING
    is_strg    = ls_strg
    it_process = lt_process
  IMPORTING
    et_outputs = lt_outputs.
LOOP AT lt_outputs INTO s_outputs.
  MOVE-CORRESPONDING s_outputs TO s_output_list.
  COLLECT s_output_list INTO t_output_list.
  MOVE-CORRESPONDING s_output_list TO s_meins_list.
  COLLECT s_meins_list INTO t_meins_list.
ENDLOOP.
SORT t_output_list BY matnr.
"  Check if unit of measure (UoM) is the same for all outputs.
DESCRIBE TABLE t_meins_list LINES lines.
IF lines > 1.
"  Different UoM occur in output list. This is not supported
"  in this version.
  READ TABLE t_meins_list INTO s_meins_list INDEX 1.
  MOVE s_meins_list-meins TO msgv1.
  READ TABLE t_meins_list INTO s_meins_list INDEX 2.
  MOVE s_meins_list-meins TO msgv2.
  CALL FUNCTION 'CM_F_MESSAGE'
    EXPORTING
      arbgb            = '61'
      msgnr            = '551'
      msgty            = 'W'
      msgv1            = msgv1
      msgv2            = msgv2
      object_dependent = 'X'
    EXCEPTIONS
      OTHERS           = 0.
  MESSAGE w551(61) WITH msgv1 msgv2 INTO message.
  EXIT.
ENDIF.
"  Fill apportionment structure.
es_split-csplit = 'BADI'.
LOOP AT t_output_list INTO s_output_list.
  s_split_aqzif-kuppl = s_output_list-matnr.
  s_split_aqzif-aqzif = s_output_list-quant.
  INSERT s_split_aqzif INTO TABLE et_split_aqzif.
ENDLOOP.


TYPES:
    BEGIN OF output_list_str,
    matnr TYPE matnr,
    quant TYPE ml4h_quantity,
    meins TYPE ml4h_meins,
    menge TYPE posmenge,
    END OF output_list_str.


SELECT ckmlmv003~matnr AS kuppl
    ckmlmv003~out_menge AS menge
    ckmlmv003~meinh AS meins
    makz~ziffr AS ziffr
INTO CORRESPONDING FIELDS OF TABLE lt_split_aqzif
FROM ckmlmv003
JOIN marc
ON marc~matnr = ckmlmv003~matnr AND
    marc~werks = ckmlmv003~werks
JOIN makz
ON makz~kuppl = ckmlmv003~matnr AND
    makz~werks = ckmlmv003~werks
WHERE ckmlmv003~kalnr_in EQ procnr AND
    ckmlmv003~mgtyp EQ ls_runperiod-mgtyp AND
    ckmlmv003~gjahr EQ ls_runperiod-gjahr AND
    ckmlmv003~perio EQ ls_runperiod-poper AND
    marc~fxpru = ' '.
CHECK NOT lt_split_aqzif[] IS INITIAL.

IF sy-subrc = 0.
    SELECT ziffr " ����� �� �������, ����� ���� ��������
    INTO CORRESPONDING FIELDS OF TABLE lt_makz " �� �������� ������� ��� � ���� �������
    FROM makz
    FOR ALL ENTRIES IN lt_split_aqzif " ����������! ��� ���� �������!
    WHERE matnr EQ matnr_process AND
        werks EQ werks_process AND
        kuppl EQ matnr_output AND
        datub >= ls_runperiod-last_day AND
        matnr = lt_split_aqzif-kuppl AND
        bmein = lt_split_aqzif-meins. " ����������������� ������� ���������, ����� ���� ������
ENDIF.
CHECK NOT lt_makz[] IS INITIAL.

   LOOP AT t_output_list INTO s_output_list.
     s_split_aqzif-kuppl = s_output_list-matnr.
     s_split_aqzif-aqzif = s_output_list-menge.
     INSERT s_split_aqzif INTO TABLE et_split_aqzif.
   ENDLOOP.