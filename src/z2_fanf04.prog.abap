*&---------------------------------------------------------------------*
*& Report z2_fanf04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2_fanf04.



CONSTANTS : rbSelected TYPE c LENGTH 1 VALUE `X`.


"Radio Buttons
SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.
  SELECTION-SCREEN ULINE /10(40).

"Country
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: rb1 RADIOBUTTON GROUP rb.
    SELECTION-SCREEN COMMENT 20(30) text-002.
  SELECTION-SCREEN END OF LINE.

"City
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: rb2 RADIOBUTTON GROUP rb.
    SELECTION-SCREEN COMMENT 20(30) text-003.
  SELECTION-SCREEN END OF LINE.

"Airport
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: rb3 RADIOBUTTON GROUP rb.
    SELECTION-SCREEN COMMENT 20(30) text-004.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN ULINE /10(40).
SELECTION-SCREEN END OF BLOCK frame1.



DATA g_selected_scope TYPE z2_study_scope3.

"Define count object based on radio selection
IF rb1 = rbSelected.
  g_selected_scope = 'C'.
ELSEIF rb2 = rbSelected.
  g_selected_scope = 'Y'.
ELSEIF rb3 = rbSelected.
"Wrong Data Type Selection
  g_selected_scope = 'A'.
ENDIF.

Z2_FANF04_COUNT=>show_number_flights_by_scope( g_selected_scope ).
