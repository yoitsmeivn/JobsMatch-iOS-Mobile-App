//
//  AuthServiceHost.swift
//  JobsMatch
//
//  Created by ivans Android on 8/4/24.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthServiceHost: ObservableObject{
    @Published var hostSession: FirebaseAuth.User? {
        didSet {
            if hostSession == nil {
                print("hostSession is nil")
                
            }
        }
    }
    
    @Published var currentHost: Host?
    
    
    @Published var first_name: String
    @Published var last_name: String
    @Published var company_name: String
    @Published var email: String
    @Published var assignedToJobs: [DocumentReference]?
    
    static let shared = AuthServiceHost()
    
    init() {
            self.hostSession = Auth.auth().currentUser
            self.first_name = ""
            self.last_name = ""
            self.company_name = ""
            self.email = ""
            self.assignedToJobs = nil
        }
    
    
    func listenToAuthStateHost() {
        print("DEBUG: Listening to auth state changes")
        Auth.auth().addStateDidChangeListener { [weak self] _, host in
            guard let self = self else {
                return
            }
            
            self.hostSession = host
            if let host = host {
                Task {
                    do {
                        print("DEBUG: host is logged in, fetching host data")
                        print(host.email ?? "")
                        print(host.uid)
                        self.fetchCurrentHost(for: host.uid)
                    }
                }
            } else {
                print("DEBUG: No host logged in")
                self.currentHost = nil
                self.hostSession = nil
            }
        }
    }
    
    
    
    func fetchCurrentHost(for host_id: String) {
        let db = Firestore.firestore()
        db.collection("recruiters").document(host_id).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    var host = try document.data(as: Host.self)
                    // Explicitly set the id field using the document ID
                    host.id = document.documentID
                    
                    DispatchQueue.main.async {
                        self?.currentHost = host
                        self?.first_name = host.employee_first_name ?? ""
                        self?.last_name = host.employee_last_name ?? ""
                        self?.company_name = host.company_name ?? ""
                        self?.email = host.employee_email ?? ""
                        self?.assignedToJobs = host.jobs
                        self?.currentHost = host
                    }
                    print("Host data successfully fetched: \(host)")
                } catch {
                    print("Error decoding host data: \(error.localizedDescription)")
                }
            } else {
                print("Host document does not exist or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
