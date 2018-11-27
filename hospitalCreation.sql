USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name='hospital')
DROP DATABASE hospital

CREATE DATABASE hospital

USE hospital

--Table creation--
CREATE TABLE PERSON
(  Person_ID CHAR(4) NOT NULL,
   F_Name NVARCHAR(100) NOT NULL,
  /* NULL is OK for middle name */
   M_Name NVARCHAR(100),
   L_Name NVARCHAR(100) NOT NULL,
  /* Should Address be nullable?  I don’t think so, but I could be wrong */
   Address NVARCHAR(100) NOT NULL,
  /* Binary/fixed number or free entry?  If binary/fixed number, INT; if not, VARCHAR */
   Gender INT,
   Birth_Date DATE NOT NULL,
   PRIMARY KEY (Person_ID) );

   CREATE TABLE EMPLOYEE
(  Person_ID CHAR(4) NOT NULL,
   Start_Date DATE NOT NULL,
   Specialization VARCHAR(20), -- Can store "nurse" or "receptionist", as well as the doctor specialties like "cardiology".
   Doctor_Type VARCHAR(9), -- Stores either “Trainee”, “Visiting”, or “Permanent” (max 9 characters); this will be null if the employee is not a doctor
   FOREIGN KEY (Person_ID) REFERENCES PERSON (Person_ID) );


CREATE TABLE CLASS1_PATIENT
(  Person_ID CHAR(4) NOT NULL,
   Doctor_ID CHAR(4) NOT NULL,
   PRIMARY KEY (Person_ID),
   FOREIGN KEY (Person_ID) REFERENCES PERSON(Person_ID),
   FOREIGN KEY (Doctor_ID) REFERENCES PERSON(Person_ID) );

CREATE TABLE ROOM
(  Room_ID UNIQUEIDENTIFIER NOT NULL,
   Room_Type VARCHAR(20),
   Nurse_ID CHAR(4),
   PRIMARY KEY (Room_ID),
   FOREIGN KEY (Nurse_ID) REFERENCES PERSON(Person_ID) );


CREATE TABLE CLASS2_PATIENT
(  Person_ID CHAR(4) NOT NULL,
   Admission_Date DATE NOT NULL,
   Discharge_Date DATE,
   Room_ID UNIQUEIDENTIFIER NOT NULL,
   PRIMARY KEY (Person_ID),
   FOREIGN KEY (Person_ID) REFERENCES PERSON(Person_ID),
   FOREIGN KEY (Room_ID) REFERENCES ROOM(Room_ID) );


CREATE TABLE ATTENDS
(  Doctor_ID CHAR(4) NOT NULL,
   Class2_Patient_ID CHAR(4) NOT NULL,
   PRIMARY KEY (Doctor_ID, Class2_Patient_ID),
   FOREIGN KEY (Doctor_ID) REFERENCES PERSON(Person_ID),
   FOREIGN KEY (Class2_Patient_ID) REFERENCES CLASS2_PATIENT(Person_ID) );


CREATE TABLE VISITOR
(  Visitor_ID UNIQUEIDENTIFIER NOT NULL,
   Person_ID CHAR(4) NOT NULL,
   Name NVARCHAR(100),
   Address NVARCHAR(100),
   Contact_Information NVARCHAR(100),
   Room_ID UNIQUEIDENTIFIER NOT NULL,
   PRIMARY KEY (Visitor_ID, Person_ID),
   FOREIGN KEY (Person_ID) REFERENCES CLASS2_PATIENT(Person_ID),
   FOREIGN KEY (Room_ID) REFERENCES ROOM(Room_ID) );

CREATE TABLE MEDICINE
(  Medicine_Code UNIQUEIDENTIFIER NOT NULL,
   Name VARCHAR(100) NOT NULL,
   Price MONEY NOT NULL,
   Date_Of_Expiration DATE NOT NULL,
   Quantity INT NOT NULL,
   Pharmacy_ID UNIQUEIDENTIFIER NOT NULL,
   PRIMARY KEY (Medicine_Code) );


