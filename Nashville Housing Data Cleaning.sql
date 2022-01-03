/*

Cleaning Data with SQL

*/

Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------

-- Have Sale date standardized

Select SaleDateConverted , CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID



--Using Substring and charindex
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplityCity nvarchar(255);

Update NashvilleHousing
Set PropertySplityCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))

select *
from NashvilleHousing



--Using parse name

select OwnerAddress
from NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.') ,3),
PARSENAME(Replace(OwnerAddress, ',', '.') ,2),
PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

select *
from NashvilleHousing



--------------------------------------------------------------------------------------------------

-- Change Y/N to Yes and No in "Sold as Vacant" column

-- Checking for Y, Yes, N, and No under "Sold as Vacant"
select distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2




-- The actual changing of the data
Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End



--------------------------------------------------------------------------------------------------

-- Remove Duplicates (Note: Was done for learning purposes)

With RowNumCTE AS(
select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
ORder by PropertyAddress





--------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Note: Was done for learning purposes)



Alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop column SaleDate

select *
from NashvilleHousing