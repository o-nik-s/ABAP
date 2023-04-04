FORM header_to_file_.

  TRANSFER '[Header]' TO txt_file. " Можно попробовать слить все в файл и лишь потом писать

  CLEAR string.
  CONCATENATE string t_header-vgbel INTO string.
  CONCATENATE string t_header-bldat INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header-netwr_mwsbk INTO string SEPARATED BY ';'.

*  PERFORM convert_and_concatenate USING t_header-delivery CHANGING string.

*  PERFORM convert USING t_header-delivery CHANGING strout.
*  CONCATENATE string strout INTO string SEPARATED BY ';'.

*  CONCATENATE string t_header-delivery INTO string SEPARATED BY ';'.


*  PERFORM convert USING t_header-kzwi5_10 CHANGING strout.
*  CONCATENATE string strout INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header-kzwi5_10 INTO string SEPARATED BY ';'.

*  CONCATENATE string t_header-kzwi5_18 INTO string SEPARATED BY ';'.
  CONCATENATE string t_header-waerk INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header-one INTO string SEPARATED BY ';'.
  CONCATENATE string t_header-empty_1 INTO string SEPARATED BY ';'.
  CONCATENATE string t_header-empty_2 INTO string SEPARATED BY ';'.

  PERFORM convert_and_concatenate USING t_header-drogery CHANGING string.
*  PERFORM convert USING t_header-drogery CHANGING strout.
*  CONCATENATE string strout INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header-drogery INTO string SEPARATED BY ';'.


  CONCATENATE string t_header-po_box_1 INTO string SEPARATED BY ';'.
  PERFORM convert_and_concatenate USING t_header-name1 CHANGING string.
*  CONCATENATE string t_header-name1 INTO string SEPARATED BY ';'.
  CONCATENATE string t_header-po_box_2 INTO string SEPARATED BY ';'.

*  CONCATENATE string t_header- INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header- INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header- INTO string SEPARATED BY ';'.

*  CONCATENATE string t_  header-kzwi5_10 INTO string SEPARATED BY ';'.
*  CONCATENATE string t_header-kzwi5_18 INTO string SEPARATED BY ';'.

*  data str_netwr_mwsbk type string.
*  CALL FUNCTION 'HRCM_AMOUNT_TO_STRING_CONVERT'
*    EXPORTING
*      betrg = t_header-netwr_mwsbk
*      WAERS = gs_vbrk-waerk
*    IMPORTING
*      STRING = str_netwr_mwsbk.
  " CONCATENATE string t_header-netwr_mwsbk INTO string SEPARATED BY ';'.

*  DATA strin TYPE string.
*  strin = 'АБВГДЕЁ'.
*  PERFORM convert USING strin CHANGING strout. " АБВГД ЕЁЖЗИЙКЛМН ОПРСТУФХЦЧШЩЪЫЬЭЮЯ абвгдеёжзийклмнопрстуфхцчшщъыьэюя
*  CONCATENATE string strout INTO string SEPARATED BY ';'.

  TRANSFER string TO txt_file.
ENDFORM.

FORM convert_and_concatenate
  USING strin
  CHANGING string. " TYPE string.
  CLEAR strout.
  PERFORM convert USING strin(15) CHANGING strout.
  CONCATENATE string strout INTO string SEPARATED BY ';'.
ENDFORM.

FORM create_converter.
  CREATE OBJECT converter
    EXPORTING
       incode = iv_codepage_fr
       outcode = iv_codepage_to
*      outcode = '1504'
*      outcode          = '4110' " UTF-8
*      outcode          = '4120' " UTF-8
    EXCEPTIONS
      invalid_codepage = 1
      internal_error   = 2
      OTHERS           = 3.
ENDFORM.

FORM convert
  USING strin
  CHANGING strout TYPE string.

  CLEAR strout.
  CALL METHOD converter->convert
      EXPORTING
        inbuff         = strin
        inbufflg       = 0
        outbufflg      = 0
      IMPORTING
        outbuff        = strout
      EXCEPTIONS
        internal_error = 1
        OTHERS         = 2.
