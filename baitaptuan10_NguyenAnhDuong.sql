--bài tập tuần 10
--1) View
use Northwind
--1. Tạo view vw_Products_Info hiển thị danh sách các sản phẩm từ bảng Products và bảng Categories.
--Thông tin bao gồm CategoryName, Description, ProductName, QuantityPerUnit, UnitPrice, UnitsInStock.
CREATE VIEW vw_Products_Info AS
SELECT C.CategoryName, C.Description,P.ProductName,P.QuantityPerUnit,P.UnitPrice, P.UnitsInStock
FROM Products P
JOIN  Categories C ON P.CategoryID = C.CategoryID;
-- Truy vấn dữ liệu từ View
SELECT * FROM vw_Products_Info;
--2. Tạo view List_Product_view chứa danh sách các sản phẩm dạng hộp (box) có đơn giá > 16, thông tin gồm ProductID, 
--ProductName, UnitPrice, QuantityPerUnit, COUNT of OrderID
CREATE VIEW List_Product_view AS 
SELECT p.ProductID, p.ProductName, p.UnitPrice, p.QuantityPerUnit, COUNT(od.OrderID) AS OrderCount 
FROM Products p 
LEFT JOIN [dbo].[Order Details] od ON p.ProductID = od.ProductID 
WHERE p.UnitPrice > 16 AND p.QuantityPerUnit LIKE '%box%' 
GROUP BY p.ProductID, p.ProductName, p.UnitPrice, p.QuantityPerUnit;
-- Truy vấn dữ liệu từ View
SELECT * FROM List_Product_view;
--3. Tạo view vw_CustomerTotals hiển thị tổng tiền bán được từ mỗi khách hàng theo tháng và theo năm.
--Thông tin gồm CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(UnitPrice*Quantity). Xem lại cú pháp lệnh tạo view này.
CREATE VIEW vw_CustomerTotals AS
SELECT CustomerID,YEAR(OrderDate) AS Year,MONTH(OrderDate) AS Month,SUM(UnitPrice * Quantity) AS Total
FROM [Order Details] OD
JOIN Orders O ON OD.OrderID = O.OrderID
GROUP BY CustomerID, YEAR(OrderDate), MONTH(OrderDate);

-- Truy vấn dữ liệu từ View
SELECT * FROM vw_CustomerTotals;

--4. Tạo view trả về tổng số lượng sản phẩm bán được của mỗi nhân viên (Employee) theo từng năm. 
--Thông tin gồm EmployeeID, OrderYear, sumOfOrderQuantity. Yêu cầu sau khi tạo view, người dùng không xem được cú pháp lệnh đã tạo view này.
CREATE VIEW vw_EmployeeSales WITH ENCRYPTION AS
SELECT  O.EmployeeID,YEAR(O.OrderDate) AS OrderYear,SUM(OD.Quantity) AS SumOfQuantity
FROM [Order Details] OD
JOIN Orders O ON OD.OrderID = O.OrderID
GROUP BY O.EmployeeID, YEAR(O.OrderDate);

-- Truy vấn dữ liệu từ View
SELECT * FROM vw_EmployeeSales;
--5. Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 5 hóa đơn đặt hàng từ năm 1997 đến 1998,
--thông tin gồm mã khách (CustomerID) , họ tên (CompanyName), Số hóa đơn (CountOfOrders).
CREATE VIEW ListCustomer_view AS
SELECT C.CustomerID,C.CompanyName,COUNT(O.OrderID) AS CountOfOrders
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE YEAR(O.OrderDate) BETWEEN 1997 AND 1998
GROUP BY C.CustomerID, C.CompanyName
HAVING COUNT(O.OrderID) > 5;

-- Truy vấn dữ liệu từ View
SELECT * FROM ListCustomer_view;
--6. Tạo view ListProduct_view chứa danh sách những sản phẩm nhóm Beverages và Seafood có tổng số lượng bán trong mỗi năm trên 30 sản phẩm, 
--thông tin gồm CategoryName, ProductName, Year, SumOfOrderQuantity.
CREATE VIEW ListProduct_view AS
SELECT C.CategoryName,P.ProductName,YEAR(O.OrderDate) AS Year,SUM(OD.Quantity) AS SumOfQuantity
FROM [Order Details] OD
JOIN Products P ON OD.ProductID = P.ProductID
JOIN Categories C ON P.CategoryID = C.CategoryID
JOIN Orders O ON OD.OrderID = O.OrderID
WHERE C.CategoryName IN ('Beverages', 'Seafood')
GROUP BY C.CategoryName, P.ProductName, YEAR(O.OrderDate)
HAVING SUM(OD.Quantity) > 30;

