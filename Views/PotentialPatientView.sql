USE hospital ;
GO

CREATE VIEW PotentialPatient
AS  SELECT F_Name, M_Name, L_Name, Number AS Phone_number, PERSON.Person_ID AS Person_ID
    FROM PERSON, CLASS1_PATIENT, PHONE_NUMBER, RECORD
    WHERE PERSON.Person_ID=CLASS1_PATIENT.Person_ID AND
          PERSON.Person_ID=PHONE_NUMBER.Person_ID AND
          PERSON.Person_ID=RECORD.Patient_ID AND
          PERSON.Person_ID NOT IN (
                SELECT Person_ID
                FROM CLASS2_PATIENT
          )
    GROUP BY F_Name, M_Name, L_Name, Number, PERSON.Person_ID
    HAVING COUNT(Record_ID) > 3;
