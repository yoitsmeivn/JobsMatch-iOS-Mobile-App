//
//  AuthService.swift
//  JobsMatch
//
//  Created by ivans Android on 7/15/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import JWTDecode
import CommonCrypto

class AuthService: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    {
        didSet {
            // SendbirdManager.register...
        }
    }
    @Published var isUserDataLoaded = false
    @Published var full_name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var work_eligibility = ""
    @Published var education: [[String: String]] = []
    @Published var degree = ""
    @Published var major = ""
    @Published var end_year = ""
    @Published var experience: [[String: String]] = []
    @Published var resume = ""
    @Published var user_bio = ""
    @Published var jobs_applied: [DocumentReference] = []
    @Published var jobs_rejected: [DocumentReference] = []
    @Published var saved_jobs: [DocumentReference] = []
    @Published var skills: [String] = []
    @Published var links: [String: String] = [:]
    @Published var google_uid = ""
    @Published var address = ""
    @Published var disability_status = ""
    @Published var military_status = ""
    
    
    static let shared = AuthService()
    
    init() {
            self.userSession = Auth.auth().currentUser
            if let userSession = self.userSession {
                // Try to get stored UUID
                if let uuid = UserDefaults.standard.string(forKey: "user_uuid") {
                    self.fetchCurrentUser(for: uuid)
                } else {
                    // If no UUID stored, query by email
                    let email = userSession.email ?? ""
                    self.findAndSetUserByEmail(email)
                }
            }
        }
    
    private func findAndSetUserByEmail(_ email: String) {
            let db = Firestore.firestore()
            db.collection("jobseekers")
                .whereField("email", isEqualTo: email)
                .getDocuments { [weak self] (snapshot, error) in
                    if let document = snapshot?.documents.first {
                        let uuid = document.documentID
                        UserDefaults.standard.set(uuid, forKey: "user_uuid")
                        self?.fetchCurrentUser(for: uuid)
                    }
                }
        }
    
    func listenToAuthState() {
            Auth.auth().addStateDidChangeListener { [weak self] _, user in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.userSession = user
                    if let user = user {
                        if let uuid = UserDefaults.standard.string(forKey: "userUUID") {
                            self.fetchCurrentUser(for: uuid)
                        } else {
                            self.findAndSetUserByEmail(user.email ?? "")
                        }
                    } else {
                        self.currentUser = nil
                        UserDefaults.standard.removeObject(forKey: "userUUID")
                    }
                }
            }
        }
    
    func updateUser(_ updatedUser: User) async throws {
        guard userSession != nil else {
            print("DEBUG: No user session found")
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user session found"])
        }

        guard let userId = UserDataManager.getUserUUID() else {
            print("DEBUG: No UUID found in UserDefaults")
            throw NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No UUID found in UserDefaults"])
        }

        do {
            let db = Firestore.firestore()
            var updatedUserWithId = updatedUser
            updatedUserWithId.id = userId // Ensure we're using the UUID
            try db.collection("jobseekers").document(userId).setData(from: updatedUserWithId, merge: true)
            self.currentUser = updatedUserWithId
            print("DEBUG: User updated successfully with UUID: \(userId)")
        } catch {
            print("DEBUG: Error updating user: \(error.localizedDescription)")
            throw error
        }
    }
    
    @discardableResult
    func fetchCurrentUser(for uuid: String) -> User? {
        print("DEBUG: Fetching user with UUID: \(uuid)")
        let db = Firestore.firestore()
        db.collection("jobseekers").document(uuid).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                do {
                    var user = try document.data(as: User.self)
                    user.id = uuid // Ensure the UUID is set correctly
                    DispatchQueue.main.async {
                        self?.currentUser = user
                        self?.isUserDataLoaded = true
                    }
                    print("User data successfully fetched with UUID: \(uuid)")
                } catch {
                    print("Error decoding user data: \(error)")
                }
            } else {
                print("User document does not exist or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        return self.currentUser
    }
    
    @MainActor
    private func uploadUserData() async throws {
        loadUserData()
        guard let uuid = UserDataManager.getUserUUID() else {
            print("DEBUG: No UUID found in UserDefaults")
            return
        }
        
        let user = User(id: uuid, // Use UUID instead of Firebase UID
           full_name: full_name,
           email: email,
           password: password,
           address: address,
           work_eligibility: work_eligibility,
           education: education,
           experience: experience,
           disability_status: disability_status,
           military_status: military_status,
           resume: resume,
           jobs_applied: [],
           jobs_declined: [],
           saved_jobs:[],
           google_uid: google_uid,
           links: links,
           skills: skills,
           user_bio: user_bio)
        
        try Firestore.firestore().collection("jobseekers").document(uuid).setData(from: user)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            // Optionally clear the UUID from UserDefaults if needed
            // UserDataManager.clearUserUUID()
        } catch {
            print("DEBUG: Failed to sign out")
        }
    }
    
    func loadUserData() {
        let userData = UserDataManager.getUserName()
        full_name = userData.full_name
        email = userData.email
        
        let resumeData = UserDataManager.getUserResume()
        education = resumeData.educationArray
        experience = resumeData.experienceArray
        work_eligibility = resumeData.selectedEligibility ?? ""
        disability_status = resumeData.selectedDisability ?? ""
        military_status = resumeData.selectedMilitaryStatus ?? ""
        links = resumeData.linksArray
        
        let passwordData = UserDataManager.getUserPassword()
        password = passwordData.password
    }
}


class JWTManager: ObservableObject {
    static let shared = JWTManager()
    
    @Published var currentToken: String?
    private let tokenKey = ""
    private let JWT_SECRET = ProcessInfo.processInfo.environment["JWT_SECRET"] ?? ""
    
    
    
