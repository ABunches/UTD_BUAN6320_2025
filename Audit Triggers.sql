USE Contoso;

DELIMITER //
CREATE TRIGGER currencyexchange_set_random_updated_by
BEFORE UPDATE ON contoso.currencyexchange
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
// DELIMITER ;


CREATE TRIGGER customer_set_random_updated_by
BEFORE UPDATE ON contoso.customer
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


CREATE TRIGGER geoarea_set_random_updated_by
BEFORE UPDATE ON contoso.geoarea
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


CREATE TRIGGER orderrows_set_random_updated_by
BEFORE UPDATE ON contoso.orderrows
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


CREATE TRIGGER orders_set_random_updated_by
BEFORE UPDATE ON contoso.orders
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


CREATE TRIGGER product_set_random_updated_by
BEFORE UPDATE ON contoso.product
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


CREATE TRIGGER productcategory_set_random_updated_by
BEFORE UPDATE ON contoso.productcategory
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


CREATE TRIGGER sales_set_random_updated_by
BEFORE UPDATE ON contoso.sales
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

CREATE TRIGGER store_set_random_updated_by
BEFORE UPDATE ON contoso.store
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

CREATE TRIGGER users_set_random_updated_by
BEFORE UPDATE ON contoso.users
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

