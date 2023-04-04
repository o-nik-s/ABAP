FUNCTION zsd_d0041_update_rk .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(IS_VBAK) TYPE  VBAK
*"  CHANGING
*"     REFERENCE(CT_VBPA) TYPE  TT_VBPAVB
*"----------------------------------------------------------------------

  DATA:
    ls_zsdt_d0041 TYPE zsdt_d0041,
    ls_kna1       TYPE kna1,
    err00         TYPE string.

  FIELD-SYMBOLS:
                 <fs_vbpa>  LIKE LINE OF ct_vbpa.


*  IF sy-uname = 'OSUSLOVA'.
*    WHILE sy-subrc = 0.
*    ENDWHILE.
*  ENDIF.


*  CHECK is_vbak-zzpvz_holder NE ''.

  IF is_vbak-zzpvz_holder NE ''.

    LOOP AT ct_vbpa ASSIGNING <fs_vbpa> WHERE parvw EQ 'RK'.

      SELECT SINGLE *
        INTO ls_zsdt_d0041
        FROM zsdt_d0041
        WHERE
          agent EQ is_vbak-zzpvz_holder.

      CHECK sy-subrc EQ 0.

      SELECT SINGLE *
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


    CLEAR ls_zsdt_d0041.

    SELECT SINGLE *
      INTO ls_zsdt_d0041
      FROM zsdt_d0041
      WHERE
        zzpvz_holder EQ is_vbak-zzpvz_holder.

    IF sy-subrc EQ 0.
*      <fs_vbpa>-kunnr = ls_zsdt_d0041-courier.

      LOOP AT ct_vbpa ASSIGNING <fs_vbpa> WHERE parvw EQ 'RG'.

*        <fs_vbpa>-kunnr = ls_zsdt_d0041-courier.

      ENDLOOP.

    ELSE.
      CONCATENATE TEXT-e00 is_vbak-zzpvz_holder INTO err00 SEPARATED BY space.
      MESSAGE err00 TYPE 'E'.
    ENDIF.


  ELSE.


  ENDIF.

ENDFUNCTION.