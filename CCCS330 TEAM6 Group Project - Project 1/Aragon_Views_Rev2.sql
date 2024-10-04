-- Create a mailing list view of Library members with their full names and complete address information.
CREATE VIEW MailingListView AS
SELECT 
    CONCAT(m.firstName, ' ', m.middleInitial, '. ', m.lastName) AS FullName, 
    a.street, a.city, a.stateProvince, a.zipCode
FROM 
    Member m
JOIN 
    Adult a ON m.memberID = a.memberID;

-- Create a view that returns isbn, copy_no, on_loan, title, translation, and cover for specific ISBNs.
CREATE VIEW SpecificISBNView AS
SELECT 
    b.isbn AS isbn, 
    bc.copyID AS copy_no, 
    bc.onLoan AS on_loan, 
    b.title as title, 
    b.bookLanguage AS translation, 
    b.cover as cover
FROM 
    Book b
JOIN 
    BookCopy bc ON b.isbn = bc.isbn

ORDER BY 
    b.isbn;

-- A dynamic query of the above:
SELECT *
FROM
    SpecificISBNView
WHERE
    isbn IN (1, 500, 1000);

-- Create a view that retrieves the member's full name, member_no, isbn, and log_date for specific members.
CREATE VIEW SpecificMembersView AS
SELECT 
    m.memberID AS member_no, 
    CONCAT(m.firstName, ' ', m.middleInitial, '. ', m.lastName) AS FullName, 
    r.isbn AS isbn, 
    r.reservationDate AS log_date
FROM 
    Member m
LEFT JOIN 
    Reservation r ON m.memberID = r.memberID
ORDER BY 
    m.memberID;

-- Create a view that lists the name and address for all adults.
CREATE VIEW adultwideView AS
SELECT 
    m.memberID AS member_no, 
    CONCAT(m.firstName, ' ', m.middleInitial, '. ', m.lastName) AS FullName, 
    a.street AS street, 
    a.city AS city, 
    a.stateProvince AS stateProvince, 
    a.zipCode AS zipCode
FROM 
    Member m
JOIN 
    Adult a ON m.memberID = a.memberID;

-- Create a view that lists the name and address for juveniles.
CREATE VIEW ChildwideView AS
SELECT 
    j.memberID, 
    CONCAT(m.firstName, ' ', m.middleInitial, '. ', m.lastName) AS FullName, 
    a.street, 
    a.city, 
    a.state, 
    a.zipCode
FROM 
    Juvenile j
JOIN 
    Member m ON j.memberID = m.memberID
JOIN 
    Adult a ON m.memberID = a.memberID;

-- Create a view that lists complete information about each book copy.
CREATE VIEW CopywideView AS
SELECT 
    bc.copyID, 
    bc.isbn, 
    bc.onLoan, 
    bc.loanable, 
    b.title, 
    b.author, 
    b.cover, 
    b.bookLanguage, 
    b.synopsis
FROM 
    BookCopy bc
JOIN 
    Book b ON bc.isbn = b.isbn;

-- Create a view that lists complete information about each loanable book copy.
CREATE VIEW LoanableView AS
SELECT 
    *
FROM 
    CopywideView
WHERE 
    loanable = 'YES';

-- Create a view that lists complete information about each book copy that is not currently on loan.
CREATE VIEW OnshelfView AS
SELECT 
    *
FROM 
    CopywideView
WHERE 
    onLoan = 'NO';

-- Create a view that lists the member, title, and loan information of a copy that is currently on loan.
CREATE VIEW OnloanView AS
SELECT 
    m.memberID, 
    CONCAT(m.firstName, ' ', m.middleInitial, '. ', m.lastName) AS FullName, 
    b.title, 
    l.loanID, 
    l.checkedOutDate, 
    l.dueDate
FROM 
    Loan l
JOIN 
    Member m ON l.memberID = m.memberID
JOIN 
    BookCopy bc ON l.copyID = bc.copyID
JOIN 
    Book b ON bc.isbn = b.isbn
WHERE 
    bc.onLoan = 'YES';

-- Query the above for a specific loanID
SELECT *
FROM OnloanView
WHERE loanID = 123;  -- Replace 123 with the specific loanID you want to query

-- Create a view that lists the member, title, and loan information of a copy that is overdue.
CREATE VIEW OverdueView AS
SELECT 
    *
FROM 
    OnloanView
WHERE 
    dueDate < CURDATE();

-- Create a view to determine book availability
CREATE VIEW BookAvailability AS
SELECT 
    b.isbn,
    b.title,
    b.author,
    b.cover,
    b.bookLanguage,
    b.synopsis,
    COUNT(CASE WHEN bc.status = 'on_loan' THEN 1 ELSE NULL END) AS CopiesOnLoan,
    COUNT(r.reservationID) AS Reservations
FROM 
    Book b
LEFT JOIN 
    BookCopy bc ON b.isbn = bc.isbn
LEFT JOIN 
    Reservation r ON b.isbn = r.isbn
GROUP BY 
    b.isbn, b.title, b.author, b.cover, b.bookLanguage, b.synopsis;

-- Create a view for expiring membership
CREATE VIEW ExpiringMemberships AS
SELECT memberID, expiryDate
FROM Member
WHERE expiryDate BETWEEN CURDATE() AND CURDATE() + INTERVAL 1 MONTH;