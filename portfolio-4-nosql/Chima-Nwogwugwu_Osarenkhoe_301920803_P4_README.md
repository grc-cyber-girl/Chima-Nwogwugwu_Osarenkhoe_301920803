
# Portfolio 4 NoSQL and Advanced Data Models

## Document model

The `digital_banking_activity` database contains a `transaction_events` collection.

Each document represents one event in the lifecycle of a bank transfer. The model uses two event types: `transfer_initiated` and `transfer_status_updated`.

Each document contains the shared fields `_id`, `event_type` and `occurred_at`. It also includes embedded `transaction`, `customer` and `accounts` documents. The `details` field varies according to the event type: initiation events record the channel used, while status-update events record the transaction status and description.

The example records use identifiers and fictional customer details from the Digital Banking Platform case study. They are illustrative MongoDB examples entered separately; they were not automatically extracted from PostgreSQL.

Example status-update document:

```javascript
{
  _id: "EVT002",
  event_type: "transfer_status_updated",
  occurred_at: ISODate("2026-10-20T09:01:00Z"),
  transaction: {
    reference: "TXN-2026-0001",
    amount: 5000,
    currency: "NGN"
  },
  customer: {
    customer_id: 1,
    full_name: "Ada Okafor"
  },
  accounts: {
    sender: {
      account_number: "2000000001",
      account_holder: "Ada Okafor"
    },
    receiver: {
      account_number: "2000000003",
      account_holder: "Zuri James"
    }
  },
  details: {
    status: "Successful",
    description: "Transfer completed successfully"
  }
}
```

## Implementation and results

The implementation uses MongoDB Community Server and `mongosh` in GitHub Codespaces. Four fictional event documents are designed for insertion into the `transaction_events` collection using one `insertMany()` operation.

The queries demonstrate:

- Counting the total number of event documents.
- Retrieving events involving Ada's account, ordered by event time.
- Filtering documents using the nested field `details.status`.

**Execution results:** To be completed after running the four-document insertion and all three queries. The expected count is four documents. The account-history query should return four events involving Ada's account, and the successful-status filter should return EVT002.

The MongoDB exercise is separate from the PostgreSQL implementation. No PostgreSQL tables or records are changed.

## Why MongoDB fits

MongoDB is suitable for this example because each transaction event can store related transaction, customer and account information together in one document. This makes it possible to retrieve an event with its relevant context without joining several collections.

The `details` field can also vary according to the event type. For example, an initiation event records the channel, while a status-update event records the transaction outcome.

A separate document for each event allows the transaction history to grow as additional events occur.

However, the embedded customer and account information represents a snapshot and does not automatically reflect changes in PostgreSQL. MongoDB also does not enforce the relational foreign-key constraints defined in the PostgreSQL database or automatically synchronise data between the two systems. PostgreSQL remains the system used for the relational banking records and associated business rules in this portfolio.

## Files

- [MongoDB JavaScript implementation](Chima-Nwogwugwu_Osarenkhoe_301920803_P4_MongoDB.js)
- [MongoDB setup notes](Chima-Nwogwugwu_Osarenkhoe_301920803_P4_Setup.md)
- [Screenshots](screenshots/)

## References

- [MongoDB documentation: insertMany()](https://www.mongodb.com/docs/manual/reference/method/db.collection.insertMany/)
- [MongoDB documentation: countDocuments()](https://www.mongodb.com/docs/manual/reference/method/db.collection.countDocuments/)
- [MongoDB documentation: find()](https://www.mongodb.com/docs/manual/reference/method/db.collection.find/)
- [MongoDB documentation: Query Documents](https://www.mongodb.com/docs/manual/tutorial/query-documents/)
