# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter config --enable-web \
  && flutter pub get \
  && flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL:-https://api.example.com} \
    --base-href=${APP_BASE_PATH:-/}

# Runtime stage
FROM nginx:1.25-alpine
ENV APP_BASE_PATH=${APP_BASE_PATH:-/}
WORKDIR /usr/share/nginx/html
COPY --from=build /app/build/web .
COPY docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
