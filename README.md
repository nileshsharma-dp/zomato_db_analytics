# Zomato SQL Data Analysis: End-to-End Relational Database Project
---


![](https://github.com/nileshsharma-dp/zomato_db_analytics/blob/main/Images/zomato_main_3.jpg)


## Project Overview
This project is an end-to-end data analysis case study focused on Zomato-like food delivery operations using SQL. The objective is to model, populate, and query a relational database to derive insights about restaurants, users, orders, and reviews. It’s perfect for aspiring data analysts or database engineers looking to deepen their SQL, data modeling, and business intelligence skills.

---

## Project Steps

### 1. Set Up the Environment
- **Tools Used**: PostgreSQL (or MySQL), VS Code, DB Browser (or pgAdmin), Git
- **Goal**: Establish a workspace and SQL environment to build and test relational queries.

### 2. Review the Database Schema
- **Schema Components**:
  - Users, Restaurants, Menu Items, Orders, Order Details, Reviews
- **Entity-Relationship Diagram**: Defines one-to-many relationships such as:
  - One user → many orders and reviews
  - One restaurant → many orders, menu items, and reviews

### 3. Create Database Tables
- **SQL Scripts**: Use DDL (Data Definition Language) to create normalized tables.
- **Constraints**: Include foreign keys, primary keys, and appropriate data types to ensure integrity.
- **Example**:
```sql
CREATE TABLE Users (
  user_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(15),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. Populate Tables with Sample Data
- **Data Insertion**: Use SQL `INSERT` statements or CSV imports.
- **Validation**: Run simple queries to verify the data loads correctly.

### 5. SQL Analysis: Business-Focused Queries
- **Core Analyses**:
  - Which restaurants have the highest average ratings?
  - What are the top 5 best-selling menu items?
  - Which users place the most orders?
  - What is the average spend per order by city or cuisine?
  - When are peak order times?

- **Sample Query**:
```sql
SELECT restaurant_id, AVG(rating) AS avg_rating
FROM Reviews
GROUP BY restaurant_id
ORDER BY avg_rating DESC
LIMIT 5;
```

### 6. Optimization and Indexing
- **Indexes**: Add indexes on foreign keys or frequently filtered fields to optimize query performance.
- **Normalization Check**: Ensure no redundancy or anomalies in data.

### 7. Reporting and Visualization (Optional)
- Export query results to Excel or integrate with tools like Power BI or Tableau for visual dashboards.

---

## Requirements

- **SQL Engine**: PostgreSQL or MySQL
- **Tools**: VS Code, pgAdmin, DBeaver, or any SQL IDE
- **Optional**: Python with `psycopg2` or `sqlalchemy` if automating queries

---

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/nileshsharma-dp/zomato_db_analytics.git

   ```
2. Open the SQL scripts from the `sql/` folder in your SQL IDE.
3. Run the schema creation script followed by the data population script.
4. Execute the analysis queries from `zomato_eda.sql`.

---

### ERD Diagram

![ERD Diagram](https://github.com/nileshsharma-dp/zomato_db_analytics/blob/main/Images/ERD_Diagram.png)

---
## Project Structure

```plaintext
📦 Zomato_Project
├── 📂 Documents
│   ├── 📘 README.md (Project Overview)
│   └── 📒 sql_queries.md (All SQL Commands)
├── 📂 assets
│   └── 📂 Images
│       ├── 🖼️ zomato_main_1.png (readme main page)
│       ├── 🖼️ zomato_main_2.png (queries main page)
│       ├── 🖼️ zomato_main_3.jpg (UI Screenshot)
│       ├── 📊 ERD_Diagram.png (Database Schema)
│       ├── 🔷 Logo.svg (Branding)
│       └── 🔶 Symbol.svg (Favicon)
├── 📂 sql
│   ├── 📝 zomato_tables.sql (Table Definitions)
│   └── 📝 zomato_eda.sql (Analysis Queries)
└── 📂 data
    ├── 📄 orders.csv (Order Records)
    ├── 📄 customers.csv (User Data)
    ├── 📄 restaurants.csv (Vendor Info)
    ├── 📄 deliveries.csv (Logistics)
    └── 📄 riders.csv (Delivery Partners)
```

---

## Results and Insights

- **Restaurant Ratings**: Identified top-rated restaurants by average score.
- **Sales Trends**: Pinpointed high-demand dishes and peak order times.
- **User Behavior**: Found power users and loyal customer patterns.
- **Revenue Analysis**: Measured total and average order values per restaurant.

---

## Future Enhancements

- Add stored procedures for repetitive analytics.
- Automate reporting with Python scripts.
- Connect to BI tools for interactive dashboards.
- Expand the schema to include delivery partners and payment logs.

---

## License

This project is licensed under the MIT License.

---

## Acknowledgments

- Inspired by Zomato's operational model.
- Diagram based on conceptual schema adapted from ERD visual guides.
