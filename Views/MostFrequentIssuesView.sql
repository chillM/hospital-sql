USE hospital ;
GO

CREATE VIEW MostFrequentIssues
AS  SELECT T.Treatment_ID, Name, COUNT(T.Treatment_ID) AS Frequency
	FROM ASSIGNED, TREATMENT T
	WHERE T.Treatment_ID=ASSIGNED.Treatment_ID
	GROUP BY T.Treatment_ID
	ORDER BY COUNT(T.Treatment_ID) DESC;