ENDFORM.





FORM file_create_txt.

  " DATA gl_cl_text TYPE REF TO cl_umg_condition_editor. " Наследник от CL_GUI_TEXTEDIT, добавлен доступ к некоторым protected методам

  data:
      begin of ltp_address,
        line(400) type c,
      end of ltp_address,
      ls_address LIKE ltp_address,
      lt_address LIKE ltp_address OCCURS 0.
      " ls_address LIKE LINE OF lt_address.

  FIELD-SYMBOLS:
         <ln_data> LIKE LINE OF gt_data.
        " <st_data> TYPE string.

  DATA: st_data TYPE string.


  DATA mess TYPE string.
  DATA str TYPE string.


  ls_address = 'test 0'.
  APPEND ls_address TO lt_address.
  ls_address = 'example 0'.
  APPEND ls_address TO lt_address.


  OPEN DATASET txt_file FOR OUTPUT "   FOR APPENDING
*   IN TEXT MODE ENCODING DEFAULT MESSAGE mess.
    IN TEXT MODE
*    IN LEGACY BINARY MODE
    ENCODING DEFAULT
    MESSAGE mess.
  IF sy-subrc ne 0.
    MESSAGE mess TYPE 'I'.
  ENDIF.

  PERFORM header_to_file.


  " CALL METHOD gl_cl_text->table_to_string
  "   EXPORTING
  "     im_table  = l_i_lines
  "   IMPORTING
  "     ex_string = l_text
  "   EXCEPTIONS
  "     OTHERS    = 5.

*CALL FUNCTION 'SWA_STRING_FROM_TABLE'
*  EXPORTING
*    character_table            = gt_data
**   NUMBER_OF_CHARACTERS             =
**   LINE_SIZE                        =
*    keep_trailing_spaces       = 'X'
**   CHECK_TABLE_TYPE                 = ' '
*  IMPORTING
*    character_string           = str
*  EXCEPTIONS
*    no_flat_charlike_structure = 1
*    OTHERS                     = 2.
*
*IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.


*  loop at gt_data INTO <ln_data>.
*    " CONCATENATE str ln_data INTO st_data SEPARATED BY space.
*    TRANSFER st_data TO txt_file.
*  endloop.


*  loop at lt_address INTO ls_address.
*    " CONCATENATE str ln_data INTO st_data SEPARATED BY space.
*    TRANSFER ls_address TO txt_file.
*  endloop.


  " LOOP at lt_address INTO ls_address.
  "   TRANSFER ls_address TO txt_file.
  " ENDLOOP.

  " LOOP at gt_data ASSIGNING <ln_data>.
*   Transfer the Recored to application server
  "   CONCATENATE ln_data INTO ls_result
  "     SEPARATED BY space.
  "   TRANSFER <st_data> TO txt_file.

  " ENDLOOP.

  CLOSE DATASET txt_file.

ENDFORM.












