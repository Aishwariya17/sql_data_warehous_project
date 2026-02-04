# Flight Crew Management Data Warehouse and Analytics Project

Welcome to the **Flight Crew Management Data Warehouse and Analytics Project** repository.  
This project demonstrates an end-to-end data warehousing and analytics solution for airline operations, from raw data ingestion to analytics-ready reporting. Designed as a portfolio project, it follows industry best practices in data engineering, data modeling, and SQL analytics.

---

## 🏗️ Data Architecture

The data architecture for this project follows **Medallion Architecture** with **Bronze**, **Silver**, and **Gold** layers and integrates data from multiple airline operational source systems.

![Data Architecture](docs/data_architecture.png)

---

### Source Systems

The warehouse consolidates data from **three airline source systems**, reflecting real-world airline data platforms:

#### OPS – Flight Operations (AODB)
Core flight schedule and movement data.
- Flights  
- Airports  

#### IRROPS – Irregular Operations
Operational disruptions and root-cause events.
- Delay events  
- Weather windows  

#### CMS – Crew Management System
Crew master data and scheduling.
- Crew  
- Crew assignments  
- Aircraft  

---

### Medallion Layers

#### Bronze Layer
- Stores raw data ingested directly from CSV files
- No transformations applied
- Preserves source-system structure and values

#### Silver Layer
- Cleanses and standardizes data
- Applies business rules and validations
- Resolves duplicates and invalid records
- Creates conformed datasets across source systems

#### Gold Layer
- Analytics-ready star schema
- Optimized for reporting and SQL analytics
- Supports operational KPIs and performance analysis

---

## 📖 Project Overview

This project includes:

1. Designing a modern SQL Server data warehouse using Medallion Architecture  
2. Building ETL pipelines to ingest data from OPS, IRROPS, and CMS systems  
3. Modeling fact and dimension tables for airline analytics  
4. Writing SQL-based analytical queries for operational insights  

---

## 🎯 Skills Demonstrated

- SQL Development  
- Data Architecture  
- Data Engineering  
- ETL Pipeline Development  
- Data Modeling  
- Data Analytics  

---

## 🛠️ Tools and Resources

All tools used in this project are free.

- **Datasets:** CSV files simulating airline operational systems  
- **SQL Server Express:** Database engine  
- **SQL Server Management Studio (SSMS):** Querying and management  
- **Git & GitHub:** Version control  
- **DrawIO:** Architecture, data flow, and data model diagrams  
- **Notion:** Project planning and documentation  

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a SQL Server–based data warehouse that consolidates airline operational data from multiple source systems to enable analytics and decision-making.

---

### Data Sources

#### OPS – Flight Operations
- Flights  
- Airports  

#### IRROPS – Irregular Operations
- Delay events  
- Weather windows  

#### CMS – Crew Management System
- Crew  
- Crew assignments  
- Aircraft  

---

### Data Quality

The project addresses common airline data quality challenges:
- Duplicate records  
- Inconsistent date and timestamp formats  
- Invalid or missing airport codes  
- Cancelled flights with populated actual timestamps  
- Negative or malformed delay values  
- Overlapping or invalid crew duty windows  

---

### Integration

All datasets are integrated into a unified analytical model:
- Flights linked to routes, airports, aircraft, and calendar dates  
- Crew assignments linked to flights and crew members  
- Delay events mapped to standardized delay categories  
- Weather windows associated with impacted airports  

---

### Scope

- Focus on the most recent **24 months of data**
- Approximately **50,000 flights**
- No slowly changing dimensions or historization
- Retain the most recent valid record when duplicates exist

---

### Documentation

The repository includes documentation for:
- Data architecture  
- ETL workflows  
- Data models (star schema)  
- Dataset catalog and naming conventions  

---

## 📊 BI and Analytics

### Objective
Develop SQL-based analytics to deliver insights into:

- Flight on-time performance (OTP)  
- Crew utilization and duty hours  
- Delay root cause analysis (IRROPS)  
- Route, airport, and hub performance  

These analytics support operational monitoring and data-driven decision-making.

---

## 📂 Repository Structure

flight-crew-data-warehouse/
│
├── datasets/
│ ├── source_ops/ # Flight Operations (OPS)
│ │ ├── flights.csv
│ │ └── airports.csv
│ │
│ ├── source_irrops/ # Irregular Operations (IRROPS)
│ │ ├── delay_events.csv
│ │ └── weather_windows.csv
│ │
│ └── source_cms/ # Crew Management System (CMS)
│ ├── crew.csv
│ ├── crew_assignments.csv
│ └── aircraft.csv
│
├── docs/
│ ├── data_architecture.png
│ ├── etl.drawio
│ ├── data_architecture.drawio
│ ├── data_flow.drawio
│ ├── data_models.drawio
│ ├── data_catalog.md
│ └── naming-conventions.md
│
├── scripts/
│ ├── bronze/ # Raw ingestion scripts
│ ├── silver/ # Cleansing and transformations
│ └── gold/ # Analytics-ready models
│
├── tests/ # Data quality checks
│
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt

---

## 🛡️ License

This project is licensed under the MIT License.
