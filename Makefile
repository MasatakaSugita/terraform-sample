up:
	docker-compose up -d --build

init:
	docker-compose exec terraform terraform init

plan:
	docker-compose exec terraform terraform init && \
	docker-compose exec terraform terraform plan

destroy:
	docker-compose exec terraform terraform init && \
	docker-compose exec terraform terraform destroy