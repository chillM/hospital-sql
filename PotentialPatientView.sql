USE hospital

CREATE VIEW PotentialPatient
AS  SELECT F_Name, M_Name, L_Name, Phone_Number, 
		PERSON.Person_ID AS Person_ID
	FROM PERSON, CLASS1_PATIENT
	WHERE PERSON.Person_ID=CLASS1_PATIENT.Person_ID
	GROUP BY CLASS1_PATIENT.Person_ID
	HAVING Count(CLASS1_PATIENT.Person_ID) > 3;