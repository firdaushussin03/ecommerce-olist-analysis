# Olist E-Commerce Analysis

An end-to-end portfolio project using **MySQL, Python, and Power BI** to explore sales, delivery performance, customer satisfaction, seller performance, and payment behavior in the Brazilian Olist marketplace.

The project combines SQL data checks and analysis, Python exploratory data analysis, and a five-page interactive Power BI report. Seller/category review calculations and consistency of order scope across tables remain under validation.

## Business questions

- How do order volume, customer payments, and average order value change over time?
- Which product categories and sellers contribute the most item sales value?
- Which customer states have the highest late-delivery rates?
- How do review scores differ between late and on-time deliveries?
- Which payment methods contribute the most payment value, and how many orders use installments?

## Tools and workflow

| Tool | Purpose |
| --- | --- |
| MySQL / MySQL Workbench | Data storage, data checks, schema changes, analytical view, and business queries |
| Python: pandas, NumPy, Matplotlib | Data import, exploratory analysis, and visualization |
| SQLAlchemy / PyMySQL | Python connection to MySQL |
| Power BI Desktop | Data modeling, measures, slicers, drill-down, and interactive reporting |

```text
Kaggle CSV files
    -> Python import into MySQL
    -> SQL data checks, schema changes, and cleaned_orders view
    -> SQL analysis and Python EDA
    -> Power BI dashboard
```

## Dataset

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The anonymized dataset covers approximately 100,000 orders from 2016 to 2018. This project uses eight source files:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `product_category_name_translation.csv`

Download and extract these files into a local `dataset/` folder at the repository root. Raw CSV files are not included in the repository and are excluded by `.gitignore`. The geolocation file is not required by the importer.

Seller IDs are anonymized identifiers, not business names. Refer to the Kaggle dataset page for its license and attribution terms. The downloadable PBIX also contains imported, source-derived data.

## Dashboard download

Download the `.pbix` asset from the [Power BI dashboard v1.0 release](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/tag/v1.0.0) and open it in Power BI Desktop.

To refresh the data, set up the local MySQL database using the instructions below and update the dashboard's data-source settings and credentials.

The dashboard is distributed through GitHub Releases rather than committed to the repository. Dashboard previews are available in the [screenshots folder](screenshots/).

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

Create `dataset/` locally for the downloaded CSV files. The PBIX can be stored locally in an optional `powerbi/` folder; neither folder needs to be uploaded to GitHub.

## Dashboard pages

| Page | Focus |
| --- | --- |
| Executive Overview | Payment totals, orders, average order value, reviews, delivery rates, time trends, and customer states |
| Sales & Product Performance | Item sales by category, revenue versus satisfaction, and negative-review rankings |
| Delivery & Customer Satisfaction | Delivery duration, late-delivery rates by state, and review scores by delivery status |
| Seller Performance | Seller item sales, order volume, satisfaction comparisons, and seller states |
| Payment Behavior | Payment methods, payment values, installment distribution, and order-level installment use |

The report includes page navigation, slicers, clear-slicer buttons, and date drill-down.

## Metric definitions

| Metric | Definition |
| --- | --- |
| Total Revenue / Total Payment Value | Sum of `payments.payment_value`: customer payment value, not profit or Olist commission income |
| Item Revenue | Sum of item `price + freight_value`, used for seller and category sales attribution |
| Delivered-order population | `cleaned_orders`: orders with `order_status = 'delivered'` and a non-null actual delivery date |
| Delivery Days | SQL `DATEDIFF(actual delivery, purchase timestamp)` |
| Delay Days | SQL `DATEDIFF(actual delivery, estimated delivery)` |
| Late Delivery Rate | Late orders divided by eligible delivered orders |
| Average Order Value | Payment value divided by distinct orders in the matching order population |
| Average Payment Value | Average `payment_value` across payment records |
| Orders Using Installments | Distinct orders with at least one payment record where `payment_installments > 1` |
| Order Payment Plan | Each order is classified once as Uses installments or No installments |
| Negative Reviews | Reviews with a score of 1 or 2 |

