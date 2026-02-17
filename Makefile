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


coverage:
	docker-compose run --rm app mvn jacoco:report


k6:
	@echo "🏎 Running K6 against $(BASE_URL)"
	@BASE_URL=$(BASE_URL) ./k6/run.sh
