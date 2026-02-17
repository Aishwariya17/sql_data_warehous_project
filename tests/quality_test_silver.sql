/*
===============================================================================
Quality Checks – Flight Crew Management (Silver Layer)
===============================================================================
Script Purpose:
    This script performs quality checks for data consistency, accuracy, and
    standardization across the 'silver' layer tables in the Flight Crew
    Management project. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces and inconsistent casing in string fields.
    - Standardization consistency for flags and categorical fields.
    - Invalid date ranges and timestamp ordering.
    - Cross-field consistency checks for operational logic (Flights, Crew, etc.)

Usage Notes:
    - Run these checks AFTER loading the Silver Layer.
    - Expectation for most checks: NO ROWS returned.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.aircraft'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    aircraft_id,
    COUNT(*) AS row_count
FROM silver.aircraft
GROUP BY aircraft_id
HAVING COUNT(*) > 1 OR aircraft_id IS NULL;

-- Check for Unwanted Spaces in Aircraft Type / Tail Number
-- Expectation: No Results
SELECT
    aircraft_id,
    aircraft_type,
    tail_number
FROM silver.aircraft
WHERE aircraft_type <> TRIM(aircraft_type)
   OR tail_number  <> TRIM(tail_number);

-- Data Standardization & Consistency (Retired Flag)
SELECT DISTINCT
    retired_flag
FROM silver.aircraft;

-- Optional: Tail number formatting sanity (example: hyphens)
-- Expectation: Investigate if multiple records share same tail_number
SELECT
    tail_number,
    COUNT(*) AS cnt
FROM silver.aircraft
WHERE tail_number LIKE '%-%'
GROUP BY tail_number
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'silver.airports'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key (Assuming airport_code is PK)
-- Expectation: No Results
SELECT
    airport_code,
    COUNT(*) AS row_count
FROM silver.airports
GROUP BY airport_code
HAVING COUNT(*) > 1 OR airport_code IS NULL;

-- Check Airport Code Standardization (3-letter code, trimmed, uppercase)
-- Expectation: No Results
SELECT
    airport_code
FROM silver.airports
WHERE LEN(TRIM(airport_code)) <> 3
   OR airport_code <> UPPER(TRIM(airport_code));

-- Data Standardization & Consistency (Hub Flag)
SELECT DISTINCT
    hub_flag
FROM silver.airports;


-- ====================================================================
-- Checking 'silver.crew'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    crew_id,
    COUNT(*) AS row_count
FROM silver.crew
GROUP BY crew_id
HAVING COUNT(*) > 1 OR crew_id IS NULL;

-- Check for Unwanted Spaces in Crew Name / Role / Base Airport
-- Expectation: No Results
SELECT
    crew_id,
    crew_name,
    crew_role,
    base_airport
FROM silver.crew
WHERE crew_name  <> TRIM(crew_name)
   OR crew_role  <> TRIM(crew_role)
   OR (base_airport IS NOT NULL AND base_airport <> TRIM(base_airport));

-- Data Standardization & Consistency (Role + Active Flag)
SELECT DISTINCT crew_role  FROM silver.crew;
SELECT DISTINCT active_flag FROM silver.crew;


-- ====================================================================
-- Checking 'silver.crew_assignments'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    assignment_id,
    COUNT(*) AS row_count
FROM silver.crew_assignments
GROUP BY assignment_id
HAVING COUNT(*) > 1 OR assignment_id IS NULL;

-- Check for NULL Crew IDs (FK completeness)
-- Expectation: No Results (unless business allows)
SELECT
    assignment_id,
    crew_id
FROM silver.crew_assignments
WHERE crew_id IS NULL;

-- Invalid duty timestamps (conversion failures should not exist in silver)
-- Expectation: No Results
SELECT *
FROM silver.crew_assignments
WHERE duty_start_ts IS NULL
   OR duty_end_ts IS NULL;

-- Duty timestamp ordering (end must be after start)
-- Expectation: No Results
SELECT *
FROM silver.crew_assignments
WHERE duty_end_ts < duty_start_ts;

-- Reserve flag standardization
SELECT DISTINCT reserve_flag
FROM silver.crew_assignments;


-- ====================================================================
-- Checking 'silver.flights'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT raw_flight_id, COUNT(*) AS cnt
FROM silver.flights
GROUP BY raw_flight_id
HAVING COUNT(*) > 1 OR raw_flight_id IS NULL;

-- Flight number standardization (no spaces, uppercase)
-- Expectation: No Results
SELECT raw_flight_id, flight_number
FROM silver.flights
WHERE flight_number LIKE '% %'
   OR flight_number <> UPPER(flight_number);

-- Origin/Destination standardization (3-letter, uppercase)
-- Expectation: No Results
SELECT raw_flight_id, origin, destination
FROM silver.flights
WHERE origin IS NULL OR destination IS NULL
   OR LEN(TRIM(origin)) <> 3 OR LEN(TRIM(destination)) <> 3
   OR origin <> UPPER(TRIM(origin))
   OR destination <> UPPER(TRIM(destination));

-- Scheduled timestamps should exist (core for OTP)
-- Expectation: No Results (unless allowed by source)
SELECT raw_flight_id, scheduled_dep_ts, scheduled_arr_ts
FROM silver.flights
WHERE scheduled_dep_ts IS NULL
   OR scheduled_arr_ts IS NULL;

-- Timestamp ordering sanity
-- Expectation: No Results
SELECT *
FROM silver.flights
WHERE scheduled_dep_ts IS NOT NULL
  AND scheduled_arr_ts IS NOT NULL
  AND scheduled_arr_ts <= scheduled_dep_ts;

SELECT *
FROM silver.flights
WHERE actual_dep_ts IS NOT NULL
  AND actual_arr_ts IS NOT NULL
  AND actual_arr_ts <= actual_dep_ts;

-- Cancelled vs Actuals consistency
-- Expectation: No Results
SELECT *
FROM silver.flights
WHERE cancelled_flag = 'No'
  AND UPPER(TRIM(status_text)) LIKE '%CANCEL%';

-- Not-cancelled past flights should not be missing BOTH actual times
-- Expectation: No Results (or review as "data missing")
SELECT *
FROM silver.flights
WHERE cancelled_flag = 'No'
  AND flight_date < CAST(GETDATE() AS date)
  AND actual_dep_ts IS NULL
  AND actual_arr_ts IS NULL;

-- Cancelled flights should typically not have actuals (exceptions possible)
-- Expectation: Review
SELECT *
FROM silver.flights
WHERE cancelled_flag = 'Yes'
  AND (actual_dep_ts IS NOT NULL OR actual_arr_ts IS NOT NULL);

-- Diverted flag standardization
SELECT DISTINCT diverted_flag
FROM silver.flights;


-- ====================================================================
-- Checking 'silver.delay_events'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results (if delay_event_id is the PK)
SELECT delay_event_id, COUNT(*) AS cnt
FROM silver.delay_events
GROUP BY delay_event_id
HAVING COUNT(*) > 1 OR delay_event_id IS NULL;

-- Delay timestamp should parse
-- Expectation: No Results
SELECT *
FROM silver.delay_events
WHERE delay_ts IS NULL;

-- Delay minutes should not be negative
-- Expectation: No Results
SELECT delay_event_id, delay_minutes
FROM silver.delay_events
WHERE delay_minutes < 0;

-- Standardization checks
SELECT DISTINCT delay_category FROM silver.delay_events;
SELECT DISTINCT delay_code     FROM silver.delay_events;

-- Notes should not have leading/trailing spaces (if stored as cleaned)
-- Expectation: No Results
SELECT delay_event_id, notes
FROM silver.delay_events
WHERE notes <> TRIM(notes);


-- ====================================================================
-- Checking 'silver.weather_windows'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT weather_window_id, COUNT(*) AS cnt
FROM silver.weather_windows
GROUP BY weather_window_id
HAVING COUNT(*) > 1 OR weather_window_id IS NULL;

-- Airport code validation (3-letter, uppercase)
-- Expectation: No Results
SELECT *
FROM silver.weather_windows
WHERE airport_code IS NULL
   OR LEN(TRIM(airport_code)) <> 3
   OR airport_code <> UPPER(TRIM(airport_code));

-- Timestamp ordering (end should be >= start)
-- Expectation: No Results
SELECT *
FROM silver.weather_windows
WHERE weather_start_ts IS NULL
   OR weather_end_ts IS NULL
   OR weather_end_ts < weather_start_ts;

-- Weather type standardization
SELECT DISTINCT weather_type
FROM silver.weather_windows;

-- Severity sanity checks (optional: tune thresholds based on your data)
SELECT *
FROM silver.weather_windows
WHERE severity IS NULL;
