/*
===============================================================================
DDL Script: Create Gold Views (Optimized - Natural Keys)
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_airports
-- PK: airport_code (Natural Key)
-- =============================================================================
CREATE OR ALTER VIEW gold.dim_airports AS
SELECT
    airport_code,
    state,
    region,
    airport_name,
    hub_flag
FROM silver.airports;
GO

-- =============================================================================
-- Create Dimension: gold.dim_aircraft
-- PK: aircraft_id (Natural Key)
-- =============================================================================
CREATE OR ALTER VIEW gold.dim_aircraft AS
SELECT
    aircraft_id,
    aircraft_type,
    tail_number,
    in_service_date,
    retired_flag
FROM silver.aircraft;
GO

-- =============================================================================
-- Create Dimension: gold.dim_crew
-- PK: crew_id (Natural Key)
-- =============================================================================
CREATE OR ALTER VIEW gold.dim_crew AS
SELECT
    crew_id,
    crew_name,
    crew_role,
    base_airport,
    hire_date,
    active_flag
FROM silver.crew;
GO

-- =============================================================================
-- Create Fact: gold.fact_flights
-- PK: flight_id (raw_flight_id)
-- FKs: origin_airport_code -> dim_airports.airport_code
--      destination_airport_code -> dim_airports.airport_code
--      aircraft_id -> dim_aircraft.aircraft_id
-- =============================================================================
CREATE OR ALTER VIEW gold.fact_flights AS
SELECT
    raw_flight_id           AS flight_id,
    flight_number,
    flight_date,

    origin                  AS origin_airport_code,
    destination             AS destination_airport_code,
    aircraft_id             AS aircraft_id,

    scheduled_dep_ts,
    actual_dep_ts,
    scheduled_arr_ts,
    actual_arr_ts,

    cancelled_flag,
    diverted_flag,
    status_text,
    last_updated_ts,

    DATEDIFF(MINUTE, scheduled_dep_ts, actual_dep_ts) AS departure_delay_minutes,
    DATEDIFF(MINUTE, scheduled_arr_ts, actual_arr_ts) AS arrival_delay_minutes,
    DATEDIFF(MINUTE, actual_dep_ts, actual_arr_ts)    AS flight_duration_minutes,

    CASE WHEN DATEDIFF(MINUTE, scheduled_dep_ts, actual_dep_ts) > 0 THEN 1 ELSE 0 END AS is_departure_delayed,
    CASE WHEN DATEDIFF(MINUTE, scheduled_arr_ts, actual_arr_ts) > 0 THEN 1 ELSE 0 END AS is_arrival_delayed
FROM silver.flights;
GO

-- =============================================================================
-- Create Fact: gold.fact_crew_assignments
-- PK: assignment_id
-- FKs: flight_id -> fact_flights.flight_id
--      crew_id -> dim_crew.crew_id
-- =============================================================================
CREATE OR ALTER VIEW gold.fact_crew_assignments AS
SELECT
    assignment_id,
    raw_flight_id           AS flight_id,
    crew_id,

    duty_start_ts,
    duty_end_ts,
    reserve_flag,
    assignment_status,
    last_updated_ts,

    DATEDIFF(MINUTE, duty_start_ts, duty_end_ts) AS duty_minutes,

    CASE
        WHEN duty_start_ts IS NULL
          OR duty_end_ts IS NULL
          OR duty_end_ts <= duty_start_ts
        THEN 1 ELSE 0
    END AS is_invalid_duty_window
FROM silver.crew_assignments;
GO

-- =============================================================================
-- Create Fact: gold.fact_delay_events
-- PK: delay_event_id
-- FK: flight_id -> fact_flights.flight_id
-- =============================================================================
CREATE OR ALTER VIEW gold.fact_delay_events AS
SELECT
    delay_event_id,
    raw_flight_id AS flight_id,
    delay_ts,
    delay_category,
    delay_code,
    delay_minutes,
    notes
FROM silver.delay_events;
GO

-- =============================================================================
-- Create Fact: gold.fact_weather_windows
-- PK: weather_window_id
-- FK: airport_code -> dim_airports.airport_code
-- =============================================================================
CREATE OR ALTER VIEW gold.fact_weather_windows AS
SELECT
    weather_window_id,
    airport_code,
    weather_start_ts,
    weather_end_ts,
    weather_type,
    severity,
    DATEDIFF(MINUTE, weather_start_ts, weather_end_ts) AS weather_duration_minutes
FROM silver.weather_windows;
GO
