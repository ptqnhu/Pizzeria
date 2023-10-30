DROP DATABASE IF EXISTS Pizzeria;
CREATE DATABASE Pizzeria;
USE Pizzeria;


CREATE TABLE MenuItem (
    MenuItemID  VARCHAR(5)  NOT NULL
    , MenuItemName  VARCHAR(50)  NOT NULL
    , MenuItemCategory  VARCHAR(10)  NOT NULL CHECK (MenuItemCategory IN ('Pizza', 'Side', 'Beverage'))
    , MenuItemSize  VARCHAR(10)  NOT NULL
    , MenuItemPrice  DECIMAL(5,2)  NOT NULL
    , CONSTRAINT PK_MenuItem_MenuItemID PRIMARY KEY CLUSTERED (MenuItemID)
    , CONSTRAINT AK_MenuItem_MenuItemName UNIQUE (MenuItemName)
)
;


CREATE TABLE Ingredient (
    IngredientID  VARCHAR(5)  NOT NULL
    , IngredientName  VARCHAR(50)  NOT NULL
    , IngredientWeight  INT  NOT NULL
    , PurchasedPrice  DECIMAL(5,2)  NOT NULL
    , CONSTRAINT PK_Ingredient_IngredientID PRIMARY KEY CLUSTERED (IngredientID)
    , CONSTRAINT AK_Ingredient_IngredientName UNIQUE (IngredientName)
)
;


CREATE TABLE Recipe (
    MenuItemID VARCHAR(5) NOT NULL
    , IngredientID  VARCHAR(5)  NOT NULL
    , RecipeQuantity  INT  NOT NULL
    , CONSTRAINT PK_Recipe_MenuItemID_IngredientID PRIMARY KEY (MenuItemID, IngredientID)
    , CONSTRAINT FK_Recipe_MenuItem_MenuItemID FOREIGN KEY (MenuItemID) REFERENCES MenuItem (MenuItemID)
    , CONSTRAINT FK_Recipe_Ingredient_Ingredient_ID FOREIGN KEY (IngredientID) REFERENCES Ingredient (IngredientID)
)
;


CREATE TABLE Inventory (
    IngredientID VARCHAR(5) NOT NULL
    , StockQuantity INT NOT NULL
    , ReorderPoint INT NOT NULL
    , SafetyStockLevel INT NOT NULL
    , CONSTRAINT PK_Inventory_IngredientID PRIMARY KEY (IngredientID)
    , CONSTRAINT FK_Inventory_Ingredient_IngredientID FOREIGN KEY (IngredientID) REFERENCES Ingredient (IngredientID)
)
;


CREATE TABLE Customer (
    CustomerID  INT  NOT NULL
    , CustomerFirstName  VARCHAR(50)  NOT NULL
    , CustomerLastName  VARCHAR(50)   NOT NULL
    , CustomerBirthDate  DATE  NOT NULL
    , CustomerGender  VARCHAR(1)  NOT NULL CHECK (CustomerGender IN ('M', 'F'))
    , CustomerPhoneNumber  VARCHAR(12)  NOT NULL
    , CONSTRAINT PK_Customer_CustomerID PRIMARY KEY NONCLUSTERED (CustomerID)
    , 
)
;


CREATE TABLE Address (
    ShippingAddressID  INT  NOT NULL
    , ShippingStreet  VARCHAR(255)  NOT NULL
    , ShippingCity  VARCHAR(50)  NOT NULL
    , ShippingZipCode  VARCHAR(5)  NOT NULL
    , CONSTRAINT PK_Address_ShippingAddressID PRIMARY KEY (ShippingAddressID)
)
;


CREATE TABLE OrderHeader (
    OrderID  VARCHAR(9)  NOT NULL
    , CustomerID  INT  NOT NULL
    , OrderDate  DATE  NOT NULL
    , OrderTime  TIME  NOT NULL
    , ShippingAddressID  INT  NOT NULL
    , OrderTotal  DECIMAL(5,2)  NOT NULL
    , OrderStatus   VARCHAR(20)  NOT NULL
    , CONSTRAINT PK_OrderHeader_OrderID PRIMARY KEY CLUSTERED (OrderID)
    , CONSTRAINT FK_OrderHeader_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    , CONSTRAINT FK_OrderHeader_Address_ShippingAddressID FOREIGN KEY (ShippingAddressID) REFERENCES Address (ShippingAddressID)
)
;


CREATE TABLE OrderDetail (
    OrderID  VARCHAR(9)  NOT NULL
    , MenuItemID  VARCHAR(5)  NOT NULL
    , QuantityOrdered  INT  NOT NULL
    , ItemTotal  DECIMAL(5,2)  NOT NULL
    , CONSTRAINT PK_OrderDetail_OrderID_MenuItemID PRIMARY KEY (OrderID, MenuItemID)
    , CONSTRAINT FK_OrderDetail_OrderHeader_OrderID FOREIGN KEY (OrderID) REFERENCES OrderHeader (OrderID)
    , CONSTRAINT FK_OrderDetail_MenuItem_MenuItemID FOREIGN KEY (MenuItemID) REFERENCES MenuItem (MenuItemID)
)
;


CREATE TABLE Employee (
    EmployeeID  VARCHAR(5)  NOT NULL
    , EmpFirstName  VARCHAR(50)  NOT NULL
    , EmpLastName  VARCHAR(50)  NOT NULL
    , EmpRole  VARCHAR(50)  NOT NULL CHECK (EmpRole IN ('Head Chef', 'Chef', 'Delivery rider'))
    , HireDate  DATE  NOT NULL
    , HourlyRate  DECIMAL(5,2)  NOT NULL CHECK (HourlyRate >= 10)
    , CONSTRAINT PK_Employee_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID)
)
;


CREATE TABLE Shift (
    ShiftID  VARCHAR(5)  NOT NULL
    , DateOfWeek  VARCHAR(20)  NOT NULL
    , StartTime  TIME  NOT NULL
    , EndTime  TIME  NOT NULL
    , CONSTRAINT PK_Shift_ShiftID PRIMARY KEY CLUSTERED (ShiftID)
)
;


CREATE TABLE Rotation (
    RotationID  INT  NOT NULL
    , Date  DATE  NOT NULL
    , ShiftID  VARCHAR(5)  NOT NULL
    , EmployeeID  VARCHAR(5)  NOT NULL
    , CONSTRAINT PK_Rotation_RotationID PRIMARY KEY (RotationID)
    , CONSTRAINT FK_Rotation_Shift_ShiftID FOREIGN KEY (ShiftID) REFERENCES Shift (ShiftID)
    , CONSTRAINT FK_Rotation_Employee_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
)
;
