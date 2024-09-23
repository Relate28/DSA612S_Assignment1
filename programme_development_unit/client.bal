import ballerina/log;
import ballerina/io;
import programme_management.clients as client;

public function executeClient() returns error? {
    client:Client programmeClient = check new ("http://localhost:8080");

    // Add a new programme
    client:Programme newProgramme = {
        code: "CS101",
        nqfLevel: "8",
        faculty: "Computing",
        department: "Computer Science",
        title: "Bachelor of Computer Science",
        registrationDate: "2019-01-01",
        courses: [
            {name: "Introduction to Computer Science", code: "CS1011", nqfLevel: "5"},
            
            {name: "Data Structures", code: "CS1012", nqfLevel: "6"}
        ]
    };

    var response = programmeClient->addProgramme(newProgramme);
    if response is client:HttpCreated {
        io:println("Programme added successfully.");
    } else {
        log:printError("Failed to add programme.", response);
    }

    // Retrieve all programmes
    var programmesResponse = programmeClient->getProgrammes();
    if programmesResponse is client:Programmes {
        io:println("All programmes: ", programmesResponse.toString());
    } else {
        log:printError("Failed to retrieve programmes.", programmesResponse);
    }

    // Update a programme
    newProgramme.title = "Bachelor of Science in Computer Science";
    response = programmeClient->updateProgramme("CS101", newProgramme);
    if response is client:HttpOk {
        io:println("Programme updated successfully.");
    } else {
        log:printError("Failed to update programme.", response);
    }

    // Retrieve specific programme by code
    var programmeResponse = programmeClient->getProgrammeByCode("CS101");
    if programmeResponse is client:Programme {
        io:println("Programme details: ", programmeResponse.toString());
    } else {
        log:printError("Failed to retrieve programme.", programmeResponse);
    }

    // Delete a programme by code
    response = programmeClient->deleteProgramme("CS101");
    if response is client:HttpOk {
        io:println("Programme deleted successfully.");
    } else {
        log:printError("Failed to delete programme.", response);
    }

    // Retrieve programmes due for review
    programmesResponse = programmeClient->getReviewDueProgrammes();
    if programmesResponse is client:Programmes {
        io:println("Programmes due for review: ", programmesResponse.toString());
    } else {
        log:printError("Failed to retrieve programmes due for review.", programmesResponse);
    }

    // Retrieve programmes by faculty
    programmesResponse = programmeClient->getProgrammesByFaculty("Computing");
    if programmesResponse is client:Programmes {
        io:println("Programmes in Computing faculty: ", programmesResponse.toString());
    } else {
        log:printError("Failed to retrieve programmes by faculty.", programmesResponse);
    }
}
 