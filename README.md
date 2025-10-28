# ⚡ Electricity Usage Analysis by Household and Month using MySQL

## 📘 Project Overview
This project analyzes electricity consumption across different households and months using **MySQL**.  
It automates billing calculations, identifies high energy consumers, and generates smart analytical reports.  

The goal is to help energy companies and households monitor usage efficiently, classify users based on consumption, and generate insights for improved energy management.

---

## 🧩 Features and Tasks

### **Task 1: Update Payment Status Based on Cost**
Automatically categorize billing records based on `cost_usd`:
```sql
UPDATE billing_info
SET payment_status = CASE
    WHEN cost_usd > 200 THEN 'High'
    WHEN cost_usd BETWEEN 100 AND 200 THEN 'Medium'
    ELSE 'Low'
END;
```

### **Task 2: Monthly Electricity Usage and Rank**
Display total monthly usage and rank households within each year:
```sql
SELECT household_id, month, year, SUM(total_kwh) AS monthly_usage,
RANK() OVER (PARTITION BY year ORDER BY SUM(total_kwh) DESC) AS usage_rank,
CASE WHEN SUM(total_kwh) > 500 THEN 'High' ELSE 'Low' END AS usage_level
FROM billing_info
GROUP BY household_id, month, year;
```

### **Task 3: Monthly Usage Pivot Table**
Generate a pivot view showing usage for January, February, and March:
```sql
SELECT household_id,
SUM(CASE WHEN month = 'Jan' THEN total_kwh ELSE 0 END) AS Jan,
SUM(CASE WHEN month = 'Feb' THEN total_kwh ELSE 0 END) AS Feb,
SUM(CASE WHEN month = 'Mar' THEN total_kwh ELSE 0 END) AS Mar
FROM billing_info
GROUP BY household_id;
```

### **Task 4: Average Monthly Usage per Household**
Join `household_info` and `billing_info` to calculate average monthly usage with city name.

### **Task 5: High AC Usage with Temperature**
Retrieve AC usage and outdoor temperature for high usage households.

### **Task 6: Stored Procedure - Get Billing by Region**
```sql
CREATE PROCEDURE billing_region(IN region_name VARCHAR(100))
BEGIN
    SELECT b.* 
    FROM household_info h
    INNER JOIN billing_info b ON h.household_id = b.household_id
    WHERE region = region_name
    ORDER BY b.year, b.month;
END;
```

### **Task 7: Stored Procedure - Calculate Total Usage**
```sql
CREATE PROCEDURE calculate_total(IN hold_id VARCHAR(100), INOUT tot_kwh DOUBLE)
BEGIN
    SELECT SUM(total_kwh) INTO tot_kwh
    FROM billing_info
    WHERE household_id = hold_id;
END;
```

### **Task 8: Trigger - Auto Calculate Cost Before Insert**
Automatically compute `cost_usd` before inserting new billing data.

### **Task 9: Trigger - Insert Calculated Metrics After Billing Entry**
After a new billing record is inserted, automatically calculate metrics such as:
- kWh per occupant  
- kWh per square foot  
- Usage category (High or Moderate)

---

## 🧠 Conclusion
This MySQL project successfully automates electricity billing and usage analysis.  
By using stored procedures, triggers, and advanced queries, it provides actionable insights, saves manual effort, and improves energy monitoring efficiency.

---

## 🗂️ Project Files
| File | Description |
|------|--------------|
| `project.sql` | Contains all SQL queries, triggers, and procedures |
| `Electricity-Usage-Analysis-by-Household-and-Month-using-MySQL.pptx` | Project presentation with explanation and results |

---

## 👩‍💻 Developed By
**Sowndharya Rajarajan**  
Student, SRM University  
CSE (AI & ML)
