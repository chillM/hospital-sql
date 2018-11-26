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
   PRIMARY KEY (Visitor_ID),
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
   Duration DATETIMEOFFSET NOT NULL,
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
INSERT INTO PERSON(Person_ID, F_Name, M_Name, L_Name, Address, Gender, Birth_Date)  
   VALUES ('P001', 'Mungo', 'B', 'Jerry', '5454 XYZ Drive', 1, '1955-05-05') 


   
 

GO
