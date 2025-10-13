@echo off
echo Testing Quality Checks endpoints...

echo.
echo 1. Testing Health endpoint:
curl -X GET http://localhost:8000/api/health

echo.
echo.
echo 2. Testing Quality Checks endpoint:
curl -X GET http://localhost:8000/api/quality-checks

echo.
echo.
echo 3. Testing simple query directly in database:
docker exec -i 29e1d7c9c2e2_db psql -U wms_user -d wms_db -c "SELECT COUNT(*) FROM quality_checks;"

pause