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
