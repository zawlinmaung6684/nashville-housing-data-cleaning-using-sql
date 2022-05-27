-- Creating Table for Importing Data
CREATE TABLE nashville(
	UniqueID INT,
    ParcelID TEXT,
    LandUse	TEXT,
    PropertyAddress	TEXT,
    SaleDate DATE,
    SalePrice DOUBLE,
    LegalReference TEXT,
    SoldAsVacant TEXT,
    OwnerName TEXT,
    OwnerAddress TEXT,
    Acreage	DOUBLE,
    TaxDistrict	TEXT,
    LandValue INT,
    BuildingValue INT,	
    TotalValue INT,
    YearBuilt YEAR,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

DROP TABLE IF EXISTS nashville;

SET GLOBAL local_infile  = 1;

-- Importing Data
LOAD DATA LOCAL INFILE 'D:/.../Nashville Housing  SQL Data Cleaning/NashvilleHousingDataforDataCleaning.txt'
INTO TABLE nashville
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- A Quick View at the Data
SELECT *
FROM nashville
LIMIT 10;