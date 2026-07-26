Absolutely. Below is a summary you can paste into a new chat so we can continue seamlessly.

---

# Project Summary

## Project

**Junko-san Project**

A local-first reservation management platform for a **single-employee massage business**.

Primary goals:

* Local-first operation
* Fool-proof for non-technical users
* React frontend
* Go backend
* SQLite database
* Firebase Hosting later (frontend only)
* GitHub for source control
* Daily SQLite backups
* Expandable for future online customer reservations

---

# Current Tech Stack

Frontend

* React
* Vite
* TypeScript

Backend

* Go
* net/http
* SQLite (modernc.org/sqlite)

Database

* SQLite (`junko.db`)
* Automatically created on startup

Deployment

* GitHub
* GitHub Codespaces
* Dev Container
* Firebase Hosting (future)

---

# Current Repository

```
backend/

    api/

    database/

    models/

    config/

    main.go

    junko.db

frontend/

    src/

scripts/

.devcontainer/
```

---

# Current Backend Architecture

```
main.go

↓

database.Connect()

↓

createTables()

↓

seedServices()

↓

HTTP handlers

↓

SQLite
```

Routes currently implemented:

```
GET /api/status

GET /api/services

GET /api/business

GET /api/reservations

POST /api/reservations

PATCH /api/reservations
```

---

# Current Database

Tables

## reservations

```
id

customer_name

phone

service

reservation_date

status

created_at
```

---

## services

```
id

name

duration_minutes

price

active

display_order
```

---

No business table yet.

Business information currently comes from

```
config/business.json
```

---

# Current Models

Business

```go
Name
Tagline
Description

Phone
Email
Address

Instagram
Facebook
Website

Logo
HeroImage

PrimaryColor
SecondaryColor
```

Reservation

```go
ID

CustomerName

Phone

Service

ReservationDate

Status

CreatedAt
```

Service

```go
ID

Name

DurationMinutes

Price

Active

DisplayOrder
```

---

# Current Frontend Structure

```
src/

api/

components/

pages/

router/

types/
```

Pages

```
Home

Reservation

Admin

NotFound
```

Current routing already works.

---

# Current Progress

Completed

✅ Backend auto-creates SQLite database

✅ Tables auto-created

✅ Default services seeded

✅ Reservation creation works

✅ Reservation persistence works

✅ Frontend communicates with backend

✅ Codespaces validation successful

---

# Architecture Decisions

Keep:

React

↓

Go REST API

↓

SQLite

Do NOT access SQLite directly from React.

---

Keep API simple.

Current style:

```
GET

POST

PATCH
```

No authentication yet.

Single employee.

---

# Planned Version 1

Business

↓

Dashboard

Reservations

Customers

Services

Business Profile

Settings

---

# Immediate Roadmap

## Commit 1

Business Profile migration

Move

```
config/business.json
```

to SQLite.

Tasks

* create business table
* seedBusiness()
* GET /api/business
* PUT /api/business

---

## Commit 2

Service CRUD

Current

```
GET /services
```

New

```
POST

PUT

DELETE (soft delete)
```

Extend Service model with

```
Description
```

Later

```
ServiceMedia

ServiceAddon
```

---

## Commit 3

Frontend

Business Settings page

Service Management page

Editable forms

---

## Commit 4

Backend logging

Add logger package

Request logging

Error logging

Database logging

---

# Future Roadmap

Dashboard

Customer management

Calendar

Media upload

Daily backups

Firebase Hosting

Online reservations

Authentication (if needed)

Reports

---

# Coding Principles

* Extend existing code instead of rewriting.
* Keep backend stable while improving the frontend.
* Store business data in SQLite, not JSON.
* Never store image binaries in SQLite; only store file paths.
* Use soft deletes (`active = false`) for services.
* Build features incrementally with small, testable commits.
* Preserve backward compatibility whenever practical.
* Keep the codebase understandable for future maintenance.

---

# Preferred Development Style (System Prompt)

```text
You are my senior software architect and pair programmer.

Project:
Junko-san Project

Stack:

- React
- TypeScript
- Vite
- Go
- SQLite
- Firebase Hosting (future)

The project is intended for a single-employee massage business.

Goals:

- local-first
- fool-proof
- simple deployment
- maintainable architecture
- future-proof without overengineering

Development philosophy:

- Never rewrite working code unless there is a strong architectural reason.
- Prefer incremental refactoring over large redesigns.
- Keep commits small and independently testable.
- Always preserve compatibility with the current implementation.
- Suggest architecture improvements only when they clearly reduce future maintenance.
- Explain why a change is beneficial before proposing it.
- Prioritize readability and simplicity over cleverness.

Backend rules:

- Go standard library where practical.
- SQLite is the source of truth.
- Database initializes automatically.
- Prefer REST endpoints.
- Avoid unnecessary dependencies.
- Add logging and error handling consistently.

Frontend rules:

- Build reusable components.
- Separate pages, API calls, and UI components.
- Use TypeScript types consistently.
- Design for desktop first, while remaining responsive.
- Optimize workflows for a single employee.

Workflow:

1. Understand the current implementation before changing it.
2. Propose a short implementation plan.
3. Modify only the files necessary for the current feature.
4. Describe how to test the change.
5. Wait for confirmation before moving to the next feature.

Current priority:

1. Migrate Business Profile from JSON to SQLite.
2. Build Business Settings CRUD.
3. Build Services CRUD.
4. Improve frontend administration UI.
5. Add structured backend logging.
```

I think this gives us a solid foundation for future sessions. It captures not only the current codebase, but also the design philosophy we've established, so we can continue building consistently without having to revisit earlier architectural decisions.
