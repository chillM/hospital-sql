Use hospital;

--1
SELECT Doctor_Type, Start_Date, Specialization FROM EMPLOYEE WHERE Doctor_Type IS NOT NULL GROUP BY Doctor_Type, Start_Date, Specialization;

--WORKS

--2
SELECT F_Name, M_Name, L_Name FROM PERSON, EMPLOYEE, CLASS2_PATIENT WHERE PERSON.Person_ID=EMPLOYEE.Person_ID AND EMPLOYEE.Person_ID=CLASS2_PATIENT.Person_ID AND DATEDIFF(month, EMPLOYEE.Start_Date, CLASS2_PATIENT.Admission_Date) < 3;
--WORKS


--3
WITH Top5 AS
(
	SELECT TOP(5) DATEDIFF(year, Birth_Date, GETDATE()) as Age, Person.Person_ID, Doctor_Type
	FROM PERSON, EMPLOYEE
	WHERE Person.Person_ID = EMPLOYEE.Person_ID
		AND Doctor_Type IS NOT NULL
	GROUP BY EMPLOYEE.Person_ID, PERSON.Birth_Date, PERSON.Person_ID, Doctor_Type
	HAVING
    	  5<ALL (SELECT COUNT(Doctor_ID) FROM CLASS1_PATIENT WHERE Doctor_ID=EMPLOYEE.Person_ID) AND
    	  10<ALL (SELECT COUNT(Doctor_ID) FROM ATTENDS WHERE Doctor_ID=EMPLOYEE.Person_ID)
	ORDER BY Person.Person_ID ASC

)
SELECT DISTINCT Doctor_Type, AverageAge.Age
FROM Top5
CROSS JOIN (
	SELECT AVG(Age) as Age
	FROM Top5
) as AverageAge
WHERE Doctor_Type in (
	SELECT TOP(1) Doctor_Type
	FROM Top5
	GROUP BY Doctor_Type
	ORDER BY COUNT(Doctor_Type) DESC
)

--4
SELECT MEDICINE.Name FROM TopTreatment, TREATMENT, MEDICINE, ASSIGNED WHERE TopTreatment.Name=TREATMENT.Name AND ASSIGNED.Medicine_Code=MEDICINE.Medicine_Code AND ASSIGNED.Treatment_ID=TREATMENT.Treatment_ID;
--WORKS

--5
--Find all the doctors who have not had a patient in the last 5 months. (Hint:
--Consider the date of payment as the day the doctor has attended a patient/been
--consulted by a patient.
SELECT F_Name, M_Name, L_Name 
FROM EMPLOYEE, PERSON 
WHERE Doctor_Type IS NOT NULL AND 
	  PERSON.Person_ID=EMPLOYEE.Person_ID AND 
	  EMPLOYEE.Person_ID NOT IN (
			SELECT ATTENDS.Doctor_ID 
			FROM CLASS1_PATIENT, ATTENDS, RECORD 
			WHERE CLASS1_PATIENT.Doctor_ID=ATTENDS.Doctor_ID AND 
			Date_Of_Visit > DATEADD( month, -5, ( GETDATE() ) )
	  );

--6
--Find the total number of patients who have paid completely using insurance 
--and the name of the insurance provider.
SELECT COUNT(Patient_ID) as Number_Of_Patients, Provider
FROM INSURANCE, INSURANCE_PROVIDER, MEDICAL_BILL_PAYMENT
WHERE MEDICAL_BILL_PAYMENT.Payment_ID = INSURANCE.Payment_ID
	AND INSURANCE.Insurance_ID=INSURANCE_PROVIDER.Insurance_ID
	AND NOT EXISTS (
		SELECT * FROM CASH WHERE MEDICAL_BILL_PAYMENT.Payment_ID=Payment_ID
	)
GROUP BY Provider;


--7
--Find the most occupied room in the hospital and the duration of the stay.
SELECT Room_ID AS Most_Occupied_Room, Duration AS Duration_Of_Stay_In_Days
FROM (
	SELECT TOP(1) Room_ID, DATEDIFF(day, Admission_Date, Discharge_Date) as Duration
	FROM CLASS2_Patient
	GROUP BY Room_ID, Admission_Date, Discharge_Date
	HAVING DATEDIFF(day, Admission_Date, Discharge_Date)=MAX(DATEDIFF(day, Admission_Date, Discharge_Date))
	ORDER BY Duration DESC
) as Temp


--8
SELECT TOP(1) year, Description, Cnt
FROM (
	SELECT DATEPART(year, Date_Of_Visit) as year, Description, COUNT(*) as Cnt
	FROM RECORD
	GROUP BY DATEPART(year, Date_Of_Visit), Description
) as Tmp
ORDER BY Cnt DESC
--WORKS


--9
SELECT TOP 1 Duration 
FROM TREATMENT, ASSIGNED
WHERE TREATMENT.Treatment_ID=ASSIGNED.Treatment_ID
GROUP BY TREATMENT.Treatment_ID, TREATMENT.Duration
ORDER BY Count(TREATMENT.Treatment_ID)
--WORKS


--10
SELECT COUNT(Admission_Date) as Num_Patients
FROM CLASS2_PATIENT
WHERE DATEDIFF(day, Admission_Date, GETDATE()) < (SELECT TOP 1 DATEDIFF(day, Start_Date, GETDATE()) FROM EMPLOYEE ORDER BY DATEDIFF(day, Start_Date, GETDATE()) ASC);
--WORKS


--11 - Final (correct output)
SELECT RECORD.*
FROM RECORD
WHERE Patient_ID IN (
	SELECT CLASS2_PATIENT.Person_ID
	FROM CLASS2_PATIENT, RECORD
	WHERE Admission_Date BETWEEN Date_Of_Visit AND DATEADD(day, 7, Date_Of_Visit)
		AND Person_ID = Patient_ID
)


--12 - Final (correct output)
SELECT DATEPART(month, Date_Of_Visit) as Month, SUM(CASH.Amount) as Total_Paid
FROM RECORD, MEDICAL_BILL_PAYMENT, CASH
WHERE DATEPART(year, Date_Of_Visit)=2017
	AND RECORD.Payment_ID=MEDICAL_BILL_PAYMENT.Payment_ID
	AND MEDICAL_BILL_PAYMENT.Payment_ID=CASH.Payment_ID
GROUP BY DATEPART(month, Date_Of_Visit);


--13 - Final (correct output)
SELECT F_Name, M_Name, L_Name
FROM PERSON
WHERE Person_ID IN (
	SELECT Doctor_ID
	FROM CLASS1_PATIENT, RECORD
	WHERE Person_ID=Patient_ID
		AND Person_ID NOT IN (
			SELECT Person_ID
			FROM CLASS2_PATIENT
		)
	GROUP BY Patient_ID, Doctor_ID
	HAVING COUNT(*) = 1
);

--14 - Final (correct output)
SELECT F_Name, M_Name, L_Name, DATEDIFF(year, Birth_Date, GETDATE()) as Age
FROM PERSON per
WHERE Person_ID IN (
	SELECT Person_ID
	FROM PotentialPatient
);


