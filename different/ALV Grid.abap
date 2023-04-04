
DATA: itab    TYPE zsdi_d0049, " TABLE OF zsdt_d0049 WITH HEADER LINE,
      wa_itab LIKE LINE OF itab. " gt_vbeln

DATA: custom_container TYPE REF TO cl_gui_custom_container,
      alv_grid         TYPE REF TO cl_gui_alv_grid,
      fcat             TYPE lvc_t_fcat.

DATA: " Для работы с выделенными строками
  gi_index_rows TYPE lvc_t_row, " WITH HEADER LINE,
  " g_selected_row LIKE lvc_s_row
  wa_index_rows LIKE LINE OF gi_index_rows.

" Классы для тулбара
CLASS cl_trans_g_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
        handle_toolbar
                    FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive, handle_user_command
                    FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS cl_trans_g_event_receiver IMPLEMENTATION.
  METHOD handle_toolbar.
    PERFORM method_trans_toolbar USING e_object.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM method_trans_user_command USING e_ucomm.
  ENDMETHOD.
ENDCLASS.


FORM fill_col
  USING db fieldname ref_field ref_table length just
  CHANGING fcat TYPE lvc_t_fcat.

  DATA: wa_fcat TYPE lvc_s_fcat.
  CLEAR wa_fcat.

  IF ( 'X' = db ).
    wa_fcat-ref_field = ref_field.
    wa_fcat-ref_table = ref_table.
  ELSE.
    wa_fcat-coltext = ref_field.
    wa_fcat-seltext = ref_table.
  ENDIF.

  wa_fcat-icon = 'X'.
  wa_fcat-fieldname = fieldname.
  wa_fcat-outputlen = length.
  wa_fcat-just = just.

  APPEND wa_fcat TO fcat.
ENDFORM.    " fill_col

MODULE create_obj OUTPUT.

  DATA: trans_g_event_receiver TYPE REF TO cl_trans_g_event_receiver, " Для тулбара
        layout                 TYPE lvc_s_layo.

  CREATE OBJECT custom_container
    EXPORTING
      container_name = 'SPECIAL_ELEMENT'.
  CREATE OBJECT alv_grid
    EXPORTING
      i_parent = custom_container.
  CREATE OBJECT trans_g_event_receiver. " Тулбар

  " layout-grid_title = TEXT-001.
  " layout-ctab_fname = 'CELLCOLORS'.
  layout-zebra = 'X'.
  layout-sel_mode = 'A'.

  " Тулбар
  SET HANDLER trans_g_event_receiver->handle_toolbar FOR alv_grid.
  SET HANDLER trans_g_event_receiver->handle_user_command FOR alv_grid.


  LOOP AT gt_werks_price_tag INTO wa_price_tag.
    CLEAR wa_itab.
    MOVE-CORRESPONDING wa_price_tag TO wa_itab.
    APPEND wa_itab TO itab.
  ENDLOOP.

  PERFORM fill_col USING '' 'COLOUR' 'Цвет ценника' 'Цвет ценника' '2' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'MATNR' 'Номер материала' 'Номер материала' '8' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'WERKS' 'Завод' 'Завод' '8' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'STOCK' 'Количество товаров на складе' 'Количество товаров на складе' '6' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'ZZPRICETXT' 'Название для ценника' 'Название для ценника' '20' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'WHERL' 'Код страны происхождения' 'Код страны происхождения' '3' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'LANDX' 'Страна происхождения' 'Страна происхождения' '10' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'EAN11' 'Европейский номер товара (EAN)' 'Европейский номер товара (EAN)' '14' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'MEINH' 'Единица измерения для просмотра' 'Единица измерения для просмотра' '3' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'VAKEY' 'Переменный ключ 100 байтов' 'Переменный ключ 100 байтов' '27' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'KNUMH' 'Номер записи условия' 'Номер записи условия' '10' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'KSCHL' 'Вид условия' 'Вид условия' '5' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'DATAB' 'Дата начала действия' 'Дата начала действия' '10' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'DATBI' 'Дата окончания действия' 'Дата окончания действия' '10' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'KBETR' 'Регулярная цена' 'Регулярная цена' '7' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'DISC_KBETR' 'Актуальная цена' 'Актуальная цена' '7' 'L' CHANGING fcat.
*  PERFORM fill_col USING '' 'KOPOS' 'Порядковый номер условия' 'Порядковый номер условия' '3' 'L' CHANGING fcat.
*  PERFORM fill_col USING '' 'KBETR' 'Сумма/процентная ставка условия при отсутствии шкалы' 'Сумма/процентная ставка условия при отсутствии шкалы' '7' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'PRDHA' 'Иерархия продуктов' 'Иерархия продуктов' '18' 'L' CHANGING fcat.
  PERFORM fill_col USING '' 'VTEXT' 'Название' 'Название' '15' 'L' CHANGING fcat.

  CALL METHOD alv_grid->set_table_for_first_display
  " EXPORTING I_Structure_Name = 'ITAB'
  " EXPORTING I_Structure_Name = fcat
    EXPORTING
      is_layout       = layout
      " С помощью каталогов описывается своя структура и передается
    CHANGING
      it_outtab       = itab[]
      it_fieldcatalog = fcat.

  " CALL METHOD ALV_Grid->Refresh_Table_Display.

ENDMODULE.


MODULE bpo_0100_status OUTPUT.
  SET PF-STATUS 'Z_STS'.
ENDMODULE.

MODULE pai_0100_status INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'Z_STS'.
  SET TITLEBAR 'Z_TTL'.
ENDMODULE.


* Добавление кнопки в тулбар
FORM method_trans_toolbar USING p_e_object TYPE REF TO cl_alv_event_toolbar_set.
  DATA: toolbar TYPE stb_button.

* разделитель
  CLEAR toolbar.
  toolbar-butn_type = 3.
  APPEND toolbar TO p_e_object->mt_toolbar.

* кнопка
  CLEAR toolbar.
  toolbar-function = 'DELIVERY_CHANGE'.
  toolbar-icon = icon_change.
  toolbar-butn_type = 0.
  toolbar-text = TEXT-002.
  APPEND toolbar TO p_e_object->mt_toolbar.

* кнопка
  CLEAR toolbar.
  toolbar-function = 'RETURN_TO_ONLINE_SHOP'.
  toolbar-icon = icon_retail_store.
  toolbar-butn_type = 0.
  toolbar-text = TEXT-003.
  APPEND toolbar TO p_e_object->mt_toolbar.
ENDFORM.

* Обработка команд тулбара
FORM method_trans_user_command USING p_e_ucomm TYPE sy-ucomm.
  CALL METHOD alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = gi_index_rows. " В gi_index_rows будут строки с индексами выделенных строк alv. /Поле INDEX/
  CASE p_e_ucomm.
    WHEN 'DELIVERY_CHANGE'.
      IF gi_index_rows IS NOT INITIAL.
*        PERFORM delivery_change USING p1_lifsk p1_lifsk_vtext.
*        PERFORM delivery_change_message.
      ENDIF.
    WHEN 'RETURN_TO_ONLINE_SHOP'.
      IF gi_index_rows IS NOT INITIAL.
*        PERFORM delivery_change USING p2_lifsk p2_lifsk_vtext.
*        PERFORM return_to_online_shop.
*        PERFORM delivery_change_message.
      ENDIF.
  ENDCASE.
  CALL METHOD alv_grid->check_changed_data.
  CALL METHOD alv_grid->refresh_table_display.
ENDFORM.