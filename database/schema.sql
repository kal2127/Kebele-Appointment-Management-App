CREATE DATABASE IF NOT EXISTS kebele_appointments
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kebele_appointments;

CREATE TABLE departments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department_id INT NULL,
  name VARCHAR(150) NOT NULL UNIQUE,
  description TEXT,
  required_documents JSON NOT NULL,
  daily_limit INT NOT NULL DEFAULT 30,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_services_department
    FOREIGN KEY (department_id) REFERENCES departments(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin', 'staff') NOT NULL,
  department_id INT NULL,
  assigned_service_id INT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_department
    FOREIGN KEY (department_id) REFERENCES departments(id)
    ON DELETE SET NULL,
  CONSTRAINT fk_users_assigned_service
    FOREIGN KEY (assigned_service_id) REFERENCES services(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointment_limits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  service_id INT NOT NULL UNIQUE,
  max_appointments_per_day INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_limits_service
    FOREIGN KEY (service_id) REFERENCES services(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_number VARCHAR(50) NOT NULL UNIQUE,
  resident_name VARCHAR(150) NOT NULL,
  phone_number VARCHAR(30) NOT NULL,
  service_id INT NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time VARCHAR(10) NOT NULL,
  status ENUM(
    'Pending',
    'Confirmed',
    'Completed',
    'Rescheduled',
    'Cancelled',
    'Not Served'
  ) NOT NULL DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_service
    FOREIGN KEY (service_id) REFERENCES services(id)
    ON DELETE RESTRICT,
  INDEX idx_appointments_number (appointment_number),
  INDEX idx_appointments_service_date (service_id, appointment_date),
  INDEX idx_appointments_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE feedback (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_number VARCHAR(50) NULL,
  rating TINYINT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_feedback_rating CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
  CONSTRAINT fk_feedback_appointment
    FOREIGN KEY (appointment_number) REFERENCES appointments(appointment_number)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO departments (name, description) VALUES
  ('Civil Registration', 'Resident identity and vital event services')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO services (department_id, name, description, required_documents, daily_limit)
VALUES
  (1, 'ID issuance', 'New Kebele resident ID issuance', JSON_ARRAY('Recent passport-size photo', 'House number confirmation'), 40),
  (1, 'ID renewal', 'Renew an existing Kebele resident ID', JSON_ARRAY('Old Kebele ID', 'Recent passport-size photo'), 35),
  (1, 'Birth certificate', 'Birth certificate appointment', JSON_ARRAY('Birth notification document', 'Parent or guardian ID'), 25),
  (1, 'Marriage certificate', 'Marriage certificate appointment', JSON_ARRAY('IDs of both applicants', 'Witness ID copies'), 20),
  (1, 'Death certificate', 'Death certificate appointment', JSON_ARRAY('Medical certificate', 'Applicant family ID'), 20)
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO users (full_name, email, password_hash, role, department_id)
VALUES ('System Admin', 'admin@kebele.gov.et', 'admin123', 'admin', 1)
ON DUPLICATE KEY UPDATE email = VALUES(email);
