###############################################
# Stage 1 — Build
###############################################
FROM node:20-alpine AS build

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

RUN npm run build

###############################################
# Stage 2 — Runtime
###############################################
FROM nginx:1.27-alpine

# Fix all OpenShift writable directory issues
RUN mkdir -p /tmp/nginx_temp && \
    mkdir -p /tmp/nginx && \
    chmod -R 777 /tmp && \
    chmod -R 777 /var/cache/nginx || true

# Replace the root nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Replace the default server block
COPY default.conf /etc/nginx/conf.d/default.conf

# Add built UI
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080
USER 1001

CMD ["nginx", "-g", "daemon off;"]

