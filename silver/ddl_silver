/*
===============================================================================
DDL Script: Create silver Tables – Flight Crew Management
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' tables.
===============================================================================
*/

-- Ensure silver schema exists
IF SCHEMA_ID('silver') IS NULL
    EXEC('CREATE SCHEMA silver');
GO

/* =========================================================
   AIRCRAFT
========================================================= */
IF OBJECT_ID('silver.aircraft', 'U') IS NOT NULL
    DROP TABLE silver.aircraft;
GO

CREATE TABLE silver.aircraft (
    aircraft_id       NVARCHAR(50),
    tail_number       NVARCHAR(50),
    aircraft_type     NVARCHAR(100),
    in_service_date   NVARCHAR(50),
    retired_flag      NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   AIRPORTS
========================================================= */
IF OBJECT_ID('silver.airports', 'U') IS NOT NULL
    DROP TABLE silver.airports;
GO

CREATE TABLE silver.airports (
    airport_code      NVARCHAR(50),
    city              NVARCHAR(50),
    state             NVARCHAR(50),
    region            NVARCHAR(50),
    airport_name      NVARCHAR(100),
    hub_flag          NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   CREW
========================================================= */
IF OBJECT_ID('silver.crew', 'U') IS NOT NULL
    DROP TABLE silver.crew;
GO

CREATE TABLE silver.crew (
    crew_id           NVARCHAR(50),
    crew_name         NVARCHAR(50),
    crew_role         NVARCHAR(50),
    base_airport      NVARCHAR(50),
    hire_date         NVARCHAR(50),
    active_flag       NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   CREW ASSIGNMENTS
========================================================= */
IF OBJECT_ID('silver.crew_assignments', 'U') IS NOT NULL
    DROP TABLE silver.crew_assignments;
GO

CREATE TABLE silver.crew_assignments (
    assignment_id     NVARCHAR(50),
    crew_id           NVARCHAR(50),
    raw_flight_id     NVARCHAR(50),
    duty_start_ts     NVARCHAR(50),
    duty_end_ts       NVARCHAR(50),
    reserve_flag      NVARCHAR(50),
    assignment_status NVARCHAR(50),
    last_updated_ts   NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   DELAY EVENTS
========================================================= */
IF OBJECT_ID('silver.delay_events', 'U') IS NOT NULL
    DROP TABLE silver.delay_events;
GO

CREATE TABLE silver.delay_events (
    delay_event_id    NVARCHAR(50),
    raw_flight_id     NVARCHAR(50),
    delay_ts          NVARCHAR(50),
    delay_category    NVARCHAR(50),
    delay_code        NVARCHAR(50),
    delay_minutes     NVARCHAR(50),
    notes             NVARCHAR(200),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   FLIGHTS
========================================================= */
IF OBJECT_ID('silver.flights', 'U') IS NOT NULL
    DROP TABLE silver.flights;
GO

CREATE TABLE silver.flights (
    raw_flight_id      NVARCHAR(50),
    flight_number      NVARCHAR(50),
    flight_date        NVARCHAR(50),
    origin             NVARCHAR(50),
    destination        NVARCHAR(50),
    scheduled_dep_ts   NVARCHAR(50),
    actual_dep_ts      NVARCHAR(50),
    scheduled_arr_ts   NVARCHAR(50),
    actual_arr_ts      NVARCHAR(50),
    cancelled_flag     NVARCHAR(50),
    diverted_flag      NVARCHAR(50),
    aircraft_id        NVARCHAR(50),
    status_text        NVARCHAR(50),
    last_updated_ts    NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* =========================================================
   WEATHER WINDOWS
========================================================= */
IF OBJECT_ID('silver.weather_windows', 'U') IS NOT NULL
    DROP TABLE silver.weather_windows;
GO

CREATE TABLE silver.weather_windows (
    weather_window_id NVARCHAR(50),
    airport_code      NVARCHAR(50),
    weather_start_ts  NVARCHAR(50),
    weather_end_ts    NVARCHAR(50),
    weather_type      NVARCHAR(50),
    severity          NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
