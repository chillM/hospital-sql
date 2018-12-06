Use hospital;
--1
(SELECT Doctor_Type, Start_Date, Specialization FROM EMPLOYEE WHERE Doctor_Type='Trainee') UNION (SELECT Doctor_Type, Start_Date, Specialization FROM EMPLOYEE WHERE Doctor_Type='Visiting') UNION (SELECT Doctor_Type, Start_Date, Specialization FROM EMPLOYEE WHERE Doctor_Type='Permanent');

--WORKS

--2
SELECT F_Name, M_Name, L_Name FROM PERSON, EMPLOYEE, CLASS2_PATIENT WHERE PERSON.Person_ID=EMPLOYEE.Person_ID AND PERSON.Person_ID=CLASS2_PATIENT.Person_ID AND Admission_Date BETWEEN Start_Date AND (SELECT DATEADD(month, 3, Start_Date));
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
SELECT M.Name FROM TopTreatment, TREATMENT, MEDICINE AS M, ASSIGNED WHERE TopTreatment.Name=Treatment.Name AND ASSIGNED.Medicine_Code=M.Medicine_Code AND ASSIGNED.Treatment_ID=TREATMENT.Treatment_ID;
--WORKS

--5
SELECT F_Name, M_Name, L_Name FROM EMPLOYEE, PERSON WHERE Doctor_Type IS NOT NULL AND PERSON.Person_ID=EMPLOYEE.Person_ID AND EMPLOYEE.Person_ID NOT IN (SELECT ATTENDS.Doctor_ID FROM CLASS1_PATIENT, ATTENDS, RECORD WHERE CLASS1_PATIENT.Doctor_ID=ATTENDS.Doctor_ID AND Date_Of_Visit > (SELECT DATEADD(month, -5, (SELECT GETDATE() ) ) ) );
--WORKS


--6
SELECT COUNT(Patient_ID) as NumPatients, Provider
FROM INSURANCE, INSURANCE_PROVIDER, MEDICAL_BILL_PAYMENT
WHERE MEDICAL_BILL_PAYMENT.Payment_ID = Insurance.Payment_ID
	AND Insurance.Payment_ID NOT IN (
		SELECT Payment_ID from CASH
	)
GROUP BY Provider
--WORKS


--7
SELECT Duration
FROM (
	SELECT TOP(1) Room_ID, DATEDIFF(day, Admission_Date, Discharge_Date) as Duration
	FROM CLASS2_Patient
	GROUP BY Room_ID, Admission_Date, Discharge_Date
	HAVING DATEDIFF(day, Admission_Date, Discharge_Date)=MAX(DATEDIFF(day, Admission_Date, Discharge_Date))
	ORDER BY Duration DESC
) as Temp
--WORKS

--8
SELECT TOP(1) DATEPART(year, Date_Of_Visit) AS year, Description
FROM (
	SELECT Date_Of_Visit, Description, COUNT(*) as Cnt
	FROM RECORD
	GROUP BY Date_Of_Visit, Description
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
SELECT COUNT(Admission_Date) 
FROM CLASS2_PATIENT
WHERE DATEDIFF(day, Admission_Date, GETDATE())>(SELECT TOP 1 DATEDIFF(day, Start_Date, GETDATE()) FROM EMPLOYEE )
GROUP BY CLASS2_PATIENT.Person_ID;
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

GO