CREATE TABLE TREATMENT
( Treatment_ID UNIQUEIDENTIFIER NOT NULL,
   Name VARCHAR(100) NOT NULL,
   Duration INT NOT NULL,
   PRIMARY KEY (Treatment_ID) );

CREATE TABLE ASSIGNED
(  Class2_Patient_ID CHAR(4)  NOT NULL,
   Medicine_Code UNIQUEIDENTIFIER NOT NULL,
   Treatment_ID UNIQUEIDENTIFIER NOT NULL,
   PRIMARY KEY (Class2_Patient_ID, Treatment_ID, Medicine_Code),
   FOREIGN KEY (Class2_Patient_ID) REFERENCES CLASS2_PATIENT(Person_ID),
   FOREIGN KEY (Medicine_Code) REFERENCES MEDICINE(Medicine_Code),
   FOREIGN KEY (Treatment_ID) REFERENCES TREATMENT(Treatment_ID) );


CREATE TABLE PHONE_NUMBER
(  Person_ID CHAR(4) NOT NULL,
   Number VARCHAR(20) NOT NULL,
   PRIMARY KEY (Person_ID, Number),
   FOREIGN KEY (Person_ID) REFERENCES PERSON(Person_ID) );


CREATE TABLE RECORD
(  Record_ID UNIQUEIDENTIFIER NOT NULL,
   Patient_ID CHAR(4) NOT NULL,
   Date_Of_Visit DATE NOT NULL,
   Description VARCHAR(500),
   Appointment UNIQUEIDENTIFIER NOT NULL,
   Receptionist_ID CHAR(4) NOT NULL,
   PRIMARY KEY (Record_ID),
   FOREIGN KEY (Patient_ID) REFERENCES PERSON(Person_ID),
   FOREIGN KEY (Receptionist_ID) REFERENCES PERSON(Person_ID) );


CREATE TABLE MEDICAL_BILL_PAYMENT
(  Payment_ID UNIQUEIDENTIFIER NOT NULL,
   Patient_ID CHAR(4) NOT NULL,
   Receptionist_ID CHAR(4) NOT NULL,
   PRIMARY KEY (Payment_ID),
   FOREIGN KEY (Patient_ID) REFERENCES PERSON(Person_ID),
   FOREIGN KEY (Receptionist_ID) REFERENCES PERSON(Person_ID) );




CREATE TABLE CASH
(  Payment_ID UNIQUEIDENTIFIER NOT NULL,
   Amount MONEY NOT NULL,
   PRIMARY KEY (Payment_ID),
   FOREIGN KEY (Payment_ID) REFERENCES MEDICAL_BILL_PAYMENT(Payment_ID) );



CREATE TABLE INSURANCE_PROVIDER
(  Insurance_ID UNIQUEIDENTIFIER NOT NULL,
   Provider VARCHAR(100) NOT NULL,
   PRIMARY KEY (Insurance_ID) );



CREATE TABLE INSURANCE
(  Payment_ID UNIQUEIDENTIFIER NOT NULL,
   Insurance_ID UNIQUEIDENTIFIER NOT NULL,
   Amount MONEY NOT NULL,
   Coverage MONEY NOT NULL,
   PRIMARY KEY (Payment_ID),
   FOREIGN KEY (Payment_ID) REFERENCES MEDICAL_BILL_PAYMENT(Payment_ID),
   FOREIGN KEY (Insurance_ID) REFERENCES INSURANCE_PROVIDER(Insurance_ID) );

--Populate the tables with data--
--Person
INSERT INTO PERSON(Person_ID, F_Name, M_Name, L_Name, Address, Gender, Birth_Date)
   VALUES
   ('P001', 'Mungo', 'B', 'Jerry', '5454 XYZ Drive', 1, '1955-05-05'),
   ('P002', 'Bobby', 'B', 'Smith', '123 Rocky Road', 1, '1978-02-16'),
   ('P003', 'Julie', 'R', 'Johnson', '808 Lorrie Ave', 2, '1986-10-07'),
   ('P004', 'Rick', 'E', 'Sanchez', '908 Milky Way', 1, '1943-04-20'),
   ('P005', 'Nancy', 'M', 'Carney', '234 Viking Drive', 2, '1963-03-30'),
   ('P006', 'Victoria', 'L', 'Rush', '221B Baker Street', 2, '1981-09-03'),
   ('P007', 'George', NULL, 'James', '221B Penny Lane', 2, '1971-02-03'),
   ('P008', 'Phil', NULL, 'Lays', '9200 Windy Lane', 2, '1996-04-24'),
   ('P009', 'Charles', NULL, 'Ronson', '6200 Worthington Drive', 2, '2001-02-14'),
   ('P010', 'Diana', NULL, 'Ross', '249 Syracuse Drive', 2, '1950-05-22'),
   ('P011', 'Colonal', NULL, 'Mustard', '6226 Clue Lane', 2, '1937-12-23');

