-- DATA Cleaning

select * from layoffs;

-- steps I am following for data cleaning process
-- 1. Removing Duplicates
-- 2. Standardizing the data - everything must be same
-- 3. checking null and blank values
-- 4. Remove rows and columns which are not necessary

create temporary table layoffs_staging
select * from layoffs;

select * from layoffs_staging;

-- Creating a copy to edit
create table layoffs_new
like layoffs;

select * from layoffs_new;

insert layoffs_new
select * from layoffs;

-- to find duplicates using row number partitioning by columns

select * ,
row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,`date`, stage, country,funds_raised_millions ) as row_num
from layoffs_new;

-- now to identify more than 1 I can do subquery or a CTE

with duplicate_cte as (
select * ,
row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,`date`, stage, country,funds_raised_millions ) as row_num
from layoffs_new)
select * from duplicate_cte where row_num > 1;

-- Now creating another table and copying these and removing duplicates
CREATE TABLE `layoffs_new2` (
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

select * from layoffs_new2;

insert into layoffs_new2
select * ,
row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,`date`, stage, country,funds_raised_millions ) as row_num
from layoffs_new;

select * from layoffs_new2
where row_num>1;

delete from layoffs_new2
where row_num > 1;

-- Standardizing data

select company, trim(company)
from layoffs_new2;





-- removing white spaces now
update layoffs_new2
set company= trim(company);


select distinct(industry)
from layoffs_new2 order by 1;
-- we have null,blank and multiple crypto,cryptocurrency

select * from layoffs_new2
where industry like 'crypto%';

update layoffs_new2
set industry = 'Crypto'
where industry like 'Crypto%';


-- checking each column
select distinct(location)
from layoffs_new2 order by 1;

select distinct(country)
from layoffs_new2 order by 1;


update layoffs_new2
set country = trim(trailing '.' from country)
where country like 'United States%';


-- changing date to proper format
select `date`, str_to_date(`date` ,'%m/%d/%Y')
from layoffs_new2;

update layoffs_new2
set `date`=  str_to_date(`date` ,'%m/%d/%Y');

-- to change the data type
alter table layoffs_new2
modify column `date` DATE;

SELECT * FROM layoffs_new2;

-- STEP 3 WORKING WITH NULL AND BLANK VALUES
select * from layoffs_new2
where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_new2 where industry is null 
or industry = '';

select * from layoffs_new2 where company = 'Airbnb';

select * from layoffs_new2 t1
join layoffs_new2 t2
on t1.company= t2.company and t1.location= t2.location
where (t1.industry is null or t1. industry ='') and t2.industry is not null;

update layoffs_new2
set industry = null
where industry = '';
-- updating
update layoffs_new2 t1
join layoffs_new2 t2
on t1.company= t2.company and t1.location= t2.location
set t1.industry= t2.industry 
where (t1.industry is null or t1. industry ='') and t2.industry is not null;

select * from layoffs_new2 where total_laid_off is null 
and percentage_laid_off is null;

delete from layoffs_new2
where total_laid_off is null and percentage_laid_off is null;

-- Step 4- removing columns which are not needed
-- we dont need row num column now
alter table layoffs_new2
drop column row_num;

select * from layoffs_new2;