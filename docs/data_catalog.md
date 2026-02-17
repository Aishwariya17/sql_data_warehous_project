# 📊 Gold Layer Data Catalog  
## Flight Crew Management – Medallion Architecture

---

## 📌 Overview

The **Gold Layer** represents the business-ready analytical model for the Flight Crew Management system.

It is structured using a **star schema with natural keys** and is designed to support:

- Operational reporting  
- On-time performance analytics  
- Crew utilization analysis  
- Delay root cause reporting  
- Weather disruption analysis  

The Gold layer consists of:

- **Dimension Tables** → Reference/master data  
- **Fact Tables** → Events and measurable business metrics  

---

# 🟡 Dimension Tables

---

## 1️⃣ `gold.dim_airports`

**Purpose:**  
Stores airport reference information used for routing, operational reporting, and weather analysis.

**Primary Key:** `airport_code`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| airport_code | NVARCHAR(10) | Natural key representing the airport code (typically 3-letter IATA code, e.g., `JFK`). |
| state | NVARCHAR(50) | State or administrative region where the airport is located. |
| region | NVARCHAR(50) | High-level geographic region grouping. |
| airport_name | NVARCHAR(200) | Full official airport name. |
| hub_flag | NVARCHAR(10) | Indicates whether the airport is a hub (`Yes`, `No`, `n/a`). |

---

## 2️⃣ `gold.dim_aircraft`

**Purpose:**  
Stores aircraft reference data for fleet-level reporting and operational analytics.

**Primary Key:** `aircraft_id`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| aircraft_id | NVARCHAR(50) | Natural key uniquely identifying each aircraft. |
| aircraft_type | NVARCHAR(50) | Standardized aircraft model (e.g., `A320`, `B737`, `E175`). |
| tail_number | NVARCHAR(50) | Aircraft registration number. |
| in_service_date | DATE | Date the aircraft entered operational service. |
| retired_flag | NVARCHAR(10) | Indicates whether the aircraft is retired (`Yes`, `No`, `n/a`). |

---

## 3️⃣ `gold.dim_crew`

**Purpose:**  
Stores crew reference information used for staffing, scheduling, and utilization reporting.

**Primary Key:** `crew_id`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| crew_id | NVARCHAR(50) | Natural key uniquely identifying each crew member. |
| crew_name | NVARCHAR(200) | Full name of the crew member. |
| crew_role | NVARCHAR(50) | Standardized crew role (e.g., `Captain`, `First_Officer`, `Flight_Attendant`, `Purser`). |
| base_airport | NVARCHAR(10) | Assigned base airport for the crew member. |
| hire_date | DATE | Date the crew member was hired. |
| active_flag | NVARCHAR(10) | Indicates whether the crew member is active (`Yes`, `No`, `n/a`). |

---

# 🔵 Fact Tables

---

## 4️⃣ `gold.fact_flights`

**Purpose:**  
Stores flight-level operational metrics used for on-time performance, cancellation analysis, and aircraft utilization.

**Grain:** 1 row per flight (`flight_id`)  
**Primary Key:** `flight_id`

**Foreign Keys:**
- `origin_airport_code` → `gold.dim_airports.airport_code`
- `destination_airport_code` → `gold.dim_airports.airport_code`
- `aircraft_id` → `gold.dim_aircraft.aircraft_id`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| flight_id | NVARCHAR(50) | Unique identifier for the flight (raw flight ID). |
| flight_number | NVARCHAR(20) | Published flight number (e.g., `AA123`). |
| flight_date | DATE | Calendar date of the flight. |
| origin_airport_code | NVARCHAR(10) | Origin airport code. |
| destination_airport_code | NVARCHAR(10) | Destination airport code. |
| aircraft_id | NVARCHAR(50) | Aircraft assigned to the flight. |
| scheduled_dep_ts | DATETIME2 | Scheduled departure timestamp. |
| actual_dep_ts | DATETIME2 | Actual departure timestamp. |
| scheduled_arr_ts | DATETIME2 | Scheduled arrival timestamp. |
| actual_arr_ts | DATETIME2 | Actual arrival timestamp. |
| cancelled_flag | NVARCHAR(10) | Indicates if flight was cancelled. |
| diverted_flag | NVARCHAR(10) | Indicates if flight was diverted. |
| status_text | NVARCHAR(200) | Operational status description. |
| last_updated_ts | DATETIME2 | Most recent update timestamp. |
| departure_delay_minutes | INT | Delay in minutes at departure. |
| arrival_delay_minutes | INT | Delay in minutes at arrival. |
| flight_duration_minutes | INT | Duration in minutes (actual departure → arrival). |
| is_departure_delayed | INT | 1 = delayed departure, 0 = not delayed. |
| is_arrival_delayed | INT | 1 = delayed arrival, 0 = not delayed. |

