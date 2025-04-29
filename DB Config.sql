USE Contoso;
SELECT *
FROM contoso.date
LIMIT 10;

        
 # Derive new tables! 
 
	## Users
	DROP TABLE IF EXISTS Contoso.users;
	CREATE TABLE IF NOT EXISTS Users (
		UserId INT NOT NULL AUTO_INCREMENT
		,UserName VARCHAR(100) NOT NULL UNIQUE
		,FirstName VARCHAR(255)NOT NULL
		,LastName VARCHAR(255) NOT NULL
		,UpdatedBy VARCHAR(255) NOT NULL
		,UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
		,CreatedBy VARCHAR(255) NOT NULL
		,CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
		,PRIMARY KEY (UserId)
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
			,TRIM(State)
			,TRIM(StateFull)
			,TRIM(Country)
			,TRIM(CountryFull)
			
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
		,UpdatedBy VARCHAR(255) NOT NULL
		,UpdatedDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
		,CreatedBy VARCHAR(255) NOT NULL
		,CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
		,PRIMARY KEY (ProductCategoryKey)
	);
	INSERT INTO contoso.ProductCategory (CategoryKey,CategoryName,SubCategoryKey,SubCategoryName,UpdatedBy,CreatedBy)
	SELECT DISTINCT
		TRIM(CategoryKey)
		,TRIM(CategoryName)
		,TRIM(SubCategoryKey)
		,TRIM(SubCategoryName)
		,CURRENT_USER() as 'UpdatedBy'
		,CURRENT_USER() as 'CreatedBy'
	FROM contoso.product;
	
    

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
        
        ALTER TABLE contoso.currencyexchange
		ADD INDEX idx_FromCurrency (FromCurrency);
    
        ALTER TABLE contoso.currencyexchange
		ADD INDEX idx_ToCurrency (ToCurrency);
       

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
        
		ALTER TABLE contoso.date
		ADD INDEX idx_Date (Date);
        
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
		UPDATE contoso.Sales SET SalesKey = (@rownum := @rownum + 1);
    
		### add new constraint to the table to ensure integrity
		ALTER TABLE contoso.Sales
		ADD CONSTRAINT unique_orderkey_linenumber UNIQUE (OrderKey, Linenumber);
    
    ## store
		ALTER TABLE contoso.store
        ADD PRIMARY KEY (StoreKey);

	## ProductCategory
    
	ALTER TABLE contoso.ProductCategory ADD INDEX idx_ProductCategory(CategoryKey);
	ALTER TABLE contoso.ProductCategory ADD INDEX idx_SubCategoryKey(SubCategoryKey);
	ALTER TABLE contoso.ProductCategory ADD INDEX idx_CategoryName(CategoryName);
	ALTER TABLE contoso.ProductCategory ADD INDEX idx_SubCategoryName(SubCategoryName);
    
	## GeoArea
	ALTER TABLE contoso.GeoArea ADD PRIMARY KEY(GeoAreaKey);        
	ALTER TABLE contoso.GeoArea MODIFY COLUMN GeoAreaKey INT NOT NULL AUTO_INCREMENT; 

# Creating the primary/foreign key relationships!    --in progress

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