//
//  userPassword.swift
//  JobsMatch
//
//  Created by ivans Android on 6/26/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
//import FirebaseMessaging
import SendbirdUIKit
import SendbirdChatSDK
import JWTDecode

extension UIApplication {
    /// Helper function to dismiss the keyboard
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct userPassword: View {
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var authService: AuthService
    @StateObject private var jwtManager = JWTManager.shared
    @State private var password = ""
    @State private var passwordCheck = ""
    @State private var navigateToCompletionView = false
    @State private var isLoading = false
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var checkingVerification = false
    @State private var isVerified = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var accountCreated = false
    @State private var showPrivacySheet = false
    
    var passwordsMatch: Bool {
        return !password.isEmpty && password == passwordCheck
    }
    
    // Define the password requirements
    var passwordLengthRequirement: Bool {
        return password.count >= 8
    }
    var passwordUppercaseRequirement: Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    var passwordLowercaseRequirement: Bool {
        return password.range(of: "[a-z]", options: .regularExpression) != nil
    }
    var passwordNumberRequirement: Bool {
        return password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    var allRequirementsMet: Bool {
        return passwordLengthRequirement && passwordUppercaseRequirement && passwordLowercaseRequirement && passwordNumberRequirement && passwordsMatch
    }
    
    private func handleSignUpError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.notificationMessage = "Error Creating Account: \(error.localizedDescription)"
            self.showNotification = true
            
            print("DEBUG: Error during sign up: \(error.localizedDescription)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.showNotification = false
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            VStack(spacing: 3){
                ZStack {
                    // HStack for the dismiss button aligned to the left
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                                .padding()
                        }
                        Spacer() // This pushes the button to the left
                    }
                    // Centered image
                    Image("WaveJustLogoWhite")
                        .resizable()
                        .frame(width: 150, height: 125)
                        .padding(.top)
                }
                .padding(.bottom)
                Spacer()
                Text("Let's Keep Things Secure")
                    .foregroundStyle(.black)
                    .font(Font.custom("helvetica-bold", size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .padding(.bottom,20)
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .font(Font.custom("helvetica", size: 14))
                    .padding(.horizontal, 12)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color.gray)
                    )
                    .padding(.horizontal, 35)
                
                ZStack(alignment: .trailing) {
                    SecureField("Password Check", text: $passwordCheck)
                        .autocapitalization(.none)
                        .font(Font.custom("helvetica", size: 14))
                        .padding(.horizontal, 12)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.gray)
                        )
                        .padding(.horizontal, 35)
                    
                    if passwordsMatch {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .padding(.trailing, 45)
                    } else {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.red)
                            .padding(.trailing, 45)
                    }
                }
                .padding(.top,10)
                // Password Requirements
                VStack(alignment: .leading, spacing: 5) {
                    Text("• Minimum 8 characters")
                        .foregroundColor(passwordLengthRequirement ? .clear : .black)
                    Text("• At least one uppercase letter")
                        .foregroundColor(passwordUppercaseRequirement ? .clear : .black)
                    Text("• At least one lowercase letter")
                        .foregroundColor(passwordLowercaseRequirement ? .clear : .black)
                    Text("• At least one number")
                        .foregroundColor(passwordNumberRequirement ? .clear : .black)
                }
                .font(Font.custom("helvetica", size: 12))
                .padding(.horizontal, 35)
                .padding()
                Spacer()
                
                Button(action: {
                    // Add validation before starting
                    guard validateResumeFile() else {
                        notificationMessage = "Please select a valid resume file"
                        showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showNotification = false
                            }
                        }
                        return
                    }
                    
                    isLoading = true
                    saveUserData5()
                    Task {
                        signUp(email: viewModel.email, password: password, full_name: viewModel.full_name)
                        contentViewModel.markAccountAsComplete()
                    }
                }) {
                    ZStack{
                        Text(isLoading ? "" : "Sign Up")
                            .font(Font.custom("helvetica-bold", size: 18))
                            .opacity(3)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 40)
                            .background(Color.black)
                            .opacity(allRequirementsMet ? 1.0 : 0.3)
                            .cornerRadius(10)
                            .padding()
                        
                        if isLoading {
                            CustomLoadingView(color: skyBlueColor.skyBlue)
                                .frame(width: 25, height: 25)
                        }
                    }
                    .padding()
                }
                .padding(.bottom,-40)
                .disabled(!allRequirementsMet || isLoading)
                
                VStack{
                    Text("By Clicking Sign Up, you agree to the Terms of Service and that you have read our Privacy Policy")
                        .font(Font.custom("helvetica-bold", size: 11))
                        .frame(width: 300, height: 40)
                        .multilineTextAlignment(.center)
                    Text("Privacy Policy")
                        .font(Font.custom("helvetica-bold", size: 13))
                        .foregroundColor(.black)
                        .underline()
                        .onTapGesture {
                            showPrivacySheet = true
                        }
                        .padding(.bottom)
                }
                .sheet(isPresented: $showPrivacySheet) {
                    termsOfService() // You might want to create a separate PrivacyPolicy view
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // Retrieve stored user data and set ViewModel properties
                let userData = UserDataManager.getUserName()
                viewModel.full_name = userData.full_name
                viewModel.email = userData.email
                _ = UserDataManager.getUserResume()
                let passwordData = UserDataManager.getUserPassword()
                viewModel.password = passwordData.password
            }
            if showNotification {
                VStack {
                    Spacer()
                    NotificationView2(message: notificationMessage)
                        .transition(.move(edge: .top))
                }
                .zIndex(1)
            }
        }
    }
    
    func saveUserData5() {
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    // Additional helper function to validate file before upload
    func validateResumeFile() -> Bool {
        guard let resumePath = UserDefaults.standard.string(forKey: "resumePath") else {
            print("❌ No resume path in UserDefaults")
            return false
        }
        
        let resumeURL: URL
        if resumePath.hasPrefix("file://") {
            guard let fileURL = URL(string: resumePath) else {
                print("❌ Invalid file URL: \(resumePath)")
                return false
            }
            resumeURL = fileURL
        } else {
            resumeURL = URL(fileURLWithPath: resumePath)
        }
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: resumeURL.path) else {
            print("❌ File does not exist at: \(resumeURL.path)")
            return false
        }
        
        // Check file size (optional - set reasonable limits)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: resumeURL.path)
            if let fileSize = attributes[.size] as? NSNumber {
                let sizeInMB = fileSize.doubleValue / (1024 * 1024)
                print("📊 File size: \(String(format: "%.2f", sizeInMB)) MB")
                
                if sizeInMB > 10 { // 10MB limit
                    print("❌ File too large: \(sizeInMB) MB")
                    return false
                }
            }
        } catch {
            print("❌ Cannot get file attributes: \(error)")
            return false
        }
        
        // Try to read the file
        do {
            let _ = try Data(contentsOf: resumeURL)
            print("✅ File is readable")
            return true
        } catch {
            print("❌ Cannot read file: \(error)")
            return false
        }
    }
    
    func signUp(email: String, password: String, full_name: String) {
        // Ensure we have a consistent UUID - either reuse existing or create new
        let customUserId = UserDefaults.standard.string(forKey: "user_uuid") ?? UUID().uuidString
        // Always save/update the UUID in UserDefaults to ensure consistency
        UserDefaults.standard.set(customUserId, forKey: "user_uuid")
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.notificationMessage = "Error Creating Account, Please Return"
                    print("error message 1")
                    print("DEBUG error creating an account: \(error.localizedDescription)")
                    print("DEBUG 2 error creating an account: \(error)")
                    self.showNotification = true
                    self.isLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showNotification = false
                        }
                    }
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.notificationMessage = "Error Creating Account, Please Return"
                    print("error message 2")
                    self.showNotification = true
                    self.isLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showNotification = false
                        }
                    }
                }
                return
            }
            
            // After successful authentication, generate the JWT
            JWTManager.shared.generateJWTToken(userId: customUserId, email: email) { result in
                switch result {
                case .success(let token):
                    // Save the JWT token
                    JWTManager.shared.saveToken(token)
                    print("Token is \(token)")
                    
                    // Upload resume using the consistent UUID
                    self.uploadResume(for: customUserId) { downloadURL in
                        guard let resumeURL = downloadURL else {
                            // Handle error
                            print("Failed to upload resume")
                            DispatchQueue.main.async {
                                self.isLoading = false
                                self.notificationMessage = "Failed to upload resume"
                                self.showNotification = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.showNotification = false
                                    }
                                }
                            }
                            return
                        }
                        
                        let db = Firestore.firestore()
                        var userData: [String: Any] = [
                            "full_name": viewModel.full_name,
                            "email": viewModel.email,
                            "address": viewModel.address,
                            "work_eligibility": viewModel.work_eligibility,
                            "education": viewModel.education,
                            "disability_status": viewModel.disability_status,
                            "military_status": viewModel.military_status,
                            "jobs_applied": viewModel.jobs_applied,
                            "jobs_rejected": viewModel.jobs_rejected,
                            "saved_jobs": viewModel.saved_jobs,
                            "google_uid": user.uid,
                            "links": viewModel.links,
                            "skills": viewModel.skills,
                            "user_bio": viewModel.user_bio,
                            "resume": resumeURL
                        ]
                        
                        userData = setExperience(userData: userData, viewModel: viewModel)
                        
                        // Use the consistent custom UUID as document ID in Firestore
                        db.collection("jobseekers").document(customUserId).setData(userData) { error in
                            if let error = error {
                                print("DEBUG: ERROR SIGNING UP\(error)")
                                print("error message 3")
                                DispatchQueue.main.async {
                                    self.notificationMessage = "Error Creating Account, Please Return"
                                    self.showNotification = true
                                    self.isLoading = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            self.showNotification = false
                                        }
                                    }
                                }
                            } else {
                                self.authService.userSession = user
                                // Use custom UUID when fetching the user
                                self.authService.fetchCurrentUser(for: customUserId)
                                SendbirdManager.shared.connectUser(authService: authService)
                                
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    self.navigateToCompletionView = true
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed to generate JWT token: \(error)")
                    self.handleSignUpError(error)
                }
            }
        }
    }
    
    // Optional: Add additional validation here if needed
    private func setExperience(userData: [String: Any], viewModel: ViewModel) -> [String: Any] {
        var userData = userData
        
        let validExperiences = viewModel.experience.filter {
            !$0.values.allSatisfy { value in value.isEmpty }
        }
        
        if validExperiences.isEmpty {
            userData["experience"] = []
        } else {
            userData["experience"] = validExperiences
        }
        
        return userData
    }
    
    // Fixed uploadResume function with better error handling and validation
    func uploadResume(for userId: String, completion: @escaping (String?) -> Void) {
        print("🔄 Starting resume upload for user: \(userId)")
        
        // 1. Check if the resume exists locally
        guard let resumePath = UserDefaults.standard.string(forKey: "resumePath") else {
            print("❌ No resume path found in UserDefaults")
            DispatchQueue.main.async {
                self.notificationMessage = "Resume Not Found, Please Return"
                self.showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.showNotification = false
                    }
                }
            }
            completion(nil)
            return
        }
        
        print("📁 Resume path found: \(resumePath)")
        
        // 2. Create proper URL handling
        let resumeURL: URL
        if resumePath.hasPrefix("file://") {
            guard let fileURL = URL(string: resumePath) else {
                print("❌ Invalid file URL string: \(resumePath)")
                DispatchQueue.main.async {
                    self.notificationMessage = "Resume Not Found, Please Return"
                    self.showNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showNotification = false
                        }
                    }
                }
                completion(nil)
                return
            }
            resumeURL = fileURL
        } else {
            resumeURL = URL(fileURLWithPath: resumePath)
        }
        
        // 3. Validate file exists and get file data
        guard FileManager.default.fileExists(atPath: resumeURL.path) else {
            print("❌ File doesn't exist at path: \(resumeURL.path)")
            DispatchQueue.main.async {
                self.notificationMessage = "Resume File Not Found"
                self.showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.showNotification = false
                    }
                }
            }
            completion(nil)
            return
        }
        
        // 4. Validate file data can be read
        guard let fileData = try? Data(contentsOf: resumeURL) else {
            print("❌ Cannot read file data from: \(resumeURL.path)")
            DispatchQueue.main.async {
                self.notificationMessage = "Cannot Read Resume File"
                self.showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.showNotification = false
                    }
                }
            }
            completion(nil)
            return
        }
        
        print("✅ File validation passed. File size: \(fileData.count) bytes")
        
        let fileName = resumeURL.lastPathComponent
        print("📄 Uploading file: \(fileName)")
        
        // 5. Setup Firebase Storage with better configuration
        let storage = Storage.storage()
        let storageRef = storage.reference().child("resumes/\(userId)/\(fileName)")
        
        // Create metadata with proper content type
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        metadata.customMetadata = [
            "userId": userId,
            "uploadTimestamp": "\(Date().timeIntervalSince1970)"
        ]
        
        // 6. Upload using data instead of file URL to avoid path issues
        let uploadTask = storageRef.putData(fileData, metadata: metadata) { metadata, error in
            if let error = error {
                print("❌ Firebase Storage upload error: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                
                // Handle specific error types
                if let storageError = error as NSError? {
                    switch storageError.code {
                    case StorageErrorCode.cancelled.rawValue:
                        print("Upload was cancelled")
                    case StorageErrorCode.invalidArgument.rawValue:
                        print("Invalid argument provided")
                    case StorageErrorCode.quotaExceeded.rawValue:
                        print("Storage quota exceeded")
                    case StorageErrorCode.unauthenticated.rawValue:
                        print("User is not authenticated")
                    case StorageErrorCode.unauthorized.rawValue:
                        print("User is not authorized")
                    default:
                        print("Unknown storage error: \(storageError.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.notificationMessage = "Upload Failed: \(error.localizedDescription)"
                    self.showNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.showNotification = false
                        }
                    }
                }
                completion(nil)
                return
            }
            
            print("✅ Firebase Storage upload successful")
            
            // 7. Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error getting download URL: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.notificationMessage = "Error Getting Download URL"
                        self.showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.showNotification = false
                            }
                        }
                    }
                    completion(nil)
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    print("❌ Download URL is nil")
                    DispatchQueue.main.async {
                        self.notificationMessage = "Download URL Error"
                        self.showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.showNotification = false
                            }
                        }
                    }
                    completion(nil)
                    return
                }
                
                print("✅ Download URL obtained: \(downloadURL)")
                
                // Save to UserDefaults
                UserDefaults.standard.set(downloadURL, forKey: "resume")
                UserDataManager.saveResume(downloadURL)
                
                // 8. Upload to FastAPI
                self.uploadToFastAPI(fileData: fileData, fileName: fileName, userId: userId, firebaseURL: downloadURL) { result in
                    switch result {
                    case .success:
                        print("✅ Successfully uploaded to FastAPI")
                        completion(downloadURL)
                        
                    case .failure(let error):
                        print("❌ Failed to upload to FastAPI: \(error.localizedDescription)")
                        // Still return the Firebase URL even if FastAPI fails
                        completion(downloadURL)
                    }
                }
            }
        }
        
        // Monitor upload progress (optional)
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("📊 Upload progress: \(percentComplete)%")
        }
    }
    
    // Updated FastAPI upload function with better error handling
    func uploadToFastAPI(fileData: Data, fileName: String, userId: String, firebaseURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🚀 Starting FastAPI upload for user: \(userId)")
        
        guard let apiURL = URL(string: "https://jobsmatch.io/api/jobseekers/embedResume") else {
            print("❌ Invalid API URL")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Get and validate JWT token
        guard let jwtToken = JWTManager.shared.getToken() else {
            print("❌ No JWT token available")
            completion(.failure(JWTManager.JWTError.invalidToken))
            return
        }
        
        // Check if token is expired before making request
        if JWTManager.shared.isTokenExpired(jwtToken) {
            print("❌ JWT token is expired")
            JWTManager.shared.clearToken()
            completion(.failure(JWTManager.JWTError.expired))
            return
        }
        
        print("✅ JWT token validated")
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0 // Increase timeout for large files
        
        // Set headers
        let authHeader = "Bearer \(jwtToken)".trimmingCharacters(in: .whitespaces)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Build multipart form data
        var body = Data()
        
        // Add user_id field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        
        // Add firebase_url field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"firebase_url\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(firebaseURL)\r\n".data(using: .utf8)!)
        
        // Add resume file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📦 Request prepared. Body size: \(body.count) bytes")
        print("🔗 API URL: \(apiURL.absoluteString)")
        print("👤 User ID: \(userId)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            // Log response data for debugging
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response body: \(responseString)")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ FastAPI upload successful")
                DispatchQueue.main.async {
                    self.contentViewModel.hasFinishedUploadingResume = true
                    self.contentViewModel.isSigningUp = false
                }
                completion(.success(()))
                
            case 401:
                print("❌ Authentication failed (401)")
                JWTManager.shared.clearToken() // Clear invalid token
                completion(.failure(JWTManager.JWTError.expired))
                
            case 403:
                print("❌ Authorization failed (403)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Error details: \(errorResponse)")
                }
                completion(.failure(JWTManager.JWTError.expired))
                
            case 413:
                print("❌ File too large (413)")
                completion(.failure(NSError(domain: "APIError", code: 413, userInfo: [NSLocalizedDescriptionKey: "File size too large"])))
                
            case 422:
                print("❌ Validation error (422)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    print("Validation error details: \(errorResponse)")
                    completion(.failure(NSError(domain: "APIError", code: 422, userInfo: [NSLocalizedDescriptionKey: errorResponse])))
                } else {
                    completion(.failure(NSError(domain: "APIError", code: 422, userInfo: [NSLocalizedDescriptionKey: "Validation error"])))
                }
                
            case 500...599:
                print("❌ Server error (\(httpResponse.statusCode))")
                completion(.failure(NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                
            default:
                print("❌ Unexpected status code: \(httpResponse.statusCode)")
                if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse])))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        }
        
        task.resume()
    }
}

