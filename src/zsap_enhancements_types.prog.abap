*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_types
*&---------------------------------------------------------------------*
  TYPES:
    BEGIN OF t_devclasses,
      transaction TYPE tcode,
      program     TYPE program_id,
      devclass    TYPE devclass,
    END OF t_devclasses,
    tt_devclasses TYPE SORTED TABLE OF t_devclasses WITH NON-UNIQUE KEY devclass,

    BEGIN OF t_enhancements,
      devclass                     TYPE devclass,
      enhancement_type             TYPE trobjtype,
      enhancement_name             TYPE sobj_name,
      user_exit_description        TYPE modtext_d,
      user_exit_implementation     TYPE cmodname,
      is_user_exit_active          TYPE abap_bool,
      badi_description             TYPE cus_text,
      badi_implementation          TYPE exit_imp,
      is_badi_sap_internal         TYPE abap_bool,
      is_badi_active               TYPE abap_bool,
      enhancement_spot_description TYPE sotr_txt,
      enhancement_spot_impl        TYPE enhname,
      is_enhancement_spot_active   TYPE abap_bool,
      is_enhancement_spot_sap_int  TYPE enhboolean,
      comp_enhancement_spot_desc   TYPE sotr_txt,
    END OF t_enhancements,
    tt_enhancements TYPE SORTED TABLE OF t_enhancements WITH NON-UNIQUE KEY devclass,

    BEGIN OF t_output,
      transaction                  TYPE tcode,
      program                      TYPE program_id,
      devclass                     TYPE devclass,
      enhancement_type             TYPE trobjtype,
      enhancement_type_description TYPE string,
      enhancement_name             TYPE sobj_name,
      description                  TYPE string,
      implementation               TYPE string,
      is_active                    TYPE abap_bool,
      is_sap_internal              TYPE abap_bool,
      color                        TYPE lvc_t_scol,
    END OF t_output,
    tt_output TYPE STANDARD TABLE OF t_output.
