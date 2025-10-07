FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Enable web support
RUN flutter config --enable-web

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

EXPOSE 3000

CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0", "--disable-service-auth-codes"]