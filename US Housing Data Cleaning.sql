Select*
From HousingData..NashvilleHousing

--Standardize Date Format
Select salesdateconverted, Convert(Date,SaleDate)
From HousingData..NashvilleHousing

Alter Table NashvilleHousing
Add SalesDateConverted Date;

update NashvilleHousing 
SET SalesdateConverted = Convert(Date,SaleDate)

--Populate Property Address Data (Data Cleaning)
Select a.ParcelID, a.Propertyaddress, b.parcelId, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
From HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[uniqueID]
WHERE a.propertyaddress is null

update a
SET Propertyaddress =  ISNULL(a.propertyaddress, b.propertyaddress)
From HousingData..NashvilleHousing a
JOIN HousingData..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID]
WHERE a.propertyaddress is null



--Breaking address into Individual columns (Address, City, State)
Select PropertyAddress
From HousingData..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress ,1, Charindex(',' ,PropertyAddress) -1) as Address
, SUBSTRING(Propertyaddress, Charindex(',', Propertyaddress) +1, Len(Propertyaddress)) as City
From HousingData..nashvillehousing 

Alter Table NashvilleHousing
Add PropertySplitaddress Nvarchar(255);

update NashvilleHousing 
SET PropertySplitaddress = SUBSTRING(PropertyAddress ,1, Charindex(',' ,PropertyAddress) -1)

Alter Table NashvilleHousing
Add Propertysplitcity Nvarchar(255);

update NashvilleHousing 
SET Propertysplitcity = SUBSTRING(Propertyaddress, Charindex(',', Propertyaddress) +1, Len(Propertyaddress))

--Breaking Owneraddress into Individual columns

SELECT
PARSENAME(REPLACE(Owneraddress,',','.'),3)
,PARSENAME(REPLACE(Owneraddress,',','.'),2)
,PARSENAME(REPLACE(Owneraddress,',','.'),1)
FROM HousingData..Nashvillehousing



Alter Table NashvilleHousing
Add Ownersplitaddress Nvarchar(255);

update NashvilleHousing 
SET Ownersplitaddress = PARSENAME(REPLACE(Owneraddress,',','.'),3)

Alter Table NashvilleHousing
Add ownersplitcity Nvarchar(255);

update NashvilleHousing 
SET ownersplitcity = PARSENAME(REPLACE(Owneraddress,',','.'),2)

Alter Table NashvilleHousing
Add ownersplitstate Nvarchar(255);

update NashvilleHousing 
SET ownersplitstate = PARSENAME(REPLACE(Owneraddress,',','.'),1)



-- Change Y and N to yes and no in "sold as vacant" field
select soldasvacant, count(soldasvacant)
From Housingdata..NashvilleHousing
Group by soldasvacant
order by 2


Select soldasvacant
, CASE when soldasvacant ='Y' THEN 'YES'
       when soldasvacant = 'N' Then 'NO'
	   ELSE soldasvacant
	   END
From Housingdata..NashvilleHousing



UPDATE nashvillehousing
SET soldasvacant =  CASE when soldasvacant ='Y' THEN 'YES'
       when soldasvacant = 'N' Then 'NO'
	   ELSE soldasvacant
	   END



--Removing duplicates
WITH RowNumCTE AS(
select *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID, 
	              Propertyaddress,
				  SalePrice,
				  SaleDate,
				  LEgalReference
				  ORDER by
				     UniqueID
					 ) row_num
From Housingdata..NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num >1
Order by propertyaddress


--Delete Unused Columns
Select *
From Housingdata..NashvilleHousing

ALTER TABLE Housingdata..NashvilleHousing
DROP COLUMN  Owneraddress, TaxDistrict, Propertyaddress

ALTER TABLE Housingdata..NashvilleHousing
DROP COLUMN  Saledate