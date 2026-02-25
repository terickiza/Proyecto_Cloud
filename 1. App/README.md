# DevOps Microservice

A simple REST microservice with Flask that validates POST requests.

## Requirements

- Python 3.7+
- Flask

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Service

```bash
python app.py
```

The service will start on `http://localhost:5000`

## Testing

### ✅ Valid POST Request (Success)

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45
  }'
```

**Expected Response:**
```json
{
  "message": "Hello Juan Perez your message will be sent"
}
```

### ❌ Invalid Method (GET, PUT, DELETE, etc.)

```bash
curl -X GET http://localhost:5000/DevOps
```

**Expected Response:**
```json
{
  "error": "ERROR"
}
```

### ❌ Invalid Body (Missing fields)

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test"
  }'
```

**Expected Response:**
```json
{
  "error": "ERROR"
}
```

### ❌ Invalid Body (Extra fields)

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45,
    "extra": "field"
  }'
```

**Expected Response:**
```json
{
  "error": "ERROR"
}
```

### ❌ Invalid Body (Wrong data types)

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": "45"
  }'
```

**Expected Response:**
```json
{
  "error": "ERROR"
}
```

## How It Works

1. **Method Validation**: Only POST is allowed. All other methods return `{"error":"ERROR"}`
2. **Body Validation**: Checks for:
   - Exactly 4 fields: `message`, `to`, `from`, `timeToLifeSec`
   - Correct data types (strings for message/to/from, integer for timeToLifeSec)
3. **Success Response**: Extracts the `to` field and returns personalized message
