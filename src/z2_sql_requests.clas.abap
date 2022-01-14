CLASS z2_sql_requests DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

    CLASS-METHODS:

        get_customer_data
            IMPORTING
                i_cname TYPE scustom-name
                i_cstr TYPE scustom-street
                i_cpost TYPE scustom-postcode
                i_ccity TYPE scustom-city
                i_carrid TYPE sbook-carrid
                i_connid TYPE sbook-connid
                i_fldate TYPE sbook-fldate
                i_bookid TYPE sbook-bookid
                i_airport_code TYPE s_airport
            RETURNING
                VALUE(r_cust_data) TYPE z2fanf01_results,

        get_flight_data
            IMPORTING
                i_carrid TYPE sflight-carrid
                i_connid TYPE sflight-connid
                i_midate TYPE sflight-fldate
                i_madate TYPE sflight-fldate
                i_airp TYPE s_airport
            RETURNING
                VALUE(r_flight_data) TYPE z2fanf02_results,

        get_lastminute_flights
            IMPORTING
                i_cityTo         TYPE spfli-cityto
                i_airpTo         TYPE spfli-airpto
                i_counTo         TYPE spfli-countryto
                i_class          TYPE sbook-class
                i_price          TYPE sflight-price
                i_curr           TYPE sflight-currency
                i_airport_code   TYPE s_airport
            RETURNING
                VALUE(r_last_minute_flights) TYPE z2fanf03_results.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS z2_sql_requests IMPLEMENTATION.

    METHOD get_customer_data.
        DATA g_result TYPE z2fanf01_results.

* SQL-Statement to filter out the required information
        SELECT
            FROM ( sbook AS b
            INNER JOIN spfli AS p ON ( b~carrid = p~carrid AND b~connid = p~connid ) )
            INNER JOIN scustom AS c ON ( b~customid = c~id )
            FIELDS
                b~carrid, b~connid, b~fldate, b~bookid,
                b~passname, c~id, c~street,
                p~deptime,
                p~arrtime, p~cityto, p~airpto, p~countryto,
                b~class, b~luggweight, b~wunit,
                b~cancelled, b~reserved
            WHERE p~airpfrom = @i_airport_code
                AND c~name LIKE @i_cname
                "if parameter is not filled by the user, it does not narrow the selection
                AND ( b~carrid = @i_carrid OR @i_carrid IS INITIAL )
                AND ( c~street LIKE @i_cstr OR @i_cstr IS INITIAL )
                AND ( c~city LIKE @i_ccity OR @i_ccity IS INITIAL )
                AND ( b~carrid = @i_carrid OR @i_carrid IS INITIAL )
                AND ( b~connid = @i_connid OR @i_connid IS INITIAL )
                AND ( b~fldate = @i_fldate OR @i_fldate IS INITIAL )
                AND ( b~bookid = @i_bookid OR @i_bookid IS INITIAL )
            INTO TABLE @r_cust_data.

    ENDMETHOD.


    METHOD get_flight_data.
        "Will carry final result table
        DATA g_result TYPE z2fanf02_results.

        " Merge of table sflight and spfli
        SELECT FROM sflight AS f
            "Select also flightplans with no specific flight
            RIGHT OUTER JOIN spfli AS p
            ON f~carrid = p~carrid
            AND f~connid = p~connid
            FIELDS p~carrid, f~connid, f~fldate, p~fltime,
                p~countryfr, p~cityfrom, p~airpfrom, p~deptime,
                p~countryto, p~cityto, p~airpto, p~arrtime,
                f~planetype, f~seatsmax, f~seatsmax_b, f~seatsmax_f
            WHERE p~carrid = @i_carrid
           "if parameter is not filled by the user, it does not narrow the selection
                AND ( p~connid = @i_connid OR @i_connid IS INITIAL )
                AND ( f~fldate >= @i_midate OR @i_midate IS INITIAL )
                AND ( f~fldate <= @i_madate OR @i_madate IS INITIAL )
                AND ( p~airpfrom = @i_airp OR p~airpto = @i_airp OR @i_airp IS INITIAL )
            ORDER BY fldate ASCENDING, p~deptime ASCENDING
            INTO TABLE @r_flight_data.

        " warning if table is initial
        IF r_flight_data IS INITIAL.
            MESSAGE 'Data not found' TYPE 'W'.
        ENDIF.

    ENDMETHOD.

    METHOD get_lastminute_flights.

        "begin of sql query
        SELECT
          "table sflight is given the alias f"
          FROM sflight AS f
          "inner join joins sflight (alias f) and spfli (alias p) on their primary key carrid and connid
          INNER JOIN spfli AS p ON ( f~carrid = p~carrid AND f~connid = p~connid )
          "appropriate fields are selected (can easily be tempered w/)
          FIELDS
            "carrid and connid mainly for assurance
            f~carrid, f~connid,
            "important flight dates/times for travelling agency information
            f~fldate, p~deptime, p~arrtime, p~fltime,
            "destination data is specified (departing airpot is not necessacary since it is i_airport_code by default)
            p~cityto, p~countryto, p~airpto,
            "Switch-Case only selects the available seats for the class specified
            ( CASE
                WHEN @i_class = 'F' THEN f~seatsmax_f - f~seatsocc_f
                WHEN @i_class = 'C' THEN f~seatsmax_b - f~seatsocc_b
                WHEN @i_class = 'Y' THEN f~seatsmax - f~seatsocc
                ELSE f~seatsmax + f~seatsmax_b + f~seatsmax_f - f~seatsocc - f~seatsocc_b - f~seatsocc_f END ) AS seatsavailable,
            f~price, f~currency
          "only flight in the future are necessary
          WHERE f~fldate > @sy-datlo
            "all optional parameters are filtered by their values if they have been initialized by the user
            AND ( p~cityto = @i_cityTo OR @i_cityTo IS INITIAL )
            AND ( p~airpto = @i_airpTo OR @i_airpTo IS INITIAL )
            AND ( p~countryTo = @i_counTo OR @i_counTo IS INITIAL )
            AND ( ( f~price <= @i_price AND f~currency = @i_curr ) OR @i_price IS INITIAL )
            "departing airport must be the airport imported w/ the variable i_airport_code of the type s_airport
            AND p~airpfrom = @i_airport_code
          "table order determinded by the date and time of departure
          ORDER BY f~fldate ASCENDING, p~deptime ASCENDING
          "previously declared table l_result is filled w/ the table received by the sql query
          INTO TABLE @r_last_minute_flights.
    ENDMETHOD.

ENDCLASS.
