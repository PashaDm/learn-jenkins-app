FROM mcr.microsoft.com/playwright:v1.54.0-jammy
RUN npm install -g netlify-cli node-jq
RUN npm install -g serve
RUN apt update && apt install jq -y