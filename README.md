# Layoffs SQL Data Cleaning & Exploratory Data Analysis (EDA)

This project focuses on cleaning and analyzing a dataset of tech company layoffs using SQL. It involves identifying and removing duplicates, handling nulls, standardizing inconsistent data, and performing exploratory data analysis to uncover key insights.

## 📊 Dataset Overview

The dataset contains layoff information from several global tech companies, including:
- Company names
- Locations
- Industries
- Total layoffs
- Percentage laid off
- Dates
- Funding raised
- Company stage and more

---

## 🧹 Phase 1: Data Cleaning

Key cleaning steps:
- Created a staging table to preserve raw data.
- Identified and removed duplicate records using `ROW_NUMBER()`.
- Trimmed whitespace and standardized text fields (e.g., industry, country).
- Converted date strings to SQL `DATE` type.
- Replaced blank values with `NULL` and filled missing values using joins.
- Dropped unnecessary columns after cleaning.

---

## 📈 Phase 2: Exploratory Data Analysis (EDA)

Performed SQL-based analysis to answer key questions:
- Total layoffs by **company**, **industry**, and **country**.
- Companies with **100% layoffs**.
- **Monthly** and **yearly** layoff trends.
- Top 5 companies with the most layoffs per year using `DENSE_RANK()` and window functions.
- Cumulative layoffs using **rolling totals** with `OVER()` clause.

---

## 🛠️ Tools Used

- **SQL :MySQL 
- **DBMS**: MySQL Workbench   

---
