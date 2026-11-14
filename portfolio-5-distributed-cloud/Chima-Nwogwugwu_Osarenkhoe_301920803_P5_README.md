
# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

The Digital Banking Platform uses PostgreSQL for its relational banking records, including customers, accounts, beneficiaries and bank transactions. MongoDB was introduced in Portfolio 4 to demonstrate a document-based approach to recording transaction events.

MongoDB Community Server 8.0.38 and MongoDB Shell 2.14.2 are installed in the Ubuntu 24.04 GitHub Codespace. MongoDB runs locally, using `/workspaces/mongodb-data` for its database files and `127.0.0.1:27017` for local connections. The Codespaces port visibility is Private.

The current setup demonstrates PostgreSQL and MongoDB running in the same Codespace. A multi-node MongoDB replica set, separate hosts, cloud deployment and replication tests have not been verified. The current environment should therefore not be described as a distributed production deployment.

## Proposed replication

For a production banking environment, I propose a three-member MongoDB replica set. Each member would hold a copy of the transaction event data, with all three members voting in elections. They should run on separate hosts and failure zones to reduce the risk of one infrastructure failure affecting every member.

| Member | Starting role | Location |
|---|---|---|
| Member 1 | Primary | Host A – Failure Zone 1 |
| Member 2 | Secondary | Host B – Failure Zone 2 |
| Member 3 | Secondary | Host C – Failure Zone 3 |

The primary accepts writes, while the secondary members copy and apply changes from the primary's operation log. For example, when a `transfer_status_updated` event records that `TXN-2026-0001` is Successful, the event would be replicated to the secondary members. This provides additional copies of the MongoDB event records. ([MongoDB replication](https://www.mongodb.com/docs/manual/replication/))

## Failure and consistency

If the primary becomes unavailable, the remaining eligible members can hold an election. A majority of the three voting members (two) is required to elect a new primary. During the election, writes are temporarily interrupted until a new primary is elected. If the remaining members cannot reach a majority, the replica set cannot elect a primary and cannot accept writes. ([Replica set elections](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/))

Using `w: "majority"` write concern means a write is acknowledged after the required majority of data-bearing voting members confirms it. In this three-member design, two members must acknowledge the write. However, secondary replication is asynchronous, so a secondary can temporarily lag behind the primary. ([Write concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/))

MongoDB replication would protect the MongoDB event records only. PostgreSQL remains responsible for its relational banking records and authoritative banking operations. Replication does not automatically synchronise PostgreSQL with MongoDB.

## Sharding and cloud deployment

Replication copies data to other members; sharding splits a collection's records across multiple shards to distribute storage and workload. Sharding is unnecessary for this small portfolio example because its four event documents do not justify the additional infrastructure and operational complexity. ([MongoDB sharding](https://www.mongodb.com/docs/manual/sharding/))

A future cloud deployment could use MongoDB Atlas with appropriate authentication, encryption in transit and at rest, restricted network access, and tested backup and restore procedures. Atlas backup capabilities and availability depend on the cluster tier. ([Atlas backup and restore](https://www.mongodb.com/docs/atlas/backup-restore-cluster/))

Cloud hosting and multiple replica members introduce ongoing costs for compute, storage, network traffic, backups and administration. A further limitation is that replication improves MongoDB availability but does not replace application-level controls or guarantee consistency between MongoDB and PostgreSQL.
