# Olist E-Commerce Analysis

An end-to-end portfolio project using **MySQL, Python, and Power BI** to analyse sales, delivery performance, customer satisfaction, seller performance, and payment behaviour in the Brazilian Olist marketplace.

The project combines SQL data checks, a Python exploratory analysis notebook, and a five-page Power BI report. **All business analyses use delivered orders with a recorded actual delivery date**, as defined by the `cleaned_orders` SQL view. Initial data-quality checks also inspect the full source tables.

## Business questions

- How do order volume, customer payments, and average order value change over time?
- Which categories and sellers contribute the most item value, including freight?
- Which customer states have the highest late-delivery rates?
- How do review scores differ between late and on-time deliveries?
- Which payment methods contribute the most payment value?
- What proportion of orders use installments?

## Tools and workflow

| Tool | Purpose |
| --- | --- |
| MySQL 8.0+ / MySQL Workbench | Data storage, schema setup, validation, analytical view, and SQL queries |
| Python: pandas, NumPy, Matplotlib | Data import, exploratory analysis, and charts |
| SQLAlchemy / PyMySQL | Python connection to MySQL |
| JupyterLab | Run the exploratory notebook |
| Power BI Desktop | Data model, measures, filters, drill-down, and reporting |

```text
Kaggle CSV files
    -> Python import into MySQL
    -> SQL data checks and schema setup
    -> cleaned_orders view
    -> SQL analysis and Python EDA
    -> Power BI dashboard
```

## Dataset

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The anonymised dataset covers approximately 100,000 orders from 2016 to 2018. This project imports eight source files:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `product_category_name_translation.csv`

Download and extract these files directly into a local `dataset/` folder at the repository root. Raw CSV files are excluded by `.gitignore`. The geolocation file is not required by this project.

Seller IDs are anonymised identifiers, not business names. Refer to the Kaggle page for licence and attribution terms. The downloadable PBIX contains imported data derived from this dataset.

## Power BI dashboard

[Download the latest Power BI dashboard](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/latest).

Open the release, download **`Olist-Ecommerce-Dashboard.pbix`** under **Assets**, and open it in Power BI Desktop. The PBIX is distributed through Releases rather than committed to the repository.

The saved report contains imported data. To refresh it, set up the local MySQL database and configure Power BI's data-source settings and credentials. In Power Query, the payments, order_items, and reviews queries retain only order IDs matching `cleaned_orders` using inner merges. Raw MySQL tables remain unchanged.

Dashboard previews are kept in the [screenshots folder](screenshots/). They should be captured from the published PBIX, with each filename matching its page.

| Page | Focus |
| --- | --- |
| Executive Overview | Payments, orders, AOV, reviews, delivery rates, time trends, and customer states |
| Sales & Product Performance | Category item value, satisfaction, and negative-review rankings |
| Delivery & Customer Satisfaction | Delivery duration, late rates by state, and review scores by delivery status |
| Seller Performance | Sellers with delivered orders, item value, order volume, and associated reviews |
| Payment Behavior | Payment methods, payment-record values, and order-level installment use |

The report includes page navigation, slicers, clear-slicer buttons, and date drill-down.

## Metric definitions

| Metric | Definition |
| --- | --- |
| Eligible orders / Total Orders | Orders in `cleaned_orders`: status `delivered` and a non-null actual delivery date |
| Total Revenue / Total Payment Value | Sum of payment values belonging to eligible orders; customer payments, not profit or Olist commission income |
| Item Revenue | Sum of item `price + freight_value` for eligible orders; used for category and seller attribution |
| Average Order Value | Eligible payment value divided by all eligible orders, including any order missing a payment record |
| Avg Items per Order | Eligible order-item rows divided by all eligible orders |
| Average Review Score | Mean of review records belonging to eligible orders |
| Negative Review Rate | Review records with scores 1 or 2 divided by all review records in the same selection |
| Sellers with Delivered Orders | Distinct seller IDs in eligible order-item rows |
| Total Categories | Category catalogue count; not a count of categories with sales in every date/state selection |
| Delivery Days | SQL `DATEDIFF(actual delivery, purchase timestamp)` |
| Delay Days | SQL `DATEDIFF(actual delivery, estimated delivery)` |
| Late Delivery Rate | Eligible orders delivered after their estimated timestamp divided by eligible orders |
| Total Transactions | Payment-record count, not distinct orders |
| Average Payment Value | Mean of payment values across eligible payment records |
| Orders Using Installments | Eligible orders with at least one payment record having more than one installment |
| Orders Using Installments % | Orders using installments divided by eligible orders with payment records |

Each order is classified once as **Uses installments** or **No installments** for the card and donut. No installments means no record exceeds one installment; it does not imply exactly one payment record. Payment-record comparisons separately classify zero or missing installment counts as **Unspecified**.

Item value and payment value come from different source records and need not be identical. Orders can contain multiple items, sellers, payment records, and review records. Review calculations use distinct order/category and order/seller associations before joining reviews, preventing repeated items from giving a review extra weight.

## Reconciled dashboard results

The following results were independently reconciled with the published dashboard's imported data with filters cleared:

