* 009/010 - Доставлен в ПВЗ ДМ / Возвращен в ИМ

  SELECT SINGLE *
    FROM vbak
    INTO CORRESPONDING FIELDS OF ls_vbak
    WHERE vbeln = uv_ordernum AND
          vbak~lifsk = 'ZP'.
  IF sy-subrc = 0.
    SELECT vbfa~vbeln vbtyp_n vbelv
      FROM vbfa
      JOIN vbak ON vbak~vbeln = vbfa~vbelv
      INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
      WHERE vbak~vbeln = uv_ordernum AND
          	vbak~lifsk = 'ZP' AND
            vbfa~vbelv = uv_ordernum AND
            vbfa~vbtyp_n = 'J'.
    IF sy-subrc = 0.
      SELECT likp~vbeln likp~lifsk
        FROM likp
        INTO CORRESPONDING FIELDS OF TABLE lt_likp
        WHERE likp~vbeln = lt_vbfa-vbeln.
      IF sy-subrc = 0.
        CASE lt_likp-lifsk.
          WHEN 'ZR'.
            cv_status = '009'.
            cv_status_txt = TEXT-009. " 'Доставлен в ПВЗ ДМ'.
            EXIT.
          WHEN 'ZV'.
            cv_status = '010'.
            cv_status_txt = TEXT-010. " 'Возвращен в ИМ'.
            EXIT.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.

----------------------------------------------------------------


      WHEN 'ZR'.
        SELECT vbfa~vbeln
          FROM vbfa
          JOIN vbak ON vbak~vbeln = vbfa~vbelv
          INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
          WHERE vbfa~vbelv = uv_ordernum AND
                vbfa~vbtyp_n = 'J'.
        IF sy-subrc <> 0.
          cv_status = '009'.
          cv_status_txt = TEXT-009." 'Доставлен в ПВЗ ДМ'.
          "         EXIT.
        ENDIF.

      WHEN 'ZV'.
        SELECT vbfa~vbeln
          FROM vbfa
          JOIN vbak ON vbak~vbeln = vbfa~vbelv
          INTO CORRESPONDING FIELDS OF TABLE lt_vbfa
          WHERE vbfa~vbelv = uv_ordernum AND
                vbfa~vbtyp_n = 'J'.
        IF sy-subrc <> 0.
          cv_status = '010'.
          cv_status_txt = TEXT-010." 'Возвращен в ИМ'.
          "         EXIT.
        ENDIF.