---

## 5️⃣ `gold.fact_crew_assignments`

**Purpose:**  
Stores crew assignments per flight for duty time tracking and staffing analysis.

**Grain:** 1 row per assignment (`assignment_id`)  
**Primary Key:** `assignment_id`

**Foreign Keys:**
- `flight_id` → `gold.fact_flights.flight_id`
- `crew_id` → `gold.dim_crew.crew_id`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| assignment_id | NVARCHAR(50) | Unique identifier for crew assignment. |
| flight_id | NVARCHAR(50) | Flight identifier. |
| crew_id | NVARCHAR(50) | Crew member identifier. |
| duty_start_ts | DATETIME2 | Duty start timestamp. |
| duty_end_ts | DATETIME2 | Duty end timestamp. |
| reserve_flag | NVARCHAR(10) | Indicates reserve assignment. |
| assignment_status | NVARCHAR(50) | Status of the assignment. |
| last_updated_ts | DATETIME2 | Most recent update timestamp. |
| duty_minutes | INT | Duration of duty in minutes. |
| is_invalid_duty_window | INT | 1 if duty window is invalid, else 0. |

---

## 6️⃣ `gold.fact_delay_events`

**Purpose:**  
Stores flight delay events used for root cause and disruption analysis.

**Grain:** 1 row per delay event (`delay_event_id`)  
**Primary Key:** `delay_event_id`

**Foreign Key:**
- `flight_id` → `gold.fact_flights.flight_id`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| delay_event_id | NVARCHAR(50) | Unique identifier for delay event. |
| flight_id | NVARCHAR(50) | Associated flight identifier. |
| delay_ts | DATETIME2 | Timestamp of the delay event. |
| delay_category | NVARCHAR(50) | Delay category (e.g., `WEATHER`, `CREW`, `MAINT`). |
| delay_code | NVARCHAR(50) | Detailed delay code. |
| delay_minutes | INT | Duration of delay in minutes. |
| notes | NVARCHAR(500) | Additional delay notes or comments. |

---

## 7️⃣ `gold.fact_weather_windows`

**Purpose:**  
Stores airport-level weather disruption windows used for impact analysis.

**Grain:** 1 row per weather window (`weather_window_id`)  
**Primary Key:** `weather_window_id`

**Foreign Key:**
- `airport_code` → `gold.dim_airports.airport_code`

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| weather_window_id | NVARCHAR(50) | Unique identifier for weather window. |
| airport_code | NVARCHAR(10) | Airport where weather applies. |
| weather_start_ts | DATETIME2 | Start timestamp of weather window. |
| weather_end_ts | DATETIME2 | End timestamp of weather window. |
| weather_type | NVARCHAR(50) | Weather type (e.g., `STORM`, `FOG`, `SNOW`). |
| severity | INT | Severity score of the weather event. |
| weather_duration_minutes | INT | Duration of weather window in minutes. |

---

# 🏗 Architecture Summary

- **Bronze Layer:** Raw source ingestion  
- **Silver Layer:** Cleansed, standardized, deduplicated operational data  
- **Gold Layer:** Business-ready star schema for analytics  

This design supports scalable reporting and can be translated directly to Snowflake, Databricks, or dbt-based cloud implementations.
