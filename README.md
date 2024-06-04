# Housing Data Cleaning Script

This repository contains an SQL script designed to clean and preprocess housing data stored in a MySQL database.
The script performs various data cleaning tasks, including date conversion, standardizing text, handling missing values, and reorganizing the schema.
The goal is to prepare the data for analysis by ensuring consistency and accuracy.

## Script Overview

The script is divided into several steps, each addressing a specific aspect of data cleaning:

1. **Initial Setup**
   - Select all data for initial inspection.
   - Convert `SaleDate` from text to `DATE` type.

2. **YearBuilt Conversion**
   - Convert `YearBuilt` from text to `YEAR` type directly.

3. **Duplicate Removal**
   - Check for and remove any complete row duplicates.

4. **Standardize Text Fields**
   - Convert string values to lowercase for consistency.
   - Standardize `SoldAsVacant` values from 'N'/'Y' to 'No'/'Yes'.

5. **Handling Missing Values**
   - Identify and replace blank values in text fields with 'unknown'.
   - Ensure no `NULL` values exist in integer columns.

6. **Address Splitting**
   - Split `PropertyAddress` and `OwnerAddress` into individual parts (street, address, state).

7. **Drop Unnecessary Columns**
   - Remove the original address and district columns after splitting.

8. **Reorganize Table Schema**
   - Create a temporary table with ordered columns.
   - Replace the original table with the new schema.

9. **Verification**
   - Verify the structure and data of the new table.

