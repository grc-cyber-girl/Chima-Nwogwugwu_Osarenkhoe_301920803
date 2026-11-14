
// Portfolio 4: Digital Banking Platform
// MongoDB document model and transaction event queries

// 1. Select the banking events database
db = db.getSiblingDB("digital_banking_events");

// 2. Insert three sample transaction event documents
// Run this insert block only once.

db.transaction_events.insertMany([
  {
    _id: "EVT001",
    event_type: "transfer_completed",
    occurred_at: ISODate("2026-11-14T09:00:00Z"),
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
  },
  {
    _id: "EVT002",
    event_type: "transfer_pending",
    occurred_at: ISODate("2026-11-14T09:15:00Z"),
    transaction: {
      reference: "TXN-2026-0002",
      amount: 2500,
      currency: "NGN"
    },
    customer: {
      customer_id: 3,
      full_name: "Zuri James"
    },
    accounts: {
      sender: {
        account_number: "2000000003",
        account_holder: "Zuri James"
      },
      receiver: {
        account_number: "2000000001",
        account_holder: "Ada Okafor"
      }
    },
    details: {
      status: "Pending",
      description: "Transfer awaiting completion"
    }
  },
  {
    _id: "EVT003",
    event_type: "transfer_failed",
    occurred_at: ISODate("2026-11-14T09:30:00Z"),
    transaction: {
      reference: "TXN-2026-0003",
      amount: 1000,
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
      status: "Failed",
      description: "Transfer failed"
    }
  }
]);

// 3. Query 1: Count transaction event documents
print("Total transaction events:");
print(db.transaction_events.countDocuments());

// 4. Query 2: Retrieve Ada's outgoing transaction history
print("Ada's outgoing transaction history:");

printjson(
  db.transaction_events.find(
    { "accounts.sender.account_number": "2000000001" },
    {
      _id: 1,
      event_type: 1,
      occurred_at: 1,
      transaction: 1,
      details: 1
    }
  ).sort({ occurred_at: 1, _id: 1 }).toArray()
);

// 5. Query 3: Find successful transfers
print("Successful transfers:");

printjson(
  db.transaction_events.find(
    { "details.status": "Successful" }
  ).toArray()
);
