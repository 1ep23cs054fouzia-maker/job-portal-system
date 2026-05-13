-- ============================================
-- Online Job Portal System - Database Schema
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS job_portal;
USE job_portal;

-- ============================================
-- 1. USERS TABLE (Job Seekers)
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    location VARCHAR(200),
    profile_image VARCHAR(500),
    bio TEXT,
    headline VARCHAR(200),
    experience_years INT DEFAULT 0,
    total_applications INT DEFAULT 0,
    account_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- 2. RECRUITERS TABLE
-- ============================================
CREATE TABLE recruiters (
    recruiter_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company_id INT,
    job_postings_count INT DEFAULT 0,
    account_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_company_id (company_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- ============================================
-- 3. COMPANIES TABLE
-- ============================================
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(200) UNIQUE NOT NULL,
    industry VARCHAR(100),
    website_url VARCHAR(300),
    company_size INT,
    about_company TEXT,
    headquarters_location VARCHAR(200),
    company_logo VARCHAR(500),
    founded_year INT,
    total_employees INT,
    company_email VARCHAR(150),
    company_phone VARCHAR(20),
    verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_name (company_name),
    INDEX idx_industry (industry)
);

-- ============================================
-- 4. JOBS TABLE
-- ============================================
CREATE TABLE jobs (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    job_title VARCHAR(200) NOT NULL,
    job_description TEXT NOT NULL,
    requirements TEXT NOT NULL,
    salary_min DECIMAL(12, 2),
    salary_max DECIMAL(12, 2),
    currency VARCHAR(10) DEFAULT 'USD',
    job_type ENUM('Full-Time', 'Part-Time', 'Contract', 'Temporary', 'Freelance') DEFAULT 'Full-Time',
    experience_required INT DEFAULT 0,
    qualification_required VARCHAR(200),
    location VARCHAR(200) NOT NULL,
    job_category VARCHAR(100),
    number_of_positions INT DEFAULT 1,
    posted_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    application_deadline DATE,
    views_count INT DEFAULT 0,
    INDEX idx_company_id (company_id),
    INDEX idx_job_category (job_category),
    INDEX idx_location (location),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (company_id) REFERENCES companies(company_id),
    FOREIGN KEY (posted_by) REFERENCES recruiters(recruiter_id)
);

-- ============================================
-- 5. APPLICATIONS TABLE
-- ============================================
CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    resume_id INT,
    cover_letter TEXT,
    application_status ENUM('Applied', 'Under Review', 'Shortlisted', 'Rejected', 'Offered') DEFAULT 'Applied',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    reviewed_by INT,
    remarks TEXT,
    INDEX idx_user_id (user_id),
    INDEX idx_job_id (job_id),
    INDEX idx_status (application_status),
    INDEX idx_applied_at (applied_at),
    UNIQUE KEY unique_application (user_id, job_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (resume_id) REFERENCES resumes(resume_id),
    FOREIGN KEY (reviewed_by) REFERENCES recruiters(recruiter_id)
);

-- ============================================
-- 6. RESUMES TABLE
-- ============================================
CREATE TABLE resumes (
    resume_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT,
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 7. SKILLS TABLE
-- ============================================
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') DEFAULT 'Beginner',
    years_of_experience DECIMAL(3, 1),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 8. SAVED JOBS TABLE
-- ============================================
CREATE TABLE saved_jobs (
    saved_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_saved (user_id, job_id),
    INDEX idx_user_id (user_id),
    INDEX idx_job_id (job_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE
);

-- ============================================
-- 9. INTERVIEWS TABLE
-- ============================================
CREATE TABLE interviews (
    interview_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    interview_type ENUM('Phone', 'Video', 'In-Person', 'Assessment') DEFAULT 'Phone',
    scheduled_date DATETIME NOT NULL,
    location VARCHAR(300),
    interviewer_id INT NOT NULL,
    interview_link VARCHAR(500),
    interview_status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    feedback TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_application_id (application_id),
    INDEX idx_scheduled_date (scheduled_date),
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (interviewer_id) REFERENCES recruiters(recruiter_id)
);

-- ============================================
-- 10. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recruiter_id INT,
    notification_type ENUM('Job Posted', 'Application Status', 'Interview Scheduled', 'Message', 'Recommendation', 'Profile Update') DEFAULT 'Message',
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_recruiter_id (recruiter_id),
    INDEX idx_is_read (is_read),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recruiter_id) REFERENCES recruiters(recruiter_id) ON DELETE SET NULL
);

-- ============================================
-- 11. MESSAGES TABLE
-- ============================================
CREATE TABLE messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    sender_type ENUM('User', 'Recruiter') NOT NULL,
    receiver_id INT NOT NULL,
    receiver_type ENUM('User', 'Recruiter') NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    INDEX idx_sender_id (sender_id),
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_created_at (created_at)
);

