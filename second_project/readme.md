# 🚗 Car Sales Data Analysis

This project explores a comprehensive dataset of used car listings to uncover pricing patterns, market behavior, technical influences, and buyer preferences across India.

---

## 📌 Objectives

- Identify key pricing drivers and value depreciation factors
- Understand the impact of region, fuel type, transmission, and ownership
- Uncover correlations between technical specifications and sale price
- Provide insights for car buyers, sellers, and dealerships

---

## 🧾 Key Insights

### 🧍‍♂️ Market Composition

- **Individual sellers dominate** the listings, making up **over 80%** of the market.
- **First-owner vehicles** constitute **66%** of listings — buyers prefer cars with minimal ownership history.
- **Diesel vehicles** are most commonly listed and fetch the **highest average prices**.
- **Automatic transmission cars** sell at a **significantly higher price** than manual ones, signaling their premium market positioning.

---

### 🌍 Regional Trends

- **South India** reports the **highest average selling prices**.
- **Central and East India** are mid-range, with **West India** being slightly lower.
- Regional pricing likely reflects differences in **income levels**, **urbanization**, and **fuel preferences**.

---

### 💸 Pricing Trends

- **Engine size** and **max power** strongly influence price — performance over efficiency.
- **Max Power** shows a **+0.75 correlation** with price.
- **Mileage (km/l)** is **negatively correlated**, suggesting **fuel economy is less valued** than engine strength in pricing.

---

### ⚙️ Technical Specifications

- **Diesel cars** average ₹8.02 lakh — nearly **double** petrol cars.
- **Automatic cars** command ₹18+ lakh on average, vs. ₹4.6 lakh for manuals.
- **Test drive vehicles** show unusually high pricing, possibly indicating **luxury cars** or **data anomalies**.

---

### 📆 Vehicle Age & Usage

- **6-year-old cars** sell at the **highest average price** (~₹17.7 lakh).
- Vehicles older than 9 years see **sharp value decline**.
- **Kilometers driven** lowers resale value, but **not as steeply** as age or engine capacity.

---

### 👥 Ownership & Value Retention

| Ownership Level  | Avg Selling Price |
|------------------|-------------------|
| First Owner      | ₹7.9 lakh         |
| Second Owner     | ₹4.0 lakh         |
| Third Owner      | ₹2.9 lakh         |
| Fourth+ Owner    | ₹2.3 lakh         |

- **First-owner vehicles retain value best**, reinforcing buyer trust in single-owner history.

---

## 🧰 Tools & Libraries Used

- Python
  - `Pandas`, `NumPy` for data processing
  - `Matplotlib`, `Seaborn`, `Plotly` for visualizations
- Jupyter Notebook for analysis
- Excel for basic preprocessing

---

## 📁 Project Structure

