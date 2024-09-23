import ballerina/http;

type Lecturer record {
    string staffNumber;
    string officeNumber;
    string staffName;
    string title;
    string[] courses;
};

type Course record {
    string courseName;
    string courseCode;
    string nqfLevel;
};

type Office record {
    string officeNumber;
    string[] lecturers;
};

// In-memory data store
map<Office> offices = {};
map<Lecturer> lecturers = {};
map<Course> courses = {};



service / on new http:Listener(9090) {

    resource function post addLecturer(map<json> lecturer) returns json|error {
        // Ensure that all required fields are provided
        if (!lecturer.hasKey("staffNumber") || !lecturer.hasKey("officeNumber") ||
        !lecturer.hasKey("staffName") || !lecturer.hasKey("title") ||
        !lecturer.hasKey("courses")) {
            return error("All required fields must be provided");
        }

        // Cast the "courses" field to a JSON array
        json[] courses = <json[]>lecturer["courses"];

        // Convert the JSON array to a string array
        // string[] courseList = courses;

        Lecturer newLecturer = {
        staffNumber: lecturer["staffNumber"].toString(),
        officeNumber: lecturer["officeNumber"].toString(),
        staffName: lecturer["staffName"].toString(),
        title: lecturer["title"].toString(),
        courses: ["DSA", "AIG"]
    };

        lecturers[newLecturer.staffNumber] = newLecturer;

        return {"message": "Lecturer added successfully"};
    }

    resource function get getAllLecturers() returns json|error {
        return lecturers.toJson();
    }

    resource function put updateLecturer(string staffNumber, Lecturer lecturer) returns json|error {
        if (lecturers.hasKey(staffNumber)) {
            lecturers[staffNumber] = lecturer;
            return {"message": "Lecturer updated successfully"};
        } else {
            return error("Lecturer not found");
        }
    }

    resource function get getLecturer(string staffNumber) returns Lecturer?|error {
        if (lecturers.hasKey(staffNumber)) {
            return lecturers[staffNumber];
        } else {
            return error("Lecturer not found");
        }
    }

    resource function delete deleteLecturer(string staffNumber) returns json|error {
        if (lecturers.hasKey(staffNumber)) {
            _ = lecturers.remove(staffNumber);
            return {"message": "Lecturer deleted successfully"};
        } else {
            return error("Lecturer not found");
        }
    }

    resource function get getLecturersByCourse(string courseCode) returns json|error {
        json[] matchingLecturers = [];
        foreach var lecturer in lecturers {
            foreach var code in lecturer.courses {
                if (courseCode == code) {
                    matchingLecturers.push(lecturer.courses);
                    break;
                }
            }
        }
        return matchingLecturers;
    }

    resource function get getLecturersByOffice(string officeNumber) returns json|error {
        if (offices.hasKey(officeNumber)) {
            json[] matchingLecturers = [];
            foreach var lecturer in lecturers {
                if (lecturer.officeNumber == officeNumber) {
                    matchingLecturers.push(lecturer.entries().toString());
                }
            }
            return matchingLecturers;
        } else {
            return error("bal not found");
        }
    }

}
