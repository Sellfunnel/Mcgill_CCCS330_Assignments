-- 1. How many loans did the library make last year? (Stored Procedure) 
CREATE PROCEDURE TotalLoansLastYear() 
BEGIN 
    SELECT COUNT(*) AS TotalLoans 
    FROM Loan 
    WHERE YEAR(checkedOutDate) = YEAR(CURDATE()) - 1; 
END; 

  

-- 2. What percentage of the membership borrowed at least one book? (View) 
CREATE VIEW PercentageMembersBorrowedView AS 
SELECT CONCAT(ROUND((COUNT(DISTINCT memberID) / (SELECT COUNT(*) FROM Member) * 100), 2), '%') AS PercentageBorrowed 
FROM Loan; 

  

-- 3. What was the greatest number of books borrowed by any one individual? (Function) 
CREATE FUNCTION MaxBooksBorrowedByIndividual() 
RETURNS INT 
BEGIN 
    DECLARE maxBooks INT; 
    SELECT MAX(bookCount) INTO maxBooks 
    FROM (SELECT memberID, COUNT(*) AS bookCount FROM Loan GROUP BY memberID) AS BookCounts; 
    RETURN maxBooks; 
END; 

  

-- 4. What percentage of the books was loaned out at least once last year? (Stored Procedure) 
CREATE PROCEDURE PercentageBooksLoanedOut() 
BEGIN 
    SELECT CONCAT(ROUND((COUNT(DISTINCT bc.isbn) / (SELECT COUNT(*) FROM Book) * 100), 2), '%') AS PercentageLoanedOut 
    FROM BookCopy bc 
    JOIN Loan l ON bc.copyID = l.copyID 
    WHERE YEAR(l.checkedOutDate) = YEAR(CURDATE()) - 1; 
END; 

  

-- 5.  What percentage of all loans eventually become overdue? (Function) 
CREATE FUNCTION PercentageLoansOverdue() 
RETURNS VARCHAR(10) 
BEGIN 
    DECLARE overdueRate VARCHAR(10); 
    SELECT CONCAT(ROUND((SUM(CASE WHEN l.dueDate < br.returnDate THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2), '%') INTO overdueRate 
    FROM Loan l 
    LEFT JOIN BookReturn br ON l.loanID = br.loanID; 
    RETURN overdueRate; 
END; 

  

-- 6. What is the average length of a loan? (View) 
CREATE VIEW AverageLoanLengthView AS 
SELECT AVG(DATEDIFF(br.returnDate, l.checkedOutDate)) AS AvgLoanDays 
FROM Loan l 
JOIN BookReturn br ON l.loanID = br.loanID; 

  

-- 7. What are the library's peak hours for loans? (Trigger) 
CREATE TRIGGER UpdatePeakHours 
AFTER INSERT ON Loan 
FOR EACH ROW 
BEGIN 
    INSERT INTO PeakHours (Hour, Count) 
    VALUES (HOUR(NEW.checkedOutDate), 1) 
    ON DUPLICATE KEY UPDATE Count = Count + 1; 
END;

-- Additional triggers and views based on the PDF document

-- Trigger to enforce the maximum number of reservations per member
DELIMITER //
CREATE TRIGGER max_reservations_trigger
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    DECLARE reservation_count INT;
    SELECT COUNT(*) INTO reservation_count FROM Reservation WHERE memberID = NEW.memberID;
    IF reservation_count >= 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A member can have a maximum of 4 books on reserve at one time.';
    END IF;
END;
//
DELIMITER ;


-- Trigger to enforce the maximum number of books checked out per member
DELIMITER //
CREATE PROCEDURE CheckoutBook(IN memberID INT, IN copyID INT)
BEGIN
    DECLARE dueDate DATETIME;
    DECLARE book_count INT;

    -- Exit handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the checkout process.';
    END;

    -- Calculate due date
    SET dueDate = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 14 DAY);

    -- Start transaction
    START TRANSACTION;

    -- Check if the member has less than 4 books checked out
    SELECT COUNT(*) INTO book_count FROM Loan WHERE memberID = memberID AND returnDate IS NULL;
    IF book_count >= 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A member can have a maximum of 4 books checked out at one time.';
    END IF;

    -- Insert into Loan table
    INSERT INTO Loan (memberID, copyID, dueDate) VALUES (memberID, copyID, dueDate);

    -- Update BookCopy status
    UPDATE BookCopy SET onLoan = 'YES' WHERE copyID = copyID;

    -- Commit transaction
    COMMIT;
END;
//
DELIMITER ;

-- Trigger to check if a book is loanable

DELIMITER //
CREATE PROCEDURE CheckoutBook(IN memberID INT, IN copyID INT)
BEGIN
    DECLARE dueDate DATETIME;
    DECLARE loanable_status ENUM('YES', 'NO');
    DECLARE book_count INT;

    -- Exit handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the checkout process.';
    END;

    -- Calculate due date
    SET dueDate = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 14 DAY);

    -- Start transaction
    START TRANSACTION;

    -- Check if the book is loanable
    SELECT loanable INTO loanable_status FROM BookCopy WHERE copyID = copyID;
    IF loanable_status = 'NO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This book is not loanable.';
    END IF;

    -- Check if the member has less than 4 books checked out
    SELECT COUNT(*) INTO book_count FROM Loan WHERE memberID = memberID AND returnDate IS NULL;
    IF book_count >= 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A member can have a maximum of 4 books checked out at one time.';
    END IF;

    -- Insert into Loan table
    INSERT INTO Loan (memberID, copyID, dueDate) VALUES (memberID, copyID, dueDate);

    -- Update BookCopy status
    UPDATE BookCopy SET onLoan = 'YES' WHERE copyID = copyID;

    -- Commit transaction
    COMMIT;
