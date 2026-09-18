# Olist E-Commerce Analysis

An end-to-end portfolio project using **MySQL, Python, and Power BI** to explore sales, delivery performance, payment behavior, customer satisfaction, and seller performance in the Brazilian Olist marketplace.

The project combines relational data checks, SQL analysis, Python exploratory analysis, and a five-page interactive report. It is an exploratory portfolio project; seller/category review metrics and cross-table order scope remain under validation.

## Business questions

- How do order volume, customer payments, and average order value change over time?
- Which product categories and sellers contribute the most item sales value?
- How do delivery duration and late-delivery rates vary by customer state?
- How are delivery outcomes associated with review scores?
- Which payment methods are most used, and how many orders use installments?

## Tools and workflow

```text
Kaggle CSV files
    -> Python import into MySQL
    -> SQL data checks, schema changes, and cleaned_orders view
    -> SQL analysis and Python EDA
    -> Power BI model and interactive report
```

| Tool | Role |
| --- | --- |
| MySQL / MySQL Workbench | Data storage, relational checks, analytical view, business queries |
| Python: pandas, NumPy, Matplotlib | Data import, exploratory analysis, and plots |
| SQLAlchemy / PyMySQL | Python-to-MySQL connection |
| Power BI Desktop | Measures, slicers, drill-down, report navigation, and visual analysis |

## Dataset

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist and collaborators.

The anonymized dataset covers approximately 100,000 orders from 2016 to 2018. This project uses orders, order items, customers, products, sellers, payments, reviews, and category translations. Seller identifiers are anonymized IDs, not business names.

Download the eight source CSV files from Kaggle into `dataset/`. Raw CSV files are excluded from this repository configuration. Refer to the source dataset page for its license and attribution terms; a PBIX with imported data also contains a copy of source-derived data.

## Repository structure

```text
ecommerce-olist-analysis/
|-- README.md
|-- requirements.txt
|-- .gitignore
|-- dataset/                         # Local CSV downloads; not committed
|-- python/
|   |-- import_to_mysql.py
|   `-- eda_olist.ipynb
|-- sql/
|   |-- 01_data_checking.sql
|   |-- 02_cleaned_orders_view.sql
|   |-- 03_sales_analysis.sql
|   |-- 04_delivery_analysis.sql
|   |-- 05_customer_satisfaction.sql
|   |-- 06_payment_analysis.sql
|   |-- 07_seller_analysis.sql
|   `-- modify_database.sql
|-- powerbi/
|   `-- E-Commerce Sales, Customer Satisfaction, Delivery & Seller Performance Analysis Dashboard.pbix
`-- screenshots/
    |-- executive_overview.png
    |-- sales_product_performance.png
    |-- delivery_customer_satisfaction.png
    |-- seller_performance.png
    `-- payment_behavior.png