-- Truy vấn dữ liệu từ View
SELECT * FROM ListProduct_view;
--7. Tạo view vw_OrderSummary với từ khóa WITH ENCRYPTION gồm OrderYear (năm của ngày lập hóa đơn), OrderMonth (tháng của ngày lập hóa đơn), 
--OrderTotal (tổng tiền, =UnitPrice*Quantity). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
CREATE VIEW vw_OrderSummary WITH ENCRYPTION AS
SELECT YEAR(O.OrderDate) AS OrderYear,MONTH(O.OrderDate) AS OrderMonth,SUM(OD.UnitPrice * OD.Quantity) AS OrderTotal
FROM [Order Details] OD
JOIN Orders O ON OD.OrderID = O.OrderID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate);

-- Truy vấn dữ liệu từ View
SELECT * FROM vw_OrderSummary;
--8. Tạo view vwProducts với từ khóa WITH SCHEMABINDING gồm ProductID, ProductName, Discount. 
--Xem thông tin của View. Xóa cột Discount. Có xóa được không? Vì sao?
CREATE VIEW vwProducts WITH SCHEMABINDING AS
SELECT P.ProductID,P.ProductName,P.Discount
FROM dbo.Products P;

-- Truy vấn dữ liệu từ View
SELECT * FROM vwProducts;
-- Thử xóa cột Discount trong bảng Products
-- ALTER TABLE Products DROP COLUMN Discount; -- Sẽ không thực hiện được vì view có từ khóa SCHEMABINDING

--9. Tạo view vw_Customer với với từ khóa WITH CHECK OPTION chỉ chứa các khách hàng ở thành phố London và Madrid, 
--thông tin gồm: CustomerID, CompanyName, City.
CREATE VIEW vw_Customer WITH CHECK OPTION AS
SELECT CustomerID,CompanyName,City
FROM Customers
WHERE City IN ('London', 'Madrid');
--a. Chèn thêm một khách hàng mới không ở thành phố London và Madrid thông qua view vừa tạo. Có chèn được không? Giải thích.
-- INSERT INTO vw_Customer (CustomerID, CompanyName, City) VALUES ('NEWCUST', 'New Customer', 'Paris'); -- Sẽ không thực hiện được vì CHECK OPTION
--b. Chèn thêm một khách hàng mới ở thành phố London và một khách hàng mới ở thành phố Madrid. Dùng câu lệnh select trên bảng Customers để xem kết quả .
INSERT INTO vw_Customer (CustomerID, CompanyName, City) VALUES ('LONCUST', 'London Customer', 'London');
INSERT INTO vw_Customer (CustomerID, CompanyName, City) VALUES ('MADRIDCUST', 'Madrid Customer', 'Madrid');
-- Dùng câu lệnh select trên bảng Customers để xem kết quả
SELECT * FROM Customers WHERE City IN ('London', 'Madrid');

--10. Tạo 3 bảng lần lượt có tên là KhangHang_Bac, KhachHang_Trung, KhachHang_Nam, dùng để lưu danh sách các khách hàng ở ba miền, 
--có cấu trúc như sau: MaKh, TenKH, DiaChi, KhuVuc. Trong đó,
--KhachHang_Bac có một Check Constraint là Khuvuc là ‘Bac Bo’
--KhachHang_Nam có một Check Constraint là Khuvuc là ‘Nam Bo’
--KhachHang_Trung có một Check Constraint là Khuvuc là ‘Trung Bo’
--Khoá chính là MaKH và KhuVuc .
--Tạo một partition view từ ba bảng trên, sau đó chèn mẫu tin tuỳ ý thông qua view.
--Kiểm tra xem mẫu tin được lưu vào bảng nào khi thêm/sửa/xóa dữ liệu vào view?
-- Tạo các bảng với Check Constraint
CREATE TABLE KhachHang_Bac (
    MaKH INT PRIMARY KEY,
    TenKH NVARCHAR(50),
    DiaChi NVARCHAR(100),
    KhuVuc NVARCHAR(50) CHECK (KhuVuc = 'Bac Bo')
);

CREATE TABLE KhachHang_Trung (
    MaKH INT PRIMARY KEY,
    TenKH NVARCHAR(50),
    DiaChi NVARCHAR(100),
    KhuVuc NVARCHAR(50) CHECK (KhuVuc = 'Trung Bo')
);

CREATE TABLE KhachHang_Nam (
    MaKH INT PRIMARY KEY,
    TenKH NVARCHAR(50),
    DiaChi NVARCHAR(100),
    KhuVuc NVARCHAR(50) CHECK (KhuVuc = 'Nam Bo')
);

-- Tạo partition view
CREATE VIEW KhachHang_View AS
SELECT MaKH, TenKH, DiaChi, KhuVuc FROM KhachHang_Bac
UNION ALL
SELECT MaKH, TenKH, DiaChi, KhuVuc FROM KhachHang_Trung
UNION ALL
SELECT MaKH, TenKH, DiaChi, KhuVuc FROM KhachHang_Nam;

