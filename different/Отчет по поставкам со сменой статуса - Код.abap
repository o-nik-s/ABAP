FORM data_select.
  DATA: v_vbelv TYPE vbfa-vbelv,
        t_vbak  TYPE TABLE OF vbak WITH HEADER LINE,
        wa_vbak LIKE LINE OF t_vbak.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE @itab " gt_vbeln
    FROM likp
    LEFT JOIN tvlst ON ( likp~lifsk = tvlst~lifsp AND tvlst~spras = 'R' )
    WHERE likp~vbeln IN @s_vbeln
      AND likp~lifsk IN @s_lifsk
      AND likp~bldat IN @s_bldat
      AND likp~lfart = @p_lfart.
  SORT itab ASCENDING BY vbeln.

  LOOP AT itab.
    SELECT SINGLE vbelv INTO v_vbelv FROM vbfa
      WHERE vbeln = itab-vbeln
        AND vbtyp_n = 'J'.
    SELECT SINGLE * INTO wa_vbak FROM vbak
      WHERE vbeln = v_vbelv.
    itab-bstnk = wa_vbak-bstnk.
    itab-bstdk = wa_vbak-bstdk.
    itab-delivery = wa_vbak-zzdelivery_point.
    MODIFY itab.
  ENDLOOP.
  DELETE itab WHERE delivery NOT IN s_werks.
ENDFORM.



------------------


  SELECT * INTO CORRESPONDING FIELDS OF TABLE @itab " gt_vbeln
    FROM likp
    LEFT JOIN tvlst ON ( likp~lifsk = tvlst~lifsp AND tvlst~spras = 'R' )
    LEFT JOIN vbfa ON ( likp~vbeln = vbfa~vbeln )
    left join vbak on ( vbfa~vbelv = vbak~vbeln )
    WHERE likp~vbeln IN @s_vbeln
      AND likp~lifsk IN @s_lifsk
      AND likp~bldat IN @s_bldat
      AND likp~lfart = @p_lfart
      AND vbfa~vbtyp_n = 'J'.
  SORT itab ASCENDING BY vbeln.
