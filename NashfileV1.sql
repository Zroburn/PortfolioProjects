/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--------------------------------------------------

--Populate Property Address Data

Select*
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b. ParcelID, b. PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID
--CHARINDEX is used to look for a character or charecter's that are in a data set. Must be in this Format. CHARINDEX('...',Column name)
	
Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
	

From PortfolioProject.dbo.NashvilleHousing

--This is also a postion index
Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
	CHARINDEX(',', PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing

--Eliminates comma at the end of the address
Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	
From PortfolioProject.dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))



Select*
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing



--Another way to split colomuns up.
Select 
Parsename(Replace(OwnerAddress,',','.'), 3)
, Parsename(Replace(OwnerAddress,',','.'), 2)
, Parsename(Replace(OwnerAddress,',','.'), 1)

From PortfolioProject.dbo.NashvilleHousing





Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'), 1)


Select*
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2



Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   end
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   end

------------------------------------------

---Remove Duplicates(This will delete data and should be used only when 100% sure there is nothing else to be done
----or the life cycle of the data is at an end)

With RowNumCTE as(
Select *,
	Row_Number() Over(
	Partition By ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					)Row_num


From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select*
From RowNumCTE
Where Row_num > 1
Order by PropertyAddress


Select*
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------



--Delete Unused Columns
---(Don't do this to the raw data



Select*
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate


