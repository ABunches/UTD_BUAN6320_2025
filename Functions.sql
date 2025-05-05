USE contoso;

DELIMITER //
-- return random date
CREATE FUNCTION RandomDate(start_date DATE, end_date DATE)
RETURNS DATE
DETERMINISTIC
BEGIN
    DECLARE diff INT;
    DECLARE dateout date;
    SET diff = DATEDIFF(end_date, start_date);
    SET dateout = DATE_ADD(start_date, INTERVAL FLOOR(RAND() * (diff + 1)) DAY);
    RETURN dateout;
END
// DELIMITER ;



DELIMITER //
-- return randomn user 
CREATE FUNCTION RandomUser()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE RandomName VARCHAR(50);
    SELECT UserName
    INTO RandomName
    FROM Users
    WHERE UserKey <> 1 -- Admin
    ORDER BY RAND()
    LIMIT 1;
    RETURN RandomName;
END
// DELIMITER ;


DELIMITER //
CREATE FUNCTION GenerateTrackingNumber()
RETURNS CHAR(13)
DETERMINISTIC
BEGIN
    DECLARE charset VARCHAR(36) DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    DECLARE result CHAR(13) DEFAULT '1Z';
    DECLARE X INT DEFAULT 1;
    
    WHILE X <= 11 DO
        SET result = CONCAT(result, SUBSTRING(charset, FLOOR(1 + RAND() * 36), 1));
        SET X = X + 1;
    END WHILE;

    RETURN result;
END
// DELIMITER ; 





-- func estimate delivery wh and time. 

