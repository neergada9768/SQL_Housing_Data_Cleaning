--Data Cleaning Project

SELECT *
FROM SQL_Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Sale Date to Standardized Format

 Select SaleDate, Convert(Date, SaleDate)
FROM SQL_Project.dbo.NashvilleHousing

 Alter Table SQL_Project.dbo.NashvilleHousing
 Add SaleDateConverted Date;

 Update SQL_Project.dbo.NashvilleHousing
 Set SaleDateConverted = Convert(Date, SaleDate)


 Select SaleDateConverted, Convert(Date, SaleDate)
FROM SQL_Project.dbo.NashvilleHousing

 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 --Populating Property address data using existing data

 Select *
FROM SQL_Project.dbo.NashvilleHousing
 Where PropertyAddress is null

 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_Project.dbo.NashvilleHousing a
 Join SQL_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQL_Project.dbo.NashvilleHousing a
 Join SQL_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking Address into individual columns

--Property Address split by ','
 
 SELECT PropertyAddress
FROM SQL_Project.dbo.NashvilleHousing

Select 
Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , LEN(PropertyAddress)) AS AddressCity
FROM SQL_Project.dbo.NashvilleHousing

 Alter Table SQL_Project.dbo.NashvilleHousing
 Add SplitAddress nvarchar(255);

 Update SQL_Project.dbo.NashvilleHousing
 Set SplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

  Alter Table SQL_Project.dbo.NashvilleHousing
 Add SplitCity nvarchar(255);

 Update SQL_Project.dbo.NashvilleHousing
 Set SplitCity = Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , LEN(PropertyAddress))


--Owner Address Split
Select OwnerAddress 
From SQL_Project.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress , ',','.'), 3),
PARSENAME(Replace(OwnerAddress , ',','.'), 2),
PARSENAME(Replace(OwnerAddress , ',','.'), 1)
From SQL_Project.dbo.NashvilleHousing


 Alter Table SQL_Project.dbo.NashvilleHousing
 Add OwnerSplitStreet nvarchar(255);

 Update SQL_Project.dbo.NashvilleHousing
 Set OwnerSplitStreet = PARSENAME(Replace(OwnerAddress , ',','.'), 3)

  Alter Table SQL_Project.dbo.NashvilleHousing
 Add OwnerSplitCity nvarchar(255);

 Update SQL_Project.dbo.NashvilleHousing
 Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress , ',','.'), 2)

  Alter Table SQL_Project.dbo.NashvilleHousing
 Add OwnerSplitState nvarchar(255);

 Update SQL_Project.dbo.NashvilleHousing
 Set OwnerSplitState = PARSENAME(Replace(OwnerAddress , ',','.'), 1)


 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 --Change Y and N to Yes and No in 'SoldAsVacant'

 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
 From SQL_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
 From SQL_Project.dbo.NashvilleHousing

 Update SQL_Project.dbo.NashvilleHousing
 SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
  

  ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

--Find Duplicates
With RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference	
   ORDER BY UniqueID
   ) row_num
  From SQL_Project.dbo.NashvilleHousing
  --Order By ParcelID
)
Select *
From RowNumCTE
Where row_num>1
Order By PropertyAddress


--Delete Duplicates
With RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference	
   ORDER BY UniqueID
   ) row_num
  From SQL_Project.dbo.NashvilleHousing
  --Order By ParcelID
)
DELETE
From RowNumCTE
Where row_num>1
--Order By PropertyAddress


--Delete Unused Columns

SELECT *
FROM SQL_Project.dbo.NashvilleHousing

Alter Table SQL_Project.dbo.NashvilleHousing
Drop Column OwnerAddress, SaleDate, LegalReference, PropertyAddress