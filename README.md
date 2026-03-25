# Smart Hospital Management System (DBMS Project)

A complete engineering-level DBMS project with frontend, backend, and MySQL database.

## Tech Stack
- Frontend: HTML, CSS, JavaScript
- Backend: Python Flask
- Database: MySQL

## Project Structure

- app.py
- requirements.txt
- .env.example
- database/smart_hospital.sql
- templates/*.html
- static/css/style.css
- static/js/main.js
- docs/database_design.md
- docs/project_report.md
- docs/viva_questions.md

## Real-World Use
Hospitals need a central system to avoid data duplication and manual records. This project simulates core real workflow:
1. Reception registers patient and doctor.
2. Appointment is booked with date/time slot validation.
3. Doctor updates treatment record.
4. Billing is generated automatically.
5. Dashboard gives consolidated operational view.

## Setup Steps (Windows)

1. Install MySQL Server 8+ and create user credentials.
2. Open this project in VS Code terminal.
3. Create virtual environment and install packages:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

4. Configure environment variables:

```powershell
copy .env.example .env
```

Edit .env values according to your MySQL setup.

5. Run SQL script in MySQL Workbench or CLI:

```sql
SOURCE path_to_project/database/smart_hospital.sql;
```

6. Run Flask app:

```powershell
python app.py
```

7. Open browser:

- http://127.0.0.1:5000/

## Main Pages
- Home
- Add Patient
- Add Doctor
- Book Appointment
- Dashboard
- Medical Records

## API Endpoints
- POST /api/patients
- POST /api/doctors
- POST /api/appointments
- GET /api/records
- POST /api/bills/generate
- GET /api/health

## Screenshot Guide for Submission
Take these screenshots in this order:

1. MySQL tables list (patients, doctors, appointments, medical_records, billing)
2. Table design showing PK/FK constraints
3. Sample records in each table
4. JOIN query output (appointment + patient + doctor)
5. GROUP BY query output
6. VIEW output: SELECT * FROM vw_appointment_details
7. Trigger/procedure execution result (bill generated)
8. Home page UI
9. Patient form page
10. Doctor form page
11. Appointment booking page
12. Dashboard page showing all data
13. Records page

## Notes
- Use docs/project_report.md directly in your final report document.
- Use docs/viva_questions.md for viva preparation.

## GitHub and Vercel Hosting

### 1. Push project to GitHub

Run these commands from this folder:

```powershell
git init
git add .
git commit -m "Initial Smart Hospital DBMS project"
gh repo create smart-hospital-management-dbms --public --source . --remote origin --push
```

### 2. Deploy to Vercel

This project includes:
- api/index.py (Flask serverless entry)
- vercel.json (routing and Python build config)

Deploy command:

```powershell
vercel --prod --yes
```

### 3. Add environment variables on Vercel dashboard

Project Settings -> Environment Variables:
- DB_HOST
- DB_PORT
- DB_USER
- DB_PASSWORD
- DB_NAME

Important: if your MySQL is local localhost, Vercel cannot access it. Use a cloud MySQL service (PlanetScale, Railway MySQL, Aiven, etc.) for live deployment.

### 4. Redeploy after env changes

```powershell
vercel --prod --yes
```
