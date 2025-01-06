# Variables
FRONTEND_DIR := user-facing-frontend
BACKEND_DIR := user-facing-backend
DOCKER_IMAGE := appointment-system
DOCKER_REGISTRY := your-docker-registry # Replace with actual registry
K8S_NAMESPACE := appointment-system
ENV_FILE := .env

# push to backend subtree
# make BRANCH=project-bootstrapping push-to-backend-subtree
push-to-backend-subtree:
	echo "Pushing to Subtree user-facing-backend/Express-Typescipt at branch $(BRANCH)"
	git subtree push --prefix=user-facing-backend/Express-Typescipt https://github.com/arsalanator/user-facing-backend-for-appointment-system-with-Express-Typescipt $(BRANCH)

# push to frontend subtree
# make BRANCH=project-bootstrapping push-to-frontend-subtree
push-to-frontend-subtree:
	echo "Pushing to Subtree user-facing-frontend/React-Typescipt at branch $(BRANCH)"
	git subtree push --prefix=user-facing-frontend/React-Typescipt https://github.com/arsalanator/user-facing-frontend-for-appointment-system-with-React-Typescipt $(BRANCH)

# generating a zip file of project
generate-project-rar-file:
	echo "Generating project .rar file"
	rm -rf current_app_state.zip && zip -r current_app_state.zip . -x "user-facing-backend/Express-Typescipt/node_modules/*" "user-facing-frontend/React-Typescipt/node_modules/*"

# Frontend tasks
install-frontend:
	cd $(FRONTEND_DIR) && npm install

start-frontend:
	cd $(FRONTEND_DIR) && npm start

build-frontend:
	cd $(FRONTEND_DIR) && npm run build

test-frontend:
	cd $(FRONTEND_DIR) && npm test

# Backend tasks
install-backend:
	cd $(BACKEND_DIR) && npm install

start-backend:
	cd $(BACKEND_DIR) && npm run dev

build-backend:
	cd $(BACKEND_DIR) && npm run build

test-backend:
	cd $(BACKEND_DIR) && npm test

# Docker tasks
build-docker:
	docker build -t $(DOCKER_IMAGE):latest .

push-docker:
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):latest
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):latest

# Docker Compose
docker-compose-up:
	docker-compose up --build -d

docker-compose-down:
	docker-compose down

# Kubernetes (Minikube)
k8s-deploy:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete namespace $(K8S_NAMESPACE)

k8s-create-namespace:
	kubectl create namespace $(K8S_NAMESPACE)

k8s-deploy-configs:
	kubectl apply -f k8s/configmaps/ -n $(K8S_NAMESPACE)
	kubectl apply -f k8s/secrets/ -n $(K8S_NAMESPACE)

k8s-deploy-services:
	kubectl apply -f k8s/services/ -n $(K8S_NAMESPACE)

k8s-deploy-deployments:
	kubectl apply -f k8s/deployments/ -n $(K8S_NAMESPACE)

# Combined tasks
install-all: install-frontend install-backend

start-all: start-frontend start-backend

build-all: build-frontend build-backend build-docker

test-all: test-frontend test-backend

deploy-all:
	make docker-compose-up
	make k8s-deploy

clean:
	rm -rf $(FRONTEND_DIR)/node_modules $(BACKEND_DIR)/node_modules
	rm -rf $(FRONTEND_DIR)/build $(BACKEND_DIR)/dist

lint-frontend:
	cd $(FRONTEND_DIR) && npm run lint

lint-backend:
	cd $(BACKEND_DIR) && npm run lint

lint-all: lint-frontend lint-backend