-- Chèn mẫu tin tuỳ ý thông qua view
INSERT INTO KhachHang_View (MaKH, TenKH, DiaChi, KhuVuc) VALUES (1, 'Khach Hang Bac', 'Dia Chi Bac', 'Bac Bo');
INSERT INTO KhachHang_View (MaKH, TenKH, DiaChi, KhuVuc) VALUES (2, 'Khach Hang Trung', 'Dia Chi Trung', 'Trung Bo');
INSERT INTO KhachHang_View (MaKH, TenKH, DiaChi, KhuVuc) VALUES (3, 'Khach Hang Nam', 'Dia Chi Nam', 'Nam Bo');

-- Kiểm tra xem mẫu tin được lưu vào bảng nào
SELECT * FROM KhachHang_Bac;
SELECT * FROM KhachHang_Trung;
SELECT * FROM KhachHang_Nam;

--11. Lần lược tạo các view sau, đặt tên tùy ý, sau khi tạo kiểm tra sự tồn tại và kết quả truy vấn từ view.
--▪ Danh sách các sản phẩm có chữ ‘Boxes’ trong DonViTinh.
CREATE VIEW vw_Products_Boxes AS
SELECT ProductID, ProductName, QuantityPerUnit
FROM Products
WHERE QuantityPerUnit LIKE '%Boxes%';

-- Truy vấn dữ liệu từ View
SELECT * FROM vw_Products_Boxes;

--▪ Danh sách các sản phẩm có đơn giá <10.
CREATE VIEW vw_Products_Under10 AS
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice < 10;
-- Truy vấn dữ liệu từ View
SELECT * FROM vw_Products_Under10;
--▪ Các sản phẩm có đơn giá gốc lớn hơn hay bằng đơn giá gốc trung bình.
CREATE VIEW vw_Products_AboveAvgPrice AS
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice >= (SELECT AVG(UnitPrice) FROM Products);
-- Truy vấn dữ liệu từ View
SELECT * FROM vw_Products_AboveAvgPrice;
--▪ Danh sách các khách hàng ứng với các hóa đơn được lập. Thông tin gồm MaKH, TenKH, và tất cả các cột trong bảng HoaDon và CT_HoaDon.
CREATE VIEW vw_Customers_Orders AS
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID;
-- Truy vấn dữ liệu từ View
SELECT * FROM vw_Customers_Orders;
--Trong các view ở câu trên view nào có thể INSERT, UPDATE, DELETE dữ liệu thông qua view được? Hãy Insert/Update/Delete thử dữ liệu tùy ý.
--2) Index
--1. Tạo chỉ mục dạng CLUSTERED cho bảng Orders với cột làm chỉ mục là Customerid.
CREATE CLUSTERED INDEX IX_Orders_CustomerID ON Orders (CustomerID);
--Xem trợ giúp về chỉ mục vừa tạo. 
EXEC sp_helpindex 'Orders';
--Dùng lệnh select xem thông tin bảng orders.
SELECT * FROM Orders;
----2. Tạo chỉ mục dạng NONCLUSTERED cho bảng Orders với cột làm chỉ mục là Employeeid. 
CREATE NONCLUSTERED INDEX IX_Orders_EmployeeID ON Orders (EmployeeID);
-- Xem trợ giúp về chỉ mục vừa tạo.
EXEC sp_helpindex 'Orders';
--Dùng lệnh select xem thông tin bảng orders.
SELECT * FROM Orders;
--Nhận xét sự khác nhau giữa hai loại chỉ mục vừa tạo.
--3. Thêm vào bảng Orders cột DiemTL. 
ALTER TABLE Orders ADD DiemTL INT;
--Tạo chỉ mục dạng unique cho cột DiemTL. 
CREATE UNIQUE INDEX IX_Orders_DiemTL ON Orders (DiemTL);

--Sau khi tạo chỉ mục này, nếu nhập dữ liệu cho 2 hóa đơn có cùng điểm tích lũy có được không? Giải thích
--khi tạo chỉ mục UNIQUE cho cột DiemTL, không thể nhập dữ liệu cho hai hóa đơn có cùng điểm tích lũy
--4. Giả sử bạn có nhu cầu truy vấn thường xuyên câu lệnh sau:
--SELECT *
--FROM Orders
--WHERE orderdate= getdate();
--Bạn hãy thực hiện việc tạo chỉ mục thích hợp để việc truy vấn câu trên thực hiện nhanh hơn?
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON Orders (OrderDate);

--5. Giả sử có nhu cầu truy vấn thường xuyên câu sau:
--SELECT *
--FROM Products
--WHERE ProductID = 57
--Bạn hãy thực hiện việc tạo chỉ mục thích hợp để việc truy vấn câu trên thực hiện nhanh hơn?

CREATE NONCLUSTERED INDEX IX_Products_ProductID ON Products (ProductID);
