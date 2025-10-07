#!/bin/bash

echo "🔧 WMS Development Helper"
echo ""

case "$1" in
  "start")
    echo "🚀 Starting all services..."
    docker-compose up --build
    ;;
  "stop")
    echo "🛑 Stopping all services..."
    docker-compose down
    ;;
  "restart")
    echo "🔄 Restarting all services..."
    docker-compose down
    docker-compose up --build
    ;;
  "logs")
    echo "📋 Showing logs..."
    docker-compose logs -f
    ;;
  "clean")
    echo "🧹 Cleaning up..."
    docker-compose down -v
    docker system prune -f
    ;;
  "flutter")
    echo "📱 Running Flutter commands..."
    cd frontend
    case "$2" in
      "get")
        flutter pub get
        ;;
      "clean")
        flutter clean
        flutter pub get
        ;;
      "analyze")
        flutter analyze
        ;;
      *)
        echo "Available Flutter commands:"
        echo "  ./dev.sh flutter get     - Get dependencies"
        echo "  ./dev.sh flutter clean   - Clean and get dependencies"
        echo "  ./dev.sh flutter analyze - Analyze code"
        ;;
    esac
    ;;
  "backend")
    echo "🐹 Running backend commands..."
    cd backend
    case "$2" in
      "run")
        go run cmd/server/main.go
        ;;
      "build")
        go build -o bin/server cmd/server/main.go
        ;;
      "test")
        go test ./...
        ;;
      *)
        echo "Available backend commands:"
        echo "  ./dev.sh backend run   - Run Go server"
        echo "  ./dev.sh backend build - Build Go binary"
        echo "  ./dev.sh backend test  - Run tests"
        ;;
    esac
    ;;
  *)
    echo "Available commands:"
    echo "  ./dev.sh start    - Start all services"
    echo "  ./dev.sh stop     - Stop all services"
    echo "  ./dev.sh restart  - Restart all services"
    echo "  ./dev.sh logs     - Show logs"
    echo "  ./dev.sh clean    - Clean up containers and volumes"
    echo "  ./dev.sh flutter  - Flutter commands"
    echo "  ./dev.sh backend  - Backend commands"
    ;;
esac