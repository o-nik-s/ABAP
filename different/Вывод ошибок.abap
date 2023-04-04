FORM fm_zsd_d0036_message.

  DATA: msgno           TYPE syst-msgno,
        lwa_bapireturn1 TYPE bapireturn1.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.

  LOOP AT messtab.
    CLEAR: msgno.
    msgno = messtab-msgnr.
    CALL FUNCTION 'WRF_MESSAGE_TEXT_BUILD'
      EXPORTING
        p_msgid   = messtab-msgid
        p_msgno   = msgno
        p_msgty   = messtab-msgtyp
        p_msgv1   = messtab-msgv1
        p_msgv2   = messtab-msgv2
        p_msgv3   = messtab-msgv3
        p_msgv4   = messtab-msgv4
      IMPORTING
        es_return = lwa_bapireturn1.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        arbgb  = lwa_bapireturn1-id
        msgty  = lwa_bapireturn1-type
        msgv1  = lwa_bapireturn1-message_v1
        msgv2  = lwa_bapireturn1-message_v2
        msgv3  = lwa_bapireturn1-message_v3
        msgv4  = lwa_bapireturn1-message_v4
        txtnr  = lwa_bapireturn1-number
        zeile  = sy-tabix
      EXCEPTIONS
        OTHERS = 3.
  ENDLOOP.

  CALL FUNCTION 'MESSAGES_SHOW'
    EXPORTING
      batch_list_type = 'J'
      i_use_grid      = 'X'
    EXCEPTIONS
      OTHERS          = 3.
ENDFORM.