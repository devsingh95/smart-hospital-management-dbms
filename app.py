import os
from decimal import Decimal
from datetime import datetime, timezone

from flask import Flask, jsonify, redirect, render_template, request, url_for
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv


app = Flask(__name__)
load_dotenv()


DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", "root"),
    "database": os.getenv("DB_NAME", "smart_hospital_db"),
}


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def execute_query(query, params=None, fetch=False, many=False):
    connection = None
    cursor = None
    try:
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)

        if many:
            cursor.executemany(query, params)
        else:
            cursor.execute(query, params)

        if fetch:
            return cursor.fetchall()

        connection.commit()
        return {"success": True, "lastrowid": cursor.lastrowid}
    except Error as exc:
        if connection:
            connection.rollback()
        return {"success": False, "error": str(exc)}
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


def as_currency(value):
    if value is None:
        return "0.00"
    if isinstance(value, Decimal):
        return f"{value:.2f}"
    return f"{float(value):.2f}"


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/patients/new", methods=["GET", "POST"])
def add_patient_page():
    if request.method == "POST":
        payload = {
            "first_name": request.form.get("first_name"),
            "last_name": request.form.get("last_name"),
            "dob": request.form.get("dob"),
            "gender": request.form.get("gender"),
            "phone": request.form.get("phone"),
            "email": request.form.get("email"),
            "address": request.form.get("address"),
            "blood_group": request.form.get("blood_group"),
        }
        result = create_patient(payload)
        if result.get("success"):
            return redirect(url_for("dashboard"))
        return render_template("patient_form.html", error=result.get("error"), data=payload)
    return render_template("patient_form.html")


@app.route("/doctors/new", methods=["GET", "POST"])
def add_doctor_page():
    if request.method == "POST":
        payload = {
            "first_name": request.form.get("first_name"),
            "last_name": request.form.get("last_name"),
            "specialization": request.form.get("specialization"),
            "phone": request.form.get("phone"),
            "email": request.form.get("email"),
            "consultation_fee": request.form.get("consultation_fee"),
        }
        result = create_doctor(payload)
        if result.get("success"):
            return redirect(url_for("dashboard"))
        return render_template("doctor_form.html", error=result.get("error"), data=payload)
    return render_template("doctor_form.html")


@app.route("/appointments/new", methods=["GET", "POST"])
def book_appointment_page():
    doctors = execute_query("SELECT doctor_id, first_name, last_name, specialization FROM doctors", fetch=True)
    patients = execute_query("SELECT patient_id, first_name, last_name FROM patients", fetch=True)

    if request.method == "POST":
        payload = {
            "patient_id": request.form.get("patient_id"),
            "doctor_id": request.form.get("doctor_id"),
            "appointment_date": request.form.get("appointment_date"),
            "appointment_time": request.form.get("appointment_time"),
            "status": request.form.get("status", "Booked"),
            "reason": request.form.get("reason"),
        }
        result = create_appointment(payload)
        if result.get("success"):
            return redirect(url_for("dashboard"))
        return render_template(
            "appointment_form.html",
            error=result.get("error"),
            data=payload,
            doctors=doctors if isinstance(doctors, list) else [],
            patients=patients if isinstance(patients, list) else [],
        )

    return render_template(
        "appointment_form.html",
        doctors=doctors if isinstance(doctors, list) else [],
        patients=patients if isinstance(patients, list) else [],
    )


@app.route("/dashboard")
def dashboard():
    patients = execute_query("SELECT * FROM patients ORDER BY patient_id DESC", fetch=True)
    doctors = execute_query("SELECT * FROM doctors ORDER BY doctor_id DESC", fetch=True)
    appointments = execute_query(
        """
        SELECT a.appointment_id, a.appointment_date, a.appointment_time, a.status,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
               CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
               d.specialization
        FROM appointments a
        JOIN patients p ON a.patient_id = p.patient_id
        JOIN doctors d ON a.doctor_id = d.doctor_id
        ORDER BY a.appointment_date DESC, a.appointment_time DESC
        """,
        fetch=True,
    )
    bills = execute_query(
        """
        SELECT b.bill_id, b.appointment_id, b.bill_date, b.total_amount, b.payment_status
        FROM billing b
        ORDER BY b.bill_id DESC
        """,
        fetch=True,
    )

    if isinstance(bills, list):
        for bill in bills:
            bill["total_amount"] = as_currency(bill.get("total_amount"))

    return render_template(
        "dashboard.html",
        patients=patients if isinstance(patients, list) else [],
        doctors=doctors if isinstance(doctors, list) else [],
        appointments=appointments if isinstance(appointments, list) else [],
        bills=bills if isinstance(bills, list) else [],
    )


