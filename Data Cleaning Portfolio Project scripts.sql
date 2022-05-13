-- Data Cleaning project

select *
From PortfolioProject..NashvilleHousing

-- Standardize SaleDate
select SaleDateShort, CAST(SaleDate as date)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CAST(SaleDate as date)

Alter Table NashvilleHousing
Add SaleDateShort Date;

Update NashvilleHousing
Set SaleDateShort = CAST(SaleDate as Date)

-- Populate Property Address with the same ParcelID data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
Join PortfolioProject..NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Break up Address into individual columns by Address and City
select PropertyAddress
From PortfolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertysplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertysplitAddress = SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertysplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertysplitCity = SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))


-- Break up Address into individual columns by Address, City and State
select PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnersplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnersplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnersplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnersplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnersplitState Nvarchar(255);

Update NashvilleHousing
Set OwnersplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
From PortfolioProject..NashvilleHousing

-- Change Y & N to Yes and No in 'SoldAsVacant' column
select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

-- Remove duplicates

With RowNumCTE as(
select *,
ROW_NUMBER() Over (Partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference Order by UniqueID) as row_num
From PortfolioProject..NashvilleHousing
)
select *
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

-- Delete unused columns
select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate