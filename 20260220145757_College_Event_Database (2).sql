-- -- COLLEGE EVENT REGISTRATION SYSTEM


-- Drop the database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CollegeEventDB')
BEGIN
  ALTER DATABASE CollegeEventDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE CollegeEventDB;
END
GO

-- Create fresh database
CREATE DATABASE CollegeEventDB;
GO

USE CollegeEventDB;
GO

-- ============================================================================
-- CREATE TABLES
-- ============================================================================

-- Create student table
CREATE TABLE STUDENT (
  student_id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  year INT NOT NULL,
  CONSTRAINT chk_email CHECK (email LIKE '%@%'),
  CONSTRAINT chk_year CHECK (year IN (1, 2, 3, 4))
);

-- Create organizer table
CREATE TABLE ORGANIZER (
  organizer_id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  contact_info VARCHAR(150) NOT NULL
);

-- Create event table
CREATE TABLE EVENT (
  event_id INT IDENTITY(1,1) PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  date DATE NOT NULL,
  location VARCHAR(150) NOT NULL,
  capacity INT NOT NULL,
  organizer_id INT NOT NULL,
  CONSTRAINT chk_date CHECK (date >= CAST(GETDATE() AS DATE)),
  CONSTRAINT chk_capacity CHECK (capacity > 0),
  CONSTRAINT fk_organizer FOREIGN KEY (organizer_id)
    REFERENCES ORGANIZER(organizer_id)
    ON DELETE CASCADE
);

