-- insert data into Aragon Library (aragondb.sql) DB
-- for pathing, place this sql file in the same directory as the data files
-- added a check for errors in the reservation table
-- added a print statement to indicate success or failure of the data load
-- added a transaction block to ensure data integrity

-- Adult table

LOAD DATA INFILE './adult.txt'
INTO TABLE Adult
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(memberID, street, city, state, zipCode, phoneNumber, expiryDate)
SET email = NULL;

BEGIN TRY
    -- Start a new transaction
    BEGIN TRANSACTION;

    -- Create a temporary table for item.txt
    CREATE TEMPORARY TABLE TempItem (
        isbn INT(13),
        titleid INT,
        bookLanguage VARCHAR(50),
        cover VARCHAR(10),
        dummy_column VARCHAR(255)
    );

    -- Create a temporary table for title.txt
    CREATE TEMPORARY TABLE TempTitle (
        titleid INT PRIMARY KEY,
        title VARCHAR(50),
        author VARCHAR(50)
    );

    -- Load data from item.txt into TempItem
    LOAD DATA INFILE './item.txt'
    INTO TABLE TempItem
    FIELDS TERMINATED BY '\t'
    LINES TERMINATED BY '\n'
    (isbn, titleid, bookLanguage, cover, dummy_column);

    -- Load data from title.txt into TempTitle
    LOAD DATA INFILE './title.txt'
    INTO TABLE TempTitle
    FIELDS TERMINATED BY '|'
    LINES TERMINATED BY '\n'
    (titleid, title, author);

    -- Insert merged data into the Book table
    INSERT INTO Book (isbn, title, author, cover, bookLanguage, synopsis)
    SELECT 
        i.isbn, 
        t.title, 
        t.author, 
        i.cover, 
        i.bookLanguage, 
        NULL AS synopsis
    FROM 
        TempItem i
    JOIN 
        TempTitle t ON i.titleid = t.titleid;

    -- Commit the transaction if all operations succeed
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Rollback the transaction if any error occurs
    ROLLBACK TRANSACTION;

    -- Log the error details
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;


-- Copy table

LOAD DATA INFILE './copy.txt'
INTO TABLE BookCopy
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(isbn, @dummy, @dummy, onLoan)
-- if onLoan is 'YES', set loanable to 'YES'; otherwise, set loanable to 'YES' with 50% probability
SET loanable = IF(onLoan = 'YES', 'YES', IF(RAND() < 0.5, 'YES', 'NO'));

-- Member table

LOAD DATA INFILE './member.txt'
INTO TABLE Member
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(memberID, lastName, firstName, middleInitial);

-- Reservation table

BEGIN TRANSACTION;

LOAD DATA INFILE './reservation.txt'
INTO TABLE Reservation
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
(memberID, copyID, reservationDate)
SET isbn = NULL;

IF @ERROR = 0
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Data loaded successfully.';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Error loading data.';
END