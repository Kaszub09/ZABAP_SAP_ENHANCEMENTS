*&---------------------------------------------------------------------*
*& Report ztoc
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsap_enhancements.

INCLUDE zsap_enhancements_types.
INCLUDE zsap_enhancements_selection.
INCLUDE zsap_enhancements_cls_call_tra.
INCLUDE zsap_enhancements_cls_report.

INITIALIZATION.
  DATA(report) = NEW lcl_report( sy-repid ).

START-OF-SELECTION.
  report->prepare_report( ).
  report->display_data( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  p_layout = report->get_layout_from_f4_selection( ).
