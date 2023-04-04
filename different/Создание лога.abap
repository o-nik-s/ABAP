DATA: gt_log_header    TYPE balhdr_t,
      gt_log_handle    TYPE bal_t_logh,
      gv_handle        TYPE balloghndl,
      gs_msg           TYPE bapiret2,
      gv_free_text(85) TYPE c.



*&---------------------------------------------------------------------*
*&  Include           ***_LOG
*&---------------------------------------------------------------------*
DATA: gs_log  TYPE bal_s_log.
DATA: gv_log_handle TYPE balloghndl.

DATA: gv_msg_was_displayed TYPE boolean.
DATA: gv_msg_was_logged TYPE boolean.
DATA: gs_msg_handle TYPE balmsghndl.

DATA: gv_free_text(85) TYPE c.


*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG_SY
*&---------------------------------------------------------------------*
*       Открыть журнал приложений.
*----------------------------------------------------------------------*
*      -->US_SY      text
*----------------------------------------------------------------------*
FORM open_log USING uv_objname TYPE balobj_d
                    uv_subobjname TYPE balsubobj.

  gs_log-object = uv_objname.
  gs_log-subobject = uv_subobjname.
*  gs_log-extnumber = logname.
  gs_log-alprog = sy-repid.
  gs_log-altcode = sy-tcode.
  gs_log-aluser = sy-uname.
  gs_log-aldate = sy-datum.
  gs_log-altime = sy-uzeit.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = gs_log
    IMPORTING
      e_log_handle            = gv_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "OPEN_LOG

*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG_SY
*&---------------------------------------------------------------------*
*       Запись в журнал
*----------------------------------------------------------------------*
*      -->US_SY      text
*----------------------------------------------------------------------*
FORM write_log_sy USING us_sy TYPE syst.
  DATA: l_s_msg TYPE bal_s_msg.

  MOVE-CORRESPONDING us_sy TO l_s_msg.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle        = gv_log_handle
      i_s_msg             = l_s_msg
    IMPORTING
      e_s_msg_handle      = gs_msg_handle
      e_msg_was_logged    = gv_msg_was_logged
      e_msg_was_displayed = gv_msg_was_displayed
    EXCEPTIONS
      log_not_found       = 1
      msg_inconsistent    = 2
      log_is_full         = 3
      OTHERS              = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "WRITE_LOG_SY

*----------------------------------------------------------------------*
*      Form  OUTPUT_ADD_TEXT
*----------------------------------------------------------------------*
*       Building up the Application log
*----------------------------------------------------------------------*
FORM write_text USING iv_msgty TYPE sy-msgty
                      iv_text LIKE gv_free_text.

  CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
    EXPORTING
      i_log_handle     = gv_log_handle
      i_msgty          = iv_msgty
      i_text           = iv_text
    EXCEPTIONS
      log_not_found    = 1
      msg_inconsistent = 2
      log_is_full      = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " OUTPUT_ADD_TEXT

*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG
*&---------------------------------------------------------------------*
*       Запись в журнал
*----------------------------------------------------------------------*
*      -->UV_TYPE    text
*      -->UV_ID      text
*      -->UV_NUMBER  text
*      -->UV_MSG1    text
*      -->UV_MSG2    text
*      -->UV_MSG3    text
*      -->UV_MSG4    text
*----------------------------------------------------------------------*
FORM write_log USING uv_type uv_id uv_number
                     uv_msg1 uv_msg2 uv_msg3 uv_msg4.

  DATA: ls_msg TYPE bal_s_msg.

  ls_msg-msgty = uv_type.
  ls_msg-msgid = uv_id.
  ls_msg-msgno = uv_number.
  ls_msg-msgv1 = uv_msg1.
  ls_msg-msgv2 = uv_msg2.
  ls_msg-msgv3 = uv_msg3.
  ls_msg-msgv4 = uv_msg4.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle        = gv_log_handle
      i_s_msg             = ls_msg
    IMPORTING
      e_s_msg_handle      = gs_msg_handle
      e_msg_was_logged    = gv_msg_was_logged
      e_msg_was_displayed = gv_msg_was_displayed
    EXCEPTIONS
      log_not_found       = 1
      msg_inconsistent    = 2
      log_is_full         = 3
      OTHERS              = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "WRITE_LOG

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       Отображение журнала на экране
*----------------------------------------------------------------------*
FORM display_log.
  DATA: lt_log_handle TYPE bal_t_logh.
  REFRESH lt_log_handle.

  APPEND gv_log_handle TO lt_log_handle.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
*     I_S_DISPLAY_PROFILE  =
      i_t_log_handle       = lt_log_handle
*     I_T_MSG_HANDLE       =
*     I_S_LOG_FILTER       =
*     I_S_MSG_FILTER       =
*     I_T_LOG_CONTEXT_FILTER       =
*     I_T_MSG_CONTEXT_FILTER       =
*     I_AMODAL             = 'X'
*     I_SRT_BY_TIMSTMP     = ' '
*   IMPORTING
*     E_S_EXIT_COMMAND     =
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_LOG
*&---------------------------------------------------------------------*
*       Сохранение журнала
*----------------------------------------------------------------------*
FORM save_log.

  DATA: lt_log_handle TYPE bal_t_logh.

  REFRESH lt_log_handle.

  APPEND gv_log_handle TO lt_log_handle.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_client         = sy-mandt
*     I_IN_UPDATE_TASK = ' '
*     i_save_all       = 'X'
      i_t_log_handle   = lt_log_handle
* IMPORTING
*     E_NEW_LOGNUMBERS =
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "SAVE_LOG

*&---------------------------------------------------------------------*
*&      Form  CLEAR_LOG
*&---------------------------------------------------------------------*
*       Очистка журнала
*----------------------------------------------------------------------*
FORM clear_log.
  CALL FUNCTION 'BAL_LOG_MSG_DELETE_ALL'
    EXPORTING
      i_log_handle  = gv_log_handle
    EXCEPTIONS
      log_not_found = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.