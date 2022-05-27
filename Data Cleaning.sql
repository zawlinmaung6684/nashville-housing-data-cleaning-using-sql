SELECT *
FROM nashville;

-- Updating Empty Values with NULL for Each Column
UPDATE nashville
SET OwnerName = NULL
WHERE OwnerName = "";

UPDATE nashville
SET OwnerAddress = NULL
WHERE OwnerAddress = "";

UPDATE nashville
SET TaxDistrict = NULL
WHERE TaxDistrict = "";

-- Remove Leading and Trailing Double Quotes in Each Column
UPDATE nashville
SET ParcelID = TRIM(BOTH '"' FROM ParcelID),
	PropertyAddress = TRIM(BOTH '"' FROM PropertyAddress),
	OwnerName = TRIM(BOTH '"' FROM OwnerName),
    OwnerAddress = TRIM(BOTH '"' FROM OwnerAddress),
    LegalReference = TRIM(BOTH '"' FROM LegalReference);

-- Populate Property Address Data
SELECT 
	a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS AddressToAdd
FROM nashville a 
	JOIN nashville b
    ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville a
	INNER JOIN nashville b
    ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking Out Address into Individual Columns (Address, City, State)
SELECT
	PropertyAddress,
	REPLACE(SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)), ',', '') AS Address,
    REPLACE(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)), ',', '') AS City
FROM nashville;

-- Create Two New Columns and Insert Splitted Addresses
ALTER TABLE nashville
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville
SET PropertySplitAddress = REPLACE(SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)), ',', '');

ALTER TABLE nashville
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville
SET PropertySplitCity = REPLACE(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)), ',', '');

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM nashville;

-- Split OwnerAddress to Three Separated Addresses
SELECT 
	OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitCity,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState
FROM nashville;

-- Create Three New Columns and Insert Splitted Addresses
ALTER TABLE nashville
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashville
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashville
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM nashville;

-- Checking SoldAsVacant Column
SELECT DISTINCT SoldAsVacant
FROM nashville;

-- Delete Incorrect Rows
DELETE 
FROM nashville
WHERE SoldAsVacant NOT IN ('Yes', 'No', 'Y', 'N') OR SoldAsVacant IS NULL;

-- Distinct Count 
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS valueCount
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2;

-- Change Y and N to Yes and No
SELECT 
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END
FROM nashville;

UPDATE nashville
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
	END;

-- Remove Duplicates
DELETE 
FROM nashville
WHERE UniqueID IN (
	SELECT UniqueID
    FROM (
		SELECT 
			UniqueID,
			ROW_NUMBER() OVER (PARTITION BY ParcelID, 
										PropertyAddress, 
                                        SalePrice,
                                        SaleDate,
                                        LegalReference
							 ORDER BY UniqueID) AS row_num
		FROM nashville
	) AS t1
	WHERE row_num > 1
);

-- Delete Unused Columns
SELECT * 
FROM nashville;

ALTER TABLE nashville
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;