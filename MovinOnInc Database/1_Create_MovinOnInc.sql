/* 
Purpose: To create a database for MovinOn Inc. that tracks the inventory of moving supplies, 
manages employee and driver data, processes job orders, and handles various related business operations.
*/

/* Script Date: May 30, 2024
Developed by: Team 6 */

-- Creating the MovinOnInc database with modern character set and collation
CREATE DATABASE IF NOT EXISTS MovinOnInc
    DEFAULT CHARACTER SET utf8mb4  -- Using utf8mb4 for full Unicode support
    DEFAULT COLLATE utf8mb4_unicode_ci;  -- Unicode (multilingual) ci for case-insensitive comparisons

-- Use the newly created database
USE MovinOnInc;

-- Commands to view current character set and collation settings
SHOW CHARACTER SET;
SHOW COLLATION;

-- List all databases
SHOW DATABASES;

-- List all tables in the current database (should be empty immediately after creation)
SHOW TABLES;