```

## Report pages

| Page | Focus |
| --- | --- |
| Executive Overview | Customer payment totals, orders, AOV, review score, delivery rates, time trends, customer states |
| Sales & Product Performance | Item sales by category, revenue versus satisfaction, negative-review rankings |
| Delivery & Customer Satisfaction | Delivery duration, state late-delivery rates, review scores by delivery status |
| Seller Performance | Seller item sales, order volume, satisfaction comparisons, seller states |
| Payment Behavior | Payment methods, payment values, installment distribution, order-level installment usage |

The report includes page navigation, slicers, clear-slicer buttons, and date drill-down. Screenshots are static previews; use Power BI Desktop to explore the interactions.

## Metric definitions and scope

| Metric | Definition / interpretation |
| --- | --- |
| Total Revenue / Total Payment Value | Sum of `payments.payment_value`; customer payment value, not profit or Olist commission income |
| Item Revenue | Sum of item `price + freight_value`; used to attribute item sales value to sellers and categories |
| Delivered-order population | `cleaned_orders`: orders with `order_status = 'delivered'` and a non-null actual delivery date |
| Delivery Days | SQL `DATEDIFF(actual delivery, purchase timestamp)` |
| Delay Days | SQL `DATEDIFF(actual delivery, estimated delivery)` |
| Late Delivery Rate | Late orders divided by eligible delivered orders |
| Average Order Value | Payment value divided by distinct orders in the intended matching order population; not average payment-record value |
| Average Payment Value | Average `payment_value` across payment records |
| Orders Using Installments | Distinct orders with at least one payment record where `payment_installments > 1` |
| Order Payment Plan | Each order belongs to one group: Uses installments or No installments, even when it has several payment records |
| Negative reviews | Review scores of 1 or 2; the aggregation grain must be checked when comparing categories or sellers |

The SQL view classifies lateness by comparing actual and estimated timestamps. Its day differences use calendar dates, so a same-date delivery can have zero delay days while still being classified as late if its timestamp is later than the estimate.

Payment analysis uses payment records unless explicitly labelled as orders. The seller table filters `Total Orders > 0`; this controls visible sellers but does not itself restrict every revenue or review calculation to delivered orders. The category table excludes blank category labels, so its visible totals can differ from overall cards.

## Observations from the report

The saved dashboard screenshots show the following descriptive patterns. They are report observations, not evidence of causal effects or a completed independent reconciliation of all measures.

- Late deliveries show an average duration of **31.48 days**, compared with **10.82 days** for on-time deliveries.
- The displayed average review score is lower for late deliveries (**2.6**) than for on-time deliveries (**4.3**). This is an association, not proof that delay alone caused the score difference.
- **51.46%** of orders use installments in the displayed selection. The order-level card and donut agree.
- Credit cards account for the largest displayed payment value.
- Sao Paulo (SP) leads the displayed customer-state and seller-state sales comparisons.

These patterns suggest investigating delivery routes with high late rates and substantial order volumes. Seller/category satisfaction rankings should be validated before using them to recommend interventions. Compare complete time periods before interpreting an end-of-dataset decline.

## Reproducing the project

The repository currently uses a local MySQL workflow. The following steps describe the intended setup; a clean-machine execution has not yet been verified.

1. Install Python, MySQL, MySQL Workbench, and Power BI Desktop. Install Python dependencies from the repository root:

   ```bash
   python -m pip install -r requirements.txt
   ```

2. Download the eight CSV files listed in `python/import_to_mysql.py` into `dataset/`.

3. Create and select a dedicated database in MySQL Workbench:

   ```sql
   CREATE DATABASE olist_project;
   USE olist_project;
   ```

4. Configure the importer and notebook with local credentials kept outside source code. Use the connection pattern in `PUBLISH_CHECKLIST.md` if they have not yet been updated. Do not commit a password or populated `.env` file.

5. Run the importer from the repository root:

   ```bash
   python python/import_to_mysql.py
   ```

   The current importer uses `if_exists="replace"`. Run it against a fresh project database; rerunning it can replace tables and conflict with constraints added later.

6. Run `01_data_checking.sql`. Review and execute `modify_database.sql` on the fresh imported schema, then create `cleaned_orders` with `02_cleaned_orders_view.sql`. The schema script changes tables and is not designed for repeated execution. Keep `olist_project` selected for scripts without their own `USE` statement.

7. Run the analytical SQL files `03` through `07`. Before running the current delivery script, correct its two undefined `o` aliases as described in `PUBLISH_CHECKLIST.md`.

8. Open `python/eda_olist.ipynb`, configure its local database connection, and run cells in order. The notebook reads its tables and the analytical view from MySQL.

9. Open the PBIX in Power BI Desktop. Configure its MySQL data-source settings and credentials for the local database before refreshing. Recheck measures and filter behavior after refresh.

## Validation status and limitations

- Seller/category review-score filtering and consistency of delivered-order scope across measures remain under validation. Hiding zero-order sellers does not prove that their underlying review calculations are correct.
- Some SQL and notebook analyses join reviews to item rows. This can weight a review multiple times for multi-item orders; multiple reviews for an order can also duplicate item amounts in joined SQL revenue sums. Aggregation grain must be reconciled before treating those rankings as final.
- Reviews belong to orders. A review on a multi-seller order cannot conclusively attribute satisfaction or dissatisfaction to an individual seller.
- Missing categories are excluded from the category table rather than resolved in the source data.
- Date coverage is incomplete at the dataset boundaries. Partial periods should not be compared directly with complete periods without qualification.
- Payment SQL and dashboard measures have different units in some places. Payment-record averages, payment value per order, and order-level installment rates must be labelled distinctly.

## Acknowledgments

Data provided by [Olist and collaborators on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). This is an independent educational analysis and is not affiliated with Olist.
