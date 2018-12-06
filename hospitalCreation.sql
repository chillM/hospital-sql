USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name='hospital')
DROP DATABASE hospital

CREATE DATABASE hospital

GO

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
   ('P100', 'Mungo', 'B', 'Jerry', '5454 XYZ Drive', 1, '1955-05-05'), --doctor
   ('P101', 'Bobby', 'B', 'Smith', '123 Rocky Road', 1, '1978-02-16'), --class 2 patient
   ('P102', 'Julie', 'R', 'Johnson', '808 Lorrie Ave', 2, '1986-10-07'), --class 1 patient
   ('P103', 'Rick', 'E', 'Sanchez', '908 Milky Way', 1, '1943-04-20'), --doctor
   ('P104', 'Nancy', 'M', 'Carney', '234 Viking Drive', 2, '1963-03-30'), --nurse
   ('P105', 'Victoria', 'L', 'Rush', '221B Baker Street', 2, '1981-09-03'), --receptionist
   ('P106', 'George', NULL, 'James', '221B Penny Lane', 1, '1971-02-03'), --receptionist
   ('P107', 'Phil', NULL, 'Lays', '9200 Windy Lane', 1, '1996-04-24'), --unused
   ('P108', 'Charles', NULL, 'Ronson', '6200 Worthington Drive', 1, '2001-02-14'), --unused
   ('P109', 'Diana', NULL, 'Ross', '249 Syracuse Drive', 2, '1950-05-22'), --unused
   ('P110', 'Colonal', NULL, 'Mustard', '6226 Clue Lane', 1, '1937-12-23'), --class 2 patient
   ('P111', 'Bob', 'N', 'Ross', '1943 Happy Little Accidents Ave', 1, '1942-10-29'), --class 2 patient
   ('P112', 'Karl', NULL, 'Popper', '101 Metaphysics Drive', 1, '1902-10-28'), --class 1 patient
   ('P113', 'Bruce', NULL, 'Banner', '321 Oak Boulevard', 1, '1965-08-17'), --unnused
   ('P114', 'Neil','D', 'Tyson', '200 Central Park West', 1, '1958-10-05'), --class 1 patient
   ('P115', 'Alan', NULL, 'Turing', '1101 Lambda Lane', 1, '1912-06-23'), --class 2 patient
   ('P116', 'Donald', NULL, 'Knuth', '1011 Combinatorics Way', 1, '1938-01-10'), --unused
   ('P117', 'Grace', NULL, 'Hopper', '1010 COBOL Parkway', 2, '1906-12-09'), --class 2 patient
   ('P118', 'Guido', 'V', 'Rossum', '1001 Benevolent Dictator For Life Blvd', 1, '1956-01-31'), --unused
   ('P119', 'Dennis', NULL, 'Ritchie', '1000 C-Side Blvd', 1, '1941-09-09'), --unused
   ('P120', 'Paul', NULL, 'Hudak', '1111 Functional Street', 1, '1952-07-15'), --unused
   ('P121', 'Rob', 'C', 'Pike', '1000 Go Lane', 1, '1956-07-03'), --class 1 patient
   ('P122', 'Robert', NULL, 'Griesemer', '1001 Go Lane', 1, '1950-04-01'), --unused
   ('P123', 'Ken', 'L', 'Thompson', '1010 Go Lane', 1, '1943-02-04'), --unused
   ('P124', 'Urban', NULL, 'Müller', '10101 Esoteric Lane', 1, '1971-01-25'), --unused
   ('P125', 'Haskell', NULL, 'Curry', '1011 Functional Street', 1, '1900-09-12'), --Intentionally Unused Doctor
   ('P126', 'John', NULL, 'McCarthy', '1101 Functional Street', 1, '1927-09-04'), --unused
   ('P127', 'Claude', 'E', 'Shannon', '11010 C23khsirfRiES Ave', 1, '1916-04-30'), --unused
   ('P128', 'Linus', 'B', 'Torvalds', '10000 Kernel Drive', 1, '1969-12-28'), --class 2  patient
   ('P129', 'Stephen', NULL, 'Wolfram', '10001 Automata Pkwy', 1, '1959-08-29'); --unused
   


--Employee
INSERT INTO EMPLOYEE(Person_ID, Start_Date, Specialization, Doctor_Type)
   VALUES
   ('P100', '1998-08-12', 'Cardiology', 'Permanent'),
   ('P103', '2015-06-01', 'Orthopedic', 'Visiting'),
   ('P125', '1975-05-04', 'Generalist', 'Permanent'),
   ('P104', '1987-01-31', 'Nurse', NULL),
   ('P105', '2007-10-31', 'Receptionist', NULL),
   ('P106', '2014-11-21', 'Receptionist', NULL);

