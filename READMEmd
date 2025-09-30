# db-engine

A lightweight, Bash-based database engine that uses directories and CSV files to emulate basic database functionalities. This project allows you to create databases, tables, schemas, and manage data right from your shell—no dependencies required beyond Bash and basic Unix utilities.

## Features

- **Create Database:** Make a new directory as your database.
- **Create Table:** Create CSV files as tables inside your database.
- **Define Schema:** Setup schemas (column definitions, types, constraints) for tables.
- **Link Schema to Table:** Metadata linking schemas to tables.
- **Add Constraints:** Specify required, optional, and unique columns.
- **Insert Rows:** Add new rows with auto-generated IDs, respecting schema constraints.
- **Select Rows:** Search for rows based on column criteria.

## How It Works

All commands are Bash functions defined in `main.sh`. To use them, source the file in your shell:

```bash
source main.sh
```

## Commands

### Create Database

```bash
mostafa-db create db <database-name>
```
Creates a new directory as your database.

### Create Table

```bash
table.create <db-name> create <table-name>
```
Creates a new CSV file (table) in your database.

### Define Schema

```bash
schema.create <schema-name> <db-name>
```
Creates a schema CSV file to define columns and constraints.

### Link Schema to Table

```bash
schema.link <schema-name> <table-name> <db-name>
```
Links a schema to a table, storing metadata in the table's file.

### Add Constraints to Schema

```bash
schema.constrains <schema-name> <db-name> "[col-name, data-type, required|optional, unique]"
```
Adds columns and constraints to a schema. You can add multiple constraints at once.

**Example:**
```bash
schema.constrains my-schema my-db "[name, string, required, unique]" "[age, int, optional]"
```

### Insert Row Into Table

```bash
table.insert <table-name> <db-name> {col_name: col_data, ...}
```
Inserts a new row, automatically generates an `id`, and checks constraints.

**Example:**
```bash
table.insert users my-db "{name: 'John Doe', age: 30, email: 'john@example.com'}"
```

### Select Rows

```bash
table.select <table-name> <db-name> {col_name: col_data, ...}
```
Selects rows matching criteria.

**Example:**
```bash
table.select users my-db "{email: 'john@example.com'}"
```

## Notes

- All data is stored locally using directories and CSV files.
- Schema constraints: `required`, `optional` (default is optional), `unique` (default is not unique).
- The `id` column is auto-generated and cannot be manually inserted.
- To use the functions, always source `main.sh` in your shell session.

## Example Workflow

```bash
source main.sh

mostafa-db create db my_db
table.create my_db create users
schema.create user_schema my_db
schema.constrains user_schema my_db "[name, string, required, unique]" "[email, string, required, unique]" "[age, int, optional]"
schema.link user_schema users my_db
table.insert users my_db "{name: 'Alice', email: 'alice@example.com', age: 25}"
table.select users my_db "{email: 'alice@example.com'}"
```

## Limitations & TODOs

- Only basic insert/select functionality provided. Delete/update not yet implemented.
- No support for complex queries.
- All data and schema definitions are stored as plain files; not suitable for production.

## Project Status

### ✅ What’s Done

- **Database Creation:** You can create a new database (directory).
- **Table Creation:** You can create new tables (CSV files) within a database.
- **Schema Creation:** You can define schemas specifying columns, types, and constraints.
- **Schema Linking:** You can link schemas to tables, storing column metadata.
- **Schema Constraints:** You can add required and unique constraints to schema columns.
- **Row Insertion:** You can insert new rows into tables, with auto-generated IDs and schema validation.
- **Row Selection:** You can select/search for rows in tables using column criteria.

### 🛠️ What’s To Be Done

- **Row Deletion:** Ability to delete rows from tables.
- **Row Update:** Ability to update/modify existing row data.
- **Advanced Querying:** Support for more complex queries and search functionalities.
- **Data Validation:** Enhanced validation for data types and formats.
- **Error Handling:** Improved error messages and robustness.
- **Backup/Restore:** Utilities for data backup and restoration.
- **Concurrency:** Handling simultaneous operations safely.
- **Documentation:** More examples and detailed usage guides.

---

Feel free to open issues or contribute to any of the above!
## Author

Mostafa Kadry

---

Feel free to contribute or suggest improvements!