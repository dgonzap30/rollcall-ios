# RollCall API v1 Specification

**Status**: DRAFT (To be completed in Phase 1)  
**Version**: 1.0.0-alpha  
**Base URL**: TBD (`https://api.rollcall.app/v1`)

## Overview

RollCall API follows RESTful principles with JSON payloads. All endpoints require authentication except public feed endpoints (when implemented).

## Authentication

TBD - Will use JWT tokens with refresh mechanism

## Endpoints

### Rolls

#### Create Roll
```
POST /rolls
```

#### Get Roll
```
GET /rolls/{rollId}
```

#### Update Roll
```
PUT /rolls/{rollId}
```

#### Delete Roll
```
DELETE /rolls/{rollId}
```

#### List Rolls
```
GET /rolls
```

### Chefs (Users)

#### Get Chef Profile
```
GET /chefs/{chefId}
```

#### Update Chef Profile
```
PUT /chefs/{chefId}
```

### Restaurants

#### Search Restaurants
```
GET /restaurants/search
```

#### Get Restaurant
```
GET /restaurants/{restaurantId}
```

## Data Models

### Roll
```json
{
  "id": "uuid",
  "chefId": "uuid",
  "restaurantId": "uuid",
  "type": "nigiri|maki|sashimi|special",
  "name": "string",
  "description": "string",
  "rating": 1-5,
  "photoUrl": "string",
  "tags": ["string"],
  "createdAt": "iso8601",
  "updatedAt": "iso8601"
}
```

### Chef
```json
{
  "id": "uuid",
  "username": "string",
  "displayName": "string",
  "bio": "string",
  "profilePhotoUrl": "string",
  "rollCount": 0,
  "joinedAt": "iso8601"
}
```

### Restaurant
```json
{
  "id": "uuid",
  "name": "string",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "postalCode": "string",
    "country": "string"
  },
  "coordinates": {
    "latitude": 0.0,
    "longitude": 0.0
  },
  "website": "string",
  "photoUrls": ["string"]
}
```

## Error Responses

Standard error format:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

## Rate Limiting

- 1000 requests per hour per authenticated user
- 100 requests per hour for unauthenticated endpoints

## Pagination

List endpoints support cursor-based pagination:
```
GET /rolls?cursor={cursor}&limit=20
```

Response includes:
```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "string",
    "hasMore": true
  }
}
```

## Sync Protocol

TBD - Will use Last-Write-Wins (LWW) with vector clocks for conflict resolution

---

*Note: This specification will be finalized during Phase 1 of development after design system implementation.*