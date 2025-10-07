#!/bin/bash

# Setup backend
echo "Setting up backend..."
cd backend

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser (optional)
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell

# Start backend
python manage.py runserver &

cd ../frontend

# Setup frontend
echo "Setting up frontend..."
flutter pub get

# Start frontend
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0

echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:3000"
echo "Admin: http://localhost:8000/admin (admin/admin123)"