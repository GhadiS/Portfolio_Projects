SELECT*
FROM Portfolio_Project_Alex_Housing..Housing_Data$
;

-- Standarizing the date format by converting it to an actual date
SELECT 
	SaleDate, CONVERT(Date, SaleDate) as Date
FROM Portfolio_Project_Alex_Housing..Housing_Data$
;


-- Updating the table with the correct date by removing the time
ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
ADD Proper_Sale_Date Date
;

Update Portfolio_Project_Alex_Housing..Housing_Data$
Set Proper_Sale_Date = CONVERT(Date, SaleDate)
;
-- Making sure the table has been updated
SELECT Proper_Sale_Date
FROM Portfolio_Project_Alex_Housing..Housing_Data$
;

--Populating the PropertyAddress null rows
SELECT*
FROM Portfolio_Project_Alex_Housing..Housing_Data$
WHERE PropertyAddress is null
;

SELECT*
FROM Portfolio_Project_Alex_Housing..Housing_Data$
ORDER BY ParcelID -- Each unique ParcelID has a distinct PropertyAddress
;

-- Hence we can Populate the Null Addresses by joining the ParcelID with the missing address to the same ParcelID where the address is showsn
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) as Address
FROM Portfolio_Project_Alex_Housing..Housing_Data$ as a
Join Portfolio_Project_Alex_Housing..Housing_Data$ as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null
;

--Save the new Column

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_Alex_Housing..Housing_Data$ as a
Join Portfolio_Project_Alex_Housing..Housing_Data$ as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null
;

--Removing the comma after "DR" from the PopertyAddress rows and seprating what's after the comma into a new column

SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, -- takes all the characters before the comma
 SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address_2 -- Takes everything after the comma and puts it in a new column
 FROM Portfolio_Project_Alex_Housing..Housing_Data$

 --To split the column, we have to create 2 new columns

 ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
 ADD Property_Split_Address Nvarchar (255)
 ;
 UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
 SET Property_Split_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
;

 ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
 ADD Property_Split_City Nvarchar (255)
 ;
 UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
 SET Property_Split_City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 --Doing the same thing for OwnerAddress column, using a simpler method
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- We added the replace bcause PARSENAME only works for periods (.), so we had to change the commas to periods for PARSENAME to be abel to work and identify the function
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project_Alex_Housing..Housing_Data$

--Saving the new columns
--ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
--ADD OWNER_Split_ADDRESS Nvarchar (255)
-- ;
-- UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
-- SET Property_Split_ADDRESS = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
--ADD OWNER_Split_CITY Nvarchar (255)
-- ;
-- UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
-- SET Property_Split_CITY = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
--ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
--ADD OWNER_Split_STATE Nvarchar (255)
-- ;
-- UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
-- SET Property_Split_STATE = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-- ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
-- DROP COLUMN OWNER_Split_ADDRESS
-- ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
-- DROP COLUMN OWNER_Split_CITY
-- ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
-- DROP COLUMN OWNER_Split_STATE

ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
ADD Owner_Split_Address Nvarchar (255)
 ;
 UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
 SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 ;
ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
ADD Owner_Split_City Nvarchar (255)
 ;
 UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
 SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 ;
ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
ADD Owner_Split_State Nvarchar (255)
 ;
 UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
 SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 SELECT DISTINCT (SoldAsVacant),
 COUNT(SoldAsVacant)
 FROM Portfolio_Project_Alex_Housing..Housing_Data$
 GROUP BY SoldAsVacant

 -- We have four categories 'Y' and 'Yes, 'N' and 'No', we need to fix these
 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No' 
	  ELSE SoldAsVacant
	  END as Sold_As_Vacant
 FROM Portfolio_Project_Alex_Housing..Housing_Data$

--Updating the Table
UPDATE Portfolio_Project_Alex_Housing..Housing_Data$
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No' 
	  ELSE SoldAsVacant
	  END 

--Remove Duplicates by creating a CTE to find the duplicates
--We use ROW_NUMBER and Partition to check for duplicate full rows

SELECT*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
ORDER BY UniqueID
	) as row_num
FROM Portfolio_Project_Alex_Housing..Housing_Data$
ORDER BY ParcelID

-- To be able to use row_num we need to create it in a CTE

WITH TEMP_ROW_TABLE AS (
SELECT*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
ORDER BY UniqueID
	) as row_num
FROM Portfolio_Project_Alex_Housing..Housing_Data$
)
SELECT*
FROM TEMP_ROW_TABLE
WHERE row_num > 1
-- We have 104 duplicates we need to delete
DELETE
FROM TEMP_ROW_TABLE
WHERE row_num > 1

--Delete unneeded columns (the ones we split previously)

ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE Portfolio_Project_Alex_Housing..Housing_Data$
DROP COLUMN SaleDate

