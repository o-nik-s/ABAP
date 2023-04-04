*&---------------------------------------------------------------------*
*& Report  Z_APPSFILE_TRANS_FTP
*&
*&---------------------------------------------------------------------*
REPORT  z_appsfile_trans_ftp.
TYPE-POOLS : rsanm.
************************************************************************
*                TYPES DECLARATION                                     *
************************************************************************
TYPES: BEGIN OF ty_ftp_det,
        ftp_id          TYPE zftp_id,
        sysid           TYPE sysysid,
        ftp_ip_address  TYPE z_ftp_ip_address,
        ftp_user        TYPE z_ftp_user,
        ftp_password    TYPE z_ftp_password,
        ftp_folder      TYPE z_ftp_folder,
       END OF ty_ftp_det,

    BEGIN OF ty_appsfile,
        name TYPE epsfilnam,
        str1 TYPE string,
        str2 TYPE string,
        str3 TYPE string,
        str4 TYPE string,
        str5 TYPE string,
        final TYPE string,
     END OF ty_appsfile,

     BEGIN OF ty_filepath,
       pathintern TYPE pathintern,
       pathname TYPE pathname,
     END OF ty_filepath.

DATA: BEGIN OF t_ftp OCCURS 10,
 line(100),
END OF t_ftp.
************************************************************************
*                INTERNAL TABLE DECLARATION                            *
************************************************************************
DATA:
t_dirlist    TYPE STANDARD TABLE OF epsfili,
t_ftp_det    TYPE STANDARD TABLE OF ty_ftp_det,
t_appsdet    TYPE STANDARD TABLE OF ty_appsfile.
************************************************************************
*                WORK AREA DECLARATION                                *
************************************************************************
DATA:
wa_ftp_det    TYPE ty_ftp_det,
wa_appsdet    TYPE ty_appsfile.
************************************************************************
*                VARIABLE DECLARATION                                 *
************************************************************************
DATA:
v_wkfl1            LIKE epsf-epsdirnam ,
v_user(30)         TYPE c,
v_host             TYPE rfchost_ext,
v_psswd            TYPE z_ftp_password,
v_path             TYPE z_ftp_folder,
v_handle           TYPE i,
v_command(150)     TYPE c,
v_target_file(120) TYPE c,
v_apps(200)        TYPE c,
v_ftppath          TYPE string,
v_setflag          TYPE c.
************************************************************************
*                CONSTANT DECLARATION                                 *
************************************************************************
CONSTANTS :
 c_text_put    TYPE char3   VALUE 'put',                 "Text
 c_fdslash     TYPE char1   VALUE '\',                   "Slash
 c_ascii       TYPE char5   VALUE 'ascii',               "ASCII
 c_rfcdst      TYPE rfcdest VALUE 'SAPFTP'.
************************************************************************
*                        Selection Screen                              *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_logic  LIKE filename-fileintern OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:p_ftpid  TYPE zftp_id OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
PARAMETERS:
"Logical command name
p_exec LIKE sxpgcolist-name       NO-DISPLAY,
"Parameters of external program (string)
p_parm LIKE sxpgcolist-parameters NO-DISPLAY,
"Control indicator for external programs (trace level)
p_trac LIKE extcmdexim-trace DEFAULT '0' NO-DISPLAY.
*----------------------------------------------------------------------*
*                    At Selection Screen
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_logic.
  PERFORM f_f4_get_logical_name.
*----------------------------------------------------------------------*
*                    Start of Selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
  "Get the apps server/Source path name and source filenames
  PERFORM f_get_file_from_apps.
  "Fetch the FTP connection details from ZFTP Table
  PERFORM f_get_ftpconnection_details.
  "Open the ftp connection
  PERFORM f_open_ftp_connection.
  "FTP each file from Source path
  LOOP AT t_appsdet INTO wa_appsdet.
    "Copy file from the SAP application server to the FTP destination.
    PERFORM f_ftp_copy1 USING v_ftppath       " Detination file path
                              v_apps          " Source file path
                              wa_appsdet-name." Source File name
  ENDLOOP.
  "Close the FTP Connection
  PERFORM f_close_ftp_connection.
*----------------------------------------------------------------------*
*                    End of Selection
*----------------------------------------------------------------------*
END-OF-SELECTION.
  LEAVE.
