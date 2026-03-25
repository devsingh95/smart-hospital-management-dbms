-- Smart Hospital Management System SQL Script
-- MySQL 8+

CREATE DATABASE IF NOT EXISTS smart_hospital_db;
USE smart_hospital_db;

-- Drop objects in dependency-safe order when re-running script.
DROP TRIGGER IF EXISTS trg_auto_bill_after_completed_appointment;
DROP PROCEDURE IF EXISTS sp_generate_bill;
DROP VIEW IF EXISTS vw_appointment_details;

DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;

-- 1) TABLE CREATION
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    blood_group VARCHAR(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(80) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    consultation_fee DECIMAL(10, 2) NOT NULL CHECK (consultation_fee >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Booked', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Booked',
    reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_doctor_slot UNIQUE (doctor_id, appointment_date, appointment_time)
);

CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    diagnosis VARCHAR(255) NOT NULL,
    prescription VARCHAR(255),
    notes TEXT,
    record_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_records_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_records_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_records_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE billing (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    bill_date DATE NOT NULL,
    consultation_fee DECIMAL(10, 2) NOT NULL CHECK (consultation_fee >= 0),
    medicine_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (medicine_charges >= 0),
    lab_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (lab_charges >= 0),
    other_charges DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (other_charges >= 0),
    total_amount DECIMAL(10, 2) GENERATED ALWAYS AS
        (consultation_fee + medicine_charges + lab_charges + other_charges) STORED,
    payment_status ENUM('Pending', 'Paid', 'Cancelled') NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_billing_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_billing_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_billing_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 2) SAMPLE DATA INSERTION
INSERT INTO patients (first_name, last_name, dob, gender, phone, email, address, blood_group)
VALUES
('Aarav', 'Sharma', '2001-02-10', 'Male', '9876543210', 'aarav@gmail.com', 'Sector 21, Chandigarh', 'B+'),
('Ananya', 'Verma', '2002-07-22', 'Female', '9876543211', 'ananya@gmail.com', 'Mohali, Punjab', 'O+'),
('Rohan', 'Gupta', '1999-12-05', 'Male', '9876543212', 'rohan@gmail.com', 'Panchkula, Haryana', 'A-');

INSERT INTO doctors (first_name, last_name, specialization, phone, email, consultation_fee)
VALUES
('Meera', 'Kapoor', 'Cardiology', '9123456780', 'meera.kapoor@hospital.com', 1200.00),
('Raj', 'Malhotra', 'Orthopedics', '9123456781', 'raj.malhotra@hospital.com', 900.00),
('Nidhi', 'Bansal', 'General Physician', '9123456782', 'nidhi.bansal@hospital.com', 700.00);

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, status, reason)
VALUES
(1, 1, '2026-03-20', '10:00:00', 'Completed', 'Chest discomfort'),
(2, 3, '2026-03-21', '11:30:00', 'Booked', 'Fever and headache'),
(3, 2, '2026-03-22', '09:15:00', 'Completed', 'Knee pain');

INSERT INTO medical_records (patient_id, doctor_id, appointment_id, diagnosis, prescription, notes, record_date)
VALUES
(1, 1, 1, 'Mild Hypertension', 'Tab Amlodipine 5mg', 'Low salt diet advised', '2026-03-20'),
(3, 2, 3, 'Ligament strain', 'Pain relief gel + physiotherapy', 'Rest for 2 weeks', '2026-03-22');

-- 3) VIEW
CREATE VIEW vw_appointment_details AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    d.consultation_fee
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

-- 4) STORED PROCEDURE
DELIMITER $$
CREATE PROCEDURE sp_generate_bill(IN p_appointment_id INT)
BEGIN
    DECLARE v_patient_id INT;
    DECLARE v_doctor_id INT;
    DECLARE v_fee DECIMAL(10,2);

    SELECT a.patient_id, a.doctor_id, d.consultation_fee
    INTO v_patient_id, v_doctor_id, v_fee
    FROM appointments a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    WHERE a.appointment_id = p_appointment_id;

    IF v_patient_id IS NULL OR v_doctor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid appointment id.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM billing WHERE appointment_id = p_appointment_id) THEN
        INSERT INTO billing (
            appointment_id,
            patient_id,
            doctor_id,
            bill_date,
            consultation_fee,
            medicine_charges,
            lab_charges,
            other_charges,
            payment_status
        ) VALUES (
            p_appointment_id,
            v_patient_id,
            v_doctor_id,
            CURDATE(),
            v_fee,
            150.00,
            200.00,
            0.00,
            'Pending'
        );
    END IF;
END $$
DELIMITER ;

-- 5) TRIGGER: Auto-generate bill after status becomes Completed
DELIMITER $$
CREATE TRIGGER trg_auto_bill_after_completed_appointment
AFTER UPDATE ON appointments
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status <> 'Completed' THEN
        CALL sp_generate_bill(NEW.appointment_id);
    END IF;
END $$
DELIMITER ;

-- 6) SELECT QUERIES (Simple + Complex JOIN)
-- Simple SELECT
SELECT patient_id, first_name, last_name, blood_group FROM patients;

-- Complex JOIN query
SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date;

-- 7) GROUP BY QUERIES
SELECT d.specialization, COUNT(*) AS total_appointments
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization;

SELECT payment_status, SUM(total_amount) AS total_amount_collected
FROM billing
GROUP BY payment_status;

-- 8) UPDATE QUERY
UPDATE appointments
SET status = 'Completed'
WHERE appointment_id = 2;

-- 9) DELETE QUERY
DELETE FROM medical_records
WHERE record_id = 9999;

-- 10) Procedure usage example
CALL sp_generate_bill(1);

-- 11) View usage example
SELECT * FROM vw_appointment_details;
