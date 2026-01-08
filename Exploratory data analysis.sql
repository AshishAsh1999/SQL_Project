-- Exploratory Data Analysis
select * from layoffs_new2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_new2;

select * from layoffs_new2
order by total_laid_off desc;
-- maximum employees laid off was 12000 and 100% people were laid of in some companies

select * from layoffs_new2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- companies which got laid off even though it had lot of funding in descending order
select company, sum(total_laid_off) as total_laid_off
from layoffs_new2
group by (company)
order by total_laid_off desc;

-- Amazon had most lay offs - combined multiple country and industry, grouped by only company.

-- checking the date ranges
select min(`date`), max(`date`)
from layoffs_new2;

select industry, sum(total_laid_off) as total_laid_off
from layoffs_new2
group by (industry)
order by total_laid_off desc;

-- Consumer and retail got hit pretty hard
select country, sum(total_laid_off) as total_laid_off
from layoffs_new2
group by (country)
order by total_laid_off desc;

-- united states had most lay off

select year(`date`), sum(total_laid_off) as total_laid_off
from layoffs_new2
group by year(`date`)
order by 1 desc;

-- 2022 was the worst year

-- we can check rolling total of the layoffs- rolling sum

select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_laid_off from layoffs_new2
where substring(`date`,1,7) is not null
group by `Month`
order by 1;

with rolling_total as
 (select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_laid_off from layoffs_new2
where substring(`date`,1,7) is not null
group by `Month`
order by 1)
select `Month`, total_laid_off,
sum(total_laid_off) over (order by `Month`) as Rolling_total
from rolling_total;

-- Now Let us see with company and the year they laid off
select company, year(`date`), sum(total_laid_off)
from layoffs_new2
group by company, year(`date`)
order by 3 desc;

-- to rank these companies as per particular year

with company_year (Company, years, total_laid_off) as
(select company, year(`date`), sum(total_laid_off)
from layoffs_new2
group by company, year(`date`)
order by 3 desc)
select *, dense_rank () over (partition by years order by total_laid_off desc) from company_year
where years is not null;
