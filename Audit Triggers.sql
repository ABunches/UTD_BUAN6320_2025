USE Contoso;
SELECT * FROM contoso.store;


CREATE TRIGGER Orders_set_random_updated_by
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
  DECLARE random_username VARCHAR(100);

  SELECT UserName
  INTO random_username
  FROM Users
  WHERE UserKey <> 1 #Admin
  ORDER BY RAND()
  LIMIT 1;

  SET NEW.UpdatedBy = random_username;
END;
