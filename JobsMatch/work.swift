/*
struct UserDataManager {
    private static let loggedInUserKey = "loggedInUser"

    // Save logged-in user data
    static func saveLoggedInUser(user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: loggedInUserKey)
        }
    }

    // Retrieve logged-in user data
    static func getLoggedInUser() -> User? {
        if let savedUser = UserDefaults.standard.object(forKey: loggedInUserKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedUser = try? decoder.decode(User.self, from: savedUser) {
                return loadedUser
            }
        }
        return nil
    }

    // Clear logged-in user data (logout)
    static func clearLoggedInUser() {
        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
    }
}


// Example:
let loggedInUser = User(firstName: "John", lastName: "Doe", email: "john.doe@example.com", password: "password", age: 30, workEligiblity: "Yes", jobFilters: ["Tech", "Engineering"], highestEducation: "Bachelor's", desiredPosition: "Software Engineer", resume: "Resume content", gender: "Male", sexualOrientation: "Straight", pronouns: "he/him", userBio: "Bio content", score: "A", jobsApplied: [])

UserDataManager.saveLoggedInUser(user: loggedInUser)




Retrieve
if let savedUser = UserDataManager.getLoggedInUser() {
    print("Logged-in user: \(savedUser.firstName) \(savedUser.lastName)")
} else {
    print("No logged-in user found.")
}
*/
