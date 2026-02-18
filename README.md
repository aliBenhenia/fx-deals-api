# FX Deals API — SDET Assignment

Spring Boot REST API to accept FX deals, validate data, prevent duplicates, and persist to PostgreSQL with full test coverage.

## Features

* Accept deal with required fields
* Field validation (format, missing, negative values)
* Duplicate prevention (HTTP 409)
* No rollback (partial success supported)
* PostgreSQL with Docker
* Full automated tests (Unit, Integration, API)
* 100% coverage with JaCoCo
* K6 performance testing
* Postman collection included
* Makefile automation

## Quick Start

```bash
git clone https://github.com/aliBenhenia/fx-deals-api
cd fx-deals-api
make up
```

## Run Tests

```bash
make test
make coverage
make coverage-check
```

## API Example

```bash
curl -X POST http://localhost:8080/api/deals \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"TEST_001\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$(date +%Y-%m-%dT%H:%M:%S)\"
  }"

```

## Makefile Commands

* `make up` — start app
* `make test` — run tests
* `make coverage` — coverage report
* `make k6` — performance test
* `make down` — stop services

## Verification

All requirements implemented:

* Validation
* Deduplication
* No rollback
* Real DB
* Tests + coverage
* Dockerized deployment

---


