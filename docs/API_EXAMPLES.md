# API Examples

All requests and responses use JSON with UTF-8 encoding so English and Amharic text can be stored and returned safely.

## List services

```bash
curl http://localhost:8080/services
```

## Service details

```bash
curl http://localhost:8080/services/1
```

## Book appointment

```bash
curl -X POST http://localhost:8080/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "resident_name": "Abebe Bekele",
    "phone_number": "0911223344",
    "service_id": 1,
    "appointment_date": "2026-06-01",
    "appointment_time": "09:00"
  }'
```

## Available slots

```bash
curl "http://localhost:8080/appointments/slots?service_id=1&date=2026-06-01"
```

## Track appointment

```bash
curl http://localhost:8080/appointments/KBL-1-1780000000000
```

## Edit appointment

```bash
curl -X PUT http://localhost:8080/appointments/KBL-1-1780000000000 \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_date": "2026-06-03",
    "appointment_time": "10:00"
  }'
```

## Cancel appointment

```bash
curl -X DELETE http://localhost:8080/appointments/KBL-1-1780000000000
```

## Staff/Admin login

```bash
curl -X POST http://localhost:8080/staff/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@kebele.gov.et",
    "password": "admin123"
  }'
```

## Staff appointment filters

```bash
curl "http://localhost:8080/staff/appointments?date=2026-06-01&status=Pending&service_id=1" \
  -H "Authorization: Bearer $TOKEN"
```

## Staff update appointment status

```bash
curl -X PUT http://localhost:8080/staff/appointments/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_number": "KBL-1-1780000000000",
    "status": "Confirmed"
  }'
```

## Admin create service

```bash
curl -X POST http://localhost:8080/admin/services \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Residency confirmation",
    "description": "Confirm resident address",
    "required_documents": ["Kebele ID", "House number confirmation"],
    "daily_limit": 30
  }'
```

## Admin update service

```bash
curl -X PUT http://localhost:8080/admin/services/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ID issuance",
    "description": "New Kebele resident ID issuance",
    "required_documents": ["Recent photo", "House number confirmation"],
    "daily_limit": 45
  }'
```

## Admin delete service

```bash
curl -X DELETE http://localhost:8080/admin/services/1 \
  -H "Authorization: Bearer $TOKEN"
```

## Admin list staff

```bash
curl http://localhost:8080/admin/staff \
  -H "Authorization: Bearer $TOKEN"
```

## Admin assign staff to service

```bash
curl -X PUT http://localhost:8080/admin/staff \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "staff_id": 2,
    "assigned_service_id": 1
  }'
```

## Admin update appointment limit

```bash
curl -X PUT http://localhost:8080/admin/limits \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "max_appointments_per_day": 45
  }'
```

## Submit feedback

```bash
curl -X POST http://localhost:8080/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "appointment_number": "KBL-1-1780000000000",
    "rating": 5,
    "message": "The appointment process was clear."
  }'
```
