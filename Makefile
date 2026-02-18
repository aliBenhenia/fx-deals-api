.PHONY: up down logs test coverage coverage-report coverage-check coverage-all k6

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# Start DB + app
up:
	docker compose up -d --build

# Stop everything
down:
	docker compose down -v

# View logs
logs:
	docker compose logs -f

# Run tests
test:
	docker compose run --rm app mvn test

# Generate coverage report
coverage:
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	docker compose run --rm app mvn clean test jacoco:report
	@echo "$(GREEN)✅ Coverage report generated$(NC)"



# Check coverage against 100% target
coverage-check:
	@echo "$(BLUE)🔍 Checking coverage...$(NC)"
	docker compose run --rm app mvn clean verify
	@echo "$(GREEN)✅ Coverage check passed!$(NC)"

# Run all coverage tasks
coverage-all: coverage coverage-report coverage-check
	@echo "$(GREEN)✅ All coverage tasks completed!$(NC)"

# Run K6 performance tests
k6:
	@echo "🏎 Running K6 performance tests..."
	@cd k6 && ./run.sh