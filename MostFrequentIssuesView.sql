USE hospital

CREATE VIEW MostFrequentIssues
AS  SELECT Treatment_ID, Name, COUNT(Treatment_ID) AS Frequency
	FROM ASSIGNED, TREATMENT
	WHERE TREATMENT.Treatment_ID=ASSIGNED.Treatment_ID
	GROUP BY Treatment_ID
	ORDER BY COUNT(Treatment_ID) DESC;