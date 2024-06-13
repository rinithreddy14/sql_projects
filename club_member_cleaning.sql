
-- Creating the 'club' database and selecting it for use
-- Uncomment the following lines if you need to create and select the database
-- The comments was genrated by ai (Because im not that perfect in advance english)
-- create database club;
-- use club;

-- Step 1: Data Type Conversion
-- Convert 'membership_date' from TEXT to DATE format

-- Ensure the 'membership_date' column is in a text format before proceeding
SELECT * FROM club_member_info;

-- Trim any extra spaces from 'membership_date'
UPDATE club_member_info 
SET 
    membership_date = TRIM(membership_date);

-- Add a new column to hold the converted date
ALTER TABLE club_member_info
ADD COLUMN membership_date1 DATE;

-- Convert the 'membership_date' to DATE format and store it in the new column
UPDATE club_member_info 
SET 
    membership_date1 = STR_TO_DATE(membership_date, '%c/%e/%Y');

-- Remove the old text column and rename the new date column
ALTER TABLE club_member_info
DROP COLUMN membership_date;

ALTER TABLE club_member_info
RENAME COLUMN membership_date1 TO membership_date;

-- Step 2: Address Parsing
-- Split 'full_address' into 'home_address', 'street', and 'state'

-- Trim extra spaces from 'full_address'
UPDATE club_member_info 
SET 
    full_address = TRIM(full_address);

-- Add columns for the parsed address components
ALTER TABLE club_member_info
ADD COLUMN home_address VARCHAR(100),
ADD COLUMN street VARCHAR(100),
ADD COLUMN state VARCHAR(100);

-- Parse and populate the address components
UPDATE club_member_info 
SET 
    home_address = SUBSTRING(full_address,
        1,
        LOCATE(',', full_address) - 1),
    street = SUBSTRING(full_address,
        LOCATE(',', full_address) + 1,
        LOCATE(',',
                full_address,
                LOCATE(',', full_address) + 1) - LOCATE(',', full_address) - 1),
    state = SUBSTRING(full_address,
        LOCATE(',',
                full_address,
                LOCATE(',', full_address) + 1) + 1);

-- Remove the old full address column
ALTER TABLE club_member_info
DROP COLUMN full_address;

-- Step 3: Name Parsing and Normalization
-- Split 'full_name' into 'first_name' and 'second_name', and convert to lowercase

-- Add columns for first and second names
ALTER TABLE club_member_info
ADD COLUMN first_name VARCHAR(100),
ADD COLUMN second_name VARCHAR(100);

-- Parse and populate the name components, converting to lowercase
UPDATE club_member_info 
SET 
    first_name = LOWER(REPLACE(SUBSTRING(full_name,
                    1,
                    LOCATE(' ', full_name) - 1),
                '?',
                '')),
    second_name = LOWER(SUBSTRING(full_name,
                LOCATE(' ', full_name) + 1));

-- Remove the old full name column
ALTER TABLE club_member_info
DROP COLUMN full_name;

-- Step 4: Age Validation
-- Remove rows with unrealistic age values

-- Create a temporary table to store invalid age rows for review
CREATE TABLE temp AS SELECT * FROM
    club_member_info
WHERE
    age < 18 OR age > 80 OR age IS NULL;

-- Delete rows with invalid ages from the main table
DELETE FROM club_member_info
WHERE age IN (SELECT age FROM temp);

-- Drop the temporary table
DROP TABLE temp;

-- Step 5: Marital Status Normalization
-- Correct spelling mistakes and handle blank values in 'marital_status'

-- Check for distinct marital status values and their counts
SELECT 
    marital_status, COUNT(1)
FROM
    club_member_info
GROUP BY marital_status;

-- Correct misspellings
UPDATE club_member_info 
SET 
    marital_status = 'divorced'
WHERE
    marital_status = 'divored';

-- Replace blank values with 'unknown'
UPDATE club_member_info 
SET 
    marital_status = 'unknown'
WHERE
    marital_status = '';

-- Step 6: Duplicate Handling
-- Remove duplicates based on 'email' and handle blanks in 'phone'

-- Identify duplicates based on email
CREATE TABLE temp AS SELECT email, COUNT(1) FROM
    club_member_info
GROUP BY email
HAVING COUNT(1) > 1;

-- Delete duplicate email entries from the main table
DELETE FROM club_member_info
WHERE email IN (SELECT email FROM temp);

-- Drop the temporary table
DROP TABLE temp;

-- Check for duplicate phone numbers and handle blanks
SELECT 
    phone, COUNT(1)
FROM
    club_member_info
GROUP BY phone
HAVING COUNT(1) > 1;

-- Replace blank phone values with 'unknown'
UPDATE club_member_info 
SET 
    phone = 'unknown'
WHERE
    phone = '';

-- Step 7: Handle Job Title Blanks
-- Replace blank job titles with 'unknown'

UPDATE club_member_info
SET job_title = "unknown" WHERE job_title = "";

-- Step 8: Final Table Reorganization
-- Rearrange columns in a specific order for better readability

CREATE TABLE temp AS SELECT first_name,
    second_name AS last_name,
    age,
    email,
    phone,
    marital_status,
    job_title,
    membership_date,
    home_address AS 'street',
    street AS city,
    state FROM
    club_member_info;

-- Drop the old table and rename the new table to the original name
DROP TABLE club_member_info;

ALTER TABLE temp
RENAME TO club_member_info;

-- Data cleaning completed successfully. Verify the table structure and contents
SELECT 
    *
FROM
    club_member_info;