-- ============================================
-- 12. ADMIN USERS TABLE
-- ============================================
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Super Admin', 'Moderator', 'Support') DEFAULT 'Moderator',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email)
);

-- ============================================
-- 13. REPORTS TABLE
-- ============================================
CREATE TABLE reports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    reported_by INT NOT NULL,
    reported_type ENUM('Job', 'User', 'Recruiter', 'Message') NOT NULL,
    reported_id INT NOT NULL,
    reason VARCHAR(200) NOT NULL,
    description TEXT,
    report_status ENUM('Pending', 'Under Review', 'Resolved', 'Dismissed') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    resolved_by INT,
    resolution_notes TEXT,
    INDEX idx_reported_by (reported_by),
    INDEX idx_status (report_status),
    FOREIGN KEY (reported_by) REFERENCES users(user_id),
    FOREIGN KEY (resolved_by) REFERENCES admin_users(admin_id)
);

-- ============================================
-- 14. ANALYTICS TABLE
-- ============================================
CREATE TABLE analytics (
    analytics_id INT PRIMARY KEY AUTO_INCREMENT,
    user_type ENUM('User', 'Recruiter') NOT NULL,
    entity_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    action_details JSON,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_type (user_type),
    INDEX idx_entity_id (entity_id),
    INDEX idx_timestamp (timestamp)
);

