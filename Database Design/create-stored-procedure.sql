CREATE PROCEDURE GetMonthlyInventory (@startDate DATE, @endDate DATE)
AS
BEGIN
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
    WHERE OrderDate BETWEEN @startDate AND @endDate
    GROUP BY 
        CTE.IngredientID
        , CTE.IngredientName
        , INV.StockQuantity
        , ING.IngredientWeight
    ORDER BY IngredientID
END
;


CREATE PROCEDURE GetIngredientNeedReordering (@startDate DATE, @endDate DATE)
AS
BEGIN
    SELECT 
        CTE.IngredientID
        , CTE.IngredientName
        , INV.StockQuantity
        , SUM(OrderItemWeight) / ING.IngredientWeight AS UnitIngredientUsed
        , INV.StockQuantity - SUM(OrderItemWeight) / ING.IngredientWeight AS RemainingStock
        , INV.ReorderPoint
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
    WHERE OrderDate BETWEEN @startDate AND @endDate
    GROUP BY 
        CTE.IngredientID
        , CTE.IngredientName
        , INV.StockQuantity
        , ING.IngredientWeight
        , INV.ReorderPoint
    HAVING INV.StockQuantity - SUM(OrderItemWeight) / ING.IngredientWeight <= ReorderPoint
    ORDER BY IngredientID
END
;
