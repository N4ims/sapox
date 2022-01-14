*&---------------------------------------------------------------------*
*& Report z2_fanf03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2_fanf03.

" Involved Airport
CONSTANTS c_airport_code TYPE s_airport VALUE `FRA`.

" Input fields to define parameters
PARAMETERS:
  p_cityTo TYPE spfli-cityto,
  p_airpTo TYPE spfli-airpto,
  p_counTo TYPE spfli-countryto,
  p_class  TYPE sbook-class,
  p_price  TYPE sflight-price,
  p_curr   TYPE sflight-currency
.

" Creating the result table g_result
DATA(g_result) = Z2_SQL_REQUESTS=>get_lastminute_flights(
             i_cityto       = p_cityTo
             i_airpto       = p_airpTo
             i_counto       = p_counTo
             i_class        = p_class
             i_price        = p_price
             i_curr         = p_curr
             i_airport_code = c_airport_code
).

" warning if table is initial
IF g_result IS INITIAL.
    MESSAGE 'Data not found' TYPE 'W'.
ENDIF.

" Method to print out the result table
cl_salv_table=>factory(
    IMPORTING
        r_salv_table = DATA(o_alv)
    CHANGING
        t_table = g_result ).
o_alv->display( ).
