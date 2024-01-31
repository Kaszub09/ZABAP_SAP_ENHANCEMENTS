*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_cls_call_tra
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_cls_report
*&---------------------------------------------------------------------*

CLASS  lcl_enhancement_transaction DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      show_user_exit IMPORTING name TYPE string,
      show_badi IMPORTING name TYPE string,
      show_enhancement_spot IMPORTING name TYPE string,
      show_composite_enhancement IMPORTING name TYPE string,
      show_user_exit_implementation IMPORTING name TYPE string,
      show_badi_implementation IMPORTING name TYPE string,
      show_enhancement_spot_impl IMPORTING name TYPE string.
ENDCLASS.

CLASS lcl_enhancement_transaction IMPLEMENTATION.
  METHOD show_badi.
    DATA batch_input TYPE TABLE OF bdcdata.

    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_IS_BADI'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_IS_BADI' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_BADINAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_BADINAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SHOW' ) TO batch_input.

    CALL TRANSACTION 'SE18' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_badi_implementation.
    DATA batch_input TYPE TABLE OF bdcdata.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0120' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_IS_CLASSIC_1'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_IS_CLASSIC_1' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0120' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'RSEXSCRN-IMP_NAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'RSEXSCRN-IMP_NAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=IMP_SHOW' ) TO batch_input.

    CALL TRANSACTION 'SE19' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_composite_enhancement.
    DATA batch_input TYPE TABLE OF bdcdata.

    APPEND VALUE #( program = 'SAPLENHANCEMENTS' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'RSEUX-CXT'  ) TO batch_input.
    APPEND VALUE #( fnam = 'RSEUX-CXT' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPLENHANCEMENTS' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'RSEUX-CXT_VALUE'  ) TO batch_input.
    APPEND VALUE #( fnam = 'RSEUX-CXT_VALUE' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=DISPLAY' ) TO batch_input.

    CALL TRANSACTION 'SE20' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_enhancement_spot.
    DATA batch_input TYPE TABLE OF bdcdata.

    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_IS_BADI'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_IS_SPOT' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0100' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_BADINAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_ENHSPOTNAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SHOW' ) TO batch_input.

    CALL TRANSACTION 'SE18' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_enhancement_spot_impl.
    DATA batch_input TYPE TABLE OF bdcdata.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0120' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_IS_NEW_1'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_IS_NEW_1' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPLSEXO' dynpro = '0120' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'G_ENHNAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'G_ENHNAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=IMP_SHOW' ) TO batch_input.

    CALL TRANSACTION 'SE19' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_user_exit.
    DATA batch_input TYPE TABLE OF bdcdata.

    APPEND VALUE #( program = 'SAPMSMOD' dynpro = '2010' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'MOD0-NAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'MODF-CHAM' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPMSMOD' dynpro = '2010' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'MOD0-NAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'MOD0-NAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SHOW' ) TO batch_input.

    CALL TRANSACTION 'SMOD' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

  METHOD show_user_exit_implementation.
    DATA batch_input TYPE TABLE OF bdcdata.

    APPEND VALUE #( program = 'SAPMSMOD' dynpro = '1010' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'MOD0-NAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'MODF-CHAP' fval = 'X' ) TO batch_input.
    APPEND VALUE #( program = 'SAPMSMOD' dynpro = '1010' dynbegin = 'X' fnam = 'BDC_CURSOR' fval = 'MOD0-NAME'  ) TO batch_input.
    APPEND VALUE #( fnam = 'MOD0-NAME' fval = name ) TO batch_input.
    APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SHOW' ) TO batch_input.

    CALL TRANSACTION 'CMOD' USING batch_input MODE 'E' UPDATE 'S'.
  ENDMETHOD.

ENDCLASS.
