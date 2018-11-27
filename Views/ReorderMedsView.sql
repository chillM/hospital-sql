USE hospital ;
GO

CREATE VIEW ReorderMeds
AS  SELECT *
	FROM MEDICINE
	WHERE Quantity < 1000 AND 
	DATEADD(month, 1, GETDATE())<Date_Of_Expiration;