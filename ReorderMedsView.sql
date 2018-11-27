USE hospital

CREATE VIEW ReorderMeds
AS  SELECT *
	FROM MEDICINE
	WHERE Quantity < 1000 AND 
	DATE_ADD(CURDATE(), INTERVAL 31 DAY)<Date_Of_Expiration;