-- ============================================
-- 15. JOB RECOMMENDATIONS TABLE
-- ============================================
CREATE TABLE job_recommendations (
    recommendation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    job_id INT NOT NULL,
    match_score DECIMAL(5, 2),
    recommendation_reason VARCHAR(500),
    is_dismissed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_job_id (job_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE
);

-- ============================================
-- 16. REVIEWS & RATINGS TABLE
-- ============================================
CREATE TABLE reviews_ratings (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    reviewer_id INT NOT NULL,
    reviewer_type ENUM('User', 'Recruiter') NOT NULL,
    reviewed_id INT NOT NULL,
    reviewed_type ENUM('User', 'Recruiter', 'Company') NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_reviewer_id (reviewer_id),
    INDEX idx_reviewed_id (reviewed_id)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_jobs_company ON jobs(company_id);
CREATE INDEX idx_applications_user ON applications(user_id);
CREATE INDEX idx_applications_status ON applications(application_status);

-- ============================================
-- TRIGGERS
-- ============================================

-- Update user's total applications
DELIMITER $$
CREATE TRIGGER update_user_applications_count_insert
AFTER INSERT ON applications
FOR EACH ROW
BEGIN
    UPDATE users SET total_applications = total_applications + 1 WHERE user_id = NEW.user_id;
END$$
DELIMITER ;

-- Update recruiter's job postings count
DELIMITER $$
CREATE TRIGGER update_recruiter_jobs_count_insert
AFTER INSERT ON jobs
FOR EACH ROW
BEGIN
    UPDATE recruiters SET job_postings_count = job_postings_count + 1 WHERE recruiter_id = NEW.posted_by;
END$$
DELIMITER ;

-- ============================================
-- SAMPLE DATA (Optional)
-- ============================================

-- Insert Companies
INSERT INTO companies (company_name, industry, website_url, company_size, headquarters_location, founded_year) VALUES
('Tech Solutions Inc', 'Information Technology', 'https://techsolutions.com', 500, 'San Francisco, CA', 2010),
('Global Finance Corp', 'Finance', 'https://globalfinance.com', 1000, 'New York, NY', 2005),
('Creative Digital Agency', 'Marketing', 'https://creativedigital.com', 150, 'Los Angeles, CA', 2015),
('Healthcare Innovations', 'Healthcare', 'https://healthcareinnovations.com', 300, 'Boston, MA', 2012);

-- Insert Users (Job Seekers)
INSERT INTO users (first_name, last_name, email, password_hash, phone, location, headline, account_verified) VALUES
('John', 'Doe', 'john.doe@gmail.com', '$2a$10$hashed_password_1', '9876543210', 'San Francisco, CA', 'Senior Software Engineer', TRUE),
('Jane', 'Smith', 'jane.smith@gmail.com', '$2a$10$hashed_password_2', '9876543211', 'New York, NY', 'Product Manager', TRUE),
('Michael', 'Johnson', 'michael.johnson@gmail.com', '$2a$10$hashed_password_3', '9876543212', 'Austin, TX', 'Full Stack Developer', TRUE);

-- Insert Recruiters
INSERT INTO recruiters (first_name, last_name, email, password_hash, phone, company_id, account_verified) VALUES
('Sarah', 'Williams', 'sarah.williams@techsolutions.com', '$2a$10$hashed_password_4', '9876543213', 1, TRUE),
('Robert', 'Brown', 'robert.brown@globalfinance.com', '$2a$10$hashed_password_5', '9876543214', 2, TRUE);

-- Insert Jobs
INSERT INTO jobs (company_id, job_title, job_description, requirements, salary_min, salary_max, job_type, experience_required, location, job_category, number_of_positions, posted_by, application_deadline) VALUES
(1, 'Senior Java Developer', 'We are looking for an experienced Java Developer...', 'Java, Spring Boot, Microservices', 80000, 120000, 'Full-Time', 5, 'San Francisco, CA', 'Software Development', 2, 1, '2026-06-13'),
(1, 'Frontend Developer (React)', 'Join our frontend team...', 'React, JavaScript, CSS, HTML', 70000, 100000, 'Full-Time', 3, 'San Francisco, CA', 'Software Development', 3, 1, '2026-06-13'),
(2, 'Financial Analyst', 'Exciting opportunity in finance...', 'Excel, Financial Modeling, SQL', 60000, 90000, 'Full-Time', 2, 'New York, NY', 'Finance', 2, 2, '2026-06-13');

-- Create views for common queries
CREATE VIEW job_seeker_view AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.headline,
    u.experience_years,
    u.total_applications,
    COUNT(DISTINCT s.skill_id) as skill_count,
    COUNT(DISTINCT sj.saved_id) as saved_jobs_count
FROM users u
LEFT JOIN skills s ON u.user_id = s.user_id
LEFT JOIN saved_jobs sj ON u.user_id = sj.user_id
GROUP BY u.user_id;

CREATE VIEW recruiter_dashboard_view AS
SELECT 
    r.recruiter_id,
    r.first_name,
    r.last_name,
    c.company_name,
    COUNT(DISTINCT j.job_id) as total_jobs,
    COUNT(DISTINCT a.application_id) as total_applications,
    SUM(CASE WHEN a.application_status = 'Shortlisted' THEN 1 ELSE 0 END) as shortlisted_count
FROM recruiters r
LEFT JOIN companies c ON r.company_id = c.company_id
LEFT JOIN jobs j ON r.recruiter_id = j.posted_by
LEFT JOIN applications a ON j.job_id = a.job_id
GROUP BY r.recruiter_id;
