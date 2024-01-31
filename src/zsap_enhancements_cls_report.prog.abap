*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_cls_report
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION INHERITING FROM zcl_zabap_salv_report.
  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_ext_type,
        user_exit             TYPE c LENGTH 4 VALUE 'SMOD',
        badi                  TYPE c LENGTH 4 VALUE 'SXSD',
        enhancement_spot      TYPE c LENGTH 4 VALUE 'ENHS',
        composite_enhancement TYPE c LENGTH 4 VALUE 'ENSC',
      END OF c_ext_type,
      BEGIN OF c_col,
        implementation TYPE string VALUE 'IMPLEMENTATION',
        name           TYPE string VALUE 'ENHANCEMENT_NAME',
      END OF c_col.

    METHODS prepare_report.

  PROTECTED SECTION.
    METHODS on_double_click REDEFINITION.

  PRIVATE SECTION.
    DATA output TYPE tt_output.

    METHODS:
      get_devclasses RETURNING VALUE(devclasses) TYPE tt_devclasses,
      get_enhancements IMPORTING devclasses TYPE tt_devclasses RETURNING VALUE(enhancements) TYPE tt_enhancements,
      get_output_line IMPORTING enhancement TYPE t_enhancements RETURNING VALUE(output_line) TYPE t_output,
      color_output CHANGING output_line TYPE t_output,
      prepare_columns.
ENDCLASS.


