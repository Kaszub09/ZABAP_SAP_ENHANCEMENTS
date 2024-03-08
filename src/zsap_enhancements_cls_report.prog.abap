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
      append_implicit_enhancements IMPORTING devclasses TYPE tt_devclasses CHANGING enhancements TYPE tt_enhancements,
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
    DATA(enhancements) = get_enhancements( devclasses ).

    "Append implicit enhancements implementations - they weren't caught earlier
    IF p_impenh = abap_true.
      append_implicit_enhancements( EXPORTING devclasses = devclasses CHANGING enhancements = enhancements ).
    ENDIF.

    "Create output from enhancements
    LOOP AT enhancements REFERENCE INTO DATA(enhancement).
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

    SORT output BY transaction
                   program
                   enhancement_type
                   enhancement_name.
    set_data( EXPORTING create_table_copy = abap_false CHANGING data_table = output ).

    prepare_columns( ).
  ENDMETHOD.

  METHOD get_devclasses.
    "TSTC - tcode <> report
    "TADIR - all repo objects
    "TRDIR
    "TFDIR - function modules group
    "ENLFDIR - funciton modules additional attributes
    "Get devclasses, try by program or function group belonging to program
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
        "User-Exit
        LEFT JOIN modsapt ON tadir~object = @c_ext_type-user_exit AND modsapt~sprsl = @sy-langu AND modsapt~name = tadir~obj_name
        LEFT JOIN modact ON tadir~object = @c_ext_type-user_exit AND modact~member = tadir~obj_name
        LEFT JOIN modattr ON modattr~name = modsapt~name
        "BADI
        LEFT JOIN sxs_attr ON tadir~object = @c_ext_type-badi AND sxs_attr~exit_name = tadir~obj_name
        LEFT JOIN sxs_attrt ON sxs_attrt~sprsl = @sy-langu AND sxs_attrt~exit_name = sxs_attr~exit_name
        LEFT JOIN sxc_exit ON sxc_exit~exit_name = sxs_attrt~exit_name
        LEFT JOIN sxc_attr ON sxc_attr~imp_name = sxc_exit~imp_name
        "Enhancement spot
        LEFT JOIN enhspotheader ON tadir~object = @c_ext_type-enhancement_spot AND enhspotheader~enhspot = tadir~obj_name
        LEFT JOIN sotr_text ON sotr_text~concept = enhspotheader~shorttextid AND sotr_text~langu = @sy-langu
        LEFT JOIN enhobj ON enhobj~main_type = @c_ext_type-enhancement_spot AND enhobj~main_name = tadir~obj_name
        LEFT JOIN enhheader ON enhheader~enhname = enhobj~enhname
        "Composite enhancement spot
        LEFT JOIN enhspotcomphead ON tadir~object = @c_ext_type-composite_enhancement AND enhspotcomphead~enhspotcomposite = tadir~obj_name
        LEFT JOIN sotr_text AS sotr_text_comp ON sotr_text~concept = enhspotcomphead~shorttextid AND sotr_text~langu = @sy-langu
      FIELDS DISTINCT tadir~devclass, tadir~object AS enhancement_type, tadir~obj_name AS enhancement_name,
          "User-Exit
          modsapt~modtext AS user_exit_description,  modact~name AS user_exit_implementation,
          CASE WHEN modattr~status = 'A' THEN @abap_true ELSE @abap_false END AS is_user_exit_active,
          "BADI
          sxs_attrt~text AS badi_description, sxs_attr~internal AS is_badi_sap_internal,
          sxc_exit~imp_name AS badi_implementation, CASE WHEN sxc_attr~active = 'X' THEN @abap_true ELSE @abap_false END AS is_badi_active,
          "Enhancement spot
          sotr_text~text AS enhancement_spot_description, enhspotheader~internal AS is_enhancement_spot_sap_int,
          enhobj~enhname AS enhancement_spot_impl,
          CASE WHEN enhheader~version = 'A' THEN @abap_true ELSE @abap_false END AS is_enhancement_spot_active,
          "Composite enhancement spot
          sotr_text_comp~text AS com_enhancement_spot_descr
      WHERE tadir~pgmid = 'R3TR' AND tadir~devclass IN @devclasses_range AND tadir~devclass IN @s_devcla
        AND tadir~object IN ( @c_ext_type-user_exit, @c_ext_type-badi, @c_ext_type-enhancement_spot, @c_ext_type-composite_enhancement )
        AND modsapt~name IN @s_uename AND sxs_attr~exit_name IN @s_badina
        AND enhspotheader~enhspot IN @s_enhnam AND enhspotcomphead~enhspotcomposite IN @s_cenhna
        AND modact~name IN @s_ueimpl AND sxc_exit~imp_name IN @s_badiim AND enhheader~enhname IN @s_enhimp
      INTO CORRESPONDING FIELDS OF TABLE @enhancements.
  ENDMETHOD.

  METHOD append_implicit_enhancements.
    DATA devclasses_range TYPE RANGE OF devclass.
    devclasses_range = VALUE #( FOR devclass IN devclasses ( sign = 'I' option = 'EQ' low = devclass-devclass ) ).

    DATA implementations_to_exclude TYPE RANGE OF enhname.
    implementations_to_exclude = VALUE #( FOR line IN enhancements where ( enhancement_type = c_ext_type-enhancement_spot )
        ( sign = 'E' option = 'EQ' low = line-enhancement_spot_impl )  ).

    SELECT FROM enhobj
        LEFT JOIN tadir ON tadir~pgmid = enhobj~pgmid AND tadir~object = enhobj~main_type AND tadir~obj_name = enhobj~main_name
        LEFT JOIN enhheader ON enhheader~enhname = enhobj~enhname
    FIELDS DISTINCT tadir~devclass, @c_ext_type-enhancement_spot AS enhancement_type, enhobj~enhname AS enhancement_spot_impl,
        CASE WHEN enhheader~version = 'A' THEN @abap_true ELSE @abap_false END AS is_enhancement_spot_active
    WHERE tadir~devclass IN @devclasses_range AND tadir~devclass IN @s_devcla
        AND enhobj~enhname IN @implementations_to_exclude AND enhobj~enhname IN @s_enhimp
    APPENDING CORRESPONDING FIELDS OF TABLE @enhancements.
  ENDMETHOD.

  METHOD get_output_line.
    output_line = CORRESPONDING t_output( enhancement ).
    IF enhancement-enhancement_type = c_ext_type-user_exit.
      output_line-description                  = enhancement-user_exit_description.
      output_line-implementation               = enhancement-user_exit_implementation.
      output_line-is_active                    = enhancement-is_user_exit_active .
      output_line-enhancement_type_description = TEXT-e01.
    ELSEIF enhancement-enhancement_type = c_ext_type-badi.
      output_line-description                  = enhancement-badi_description.
      output_line-implementation               = enhancement-badi_implementation.
      output_line-is_active                    = enhancement-is_badi_active.
      output_line-is_sap_internal              = enhancement-is_badi_sap_internal.
      output_line-enhancement_type_description = TEXT-e02.
    ELSEIF enhancement-enhancement_type = c_ext_type-enhancement_spot.
      output_line-description                  = enhancement-enhancement_spot_description.
      output_line-implementation               = enhancement-enhancement_spot_impl.
      output_line-is_active                    = enhancement-is_enhancement_spot_active.
      output_line-is_sap_internal              = enhancement-is_enhancement_spot_sap_int.
      output_line-enhancement_type_description = TEXT-e03.
    ELSEIF enhancement-enhancement_type = c_ext_type-composite_enhancement.
      output_line-description                  = enhancement-comp_enhancement_spot_desc.
      output_line-enhancement_type_description = TEXT-e04.
    ENDIF.
  ENDMETHOD.

  METHOD color_output.
    IF NOT output_line-implementation IS INITIAL.
      APPEND VALUE #( fname = c_col-implementation color = VALUE #( col = COND #( WHEN output_line-is_active = abap_true THEN 5 ELSE 1 )
                                                                  ) ) TO output_line-color.
    ENDIF.
    IF output_line-is_sap_internal = abap_true.
      APPEND VALUE #( fname = c_col-name color = VALUE #( col = 7 ) ) TO output_line-color.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_columns.
    set_fixed_column_text( column = 'DESCRIPTION' text = TEXT-c01 ).
    set_fixed_column_text( column = 'IMPLEMENTATION' text = TEXT-c02 ).
    set_fixed_column_text( column = 'ENHANCEMENT_TYPE_DESCRIPTION' text = TEXT-c03 ).
    set_fixed_column_text( column = 'IS_ACTIVE' text = TEXT-c04 ).
    set_fixed_column_text( column = 'IS_SAP_INTERNAL' text = TEXT-c05 ).

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
        WHEN c_ext_type-enhancement_spot. enhancement_transaction->show_enhancement_spot_impl( row_data->implementation ).
      ENDCASE.

    ENDIF.
  ENDMETHOD.


ENDCLASS.
