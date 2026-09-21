# Olist E-Commerce Analysis

An end-to-end portfolio project using **MySQL, Python, and Power BI** to analyse sales, delivery performance, customer satisfaction, seller performance, and payment behaviour in the Brazilian Olist marketplace.

The project combines SQL data checks, Python exploratory analysis, and a five-page interactive Power BI dashboard.

**Analysis scope:** Delivered orders with a recorded actual delivery date, as defined by the `cleaned_orders` SQL view. Initial data-quality checks also inspect the full source tables.

## Business Questions

- How do order volume, customer payments, and average order value change over time?
- Which product categories and sellers contribute the most item value?
- Which customer states have the highest late-delivery rates?
- How do customer review scores differ between late and on-time deliveries?
- Which payment methods contribute the most payment value?
- What proportion of orders use installments?

## Tools and Workflow

| Tool | Purpose |
| --- | --- |
| MySQL 8.0+ / MySQL Workbench | Data storage, schema setup, validation, analytical view, and SQL analysis |
| Python: pandas, NumPy, Matplotlib | Data import, exploratory analysis, and visualisation |
| SQLAlchemy / PyMySQL | Python connection to MySQL |
| JupyterLab | Execute the exploratory analysis notebook |
| Power BI Desktop | Data modelling, measures, slicers, drill-down, and reporting |

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

The anonymised dataset contains approximately 100,000 orders from 2016 to 2018. This project uses eight source files:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `product_category_name_translation.csv`

Download and extract these files directly into a local `dataset/` folder at the repository root.

Raw CSV files are excluded by `.gitignore`. The geolocation file is not required by this project.

Seller IDs are anonymised identifiers, not business names. Refer to the Kaggle dataset page for licence and attribution terms. The downloadable Power BI file contains imported data derived from this dataset.

## Power BI Dashboard

[Download the latest Power BI dashboard](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/latest).

Open the release, download **`Olist-Ecommerce-Dashboard.pbix`** under **Assets**, and open it in Power BI Desktop.

The PBIX is distributed through GitHub Releases rather than committed to the repository. Dashboard previews are available in the [screenshots folder](screenshots/).

The saved report contains imported data. To refresh it, configure the local MySQL database and update the data-source settings and credentials in Power BI Desktop.

In Power Query, the payments, order items, and reviews queries retain only order IDs matching `cleaned_orders` through inner merges. These transformations do not delete records from the source MySQL tables.

### Dashboard Pages

| Page | Focus |
| --- | --- |
| Executive Overview | Payments, orders, average order value, reviews, delivery rates, time trends, and customer states |
| Sales & Product Performance | Category item value, customer satisfaction, and negative-review rankings |
| Delivery & Customer Satisfaction | Delivery duration, late-delivery rates by state, and reviews by delivery status |
| Seller Performance | Sellers with delivered orders, item value, order volume, and associated reviews |
| Payment Behavior | Payment methods, payment-record values, installment distribution, and order-level installment use |

The dashboard includes page navigation, slicers, clear-slicer buttons, and date drill-down.

## Metric Definitions

| Metric | Definition |
| --- | --- |
| Total Orders | Orders in `cleaned_orders`: status `delivered` and a non-null actual delivery date |
| Total Revenue / Total Payment Value | Sum of payment values belonging to eligible delivered orders |
| Item Revenue | Sum of item `price + freight_value` for eligible orders, used for category and seller attribution |
| Average Order Value | Eligible payment value divided by all eligible orders, including any order missing a payment record |
| Average Items per Order | Eligible order-item rows divided by all eligible orders |
| Average Review Score | Mean of review records belonging to eligible orders |
| Negative Review Rate | Review records with scores 1 or 2 divided by all review records in the same selection |
| Sellers with Delivered Orders | Distinct seller IDs in eligible order-item rows |
| Total Categories | Category catalogue count, rather than categories with sales under every date or state selection |
| Delivery Days | SQL `DATEDIFF(actual delivery, purchase timestamp)` |
| Delay Days | SQL `DATEDIFF(actual delivery, estimated delivery)` |
| Late Delivery Rate | Eligible orders delivered after their estimated timestamp divided by eligible orders |
| Total Transactions | Payment-record count, not distinct order count |
| Average Payment Value | Mean payment value across eligible payment records |
| Orders Using Installments | Eligible orders with at least one payment record having more than one installment |
| Orders Using Installments % | Orders using installments divided by eligible orders with payment records |

