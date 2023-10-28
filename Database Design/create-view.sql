CREATE VIEW vOrderActivity
AS
SELECT
    OH.OrderID
    , MI.MenuItemCategory
    , MI.MenuItemName
    , OD.QuantityOrdered
    , OD.ItemTotal
    , OH.OrderDate
    , OH.OrderTime
    , OH.OrderStatus
    , A.ShippingStreet
    , A.ShippingCity
    , A.ShippingZipCode
FROM OrderHeader OH 
    LEFT JOIN OrderDetail OD 
        ON OH.OrderID = OD.OrderID
    LEFT JOIN MenuItem MI
        ON OD.MenuItemID = MI.MenuItemID
    LEFT JOIN Address A 
        ON OH.ShippingAddressID = A.ShippingAddressID
;


CREATE VIEW vCostDetail
AS
SELECT
    MenuItemID
    , MenuItemName
    , IngredientID
    , IngredientName
    , IngredientWeight
    , PurchasedPrice
    , OrderTotalQuantity
    , RecipeQuantity
    , OrderTotalQuantity * RecipeQuantity AS OrderWeight
    , PurchasedPrice / IngredientWeight AS UnitCost
    , OrderTotalQuantity * RecipeQuantity * PurchasedPrice / IngredientWeight AS IngredientCost
FROM (
    SELECT
        MI.MenuItemID
        , MI.MenuItemName
        , ING.IngredientID
        , ING.IngredientName
        , SUM(OD.QuantityOrdered) AS OrderTotalQuantity
        , R.RecipeQuantity
        , ING.IngredientWeight
        , ING.PurchasedPrice
    FROM OrderHeader OH 
        LEFT JOIN OrderDetail OD
            ON OH.OrderID = OD.OrderID
        LEFT JOIN MenuItem MI 
            ON OD.MenuItemID = MI.MenuItemID
        LEFT JOIN Recipe R 
            ON MI.MenuItemID = R.MenuItemID
        LEFT JOIN Ingredient ING
            ON R.IngredientID = ING.IngredientID
    GROUP BY
        MI.MenuItemID
        , MI.MenuItemName
        , ING.IngredientID
        , ING.IngredientName
        , R.RecipeQuantity
        , ING.IngredientWeight
        , ING.PurchasedPrice
) CTE
;


CREATE VIEW vInventoryDetail
AS
SELECT 
    CTE.IngredientID
    , CTE.IngredientName
    , INV.StockQuantity
    , SUM(OrderItemWeight) / ING.IngredientWeight AS UnitIngredientUsed
    , INV.StockQuantity - SUM(OrderItemWeight) / ING.IngredientWeight AS RemainingStock
FROM (
    SELECT
        OH.OrderDate
        , OH.OrderID
        , OD.MenuItemID
        , MI.MenuItemName
        , OD.QuantityOrdered
        , ING.IngredientID
        , ING.IngredientName
        , R.RecipeQuantity
        , OD.QuantityOrdered * RecipeQuantity AS OrderItemWeight
    FROM OrderHeader OH 
        LEFT JOIN OrderDetail OD
            ON OH.OrderID = OD.OrderID
        LEFT JOIN MenuItem MI 
            ON OD.MenuItemID = MI.MenuItemID
        LEFT JOIN Recipe R 
            ON MI.MenuItemID = R.MenuItemID
        LEFT JOIN Ingredient ING
            ON R.IngredientID = ING.IngredientID
) CTE
    LEFT JOIN Ingredient ING 
        ON ING.IngredientID = CTE.IngredientID
    LEFT JOIN Inventory INV
        ON INV.IngredientID = CTE.IngredientID
GROUP BY 
    CTE.IngredientID
    , CTE.IngredientName
    , INV.StockQuantity
    , ING.IngredientWeight
;


CREATE VIEW vStaffWage
AS
WITH ShiftStaffDetail AS (
    SELECT
        R.Date
        , E.EmployeeID
        , E.EmpFirstName
        , E.EmpLastName
        , E.HourlyRate
        , S.StartTime
        , S.EndTime
        , DATEDIFF(HOUR, StartTime, S.EndTime) AS HourInShift
        , DATEDIFF(HOUR, StartTime, S.EndTime) * HourlyRate AS StaffCost
    FROM Rotation R  
        LEFT JOIN Employee E
            ON R.EmployeeID = E.EmployeeID
        LEFT JOIN Shift S 
            ON R.ShiftID = S.ShiftID
)
SELECT 
    EmployeeID
    , EmpFirstName
    , EmpLastName
    , HourlyRate
    , COUNT(HourInShift) AS ShiftCount
    , SUM(HourInShift) AS TotalWorkHour
    , SUM(StaffCost) AS TotalWage
FROM ShiftStaffDetail
GROUP BY 
    EmployeeID
    , EmpFirstName
    , EmpLastName
    , HourlyRate
;
