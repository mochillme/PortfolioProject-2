                   
----- cleaning data in sql queries
  
select *
  from portfolioproject..Housingdata


------  standardise date format

select SaleDateConverted, CONVERT(Date, SaleDate)
  from portfolioproject..Housingdata

Update Housingdata
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Housingdata
Add SaleDateConverted Date;

Update Housingdata
SET SaleDateConverted = CONVERT(Date, SaleDate)



--- populate property address data

select *
  from portfolioproject..Housingdata
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from portfolioproject..Housingdata a
  JOIN portfolioproject..Housingdata b
      ON a.ParcelID = b.ParcelID
	   AND a.[UniqueID] <> b.[UniqueID]
where b.PropertyAddress is null

Update b
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioproject..Housingdata a
  JOIN portfolioproject..Housingdata b
      ON a.ParcelID = b.ParcelID
	   AND a.[UniqueID] <> b.[UniqueID]
where b.PropertyAddress is null


---Breaking out address into individual columns

select PropertyAddress
  from portfolioproject..Housingdata
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address  

from portfolioproject..Housingdata

ALTER TABLE portfolioproject..Housingdata
Add PropertySplitAddress Nvarchar(255);

Update portfolioproject..Housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE portfolioproject..Housingdata
Add PropertySplitCity Nvarchar(255);

Update portfolioproject..Housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from portfolioproject..Housingdata

---2nd method

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

from portfolioproject..Housingdata

ALTER TABLE portfolioproject..Housingdata
Add OwnerSplitAddress Nvarchar(255);

Update portfolioproject..Housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE portfolioproject..Housingdata
Add OwnerSplitCity Nvarchar(255);

Update portfolioproject..Housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE portfolioproject..Housingdata
Add OwnerSplitState Nvarchar(255);

Update portfolioproject..Housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---- change Y and N to No and Yes in "Sold as Vacant" Field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from portfolioproject..Housingdata
Group by SoldAsVacant
Order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from portfolioproject..Housingdata

UPDATE portfolioproject..Housingdata
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----remove duplicates

WITH RowNumCTE AS(
select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				  UniqueID
				  ) row_num

from portfolioproject..Housingdata
--order by ParcelID
)
select *
--DELETE
From RowNumCTE
where row_num > 1 
Order by PropertyAddress


--- DELETE Unused columns

select *
from portfolioproject..Housingdata

ALTER TABLE portfolioproject..Housingdata
DROP COLUMN OwnerAddress, SaleDate, TaxDistrict
, PropertyAddress



















