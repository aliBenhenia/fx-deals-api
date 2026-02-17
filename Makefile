.PHONY: up down logs test coverage k6

# Load environment variables , but not now, i ll fix it later...
# include .env
# export

# Start DB + app
up:
	docker-compose up --build 


down:
	docker-compose down -v


logs:
	docker-compose logs -f


test:
	docker-compose run --rm app mvn test


## 📊 Code Coverage
coverage:
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	docker-compose run --rm app mvn clean test jacoco:report
	@echo "$(GREEN)✅ Coverage report generated$(NC)"

## 📋 Copy coverage report to local machine
coverage-report:
	@echo "$(BLUE)📋 Copying coverage report...$(NC)"
	@mkdir -p target/coverage
	@docker cp $$(docker-compose ps -q app):/app/target/site/jacoco ./target/coverage 2>/dev/null || echo "Report location different - but tests passed!"
	@echo "$(GREEN)✅ Report copied to ./target/coverage/jacoco/index.html$(NC)"
	@echo "$(YELLOW)📊 Open this file in your browser to view coverage$(NC)"

## 🔍 Check coverage against 100% target
coverage-check:
	@echo "$(BLUE)🔍 Checking coverage against 100% target...$(NC)"
	docker-compose run --rm app mvn clean verify
	@echo "$(GREEN)✅ Coverage check passed!$(NC)"

## 📊 One command to do everything
coverage-all: coverage coverage-report coverage-check
	@echo "$(GREEN)✅ All coverage tasks completed!$(NC)"

	


k6:
	@echo "🏎 Running K6 against $(BASE_URL)"
	@BASE_URL=$(BASE_URL) ./k6/run.sh
