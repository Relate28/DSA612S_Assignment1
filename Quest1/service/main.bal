import ballerina/http;

type Course record{
    string courseCode;
    string courseName;
    int nqfLevel;
};


type Programme record{
    string programmeCode;
    int nqfLevel;
    string faculty;
    string department;
    string title;
    string registrationDate;
    map<Course> courses;
};

map<Programme> programmes = {};


service /programme on new http:Listener(8080){
    //[POST] Add new programme
    resource function post programmes(http:Caller caller, http:Request req) returns error? {
        Programme newProgramme = check req.getJsonPayload();
        programmes[newProgramme.programmeCode] = newProgramme;
        check caller->respond(201);
        
    }

    //[GET]     Get list of programmes
    resource function get programmes(http:Caller caller) returns error? {
        map<Programme> programmesList = programmes;
        check caller->respond(programmesList);
    }

    //GET]      Retrieve the details of a specific programme by its code
     resource function get programmes/[string programmeCode](http:Caller caller) returns error? {
        Programme? programme = programmes[programmeCode];
        if (programme is ()) {
            check caller->respond(404);
        } else {
            check caller->respond(programme);
        }
    }

    //[PUT]     Update an existing programme's information by its code
    resource function put programmes/[string programmeCode](http:Caller caller, http:Request req) returns error? {
        Programme updatedProgramme = check req.getJsonPayload();
        programmes[programmeCode] = updatedProgramme;
        check caller->respond(200);
    }
    //[DELETE]  Delete a programme by its code
    resource function delete programmes/[string programmeCode](http:Caller caller) returns error? {
        if programmes.hasKey(programmeCode) {
            programmes.remove(programmeCode);
            check caller->respond(204);
        } else {
            check caller->respond(404);
        }
    }
    
    //[GET]     Retrieve all programmes that are due for review (5 years since registration)
    resource function get programmes/review(http:Caller caller) returns error? {
        json[] dueForReview = [];
        int currentYear = currentTime.year;

       foreach var [_, programme] in programmes.entries(){
        int regYear = check 'int:fromString(substring(programme.registrationDate, 0, 4));
        if (currentYear - regYear >= 5){
            dueForReview.push(programme);
        }
    }
    }

    
    //[GET]     Retrieve all programmes that belong to the same faculty
    resource function get programmes/faculty/[string faculty](http:Caller caller) returns error? {
        json[] facultyProgrammes = [];
        foreach var [_, programme] in programmes.entries() {
            if programme.faculty == faculty {
                facultyProgrammes.push(programme);
            }
        }
        check caller->respond(facultyProgrammes);
    }



}


