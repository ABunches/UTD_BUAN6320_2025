# Read Me place holder




```mermaid
graph TD
    S[SET GLOBALS] --> T1[Create Tables & Insert Data]
    T1 --> C1[ALTER TABLE - PKs & Constraints]
    C1 --> C2[CREATE INDEX]
    C2 --> U1[Assign Surrogate Keys (UPDATE)]
    U1 --> FK[Add Foreign Keys]
    FK --> F[Create Functions]
    F --> P[Create Procedures]
    P --> Call1[CALL AddMissingAuditColumns]
    Call1 --> TR[Create Triggers]
    TR --> Call2[CALL UpdateAuditFields]



flowchart TD
    C1[Chunk 1: Set Global Variables] --> C2[Chunk 2: Create Users Table and Seed Data]
    C2 --> C3[Chunk 3: Create SchemaChangeLog Table]
    C3 --> C4[Chunk 4: Create GeoArea and ProductCategorySubCategory Tables with Data]
    C4 --> C5[Chunk 5: Add Primary Keys and Unique Constraints]
    C5 --> C6[Chunk 6: Create Indexes on Key Columns]
    C6 --> C7[Chunk 7: Assign Surrogate Keys to Existing Rows]
    C7 --> C8[Chunk 8: Add Foreign Key Constraints]
    C8 --> C9[Chunk 9: Create User-Defined Functions]
    C9 --> C10[Chunk 10: Create Stored Procedures]
    C10 --> C11[Chunk 11: Execute AddMissingAuditColumns]
    C11 --> C12[Chunk 12: Create BEFORE UPDATE/INSERT Triggers for Audit Fields]
    C12 --> C13[Chunk 13: Execute UpdateAuditFields]