### Important Distinctions

- **Total Revenue represents customer payment value**, not profit or Olist commission income.
- **Item Revenue includes freight.** It is not product price alone.
- Payment value and item value come from different source records and are not required to be identical.
- One order can contain multiple items, sellers, payment records, and review records.
- Category and seller review calculations use distinct order/category or order/seller associations before joining reviews. This prevents repeated items from giving a review extra weight.
- The installment card and donut classify each order once as **Uses installments** or **No installments**.
- **No installments** means no payment record exceeds one installment. It does not mean the order necessarily has exactly one payment record.
- Payment-record comparisons separately classify zero or missing installment counts as **Unspecified**.

## Reconciled Dashboard Results

The following results were independently reconciled with the published dashboard’s imported data with filters cleared:

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

These results describe the eligible delivered-order population. Changing dashboard filters changes the population used by the relevant measures.

## Key Insights and Recommendations

### 1. Late Deliveries Are Associated with Lower Customer Satisfaction

Late deliveries averaged **31.48 days**, compared with **10.82 days** for on-time deliveries.

Their associated average review scores were approximately **2.6** and **4.3**, respectively.

**Recommendation:** Investigate delivery delays on routes with both high late-delivery rates and substantial order volumes. This relationship is an association, not proof that delivery delays alone caused low review scores.

### 2. Health and Beauty Leads Category Item Value

Health and Beauty generated the highest item value, including freight, among the categories shown in the dashboard. Its average review score was approximately **4.23**.

**Recommendation:** Monitor fulfilment capacity and service quality in this high-value category. Revenue alone does not establish profitability.

### 3. Installments Are Used by Slightly More Than Half of Payment Orders

**51.47%** of eligible orders with payment records used installments. Credit cards contributed the largest total payment value.

**Recommendation:** Treat installment availability as an important payment feature. Further analysis would be needed to determine whether offering installments increases customer spending or conversion.

### 4. São Paulo Leads the State Sales Comparisons

São Paulo ranked first for both customer-state payment value and seller-state item value.

**Recommendation:** Prioritise operational monitoring in this major market while evaluating other states using both sales volume and delivery performance.

### Interpreting Category Rankings

High negative-review percentages should be considered alongside sample sizes.

For example, `pc_gamer` has **seven delivered-order review records**, including two negative reviews. This gives a **28.57% negative-review rate** and an average score of **3.43**.

The calculation is valid, but seven reviews are too few to treat the category’s position as a strong operational conclusion on its own.

## Repository Structure

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

Create `dataset/` locally for the source CSV files. An optional local `powerbi/` folder can hold the downloaded PBIX. Neither folder needs to be committed to GitHub.

## Reproducing the Project

### 1. Install the Required Software

Install:

- Python
- MySQL Server **8.0 or later**
- MySQL Workbench
- Power BI Desktop

The analytical SQL uses common table expressions. MySQL and Power BI are separate applications and are not installed through `requirements.txt`.

### 2. Install Python Dependencies

Download or clone the repository, then open a terminal in its root folder:

```bash
python -m pip install -r requirements.txt
```

### 3. Download the Dataset

Download the eight source CSV files from Kaggle and place them directly inside:

```text
ecommerce-olist-analysis/dataset/
```

### 4. Create the Database

Run the following in MySQL Workbench:

```sql
CREATE DATABASE olist_project;
USE olist_project;
```

### 5. Import the CSV Files

Check the connection settings in `python/import_to_mysql.py`.

The default settings use:

- Host: `localhost`
- Port: `3306`
- Username: `root`
- Database: `olist_project`

The password is requested through `getpass()` rather than stored in the source code.

From the repository root, run:

```bash
python python/import_to_mysql.py
```

The importer uses `if_exists="replace"`. Use a fresh project database: rerunning the importer replaces tables and can conflict with constraints added later.

### 6. Check the Data and Configure the Schema

With `olist_project` selected in MySQL Workbench, run these files in order:

```text
sql/01_data_checking.sql
sql/modify_database.sql
sql/02_cleaned_orders_view.sql
```

Review the data-check results before applying schema changes.

**Run `modify_database.sql` only once on freshly imported tables.** It is an initial-setup script and is not designed for repeated execution against an already configured database.

### 7. Run the SQL Analyses

Run:

```text
sql/03_sales_analysis.sql
sql/04_delivery_analysis.sql
sql/05_customer_satisfaction.sql
sql/06_payment_analysis.sql
sql/07_seller_analysis.sql
```

The corrected analyses use the delivered-order population. Payment-record statistics and order-level statistics are labelled separately.

### 8. Run the Python Notebook

Start JupyterLab:

```bash
python -m jupyterlab
```

Open:

```text
python/eda_olist.ipynb
```

Check its MySQL connection settings, enter the password when prompted, and run all cells in order.

The notebook checks the raw tables first, then filters payments, items, and reviews to `cleaned_orders` before performing the business analyses.

Saved outputs were cleared when the calculations were corrected. Running the notebook regenerates its tables and charts. Save the executed notebook if you want those results visible on GitHub.

### 9. Open the Power BI Dashboard

Download the PBIX from the [latest release](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/latest).

Open it in Power BI Desktop. Configure its MySQL data-source settings before refreshing, and preserve the delivered-order inner merges in Power Query.

### 10. Check the Results

Clear the dashboard slicers and compare the main cards with the **Reconciled Dashboard Results** table above.

Category, state, date, and delivery-status selections can change the results. Missing-category exclusions and ranking thresholds can also affect which rows appear in individual visuals.

## Validation and Limitations

- **Validation scope:** The PBIX’s saved measures, relationships, and imported data were inspected, and key metrics were independently reconciled. This does not constitute testing every interactive slicer combination.

- **Reproduction:** A complete fresh MySQL setup and execution of the corrected notebook still need to be verified in the local environment. Python dependency versions are not pinned.

- **Review attribution:** Reviews belong to orders. For multi-seller orders, a review cannot conclusively identify which seller caused satisfaction or dissatisfaction. Multi-category orders contribute their reviews to each relevant category.

- **Ranking thresholds:** The notebook’s negative-review ranking requires at least 20 review records. The full SQL category-rate table has no minimum. Seller SQL comparisons require at least 20 delivered orders and an average score below 3.5 where stated. Different thresholds can produce different rankings without changing the underlying metric definitions.

- **Missing categories:** SQL retains null category groups for reconciliation. Some notebook charts and dashboard visuals omit blank labels, so visible category totals can differ from overall cards.

- **Partial periods:** The dataset boundaries contain incomplete periods. Compare complete periods before interpreting apparent growth or decline.

- **Late classification:** The SQL view compares actual and estimated timestamps. Day differences use calendar dates, so a delivery can have zero delay days and still be classified as late.

- **Payment units:** One order can have several payment records or methods. Payment-record averages, value per order, and installment-use percentages answer different questions. Orders may appear in multiple payment-method or installment-count groups, while the order-level installment donut classifies each order once.

- **Business interpretation:** The analysis is descriptive. It does not establish causal effects, profitability, or the effectiveness of proposed interventions.

## Acknowledgments

Data provided by [Olist and collaborators on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

This is an independent educational portfolio project and is not affiliated with Olist.
