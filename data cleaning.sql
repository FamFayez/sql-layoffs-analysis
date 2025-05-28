-- : View Original Data
SELECT * FROM layoffs;

-- : Create a staging table to avoid modifying the original data
CREATE TABLE layoffs_staging 
LIKE layoffs;




--  :Insert data from the original table into the staging table
INSERT INTO layoffs_staging 
SELECT * FROM layoffs;

SELECT *
 FROM layoffs_staging;
-- Identify duplicate rows using ROW_NUMBER over key fields
WITH duplicate_cte AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, 
                        percentage_laid_off, date, stage, country, funds_raised_millions
           ORDER BY company
         ) AS row_num
  FROM layoffs_staging
)

SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

-- Example check for duplicates in a specific company
SELECT *
FROM layoffs_staging 
WHERE company = 'casper';

-- : Create a new staging table  to include a row_num column
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Insert data with calculated row_num for duplicate identification
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
         PARTITION BY company, location, industry, total_laid_off, 
                      percentage_laid_off, date, stage, country, funds_raised_millions
         ORDER BY company
       ) AS row_num
FROM layoffs_staging;
--  check for duplicates after insert
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;



-- Delete duplicates (keep only row_num = 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- View the cleaned data
SELECT * FROM layoffs_staging2;

-- STEP 2: Standardize Data

--  Trim whitespace from company names
SELECT company, TRIM(company)
 FROM layoffs_staging2;
UPDATE layoffs_staging2 SET company = TRIM(company);

-- : Normalize industry names
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;

-- Fix inconsistent 'Crypto' labels 
SELECT *
 FROM layoffs_staging2 
 WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging2 SET industry = 'Crypto'
 WHERE industry LIKE 'Crypto%';

-- : Normalize country names ( remove trailing dot)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Preview conversion of string to DATE
SELECT date, STR_TO_DATE(date, '%m/%d/%Y') FROM layoffs_staging2;

-- Update column values to actual date format
UPDATE layoffs_staging2 
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Change the column type to proper DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- 3: Handle Null or Blank Values

-- A. Find rows with both  NULL 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- . Find rows with empty or NULL industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Set blank industry fields to NULL 
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- missing industry in t1, but known in t2
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Update missing industry values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

SELECT *
 FROM layoffs_staging2;
 
-- 4. remove any columns and rows we need to


-- . Remove rows where both total_laid_off and percentage_laid_off are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- . Drop row_num column now that deduplication is complete
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final result
SELECT * FROM layoffs_staging2;