--Employee
INSERT INTO EMPLOYEE(Person_ID, Start_Date, Specialization, Doctor_Type)
   VALUES
   ('P001', '1998-08-12', 'Cardiology', 'Permanent'),
   ('P004', '2015-06-01', 'Orthopedic', 'Visiting'),
   ('P003', '1987-01-31', 'Nurse', NULL),
   ('P005', '2007-10-31', 'Receptionist', NULL);

INSERT INTO EMPLOYEE(Person_ID, Start_Date, Specialization, Doctor_Type)
	VALUES('P008', '2014-11-21', 'Receptionist', NULL);

--Class 1 Patient
INSERT INTO CLASS1_PATIENT(Person_ID, Doctor_ID)
	VALUES
	('P002', 'P004'),
	('P001', 'P004'),
	('P006', 'P001');

--Room
INSERT INTO ROOM(Room_ID, Room_Type, Nurse_ID)
	VALUES
	('e10d5923-ebbb-47a9-8fde-f9ba4ac229db', 'Single', 'P003'),
	('9044ad76-bd87-4bed-9605-d984cadf4658', 'Double', 'P003'),
	('979fb8b8-232d-49ed-84cd-e4b247ff09a6', 'Quadruple', 'P003'),
	('011a63ce-4d66-495e-b8b9-f33c854822b0', 'Multiple', 'P003');

