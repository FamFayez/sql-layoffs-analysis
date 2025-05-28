-- show all data
select *
from layoffs_staging2;

-- find max layoffs and max percentage of layoffs
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- show companies that laid off 100% of their employees, ordered by layoffs
select *
from layoffs_staging2
where percentage_laid_off = 1 
order by total_laid_off desc;

-- total layoffs per company
select sum(total_laid_off), company
from layoffs_staging2
group by company
order by 1 desc;

-- earliest and latest layoff dates
select min(date), max(date)
from layoffs_staging2;

-- total layoffs per industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- total layoffs per country
select sum(total_laid_off), country
from layoffs_staging2
group by country
order by 1 desc;

-- total layoffs per year
select year(date), sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by 1 desc;

-- total layoffs per company (again, for emphasis)
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- total layoffs by month
select substring(date, 1, 7) as month, sum(total_laid_off) 
from layoffs_staging2
where substring(date, 1, 7) is not null
group by month
order by 1 asc;

-- rolling total of layoffs over time
with rolling_total as (
  select substring(date, 1, 7) as month, sum(total_laid_off) as total_off
  from layoffs_staging2
  where substring(date, 1, 7) is not null
  group by month
  order by 1 asc
)
select month, total_off, 
       sum(total_off) over (order by month) as rolling_total
from rolling_total;

-- total layoffs per company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- total layoffs per company per year
select company, year(date), sum(total_laid_off)
from layoffs_staging2
group by company, year(date)
order by 3 desc;

-- top 5 companies with most layoffs each year
with company_year(company, years, total_laid_off) as (
  select company, year(date), sum(total_laid_off)
  from layoffs_staging2
  group by company, year(date)
),
company_year_rank as (
  select *, 
         dense_rank() over (partition by years order by total_laid_off desc) as ranking
  from company_year
  where years is not null
)
select *
from company_year_rank
where ranking <= 5;
