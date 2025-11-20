//
//  ViewModel2.swift
//  JobsMatch
//
//  Created by ivans Android on 7/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PhotosUI


final class UserManager: ObservableObject {
    @Published var user: User?
    
    static let shared = UserManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init(user: User? = nil) {
        self.user = user
    }
    
    func clearUser() {
        user = nil
    }
}


class ViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var full_name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var address = ""
    @Published var work_eligibility = ""
    @Published var education: [[String: String]] = []
    @Published var degree = ""
    @Published var major = ""
    @Published var end_year = ""
    @Published var experience: [[String: String]] = []
    @Published var disability_status = ""
    @Published var military_status = ""
    @Published var resume = ""
    @Published var jobs_applied: [DocumentReference] = []
    @Published var jobs_rejected: [DocumentReference] = []
    @Published var saved_jobs: [DocumentReference] = []
    @Published var google_uid = ""
    @Published var links: [String:String] = [:]
    @Published var skills: [String] = []
    @Published var user_bio = ""
    
    @Published var isLoggedOut = false
    @Published var isAuthenticating = false
    @Published var isFirstTimeUser: Bool = false
    private let db = Firestore.firestore()
    
}