--Class 2 Patient
INSERT INTO CLASS2_PATIENT(Person_ID, Admission_Date, Discharge_Date, Room_ID)
	VALUES
	('P002', '20181101', NULL, 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('P003', '20180708', '20180714', '9044ad76-bd87-4bed-9605-d984cadf4658'),
	('P007', '2018-09-16', NULL, '979fb8b8-232d-49ed-84cd-e4b247ff09a6'),
	('P009', '2018-11-10', NULL, '011a63ce-4d66-495e-b8b9-f33c854822b0'),
	('P010', '2018-11-06', '2018-11-29', '011a63ce-4d66-495e-b8b9-f33c854822b0'),
	('P011', '2018-11-10', NULL, '011a63ce-4d66-495e-b8b9-f33c854822b0');

--Attends
INSERT INTO ATTENDS(Doctor_ID, Class2_Patient_ID)
	VALUES
	('P004', 'P002'),
	('P001', 'P002'),
	('P004', 'P003');


--Visitor
INSERT INTO VISITOR(Visitor_ID, Person_ID, Name, Address, Contact_Information, Room_ID)
	VALUES
	('949ddb6d-7f41-4acb-a2a9-2f747ebe2ff6', 'P002', 'Hammond Johnson', '25 Fish Blvd.', '(273) 555-1234', 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('d9abd5af-ae30-4386-ab4d-0a6920ecfb3a', 'P002', 'Susie Johnson', '25 Fish Blvd.', '(273) 555-4321', 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('a584f717-1942-49b0-8c6e-05b7834d1068', 'P003', 'Fracis McGee', '613 Salmon Ln.', '(990) 555-2413', '9044ad76-bd87-4bed-9605-d984cadf4658');

--Medicine
INSERT INTO MEDICINE(Medicine_Code, Name, Price, Date_Of_Expiration, Quantity, Pharmacy_ID)
	VALUES
	('c1e37f61-455f-4b51-a43a-ea1d20619a1f', 'Amoxicillin', '$4.00', '20200927', 50, 'd4178aa7-c5ab-44d8-8770-ffdc3b3baa5e'),
	('f703936a-f725-4ba8-a031-8af9a6b30e05', 'Acetaminophen', '$0.90', '20250713', 1000, '3565cc04-0d42-46d8-b7ec-1fb1ca20703a'),
	('e97749f2-ceb2-4cd7-82c3-2fac36379d0b', 'Daklinza', '$49400.00', '20220404', 10, '68ead9e2-4a70-4202-903c-43104e2a2e65');

--Treatment
INSERT INTO TREATMENT(Treatment_ID, Name, Duration)
	VALUES
	('09610573-ec8b-40a6-8698-f40479b040dc', 'Painkillers', 72),
	('86f9d393-ae87-4247-9cd3-40d1197b2f51', 'Antibiotics', 168);

--Assigned
INSERT INTO ASSIGNED(Class2_Patient_ID, Medicine_Code, Treatment_ID)
	VALUES
	('P002', 'c1e37f61-455f-4b51-a43a-ea1d20619a1f', '86f9d393-ae87-4247-9cd3-40d1197b2f51'),
	('P003', 'c1e37f61-455f-4b51-a43a-ea1d20619a1f', '86f9d393-ae87-4247-9cd3-40d1197b2f51'),
	('P003', 'f703936a-f725-4ba8-a031-8af9a6b30e05', '09610573-ec8b-40a6-8698-f40479b040dc');

--Phone Number
INSERT INTO PHONE_NUMBER(Person_ID, Number)
	VALUES
    ('P001', '972-867-5309'),
	('P002', '555-555-5555')

--Record
INSERT INTO RECORD(Record_ID, Patient_ID, Date_Of_Visit, Description, Appointment, Receptionist_ID)
	VALUES
	('80fb52bb-6999-44cc-9489-dd13782a69a9', 'P007', '2018-06-10', 'Long description here', 'd46ad8e7-9895-4cde-a9f5-606fab789e83', 'P008'),
	('223442a3-9fb2-49e0-9d7c-1e7a26144b54', 'P009', '2016-03-18', 'Long description here', '368b8003-ef87-4285-9b5f-b7555d5d8785', 'P008'),
	('9e7b9b93-ce2f-488b-bf5d-03cb410003ae', 'P010', '2016-08-25', 'Professional description here', '20ee8a07-94b4-47d9-8420-5333c98fd361', 'P008'),
	('5434c983-90b0-4d88-93ae-f4f648fb9a86', 'P011', '2016-08-25', 'Professional description here', 'f5cc3240-f034-487f-8420-eb91533565ab', 'P005');

--Medical Bill Payment
INSERT INTO MEDICAL_BILL_PAYMENT(Payment_ID, Patient_ID, Receptionist_ID)
	VALUES
	('b9f17e90-c7e1-4eec-a3d0-d2c8f62d2b31', 'P010', 'P008'),
	('f69489f8-dfbe-4ff4-b63d-b446198066d6', 'P011', 'P005'),
	('4499f15f-ffb4-4aa3-a603-50ed5dbfa17d', 'P009', 'P008');

--Cash
INSERT INTO CASH(Payment_ID, Amount)
	VALUES
    ('b9f17e90-c7e1-4eec-a3d0-d2c8f62d2b31', 2000),
	('f69489f8-dfbe-4ff4-b63d-b446198066d6', 1200);

--Insurance Provider
INSERT INTO INSURANCE_PROVIDER(Insurance_ID, Provider)
	VALUES
    ('acb32635-a23d-48e5-aae7-7d6dd77589da', 'Mercy'),
	('2bfa19a9-c5ce-4815-865e-d4ee7e8ea63c', 'Schadenfreude');

--Insurance
INSERT INTO INSURANCE(Payment_ID, Insurance_ID, Amount, Coverage)
	VALUES
    ('b9f17e90-c7e1-4eec-a3d0-d2c8f62d2b31', 'acb32635-a23d-48e5-aae7-7d6dd77589da', 5000, 3000),
	('4499f15f-ffb4-4aa3-a603-50ed5dbfa17d', '2bfa19a9-c5ce-4815-865e-d4ee7e8ea63c', 1400, 6000);


GO

