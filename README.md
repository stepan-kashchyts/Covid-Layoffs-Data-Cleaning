# Data Cleaning for Layoffs Dataset

This repository contains SQL scripts for cleaning and preparing a layoffs dataset. The goal of this project is to transform raw data into a clean, standardized format suitable for analysis and reporting.

## Overview

The dataset consists of information about company layoffs, including details such as company name, location, industry, number of layoffs, percentage of layoffs, and the date of the layoffs. The cleaning process involves removing duplicates, standardizing data formats, handling null values, and dropping unnecessary columns.

## SQL Scripts

The project includes the following SQL scripts for data cleaning:

1. **Data Cleaning Process**
   - **Removing Duplicates**: Identifies and deletes duplicate records based on specific columns.
   - **Standardizing Data**: Formats company names, industry types, country names, and dates to ensure consistency.
   - **Handling Null/Blank Values**: Identifies and updates or deletes records with null or blank values.
   - **Removing Unnecessary Columns**: Drops columns that are no longer needed after cleaning.

## Setup

1. **Create Staging Tables**
```sql
   CREATE TABLE `layoffs_staging` LIKE `layoffs`;
   INSERT INTO `layoffs_staging` SELECT * FROM `layoffs`;
```

```sql
WITH duplicates_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM `layoffs_staging`
)
DELETE FROM `duplicates_CTE` WHERE `row_num` > 1;
```
Standardize Data

sql
```
-- Remove extra spaces from company names
UPDATE `layoffs_staging2` SET `company` = TRIM(`company`);

-- Format industry names
UPDATE `layoffs_staging2` SET `industry` = 'Crypto' WHERE `industry` LIKE 'Crypto%';

-- Format country names
UPDATE `layoffs_staging2` SET `country` = TRIM(TRAILING '.' FROM `country`) WHERE `country` LIKE 'United States_';

-- Convert date formats
UPDATE `layoffs_staging2` SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE `layoffs_staging2` MODIFY COLUMN `date` DATE;

Handle Null/Blank Values
```
```sql

DELETE FROM `layoffs_staging2` WHERE `total_laid_off` IS NULL AND `percentage_laid_off` IS NULL;

UPDATE `layoffs_staging2` SET `industry` = NULL WHERE `industry` = '';
```
Remove Unnecessary Columns

sql
```
    ALTER TABLE `layoffs_staging2` DROP COLUMN `row_num`;
```
Usage
```
    Execute the SQL Scripts: Run each script sequentially in your SQL environment to apply the data cleaning transformations.
    Verify Data: Check the layoffs_staging2 table to ensure that the data has been cleaned and standardized as expected.
```