CLASS lcl_report IMPLEMENTATION.
  METHOD prepare_report.

    DATA(filter_by_program) = xsdbool( lines( s_tcode ) > 0 OR lines( s_pgmna ) > 0 ).

    "Either get enhancements filtered by devclasses or just get all by name/implementation
    IF filter_by_program = abap_true.
      DATA(devclasses) = get_devclasses( ).
    ENDIF.
    DATA(enhacements) = get_enhancements( devclasses ).


    "Create output from enhancements
    LOOP AT enhacements REFERENCE INTO DATA(enhancement).
      DATA(output_line) = get_output_line( enhancement->* ).
      color_output( CHANGING output_line = output_line ).

      IF filter_by_program = abap_true.
        LOOP AT devclasses REFERENCE INTO DATA(devclass) WHERE devclass = enhancement->devclass.
          APPEND CORRESPONDING #( BASE ( output_line ) devclass->* ) TO output.
        ENDLOOP.
      ELSE.
        APPEND output_line TO output.
      ENDIF.
    ENDLOOP.

    SORT output BY transaction program enhancement_type enhancement_name.
    set_data( EXPORTING create_table_copy = abap_false CHANGING data_table = output ).

    prepare_columns( ).
  ENDMETHOD.

  METHOD get_devclasses.
    "TSTC - tcode <> report
    "TADIR - all repo objects
    "TRDIR
    "TFDIR - function modules group
    "ENLFDIR - funciton modules additional attributes
    "GET CLASSES, try by progrma or function group belonging to program
    SELECT FROM tstc
        LEFT JOIN tadir ON tadir~pgmid = 'R3TR' AND tadir~object = 'PROG' AND tadir~obj_name = tstc~pgmna
        LEFT JOIN trdir ON trdir~name = tstc~pgmna AND trdir~subc = 'F'
        LEFT JOIN tfdir ON tfdir~pname = tstc~pgmna
        LEFT JOIN enlfdir ON enlfdir~funcname = tfdir~funcname
        LEFT JOIN tadir AS tadir_2 ON tadir_2~pgmid = 'R3TR' AND tadir_2~object = 'FUGR' AND tadir_2~obj_name = enlfdir~area
      FIELDS DISTINCT tstc~tcode AS transaction, tstc~pgmna AS program, CASE WHEN tadir~devclass IS NULL THEN tadir_2~devclass ELSE tadir~devclass END AS devclass
      WHERE tstc~tcode IN @s_tcode AND tstc~pgmna IN @s_pgmna
      INTO CORRESPONDING FIELDS OF TABLE @devclasses.
  ENDMETHOD.

  METHOD get_enhancements.
    DATA devclasses_range TYPE RANGE OF devclass.
    devclasses_range = VALUE #( FOR devclass IN devclasses ( sign = 'I' option = 'EQ' low = devclass-devclass ) ).

    SELECT FROM tadir
        LEFT JOIN modsapt ON modsapt~sprsl = @sy-langu AND modsapt~name = tadir~obj_name
        LEFT JOIN modact ON modact~member = tadir~obj_name
        LEFT JOIN modattr ON modattr~name = modsapt~name
        LEFT JOIN sxs_attr ON sxs_attr~exit_name = tadir~obj_name
        LEFT JOIN sxs_attrt ON sxs_attrt~sprsl = @sy-langu AND sxs_attrt~exit_name = sxs_attr~exit_name
        LEFT JOIN sxc_exit ON sxc_exit~exit_name = sxs_attrt~exit_name
        LEFT JOIN sxc_attr ON sxc_attr~imp_name = sxc_exit~imp_name
      FIELDS tadir~devclass, object AS enhancement_type, obj_name AS enhancement_name,
          modsapt~modtext AS user_exit_description,  modact~name AS user_exit_implementation, modattr~status AS is_user_exit_active,
          sxs_attrt~text AS badi_description, sxs_attr~internal AS is_badi_sap_internal,
          sxc_exit~imp_name AS badi_implementation, sxc_attr~active AS is_badi_active
      WHERE tadir~pgmid     = 'R3TR' AND tadir~devclass IN @devclasses_range and tadir~devclass in @s_devcla
        AND tadir~object   IN ( @c_ext_type-user_exit, @c_ext_type-badi, @c_ext_type-enhancement_spot, @c_ext_type-composite_enhancement )
        AND tadir~obj_name IN @s_uename AND tadir~obj_name IN @s_badina
        AND modact~name    IN @s_ueimpl AND sxc_exit~imp_name IN @s_badiim
      INTO CORRESPONDING FIELDS OF TABLE @enhancements.
  ENDMETHOD.

  METHOD get_output_line.
    output_line = CORRESPONDING t_output( enhancement ).
    IF enhancement-enhancement_type = c_ext_type-user_exit.
      output_line-description                  = enhancement-user_exit_description.
      output_line-implementation               = enhancement-user_exit_implementation.
      output_line-is_active                    = COND #( WHEN enhancement-is_user_exit_active = abap_false THEN abap_false ELSE abap_true ).
      output_line-enhancement_type_description = TEXT-e01.
    ELSEIF enhancement-enhancement_type = c_ext_type-badi.
      output_line-description                  = enhancement-badi_description.
      output_line-implementation               = enhancement-badi_implementation.
      output_line-is_active                    = COND #( WHEN enhancement-is_badi_active = abap_false THEN abap_false ELSE abap_true ).
      output_line-is_badi_sap_internal         = enhancement-is_badi_sap_internal.
      output_line-enhancement_type_description = TEXT-e02.
    ELSEIF enhancement-enhancement_type = c_ext_type-enhancement_spot.
      output_line-enhancement_type_description = TEXT-e03.
    ELSEIF enhancement-enhancement_type = c_ext_type-composite_enhancement.
      output_line-enhancement_type_description = TEXT-e04.
    ENDIF.
  ENDMETHOD.

  METHOD color_output.
    IF NOT output_line-implementation IS INITIAL.
      APPEND VALUE #( fname = c_col-implementation color = VALUE #( col = COND #( WHEN output_line-is_active = abap_true THEN 5 ELSE 1 )
                                                                      ) ) TO output_line-color.
    ENDIF.
    IF output_line-is_badi_sap_internal = abap_true.
      APPEND VALUE #( fname = c_col-name color = VALUE #( col = 7 ) ) TO output_line-color.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_columns.
    set_fixed_column_text( column = 'DESCRIPTION' text = TEXT-c01 ).
    set_fixed_column_text( column = 'IMPLEMENTATION' text = TEXT-c02 ).
    set_fixed_column_text( column = 'ENHANCEMENT_TYPE_DESCRIPTION' text = TEXT-c03 ).
    set_fixed_column_text( column = 'IS_ACTIVE' text = TEXT-c04 ).
    set_fixed_column_text( column = 'IS_BADI_SAP_INTERNAL' text = TEXT-c05 ).

    hide_column( 'ENHANCEMENT_TYPE' ).

    alv_table->get_columns( )->set_color_column( 'COLOR' ).
  ENDMETHOD.

  METHOD on_double_click.
    IF row = 0.
      RETURN.
    ENDIF.

    DATA(row_data) = REF #( output[ row ] ).

    IF ( column = c_col-name AND row_data->enhancement_name IS INITIAL ) OR ( column = c_col-implementation AND row_data->implementation IS INITIAL ).
      RETURN.
    ENDIF.

    "Call correct transaction
    DATA(enhancement_transaction) = NEW lcl_enhancement_transaction( ).
    IF column = c_col-name.
      CASE row_data->enhancement_type.
        WHEN c_ext_type-user_exit. enhancement_transaction->show_user_exit( CONV #( row_data->enhancement_name ) ).
        WHEN c_ext_type-badi. enhancement_transaction->show_badi( CONV #( row_data->enhancement_name ) ).
        WHEN c_ext_type-enhancement_spot. enhancement_transaction->show_enhancement_spot( CONV #( row_data->enhancement_name ) ).
        WHEN c_ext_type-composite_enhancement. enhancement_transaction->show_composite_enhancement( CONV #( row_data->enhancement_name ) ).
      ENDCASE.

    ELSEIF column = c_col-implementation.
      CASE row_data->enhancement_type.
        WHEN c_ext_type-user_exit. enhancement_transaction->show_user_exit_implementation( row_data->implementation ).
        WHEN c_ext_type-badi. enhancement_transaction->show_badi_implementation( row_data->implementation ).
      ENDCASE.

    ENDIF.
  ENDMETHOD.


ENDCLASS.
