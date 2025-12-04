#!/bin/bash
set -e

AWS_ACCOUNT="803817915563"
REGION="us-east-1"

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./deploy.sh <app> <tag>"
  echo "Example: ./deploy.sh frontend v2"
  echo "         ./deploy.sh backend v1"
  exit 1
fi

APP="$1"
TAG="$2"
ECR_REPO="${AWS_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${APP}"
FULL_IMAGE="${ECR_REPO}:${TAG}"
APP_DIR="./${APP}"
DEPLOYMENT_FILE="./base/${APP}/deployment.yaml"

if [ ! -d "${APP_DIR}" ]; then
  echo "Error: App directory '${APP_DIR}' not found"
  exit 1
fi

if [ ! -f "${DEPLOYMENT_FILE}" ]; then
  echo "Error: Deployment file '${DEPLOYMENT_FILE}' not found"
  exit 1
fi

echo "==> Logging into ECR..."
aws ecr get-login-password --region ${REGION} | finch login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

echo "==> Building image: ${FULL_IMAGE}"
finch build --no-cache --platform linux/arm64,linux/amd64 --tag ${FULL_IMAGE} ${APP_DIR}

echo "==> Pushing image: ${FULL_IMAGE}"
finch push --platform linux/arm64,linux/amd64 ${FULL_IMAGE}

echo "==> Updating deployment to use ${FULL_IMAGE}"
sed -i '' "s|image: ${ECR_REPO}:.*|image: ${FULL_IMAGE}|" ${DEPLOYMENT_FILE}

echo "==> Done! Don't forget to commit and push:"
echo "    git add -A && git commit -m 'Deploy ${APP} ${TAG}' && git push"
