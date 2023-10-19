/*

CLEANING DATA IN SQL QUERIES

*/


Select * from PortfolioProject.dbo.NashvilleHoushing

--------------------------------------------------------------------------------------------

--------------------- Standarlise Date Format

--Cara 1 tidak berhasil dan hasilnya bersifat sementara

Select SaleDate, CONVERT(Date,SaleDate)
	from PortfolioProject.dbo.NashvilleHoushing

Update NashvilleHoushing
	Set SaleDate = CONVERT(Date,SaleDate)

-- Cara 2 berhasil

ALTER TABLE NashvilleHoushing
	add SaleDateConverted Date;

Update NashvilleHoushing
	Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
	from PortfolioProject.dbo.NashvilleHoushing

----------------------------------------------------------------------------------------

------------------------- Populate Property Address Data

Select PropertyAddress
	from PortfolioProject.dbo.NashvilleHoushing
where PropertyAddress is null

--Property addres ada yang null, kita harus cari penyebabnya

Select *
	from  PortfolioProject.dbo.NashvilleHoushing
order by ParcelID

--setelah diselidiki, property addres selalu sama dengan Parcel ID, 
--sehingga jika ada property addres yang null, kita populate dengan mencocokan dengan parcel ID yang sama 
--dan memasukan property addres yang sudah tersedia berdasarkan berdasarkan parcel ID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, a.[UniqueID ], b.[UniqueID ], ISNULL(a.PropertyAddress,b.PropertyAddress)
from  PortfolioProject.dbo.NashvilleHoushing a
JOIN PortfolioProject.dbo.NashvilleHoushing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from  PortfolioProject.dbo.NashvilleHoushing a
JOIN PortfolioProject.dbo.NashvilleHoushing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------

--------------------------- Breaking out Adress into Individual Columns (Address, City, State)

Select PropertyAddress
	from  PortfolioProject.dbo.NashvilleHoushing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) as Address
	from  PortfolioProject.dbo.NashvilleHoushing


ALTER TABLE NashvilleHoushing
	add PropertySplitAddress Nvarchar(255);

Update NashvilleHoushing
	Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHoushing
	add PropertySplitCity Nvarchar(255);

Update NashvilleHoushing
	Set PropertySplitCity  = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) )

Select *
	from  PortfolioProject.dbo.NashvilleHoushing



Select OwnerAddress
	from  PortfolioProject.dbo.NashvilleHoushing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	from  PortfolioProject.dbo.NashvilleHoushing

ALTER TABLE NashvilleHoushing
	add OwnerSplitAddress Nvarchar(255);
	
Update NashvilleHoushing
	Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHoushing
	add OwnerSplitCity Nvarchar(255);
	
Update NashvilleHoushing
	Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHoushing
	add OwnerSplitState Nvarchar(255);
	
Update NashvilleHoushing
	Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
	from  PortfolioProject.dbo.NashvilleHoushing

----------------------------------------------------------------------------------------------------------------------

---------------------------- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	From PortfolioProject.dbo.NashvilleHoushing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHoushing


Update NashvilleHoushing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------------------------------------------------------

-------------------------------- Remove Duplicate

Select *
	from  PortfolioProject.dbo.NashvilleHoushing

--cara melihat duplikat
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)
				row_num
	from  PortfolioProject.dbo.NashvilleHoushing)

Select * from RowNumCTE
	where row_num > 1
	order by PropertyAddress

--delete duplicate
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID)
				row_num
	from  PortfolioProject.dbo.NashvilleHoushing)

DELETE from RowNumCTE
	where row_num > 1

--Setelah delete, cek lagi datanya masih ada atau sudah dihapus
	
------------------------------------------------------------------------------------------------------------

-------------------------------Delete Unused Columns

Select *
	from  PortfolioProject.dbo.NashvilleHoushing


ALTER TABLE PortfolioProject.dbo.NashvilleHoushing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


