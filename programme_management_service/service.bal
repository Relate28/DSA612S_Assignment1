import ballerina/http;
import ballerina/mysql;

type Course record {
    string name;
    string code;
    int nqfLevel;
};

type Programme record {
    string programmeCode;
    int nqfLevel;
    string faculty;
    string department;
    string title;
    string registrationDate;
    Course[] courses;
};

mysql:Client dbClient = check new (mysql:ClientConfig = {
    host: "localhost",
    port: 3306,
    name: "Programmes_db",
    username: "root",
    password: "@iCui4Cu123456",
    options: { useSSL: false }
});


# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - name as a string or nil
    # + return - string name with hello message or error
    resource function post addProgramme(http:Caller caller, http:Request request) returns error? {
    Programme programme = check request.getJsonPayload();
    
    // Insert programme details into the database
    sql:ParameterizedQuery sqlQuery = `INSERT INTO Programmes (programmeCode, nqfLevel, faculty, department, title, registrationDate)
                                       VALUES (${programme.programmeCode}, ${programme.nqfLevel}, ${programme.faculty}, ${programme.department}, ${programme.title}, ${programme.registrationDate})`;
    _ = check dbClient->execute(sqlQuery);
    
    // Insert courses related to the programme
    foreach var course in programme.courses {
        sqlQuery = `INSERT INTO Courses (name, code, nqfLevel, programmeCode)
                    VALUES (${course.name}, ${course.code}, ${course.nqfLevel}, ${programme.programmeCode})`;
        _ = check dbClient->execute(sqlQuery);
    }
    
    check caller->respond("Programme added successfully.");
}

resource function get allProgrammes(http:Caller caller, http:Request request) returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM Programmes`;
    stream<record {}, error> programmeStream = dbClient->query(sqlQuery);

    json[] programmeList = [];
    
    // Fetch all programmes
    error? e = programmeStream.forEach(function(record {} programme) {
        json pJson = check json.construct(programme);
        programmeList.push(pJson);
    });

    check caller->respond(programmeList);
}

resource function get programmeDetails(string programmeCode, http:Caller caller, http:Request request) returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM Programmes WHERE programmeCode = ${programmeCode}`;
    sql:Row programmeRow = check dbClient->queryRow(sqlQuery);

    if programmeRow is () {
        check caller->respond("Programme not found.");
    } else {
        json programmeJson = check json.construct(programmeRow);
        check caller->respond(programmeJson);
    }
}

resource function put updateProgramme(string programmeCode, http:Caller caller, http:Request request) returns error? {
    Programme updatedProgramme = check request.getJsonPayload();
    
    sql:ParameterizedQuery sqlQuery = `UPDATE Programmes SET nqfLevel = ${updatedProgramme.nqfLevel}, faculty = ${updatedProgramme.faculty}, 
                                       department = ${updatedProgramme.department}, title = ${updatedProgramme.title}
                                       WHERE programmeCode = ${programmeCode}`;
    _ = check dbClient->execute(sqlQuery);
    
    check caller->respond("Programme updated successfully.");
}

resource function delete deleteProgramme(string programmeCode, http:Caller caller, http:Request request) returns error? {
    sql:ParameterizedQuery sqlQuery = `DELETE FROM Programmes WHERE programmeCode = ${programmeCode}`;
    _ = check dbClient->execute(sqlQuery);
    
    // Delete related courses
    sqlQuery = `DELETE FROM Courses WHERE programmeCode = ${programmeCode}`;
    _ = check dbClient->execute(sqlQuery);
    
    check caller->respond("Programme deleted successfully.");
}

resource function get programmesByFaculty(string faculty, http:Caller caller, http:Request request) returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM Programmes WHERE faculty = ${faculty}`;
    stream<record {}, error> facultyStream = dbClient->query(sqlQuery);

    json[] facultyProgrammes = [];
    error? e = facultyStream.forEach(function(record {} programme) {
        json programmeJson = check json.construct(programme);
        facultyProgrammes.push(programmeJson);
    });

    check caller->respond(facultyProgrammes);
}

resource function get dueForReview(http:Caller caller, http:Request request) returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM Programmes WHERE registrationDate <= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)`;
    stream<record {}, error> dueForReviewStream = dbClient->query(sqlQuery);

    json[] dueForReviewProgrammes = [];
    error? e = dueForReviewStream.forEach(function(record {} programme) {
        json programmeJson = check json.construct(programme);
        dueForReviewProgrammes.push(programmeJson);
    });

    check caller->respond(dueForReviewProgrammes);
}

}
