import ballerina/http;
import ballerina/sql;
import ballerina/mysql;
import ballerina/time;

mysql:Client dbClient = new ({
    host: "localhost",
    port: 3306,
    name: "programme_db",
    username: "root",
    password: "password"
});

service /programmes on new http:Listener(8080) {

    resource function post programmes(http:Caller caller, http:Request req) returns error? {
        json programmeJson = check req.getJsonPayload();
        string code = check programmeJson.code.toString();
        int nqfLevel = check programmeJson.nqfLevel.toInt();
        string faculty = check programmeJson.faculty.toString();
        string department = check programmeJson.department.toString();
        string title = check programmeJson.title.toString();
        string registrationDate = check programmeJson.registrationDate.toString();

        // Calculate the review date (5 years after registration)
        time:Civil registrationTime = check time:parse(registrationDate);
        time:Civil reviewTime = registrationTime + {years: 5};

        sql:ParameterizedQuery query = `INSERT INTO Programme
            (code, nqfLevel, faculty, department, title, registrationDate, reviewDate)
            VALUES (${code}, ${nqfLevel}, ${faculty}, ${department}, ${title}, ${registrationDate}, ${reviewTime.toString()})`;

        _ = check dbClient->execute(query);
        check caller->respond(201);
    }

    resource function get programmes(http:Caller caller, http:Request req) returns error? {
        sql:ParameterizedQuery query = `SELECT * FROM Programme`;
        stream<record{}, sql:Error> resultStream = dbClient->query(query);

        json programmes = [];
        check from record{} row in resultStream
            do {
                json programme = row.toJson();
                programmes.push(programme);
            };

        check caller->respond(programmes);
    }

    resource function get programmes/[string code](http:Caller caller, http:Request req, string code) returns error? {
        sql:ParameterizedQuery query = `SELECT * FROM Programme WHERE code = ${code}`;
        stream<record{}, sql:Error> resultStream = dbClient->query(query);

        json programme;
        check from record{} row in resultStream
            do {
                programme = row.toJson();
            };

        check caller->respond(programme);
    }

    resource function put programmes/[string code](http:Caller caller, http:Request req, string code) returns error? {
        json programmeJson = check req.getJsonPayload();
        int nqfLevel = check programmeJson.nqfLevel.toInt();
        string faculty = check programmeJson.faculty.toString();
        string department = check programmeJson.department.toString();
        string title = check programmeJson.title.toString();
        string registrationDate = check programmeJson.registrationDate.toString();

        sql:ParameterizedQuery query = `UPDATE Programme SET
            nqfLevel = ${nqfLevel},
            faculty = ${faculty},
            department = ${department},
            title = ${title},
            registrationDate = ${registrationDate}
            WHERE code = ${code}`;

        _ = check dbClient->execute(query);
        check caller->respond(200);
    }

    resource function delete programmes/[string code](http:Caller caller, http:Request req, string code) returns error? {
        sql:ParameterizedQuery query = `DELETE FROM Programme WHERE code = ${code}`;
        _ = check dbClient->execute(query);
        check caller->respond(204);
    }

    resource function get programmes/review(http:Caller caller, http:Request req) returns error? {
        time:Civil currentTime = time:currentTime().toCivil();
        sql:ParameterizedQuery query = `SELECT * FROM Programme WHERE reviewDate <= ${currentTime.toString()}`;
        stream<record{}, sql:Error> resultStream = dbClient->query(query);

        json programmes = [];
        check from record{} row in resultStream
            do {
                json programme = row.toJson();
                programmes.push(programme);
            };

        check caller->respond(programmes);
    }

    resource function get programmes/faculty/[string faculty](http:Caller caller, http:Request req, string faculty) returns error? {
        sql:ParameterizedQuery query = `SELECT * FROM Programme WHERE faculty = ${faculty}`;
        stream<record{}, sql:Error> resultStream = dbClient->query(query);

        json programmes = [];
        check from record{} row in resultStream
            do {
                json programme = row.toJson();
                programmes.push(programme);
            };

        check caller->respond(programmes);
    }
}
