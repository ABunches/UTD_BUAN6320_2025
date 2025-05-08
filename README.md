# 



# Post Mortem: `contoso.UpdateAuditFields` Stored Procedure

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
