
SET GLOBAL innodb_buffer_pool_size = 10737418240;  -- 10 GB for pooling assuming 16 GB RAM Free
SET GLOBAL wait_timeout = 2400; 
SET GLOBAL interactive_timeout = 2400;
SET GLOBAL net_read_timeout = 2400;
SET GLOBAL net_write_timeout = 2400;
SET GLOBAL wait_timeout = 2400;


USE Contoso;

# Derive new tables!  ###########################################################################################################################

    ## Users
    DROP TABLE IF EXISTS Contoso.users;
    CREATE TABLE IF NOT EXISTS contoso.Users (
        UserKey INT NOT NULL AUTO_INCREMENT
        ,UserName VARCHAR(100) NOT NULL UNIQUE
        ,FirstName VARCHAR(255)NOT NULL
        ,LastName VARCHAR(255) NOT NULL
        ,UpdatedBy VARCHAR(255)
        ,UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ,CreatedBy VARCHAR(255)
        ,CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
        ,PRIMARY KEY (UserKey)
    );

    INSERT INTO Users 	(UserName				,FirstName	,LastName	,UpdatedBy	,UpdatedDate		,CreatedBy	,CreatedDate)
            VALUES		("Admin@LocalHost"		,"Service"	,"Account"	,"Admin"	,current_timestamp	,"Admin"	,"2024-06-01 09:15:00"),
                        ("Sudo@LocalHost"		,"Alex"		,"Bunch"	,"Admin"	,current_timestamp	,"Admin"	,"2024-06-01 09:15:01"),
                        ("jdoe@LocalHost"		,"John"		,"Doe"		,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-01 09:15:00"),
                        ("asmith@LocalHost"		,"Anna"		,"Smith"	,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-02 14:22:00"),
                        ("bchan@LocalHost"		,"Brian"	,"Chan"		,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-03 08:30:00"),
                        ("mgarcia@LocalHost"	,"Maria"	,"Garcia"	,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-04 10:45:00"),
                        ("kwilson@LocalHost"	,"Kevin"	,"Wilson"	,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-05 13:00:00"),
                        ("lpatel@LocalHost"		,"Leena"	,"Patel"	,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-06 16:10:00"),
                        ("tjohnson@LocalHost"	,"Tom"		,"Johnson"	,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-07 11:30:00"),
                        ("ycho@LocalHost"		,"Yuna"		,"Cho"		,"Sudo"		,current_timestamp	,"Sudo"		,"2024-06-08 15:20:00");
            
            
    ## SchemaChangeLog
    DROP TABLE IF EXISTS contoso.SchemaChangeLog;
        CREATE TABLE IF NOT EXISTS contoso.SchemaChangeLog (
        SchemaChangeLogKey INT NOT NULL AUTO_INCREMENT
        ,SchemaName VARCHAR(128) NOT NULL
        ,TableName VARCHAR(128) NOT NULL
        ,ExecutedSQL TEXT NOT NULL
        ,ExecutedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        ,ExecutedBy VARCHAR(255)
        ,PRIMARY KEY (SchemaChangeLogKey)
    );            


    ## GeoArea
    DROP TABLE IF EXISTS contoso.GeoArea;
    CREATE TABLE IF NOT EXISTS contoso.GeoArea (
        GeoAreaKey INT NOT NULL
        , State VARCHAR(255)
        , StateFull VARCHAR(255)
        , Country VARCHAR(255)
        , CountryFull VARCHAR(255)
    );
    INSERT INTO contoso.GeoArea ( GeoAreaKey, State, StateFull, Country, CountryFull)
        -- Trim functions due to bad record
        SELECT DISTINCT 
            GeoAreaKey
            ,TRIM(State) 'State'
            ,TRIM(StateFull) 'StateFull'
            ,TRIM(Country) 'Country'
            ,TRIM(CountryFull) 'CountryFull'
            
        FROM contoso.customer

        ORDER BY
            GeoAreaKey ASC
            ,StateFull ASC;
        
        
    ## ProductCategorySubCategory
    DROP TABLE IF EXISTS contoso.ProductCategorySubCategory;
    CREATE TABLE ProductCategory (
        ProductCategoryKey INT NOT NULL AUTO_INCREMENT
        ,CategoryKey INT NOT NULL
        ,CategoryName VARCHAR(255)
        ,SubCategoryKey INT NOT NULL
        ,SubCategoryName VARCHAR(255)
        ,UpdatedBy VARCHAR(255)
        ,UpdatedDate DATETIME
        ,CreatedBy VARCHAR(255)
        ,CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
        ,PRIMARY KEY (ProductCategoryKey)
    );
    INSERT INTO contoso.ProductCategory (CategoryKey,CategoryName,SubCategoryKey,SubCategoryName,UpdatedBy,CreatedBy)
    SELECT DISTINCT
        TRIM(CategoryKey) 'CategoryKey'
        ,TRIM(CategoryName) 'CategoryName'
        ,TRIM(SubCategoryKey) 'SubCategoryKey'
        ,TRIM(SubCategoryName)'SubCategoryName'
        ,NULL as 'UpdatedBy'
        ,CURRENT_USER() as 'CreatedBy'

    FROM contoso.product

    ORDER BY 
        CategoryKey ASC;


# Table Modifications ###########################################################################################################################
    DELIMITER //
        ALTER TABLE contoso.currencyexchange
        ADD CONSTRAINT unique_date_from_to UNIQUE (Date, FromCurrency, ToCurrency);

        ALTER TABLE contoso.currencyexchange 
        ADD COLUMN currencyexchangeKey INT FIRST;

        ALTER TABLE contoso.customer
        ADD PRIMARY KEY (CustomerKey);

        ALTER TABLE contoso.date
        ADD PRIMARY KEY (DateKey);

        ALTER TABLE contoso.orderrows 
        ADD COLUMN OrderRowsKey INT FIRST;

        ALTER TABLE contoso.orderrows
        ADD CONSTRAINT unique_orderkey_linenumber UNIQUE (OrderKey, Linenumber);

        ALTER TABLE contoso.orders
        ADD PRIMARY KEY (OrderKey);	

        ALTER TABLE contoso.Product
        ADD PRIMARY KEY (ProductKey);

        ALTER TABLE contoso.sales 
        ADD COLUMN SalesKey INT FIRST;

        ALTER TABLE contoso.Sales
        ADD CONSTRAINT unique_orderkey_linenumber UNIQUE (OrderKey, Linenumber);

        ALTER TABLE contoso.store
        ADD PRIMARY KEY (StoreKey);

        ALTER TABLE contoso.GeoArea 
        ADD PRIMARY KEY(GeoAreaKey);        

        ALTER TABLE contoso.GeoArea 
        MODIFY COLUMN GeoAreaKey INT NOT NULL AUTO_INCREMENT; 

    DELIMITER // ; 


# Add indexes to the tables ###########################################################################################################################
    DELIMITER //
        ALTER TABLE contoso.currencyexchange
        ADD INDEX idx_FromCurrency (FromCurrency);

        ALTER TABLE contoso.currencyexchange
        ADD INDEX idx_ToCurrency (ToCurrency);

        ALTER TABLE contoso.customer
        ADD INDEX idx_CustomerKey_GeoAreaKey (GeoAreaKey,CustomerKey);

        ALTER TABLE contoso.customer
        ADD INDEX idx_GivenName (GivenName);

        ALTER TABLE contoso.customer
        ADD INDEX idx_Surname (Surname);

        ALTER TABLE contoso.customer
        ADD INDEX idx_Surname (Occupation);

        ALTER TABLE contoso.date
        ADD INDEX idx_Date (Date);

        ALTER TABLE contoso.Product
        ADD INDEX idx_ProductCode (ProductCode);

        ALTER TABLE contoso.ProductCategory 
        ADD INDEX idx_ProductCategory(CategoryKey);

        ALTER TABLE contoso.ProductCategory 
        ADD INDEX idx_SubCategoryKey(SubCategoryKey);

        ALTER TABLE contoso.ProductCategory 
        ADD INDEX idx_CategoryName(CategoryName);

        ALTER TABLE contoso.ProductCategory 
        ADD INDEX idx_SubCategoryName(SubCategoryName);

    // DELIMITER ;


# Update Keys.  ###########################################################################################################################
    DELIMITER //
        SET @rownum = 0;
        UPDATE contoso.Sales SET SalesKey = (@rownum := @rownum + 1);

        SET @rownum = 0;
        UPDATE contoso.orderrows SET OrderRowsKey = (@rownum := @rownum + 1);

        SET @rownum = 0;
        UPDATE contoso.currencyexchange SET CurrencyExchangeKey = (@rownum := @rownum + 1);
    // DELIMITER ;


# Update Columns as Primary Keys ########################################################################################################################### 
    DELIMITER //
        ALTER TABLE contoso.sales 
        MODIFY COLUMN SalesKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
        ALTER TABLE contoso.orderrows 
        MODIFY COLUMN OrderRowsKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
        ALTER TABLE contoso.currencyexchange 
        MODIFY COLUMN CurrencyExchangeKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
    DELIMITER // ;


# Create Foreign Keys ###########################################################################################################################
    DELIMITER //
        ALTER TABLE contoso.customer
        ADD CONSTRAINT fk_customer_geoarea
        FOREIGN KEY (GeoAreaKey)
        REFERENCES GeoArea(GeoAreaKey);

        ALTER TABLE contoso.orderrows
        ADD CONSTRAINT fk_orderrows_orders
        FOREIGN KEY (orderkey)
        REFERENCES orders(orderkey);
        
        ALTER TABLE contoso.orderrows
        ADD CONSTRAINT fk_orderrows_product
        FOREIGN KEY (ProductKey)
        REFERENCES Product(ProductKey);
        
        ALTER TABLE contoso.orders
        ADD CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerKey)
        REFERENCES Customer(CustomerKey);

        ALTER TABLE contoso.orders
        ADD CONSTRAINT fk_orders_store
        FOREIGN KEY (StoreKey)
        REFERENCES store(StoreKey);
            
        ALTER TABLE contoso.sales
        ADD CONSTRAINT fk_sales_orders
        FOREIGN KEY (OrderKey)
        REFERENCES Orders(OrderKey);
        
        ALTER TABLE contoso.sales
        ADD CONSTRAINT fk_sales_customer
        FOREIGN KEY (CustomerKey)
        REFERENCES Customer(CustomerKey);
        
        ALTER TABLE contoso.sales
        ADD CONSTRAINT fk_sales_store
        FOREIGN KEY (StoreKey)
        REFERENCES Store(StoreKey);
        
        ALTER TABLE contoso.sales
        ADD CONSTRAINT fk_sales_product
        FOREIGN KEY (productkey)
        REFERENCES product(productkey);
    // DELIMITER ;        


# Create Functions ###########################################################################################################################
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
        -- create random tracking number
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



# Create procedures ###########################################################################################################################
    DELIMITER //  
    -- Schema log entry 
        DROP PROCEDURE IF EXISTS contoso.LogSchemaChange;         
        CREATE PROCEDURE contoso.LogSchemaChange (
            IN SchemaName VARCHAR(128),
            IN TableName VARCHAR(128),
            IN ExecutedSQL TEXT,
            IN ExecutedBy VARCHAR(50)
        )
        BEGIN
            INSERT INTO SchemaChangeLog (SchemaName, TableName, ExecutedSQL,ExecutedBy)
            VALUES (SchemaName, TableName, ExecutedSQL,ExecutedBy);
        END;
    // DELIMITER ;

    DELIMITER //  
    -- add audit column to all tables 
        DROP PROCEDURE IF EXISTS contoso.AddMissingAuditColumns;
        CREATE PROCEDURE contoso.AddMissingAuditColumns(IN target_schema VARCHAR(64))
        BEGIN
            DECLARE done INT DEFAULT 0;
            DECLARE tbl_name VARCHAR(64);
            DECLARE alter_sql TEXT;
            DECLARE cursor_tables CURSOR FOR
                SELECT TABLE_NAME
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = target_schema
                AND TABLE_TYPE = 'BASE TABLE'
                AND TABLE_NAME <> 'schemachangelog';
                

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

            OPEN cursor_tables;

            table_loop: LOOP
                FETCH cursor_tables INTO tbl_name;
                IF done THEN
                    LEAVE table_loop;
                END IF;

                SET @sql_parts := '';

                -- Add CreatedBy
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = target_schema 
                    AND TABLE_NAME = tbl_name 
                    AND COLUMN_NAME = 'CreatedBy'
                ) THEN
                    SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN CreatedBy VARCHAR(255)');
                END IF;

                -- Add CreatedDate
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = target_schema 
                    AND TABLE_NAME = tbl_name 
                    AND COLUMN_NAME = 'CreatedDate'
                ) THEN
                    SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP');
                END IF;

                -- Add UpdatedBy
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = target_schema 
                    AND TABLE_NAME = tbl_name 
                    AND COLUMN_NAME = 'UpdatedBy'
                ) THEN
                    SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN UpdatedBy VARCHAR(255)');
                END IF;

                -- Add UpdatedDate
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = target_schema 
                    AND TABLE_NAME = tbl_name 
                    AND COLUMN_NAME = 'UpdatedDate'
                ) THEN
                    SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN UpdatedDate DATETIME');
                END IF;

                -- Execute ALTER TABLE if needed
                IF LENGTH(@sql_parts) > 0 THEN
                    SET @alter_stmt := CONCAT('ALTER TABLE `', target_schema, '`.`', tbl_name, '`', 
                                            SUBSTRING(@sql_parts, 2), ';');
                    PREPARE stmt FROM @alter_stmt;
                    EXECUTE stmt;
                    DEALLOCATE PREPARE stmt;

                    -- Log the executed SQL
                    CALL LogSchemaChange(target_schema, tbl_name, @alter_stmt, CURRENT_USER());
                END IF;

            END LOOP;

            CLOSE cursor_tables;
        END;
    // DELIMITER ;

    DELIMITER //
        -- generate user info for all tables
        DROP PROCEDURE IF EXISTS UpdateAuditFields;
        CREATE PROCEDURE contoso.UpdateAuditFields(IN target_schema VARCHAR(255))
        BEGIN
            DECLARE done INT DEFAULT 0;
            DECLARE tablename VARCHAR(255);
            DECLARE colname VARCHAR(64);
            DECLARE sql_stmt TEXT;

            DECLARE cur CURSOR FOR
                SELECT TABLE_NAME, COLUMN_NAME
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = target_schema
                AND COLUMN_NAME = 'CreatedBy'
                AND TABLE_NAME NOT IN ('users', 'schemachangelog');

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 0;

            OPEN cur;

            read_loop: LOOP
                FETCH cur INTO tablename, colname;
                IF done THEN
                    LEAVE read_loop;
                END IF;

                SET @sql_stmt = CONCAT(
                    'UPDATE `', target_schema, '`.`', tablename, '` ',
                    'SET `', colname, '` = RandomUser() ',
                    'WHERE `', colname, '` IS NULL'
                );

                PREPARE stmt FROM @sql_stmt;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END LOOP;

            CLOSE cur;
        END
    // DELIMITER ;


# Run AddMissingAuditColumns ###########################################################################################################################
    DELIMITER //
        CALL contoso.AddMissingAuditColumns('contoso'); 
    // DELIMITER ;


# Add triggers to set CreatedBy, CreatedDate, UpdatedBy, UpdatedDate fields #######################################################################
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

    DELIMITER //
        CREATE TRIGGER date_set_random_updated_by
        BEFORE UPDATE ON contoso.date
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP
        END;
    DELIMITER // ; 

 
    DELIMITER //
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
        SET NEW.UpdatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

 
    DELIMITER //
        CREATE TRIGGER currencyexchange_set_random_created_by
        BEFORE INSERT ON contoso.currencyexchange
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

 
    DELIMITER //
        CREATE TRIGGER customer_set_random_created_by
        BEFORE INSERT ON contoso.customer
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

    DELIMITER //
        CREATE TRIGGER date_set_random_created_by
        BEFORE INSERT ON contoso.date
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 
 
    DELIMITER //
        CREATE TRIGGER geoarea_set_random_created_by
        BEFORE INSERT ON contoso.geoarea
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

 
    DELIMITER //
        CREATE TRIGGER orderrows_set_random_created_by
        BEFORE INSERT ON contoso.orderrows
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

 
    DELIMITER //

        CREATE TRIGGER orders_set_random_created_by
        BEFORE INSERT ON contoso.orders
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 


    DELIMITER //
        CREATE TRIGGER product_set_random_created_by
        BEFORE INSERT ON contoso.product
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ; 

    DELIMITER //
        CREATE TRIGGER productcategory_set_random_created_by
        BEFORE INSERT ON contoso.productcategory
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ;


    DELIMITER //
        CREATE TRIGGER sales_set_random_created_by
        BEFORE INSERT ON contoso.sales
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ;

    DELIMITER //
        CREATE TRIGGER store_set_random_created_by
        BEFORE INSERT ON contoso.store
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    DELIMITER // ;

    DELIMITER //
        CREATE TRIGGER users_set_random_created_by
        BEFORE INSERT ON contoso.users
        FOR EACH ROW
        BEGIN
            DECLARE random_username VARCHAR(100);

            SELECT UserName
            INTO random_username
            FROM Users
            WHERE UserKey <> 1 #Admin
            ORDER BY RAND()
            LIMIT 1;

            SET NEW.CreatedBy = random_username;
            SET NEW.CreatedDate = CURRENT_TIMESTAMP;
        END;
    // DELIMITER ;


# Run UpdateAuditFields ###########################################################################################################################
    DELIMITER //
    CALL contoso.UpdateAuditFields('contoso');
     // DELIMITER ;