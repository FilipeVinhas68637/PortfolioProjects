/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject..NashvilleHousing

---------------------------------------------------------------

--Standardize SaleDate

Select SaleDate
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(DATE,SaleDate)   

-- If it doesn´t work we need to create a new column with the converted date

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------

--Populate Proprety Adress Data


Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--Equal ParcelID have the same adsress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------

--Breaking out Adress into Individual Columns (Adress, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, --charindex gives the position where we find the comma, so we do -1 to hide it
SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Easier away using PARSENAME
--OwnerAddress

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

--Add the values to the main table

Alter table NashvilleHousing
add OwnerSplitAddress NVARCHAR(255);

Alter table NashvilleHousing
add OwnerSplitAddressCity NVARCHAR(255);

Alter table NashvilleHousing
add OwnerSplitAddressState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-----------------------------------------------

--Changing Y and N to Yes and No from column SoldAsVacant


select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Numero
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,	
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
set SoldAsVacant =
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

--------------------------------------------------------

--Remove Duplicates

--See all duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

--delete them

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1


------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

