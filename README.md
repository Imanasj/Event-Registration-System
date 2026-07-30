
#  College Event Registration System  
*A database-driven system for managing college event registrations, enforcing capacity rules, and generating event insights.*

##  Project Overview  
The **College Event Registration System** is a relational database project designed to manage student registrations for campus events. It ensures data integrity, enforces event capacity limits, manages waitlists automatically, and provides reporting tools for organizers and administrators.

---

##  Features  
###  Core Functionality  
- Student registration for campus events  
- Automatic capacity enforcement  
- Automatic waitlisting when events are full  
- Organizer–event management  
- Reporting on attendance, engagement, and event fill rates  

###  Database Features  
- Fully normalized relational schema  
- Primary keys, foreign keys, unique constraints, and check constraints  
- INSTEAD OF INSERT trigger for capacity enforcement  
- Stored procedure for controlled registration  
- Indexes for performance optimization  
- View for simplified reporting  

---

## Database Schema  
### **Entities**
- **STUDENT** – student info (name, email, year)  
- **ORGANIZER** – event organizers  
- **EVENT** – event details (title, date, location, capacity)  
- **REGISTRATION** – links students to events with status + timestamp  

### **Key Relationships**
- A student can register for many events  
- An event can have many registrations  
- Each event is managed by exactly one organizer  
- Each registration belongs to one student and one event  

---

##  Relational Schema (Summary)

| Table | Key Fields | Notes |
|-------|------------|-------|
| **STUDENT** | student_id PK | Unique email, year check (1–4) |
| **ORGANIZER** | organizer_id PK | Linked to EVENT (ON DELETE CASCADE) |
| **EVENT** | event_id PK | Future date check, capacity > 0 |
| **REGISTRATION** | registration_id PK | Unique (student_id, event_id), status check |

---

##  Sample Data  
The project includes sample inserts for:  
- **12 students**  
- **6 organizers**  
- **10 events**  
- **26 registrations**  

These datasets allow full testing of triggers, views, and queries.

---

## ⚙️ Trigger: Capacity Enforcement  
A custom **INSTEAD OF INSERT** trigger ensures events never exceed capacity.

**Trigger behavior:**  
- Counts current registered students  
- Compares with event capacity  
- If full → assigns **waitlist**  
- Otherwise → assigns **registered**  
- Inserts final status automatically  

This enforces business rules without requiring application logic.

---

##  Stored Procedure: `quick_register`  
A stored procedure that:  
- Accepts `student_id` and `event_id`  
- Checks event capacity  
- Determines registration status  
- Inserts the registration  
- Returns a confirmation message  

Useful for consistent, controlled registration logic.

---

##  SQL Queries Included  
The project includes 5 reporting queries:

1. **List events with registered students**  
2. **Find students registered for multiple events**  
3. **Show upcoming events with available slots**  
4. **Summarize participant counts by event**  
5. **List events by a specific organizer**

---

## 🚀 Performance Optimization  
Indexes created on:  
- Event date  
- Organizer ID  
- Registration event ID  

These improve search and join performance across queries.

---

##  View: `active_registrations`  
A simplified reporting view showing:  
- Student name + email  
- Event title, date, location  
- Registration timestamp  
- Only includes **active (registered)** students  

--- 
- ERD revision & design verification  
- Relational schema + all CREATE TABLE statements  
- Initial sample data (students, organizers, events, registrations)  
- Trigger purpose & logic explanation  

### **Saranya Rajendran**  
- Trigger implementation  
- Expanded sample dataset (12 students, 10 events, 26 registrations)  
- All SQL reporting queries  
- Indexes, view, and stored procedure implementation  

---

##  How to Use  
1. Run all **CREATE TABLE** statements  
2. Insert sample data  
3. Add trigger, view, and stored procedure  
4. Run queries to test reporting and capacity logic  
