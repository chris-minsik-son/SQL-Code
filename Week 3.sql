-- WEEK 3: DATA EXPLORATION EXERCISES

-- IDENTIFYING DUPLICATE RECORDS

-- (1) Which id value has the most number of duplicate records in the health.user_logs table?
-- First retrieve all records and then sum the distinct records
-- Note, we set frequency > 1 as we only want to get the cumulative frequency of DUPLICATE id's
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  id,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY id
ORDER BY total_duplicate_rows DESC
LIMIT 1;

-- (2) Which log_date value had the most duplicate records after removing the max duplicate id value from question 1?
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  log_date,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1 AND id != '054250c692e07a9fa9e62e345231df4b54ff435d'
GROUP BY log_date
ORDER BY total_duplicate_rows DESC
LIMIT 1;

-- (3) Which measure_value had the most occurences in the health.user_logs value when measure = 'weight'?
SELECT
  measure,
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
WHERE measure = 'weight'
GROUP BY measure_value, measure
ORDER BY frequency DESC
LIMIT 1;

-- (4) How many single duplicated rows exist when measure = 'blood_pressure' in the health.user_logs? How about the total number of duplicate records in the same table?
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency -- Sets all records' frequency to 1
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  COUNT(*) as single_duplicate_rows, -- Counts all the records with frquency >= 2
  SUM(frequency) as total_duplicate_records -- Sums all the frequencies of those record i.e. total
FROM groupby_counts
WHERE frequency > 1;

-- (5) What percentage of records measure_value = 0 when measure = 'blood_pressure' in the health.user_logs table? How many records are there also for this same condition?
-- SUM(COUNT(*)) OVER() since we want to add the counts of each measure value for when measure = 'blood_pressure'
WITH measure_bp AS (
  SELECT
    measure_value,
    COUNT(*) AS bp_count,
    SUM(COUNT(*)) OVER() AS total_count
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP by measure_value
)
SELECT
  measure_value,
  bp_count,
  total_count,
  ROUND(100 * bp_count::NUMERIC / total_count, 2) AS PERCENTAGE
FROM measure_bp
WHERE measure_value = 0;

-- (6) What percentage of records are duplicates in the health.user_logs table?
-- In the case statement below,  subtract 1 from the frequency to count the actual duplicates
WITH groupby_freq AS (
  SELECT
    id,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT ROUND(100 * SUM(CASE
                      WHEN frequency > 1
                      THEN frequency - 1
                      ELSE 0
                      END)::NUMERIC / SUM(frequency), 2)
AS duplicate_percentage
FROM groupby_freq





-- Exploring the Health Analytics Data:
SELECT * FROM health.user_logs LIMIT 10;

-- How many rows in the data?
SELECT COUNT(*) FROM health.user_logs;

-- Count on the unique entries in the measures column
SELECT
    measure,
    COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure;

-- Number of unique customers
SELECT COUNT(DISTINCT id) FROM health.user_logs;

-- Find the top 10 customers by record count
SELECT
    id,
    COUNT(*) AS row_count
FROM health.user_logs
GROUP BY id
ORDER BY row_count DESC
LIMIT 10;

-- Inspecting data where measure_value = 0
SELECT *
FROM health.user_logs
WHERE measure_value = 0;

SELECT
    measure,
    COUNT(*) AS record_count
FROM health.user_logs
WHERE measure_value = 0
GROUP BY measure;

-- Checking NULL values in the systolic column
SELECT COUNT(*)
FROM health.user_logs
WHERE systolic IS NULL;

-- Removing duplicates and counting unique entries
-- CTE: (preferred method over subquery)
WITH deduped_logs AS (
    SELECT DISTINCT *
    FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;

-- Subquery:
SELECT COUNT(*)
FROM (
    SELECT DISTINCT *
    FROM health.user_logs
) AS subquery;

-- Removing unique values: Duplicate data
SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS record_count
FROM health.user_logs
GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
HAVING COUNT(*) > 1

WITH duplicate_data AS (
    SELECT
        id,
        log_date,
        measure,
        measure_value,
        systolic,
        diastolic,
        COUNT(*) AS record_count
    FROM health.user_logs
    GROUP BY
        id,
        log_date,
        measure,
        measure_value,
        systolic,
        diastolic
    HAVING COUNT(*) > 1
)
SELECT
    id,
    SUM(record_count) AS total_count
FROM duplicate_data
WHERE record_count > 1
GROUP BY id
ORDER BY total_count DESC