--checking out the sales date column
select SaleDate, cast(SaleDate as date)
from nashville_housing

--separating it from time included in the data
update nashville_housing
set SaleDateConverted = cast(SaleDate as date)

select SaleDateConverted
from nashville_housing

alter table national_housing
add SaleDateConverted Date

--Property address
select *
from nashville_housing
where propertyaddress is null

--Self joining to single out Parcel ID and Property address and populating the null address
select NHA.ParcelID, NHA.PropertyAddress, NHB.ParcelID, NHB.PropertyAddress, isnull(NHA.propertyaddress, NHB.PropertyAddress)
from nashville_housing NHA
join nashville_housing NHB
on NHA.ParcelID = NHB.ParcelID
AND NHA.[UniqueID ] <> NHB.[UniqueID ]
where NHA.PropertyAddress IS NULL

--updating and removing the null fields
update NHA
set propertyaddress = isnull(NHA.propertyaddress, NHB.PropertyAddress)
from nashville_housing NHA
join nashville_housing NHB
on NHA.ParcelID = NHB.ParcelID
AND NHA.[UniqueID ] <> NHB.[UniqueID ]
where NHA.PropertyAddress IS NULL

--Breaking out property address diffrently into (address,city and state)
select propertyaddress
from nashville_housing

select 
SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1) Address
,SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) Address
from nashville_housing

alter table national_housing
add property_Address varchar(255)

update nashville_housing
set property_Address = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1)


alter table national_housing
add Property_City varchar(255)

update nashville_housing
set Property_City = SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress))

--Breaking out owners address diffrently into (address,city and state)

select OwnerAddress
from nashville_housing

select
parsename(replace(OwnerAddress, ',', '.'),3)
,parsename(replace(OwnerAddress, ',', '.'),2)
,parsename(replace(OwnerAddress, ',', '.'),1)
from nashville_housing

alter table national_housing
add Owners_Address varchar(255)

update nashville_housing
set Owners_Address = parsename(replace(OwnerAddress, ',', '.'),3)

alter table national_housing
add Owners_city varchar(255)

update nashville_housing
set Owners_city = parsename(replace(OwnerAddress, ',', '.'),2)

alter table national_housing
add Owners_state varchar(255)

update nashville_housing
set Owners_state = parsename(replace(OwnerAddress, ',', '.'),1)


--checking out if we have rows that does not have yes or no
select Distinct SoldAsVacant, count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant


--replacing Y with Yes and N with No
select SoldAsVacant
,case when SoldAsVacant = 'N' THEN 'No'
	when SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
from nashville_housing

update nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'N' THEN 'No'
	when SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

	select*
	from nashville_housing

--removing duplicates
with Row_num_cte as(
select*,
row_number() over(
partition by ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference
order by uniqueid)
		row_num
from nashville_housing
)
select * 
FROM Row_num_cte



