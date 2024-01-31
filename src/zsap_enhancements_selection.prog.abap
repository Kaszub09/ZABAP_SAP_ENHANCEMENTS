*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_selection
*&---------------------------------------------------------------------*

TABLES: tstc,tadir, modsap, modact, sxs_attrt,sxc_exit.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-s01.
SELECT-OPTIONS:
  s_tcode FOR tstc-tcode,
  s_pgmna FOR tstc-pgmna,
  s_devcla FOR tadir-devclass,
  s_uename FOR modsap-name,
  s_badina FOR sxs_attrt-exit_name.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-s02.
SELECT-OPTIONS:
  s_ueimpl FOR modact-name,
  s_badiim FOR sxc_exit-imp_name.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-s03.
PARAMETERS:
  p_layout TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b03.
