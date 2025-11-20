//
//  userInfo.swift
//  JobsMatch
//
//  Created by ivans Android on 4/9/24.
//

import Foundation
//import FirebaseFirestore
import FirebaseFirestore


struct User: Codable, Identifiable, Hashable {
    @DocumentID var id: String?  // This will map to the Firestore document ID
    //let uid: String  // This will store the Firebase Auth UID
    var full_name: String?
    var email: String?
    var password: String?
    var address: String?
    var work_eligibility: String?
    //var job_filters: [String]?
    var education: [[String: String]]?
    var experience: [[String: String]]?
    var disability_status: String?
    var military_status: String?
    //var desired_position: String?
    var resume: String?
    //var gender: String?
    //var sexual_orientation: String?
   // var pronouns: String?
    var jobs_applied: [DocumentReference]?
    var jobs_declined: [DocumentReference]?
    var saved_jobs: [DocumentReference]?
    var google_uid: String?
    var links: [String:String]?
    var skills: [String]?
    var user_bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        //case uid
        case full_name = "first_name"
        case email = "email"
        case password = "password"
        case address = "address"
        case work_eligibility = "work_eligibility"
        //case job_filters = "jobfilters"
        case education = "education"
        //case desired_position = "desiredposition"
        case experience = "experience"
        case disability_status = "disability_status"
        case military_status = "military_status"
        case resume = "resume"
        //case gender = "gender"
        //case sexual_orientation = "sexualorientation"
        //case pronouns = "pronouns"
        case jobs_applied = "jobs_applied"
        case jobs_declined = "jobs_declined"
        case saved_jobs = "saved_jobs"
        case google_uid = "google_uid"
        case links = "links"
        case skills = "skills"
        case user_bio = "user_bio"
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UserDataManager {
    // Save user data
    static func saveUserName(full_name: String, email: String, gender: String, pronouns: String) {
        UserDefaults.standard.set(full_name, forKey: "full_name")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(gender, forKey: "gender")
        UserDefaults.standard.set(pronouns, forKey: "pronouns")
    }

    static func saveUserJobFilter(interests: Set<String>) {
        UserDefaults.standard.set(Array(interests), forKey: "interests")
    }

    static func saveUserResume(educationArray: [[String: String]], selectedEligibility: String?, selectedPositions: String?,experienceArray: [[String: String]],selectedDisability: String?, selectedMilitaryStatus: String?, linksArray: [String],user_bio: String?,skills: [String]) {
        UserDefaults.standard.set(educationArray, forKey: "educationArray")
        UserDefaults.standard.set(selectedEligibility, forKey: "selectedEligibility")
        UserDefaults.standard.set(selectedPositions, forKey: "selectedPositions")
        UserDefaults.standard.set(experienceArray, forKey: "experienceArray")
        UserDefaults.standard.set(selectedDisability, forKey: "selectedDisability")
        UserDefaults.standard.set(selectedMilitaryStatus, forKey: "selectedMilitaryStatus")
        UserDefaults.standard.set(linksArray, forKey: "linksArray")
        UserDefaults.standard.set(user_bio, forKey: "user_bio")
        UserDefaults.standard.set(skills, forKey: "skills")
    }

    static func saveUserPassword(password: String, passwordCheck: String) {
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(passwordCheck, forKey: "passwordCheck")
    }

    // Retrieve user data
    static func getUserName() -> (id: String, full_name: String, email: String, address: String) {
        let id = UserDefaults.standard.string(forKey: "id") ?? ""
        let full_name = UserDefaults.standard.string(forKey: "full_name") ?? ""
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let address = UserDefaults.standard.string(forKey: "address") ?? ""
        return (id, full_name, email,address)
    }

    static func getUserJobFilter() -> Set<String> {
        let interestsArray = UserDefaults.standard.array(forKey: "interests") as? [String] ?? []
        return Set(interestsArray)
    }

    static func getUserResume() -> (educationArray: [[String: String]],selectedEligibility: String?, selectedPositions: String?, experienceArray: [[String: String]], selectedDisability: String?, selectedMilitaryStatus: String?, linksArray:[String: String],user_bio: String?,skills: [String]) {
        let educationArray = UserDefaults.standard.array(forKey: "educationArray") as? [[String: String]] ?? []
        let selectedEligibility = UserDefaults.standard.string(forKey: "selectedEligibility")
        let selectedPositions = UserDefaults.standard.string(forKey: "selectedPositions")
        let experienceArray = UserDefaults.standard.array(forKey: "experienceArray") as? [[String: String]] ?? []
        let selectedDisability = UserDefaults.standard.string(forKey: "selectedDisability")
        let selectedMilitaryStatus = UserDefaults.standard.string(forKey: "selectedMilitaryStatus")
        let linksArray = UserDefaults.standard.array(forKey: "linksArray") as? [String: String] ?? [:]
        let user_bio = UserDefaults.standard.string(forKey: "user_bio")
        let skills = UserDefaults.standard.array(forKey: "skills") as? [String] ?? []
        return (educationArray, selectedEligibility, selectedPositions, experienceArray,selectedDisability,selectedMilitaryStatus,linksArray,user_bio, skills)
    }

    static func getUserPassword() -> (password: String, passwordCheck: String) {
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        let passwordCheck = UserDefaults.standard.string(forKey: "passwordCheck") ?? ""
        return (password, passwordCheck)
    }
    
    static func saveResume(_ url: String) {
        UserDefaults.standard.set(url, forKey: "resume")
    }

    // New method to get resume URL
    static func getResume() -> String? {
        return UserDefaults.standard.string(forKey: "resume")
    }
    static func getUserUUID() -> String? {
        return UserDefaults.standard.string(forKey: "user_uuid")
    }
}