@app.route("/records")
def records_page():
    records = execute_query(
        """
        SELECT mr.record_id, mr.diagnosis, mr.prescription, mr.record_date,
               CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
               CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
        FROM medical_records mr
        JOIN patients p ON mr.patient_id = p.patient_id
        JOIN doctors d ON mr.doctor_id = d.doctor_id
        ORDER BY mr.record_date DESC
        """,
        fetch=True,
    )
    return render_template("records.html", records=records if isinstance(records, list) else [])


@app.route("/billing/generate/<int:appointment_id>", methods=["POST"])
def generate_bill_page(appointment_id):
    result = execute_query("CALL sp_generate_bill(%s)", (appointment_id,))
    if not result.get("success"):
        return jsonify(result), 400
    return redirect(url_for("dashboard"))


@app.route("/api/health")
def api_health():
    try:
        connection = get_db_connection()
        connection.close()
        return jsonify({"status": "ok", "message": "Database connected"})
    except Error as exc:
        return jsonify({"status": "error", "message": str(exc)}), 500


@app.route("/api/patients", methods=["POST"])
def api_add_patient():
    payload = request.get_json(force=True)
    result = create_patient(payload)
    return (jsonify(result), 201) if result.get("success") else (jsonify(result), 400)


@app.route("/api/doctors", methods=["POST"])
def api_add_doctor():
    payload = request.get_json(force=True)
    result = create_doctor(payload)
    return (jsonify(result), 201) if result.get("success") else (jsonify(result), 400)


@app.route("/api/appointments", methods=["POST"])
def api_book_appointment():
    payload = request.get_json(force=True)
    result = create_appointment(payload)
    return (jsonify(result), 201) if result.get("success") else (jsonify(result), 400)


@app.route("/api/records", methods=["GET"])
def api_view_records():
    records = execute_query(
        """
        SELECT mr.record_id, mr.patient_id, mr.doctor_id, mr.diagnosis,
               mr.prescription, mr.notes, mr.record_date
        FROM medical_records mr
        ORDER BY mr.record_date DESC
        """,
        fetch=True,
    )
    if isinstance(records, list):
        return jsonify(records)
    return jsonify(records), 500


@app.route("/api/bills/generate", methods=["POST"])
def api_generate_bill():
    payload = request.get_json(force=True)
    appointment_id = payload.get("appointment_id")
    result = execute_query("CALL sp_generate_bill(%s)", (appointment_id,))
    return (jsonify(result), 201) if result.get("success") else (jsonify(result), 400)


def create_patient(payload):
    query = """
        INSERT INTO patients
            (first_name, last_name, dob, gender, phone, email, address, blood_group)
        VALUES
            (%s, %s, %s, %s, %s, %s, %s, %s)
    """
    params = (
        payload.get("first_name"),
        payload.get("last_name"),
        payload.get("dob"),
        payload.get("gender"),
        payload.get("phone"),
        payload.get("email"),
        payload.get("address"),
        payload.get("blood_group"),
    )
    return execute_query(query, params)


def create_doctor(payload):
    query = """
        INSERT INTO doctors
            (first_name, last_name, specialization, phone, email, consultation_fee)
        VALUES
            (%s, %s, %s, %s, %s, %s)
    """
    params = (
        payload.get("first_name"),
        payload.get("last_name"),
        payload.get("specialization"),
        payload.get("phone"),
        payload.get("email"),
        payload.get("consultation_fee"),
    )
    return execute_query(query, params)


def create_appointment(payload):
    query = """
        INSERT INTO appointments
            (patient_id, doctor_id, appointment_date, appointment_time, status, reason)
        VALUES
            (%s, %s, %s, %s, %s, %s)
    """
    params = (
        payload.get("patient_id"),
        payload.get("doctor_id"),
        payload.get("appointment_date"),
        payload.get("appointment_time"),
        payload.get("status", "Booked"),
        payload.get("reason"),
    )
    return execute_query(query, params)


@app.context_processor
def inject_now():
    return {"now": datetime.now(timezone.utc)}


if __name__ == "__main__":
    app.run(debug=True)
