SELECT *
FROM PortfolioProject..NashvilleHousing


-- STANDARIZE DATE FORMAT

SELECT SaleDateNew
FROM PortfolioProject..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateNew DATE;

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(DATE, SaleDate)



-- POPULATE PROPERTY DATA 

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT na.ParcelID, na.PropertyAddress, nb.ParcelID, nb.PropertyAddress, ISNULL(na.PropertyAddress, nb.PropertyAddress) as NewAddress
FROM PortfolioProject..NashvilleHousing na
JOIN PortfolioProject..NashvilleHousing nb
ON na.ParcelID = nb.ParcelID
AND na.[UniqueID ] <> nb.[UniqueID ]
WHERE na.PropertyAddress is null

UPDATE na
SET PropertyAddress = ISNULL (na.PropertyAddress, nb.PropertyAddress)
FROM PortfolioProject..NashvilleHousing na
JOIN PortfolioProject..NashvilleHousing nb
ON na.ParcelID = nb.ParcelID
AND na.[UniqueID ] <> nb.[UniqueID ]
WHERE na.PropertyAddress is null


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address

FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))  as Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit Nvarchar(200);

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity Nvarchar(200);

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing


-- Another Way

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit nvarchar(200);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(200);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(200);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1

SELECT *
FROM PortfolioProject..NashvilleHousing




-- CHANGING YES AND NO TO Y AND N IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
     WHEN SoldAsVacant = 'No' THEN 'N'
	 ELSE SoldAsVacant
	 END 
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Yes' THEN 'Y'
     WHEN SoldAsVacant = 'No' THEN 'N'
	 ELSE SoldAsVacant
	 END 



-- REMOVING DUPLICATION

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



-- DELETING UNUSED COLUMNS

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate







