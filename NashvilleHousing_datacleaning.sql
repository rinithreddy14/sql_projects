-- Create and use the database
-- Note: Only include this if the database does not already exist
-- CREATE DATABASE housing;
USE housing;

-- Select all data from housing table for initial inspection
SELECT * FROM housing;

-- Step 1: Convert SaleDate from text to datetime
UPDATE housing
SET SaleDate = STR_TO_DATE(SaleDate, "%M %d, %Y");

-- Modify the column type to date
ALTER TABLE housing
MODIFY COLUMN SaleDate DATE;

-- Step 2: Convert YearBuilt from text to datetime
UPDATE housing
SET YearBuilt = STR_TO_DATE(CONCAT(YearBuilt, '01-01'), "%Y-%m-%d");

-- Modify the column type to date
ALTER TABLE housing
MODIFY COLUMN YearBuilt DATE;

-- Step 3: Remove duplicate values (if any)
-- Check for complete row duplicates
SELECT DISTINCT * FROM housing;

-- Step 4: Standardize string values to lowercase
UPDATE housing
SET LandUse = LOWER(LandUse),
    OwnerName = LOWER(OwnerName),
    TaxDistrict = LOWER(TaxDistrict),
    PropertyAddress = LOWER(PropertyAddress),
    OwnerAddress = LOWER(OwnerAddress);

-- Standardize SoldAsVacant values
UPDATE housing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N';

UPDATE housing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y';

-- Step 5: Handle blank columns or rows
-- Check for blank values
SELECT * FROM housing
WHERE ParcelID = '' OR LandUse = '' OR PropertyAddress = '' OR OwnerName = '' OR OwnerAddress = '' OR TaxDistrict = '' OR LegalReference = '' OR SoldAsVacant = '';

-- Check for null values in integer columns
SELECT * FROM housing
WHERE UniqueID IS NULL OR SalePrice IS NULL OR LandValue IS NULL OR BuildingValue IS NULL OR TotalValue IS NULL OR FullBath IS NULL OR HalfBath IS NULL OR Bedrooms IS NULL;

-- Replace blank values with 'unknown'
UPDATE housing
SET PropertyAddress = 'unknown'
WHERE PropertyAddress = '';

UPDATE housing
SET OwnerName = 'unknown'
WHERE OwnerName = '';

-- Step 6: Split PropertyAddress into individual parts
ALTER TABLE housing
ADD PropertyState VARCHAR(20);

UPDATE housing
SET PropertyState = TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1));

ALTER TABLE housing
ADD PropertyStreet VARCHAR(40);

UPDATE housing
SET PropertyStreet = TRIM(SUBSTRING(PropertyAddress, 1, LOCATE(' ', PropertyAddress) - 1));

ALTER TABLE housing
ADD PropertyDetails VARCHAR(40);

UPDATE housing
SET PropertyDetails = TRIM(SUBSTRING(PropertyAddress, LOCATE(' ', PropertyAddress) + 1, LOCATE(',', PropertyAddress) - 1));

-- Step 7: Split OwnerAddress into individual parts
ALTER TABLE housing
ADD OwnerState VARCHAR(20);

UPDATE housing
SET OwnerState = TRIM(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress) + 1));

ALTER TABLE housing
ADD OwnerStreet VARCHAR(40);

UPDATE housing
SET OwnerStreet = TRIM(SUBSTRING(OwnerAddress, 1, LOCATE(' ', OwnerAddress) - 1));

ALTER TABLE housing
ADD OwnerDetails VARCHAR(40);

UPDATE housing
SET OwnerDetails = TRIM(SUBSTRING(OwnerAddress, LOCATE(' ', OwnerAddress) + 1, LOCATE(',', OwnerAddress) - 1));

-- Step 8: Drop unnecessary columns
ALTER TABLE housing
DROP COLUMN PropertyAddress;

ALTER TABLE housing
DROP COLUMN OwnerAddress;

ALTER TABLE housing
DROP COLUMN TaxDistrict;

-- Step 9: Create a temporary table with ordered columns
CREATE TABLE temp_table AS
SELECT UniqueID, ParcelID, TRIM(LandUse) AS LandUse, Acreage,
       PropertyStreet, PropertyDetails, PropertyState, LegalReference, YearBuilt,
       LandValue, BuildingValue, TotalValue, SaleDate, SalePrice, SoldAsVacant,
       OwnerName, OwnerStreet, OwnerDetails, OwnerState,
       Bedrooms, FullBath, HalfBath
FROM housing
ORDER BY UniqueID;

-- Step 10: Replace the original table with the temporary table
DROP TABLE housing;

ALTER TABLE temp_table
RENAME TO housing;

-- Final step: Verify the structure and data of the new table
SELECT * FROM housing;
