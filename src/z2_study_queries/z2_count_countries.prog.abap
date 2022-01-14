*&---------------------------------------------------------------------*
*& Report z2_count_countries
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z2_count_countries.

PARAMETERS p_countr TYPE spfli-countryfr.

SELECT COUNT( * )
    FROM spfli
    WHERE spfli~countryfr = @p_countr
    GROUP BY ( spfli~countryfr )
    INTO @DATA(g_flights_count).
ENDSELECT.

WRITE g_flights_count.
