-- Data Cleaning


SELECT * 
FROM `layoffs`;


-- 1. Removing Duplicates
-- 2. Standardizing the Data
-- 3. Null/Blank Values
-- 4. Removing unnecessary Columns


CREATE TABLE `layoffs_staging`
LIKE `layoffs`;


SELECT * 
FROM `layoffs_staging`;


INSERT `layoffs_staging`
SELECT *
FROM `layoffs`;

-- 1. Removing Duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM `layoffs_staging`;



WITH duplicates_CTE AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM `layoffs_staging`)
DELETE FROM `duplicates_CTE`
WHERE `row_num` > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * 
FROM `layoffs_staging2`;


INSERT INTO `layoffs_staging2`
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM `layoffs_staging`;


SELECT * FROM `layoffs_staging2`
WHERE `row_num` > 1;

-- Removing the Duplicates
DELETE FROM `layoffs_staging2`
WHERE `row_num` > 1;


-- Standardizing the Data
SELECT DISTINCT(TRIM(`company`))
FROM `layoffs_staging2`;


UPDATE `layoffs_staging2`
SET `company` = TRIM(`company`);


SELECT DISTINCT(`industry`)
FROM `layoffs_staging2`
WHERE `industry` LIKE 'Crypto%'
ORDER BY 1;

-- Formating Industry names
UPDATE `layoffs_staging2`
SET `industry` = 'Crypto'
WHERE `industry` LIKE 'Crypto%';


SELECT DISTINCT `country` , TRIM(TRAILING '.' FROM `country`)
FROM `layoffs_staging2`
ORDER BY 1;

-- Formating Country name
UPDATE  `layoffs_staging2`
SET `country` = TRIM(TRAILING '.' FROM `country`)
WHERE `country` LIKE 'United States_';


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM `layoffs_staging2`;

-- Formating Date Column
UPDATE `layoffs_staging2`
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');


ALTER TABLE `layoffs_staging2`
MODIFY COLUMN `date` DATE;

-- Deleting Useless Data
SELECT * FROM `layoffs_staging2` 
WHERE `total_laid_off` IS NULL
AND `percentage_laid_off` IS NULL;

DELETE FROM `layoffs_staging2` 
WHERE `total_laid_off` IS NULL
AND `percentage_laid_off` IS NULL;


SELECT *
FROM `layoffs_staging2` 
WHERE `industry` IS NULL
OR `industry` = '';


SELECT *
FROM `layoffs_staging2`
WHERE `company` LIKE 'Ball%';


SELECT * FROM `layoffs_staging2` t1
JOIN `layoffs_staging2` t2
	ON t1.company = t2.company 
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

-- Removing NULLs
UPDATE `layoffs_staging2`
SET `industry` = NULL
WHERE `industry` = '';


UPDATE `layoffs_staging2` t1
JOIN `layoffs_staging2` t2
	ON t1.company = t2.company 
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;


-- 4. Removing unnecessary Columns

ALTER TABLE `layoffs_staging2`
DROP COLUMN `row_num`;








