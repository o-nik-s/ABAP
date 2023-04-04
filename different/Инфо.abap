    CLEAR ls_kna1.
    SELECT SINGLE 
      INTO ls_kna1
      FROM kna1
      WHERE
        kunnr EQ ls_zsdt_d0041-agent.

    IF sy-subrc EQ 0.
      flag = 0.
      LOOP AT ct_vbpa ASSIGNING <fs_vbpa> WHERE parvw EQ 'RG'.
        <fs_vbpa>-kunnr = ls_zsdt_d0041-agent.
        <fs_vbpa>-adrnr = ls_kna1-adrnr.
        <fs_vbpa>-land1 = ls_kna1-land1.
        <fs_vbpa>-xcpdk = ls_kna1-xcpdk.
        ADD 1 TO flag.
      ENDLOOP.
      IF flag EQ 0.
        APPEND INITIAL LINE TO ct_vbpa ASSIGNING <fs_vbpa>.
        <fs_vbpa>-kunnr = ls_zsdt_d0041-agent.
        <fs_vbpa>-adrnr = ls_kna1-adrnr.
        <fs_vbpa>-land1 = ls_kna1-land1.
        <fs_vbpa>-xcpdk = ls_kna1-xcpdk.
      ENDIF.
    ENDIF.

    CLEAR ls_kna1.
    SELECT SINGLE 
      INTO ls_kna1
      FROM kna1
      WHERE
        kunnr EQ ls_zsdt_d0041-courier.

    IF sy-subrc EQ 0.
      flag = 0.
      LOOP AT ct_vbpa ASSIGNING <fs_vbpa> WHERE parvw EQ 'RK'.
        <fs_vbpa>-kunnr = ls_zsdt_d0041-courier.
        <fs_vbpa>-adrnr = ls_kna1-adrnr.
        <fs_vbpa>-land1 = ls_kna1-land1.
        <fs_vbpa>-xcpdk = ls_kna1-xcpdk.
        ADD 1 TO flag.
      ENDLOOP.
      IF flag EQ 0.
        APPEND INITIAL LINE TO ct_vbpa ASSIGNING <fs_vbpa>.
        <fs_vbpa>-kunnr = ls_zsdt_d0041-courier.
        <fs_vbpa>-adrnr = ls_kna1-adrnr.
        <fs_vbpa>-land1 = ls_kna1-land1.
        <fs_vbpa>-xcpdk = ls_kna1-xcpdk.
      ENDIF.
    ENDIF.



Include MV45AFZZ.

ENHANCEMENT 1  ZENH_MV45AFZZ_MOVE_FIELD_VBAP.    "active version

  CALL FUNCTION 'ZSD_D0041_UPDATE_RK'
    EXPORTING
      is_vbak       = vbak
    changing
      ct_vbpa       = xvbpa[].

ENDENHANCEMENT.
ENHANCEMENT 2  ZSD_DEF_RULE_SO.    "active version



if SY-UNAME = 'OSUSLOVA'.
  while SY-SUBRC = 0.
  endwhile.
endif.




����������� ���

FUNCTION zsd_d0041_update_rk .
"----------------------------------------------------------------------
""��������� ���������:
"  IMPORTING
"     REFERENCE(IS_VBAK) TYPE  VBAK
"  CHANGING
"     REFERENCE(CT_VBPA) TYPE  TT_VBPAVB
"----------------------------------------------------------------------

  DATA:
    ls_zsdt_d0041 TYPE zsdt_d0041,
    ls_kna1       TYPE kna1.

  FIELD-SYMBOLS:
                 <fs_vbpa>  LIKE LINE OF ct_vbpa.


if SY-UNAME = 'OSUSLOVA'.
  while SY-SUBRC = 0.
  endwhile.
endif.


  CHECK is_vbak-zzpvz_holder NE ''.

  IF is_vbak-zzpvz_holder NE ''.

    LOOP AT ct_vbpa ASSIGNING <fs_vbpa> WHERE parvw EQ 'RK'.

      SELECT SINGLE 
        INTO ls_zsdt_d0041
        FROM zsdt_d0041
        WHERE
          agent EQ is_vbak-zzpvz_holder.

      CHECK sy-subrc EQ 0.

      SELECT SINGLE 
        INTO ls_kna1
        FROM kna1
        WHERE
          kunnr EQ ls_zsdt_d0041-courier.

      CHECK sy-subrc EQ 0.

      <fs_vbpa>-kunnr = ls_zsdt_d0041-courier.
      <fs_vbpa>-adrnr = ls_kna1-adrnr.
      <fs_vbpa>-land1 = ls_kna1-land1.
      <fs_vbpa>-xcpdk = ls_kna1-xcpdk.

    ENDLOOP.

  ELSE.

  ENDIF.

ENDFUNCTION.