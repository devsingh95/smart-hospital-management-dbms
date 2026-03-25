# Smart Hospital Management System

## 1. Title Page

Project Title: Smart Hospital Management System  
Course: Database Management Systems (DBMS)  
Program: B.Tech Computer Science Engineering  
Student Name: ____________________  
Roll Number: ____________________  
College Name: ____________________  
Academic Session: 2025-26

## 2. Abstract

This project presents a Smart Hospital Management System developed using Flask, MySQL, HTML, CSS, and JavaScript. The system helps in handling important hospital operations such as patient registration, doctor management, appointment booking, medical record maintenance, and billing. The design follows DBMS principles with proper normalization up to 3NF, primary and foreign keys, and constraints. Advanced SQL features such as views, triggers, and stored procedures are used to make the system realistic and automation-friendly.

## 3. Introduction

Hospitals handle a large amount of patient and doctor information daily. Traditional manual methods are slow and error-prone. A digital management system improves speed, accuracy, and transparency. This project builds a compact but practical hospital system for educational and engineering-level DBMS learning.

## 4. Problem Statement

Manual hospital workflows make data management difficult. There is no central place to track patients, doctors, appointments, records, and billing. The problem is to build a database-driven application that stores data in a structured way and supports daily operations effectively.

## 5. Objectives

- To design a normalized hospital database up to 3NF
- To implement tables with proper constraints and keys
- To create a backend using Flask and connect with MySQL
- To build simple web pages for user interaction
- To use advanced SQL objects: view, trigger, and procedure
- To demonstrate realistic queries and reporting

## 6. System Design

### Architecture

- Frontend: HTML, CSS, JavaScript
- Backend: Python Flask
- Database: MySQL

### Workflow

1. User registers patient and doctor details.
2. User books an appointment.
3. Doctor records diagnosis and prescription.
4. Bill is generated from appointment details.
5. Dashboard shows complete operational data.

## 7. ER Diagram Explanation

The ER model has five main entities: Patients, Doctors, Appointments, Medical_Records, and Billing.

- Patient to Appointment: One-to-Many
- Doctor to Appointment: One-to-Many
- Appointment to Billing: One-to-One
- Patient to Medical_Records: One-to-Many
- Doctor to Medical_Records: One-to-Many

This structure avoids duplication and gives clean data flow.

## 8. Database Schema

Schema details are documented in docs/database_design.md. The implementation uses:

- Primary keys for each table
- Foreign keys for relationship mapping
- Unique constraints on phone and email
- CHECK and ENUM constraints for data quality

## 9. SQL Queries

All required SQL is implemented in database/smart_hospital.sql:

- CREATE TABLE statements
- INSERT sample data
- SELECT simple and JOIN queries
- GROUP BY queries
- UPDATE and DELETE queries
- VIEW: vw_appointment_details
- TRIGGER: trg_auto_bill_after_completed_appointment
- STORED PROCEDURE: sp_generate_bill

## 10. Results

The system successfully performs:

- Patient registration
- Doctor registration
- Appointment booking
- Medical record viewing
- Bill generation
- Dashboard visualization for all modules

API endpoints also return JSON responses for integration and testing.

## 11. Conclusion

The Smart Hospital Management System demonstrates practical use of DBMS concepts with application development. It combines normalized relational design, SQL programming, and a web-based interface. The project is suitable for academic evaluation and can be extended to real-world deployment.

## 12. Future Scope

- Authentication and role-based login (Admin/Doctor/Receptionist)
- Online payment integration
- Email/SMS appointment reminders
- Detailed analytics dashboard
- File upload for reports and prescriptions
- Integration with pharmacy and laboratory modules
