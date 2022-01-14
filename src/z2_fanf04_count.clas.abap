CLASS z2_fanf04_count DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.
    "
    CLASS-METHODS show_number_flights_by_scope
        IMPORTING
            i_selected_scope TYPE z2_study_scope3.



PROTECTED SECTION.

PRIVATE SECTION.


    CLASS-DATA g_selected_scope TYPE z2_study_scope3.

    CLASS-DATA g_nr_arrivals_table TYPE z2stats_results.
    CLASS-DATA g_nr_departures_table TYPE z2stats_results.
    CLASS-DATA g_stats_table TYPE z2stats_results.


    "!fills a z2stats_results table with all flight arrival & departure locations
    CLASS-METHODS get_all_locations
        CHANGING c_stats_table TYPE z2stats_results.
ENDCLASS.




CLASS z2_fanf04_count IMPLEMENTATION.

    METHOD show_number_flights_by_scope.

        g_selected_scope = i_selected_scope.

        "Get all flight locations (based on selected scope)
        get_all_locations( CHANGING c_stats_table = g_stats_table ).


        DATA group_by_field_departures TYPE string.
        DATA group_by_field_arrivals TYPE string.

     "Select query modifier based on scope
        CASE g_selected_scope.
            WHEN `C`. group_by_field_departures = `P~COUNTRYFR`.
                        group_by_field_arrivals = `P~COUNTRYTO`.
            WHEN `Y`. group_by_field_departures = `P~CITYFROM`.
                        group_by_field_arrivals = `P~CITYTO`.
            WHEN `A`. group_by_field_departures = `P~AIRPFROM`.
                        group_by_field_arrivals = `P~AIRPTO`.
        ENDCASE.

    "Dynamic select field for departures & count number
        DATA(select_field_departures) = group_by_field_departures && | AS location, COUNT( * ) AS nr_departures|.
    "Dynamic select field for arrivals & count number
        DATA(select_field_arrivals) = group_by_field_arrivals && | AS location, COUNT( * ) AS nr_arrivals|.


    "Departure counting
         select FROM spfli AS p
            INNER JOIN sflight AS f
                ON f~carrid = p~carrid
                AND f~connid = p~connid
            "Dynamic field depending on selected_scope
            FIELDS (select_field_departures)
            "Dynamic group depending on selected_scope
            GROUP BY (group_by_field_departures)
            INTO CORRESPONDING FIELDS of TABLE @g_nr_departures_table.

    "Arrival counting
         SELECT FROM spfli AS p
         "get extended informations on the flights
            INNER JOIN sflight AS f
                ON f~carrid = p~carrid
                AND f~connid = p~connid
            "Dynamic field depending on selected_scope
            FIELDS (select_field_arrivals)
            "Dynamic group depending on selected_scope
            GROUP BY (group_by_field_arrivals)
            INTO CORRESPONDING FIELDS OF TABLE @g_nr_arrivals_table.


    "Merge locations, nr_arrivals and nr_departures into final table g_stats_table
    "Loop through all flight locations
         LOOP AT g_stats_table REFERENCE INTO DATA(g_stats).

         "Insert nr_departures into row g_stats if there are departures from location
            TRY.
                g_stats->nr_departures = g_nr_departures_table[ location = g_stats->location ]-nr_departures.
            CATCH cx_sy_itab_line_not_found.

            ENDTRY.

        "Insert nr_arrivals into row g_stats if the are arrivals to location
            TRY.
                g_stats->nr_arrivals = g_nr_arrivals_table[ location = g_stats->location ]-nr_arrivals.
            CATCH cx_sy_itab_line_not_found.

            ENDTRY.
         ENDLOOP.


    "Print result table
     cl_salv_table=>factory(
      IMPORTING
        r_salv_table = DATA(o_alv)
      CHANGING
        t_table = g_stats_table ).

        o_alv->display( ).

    ENDMETHOD.



  METHOD get_all_locations.

    "Get departure locations
        SELECT FROM spfli AS p
        FIELDS ( CASE
            WHEN @g_selected_scope = 'C' THEN p~countryfr
            WHEN @g_selected_scope = 'Y' THEN p~cityfrom
            WHEN @g_selected_scope = 'A' THEN p~airpfrom
        END ) AS location
        "Unite 2 queries
        UNION
        "Get arrival locations
        SELECT FROM spfli AS p
        FIELDS ( CASE
            WHEN @g_selected_scope = 'C' THEN p~countryto
            WHEN @g_selected_scope = 'Y' THEN p~cityto
            WHEN @g_selected_scope = 'A' THEN p~airpto
        END ) AS location
        INTO TABLE @c_stats_table.


  ENDMETHOD.

ENDCLASS.
