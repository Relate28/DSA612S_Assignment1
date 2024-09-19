import ballerina/http;

public function main() returns error? {
    http:Client programmeClient = check new ("http://localhost:8080/programmes");

    // Add a new programme
    Programme programme = {
        programmeCode: "CS101",
        nqfLevel: 7,
        faculty: "Science",
        department: "Computer Science",
        title: "BSc Computer Science",
        registrationDate: "2018-01-01",
        courses: [{courseCode: "CS101", courseName: "Intro to CS", nqfLevel: 5}]
    };

    http:Response response = check programmeClient->post("/programmes", programme);
    io:println("Add programme response: ", response.statusCode);
    
    // Retrieve all programmes
    response = check programmeClient->get("/programmes");
    json programmes = check response.getJsonPayload();
    io:println("Programmes: ", programmes);
}
