-- create new database "aragondb"
CREATE DATABASE aragondb;

-- use the database
USE aragondb;

-- create table  Member
CREATE TABLE Member (
  memberID INT(6) PRIMARY KEY,										-- primary key constraint
  lastName VARCHAR(30) NOT NULL,
  firstName VARCHAR(30) NOT NULL,
  middleInitial CHAR(1) NOT NULL,
);

-- create table Photo
CREATE TABLE Photo (
	photoID INT PRIMARY KEY AUTO_INCREMENT,							-- primary key constraint
    memberID INT(6),
    photograph BLOB,
    FOREIGN KEY (memberID) REFERENCES Member(memberID)				-- foreign key constraint
);

-- create Table Adult
CREATE TABLE Adult (
	memberID INT(6) PRIMARY KEY,									-- primary key constraint
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    stateProvince VARCHAR(5) NOT NULL DEFAULT 'QC',							-- default constraint
    zipCode VARCHAR(6) NOT NULL,
    phoneNumber VARCHAR(12),
    expiryDate DATETIME NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,								-- unique constraint on email
	FOREIGN KEY (memberID) REFERENCES Member(memberID)				-- foreign key constraint
);

-- create Table Book
CREATE TABLE Book (
	isbn INT(13) PRIMARY KEY,										-- primary key constraint
    title VARCHAR(50) NOT NULL,
    author VARCHAR(50) NOT NULL,
    cover VARCHAR(10) NOT NULL,
    bookLanguage VARCHAR(50) NOT NULL,
    synopsis TEXT  
);

-- create Table Book Copy
CREATE TABLE BookCopy (
  copyID INT PRIMARY KEY AUTO_INCREMENT,							-- primary key constraint with auto-increment
  isbn INT(13) NOT NULL,
  onLoan ENUM('YES', 'NO') NOT NULL,
  loanable ENUM('YES', 'NO') NOT NULL,
  FOREIGN KEY (isbn) REFERENCES Book(isbn),						-- foreign key constraint
  UNIQUE (isbn, copyID),											-- unique constraint to ensure each copy of a book is unique
  CHECK (onLoan IN ('YES', 'NO')),								-- check constraint for onLoan
  CHECK (loanable IN ('YES', 'NO'))								-- check constraint for loanable
);

-- create Table Librarians
CREATE TABLE Librarians (
  librarianID INT(6) PRIMARY KEY,									-- primary key constraint
  lastName VARCHAR(30) NOT NULL,
  firstName VARCHAR(30) NOT NULL,
  middleInitial CHAR(1) NOT NULL
);

-- Create Table Loan
CREATE TABLE Loan (
    loanID INT PRIMARY KEY,
    memberID INT NOT NULL,
    copyID INT NOT NULL,
    checkedOutDate DATETIME NOT NULL,
    dueDate DATETIME NOT NULL,
    librarianID INT NOT NULL,
    FOREIGN KEY (memberID) REFERENCES Member(memberID),
    FOREIGN KEY (copyID) REFERENCES BookCopy(copyID),
    FOREIGN KEY (librarianID) REFERENCES Librarians(librarianID),
    CHECK (checkedOutDate < dueDate) -- ensure checkedOutDate is before dueDate
);

-- Create a non-clustered index on memberID
CREATE NONCLUSTERED INDEX idx_MemberID ON Loan(memberID);

-- Create a clustered index on dueDate
CREATE CLUSTERED INDEX idx_DueDate ON Loan(dueDate);

-- create Table Reservation
CREATE TABLE Reservation (
	reservationID INT PRIMARY KEY AUTO_INCREMENT,					-- primary key constraint with auto-increment
    memberID INT(6) NOT NULL,
    copyID INT NOT NULL,
    isbn INT(13),
    reservationDate DATETIME NOT NULL,
    librarianID INT(6) NOT NULL,
   	FOREIGN KEY (memberID) REFERENCES Member(memberID),				-- foreign key constraint
	  FOREIGN KEY (isbn) REFERENCES Book(isbn),						-- foreign key constraint
   	FOREIGN KEY (copyID) REFERENCES BookCopy(copyID),				-- foreign key constraint
    FOREIGN KEY (librarianID) REFERENCES Librarians(librarianID)	-- foreign key constraint
    CHECK (reservationDate <= NOW())								-- check constraint to ensure reservation date is not in the future
);

-- create Table BookReturn
CREATE TABLE BookReturn (
	bookReturnID INT PRIMARY KEY AUTO_INCREMENT,					-- primary key constraint with auto-increment
    loanID INT(6) NOT NULL,
    returnDate DATETIME NOT NULL,
   	FOREIGN KEY (loanID) REFERENCES Loan(loanID)					-- foreign key constraint
);

-- create Table Juvenile
CREATE TABLE Juvenile (
  memberID INT(6) PRIMARY KEY,										-- primary key constraint
  lastName VARCHAR(30) NOT NULL,
  firstName VARCHAR(30) NOT NULL,
  middleInitial CHAR(1) NOT NULL,
  dateOfBirth DATETIME NOT NULL,
  signature BLOB,
  FOREIGN KEY (memberID) REFERENCES Member(memberID)				-- foreign key constraint  
);

-- default constraint for "State" column "Adult" table  
ALTER TABLE Adult 
    ALTER COLUMN state SET DEFAULT 'QC';
    
-- check constraint for phone number in "adult" table (phone number pattern 555-555-5555)
ALTER TABLE Adult
	ADD CONSTRAINT CK_phoneNumber CHECK (phoneNumber REGEXP '^[0-9]{3}-[0-9]{3}-[0-9]{4}$');
    
-- check constraint for zip code in "adult" table (zip code pattern 1H1P31)
ALTER TABLE Adult
	ADD CONSTRAINT CK_zipCode CHECK (zipCode REGEXP '^[A-Z][0-9][A-Z][0-9][A-Z][0-9]$');
    
-- check constraint for onLoan in "bookCopy" table
 ALTER TABLE BookCopy 
	ADD CONSTRAINT CK_onLoan CHECK (onLoan IN ('YES' ,'NO'));
    
-- check constraint for onLoan in "bookCopy" table
 ALTER TABLE BookCopy 
	ADD CONSTRAINT CK_loanable CHECK (loanable IN ('YES' ,'NO'));
    
-- check constraint for between duedate >= checkedoutdate in "loan" table
ALTER TABLE Loan
	ADD CONSTRAINT CK_dueDate CHECK (checkedOutDate <= dueDate);
    
-- unique constraint for memberID and isbn in "reservation" table to insure member cannot reserve same book more than one time
ALTER TABLE Reservation
ADD CONSTRAINT UNIQUE (memberID, isbn);


-- This is a last minute addition to create a table for membership expiry notification list
-- It is not reflected in the ERD or the RDS

CREATE TABLE Notifications (
  notificationID INT AUTO_INCREMENT PRIMARY KEY,
  memberID INT(6) NOT NULL,
  message TEXT,
  FOREIGN KEY (memberID) REFERENCES Member(memberID)
);