*&---------------------------------------------------------------------*
*&      Form  F_F4_GET_LOGICAL_NAME
*&---------------------------------------------------------------------*
*  F4 functionality to get the Logical File name of the Apps Server
*----------------------------------------------------------------------*
FORM f_f4_get_logical_name .

  DATA : lt_filepath TYPE STANDARD TABLE OF ty_filepath,
         repid TYPE sy-repid,
         dynnr TYPE sy-dynnr.

  repid = sy-repid.
  dynnr = sy-dynnr.
  REFRESH lt_filepath.
  CLEAR lt_filepath.

  SELECT  pathintern "Logical path name
           pathname  "Short description of logical file path
           FROM  pathtext
           INTO TABLE lt_filepath
           WHERE  language  = sy-langu.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = 'PATHINTERN'
      dynpprog         = repid
      dynpnr           = dynnr
      dynprofield      = 'p_logic'
      value_org        = 'S'
      callback_program = repid
    TABLES
      value_tab        = lt_filepath.
ENDFORM.                    " F_F4_GET_LOGICAL_NAME
*&---------------------------------------------------------------------*
*&      Form  F_GET_FILE_FROM_APPS
*&---------------------------------------------------------------------*
* Get the application Server / Source path name and source filenames
*----------------------------------------------------------------------*
FORM f_get_file_from_apps .
  CLEAR:  v_wkfl1.
*--Generate the file path by concatenating the path name and Interface id
  IF NOT p_logic IS INITIAL.
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        client           = sy-mandt
        logical_filename = p_logic  "Logical path from selection screen
        operating_system = sy-opsys
      IMPORTING
        file_name        = v_wkfl1
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*--Fetch all the file from the Apps Server path in an internal table
  CLEAR:t_dirlist.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = v_wkfl1  "Apps Directory
    TABLES
      dir_list               = t_dirlist " Apps filename in int table
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " F_GET_FILE_FROM_APPS
*&---------------------------------------------------------------------*
*&      Form  F_GET_FTPCONNECTION_DETAILS
*&---------------------------------------------------------------------*
*  FTP Connection details are maintained in Z Table
*----------------------------------------------------------------------*
FORM f_get_ftpconnection_details .
*--Fetch the connection details froM
  "ZTABLE where the connection deatils are available
  SELECT ftp_id          " FTP Account ID
         sysid           " Sys ID
         ftp_ip_address  " FTP IP Address
         ftp_user        " FTP Username
         ftp_password    " FTP Password
         ftp_folder      " FTP Folder Path
    INTO TABLE t_ftp_det
    FROM zftp
    WHERE ftp_id EQ p_ftpid
    AND sysid EQ sy-sysid.
  IF sy-subrc EQ 0.
    READ TABLE t_ftp_det INTO wa_ftp_det INDEX 1.
    IF sy-subrc EQ 0.
      v_user  = wa_ftp_det-ftp_user.
      v_host  = wa_ftp_det-ftp_ip_address.
      v_psswd = wa_ftp_det-ftp_password.
      v_path  = wa_ftp_det-ftp_folder.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_FTPCONNECTION_DETAILS
*&---------------------------------------------------------------------*
*&      Form  F_OPEN_FTP_CONNECTION
*&---------------------------------------------------------------------*
*       This form opens the ftp connection between the current system
*       and the system defined in the interface parameters.
*----------------------------------------------------------------------*
FORM f_open_ftp_connection .
  DATA:   lv_key TYPE i VALUE 26101957,
          lv_dstlen TYPE i.
  DATA lv_d_password(50).
*--Get the length of password in a string variable
  lv_dstlen = STRLEN( v_psswd ).
*--Call the FM before call to the FTP_CONNECT,
  "the password needs to be scrambled for security reasons
  CALL FUNCTION 'HTTP_SCRAMBLE'
    EXPORTING
      SOURCE      = v_psswd
      sourcelen   = lv_dstlen
      key         = lv_key
    IMPORTING
      destination = lv_d_password.
*--This scrambled password will be sent to FM to establish the FTP connection
  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user            = v_user
      password        = lv_d_password
      host            = v_host
      rfc_destination = c_rfcdst
    IMPORTING
      handle          = v_handle
    EXCEPTIONS
      not_connected   = 1
      OTHERS          = 2.