| Metric | Result |
| --- | ---: |
| Delivered orders | 96,470 |
| Total payment value | 15,421,082.85 |
| Item value including freight | 15,418,394.83 |
| Average order value | 159.85 |
| Average items per order | 1.14 |
| Average review score | 4.16 |
| Negative-review rate | 12.81% |
| Late orders | 7,826 |
| Late delivery rate | 8.11% |
| On-time delivery rate | 91.89% |
| Orders using installments | 51.47% |
| Sellers with delivered orders | 2,970 |

Late deliveries average **31.48 days**, compared with **10.82 days** for on-time deliveries. Their associated average review scores are approximately **2.6** and **4.3**, respectively. This association supports investigating delivery performance; it does not establish causation.

As a small reconciliation example, `pc_gamer` has seven delivered-order review records, two negative reviews, a **28.57%** negative-review rate, and an average score of **3.43**. Seven reviews are too few to treat this category as a robust operational ranking by itself.

## Repository structure

```text
ecommerce-olist-analysis/
|-- README.md
|-- requirements.txt
|-- .gitignore
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
`-- screenshots/
    |-- Executive Overview.png
    |-- Sales & Product Performance.png
    |-- Delivery & Customer Satisfaction.png
    |-- Seller Performance.png
    `-- Payment Behavior.png
```

Create `dataset/` locally for the source CSVs. An optional local `powerbi/` folder can hold the downloaded PBIX. Neither folder needs to be committed.

## Reproducing the project

1. Install Python, MySQL Server **8.0 or later**, MySQL Workbench, and Power BI Desktop. The analytical SQL uses common table expressions. MySQL and Power BI are separate applications, not Python dependencies.

2. Download or clone the repository. Open a terminal in the repository root and install the Python dependencies:

   ```bash
   python -m pip install -r requirements.txt
   ```

3. Download the eight source CSVs and place them directly inside `dataset/`.

4. Create a dedicated database in MySQL Workbench:

   ```sql
   CREATE DATABASE olist_project;
   USE olist_project;
   ```

5. Check the connection settings in `python/import_to_mysql.py`. The defaults are `root`, `localhost`, port `3306`, and database `olist_project`. Passwords are entered through `getpass()` rather than stored in the code. From the repository root, run:

   ```bash
   python python/import_to_mysql.py
   ```

   The importer uses `if_exists="replace"`. Use a fresh project database: rerunning it replaces tables and can conflict with constraints added later.

6. With `olist_project` selected, run these files in order:

   ```text
   sql/01_data_checking.sql
   sql/modify_database.sql
   sql/02_cleaned_orders_view.sql
   ```

   Review the data-check results before applying the schema changes. `modify_database.sql` is an initial-setup script: run it once on the freshly imported tables. It is not designed to be rerun against an already configured database.

7. Run `03_sales_analysis.sql` through `07_seller_analysis.sql`. These analyses use the delivered-order population. Payment-record statistics and order-level statistics have separate labels.

8. Start JupyterLab:

   ```bash
   python -m jupyterlab
   ```

   Open `python/eda_olist.ipynb`, check the MySQL settings, and run all cells in order. Enter the database password when prompted. The notebook checks the raw tables first, then filters payments, items, and reviews to `cleaned_orders` before the business analyses. Saved outputs were cleared after the corrections; running the notebook regenerates its tables and charts.

9. Download the PBIX from the [latest release](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/latest). Configure its MySQL connection before refreshing. Preserve the delivered-order inner merges in Power Query.

10. Clear dashboard slicers and compare its main cards with the reconciliation table above. Different category/state/date selections, missing-category exclusions, and ranking thresholds can change results.

## Validation and limitations

- **Validation scope:** The PBIX's saved measures, relationships, and imported data were inspected, and key metrics were independently reconciled. This does not constitute testing every interactive slicer combination.
- **Reproduction:** A complete fresh MySQL setup and execution of the corrected notebook still need to be run in the user's local environment. Python dependency versions are not pinned.
- **Review attribution:** Reviews belong to orders. A multi-seller order's review cannot conclusively identify which seller caused satisfaction or dissatisfaction. Multi-category orders contribute their reviews to each relevant category.
- **Ranking rules:** The notebook's negative-review ranking requires at least 20 review records. The full SQL category-rate table has no minimum. Seller SQL comparisons require at least 20 delivered orders and a mean score below 3.5 where stated. Different thresholds can produce different rankings without changing metric definitions.
- **Missing categories:** SQL retains null category groups for reconciliation; some notebook charts and dashboard visuals omit blank labels. Visible category totals can therefore differ from overall cards.
- **Partial periods:** Dataset boundaries contain incomplete periods. Compare complete periods before interpreting apparent growth or decline.
- **Late classification:** The SQL view compares actual and estimated timestamps. Day differences use calendar dates, so a delivery can have zero delay days and still be classified as late.
- **Payment units:** One order can have several payment records or methods. Payment-record averages, value per order, and installment-use percentages answer different questions. Orders may appear in multiple payment-method or installment-count groups, while the order-level installment donut classifies each order once.

## Acknowledgments

Data provided by [Olist and collaborators on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). This is an independent educational project and is not affiliated with Olist.
