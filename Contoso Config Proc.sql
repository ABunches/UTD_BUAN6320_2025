USE Contoso;
SELECT *
FROM contoso.sales
LIMIT 10;

SELECT *
FROM contoso.OrderRows
LIMIT 10;


# Table Modifications
	## currencyexchange

		### Add Key Column, set to first ordinal position
		ALTER TABLE contoso.currencyexchange
		ADD COLUMN CurrencyExchangeKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

		### update the new key column
		SET @rownum = 0;
		UPDATE contoso.currencyexchange SET CurrencyExchangeKey = (@rownum := @rownum + 1);

		### add new constraint to the table to ensure integrity
		ALTER TABLE contoso.currencyexchange
		ADD CONSTRAINT unique_date_from_to UNIQUE (Date, FromCurrency, ToCurrency);

	## customer
    
		### Set CustomerKeyColum to primary key
		ALTER TABLE contoso.customer
		ADD PRIMARY KEY (CustomerKey);
		
        ### Add indecies
		ALTER TABLE contoso.customer
		ADD INDEX idx_CustomerKey_GeoAreaKey (GeoAreaKey,CustomerKey);

        ALTER TABLE contoso.customer
		ADD INDEX idx_GivenName (GivenName);
    
		ALTER TABLE contoso.customer
		ADD INDEX idx_Surname (Surname);
    
		ALTER TABLE contoso.customer
		ADD INDEX idx_Surname (Occupation);
    
    ## date
		ALTER TABLE contoso.date
		ADD PRIMARY KEY (DateKey);
        
        
	## orderrows
		### Add Key Column, set to first ordinal position
		ALTER TABLE contoso.orderrows
		ADD COLUMN OrderRowsKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

		### update the new key column
		SET @rownum = 0;
		UPDATE contoso.orderrows SET OrderRowsKey = (@rownum := @rownum + 1);
    
		### add new constraint to the table to ensure integrity
		ALTER TABLE contoso.orderrows
		ADD CONSTRAINT unique_orderkey_linenumber UNIQUE (OrderKey, Linenumber);
	
    ## orders
		
        ## designate primary key column
		ALTER TABLE contoso.orders
		ADD PRIMARY KEY (OrderKey);	
        
	## product
		## designate primary key column
		ALTER TABLE contoso.Product
		ADD PRIMARY KEY (ProductKey);	
        
		ALTER TABLE contoso.Product
		ADD INDEX idx_ProductCode (ProductCode);
    
    ## Sales
		### Add Key Column, set to first ordinal position
		ALTER TABLE contoso.sales
		ADD COLUMN SalesKey INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

		### update the new key column
		SET @rownum = 0;
		UPDATE contoso.SalesKey SET SalesKey = (@rownum := @rownum + 1);
    
		### add new constraint to the table to ensure integrity
		ALTER TABLE contoso.SalesKey
		ADD CONSTRAINT unique_orderkey_linenumber UNIQUE (OrderKey, Linenumber);
    
# Creating the priamry/foreign key relationships!    
    ALTER TABLE contoso.customer
	ADD CONSTRAINT fk_customer_geoarea
	FOREIGN KEY (column_name)
	REFERENCES referenced_table(referenced_column)
	ON UPDATE CASCADE;




# Create a ProductCategory --> ProductSubCategory Tables, derived from Product Tables
# Create GeoArea Table Derive from Customer Table
