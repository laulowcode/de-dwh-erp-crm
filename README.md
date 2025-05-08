# Data Engineering Project

## Overview

This project implements a data pipeline for transforming and validating data through bronze, silver, and gold layers. It includes quality checks, data lineage tracking, and integration documentation.

## Project Structure

├── doc/
│ ├── lineage.md # Data lineage documentation
│ ├── catalog.md # Data catalog documentation
│ └── integration.md # Integration documentation
├── sql/
│ └── gold/
│ └── ddl.sql # Gold layer table definitions
└── tests/
├── quality_checks_silver.sql # Quality checks for silver layer
└── quality_checks_gold.sql # Quality checks for gold layer

## Components

### Data Layers

- **Gold Layer**: Contains the final, business-ready data models
  - Defined in `sql/gold/ddl.sql`
  - Includes quality checks in `tests/quality_checks_gold.sql`

### Quality Assurance

- Silver layer quality checks: `tests/quality_checks_silver.sql`
- Gold layer quality checks: `tests/quality_checks_gold.sql`

### Documentation

- **Data Lineage**: Track data flow and transformations (`doc/lineage.md`)
- **Data Catalog**: Metadata and data dictionary (`doc/catalog.md`)
- **Integration**: Integration patterns and guidelines (`doc/integration.md`)

## Getting Started

### Prerequisites

- SQL database system
- Access to source data systems

### Setup

1. Review the documentation in the `doc/` directory
2. Execute the DDL scripts in `sql/gold/ddl.sql`
3. Run quality checks to validate data integrity

## Quality Checks

The project includes comprehensive quality checks for both silver and gold layers:

- Data completeness
- Data accuracy
- Data consistency
- Business rule validation