    private init() {
        currentToken = UserDefaults.standard.string(forKey: tokenKey)
    }
    
    // Verify token matching the JavaScript implementation
    func verifyToken(_ token: String) -> Bool {
            let parts = token.components(separatedBy: ".")
            guard parts.count == 3 else {
                print("❌ Token verification failed: Invalid number of parts")
                return false
            }
            
            let headerBase64 = parts[0]
            let payloadBase64 = parts[1]
            let signatureBase64 = parts[2]
            
            // Debug print decoded payload
            if let payloadData = Data(base64URLEncoded: payloadBase64),
               let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                print("🔍 Token Payload:", payload)
                
                if let exp = payload["exp"] as? TimeInterval {
                    let expirationDate = Date(timeIntervalSince1970: exp)
                    let currentDate = Date()
                    print("⏰ Token Expiration:", expirationDate)
                    print("⏰ Current Time:", currentDate)
                    print("⏰ Is Expired:", currentDate >= expirationDate)
                }
            }
            
            // Verify signature
            let signatureInput = "\(headerBase64).\(payloadBase64)"
            let expectedSignature = signatureInput.data(using: .utf8)!
                .hmacSHA256(key: JWT_SECRET)
                .base64URLEncodedString()
            
            let isSignatureValid = signatureBase64 == expectedSignature
            print("🔐 Signature Valid:", isSignatureValid)
            
            if !isSignatureValid {
                print("❌ Token verification failed: Invalid signature")
                print("Expected:", expectedSignature)
                print("Received:", signatureBase64)
                return false
            }
            
            // Decode and verify payload
            guard let payloadData = Data(base64URLEncoded: payloadBase64),
                  let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
                  let expiration = payload["exp"] as? TimeInterval else {
                print("❌ Token verification failed: Could not decode payload")
                return false
            }
            
            let isExpired = Date().timeIntervalSince1970 >= expiration
            if isExpired {
                print("❌ Token verification failed: Token is expired")
            }
            
            return !isExpired
        }
    
    func generateJWTToken(userId: String, email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let header = ["alg": "HS256", "typ": "JWT"]
        let payload: [String: Any] = [
            "uid": userId,
            "email": email,
            "exp": Int(Date().addingTimeInterval(15 * 60).timeIntervalSince1970)
        ]
        
        do {
            guard let headerData = try? JSONSerialization.data(withJSONObject: header),
                  let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
                completion(.failure(JWTError.encodingFailed))
                return
            }
            
            let headerBase64 = headerData.base64URLEncodedString()
            let payloadBase64 = payloadData.base64URLEncodedString()
            
            let signatureInput = "\(headerBase64).\(payloadBase64)"
            let signature = signatureInput.data(using: .utf8)!
                .hmacSHA256(key: JWT_SECRET)
                .base64URLEncodedString()
            
            let token = "\(headerBase64).\(payloadBase64).\(signature)"
            completion(.success(token))
        }
    }
    func debugToken(_ token: String) {
        print("\n🔍 Debugging Token:")
        let parts = token.components(separatedBy: ".")
        
        if parts.count == 3 {
            if let headerData = Data(base64URLEncoded: parts[0]),
               let header = try? JSONSerialization.jsonObject(with: headerData) as? [String: Any] {
                print("Header:", header)
            }
            
            if let payloadData = Data(base64URLEncoded: parts[1]),
               let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                print("Payload:", payload)
                
                if let exp = payload["exp"] as? TimeInterval {
                    let expirationDate = Date(timeIntervalSince1970: exp)
                    print("Expiration Date:", expirationDate)
                    print("Current Date:", Date())
                    print("Time Until Expiration:", expirationDate.timeIntervalSinceNow, "seconds")
                }
            }
        } else {
            print("Invalid token format")
        }
    }
    
    enum JWTError: Error {
        case encodingFailed
        case invalidToken
        case expired
    }

    
    func saveToken(_ token: String) {
        guard verifyToken(token) else {
            print("Invalid token - not saving")
            return
        }
        
        DispatchQueue.main.async {
            self.currentToken = token
            UserDefaults.standard.set(token, forKey: self.tokenKey)
        }
    }
    
    func getToken() -> String? {
        guard let token = currentToken, verifyToken(token) else {
            // Token is invalid or expired, clear it
            return nil
        }
        return token
    }
    
    func isTokenExpired(_ token: String) -> Bool {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3,
              let payloadData = Data(base64URLEncoded: parts[1]),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let expiration = payload["exp"] as? TimeInterval else {
            print("❌ Could not decode token for expiration check")
            return true
        }
        
        let isExpired = Date().timeIntervalSince1970 >= expiration
        let expirationDate = Date(timeIntervalSince1970: expiration)
        print("⏰ Token Expiration Check:")
        print("Expiration Date:", expirationDate)
        print("Current Date:", Date())
        print("Is Expired:", isExpired)
        
        return isExpired
    }

    
    func clearToken() {
        DispatchQueue.main.async {
            self.currentToken = nil
            UserDefaults.standard.removeObject(forKey: self.tokenKey)
        }
    }
}

// Extensions for Base64URL encoding/decoding
extension Data {
    func base64URLEncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    init?(base64URLEncoded string: String) {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        while base64.count % 4 != 0 {
            base64 += "="
        }
        
        self.init(base64Encoded: base64)
    }
    
    func hmacSHA256(key: String) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let keyData = key.data(using: .utf8)!
        
        keyData.withUnsafeBytes { keyPtr in
            self.withUnsafeBytes { dataPtr in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
                      keyPtr.baseAddress, keyData.count,
                      dataPtr.baseAddress, self.count,
                      &digest)
            }
        }
        return Data(digest)
    }
}


