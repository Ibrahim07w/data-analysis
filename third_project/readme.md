# 🔍 Fraud Detection Analysis – Digital Transactions

This project analyzes digital transaction data to uncover fraud patterns, identify vulnerable user segments, and recommend preventive measures for high-risk combinations of time, location, and user demographics.

---

## 🎯 Objectives

- Quantify the impact and nature of fraud in digital transactions
- Identify high-risk transaction types, time periods, and sender-receiver profiles
- Assess bank and state-level vulnerabilities
- Provide data-driven recommendations for fraud mitigation

---

## 📊 Fraud Overview

- **Total Loss**: ₹719,631 across **480 fraud cases**
- **Fraud Rate**: 0.19% — relatively rare but financially significant
- **Average Fraud Amount**: ₹1,500 (15% higher than legit transactions)

---

## ⚠️ High-Risk Transaction Categories

| Category                  | Fraud Rate |
|---------------------------|------------|
| Recharge → Healthcare     | 0.60%      |
| Recharge → Shopping       | 0.41%      |
| Recharge → Entertainment  | 0.39%      |
| Recharge → Transport      | 0.30%      |
| P2M → Shopping            | 0.27%      |
| P2P → Entertainment       | 0.24%      |

- **Recharge-related services** show highest risk — likely due to minimal authentication layers.
- **P2M and P2P transactions** with large volume are prime fraud targets.

---

## 🕒 Temporal Insights

### 📆 Weekday Trends
- **Highest fraud rates** on **Sunday** and **Wednesday (0.21%)**
- Lower risk on **Tuesday** and **Friday**

### ⏰ Hourly Trends
| Hour | Fraud Rate |
|------|------------|
| 3 AM | 0.30%      |
| 1 AM | 0.27%      |
| 10 PM| 0.25%      |
| 3 PM | 0.25%      |

- **Late night and early morning** are riskier due to lower surveillance activity.

---

## 🏦 Sender State & Bank Combinations

- 🚨 **West Bengal + IndusInd** (0.41%), **Rajasthan + PNB** (0.39%)
- 🔎 Frequent mentions of **Kotak** across high-fraud combinations
- ✅ **West Bengal + HDFC** reported **zero fraud cases**

---

## 👥 Demographics & Behavior

| Sender → Receiver         | Fraud Rate |
|---------------------------|------------|
| Teenager → Teenager       | 0.29%      |
| Retired → Teenager/Gentleman | ~0.29% |
| Old → Old                 | 0.32% (Highest) |

- Elderly and teenagers are **most vulnerable**.
- **Adult → Adult** transactions are the most stable.

---

## 📡 Channel-Specific Observations

- **Recharge & Bill Payments**: High fraud density, low amounts
- **P2P and P2M**: High fraud counts due to volume and scalability
- **High-risk categories**: Fuel, Shopping, Education — suggest layered authentication

---

## ✅ Recommendations

- ⏱ **Enforce strict fraud checks** between **1–3 AM** and **10 PM–12 AM**
- 🎯 Launch **awareness campaigns** for **elderly and teen users**
- 🏦 **Audit security** for **Kotak, PNB, IndusInd** in vulnerable regions
- 🧾 **Strengthen merchant onboarding** in **Shopping and Fuel** sectors
- 📊 Deploy **weekly fraud dashboards** to track anomalies in real time

---

## 🧰 Tools Used

- Python: `Pandas`, `NumPy`, `Matplotlib`, `Seaborn`
- Jupyter Notebook for EDA
- SQL for data extraction
- Optional: Power BI or Tableau for dashboards

---


