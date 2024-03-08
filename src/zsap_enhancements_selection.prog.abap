*&---------------------------------------------------------------------*
*&  Include  zsap_enhancements_selection
*&---------------------------------------------------------------------*

TABLES: tstc,tadir, modsap, modact, sxs_attrt,sxc_exit.
DATA enhheader TYPE enhheader.
DATA enhspotheader TYPE enhspotheader.
DATA enhspotcomphead TYPE enhspotcomphead.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-s01.
SELECT-OPTIONS:
  s_tcode FOR tstc-tcode,
  s_pgmna FOR tstc-pgmna,
  s_devcla FOR tadir-devclass,
  s_uename FOR modsap-name,
  s_badina FOR sxs_attrt-exit_name,
  s_enhnam FOR enhspotheader-enhspot,
  s_cenhna FOR enhspotcomphead-enhspotcomposite.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-s02.
SELECT-OPTIONS:
  s_ueimpl FOR modact-name,
  s_badiim FOR sxc_exit-imp_name,
  s_enhimp FOR enhheader-enhname.
PARAMETERS: p_impenh AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-s03.
PARAMETERS:
  p_layout TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b03.
