*&---------------------------------------------------------------------*
*& Report z2_fanf02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2_fanf02.


"Init of parameters, which flights the carrier wants to synchronize
PARAMETERS p_carrid TYPE sflight-carrid OBLIGATORY.
PARAMETERS p_connid TYPE sflight-connid.
PARAMETERS p_midate TYPE sflight-fldate.
PARAMETERS p_madate TYPE sflight-fldate.
PARAMETERS p_airp TYPE s_airport.



"Check for wrong time interval
IF ( p_madate < p_midate AND ( p_midate IS NOT INITIAL AND p_madate IS NOT INITIAL ) ).
  WRITE `Your max. date must be greater than your min. date`.
  RETURN.
ENDIF.

DATA(g_carrier_flights) = Z2_SQL_REQUESTS=>get_flight_data(
                           i_carrid = p_carrid
                           i_connid = P_connid
                           i_midate = p_midate
                           i_madate = p_madate
                           i_airp   = p_airp
                         ).

" Method to print the result table g_carrier_flights
cl_salv_table=>factory(
IMPORTING
  r_salv_table = DATA(o_alv)
CHANGING
  t_table = g_carrier_flights ).

o_alv->display( ).