-- Create registration table
CREATE TABLE REGISTRATION (
  registration_id INT IDENTITY(1,1) PRIMARY KEY,
  student_id INT NOT NULL,
  event_id INT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'registered',
  registration_date DATETIME NOT NULL DEFAULT GETDATE(),
  CONSTRAINT fk_student FOREIGN KEY (student_id)
    REFERENCES STUDENT(student_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_event FOREIGN KEY (event_id)
    REFERENCES EVENT(event_id)
    ON DELETE CASCADE,
  CONSTRAINT chk_status CHECK (status IN ('registered', 'waitlist', 'cancelled')),
  CONSTRAINT unique_student_event UNIQUE (student_id, event_id)
);

GO

-- ============================================================================
-- INSERT DATA BEFORE CREATING TRIGGER
-- ============================================================================

-- Insert student table (5 initial students)
INSERT INTO STUDENT (name, email, year)
VALUES
  ('Lila Chea', 'lila.chea@edu.ca', 2),
  ('Alice Thompson', 'alice.thompson@gmail.com', 3),
  ('Amanda Smith', 'amanda.smith@edu.ca', 1),
  ('Michael Dukefe', 'michael.d@edu.ca', 4),
  ('James Wilson', 'james.wilson@gmail.com', 2);

-- Insert organizer table
INSERT INTO ORGANIZER (name, contact_info)
VALUES
  ('Student Council', 'council@edu.ca'),
  ('Computer Science Club', 'comp.sciclub@edu.ca'),
  ('Sports Club', 'sports.club@edu.ca');

-- Insert event table
INSERT INTO EVENT (title, date, location, capacity, organizer_id)
VALUES
  ('Welcoming Week', '2026-03-20', 'Main Auditorium', 150, 1),
  ('AI Workshop', '2026-03-17', 'Computer Lab', 30, 2),
  ('Sports Tryout Event', '2026-03-22', 'Athletic Center', 100, 3),
  ('Career Fair 2026', '2026-03-24', 'Student Center', 200, 1);

-- Add more students (7 additional = 12 total)
INSERT INTO STUDENT (name, email, year)
VALUES
  ('Sarah Parker', 'sarah.parker@edu.ca', 3),
  ('Adam Davis', 'adam.davis@gmail.com', 2),
  ('Emily Brooke', 'emily.brooke@edu.ca', 1),
  ('Robert Taylor', 'robert.taylor@gmail.com', 4),
  ('Lisa Marie', 'lisa.marie@edu.ca', 2),
  ('Kevin Brown', 'kevin.b@edu.ca', 3),
  ('Stephanie Maria', 'stephanie.maria@gmail.com', 1);

-- Add more organizers (3 additional = 6 total)
INSERT INTO ORGANIZER (name, contact_info)
VALUES
  ('Visual Arts Club', 'visual.artsclub@edu.ca'),
  ('Networking Club', 'networking.club@edu.ca'),
  ('Environmental Society', 'environmental.society@edu.ca');

-- Add more events (6 additional = 10 total)
INSERT INTO EVENT (title, date, location, capacity, organizer_id)
VALUES
  ('Art Festival Opening Night', '2026-03-02', 'Theater Hall', 80, 4),
  ('Entrepreneurship Workshop', '2026-03-05', 'Business Building, Room 305', 40, 5),
  ('Campus Cleanup Day', '2026-03-12', 'Main Campus Field', 60, 6),
  ('Junior Dance', '2026-03-14', 'Student Center Ballroom', 120, 1),
  ('Basketball Season Tryouts', '2026-03-16', 'Main Gymnasium', 50, 3),
  ('Hackathon Competition', '2026-03-18', 'Computer Lab 201', 25, 2);

-- Insert initial registrations (7 initial)
INSERT INTO REGISTRATION (student_id, event_id, status)
VALUES
  (1, 1, 'registered'),
  (1, 2, 'registered'),
  (2, 1, 'registered'),
  (2, 3, 'registered'),
  (3, 2, 'waitlist'),
  (4, 4, 'registered'),
  (5, 1, 'registered');

-- Add more registrations (19 additional = 26 total)
INSERT INTO REGISTRATION (student_id, event_id, status)
VALUES
  (3, 3, 'registered'),
  (4, 1, 'registered'),
  (5, 4, 'registered'),
  (6, 2, 'registered'),
  (6, 5, 'registered'),
  (6, 8, 'registered'),
  (7, 6, 'registered'),
  (7, 9, 'registered'),
  (8, 7, 'registered'),
  (9, 4, 'registered'),
  (9, 10, 'registered'),
  (10, 8, 'registered'),
  (11, 5, 'registered'),
  (11, 9, 'registered'),
  (12, 7, 'registered'),
  (12, 8, 'cancelled'),
  (1, 10, 'registered'),
  (2, 6, 'waitlist'),
  (3, 4, 'registered'),
  (5, 9, 'registered');

GO

-- ============================================================================
-- CREATE TRIGGER - CAPACITY ENFORCEMENT
-- ============================================================================

CREATE TRIGGER trg_check_event_capacity
ON REGISTRATION
INSTEAD OF INSERT
AS
BEGIN
  DECLARE @student_id INT;
  DECLARE @event_id INT;
  DECLARE @status VARCHAR(20);
  DECLARE @current_count INT;
  DECLARE @max_capacity INT;

  SELECT @student_id = student_id,
         @event_id = event_id,
         @status = status
  FROM inserted;

  SELECT @current_count = COUNT(*)
  FROM REGISTRATION
  WHERE event_id = @event_id AND status = 'registered';

  SELECT @max_capacity = capacity
  FROM EVENT
  WHERE event_id = @event_id;

  IF @current_count >= @max_capacity
  BEGIN
    SET @status = 'waitlist';
  END

  INSERT INTO REGISTRATION (student_id, event_id, status, registration_date)
  VALUES (@student_id, @event_id, @status, GETDATE());
END;

GO

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

CREATE INDEX idx_event_date ON EVENT(date);
CREATE INDEX idx_event_organizer ON EVENT(organizer_id);
CREATE INDEX idx_registration_event ON REGISTRATION(event_id);

GO

-- ============================================================================
-- CREATE VIEW
-- ============================================================================

CREATE VIEW active_registrations AS
SELECT
  S.name AS student_name,
  S.email AS student_email,
  E.title AS event_title,
  E.date AS event_date,
  E.location AS event_location,
  R.registration_date
FROM REGISTRATION R
INNER JOIN STUDENT S ON R.student_id = S.student_id
INNER JOIN EVENT E ON R.event_id = E.event_id
WHERE R.status = 'registered';

GO

-- ============================================================================
-- CREATE STORED PROCEDURE
-- ============================================================================

CREATE PROCEDURE quick_register
  @student_id INT,
  @event_id INT,
  @message VARCHAR(200) OUTPUT
AS
BEGIN
  DECLARE @current_count INT;
  DECLARE @max_capacity INT;
  DECLARE @registration_status VARCHAR(20);

  SELECT @current_count = COUNT(*)
  FROM REGISTRATION
  WHERE event_id = @event_id AND status = 'registered';

  SELECT @max_capacity = capacity
  FROM EVENT WHERE event_id = @event_id;

  IF @current_count >= @max_capacity
  BEGIN
    SET @registration_status = 'waitlist';
  END
  ELSE
  BEGIN
    SET @registration_status = 'registered';
  END

  INSERT INTO REGISTRATION (student_id, event_id, status, registration_date)
  VALUES (@student_id, @event_id, @registration_status, GETDATE());

  SET @message = 'Registration successful with status: ' + @registration_status;
END;

GO

-- ============================================================================
-- VERIFY TABLES CREATED
-- ============================================================================

SELECT 'STUDENT table' AS TableName, COUNT(*) AS RecordCount FROM STUDENT
UNION ALL
SELECT 'ORGANIZER', COUNT(*) FROM ORGANIZER
UNION ALL
SELECT 'EVENT', COUNT(*) FROM EVENT
UNION ALL
SELECT 'REGISTRATION', COUNT(*) FROM REGISTRATION;

GO

-- ============================================================================
-- ESSENTIAL QUERIES
-- ============================================================================

-- Query 1: List Events with Registered Students
SELECT
  E.title AS event_title,
  E.date AS event_date,
  E.location,
  S.name AS student_name,
  R.status
FROM EVENT E
INNER JOIN REGISTRATION R ON E.event_id = R.event_id
INNER JOIN STUDENT S ON R.student_id = S.student_id
ORDER BY E.date, E.title, S.name;

GO

-- Query 2: Find Students Registered for Multiple Events
SELECT
  S.name AS student_name,
  S.email,
  COUNT(R.registration_id) AS event_count
FROM STUDENT S
INNER JOIN REGISTRATION R ON S.student_id = R.student_id
WHERE R.status IN ('registered', 'waitlist')
GROUP BY S.student_id, S.name, S.email
HAVING COUNT(R.registration_id) > 1
ORDER BY event_count DESC, S.name;

GO

-- Query 3: Show Upcoming Events with Available Slots
SELECT
  E.title,
  E.date,
  E.location,
  E.capacity,
  COUNT(R.registration_id) AS current_registrations,
  E.capacity - COUNT(R.registration_id) AS available_slots
FROM EVENT E
LEFT JOIN REGISTRATION R ON E.event_id = R.event_id
AND R.status = 'registered'
WHERE E.date >= CAST(GETDATE() AS DATE)
GROUP BY E.event_id, E.title, E.date, E.location, E.capacity
ORDER BY E.date;

GO

-- Query 4: Summarize Participant Counts by Event
SELECT
  E.title AS event_title,
  O.name AS organizer_name,
  COUNT(R.registration_id) AS total_participants,
  E.capacity,
  ROUND((CAST(COUNT(R.registration_id) AS DECIMAL) / E.capacity) * 100, 2) AS fill_percentage
FROM EVENT E
INNER JOIN ORGANIZER O ON E.organizer_id = O.organizer_id
LEFT JOIN REGISTRATION R ON E.event_id = R.event_id
AND R.status = 'registered'
GROUP BY E.event_id, E.title, O.name, E.capacity
ORDER BY total_participants DESC;

GO

-- Query 5: Events by Specific Organizer
SELECT
  E.title,
  E.date,
  E.location,
  E.capacity,
  COUNT(R.registration_id) AS registration_count
FROM EVENT E
INNER JOIN ORGANIZER O ON E.organizer_id = O.organizer_id
LEFT JOIN REGISTRATION R ON E.event_id = R.event_id
AND R.status = 'registered'
WHERE O.name = 'Student Council'
GROUP BY E.event_id, E.title, E.date, E.location, E.capacity
ORDER BY E.date;

GO

-- ============================================================================
-- END OF SCRIPT
-- =====================================================================================================