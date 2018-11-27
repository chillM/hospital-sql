USE hospital

CREATE VIEW TopTreatment
AS  SELECT Name, Price
	FROM ASSIGNED, TREATMENT, MEDICINE
	WHERE TREATMENT.Treatment_ID=ASSIGNED.Treatment_ID AND
		  ASSIGNED.Medicine_Code=MEDICINE.Medicine_Code
	GROUP BY Treatment_ID
	ORDER BY COUNT(Treatment_ID) DESC
	LIMIT 1;