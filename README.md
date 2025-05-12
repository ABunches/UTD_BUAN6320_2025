## How to Run

The `CreateDatabase.ipynb` script is designed to be run from a Jupyter environment such as VS Code or Anaconda Navigator. It will:

- Create the `contoso` schema if it does not exist
- Download and extract the source dataset
- Create all tables and relationships
- Seed reference data
- Apply indexes and constraints
- Generate audit fields and execute triggers

### Prerequisites

Ensure the following are met before execution:

- You have a local MySQL Server 8.0+ instance running
- You have followed the `my.ini` performance configuration steps
- You are running the correct Python environment (see `environment.yml`)
- You have `mysql.connector` installed in your environment

### Required Configuration

In the first code cell of the script, update the following variables with your **local MySQL credentials**:

```python
USER = "your_mysql_username"
PASSWORD = "your_mysql_password"
```

These are required for establishing the connection to your local MySQL instance. By default, the connection targets:

```python
HOST = "localhost"
DATABASE = "contoso"
PORT = 3306
```

If your environment differs (e.g., custom port or remote server), update the values accordingly.

### Running the Script

1. Open the notebook in your preferred Jupyter environment.
2. Set your `USER` and `PASSWORD` values.
3. Execute the notebook cell by cell or use **Run All**.

> Note: Initial data download and table construction may take several hours depending on your system performance.


<br><br><br><br><br><br>


# How to Use `environment.yml` to Reproduce the Project Environment

This project includes an `environment.yml` file designed to allow developers and analysts to replicate the exact Python environment used during development. It ensures compatibility for executing scripts, notebooks, and SQL integration tasks with all required dependencies.

---

## Requirements

