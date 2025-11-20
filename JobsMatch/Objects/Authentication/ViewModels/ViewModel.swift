//
//  ViewModel.swift
//  JobsMatch
//
//  Created by ivans Android on 6/24/24.
//
import Foundation

import Combine

/*
enum Table {
    static let jobseekers = "jobseekers"
} 

enum AuthAction: String, CaseIterable {
    case signIn = "Sign In"
    case signUp = "Sign Up"
}

 */
/*final class UserManager: ObservableObject {
    @Published var user: User?
    
    static let shared = UserManager()
    
    init(user: User? = nil) {
        self.user = user
    }
    
    func clearUser() {
        user = nil
    }
}*/


/*
final class ViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoggedOut = false
    @Published var authAction: AuthAction = .signIn
    @Published var jobseeker = [User]()
    @Published var showingAuthView = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var age: Int = 0
    @Published var workEligiblity = ""
    @Published var jobFilters: [String] = []
    @Published var highestEducation = ""
    @Published var desiredPosition = ""
    @Published var resume = ""
    @Published var gender = ""
    @Published var sexualOrientation = ""
    @Published var pronouns = ""
    @Published var userBio = ""
    
    let supabase = SupabaseManager.shared.client
    
    init() {
        Task {
            UserDataManager.getLoggedInUser()
        }
    }
    
    
    // MARK: -- DATABASE
    
    func loadUserData() {
        let userData = UserDataManager.getUserName()
        firstName = userData.firstName
        lastName = userData.lastName
        email = userData.email
        
        jobFilters = Array(UserDataManager.getUserJobFilter())
        
        let resumeData = UserDataManager.getUserResume()
        highestEducation = resumeData.selectedEducation ?? ""
        age = resumeData.selectedAgeGroup ?? 0
        workEligiblity = resumeData.selectedEligibility ?? ""
        desiredPosition = resumeData.selectedPositions ?? ""
        
        let passwordData = UserDataManager.getUserPassword()
        password = passwordData.password
    }
    
    // MARK: -- AUTHENTICATION
    func signUp() async throws {
        loadUserData()
        print("ViewModel state at sign up:")
        print("Email: \(self.email)")
        print("Password: \(self.password)")
        
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            age: age,
            workEligiblity: workEligiblity,
            jobFilters: jobFilters,
            highestEducation: highestEducation,
            desiredPosition: desiredPosition,
            resume: resume,
            gender: gender,
            sexualOrientation: sexualOrientation,
            pronouns: pronouns,
            userBio: userBio
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let userData = try encoder.encode(newUser)
            
            print("User data to be inserted: \(String(data: userData, encoding: .utf8) ?? "")")
            
            let response = try await supabase
                .from("jobseekers")
                .insert(newUser)
                .execute()
            
            print("Supabase response: \(response)")
            
            // Handle the non-optional Data
            let insertedData = response.data
            print("Inserted data: \(String(data: insertedData, encoding: .utf8) ?? "Unable to decode")")
            
            // If you need to decode the response data
            let decoder = JSONDecoder()
            if let insertedUser = try? decoder.decode(User.self, from: insertedData) {
                print("Inserted user: \(insertedUser)")
            } else {
                print("Unable to decode inserted user data")
            }
        } catch {
            print("Error inserting user: \(error)")
            throw error
        }
    }
    
    func logOut() {
        UserDataManager.clearLoggedInUser()
        DispatchQueue.main.async {
            self.isLoggedOut = true
            self.isAuthenticated = false // Update the authentication state
            UserManager.shared.clearUser() // Clear the user from UserManager
        }
    }
    
    func authorize(email: String, password: String) async throws -> Bool {
        do {
            let jobseekersResponse = try await supabase
                .from("jobseekers")
                .select()
                .eq("email", value: email)
                .execute()
            
            // Logging the response
            let responseData = jobseekersResponse.data
            print("Jobseekers response data: \(String(data: responseData, encoding: .utf8) ?? "No data")")
            print("Jobseekers response status: \(jobseekersResponse.status)")
            
            // Convert the Data to JSON object
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]]
                print("JSON Array: \(String(describing: jsonArray))")
                
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray ?? [])
                let decoder = JSONDecoder()
                let jobseekers = try decoder.decode([User].self, from: jsonData)
                
                print("Decoded jobseekers: \(jobseekers)")
                
                guard let jobseeker = jobseekers.first else {
                    print("Error: No jobseekers found.")
                    return false
                }
                
                if password == jobseeker.password {
                    UserDataManager.saveLoggedInUser(user: jobseeker)
                    UserManager.shared.user = jobseeker
                    self.isAuthenticated = true
                    self.isLoggedOut = false
                    print("User signed in successfully.")
                    return true
                } else {
                    self.isAuthenticated = false
                    self.isLoggedOut = true
                    print("Invalid credentials.")
                    return false
                }
            } catch {
                self.isAuthenticated = false
                self.isLoggedOut = true
                print("JSON Decoding error: \(error)")
                return false
            }
        } catch {
            self.isAuthenticated = false
            self.isLoggedOut = true
            print("Error signing in: \(error.localizedDescription)")
            return false
        }
    }
    
    
    //MARK: -- UPDATE USER
    
    func updateUser() async throws {
        guard let user = UserManager.shared.user else {
            print("Can't update")
            return }

        var updatedUser = user
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        updatedUser.email = email
        updatedUser.pronouns = pronouns
        updatedUser.gender = gender
        updatedUser.sexualOrientation = sexualOrientation
        updatedUser.highestEducation = highestEducation
        updatedUser.jobFilters = jobFilters
        updatedUser.resume = resume
        updatedUser.userBio = userBio

        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let userData = try encoder.encode(updatedUser)

            print("User data to be updated: \(String(data: userData, encoding: .utf8) ?? "")")

            let response = try await supabase
                .from("jobseekers")
                .update(updatedUser)
                .eq("email",value: email)
                .execute()

            print("User updated successfully: \(response)")

            // Save the updated user back to UserManager
            UserManager.shared.user = updatedUser
            // Save the updated user to UserDefaults
            UserDataManager.saveLoggedInUser(user: updatedUser)
        } catch {
            print("Error updating user: \(error)")
            throw error
        }
    }
}
*/
