/* Housing Data Cleaning and Transformation */

SELECT*
FROM Project05..HousingData


-- 01) Turning the DATETIME Format to just DATE

SELECT SaleDate, CONVERT(Date, SaleDate)  -- Coverting to DATE
FROM Project05..HousingData

ALTER TABLE Project05..HousingData ADD Sale_Date Date  -- Creating a new column to store the new DATE formast

UPDATE Project05..HousingData
SET Sale_Date = CONVERT(Date, SaleDate) --Populating the new DATE column

ALTER TABLE Project05..HousingData DROP COLUMN SaleDate --Delete the DATETIME format column from the table

-- Checking
SELECT *
FROM Project05..HousingData




-- 02) Populating the PropertyAddress Data Where PropertyAddress is NULL

SELECT *
FROM Project05..HousingData
ORDER BY ParcelID

-- Some of the PropertyAddress are NULL but they can by populated from other PropertyAddress with thesame ParcelID
-- To do this, I will do a self JOIN

SELECT Blank.ParcelID, Blank.PropertyAddress, Similar.ParcelID, Similar.PropertyAddress, ISNULL(Blank.PropertyAddress, Similar.PropertyAddress)
FROM Project05..HousingData AS Blank
 JOIN Project05..HousingData AS Similar
 ON Blank.ParcelID = Similar.ParcelID
 AND Blank.UniqueID <> Similar.UniqueID
WHERE Blank.PropertyAddress IS NULL

UPDATE Blank
SET PropertyAddress = ISNULL(Blank.PropertyAddress, Similar.PropertyAddress)
FROM Project05..HousingData AS Blank
 JOIN Project05..HousingData AS Similar
 ON Blank.ParcelID = Similar.ParcelID
 AND Blank.UniqueID <> Similar.UniqueID
WHERE Blank.PropertyAddress IS NULL

-- Checking
SELECT *
FROM Project05..HousingData




-- 03) Splitting Address into separate columns such as Address, City, State

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Project05..HousingData

ALTER TABLE Project05..HousingData ADD SplitPropertyAddress nvarchar(255);

UPDATE Project05..HousingData
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Project05..HousingData ADD SplitPropertyCity  nvarchar(255);

UPDATE Project05..HousingData
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

ALTER TABLE Project05..HousingData DROP COLUMN PropertyAddress

-- Checking
SELECT *
FROM Project05..HousingData


-- 04) Splitting the Owner Address into Separate Columns Using PARSENAME
-- PRSENAME only identify '.' as delimiter and it operates backwards. Therefore, I will replace ',' with '.' and reverse the number from 3 to 1

SELECT
 PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3) AS SplitOwnerAddress,
 PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2) AS SplitOwnerCity,
 PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) AS SplitOwnerState
FROM Project05..HousingData

ALTER TABLE Project05..HousingData ADD SplitOwnerAddress  nvarchar(255);

UPDATE Project05..HousingData
SET SplitOwnerAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Project05..HousingData ADD SplitOwnerCity  nvarchar(255);

UPDATE Project05..HousingData
SET SplitOwnerCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Project05..HousingData ADD SplitOwnerState  nvarchar(255);

UPDATE Project05..HousingData
SET SplitOwnerState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1);

ALTER TABLE Project05..HousingData DROP COLUMN OwnerAddress

-- Checking
SELECT *
FROM Project05..HousingData




-- Replacing Y and N to Yes and No in the Column SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project05..HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant END
FROM Project05..HousingData

UPDATE Project05..HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                   WHEN SoldAsVacant = 'N' THEN 'No'
	               ELSE SoldAsVacant END

-- Checking
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project05..HousingData
GROUP BY SoldAsVacant
ORDER BY 2


-- Removing Duplicates

WITH RowNumCTE AS
(
 SELECT *, 
  ROW_NUMBER() OVER ( PARTITION BY ParcelID,SalePrice, Sale_Date, LegalReference ORDER BY UniqueID ) AS RowNumber

FROM Project05..HousingData
)
DELETE
FROM RowNumCTE
WHERE RowNumber > 1

