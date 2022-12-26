

-- Cleaning Data in SQL Queries

select * from PortfolioProject.dbo.NashVilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize sales date format

select SaleDateConverted, CONVERT(date, SaleDate) 
from PortfolioProject.dbo.NashVilleHousing

update NashVilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashVilleHousing
add SaleDateConverted date;

update NashVilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------

-- populate property address data

select * 
from PortfolioProject.dbo.NashVilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing  a
join PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- use alias when doing join in update statement
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing  a
join PortfolioProject.dbo.NashVilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------------------------

-- breaking out address into columns (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashVilleHousing
order by ParcelID

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashVilleHousing

alter table NashVilleHousing
add propertySplitAddress nvarchar(255);

update NashVilleHousing
set propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashVilleHousing
add propertySplitCity nvarchar(255);

update NashVilleHousing
set propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashVilleHousing

-- parcename take fullstop instead of comma as seperator and it runs backward (owner address)

select parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashVilleHousing

alter table NashVilleHousing
add OwnerSplitAddress nvarchar(255);

update NashVilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashVilleHousing
add OwnerSplitCity nvarchar(255);

update NashVilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashVilleHousing
add OwnerSplitState nvarchar(255);

update NashVilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashVilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------

-- change Y and N to yes and no in "Sold at vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashVilleHousing
group by SoldAsVacant
order by 1

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashVilleHousing

update NashVilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates by using window function row_number (use DELETE to delete duplicate in select from RowNumCTE where row_num > 1)

with RowNumCTE as(
select *, ROW_NUMBER() over (partition by ParcelId,
                                          PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference order by UniqueId) as row_num
from PortfolioProject.dbo.NashVilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------- 

-- Delete unused columns (consult with superior before using as this will delete data from database)

select *
from PortfolioProject.dbo.NashVilleHousing

alter table PortfolioProject.dbo.NashVilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

--alter table PortfolioProject.dbo.NashVilleHousing drop column SaleDate