The SQL view compares actual and estimated timestamps to classify lateness. Its day differences use calendar dates, so a delivery can have zero delay days and still be classified as late when its timestamp is later than the estimate.

Payment records and orders are different units: one order can have multiple payment records. The installment-use card and donut use order-level classification to avoid counting one order in both groups.

## Observations from the report

The saved report shows these descriptive patterns in its displayed selection:

- Late deliveries average **31.48 days**, compared with **10.82 days** for on-time deliveries.
- Average review scores are **2.6 for late deliveries** and **4.3 for on-time deliveries**.
- **51.46% of orders use installments**; the order-level card and donut agree.
- Credit cards contribute the largest displayed payment value.
- Sao Paulo (SP) leads the displayed customer-state and seller-state sales comparisons.

These observations suggest investigating delivery routes with high late rates and substantial order volumes. They describe associations, not proof of causation. Seller/category satisfaction rankings require the validation described below before being used to recommend interventions.

## Reproducing the project

The project uses a local MySQL workflow. A complete clean-machine execution has not yet been verified.

1. Install Python, MySQL Server, MySQL Workbench, and Power BI Desktop. MySQL and Power BI are separate applications and are not installed by `requirements.txt`.

2. Download or clone this repository and open a terminal in its root folder. Install the Python dependencies:

   ```bash
   python -m pip install -r requirements.txt
   ```

3. Download the eight CSV files listed above and place them directly inside `dataset/`.

4. Create a dedicated database in MySQL Workbench:

   ```sql
   CREATE DATABASE olist_project;
   USE olist_project;
   ```

5. Check the connection settings in `python/import_to_mysql.py`. The default connection uses `root`, `localhost`, port `3306`, and database `olist_project`. The password is entered using `getpass()` instead of being stored in the source code. Run the importer from the repository root:

   ```bash
   python python/import_to_mysql.py
   ```

   The importer uses `if_exists="replace"`. Use a fresh project database: rerunning it replaces tables and can conflict with constraints added later.

6. In MySQL Workbench, keep `olist_project` selected. Run `sql/01_data_checking.sql`, review and execute `sql/modify_database.sql`, then run `sql/02_cleaned_orders_view.sql`. The schema modification script is intended for the initial setup and is not designed for repeated execution.

7. Run analytical SQL files `03_sales_analysis.sql` through `07_seller_analysis.sql`.

8. Start JupyterLab:

   ```bash
   python -m jupyterlab
   ```

   Open `python/eda_olist.ipynb`, check its database connection settings, enter the MySQL password when prompted, and run the cells in order.

9. Download the PBIX from the [published release](https://github.com/firdaushussin03/ecommerce-olist-analysis/releases/tag/v1.0.0). Open it in Power BI Desktop. Before refreshing, configure its MySQL data-source settings and credentials for your local database.

Python dependency versions are not pinned; this repository does not yet provide a fully tested, reproducible environment lockfile.

## Validation status and limitations

- **Order scope:** Consistency of the delivered-order population across payment, item, seller, and review measures remains under validation. Filtering the seller table to `Total Orders > 0` controls visible sellers but does not itself restrict every underlying calculation to delivered orders.
- **Join duplication:** Some SQL and notebook analyses join reviews directly to item rows. Multi-item orders can cause a review to receive extra weight; multiple reviews for one order can duplicate item amounts in joined revenue sums. These aggregations need reconciliation before treating rankings as final.
- **Review attribution:** Reviews belong to orders. For a multi-seller order, a review cannot conclusively identify which seller caused satisfaction or dissatisfaction.
- **Missing categories:** The category table excludes blank category labels rather than resolving the missing source values. Its visible totals can therefore differ from overall cards.
- **Partial periods:** Dataset boundaries contain incomplete time periods. Compare complete periods before interpreting apparent growth or decline.
- **Payment units:** Payment-record averages, payment value per order, and order-level installment rates answer different questions. Some SQL and dashboard calculations use different units and should be interpreted accordingly.

## Acknowledgments

Data provided by [Olist and collaborators on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). This is an independent educational project and is not affiliated with Olist.
