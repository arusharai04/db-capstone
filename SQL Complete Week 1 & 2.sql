USE littlelemondb;
SHOW DATABASES;
SHOW TABLES;
SELECT
    c.CustomerID AS CustomerID,
    c.CustomerName AS FullName,
    o.OrderID AS OrderID,
    o.TotalCost AS Cost,
    m.MenuName AS MenuName,
    mi.Course AS CourseName,
    mi.Starters AS StarterName
FROM customers c
JOIN orders o
	USING (CustomerID)
JOIN menus m
	USING (MenuID)
JOIN menucontents mc
	USING (MenuID)
JOIN menuitems mi
	USING (MenuItemsID)
WHERE o.TotalCost > 150
ORDER BY o.TotalCost ASC;

SELECT MenuName FROM menus WHERE MenuID = ANY (SELECT MenuID FROM orders WHERE OrderQuantity > 2);

DROP PROCEDURE IF EXISTS GetMaxQuantity;
CREATE PROCEDURE GetMaxQuantity() SELECT MAX(OrderQuantity) AS 'Max Quantity in Order' FROM orders;
CALL GetMaxQuantity();

DROP PROCEDURE IF EXISTS GetOrderDetails;
CREATE PROCEDURE GetOrderDetails(IN CustomerID INT) SELECT OrderID, OrderQuantity, TotalCost FROM orders WHERE CustomerID = CustomerID;
SET @id = 1;
CALL GetOrderDetails(@id);

prepare GetOrderDetails FROM 'Select OrderID, OrderQuantity, TotalCost FROM Orders WHERE CustomerID = ?';
SET @id = 1;
EXECUTE GetOrderDetails USING @id;

DROP PROCEDURE IF EXISTS CancelOrder;
DELIMITER $$
CREATE PROCEDURE CancelOrder(IN OrderID INT)
	BEGIN
		DELETE FROM orders
        WHERE OrderID = OrderID;
        SELECT CONCAT("Order ", OrderID, " is cancelled") AS Confirmation;
    END$$
DELIMITER ;
CALL CancelOrder(5);

SELECT * FROM bookings;
INSERT INTO bookings (BookingDate, TableNumber, CustomerID)
VALUES 	("2022-10-10", 5, 1),
		("2022-11-12", 3, 3),
		("2022-10-11", 2, 2),
		("2022-10-13", 2, 1);
SELECT * FROM bookings;

DROP PROCEDURE IF EXISTS CheckBooking;
CREATE PROCEDURE CheckBooking(IN BookingDate DATE, IN TableNumber INT)
	SELECT CASE
				WHEN BookingDate = BookingDate AND TableNumber = TableNumber
					THEN CONCAT("Table ", TableNumber, " is already booked")
                    ELSE CONCAT("Table ", TableNumber, " is free")
			END AS BookingStatus
    FROM bookings
    WHERE BookingDate = BookingDate OR TableNumber = TableNumber
    LIMIT 1;
CALL CheckBooking("2022-11-12", 3);

DROP PROCEDURE IF EXISTS AddValidBooking;
DELIMITER $$
CREATE PROCEDURE AddValidBooking(IN BookingDate DATE, IN TableNumber INT, IN CustomerID INT)
BEGIN
	DECLARE FoundBooking INT DEFAULT 0;
     START TRANSACTION;
        SELECT COUNT(*) INTO FoundBooking
        FROM bookings
        WHERE BookingDate = BookingDate AND TableNumber = TableNumber;
       INSERT INTO bookings (BookingDate, TableNumber, CustomerID)
	VALUES (BookingDate, TableNumber, CustomerID);
	IF FoundBooking <> 0 THEN
		SELECT CONCAT("Table ", TableNumber, " is already booked - booking cancelled") AS "Booking status";
		ROLLBACK;
	ELSE
		COMMIT;
	END IF;
END$$
CALL AddValidBooking("2022-12-11", 6, 5);

DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER $$
CREATE PROCEDURE AddBooking(IN BookingID INT, IN CustomerID INT, IN TableNumber INT, IN BookingDate DATE)
	BEGIN
		INSERT INTO bookings (BookingID, CustomerID, TableNumber, BookingDate)
		VALUES (BookingID, CustomerID, TableNumber, BookingDate);
		SELECT "New booking added" AS "Confirmation";
    END$$
DELIMITER ;
CALL AddBooking(9, 3, 4, "2022-12-30");

DROP PROCEDURE IF EXISTS CheckBooking;
CREATE PROCEDURE CheckBooking(IN BookingDate DATE, IN TableNumber INT)
	SELECT CASE
				WHEN BookingDate = BookingDate AND TableNumber = TableNumber
					THEN CONCAT("Table ", TableNumber, " is already booked")
                    ELSE CONCAT("Table ", TableNumber, " is free")
			END AS BookingStatus
    FROM bookings
    WHERE BookingDate = BookingDate OR TableNumber = TableNumber
    LIMIT 1;
    CALL CheckBooking("2022-11-12", 3);
    
    DROP PROCEDURE IF EXISTS UpdateBooking;
    DELIMITER $$
CREATE PROCEDURE UpdateBooking(IN BookingID INT, IN BookingDate DATE)
	BEGIN
		UPDATE bookings
		SET BookingDate = BookingDate
        WHERE BookingID = BookingID;
		SELECT CONCAT("Booking ", BookingID, " updated") AS "Confirmation";
    END$$
DELIMITER ;
CALL UpdateBooking(9, "2022-12-17");

DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER $$
CREATE PROCEDURE CancelBooking(IN BookingID INT)
	BEGIN
		DELETE FROM bookings
        WHERE BookingID = BookingID;
		SELECT CONCAT("Booking ID : ", BookingID, "has been cancelled");
    END$$
DELIMITER ;
CALL CancelBooking(9);


    












  


