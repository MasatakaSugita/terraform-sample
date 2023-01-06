init:
	docker-compose exec terraform terraform init

plan:
	docker-compose exec terraform terraform init && \
	docker-compose exec terraform terraform plan

apply:
	docker-compose exec terraform terraform init && \
  docker-compose exec terraform terraform apply

destroy:
	docker-compose exec terraform terraform init && \
	docker-compose exec terraform terraform destroy

fmt:
	docker-compose exec terraform terraform fmt -recursive

up:
	docker-compose up -d --build

down:
	docker-compose down