FORM body_data.
  DATA:
        ls_vbdpr LIKE LINE OF gt_vbdpr,
        s_vbrp TYPE vbrp,
        s_mara TYPE mara,
        s_maw1 TYPE maw1,
        s_marm TYPE marm,
        s_t179t TYPE t179t.
  FIELD-SYMBOLS:
                 <fs_body>  LIKE LINE OF t_body.
  CLEAR t_body.
  SORT gt_vbdpr BY posnr ASCENDING.
  LOOP AT gt_vbdpr INTO ls_vbdpr.
      SELECT SINGLE *
        INTO s_vbrp
        FROM vbrp
        WHERE matnr = ls_vbdpr-matnr.
      t_body-matnr = s_vbrp-matnr.
      SELECT SINGLE *
        INTO s_mara
        FROM mara
        WHERE matnr = s_vbrp-matnr.
      t_body-zzpricetxt = s_mara-zzpricetxt.
      " Здесь vtext
      IF s_mara-prdha = ''.
        t_body-vtext = '_'.
      ELSE.
        " v_prhda = s_mara-prdha(5).
        SELECT SINGLE *
         INTO s_t179t
         FROM t179t
         WHERE prodh = s_mara-prdha(5).
        t_body-vtext = s_t179t-vtext.
      ENDIF.
      SELECT SINGLE *
        INTO s_maw1
        FROM maw1
        WHERE matnr = s_vbrp-matnr.
      t_body-wherl = s_maw1-wherl.
      IF t_body-wherl = ''.
        t_body-wherl = '_'.
      ENDIF.
      t_body-fkimg = s_vbrp-fkimg.
      t_body-kzwi5_1 = ( s_vbrp-kzwi5 + s_vbrp-kzwi3 ) / s_vbrp-fkimg.
      t_body-kzwi3_1 = s_vbrp-kzwi3 / s_vbrp-fkimg.
      SELECT SINGLE *
        INTO s_marm
        FROM marm
        WHERE matnr = s_vbrp-matnr.
      t_body-ean11 = s_vbrp-ean11.
      t_body-kzwi4_1_1 = s_vbrp-kzwi4 / s_vbrp-fklmg.
      t_body-kzwi4 = s_vbrp-kzwi4.
      CASE s_vbrp-ktgrm.
        WHEN 'T1'.
          t_body-nds = 0.
        WHEN 'T2'.
          t_body-nds = 10.
        WHEN 'T3'.
          t_body-nds = 18.
        WHEN OTHERS.
      ENDCASE.
      t_body-kzwi4_1_1 = t_body-kzwi4_1_2.
  ENDLOOP.
ENDFORM.



FORM line_to_file.
  DATA: ld_i_tab_converted_data  TYPE TRUXS_T_TEXT_DATA,
        it_i_tab_sap_data	TYPE STANDARD TABLE OF type_header,
        wa_i_tab_sap_data	LIKE LINE OF it_i_tab_sap_data.

  if SY-UNAME = 'MIGOSHIN'.
    while SY-SUBRC = 0.
    endwhile.
  endif.

  READ TABLE t_header INTO wa_i_tab_sap_data INDEX 0.
  wa_i_tab_sap_data-VGBEL = 0160000002.
  wa_i_tab_sap_data-DELIVERY = 'Поставка'.
  append wa_i_tab_sap_data to it_i_tab_sap_data.

 CALL FUNCTION 'SAP_CONVERT_TO_TXT_FORMAT'
  EXPORTING
    i_field_seperator =          ';' " ld_i_field_seperator
*    i_line_header =              ld_i_line_header
*    i_filename =                 txt_file " ld_i_filename
*    i_appl_keep =                ld_i_appl_keep
   TABLES
     i_tab_sap_data =            it_i_tab_sap_data
  CHANGING
    i_tab_converted_data =       ld_i_tab_converted_data
   EXCEPTIONS
     CONVERSION_FAILED =          1
     .  "  SAP_CONVERT_TO_TXT_FORMAT

 IF SY-SUBRC EQ 0.
   "All OK
 ELSEIF SY-SUBRC EQ 1. "Exception
   "Add code for exception here
 ENDIF.

ENDFORM.



*  exec sql.
*    SELECT sum( kzwi5 ) INTO :h_kzwi5_10 FROM gt_vbrp WHERE ktgrm = 'T2'.
*  endexec.


FORM line_to_file_.
*  data: string type string.
  data: fldstr type string.
  data: substr type string.
  field-symbols: <t_head>, <fs>.

  do.
    assign component sy-index of structure t_header to <fs>.
    if sy-subrc <> 0.
      exit.
    endif.
    fldstr = <fs>.
    concatenate substr fldstr into substr separated by ';'. " space.
    shift substr left deleting leading ';'. " space.
  enddo.

  TRANSFER substr TO txt_file.
ENDFORM.


*  WRITE t_header-kzwi5_18 TO str.