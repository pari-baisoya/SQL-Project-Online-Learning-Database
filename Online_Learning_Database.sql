-- Task 1
Create Database online_learning_system;
Use online_learning_system;

-- Student Table
Create Table Student_Table
(
StudentID Int Primary Key,
FirstName Varchar(100),
LastName Varchar(100),
Email Varchar(50),
Contact Varchar(100)
);
Insert Into Student_Table(StudentID, FirstName, LastName, Email, Contact) Values
(101, 'Pari', 'Baisoya', 'pari@gmail.com', '9876543211'),
(102, 'Pooja', 'Sharma', 'pooja@gmail.com', '9658743212'),
(103, 'Preeti', 'Patel', 'preeti@gmail.com', '9854673213'),
(104, 'Sarika', 'Shakya', 'sarika@gmail.com', '7854882134'),
(105, 'Lucky', 'Singh', 'lucky@gmail.com', '8546285235');

-- Retrieve all columns
Select * From Student_Table;

-- Course Table
Create Table Course_Table
(
CourseID Int Primary Key auto_increment,
CourseName Varchar(100),
CourseInstructor Varchar(100),
CourseDuration Varchar(50)
);
Insert Into Course_Table(CourseName, CourseInstructor, CourseDuration)Values
('AI', 'Deepika Singh', '1 Year'),
('Copa', 'Rajkumar', '1 Year'),
('CSA', 'Guruvulu', '1 Year'),
('IT', 'Raj Singh', '2 Year'),
('IBM', 'Anshika Sharma', '2 Year');

-- Retrieve all Columns
Select * From Course_Table;

-- Enrollment Table
CREATE TABLE Enrollment_Table (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student_Table(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course_Table(CourseID)
);

Insert Into Enrollment_Table(StudentID, CourseID, EnrollmentDate) Values
(101, 1, '2024-10-30'),
(102, 2, '2024-02-11'),
(103, 3, '2024-06-17'),
(104, 4, '2024-03-26'),
(105, 5, '2024-01-10');

-- Retrieve All Coloumns
Select * From Enrollment_Table;

-- Payment Table
CREATE TABLE Payment_Table (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Student_Table(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course_Table(CourseID),
    FOREIGN KEY (EnrollmentID) REFERENCES Enrollment_Table(EnrollmentID)
);
Insert Into Payment_Table(PaymentID, StudentID, CourseID, EnrollmentID, Amount)Values
(101, 1, 1,1, 500.00),
(102, 2, 2,2, 550.00),
(103, 3, 3,3, 600.00),
(104, 4, 4,4, 650.00),
(105, 5, 5,5, 700.00);

-- Retrieve All Coloumns
Select * From Payment_Table;
-- Task 2 Relationship between the tables bt ER daigram

-- Task 3  
-- Start the Transaction
-- Change delimiter to avoid issues with semicolons in the block
DELIMITER $$

-- Start the transaction
START TRANSACTION;

-- Step 1: Insert the Enrollment Record
INSERT INTO Enrollment_Table (student_id, course_id, enrollment_date)
VALUES (1, 101, CURDATE());

-- Capture the newly inserted enrollment_id
SET @enrollment_id = LAST_INSERT_ID();

-- Step 2: Insert the Payment Record
INSERT INTO Payment_Table (enrollment_id, payment_date, amount, payment_status, payment_method)
VALUES (@enrollment_id, CURDATE(), 200.00, 'completed', 'credit card');

-- Step 3: Commit the transaction if everything succeeds
COMMIT;

-- Reset the delimiter back to the default semicolon
DELIMITER ;
SELECT * FROM Enrollment_Table WHERE StudentID = 1 AND CourseID = 101;
SELECT * FROM Payment_Table WHERE EnrollmentID = (SELECT EnrollmentID FROM Enrollment_Table WHERE StudentID = 1 AND CourseID = 101);




DELIMITER $$

CREATE PROCEDURE HandlePaymentFailure(
    IN student_id INT, 
    IN course_id INT, 
    IN payment_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE enrollment_id INT;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Insert Enrollment
    INSERT INTO Enrollments (StudentID, course_id, enrollment_date)
    VALUES (student_id, course_id, CURDATE());
    
    -- Get the last inserted enrollment_id
    SET enrollment_id = LAST_INSERT_ID();
    
    -- Insert Payment (Simulating failure in this case)
    INSERT INTO Payments (EnrollmentID, payment_date, amount, payment_status, payment_method)
    VALUES (enrollment_id, CURDATE(), payment_amount, 'failed', 'credit card');
    
    -- If payment fails, rollback both enrollment and payment
    IF payment_amount <= 0 THEN
        ROLLBACK;
        SELECT 'Transaction Failed - Payment not processed';
    ELSE
        COMMIT;
        SELECT 'Transaction Completed - Enrollment and Payment Successful';
    END IF;
    
END$$

DELIMITER ;
SHOW CREATE PROCEDURE HandlePaymentFailure;