- An installation of either [Anaconda](https://www.anaconda.com/products/distribution) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html).
- Access to the terminal, command line, or Anaconda Prompt.

---

## Setup Instructions

### Step 1: Navigate to the project directory

Open your terminal or command prompt and change directories to the folder containing the `environment.yml` file.

```bash
cd /path/to/project/
```

### Step 2: Create the conda environment

Use the following command to create a new environment from the `environment.yml` definition.

```bash
conda env create -f environment.yml
```

This will install the environment with all packages listed in the file, including version-specific dependencies.

### Step 3: Activate the environment

Once created, activate the environment using:

```bash
conda activate your-environment-name
```

Replace `your-environment-name` with the name defined at the top of the `environment.yml` file (typically under `name:`).

---

## Updating the Environment

If the `environment.yml` file has been modified (for example, new dependencies added), update your environment as follows:

```bash
conda env update -f environment.yml --prune
```

The `--prune` option removes packages that are no longer required.

---

## Optional: Jupyter Notebook Integration

If you plan to run Jupyter notebooks from this environment, you may need to register it as a kernel:

```bash
conda install ipykernel
python -m ipykernel install --user --name=your-environment-name
```

---

## Removing the Environment

To clean up or reset your environment:

```bash
conda deactivate
conda env remove --name your-environment-name
```

---

## Best Practices

- Commit `environment.yml` to version control, but avoid committing `environment.lock` or `env/` folders.
- Regenerate the `environment.yml` file periodically using `conda env export > environment.yml` to reflect any updates made to your environment.

<br><br><br><br><br><br>

# Updating MySQL Configuration for Performance Optimization

This project includes a custom `my.ini` file located in the repository, which is tailored for batch processing, large data volumes, and long-running transactions. Applying these configuration settings can significantly improve MySQL performance on local installations.

---

## Location of the MySQL Configuration File

For MySQL Server 8.0 on Windows, the configuration file is typically located at:

```
C:\ProgramData\MySQL\MySQL Server 8.0\my.ini
```

> Note: The `ProgramData` folder is hidden by default. Enable **View > Hidden Items** in File Explorer to access it.

---

## Step-by-Step Instructions to Overwrite `my.ini`

### 1. Stop the MySQL Service

Before replacing the configuration file, stop the MySQL server:

**Option A: Using Services**
- Press `Win + R`, type `services.msc`, and press Enter.
- Locate **MySQL80** in the list.
- Right-click and select **Stop**.

**Option B: Using Command Prompt (Admin)**
```cmd
net stop MySQL80
```

---

### 2. Back Up the Existing Configuration

Create a backup of the original `my.ini` file:

```cmd
copy "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini.backup"
```

---

### 3. Overwrite with the Project’s `my.ini` File

In this repository, locate the provided `my.ini` file. Copy it over the existing system configuration:

```cmd
copy "path\to\repo\my.ini" "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini"
```

Make sure to run your command prompt or file copy operation **with Administrator privileges**.

---

### 4. Restart the MySQL Service

**Using Services:**
- Right-click on **MySQL80** in `services.msc` and click **Start**.

**Or in Command Prompt:**
```cmd
net start MySQL80
```

---

### 5. Confirm Configuration Was Applied

Run the following in MySQL Workbench or any SQL client:

```sql
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'wait_timeout';
SHOW VARIABLES LIKE 'innodb_thread_concurrency';
```

Ensure the returned values match those specified in your new configuration.

---

## Configuration Goals

The included `my.ini` is optimized for:

- Improved `innodb_buffer_pool_size` for caching
- Increased timeout thresholds for long-running batch jobs
- Additional concurrency for multi-threaded inserts
- Reduced commit overhead with adjusted `innodb_flush_log_at_trx_commit`

---

## Recovery Option

If something goes wrong and MySQL won’t start, restore the original file:

```cmd
copy "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini.backup" "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini"
```

Then restart the service again.

---

## Additional Notes

- Only apply this configuration to local development environments.
- You may modify buffer sizes depending on available RAM. For example:
  - `10GB`: `innodb_buffer_pool_size = 10737418240`
  - `4GB`: Use a smaller value such as `4294967296`


<br><br><br><br><br><br>

## SQL Deployment Script: `All in one.sql`

This script serves as a standalone, linear alternative to the modular `sql_chunks` dictionary implemented in the Python orchestration logic. It contains all schema definitions, data manipulation statements, index creation, audit logic, foreign key constraints, stored procedures, functions, and triggers necessary to fully build and initialize the Contoso database from scratch.

### Purpose

- Enables quick deployment in SQL-based IDEs such as MySQL Workbench
- Useful for verification, one-time builds, or step-by-step debugging without the need to run the full Python orchestration
- Mirrors the order and logic defined in the Python-based `sql_runner` using the `sql_chunks` structure

### Notes

- The SQL statements are ordered to respect dependency chains (e.g., table creation precedes indexing and constraints).
- Stored procedure `CALL` commands are placed at key points where dynamic alterations or data manipulations must occur.
- This file is functionally equivalent to executing the entire `sql_chunks` sequence in Python, but as a static SQL batch.

### Usage

You can execute this file in:
- MySQL Workbench
- Any compatible SQL client connected to your MySQL 8.0+ instance

Ensure you have modified your `my.ini` file for optimal performance before running this script on large datasets.




<br><br><br><br><br><br>
# Development Postmortem: Contoso Database Build and Audit Automation

## 1. Overview

This project involved building a full database orchestration pipeline using Python and MySQL to initialize and populate a large-scale Contoso dataset. The solution aimed to:

- Establish a clean schema and table structure
- Ingest millions of rows of data from a compressed source
- Normalize and optimize schema objects
- Implement auditing fields (`CreatedBy`, `UpdatedBy`, etc.)
- Provide reliable, low-lock batch update automation

The final solution replaced stored procedure-driven logic with a Python-controlled batching framework to allow for finer-grained control and monitoring.

---

## 2. System Architecture

- **Database**: MySQL 8.0, local instance
- **Language**: Python 3.10 (Anaconda environment)
- **Libraries Used**:
  - `os`, `glob`, `math`
  - `pandas`, `numpy` for data manipulation
  - `mysql.connector` and `MySQLConnection` for SQL execution
  - `requests` for HTTP and file retrieval
  - `py7zr` for handling `.7z` archives
  - `tqdm` for progress monitoring
  - `typing` for annotated function definitions and clarity
- **Dataset**: Contoso compressed CSV files
- **Execution Environment**: Jupyter Notebook (VS Code)

---

## 3. Data Ingestion and Transformation

- Data is downloaded via `requests` and extracted using `py7zr`
- CSVs are read and parsed using `pandas`, then chunked for efficient insertion
- `INSERT IGNORE` and conditional deduplication logic is used for initial load
- Trim operations are applied to clean inconsistent values across key fields (e.g., state, product category)
- Created Normalized tables from existing tables

---

## 4. Database and Schema Creation

- All tables are dropped and recreated using a clear naming and normalization strategy
- Surrogate keys are added post-insertion using:

  ```sql
  ALTER TABLE tablename ADD COLUMN SomeKey INT FIRST;
  SET @rownum = 0;
  UPDATE tablename SET SomeKey = (@rownum := @rownum + 1);
  ALTER TABLE tablename MODIFY COLUMN SomeKey INT NOT NULL PRIMARY KEY;
  ```

- Indexes are explicitly created on foreign key columns, lookup fields, and audit fields
- Foreign key constraints are added after data load to avoid load-time failures

---

## 5. Audit Field Strategy

Audit fields (`CreatedBy`, `CreatedDate`, `UpdatedBy`, `UpdatedDate`) were standardized across all user-facing tables. These fields were added dynamically if missing using a stored procedure with `INFORMATION_SCHEMA` lookup logic. Fields were populated via a random user generator function (`RandomUser()`) tied to logic executed either by trigger or controlled Python batching.

---

## 6. Batch Update Execution (Python-Driven)

To replace the long-running stored procedure logic, a Python loop was developed that:

- Controlled `LIMIT`-based batch sizes
- Applied `UPDATE ... WHERE CreatedBy IS NULL LIMIT 1000`
- Checked for affected rows using `SELECT ROW_COUNT()`
- Committed results incrementally
- Automatically terminated when no further rows were updated

This approach improved observability and reduced contention from long-running locks.

See Detailed Post Mortem: `contoso.UpdateAuditFields` below. 

---

## 7. Error Handling and Recovery

- All SQL executions were wrapped in `try/except` blocks with conditional breakpoints
- Errors were logged with context and optionally paused for user intervention
- `autocommit` was toggled around batch operations to isolate transactional scope
- Rollbacks were avoided through batch commitment and staged execution

---

## 8. Performance Analysis

- Stored procedure approach: >2,000 minutes to complete on multi-million-row tables. This was changed to Python batching due to MySQL limitations.
- Python batching: Approximately 3× faster in real-world performance. This can be further improved through hyperthreading and leveraging multiple connections to the Database.
- Remaining bottlenecks were due to InnoDB row-level locks and background rollback. This can be aleviated through Python managed functions. 
- Indexing on `CreatedBy` made a significant impact on row selection speed, while improved performance, there is still several hours of processing required. 

---

## 9. Challenges and Mitigations

| Challenge | Mitigation |
|----------|------------|
| InnoDB locking during mass update | Introduced `LIMIT` and `autocommit` batching |
| Metadata locks from concurrent triggers | Sequenced trigger creation after table loads |
| Stored procedure rollback delay | Replaced with Python-native retry loops |
| Detecting idle or blocked transactions | Monitored `INFORMATION_SCHEMA.INNODB_TRX` |
| Database initial configuration limitations | Adjusted global values and /ini file to take advantage of more sytem resources

---

## 10. Lessons Learned

- How to avoid long-running stored procedures for large update tasks
- Externalize batching logic into the application layer for flexibility
- Always prepare and persist required indexes before updates
- Watch for metadata locking behavior when procedures, triggers, or DDL are involved
- Native admin funtions and tooling in MySQL to monitor and assess DB health a perfomance
- Extensive differneces between MySQL, TSQL, and Postgres. 

---

## 11. Future Enhancements

- Parallel execution of batch updates across tables
- Use of message queues for distributed update signaling
- Integration with GitHub Actions for automated database builds
- Incremental load strategy to avoid full rebuilds on rerun
- Automated index health checks post-load

---

## 12. Trigger Design and Automation

To automate auditing behavior during data mutations, two categories of triggers were created:

- **BEFORE INSERT Triggers**: Populate `CreatedBy` and `CreatedDate` using `RandomUser()` and `CURRENT_TIMESTAMP`
- **BEFORE UPDATE Triggers**: Populate `UpdatedBy` and `UpdatedDate` using `RandomUser()` and `CURRENT_TIMESTAMP`

Each table received both triggers where applicable. Triggers were consistently named using the pattern:

```sql
CREATE TRIGGER tablename_set_random_created_by ...
CREATE TRIGGER tablename_set_random_updated_by ...
```

This structure ensures clear audit lineage without requiring explicit application-level updates during inserts or modifications.

> Note: Trigger creation was deferred until after table and data initialization to avoid metadata lock conflicts.

---

## 13. Stored Procedure Lifecycle and Refactor

The initial implementation of audit field population was fully encapsulated in a stored procedure (`UpdateAuditFields`) that:

- Used cursors over `INFORMATION_SCHEMA.COLUMNS`
- Generated dynamic SQL via `PREPARE`/`EXECUTE`
- Operated inside nested `WHILE` loops to manage batching

However, the procedure suffered from:

- Excessive row-level locking
- Poor transparency during execution
- Difficulty interrupting or rolling back long transactions

This led to a full migration of batching control into the Python layer, leaving the stored procedure for schema introspection only (if needed). Eventually, even `ROW_COUNT()` checks were handled externally.

---

## 14. Python Runner Architecture

The orchestration of schema creation, indexing, batching, and logging was managed by a modular Python runner. It featured:

- **Structured `sql_chunks` Dictionary**:
  - Human-readable descriptions
  - Statement-level granularity for controlled execution

- **Chunk Execution Engine**:
  - Sequentially executed SQL commands per chunk
  - Logged results and errors
  - Allowed step-wise debugging and visibility

- **Interactive Behavior**:
  - Optional prompts on error
  - Commit and rollback flexibility
  - Controlled use of `autocommit`

- **Audit Logging and DDL Safety**:
  - Calls to `LogSchemaChange` to document dynamic modifications
  - Consistent `DROP IF EXISTS` usage to prevent conflicts

This Python-first model became the core control layer, offering repeatable, auditable execution from a single notebook or CLI script.

---

<br><br><br>


<br><br><br>


# Detailed Post Mortem: `contoso.UpdateAuditFields` Stored Procedure

## Objective

To automate the population of `CreatedBy` fields across all tables in the `contoso` schema where values were missing, using batch updates with minimal locking risk. The solution was designed to be scalable across multi-million row datasets while preserving data integrity and transactional safety.

---

## Design Summary

- A cursor iterated over all tables containing a `CreatedBy` column.
- Dynamic SQL statements were constructed to perform batch updates for each table.
- Conditional dynamic indexing was implemented to create an index on the `CreatedBy` column where missing, intended to minimize locking scope.
- An OUT parameter was used to return the number of rows updated per batch, allowing control from an external Python runner.

---

## Outcomes

| Goal                                             | Result          |
|--------------------------------------------------|-----------------|
| Batch processing across multiple tables          | Achieved        |
| Lock minimization through indexing               | Achieved        |
| Dynamic indexing and index removal               | Functioned, later determined to be unnecessary due to permanent indexes |
| Feedback loop to external Python runner          | Successfully implemented |
| Successful updates on smaller tables             | Consistent      |

---

## Challenges and Root Causes

| Issue                                           | Root Cause      |
|-------------------------------------------------|-----------------|
| Prolonged total execution time (over 2,000 minutes) | Single-threaded cursor loop combined with dataset size |
| Lock counts exceeded batch size at times        | InnoDB lock propagation and row versioning under dynamic SQL execution |
| Metadata locking and blocking                   | Simultaneous dynamic DDL operations and active concurrent sessions |
| Modification and deployment delays              | Metadata locks persisted throughout long-running transactions |
| Lock wait timeouts and rollback latency         | Large transactional scopes and InnoDB rollback mechanics |
| Limited visibility into real-time lock escalation | Inherent limitations in MySQL's dynamic SQL and lock tracking |
| Complex error management                        | Dynamic SQL and nested cursor loops complicated exception handling |

---

## Root Cause Summary

The procedure centralized too much logic and control within the database engine. Dynamic SQL inside a cursor loop introduced significant locking complexity and index management overhead. Lock propagation behavior and transaction handling within MySQL stored procedures introduced unpredictable scaling characteristics. Despite the presence of pre-created permanent indexes, the design's reliance on MySQL’s internal locking and concurrency control created scaling bottlenecks and long execution times.

---

## Key Lessons Learned

| Lesson                                         | Recommended Practice |
|------------------------------------------------|-----------------------|
| SQL-based batching is difficult to scale for large update operations | Move batching control to the application layer |
| Dynamic index creation introduces avoidable overhead | Pre-create all necessary indexes in advance |
| Transactional control is limited within SQL procedures | Use external orchestration for batch control and error recovery |
| Lock escalation in MySQL is difficult to monitor in dynamic contexts | Proactively design for minimal locking scope and improved observability |
| Progress tracking and error handling are more robust in application-level batching | Use Python or similar scripting languages for process orchestration |

---

## Architectural Decision

The stored procedure method has been deprecated for this use case. Future updates will be orchestrated entirely from the application layer (Python), allowing:

- Flexible batch sizing and iteration
- Explicit error handling and retry mechanisms
- Transparent lock and transaction management
- Easier extension to parallelization where appropriate

---

## Current Status

The `contoso.UpdateAuditFields` stored procedure is no longer recommended for batch update scenarios involving large datasets or concurrency-sensitive environments. The Python-based batching framework will serve as the primary solution moving forward.



<br><br><br><br><br><br>


# Function Descriptions
<br>

## `download_file(url: str, filename: str)`

```python
def download_file(url: str, filename: str)
```

### **Purpose**
This function downloads a file from a specified URL and saves it to the user's system, using a visible progress bar to show download status.


### **Key Features**
- **Progress Feedback**: Uses `tqdm` to display real-time download progress in the console.
- **Automatic Pathing**: Constructs the full path using the system's Downloads folder and appends the provided filename.
- **Error Handling**: Includes basic exception capture for network-related issues and file write failures.
- **Streaming Download**: Reads the file in binary chunks (`1024` bytes) rather than loading the entire file into memory, making it efficient for large files.


### **How It Works**
1. Sends a `GET` request to the URL with `stream=True` to begin a streaming download.
2. Extracts the `Content-Length` header to determine the total file size.
3. Constructs the output path by combining the Downloads directory with the specified filename.
4. Opens the target file in binary write mode.
5. Iterates through the streamed response in chunks and writes each to disk, updating the progress bar.


### **Example Usage**
```python
download_file(
    url="https://example.com/data.7z",
    filename="contoso_data.7z"
)
```

### **Strengths**
- Handles large files efficiently via streaming.
- Provides user-friendly progress visualization.
- Easy to integrate into larger ETL or orchestration scripts.


### **Limitations**
- Assumes a stable network connection.
- No retry mechanism for failed downloads.
- No checksum verification for downloaded content.

<br><br>
---

<br>

---
<br><br>

## `extract_archive(filename: str)`
```python
def extract_archive(filename: str)
```

### **Purpose**
Extracts the contents of a `.7z` archive located in the system’s Downloads directory into a predefined extraction path (`EXTRACT_DIR`), using the `py7zr` library with robust error handling and user feedback.


### **Key Features**
- **Archive Detection**: Searches for the `.7z` file in the user's `Downloads` directory.
- **Progress Logging**: Uses `tqdm` to show extraction progress visually in the terminal.
- **Error Messaging**: Includes multiple `try-except` blocks to handle:
  - File not found
  - Archive corruption
  - File system errors
- **Output Pathing**: Extracts files directly into `EXTRACT_DIR`, a designated workspace for processing.


### **How It Works**
1. Constructs the full file path by combining the Downloads folder and provided filename.
2. Verifies the existence of the `.7z` file.
3. Uses the `py7zr.SevenZipFile` context manager to open the archive.
4. Extracts all contents into the extraction directory.
5. Logs file names as they are extracted using `tqdm` to simulate progress tracking.
6. Returns the output path if successful, otherwise returns `None`.


### **Example Usage**
```python
extract_archive("contoso_data.7z")
```


### **Strengths**
- Transparent and user-friendly with visual feedback.
- Resilient to common runtime issues (missing file, I/O errors).
- Easy integration with automated workflows that include compressed datasets.


### **Limitations**
- Only supports `.7z` format (via `py7zr`).
- No support for password-protected archives.
- Fails silently (returns `None`) if an unknown exception occurs without granular diagnostics.


<br><br>
---

<br>

---
<br><br>

## `create_database(db_name: str)`
```python
def create_database(db_name: str)
```

### **Purpose**
Creates a new MySQL database if it does not already exist. This function is typically called at the beginning of a database setup workflow to ensure the target schema is available for table creation and data loading.


### **Key Features**
- **Idempotent Design**: Uses `CREATE DATABASE IF NOT EXISTS` to avoid duplicate errors when the database already exists.
- **Reusability**: Can be called programmatically as part of a setup or initialization routine.
- **Dynamic Support**: Accepts the database name as a parameter, enabling flexible reuse across different environments or schemas.


### **How It Works**
1. Constructs a `CREATE DATABASE IF NOT EXISTS` SQL statement using the provided `db_name`.
2. Establishes a short-lived MySQL connection using the global `CONN_CONFIG` object.
3. Executes the SQL statement to create the schema.
4. Commits the change and closes the connection immediately.


### **Example Usage**
```python
create_database("contoso")
```


### **Strengths**
- Ensures schema availability before attempting DDL operations.
- Low-overhead operation that cleanly integrates into automated workflows.
- Avoids redundant recreation or failure if the database already exists.


### **Limitations**
- Assumes `CONN_CONFIG` has sufficient privileges to create databases.
- Does not perform any validation or logging on schema properties (e.g., charset, collation).
- No exception handling; failure conditions (e.g., permission denied) will raise unhandled errors.


<br><br>
---

<br>

---
<br><br>

## `infer_mysql_dtype(...)`
```python
def infer_mysql_dtype(series: pd.Series) -> str:
```

### **Purpose**
Infers the most appropriate MySQL data type for a given pandas Series by inspecting its values and patterns.

### **Key Features**
- Detects MySQL-compatible types: `DATETIME`, `DATE`, `INT`, `DECIMAL`, `BIT`, `VARCHAR`, `TEXT`, and `LONGTEXT`.
- Uses both Python type inspection and custom datetime parsing logic.
- Automatically scales VARCHAR size and selects text type based on content length.

### **How It Works**
1. Drops nulls from the Series.
2. Attempts to match each value to date/time formats using `check_datetime()`.
3. Checks for:
   - Boolean-only data (0/1) → `BIT`
   - Integer-only or decimal values → `INT` / `DECIMAL`
   - Datetime strings → `DATETIME` or `DATE`
4. Defaults to text types based on maximum length:
   - `< 255 chars` → `VARCHAR(255)`
   - up to 65,535 → `TEXT`
   - beyond → `LONGTEXT`

### **Strengths**
- Dynamic and intelligent inference suitable for automated schema generation.
- Handles a variety of real-world CSV content and format inconsistencies.

### **Limitations**
- Doesn’t distinguish mixed-type columns or ambiguous values well.
- Date/time detection is limited to predefined formats.
- Cannot infer ENUMs, foreign keys, or composite constraints.



## `compute_scale(...)`

```python
def compute_scale(x: float, min_x=0, max_x=10_000_000, min_scale=0.01, max_scale=0.20) -> float:
```

### **Purpose**
Generates a normalized scaling factor for an input value `x`, typically used to adjust the proportion of records to sample or process in downstream operations.


### **Key Features**
- **Logarithmic Normalization**: Uses a non-linear scale to compress large values and expand smaller ones.
- **Dynamic Range Control**: Allows caller to specify input and output range bounds:
  - `min_x`, `max_x` = input range for `x`
  - `min_scale`, `max_scale` = output range for computed scale
- **Edge Case Handling**: Clamps values to ensure results never fall outside of the desired scaling range.


### **How It Works**
1. Validates `x` against `min_x` and `max_x`.
2. Computes a normalized ratio between 0 and 1 using:
   ```python
   ratio = (x - min_x) / (max_x - min_x)
   ```
3. Applies the ratio to interpolate a scale within `min_scale` to `max_scale`.
4. Returns the scaled value.


### **Example Usage**
```python
rows = 1_000_000
scale = compute_scale(rows, min_x=0, max_x=10_000_000, min_scale=0.01, max_scale=0.20)
```


### **Strengths**
- Flexible and easily reusable in any context where proportional sampling or scaling is needed.
- Avoids extreme values (e.g., 0 or 1) by using configurable bounds.
- Supports large-scale processing decisions (e.g., how many rows to sample).


### **Limitations**
- Requires well-chosen bounds; poorly chosen `min_x` or `max_x` may distort scaling.
- Assumes a linear mapping; no exponential/logarithmic curve options.
- No logging or diagnostics if input is out of bounds or misused.

<br><br>
### Data Scaling Visualization (`compute_scale`)

#### Purpose

This plot visualizes the relationship between input record counts and their corresponding scaling factors, constrained between a lower bound (e.g., `0.001`) and an upper bound (e.g., `0.15`). The function is designed to return diminishing scaling values as volume increases, which helps:

- Adjust randomized sample sizes
- Throttle transformation behavior for large datasets
- Control batch size proportionality

#### Usage

The scaling plot is invoked directly in the notebook for visual inspection, and is not required for production execution. It serves as a verification step to confirm that the non-linear scaling function behaves as intended across a defined input range (typically 0 to 1,000,000).

#### Notes

- This is primarily a **diagnostic utility**, not used in batch execution logic.
- Requires `matplotlib.pyplot` to be installed in the environment.

<br><br>
---

<br>

---
<br><br>

## `create_tables_from_csv()`
```python
def create_tables_from_csv(targetdirectory: str = EXTRACT_DIR) -> None:
```

### **Purpose**
Creates MySQL tables based on CSV file structures and loads their data using inferred schema and chunked inserts.

### **Key Features**
- Searches a directory for all `.csv` files.
- Infers each column's data type using `infer_mysql_dtype()`.
- Automatically builds `CREATE TABLE` SQL statements.
- Loads data incrementally using `pandas.read_csv(..., chunksize=...)`.
- Uses `executemany()` for batch inserts with progress monitoring via `tqdm`.

#### **How It Works**
1. Scans each `.csv` file and reads a sample row.
2. Infers types for all columns based on sample and value inspection.
3. Constructs and executes a full `CREATE TABLE` statement.
4. Loads CSV in batches of 1000 rows and inserts them into the corresponding MySQL table.
5. Tracks success/failure for each file and table.

#### **Strengths**
- Enables fast and flexible schema creation from arbitrary data files.
- Handles millions of records using chunked memory-efficient logic.
- Can be reused for multiple datasets with minimal reconfiguration.

#### **Limitations**
- Assumes well-formed and consistent CSV headers.
- Does not validate or enforce relationships (e.g., foreign keys).
- Minimal error handling and no retry logic for failed inserts..



### `create_table(table_name: str, columns: Dict)`

```python
def create_table(table_name: str, columns: Dict[str, str]) -> None:
```

### **Purpose**
Creates a new MySQL table using a programmatically constructed `CREATE TABLE` SQL statement based on a dictionary of column names and inferred MySQL data types.


### **Key Features**
- **Dynamic Schema Generation**: Accepts any table name and column definition dictionary, enabling flexible table creation for different datasets.
- **Safe Execution**: Uses `CREATE TABLE IF NOT EXISTS` to prevent errors when the table already exists.
- **Integrates with Type Inference**: Designed to work with output from `infer_mysql_dtype()` or similar inference logic.


### **How It Works**
1. Constructs a comma-separated string of column definitions using:
   ```python
   ",\n".join([f"`{col}` {dtype}" for col, dtype in columns.items()])
   ```
2. Builds a full SQL `CREATE TABLE` statement:
   ```sql
   CREATE TABLE IF NOT EXISTS `table_name` (
       `col1` TYPE1,
       `col2` TYPE2,
       ...
   );
   ```
3. Executes the statement using the global `cursor` object.


### **Example Usage**
```python
create_table(
    table_name="customer",
    columns={
        "CustomerID": "INT",
        "CustomerName": "VARCHAR(255)",
        "CreatedDate": "DATETIME"
    }
)
```


### **Strengths**
- Easily integrates into ETL pipelines or data onboarding workflows.
- Supports flexible and readable schema definitions using Python dictionaries.
- Prevents accidental overwrites or failures if a table already exists.


### **Limitations**
- Assumes access to a valid `cursor` object from `mysql.connector`.
- No support for constraints (e.g., primary keys, indexes, or foreign keys).
- No error handling or validation of column names or types.


<br><br>
---

<br>

---
<br><br>

### `sql_runner(connection, cursor, chunks)`

```python
def sql_runner(connection, cursor, chunks)
```

### **Purpose**
Executes a series of SQL statement batches (called "chunks") with detailed progress logging, exception handling, and manual commit control. Designed for orchestrated deployment or setup tasks like schema changes, table population, and indexing.


### **Key Features**
- **Chunked Execution**: Processes SQL in grouped segments for better visibility and control.
- **Error Isolation**: Captures and logs errors on a per-statement basis without halting the entire execution (unless the user decides to).
- **Commit Logic**: Explicitly commits after each chunk to ensure data consistency and to reduce transaction size.
- **Interactive Debugging**: If an error occurs, prompts the user to decide whether to continue or halt execution.
- **Contextual Output**: Prints clear labels for each chunk and statement being executed.


### **How It Works**
1. Iterates over each chunk in the provided list. Each chunk is a dictionary with:
   - `description`: A brief label describing the purpose of the chunk.
   - `statements`: A list of SQL strings to execute sequentially.
2. For each statement in the chunk:
   - Prints the SQL to the console.
   - Tries to execute it using the active cursor.
   - Catches exceptions and prompts the user for continuation.
3. If all statements succeed, commits the chunk and proceeds to the next.
4. If the user halts execution after an error, the function returns early.


### **Example Usage**
```python
sql_runner(connection, cursor, [
    {
        'description': 'Create user table',
        'statements': [
            "DROP TABLE IF EXISTS users;",
            "CREATE TABLE users (UserID INT PRIMARY KEY, UserName VARCHAR(255));"
        ]
    }
])
```


### **Strengths**
- Gives complete visibility and control over SQL execution.
- Ideal for infrastructure setup, migration, or data loading operations.
- Helps troubleshoot errors interactively without restarting the entire process.


### **Limitations**
- Requires active user input to continue after errors — not fully automated.
- Assumes the presence of a live `connection` and `cursor` object.
- No internal retry logic or rollback on failure.

<br><br>
---

<br>

---
<br><br>

# Conclusion and Lessons Learned

This project served as a comprehensive exercise in full-cycle database construction, batch processing, and performance engineering on MySQL using a Python-driven orchestration layer. While the final deliverable is a robust and repeatable build script capable of initializing and populating a production-grade schema, the project exposed key insights into the practical limitations of MySQL and the InnoDB storage engine when scaling data operations.

### Key Takeaways

#### InnoDB Behavior and Locking

- **Row-level locks accumulate aggressively** during large `UPDATE` operations, particularly when no indexes exist on the filter criteria (`WHERE CreatedBy IS NULL`), often resulting in transaction rollback delays and blocking behavior.
- MySQL’s default behavior does not optimize for long-running or incremental DML operations out-of-the-box; **manual batching and autocommit strategies were critical** to avoid overwhelming transaction memory.

#### Stored Procedures vs. Python Orchestration

- Initial reliance on stored procedures for recursive batch updates created visibility and control challenges under lock-heavy workloads.
- Python proved to be a more transparent and debuggable alternative, with improved control over:
  - Retry logic
  - Batch size tuning
  - Transaction scoping
- This shift allowed for a modular and testable deployment process via the `sql_chunks` dictionary, with full logging and rollback awareness.

#### Schema and Script Reusability

- All logic has been captured in a clean, version-controlled structure using a single Jupyter notebook and accompanying `environment.yml`.
- The system can be deployed end-to-end on any MySQL-compatible system, with customizable tuning for memory and concurrency based on local configuration.
- Core components—such as the audit trigger generation, schema logging, and dynamic batching—are written to be **generic and portable** across datasets.

---

## Summary

This project highlights the importance of understanding **database internals, concurrency control, and execution strategy**—especially when automating data-heavy workloads. The migration from stored procedures to a Python-first execution model resulted in a system that is both more scalable and more maintainable, and which adheres to good software engineering practices in a data engineering context.

Future iterations may adapt this system for PostgreSQL or cloud-native managed databases to take advantage of improved isolation handling and bulk processing support.
