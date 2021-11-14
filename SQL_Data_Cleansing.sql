

-- Data Cleansing Using SQL




-- Standardizing Date format

Alter Table housing_data
ADD SaleDate2 Date

Update housing_data
SET SaleDate2 = CONVERT(date, SaleDate)

Select SaleDate2
From SQLPortfolio..housing_data




-- Populating Propety Address Data

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From SQLPortfolio..housing_data a
Join SQLPortfolio..housing_data b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL

Select PropertyAddress
From SQLPortfolio..housing_data
Where PropertyAddress is NULL




-- Breaking Address into Address, City, State

ALTER TABLE housing_data
ADD PropertySplitAddress nvarchar (255)

Update housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE housing_data
ADD PropertySplitCity nvarchar (255)

Update housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From SQLPortfolio..housing_data



ALTER TABLE housing_data
ADD OwnerSplitAddress nvarchar (255)

Update housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing_data
ADD OwnerSplitCity nvarchar (255)

Update housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing_data
ADD OwnerSplitState nvarchar (255)

Update housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From SQLPortfolio..housing_data




-- In 'SoldAsVacant' field changing Y to Yes and N to No

UPDATE housing_data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						END




-- Removing Duplicates

WITH RowNum AS(
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference,
				 SalePrice
				 Order BY
				     UniqueID
				     ) row_num
From SQLPortfolio..housing_data
)
DELETE 
From RowNum
Where row_num > 1




-- Deleting useless Columns

ALTER TABLE housing_data
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