END;
//
DELIMITER ;

-- Start the transaction
START TRANSACTION;

-- Trigger for updating Juvenile to Adult based on age
CREATE TRIGGER UpdateToAdult
AFTER UPDATE ON Juvenile
FOR EACH ROW
BEGIN
  IF NEW.dateOfBirth <= CURDATE() - INTERVAL 18 YEAR THEN
    INSERT INTO Adult (memberID, street, city, state, zipCode, phoneNumber, expiryDate, email)
    VALUES (NEW.memberID, '', '', 'QC', '', '', CURDATE() + INTERVAL 1 YEAR, '');
    DELETE FROM Juvenile WHERE memberID = NEW.memberID;
  END IF;
END;

-- Trigger to handle the expiry date in the Adult table
CREATE TRIGGER UpdateExpiryDate
BEFORE UPDATE ON Adult
FOR EACH ROW
BEGIN
  IF NEW.expiryDate <= CURDATE() THEN
    SET NEW.expiryDate = CURDATE() + INTERVAL 1 YEAR;
  END IF;
END;

-- Commit the transaction
COMMIT;

-- Stored procedure for checking out books

DELIMITER //
CREATE PROCEDURE CheckoutBook(IN memberID INT, IN copyID INT)
BEGIN
    DECLARE dueDate DATETIME;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the checkout process.';
    END;

    SET dueDate = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 14 DAY);

    -- Start transaction
    START TRANSACTION;

    -- Insert into Loan table
    INSERT INTO Loan (memberID, copyID, dueDate) VALUES (memberID, copyID, dueDate);

    -- Update BookCopy status
    UPDATE BookCopy SET onLoan = 'YES' WHERE copyID = copyID;

    -- Commit transaction
    COMMIT;
END;
//
DELIMITER ;

-- Trigger to notify members about expiring memberships
CREATE TABLE  IF NOT EXISTS Notifications (
  notificationID INT AUTO_INCREMENT PRIMARY KEY,
  memberID INT(6),
  message TEXT,
  sentDate DATETIME DEFAULT CURRENT_TIMESTAMP, -- Stores the date when the notification was sent
  FOREIGN KEY (memberID) REFERENCES Member(memberID)
);

CREATE TRIGGER NotifyExpiryBeforeUpdate
BEFORE UPDATE ON Adult
FOR EACH ROW
BEGIN
  -- Check if the new expiry date is one month ahead of the current date
  IF NEW.expiryDate = CURDATE() + INTERVAL 1 MONTH THEN
    INSERT INTO Notifications(memberID, message)
    VALUES (NEW.memberID, CONCAT('Your membership will expire on ', NEW.expiryDate, '. Please renew.'));
  END IF;
END；