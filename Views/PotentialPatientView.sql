USE hospital ;
GO

CREATE VIEW PotentialPatient
AS  SELECT F_Name, M_Name, L_Name, Number AS Phone_number, 
		PERSON.Person_ID AS Person_ID
	FROM PERSON, CLASS1_PATIENT, PHONE_NUMBER
	WHERE PERSON.Person_ID=CLASS1_PATIENT.Person_ID AND
		  PERSON.Person_ID=PHONE_NUMBER.Person_ID
	GROUP BY CLASS1_PATIENT.Person_ID, F_Name, M_Name, L_Name, Number, PERSON.Person_ID
	HAVING Count(CLASS1_PATIENT.Person_ID) > 3;