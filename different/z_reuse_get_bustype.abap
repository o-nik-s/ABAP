FUNCTION z_reuse_get_bustype .
*"----------------------------------------------------------------------
*"  Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"     REFERENCE(IV_DATE) TYPE  DATS
*"  EXPORTING
*"     VALUE(EV_BUSTYPE) TYPE  ZEFI_BUSTYPE
*"     VALUE(EV_TEXT) TYPE  ZEFI_BUSTYPE_TEXT
*"----------------------------------------------------------------------

  DATA ls_data TYPE ty_reuse_get_bustype.

  SELECT SINGLE ztfi_bukrs_busty~bustype ztfi_busty~text
    INTO CORRESPONDING FIELDS OF ls_data
    FROM ztfi_bukrs_busty
    INNER JOIN ztfi_busty ON ztfi_busty~bustype = ztfi_bukrs_busty~bustype
    WHERE ztfi_bukrs_busty~bukrs = iv_bukrs
      AND ztfi_bukrs_busty~adatu <= iv_date
      AND ztfi_bukrs_busty~bdatu >= iv_date.
  ev_bustype = ls_data-bustype.
  ev_text = ls_data-text.

ENDFUNCTION.