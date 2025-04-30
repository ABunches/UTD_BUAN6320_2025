SELECT 
	ROUTINE_NAME
    , ROUTINE_TYPE
    , DTD_IDENTIFIER AS RETURNS
    , ROUTINE_DEFINITION
    
FROM INFORMATION_SCHEMA.ROUTINES

WHERE 
	ROUTINE_TYPE IN ('PROCEDURE','FUNCTION')
  AND ROUTINE_SCHEMA = 'contoso';

## SchemaChangeLog
DELIMITER //  

-- Schema log entry 
DROP PROCEDURE IF EXISTS contoso.LogSchemaChange;         
CREATE PROCEDURE contoso.LogSchemaChange (
    IN SchemaName VARCHAR(128),
    IN TableName VARCHAR(128),
    IN ExecutedSQL TEXT
)
BEGIN
    INSERT INTO SchemaChangeLog (SchemaName, TableName, ExecutedSQL)
    VALUES (SchemaName, TableName, ExecutedSQL);
END;


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
          AND TABLE_TYPE = 'BASE TABLE';

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
            SET @sql_parts := CONCAT(@sql_parts, ', ADD COLUMN UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
        END IF;

        -- Execute ALTER TABLE if needed
        IF LENGTH(@sql_parts) > 0 THEN
            SET @alter_stmt := CONCAT('ALTER TABLE `', target_schema, '`.`', tbl_name, '`', 
                                      SUBSTRING(@sql_parts, 2), ';');
            PREPARE stmt FROM @alter_stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            -- Log the executed SQL
            CALL LogSchemaChange(target_schema, tbl_name, @alter_stmt);
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
          AND COLUMN_NAME IN ('CreatedBy', 'ModifiedBy')
          AND TABLE_NAME NOT IN ('users');

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


DELIMITER //
CALL contoso.AddMissingAuditColumns('contoso'); 
CALL contoso.UpdateAuditFields('contoso')
// DELIMITER ;

