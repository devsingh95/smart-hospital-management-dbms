# Smart Hospital Management System - Database Design

## 1. ER Diagram (Text Format)

### Entities and Attributes

1. Patients
- patient_id (PK)
- first_name
- last_name
- dob
- gender
- phone (UNIQUE)
- email (UNIQUE)
- address
- blood_group

2. Doctors
- doctor_id (PK)
- first_name
- last_name
- specialization
- phone (UNIQUE)
- email (UNIQUE)
- consultation_fee

3. Appointments
- appointment_id (PK)
- patient_id (FK)
- doctor_id (FK)
- appointment_date
- appointment_time
- status
- reason

4. Medical_Records
- record_id (PK)
- patient_id (FK)
- doctor_id (FK)
- appointment_id (FK, optional)
- diagnosis
- prescription
- notes
- record_date

5. Billing
- bill_id (PK)
- appointment_id (FK, UNIQUE)
- patient_id (FK)
- doctor_id (FK)
- bill_date
- consultation_fee
- medicine_charges
- lab_charges
- other_charges
- total_amount
- payment_status

### Relationships
- One Patient can have many Appointments (1:N)
- One Doctor can have many Appointments (1:N)
- One Appointment can create one Bill (1:1)
- One Patient can have many Medical Records (1:N)
- One Doctor can write many Medical Records (1:N)
- One Appointment may have one related Medical Record (0/1:1)

## 2. Relational Schema

Patients(
patient_id PK,
first_name,
last_name,
dob,
gender,
phone UNIQUE,
email UNIQUE,
address,
blood_group,
created_at
)

Doctors(
doctor_id PK,
first_name,
last_name,
specialization,
phone UNIQUE,
email UNIQUE,
consultation_fee,
created_at
)

Appointments(
appointment_id PK,
patient_id FK -> Patients.patient_id,
doctor_id FK -> Doctors.doctor_id,
appointment_date,
appointment_time,
status,
reason,
created_at,
UNIQUE(doctor_id, appointment_date, appointment_time)
)

Medical_Records(
record_id PK,
patient_id FK -> Patients.patient_id,
doctor_id FK -> Doctors.doctor_id,
appointment_id FK -> Appointments.appointment_id,
diagnosis,
prescription,
notes,
record_date,
created_at
)

Billing(
bill_id PK,
appointment_id FK UNIQUE -> Appointments.appointment_id,
patient_id FK -> Patients.patient_id,
doctor_id FK -> Doctors.doctor_id,
bill_date,
consultation_fee,
medicine_charges,
lab_charges,
other_charges,
total_amount,
payment_status,
created_at
)

## 3. Normalization up to 3NF

### UNF to 1NF
- In UNF, repeating groups and multi-valued data can exist.
- In this design, all attributes are atomic: one cell has one value.
- Example: patient phone is a single value, appointment status is single value.
- So all tables satisfy 1NF.

### 1NF to 2NF
- 2NF requires no partial dependency on a composite key.
- Every table uses a single-column primary key (patient_id, doctor_id, etc.), so partial dependency is not possible.
- Non-key attributes depend on the full key.
- So all tables satisfy 2NF.

### 2NF to 3NF
- 3NF requires no transitive dependency (non-key depending on another non-key).
- Doctor specialization and fee are stored in Doctors table, not in Appointments.
- Patient details are stored in Patients table, not duplicated in Billing or Appointments.
- Billing links through IDs and computes total_amount from direct bill components.
- Therefore, the schema avoids transitive dependencies and satisfies 3NF.

## 4. Constraints Used
- Primary Keys on all tables
- Foreign Keys with referential actions
- NOT NULL on required fields
- UNIQUE on phone, email, and appointment slot
- CHECK constraints for non-negative money values
- ENUM for status consistency