--Class 1 Patient
INSERT INTO CLASS1_PATIENT(Person_ID, Doctor_ID)
	VALUES
	('P102', 'P100'),
	('P100', 'P103'),
	('P121', 'P100'),
	('P112', 'P103'),
	('P114', 'P103');

--Room
INSERT INTO ROOM(Room_ID, Room_Type, Nurse_ID)
	VALUES
	('e10d5923-ebbb-47a9-8fde-f9ba4ac229db', 'Single', 'P104'),
	('9044ad76-bd87-4bed-9605-d984cadf4658', 'Double', 'P104'),
	('979fb8b8-232d-49ed-84cd-e4b247ff09a6', 'Quadruple', 'P104'),
	('011a63ce-4d66-495e-b8b9-f33c854822b0', 'Multiple', 'P104');

--Class 2 Patient
INSERT INTO CLASS2_PATIENT(Person_ID, Admission_Date, Discharge_Date, Room_ID)
	VALUES
	('P101', '2018-11-01', NULL, 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('P111', '2018-07-08', '20180714', '9044ad76-bd87-4bed-9605-d984cadf4658'),
	('P128', '2018-09-16', NULL, '979fb8b8-232d-49ed-84cd-e4b247ff09a6'),
	('P115', '2018-11-10', NULL, '011a63ce-4d66-495e-b8b9-f33c854822b0'),
	('P110', '2018-11-06', '2018-11-29', '011a63ce-4d66-495e-b8b9-f33c854822b0'),
	('P117', '2018-11-10', NULL, '011a63ce-4d66-495e-b8b9-f33c854822b0');

--Attends
INSERT INTO ATTENDS(Doctor_ID, Class2_Patient_ID)
	VALUES
	('P103', 'P101'),
	('P100', 'P111'),
	('P103', 'P128'),
	('P103', 'P115'),
	('P100', 'P110'),
	('P100', 'P117');


--Visitor
INSERT INTO VISITOR(Visitor_ID, Person_ID, Name, Address, Contact_Information, Room_ID)
	VALUES
	('949ddb6d-7f41-4acb-a2a9-2f747ebe2ff6', 'P111', 'Hammond Johnson', '25 Fish Blvd.', '(273) 555-1234', 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('d9abd5af-ae30-4386-ab4d-0a6920ecfb3a', 'P128', 'Susie Johnson', '25 Fish Blvd.', '(273) 555-4321', 'e10d5923-ebbb-47a9-8fde-f9ba4ac229db'),
	('a584f717-1942-49b0-8c6e-05b7834d1068', 'P110', 'Fracis McGee', '613 Salmon Ln.', '(990) 555-2413', '9044ad76-bd87-4bed-9605-d984cadf4658');

--Medicine
INSERT INTO MEDICINE(Medicine_Code, Name, Price, Date_Of_Expiration, Quantity, Pharmacy_ID)
	VALUES
	('c1e37f61-455f-4b51-a43a-ea1d20619a1f', 'Amoxicillin', '$4.00', '20200927', 50, 'd4178aa7-c5ab-44d8-8770-ffdc3b3baa5e'),
	('f703936a-f725-4ba8-a031-8af9a6b30e05', 'Acetaminophen', '$0.90', '20250713', 1000, '3565cc04-0d42-46d8-b7ec-1fb1ca20703a'),
	('e97749f2-ceb2-4cd7-82c3-2fac36379d0b', 'Daklinza', '$49400.00', '20220404', 10, '68ead9e2-4a70-4202-903c-43104e2a2e65'),
	('0406448d-3e0d-41d0-b49d-ec8500a9cdb8', 'Etoposide', '$35.00', '20220101', 100, '68ead9e2-4a70-4202-903c-43104e2a2e65'),
	('303ada46-46eb-459b-8420-d6775ecfcac3', 'Micafungin', '$300.00', '20220101', 99, '3565cc04-0d42-46d8-b7ec-1fb1ca20703a'),
	('ff77113c-4c92-4762-be62-0e83b433c8cc', 'AmBisome', '$267.00', '20220101', 12, '3565cc04-0d42-46d8-b7ec-1fb1ca20703a'),
	('b310da15-bceb-4cde-9a34-3dcfa9a00eaf', 'Diphenhydramine', '$22.00', '20220101', 365, 'e4178aa7-c5ab-44d8-8770-ffdc3b3baa5e');

--Treatment
INSERT INTO TREATMENT(Treatment_ID, Name, Duration)
	VALUES
	('09610573-ec8b-40a6-8698-f40479b040dc', 'Painkillers', 72),
	('86f9d393-ae87-4247-9cd3-40d1197b2f51', 'Antibiotics', 168);

--Assigned
INSERT INTO ASSIGNED(Class2_Patient_ID, Medicine_Code, Treatment_ID)
	VALUES
	('P101', 'c1e37f61-455f-4b51-a43a-ea1d20619a1f', '86f9d393-ae87-4247-9cd3-40d1197b2f51'),
	('P111', 'c1e37f61-455f-4b51-a43a-ea1d20619a1f', '86f9d393-ae87-4247-9cd3-40d1197b2f51'),
	('P128', 'f703936a-f725-4ba8-a031-8af9a6b30e05', '09610573-ec8b-40a6-8698-f40479b040dc');

--Phone Number
INSERT INTO PHONE_NUMBER(Person_ID, Number)
	VALUES
    ('P101', '972-867-5309'),
	('P102', '555-555-5555'),
	('P121', '800-555-3311');

--Record
INSERT INTO RECORD(Record_ID, Patient_ID, Date_Of_Visit, Description, Appointment, Receptionist_ID)
	VALUES
	('80fb52bb-6999-44cc-9489-dd13782a69a9', 'P100', '2017-06-10', 'Long description here', 'd46ad8e7-9895-4cde-a9f5-606fab789e83', 'P105'),
	('5434c983-90b0-4d88-93ae-f4f648fb9a86', 'P117', '2017-11-10', 'Feeling ill', 'f5cc3240-f034-487f-8420-eb91533565ab', 'P106'),
	('f3d0ff3f-3e9f-483b-bc13-a75a5810794a', 'P117', '2017-11-25', 'Dizzy spell at work', '73c5c18f-c8d1-485d-aa9d-263f91e70215', 'P106'),
	('9e7b9b93-ce2f-488b-bf5d-03cb410003ae', 'P111', '2017-07-08', 'First Visit', '20ee8a07-94b4-47d9-8420-5333c98fd361', 'P105'),
	('2c46cd58-941a-4a84-a20e-5b2b41dac8e4', 'P111', '2017-07-18', 'Second Visit', '2f1b746e-7dec-42fc-8632-6e9c1b185741', 'P105'),
	('0e2e0d47-972d-42e4-b675-f229e6edf675', 'P111', '2017-10-08', 'Third Visit', 'f67d418f-cf43-410c-ae36-3cdcefafcb1d', 'P106'),
	('a6628231-cff3-4c77-bf30-03dcba34fc4c', 'P111', '2018-11-27', 'Admitted as Class 2', 'e0aef839-8d12-412f-8edf-0d88b000dea6', 'P105'),
	('223442a3-9fb2-49e0-9d7c-1e7a26144b54', 'P121', '2016-03-18', 'First Visit', '368b8003-ef87-4285-9b5f-b7555d5d8785', 'P105'),
	('3c52e920-c96a-4ea9-888b-2a27855c155d', 'P121', '2018-08-09', 'Second Visit', '8d7dc9e4-8a14-4197-926d-ea8ab235b720', 'P105'),
	('075c5b02-ea32-4db3-adf2-68f7fc8eb4e6', 'P121', '2018-09-10', 'Third Visit', 'ceee1ee1-f8aa-40f6-a18b-311b4592fe48', 'P106'),
	('54b9c43a-fa1e-4b63-bc95-1fca426f32cd', 'P121', '2018-09-10', 'Fourth Visit', '1c131320-5652-43e7-9a64-97e25d9f1967', 'P106');

--Medical Bill Payment
INSERT INTO MEDICAL_BILL_PAYMENT(Payment_ID, Patient_ID, Receptionist_ID)
	VALUES
	('b9f17e90-c7e1-4eec-a3d0-d2c8f62d2b31', 'P100', 'P105'),
	('f69489f8-dfbe-4ff4-b63d-b446198066d6', 'P121', 'P105'),
	('8fa72d4c-2614-4bd5-b2bc-a4b5fe55c1c7', 'P112', 'P106'),
	('788d5594-9c99-4358-adbb-4139d2bc4c76', 'P114', 'P106'),
	('4499f15f-ffb4-4aa3-a603-50ed5dbfa17d', 'P117', 'P106');

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
	('8fa72d4c-2614-4bd5-b2bc-a4b5fe55c1c7', 'acb32635-a23d-48e5-aae7-7d6dd77589da', 1000, 1000),
	('788d5594-9c99-4358-adbb-4139d2bc4c76', 'acb32635-a23d-48e5-aae7-7d6dd77589da', 50, 50),
	('4499f15f-ffb4-4aa3-a603-50ed5dbfa17d', '2bfa19a9-c5ce-4815-865e-d4ee7e8ea63c', 1400, 6000);


GO
