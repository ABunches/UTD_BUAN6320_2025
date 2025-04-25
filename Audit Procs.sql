DELIMITER //
CREATE PROCEDURE AddMissingAuditColumns(IN target_schema VARCHAR(64))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tbl_name VARCHAR(64);
    DECLARE alter_sql TEXT;
    DECLARE cursor_tables CURSOR FOR
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = target_schema
          AND TABLE_TYPE = 'BASE TABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_tables;

    table_loop: LOOP
        FETCH cursor_tables INTO tbl_name;
        IF done THEN
            LEAVE table_loop;
        END IF;

        SET @sql_parts := '';

        -- CreatedBy
        IF NOT EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = target_schema 
              AND TABLE_NAME = tbl_name 
              AND COLUMN_NAME = 'CreatedBy'
        ) THEN
            SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN CreatedBy VARCHAR(255) NOT NULL');
        END IF;

        -- CreatedDate
        IF NOT EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = target_schema 
              AND TABLE_NAME = tbl_name 
              AND COLUMN_NAME = 'CreatedDate'
        ) THEN
            SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP');
        END IF;

        -- UpdatedBy
        IF NOT EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = target_schema 
              AND TABLE_NAME = tbl_name 
              AND COLUMN_NAME = 'UpdatedBy'
        ) THEN
            SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN UpdatedBy VARCHAR(255) NOT NULL');
        END IF;

        -- UpdatedDate
        IF NOT EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = target_schema 
              AND TABLE_NAME = tbl_name 
              AND COLUMN_NAME = 'UpdatedDate'
        ) THEN
            SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
        END IF;

        -- Execute if there's something to alter
        IF LENGTH(@sql_parts) > 0 THEN
            SET @alter_stmt := CONCAT('ALTER TABLE `', target_schema, '`.`', tbl_name, '`', 
                                      SUBSTRING(@sql_parts, 2), ';');
            PREPARE stmt FROM @alter_stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

    END LOOP;

    CLOSE cursor_tables;
END;
//

DELIMITER ;


CREATE TABLE IF NOT EXISTS SchemaChangeLog (
    LogId INT AUTO_INCREMENT PRIMARY KEY
    ,SchemaName VARCHAR(128) NOT NULL
    ,TableName VARCHAR(128) NOT NULL
    ,ExecutedSQL TEXT NOT NULL
    ,ExecutedAt DATETIME DEFAULT CURRENT_TIMESTAMP
    ,ExecutedBy VARCHAR(255) DEFAULT CURRENT_USER()
);


DELIMITER //

CREATE PROCEDURE LogSchemaChange (
    IN SchemaName VARCHAR(128),
    IN TableName VARCHAR(128),
    IN ExecutedSQL TEXT
)
BEGIN
    INSERT INTO SchemaChangeLog (SchemaName, TableName, ExecutedSQL)
    VALUES (SchemaName, TableName, ExecutedSQL);
END;
//

DELIMITER ;


CALL LogSchemaChange('my_database', 'Users', 'ALTER TABLE Users ADD COLUMN CreatedBy VARCHAR(255) NOT NULL;');

