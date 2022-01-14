*&---------------------------------------------------------------------*
*& Report z2_fanf01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2_fanf01.

CONSTANTS c_airport_code TYPE s_airport VALUE 'FRA'.

* Input-Parameters to filter booking table
PARAMETERS p_cname TYPE scustom-name OBLIGATORY .
PARAMETERS p_cstr TYPE scustom-street.
PARAMETERS p_cpost TYPE scustom-postcode.
PARAMETERS p_ccity TYPE scustom-city.
PARAMETERS p_carrid TYPE sbook-carrid.
PARAMETERS p_connid TYPE sbook-connid.
PARAMETERS p_fldate TYPE sbook-fldate.
PARAMETERS p_bookid TYPE sbook-bookid.


* Necessary for the LIKE expression below
    p_cname = '%' && p_cname && '%'.
    p_cstr = '%' && p_cstr && '%'.
    p_ccity = '%' && p_ccity && '%'.

DATA(g_result) = Z2_SQL_REQUESTS=>get_customer_data(
                   i_cname        = p_cname
                   i_cstr         = p_cstr
                   i_cpost        = p_cpost
                   i_ccity        = p_ccity
                   i_carrid       = p_carrid
                   i_connid       = p_connid
                   i_fldate       = p_fldate
                   i_bookid       = p_bookid
                   i_airport_code = c_airport_code
                 ).

* Check if the parameters are correct
IF g_result IS INITIAL.
  MESSAGE 'Incorrect parameters' TYPE 'W'.
ENDIF.

* Method to print out table
cl_salv_table=>factory(
    IMPORTING
        r_salv_table = DATA(o_alv)
    CHANGING
        t_table = g_result ).
o_alv->display( ).
