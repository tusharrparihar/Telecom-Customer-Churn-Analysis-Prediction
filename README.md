# 📊 Telecom Customer Churn — Analysis & Prediction
 
**An end-to-end analytics project: SQL ETL → Power BI dashboarding → Machine learning churn prediction**
 
![SQL](https://img.shields.io/badge/SQL_Server-ETL-CC2927?logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-Modeling-3776AB?logo=python&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-RandomForest-F7931E?logo=scikitlearn&logoColor=white)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
 
</div>
 
## 📌 Overview
 
Telecom companies lose revenue every time a customer leaves, and it's far cheaper to retain a customer than acquire a new one. This project builds a complete churn analytics pipeline for a telecom operator:
 
1. **Clean and structure** raw customer data using SQL
2. **Visualize** churn patterns across demographics, geography, contracts, and services in Power BI
3. **Predict** which new customers are likely to churn using a Random Forest classifier, so retention teams can act *before* the customer leaves
> **Headline result:** Of 6,563 customers, 1,727 have churned (**26.3%** churn rate). The prediction model, applied to 561 new customers, flags **538 as at-risk** — with month-to-month contracts and competitor pressure as the dominant drivers.
 
---
 
## 🗂️ Table of Contents
 
- [Key Metrics](#-key-metrics)
- [Project Architecture](#-project-architecture)
- [Repository Structure](#-repository-structure)
- [Dataset](#-dataset)
- [ETL Pipeline](#-etl-pipeline-sql)
- [Dashboard](#-power-bi-dashboard)
- [Predictive Model](#-predictive-model)
- [Model Performance](#-model-performance)
- [At-Risk Customer List](#-at-risk-customer-list)
- [Key Insights](#-key-insights)
- [Recommendations](#-recommendations)
- [How to Reproduce](#-how-to-reproduce)
- [Tech Stack](#-tech-stack)
- [Limitations](#-limitations--honest-caveats)
- [License](#-license)
---
 
## 🎯 Key Metrics
 
| Metric | Value |
|---|---|
| Total Customers | **6,563** |
| Churned Customers | **1,727** |
| Churn Rate | **26.3%** |
| New Customers (Joined) | **561** |
| Model Accuracy (test set) | **85%** |
| Model Recall — Churn Class | **62%** |
| Customers Flagged At-Risk | **538 / 561** |
 
---
 
## 🏗️ Project Architecture
 
```
Raw Customer Data (CSV)
        │
        ▼
   SQL Server ETL
   (clean, deduplicate, handle nulls)
        │
        ▼
┌───────────────┴───────────────┐
▼                                ▼
vw_ChurnData                vw_JoinData
(6,003 labeled records:     (561 new customers,
 Churned / Stayed)           no outcome yet)
        │                                │
        ▼                                │
  Power BI Dashboard                     │
  (descriptive analytics)                │
        │                                │
        ▼                                ▼
  Random Forest Model  ───train───►  Predict on new data
        │                                │
        ▼                                ▼
  Evaluation Report              Predictions.csv
  (accuracy / recall)            (538 at-risk customers)
```
 
---
 
## 📁 Repository Structure
 
```
telecom-churn-analysis/
│
├── data/
│   ├── Customer_Data.csv              # Raw source data (6,563 rows, 32 fields)
│   ├── vw_churndata.csv               # Cleaned historical data (Churned/Stayed)
│   ├── vw_joindata.csv                # New customers (no churn outcome yet)
│   ├── Prediction_data.xlsx           # Excel workbook feeding the model
│   └── Predictions.csv                # Model output: 538 flagged at-risk customers
│
├── sql/
│   ├── Create_Database.sql            # Database setup
│   ├── Create_Table.sql               # Table creation
│   ├── data_exploration_check_null.sql   # Null audit across all 32 fields
│   ├── data_exploration_remove_null.sql  # Cleaning rules (COALESCE defaults)
│   ├── data_exploration_views.sql     # vw_ChurnData / vw_JoinData view creation
│   └── data_distribution.sql          # Distribution sanity checks
│
├── notebooks/
│   └── Prediction.ipynb               # Random Forest training + prediction pipeline
│
├── dashboard/
│   └── Churn_Analysis.pbix            # Power BI dashboard (Summary + Prediction pages)
│
├── docs/
│   ├── Data_understand.txt            # Data dictionary
│   ├── Project_Overview.docx          # Original project brief
│   └── Churn_Analysis.pdf             # Exported dashboard report
│
├── assets/
│   ├── dashboard_summary.png
│   └── dashboard_prediction.png
│
└── README.md
```
 
---
 
## 🗃️ Dataset
 
Single customer-level table, one row per customer, **6,563 records × 32 fields**.
 
<details>
<summary><strong>Click to expand full data dictionary</strong></summary>
| Field | Description |
|---|---|
| `Customer_ID` | Unique key per customer |
| `Gender`, `Age`, `Married` | Demographics |
| `State` | Geographic location |
| `Number_of_Referrals` | Referrals made by the customer |
| `Tenure_in_Months` | Length of relationship with company |
| `Value_Deal` | Promotional deal attached to account |
| `Phone_Service`, `Multiple_Lines` | Phone service details |
| `Internet_Service`, `Internet_Type` | Internet subscription & connection type |
| `Online_Security`, `Online_Backup`, `Device_Protection_Plan`, `Premium_Support` | Add-on services |
| `Streaming_TV`, `Streaming_Movies`, `Streaming_Music`, `Unlimited_Data` | Entertainment/data add-ons |
| `Contract`, `Paperless_Billing`, `Payment_Method` | Account & billing configuration |
| `Monthly_Charge`, `Total_Charges`, `Total_Refunds`, `Total_Extra_Data_Charges`, `Total_Long_Distance_Charges`, `Total_Revenue` | Financial fields |
| `Customer_Status` | **Target field** — `Churned`, `Stayed`, or `Joined` |
| `Churn_Category`, `Churn_Reason` | Reason codes for churned customers |
 
</details>
---
 
## 🔧 ETL Pipeline (SQL)
 
| Step | File | Purpose |
|---|---|---|
| 1 | `Create_Database.sql` | Provision `db_TeleChurn` |
| 2 | `Create_Table.sql` | Load raw data into `customer_churn` |
| 3 | `data_exploration_check_null.sql` | Audit nulls across all 32 columns in one query |
| 4 | `data_exploration_remove_null.sql` | Build `prod_churn` with `COALESCE` defaults (e.g. missing add-ons → `'No'`, missing deal → `'None'`) — no rows dropped |
| 5 | `data_exploration_views.sql` | Create `vw_ChurnData` (Churned/Stayed, 6,003 rows) and `vw_JoinData` (Joined, 561 rows) |
| 6 | `data_distribution.sql` | Sanity-check category distributions (gender, contract, state, revenue share) |
 
---
 
## 📈 Power BI Dashboard
 
### Summary Page
Demographic, geographic, and account-level churn breakdown with interactive slicers (Monthly Charge Range, Married status).
 
<img width="901" height="510" alt="Churn Analysis" src="https://github.com/user-attachments/assets/56eb117a-4170-45c2-83ed-ba668e2226ad" />

### Prediction Page
Profile of the 538 customers flagged at-risk by the model, plus a searchable/sortable table for retention teams.
 
 <img width="971" height="547" alt="Churn Analysis - Prediction" src="https://github.com/user-attachments/assets/b8d22f82-cfdc-4189-b574-1b03d2b095ff" />
 
---
 
## 🤖 Predictive Model
 
Built in `Prediction.ipynb` using **pandas** + **scikit-learn**.
 
**Pipeline:**
1. Load `vw_churndata` (6,003 labeled records)
2. Drop `customer_id`, `churn_category`, `churn_reason` (not available at prediction time)
3. Label-encode 19 categorical fields
4. Encode target: `Stayed → 0`, `Churned → 1`
5. Train/test split — 80/20, `random_state=42`
6. Train a `RandomForestClassifier(n_estimators=100, random_state=42)`
7. Evaluate on the held-out test set
8. Apply the trained model + saved encoders to `vw_joindata` (561 new customers)
9. Export every customer predicted `Churned` to `Predictions.csv`
**Why Random Forest?** The feature set mixes categorical and numeric fields with likely non-linear relationships to churn, and it produces a feature-importance ranking usable directly in business conversations.
 
---
 
## 📊 Model Performance
 
**Confusion Matrix** (test set, n = 1,201)
 
| | Predicted: Stayed | Predicted: Churned |
|---|---|---|
| **Actual: Stayed** | 811 | 44 |
| **Actual: Churned** | 132 | 214 |
 
**Classification Report**
 
| Class | Precision | Recall | F1-score |
|---|---|---|---|
| Stayed (0) | 0.86 | 0.95 | 0.90 |
| Churned (1) | 0.83 | 0.62 | 0.71 |
| **Accuracy** | | | **0.85** |
 
> ⚠️ **Read this carefully:** 85% accuracy is inflated by the majority "Stayed" class. The model only catches **62%** of actual churners — it misses 132 of 346 in the test set. See [Limitations](#-limitations--honest-caveats).
 
---
 
## 🎯 At-Risk Customer List
 
538 of 561 new customers (`vw_joindata`) are flagged `Churned` by the model.
 
| Attribute | Breakdown |
|---|---|
| Contract | **89%** month-to-month |
| Tenure | Largest group: **< 6 months** (213 customers) |
| Age | Concentrated in **36–50** (193 customers) |
| Gender | 340 female / 198 male |
| Marital status | 279 unmarried / 259 married |
| Top states by volume | Uttar Pradesh (56), Maharashtra (47), Tamil Nadu (41) |
 
Each flagged record in `Predictions.csv` includes `customer_id`, `monthly_charge`, `total_revenue`, `total_refunds`, and `number_of_referrals` — enough to prioritize outreach by value.
 
---
 
## 💡 Key Insights
 
- **Contract type is the strongest churn driver:** Month-to-month churns at **44.8%** vs. 10.9% (one-year) and 2.7% (two-year).
- **Competitor pressure drives 44% of churn** (761 of 1,727) — mostly "better devices" (289) and "better offers" (274).
- **Fiber Optic customers churn at 40.6%** — the highest of any internet type, despite being the premium product. This is a red flag, not a demand signal.
- **Churn rises with age:** 22.2% (18–25) → 36.4% (60+).
- **Geographic hot spots:** Jammu & Kashmir (56.0%), Assam (36.6%), Jharkhand (33.1%) — all far above the 26.3% average.
- **Payment method matters:** Bank Withdrawal (33.9%) and Mailed Check (32.3%) churn ~2x more than Credit Card (14.5%).
---
 
## ✅ Recommendations
 
1. **Target month-to-month contract holders first** — highest-leverage segment in the entire dataset.
2. **Investigate the Fiber Optic churn spike** — likely a pricing or reliability issue, not demand.
3. **Strengthen competitive positioning** on devices and pricing, especially in high-churn states.
4. **Bundle protective add-ons** (online security, premium support) into onboarding rather than upselling later.
5. **Treat the 538-name at-risk list as a starting point** — rank by revenue, tenure, and referrals before running outreach.
6. **Improve model recall** (class weighting / SMOTE / threshold tuning) before scaling this into a production retention program.
---
 
## 🔁 How to Reproduce
 
```bash
# 1. Set up the database
sqlcmd -i sql/Create_Database.sql
sqlcmd -i sql/Create_Table.sql
 
# 2. Run data quality checks and cleaning
sqlcmd -i sql/data_exploration_check_null.sql
sqlcmd -i sql/data_exploration_remove_null.sql
sqlcmd -i sql/data_exploration_views.sql
 
# 3. Open the dashboard
#    dashboard/Churn_Analysis.pbix in Power BI Desktop
 
# 4. Run the model
pip install pandas numpy matplotlib seaborn scikit-learn joblib
jupyter notebook notebooks/Prediction.ipynb
```
 
---
 
## 🛠️ Tech Stack
 
| Layer | Tool |
|---|---|
| Database & ETL | PostgreSQL |
| Dashboarding | Power BI |
| Modeling | Python — pandas, scikit-learn, seaborn, matplotlib |
| Environment | Jupyter Notebook |
 
---
 
## ⚠️ Limitations & Honest Caveats
 
- **Recall on the churn class is 62%**, not 85% — the headline accuracy number is misleading on its own. Roughly 1 in 3 real churners are currently missed.
- **538 of 561 flagged as at-risk (96%)** is a very wide net given the recall gap — this list needs manual prioritization, not blanket action.
- **Feature importance values** were not captured in the saved notebook output — only the chart. Re-run the notebook cell to reproduce exact numbers.
- **Fiber Optic churn spike is unexplained** by this dataset — root cause (price vs. reliability vs. support) requires further investigation.
---
 
## 📄 License

This project is licensed under the **MIT License**.

Copyright (c) 2026 **Tushar Parihar**

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the **"Software"**), to deal
in the Software without restriction, including without limitation the rights
to:

- Use
- Copy
- Modify
- Merge
- Publish
- Distribute
- Sublicense
- Sell copies of the Software

and to permit persons to whom the Software is furnished to do so, subject to
the following condition:

> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.

### Disclaimer

THE SOFTWARE IS PROVIDED **"AS IS"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
