USE PortfolioProject;
-- Updating NULL Values
UPDATE PortfolioProject.nashvilehousing
SET PropertyAddress = NULL
WHERE PropertyAddress = '';

UPDATE PortfolioProject.nashvilehousing
SET SalePrice = NULL
WHERE SalePrice = '';

UPDATE PortfolioProject.nashvilehousing
SET OwnerName = NULL
WHERE OwnerName = '';

UPDATE PortfolioProject.nashvilehousing
SET OwnerAddress = NULL
WHERE OwnerAddress = '';

UPDATE PortfolioProject.nashvilehousing
SET Acreage = NULL
WHERE Acreage = '';

UPDATE PortfolioProject.nashvilehousing
SET TaxDistrict = NULL
WHERE TaxDistrict = '';

UPDATE PortfolioProject.nashvilehousing
SET LandValue = NULL
WHERE LandValue = '';

UPDATE PortfolioProject.nashvilehousing
SET BuildingValue = NULL
WHERE BuildingValue = '';

UPDATE PortfolioProject.nashvilehousing
SET TotalValue = NULL
WHERE TotalValue = '';

UPDATE PortfolioProject.nashvilehousing
SET YearBuilt = NULL
WHERE YearBuilt = '';

UPDATE PortfolioProject.nashvilehousing
SET Bedrooms = NULL
WHERE Bedrooms = '';

UPDATE PortfolioProject.nashvilehousing
SET FullBath = NULL
WHERE FullBath = '';

UPDATE PortfolioProject.nashvilehousing
SET HalfBath = NULL
WHERE HalfBath = '';

UPDATE PortfolioProject.nashvilehousing
SET SalePrice = REPLACE(REPLACE(SalePrice, ',', ''), '$', '');

-- Modifying The Table Data Types
ALTER TABLE PortfolioProject.nashvilehousing
MODIFY SaleDate DATE,
MODIFY SalePrice INT,
MODIFY SoldAsVacant CHAR(3),
MODIFY Acreage FLOAT,
MODIFY LandValue INT,
MODIFY BuildingValue INT,
MODIFY TotalValue INT,
MODIFY YearBuilt INT,
MODIFY Bedrooms INT,
MODIFY FullBath INT,
MODIFY HalfBath INT;


# Cleaning Data In SQL Queries
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM PortfolioProject.nashvilehousing;

-- Populate Property Address Data

SELECT * FROM PortfolioProject.nashvilehousing
 --  WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.nashvilehousing a
JOIN PortfolioProject.nashvilehousing b 
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE PortfolioProject.nashvilehousing a
JOIN (
    SELECT a.UniqueID, IFNULL(a.PropertyAddress, b.PropertyAddress) AS NewAddress
    FROM PortfolioProject.nashvilehousing a
    JOIN PortfolioProject.nashvilehousing b 
    ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress IS NULL
) AS subquery
ON a.UniqueID = subquery.UniqueID
SET a.PropertyAddress = subquery.NewAddress;

-- Breaking Out Address Into Individual Columns (Address, City, State)
SELECT PropertyAddress FROM PortfolioProject.nashvilehousing;

SELECT 
SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1) AS Address,
SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) AS Address
FROM PortfolioProject.nashvilehousing;

ALTER TABLE PortfolioProject.nashvilehousing
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE PortfolioProject.nashvilehousing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1);

ALTER TABLE PortfolioProject.nashvilehousing
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvilehousing
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress));

SELECT * FROM PortfolioProject.nashvilehousing;


SELECT OwnerAddress 
FROM PortfolioProject.nashvilehousing;

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM PortfolioProject.nashvilehousing;
       
ALTER TABLE PortfolioProject.nashvilehousing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE PortfolioProject.nashvilehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE PortfolioProject.nashvilehousing
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvilehousing
SET OwnerSplitCity =SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE PortfolioProject.nashvilehousing
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE PortfolioProject.nashvilehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT * FROM PortfolioProject.nashvilehousing;


-- Change Y and N to Yes and No in "SoldAsVacant" Column
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.nashvilehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM PortfolioProject.nashvilehousing;

UPDATE PortfolioProject.nashvilehousing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             ORDER BY UniqueID 
             ) row_num
FROM PortfolioProject.nashvilehousing
ORDER BY UniqueID
)

SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY UniqueID;

DELETE -- Works Only in SQL_SERVER (Not in Oracle - MySql)
FROM RowNumCTE 
WHERE row_num > 1;

DELETE FROM PortfolioProject.nashvilehousing
WHERE UniqueID NOT IN (
    SELECT subquery.UniqueID 
    FROM (
        SELECT MIN(UniqueID) AS UniqueID
        FROM PortfolioProject.nashvilehousing
        GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ) AS subquery
);

-- Delete Unused Columns
SELECT * 
FROM PortfolioProject.nashvilehousing;

ALTER TABLE PortfolioProject.nashvilehousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