ENDFORM.                    " F_OPEN_FTP_CONNECTION
*&---------------------------------------------------------------------*
*&      Form  F_FTP_COPY1
*&---------------------------------------------------------------------*
*   File Copy from Application Server to FTP destination
*----------------------------------------------------------------------*
*      -->P_v_ftppath        FTP Destination path
*      -->P_v_apps           Apps path
*      -->P_wa_appsdet_NAME  Source/Apps Filename
*----------------------------------------------------------------------*
FORM f_ftp_copy1  USING    p_v_ftppath
                           p_v_apps
                           p_wa_appsdet_name.
  DATA:lv_source TYPE string.
  v_command = c_ascii.
*--Pass the commands which we need to perform in FM FTP_COMMAND also
  "pass the value of handle we received from the FTP_CONNECT to FTP_COMMAND
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_handle
      command       = v_command
    TABLES
      data          = t_ftp
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3
      OTHERS        = 4.
*--Concat the FTP path '/' filename  into target file
  CONCATENATE v_path c_fdslash p_v_ftppath INTO v_target_file.
  CONDENSE v_target_file NO-GAPS.
  " FTP Command = PUT Command + Apps Server path + FTP path
  CONCATENATE c_text_put p_v_apps v_target_file
              INTO v_command SEPARATED BY space.
* Perform the FTP file copy
  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_handle
      command       = v_command
    TABLES
      data          = t_ftp
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3
      OTHERS        = 4.
*--Archieve the folder once the files are FTPies
  CLEAR : lv_source.
  lv_source = p_wa_appsdet_name." Apps File name
  PERFORM f_archive_after_ftp USING p_v_apps  " Apps Directory Name
                                    lv_source. "Apps File name
  IF v_setflag = 'X'.
    "Delete the file from Apps server once the file is FTPied
    OPEN DATASET p_v_apps FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      DELETE DATASET p_v_apps.
    ENDIF.
    CLOSE DATASET p_v_apps.
  ENDIF.
  CLEAR:v_setflag.
ENDFORM.                    " F_FTP_COPY1
*&---------------------------------------------------------------------*
*&      Form  F_ARCHIVE_AFTER_FTP
*&---------------------------------------------------------------------*
*   Archieve the File once deleted from Source Apps Server path
*----------------------------------------------------------------------*
*      -->P_P_v_apps  Directory path
*      -->P_LV_SOURCE  Source Filename name
*----------------------------------------------------------------------*
FORM f_archive_after_ftp  USING  p_v_apps lv_source.
  DATA:lv_appdir LIKE epsf-epsdirnam ,
       lv_spath  LIKE sapb-sappfad,
       lv_tpath  LIKE sapb-sappfad.
  CLEAR: lv_appdir,
         lv_spath,
         lv_tpath.
  "Get the file name from where deleted file needs to be archieved
  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      client           = sy-mandt
      logical_filename = 'Z_ARCHIVE' "Archive Logical File name
      operating_system = sy-opsys
    IMPORTING
      file_name        = lv_appdir " Archive Directory
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  "Concatenate Directory path(/IA/D60/OUTBOUND/ARCHIVE/)
  " with the File name (Filename1.xml)
  CONCATENATE lv_appdir lv_source INTO lv_tpath.
  lv_spath = p_v_apps.
  "File copy from Source Apps path to Archive Apps path
  CALL FUNCTION 'ARCHIVFILE_SERVER_TO_SERVER'
    EXPORTING
      sourcepath       = lv_spath "/IA/D60/OUTBOUND/Filename1.xml
      targetpath       = lv_tpath "/IA/D60/OUTBOUND/ARCHIVE/Filename1.xml
    EXCEPTIONS
      error_file       = 1
      no_authorization = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " F_ARCHIVE_AFTER_FTP
*&---------------------------------------------------------------------*
*&      Form  F_CLOSE_FTP_CONNECTION
*&---------------------------------------------------------------------*
*       This form closes the FTP connection.  If and error occured
*       during the FTP command, the process is abended.
*----------------------------------------------------------------------*
FORM f_close_ftp_connection .
  CALL FUNCTION 'FTP_DISCONNECT'
    EXPORTING
      handle = v_handle
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    "throw error.
  ENDIF.
ENDFORM.                    " F_CLOSE_FTP_CONNECTION