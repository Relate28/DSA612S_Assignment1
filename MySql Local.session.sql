CREATE TABLE Programmes (
  programmeCode VARCHAR(50) PRIMARY KEY,
  title VARCHAR(100),
  nQFLevel INT,
  faculty VARCHAR(100),
  department VARCHAR(100),
  registrationDate DATE
);

CREATE TABLE Courses (
  courseCode VARCHAR(50) PRIMARY KEY,
  courseName VARCHAR(100),
  nQFLevel INT,
  programmeCode VARCHAR(50),
  FOREIGN KEY (programmeCode) REFERENCES Programmes(programmeCode) ON DELETE CASCADE
);


INSERT INTO Programmes (programmeCode, title, nQFLevel, faculty, department, registrationDate)
VALUES ('07BCCS', 'Bachelor of Computer Science(Cyber Security)', 7, 'Faculty of Computing and Informatics', 'Department of Computer Science', '2023-02-22'),
       ('09MMET', 'Master of Engineering in Metallurgy', 9, 'Faculty of Engineering and the Built Environment', 'Department of Civil, Mining and Process Engineering
', '2023-02-25');

INSERT INTO Courses (courseCode, courseName, nQFLevel, programmeCode)
VALUES ('CSC101', 'Introduction to Programming', 7, '07BCCS');


SELECT * FROM programmes;