// Extension for AuthService to handle Google Sign-In with consistent UUID
extension AuthService {
    func signInWithGoogle(credential: AuthCredential, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        // Get or create a consistent UUID
        let customUserId = UserDefaults.standard.string(forKey: "user_uuid") ?? UUID().uuidString
        UserDefaults.standard.set(customUserId, forKey: "user_uuid")
        
        // Sign in with Google credential
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in with Google"])))
                return
            }
            
            // Update the user session
            self.userSession = user
            
            // Link Firebase auth user to our custom UUID in Firestore
            let db = Firestore.firestore()
            db.collection("jobseekers").document(customUserId).getDocument { snapshot, error in
                if let error = error {
                    print("Error checking for existing user: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists {
                    // Update existing user with Google auth info
                    db.collection("jobseekers").document(customUserId).updateData([
                        "google_uid": user.uid,
                        "email": user.email ?? ""
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.fetchCurrentUser(for: customUserId)
                            completion(.success(user))
                        }
                    }
                } else {
                    // Create a new user document with the custom UUID
                    let userData: [String: Any] = [
                        "full_name": user.displayName ?? "",
                        "email": user.email ?? "",
                        "google_uid": user.uid,
                        "jobs_applied": [],
                        "jobs_rejected": [],
                        "saved_jobs": []
                    ]
                    
                    db.collection("jobseekers").document(customUserId).setData(userData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.fetchCurrentUser(for: customUserId)
                            completion(.success(user))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    userPassword()
}













