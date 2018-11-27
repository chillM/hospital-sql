SELECT Start_Date, Specialization FROM EMPLOYEE WHERE Doctor_Type IS NOT NULL;  
--WORKS

SELECT F_Name, M_Name, L_Name FROM PERSON, EMPLOYEE, CLASS2_PATIENT WHERE PERSON.Person_ID=EMPLOYEE.Person_ID AND PERSON.Person_ID=CLASS2_PATIENT.Person_ID AND Admission_Date BETWEEN Start_Date AND (SELECT DATEADD(month, 3, Start_Date));
--WORKS


(SELECT AVG(DATEDIFF(year, Birth_Date, GETDATE() ) ) 
FROM PERSON,EMPLOYEE 
WHERE PERSON.Person_ID=EMPLOYEE.Person_ID AND Person_ID=(SELECT Person_ID FROM CLASS1_PATIENT, CLASS2_PATIENT, EMPLOYEE, PERSON WHERE EMPLOYEE.Person_ID=PERSON.Person_ID AND 5<ALL (SELECT COUNT(Doctor_ID) FROM CLASS1_PATIENT WHERE Doctor_ID=EMPLOYEE.Person_ID) AND 10<ALL (SELECT COUNT(Doctor_ID) FROM CLASS2_PATIENT WHERE Doctor_ID=EMPLOYEE.Person_ID) ) )

UNION

(SELECT Doctor_Type FROM 
(SELECT Doctor_Type, COUNT(*) 
FROM EMPLOYEE WHERE Person_ID=(SELECT Person_ID FROM CLASS1_PATIENT, CLASS2_PATIENT, EMPLOYEE, PERSON WHERE EMPLOYEE.Person_ID=PERSON.Person_ID AND 5<ALL (SELECT COUNT(Doctor_ID) FROM CLASS1_PATIENT WHERE Doctor_ID=EMPLOYEE.Person_ID) AND 10<ALL (SELECT COUNT(Doctor_ID) FROM CLASS2_PATIENT WHERE Doctor_ID=EMPLOYEE.Person_ID) )  
GROUP BY Doctor_Type HAVING COUNT(*)=MAX(COUNT(*) ) );



SELECT M_Name FROM TopTreatment, TREATMENT, MEDICINE AS M(Medicine_Code, M_Name, Price, Date_Of_Expiration, Quantity, Pharmacy_ID), ASSIGNED WHERE TopTreatment.Name=Treatment.Name AND ASSIGNED.Medicine_Code=M.Medicine_Code AND ASSIGNED.Treatment_ID=TREATMENT.Treatment_ID;


SELECT F_Name, M_Name, L_Name FROM EMPLOYEE WHERE Doctor_Type IS NOT NULL AND Person_ID NOT IN (SELECT Doctor_ID FROM CLASS1_PATIENT, ATTENDS, RECORD WHERE Date_Of_Visit > (SELECT DATEADD(month, -5, (SELECT GETDATE() ) ) ) );


SELECT Provider, COUNT(*) FROM INSURANCE, INSURANCE_PROVIDER WHERE Amount=Coverage GROUP BY Provider;


SELECT Room_ID, DATEDIFF(day, Admission_Date, Discharge_Date) FROM CLASS2_Patient WHERE DATEDIFF(day, Admission_Date, Discharge_Date)=MAX(DATEDIFF(day, Admission_Date, Discharge_Date));


SELECT TOP 1 DATEPART(year, Date_Of_Visit) AS year, Description FROM RECORD WHERE year=(SELECT year FROM (SELECT DATEPART(year, Date_Of, Visit) AS year, COUNT(*) FROM RECORD GROUP BY year HAVING COUNT(*)=MAX(COUNT(*) ) ) ) AND Description=(SELECT Description FROM (SELECT Description, COUNT(*) FROM RECORD WHERE DATEPART(year, Date_Of_Visit)=year GROUP BY Description HAVING COUNT(*)=MAX(COUNT(*) ) ) );


SELECT Duration FROM (SELECT Name, Duration, COUNT(*) FROM ASSIGNED, TREATMENT GROUP BY Name HAVING COUNT(*)=MIN(COUNT(*) ) );


SELECT COUNT(Admission_Date>(SELECT MIN(DATEDIFF(day, Start_Date, GETDATE())) FROM EMPLOYEE )) FROM CLASS2_PATIENT;


SELECT * FROM CLASS2_PATIENT, ATTENDS, VISITOR AS V(Visitor_ID, Person_ID, V_NAME, Address, Contact_Information, Room_ID), MEDICINE AS M(Medicine_Code, M_Name, Price, Date_Of_Expiration, Quantity, Pharmacy_ID), TREATMENT AS T(T_Name, Duration), ASSIGNED, PHONE_NUMBER, RECORD WHERE Class2_Patient_ID=Patient_ID AND CLASS2_PATIENT.Person_ID=Patient_ID AND V.Person_ID=Patient_ID AND PHONE_NUMBER.Person_ID=Patient_ID AND Admission_Date BETWEEN Date_Of_Visit AND DATEADD(day, 7, Date_Of_Visit);



SELECT DATEPART(month, Date_Of_Visit), SUM(Amount) FROM RECORD, MEDICAL_BILL_PAYMENT, CASH, INSURANCE WHERE DATEPART(year, Date_Of_Visit)=2017 GROUP BY DATEPART(month, Date_Of, Visit);


SELECT F_Name, M_Name, L_Name FROM PERSON WHERE Person_ID IN (SELECT Doctor_ID FROM (SELECT Patient_ID, Doctor_ID, COUNT(*) FROM CLASS1_PATIENT, RECORD WHERE Person_ID=Patient_ID GROUP BY Patient_ID HAVING COUNT(*) = 1) );


SELECT F_Name, M_Name, L_Name, DATEDIFF(year, Birth_Date, GETDATE()) FROM POTENTIAL_PATIENT, PERSON WHERE Patient_ID=Person_ID;






